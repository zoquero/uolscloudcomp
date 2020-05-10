<html>
  <head>
    <meta charset="UTF-8">
    <title>Aplicación que duerme</title>
  </head>
  <body>
    <h1>Aplicación que duerme</h1>
<?php
  $serverWithSleepTime = "ec2-3-92-166-153.compute-1.amazonaws.com";
  $usSleepTimeURL = "http://$serverWithSleepTime/ussleeptime";
  $usSleepTime = intval(file_get_contents($usSleepTimeURL));
  echo "Sleep time dictado por $usSleepTimeURL = $usSleepTime us";
  usleep($usSleepTime);
?>
  </body>
</html>
