#ABSTRACT: Type constraints used by WWW::Sitemap::XML and WWW::Sitemap::XML::URL
use strict;
use warnings;
package WWW::Sitemap::XML::Types;

use MooseX::Types -declare => [qw(
    SitemapURL
    SitemapIndexSitemap

    Location
    ChangeFreq
    LowercaseStr
    Priority

    VideoPlayer
    VideoObject
    ArrayRefOfVideoObjects
    ImageObject
    ArrayRefOfImageObjects
    StrBool
    Max100CharsStr
    Max2048CharsStr
)];

use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( Object Str Num Bool ArrayRef HashRef );
use MooseX::Types::URI qw( Uri );
use Scalar::Util qw( blessed );

role_type SitemapURL, { role => 'WWW::Sitemap::XML::URL::Interface' };

role_type SitemapIndexSitemap, { role => 'WWW::SitemapIndex::XML::Sitemap::Interface' };

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

subtype LowercaseStr,
    as Str,
    where {
        $_ eq lc($_)
    },
    message { "$_ contains uppercase characters" };

coerce LowercaseStr,
    from Str,
    via { lc($_) };

subtype Max100CharsStr,
    as Str,
    where {
        length($_) <= 100
    },
    message { "Maximum of 100 characters allowed" };

subtype Max2048CharsStr,
    as Str,
    where {
        length($_) <= 2048
    },
    message { "Maximum of 2048 characters allowed" };

# <changefreq>
my %valid_changefreqs = map { $_ => 1 } qw( always hourly daily weekly monthly yearly never );
subtype ChangeFreq,
    as LowercaseStr,
    where {
        exists $valid_changefreqs{$_}
    };

coerce ChangeFreq,
    from Str,
    via { lc($_) };

# <priority>
subtype Priority,
    as Num,
    where {
        $_ >= 0 && $_ <= 1
    },
    message { 'Valid priority ranges from 0.0 to 1.0'};

# allow_embed
my %valid_str_bool = ( yes => 1, no => 1 );
subtype StrBool,
    as LowercaseStr,
    where {
        exists $valid_str_bool{ lc($_) }
    };

coerce StrBool,
    from Bool,
    via { $_ ? 'yes' : 'no' };

role_type VideoObject, { role => 'WWW::Sitemap::XML::Google::Video::Interface' };

coerce VideoObject,
    from HashRef,
    via {
        return WWW::Sitemap::XML::Google::Video->new( %{ $_ || {} } )
    };

subtype ArrayRefOfVideoObjects,
    as ArrayRef[VideoObject];

coerce ArrayRefOfVideoObjects,
    from ArrayRef[HashRef|Object],
    via {
        [
            map { blessed($_) ? $_ : WWW::Sitemap::XML::Google::Video->new( %{ $_ || {} } ) } @$_
        ]
    };

role_type ImageObject, { role => 'WWW::Sitemap::XML::Google::Image::Interface' };

coerce ImageObject,
    from HashRef,
    via {
        return WWW::Sitemap::XML::Google::Image->new( %{ $_ || {} } )
    };

subtype ArrayRefOfImageObjects,
    as ArrayRef[ImageObject],
    where {
        scalar(@$_) <= 1000
    };

coerce ArrayRefOfImageObjects,
    from ArrayRef[HashRef|Object],
    via {
        [
            map { blessed($_) ? $_ : WWW::Sitemap::XML::Google::Image->new( %{ $_ || {} } ) } @$_
        ]
    };


role_type VideoPlayer, { role => 'WWW::Sitemap::XML::Google::Video::Player::Interface' };

coerce VideoPlayer,
    from HashRef,
    via {
        WWW::Sitemap::XML::Google::Video::Player->new( %{ $_ || {} } )
    };

coerce VideoPlayer,
    from Str,
    via {
        WWW::Sitemap::XML::Google::Video::Player->new( loc => $_ )
    };

# runtime to avoid circular references
require WWW::Sitemap::XML::Google::Image;
require WWW::Sitemap::XML::Google::Video;
require WWW::Sitemap::XML::Google::Video::Player;

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

Role type, argument needs to implement L<WWW::Sitemap::XML::URL::Interface>.

=type SitemapIndexSitemap

    has 'sitemap' => (
        is => 'rw',
        isa => SitemapIndexSitemap,
    );

Role type, argument needs to implement L<WWW::SitemapIndex::XML::Sitemap::Interface>.

=type LowercaseStr

    has 'lowercase' => (
        is => 'rw',
        coerce => 1,
        isa => LowercaseStr,
    );

Subtype of C<Str>, with only lowercase characters.

Coerces from C<Str> using C<lc>.

=type Max100CharsStr

    has 'short_str' => (
        is => 'rw',
        isa => Max100CharsStr,
    );

Subtype of C<Str>, up to 100 characters.

=type Max2048CharsStr

    has 'longer_str' => (
        is => 'rw',
        isa => Max2048CharsStr,
    );

Subtype of C<Str>, up to 2048 characters.

=type StrBool

    has 'yes_no' => (
        is => 'rw',
        coerce => 1,
        isa => StrBool,
    );

Subtype of C<LowercaseStr>, with valid values I<yes> and I<no>.

Coerces from C<Bool>.

=type ImageObject

    has 'image' => (
        is => 'rw',
        coerce => 1,
        isa => ImageObject,
    );

Role type, argument needs to implement L<WWW::Sitemap::XML::Google::Image::Interface>.

Coerces from C<HashRef> by creating L<WWW::Sitemap::XML::Google::Image> object.

=type ArrayRefOfImageObjects

    has 'images' => (
        is => 'rw',
        coerce => 1,
        isa => ArrayRefOfImageObjects,
    );

Subtype of C<ArrayRef>, were values are L<"ImageObject"> elements.

Coerces from C<ArrayRef[HashRef]> by creating an array of L<WWW::Sitemap::XML::Google::Image> objects.

=type VideoObject

    has 'video' => (
        is => 'rw',
        coerce => 1,
        isa => VideoObject,
    );

Role type, argument needs to implement L<WWW::Sitemap::XML::Google::Video::Interface>.

Coerces from C<HashRef> by creating L<WWW::Sitemap::XML::Google::Video> object.

=type ArrayRefOfVideoObjects

    has 'videos' => (
        is => 'rw',
        coerce => 1,
        isa => ArrayRefOfVideoObjects,
    );

Subtype of C<ArrayRef>, were values are L<"VideoObject"> elements.

Coerces from C<ArrayRef[HashRef]> by creating an array of L<WWW::Sitemap::XML::Google::Video> objects.

=type VideoPlayer

    has 'video_player' => (
        is => 'rw',
        coerce => 1,
        isa => VideoPlayer,
    );

Role type, argument needs to implement L<WWW::Sitemap::XML::Google::Video::Player::Interface>.

Coerces from C<HashRef> by creating L<WWW::Sitemap::XML::Google::Video::Player> object.

Coerces from C<Str> by creating L<WWW::Sitemap::XML::Google::Video::Player>
object, where the string is used as L<WWW::Sitemap::XML::Google::Video::Player/"loc">.

=cut

no Moose::Util::TypeConstraints;

1;

