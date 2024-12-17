#!/bin/perl

package pair;

sub new
{
	my $class = shift;
	my $self = {
		_first => shift,
		_second => shift,
	};

	bless $self, $class;
	return $self;
}

sub set
{
	my ($self, $first, $second) = @_;
	$self->{_first} = $first if defined($first);
	$self->{_second} = $second if defined($second);
}

sub setFirst
{
	my ($self, $first) = @_;
	$self->{_first} = $first if defined($first);
}

sub setSecond
{
	my ($self, $second) = @_;
	$self->{_second} = $second if defined($second);
}

sub first
{
	my ($self) = @_;
	return $self->{_first};
}

sub second
{
	my ($self) = @_;
	return $self->{_second};
}


1;
