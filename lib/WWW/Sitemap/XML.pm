use strict;
use warnings;
package WWW::Sitemap::XML;
#ABSTRACT: XML Sitemap protocol

use Moose;

use WWW::Sitemap::XML::URL;
use XML::Twig;
use Scalar::Util qw( blessed );
use IO::Zlib;

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

    # get xml object
    my $xml = $map->as_xml;
    $xml->set_pretty_print('indented');

    print $xml->sprint;

    # write to file
    $map->write( 'sitemap.xml', pretty_print => 'indented' );

    # write compressed
    $map->write( 'sitemap.xml.gz' );

    # or
    my $cfh = IO::Zlib->new();
    $cfh->open("sitemap.xml.gz", "wb9");

    $map->write( $cfh );

    $cfh->close;

=head1 DESCRIPTION

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
        if length $loc >= 2048;

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

=method load($sitemap)

    $map->load( $sitemap );

It is a shortcut for:

    $map->add($_) for $map->read($sitemap);

Please see L<"read"> for details.

=cut

sub load {
    my ($self, $sitemap) = @_;

    $self->add($_) for $self->read($sitemap);
}

=method read($sitemap)

    my @urls = $map->read( $sitemap );

Read the content of C<$sitemap> and return the list of
L<WWW::Sitemap::XML::URL> objects representing single C<E<lt>urlE<gt>>
element.

C<$sitemap> could be either a string containing the whole XML sitemap, a
filename of a sitemap file or an open L<IO::Handle>.

=cut

sub read {
    my ($self, $sitemap) = @_;

    my @urls;

    my $xt = XML::Twig->new(
        twig_roots => {
            'urlset/url' => sub {
                my ($t, $url) = @_;

                push @urls,
                    WWW::Sitemap::XML::URL->new(
                        map { $_->name => $_->field } $url->children
                    );

                $t->purge;
            }
        }
    );

    $xt->parse($sitemap);

    return @urls;
}

=method write($file, %options)

    # write to file
    $map->write( 'sitemap.xml', pretty_print => 'indented');

    # or
    my $fh = IO::File->new();
    $fh->open("sitemap.xml", ">:utf8");
    $map->write( $fh, pretty_print => 'indented');
    $cfh->close;

    # write compressed
    $map->write( 'sitemap.xml.gz' );

    # or
    my $cfh = IO::Zlib->new();
    $cfh->open("sitemap.xml.gz", "wb9");
    $map->write( $cfh );
    $cfh->close;

Write XML sitemap to C<$file> - a file name or L<IO::Handle> object.

If file names ends in C<.gz> then the output file will be compressed using
L<IO::Zlib>.

Optional C<%options> are passed to C<flush> or C<print_to_file> methods
(depending on the type of C<$file>, respectively for file handle and file name)
as decribed in L<XML::Twig>.

=cut

sub write {
    my ($self, $fh, %options) = @_;

    my $writer = 'flush';
    my $_fh_was_opened;

    unless ( ref $fh ) {
        if ( $fh =~ /\.gz$/i ) {
            my $fname = $fh;

            $fh = IO::Zlib->new($fname, "wb9")
                or die "Cannot open $fname for writing: $!";

            $_fh_was_opened = 1;
        } else {
            $writer = 'print_to_file';
        }
    }
    my $xml = $self->as_xml;

    $xml->$writer( $fh, %options );

    $fh->close if $_fh_was_opened;
}

=method as_xml

    my $xml = $map->as_xml;

    $xml->set_pretty_print('indented');

    open SITEMAP, ">sitemap.xml";
    print SITEMAP $xml->sprint;
    close SITEMAP;

    # write compressed
    $xml->set_pretty_print('none');

    my $cfh = IO::Zlib->new();
    $cfh->open("sitemap.xml.gz", "wb9");

    print $cfh $xml->sprint;

    $cfh->close;


Returns L<XML::Twig> object representing the sitemap in XML format.

=cut

sub as_xml {
    my $self = shift;

    my $xt = XML::Twig->new(
        no_prolog => 0,
    );;

    $xt->set_xml_version("1.0");
    $xt->set_encoding("UTF-8");
    my $root = XML::Twig::Elt->new('urlset',
        {
            'xmlns' => "http://www.sitemaps.org/schemas/sitemap/0.9",
            'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
            'xsi:schemaLocation' => join(' ',
                'http://www.sitemaps.org/schemas/sitemap/0.9',
                'http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd'
            ),
        },
        map {
            my $xml = $_->as_xml;
            ref $xml ? $xml : XML::Twig::Elt->parse($xml)
        } $self->urls
    );
    $xt->set_root( $root );

    return $xt;
}

=head1 SEE ALSO

L<http://www.sitemaps.org/>

L<Search::Sitemap>

=cut

__PACKAGE__->meta->make_immutable;

1;

