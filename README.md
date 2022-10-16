# DateTime::React

A module for Raku that makes it incredibly easy to be alerted when clock rollovers occur (e.g. when the minute or hour ticks up).

Using it is very simple:

    use DateTime::React;
    
    react {
        whenever minute-shifts() { 
            say "We've gone from ??:??:59 to ??:??:00!";
        }
        whenever hour-shifts() {
            say "We've gone from ??:59:59 to to ??:00:00!"; 
        }
        whenever day-shifts() {
            say "We've gone from 23:59:59 to to 00:00:00!"; 
        }
        whenever timezone-shifts() -> $shift {
            say "The offset in {$shift.timezone} is now {$shift.new-offset}!"; 
        }
    }

Each supply emits a meta event of type `DateTimeEventish`.  It provides three values:
   * **`time`**: the time the event was scheduled
   * **`next-at`**: when the next event will occur 
   * **`type`**: the type of event (any of *minute, hour, day, month, year, timezone*)

Currently, only `timezone-shifts()` provides additional metadata:
   * **`olson-id`**: the Olson (or IANA) identifier for the timezone 
   * **`timezone`**: an alias of `olson-id`
   * **`old-offset`**: the former GMT offset (e.g. -5h for *America/New_York* for spring switch over)
   * **`new-offset`**: the now current GMT offset (e.g. -4h for *America/New_York* for spring switch over)

When using `timezone-shifts()`, this module will (currently) automatically adjust the `$*TZ` value for you so that new DateTime objects are generated with the correct offset.
Be mindful that DateTime itself is not timezone aware, so creating historical/future dates will always use the current $*TZ value.
If that is needed, you should look at the `DateTime::Timezones` module which does that for you.

The `$*TZ` adjusting feature may be moved into a different module down the road but the behavior will be maintained (at the cost of an additional dependency for this one).

# Version history
  * **v0.1.0**
    * Initial release

# Copyright / License
Copyright © 2022 Matthew Stephen Stuckwisch.  Licensed under the Artistic License 2.0