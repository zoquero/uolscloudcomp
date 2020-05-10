<html>
  <head>
    <meta charset="UTF-8">
    <title>Aplicación que gasta CPU</title>
  </head>
  <body>
    <h1>Aplicación que gasta CPU</h1>
<?php
  $serverWithSpentTime = "ec2-3-92-166-153.compute-1.amazonaws.com";
  $usSpentTimeURL = "http://$serverWithSpentTime/ussleeptime";
  $usSpentTime = intval(file_get_contents($usSpentTimeURL));
  echo "Spent time dictado por $usSpentTimeURL = $usSpentTime s";

  list($usec, $sec) = explode(" ", microtime());
  $antes=$sec+$usec;
  $i=1; 
  $j=$usSpentTime; 
  while(1) {
    $j+=$i; $j/=$usSpentTime;
    list($usec, $sec) = explode(" ", microtime());
    $despues=$sec+$usec;
    if(($despues-$antes) > $usSpentTime) {
      break;
    }
  }
?>
  </body>
</html>
