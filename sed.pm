#!/bin/perl

package sed;
require "match_lines.pm";

$_match_lines = match_lines->new();

$match_default = sub
{
	return 0;
};

$match = sub
{
	return $_ =~ /$match_str/;
};

$match_e = sub
{
	my $pair = $_match_lines->getPair();
	my $match_line_begin = $pair->first();
	if ($. > $match_line_begin)
	{
		return $_ =~ /$match_str/;
	}
	return 0;
};

$match_b1 = sub
{
	my $pair = $_match_lines->getPair();
	my $match_line_begin = $pair->first();
	my $match_line_end = $pair->second();
	if ($. < $match_line_begin || $. > $match_line_end)
	{
		return 0;
	}
	return $_ =~ /$match_str/;
};

$match_e1 = $match_b1;

$match_r = sub
{
	my $pair = $_match_lines->getPair();
	my $match_line_begin = $pair->first();
	my $match_line_end = $pair->second();
	if ($. < $match_line_begin || $. > $match_line_end)
	{
		return 0;
	}
	if ($. == $match_line_end)
	{
		$_match_lines->addIndex();
	}
	return $_ =~ /$match_str/;
};

$replace_s = sub
{
	return $_ =~ s/$match_str/$new_str/g;
};

$replace_i = sub
{
	return $_ =~ s/$match_str/$&$new_str/g;
};

$run_a = sub
{
	$_ = $_.$next_line.$new_str;
};

$run_O = sub
{
	$_ = $new_str.$next_line.$_;
};

$run_b = sub
{
	my ($line) = @_;
	$_match_lines->pushPair($line, 0);
	print "run_b ";
	$_match_lines->print();
};

$run_b1 = sub
{
	my ($line) = @_;
	$_match_lines->setFirst($line);
	print "run_b1 ";
	$_match_lines->print();
};

$run_e = sub
{
	my ($line) = @_;
	$_match_lines->setSecond($line);
	print "run_e ";
	$_match_lines->print();
	$_match_lines->addIndex();
};

$run_e1 = sub
{
	my ($line) = @_;
	$_match_lines->setSecond($line);
	print "run_e1 ";
	$_match_lines->print();
	$_match_lines->addIndex();
};

$run_default = sub
{
};

$run_d = sub
{
	$_ = "";
};

$run_getnum = sub
{
	$ret_value = 0;
	if ($_ =~ /(\d+)/)
	{
		$ret_value = $1;
	}
};

$add_match = sub
{
	$_match_count++;
};


my $runbase = sub
{
	my ($match_func, $run_special_func) = @_;
	open(infile, "<$path") or die "can not read $path";
	my @file = ();
	my $next_line = "\n";
	my @change_line = ();
	while(<infile>)
	{
		if ($match_func->())
		{
			if ($line_offset != 0 || $total_match_count != 0)
			{
				my $match_line = $. + $line_offset - 1;
				push @change_line, $match_line;
			}
			else
			{
				$run_special_func->($.);
			}
		}
		push @file, $_;
	}
	close(infile);

	my $change_line_func = sub
	{
		my $change_line_size = @change_line;
		if ($change_line_size == 0)
		{
			return;
		}

		my $change_index = 0;
		if ($total_match_count < 0)
		{
			$change_index = $change_line_size + $total_match_count;
		}
		elsif ($total_match_count > 0)
		{
			$change_index = $total_match_count - 1;
		}

		if ($change_index < 0 || $change_index >= $change_line_size)
		{
			print "change_index out of range index[$change_index] size[$change_line_size] total_match_count[$total_match_count] match_str[$match_str] path[$path]\n";
			return;
		}

		my $file_size = @file;
		for ($i = $change_index; $i < $change_line_size; $i++)
		{
			my $line_index = $change_line[$i];
			if ($line_index < 0 || $line_index >= $file_size)
			{
				print "line out of range index[$line_index] size[$file_size] line_offset[$line_offset] match_str[$match_str] path[$path]\n";
				last;
			}

			$_ = $file[$line_index];
			my $line = $line_index + 1;
			$run_special_func->($line);
			$file[$line_index] = $_;

			if ($total_match_count != 0)
			{
				last;
			}
		}
	};
	$change_line_func->();

	open(outfile, ">$path") or die "can not write $path";
	print outfile @file;
	close(outfile);
};

sub run
{
	($total_match_count, $line_offset, $type, $match_str, $new_str, $path) = @_;

	my $match_func = $match;
	my $pair = $_match_lines->getPair();
	if ($pair->first() > 0 && $pair->second() > 0)
	{
		$match_func = $match_r;
	}

	if ($type eq "a")
	{
		$runbase->($match_func, $run_a);
	}
	elsif ($type eq "O")
	{
		$runbase->($match_func, $run_O);
	}
	elsif ($type eq "s")
	{
		$runbase->($match_func, $replace_s);
	}
	elsif ($type eq "i")
	{
		$runbase->($match_func, $replace_i);
	}
	elsif ($type eq "d")
	{
		$runbase->($match_func, $run_d);
	}
	elsif ($type eq "n")
	{
		$runbase->($match_func, $run_getnum);
	}
	elsif ($type eq "m")
	{
		$_match_count = 0;
		$runbase->($match_func, $add_match);
	}
	elsif ($type eq "b")
	{
		$_match_lines->clear();
		$runbase->($match, $run_b);
	}
	elsif ($type eq "e")
	{
		$runbase->($match_e, $run_e);
		$_match_lines->resetIndex();
	}
	elsif ($type eq "b1")
	{
		$runbase->($match_b1, $run_b1);
	}
	elsif ($type eq "e1")
	{
		$runbase->($match_e1, $run_e1);
		$_match_lines->resetIndex();
	}
	else
	{
		$runbase->($match_default, $run_default);
	}

	if ($type ne "b" && $type ne "e" && $type ne "b1" && $type ne "e1" && $_match_lines->size() > 0)
	{
		$_match_lines->clear();
	}
}

sub all
{
	my ($line_offset, $type, $match_str, $new_str, $path) = @_;
	run(0, $line_offset, $type, $match_str, $new_str, $path);
}

sub first
{
	my ($line_offset, $type, $match_str, $new_str, $path) = @_;
	run(1, $line_offset, $type, $match_str, $new_str, $path);
}

sub last
{
	my ($line_offset, $type, $match_str, $new_str, $path) = @_;
	run(-1, $line_offset, $type, $match_str, $new_str, $path);
}

sub getnum
{
	my ($total_match_count, $match_str, $path) = @_;
	run($total_match_count, 0, "m", $match_str, "", $path);
	return $ret_value;
}

sub changeNum
{
	my ($number_diff, $match_str, $path) = @_;
	open(infile, "<$path") or die "can not read $path";
	my @file = ();
	while (<infile>)
	{
		if (/$match_str/)
		{
			if ($_ =~ /(\d+)/)
			{
				my $num = $1;
				$num = $num + $number_diff;
				$_ =~ s/(.*?)\d+/$1$num/;
			}
			else
			{
				print "changeNum $match_str no number at $path\n";
			}
		}
		push @file, $_;
	}
	close(infile);

	open(outfile, ">$path") or die "can not write $path";
	print outfile @file;
	close(outfile);
}

sub matchCount
{
	my ($match_str, $path) = @_;
	run(1, 0, "m", $match_str, "", $path);
	return $_match_count;
}

sub writefile
{
	my ($path, $file_contents) = @_;
	`touch $path`;
	open(outfile, ">$path") or die "can not write $path";
	print outfile $file_contents;
	close(outfile);
}

1
