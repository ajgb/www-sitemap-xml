#ABSTRACT: Abstract interface for sitemap indexes' Sitemap classes
use strict;
use warnings;
package WWW::SitemapIndex::XML::Sitemap::Interface;
use Moose::Role;

requires qw(
    loc lastmod as_xml
);

=head1 SYNOPSIS

    package My::SitemapIndex::Sitemap;
    use Moose;

    has [qw( loc lastmod as_xml )] => (
        is => 'rw',
        isa => 'Str',
    );

    with 'WWW::SitemapIndex::XML::Sitemap::Interface';

=head1 DESCRIPTION

Abstract interface for Sitemap elements added to sitemap index.

=head1 ABSTRACT METHODS

=head2 loc

URL of the sitemap.

=head2 lastmod

The date of last modification of the sitemap.

=head2 as_xml

XML representing the C<E<lt>sitemapE<gt>> entry in the sitemap index.

=cut

no Moose::Role;

1;

