#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

use Devel::NanoJIT;

my $fragmento = Devel::NanoJIT::Fragmento->new();
my $buf = Devel::NanoJIT::LirBuffer->new($fragmento);

isa_ok($buf, "Devel::NanoJIT::LirBuffer");
