#!/usr/bin/env perl
use strict;
use warnings;
use Benchmark qw(:hireswallclock cmpthese);
use List::Util qw(shuffle);

my @hostmask_patterns = map {
    sprintf('user%d!*@*.example%d.net', $_, $_ % 50)
} 1 .. 1500;

my @compiled_patterns = map {
    { mask => $_, regex => _compile($_) }
} @hostmask_patterns;

my @messages = map {
    my $i = $_ % 1500;
    sprintf('user%d!ident%d@dynamic-%d.example%d.net', $i, $i, $i % 300, $i % 50)
} 1 .. 500;

my @workload = shuffle(@messages);

sub naive_lookup {
    my ($fullmask) = @_;
    foreach my $mask (@hostmask_patterns) {
        my $regex = _compile($mask);
        return 1 if $fullmask =~ $regex;
    }
    return 0;
}

sub cached_lookup {
    my ($fullmask) = @_;
    foreach my $entry (@compiled_patterns) {
        next unless $entry->{regex};
        return 1 if $fullmask =~ $entry->{regex};
    }
    return 0;
}

print "Comparing naive vs cached hostmask resolution over " . scalar(@workload) . " messages...\n";
cmpthese(50, {
    naive  => sub { naive_lookup($_) for @workload },
    cached => sub { cached_lookup($_) for @workload },
});

sub _compile {
    my ($mask) = @_;
    return unless defined $mask && length $mask;
    my $regex = quotemeta $mask;
    $regex =~ s/\\\*/.*/g;
    $regex =~ s/\\\?/.?/g;
    return qr/^$regex/;
}
