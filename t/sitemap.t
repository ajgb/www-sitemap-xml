
use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::NoWarnings;



my $o;
my @smart_uri_test = eval {
    require URI::SmartURI;
    { loc => URI::SmartURI->new('https://domain.test:8443/test/p') };
};

my @valid = (
    @smart_uri_test ? @smart_uri_test : (),
    {
        loc => 'https://domain.test:8443/test/p',
    },
    {
        loc => 'http://www.mywebsite.com/sitemap1.xml.gz',
    },
    {
        loc     => 'http://www.mywebsite.com/sitemap1.xml.gz?source=google',
        lastmod => time(),
    }
);
my @invalid = (
    {},
    {
        loc => 'http://mywebsite.com/sitemap1.xml.gz',
        lastmod => 'now',
    },
);

plan tests => 1     # use_ok
    + 1             # "no warnings"
    + 2 * @valid    # two tests per valid entry
    + @invalid;     # one test per invalid entry

use_ok('WWW::SitemapIndex::XML::Sitemap');

for my $args ( @valid ) {
    lives_ok {
        $o = WWW::SitemapIndex::XML::Sitemap->new(%$args);
    } 'object created with valid args';
    isa_ok($o->as_xml, 'XML::LibXML::Element');
}

for my $args ( @invalid ) {
    dies_ok {
        $o = WWW::SitemapIndex::XML::Sitemap->new(%$args);
    } 'object not created with invalid args';
}
