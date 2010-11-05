package WWW::Wookie::Connector::Service;  # -*- cperl; cperl-indent-level: 4 -*-
use strict;
use warnings;

# $Id: Service.pm 351 2010-11-05 23:02:40Z roland $
# $Revision: 351 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/lib/WWW/Wookie/Connector/Service.pm $
# $Date: 2010-11-06 00:02:40 +0100 (Sat, 06 Nov 2010) $

use utf8;
use 5.006000;

our $VERSION = '0.01';

use CGI;
use Exception::Class;
use HTTP::Headers;
use HTTP::Request;
use HTTP::Request::Common;
use HTTP::Status qw(HTTP_CREATED HTTP_OK HTTP_UNAUTHORIZED);
use LWP::UserAgent qw/POST/;
use Log::Log4perl qw(:easy get_logger);
use Moose qw/around has with/;
use MooseX::AttributeHelpers;
use Regexp::Common qw(URI);
use XML::Simple;
use namespace::autoclean;

use WWW::Wookie::Connector::Exceptions;
use WWW::Wookie::Server::Connection;
use WWW::Wookie::User;
use WWW::Wookie::Widget;
use WWW::Wookie::Widget::Property;
use WWW::Wookie::Widget::Instance;
use WWW::Wookie::Widget::Instances;

use Readonly;
## no critic qw(ProhibitCallsToUnexportedSubs)
Readonly::Scalar my $EMPTY           => q{};
Readonly::Scalar my $QUERY           => q{?};
Readonly::Scalar my $TRUE            => 1;
Readonly::Scalar my $FALSE           => 0;
Readonly::Scalar my $MORE_ARGS       => 4;
Readonly::Scalar my $MOST_ARGS       => 5;
Readonly::Scalar my $GET             => q{GET};
Readonly::Scalar my $POST            => q{POST};
Readonly::Scalar my $DELETE          => q{DELETE};
Readonly::Scalar my $PARTICIPANTS    => q{participants};
Readonly::Scalar my $PROPERTIES      => q{properties};
Readonly::Scalar my $WIDGETINSTANCES => q{widgetinstances};
Readonly::Scalar my $DEFAULT_ICON =>
  q{http://www.oss-watch.ac.uk/images/logo2.gif};
Readonly::Scalar my $DEFAULT_SCHEME => q{http};
Readonly::Scalar my $VALID_SCHEMES  => $DEFAULT_SCHEME . q{s?};    # http(s)

Readonly::Hash my %ERR => (
    NO_WIDGET_INSTANCE     => q{No Widget instance},
    NO_PROPERTIES_INSTANCE => q{No properties instance},
    NO_USER_OBJECT         => q{No User object},
    NO_WIDGET_GUID         => q{No GUID nor widget object},
    MALFORMED_URL => q{URL for supplied Wookie Server is malformed: %s},
    INCORRECT_PARTICIPANTS_REST_URL =>
      q{Participants rest URL is incorrect: %s},
    INCORRECT_PROPERTIES_REST_URL => q{Properties rest URL is incorrect: %s},
    INVALID_API_KEY               => q{Invalid API key},
    HTTP                          => q{%s<br />%s},
);
## use critic

## no critic qw(ProhibitCallsToUnexportedSubs)
Log::Log4perl::easy_init($DEBUG);
## use critic

has '_logger' => (
    is  => 'ro',
    isa => 'Log::Log4perl::Logger',
    default =>
      sub { Log::Log4perl->get_logger('WWW::Wookie::Connector::Service') },
    reader => 'getLogger',
);

has '_conn' => (
    is     => 'rw',
    isa    => 'WWW::Wookie::Server::Connection',
    reader => 'getConnection',
    writer => '_setConnection',
);

has '_ua' => (
    is      => 'rw',
    isa     => 'LWP::UserAgent',
    default => sub { LWP::UserAgent->new },
);

has 'WidgetInstances' => (
    is     => 'rw',
    isa    => 'WWW::Wookie::Widget::Instances',
    writer => '_setWidgetInstances',
);

sub _check_url {
    my ( $self, $url ) = @_;
    return $url =~ m{^$RE{URI}{HTTP}{-keep}{ -scheme => $VALID_SCHEMES }$}smx;
}

## no critic qw(Capitalization)
sub getProperty {
## use critic
    my ( $self, $widget_instance, $property_instance ) = @_;
    my $url = $self->getConnection()->getURL() . $PROPERTIES;
    if ( !ref $widget_instance ne q{WWW::Wookie::Widget::Instance} ) {
        ## no critic qw(RequireExplicitInclusion)
        WookieWidgetInstanceException->throw(
            error => $ERR{NO_WIDGET_INSTANCE} );
        ## use critic
    }
    if ( !ref $property_instance ne q{WWW::Wookie::Property} ) {
        ## no critic qw(RequireExplicitInclusion)
        WookieConnectorException->throw(
            error => $ERR{NO_PROPERTIES_INSTANCE} );
        ## use critic
    }
    my $request = CGI->new(
        {
            'api_key'       => $self->getConnection()->getApiKey(),
            'shareddatakey' => $self->getConnection()->getSharedDataKey(),
            'userid'        => $self->getUser()->getLoginName(),
            'widgetid'      => $widget_instance->getIdentifier(),
            'propertyname'  => $property_instance->getName(),
        }
    );
    if ( !$self->_check_url($url) ) {
        ## no critic qw(RequireExplicitInclusion)
        WookieConnectorException->throw(
            error => sprintf $ERR{INCORRECT_URL},
            $url
        );
        ## use critic
    }
    my $response = $self->_ua->get( $url . $request );
    if ( !$response->is_success ) {
        ## no critic qw(RequireExplicitInclusion)
        WookieConnectorException->throw(
            error => sprintf $ERR{HTTP},
            $response->header()->as_string, $response->content
        );
        ## use critic
    }
    return WWW::Wookie::Widget::Property->new( $property_instance->getName(),
        $response->content );

}

## no critic qw(Capitalization)
sub getOrCreateInstance {
## use critic
    my ( $self, $widget_or_guid ) = @_;
    my $guid;
    if ( ref $widget_or_guid eq q{WWW::Wookie::Widget} ) {
        $guid = $widget_or_guid->getIdentifier();
    }
    else {
        $guid = $widget_or_guid;
    }
    my $result = eval {
        if ( $guid eq $EMPTY )
        {
            ## no critic qw(RequireExplicitInclusion)
            WookieConnectorException->throw( error => $ERR{NO_WIDGET_GUID} );
            ## use critic
        }
        my $requestUrl = $self->getConnection()->getURL() . $WIDGETINSTANCES;
        my $content    = {
            api_key       => $self->getConnection()->getApiKey(),
            userid        => $self->getUser()->getLoginName(),
            shareddatakey => $self->getConnection()->getSharedDataKey(),
            widgetid      => $guid,
        };
        if ( my $locale = $self->getLocale() ) {
            $content->{locale} = $locale;
        }
        if ( !$self->_check_url($requestUrl) ) {
            ## no critic qw(RequireExplicitInclusion)
            WookieConnectorException->throw(
                error => sprintf $ERR{MALFORMED_URL},
                $requestUrl
            );
            ## use critic
        }
        my $response = $self->_do_request( $requestUrl, $content );
        if ( $response->code == HTTP_CREATED ) {
            $response = $self->_do_request( $requestUrl, $content );
        }
        if ( $response->code == HTTP_UNAUTHORIZED ) {
            ## no critic qw(RequireExplicitInclusion)
            WookieConnectorException->throw( error => $ERR{INVALID_API_KEY} );
            ## use critic
        }
        return $self->_parse_instance( $guid, $response->content );
    };

    if ( my $e = Exception::Class->caught('WookieConnectorException') ) {
        $self->getLogger()->error( $e->error );
        return $FALSE;
    }
    return $result;
}

sub _parse_instance {
    my ( $self, $guid, $xml ) = @_;
    my $xs     = XML::Simple->new( ForceArray => 1, KeyAttr => 'identifier' );
    my $xmlObj = $xs->XMLin($xml);
    my $url    = $xmlObj->{url}[0];
    my $title  = $xmlObj->{title}[0];
    my $height = $xmlObj->{height}[0];
    my $width  = $xmlObj->{width}[0];
    my $instance =
      WWW::Wookie::Widget::Instance->new( $url, $guid, $title, $height,
        $width );

    if ($instance) {
        $self->WidgetInstances->put($instance);
        $self->addParticipant( $instance, $self->getUser() );
    }
    return $instance;
}

sub _do_request {
    my ( $self, $url, $data, $method ) = @_;
    if ( !defined $method ) {
        $method = $POST;
    }
    my $dummy = POST $url, [ %{$data} ];
    my $request = HTTP::Request->new(
        $method => $url . $QUERY . $dummy->content,
        HTTP::Headers->new(),
        $dummy->content
    );
    return $self->_ua->request($request);
}

## no critic qw(Capitalization)
sub getUsers {
## use critic
    my ( $self, $widget_instance ) = @_;
    my $url     = $self->getConnection()->getURL() . $PARTICIPANTS;
    my @users   = ();
    my $content = {
        api_key       => $self->getConnection()->getApiKey(),
        shareddatakey => $self->getConnection()->getSharedDataKey(),
        userid        => $self->getUser()->getLoginName(),
        widgetid      => $widget_instance->getIdentifier(),
    };

    if ( !$self->_check_url($url) ) {
        ## no critic qw(RequireExplicitInclusion)
        WookieConnectorException->throw(
            error => sprintf $ERR{INCORRECT_URL},
            $url
        );
        ## use critic
    }
    my $response = $self->_do_request( $url, $content, $GET );
    if ( $response->code > HTTP_OK ) {
        ## no critic qw(RequireExplicitInclusion)
        WookieConnectorException->throw(
            error => sprintf $ERR{HTTP},
            $response->header()->as_string, $response->content
        );
        ## use critic
    }
    my $xs = XML::Simple->new( ForceArray => 1, KeyAttr => 'identifier' );
    my $xmlObj = $xs->XMLin( $response->content );
    for my $participant ( @{ $xmlObj->{participant} } ) {
        my $id            = $participant->{id};
        my $name          = $participant->{displayName};
        my $thumbnail_url = $participant->{thumbnail_url};
        my $new_user =
          WWW::Wookie::User->new( $id, $name || $id, $thumbnail_url || $EMPTY );
        push @users, $new_user;
    }
    return @users;
}

has '_locale' => (
    is     => 'rw',
    isa    => 'Str',
    reader => 'getLocale',
    writer => 'setLocale',
);

has '_user' => (
    is      => 'rw',
    isa     => 'WWW::Wookie::User',
    reader  => 'getUser',
    writer  => 'setUser',
    default => sub { WWW::Wookie::User->new() },
);

has properties => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef[WWW::Wookie::User]',
    default   => sub { {} },
    provides  => {
        'set'    => 'addProperty',
        'delete' => 'deleteProperty',
    },
);

sub getAvailableWidgets {
    my $self    = shift;
    my %widgets = ();
    my $request = $self->getConnection()->getURL() . 'widgets?all=true';
    if ( my $locale = $self->getLocale() ) {
        $request .= qq{&locale=$locale};
    }
    if ( !$self->_check_url($request) ) {
        ## no critic qw(RequireExplicitInclusion)
        WookieConnectorException->throw(
            error => sprintf $ERR{MALFORMED_URL},
            $request->url
        );
        ## use critic
    }

    my $response = $self->_ua->get($request);
    my $xs       = XML::Simple->new( ForceArray => 1, KeyAttr => 'identifier' );
    my $xmlObj   = $xs->XMLin( $response->content );
    while ( my ( $id, $value ) = each %{ $xmlObj->{widget} } ) {
        my $title = $xmlObj->{widget}->{$id}->{title}[0]->{content};
        my $description =
          ref $xmlObj->{widget}->{$id}->{description}[0]
          ? $xmlObj->{widget}->{$id}->{description}[0]->{content}
          : $xmlObj->{widget}->{$id}->{description}[0];
        my $icon =
          ref $xmlObj->{widget}->{$id}->{icon}[0]
          ? $xmlObj->{widget}->{$id}->{icon}[0]->{content}
          : $xmlObj->{widget}->{$id}->{icon}[0];
        if ( !$icon ) {
            $icon = $DEFAULT_ICON;
        }
        $widgets{$id} =
          WWW::Wookie::Widget->new( $id, $title, $description, $icon );
    }
    return %widgets;
}

sub setProperty {
    my ( $self, $widget_instance, $property_instance ) = @_;
    my $url    = $self->getConnection()->getURL() . $PROPERTIES;
    my $result = eval {
        if ( ref $widget_instance ne q{WWW::Wookie::Widget::Instance} )
        {
            ## no critic qw(RequireExplicitInclusion)
            WookieWidgetInstanceException->throw(
                error => $ERR{NO_WIDGET_INSTANCE} );
            ## use critic
        }
        if ( ref $property_instance ne q{WWW::Wookie::Widget::Property} ) {
            ## no critic qw(RequireExplicitInclusion)
            WookieConnectorException->throw(
                error => $ERR{NO_PROPERTIES_INSTANCE} );
            ## use critic
        }
        my $property = {
            api_key       => $self->getConnection()->getApiKey(),
            shareddatakey => $self->getConnection()->getSharedDataKey(),
            userid        => $self->getUser()->getLoginName(),
            widgetid      => $widget_instance->getIdentifier(),
            propertyname  => $property_instance->getName(),
            propertyvalue => $property_instance->getValue(),
            is_public     => $property_instance->getIsPublic(),
        };
        if ( !$self->_check_url($url) ) {
            ## no critic qw(RequireExplicitInclusion)
            WookieConnectorException->throw(
                error => sprintf $ERR{INCORRECT_PROPERTIES_REST_URL},
                $url
            );
            ## use critic
        }
        my $response = $self->_do_request( $url, $property );
        if ( $response->code == HTTP_CREATED ) {
            return $property_instance;
        }
        else {
            ## no critic qw(RequireExplicitInclusion)
            WookieConnectorException->throw(
                error => sprintf $ERR{HTTP},
                $response->header()->as_string, $response->content
            );
            ## use critic
        }
    };
    if ( my $e = Exception::Class->caught('WookieConnectorException') ) {
        $self->getLogger()->error( $e->error );
        return $FALSE;
    }
    if ( my $e = Exception::Class->caught('WookieWidgetInstanceException') ) {
        $self->getLogger()->error( $e->error );
        return $FALSE;
    }
    return $result;
}

sub _setWidgetInstancesHolder {
    my $self = shift;
    $self->_setWidgetInstances( WWW::Wookie::Widget::Instances->new );
    return;
}

sub addParticipant {
    my ( $self, $widget_instance, $user ) = @_;
    my $url         = $self->getConnection()->getURL() . $PARTICIPANTS;
    my $participant = {
        api_key                   => $self->getConnection()->getApiKey(),
        shareddatakey             => $self->getConnection()->getSharedDataKey(),
        userid                    => $self->getUser()->getLoginName(),
        widgetid                  => $widget_instance->getIdentifier(),
        participant_id            => $self->getUser()->getLoginName(),
        participant_display_name  => $user->getScreenName(),
        participant_thumbnail_url => $user->getThumbnailUrl(),
    };
    if ( !$self->_check_url($url) ) {
        ## no critic qw(RequireExplicitInclusion)
        WookieConnectorException->throw(
            error => sprintf $ERR{INCORRECT_PARTICIPANTS_REST_URL},
            $url
        );
        ## use critic
    }
    my $response = $self->_do_request( $url, $participant );
    if ( $response->code == HTTP_OK ) {
        return $TRUE;
    }
    elsif ( $response->code == HTTP_CREATED ) {
        return $TRUE;
    }
    elsif ( $response->code > HTTP_CREATED ) {
        return $response->content;
    }
    return $FALSE;
}

sub deleteParticipant {
    my ( $self, $widget_instance, $user ) = @_;
    my $url         = $self->getConnection()->getURL() . $PARTICIPANTS;
    my $participant = {
        api_key                   => $self->getConnection()->getApiKey(),
        shareddatakey             => $self->getConnection()->getSharedDataKey(),
        userid                    => $self->getUser()->getLoginName(),
        widgetid                  => $widget_instance->getIdentifier(),
        participant_id            => $self->getUser()->getLoginName(),
        participant_display_name  => $user->getScreenName(),
        participant_thumbnail_url => $user->getThumbnailUrl(),
    };
    if ( !$self->_check_url($url) ) {
        ## no critic qw(RequireExplicitInclusion)
        WookieConnectorException->throw(
            error => sprintf $ERR{INCORRECT_PARTICIPANT_REST_URL},
            $url
        );
        ## use critic
    }
    my $response = $self->_do_request( $url, $participant, $DELETE );
    if ( $response->code == HTTP_OK ) {
        return $TRUE;
    }
    elsif ( $response->code == HTTP_CREATED ) {
        return $TRUE;
    }
    elsif ( $response->code > HTTP_CREATED ) {
        ## no critic qw(RequireExplicitInclusion)
        WookieConnectorException->throw(
            error => sprintf $ERR{HTTP},
            $response->header()->as_string, $response->content
        );
        ## use critic
    }
    return $FALSE;
}

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    if ( @_ == $MORE_ARGS ) {
        push @_, $EMPTY;
    }
    if ( @_ == $MOST_ARGS && !ref $_[0] ) {
        my ( $url, $api_key, $shareddata_key, $loginname, $screenname ) = @_;
        return $class->$orig(
            _user => WWW::Wookie::User->new( $loginname, $screenname ),
            _conn => WWW::Wookie::Server::Connection->new(
                $url, $api_key, $shareddata_key
            ),
        );
    }
    return $class->$orig(@_);
};

sub BUILD {
    my $self = shift;
    $self->_setWidgetInstancesHolder();
    return;
}

with 'WWW::Wookie::Connector::Service::Interface';

no Moose;

## no critic qw(RequireExplicitInclusion)
__PACKAGE__->meta->make_immutable;
## use critic

1;

__END__

=encoding utf8

=for stopwords Roland van Ipenburg Wookie Readonly API login URL

=head1 NAME

WWW::Wookie::Connector::Service - Wookie connector service, handles all the
data requests and responses.

=head1 VERSION

This document describes WWW::Wookie::Connector::Service version 0.0.1

=head1 SYNOPSIS

    use WWW::Wookie::Connector::Service;

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<new>

Create a new connector

=over

=item URL to Wookie host as string

=item Wookie API key as string

=item Shared data key to use as string

=item User login name

=item User display name

=back

=head2 C<addParticipant>

Implementation of the L<WWW::Wookie::Connector::Service::Interface
|WWW::Wookie::Connector::Service::Interface>.

=head2 C<deleteParticipant>

Implementation of the L<WWW::Wookie::Connector::Service::Interface
|WWW::Wookie::Connector::Service::Interface>.

=head2 C<getAvailableWidgets>

Implementation of the L<WWW::Wookie::Connector::Service::Interface
|WWW::Wookie::Connector::Service::Interface>.

=head2 C<getOrCreateInstance>

Implementation of the L<WWW::Wookie::Connector::Service::Interface
|WWW::Wookie::Connector::Service::Interface>.

=head2 C<getProperty>

Implementation of the L<WWW::Wookie::Connector::Service::Interface
|WWW::Wookie::Connector::Service::Interface>.

=head2 C<getUser>

Implementation of the L<WWW::Wookie::Connector::Service::Interface
|WWW::Wookie::Connector::Service::Interface>.

=head2 C<setUser>

Implementation of the L<WWW::Wookie::Connector::Service::Interface
|WWW::Wookie::Connector::Service::Interface>.

=head2 C<getUsers>

Implementation of the L<WWW::Wookie::Connector::Service::Interface
|WWW::Wookie::Connector::Service::Interface>.

=head2 C<setProperty>

Implementation of the L<WWW::Wookie::Connector::Service::Interface
|WWW::Wookie::Connector::Service::Interface>.

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

L<HTTP::Headers|HTTP::Headers>
L<HTTP::Request|HTTP::Request>
L<HTTP::Request::Common|HTTP::Request::Common>
L<HTTP::Status|HTTP::Status>
L<LWP::UserAgent|LWP::UserAgent>
L<Log::Log4perl|Log::Log4perl>
L<MooseX::AttributeHelpers|MooseX::AttributeHelpers>
L<Moose|Moose>
L<Moose|Moose>
L<Readonly|Readonly>
L<Regexp::Common|Regexp::Common>
L<WWW::Wookie::Connector::Exceptions|WWW::Wookie::Connector::Exceptions>
L<WWW::Wookie::Server::Connection|WWW::Wookie::Server::Connection>
L<WWW::Wookie::User|WWW::Wookie::User>
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance>
L<WWW::Wookie::Widget::Instances|WWW::Wookie::Widget::Instances>
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property>
L<WWW::Wookie::Widget|WWW::Wookie::Widget>
L<XML::Simple|XML::Simple>
L<namespace::autoclean|namespace::autoclean>

=head1 INCOMPATIBILITIES

=head1 DIAGNOSTICS

=head1 BUGS AND LIMITATIONS

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
