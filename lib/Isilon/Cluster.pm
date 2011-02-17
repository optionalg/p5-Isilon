package Isilon::Cluster;

use strict;
use warnings;

use Carp;
use Net::SNMP qw(:asn1 :snmp DEBUG_ALL);

our $LASTERROR;

sub new {
	my $self = shift;
	my $class = ref($self) || $self;

	my %params =
	(
		community => 'public',
		port      => 161,
		timeout   => 10,
		version   => '2c'
	);

	my %args;
	if (@_ == 1) {
		($params{'hostname'}) = @_
	} else {
		%args = @_;
		for (keys(%args)) {
			if (/^-?port$/i) {
				$params{'port'} = $args{$_}
			} elsif (/^-?community$/i) {
				$params{'community'} = $args{$_}
			} elsif ((/^-?hostname$/i) || (/^-?(?:de?st|peer)?addr$/i)) {
				$params{'hostname'} = $args{$_}
			} elsif (/^-?timeout$/i) {
				$params{'timeout'} = $args{$_}
			}
		}
	}

	my ($session, $error) = Net::SNMP->session(%params);

	if (!defined($session)) {
		$LASTERROR = "Error creating Net::SNMP object: $error";
		return(undef)
	}

	return bless {
		%params,
		'_SESSION_' => $session
	}, $class
}

sub session {
	my $self = shift;
	return $self->{'_SESSION_'}
}

sub name {
	my $self  = shift;
	my $class = ref($self) || $self;

	my $session = $self->{'_SESSION_'};

	my $clusterName = '1.3.6.1.4.1.12124.1.1.1.0';
	my $response = $session->get_request($clusterName);
	if (!defined($response)) {
		$LASTERROR = $session->error;
		return(undef);
	}
	return $response->{$clusterName};
}

sub health {
	my $self  = shift;
	my $class = ref($self) || $self;

	my $clusterHealth = '1.3.6.1.4.1.12124.1.1.2.0';

	my $session = $self->{'_SESSION_'};

	my $response = $session->get_request($clusterHealth);
	if (!defined($response)) {
		$LASTERROR = $session->error;
		return(undef);
	}
	# 0 = ok, 1 = attn, 2 = down, 3 = invalid
	return $response->{$clusterHealth};
}

sub guid {
	my $self  = shift;
	my $class = ref($self) || $self;

	my $session = $self->{'_SESSION_'};

	my $clusterGUID = '1.3.6.1.4.1.12124.1.1.3.0';
	my $response = $session->get_request($clusterGUID);
	if (!defined($response)) {
		$LASTERROR = $session->error;
		return(undef);
	}
	return $response->{$clusterGUID};
}

sub nodecount {
	my $self  = shift;
	my $class = ref($self) || $self;

	my $session = $self->{'_SESSION_'};

	my $nodeCount = '1.3.6.1.4.1.12124.1.1.4.0';
	my $response = $session->get_request($nodeCount);
	if (!defined($response)) {
		$LASTERROR = $session->error;
		return(undef);
	}
	return $response->{$nodeCount};
}

sub close {
	my $self = shift;
	$self->{_SESSION_}->close();
}

sub error {
	return($LASTERROR)
}

1;

__END__

=head1 NAME

Isilon::Cluster - Interface for an Isilon Cluster

=head1 SYNOPSIS

	use Isilon::Cluster;

	my $isi = new Isilon::Cluster(
		-hostname  => 'beaker',
		-community => 'public',
		-version   => '2c'
	);

	print $isi->name();

	$isi->close();

=head1 DESCRIPTION

Isilon::Cluster is a class for retrieving management data from
Isilon clusters - mostly via SNMP.  Isilon::Cluster uses the
Net::SNMP module to do the SNMP calls.

=head1 METHODS

=head2 new

Creates a new Isilon::Cluster object

	my $isi = Isilon::Cluster->new([OPTIONS]);

=head1 BUGS

None known

=head1 DEVELOPERS

The latest code for this module can be found at

http://github.com/skreuzer/p5-Isilon

=head1 AUTHOR

Written by Steven Kreuzer <skreuzer@exit2shell.com>

=head1 COPYRIGHT

Copyright (c) 2010-2011, Steven Kreuzer

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl
itself.

=cut
