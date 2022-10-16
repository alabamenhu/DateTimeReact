use v6.d;
unit module Shifts;

role DateTimeEventish
is   export
{
    has $.type;
    has $.time;
    has $.next-at;
}

class Shift::Timezone
does  DateTimeEventish
is    export
{
    has $.olson-id;   #= The Olson ID for the timezone
    has $.old-offset; #= The former GMT offset for the timezone
    has $.new-offset; #= The current GMT offset for the timezone
    method timezone { #= The Olson ID for the timezone (alias of .olson-id)
        $!olson-id
    }
    method new (|c) { self.bless: |c, :type<timezone> }
}

class Shift::Minute
does  DateTimeEventish
is    export
{
    method new (|c) { self.bless: |c, :type<minute> }
}

class Shift::Hour
does  DateTimeEventish
is    export
{
    method new (|c) { self.bless: |c, :type<hour> }
}

class Shift::Day
does  DateTimeEventish
is    export
{
    method new (|c) { self.bless: |c, :type<day> }
}

class Shift::Month
does  DateTimeEventish
is    export
{
    method new (|c) { self.bless: |c, :type<month> }
}

class Shift::Year
does  DateTimeEventish
is    export
{
    method new (|c) { self.bless: |c, :type<year> }
}