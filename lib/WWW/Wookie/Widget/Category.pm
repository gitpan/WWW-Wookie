package WWW::Wookie::Widget::Category;    # -*- cperl; cperl-indent-level: 4 -*-
use strict;
use warnings;

# $Id: Category.pm 363 2010-11-24 14:52:58Z roland $
# $Revision: 363 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/lib/WWW/Wookie/Widget/Category.pm $
# $Date: 2010-11-24 15:52:58 +0100 (Wed, 24 Nov 2010) $

use utf8;
use 5.006000;

our $VERSION = '0.03';

use Moose qw/around has/;
use MooseX::AttributeHelpers;

has '_name' => (
    is      => 'ro',
    isa     => 'Str',
    reader  => 'getName',
);

has '_widgets' => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef[WWW::Wookie::Widget]',
    default   => sub { {} },
);

sub put {
    my ( $self, $widget ) = @_;
    $self->_widgets->{ $widget->getIdentifier } = $widget;
    return;
}

sub get {
    my $self = shift;
    return $self->_widgets;
}

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    if ( @_ == 1 && !ref $_[0] ) {
        my ( $name ) = @_;
        return $class->$orig(
            _name    => $name,
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

=for stopwords Roland van Ipenburg plugins login url

=head1 NAME

WWW::Wookie::Widget::Category - client side representation of a widget service
category

=head1 VERSION

This document describes WWW::Wookie::Widget::Category version 0.03

=head1 SYNOPSIS

    use WWW::Wookie::Widget::Category;
    $c = WWW::Wookie::Widget::Category->new($name);
    $c->getName;

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<new>

Create a new service type.

=over

=item 1. Service name as string

=back

=head2 C<getName>

Gets the name of the service. Returns the name of the service as string.

=head2 C<get>

Gets the widgets available for this service. Returns an array of
L<WWW::Wookie::Widget|WWW::Wookie::Widget> objects.

=head2 C<put>

Adds a L<WWW::Wookie::Widget|WWW::Wookie::Widget> object to this service.

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

L<Moose|Moose>
L<MooseX::AttributeHelpers|MooseX::AttributeHelpers>

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
