use v6.d;
unit module React;

use DateTime::React::Shifts:auth<zef:guifa>;

my %supplies;

sub shifts ( $type where *.first( <minute hour day week month year>.any ) )
  is export
{
    .return with %supplies{$type};

    %supplies{$type} = supply {
      CATCH { default { .message.say; .rethrow } }

        my $time = DateTime.now.truncated-to($type).later( |($type  => 1) );
        my $next-at;
        loop {
            $next-at = $time.later(:1minute);
            await Promise.at($time.Instant);
            my %args = ( :$time, :$next-at );
            emit (
              do given $type {
                when 'minute' { Shift::Minute }
                when 'hour'   { Shift::Hour   }
                when 'day'    { Shift::Day    }
                when 'week'   { Shift::Week   }
                when 'month'  { Shift::Month  }
                when 'year'   { Shift::Year   }
              }
            ).new( |%args );
            $time = $next-at;
        }
    }
}

sub timezone-shifts is export {
    .return with state $supply;

    $supply = supply {
        use User::Timezone:auth<zef:guifa>;
        use Timezones::ZoneInfo:auth<zef:guifa> :tz-shift, :constants;

        my $zone = user-timezone;
        my $time = next-tz-shift(now.to-posix.head.Int, $zone);
        my $next-at;
        my $old-offset = $*TZ;
        my $new-offset;

        loop {
            # If the value of $time is max-time, there are no future changes,
            # so we can just exit the loop, effectively ending the supply
            last if $time == max-time;

            # Calculate the new values and wait (we could calculate these after await,
            # but then the emission would be delayed a smidgen more).
            $next-at = next-tz-shift $time + 1, $zone;
            $new-offset = calendar-from-posix($time, $zone).gmt-offset;
            await Promise.at(Instant.from-posix: $time);

            # Update $*TZ (in case some other module isn't already doing this
            $*TZ = $new-offset;
            # This event provides a bit more information than the previous ones
            emit Shift::Timezone.new: :$time, :$next-at, :$old-offset, :$new-offset, olson-id => $zone.name;

            # Cycle values
            $time = $next-at;
            $old-offset = $new-offset;
        }
    }
}
