use v6.d;
unit module React;

use DateTime::React::Shifts:auth<zef:guifa>;

sub term:<minute-shifts> is export {
    .return with state $supply;
    state $supplier = Supplier.new;
    $supply = $supplier.Supply;

    start {
        my $time = DateTime.now.truncated-to('minute').later(:1minute);
        my $next-at;
        loop {
            $next-at = $time.later(:1minute);
            await Promise.at($time.Instant);
            $supplier.emit: Shift::Minute.new(:$time, :$next-at);
            $time = $next-at;
        }
    }
    $supply;
}

sub term:<hour-shifts> is export {
    .return with state $supply;
    state $supplier = Supplier.new;
    $supply = $supplier.new;

    start {
        my $time = DateTime.now.truncated-to('hour').later(:1hour);
        my $next-at;
        loop {
            $next-at = $time.later(:1hour);
            await Promise.at($time.Instant);
            $supplier.emit: Shift::Hour.new(:$time, :$next-at);
            $time = $next-at;
        }
    }
    $supply
}

sub term:<day-shifts> is export {
    .return with state $supply;
    state $supplier = Supplier.new;
    $supply = $supplier.new;

    start {
        my $time = DateTime.now.truncated-to('day').later(:1day);
        my $next-at;
        loop {
            $next-at = $time.later(:1day);
            await Promise.at($time.Instant);
            $supplier.emit: Shift::Day.new(:$time, :$next-at);
            $time = $next-at;
        }
    }
    $supply
}

sub term:<month-shifts> is export {
    .return with state $supply;
    state $supplier = Supplier.new;
    $supply = $supplier.new;

    start {
        my $time = DateTime.now.truncated-to('month').later(:1month);
        my $next-at;
        loop {
            $next-at = $time.later(:1month);
            await Promise.at($time.Instant);
            $supplier.emit: Shift::Month.new(:$time, :$next-at);
            $time = $next-at;
        }
    }
    $supply
}

sub term:<year-shifts> is export {
    .return with state $supply;
    state $supplier = Supplier.new;
    $supply = $supplier.new;

    start {
        my $time = DateTime.now.truncated-to('year').later(:1year);
        my $next-at;
        loop {
            $next-at = $time.later(:1year);
            await Promise.at($time.Instant);
            $supplier.emit: Shift::Year.new(:$time, :$next-at);
            $time = $next-at;
        }
    }
    $supply
}

sub term:<timezone-shifts> is export {
    .return with state $supply;
    state $supplier = Supplier.new;
    $supply = $supplier.new;

    start {
        use User::Timezone:auth<zef:guifa>;
        use Timezones::ZoneInfo:auth<zef:guifa> :tz-shift, :constants;

        my $zone = timezone-data user-timezone;
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
            $supplier.emit:
                Shift::Timezone.new(
                    :$time,
                    :$next-at,
                    :$old-offset,
                    :$new-offset,
                    olson-id => $zone.name);

            # Cycle values
            $time = $next-at;
            $old-offset = $new-offset;
        }
    }
    $supply
}

# Backwards compatibility with v0.1.*
our &minute-shifts   is export = &term:<minute-shifts>;
our &hour-shifts     is export = &term:<hour-shifts>;
our &day-shifts      is export = &term:<day-shifts>;
our &month-shifts    is export = &term:<month-shifts>;
our &year-shifts     is export = &term:<year-shifts>;
our &timezone-shifts is export = &term:<timezone-shifts>;