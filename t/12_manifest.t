# $Id: 12_manifest.t 315 2010-10-12 23:12:18Z roland $
# $Revision: 315 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/t/12_manifest.t $
# $Date: 2010-10-13 01:12:18 +0200 (Wed, 13 Oct 2010) $

use Test::More;
eval "use Test::CheckManifest 1.01";
plan skip_all => "Test::CheckManifest 1.01 required for testing test coverage"
  if $@;
ok_manifest( { filter => [qr/(Debian_CPANTS.txt|\.(svn|bak))/] } );
