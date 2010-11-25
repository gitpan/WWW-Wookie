# -*- cperl; cperl-indent-level: 4 -*-
package WWW::Wookie::Connector::Exceptions;
use strict;
use warnings;

## no critic qw(ProhibitLongLines)
# $Id: Exceptions.pm 361 2010-11-22 21:50:23Z roland $
# $Revision: 361 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/lib/WWW/Wookie/Connector/Exceptions.pm $
# $Date: 2010-11-22 22:50:23 +0100 (Mon, 22 Nov 2010) $
## use critic

use utf8;
use 5.006000;

our $VERSION = '0.03';

use Exception::Class qw(
  WookieConnectorException
  WookieWidgetInstanceException
);

1;

__END__

=encoding utf8

=for stopwords Roland van Ipenburg

=head1 NAME

WWW::Wookie::Connector::Exceptions - Handles exception information

=head1 VERSION

This document describes WWW::Wookie::Connector::Exceptions version 0.03

=head1 SYNOPSIS

    use WWW::Wookie::Connector::Exceptions;
    WookieConnectorException->throw( error => $ERR );
    WookieWidgetInstanceException->throw( error => $ERR );

=head1 DESCRIPTION

Provides C<WookieConnectorException> and C<WookieWidgetInstanceException>
exception classes based on L<Exception::Class::Base|Exception::Class::Base>.

=head1 SUBROUTINES/METHODS

All inherited from L<Exception::Class::Base|Exception::Class::Base/METHODS>.

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

L<Exception::Class|Exception::Class>

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
