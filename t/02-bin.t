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
    opendir(my $dh, $dir) || die "can't opendir $dir: $!";
    my @files = readdir($dh);
    closedir $dh;
    return @files;
}

my $bin_directory = "$ENV{HOME}/bin";
my @bins = grep { !/^[._]/ } get_directory($bin_directory);

OUTER:
for my $file (@bins) {
    if ( $file eq 'COPYING' or $file eq 'README.md' ) {
        next OUTER;
    }
    my $ifh = IO::File->new("$bin_directory/$file", '<');
    die if (!defined $ifh);

    my $purpose_found = 0;
    INNER:
    while(<$ifh>) {
        if ( /#\s*purpose:\s*\w/ ) {
            $purpose_found++;
            last INNER;
        }
    }
    $ifh->close;
    $number_of_tests++;
    is($purpose_found,1,"purpose: $file");
}

done_testing($number_of_tests);

