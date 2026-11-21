#!/usr/bin/perl
# pecmp.pl A B: compare two files that the Microsoft tools made: a program, a DLL, an object
# file, a library or a resource file. The tools write the time of the build into these files.
# Prints one of
#   same
#   same but for the time stamps
#   N bytes differ (first at offset X)       exit code 1
#   sizes differ: N and M bytes              exit code 1
use strict;

@ARGV == 2 or die "usage: pecmp.pl A B\n";
my $x = slurp($ARGV[0]);
my $y = slurp($ARGV[1]);
if ($x eq $y) {
    print "same\n";
    exit 0;
}
if (length($x) != length($y)) {
    printf "sizes differ: %d and %d bytes\n", length($x), length($y);
    exit 1;
}
mask(\$x);
mask(\$y);
if ($x eq $y) {
    print "same but for the time stamps\n";
    exit 0;
}
my $d = $x ^ $y;
my $n = ($d =~ tr/\0//c);
$d =~ /[^\0]/;
printf "%d bytes differ (first at offset 0x%x)\n", $n, $-[0];
exit 1;

sub slurp {
    my ($f) = @_;
    open my $h, '<', $f or die "$f: $!\n";
    binmode $h;
    local $/;
    return scalar <$h>;
}

# put zeros where the tools write a time or a value made from it
sub mask {
    my ($r) = @_;
    if (substr($$r, 0, 8) eq "!<arch>\n") {
        mask_lib($r);
    } elsif (substr($$r, 0, 2) eq 'MZ') {
        mask_image($r);
    } else {
        mask_object($r, 0, length $$r);
    }
}

sub zero {
    my ($r, $off, $len) = @_;
    substr($$r, $off, $len) = "\0" x $len if $off >= 0 && $off + $len <= length $$r;
}

# an object file: the time stamp of the file header. An import object of a library has it too.
sub mask_object {
    my ($r, $off, $len) = @_;
    return if $len < 20;
    my ($machine, $nsec) = unpack('vv', substr($$r, $off, 4));
    if ($machine == 0 && $nsec == 0xffff) {
        zero($r, $off + 8, 4);
    } elsif (grep { $machine == $_ } 0x14c, 0x162, 0x166, 0x184, 0x1f0, 0x200, 0x284) {
        zero($r, $off + 4, 4);
    }
}

# a library: the date of each member, and the time stamp of each object in it
sub mask_lib {
    my ($r) = @_;
    my $p = 8;
    while ($p + 60 <= length $$r) {
        my $size = substr($$r, $p + 48, 10) + 0;
        substr($$r, $p + 16, 12) = ' ' x 12;
        mask_object($r, $p + 60, $size);
        $p += 60 + $size + ($size & 1);
    }
}

# a program or a DLL: the time stamps of the file header, of the export, resource and debug
# directories, and the checksum
sub mask_image {
    my ($r) = @_;
    return if length($$r) < 0x40;
    my $pe = unpack('V', substr($$r, 0x3c, 4));
    return if $pe + 24 > length($$r) || substr($$r, $pe, 4) ne "PE\0\0";
    my ($nsec, $optsize) = (unpack('v', substr($$r, $pe + 6, 2)), unpack('v', substr($$r, $pe + 20, 2)));
    zero($r, $pe + 8, 4);
    my $opt = $pe + 24;
    zero($r, $opt + 64, 4);
    my @sec;
    for my $i (0 .. $nsec - 1) {
        my ($vsize, $va, $rsize, $rptr) = unpack('VVVV', substr($$r, $opt + $optsize + 40 * $i + 8, 16));
        push @sec, [$va, ($vsize > $rsize ? $vsize : $rsize), $rptr];
    }
    my $off = sub {
        my ($rva) = @_;
        for my $s (@sec) {
            return $rva - $s->[0] + $s->[2] if $rva >= $s->[0] && $rva < $s->[0] + $s->[1];
        }
        return -1;
    };
    my $ndir = unpack('V', substr($$r, $opt + 92, 4));
    my $dir = sub {
        my ($i) = @_;
        return (0, 0) if $i >= $ndir;
        return unpack('VV', substr($$r, $opt + 96 + 8 * $i, 8));
    };
    # exports
    my ($rva, $size) = $dir->(0);
    zero($r, $off->($rva) + 4, 4) if $rva && $off->($rva) >= 0;
    # resources: a tree of directories
    ($rva, $size) = $dir->(2);
    if ($rva && (my $base = $off->($rva)) >= 0) {
        my @todo = (0);
        my %seen;
        while (@todo) {
            my $d = shift @todo;
            next if $seen{$d}++ || $base + $d + 16 > length $$r;
            zero($r, $base + $d + 4, 4);
            my ($named, $ids) = unpack('vv', substr($$r, $base + $d + 12, 4));
            for my $i (0 .. $named + $ids - 1) {
                my $e = $base + $d + 16 + 8 * $i;
                last if $e + 8 > length $$r;
                my $to = unpack('V', substr($$r, $e + 4, 4));
                push @todo, $to & 0x7fffffff if $to & 0x80000000;
            }
        }
    }
    # debug directory, and the signature of a program database
    ($rva, $size) = $dir->(6);
    if ($rva && (my $p = $off->($rva)) >= 0) {
        for (my $e = $p; $e + 28 <= $p + $size && $e + 28 <= length $$r; $e += 28) {
            zero($r, $e + 4, 4);
            my ($type, $dsize, $draw, $dptr) = unpack('VVVV', substr($$r, $e + 12, 16));
            zero($r, $dptr + 8, 4) if $type == 2 && $dsize >= 16 && substr($$r, $dptr, 4) eq 'NB10';
        }
    }
}
