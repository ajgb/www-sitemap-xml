#ABSTRACT: Abstract interface for Google extension video player class
use strict;
use warnings;
package WWW::Sitemap::XML::Google::Video::Player::Interface;

use Moose::Role;

requires qw(
    loc allow_embed autoplay as_xml
);

=head1 SYNOPSIS

    package My::Sitemap::Google::Video::Player;
    use Moose;

    has [qw( loc allow_embed autoplay as_xml )] => (
        is => 'rw',
        isa => 'Str',
    );

    with 'WWW::Sitemap::XML::Google::Video::Player::Interface';

=head1 DESCRIPTION

Abstract interface for video player elements added to sitemap.

See L<WWW::Sitemap::XML::Google::Video::Player> for details.

=cut

no Moose::Role;

1;
