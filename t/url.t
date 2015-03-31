
use strict;
use warnings;

use Test::More tests => 10;
use Test::Exception;
use Test::NoWarnings qw(had_no_warnings);
$Test::NoWarnings::do_end_test = 0;

BEGIN { use_ok('WWW::Sitemap::XML::URL') }


my $o;

my @valid = (
    {
        loc => 'http://www.mywebsite.com/friendly_url.html?name=Alex%20J.%20G.%20Burzyński',
    },
    {
        loc => 'http://www.mywebsite.com/friendly_url.html?name=Alex%20J.%20G.%20Burzyński#fragment',
        lastmod => time(),
        changefreq => 'daily',
        priority => 0.3,
    }
);
my @invalid = (
    {},
    {
        loc => 'http://mywebsite.com/',
        lastmod => 'now',
    },
    {
        loc => 'http://mywebsite.com/',
        changefreq => 'nightly',
    },
    {
        loc => 'http://mywebsite.com/',
        priority => 2,
    },
);

for my $args ( @valid ) {
    lives_ok {
        $o = WWW::Sitemap::XML::URL->new(%$args);
    } 'object created with valid args';
    isa_ok($o->as_xml, 'XML::LibXML::Element');
}

for my $args ( @invalid ) {
    dies_ok {
        $o = WWW::Sitemap::XML::URL->new(%$args);
    } 'object not created with invalid args';
}


SKIP: {
    skip 'author testing', 1 unless ($ENV{'AUTHOR_TESTING'});

    had_no_warnings;
};
