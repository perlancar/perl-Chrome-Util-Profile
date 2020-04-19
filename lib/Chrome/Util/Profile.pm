package Chrome::Util::Profile;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

use File::chdir;

use Exporter 'import';
our @EXPORT_OK = qw(list_chrome_profiles);

our %SPEC;

$SPEC{list_chrome_profiles} = {
    v => 1.1,
    summary => 'List available Google Chrome profiles',
    description => <<'_',

This utility will search for profile directories under ~/.config/google-chrome/.

_
    args => {
        detail => {
            schema => 'bool',
            cmdline_aliases => {l=>{}},
        },
    },
};
sub list_chrome_profiles {
    require File::Slurper;
    require JSON::MaybeXS;
    require Sort::Sub;

    my %args = @_;

    my $gc_dir     = "$ENV{HOME}/.config/google-chrome";
    unless (-d $gc_dir) {
        return [412, "Cannot find google chrome directory $gc_dir"];
    }

    my @rows;
    my $resmeta = {};
    local $CWD = $gc_dir;
  DIR:
    for my $dir (glob "*") {
        next unless -d $dir;
        my $prefs_path = "$dir/Preferences";
        next unless -f $prefs_path;
        my $prefs = JSON::MaybeXS::decode_json(
            File::Slurper::read_binary $prefs_path);
        my $profile_name = $prefs->{profile}{name};
        defined $profile_name && length $profile_name or do {
            log_warn "Profile in $prefs_path does not have profile/name, skipped";
            next DIR;
        };
        push @rows, {
            path => "$gc_dir/$prefs_path",
            dir  => $dir,
            name => $profile_name,
        };
        $resmeta->{'func.raw_prefs'}{$profile_name} = $prefs;
    }

    [200, "OK", \@rows, $resmeta];
}

1;
# ABSTRACT:

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 SEE ALSO

Other C<Chrome::Util::*> modules.

L<Firefox::Util::Profile>

L<Vivaldi::Util::Profile>

L<Opera::Util::Profile>

=cut
