#!/bin/perl

package xml;
require "sed.pm";

sub Replace1
{
	my ($match_str, $new_str, $path) = @_;
	$match_str_xml = "<${match_str}>.*?</${{match_str}>";
	$replace_str = "<${match_str}>${new_str}</${{match_str}>";
	sed::all(0, 's', $match_str_xml, $replace_str, $path);
}

sub Replace2
{
	my ($match_str, $match_str2, $new_str, $path) = @_;
	sed::all(0, 'b', "<${match_str}>", "", $path);
	sed::all(0, 'e', "</${match_str}>", "", $path);
	$match_str_xml = "<${match_str2}>.*?</${{match_str2}>";
	$replace_str = "<${match_str2}>${new_str}</${{match_str2}>";
	sed::all(0, 's', $match_str_xml, $replace_str, $path);
}

sub Replace2First
{
	my ($total_match_count, $match_str, $match_str2, $new_str, $path) = @_;
	sed::run($total_match_count, 0, 'b', "<${match_str}>", "", $path);
	sed::first(0, 'e', "</${match_str}>", "", $path);
	$match_str_xml = "<${match_str2}>.*?</${{match_str2}>";
	$replace_str = "<${match_str2}>${new_str}</${{match_str2}>";
	sed::all(0, 's', $match_str_xml, $replace_str, $path);
}

sub Replace3
{
	my ($match_str, $match_str2, $match_str2, $new_str, $path) = @_;
	sed::all(0, 'b', "<${match_str}>", "", $path);
	sed::all(0, 'e', "</${match_str}>", "", $path);
	sed::all(0, 'b1', "<${match_str2}>", "", $path);
	sed::all(0, 'e1', "</${match_str2}>", "", $path);
	$match_str_xml = "<${match_str3}>.*?</${{match_str3}>";
	$replace_str = "<${match_str3}>${new_str}</${{match_str3}>";
	sed::all(0, 's', $match_str_xml, $replace_str, $path);
}

sub Delete1
{
	my ($match_str, $match_str2, $path) = @_;
	sed::all(0, 'b', "<${match_str}>", "", $path);
	sed::all(0, 'e', "</${match_str}>", "", $path);
	sed::all(0, 'd', $match_str2, "", $path);
}

sub Delete2
{
	my ($match_str, $match_str2, $path) = @_;
	sed::all(0, 'b', "<${match_str}>", "", $path);
	sed::all(0, 'e', "</${match_str}>", "", $path);
	sed::all(0, 'b1', "<${match_str2}>", "", $path);
	sed::all(0, 'e1', "</${match_str2}>", "", $path);
	sed::all(0, 'd', ".*", "", $path);
}

1;
