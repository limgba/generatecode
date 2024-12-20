#!/bin/perl

require "xml_tool.pm";

my $path = "aa.xml";
#xml::replace1("aa", "3", $path);
#xml::replace2("aa", "bb", "4", $path);
xml::replace3("aa", "bb", "cc", "1", $path);
