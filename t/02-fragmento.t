#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

use Devel::NanoJIT;

my $fragmento = Devel::NanoJIT::Fragmento->new();

isa_ok($fragmento, "Devel::NanoJIT::Fragmento");