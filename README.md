# Wiretap

Copy ENV, STDIN, STDOUT and STDERR to files for debuging

Synopsis: Wiretap::wiretap list

Parameters:
File name for the copy of ENV, STDIN, STDOUT and STDERR respectively.

Copy is disabled for file names that evaluates to false in perl.

Usage example:

    #!/usr/bin/perl
    use Wiretap;
    Wiretap::wiretap (
	"/tmp/wiretap-$$-ENV",
	"/tmp/wiretap-$$-STDIN",
	"/tmp/wiretap-$$-STDOUT",
	"/tmp/wiretap-$$-STDERR",
	);

The corresponding source is wiretapped from that on.
