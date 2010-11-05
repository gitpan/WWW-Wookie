use 5.006000;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    ( MM->can('signature_target') ? ( SIGN => 1 ) : () ),
    NAME         => 'WWW::Wookie',
    VERSION_FROM => 'lib/WWW/Wookie.pm',    # finds $VERSION
    PREREQ_PM    => {
        Readonly                     => 0,
        Test::More                   => 0.81,
        Test::NoWarnings             => 0,
        Log::Log4perl                => 0,
        Moose                        => 0,
        Moose::Util::TypeConstraints => 0,
        MooseX::AttributeHelpers     => 0,
        HTTP::Request::Common        => 0,
        HTTP::Response               => 0,
        HTTP::Status                 => 0,
        LWP::UserAgent               => 0,
        Regexp::Common               => 0,
        XML::Simple                  => 0,
    },
    (
        $] >= 5.005
        ?    ## Add these new keywords supported since 5.005
          (
            ABSTRACT_FROM =>
              'lib/WWW/Wookie.pm',    # retrieve abstract from module
            AUTHOR => 'Roland van Ipenburg <ipenburg@xs4all.nl>'
          )
        : ()
    ),
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002 ?
          ( 'LICENSE' => 'apache', )
        : () ),
);
