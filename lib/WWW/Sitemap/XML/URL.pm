#ABSTRACT: XML Sitemap url entry
use strict;
use warnings;
package WWW::Sitemap::XML::URL;

use Moose;
use WWW::Sitemap::XML::Types qw( Location ChangeFreq Priority ArrayRefOfImageObjects ArrayRefOfVideoObjects );
use MooseX::Types::DateTime::W3C qw( DateTimeW3C );
use XML::LibXML;
use WWW::Sitemap::XML::Google::Image;
use WWW::Sitemap::XML::Google::Video;

=head1 SYNOPSIS

    my $url = WWW::Sitemap::XML::URL->new(
        loc => 'http://mywebsite.com/',
        lastmod => '2010-11-26',
        changefreq => 'always',
        priority => 1.0,
    );

XML output:

    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
       <url>
          <loc>http://mywebsite.com/</loc>
          <lastmod>2010-11-26</lastmod>
          <changefreq>always</changefreq>
          <priority>1.0</priority>
       </url>
    </urlset>

Google sitemap video and image extensions:

    my $url2 = WWW::Sitemap::XML::URL->new(
        loc => 'http://mywebsite.com/',
        lastmod => '2010-11-26',
        changefreq => 'always',
        priority => 1.0,
        images => [
            {
                loc => 'http://mywebsite.com/image1.jpg',
                caption => Caption 1',
                title => 'Title 1',
                license => 'http://www.mozilla.org/MPL/2.0/',
                geo_location => 'Town, Region',
            },
            {
                loc => 'http://mywebsite.com/image2.jpg',
                caption => Caption 2',
                title => 'Title 2',
                license => 'http://www.mozilla.org/MPL/2.0/',
                geo_location => 'Town, Region',
            }
        ],
        videos => [
            content_loc => 'http://mywebsite.com/video1.flv',
            player => {
                loc => 'http://mywebsite.com/video_player.swf?video=1',
                allow_embed => "yes",
                autoplay => "ap=1",
            }
            thumbnail_loc => 'http://mywebsite.com/thumbs/1.jpg',
            title => 'Video Title 1',
            description => 'Video Description 1',
        ]

    );

XML output:

    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:image="http://www.google.com/schemas/sitemap-image/1.1"
        xmlns:video="http://www.google.com/schemas/sitemap-video/1.1">
       <url>
          <loc>http://mywebsite.com/</loc>
          <lastmod>2010-11-26</lastmod>
          <changefreq>always</changefreq>
          <priority>1.0</priority>
          <image:image>
             <image:loc>http://mywebsite.com/image1.jpg</image:loc>
             <image:caption>Caption 1</image:caption>
             <image:title>Title 1</image:title>
             <image:license>http://www.mozilla.org/MPL/2.0/</image:license>
             <image:geo_location>Town, Region</image:geo_location>
          </image:image>
          <image:image>
             <image:loc>http://mywebsite.com/image2.jpg</image:loc>
             <image:caption>Caption 2</image:caption>
             <image:title>Title 2</image:title>
             <image:license>http://www.mozilla.org/MPL/2.0/</image:license>
             <image:geo_location>Town, Region</image:geo_location>
          </image:image>
          <video:video>
             <video:content_loc>http://mywebsite.com/video1.flv</video:content_loc>
             <video:title>Video Title 1</video:title>
             <video:description>Video Description 1</video:description>
             <video:thumbnail_loc>http://mywebsite.com/thumbs/1.jpg</video:thumbnail_loc>
             <video:player_loc allow_embed="yes" autoplay="ap=1">http://mywebsite.com/video_player.swf?video=1</video:player_loc>
          </video:video>

       </url>
    </urlset>


=head1 DESCRIPTION

WWW::Sitemap::XML::URL represents single url entry in sitemap file.

Class implements L<WWW::Sitemap::XML::URL::Interface>.

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

The date of last modification of the page.

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
    coerce => 1,
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

=attr images

Array reference of images on page.

Note: This is a Google sitemap extension.

isa: L<WWW::Sitemap::XML::Types/"ArrayRefOfImageObjects">

Optional.

=cut

has 'images' => (
    is => 'rw',
    isa => ArrayRefOfImageObjects,
    required => 0,
    coerce => 1,
    predicate => 'has_images',
);

=attr videos

Array reference of videos on page.

Note: This is a Google sitemap extension.

isa: L<WWW::Sitemap::XML::Types/"ArrayRefOfVideoObjects">

Optional.

=cut

has 'videos' => (
    is => 'rw',
    isa => ArrayRefOfVideoObjects,
    required => 0,
    coerce => 1,
    predicate => 'has_videos',
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

    if ( $self->has_images ) {
        for my $image ( @{ $self->images || [] } ) {
            $url->appendChild( $image->as_xml );
        }
    }

    if ( $self->has_videos ) {
        for my $video ( @{ $self->videos || [] } ) {
            $url->appendChild( $video->as_xml );
        }
    }

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

