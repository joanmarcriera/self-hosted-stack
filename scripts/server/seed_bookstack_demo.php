<?php

declare(strict_types=1);

use BookStack\Entities\Models\Book;
use BookStack\Entities\Models\Bookshelf;
use BookStack\Entities\Models\Page;
use BookStack\Entities\Repos\BookRepo;
use BookStack\Entities\Repos\BookshelfRepo;
use BookStack\Entities\Repos\PageRepo;
use BookStack\Users\Models\User;
use Illuminate\Contracts\Console\Kernel;
use Illuminate\Support\Facades\Auth;

require '/app/www/vendor/autoload.php';

$app = require '/app/www/bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();

$ownerEmail = getenv('DEMO_OWNER_EMAIL') ?: '';
$baseDomain = getenv('DEMO_BASE_DOMAIN') ?: 'example.com';

if ($ownerEmail === '') {
    fwrite(STDERR, "missing DEMO_OWNER_EMAIL\n");
    exit(1);
}

$owner = User::query()->where('email', $ownerEmail)->first();

if (!$owner) {
    fwrite(STDERR, "unable to find BookStack owner user for {$ownerEmail}\n");
    exit(1);
}

Auth::shouldUse('web');
Auth::setUser($owner);

$bookRepo = app(BookRepo::class);
$shelfRepo = app(BookshelfRepo::class);
$pageRepo = app(PageRepo::class);

$shelfName = 'Demo Clients';
$bookName = 'Acme Bakery Automation';
$bookDescription = implode("\n", [
    'Demo client space for the three-person automation consultancy walkthrough.',
    "CRM: https://crm.{$baseDomain}",
    "Tasks: https://tasks.{$baseDomain}",
    "Status: https://status.{$baseDomain}/d/stack-overview/stack-overview",
]);

$book = Book::query()->where('name', $bookName)->first();
$bookAction = 'updated';

if (!$book) {
    $book = $bookRepo->create([
        'name' => $bookName,
        'description' => $bookDescription,
    ]);
    $bookAction = 'created';
} else {
    $bookRepo->update($book, [
        'name' => $bookName,
        'description' => $bookDescription,
    ]);
}

$shelf = Bookshelf::query()->where('name', $shelfName)->first();
$shelfAction = 'updated';

if (!$shelf) {
    $shelf = $shelfRepo->create([
        'name' => $shelfName,
        'description' => 'Seeded demo shelf for the SME automation stack.',
    ], [$book->id]);
    $shelfAction = 'created';
} else {
    $bookIds = $shelf->books()->pluck('id')->all();
    if (!in_array($book->id, $bookIds, true)) {
        $bookIds[] = $book->id;
    }
    $shelfRepo->update($shelf, [
        'name' => $shelfName,
        'description' => 'Seeded demo shelf for the SME automation stack.',
    ], $bookIds);
}

$pageSpecs = [
    [
        'title' => 'Discovery Brief',
        'html' => <<<HTML
<h1>Discovery Brief</h1>
<p><strong>Client:</strong> Acme Bakery</p>
<p><strong>Goal:</strong> Reduce lead-response time, standardize onboarding, and make weekly KPI reporting automatic.</p>
<ul>
  <li>Joan Marc owns commercial discovery in EspoCRM.</li>
  <li>Alex owns the n8n implementation and technical validation.</li>
  <li>Marta owns kickoff logistics, data collection, and follow-up.</li>
</ul>
<p>Linked systems for this demo:</p>
<ul>
  <li><a href="https://crm.{$baseDomain}">EspoCRM</a></li>
  <li><a href="https://tasks.{$baseDomain}">Vikunja</a></li>
  <li><a href="https://status.{$baseDomain}/d/stack-overview/stack-overview">Grafana status dashboard</a></li>
</ul>
HTML,
    ],
    [
        'title' => 'Implementation Runbook',
        'html' => <<<HTML
<h1>Implementation Runbook</h1>
<ol>
  <li>Capture the lead in EspoCRM with company, contact, and deal stage.</li>
  <li>Create delivery tasks in Vikunja for discovery, build, and handover.</li>
  <li>Import or adapt the n8n example workflows for intake, Gmail, and KPI summaries.</li>
  <li>Track service health, TLS posture, and later funnel telemetry in Grafana.</li>
  <li>Document decisions and handover steps in BookStack.</li>
</ol>
<p>Demo scope:</p>
<ul>
  <li>Lead intake to Telegram/Gmail follow-up</li>
  <li>Weekly KPI digest</li>
  <li>Client onboarding checklist</li>
</ul>
HTML,
    ],
    [
        'title' => 'Weekly KPI Handover',
        'html' => <<<HTML
<h1>Weekly KPI Handover</h1>
<p>This page represents the client-facing handover note the team would update every Friday.</p>
<table>
  <thead>
    <tr><th>Metric</th><th>Example value</th><th>Source</th></tr>
  </thead>
  <tbody>
    <tr><td>New leads captured</td><td>14</td><td>EspoCRM</td></tr>
    <tr><td>Lead-response median</td><td>11 minutes</td><td>n8n / Gmail</td></tr>
    <tr><td>Open onboarding tasks</td><td>5</td><td>Vikunja</td></tr>
    <tr><td>Service availability</td><td>100%</td><td>Grafana</td></tr>
  </tbody>
</table>
<p>Next action: Marta confirms client approvals, Alex schedules the next workflow revision, Joan Marc reviews upsell opportunities in CRM.</p>
HTML,
    ],
];

$pageResults = [];

foreach ($pageSpecs as $spec) {
    $page = Page::query()
        ->where('book_id', $book->id)
        ->where('name', $spec['title'])
        ->first();

    if ($page) {
        $pageRepo->update($page, [
            'name' => $spec['title'],
            'html' => $spec['html'],
            'editor' => 'wysiwyg',
            'summary' => 'Refresh seeded demo content',
        ]);
        $pageResults[] = "{$spec['title']}:updated";
        continue;
    }

    $draft = $pageRepo->getNewDraftPage($book);
    $pageRepo->publishDraft($draft, [
        'name' => $spec['title'],
        'html' => $spec['html'],
        'editor' => 'wysiwyg',
        'summary' => 'Seed demo content',
    ]);
    $pageResults[] = "{$spec['title']}:created";
}

printf(
    "bookstack shelf=%s:%s book=%s:%s pages=%s\n",
    $shelfName,
    $shelfAction,
    $bookName,
    $bookAction,
    implode(',', $pageResults),
);
