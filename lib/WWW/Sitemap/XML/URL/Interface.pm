#ABSTRACT: Abstract interface for sitemap's URL classes
use strict;
use warnings;
package WWW::Sitemap::XML::URL::Interface;

use Moose::Role;

requires qw(
    loc lastmod changefreq priority images videos mobile as_xml
);

=head1 SYNOPSIS

    package My::Sitemap::URL;
    use Moose;

    has [qw( loc lastmod changefreq priority as_xml )] => (
        is => 'rw',
        isa => 'Str',
    );

    has [qw( images videos )] => (
        is => 'rw',
        isa => 'ArrayRef',
    );

    has [qw( mobile )] => (
        is => 'rw',
        isa => 'Bool',
    );

    with 'WWW::Sitemap::XML::URL::Interface';

=head1 DESCRIPTION

Abstract interface for URL elements added to sitemap.

See L<WWW::Sitemap::XML::URL> for details.

=cut

no Moose::Role;

1;

