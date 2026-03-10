<?php

declare(strict_types=1);

use Espo\Core\Application;
use Espo\ORM\Entity;
use Espo\ORM\EntityManager;
use Espo\ORM\Repository\RDBRepository;

require_once '/var/www/html/bootstrap.php';

$ownerEmail = getenv('DEMO_OWNER_EMAIL') ?: '';
$baseDomain = getenv('DEMO_BASE_DOMAIN') ?: 'example.com';

if ($ownerEmail === '') {
    fwrite(STDERR, "missing DEMO_OWNER_EMAIL\n");
    exit(1);
}

$application = new Application();
$application->setupSystemUser();
$entityManager = $application->getContainer()->getByClass(EntityManager::class);

/**
 * @return RDBRepository<Entity>
 */
function repo(EntityManager $entityManager, string $entityType): RDBRepository
{
    return $entityManager->getRDBRepository($entityType);
}

function findOneBy(EntityManager $entityManager, string $entityType, array $where): ?Entity
{
    return repo($entityManager, $entityType)->where($where)->findOne();
}

function upsertEntity(EntityManager $entityManager, string $entityType, array $lookup, array $data): array
{
    $entity = findOneBy($entityManager, $entityType, $lookup);

    if ($entity) {
        $entity->set($data);
        $entityManager->saveEntity($entity);
        return [$entity, 'updated'];
    }

    return [$entityManager->createEntity($entityType, $data), 'created'];
}

$founder = findOneBy($entityManager, 'User', ['emailAddress' => $ownerEmail])
    ?: findOneBy($entityManager, 'User', ['userName' => 'akadmin'])
    ?: findOneBy($entityManager, 'User', ['userName' => 'admin']);

if (!$founder) {
    fwrite(STDERR, "unable to find EspoCRM founder user for {$ownerEmail}\n");
    exit(1);
}

$alex = findOneBy($entityManager, 'User', ['userName' => 'alex']);
$marta = findOneBy($entityManager, 'User', ['userName' => 'marta']);

$crmRecords = [
    [
        'account' => [
            'name' => 'Acme Bakery',
            'website' => 'https://acme-bakery.example',
            'type' => 'Customer',
            'description' => "Retail bakery automation demo.\nStack links: docs.{$baseDomain}, tasks.{$baseDomain}, status.{$baseDomain}/d/stack-overview/stack-overview",
            'assignedUserId' => $marta?->getId() ?? $founder->getId(),
        ],
        'contact' => [
            'firstName' => 'Nora',
            'lastName' => 'Patel',
            'title' => 'Operations Manager',
            'emailAddress' => 'nora.patel@acme-bakery.example',
            'description' => 'Primary demo client contact for onboarding and weekly KPI review.',
            'assignedUserId' => $marta?->getId() ?? $founder->getId(),
        ],
        'opportunity' => [
            'name' => 'Acme Bakery onboarding automation',
            'amount' => 4800,
            'stage' => 'Proposal',
            'probability' => 50,
            'closeDate' => gmdate('Y-m-d', strtotime('+21 days')),
            'description' => 'Lead intake, Gmail follow-up, onboarding checklist, and weekly KPI summary.',
            'assignedUserId' => $founder->getId(),
        ],
    ],
    [
        'account' => [
            'name' => 'Blue Harbor Legal',
            'website' => 'https://blue-harbor-legal.example',
            'type' => 'Customer',
            'description' => 'Legal-services intake triage demo with CRM-driven follow-up and handover notes.',
            'assignedUserId' => $founder->getId(),
        ],
        'contact' => [
            'firstName' => 'Daniel',
            'lastName' => 'Ross',
            'title' => 'Managing Partner',
            'emailAddress' => 'daniel.ross@blue-harbor-legal.example',
            'description' => 'Decision maker for the legal intake automation demo.',
            'assignedUserId' => $founder->getId(),
        ],
        'opportunity' => [
            'name' => 'Blue Harbor intake triage',
            'amount' => 7200,
            'stage' => 'Negotiation',
            'probability' => 80,
            'closeDate' => gmdate('Y-m-d', strtotime('+14 days')),
            'description' => 'Matter-intake routing, consult scheduling, and proposal follow-up.',
            'assignedUserId' => $alex?->getId() ?? $founder->getId(),
        ],
    ],
];

$results = [];

foreach ($crmRecords as $record) {
    [$account, $accountAction] = upsertEntity(
        $entityManager,
        'Account',
        ['name' => $record['account']['name']],
        $record['account'],
    );

    $contactData = $record['contact'] + [
        'accountId' => $account->getId(),
        'accountName' => $account->get('name'),
    ];

    [$contact, $contactAction] = upsertEntity(
        $entityManager,
        'Contact',
        ['emailAddress' => $record['contact']['emailAddress']],
        $contactData,
    );

    $opportunityData = $record['opportunity'] + [
        'accountId' => $account->getId(),
        'accountName' => $account->get('name'),
        'contactId' => $contact->getId(),
        'contactName' => trim(($contact->get('firstName') ?? '') . ' ' . ($contact->get('lastName') ?? '')),
    ];

    [$opportunity, $opportunityAction] = upsertEntity(
        $entityManager,
        'Opportunity',
        ['name' => $record['opportunity']['name']],
        $opportunityData,
    );

    $results[] = implode(':', [
        $account->get('name'),
        $accountAction,
        $contact->get('emailAddress'),
        $contactAction,
        $opportunity->get('name'),
        $opportunityAction,
    ]);
}

printf("espocrm %s\n", implode(',', $results));
