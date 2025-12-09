use strict;
use warnings;
use Test::More;
use lib '.';

use_ok('Mediabot::Core');
use_ok('Mediabot::LogService');
use Mediabot::LogService qw(logBot logBotAction);

{   # Mediabot::Core constructor baseline
    my $core = Mediabot::Core->new({});
    isa_ok($core, 'Mediabot::Core');
    ok(exists $core->{logger}, 'logger initialized');
}

{   # Mediabot::LogService helpers no-op without DB handle
    my $calls;
    my $dummy = bless {
        logger => bless({}, 'DummyLogger'),
        dbh    => bless({}, 'DummyDBH'),
    }, 'DummyBot';
    *DummyLogger::log = sub { $calls++; };
    *DummyBot::get_user_from_message = sub { return; };
    *DummyBot::noticeConsoleChan    = sub { $calls++; };
    *DummyDBH::prepare = sub { bless {}, 'DummySTH' };
    *DummySTH::execute = sub { return 1 };
    *DummySTH::fetchrow_hashref = sub { return { id_channel => 1 } };
    *DummySTH::finish = sub { return 1 };

    my $message = bless {}, 'DummyMessage';
    *DummyMessage::prefix = sub { return 'nick!user@host'; };

    logBot($dummy, $message, undef, 'noop');
    logBotAction($dummy, $message, 'join', 'nick', '#chan', 'text');
    pass('log helpers invoked without DB handle');
}

sub DummyLogger::log {}

done_testing();
