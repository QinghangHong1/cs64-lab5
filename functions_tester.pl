#!/usr/bin/perl -w

# tests the implementation in functions.asm

use strict;

# -Filename
# Returns a reference to an array of file contents
sub readFile($) {
    my $filename = shift();
    my $fh;
    open($fh, "<$filename") or die "Could not open file '$filename' for reading";
    my @contents = <$fh>;
    close($fh);
    return \@contents;
}

# -Array ref of file contents.  Assumes that newlines
#  are already contained within.
# -Filename to write to
sub writeFile($$) {
    my ($arrRef, $filename) = @_;
    my $fh;
    open($fh, ">$filename") or die "Could not open file '$filename' for writing";
    print $fh join('', @$arrRef);
    close($fh);
}

# -Patch to apply
# -What to patch
# -Patched filename
sub producePatchedFile($$$) {
    my ($toApply, $whatToPatch, $patchedFilename) = @_;
    my $stubRef = readFile($toApply);
    my $studentRef = readFile($whatToPatch);
    my @toWrite;

    # the file should start with the stub
    foreach my $line (@$stubRef) {
        push(@toWrite, $line);
    }

    my $inPayload = undef;
    # look for the COPYFROMHERE line
    foreach my $line (@$studentRef) {
        if ($inPayload) {
            push(@toWrite, $line);
        } elsif ($line =~ /^# COPYFROMHERE \- DO NOT REMOVE THIS LINE/) {
            push(@toWrite, '');
            $inPayload = 1;
        }
    }

    defined($inPayload) || die "File to patch didn't contain COPYFROMHERE line";
    
    writeFile(\@toWrite, $patchedFilename);
}

# -A command to execute
# Returns a reference to an array of elements, where
# each element isn't blank, with no newlines
sub commandOutputNoBlanks($) {
    my $command = shift();
    my @rawOutput = `$command`;
    my @retval;
    foreach my $item (@rawOutput) {
        chomp($item);
        if (defined($item) &&
            $item ne '') {
            push(@retval, $item);
        }
    }
    return \@retval;
}

# -Reference to array of command output
# -Reference to array of expected output
sub compareResults($$) {
    my ($commandRef, $expectedRef) = @_;
    my $commandLen = scalar(@$commandRef);
    my $expectedLen = scalar(@$expectedRef);
    my $commandPos = 0;
    my $expectedPos = 0;

    my $spLine = undef;
    my $sRegUseCount = 0;
    my $sRegLine = undef;
    
    while ($commandPos < $commandLen) {
        my $curCommand = $commandRef->[$commandPos];
        if ($curCommand =~ /^Loaded/) {
            $commandPos++;
        } elsif ($curCommand =~/^SP ENTER VALUE: (.*)$/) {
            if (!defined($spLine)) {
                $spLine = $1;
                $commandPos++;
            } else {
                print "UNEXPECTED MULTIPLE USE OF \$sp\n";
                return;
            }
        } elsif ($curCommand =~ /^S REGISTERS: (.*)$/) {
            if ($sRegUseCount == 0) {
                $sRegLine = $1;
                $sRegUseCount++;
                $commandPos++;
            } elsif ($sRegUseCount == 1) {
                if ($sRegLine ne $1) {
                    print "\$s* REGISTERS WERE MODIFIED\n";
                    print "\tOriginal values: $sRegLine\n";
                    print "\tNew values:      $1\n";
                    return;
                }
                $sRegUseCount++;
                $commandPos++;
            } else {
                print "UNEXPECTED MULTIPLE USE OF \$s* REGISTERS\n";
                return;
            }
        } elsif ($curCommand =~ /^SP EXIT VALUE: (.*)$/) {
            if (!defined($spLine)) {
                print "NO \$sp DEFINED\n";
                return;
            } elsif ($spLine ne $1) {
                print "\$sp WAS MODIFIED\n";
                print "\tOriginal value: $spLine\n";
                print "\tNew value:      $1\n";
                return;
            }
            $commandPos++;
        } else {
            if ($expectedPos < $expectedLen) {
                my $expected = $expectedRef->[$expectedPos];
                if ($curCommand ne $expected) {
                    print "OUTPUT MISMATCH:\n";
                    print "\tFound:    $curCommand\n";
                    print "\tExpected: $expected\n";
                    return;
                }
                $expectedPos++;
                $commandPos++;
            } else {
                print "HAD MORE OUTPUT THAN EXPECTED:\n";
                print "First extra line: $curCommand\n";
                return
            }
        }
    } # while

    if ($expectedPos != $expectedLen) {
        my $expected = $expectedRef->[$expectedPos];
        print "DID NOT HAVE ENOUGH OUTPUT:\n";
        print "First line of missing expected: $expected\n";
        return;
    } elsif ($sRegUseCount != 2) {
        print "DID NOT USE S REGISTERS ENOUGH\n";
        return;
    } elsif (!defined($spLine)) {
        print "DID NOT USE \$sp ENOUGH\n";
        return;
    }

    print "Test passed.  This is NOT comprehensive - do your own testing too!\n";
} # compareResults

# ---BEGIN MAIN CODE---

my @expected = ("-78",
                "My Convention Check",
                "45",
                "My Convention Check",
                "9",
                "My Convention Check",
                "453",
                "My Convention Check",
                "-223",
                "My Convention Check",
                "-1",
                "My Convention Check",
                "332",
                "My Convention Check",
                "-66",
                "My Convention Check",
                "123",
                "My Convention Check",
                "33",
                "My Convention Check",
                "0",
                "My Convention Check");

my $patchFileName = "functions_temp_ignore_me_testing.asm";
producePatchedFile("functions_testing_stub.asm",
                   "functions.asm",
                   $patchFileName);
my $outputRef = commandOutputNoBlanks("spim -file $patchFileName");
compareResults($outputRef, \@expected);
unlink($patchFileName);
