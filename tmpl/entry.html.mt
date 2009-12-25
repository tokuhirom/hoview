? my ($title, $body, $lastmodified, $permalink) = @_;
? extends 'base.html';

? block title => sub { "$title - " };

? block content => sub {
    <h2 class="entry-title title"><?= $title ?></h2>
    <div class="entry-content"><?= $body ?></div>
    <div class="updated">Last Modified: <?= $lastmodified ?></div>
    <div class="bookmark"><a href="<?= $permalink ?>" rel="bookmark">permalink</a><img src="http://b.hatena.ne.jp/entry/image/<?= $permalink ?>"></div>
? }
