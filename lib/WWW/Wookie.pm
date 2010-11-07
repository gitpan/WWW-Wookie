package WWW::Wookie;    # -*- cperl; cperl-indent-level: 4 -*-
use strict;
use warnings;

## no critic qw(ProhibitLongLines)
# $Id: Wookie.pm 354 2010-11-06 16:24:17Z roland $
# $Revision: 354 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/lib/WWW/Wookie.pm $
# $Date: 2010-11-06 17:24:17 +0100 (Sat, 06 Nov 2010) $
## use critic

use utf8;
use 5.006000;

our $VERSION = '0.02';

1;

__END__

=encoding utf8

=for stopwords Roland van Ipenburg Wookie Readonly PHP

=head1 NAME

WWW::Wookie - Apache Wookie Connector Framework implementation

=head1 VERSION

This document describes WWW::Wookie version 0.0.2

=head1 SYNOPSIS

    use WWW::Wookie;

    $w = WWW::Wookie::Connector::Service->new(
        $SERVER, $API_KEY, $SHARED_DATA_KEY, $USER
    );
    %available_widgets = $w->getAvailableWidgets();

=head1 DESCRIPTION

This is a Perl implementation of the Wookie Connector Framework. For more
information see:
L<http://incubator.apache.org/wookie/embedding-wookie-widgets-in-other-applications.html|
http://incubator.apache.org/wookie/embedding-wookie-widgets-in-other-applications.html>

=head1 SUBROUTINES/METHODS

=head1 CONFIGURATION AND ENVIRONMENT

The Wookie Connector Framework is supposed to connect to a Wookie server, see
L<http://incubator.apache.org/wookie|http://incubator.apache.org/wookie>.

=head1 DEPENDENCIES

L<HTTP::Request::Common|HTTP::Request::Common>
L<HTTP::Response|HTTP::Response>
L<HTTP::Status|HTTP::Status>
L<LWP::UserAgent|LWP::UserAgent>
L<Log::Log4perl|Log::Log4perl>
L<MooseX::AttributeHelpers|MooseX::AttributeHelpers>
L<Moose|Moose>
L<Readonly|Readonly>
L<Regexp::Common|Regexp::Common>
L<Test::More|Test::More>
L<Test::More|Test::More>
L<Test::NoWarnings|Test::NoWarnings>
L<XML::Simple|XML::Simple>
L<namespace::autoclean|namespace::autoclean>

=head1 INCOMPATIBILITIES

This is a port based on the PHP version of the Wookie Connector Framework, not
a port of the reference Java version of the Wookie Connector Framework. 

=head1 DIAGNOSTICS

This module uses L<Log::Log4perl|Log::Log4perl> for logging.

=head1 BUGS AND LIMITATIONS

Testing is only done manually and interactively using the
L<scripts/TestWookieService.pl|
http://search.cpan.org/~ipenburg/WWW-Wookie-0.02/scripts/TestWookieService.pl>
script that has to connect to a live Wookie server. Issues can be caused by
this Connector Framework, the test script, the Wookie server or the widgets
served by the Wookie server, which could all be considered works in progress.

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
