use strict;
use warnings;

package Imager::PlaceHold;

use Imager;
use Moo;
use File::Find;
use File::Spec;
use Scalar::Util qw(looks_like_number);

has font_file => (
    is      => 'ro',
    default => sub {
        my $font;
        my @paths = File::Spec->catfile('/','usr','share','fonts');
        find( sub { $font = $File::Find::name if $_ eq 'DejaVuSans-Bold.ttf' }, @paths);
        die "font not found." if not $font;
        return $font;
    }
);

has font_color => (
    is      => 'ro',
    default => '#969696'
);

has background_color => (
    is      => 'ro',
    default => '#cccccc'
);

has x_size => (
    is       => 'ro',
    required => 1,
);

has y_size => (
    is       => 'ro',
    required => 1
);

has text => ( is => 'lazy', );

has text_x_perc_size => (
    is      => 'ro',
    isa     => sub {
        die "$_[0] is not a number!" unless looks_like_number $_[0];
        die "$_[0] is not greater than 0 and less or equal to 1!" unless $_[0] > 0 && $_[0] <= 1;
    },
    default => 0.5
);

has text_y_perc_size => (
    is      => 'ro',
    isa     => sub {
        die "$_[0] is not a number!" unless looks_like_number $_[0];
        die "$_[0] is not 0 < text_y_perc_size <= 1!" unless $_[0] > 0 && $_[0] <= 1;
    },
    default => 0.5
);

has font => ( is => 'lazy' );

has image => ( is => 'lazy' );

#sub BUILDARGS {
#    my ($class, %args) = @_;
#
#    use DDP;
#    p %args;
#    return { %args };
#}

sub _build_text {
    my ($self) = @_;

    return $self->x_size . ' x ' . $self->y_size;
}

sub _build_font {
    my ($self) = @_;

    return Imager::Font->new(
        file  => $self->font_file,
        color => $self->font_color,
        aa    => 1
    );
}

sub _build_image {
    my ($self) = @_;

    my $img = Imager->new(
        xsize    => $self->x_size,
        ysize    => $self->y_size,
        channels => 4,
        debug    => 0
    );
    $img->box( filled => 1, color => $self->background_color );
    return $img;
}
use DDP;

sub image_with_string {
    my ($self) = @_;

    my $text_x_size = int $self->x_size * $self->text_x_perc_size;
    my $text_y_size = int $self->y_size * $self->text_y_perc_size;

    my ( $neg_width, $global_descent, $descent,
        $ascent, $advance_width, $right_bearing );

    my $pos_width     = 0;
    my $global_ascent = 0;

    my $text_size = 1;
    while ( $text_x_size > $pos_width && $text_y_size > $global_ascent ) {
        (
            $neg_width, $global_descent, $pos_width, $global_ascent, $descent,
            $ascent, $advance_width, $right_bearing
          )
          = $self->font->bounding_box(
            string => $self->text,
            canon  => 1,
            size   => $text_size++
          );
        if ( ! ($text_x_size > $pos_width && $text_y_size > $global_ascent) ) {
            $text_size = $text_size - 2;
        (
            $neg_width, $global_descent, $pos_width, $global_ascent, $descent,
            $ascent, $advance_width, $right_bearing
          )
          = $self->font->bounding_box(
            string => $self->text,
            canon  => 1,
            size   => $text_size
          );
            last;
        }
    }

    my $font_x_size = int( $self->x_size - $pos_width ) / 2;
    my $font_y_size = int( $self->y_size / 2 ) + ( $global_ascent / 4 );

    $self->image->string(
        string => $self->text,
        font   => $self->font,
        x      => $font_x_size,
        y      => $font_y_size,
        size   => $text_size
    );
    $self->image->write( file => "test.png", type => 'png' );

}

1;
