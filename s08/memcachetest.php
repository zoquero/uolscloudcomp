<?php

$memtest = new Memcached();
$memtest->addServer("127.0.0.1", 11211);
$querykey = "1";

$result = $memtest->get($querykey);
if ($result) {
  echo "Sí estava: $querykey=$result\n";
}
else {
  echo "NO estava $querykey\n";
}

$memtest->set($querykey, "uan");
?>
