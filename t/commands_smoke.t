use strict;
use warnings;
use Test::More;

use lib '.';
use Mediabot::Commands qw(mbCommandPublic mbCommandPrivate getReplyTarget);

{   # stub classes
    package TestLogger;    ## no critic
    sub new { bless { logs => [] }, shift }
    sub log { my ($self, @args) = @_; push @{ $self->{logs} }, \@args; }

    package TestMessage;   ## no critic
    sub new { my ($class, %attrs) = @_; return bless \%attrs, $class }
    sub prefix { return $_[0]->{prefix} }
}

my $bot = { logger => TestLogger->new };
my $message = TestMessage->new(prefix => 'tester!u@h', params => ['#chan']);

{   # Public command dispatch hits handler directly
    my @received;
    no warnings 'redefine';
    local *Mediabot::mbChangeNick = sub {
        my ($self, $msg, $nick, @args) = @_;
        push @received, [$self, $msg, $nick, @args];
        return 'public-nick';
    };

    my $result = mbCommandPublic($bot, $message, '#chan', 'Tester', 0, 'nick', 'NewNick');

    is($result, undef, 'public dispatch does not return a value');
    is_deeply(
        $received[0],
        [$bot, $message, 'Tester', 'NewNick'],
        'public nick command forwarded to handler'
    );
    ok(@{ $bot->{logger}->{logs} } >= 1, 'public dispatch recorded a log entry');
}

{   # Private command dispatch returns handler output
    my @private;
    no warnings 'redefine';
    local *Mediabot::mbQuit = sub {
        my ($self, $msg, $target, $nick, @args) = @_;
        push @private, [$self, $msg, $target, $nick, @args];
        return 'quit-called';
    };

    my $result = mbCommandPrivate($bot, $message, 'Tester', 'die', 'now');

    is($result, 'quit-called', 'private dispatch returns handler value');
    is_deeply(
        $private[0],
        [$bot, $message, '#chan', 'Tester', 'now'],
        'private command receives reply target and args'
    );
}

{   # getReplyTarget helper
    is(getReplyTarget($bot, $message, 'Tester'), '#chan', 'channel target returned when params contain channel');

    my $dm = TestMessage->new(prefix => 'tester!u@h', params => ['Tester']);
    is(getReplyTarget($bot, $dm, 'Tester'), 'Tester', 'nick returned when message not for channel');
}

done_testing;
