#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

use Devel::NanoJIT;
use Devel::NanoJIT::Constants qw(:all);

my $fragmento = Devel::NanoJIT::Fragmento->new();
my $buf = Devel::NanoJIT::LirBuffer->new($fragmento);
my $w = Devel::NanoJIT::LirBufWriter->new($buf);

isa_ok($w, "Devel::NanoJIT::LirBufWriter");

my $ins = $w->ins0(LIR_start);

isa_ok($ins, "Devel::NanoJIT::LIns");