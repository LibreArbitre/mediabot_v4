use strict;
use warnings;

use Test::More;
use File::Temp qw(tempfile);
use lib '.';

use Mediabot::Log;

my ($fh, $filename) = tempfile();
close $fh;

my $logger = Mediabot::Log->new(
    debug_level => 0,
    logfile     => $filename,
);

my $test_message = 'handler redirect smoke test';
$logger->info($test_message);
$logger->flush();

open my $rfh, '<', $filename or die "Cannot read temp logfile: $!";
my $content = do { local $/; <$rfh> };
close $rfh;

like($content, qr/\Q$test_message\E/, 'info helper writes to configured logfile');

END {
    unlink $filename if defined $filename && -e $filename;
}

done_testing();
