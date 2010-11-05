# $Id: 11_test-coverage.t 350 2010-11-05 22:04:49Z roland $
# $Revision: 350 $
# $HeadURL: svn+ssh://ipenburg.xs4all.nl/srv/svnroot/barclay/trunk/t/11_test-coverage.t $
# $Date: 2010-11-05 23:04:49 +0100 (Fri, 05 Nov 2010) $

use Test::More;
eval "use Test::TestCoverage 0.08";
plan skip_all => "Test::TestCoverage 0.08 required for testing test coverage"
  if $@;

plan tests => 7;
my $TEST   = q{test};
my $URL    = q{http://localhost:8080/wookie/};
my $WIDGET = $URL . q{wservices/notsupported};
my $GUID   = q{http://notsupported};
my $TITLE  = q{Unsupported widget widget};
my $LOCALE = q{en_US};

my $obj;

test_coverage("WWW::Wookie::Widget");
$obj = WWW::Wookie::Widget->new( $TEST, $TEST, $TEST, $TEST );
$obj->getIdentifier();
$obj->getTitle();
$obj->getDescription();
$obj->getIcon();
$obj->DESTROY();
$obj->meta();
ok_test_coverage('WWW::Wookie::Widget');

test_coverage("WWW::Wookie::Widget::Instance");
$obj = WWW::Wookie::Widget::Instance->new( $TEST, $TEST, $TEST, 1, 1 );
$obj->getUrl();
$obj->setUrl($TEST);
$obj->getIdentifier();
$obj->setIdentifier($TEST);
$obj->getTitle();
$obj->setTitle($TEST);
$obj->getHeight();
$obj->setHeight(1);
$obj->getWidth();
$obj->setWidth(1);
$obj->DESTROY();
$obj->meta();
ok_test_coverage('WWW::Wookie::Widget::Instance');

test_coverage("WWW::Wookie::Widget::Instances");
$obj = WWW::Wookie::Widget::Instances->new();
$obj->put( WWW::Wookie::Widget::Instance->new( $TEST, $TEST, $TEST, 1, 1 ) );
$obj->get();
$obj->DESTROY();
$obj->meta();
ok_test_coverage('WWW::Wookie::Widget::Instances');

test_coverage("WWW::Wookie::Widget::Property");
$obj = WWW::Wookie::Widget::Property->new( $TEST, $TEST, 0 );
$obj->getName();
$obj->setName($TEST);
$obj->getValue();
$obj->setValue($TEST);
$obj->getIsPublic();
$obj->setIsPublic(1);
$obj->DESTROY();
$obj->meta();
ok_test_coverage('WWW::Wookie::Widget::Property');

test_coverage("WWW::Wookie::User");
$obj = WWW::Wookie::User->new();
$obj->getLoginName();
$obj->setLoginName($TEST);
$obj->getScreenName();
$obj->setScreenName($TEST);
$obj->getThumbnailUrl();
$obj->setThumbnailUrl($TEST);
$obj->DESTROY();
$obj->meta();
ok_test_coverage('WWW::Wookie::User');

test_coverage("WWW::Wookie::Server::Connection");
$obj = WWW::Wookie::Server::Connection->new( $URL, $TEST, $TEST );
$obj->getURL();
$obj->getApiKey();
$obj->getSharedDataKey();
$obj->as_string();
my $up = $obj->test();
$obj->DESTROY();
$obj->meta();
ok_test_coverage('WWW::Wookie::Server::Connection');

TODO: {
    local $TODO = q{Need a live Wookie server for this test} if !$up;
    test_coverage("WWW::Wookie::Connector::Service");

 #$obj = WWW::Wookie::Connector::Service->new($URL, $TEST, $TEST, $TEST, $TEST);
 #$obj->getLogger();
 #$obj->getConnection();
 #$obj->getLocale();
 #$obj->setLocale($LOCALE);
 #$obj->getUsers(
 #	WWW::Wookie::Widget::Instance->new($WIDGET, $GUID, $TITLE, 1, 1),
 #);
 #$obj->getUser();
 #$obj->setUser($TEST, $TEST);
 #$obj->properties();
 #$obj->WidgetInstances();
 #$obj->getProperty(
 #	WWW::Wookie::Widget::Instance->new($WIDGET, $GUID, $TITLE, 1, 1),
 #	WWW::Wookie::Widget::Property->new($TEST, $TEST, 0),
 #);
 #$obj->getOrCreateInstance($GUID);
 #$obj->deleteProperty(
 #	WWW::Wookie::Widget::Instance->new($TEST, $TEST, $TEST, 1, 1),
 #	WWW::Wookie::Widget::Property->new($TEST, $TEST, 0),
 #);
 #$obj->getAvailableWidgets();
 #$obj->setProperty(
 #	WWW::Wookie::Widget::Instance->new($TEST, $TEST, $TEST, 1, 1),
 #	WWW::Wookie::Widget::Property->new($TEST, $TEST, 0),
 #);
 #$obj->addParticipant(
 #	WWW::Wookie::Widget::Instance->new($TEST, $TEST, $TEST, 1, 1),
 #	WWW::Wookie::User->new($TEST, $TEST, $TEST),
 #);
 #$obj->deleteParticipant(
 #	WWW::Wookie::Widget::Instance->new($TEST, $TEST, $TEST, 1, 1),
 #	WWW::Wookie::User->new($TEST, $TEST, $TEST),
 #);
 #$obj->DESTROY();
 #$obj->meta();
    ok_test_coverage('WWW::Wookie::Connector::Service');
}
