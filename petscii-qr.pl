#!/usr/bin/perl
use strict;
use warnings;

# petsciiqr.pl - convert an ASCII QR code into PETSCII quarter-block graphics
#
# Assumes 40-col screen @ $8000 (PET 2001 through PET 4032)
#

my $screen = 40;

# Quarter-block table (2 bits from current line, 2 bits from next line below)
my %qtr = (
    "    " => 0x20,  #  32
    "   #" => 0x6C,  # 108
    "  # " => 0x7B,  # 123
    "  ##" => 0x62,  #  98
    " #  " => 0x7C,  # 124
    " # #" => 0xE1,  # 225
    " ## " => 0xFF,  # 255
    " ###" => 0xFE,  # 254
    "#   " => 0x7E,  # 126
    "#  #" => 0x7F,  # 127
    "# # " => 0x61,  #  97
    "# ##" => 0xFC,  # 252
    "##  " => 0XE2,  # 226
    "## #" => 0xFB,  # 251
    "### " => 0xEC,  # 236
    "####" => 0xA0,  # 160
);

my $qr_width = 0;
my $rpad = 0;

my $hdr = pack('C*', (0x00, 0x80));

print $hdr;

while (my $line1 = <STDIN>) {
    chomp $line1;

    # de-double QR pattern elements on this line
    $line1 =~ s/(.)./$1/g;

    # calculate line width and padding once we know
    $qr_width = length($line1) unless $qr_width;
    $rpad = $screen-int($qr_width/2+0.5) unless $rpad;

    # read second line
    my $line2 = <STDIN>;

    # de-double second line or, if last line, make it all padding
    if (defined $line2) {
        chomp $line2;
        $line2 =~ s/(.)./$1/g;
    } else {
        $line2 = " " x $qr_width;
    }

    # make sure lines have even number of chars
    $line1 .= " " if (length($line1) % 2);
    $line2 .= " " if (length($line2) % 2);

    # Process the pair of lines
    while (length $line1) {
        my $token = substr($line1, 0, 2) . substr($line2, 0, 2);
        my $val = $qtr{$token};
        print pack('C*', $val);
        $line1 =~ s/^..//;
        $line2 =~ s/^..//;
    }

    # pad for screen width
    print pack('C*', $qtr{'    '}) x $rpad;
    
}
