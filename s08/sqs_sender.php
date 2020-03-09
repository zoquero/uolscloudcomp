<?php
#
# Ejemplo de envío de mensaje a una cola SQS
# angel.galindo@uols.org 20200309
#
require 'vendor/autoload.php';
use Aws\Sqs\SqsClient;

$queueUrl = "https://sqs.us-east-1.amazonaws.com/707028815336/uols-test-queue";
$msg = 'Probando SQS en UOLS';

$client = SqsClient::factory(array(
    'profile' => 'default',
    'version' => 'latest',
    'region'  => 'us-east-1'
));

echo "Enviamos un mensaje a la cola $queueUrl: ... ";
$client->sendMessage(array(
    'QueueUrl'    => $queueUrl,
    'MessageBody' => $msg,
));
echo " enviado!\n";
?>
