<?php

declare(strict_types=1);

use Espo\Core\Application;
use Espo\Core\Utils\Util;
use Espo\ORM\Entity;
use Espo\ORM\EntityManager;
use Espo\ORM\Repository\RDBRepository;

require_once '/var/www/html/bootstrap.php';

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

$leadCaptureName = getenv('COMMERCIAL_LEAD_CAPTURE_NAME') ?: 'Automation Audit Intake';
$targetTeamId = getenv('COMMERCIAL_TARGET_TEAM_ID') ?: '';

if ($targetTeamId === '') {
    fwrite(STDERR, "missing COMMERCIAL_TARGET_TEAM_ID\n");
    exit(1);
}

$application = new Application();
$application->setupSystemUser();
$entityManager = $application->getContainer()->getByClass(EntityManager::class);

$fieldList = [
    'firstName',
    'lastName',
    'emailAddress',
    'accountName',
    'website',
    'description',
];

$leadCaptureData = [
    'name' => $leadCaptureName,
    'isActive' => true,
    'fieldList' => $fieldList,
    'duplicateCheck' => true,
    'optInConfirmation' => false,
    'leadSource' => 'Web Site',
    'targetTeamId' => $targetTeamId,
    'formEnabled' => false,
    'description' => 'Commercial intake for riera.co.uk',
];

$leadCapture = findOneBy($entityManager, 'LeadCapture', ['name' => $leadCaptureName]);
$action = 'updated';

if ($leadCapture) {
    foreach ($leadCaptureData as $field => $value) {
        $leadCapture->set($field, $value);
    }

    if (!$leadCapture->get('apiKey')) {
        $leadCapture->set('apiKey', Util::generateApiKey());
    }

    $entityManager->saveEntity($leadCapture);
} else {
    $leadCaptureData['apiKey'] = Util::generateApiKey();
    $leadCapture = $entityManager->createEntity('LeadCapture', $leadCaptureData);
    $action = 'created';
}

$apiKey = $leadCapture->get('apiKey');

if (!$apiKey) {
    fwrite(STDERR, "lead capture entity exists but has no api key\n");
    exit(1);
}

printf("ESPOCRM_LEAD_CAPTURE_NAME=%s\n", $leadCapture->get('name'));
printf("ESPOCRM_LEAD_CAPTURE_ID=%s\n", $leadCapture->getId());
printf("ESPOCRM_LEAD_CAPTURE_API_KEY=%s\n", $apiKey);
printf("ESPOCRM_LEAD_CAPTURE_ACTION=%s\n", $action);
