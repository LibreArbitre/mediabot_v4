package Mediabot::LogService;

use strict;
use warnings;
use Exporter qw(import);
use POSIX qw(strftime);
use Data::Dumper;

our @EXPORT_OK = qw(logBot logBotAction);

sub logBot {
    my ($self, $message, $channel, $action, @args) = @_;

    return unless $self->{dbh};

    my $user = $self->get_user_from_message($message);

    my $user_id   = $user ? $user->id       : undef;
    my $user_name = $user ? $user->nickname : 'Unknown user';
    my $hostmask  = $message->prefix        // 'unknown';

    my $channel_id;
    if (defined $channel && exists $self->{channels}{$channel}) {
        $channel_id = $self->{channels}{$channel}->get_id;
    }

    my $args_string = @args ? join(' ', map { defined($_) ? $_ : '' } @args) : '';

    my $sql = "INSERT INTO ACTIONS_LOG (ts, id_user, id_channel, hostmask, action, args) VALUES (?, ?, ?, ?, ?, ?)";
    my $sth = $self->{dbh}->prepare($sql) or do {
        $self->{logger}->log(0, "logBot() SQL prepare failed: $DBI::errstr");
        return;
    };

    my $timestamp = strftime('%Y-%m-%d %H:%M:%S', localtime(time));

    unless ($sth->execute($timestamp, $user_id, $channel_id, $hostmask, $action, $args_string)) {
        $self->{logger}->log(0, "logBot() SQL error: $DBI::errstr — Query: $sql");
        return;
    }

    my $log_msg = "($user_name : $hostmask) command $action";
    $log_msg .= " $args_string" if $args_string ne '';
    $log_msg .= " on $channel"  if defined $channel;

    $self->noticeConsoleChan($log_msg);
    $self->{logger}->log(3, "logBot() $log_msg");

    $sth->finish;
}

sub logBotAction {
    my ($self, $message, $eventtype, $sNick, $sChannel, $sText) = @_;

    my $sUserhost = "";
    $sUserhost = $message->prefix if defined $message;

    if (defined $sChannel) {
        $self->{logger}->log(5, "logBotAction() eventtype = $eventtype chan = $sChannel nick = $sNick text = $sText");
    } else {
        $self->{logger}->log(5, "logBotAction() eventtype = $eventtype nick = $sNick text = $sText");
    }

    $self->{logger}->log(5, "logBotAction() " . Dumper($message)) if defined($self->{logger}->{debug}) && $self->{logger}->{debug} >= 5;

    my $id_channel;

    if (defined $sChannel) {
        my $sQuery = "SELECT id_channel FROM CHANNEL WHERE name = ?";
        my $sth = $self->{dbh}->prepare($sQuery);

        unless ($sth->execute($sChannel)) {
            $self->{logger}->log(1, "logBotAction() SQL Error: $DBI::errstr Query: $sQuery");
            return;
        }

        my $ref = $sth->fetchrow_hashref();
        unless ($ref) {
            $self->{logger}->log(3, "logBotAction() channel not found: $sChannel");
            return;
        }

        $id_channel = $ref->{'id_channel'};
    }

    my $insert_query = <<'SQL';
INSERT INTO CHANNEL_LOG (id_channel, event_type, nick, userhost, publictext)
VALUES (?, ?, ?, ?, ?)
SQL

    my $sth_insert = $self->{dbh}->prepare($insert_query);
    unless ($sth_insert->execute($id_channel, $eventtype, $sNick, $sUserhost, $sText)) {
        $self->{logger}->log(1, "logBotAction() SQL Insert Error: $DBI::errstr Query: $insert_query");
    } else {
        $self->{logger}->log(5, "logBotAction() inserted $eventtype event into CHANNEL_LOG");
    }
}

1;
