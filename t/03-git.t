# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Foo-Bar.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Data::Dumper;
use File::Copy;
use IO::File;
use Test::More;
my $number_of_tests = 0;

my $source_pre_commit = "$ENV{HOME}/bin/git-pre-commit";
my $update_gits = "$ENV{HOME}/.update_gits";
my $ifh = IO::File->new( $update_gits, '<' );
die if ( !defined $ifh );
my $mode = 0755;
while (my $dir=<$ifh>) {
    chomp $dir;
    if ( ! -d $dir ) {
        next;
    }
    my $pre_commit = 0;
    my $target_pre_commit = "$dir/hooks/pre-commit";
    # unlink $target_pre_commit;
    if ( -f $target_pre_commit ) {
        $pre_commit = 1;
    }
    $number_of_tests++;
    is( $pre_commit, 1, "pre_commit: $dir" );
    if ( $pre_commit != 1 ) {
        print "    attempting to fix...";
        if ( copy("$dir/../git-pre-commit",$target_pre_commit) ) {
            chmod $mode, $target_pre_commit;
            print "fixed!\n";
        }
        elsif ( copy($source_pre_commit,$target_pre_commit) ) {
            chmod $mode, $target_pre_commit;
            copy($target_pre_commit, "$dir/../git-pre-commit");
            print "fixed!\n";
        }
        else {
            print "failed\n";
        }
    }
}

done_testing($number_of_tests);

