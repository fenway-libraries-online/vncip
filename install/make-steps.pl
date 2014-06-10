#!/usr/bin/perl

use strict;
use warnings;

use File::Glob qw(glob);

$> == 0 or die "This script must be run as root";
open STDOUT, '>', 'run-steps.zsh' or die "Can't open run-steps.zsh: $!";
-d 'step' or mkdir 'step' or die "Can't mkdir step: $!";

my $i = '000';
my ($title, $inhead, $interp, $fhscript, @opts);
my (@mod, %opt, @cmd);

print <<'EOS';
#!/bin/zsh

# Functions
source ./functions.zsh

PATH=./bin:$PATH

EOS

open my $fhsrc, '<', 'steps.src' or die "Can't open steps.src: $!";

unlink glob('step/*.*');

while (<$fhsrc>) {
    if (/^\{\{\{ *(.+)$/) {
        die if defined $fhscript;
        $title = $1;
        $inhead = 1;
        $interp = 'zsh';
        @mod = ();
        %opt = ();
    }
    elsif ($inhead && s/^#!\s*//) {
        die if !$inhead;
        chomp;
        $interp = $_;
    }
    elsif ($inhead && /^#\+(\w+)$/) {
        $opt{$1} = 1;
    }
    elsif ($inhead && /^#\-(\w+)$/) {
        $opt{$1} = 0;
    }
    elsif ($inhead && s/^#>\s*//) {
        chomp;
        push @mod, $_;
    }
    elsif ($inhead && !/^#/) {
        open $fhscript, '>', 'step/' . mkfilename($i, $title);
        print $fhscript preamble($interp);
        print $fhscript $_;
        $inhead = 0;
    }
    elsif (/^\}\}\}$/) {
        print join(' ', map { quote($_) } ('step', $i, options(keys %opt), $title)), "\n";
        close $fhscript;
        undef $fhscript;
        $i++;
    }
    elsif (defined $fhscript) {
        print $fhscript $_;
    }
    elsif (/\S/) {
        die "Malformed step: $_\n";
    }
}

chmod 0755, glob('step/*.*');

# --- Functions

sub mkfilename {
    my ($i, $title) = @_;
    for ($title) {
        tr/ A-Z/-a-z/;
        tr/-a-z//cd;
    }
    sprintf('%03d.%s', $i, $title);
}

sub quote {
    local $_ = shift;
    return "\\\n" if $_ eq "\n";
    return qq{"$_"} if s/(['"\\])/\\$1/g || /\s/;
    return $_;
}

sub preamble {
    my ($interp) = @_;
    my @lines;
    if ($interp eq 'perl') {
        push @lines, <<'EOS';
#!/usr/bin/perl

use strict;
use warnings;

EOS
        foreach (@mod) {
            my ($mod, $args) = split /\s+/, $_, 2;
            if ($mod eq 'runas') {
                push @lines, "runas qq{$args};\n";
            }
            elsif ($mod eq 'makes') {
                push @lines, "makes qq{$_};\n" for split /\s+/, $args;
            }
            elsif ($mod eq 'requires') {
                push @lines, "lacking qq{$_} if ! -e qq{$_};\n" for split /\s+/, $args;
            }
            elsif ($mod eq 'skiptest') {
                push @lines, "skip if system qq{$args} != 0;\n";
            }
            elsif ($mod eq 'configs') {
                push @lines, "configs qq{$_};\n" for split /\s+/, $args;
            }
        }
        push @lines, "\n" if @mod;
    }
    elsif ($interp eq 'zsh') {
        push @lines, <<'EOS';
#!/bin/zsh -e

EOS
        foreach (@mod) {
            my ($mod, $args) = split /\s+/, $_, 2;
            if ($mod eq 'runas') {
                push @lines, "runas $args\n";
            }
            elsif ($mod eq 'makes') {
                push @lines, "makes $_\n" for map { quote($_) } split /\s+/, $args;
            }
            elsif ($mod eq 'requires') {
                push @lines, "[[ -e $_ ]] || lacking $_\n" for split /\s+/, $args;
            }
            elsif ($mod eq 'skiptest') {
                push @lines, "$args || SKIP $i\n";
            }
            elsif ($mod eq 'configs') {
                push @lines, "configs $_\n" for map { quote($_) } split /\s+/, $args;
            }
        }
        push @lines, "\n" if @mod;
    }
    return @lines;
}

sub options {
    my %name2opt = qw(
        noskip  -S
    );
    return if !@_;
    map { $name2opt{$_} || die "Unrecognized option: $_" } @_;
}
