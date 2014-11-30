#ABSTRACT: Abstract interface for Google extension video class
use strict;
use warnings;
package WWW::Sitemap::XML::Google::Video::Interface;

use Moose::Role;

requires qw(
    content_loc title description thumbnail_loc player as_xml
);

=head1 SYNOPSIS

    package My::Sitemap::Google::Video;
    use Moose;

    has [qw( content_loc title description thumbnail_loc player as_xml )] => (
        is => 'rw',
        isa => 'Str',
    );

    with 'WWW::Sitemap::XML::Google::Video::Interface';

=head1 DESCRIPTION

Abstract interface for video elements added to sitemap.

See L<WWW::Sitemap::XML::Google::Video> for details.

=cut

1;
