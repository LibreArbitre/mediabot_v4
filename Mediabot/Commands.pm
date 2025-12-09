package Mediabot::Commands;

use strict;
use warnings;
use Exporter qw(import);

our @EXPORT_OK = qw(mbCommandPublic mbCommandPrivate getReplyTarget);

# 🧙‍♂️ mbCommandPublic: The Sorting Hat of Mediabot – routes every incantation to the proper spell
sub mbCommandPublic {
    my ($self, $message, $sChannel, $sNick, $botNickTriggered, $sCommand, @tArgs) = @_;

    my %command_map = (
        die          => sub { Mediabot::mbQuit($self, $message, $sNick, @tArgs) },
        nick         => sub { Mediabot::mbChangeNick($self, $message, $sNick, @tArgs) },
        addtimer     => sub { Mediabot::mbAddTimer($self, $message, $sChannel, $sNick, @tArgs) },
        remtimer     => sub { Mediabot::mbRemTimer($self, $message, $sChannel, $sNick, @tArgs) },
        timers       => sub { Mediabot::mbTimers($self, $message, $sChannel, $sNick, @tArgs) },
        msg          => sub { Mediabot::msgCmd($self, $message, $sNick, @tArgs) },
        say          => sub { Mediabot::sayChannel($self, $message, $sNick, @tArgs) },
        act          => sub { Mediabot::actChannel($self, $message, $sNick, @tArgs) },
        cstat        => sub { Mediabot::userCstat($self, $message, $sNick, @tArgs) },
        status       => sub { Mediabot::mbStatus($self, $message, $sNick, $sChannel, @tArgs) },
        adduser      => sub { Mediabot::addUser($self, $message, $sNick, @tArgs) },
        deluser      => sub { Mediabot::delUser($self, $message, $sNick, @tArgs) },
        users        => sub { Mediabot::userStats($self, $message, $sNick, $sChannel, @tArgs) },
        userinfo     => sub { Mediabot::userInfo($self, $message, $sNick, $sChannel, @tArgs) },
        addhost      => sub { Mediabot::addUserHost($self, $message, $sNick, $sChannel, @tArgs) },
        addchan      => sub { Mediabot::addChannel($self, $message, $sNick, @tArgs) },
        chanset      => sub { Mediabot::channelSet($self, $message, $sNick, $sChannel, @tArgs) },
        purge        => sub { Mediabot::purgeChannel($self, $message, $sNick, @tArgs) },
        part         => sub { Mediabot::channelPart($self, $message, $sNick, $sChannel, @tArgs) },
        join         => sub { Mediabot::channelJoin($self, $message, $sNick, @tArgs) },
        add          => sub { Mediabot::channelAddUser($self, $message, $sNick, $sChannel, @tArgs) },
        del          => sub { Mediabot::channelDelUser($self, $message, $sNick, $sChannel, @tArgs) },
        modinfo      => sub { Mediabot::userModinfo($self, $message, $sNick, $sChannel, @tArgs) },
        op           => sub { Mediabot::userOpChannel($self, $message, $sNick, $sChannel, @tArgs) },
        deop         => sub { Mediabot::userDeopChannel($self, $message, $sNick, $sChannel, @tArgs) },
        invite       => sub { Mediabot::userInviteChannel($self, $message, $sNick, $sChannel, @tArgs) },
        voice        => sub { Mediabot::userVoiceChannel($self, $message, $sNick, $sChannel, @tArgs) },
        devoice      => sub { Mediabot::userDevoiceChannel($self, $message, $sNick, $sChannel, @tArgs) },
        kick         => sub { Mediabot::userKickChannel($self, $message, $sNick, $sChannel, @tArgs) },
        showcommands => sub { Mediabot::userShowcommandsChannel($self, $message, $sNick, $sChannel, @tArgs) },
        chaninfo     => sub { Mediabot::userChannelInfo($self, $message, $sNick, $sChannel, @tArgs) },
        chanlist     => sub { Mediabot::channelList($self, $message, $sNick, $sChannel, @tArgs) },
        whoami       => sub { Mediabot::userWhoAmI($self, $message, $sNick, @tArgs) },
        auth         => sub { Mediabot::userAuthNick($self, $message, $sNick, @tArgs) },
        verify       => sub { Mediabot::userVerifyNick($self, $message, $sNick, @tArgs) },
        access       => sub { Mediabot::userAccessChannel($self, $message, $sNick, $sChannel, @tArgs) },
        addcmd       => sub { Mediabot::mbDbAddCommand($self, $message, $sNick, @tArgs) },
        remcmd       => sub { Mediabot::mbDbRemCommand($self, $message, $sNick, @tArgs) },
        modcmd       => sub { Mediabot::mbDbModCommand($self, $message, $sNick, @tArgs) },
        mvcmd        => sub { Mediabot::mbDbMvCommand($self, $message, $sNick, @tArgs) },
        chowncmd     => sub { Mediabot::mbChownCommand($self, $message, $sNick, @tArgs) },
        showcmd      => sub { Mediabot::mbDbShowCommand($self, $message, $sNick, @tArgs) },
        chanstatlines => sub { Mediabot::channelStatLines($self, $message, $sChannel, $sNick, @tArgs) },
        whotalk      => sub { Mediabot::whoTalk($self, $message, $sChannel, $sNick, @tArgs) },
        whotalks     => sub { Mediabot::whoTalk($self, $message, $sChannel, $sNick, @tArgs) },
        countcmd     => sub { Mediabot::mbCountCommand($self, $message, $sNick, $sChannel, @tArgs) },
        topcmd       => sub { Mediabot::mbTopCommand($self, $message, $sNick, $sChannel, @tArgs) },
        popcmd       => sub { Mediabot::mbPopCommand($self, $message, $sNick, $sChannel, @tArgs) },
        searchcmd    => sub { Mediabot::mbDbSearchCommand($self, $message, $sNick, $sChannel, @tArgs) },
        lastcmd      => sub { Mediabot::mbLastCommand($self, $message, $sNick, $sChannel, @tArgs) },
        owncmd       => sub { Mediabot::mbDbOwnersCommand($self, $message, $sNick, $sChannel, @tArgs) },
        holdcmd      => sub { Mediabot::mbDbHoldCommand($self, $message, $sNick, $sChannel, @tArgs) },
        addcatcmd    => sub { Mediabot::mbDbAddCategoryCommand($self, $message, $sNick, $sChannel, @tArgs) },
        chcatcmd     => sub { Mediabot::mbDbChangeCategoryCommand($self, $message, $sNick, $sChannel, @tArgs) },
        topsay       => sub { Mediabot::userTopSay($self, $message, $sNick, $sChannel, @tArgs) },
        checkhostchan => sub { Mediabot::mbDbCheckHostnameNickChan($self, $message, $sNick, $sChannel, @tArgs) },
        checkhost    => sub { Mediabot::mbDbCheckHostnameNick($self, $message, $sNick, $sChannel, @tArgs) },
        checknick    => sub { Mediabot::mbDbCheckNickHostname($self, $message, $sNick, $sChannel, @tArgs) },
        greet        => sub { Mediabot::userGreet($self, $message, $sNick, $sChannel, @tArgs) },
        nicklist     => sub { Mediabot::channelNickList($self, $message, $sNick, $sChannel, @tArgs) },
        rnick        => sub { Mediabot::randomChannelNick($self, $message, $sNick, $sChannel, @tArgs) },
        birthdate    => sub { Mediabot::displayBirthDate($self, $message, $sNick, $sChannel, @tArgs) },
        colors       => sub { Mediabot::mbColors($self, $message, $sNick, $sChannel, @tArgs) },
        seen         => sub { Mediabot::mbSeen($self, $message, $sNick, $sChannel, @tArgs) },
        date         => sub { Mediabot::displayDate($self, $message, $sNick, $sChannel, @tArgs) },
        weather      => sub { Mediabot::displayWeather($self, $message, $sNick, $sChannel, @tArgs) },
        meteo        => sub { Mediabot::displayWeather($self, $message, $sNick, $sChannel, @tArgs) },
        addbadword   => sub { Mediabot::channelAddBadword($self, $message, $sNick, $sChannel, @tArgs) },
        rembadword   => sub { Mediabot::channelRemBadword($self, $message, $sNick, $sChannel, @tArgs) },
        ignores      => sub { Mediabot::IgnoresList($self, $message, $sNick, $sChannel, @tArgs) },
        ignore       => sub { Mediabot::addIgnore($self, $message, $sNick, $sChannel, @tArgs) },
        unignore     => sub { Mediabot::delIgnore($self, $message, $sNick, $sChannel, @tArgs) },
        yt           => sub { Mediabot::youtubeSearch($self, $message, $sNick, $sChannel, @tArgs) },
        song         => sub { Mediabot::displayRadioCurrentSong($self, $message, $sNick, $sChannel, @tArgs) },
        listeners    => sub { Mediabot::displayRadioListeners($self, $message, $sNick, $sChannel, @tArgs) },
        nextsong     => sub { Mediabot::radioNext($self, $message, $sNick, $sChannel, @tArgs) },
        addresponder => sub { Mediabot::addResponder($self, $message, $sNick, $sChannel, @tArgs) },
        delresponder => sub { Mediabot::delResponder($self, $message, $sNick, $sChannel, @tArgs) },
        update       => sub { Mediabot::update($self, $message, $sNick, $sChannel, @tArgs) },
        lastcom      => sub { Mediabot::lastCom($self, $message, $sNick, $sChannel, @tArgs) },
        q            => sub { Mediabot::mbQuotes($self, $message, $sNick, $sChannel, @tArgs) },
        Q            => sub { Mediabot::mbQuotes($self, $message, $sNick, $sChannel, @tArgs) },
        moduser      => sub { Mediabot::mbModUser($self, $message, $sNick, $sChannel, @tArgs) },
        antifloodset => sub { Mediabot::setChannelAntiFloodParams($self, $message, $sNick, $sChannel, @tArgs) },
        leet         => sub { Mediabot::displayLeetString($self, $message, $sNick, $sChannel, @tArgs) },
        rehash       => sub { Mediabot::mbRehash($self, $message, $sNick, $sChannel, @tArgs) },
        play         => sub { Mediabot::playRadio($self, $message, $sNick, $sChannel, @tArgs) },
        rplay        => sub { Mediabot::rplayRadio($self, $message, $sNick, $sChannel, @tArgs) },
        queue        => sub { Mediabot::queueRadio($self, $message, $sNick, $sChannel, @tArgs) },
        next         => sub { Mediabot::nextRadio($self, $message, $sNick, $sChannel, @tArgs) },
        mp3          => sub { Mediabot::mp3($self, $message, $sNick, $sChannel, @tArgs) },
        exec         => sub { Mediabot::mbExec($self, $message, $sNick, $sChannel, @tArgs) },
        qlog         => sub { Mediabot::mbChannelLog($self, $message, $sNick, $sChannel, @tArgs) },
        hailo_ignore   => sub { Mediabot::hailo_ignore($self, $message, $sNick, $sChannel, @tArgs) },
        hailo_unignore => sub { Mediabot::hailo_unignore($self, $message, $sNick, $sChannel, @tArgs) },
        hailo_status   => sub { Mediabot::hailo_status($self, $message, $sNick, $sChannel, @tArgs) },
        hailo_chatter  => sub { Mediabot::hailo_chatter($self, $message, $sNick, $sChannel, @tArgs) },
        whereis      => sub { Mediabot::mbWhereis($self, $message, $sNick, $sChannel, @tArgs) },
        birthday     => sub { Mediabot::userBirthday($self, $message, $sNick, $sChannel, @tArgs) },
        f            => sub { Mediabot::fortniteStats($self, $message, $sNick, $sChannel, @tArgs) },
        xlogin       => sub { Mediabot::xLogin($self, $message, $sNick, $sChannel, @tArgs) },
        yomomma      => sub { Mediabot::Yomomma($self, $message, $sNick, $sChannel, @tArgs) },
        spike        => sub { Mediabot::botPrivmsg($self, $sChannel, "https://teuk.org/In_Spike_Memory.jpg") },
        resolve      => sub { Mediabot::mbResolver($self, $message, $sNick, $sChannel, @tArgs) },
        tmdblangset  => sub { Mediabot::setTMDBLangChannel($self, $message, $sNick, $sChannel, @tArgs) },
        debug        => sub { Mediabot::mbDebug($self, $message, $sNick, $sChannel, @tArgs) },
        version      => sub { $self->versionCheck($message, $sChannel, $sNick) },
        help         => sub {
            if (defined($tArgs[0]) && $tArgs[0] ne "") {
                Mediabot::botPrivmsg($self, $sChannel, "Help on command $tArgs[0] is not available (unknown command ?). Please visit https://github.com/teuk/mediabot_v3/wiki");
            } else {
                Mediabot::botPrivmsg($self, $sChannel, "Please visit https://github.com/teuk/mediabot_v3/wiki for full documentation on mediabot");
            }
        },
    );

    if (exists $command_map{$sCommand}) {
        $self->{logger}->log(3, "✅ PUBLIC: $sNick triggered .$sCommand on $sChannel");
    }

    if (exists $command_map{lc $sCommand}) {
        $command_map{lc $sCommand}->();
        return;
    }

    my $found = Mediabot::mbDbCommand($self, $message, $sChannel, $sNick, $sCommand, @tArgs);
    return if $found;

    if ($botNickTriggered) {
        my $what = join(" ", $sCommand, @tArgs);

        if ($what =~ /how\s+old\s+(are|r)\s+(you|u)/i) {
            Mediabot::displayBirthDate($self, $message, $sNick, $sChannel, @tArgs);
        }
        elsif ($what =~ /who.*(your daddy|is your daddy)/i) {
            my $owner = Mediabot::getChannelOwner($self, $sChannel);
            my $reply = defined $owner && $owner ne ""
                ? "Well I'm registered to $owner on $sChannel, but Te[u]K's my daddy"
                : "I have no clue of who is " . $sChannel . "'s owner, but Te[u]K's my daddy";
            Mediabot::botPrivmsg($self, $sChannel, $reply);
        }
        elsif ($what =~ /^(thx|thanx|thank you|thanks)$/i) {
            Mediabot::botPrivmsg($self, $sChannel, "you're welcome $sNick");
        }
        else {
            Mediabot::hailo($self, $message, $sNick, $sChannel, $what);
        }
    }
}

# Extracts reply target from a message (either channel or sender nick)
sub getReplyTarget {
    my ($self, $message, $nick) = @_;
    my $target = $message->{params}[0] // '';
    return ($target =~ /^#/) ? $target : $nick;
}

# 🧙‍♂️ Handle private commands with centralized dispatching and full command set.
sub mbCommandPrivate {
    my ($self, $message, $sNick, $sCommand, @tArgs) = @_;

    $sCommand = lc $sCommand;

    my %command_table = (
        die          => \&Mediabot::mbQuit,
        nick         => \&Mediabot::mbChangeNick,
        addtimer     => \&Mediabot::mbAddTimer,
        remtimer     => \&Mediabot::mbRemTimer,
        timers       => \&Mediabot::mbTimers,
        register     => \&Mediabot::mbRegister,
        dump         => \&Mediabot::dumpCmd,
        msg          => \&Mediabot::msgCmd,
        say          => \&Mediabot::sayChannel,
        act          => \&Mediabot::actChannel,
        status       => \&Mediabot::mbStatus,
        login        => \&Mediabot::userLogin,
        pass         => \&Mediabot::userPass,
        ident        => \&Mediabot::userIdent,
        cstat        => \&Mediabot::userCstat,
        adduser      => \&Mediabot::addUser,
        deluser      => \&Mediabot::delUser,
        users        => \&Mediabot::userStats,
        userinfo     => \&Mediabot::userInfo,
        addhost      => \&Mediabot::addUserHost,
        addchan      => \&Mediabot::addChannel,
        chanset      => \&Mediabot::channelSet,
        purge        => \&Mediabot::purgeChannel,
        part         => \&Mediabot::channelPart,
        join         => \&Mediabot::channelJoin,
        add          => \&Mediabot::channelAddUser,
        del          => \&Mediabot::channelDelUser,
        modinfo      => \&Mediabot::userModinfo,
        op           => \&Mediabot::userOpChannel,
        deop         => \&Mediabot::userDeopChannel,
        invite       => \&Mediabot::userInviteChannel,
        voice        => \&Mediabot::userVoiceChannel,
        devoice      => \&Mediabot::userDevoiceChannel,
        kick         => \&Mediabot::userKickChannel,
        topic        => \&Mediabot::userTopicChannel,
        showcommands => \&Mediabot::userShowcommandsChannel,
        chaninfo     => \&Mediabot::userChannelInfo,
        chanlist     => \&Mediabot::channelList,
        whoami       => \&Mediabot::userWhoAmI,
        verify       => \&Mediabot::userVerifyNick,
        auth         => \&Mediabot::userAuthNick,
        access       => \&Mediabot::userAccessChannel,
        addcmd       => \&Mediabot::mbDbAddCommand,
        remcmd       => \&Mediabot::mbDbRemCommand,
        modcmd       => \&Mediabot::mbDbModCommand,
        showcmd      => \&Mediabot::mbDbShowCommand,
        chowncmd     => \&Mediabot::mbChownCommand,
        mvcmd        => \&Mediabot::mbDbMvCommand,
        countcmd     => \&Mediabot::mbCountCommand,
        topcmd       => \&Mediabot::mbTopCommand,
        popcmd       => \&Mediabot::mbPopCommand,
        searchcmd    => \&Mediabot::mbDbSearchCommand,
        lastcmd      => \&Mediabot::mbLastCommand,
        owncmd       => \&Mediabot::mbDbOwnersCommand,
        holdcmd      => \&Mediabot::mbDbHoldCommand,
        addcatcmd    => \&Mediabot::mbDbAddCategoryCommand,
        chcatcmd     => \&Mediabot::mbDbChangeCategoryCommand,
        topsay       => \&Mediabot::userTopSay,
        checkhostchan => \&Mediabot::mbDbCheckHostnameNickChan,
        checkhost    => \&Mediabot::mbDbCheckHostnameNick,
        checknick    => \&Mediabot::mbDbCheckNickHostname,
        greet        => \&Mediabot::userGreet,
        nicklist     => \&Mediabot::channelNickList,
        rnick        => \&Mediabot::randomChannelNick,
        chanstatlines => \&Mediabot::channelStatLines,
        whotalk      => \&Mediabot::whoTalk,
        birthdate    => \&Mediabot::displayBirthDate,
        ignores      => \&Mediabot::IgnoresList,
        ignore       => \&Mediabot::addIgnore,
        unignore     => \&Mediabot::delIgnore,
        metadata     => \&Mediabot::setRadioMetadata,
        update       => \&Mediabot::update,
        lastcom      => \&Mediabot::lastCom,
        moduser      => \&Mediabot::mbModUser,
        antifloodset => \&Mediabot::setChannelAntiFloodParams,
        rehash       => \&Mediabot::mbRehash,
        play         => \&Mediabot::playRadio,
        radiopub     => \&Mediabot::radioPub,
        song         => \&Mediabot::displayRadioCurrentSong,
        debug        => \&Mediabot::mbDebug,
    );

    if (my $handler = $command_table{$sCommand}) {
        my $reply_target = getReplyTarget($self, $message, $sNick);
        return $handler->($self, $message, $reply_target, $sNick, @tArgs);
    }

    $self->{logger}->log(3, $message->prefix . " Private command '$sCommand' not found");
    return undef;
}

1;
