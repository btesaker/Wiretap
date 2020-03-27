# Wiretap

Copy ENV, STDIN, STDOUT and STDERR to files for debuging. 

Synopsis: Wiretap::wiretap list

## Parameters:
Files for the copy of ENV, STDIN, STDOUT and STDERR respectively, either
- a file name
- a list ref handed to open(), starting with mode
- a false value for no copy

## Usage example:

    #!/usr/bin/perl
    use Wiretap;
    Wiretap::wiretap (
	"/tmp/wiretap-ENV",
	"",
	[">>", "/tmp/wiretap-STDOUT"],
	["|-", "/local/bin/someprocess", "-someoptions"],
	);

The corresponding source is wiretapped from that on:
- %ENV is written to "/tmp/wiretap-ENV"
- STDIN is not copied
- STDOUT is appended to "/tmp/wiretap-STDOUT"
- STDERR is piped into the command "/local/bin/someprocess -someoptions"

## Formats
The environment is written with Data::Dumper::Dumper

The file streams is prefixed with Time::HiRes::time() and " < ", " > " " # " respectively.

## Bugs and limitations

This module is linebased and not suited for binary streams.
