#!/usr/bin/perl

# +---------------------------------------------------------------------------+
# !          LOG PRUNING SCRIPT FOR MEDIABOT                                  !
# +---------------------------------------------------------------------------+
#
# This script deletes old records from ACTIONS_LOG and CHANNEL_LOG to keep
# the database size manageable.
#
# Usage:
#   perl prune_logs.pl --conf /path/to/mediabot.conf --days 180
#
#   --conf: Path to the mediabot configuration file. (Required)
#   --days: Delete records older than this many days. (Default: 180)
#
# Setup as a cron job to run nightly or weekly. For example:
#   0 3 * * * /usr/bin/perl /path/to/mediabot/contrib/tools/prune_logs.pl --conf /path/to/mediabot.conf --days 180 > /dev/null 2>&1
#

use strict;
use warnings;
use Getopt::Long;
use POSIX qw/strftime/;
use File::Basename;

# Adjust @INC to find Mediabot modules
use Cwd qw(abs_path);
my ($root_dir);
BEGIN {
    $root_dir = dirname(dirname(dirname(abs_path($0))));
    unshift @INC, $root_dir;
}

use Mediabot::Conf;
use Mediabot::Log;
use Mediabot::DB;

# --- Script Configuration ---
my $CONFIG_FILE;
my $DAYS_TO_KEEP = 180;
my $DRY_RUN = 0; # Set to 1 to just select, not delete.

# --- Command Line Parsing ---
GetOptions (
    "conf=s" => \$CONFIG_FILE,
    "days=i" => \$DAYS_TO_KEEP,
    "dry-run" => \$DRY_RUN,
) or die "Error in command line arguments.\n";

unless ($CONFIG_FILE && -f $CONFIG_FILE) {
    die "Usage: $0 --conf /path/to/mediabot.conf [--days NUMBER] [--dry-run]\n";
}


# --- Initialization ---
my $logger = Mediabot::Log->new(debug_level => 3); # Log to console
my $conf = Mediabot::Conf->new( { file => $CONFIG_FILE } );
unless ($conf->read()) {
    $logger->log(0, "FATAL: Could not read configuration file '$CONFIG_FILE'");
    exit 1;
}

my $db = Mediabot::DB->new($conf, $logger);
my $dbh = $db->dbh;

unless ($dbh) {
    $logger->log(0, "FATAL: Database connection failed.");
    exit 1;
}

$logger->log(0, "Starting log pruning process.");
$logger->log(0, "Target tables: ACTIONS_LOG, CHANNEL_LOG");
$logger->log(0, "Retention period: $DAYS_TO_KEEP days");
$logger->log(0, "Dry run mode: " . ($DRY_RUN ? "ON (no data will be deleted)" : "OFF"));

# --- Pruning Logic ---

my $cutoff_date = strftime('%Y-%m-%d %H:%M:%S', localtime(time - ($DAYS_TO_KEEP * 24 * 60 * 60)));
$logger->log(1, "Calculated cutoff date: $cutoff_date");

prune_table('ACTIONS_LOG', 'ts', $cutoff_date);
prune_table('CHANNEL_LOG', 'ts', $cutoff_date);

$logger->log(0, "Log pruning process finished.");
exit 0;

# --- Subroutine to perform the pruning ---
sub prune_table {
    my ($table_name, $date_column, $cutoff) = @_;
    my $rows_affected = 0;

    $logger->log(1, "Processing table: $table_name");

    # First, count how many records will be deleted
    my $count_sql = "SELECT COUNT(*) FROM `$table_name` WHERE `$date_column` < ?";
    my $sth_count = $dbh->prepare($count_sql);
    $sth_count->execute($cutoff);
    my ($count) = $sth_count->fetchrow_array();
    $sth_count->finish;

    if ($count == 0) {
        $logger->log(1, "No records older than $cutoff_date found in $table_name. Skipping.");
        return;
    }

    $logger->log(1, "Found $count records to delete from $table_name.");

    if ($DRY_RUN) {
        $logger->log(1, "[DRY RUN] Skipping deletion for $table_name.");
        return;
    }

    # If not a dry run, proceed with deletion
    my $delete_sql = "DELETE FROM `$table_name` WHERE `$date_column` < ?";
    my $sth_delete = $dbh->prepare($delete_sql);
    
    eval {
        $rows_affected = $sth_delete->execute($cutoff);
    };
    if ($@) {
        $logger->log(0, "ERROR deleting from $table_name: $@");
        $sth_delete->finish;
        return;
    }

    $sth_delete->finish;

    # The return from execute() for DELETE is the number of rows affected.
    if (defined $rows_affected) {
        $logger->log(0, "Successfully deleted $rows_affected rows from $table_name.");
    } else {
        $logger->log(0, "Deletion query ran on $table_name, but the number of affected rows is unknown (may indicate an issue).");
    }
}
