? my ($entries, $lastmodified) = @_;
? extends 'base.html';

? block content => sub {
        <h2 class="title">list of memo</h2>
        <ul>
? for my $entry (@$entries) {
            <li><a href="<?= $entry->{fname} ?>"><?= $entry->{title} ?>(<?= $entry->{mtime}->strftime('%Y-%m-%d(%a) %H:%M:%S') ?>)</a></li>
? }
        </ul>
        <div class="updated">Last Modified: <?= $lastmodified ?></div>
? }
