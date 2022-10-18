use v6.d;
use DateTime::React;
use Test;

my $now = DateTime.now;
my $s = ceiling 60 - $now.second;
my $clock__ = sprintf("%2d:%02d:%02d",(.hour,.minute,.second with $now));
my $second = $s == 1 ?? 'second' !! 'seconds';

# Warn users so they know we're not hanging
note "This module is not fully testable on the user side since we cannot \n",
    "manually adjust the system clock to test for the date/time conditions\n",
    "that this module reacts to.  It will, however, test for the minute\n",
    "roll over. The current time is $clock__, so this test should take\n",
    "approximately $s $second to complete.  Please be patient.";

# Used just in case something goes wrong so we can fail gracefully
my $event-called = False;

# Asynchronous here because if something goes wrong,
# the test file will never exit.
start react {
    whenever shifts('minute') -> $shift {
        my $time = DateTime.now;
        ok -0.1 < $time - $shift.time < 0.1, "Time shift event dispatched reasonably close to scheduled time";
        is $shift.next-at - $shift.time, 60, "Next event calculation";
        is $shift.type, 'minute', "Time shift event reported";
        $event-called = True;
    }
}

# Sleep just a teensy bit longer than needed (we already
# called ceiling so this will be 1-2 seconds extra)
sleep $s + 1;

# If the event is never called, this will actually fail how installers expect
ok $event-called, "Time shift event called";

done-testing;
