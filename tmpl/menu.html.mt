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
<ul>
    <li><h2>entry list</h2>
        <ul>
? for my $entry (@$entries) {
            <li><a href="<?= $entry->{fname} ?>"><?= $entry->{title} ?>(<?= $entry->{mtime}->strftime('%Y-%m-%d') ?>)</a></li>
? }
        </ul>
    </li>
    <li><h2>feed</h2>
        <ul>
            <li><a href="http://feeds.feedburner.com/64porgMemo">RSS</a></li>
        </ul>
    </li>
    <li><h2>link</h2>
        <ul>
            <li><a href="http://64p.org/">gpath</a></li>
        </ul>
    </li>
</body>
</html>
