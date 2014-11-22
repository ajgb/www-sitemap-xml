#ABSTRACT: XML Sitemap index sitemap entry
use strict;
use warnings;
package WWW::SitemapIndex::XML::Sitemap;

use Moose;
use WWW::Sitemap::XML::Types qw( Location );
use MooseX::Types::DateTime::W3C qw( DateTimeW3C );
use XML::LibXML;

=head1 SYNOPSIS

    my $sitemap = WWW::SitemapIndex::XML::Sitemap->new(
        loc => 'http://mywebsite.com/sitemap1.xml.gz',
        lastmod => '2010-11-26',
    );

XML sample:

    <?xml version="1.0" encoding="UTF-8"?>
    <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
       <sitemap>
          <loc>http://mywebsite.com/sitemap1.xml.gz</loc>
          <lastmod>2010-11-26</lastmod>
       </sitemap>
    </sitemapindex>

=head1 DESCRIPTION

WWW::SitemapIndex::XML::Sitemap represents single sitemap entry in sitemap
index file.

Class implements L<WWW::SitemapIndex::XML::Sitemap::Interface>.

=cut

=attr loc

    $url->loc('http://mywebsite.com/sitemap1.xml.gz')

URL of the sitemap.

isa: L<WWW::Sitemap::XML::Types/"Location">

Required.

=cut

has 'loc' => (
    is => 'rw',
    isa => Location,
    required => 1,
    coerce => 1,
    predicate => 'has_loc',
);

=attr lastmod

The date of last modification of the sitemap.

isa: L<MooseX::Types::DateTime::W3C/"DateTimeW3C">

Optional.

=cut

has 'lastmod' => (
    is => 'rw',
    isa => DateTimeW3C,
    required => 0,
    coerce => 1,
    predicate => 'has_lastmod',
);

=method as_xml

Returns L<XML::LibXML::Element> object representing the C<E<lt>sitemapE<gt>>
entry in the sitemap.

=cut

sub as_xml {
    my $self = shift;

    my $sitemap = XML::LibXML::Element->new('sitemap');

    do {
        my $name = $_;
        my $e = XML::LibXML::Element->new($name);

        $e->appendText( $self->$name );

        $sitemap->appendChild( $e );

    } for 'loc',grep {
            eval('$self->has_'.$_) || defined $self->$_()
        } qw( lastmod );


    return $sitemap;
}

around BUILDARGS => sub {
    my $next = shift;
    my $class = shift;

    if ( @_ == 1 && ! ref $_[0] ) {
        return $class->$next(loc => $_[0]);
    }
    return $class->$next( @_ );
};

with 'WWW::SitemapIndex::XML::Sitemap::Interface';

=head1 SEE ALSO

L<http://www.sitemaps.org/protocol.php>

=cut

__PACKAGE__->meta->make_immutable;

1;

