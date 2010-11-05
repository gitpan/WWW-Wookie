# $Id: 14_kwalitee.t 315 2010-10-12 23:12:18Z roland $
# $Revision: 315 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/t/14_kwalitee.t $
# $Date: 2010-10-13 01:12:18 +0200 (Wed, 13 Oct 2010) $

use Test::More;

eval {
    require Test::Kwalitee;
    Test::Kwalitee->import( tests => [qw( -has_meta_yml)] );
};

plan( skip_all => 'Test::Kwalitee not installed; skipping' ) if $@;
