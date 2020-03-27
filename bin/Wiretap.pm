#!/usr/bin/perl -w
use strict;

package Wiretap;

sub wiretap {
    use Time::HiRes;
    my $envtape = shift;
    my $intape = shift;
    my $outtape = shift;
    my $errtape = shift;

    # Dump the environment
    #
    if ($envtape) {
	if (open TAPE, '>', $envtape) {
	    use Data::Dumper;
	    print TAPE Dumper(\%ENV);
	    close(TAPE);
	}
	else { warn "open($envtape): $!\n"; }
    }

    # Tap STDIN
    #
    if ($intape) {
	if (open TAPE, '>', $intape) {
	    pipe(\*INPIPEREAD, \*INPIPEREAD);
	    if (my $pid = fork()) {
		close(INPIPEWRITE);
		close(TAPE);
		close(STDIN);
		open(STDIN, "<&INPIPEREAD");
	    }
	    else {
		$SIG{PIPE} = $SIG{INT} = $SIG{TERM} = sub { close(TAPE); exit(0); };
		$0 = "$0 (intape)";
		select(INPIPEREAD);
		$|=1;
		while (<STDIN>) {
		    printf TAPE "%0.9f < %s", Time::HiRes::time(), $_;
		    print;
		}
		close(TAPE);
		exit;
	    }
	}
	else { warn "open($intape): $!\n"; }
    }

    # Tap STDOUT
    #
    if ($outtape) {
	if (open TAPE, '>', $outtape) {
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
		close(OUTPIPEREAD);
		close(TAPE);
		exit;
	    }
	}
	else { warn "open($intape): $!\n"; }
    }

    # Tap STDERR
    #
    if ($errtape) {
	if (open TAPE, '>', $errtape) {
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
	else { warn "open($errtape): $!\n"; }
    }
}

1;
