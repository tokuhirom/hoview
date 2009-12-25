? my @entries = @_;
? use HTTP::Date;
<?= encoded_string qq[<\?xml version="1.0" encoding="utf-8"?\>] ?>
<rss version="2.0"
     xmlns:dc="http://purl.org/dc/elements/1.1/"
     xmlns:content="http://purl.org/rss/1.0/modules/content/"
     xml:lang="ja">
  <channel>
    <title>64p.org memo</title>
    <link>http://64p.org/memo/</link>
    <description>my own memo</description>
? for my $entry (@entries) {
    <item>
      <title><?= $entry->{title} ?></title>
      <link>http://64p.org/memo/<?= $entry->{fname} ?></link>
      <description><![CDATA[<?= encoded_string $entry->{body} ?>]]></description>
      <dc:creator>tokuhirom</dc:creator>
      <pubDate><?= HTTP::Date::time2str($entry->{mtime}->epoch) ?></pubDate>
    </item>
? }
  </channel>
</rss>
