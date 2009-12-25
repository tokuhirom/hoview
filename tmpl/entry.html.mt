? my ($title, $body, $lastmodified) = @_;
? extends 'base.html';

? block title => sub { "$title - " };

? block content => sub {
    <h2 class="entry-title title"><?= $title ?></h2>
    <div class="entry-content"><?= $body ?></div>
    <div class="updated">Last Modified: <?= $lastmodified ?></div>
? }
