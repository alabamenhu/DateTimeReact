#!/usr/bin/env raku

# The most inefficient clock ever.

use v6.d;
use DateTime::React:auth<zef:guifa>:ver<0.1.1>;
use Timezones::ZoneInfo;
use User::Timezone;

# Initial data
my $zone   = timezone-data user-timezone;
my $date   = DateTime.now;
my $minute = $date.minute;
my $hour   = $date.hour;
my $day    = $date.day;
my $month  = $date.month;
my $year   = $date.year;
my $tz     = calendar-from-posix($date.posix.Int, $zone).tz-abbr;


#| Update the display based on stored data
sub update-display {
    print sprintf "\r%04d/%02d/%02d at %02d:%02d %s", $year, $month, $day, $hour, $minute, $tz
}

# An initial print so it's not blank initially
update-display;

# Begin our block
react {
    whenever minute-shifts {
        $minute = .time.minute;
        # Sometimes the other events can fire a split second too soon
        Promise.in(0.01).then: { update-display }
    }
    whenever hour-shifts     { $hour  = .time.hour  }
    whenever day-shifts      { $day   = .time.day   }
    whenever month-shifts    { $month = .time.month }
    whenever year-shifts     { $day   = .time.year  }
    whenever timezone-shifts {
        $tz = calendar-from-posix(.posix.Int, $zone).tz-abbr
    }
}