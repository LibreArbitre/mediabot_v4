#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use DBI;
use Mediabot::User;

my %opt = (
    dsn  => $ENV{MEDIABOT_DSN}      || '',
    user => $ENV{MEDIABOT_DB_USER}  || '',
    pass => $ENV{MEDIABOT_DB_PASS}  || '',
);

GetOptions(
    'dsn=s'  => \$opt{dsn},
    'user=s' => \$opt{user},
    'pass=s' => \$opt{pass},
    'help'   => sub { print_usage(); exit 0; },
) or die print_usage();

if (!$opt{dsn}) {
    die print_usage("Missing --dsn (ex: DBI:mysql:database=mediabot)");
}

my $dbh = DBI->connect(
    $opt{dsn},
    $opt{user},
    $opt{pass},
    {
        RaiseError           => 1,
        PrintError           => 0,
        AutoCommit           => 1,
        mysql_enable_utf8mb4 => 1,
    }
) or die "Unable to connect to database: $DBI::errstr\n";

my $sth = $dbh->prepare('SELECT id_user, hostmasks FROM USER');
$sth->execute;

my $count   = 0;
my $updated = 0;
while (my $row = $sth->fetchrow_hashref) {
    $count++;
    my $id_user   = $row->{id_user};
    my $hostmasks = $row->{hostmasks} // '';
    my $inserted  = eval { Mediabot::User::sync_hostmask_index($dbh, $id_user, $hostmasks, {}); };
    if ($@) {
        warn "Failed to sync hostmasks for user $id_user: $@\n";
        next;
    }
    $updated++ if defined $inserted;
}

printf "Synced hostmasks for %d/%d users\n", $updated, $count;

sub print_usage {
    my ($err) = @_;
    my $msg = <<'USAGE';
Usage: rebuild_hostmask_index.pl --dsn DBI:mysql:database=mediabot [--user bot] [--pass secret]
       MEDIABOT_DSN/MEDIABOT_DB_USER/MEDIABOT_DB_PASS environment variables are also supported.
USAGE
    return $err ? "$err\n\n$msg" : $msg;
}
