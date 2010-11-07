# $Id: 00_dependencies.t 355 2010-11-06 23:22:51Z roland $
# $Revision: 355 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/t/00_dependencies.t $
# $Date: 2010-11-07 00:22:51 +0100 (Sun, 07 Nov 2010) $

use Test::More;

if ( not $ENV{TEST_AUTHOR} ) {
    my $msg =
'Author test. Set the environment variable TEST_AUTHOR to enable this test.';
    plan( skip_all => $msg );
}

eval "use Test::Dependencies exclude => [qw/ WWW::Wookie /], style => q{heavy}";
plan skip_all => "Test::Dependencies required for testing dependencies" if $@;

TODO: {
    todo_skip q{Test::Dependencies can't do WWW::Wookie::Connector::Service}, 1
      if 1;    #!-f q{META.yml};
    ok_dependencies();
}
