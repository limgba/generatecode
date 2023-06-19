#!/bin/perl

package config;

$class_name="test";
$note="test";
$root="/root/perl";
$author_name="limgba";

($file_name = $class_name) =~ s/$class_name/\L$&/;

$def_name = $class_name;
$def_name =~ s/[A-Z]/_$&/g;
$def_name =~ s/^_//g;
$def_name =~ s/_+/_/g;
$def_name =~ s/.*/\U$&/g;

$var_name = $class_name;
$var_name =~ s/[A-Z]/_\L$&/g;
$var_name =~ s/^_/m_/g;
$var_name =~ s/_+/_/g;

$xml_name = $class_name;
$xml_name =~ s/[A-Z]/_\L$&/g;
$xml_name =~ s/^_//g;
$xml_name =~ s/_+/_/g;

1;
