#ABSTRACT: XML Sitemap Google extension image entry
use strict;
use warnings;
package WWW::Sitemap::XML::Google::Image;

use Moose;
use WWW::Sitemap::XML::Types qw( Location );
use XML::LibXML;

=head1 SYNOPSIS

    my $image = WWW::Sitemap::XML::Google::Image->new(
        {
            loc => 'http://mywebsite.com/image1.jpg',
            caption => 'Caption 1',
            title => 'Title 1',
            license => 'http://www.mozilla.org/MPL/2.0/',
            geo_location => 'Town, Region',
        },
    );

XML output:

    <?xml version="1.0" encoding="UTF-8"?>
    <image:image>
      <image:loc>http://mywebsite.com/image1.jpg</image:loc>
      <image:caption>Caption 1</image:caption>
      <image:title>Title 1</image:title>
      <image:license>http://www.mozilla.org/MPL/2.0/</image:license>
      <image:geo_location>Town, Region</image:geo_location>
    </image:image>

=head1 DESCRIPTION

WWW::Sitemap::XML::Google::Image represents single image entry in sitemap file.

Class implements L<WWW::Sitemap::XML::Google::Image::Interface>.

=cut

=attr loc

The URL of the image.

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

=attr caption

The caption of the image.

isa: C<Str>

Optional.

=cut

has 'caption' => (
    is => 'rw',
    isa => 'Str',
    required => 0,
    predicate => 'has_caption',
);

=attr title

The title of the image.

isa: C<Str>

Optional.

=cut

has 'title' => (
    is => 'rw',
    isa => 'Str',
    required => 0,
    predicate => 'has_title',
);

=attr geo_location

The geographic location of the image.

isa: C<Str>

Optional.

=cut

has 'geo_location' => (
    is => 'rw',
    isa => 'Str',
    required => 0,
    predicate => 'has_geo_location',
);

=attr license

A URL to the license of the image.

isa: L<WWW::Sitemap::XML::Types/"Location">

Optional.

=cut

has 'license' => (
    is => 'rw',
    isa => Location,
    required => 0,
    coerce => 1,
    predicate => 'has_license',
);

=method as_xml

Returns L<XML::LibXML::Element> object representing the C<E<lt>image:imageE<gt>> entry in the sitemap.

=cut

sub as_xml {
    my $self = shift;

    my $image = XML::LibXML::Element->new('image:image');

    do {
        my $name = $_;
        my $e = XML::LibXML::Element->new("image:$name");

        $e->appendText( $self->$name );

        $image->appendChild( $e );

    } for 'loc',grep {
            eval('$self->has_'.$_) || defined $self->$_()
        } qw( caption title license geo_location );

    return $image;
}

around BUILDARGS => sub {
    my $next = shift;
    my $class = shift;

    if ( @_ == 1 && ! ref $_[0] ) {
        return $class->$next(loc => $_[0]);
    }
    return $class->$next( @_ );
};

with 'WWW::Sitemap::XML::Google::Image::Interface';

=head1 SEE ALSO

L<https://support.google.com/webmasters/answer/183668>

=cut

__PACKAGE__->meta->make_immutable;

1;

