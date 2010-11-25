# $Id: rt.t 360 2010-11-22 13:03:01Z roland $
# $Revision: 360 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/t/rt.t $
# $Date: 2010-11-22 14:03:01 +0100 (Mon, 22 Nov 2010) $

use Test::More tests => 2 + 2;
use Test::NoWarnings;

use Readonly;
Readonly::Scalar my $WOOKIE_SERVER_CIRCUM => q{http://localhost:8080/wookie};
Readonly::Scalar my $WOOKIE_SERVER        => q{http://localhost:8080/wookie/};
Readonly::Scalar my $API_KEY              => q{TEST};
Readonly::Scalar my $SHARED_DATA_KEY      => q{localhost_dev};
use WWW::Wookie::Server::Connection;

my $obj = WWW::Wookie::Server::Connection->new( $WOOKIE_SERVER_CIRCUM, $API_KEY,
    $SHARED_DATA_KEY );
is( $obj->getURL, $WOOKIE_SERVER, q{RT#63231} );
$obj = WWW::Wookie::Server::Connection->new( $WOOKIE_SERVER, $API_KEY,
    $SHARED_DATA_KEY );
is( $obj->getURL, $WOOKIE_SERVER, q{RT#63231} );

my $msg = 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.';
SKIP: {
    skip $msg, 1 unless $ENV{TEST_AUTHOR};
}
$ENV{TEST_AUTHOR} && Test::NoWarnings::had_no_warnings();
