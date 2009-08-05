use 5.008008;
use ExtUtils::MakeMaker;
use File::Spec;
use File::Path qw(mkpath);
use Config;

use strict;

my $CC = 'g++ -O';

my @files = qw(
    Assembler.o
    avmplus.o
    Fragmento.o
    LIR.o
    NanoJIT.o
    RegAlloc.o
);

my $myarchname = $Config{myarchname};

my $avmplus_arch;
if ($myarchname =~ /^(i386|i686|i86pc)-/) {
    $avmplus_arch = "AVMPLUS_IA32";
    push @files, "Nativei386.o";
}
elsif ($myarchname =~ /^sun4-/) {
    $avmplus_arch = "AVMPLUS_SPARC";
    push @files, "NativeSparc.o";
}
else {
    die "Unsupported architecture: '${myarchname}'";
}
# Generate LIR opcode constants
open(my $in, "cpp LIRopcode.tbl |") || die $!;
my @opcodes;
while(<$in>) {
    next unless m{^ OPDEF \( \s* (\w+) \s* , \s* (\d+) \s* , \s* (\d+) \s* \)}x;
    push @opcodes, { name => "LIR_$1", value => $2, operands => $3 };
}
close($in);

mkpath(File::Spec->catdir("lib", "Devel", "NanoJIT"));
open(my $out, ">", File::Spec->catfile("lib", "Devel", "NanoJIT", "Constants.pm")) || die $!;
print $out q{
package Devel::NanoJIT::Constants;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = ();
our @EXPORT_OK = qw(
};

print $out join("\n", map { "\t" . $_->{name} } @opcodes), "\n";
print $out ");\nour \%EXPORT_TAGS = ( all => [\@EXPORT_OK] );\n";


print $out "use constant {\n";
print $out join("\n", map { "\t" . $_->{name} . " => " . $_->{value} . "," } @opcodes), "\n";
print $out "};\n\n";
print $out "1;\n";

close($out);

my $CCFLAGS;
if ($^O eq "darwin") {
    $CCFLAGS = "-arch i386";
}

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Devel::NanoJIT',
    VERSION_FROM      => 'lib/Devel/NanoJIT.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Devel/NanoJIT.pm', # retrieve abstract from module
       AUTHOR         => 'Claes Jakobsson <claes@versed.se>') : ()),
    LIBS              => ['-lffi'], # e.g., '-lm'
    DEFINE            => "-DFEATURE_NANOJIT -D${avmplus_arch} -DAVMPLUS_UNIX -DJS_NO_FASTCALL", # e.g., '-DHAVE_SOMETHING'
    INC               => '-I. -I./nanojit', # e.g., '-I. -I/usr/include/other'
	# Un-comment this if you add C files to link with later:
    OBJECT            => join(" ", @files), # link all the C files too
    CC                => $CC,
    CCFLAGS           => $CCFLAGS,
    LD                => '$(CC)',
    XSOPT             => '-C++',    
);
