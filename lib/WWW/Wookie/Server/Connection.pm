package WWW::Wookie::Server::Connection;  # -*- cperl; cperl-indent-level: 4 -*-
use strict;
use warnings;

# $Id: Connection.pm 365 2010-11-25 01:15:48Z roland $
# $Revision: 365 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/lib/WWW/Wookie/Server/Connection.pm $
# $Date: 2010-11-25 02:15:48 +0100 (Thu, 25 Nov 2010) $

use utf8;
use 5.006000;

our $VERSION = '0.03';

use Data::Dumper;
use Moose qw/around has/;
use Moose::Util::TypeConstraints qw/as coerce from where subtype via/;
use URI;
use LWP::UserAgent;
use XML::Simple;

use overload '""' => 'as_string';

use Readonly;
## no critic qw(ProhibitCallsToUnexportedSubs)
Readonly::Scalar my $EMPTY     => q{};
Readonly::Scalar my $MORE_ARGS => 3;
Readonly::Scalar my $ADVERTISE => q{advertise?all=true};
Readonly::Scalar my $TIMEOUT   => 15;
Readonly::Scalar my $AGENT     => q{WWW::Wookie/} . $VERSION;
Readonly::Scalar my $SERVER_CONNECTION =>
  q{Wookie Server Connection - URL: %sAPI Key: %sShared Data Key: %s};
## use critic

subtype 'Trailing' => as 'Str' => where { m{(^$|(/$))}gsmx };

coerce 'Trailing' => from 'Str' => via { $_ =~ s{([^/])$}{$1/}gsmx; $_ };

has _url => (
    is     => 'ro',
    isa    => 'Trailing',
    coerce => 1,
    reader => 'getURL',
);

has _api_key => (
    is      => 'ro',
    isa     => 'Str',
    default => q{TEST},
    reader  => 'getApiKey',
);

has _shared_data_key => (
    is      => 'ro',
    isa     => 'Str',
    default => q{mysharedkey},
    reader  => 'getSharedDataKey',
);

sub as_string {
    my $self = shift;
    return sprintf $SERVER_CONNECTION, $self->getURL, $self->getApiKey,
      $self->getSharedDataKey;
}

sub test {
    my $self = shift;
    my $url  = $self->getURL;
    if ( $url ne $EMPTY ) {
        my $ua = LWP::UserAgent->new(
            timeout => $TIMEOUT,
            agent   => $AGENT,
        );
        my $response = $ua->get( $url . $ADVERTISE );
        if ( $response->is_success ) {
            my $xml_obj =
              XML::Simple->new( ForceArray => 1, KeyAttr => 'identifier' )
              ->XMLin( $response->content );
            if ( exists $xml_obj->{widget} ) {
                return 1;
            }
        }
    }
    return 0;
}

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    if ( @_ == $MORE_ARGS && !ref $_[0] ) {
        my ( $url, $api_key, $shareddata_key ) = @_;
        return $class->$orig(
            _url             => $url,
            _api_key         => $api_key,
            _shared_data_key => $shareddata_key,
        );
    }
    return $class->$orig(@_);
};

no Moose;

## no critic qw(RequireExplicitInclusion)
__PACKAGE__->meta->make_immutable;
## use critic

1;

__END__

=encoding utf8

=for stopwords Roland van Ipenburg Wookie API Readonly URI URL

=head1 NAME

WWW::Wookie::Server::Connection - A connection to a Wookie server

=head1 VERSION

This document describes WWW::Wookie::Server::Connection version 0.03

=head1 SYNOPSIS

    use WWW::Wookie::Server::Connection;
    $c = WWW::Wookie::Server::Connection->new($url, $api_key, $data_key);

=head1 DESCRIPTION

A connection to a Wookie server. This maintains the necessary data for
connecting to the server and provides utility methods for making common calls
via the Wookie REST API.

=head1 SUBROUTINES/METHODS

=head2 C<new>

Create a connection to a Wookie server at a given URL.

=over 4

=item 1. The URL of the Wookie server as string

=item 2. The API key for the server as string

=item 3. The shared data key for the server connection as string

=back

=head2 C<getURL>

Get the URL of the Wookie server. Returns the current Wookie connection's URL
as string.

=head2 C<setURL>

Set the URL of the Wookie server.

=head2 C<getApiKey>

Get the API key for this server. Returns the current Wookie connection's API
key as string. Throws a C<WookieConnectorException>.

=head2 C<setApiKey>

Set the API key for this server.

=head2 C<getSharedDataKey>

Get the shared data key for this server. Returns the current Wookie
connection's shared data key. Throws a C<WookieConnectorException>.

=head2 C<setSharedDataKey>

Set the shared data key for this server.

=head2 C<as_string>

Output connection information as string.

=head2 C<test>

Test the Wookie server connection.

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

L<Data::Dumper|Data::Dumper>
L<LWP::UserAgent|LWP::UserAgent>
L<Moose|Moose>
L<Moose::Util::TypeConstraints|Moose::Util::TypeConstraints>
L<Readonly|Readonly>
L<URI|URI>
L<XML::Simple|XML::Simple>
L<overload|overload>

=head1 INCOMPATIBILITIES

=head1 DIAGNOSTICS

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests at L<RT for
rt.cpan.org|https://rt.cpan.org/Dist/Display.html?Queue=WWW-Wookie>.

=head1 AUTHOR

Roland van Ipenburg  C<< <ipenburg@xs4all.nl> >>

=head1 LICENSE AND COPYRIGHT

    Copyright 2010 Roland van Ipenburg

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

=head1 DISCLAIMER OF WARRANTY

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

=cut
