# -*- cperl; cperl-indent-level: 4 -*-
package WWW::Wookie::Connector::Service::Interface;
use strict;
use warnings;

## no critic qw(ProhibitLongLines)
# $Id: Interface.pm 347 2010-11-05 15:06:12Z roland $
# $Revision: 347 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/lib/WWW/Wookie/Connector/Service/Interface.pm $
# $Date: 2010-11-05 16:06:12 +0100 (Fri, 05 Nov 2010) $
## use critic

use utf8;
use 5.006000;

our $VERSION = '0.01';

use Moose::Role qw/requires/;
requires 'getAvailableWidgets';
requires 'getConnection';
requires 'setUser';
requires 'getUser';
requires 'getOrCreateInstance';
requires 'addParticipant';
requires 'deleteParticipant';
requires 'getUsers';
requires 'setProperty';
requires 'getProperty';
requires 'deleteProperty';
requires 'setLocale';
requires 'getLocale';

1;

__END__

=encoding utf8

=for stopwords Roland van Ipenburg Wookie guid

=head1 NAME

WWW::Wookie::Connector::Service::Interface - Interface for
L<Wookie::Connector::Service|Wookie::Connector::Service>.

=head1 VERSION

This document describes WWW::Wookie::Connector::Service::Interface version
0.0.1

=head1 SYNOPSIS

    with 'WWW::Wookie::Connector::Service::Interface';

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<getAvailableWidgets>

Get all available widgets. Returns an array of
L<WWW::Wookie::Widget|WWW::Wookie::Widget> objects, otherwise false.

=head2 C<getConnection>

Get the current connection. Returns an
L<WWW::Wookie::Server::Connection|WWW::Wookie::Server::Connection> object.

=head2 C<setUser>

Set new user.

=over

=item User name for Wookie connection

=item Screen name for Wookie connection

=back

=head2 C<getUser>

Get current user. Returns instance of user as a
L<WWW::Wookie::User|WWW::Wookie::User> object.

=head2 C<getOrCreateInstance>

Get or create a new widget instance. Returns a
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object if
successful, otherwise false.

=over

=item widget as guid string or L<WWW::Wookie::Widget|WWW::Wookie::Widget>
object

=back

=head2 C<addParticipant>

Add a new participant. Returns true if successful, otherwise false.

=over

=item instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item instance of user as L<WWW::Wookie::User|WWW::Wookie::User> object

=back

=head2 C<deleteParticipant>

Delete participant. Return true if successful, otherwise false.

=over

=item instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item instance of user as L<WWW::Wookie::User|WWW::Wookie::User> object

=back

=head2 C<getUsers>

Get all participants of current widget. Returns an array of
L<WWW::Wookie::User|WWW::Wookie::User> instances.

=over

=item instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=back

=head2 C<setProperty>

Set a new property. Returns the property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> if successful,
otherwise false.

=over

=item instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item instance of property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> object

=back

=head2 C<getProperty>

Get property. Returns the property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> if successful,
otherwise false.

=over

=item instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item instance of property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> object

=back

=head2 C<deleteProperty>

Delete property. Returns true if successful, otherwise false.

=over

=item instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item instance of property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> object

=back

=head2 C<setLocale>

Set locale.

=over

=item locale as string

=back

=head2 C<getLocale>

Get current locale setting. Returns current locale as string.

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

L<Moose::Role|Moose::Role>

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
