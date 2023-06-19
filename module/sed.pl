#!/bin/perl

if ($^O eq "msys" || $^O eq "MSWin32")
{
	push(@INC, ".");
}

require "../sed.pm";
require "../config.pm";
require "config.pl";
require "str.pl";

#if (-e $module_dir)
#{
#	print "$module_dir already exist\n";
#	exit;
#}

$file_name = "$module_hpp";
$match_str = "num";
sed::changeNum(1, $match_str, $file_name);
$num = sed::getnum(1, $match_str, $file_name);
print $num . "\n";

$match_str = "all";
sed::all(0, "a", $match_str, $module_all, $file_name);
sed::all(-1, "a", $match_str, $module_all, $file_name);
sed::all(1, "a", $match_str, $module_all, $file_name);

$match_str = "first";
sed::first(0, "a", $match_str, $module_first, $file_name);
sed::first(-1, "a", $match_str, $module_first, $file_name);
sed::first(1, "a", $match_str, $module_first, $file_name);

$match_str = "last";
sed::last(0, "a", $match_str, $module_last, $file_name);
sed::last(-1, "a", $match_str, $module_last, $file_name);
sed::last(1, "a", $match_str, $module_last, $file_name);

$file_name = "$module_cpp";
sed::writefile($file_name, $module_content_cpp);
