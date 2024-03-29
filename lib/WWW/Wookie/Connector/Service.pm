package WWW::Wookie::Connector::Service;  # -*- cperl; cperl-indent-level: 4 -*-
use strict;
use warnings;

# $Id: Service.pm 365 2010-11-25 01:15:48Z roland $
# $Revision: 365 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/lib/WWW/Wookie/Connector/Service.pm $
# $Date: 2010-11-25 02:15:48 +0100 (Thu, 25 Nov 2010) $

use utf8;
use 5.006000;

our $VERSION = '0.03';

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
use URI::Escape qw(uri_escape);
use XML::Simple;
use namespace::autoclean;

use WWW::Wookie::Connector::Exceptions;
use WWW::Wookie::Server::Connection;
use WWW::Wookie::User;
use WWW::Wookie::Widget;
use WWW::Wookie::Widget::Category;
use WWW::Wookie::Widget::Property;
use WWW::Wookie::Widget::Instance;
use WWW::Wookie::Widget::Instances;

use Readonly;
## no critic qw(ProhibitCallsToUnexportedSubs)
Readonly::Scalar my $DEFAULT_ICON =>
  q{http://www.oss-watch.ac.uk/images/logo2.gif};
Readonly::Scalar my $TIMEOUT  => 15;
Readonly::Scalar my $AGENT    => q{WWW::Wookie/} . $VERSION;
Readonly::Scalar my $TESTUSER => q{testuser};

Readonly::Scalar my $EMPTY => q{};
Readonly::Scalar my $QUERY => q{?};
Readonly::Scalar my $SLASH => q{/};
Readonly::Scalar my $TRUE  => 1;
Readonly::Scalar my $FALSE => 0;

Readonly::Scalar my $MORE_ARGS => 4;
Readonly::Scalar my $MOST_ARGS => 5;

Readonly::Scalar my $GET    => q{GET};
Readonly::Scalar my $POST   => q{POST};
Readonly::Scalar my $DELETE => q{DELETE};
Readonly::Scalar my $PUT    => q{PUT};

Readonly::Scalar my $ALL             => q{all};
Readonly::Scalar my $PARTICIPANTS    => q{participants};
Readonly::Scalar my $PROPERTIES      => q{properties};
Readonly::Scalar my $SERVICES        => q{services};
Readonly::Scalar my $WIDGETS         => q{widgets};
Readonly::Scalar my $WIDGETINSTANCES => q{widgetinstances};

Readonly::Scalar my $DEFAULT_SCHEME => q{http};
Readonly::Scalar my $VALID_SCHEMES  => $DEFAULT_SCHEME . q{s?};    # http(s)

Readonly::Hash my %LOG => (
    GET_USERS     => q{Getting users for instance of '%s'},
    USING_URL     => q{Using URL '%s'},
    RESPONSE_CODE => q{Got response code %s},
    DO_REQUEST    => q{Requesting %s '%s'},
    ALL_TRUE      => q{Requesting all widgets},
);

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
Log::Log4perl::easy_init($ERROR);
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

has '_locale' => (
    is     => 'rw',
    isa    => 'Str',
    reader => 'getLocale',
    writer => 'setLocale',
);

## no critic qw(Capitalization)
sub getAvailableServices {
## use critic
    my ( $self, $service_name ) = @_;
    my $url     = $self->_append_path($SERVICES);
    $self->_check_url( $url, $ERR{MALFORMED_URL} );
    my $content = {};
    if ($service_name) {
        $url .= $SLASH . URI::Escape::uri_escape($service_name);
    }
    if ( $self->getLocale ) {
        $content->{locale} = $self->getLocale;
    }

    my %services = ();
    my $response = $self->_do_request( $url, $content, $GET );
    my $xml_obj  = XML::Simple->new(
        ForceArray => 1,
        KeyAttr    => { widget => q{identifier}, service => q{name} }
    )->XMLin( $response->content );
    while ( my ( $name, $value ) = each %{ $xml_obj->{service} } ) {
        $self->getLogger->debug($name);
        my $service = WWW::Wookie::Widget::Category->new( name => $name );
        while ( my ( $id, $value ) = each %{ $value->{widget} } ) {
            $service->put(
                WWW::Wookie::Widget->new( $id, $self->_parse_widget($value) ) );
        }
        $services{$name} = $service;
    }
    return values %services;
}

## no critic qw(Capitalization)
sub getAvailableWidgets {
## use critic
    my ( $self, $service ) = @_;
    my %widgets = ();
    my $url     = $self->_append_path($WIDGETS);
    my $content = {};
    if ( !defined $service || $service eq $ALL ) {
        $self->getLogger->debug( $LOG{ALL_TRUE} );
        $content->{all} = q{true};
    }
    elsif ($service) {
        $url .= $SLASH . URI::Escape::uri_escape($service);
    }
    if ( $self->getLocale ) {
        $content->{locale} = $self->getLocale;
    }
    $self->_check_url( $url, $ERR{MALFORMED_URL} );

    my $response = $self->_do_request( $url, $content, $GET );
    my $xml_obj =
      XML::Simple->new( ForceArray => 1, KeyAttr => 'identifier' )
      ->XMLin( $response->content );
    while ( my ( $id, $value ) = each %{ $xml_obj->{widget} } ) {
        $widgets{$id} =
          WWW::Wookie::Widget->new( $id,
            $self->_parse_widget( $xml_obj->{widget}->{$id} ) );
    }
    return values %widgets;
}

has '_user' => (
    is     => 'ro',
    isa    => 'WWW::Wookie::User',
    reader => '_getUser',
    writer => '_setUser',
);

## no critic qw(Capitalization)
sub getUser {
## use critic
    my ( $self, $userid ) = @_;
    if ( defined $userid && $userid =~ /$TESTUSER(\d+)/gsmxi ) {
        return WWW::Wookie::User->new( $userid, qq{Test User $1} );
    }
    return $self->_getUser;
}

## no critic qw(Capitalization)
sub setUser {
## use critic
    my ( $self, $login, $screen ) = @_;
    $self->_setUser( WWW::Wookie::User->new( $login, $screen ) );
    return;
}

has 'WidgetInstances' => (
    is      => 'rw',
    isa     => 'WWW::Wookie::Widget::Instances',
    default => sub { WWW::Wookie::Widget::Instances->new() },
    writer  => '_setWidgetInstances',
);

## no critic qw(Capitalization)
sub getWidget {
## use critic
    my ( $self, $widget_id ) = @_;
    my @widgets =
      grep { $_->getIdentifier eq $widget_id } $self->getAvailableWidgets;
    return shift @widgets;

    # API method isn't implemented using proper id on the server.
    #my $url = $self->_append_path($WIDGETS);
    #if ( defined $widget_id ) {
    #    $url .= $SLASH . URI::Escape::uri_escape($widget_id);
    #}
    #$self->_check_url($url, $ERR{MALFORMED_URL});

    #my $response = $self->_do_request( $url, {}, $GET );
    #my $xs = XML::Simple->new( ForceArray => 1, KeyAttr => 'identifier' );
    #my $xml_obj = $xs->XMLin( $response->content );
    #return WWW::Wookie::Widget->new( $widget_id,
    #    $self->_parse_widget($xml_obj) );
}

## no critic qw(Capitalization)
sub getOrCreateInstance {
## use critic
    my ( $self, $widget_or_guid ) = @_;
    my $guid = $widget_or_guid;
    if ( ref $widget_or_guid eq q{WWW::Wookie::Widget} ) {
        $guid = $widget_or_guid->getIdentifier;
    }
    my $result = eval {
        if ( defined $guid && $guid eq $EMPTY )
        {
            ## no critic qw(RequireExplicitInclusion)
            WookieConnectorException->throw( error => $ERR{NO_WIDGET_GUID} );
            ## use critic
        }
        my $url = $self->_append_path($WIDGETINSTANCES);
        $self->_check_url( $url, $ERR{MALFORMED_URL} );
        my $content = { widgetid => $guid };
        if ( my $locale = $self->getLocale ) {
            $content->{locale} = $locale;
        }
        my $response = $self->_do_request( $url, $content );
        if ( $response->code == HTTP_CREATED ) {
            $response = $self->_do_request( $url, $content );
        }
        if ( $response->code == HTTP_UNAUTHORIZED ) {
            ## no critic qw(RequireExplicitInclusion)
            WookieConnectorException->throw( error => $ERR{INVALID_API_KEY} );
            ## use critic
        }
        my $instance = $self->_parse_instance( $guid, $response->content );
        if ($instance) {
            $self->WidgetInstances->put($instance);
            $self->addParticipant( $instance, $self->getUser );
        }
        return $instance;
    };

    if ( my $e = Exception::Class->caught('WookieConnectorException') ) {
        $self->getLogger->error( $e->error );
        $e->rethrow;
        return $FALSE;
    }
    return $result;
}

## no critic qw(Capitalization)
sub getUsers {
## use critic
    my ( $self, $instance ) = @_;
    if ( ref $instance ne q{WWW::Wookie::Widget::Instance} ) {
        $instance = $self->getOrCreateInstance($instance);
    }
    $self->getLogger->debug( sprintf $LOG{GET_USERS},
        $instance->getIdentifier );
    my $url = $self->_append_path($PARTICIPANTS);
    $self->getLogger->debug( sprintf $LOG{USING_URL}, $url );

    $self->_check_url( $url, $ERR{MALFORMED_URL} );
    my $response =
      $self->_do_request( $url, { widgetid => $instance->getIdentifier, }, $GET,
      );

    if ( $response->code > HTTP_OK ) {
        $self->_throw_http_err($response);
    }
    my $xml_obj =
      XML::Simple->new( ForceArray => 1, KeyAttr => 'identifier' )
      ->XMLin( $response->content );
    my @users = ();
    for my $participant ( @{ $xml_obj->{participant} } ) {
        my $id            = $participant->{id};
        my $name          = $participant->{displayName};
        my $thumbnail_url = $participant->{thumbnail_url};
        my $new_user      = WWW::Wookie::User->new(
            $id,
            defined $name || $id,
            defined $thumbnail_url || $EMPTY
        );
        push @users, $new_user;
    }
    return @users;
}

## no critic qw(Capitalization)
sub addProperty {
## use critic
    my ( $self, $widget, $property ) = @_;
    my $url = $self->_append_path($PROPERTIES);
    $self->_check_url( $url, $ERR{INCORRECT_PROPERTIES_REST_URL} );
    my $response = $self->_do_request(
        $url,
        {
            widgetid      => $widget->getIdentifier,
            propertyname  => $property->getName,
            propertyvalue => $property->getValue,
            is_public     => $property->getIsPublic,
        },
        $POST,
    );
    if ( $response->code == HTTP_OK || $response->code == HTTP_CREATED ) {
        return $TRUE;
    }
    elsif ( $response->code > HTTP_CREATED ) {
        return $response->content;
    }
    return $FALSE;
}

## no critic qw(Capitalization)
sub getProperty {
## use critic
    my ( $self, $widget_instance, $property_instance ) = @_;
    my $url = $self->_append_path($PROPERTIES);
    $self->_check_widget($widget_instance);
    $self->_check_property($property_instance);
    $self->_check_url( $url, $ERR{MALFORMED_URL} );
    my $response = $self->_do_request(
        $url,
        {
            'widgetid'     => $widget_instance->getIdentifier,
            'propertyname' => $property_instance->getName,
        },
        $GET
    );
    if ( !$response->is_success ) {
        $self->_throw_http_err($response);
        return $FALSE;
    }
    return WWW::Wookie::Widget::Property->new( $property_instance->getName,
        $response->content );

}

## no critic qw(Capitalization)
sub setProperty {
## use critic
    my ( $self, $widget, $property ) = @_;
    my $url    = $self->_append_path($PROPERTIES);
    my $result = eval {
        $self->_check_widget($widget);
        $self->_check_property($property);
        $self->_check_url( $url, $ERR{INCORRECT_PROPERTIES_REST_URL} );
        my $response = $self->_do_request(
            $url,
            {
                widgetid      => $widget->getIdentifier,
                propertyname  => $property->getName,
                propertyvalue => $property->getValue,
                is_public     => $property->getIsPublic,
            },

            # TODO: $PUT breaks, but should be used instead of $POST
            $POST,
        );
        if ( $response->code == HTTP_CREATED || $response == HTTP_OK ) {
            return $property;
        }
        else {
            $self->_throw_http_err($response);
        }
    };
    if ( my $e = Exception::Class->caught('WookieConnectorException') ) {
        $self->getLogger->error( $e->error );
        $e->rethrow;
        return $FALSE;
    }
    if ( my $e = Exception::Class->caught('WookieWidgetInstanceException') ) {
        $self->getLogger->error( $e->error );
        $e->rethrow;
        return $FALSE;
    }
    return $result;
}

## no critic qw(Capitalization)
sub deleteProperty {
## use critic
    my ( $self, $widget, $property ) = @_;
    my $url = $self->_append_path($PROPERTIES);
    $self->_check_url( $url, $ERR{INCORRECT_PROPERTIES_REST_URL} );
    $self->_check_widget($widget);
    $self->_check_property($property);
    my $response = $self->_do_request(
        $url,
        {
            widgetid     => $widget->getIdentifier,
            propertyname => $property->getName,
        },
        $DELETE,
    );
    if ( $response->code == HTTP_OK ) {
        return $TRUE;
    }
    return $FALSE;
}

## no critic qw(Capitalization)
sub addParticipant {
## use critic
    my ( $self, $widget_instance, $user ) = @_;
    $self->_check_widget($widget_instance);
    my $url = $self->_append_path($PARTICIPANTS);
    $self->_check_url( $url, $ERR{INCORRECT_PARTICIPANTS_REST_URL} );
    my $response = $self->_do_request(
        $url,
        {
            widgetid                  => $widget_instance->getIdentifier,
            participant_id            => $self->getUser->getLoginName,
            participant_display_name  => $user->getScreenName,
            participant_thumbnail_url => $user->getThumbnailUrl,
        },
    );
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

## no critic qw(Capitalization)
sub deleteParticipant {
## use critic
    my ( $self, $widget, $user ) = @_;
    $self->_check_widget($widget);
    my $url = $self->_append_path($PARTICIPANTS);
    $self->_check_url( $url, $ERR{INCORRECT_PARTICIPANTS_REST_URL} );
    my $response = $self->_do_request(
        $url,
        {
            widgetid                  => $widget->getIdentifier,
            participant_id            => $self->getUser->getLoginName,
            participant_display_name  => $user->getScreenName,
            participant_thumbnail_url => $user->getThumbnailUrl,
        },
        $DELETE,
    );
    if ( $response->code == HTTP_OK ) {
        return $TRUE;
    }
    elsif ( $response->code == HTTP_CREATED ) {
        return $TRUE;
    }
    elsif ( $response->code > HTTP_CREATED ) {
        $self->_throw_http_err($response);
    }
    return $FALSE;
}

## no critic qw(Capitalization)
sub _setWidgetInstancesHolder {
## use critic
    my $self = shift;
    $self->_setWidgetInstances( WWW::Wookie::Widget::Instances->new );
    return;
}

has '_ua' => (
    is      => 'rw',
    isa     => 'LWP::UserAgent',
    default => sub {
        LWP::UserAgent->new(
            timeout => $TIMEOUT,
            agent   => $AGENT,
        );
    },
);

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
    $self->_setWidgetInstancesHolder;
    return;
}

sub _append_path {
    my ( $self, $path ) = @_;
    return $self->getConnection->getURL . URI::Escape::uri_escape($path);
}

sub _check_url {
    my ( $self, $url, $message ) = @_;
    if ( $url !~ m{^$RE{URI}{HTTP}{-keep}{ -scheme => $VALID_SCHEMES }$}smx ) {
        ## no critic qw(RequireExplicitInclusion)
        WookieConnectorException->throw( error => sprintf $message, $url );
        ## use critic
    }
    return;
}

sub _check_widget {
    my ( $self, $ref ) = @_;
    if ( ref $ref ne q{WWW::Wookie::Widget::Instance} ) {
        ## no critic qw(RequireExplicitInclusion)
        WookieWidgetInstanceException->throw(
            ## use critic
            error => $ERR{NO_WIDGET_INSTANCE}
        );
    }
    return;
}

sub _check_property {
    my ( $self, $ref ) = @_;
    if ( ref $ref ne q{WWW::Wookie::Widget::Property} ) {
        ## no critic qw(RequireExplicitInclusion)
        WookieConnectorException->throw(
            ## use critic
            error => $ERR{NO_PROPERTIES_INSTANCE}
        );
    }
    return;
}

sub _throw_http_err {
    my ( $self, $response ) = @_;
    ## no critic qw(RequireExplicitInclusion)
    WookieConnectorException->throw(
        ## use critic
        error => sprintf $ERR{HTTP},
        $response->headers->as_string, $response->content
    );
    return;
}

sub _do_request {
    my ( $self, $url, $data, $method ) = @_;

    # Widgets and Services request doesn't require API key stuff:
    if ( $url !~ m{/(widgets|services)([?/]|$)}gismx ) {
        $data = {
            api_key       => $self->getConnection->getApiKey,
            shareddatakey => $self->getConnection->getSharedDataKey,
            userid        => $self->getUser->getLoginName,
            %{$data},
        };
    }
    if ( !defined $method ) {
        $method = $POST;
    }

    if ( ( my $content = [ POST $url, [ %{$data} ] ]->[0]->content ) ne $EMPTY )
    {
        $url .= $QUERY . $content;
    }
    $self->getLogger->debug( sprintf $LOG{DO_REQUEST}, $method, $url );
    my $request = HTTP::Request->new(
        $method => $url,
        HTTP::Headers->new(),
    );
    my $response = $self->_ua->request($request);
    $self->getLogger->debug( sprintf $LOG{RESPONSE_CODE}, $response->code );
    return $response;
}

sub _parse_instance {
    my ( $self, $guid, $xml ) = @_;
    my $xml_obj =
      XML::Simple->new( ForceArray => 1, KeyAttr => 'identifier' )->XMLin($xml);
    if (
        my $instance = WWW::Wookie::Widget::Instance->new(
            $xml_obj->{url}[0],   $guid,
            $xml_obj->{title}[0], $xml_obj->{height}[0],
            $xml_obj->{width}[0]
        )
      )
    {
        $self->WidgetInstances->put($instance);
        $self->addParticipant( $instance, $self->getUser );
        return $instance;
    }
    return;
}

sub _parse_widget {
    my ( $self, $xml ) = @_;
    my $title = $xml->{title}[0]->{content};
    my $description =
      ref $xml->{description}[0]
      ? $xml->{description}[0]->{content}
      : $xml->{description}[0];
    my $icon =
      ref $xml->{icon}[0]
      ? $xml->{icon}[0]->{content}
      : $xml->{icon}[0];
    if ( !$icon ) {
        $icon = $DEFAULT_ICON;
    }
    return ( $title, $description, $icon );
}

with 'WWW::Wookie::Connector::Service::Interface';

no Moose;

## no critic qw(RequireExplicitInclusion)
__PACKAGE__->meta->make_immutable;
## use critic

1;

__END__

=encoding utf8

=for stopwords Roland van Ipenburg Wookie Readonly API login URL guid

=head1 NAME

WWW::Wookie::Connector::Service - Wookie connector service, handles all the
data requests and responses

=head1 VERSION

This document describes WWW::Wookie::Connector::Service version 0.03

=head1 SYNOPSIS

    use WWW::Wookie::Connector::Service;

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

This module is an implementation of the
L<WWW::Wookie::Connector::Service::Interface
|WWW::Wookie::Connector::Service::Interface/"SUBROUTINES/METHODS">.

=head2 C<new>

Create a new connector

=over

=item 1. URL to Wookie host as string

=item 2. Wookie API key as string

=item 3. Shared data key to use as string

=item 4. User login name

=item 5. User display name

=back

=head2 C<getAvailableServices>

Get a all available service categories in the server. Returns an array of
L<WWWW::Wookie::Widget::Category|WW::Wookie::Widget::Category> objects.
Throws a C<WookieConnectorException>.

=head2 C<getAvailableWidgets>

Get all available widgets in the server, or only the available widgets in the
specified service category. Returns an array of
L<WWW::Wookie::Widget|WWW::Wookie::Widget> objects, otherwise false. Throws a
C<WookieConnectorException>.

=over

=item 1. Service category name as string

=back

=head2 C<getWidget>

Get the details of the widget specified by it's identifier. Returns a
L<WWW::Wookie::Widget|WWW::Wookie::Widget> object.

=over

=item 1. The identifier of an available widget

=back

=head2 C<getConnection>

Get the currently active connection to the Wookie server. Returns a
L<WWW::Wookie::Server::Connection|WWW::Wookie::Server::Connection> object.

=head2 C<setUser>

Set the current user.

=over

=item 1. User name for the current Wookie connection 

=item 2. Screen name for the current Wookie connection

=back

=head2 C<getUser>

Retrieve the details of the current user. Returns an instance of the user as a
L<WWW::Wookie::User|WWW::Wookie::User> object.

=head2 C<getOrCreateInstance>

Get or create a new instance of a widget. The current user will be added as a
participant. Returns a
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object if
successful, otherwise false. Throws a C<WookieConnectorException>. 

=over

=item 1. Widget as guid string or a L<WWW::Wookie::Widget|WWW::Wookie::Widget>
object

=back

=head2 C<addParticipant>

Add a participant to a widget. Returns true if successful, otherwise false.
Throws a C<WookieWidgetInstanceException> or a C<WookieConnectorException>.

=over

=item 1. Instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item 2. Instance of user as L<WWW::Wookie::User|WWW::Wookie::User> object

=back

=head2 C<deleteParticipant>

Delete a participant. Returns true if successful, otherwise false. Throws a
C<WookieWidgetInstanceException> or a C<WookieConnectorException>.

=over

=item 1. Instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item 2. Instance of user as L<WWW::Wookie::User|WWW::Wookie::User> object

=back

=head2 C<getUsers>

Get all participants of the current widget. Returns an array of
L<WWW::Wookie::User|WWW::Wookie::User> instances. Throws a
C<WookieConnectorException>.

=over

=item 1. Instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=back

=head2 C<addProperty>

Adds a new property. Returns true if successful, otherwise false. Throws a
C<WookieConnectorException>.

=over

=item 1. Instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item 2. Instance of property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> object

=back

=head2 C<setProperty>

Set a new property. Returns the property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> if successful,
otherwise false. Throws a C<WookieWidgetInstanceException> or a
C<WookieConnectorException>.

=over

=item 1. Instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item 2. Instance of property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> object

=back

=head2 C<getProperty>

Get a property. Returns the property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> if successful,
otherwise false. Throws a C<WookieWidgetInstanceException> or a
C<WookieConnectorException>.

=over

=item 1. Instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item 2. Instance of property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> object

=back

=head2 C<deleteProperty>

Delete a property. Returns true if successful, otherwise false. Throws a
C<WookieWidgetInstanceException> or a C<WookieConnectorException>.

=over

=item 1. Instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item 2. Instance of property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> object

=back

=head2 C<setLocale>

Set a locale.

=over

=item 1. Locale as string

=back

=head2 C<getLocale>

Get the current locale setting. Returns current locale as string.

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

L<HTTP::Headers|HTTP::Headers>
L<HTTP::Request|HTTP::Request>
L<HTTP::Request::Common|HTTP::Request::Common>
L<HTTP::Status|HTTP::Status>
L<LWP::UserAgent|LWP::UserAgent>
L<Log::Log4perl|Log::Log4perl>
L<Moose|Moose>
L<Moose::Util::TypeConstraints|Moose::Util::TypeConstraints>
L<MooseX::AttributeHelpers|MooseX::AttributeHelpers>
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
