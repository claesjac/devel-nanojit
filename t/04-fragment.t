#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use Devel::NanoJIT;

my $fragmento = Devel::NanoJIT::Fragmento->new();
my $buf = Devel::NanoJIT::LirBuffer->new($fragmento);

my $fragment = Devel::NanoJIT::Fragment->new();
isa_ok($fragment, "Devel::NanoJIT::Fragment");

is($fragment->root, undef);
is($fragment->lirbuf, undef);

$fragment->set_lirbuf($buf);
$fragment->set_root($fragment);