#ABSTRACT: Type constraints used by WWW::Sitemap::XML and WWW::Sitemap::XML::URL
use strict;
use warnings;
package WWW::Sitemap::XML::Types;

use MooseX::Types -declare => [qw(
    SitemapURL
    SitemapIndexSitemap

    Location
    ChangeFreq
    Priority
)];

use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( Object Str Num );
use MooseX::Types::URI qw( Uri );

subtype SitemapURL,
    as Object,
    where {
        $_->meta->does_role('WWW::Sitemap::XML::URL::Interface')
    },
    message {
        'object does not implement WWW::Sitemap::XML::URL::Interface'
    };

subtype SitemapIndexSitemap,
    as Object,
    where {
        $_->meta->does_role('WWW::SitemapIndex::XML::Sitemap::Interface')
    },
    message {
        'object does not implement WWW::SitemapIndex::XML::Sitemap::Interface'
    };


# <loc>
subtype Location,
    as Str,
    where {
        my $url = to_Uri($_);
        $url->scheme && $url->authority
    },
    message { "$_ is not a valid URL" };

coerce Location,
    from Uri,
    via { $_->as_string };

# <changefreq>
subtype ChangeFreq,
    as enum([ qw( always hourly daily weekly monthly yearly never ) ]),
    message { 'Invalid changefreq' };

# <priority>
subtype Priority,
    as Num,
    where {
        $_ >= 0 && $_ <= 1
    },
    message { 'Valid priority ranges from 0.0 to 1.0'};

=head1 DESCRIPTION

Type constraints used by L<WWW::Sitemap::XML> and L<WWW::Sitemap::XML::URL>.

=type Location

    has 'loc' => (
        is => 'rw',
        isa => Location,
    );

URL location, coerced from L<Uri|MooseX::Types::URI> via C<{ $_-E<gt>as_string }>.

=type ChangeFreq

    has 'changefreq' => (
        is => 'rw',
        isa => ChangeFreq,
    );

Valid values are:

=over

=item * always

=item * hourly

=item * daily

=item * weekly

=item * monthly

=item * yearly

=item * never

=back

=type Priority

    has 'priority' => (
        is => 'rw',
        isa => Priority,
    );

Subtype of C<Num> with values in range from C<0.0> to C<1.0>.

=type SitemapURL

    has 'url' => (
        is => 'rw',
        isa => SitemapURL,
    );

Subtype of C<Object>, argument needs to implement L<WWW::Sitemap::XML::URL::Interface>.

=type SitemapIndexSitemap

    has 'sitemap' => (
        is => 'rw',
        isa => SitemapIndexSitemap,
    );

Subtype of C<Object>, argument needs to implement L<WWW::SitemapIndex::XML::Sitemap::Interface>.

=cut

no Moose::Util::TypeConstraints;

1;

