# $Id: 09_pod.t 315 2010-10-12 23:12:18Z roland $
# $Revision: 315 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/t/09_pod.t $
# $Date: 2010-10-13 01:12:18 +0200 (Wed, 13 Oct 2010) $

use Test::More;
eval "use Test::Pod 1.00";
plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
all_pod_files_ok();
