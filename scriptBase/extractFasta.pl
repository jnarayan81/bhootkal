#!/usr/bin/perl

use strict;
use warnings;

$ARGV[2] or die "use extractSeq.pl LIST FASTA OUT threshold\n";

my $list = shift @ARGV;
my $fasta = shift @ARGV;
my $out = shift @ARGV;
my $threshold = shift @ARGV;
my %select;

open L, "$list" or die;
while (<L>) {
    chomp;
    #s/>//g;
    my @tmpVal = split '\t', $_;
    next if $tmpVal[-1] <= $threshold;
    $select{$tmpVal[3]} = 1;
}
close L;

local $/ = "\n>";  # read by FASTA record
open O, ">$out" or die;
open F, "$fasta" or die;

while (my $seq = <F>) {
    #chomp $seq;
    $seq =~ s/>//g ;
    my ($id) = $seq =~ /^>*(\S+)/;  # parse ID as first word in FASTA header
    print O ">$seq" if (defined $select{$id});
}
close F;
close O;
