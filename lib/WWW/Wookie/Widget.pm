package WWW::Wookie::Widget;    # -*- cperl; cperl-indent-level: 4 -*-
use strict;
use warnings;

# $Id: Widget.pm 360 2010-11-22 13:03:01Z roland $
# $Revision: 360 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/lib/WWW/Wookie/Widget.pm $
# $Date: 2010-11-22 14:03:01 +0100 (Mon, 22 Nov 2010) $

use utf8;
use 5.006000;

our $VERSION = '0.03';

use Moose qw/around has/;

use Readonly;
## no critic qw(ProhibitCallsToUnexportedSubs)
Readonly::Scalar my $MORE_ARGS => 4;
## use critic

has '_identifier' => (
    is     => 'ro',
    isa    => 'Str',
    reader => 'getIdentifier',
);

has '_title' => (
    is     => 'ro',
    isa    => 'Str',
    reader => 'getTitle',
);

has '_description' => (
    is     => 'ro',
    isa    => 'Str',
    reader => 'getDescription',
);

has '_icon' => (
    is     => 'ro',
    isa    => 'Str',
    reader => 'getIcon',
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    if ( @_ == $MORE_ARGS && !ref $_[0] ) {
        my ( $identifier, $title, $description, $icon ) = @_;
        return $class->$orig(
            _identifier  => $identifier,
            _title       => $title,
            _description => $description,
            _icon        => $icon,
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

=for stopwords Roland van Ipenburg url guid Readonly

=head1 NAME

WWW::Wookie::Widget - A client side representation of a widget

=head1 VERSION

This document describes WWW::Wookie::Widget version 0.03

=head1 SYNOPSIS

    use WWW::Wookie::Widget;
    $w = WWW::Wookie::Widget->new($guid, $title, $description, $icon);
    $w->getIdentifier;
    $w->getTitle;
    $w->getDescription;
    $w->getIcon;

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<new>

Initialize a new widget.

=over

=item 1. Widget identifier/guid as string

=item 2. Widget title as string

=item 3. Widget description as string

=item 4. Widget icon url as string

=back

=head2 C<getIdentifier>

Get a unique identifier for this widget type. Returns a widget identifier
(guid) as string.

=head2 C<getTitle>

Get the human readable title of this widget. Returns the widget title as
string.

=head2 C<getIcon>

Get the location of a logo for this widget. Returns the widget icon url as
string.

=head2 C<getDescription>

Get the description of the widget. Returns the widget description as string.

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

L<Moose|Moose>
L<Readonly|Readonly>

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
