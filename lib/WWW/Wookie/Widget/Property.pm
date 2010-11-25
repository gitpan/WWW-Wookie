package WWW::Wookie::Widget::Property;    # -*- cperl; cperl-indent-level: 4 -*-
use strict;
use warnings;

# $Id: Property.pm 360 2010-11-22 13:03:01Z roland $
# $Revision: 360 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/lib/WWW/Wookie/Widget/Property.pm $
# $Date: 2010-11-22 14:03:01 +0100 (Mon, 22 Nov 2010) $

use utf8;
use 5.006000;

our $VERSION = '0.03';

use Moose qw/around has/;

use Readonly;
## no critic qw(ProhibitCallsToUnexportedSubs)
Readonly::Scalar my $MORE_ARGS => 3;
## use critic

has '_name' => (
	is  => 'rw',
	isa => 'Str',
	reader => 'getName',
	writer => 'setName',
);

has '_value' => (
	is  => 'rw',
	isa => 'Any',
	reader => 'getValue',
	writer => 'setValue',
);

has '_public' => (
	is  => 'rw',
	isa => 'Bool',
	reader => 'getIsPublic',
	writer => 'setIsPublic',
);

around BUILDARGS => sub {
	my $orig  = shift;
	my $class = shift;

	if (@_ == 1 && !ref $_[0]) {
		push @_, undef;
	}
	if (@_ == 2 && !ref $_[0]) {
		push @_, 0;
	}
	if ( @_ == $MORE_ARGS && !ref $_[0] ) {
		return $class->$orig(
			_name => $_[0],
			_value => $_[1],
			_public => $_[2],
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

=for stopwords Roland van Ipenburg Readonly boolean

=head1 NAME

WWW::Wookie::Widget::Property - Property class

=head1 VERSION

This document describes WWW::Wookie::Widget::Property version 0.03

=head1 SYNOPSIS

    use WWW::Wookie::Widget::Property;
    $p = WWW::Wookie::Widget::Property->new($name, $value, 0);

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<new>

Construct a new property.

=over

=item 1. Property name as string

=item 2. Property value as string

=item 3. Is property public (handled as shared data key) or private as boolean

=back

=head2 C<getValue>

Get property value. Returns value of property as sting.

=head2 C<getName>

Get property name. Returns name of property as sting.

=head2 C<isPublic>

Get property C<isPublic> flag. Return the C<isPublic> flag of the property as
string.

=head2 C<setValue>

Set property value.

=over

=item 1. New value as string

=back

=head2 C<setName>

Set property name.

=over

=item 1. New name as string

=back

=head2 C<setIsPublic>

Set C<isPublic> flag, 1 or 0.

=over

=item 1. Flag 1 or 0

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
