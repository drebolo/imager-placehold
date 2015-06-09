use strict;
use warnings;

package Imager::PlaceHold;

use Imager;
use Moo;

has font_file => (
    is      => 'ro',
    default => "/usr/share/fonts/truetype/msttcorefonts/Arial_Bold.ttf"
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
    default => 0.5
);

has text_y_perc_size => (
    is      => 'ro',
    default => 0.5
);

has font => ( is => 'lazy' );

has image => ( is => 'lazy' );


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
        debug    => 1
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
my @a = (
            $neg_width, $global_descent, $pos_width, $global_ascent, $descent,
            $ascent, $advance_width, $right_bearing
          );
p @a;
        if ( $text_x_size > $pos_width && $text_y_size > $global_ascent ) {
#            $pos_width = $local_pos_width;
#            $global_ascent = $local_global_ascent;
        }
        else {
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
