use strict;
use warnings;
use Filesys::Notify::Simple;
use Text::Hatena;
use Text::MicroTemplate qw/render_mt encoded_string/;
use File::Basename;
use File::stat;
use POSIX;
use DateTime;
use Path::Class qw/dir/;

my $render_entryingPerChild = 1000;
my $inputdir = '/Users/tokuhirom/share/howm/articles/';
my $outputdir = '/tmp/yoyo';
my $entry_tmpl = <<'...';
? my ($title, $body, $lastmodified) = @_;
<!doctype html>
<html>
<head>
    <title><?= $title ?> - tokuhirom's memo</title>
</head>
<body>
    <h1><?= $title ?> - tokuhirom's memo</h1>
    <?= $body ?>
    <div class="lastmodified">Last Modified: <?= $lastmodified ?></div>
</body>
</html>
...
my $index_tmpl = <<'...';
? my ($entries, $lastmodified) = @_;
<!doctype html>
<html>
<head>
    <title>tokuhirom's memo</title>
</head>
<body>
    <h1>tokuhirom's memo</h1>
    <ul>
? for my $entry (@$entries) {
        <li><a href="<?= $entry->{fname} ?>"><?= $entry->{title} ?>(<?= $entry->{mtime}->strftime('%Y-%m-%d(%a) %H:%M:%S') ?>)</a></li>
? }
    </ul>
    <div class="lastmodified">Last Modified: <?= $lastmodified ?></div>
</body>
</html>
...
my $map = {};

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
            }
        });
    }
}

sub first {
    for my $fname (dir($inputdir)->children) {
        render_entry($fname);
    }
    render_index();
}

sub render_entry {
    my $file = shift;
    my $basename = basename($file);
    return if $basename =~ /^[.]/;

    print "rendering $file\n";

    open my $fh, '<:utf8', $file or die "Can't open file($file) : $!";
    my $title = <$fh>;
    my $bodysrc = do { local $/; <$fh> };
    close $fh;

    $title =~ s/^\*\s*//;
    my $body = Text::Hatena->parse($bodysrc);
    my $mtime = DateTime->from_epoch(epoch => stat($file)->mtime);
    my $html = render_mt($entry_tmpl, $title, encoded_string($body), $mtime->strftime('%Y-%m-%d(%a) %H:%M:%S'))->as_string;
    (my $obasename = $basename) =~ s/\.[^.]+$/.html/;
    my $ofilename = "$outputdir/$obasename";
    write_file($html => $ofilename);

    $map->{$obasename} = {mtime => $mtime, title => $title};
}

sub render_index {
    my @files;
    while (my ($file, $attr) = each %$map) {
        push @files, {fname => $file, %$attr};
    }
    @files = sort { $a->{mtime} <=> $b->{mtime} } @files;

    my $html = render_mt($index_tmpl, \@files, DateTime->now->strftime('%Y-%m-%d(%a) %H:%M:%S'));
    write_file($html => "$outputdir/index.html");
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

