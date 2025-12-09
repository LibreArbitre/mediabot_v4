package Mediabot::Core;

use strict;
use warnings;
use Carp qw(croak);
use POSIX qw(strftime);

sub new {
    my ($class, $args) = @_;

    my $self = bless {
        config_file => $args->{config_file} // undef,
        server      => $args->{server}      // undef,
        dbh         => $args->{dbh}         // undef,
        conf        => $args->{conf}        // undef,
        channels    => {},
    }, $class;

    # Minimal logging setup
    require Mediabot::Log;
    $self->{logger} = Mediabot::Log->new(
        debug_level => 0,
        logfile     => undef
    );

    return $self;
}

sub readConfigFile {
    my ($self, $file) = @_;

    my $logger = $self->{logger};

    $file //= $self->{config_file}
        or croak "No config file specified (\\$self->{config_file} is empty)";

    unless (-e $file) {
        $logger->error("Config file '$file' does not exist");
        return;
    }
    unless (-r $file) {
        $logger->error("Cannot read config file '$file'");
        return;
    }

    $logger->info("Loading configuration from '$file'");

    my $conf;
    eval {
        require Mediabot::Conf;
        $conf = Mediabot::Conf->new(undef, $file);
    };
    if ($@ or not $conf) {
        $logger->error("Failed to load configuration: $@");
        return;
    }

    $self->{conf} = $conf;

    $logger->info("Configuration loaded successfully");
    return 1;
}

sub getVersion {
    my $self = shift;
    my ($local_version, $remote_version) = ("Undefined", "Undefined");
    my ($c_major, $c_minor, $c_type, $c_dev_info);
    my ($r_major, $r_minor, $r_type, $r_dev_info);

    $self->{logger}->log(0, "Reading local version from VERSION file...");

    if (open my $fh, '<', 'VERSION') {
        chomp($local_version = <$fh>);
        close $fh;
        ($c_major, $c_minor, $c_type, $c_dev_info) = $self->getDetailedVersion($local_version);
    } else {
        $self->{logger}->log(0, "Unable to read local VERSION file.");
    }

    if (defined $c_major && defined $c_minor && defined $c_type) {
        my $suffix = $c_dev_info ? "($c_dev_info)" : '';
        $self->{logger}->log(0, "-> Mediabot $c_type version $c_major.$c_minor $suffix");
    } else {
        $self->{logger}->log(0, "-> Unknown local version format: $local_version");
    }

    if ($local_version ne "Undefined") {
        $self->{logger}->log(0, "Checking latest version from GitHub...");

        if (open my $gh, '-|', 'curl --connect-timeout 5 -f -s https://raw.githubusercontent.com/teuk/mediabot_v3/master/VERSION') {
            chomp($remote_version = <$gh>);
            close $gh;
            ($r_major, $r_minor, $r_type, $r_dev_info) = $self->getDetailedVersion($remote_version);

            if (defined $r_major && defined $r_minor && defined $r_type) {
                my $suffix = $r_dev_info ? "($r_dev_info)" : '';
                $self->{logger}->log(0, "-> GitHub $r_type version $r_major.$r_minor $suffix");

                if ($local_version eq $remote_version) {
                    $self->{logger}->log(0, "Mediabot is up to date.");
                } else {
                    $self->{logger}->log(0, "Update available: $r_type version $r_major.$r_minor $suffix");
                }
            } else {
                $self->{logger}->log(0, "Unknown remote version format: $remote_version");
            }
        } else {
            $self->{logger}->log(0, "Failed to fetch version from GitHub.");
        }
    }

    $self->{main_prog_version} = $local_version;
    return ($local_version, $remote_version);
}

sub getDetailedVersion {
    my ($self, $version_string) = @_;

    if ($version_string =~ /^(\d+)\.(\d+)$/) {
        return ($1, $2, "stable", undef);
    } elsif ($version_string =~ /^(\d+)\.(\d+)dev[-_]?([\d_]+)$/) {
        return ($1, $2, "devel", $3);
    } else {
        return (undef, undef, undef, undef);
    }
}

sub getDebugLevel {
    my $self = shift;
    return $self->{conf}->get('main.MAIN_PROG_DEBUG');
}

sub getLogFile {
    my $self = shift;
    return $self->{conf}->get('main.MAIN_LOG_FILE');
}

sub dumpConfig {
    my ($self) = @_;

    my %conf = $self->{conf}->all;
    return unless %conf;

    print STDERR "\e[1m=== Mediabot configuration dump ===\e[0m\n";

    foreach my $key (sort keys %conf) {
        my $val = $conf{$key};

        if (ref $val eq 'HASH') {
            print STDERR "$key => {\n";
            foreach my $subkey (sort keys %{$val}) {
                my $subval = $val->{$subkey};
                $subval = '(undef)' unless defined $subval;
                print STDERR "  $subkey => $subval\n";
            }
            print STDERR "}\n";
        } else {
            $val = '(undef)' unless defined $val;
            print STDERR "$key => $val\n";
        }
    }
}

1;
