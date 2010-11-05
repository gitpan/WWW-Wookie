# $Id: 10_pod-coverage.t 350 2010-11-05 22:04:49Z roland $
# $Revision: 350 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/t/10_pod-coverage.t $
# $Date: 2010-11-05 23:04:49 +0100 (Fri, 05 Nov 2010) $

use Test::More;
eval "use Test::Pod::Coverage 1.00";
plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage"
  if $@;
all_pod_coverage_ok( { also_private => [q{BUILD}] } );
