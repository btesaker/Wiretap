#!/usr/bin/perl -w

# Wiretaping perl script
# See https://github.com/btesaker/Wiretap

use strict;

package Wiretap;

sub wiretap {
    use Time::HiRes;
    my $envtape = shift; $envtape = ['>', $envtape] if $envtape and ref($envtape) ne 'ARRAY';
    my $intape  = shift; $intape  = ['>', $intape]  if $envtape and ref($intape)  ne 'ARRAY';
    my $outtape = shift; $outtape = ['>', $outtape] if $envtape and ref($outtape) ne 'ARRAY';
    my $errtape = shift; $errtape = ['>', $errtape] if $envtape and ref($errtape) ne 'ARRAY';

    # Dump the environment
    #
    if ($envtape) {
	my $mode = shift(@$envtape);
	if (open TAPE, $mode, @$envtape) {
	    use Data::Dumper;
	    print TAPE Dumper(\%ENV);
	    close(TAPE);
	}
	else { warn "open($mode, @$envtape): $!\n"; }
    }

    # Tap STDIN
    #
    if ($intape) {
	my $mode = shift(@$intape);
	if (open TAPE, $mode, @$intape) {
	    pipe(\*INPIPEREAD, \*INPIPEWRITE);
	    if (my $pid = fork()) {
		close(INPIPEWRITE);
		close(TAPE);
		close(STDIN);
		open(STDIN, "<&INPIPEREAD");
	    }
	    else {
		close(INPIPEREAD);
		$SIG{PIPE} = $SIG{INT} = $SIG{TERM} = sub { close(TAPE); exit(0); };
		$0 = "$0 (intape)";
		select(INPIPEWRITE);
		$|=1;
		while (<STDIN>) {
		    printf TAPE "%0.9f < %s", Time::HiRes::time(), $_;
		    print;
		}
		close(TAPE);
		close(INPIPEWRITE);
		exit;
	    }
	}
	else { warn "open($mode, @$intape): $!\n"; }
    }

    # Tap STDOUT
    #
    if ($outtape) {
	my $mode = shift(@$outtape);
	if (open TAPE, $mode, @$outtape) {
	    pipe(\*OUTPIPEREAD, \*OUTPIPEWRITE);
	    if (my $pid = fork()) {
		close(OUTPIPEREAD);
		close(TAPE);
		close(STDOUT);
		open(STDOUT, ">&OUTPIPEWRITE");
	    }
	    else {
		close(OUTPIPEWRITE);
		$SIG{PIPE} = $SIG{INT} = $SIG{TERM} = sub { close(TAPE); exit(0); };
		$0 = "$0 (outtape)";
		select(STDOUT);
		$|=1;
		while (<OUTPIPEREAD>) {
		    printf TAPE "%0.9f > %s", Time::HiRes::time(), $_;
		    print;
		}
		close(TAPE);
		exit;
	    }
	}
	else { warn "open($mode, @$outtape): $!\n"; }
    }

    # Tap STDERR
    #
    if ($errtape) {
	my $mode = shift(@$errtape);
	if (open TAPE, $mode, @$errtape) {
	    pipe(\*ERRPIPEREAD, \*ERRPIPEWRITE);
	    if (my $pid = fork()) {
		close(ERRPIPEREAD);
		close(TAPE);
		close(STDERR);
		open(STDERR, ">&ERRPIPEWRITE");
	    }
	    else {
		$SIG{PIPE} = $SIG{INT} = $SIG{TERM} = sub { close(TAPE);  exit(0); };
		close(ERRPIPEWRITE);
		$0 = "$0 (errtape)";
		select(STDERR);
		$|=1;
		while (<ERRPIPEREAD>) {
		    printf TAPE "%0.9f # %s", Time::HiRes::time(), $_;
		    print;
		}
		close(TAPE);
		exit;
	    }
	}
	else { warn "open($mode, @$errtape): $!\n"; }
    }
}

1;
