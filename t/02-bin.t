# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Foo-Bar.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use IO::File;
use Data::Dumper;
use Test::More;
my $number_of_tests = 0;

# example
# my @dot_files = grep { /^\./ && -f "$some_dir/$_" } get_directory($target);
sub get_directory {
    my ($dir) = @_;
    opendir( my $dh, $dir ) || die "can't opendir $dir: $!";
    my @files = readdir($dh);
    closedir $dh;
    return @files;
}

my $bin_directory = "$ENV{HOME}/bin";
my @bins = map { "$bin_directory/$_" } grep { !/^[._]/ } get_directory($bin_directory);

my $bin_directory2 = "$ENV{HOME}/bin2";
push @bins, map { "$bin_directory2/$_" } grep { !/^[._]/ } get_directory($bin_directory2);

OUTER:
for my $file (@bins) {
    if ( $file eq "$bin_directory/COPYING" or $file eq "$bin_directory/README.md" ) {
        next OUTER;
    }
    my $ifh = IO::File->new( $file, '<' );
    die if ( !defined $ifh );

    my $purpose_found = 0;
    my $version_found = 0;
  INNER:
    while (<$ifh>) {
        if (/#\s*purpose:\s*\w/) {
            $purpose_found = 1;
        }
        if (/VERSION/) {
            $version_found = 1;
        }
    }
    $ifh->close;

    $number_of_tests++;
    is( $purpose_found, 1, "purpose: $file" );

    $number_of_tests++;
    is( $version_found, 1, "version: $file" );
}

done_testing($number_of_tests);

