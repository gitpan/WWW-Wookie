package WWW::Wookie::User;    # -*- cperl; cperl-indent-level: 4 -*-
use strict;
use warnings;

# $Id: User.pm 350 2010-11-05 22:04:49Z roland $
# $Revision: 350 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/lib/WWW/Wookie/User.pm $
# $Date: 2010-11-05 23:04:49 +0100 (Fri, 05 Nov 2010) $

use utf8;
use 5.006000;

our $VERSION = '0.01';

use Moose qw/around has/;
use Moose::Util::TypeConstraints qw/as coerce from where subtype via/;

use Readonly;
## no critic qw(ProhibitCallsToUnexportedSubs)
Readonly::Scalar my $EMPTY     => q{};
Readonly::Scalar my $UNKNOWN   => q{UNKNOWN};
Readonly::Scalar my $MORE_ARGS => 3;
## use critic

subtype 'Trimmed' => as 'Str' => where { m{(^\S|\S*$)}gsmx };

coerce 'Trimmed' => from 'Str' => via { $_ =~ s{^\s+(.*)\s+$}{$1}gsmx; $_ };

has 'loginName' => (
    is      => 'rw',
    isa     => 'Trimmed',
    coerce  => 1,
    default => $UNKNOWN,
    reader  => 'getLoginName',
    writer  => 'setLoginName',
);

has 'screenName' => (
    is      => 'rw',
    isa     => 'Trimmed',
    coerce  => 1,
    default => $UNKNOWN,
    reader  => 'getScreenName',
    writer  => 'setScreenName',
);

has 'thumbnailUrl' => (
    is      => 'ro',
    isa     => 'Str',
    default => $EMPTY,
    reader  => 'getThumbnailUrl',
    writer  => 'setThumbnailUrl',
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    if ( @_ == 2 && !ref $_[0] ) {
        push @_, $EMPTY;
    }
    if ( @_ == $MORE_ARGS && !ref $_[0] ) {
        return $class->$orig(
            loginName    => $_[0],
            screenName   => $_[1],
            thumbnailUrl => $_[2],
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

=for stopwords Roland van Ipenburg plugins login url Readonly

=head1 NAME

WWW::Wookie::User - represent a possible user of a widget.

=head1 VERSION

This document describes WWW::Wookie::User version 0.0.1

=head1 SYNOPSIS

    use WWW::Wookie::User;
	$u = WWW::Wookie::User->new($login, $nick);

=head1 DESCRIPTION

A user represents a possible user of a widget. This class provides a standard
way of representing users in plugins for host environments.

=head1 SUBROUTINES/METHODS

=head2 C<new>

Create a new user.

=over

=item user login name as string
=item user display name as string
=item optional thumbnail URL as string

=back

=head2 C<getLoginName>

Get the login name for this user. Returns the user login name as string.

=head2 C<getScreenName>

Get the screen name for this user. This is the name that is intended to be
displayed on screen. In many cases it will be the same as the login name.
Returns the user display name as a string.

=head2 C<setLoginName>

Set the login name for this user. this is the value that is used by the user
to register on the system, it is guaranteed to be unique.

=over

=item new login name as string

=back

=head2 C<setScreenName>

Set the screen name for this user. This is the value that should be displayed
on screen. In many cases it will be the same as the login name.

=over

=item new screen name as string

=back

=head2 C<getThumbnailUrl>

Get the URL for a thumbnail representing this user. Returns the user thumbnail
icon url as string.

=head2 C<setThumbnailUrl>

Set the URL for a thumbnail representing this user.

=over

=item new thumbnail URL as string

=back

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

L<Moose|Moose>
L<Moose::Util::TypeConstraints|Moose::Util::TypeConstraints>
L<Readonly|Readonly>

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
