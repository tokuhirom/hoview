use strict;
use warnings;
use Filesys::Notify::Simple;
use Text::Hatena;
use Text::MicroTemplate qw/render_mt encoded_string/;
use File::Basename;
use File::stat;
use POSIX;
use Time::Piece;
use Path::Class qw/dir/;

my $render_entryingPerChild = 1000;
my $inputdir = '/home/tokuhirom/dev/gp.ath.cx/data/';
my $outputdir = '/usr/local/webapp/gp.ath.cx/public/memo/';
my $entry_tmpl = <<'...';
? my ($title, $body, $lastmodified) = @_;
<!doctype html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title><?= $title ?> - tokuhirom's memo</title>
    <meta http-equiv="Content-Style-Type" content="text/css" />  
    <meta http-equiv="Content-Script-Type" content="text/javascript" />  
    <link href="/static/css/reset.css" rel="stylesheet" type="text/css" />
    <link href="/static/css/gpath.css" rel="stylesheet" type="text/css" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.2.6/jquery.min.js" type="text/javascript"></script>
    <script>
        $(function () {
            $("#menuContainer").load("/memo/menu.html");
        });
    </script>
</head>
<body>
    <div id="container">
        <div id="bodyContainer">
            <h1 class="entry-title"><?= $title ?></h1>
            <div class="entry-content"><?= $body ?></div>
            <div class="updated">Last Modified: <?= $lastmodified ?></div>
        </div>
        <div id="menuContainer">
            now loading
        </div>
    </div>
</body>
</html>
...
my $index_tmpl = <<'...';
? my ($entries, $lastmodified) = @_;
<!doctype html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>tokuhirom's memo</title>
    <meta http-equiv="Content-Style-Type" content="text/css" />  
    <meta http-equiv="Content-Script-Type" content="text/javascript" />  
    <link href="/static/css/reset.css" rel="stylesheet" type="text/css" />
    <link href="/static/css/gpath.css" rel="stylesheet" type="text/css" />
</head>
<body class="Index">
    <div id="container">
        <div id="bodyContainer">
        <h1>tokuhirom's memo</h1>
        <ul>
? for my $entry (@$entries) {
            <li><a href="<?= $entry->{fname} ?>"><?= $entry->{title} ?>(<?= $entry->{mtime}->strftime('%Y-%m-%d(%a) %H:%M:%S') ?>)</a></li>
? }
        </ul>
        <div class="updated">Last Modified: <?= $lastmodified ?></div>
        </div>
    </div>
</body>
</html>
...
my $menu_tmpl = <<'...';
? my ($entries, $lastmodified) = @_;
<!doctype html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>tokuhirom's memo</title>
    <meta http-equiv="Content-Style-Type" content="text/css" />  
    <meta http-equiv="Content-Script-Type" content="text/javascript" />  
</head>
<body>
    <h3>entry list</h3>
    <ul>
? for my $entry (@$entries) {
        <li><a href="<?= $entry->{fname} ?>"><?= $entry->{title} ?>(<?= $entry->{mtime}->strftime('%Y-%m-%d') ?>)</a></li>
? }
    </ul>
    <h3>link</h3>
    <ul>
        <li><a href="http://gp.ath.cx/">gpath</a></li>
    </ul>
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
        my $html = render_mt($entry_tmpl, $title, encoded_string($body), $mtime->strftime('%Y-%m-%d(%a) %H:%M:%S'))->as_string;
        (my $obasename = $basename) =~ s/\.[^.]+$/.html/;
        my $ofilename = "$outputdir/$obasename";
        write_file($html => $ofilename);

        $map->{$obasename} = {mtime => $mtime, title => $title};
    };
    warn "Cannot rendering $file: $@\n" if $@;
}

sub render_index {
    my @files;
    while (my ($file, $attr) = each %$map) {
        push @files, {fname => $file, %$attr};
    }
    @files = reverse sort { $a->{mtime} <=> $b->{mtime} } @files;

    my $html = render_mt($index_tmpl, \@files, Time::Piece->new->strftime('%Y-%m-%d(%a) %H:%M:%S'));
    write_file($html => "$outputdir/index.html");
}
sub render_menu {
    my @files;
    while (my ($file, $attr) = each %$map) {
        push @files, {fname => $file, %$attr};
    }
    @files = reverse sort { $a->{mtime} <=> $b->{mtime} } @files;

    my $html = render_mt($menu_tmpl, \@files, Time::Piece->new->strftime('%Y-%m-%d(%a) %H:%M:%S'));
    write_file($html => "$outputdir/menu.html");
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

