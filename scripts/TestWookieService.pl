#!/usr/bin/perl -w    # -*- cperl; cperl-indent-level: 4 -*-
use strict;
use warnings;

# $Id: TestWookieService.pl 347 2010-11-05 15:06:12Z roland $
# $Revision: 347 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/scripts/TestWookieService.pl $
# $Date: 2010-11-05 16:06:12 +0100 (Fri, 05 Nov 2010) $

use utf8;
use 5.006000;

our $VERSION = '0.01';

use CGI qw/:all/;
use Data::Dumper qw/Dumper/;
use HTTP::Server::Brick;

use lib q{../lib};
use Getopt::Long;
use Pod::Usage;
use WWW::Wookie::Connector::Service;
use WWW::Wookie::User;
use WWW::Wookie::Widget::Property;

use Readonly;
## no critic qw(ProhibitCallsToUnexportedSubs)
Readonly::Scalar my $CONNECTOR_PORT  => 8081;
Readonly::Scalar my $WOOKIE_SERVER   => q{http://localhost:8080/wookie/};
Readonly::Scalar my $API_KEY         => q{TEST};
Readonly::Scalar my $SHARED_DATA_KEY => q{localhost_dev};
Readonly::Scalar my $USER            => q{demo_1};
Readonly::Scalar my $DEMO_PROP       => q{demo_property};
Readonly::Scalar my $DEMO_VAL        => q{demo_value};
Readonly::Scalar my $LOCALE          => q{en};

Readonly::Scalar my $STRIP_QUERY => qr{^/\?}sxm;

Readonly::Scalar my $EMPTY           => q{};
Readonly::Scalar my $ROOT            => q{/};
Readonly::Scalar my $GET             => q{GET};
Readonly::Scalar my $ERROR           => q{error};
Readonly::Scalar my $SELECT          => q{Select};
Readonly::Scalar my $WOOKIE_TITLE    => q{Wookie Connector Framework Test};
Readonly::Scalar my $NO_WIDGET       => q{No widget selected};
Readonly::Scalar my $USERS_AFTER_DEL => q{Users after delete};
Readonly::Scalar my $PROPS_AFTER_DEL => q{Properties after delete};

Readonly::Array my @GETOPT_CONFIG =>
  qw(no_ignore_case bundling auto_version auto_help);
Readonly::Array my @GETOPTIONS =>
  ( q{server|s=s}, q{port|p=s}, q{help|h}, q{verbose|v+}, );
Readonly::Hash my %OPTS_DEFAULT => (
    server => $WOOKIE_SERVER,
    port   => $CONNECTOR_PORT,
);

Readonly::Array my @IDS => (
    { id => q{widget_id},  login => q{demo_2} },
    { id => q{widget_id2}, login => q{demo_425} },
);
## use critic

Getopt::Long::Configure(@GETOPT_CONFIG);
my %opts = %OPTS_DEFAULT;
Getopt::Long::GetOptions( \%opts, @GETOPTIONS ) or Pod::Usage::pod2usage(2);

my $server = HTTP::Server::Brick->new( port => $opts{port} );

$server->mount(
    $ROOT => {
        handler  => \&main,
        wildcard => 1,
    }
);

sub main {
    my ( $req, $res ) = @_;
    my $uri = $req->uri;
    $uri =~ s{$STRIP_QUERY}{}smx;
    my $q = CGI->new($uri);
    my $test =
      WWW::Wookie::Connector::Service->new( $opts{server}, $API_KEY,
        $SHARED_DATA_KEY, $USER );
    $test->setLocale($LOCALE);
    $test->getUser()->setLoginName($USER);
    my %available_widgets = $test->getAvailableWidgets();

    $res->add_content( $q->start_html($WOOKIE_TITLE) );

    if ( !$test->getConnection()->test() ) {
        $res->add_content( $ERROR . $q->br );
    }

    $res->add_content( $q->start_pre
          . $q->start_form( { method => $GET, action => $EMPTY } ) );

    for my $id (@IDS) {
        my %labels = ( $EMPTY => $NO_WIDGET );
        foreach my $widget ( values %available_widgets ) {
            $labels{ $widget->getIdentifier() } = $widget->getTitle();
        }
        $res->add_content(
            $q->popup_menu(
                {
                    name    => $id->{id},
                    values  => [ keys %labels ],
                    labels  => \%labels,
                    default => [ $q->param( $id->{id} ) ],
                }
            )
        );
    }

    $res->add_content( $q->submit( { value => $SELECT } ) . $q->end_form );

    for my $id (@IDS) {
        if ( defined $q->param( $id->{id} )
            && $q->param( $id->{id} ) ne $EMPTY )
        {
            $test->getUser()->setLoginName( $id->{login} );
            my $widget = $test->getOrCreateInstance( $q->param( $id->{id} ) );
            if ($widget) {
                $res->add_content(
                    $q->start_iframe(
                        {
                            src    => $widget->getUrl(),
                            width  => $widget->getWidth(),
                            height => $widget->getHeight(),
                        }
                      )
                      . $q->end_iframe
                      . $q->br
                );
                $test->addParticipant( $widget,
                    WWW::Wookie::User->new( $id->{login}, $id->{login} ) );
                $res->add_content(
                    $q->escapeHTML(
                        Data::Dumper::Dumper $test->getUsers($widget)
                    )
                );

                ( $id != $IDS[0] ) && next;
                $test->deleteParticipant( $widget,
                    WWW::Wookie::User->new( $id->{login}, $id->{login} ) );
                $res->add_content(
                        $USERS_AFTER_DEL
                      . $q->br
                      . $q->escapeHTML(
                        Data::Dumper::Dumper $test->getUsers($widget)
                      )
                      . $q->escapeHTML(
                        Data::Dumper::Dumper $test->setProperty(
                            $widget,
                            WWW::Wookie::Widget::Property->new(
                                $DEMO_PROP, $DEMO_VAL
                            )
                        )
                      )
                      . $PROPS_AFTER_DEL
                      . $q->br
                      . (
                        $q->escapeHTML(
                            Data::Dumper::Dumper $test->deleteProperty(
                                $widget,
                                WWW::Wookie::Widget::Property->new($DEMO_PROP)
                            )
                          )
                          || $EMPTY
                      )
                      . $q->br
                );
            }
        }
    }

    $res->add_content(
        $q->escapeHTML( Data::Dumper::Dumper( $test->WidgetInstances->get() ) )
          . $q->end_pre
          . $q->end_html );

    $res->header( 'Content-Type', 'application/xhtml+xml' );
    return 1;
}

$server->start;

__END__

=encoding utf8

=for stopwords Roland van Ipenburg Wookie TestWookieService.pl

=head1 NAME

TestWookieService.pl - HTTP server for testing the Apache Wookie Connector
Framework Perl implementation

=head1 VERSION

This document describes C<TestWookieService.pl> version 0.0.1

=head1 USAGE

    ./TestWookieService.pl --server=http://localhost:8080/wookie/ --port=8081

=head1 REQUIRED ARGUMENTS

None.

=head1 OPTIONS

=over 4

=item B<--server> URL of the Wookie server, default
L<http://localhost:8080/wookie/|http://localhost:8080/wookie/>

=item B<--port> Port number on which this HTTP server will be listening on
C<localhost>, default port 8081 

=back

=head1 DIAGNOSTICS

=head1 EXIT STATUS

=head1 CONFIGURATION

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 DESCRIPTION

This starts an HTTP service which presents an HTML page that interacts with a
Apache Wookie Server using a Perl implementation of the Apache Wookie
Connector Framework.  For more information see:
L<http://incubator.apache.org/wookie/
embedding-wookie-widgets-in-other-applications.html
|http://incubator.apache.org/wookie/
embedding-wookie-widgets-in-other-applications.html>

=head1 CONFIGURATION AND ENVIRONMENT

Using the defaults it starts the HTTP service on port 8081 and tries to
connect to an Apache Wookie service on C<localhost> port 8080.

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
