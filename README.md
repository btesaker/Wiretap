# Wiretap
Copy ENV, STDIN, STDOUT and STDERR to files for debuging

Takes four parameters, each filaames for the respective source. Specify empty string to disable a tap.

Usage example:

    #!/usr/bin/perl
    use Wiretap;
    Wiretap::wiretap (
	"/tmp/wiretap-$$-ENV",
	"/tmp/wiretap-$$-STDIN",
	"/tmp/wiretap-$$-STDOUT",
	"/tmp/wiretap-$$-STDERR",
	);

