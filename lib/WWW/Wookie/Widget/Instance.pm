package WWW::Wookie::Widget::Instance;    # -*- cperl; cperl-indent-level: 4 -*-
use strict;
use warnings;

# $Id: Instance.pm 360 2010-11-22 13:03:01Z roland $
# $Revision: 360 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/lib/WWW/Wookie/Widget/Instance.pm $
# $Date: 2010-11-22 14:03:01 +0100 (Mon, 22 Nov 2010) $

use utf8;
use 5.006000;

our $VERSION = '0.03';

use Moose qw/around has/;

use Readonly;
## no critic qw(ProhibitCallsToUnexportedSubs)
Readonly::Scalar my $MORE_ARGS => 5;
## use critic

has '_url' => (
    is     => 'rw',
    isa    => 'Str',
    reader => 'getUrl',
    writer => 'setUrl',
);

has '_guid' => (
    is     => 'rw',
    isa    => 'Str',
    reader => 'getIdentifier',
    writer => 'setIdentifier',
);

has '_title' => (
    is     => 'rw',
    isa    => 'Str',
    reader => 'getTitle',
    writer => 'setTitle',
);

has '_height' => (
    is     => 'rw',
    isa    => 'Int',
    reader => 'getHeight',
    writer => 'setHeight',
);

has '_width' => (
    is     => 'rw',
    isa    => 'Int',
    reader => 'getWidth',
    writer => 'setWidth',
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    if ( @_ == $MORE_ARGS && !ref $_[0] ) {
        my ( $url, $guid, $title, $height, $width ) = @_;
        return $class->$orig(
            _url    => $url,
            _guid   => $guid,
            _title  => $title,
            _height => $height,
            _width  => $width,
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

=for stopwords Roland van Ipenburg Readonly url guid

=head1 NAME

WWW::Wookie::Widget::Instance - An instance of a widget for use on the client

=head1 VERSION

This document describes WWW::Wookie::Widget::Instance version 0.03

=head1 SYNOPSIS

    use WWW::Wookie::Widget::Instance;
    $i = WWW::Wookie::Widget::Instance->new(
        $url, $guid, $title, $height, $width);

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<new>

Initialize new widget instance.

=over

=item 1. Url of the widget as string

=item 2. Guid of the widget as string

=item 3. Title of the widget as string

=item 4. Height of the widget as string

=item 5. Width of the widget as string

=back

=head2 C<getUrl>

Get widget instance url. Returns widget instance url as string.

=head2 C<setUrl>

Set widget instance url.

=over

=item 1. New url for instance as string

=back

=head2 C<getIdentifier>

Get widget guid value. Returns guid of widget as string.

=head2 C<setIdentifier>

Set widget guid value.

=over

=item 1. Guid value as string

=back

=head2 C<getTitle>

Get widget title. Returns widget title as string.

=head2 C<setTitle>

Set widget title.

=over

=item 1. New widget title as string

=back

=head2 C<getHeight>

Get widget height. Returns widget height as integer.

=head2 C<setHeight>

Set widget height.

=over

=item 1. New widget height as integer

=back

=head2 C<getWidth>

Get widget width. Return widget width as integer.

=head2 C<setWidth>

Set widget width.

=over

=item 1. New widget width as integer

=back

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
