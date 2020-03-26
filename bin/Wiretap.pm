#!/usr/bin/perl -w
use strict;

package Wiretap;

sub wiretap {
    use FileHandle;
    use Time::HiRes;
    my $envtape = shift;
    my $intape = shift;
    my $outtape = shift;
    my $errtape = shift;

    # Dump the environment
    #
    if ($envtape) {
	my $tape = FileHandle->new;
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
	    my $piperead = FileHandle->new;
	    my $pipewrite = FileHandle->new;
	    pipe($piperead, $pipewrite);
	    if (my $pid = fork()) {
		close(TAPE);
		close(STDIN);
		open(STDIN, "<&", $piperead);
		eval "END { kill(15, $pid); wait; }";
	    }
	    else {
		$0 = "$0 (intape)";
		select($pipewrite);
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
	    my $piperead = FileHandle->new;
	    my $pipewrite = FileHandle->new;
	    pipe($piperead, $pipewrite);
	    if (my $pid = fork()) {
		close(TAPE);
		close(STDOUT);
		open(STDOUT, ">&", $pipewrite);
		eval "END { kill(15, $pid); wait; wait; }";
	    }
	    else {
		$0 = "$0 (outtape)";
		$SIG{TERM} = sub { close(TAPE); exit(0); };
		select(STDOUT);
		$|=1;
		while (<$piperead>) {
		    printf TAPE "%0.9f > %s", Time::HiRes::time(), $_;
		    print;
		}
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
	    my $piperead = FileHandle->new;
	    my $pipewrite = FileHandle->new;
	    pipe($piperead, $pipewrite);
	    if (my $pid = fork()) {
		close(TAPE);
		close(STDERR);
		open(STDERR, ">&", $pipewrite);
		eval "END { kill(15, $pid); wait; wait; }";
	    }
	    else {
		$0 = "$0 (errtape)";
		$SIG{TERM} = sub { close(TAPE); exit(0); };
		select(STDERR);
		$|=1;
		while (<$piperead>) {
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
