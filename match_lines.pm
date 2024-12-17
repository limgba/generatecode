#!/bin/perl

package match_lines;
require "pair.pm";

sub new
{
	my $class = shift;
	my $self = {
		_index => 0,
		_lines => [],
		@_,
	};

	bless $self, $class;
	return $self;
}

sub clear
{
	my ($self) = @_;
	$self->{_index} = 0;
	$self->{_lines} = [];
}

sub size
{
	my ($self) = @_;
	my $size = @{$self->{_lines}};
	return $size;
}

sub addIndex
{
	my ($self) = @_;
	my $size = @{$self->{_lines}};
	if ($self->{_index} >= $size)
	{
		return;
	}
	$self->{_index}++;
}

sub resetIndex
{
	my ($self) = @_;
	$self->{_index} = 0;
}

sub pushPair
{
	my ($self, $first, $second) = @_;
	my $p = pair->new($first, $second);
	push @{$self->{_lines}}, $p;
}

sub getPair
{
	my ($self) = @_;
	my $index = $self->{_index};
	my $size = @{$self->{_lines}};
	if ($index < 0 || $index >= $size)
	{
		$self->pushPair(0, 0);
		return $self->getPair();
	}
	return ${$self->{_lines}}[$index];
}

sub setFirst
{
	my ($self, $first) = @_;
	my $pair = $self->getPair();
	$pair->setFirst($first);
}

sub setSecond
{
	my ($self, $second) = @_;
	my $pair = $self->getPair();
	$pair->setSecond($second);
}


1;
