# -*- cperl; cperl-indent-level: 4 -*-
package WWW::Wookie::Connector::Service::Interface;
use strict;
use warnings;

## no critic qw(ProhibitLongLines)
# $Id: Interface.pm 357 2010-11-07 10:53:18Z roland $
# $Revision: 357 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/lib/WWW/Wookie/Connector/Service/Interface.pm $
# $Date: 2010-11-07 11:53:18 +0100 (Sun, 07 Nov 2010) $
## use critic

use utf8;
use 5.006000;

our $VERSION = '0.02';

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

=for stopwords Roland van Ipenburg Wookie guid PHP

=head1 NAME

WWW::Wookie::Connector::Service::Interface - Interface for
L<Wookie::Connector::Service|Wookie::Connector::Service>

=head1 VERSION

This document describes WWW::Wookie::Connector::Service::Interface version
0.0.2

=head1 SYNOPSIS

    use Moose;
    with 'WWW::Wookie::Connector::Service::Interface';

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<getAvailableWidgets>

Get all available widgets. Returns an array of
L<WWW::Wookie::Widget|WWW::Wookie::Widget> objects, otherwise false.

=head2 C<getConnection>

Get the current connection. Returns a
L<WWW::Wookie::Server::Connection|WWW::Wookie::Server::Connection> object.

=head2 C<setUser>

Set the new user.

=over

=item 1. User name for the Wookie connection 

=item 2. Screen name for the Wookie connection

=back

=head2 C<getUser>

Get the current user. Returns an instance of the user as a
L<WWW::Wookie::User|WWW::Wookie::User> object.

=head2 C<getOrCreateInstance>

Get or create a new widget instance. Returns a
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object if
successful, otherwise false.

=over

=item 1. Widget as guid string or a L<WWW::Wookie::Widget|WWW::Wookie::Widget>
object

=back

=head2 C<addParticipant>

Add a new participant. Returns true if successful, otherwise false.

=over

=item 1. Instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item 2. Instance of user as L<WWW::Wookie::User|WWW::Wookie::User> object

=back

=head2 C<deleteParticipant>

Delete a participant. Returns true if successful, otherwise false.

=over

=item 1. Instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item 2. Instance of user as L<WWW::Wookie::User|WWW::Wookie::User> object

=back

=head2 C<getUsers>

Get all participants of the current widget. Returns an array of
L<WWW::Wookie::User|WWW::Wookie::User> instances.

=over

=item 1. Instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=back

=head2 C<setProperty>

Set a new property. Returns the property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> if successful,
otherwise false.

=over

=item 1. Instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item 2. Instance of property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> object

=back

=head2 C<getProperty>

Get a property. Returns the property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> if successful,
otherwise false.

=over

=item 1. Instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=item 2. Instance of property as
L<WWW::Wookie::Widget::Property|WWW::Wookie::Widget::Property> object

=back

=head2 C<deleteProperty>

Delete a property. Returns true if successful, otherwise false.

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

L<Moose::Role|Moose::Role>

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
