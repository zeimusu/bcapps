#!/bin/perl

# This script will handle all nagios notifications (currently empty)

push(@INC,"/usr/local/lib");
require "bclib.pl";

open(A,">/tmp/bc-nagios-handler-test1.txt");
for $i (sort keys %ENV) {
  print A "$i -> $ENV{$i}\n";
}
close(A);
