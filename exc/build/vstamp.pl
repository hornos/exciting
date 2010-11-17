#!/usr/bin/perl

$git_path = "../.git";

open HEADREF, "<", $git_path . "/HEAD";
while (<HEADREF>) {
  if (m/ref:\s*([\w\/]*)/) {
    $ref = $1;
  }
}
close HEADREF;


if ( -e  $git_path . "/" . $ref ) {
  open HEAD, $git_path . "/" . $ref;
  read HEAD, $hasht, 40;

  $hash1 = substr( $hasht, 0,  20 );
  $hash2 = substr( $hasht, 20, 39 );

  close HEAD;
}
else {
  open REFS , $git_path . "/packed-refs";
  while(<REFS>) {
    if(m/$ref/) {
      $hash1 = substr( $_, 0,  20 );
      $hash2 = substr( $_, 20, 20 );
    }
  }
}

open VERISIONINC, ">", "version.inc";
print VERISIONINC "\#define GITHASH \"$hash1\"\n";
print VERISIONINC "\#define GITHASH2 \"$hash2\"\n";

print VERISIONINC "\#define VERSIONFROMDATE ", `date "+/%y,%m,%d/"`
