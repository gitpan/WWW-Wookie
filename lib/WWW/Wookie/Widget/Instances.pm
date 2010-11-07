package WWW::Wookie::Widget::Instances;   # -*- cperl; cperl-indent-level: 4 -*-
use strict;
use warnings;

# $Id: Instances.pm 357 2010-11-07 10:53:18Z roland $
# $Revision: 357 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/lib/WWW/Wookie/Widget/Instances.pm $
# $Date: 2010-11-07 11:53:18 +0100 (Sun, 07 Nov 2010) $

use utf8;
use 5.006000;

our $VERSION = '0.02';

use Moose qw/around has/;
use MooseX::AttributeHelpers;

use WWW::Wookie::Widget::Instance;

has _instances => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef[WWW::Wookie::Widget::Instance]',
    default   => sub { {} },
);

sub put {
    my ( $self, $instance ) = @_;
    $self->_instances->{ $instance->getIdentifier() } = $instance;
    return;
}

sub get {
    my $self = shift;
    return $self->_instances;
}

no Moose;

## no critic qw(RequireExplicitInclusion)
__PACKAGE__->meta->make_immutable;
## use critic

1;

__END__

=encoding utf8

=for stopwords Roland van Ipenburg Readonly

=head1 NAME

WWW::Wookie::Widget::Instances - A collection of known widget instances
available to a host

=head1 VERSION

This document describes WWW::Wookie::Widget::Instances version 0.0.2

=head1 SYNOPSIS

    use WWW::Wookie::Widget::Instances;
    $i = WWW::Wookie::Widget::Instances->new();

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<new>

Create an empty collection.

=head2 C<put>

Record an instance of the given widget.

=over

=item 1. Instance of widget as
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance> object

=back

=head2 C<get>

Get all Widget instances. Returns an array of widget instances.

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

L<Moose|Moose>
L<MooseX::AttributeHelpers|MooseX::AttributeHelpers>
L<Readonly|Readonly>
L<WWW::Wookie::Widget::Instance|WWW::Wookie::Widget::Instance>

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
