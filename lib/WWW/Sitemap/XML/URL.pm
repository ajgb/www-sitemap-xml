use strict;
use warnings;
package WWW::Sitemap::XML::URL;
#ABSTRACT: XML Sitemap url entry

use Moose;
use WWW::Sitemap::XML::Types qw( Location ChangeFreq Priority );
use MooseX::Types::DateTime::W3C qw( DateTimeW3C );
use XML::LibXML;

=head1 SYNOPSIS

    my $url = WWW::Sitemap::XML::URL->new(
        loc => 'http://mywebsite.com/',
        lastmod => time(),
        changefreq => 'always',
        priority => 1.0,
    );

=head1 DESCRIPTION

WWW::Sitemap::XML::URL represents single url entry in sitemap file.

    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
       <url>
          <loc>http://mywebsite.com/</loc>
          <lastmod>2010-11-26</lastmod>
          <changefreq>always</changefreq>
          <priority>1.0</priority>
       </url>
        <url>
          <loc>http://mywebsite.com/page.html</loc>
       </url>
    </urlset>

Implements L<WWW::Sitemap::XML::URL::Interface>.

=cut

=attr loc

    $url->loc('http://mywebsite.com/')

URL of the page.

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

The date of last modification of the file.

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

=attr changefreq

How frequently the page is likely to change.

isa: L<WWW::Sitemap::XML::Types/"ChangeFreq">

Optional.

=cut

has 'changefreq' => (
    is => 'rw',
    isa => ChangeFreq,
    required => 0,
    predicate => 'has_changefreq',
);

=attr priority

The priority of this URL relative to other URLs on your site.

isa: L<WWW::Sitemap::XML::Types/"Priority">

Optional.

=cut

has 'priority' => (
    is => 'rw',
    isa => Priority,
    required => 0,
    predicate => 'has_priority',
);

=method as_xml

Returns L<XML::LibXML::Element> object representing the C<E<lt>urlE<gt>> entry in the sitemap.

=cut

sub as_xml {
    my $self = shift;

    my $url = XML::LibXML::Element->new('url');

    do {
        my $name = $_;
        my $e = XML::LibXML::Element->new($name);

        $e->appendText( $self->$name );

        $url->appendChild( $e );

    } for 'loc',grep {
            eval('$self->has_'.$_) || defined $self->$_()
        } qw( lastmod changefreq priority );


    return $url;
}

around BUILDARGS => sub {
    my $next = shift;
    my $class = shift;

    if ( @_ == 1 && ! ref $_[0] ) {
        return $class->$next(loc => $_[0]);
    }
    return $class->$next( @_ );
};

with 'WWW::Sitemap::XML::URL::Interface';

=head1 SEE ALSO

L<http://www.sitemaps.org/protocol.php>

=cut

__PACKAGE__->meta->make_immutable;

1;

