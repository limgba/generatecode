#!/bin/perl

if ($^O eq "msys" || $^O eq "MSWin32")
{
	push(@INC, ".");
}

require "../sed.pm";
require "../config.pm";
require "config.pl";

$module_all = << "eof";
lla
eof

$module_first = << "eof";
tsrif
eof

$module_last = << "eof";
tsal
eof

$module_content_cpp = << "eof";
ffaa
eof
