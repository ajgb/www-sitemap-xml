use strict;
use warnings;
package WWW::Sitemap::XML;
#ABSTRACT: XML Sitemap protocol

use Moose;

use WWW::Sitemap::XML::URL;
use XML::LibXML 1.70;
use Scalar::Util qw( blessed );

use WWW::Sitemap::XML::Types qw( SitemapURL );

=head1 SYNOPSIS

    use WWW::Sitemap::XML;

    my $map = WWW::Sitemap::XML->new();

    # add new url
    $map->add( 'http://mywebsite.com/' );

    # or
    $map->add(
        loc => 'http://mywebsite.com/',
        lastmod => '2010-11-22',
        changefreq => 'monthly',
        priority => 1.0,
    );

    # or
    $map->add(
        WWW::Sitemap::XML::URL->new(
            loc => 'http://mywebsite.com/',
            lastmod => '2010-11-22',
            changefreq => 'monthly',
            priority => 1.0,
        )
    );

    # read URLs from existing sitemap.xml file
    my @urls = $map->read( 'sitemap.xml' );

    # load urls from existing sitemap.xml file
    $map->load( 'sitemap.xml' );

    # get XML::LibXML object
    my $xml = $map->as_xml;

    print $xml->toString(1);

    # write to file
    $map->write( 'sitemap.xml', my $pretty_print = 1 );

    # write compressed
    $map->write( 'sitemap.xml.gz' );


=head1 DESCRIPTION

    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
       <url>
          <loc>http://mywebsite.com/</loc>
          <lastmod>2010-11-22</lastmod>
          <changefreq>monthly</changefreq>
          <priority>1.0</priority>
       </url>
    </urlset> 

Read and write sitemap xml files as defined at L<http://www.sitemaps.org/>.

=cut

has '_urlset' => (
    is => 'ro',
    traits => [qw( Array )],
    isa => 'ArrayRef',
    default => sub { [] },
    handles => {
        _add_url => 'push',
        _count_urls => 'count',
        urls => 'elements',
    }
);

has '_first_url' => (
    is => 'rw',
    isa => 'Str',
);

sub _pre_check_add {
    my ($self, $url) = @_;

    die 'object does not implement WWW::Sitemap::XML::URL::Interface'
        unless is_SitemapURL($url);

    die "Sitemap cannot contain more then 50 000 URLs"
        if $self->_count_urls >= 50_000;

    my $loc = $url->loc;

    die "URL cannot be longer then 2048 characters"
        unless length $loc < 2048;

    my($scheme, $authority) = $loc =~ m|(?:([^:/?#]+):)?(?://([^/?#]*))?|;
    my $new = "$scheme://$authority";
    if ( $self->_count_urls ) {
        my $first = $self->_first_url;

        die "URLs in sitemap should use the same protocol and reside on the "
            ."same host: $first, not $new" unless $first eq $new;
    } else {
        $self->_first_url( $new );
    }
}

=method add($url|%attrs)

    $map->add(
        WWW::Sitemap::XML::URL->new(
            loc => 'http://mywebsite.com/',
            lastmod => '2010-11-22',
            changefreq => 'monthly',
            priority => 1.0,
        )
    );

Add the C<$url> object representing single page in the sitemap.

Accepts blessed objects implementing L<WWW::Sitemap::XML::URL::Interface>.

Otherwise the arguments C<%attrs> are passed as-is to create new
L<WWW::Sitemap::XML::URL> object.

    $map->add(
        loc => 'http://mywebsite.com/',
        lastmod => '2010-11-22',
        changefreq => 'monthly',
        priority => 1.0,
    );

    # single url argument
    $map->add( 'http://mywebsite.com/' );

    # is same as
    $map->add( loc => 'http://mywebsite.com/' );

Performs basic validation of urls added:

=over

=item * maximum of 50 000 urls in single sitemap

=item * URL no longer then 2048 characters

=item * all URLs should use the same protocol and reside on same host

=back

=cut

sub add {
    my $self = shift;

    my $arg = @_ == 1 && blessed $_[0] ?
                shift @_ : WWW::Sitemap::XML::URL->new(@_);

    $self->_pre_check_add($arg);

    $self->_add_url( $arg );
}

=method urls

    my @urls = $map->urls;

Returns a list of all URL objects added to sitemap.

=method load(%sitemap_location)

    $map->load( location => $sitemap_file );

It is a shortcut for:

    $map->add($_) for $map->read( location => $sitemap_file );

Please see L<"read"> for details.

=cut

sub load {
    my $self = shift;

    $self->add($_) for $self->read(@_);
}

=method read(%sitemap_location)

    # file or url to sitemap
    my @urls = $map->read( location => $file_or_url );

    # file handle
    my @urls = $map->read( IO => $fh );

    # xml string
    my @urls = $map->read( string => $xml );

Read the sitemap from file, URL, open file handle or string and return the list of
L<WWW::Sitemap::XML::URL> objects representing C<E<lt>urlE<gt>> elements.

=cut

sub read {
    my ($self, %sitemap) = @_;

    my @urls;

    my $xml = XML::LibXML->load_xml( %sitemap );

    for my $url ( $xml->getDocumentElement->nonBlankChildNodes() ) {
        push @urls,
            WWW::Sitemap::XML::URL->new(
                map { $_->nodeName => $_->textContent } $url->nonBlankChildNodes
            );
    }

    return @urls;
}

=method write($file, $format = 0)

    # write to file
    $map->write( 'sitemap.xml', my $pretty_print = 1);

    # or
    my $fh = IO::File->new();
    $fh->open("sitemap.xml", "w");
    $map->write( $fh, my $pretty_print = 1);
    $cfh->close;

    # write compressed
    $map->write( 'sitemap.xml.gz' );

Write XML sitemap to C<$file> - a file name or L<IO::Handle> object.

If file names ends in C<.gz> then the output file will be compressed by
setting compression on xml object - please note that it requires I<libxml2> to
be compiled with I<zlib> support.

Optional C<$format> is passed to C<toFH> or C<toFile> methods
(depending on the type of C<$file>, respectively for file handle and file name)
as described in L<XML::LibXML>.

=cut

sub write {
    my ($self, $fh, $format) = @_;

    $format ||= 0;

    my $writer = 'toFH';
    my $xml = $self->as_xml;

    unless ( ref $fh ) {
        $writer = 'toFile';
        if ( $fh =~ /\.gz$/i ) {
            $xml->setCompression(8);
        }
    }

    $xml->$writer( $fh, $format );
}

=method as_xml

    my $xml = $map->as_xml;

    # pretty print
    print $xml->toString(1);

    # write compressed
    $xml->setCompression(8);
    $xml->toFile( "sitemap.xml" );


Returns L<XML::LibXML::Document> object representing the sitemap in XML format.

The C<E<lt>urlE<gt>> elements are built by calling I<as_xml> on all URL objects
added into sitemap.

=cut

{
    my %ns = (
        'xmlns' => "http://www.sitemaps.org/schemas/sitemap/0.9",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' => join(' ',
            'http://www.sitemaps.org/schemas/sitemap/0.9',
            'http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd'
        ),
    );

    sub as_xml {
        my $self = shift;

        my $xml = XML::LibXML->createDocument('1.0','UTF-8');
        my $urlset = $xml->createElement('urlset');

        while (my ($k, $v) = each %ns ) {
            $urlset->setAttribute($k, $v);
        };

        $urlset->appendChild($_) for
            map {
                my $xml = $_->as_xml;
                blessed $xml ? $xml : XML::LibXML->load_xml(string => $xml)->documentElement()
            } $self->urls;

        $xml->setDocumentElement($urlset);

        return $xml;
    }

}

=head1 SEE ALSO

L<http://www.sitemaps.org/>

L<Search::Sitemap>

=cut

__PACKAGE__->meta->make_immutable;

1;

