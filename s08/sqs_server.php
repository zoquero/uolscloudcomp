<?php
#
# Ejemplo de lectura de un mensaje a de cola SQS
# angel.galindo@uols.org 20200309
#
require 'vendor/autoload.php';
use Aws\Sqs\SqsClient;
use Aws\Exception\AwsException;

$queueUrl = "https://sqs.us-east-1.amazonaws.com/707028815336/uols-test-queue";

$client = SqsClient::factory(array(
    'profile' => 'default',
    'version' => 'latest',
    'region'  => 'us-east-1'
));

try {
    $result = $client->receiveMessage(array(
        'AttributeNames' => ['SentTimestamp'],
        'MaxNumberOfMessages' => 1,
        'MessageAttributeNames' => ['All'],
        'QueueUrl' => $queueUrl, // REQUIRED
        'WaitTimeSeconds' => 0,
    ));
    if (!empty($result->get('Messages'))) {
        # var_dump($result->get('Messages')[0]);
        $messageId = $result->get('Messages')[0]['MessageId'];
        $body = $result->get('Messages')[0]['Body'];
	echo "Recibido mensaje con id=$messageId y contenido='$body'\n";

        #  Nota: El mensaje recibido tiene otras 3 componentes además del id y el cuerpo:
        #  * ReceiptHandle
        #  * MD5OfBody
        #  * Attributes , que a su vez es un hash con al menos el campo "SentTimestamp"

        $result = $client->deleteMessage([
            'QueueUrl' => $queueUrl,
            'ReceiptHandle' => $result->get('Messages')[0]['ReceiptHandle']
        ]);
    } else {
        echo "No hay mensajes en la cola. \n";
    }
} catch (AwsException $e) {
    // output error message if fails
    error_log($e->getMessage());
}
?>
