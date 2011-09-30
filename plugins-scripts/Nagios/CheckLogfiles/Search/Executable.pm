package Nagios::CheckLogfiles::Search::Executable;

use strict;
use Exporter;
use File::Basename;
use vars qw(@ISA);

use constant OK => 0;
use constant WARNING => 1;
use constant CRITICAL => 2;
use constant UNKNOWN => 3;

@ISA = qw(Nagios::CheckLogfiles::Search);

sub new {
  my $self = bless {}, shift;
  return $self->init(shift);
}
    
sub analyze_situation {
  my $self = shift;
  $self->{logmodified} = 1; 
}

sub collectfiles {
  my $self = shift;
  my @rotatedfiles = ();
  my $fh = new IO::File;
  #if ($self->getfileisreadable($self->{logfile})) {
  if ($self->getfileisexecutable($self->{logfile})) {
    $fh->open($self->{logfile}."|");
    $self->trace("opened scriptfile %s", $self->{logfile});
    push(@{$self->{relevantfiles}},
      { filename => $self->{logfile}, 
        fh => $fh, seekable => 0,
        modtime => time,
        fingerprint => "0:0" });
  } else {
    if (-e $self->{logfile}) {
      #  permission problem
      $self->trace("could not open logfile %s", $self->{logfile});
      $self->addevent('CRITICAL', sprintf "could not open logfile %s",
          $self->{logfile});
    } else {
      if ($self->{options}->{logfilenocry}) {
        $self->trace("could not find scriptfile %s", $self->{logfile});
        $self->addevent('UNKNOWN', sprintf "could not find scriptfile %s",
            $self->{logfile});
      } else {
        # dont care.
        $self->trace("could not find scriptfile %s, but that's ok",
            $self->{logfile});
      }
    }
  }
}

sub loadstate {
  my $self = shift;
  $self->SUPER::loadstate();
  $self->{laststate}->{logoffset} = 0;
}

sub savestate {
  my $self = shift;
  foreach (keys %{$self->{laststate}}) {
    $self->{newstate}->{$_} = $self->{laststate}->{$_};
  }
  $self->SUPER::savestate();
}



