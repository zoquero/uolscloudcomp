<?php
#
# Ejemplo de envío de mensaje a un tema SNS
# angel.galindo@uols.org 20200309
#
require 'vendor/autoload.php';

use Aws\Sns\SnsClient; 
use Aws\Exception\AwsException;

$SnSclient = new SnsClient([
    'profile' => 'default',
    'region' => 'us-east-1',
    'version' => '2010-03-31'
]);

$msg = 'Éste es un mensaje SNS de prueba usando el CLI ';
$topic = 'arn:aws:sns:us-east-1:707028815336Z:uol-sns-test';

try {
    echo "Vamos a enviar el mensaje: $msg\n";
    $result = $SnSclient->publish([
        'Message' => $msg,
        'TopicArn' => $topic,
    ]);
    echo "Ésta es la respuesta a la petición:\n";
    var_dump($result);
} catch (AwsException $e) {
    error_log($e->getMessage());
} 
?>
