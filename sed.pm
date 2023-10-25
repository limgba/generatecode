#!/bin/perl

package sed;

$match_default = sub
{
	return 0;
};

$match = sub
{
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
				$run_special_func->();
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

		my $line = $change_line[$change_index];
		my $file_size = @file;

		if ($line < 0 || $line >= $file_size)
		{
			print "line out of range index[$line] size[$file_size] line_offset[$line_offset] match_str[$match_str] path[$path]\n";
			return;
		}

		$_ = $file[$line];
		$run_special_func->();
		$file[$line] = $_;
	};
	$change_line_func->();

	open(outfile, ">$path") or die "can not write $path";
	print outfile @file;
	close(outfile);
};

sub run
{
	($total_match_count, $line_offset, $type, $match_str, $new_str, $path) = @_;

	if ($type eq "a")
	{
		$runbase->($match, $run_a);
	}
	elsif ($type eq "O")
	{
		$runbase->($match, $run_O);
	}
	elsif ($type eq "s")
	{
		$runbase->($match, $replace_s);
	}
	elsif ($type eq "i")
	{
		$runbase->($match, $replace_i);
	}
	elsif ($type eq "d")
	{
		$runbase->($match, $run_d);
	}
	elsif ($type eq "m")
	{
		$runbase->($match, $run_getnum);
	}
	else
	{
		$runbase->($match_default, $run_default);
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

sub writefile
{
	my ($path, $file_contents) = @_;
	`touch $path`;
	open(outfile, ">$path") or die "can not write $path";
	print outfile $file_contents;
	close(outfile);
}

1
