use v6.d;
use DateTime::React:ver<0.1.1>;
use Test;

my $now = DateTime.now;
my $s = 60 + ceiling 60 - $now.second;
my $clock__ = sprintf("%2d:%02d:%02d",(.hour,.minute,.second with $now));

# Warn users so they know we're not hanging
note "This module is not fully testable on the user side since it is not \n",
     "possible to manually adjust the system clock to test for the date/\n",
     "time conditions that this module reacts to. It will, however, test \n",
     "that the minute rollover correctly fires twice. The current time's \n",
     "$clock__ so this test should take around $s seconds to complete. \n\n",
     "Please be patient and enjoy the module! ~~ Matéu";

# Used just in case something goes wrong so we can fail gracefully
my $event-called = 0;

# Asynchronous here because if something goes wrong,
# the test file will never exit.
start react {
    whenever minute-shifts() -> $shift {
        $event-called++;
        my $time = DateTime.now;
        ok -0.1 < $time - $shift.time < 0.1, "Time shift event dispatched reasonably close to scheduled time (round $event-called)";
        is $shift.next-at - $shift.time, 60, "Next event calculation (round $event-called)";
        is $shift.type, 'minute', "Time shift event reported (round $event-called)";
    }
}

# Sleep just a teensy bit longer than needed (we already
# called ceiling so this will be 1-2 seconds extra)
sleep $s + 1;

# If the event is never called, this will actually fail how installers expect
ok $event-called  > 0, "Time shift event called at least once";
ok $event-called == 2, "Time shift event called both times";

done-testing;
