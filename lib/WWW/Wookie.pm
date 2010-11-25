package WWW::Wookie;    # -*- cperl; cperl-indent-level: 4 -*-
use strict;
use warnings;

## no critic qw(ProhibitLongLines)
# $Id: Wookie.pm 365 2010-11-25 01:15:48Z roland $
# $Revision: 365 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/lib/WWW/Wookie.pm $
# $Date: 2010-11-25 02:15:48 +0100 (Thu, 25 Nov 2010) $
## use critic

use utf8;
use 5.006000;

our $VERSION = '0.03';

1;

__END__

=encoding utf8

=for stopwords Roland van Ipenburg Wookie Readonly PHP URI

=head1 NAME

WWW::Wookie - Apache Wookie Connector Framework implementation

=head1 VERSION

This document describes WWW::Wookie version 0.03

=head1 SYNOPSIS

    use WWW::Wookie::Connector::Service;

    $w = WWW::Wookie::Connector::Service->new(
        $SERVER, $API_KEY, $SHARED_DATA_KEY, $USER
    );
    @available_widgets = $w->getAvailableWidgets;

=head1 DESCRIPTION

This is a Perl implementation of the Wookie Connector Framework. For more
information see:
L<http://incubator.apache.org/wookie/embedding-wookie-widgets-in-other-applications.html|http://incubator.apache.org/wookie/embedding-wookie-widgets-in-other-applications.html>

=head1 SUBROUTINES/METHODS

=head1 CONFIGURATION AND ENVIRONMENT

The Wookie Connector Framework is supposed to connect to a Wookie server, see
L<http://incubator.apache.org/wookie|http://incubator.apache.org/wookie>.

=head1 DEPENDENCIES

L<Exception::Class|Exception::Class>
L<HTTP::Headers|HTTP::Headers>
L<HTTP::Request|HTTP::Request>
L<HTTP::Request::Common|HTTP::Request::Common>
L<HTTP::Status|HTTP::Status>
L<LWP::UserAgent|LWP::UserAgent>
L<Log::Log4perl|Log::Log4perl>
L<Moose|Moose>
L<Moose::Role|Moose::Role>
L<Moose::Util::TypeConstraints|Moose::Util::TypeConstraints>
L<MooseX::AttributeHelpers|MooseX::AttributeHelpers>
L<Readonly|Readonly>
L<Regexp::Common|Regexp::Common>
L<URI|URI>
L<URI::Escape|URI::Escape>
L<XML::Simple|XML::Simple>
L<namespace::autoclean|namespace::autoclean>
L<Test::More|Test::More>
L<Test::NoWarnings|Test::NoWarnings>

=head1 INCOMPATIBILITIES

This is a port based on the PHP version of the Wookie Connector Framework, not
a port of the reference Java version of the Wookie Connector Framework.

=head1 DIAGNOSTICS

This module uses L<Log::Log4perl|Log::Log4perl> for logging.

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
