#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use Carp;
use File::Find;
use File::Copy;

sub pm_file {
    my $file = $_;
    return unless (( -f $file ) && ( $file =~ /\.pm$/ ));

    print STDERR "Fixing $file\n";

    open( my $fh, '<', $file ) or croak "Could not open $file: $!";
    my $contents = do { local $/; <$fh>; };

    my $delete_backup = 1;
    my $backup_ext = '.bak';
    my $backup_file = $file . $backup_ext;
    copy( $file, $backup_file ) or croak "Could not copy $file to $backup_file: $!";

    my $license = <<'LICENSE';
Copyright 2011 Brian Sorahan.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as
published by the Free Software Foundation; or the Artistic License.
LICENSE

    my %fields =
        (
         AUTHOR     => 'Brian Sorahan, C<< <bsorahan@gmail.com> >>',
         SUPPORT    => 'Join the Google group: <http://groups.google.com/group/www-echonest>',
         THANKS     => 'Everyone at The Echo Nest <http://the.echonest.com>',
         LICENSE    => $license,
        );

    for my $field (keys %fields) {
        my $value = $fields{$field};
        $contents =~ s[=head1 $field(.*?)=head1]
                      [=head1 $field\n\n$value\n\n=head1]ms;
    }

    open( my $out, '>', $file );
    print { $out } $contents;

    unlink $backup_file if $delete_backup;
    close $fh;
    close $out;
}

find ( \&pm_file, '.' );
