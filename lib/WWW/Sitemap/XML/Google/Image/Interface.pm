#ABSTRACT: Abstract interface for Google extension image class
use strict;
use warnings;
package WWW::Sitemap::XML::Google::Image::Interface;

use Moose::Role;

requires qw(
    loc caption title geo_location license as_xml
);

=head1 SYNOPSIS

    package My::Sitemap::Google::Image;
    use Moose;

    has [qw( loc caption title geo_location license as_xml )] => (
        is => 'rw',
        isa => 'Str',
    );

    with 'WWW::Sitemap::XML::Google::Image::Interface';

=head1 DESCRIPTION

Abstract interface for image elements added to sitemap.

See L<WWW::Sitemap::XML::Google::Image> for details.

=cut

1;
