#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;
use Test::Exception;
use Test::Warn;

use Devel::NanoJIT;
use Devel::NanoJIT::Constants qw(:all);

my $fragmento = Devel::NanoJIT::Fragmento->new();
my $buf = Devel::NanoJIT::LirBuffer->new($fragmento);
my $fragment = Devel::NanoJIT::Fragment->new();
$fragment->set_root($fragment);
$fragment->set_lirbuf($buf);

my $w = Devel::NanoJIT::LirBufWriter->new($buf);
my $ins = $w->ins0(LIR_start);

my $five = $w->insImm(5);
my $three = $w->insImm(3);
my $result = $w->ins2(LIR_add, $five, $three);
$w->ins1(LIR_ret, $result);

for ("", "I;", "CC") {
    dies_ok {
        my $cv = compile($fragmento, $fragment, $w, $_);
    } "Invalid signature $_";
}

my $cv = compile($fragmento, $fragment, $w, ";i");

warning_is { compile($fragmento, $fragment, $w, ";v"); } "Fragment already compiled", "Warn if fragment is already compiled";

my $v = $cv->call();
is($v, 8);