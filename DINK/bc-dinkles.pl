#!/bin/perl

# A more direct attempt at creating maps for Dink D-Mods

require "/usr/local/lib/bclib.pl";

my(%dinksprites) = read_dink_ini();

# TODO: allow map.dat to be in different dir
# how many screens?
my($ns) = int((-s "map.dat")/31280);
open(A,"map.dat")||die;
my($buf);

read(A,$buf,31820);
dink_sprite_data($buf);

die "TESTING";

for $i (0..$ns-1) {
  debug("SCREEN $i");
  seek(A,31280*$i,SEEK_SET);
  read(A,$buf,31820);
  dink_render_screen($buf,"/tmp/final$i.png");
}

# Given the 31820 byte chunk representing a screen, attempt to recreate screen in given filename

sub dink_render_screen {
  my($data,$file) = @_;

  # TODO: this is probably a bad idea
  if (-f $file) {return;}

  # need better output convention
  local(*A);
  open(A,"|montage \@- -tile 12x8 -geometry +0+0 $file");

  # the tiles
  for $y (1..8) {
    for $x (1..12) {
      $data=~s/^.{20}(.)(.)(.{58})//s;
      # tile number and screen number (wraparound if $t>=128)
      my($t,$s) = (ord($1),2*ord($2)+1);
      if ($t>=128) {$s++; $t=-128;}
      # top left pixel
      my($px,$py) = ($t%12*50,int($t/12)*50);
      # TODO: fix ts*.bmp case oddnesses
      # TODO: look for tiles in game itself, not just stdloc
      # create if not already existing
      unless (-f "/var/cache/DINK/tile-$s-$px-$py.png") {
	my($fname) = sprintf("/usr/share/dink/dink/Tiles/Ts%02d.bmp",$s);
	unless (-f $fname) {die "NO SUCH FILE: $fname";}
	my($out,$err,$res) = cache_command2("convert -crop 50x50+$px+$py $fname /var/cache/DINK/tile-$s-$px-$py.png");
      }
      print A "/var/cache/DINK/tile-$s-$px-$py.png\n";
    }
    close(A);
  }
}

# determine sprite data (but do nothing w/ it for now), given screen

sub dink_sprite_data {
  my($data) = @_;
  # sprite data starts at 8020, but first sprite is always blank
  $data=~s/^.{8240}//;

  while ($data=~s/^(.{220})//) {
    my($sprite) = $1;
    my(@sprite);
    debug("SPR: $sprite");
    while ($sprite=~s/^(....)//) {push(@sprite,unpack("i4",$1));}
    # xpos = 4 char, ypos = 4 char, seq = 4 char, frame = 4 char, type/size?
    my($xpos, $ypos, $seq, $frame, $type, $size) = @sprite;
    my($fname) = "/usr/local/etc/DINK/BMP/$dinksprites{$seq}";

    # see if sprite exists where I uncompressed all sprites
    debug("SPRITES",glob("$fname*"));
  }
}

# reads the standard Dink.ini file (not mod-specific), returns a
# number-to-sprite-hash

sub read_dink_ini {
  my(%result);
  my(@lines) = `fgrep load_sequence /usr/share/dink/dink/Dink.ini`;

  for $i (@lines) {
    $i=~/^.*\\(.*?)\s+(\d+)/;
    $result{$2} = uc($1);
  }
  return %result;
}

