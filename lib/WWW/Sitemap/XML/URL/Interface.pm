#ABSTRACT: Abstract interface for sitemap's URL classes
use strict;
use warnings;
package WWW::Sitemap::XML::URL::Interface;
use Moose::Role;

requires qw(
    loc lastmod changefreq priority as_xml
);

=head1 SYNOPSIS

    package My::Sitemap::URL;
    use Moose;

    has [qw( loc lastmod changefreq priority as_xml )] => (
        is => 'rw',
        isa => 'Str',
    );

    with 'WWW::Sitemap::XML::URL::Interface';

=head1 DESCRIPTION

Abstract interface for URL elements added to sitemap.

=head1 ABSTRACT METHODS

=head2 loc

URL of the page.

=head2 lastmod

The date of last modification of the file.

=head2 changefreq

How frequently the page is likely to change.

=head2 priority

The priority of this URL relative to other URLs on your site.

=head2 as_xml

XML representing the C<E<lt>urlE<gt>> entry in the sitemap.

=cut

no Moose::Role;

1;

