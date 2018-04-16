#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use AnyEvent;
use AnyEvent::I3 qw(:all);

my $i3 = i3();

$i3->connect->recv or die "Could not connect to i3: $!";
$i3->message(TYPE_COMMAND, "mode 1");

my %callbacks = (
  workspace => sub {
    my $e = shift;
    my $mode = substr $e->{'current'}->{'name'}, -1;

    $i3->message(TYPE_COMMAND, "mode ${mode}");
  },
  _error => sub {
    my $msg = shift;

    unless ($msg eq 'Unexpected end-of-file') {
      print STDERR "An error occured: $msg";
      exit 1;
    }

    exit 0;
  }
);

$i3->subscribe(\%callbacks)->recv->{success}
  or die "Could not subscribe to the events: $!";



AE::cv->recv;
