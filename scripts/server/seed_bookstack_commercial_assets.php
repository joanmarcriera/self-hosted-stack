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

$ownerEmail = getenv('COMMERCIAL_OWNER_EMAIL') ?: '';
$baseDomain = getenv('COMMERCIAL_BASE_DOMAIN') ?: 'riera.co.uk';

if ($ownerEmail === '') {
    fwrite(STDERR, "missing COMMERCIAL_OWNER_EMAIL\n");
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

$shelfName = 'Commercial Delivery';
$bookName = 'Automation Audit Templates';
$bookDescription = implode("\n", [
    'Commercial templates for the paid Automation Audit, fixed-scope sprint, and monitoring retainer.',
    "Commercial front door: https://riera.co.uk",
    "CV surface: https://cv.{$baseDomain}",
    "Demo surface: https://sme.{$baseDomain}",
    "Strategy surface: https://cxo.{$baseDomain}",
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
        'description' => 'Sales and delivery assets for the automation consultancy.',
    ], [$book->id]);
    $shelfAction = 'created';
} else {
    $bookIds = $shelf->books()->pluck('id')->all();
    if (!in_array($book->id, $bookIds, true)) {
        $bookIds[] = $book->id;
    }
    $shelfRepo->update($shelf, [
        'name' => $shelfName,
        'description' => 'Sales and delivery assets for the automation consultancy.',
    ], $bookIds);
}

$pageSpecs = [
    [
        'title' => 'Automation Audit Template',
        'html' => <<<HTML
<h1>Automation Audit Template</h1>
<p><strong>Client:</strong> [Company]</p>
<p><strong>Primary contact:</strong> [Name / role / email]</p>
<p><strong>Audit fee:</strong> &pound;750 paid upfront</p>
<p><strong>Discovery session date:</strong> [Date]</p>
<h2>1. Current operating picture</h2>
<ul>
  <li>Team size and roles</li>
  <li>Current tools in use</li>
  <li>Where data starts and where it gets retyped</li>
  <li>Where ownership is ambiguous</li>
</ul>
<h2>2. Manual work inventory</h2>
<table>
  <thead>
    <tr><th>Process</th><th>Current owner</th><th>Frequency</th><th>Estimated time lost</th><th>Observed risk</th></tr>
  </thead>
  <tbody>
    <tr><td>[Lead intake]</td><td>[Owner]</td><td>[Daily]</td><td>[5-10h]</td><td>[Slow response / lost demand]</td></tr>
    <tr><td>[Onboarding / support / monitoring]</td><td>[Owner]</td><td>[Weekly]</td><td>[x h]</td><td>[Missed handoffs / invisible failures]</td></tr>
  </tbody>
</table>
<h2>3. Top three automation opportunities</h2>
<ol>
  <li><strong>[Opportunity]</strong>: Before state, proposed future state, rough ROI, dependencies.</li>
  <li><strong>[Opportunity]</strong>: Before state, proposed future state, rough ROI, dependencies.</li>
  <li><strong>[Opportunity]</strong>: Before state, proposed future state, rough ROI, dependencies.</li>
</ol>
<h2>4. Recommendation</h2>
<p>Recommend one fixed-scope sprint that can be delivered in 7 calendar days and handed over cleanly.</p>
<h2>5. Sprint fit check</h2>
<ul>
  <li>Named process owner exists</li>
  <li>Required systems access is available</li>
  <li>Client can review within one business day</li>
  <li>Monitoring/handover path is defined</li>
</ul>
HTML,
    ],
    [
        'title' => 'Sprint Proposal Template',
        'html' => <<<HTML
<h1>Sprint Proposal Template</h1>
<p><strong>Client:</strong> [Company]</p>
<p><strong>Sprint fee:</strong> &pound;2,500</p>
<p><strong>Commercial terms:</strong> 50% upfront, 50% on delivery, one revision round, 14 days of email hypercare</p>
<h2>Scope</h2>
<p>Deliver one workflow or monitoring system in 7 calendar days.</p>
<ul>
  <li>Target process: [Lead intake / onboarding triage / monitoring]</li>
  <li>Systems touched: [CRM / n8n / BookStack / Grafana / email / forms]</li>
  <li>Named owner after handover: [Owner]</li>
</ul>
<h2>Before / after</h2>
<table>
  <thead>
    <tr><th>Before</th><th>After</th></tr>
  </thead>
  <tbody>
    <tr><td>[Manual retyping / slow response / no monitoring]</td><td>[Automated capture / explicit notifications / visible status]</td></tr>
  </tbody>
</table>
<h2>Delivery sequence</h2>
<ol>
  <li>Confirm access, data fields, and approval path.</li>
  <li>Build and test the workflow or monitor set.</li>
  <li>Document the system map and rollback notes in BookStack.</li>
  <li>Run client walkthrough and collect one revision round.</li>
  <li>Hand over the operating note and hypercare window.</li>
</ol>
<h2>Out of scope</h2>
<ul>
  <li>Broad digital transformation programmes</li>
  <li>Custom application development beyond the sprint target</li>
  <li>High-risk production hosting on the shared demo server</li>
</ul>
HTML,
    ],
    [
        'title' => 'Commercial Terms',
        'html' => <<<HTML
<h1>Commercial Terms</h1>
<ul>
  <li><strong>Automation Audit:</strong> &pound;750, paid in full before the discovery session.</li>
  <li><strong>Implementation Sprint:</strong> &pound;2,500, 50% upfront and 50% on delivery.</li>
  <li><strong>Monitoring Retainer:</strong> &pound;300/month, billed monthly in advance for up to three endpoints.</li>
  <li><strong>Delivery window:</strong> sprint work is scheduled only after access and payment clear.</li>
  <li><strong>Revision policy:</strong> one revision round is included; net-new scope becomes a new proposal.</li>
  <li><strong>Hosting:</strong> the shared demo server is not reused for high-risk client production work.</li>
</ul>
<p>Default pipeline for this offer: New lead, Qualified, Audit proposed, Audit paid, Audit delivered, Sprint proposed, Sprint won, Retainer active, Dormant.</p>
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
            'summary' => 'Refresh commercial templates',
        ]);
        $pageResults[] = "{$spec['title']}:updated";
        continue;
    }

    $draft = $pageRepo->getNewDraftPage($book);
    $pageRepo->publishDraft($draft, [
        'name' => $spec['title'],
        'html' => $spec['html'],
        'editor' => 'wysiwyg',
        'summary' => 'Seed commercial templates',
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
