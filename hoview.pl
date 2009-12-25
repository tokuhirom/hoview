use strict;
use warnings;
use Filesys::Notify::Simple;
use Text::Hatena;
use Text::MicroTemplate qw/render_mt encoded_string/;
use Text::MicroTemplate::Extended;
use File::Basename;
use File::stat;
use POSIX;
use Time::Piece;
use Path::Class qw/dir/;
use XML::RSS::LibXML;
use File::Spec;

my $basedir = File::Spec->rel2abs(dirname(__FILE__));
my $mt = Text::MicroTemplate::Extended->new(
    include_path => "$basedir/tmpl",
    template_args => {
        rss_url => "http://feeds.feedburner.com/64porgMemo",
    },
);
my $render_entryingPerChild = 1000;
my $AUTHOR = 'tokuhirom';
my $inputdir = '/home/tokuhirom/dev/gp.ath.cx/data/';
my $outputdir = '/usr/local/webapp/gp.ath.cx/public/memo/';
my $map = {};

print "start hoview\n";
&main;exit;

# -------------------------------------------------------------------------

sub main {
    first();

    my $watcher = Filesys::Notify::Simple->new([$inputdir]);
    for (1..$render_entryingPerChild) {
        $watcher->wait(sub {
            for my $e (@_) {
                my $path = $e->{path};
                next if $path =~ /\.sw[pon]$/;
                render_entry($path);
                render_index();
                render_menu();
            }
        });
    }
}

sub first {
    for my $fname (dir($inputdir)->children) {
        render_entry($fname);
    }
    render_index();
    render_menu();
    render_rss();
}

sub render_entry {
    my $file = shift;
    my $basename = basename($file);
    return if $basename =~ /^[.]/;
    print "rendering $file\n";

    eval {
        open my $fh, '<:utf8', $file or die "Can't open file($file) : $!";
        my $title = <$fh>;
        my $bodysrc = do { local $/; <$fh> };
        close $fh;

        $title =~ s/^\*\s*//;
        my $body = Text::Hatena->parse($bodysrc);
        my $mtime = Time::Piece->new(stat($file)->mtime);
        my $html = $mt->render('entry.html', $title, encoded_string($body), $mtime->strftime('%Y-%m-%d(%a) %H:%M:%S'));
        (my $obasename = $basename) =~ s/\.[^.]+$/.html/;
        my $ofilename = "$outputdir/$obasename";
        write_file($html => $ofilename);

        $map->{$obasename} = {mtime => $mtime, title => $title, body => $body, bodysrc => $bodysrc};
    };
    warn "Cannot rendering $file: $@\n" if $@;
}

sub render_index {
    my @files;
    while (my ($file, $attr) = each %$map) {
        push @files, {fname => $file, %$attr};
    }
    @files = reverse sort { $a->{mtime} <=> $b->{mtime} } @files;

    my $html = $mt->render('index.html', \@files, Time::Piece->new->strftime('%Y-%m-%d(%a) %H:%M:%S'));
    write_file($html => "$outputdir/index.html");
}
sub render_menu {
    my @files;
    while (my ($file, $attr) = each %$map) {
        push @files, {fname => $file, %$attr};
    }
    @files = reverse sort { $a->{mtime} <=> $b->{mtime} } @files;

    my $html = $mt->render('menu.html', \@files, Time::Piece->new->strftime('%Y-%m-%d(%a) %H:%M:%S'));
    write_file($html => "$outputdir/menu.html");
}

sub render_rss {
    my @files;
    while (my ($file, $attr) = each %$map) {
        push @files, {fname => $file, %$attr};
    }
    @files = reverse sort { $a->{mtime} <=> $b->{mtime} } @files;
    @files = @files[0..15];
    my $html = $mt->render('index.rss', @files);
    write_file($html, "$outputdir/index.rss");
}

sub write_file {
    my ($txt, $dst) = @_;
    print "- write to $dst\n";
    open my $fh, ">:utf8", $dst or die "Can't open file($dst): $!";
    print $fh $txt;
    close $fh;
}

__END__

daemontools でうごかす前提。

一定回数処理したら、死ぬがよい。

