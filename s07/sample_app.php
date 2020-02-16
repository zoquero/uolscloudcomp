<?php

/* Aplicación demostrativa del acceso a base de datos
 * para la asignatura "Cloud Computing" de UOLS.
 *
 * angel.galindo@uols.org
 * 2020/02/15
 */

$scriptName = basename(__FILE__);
$hostname = "localhost";
$username = "xxxxxxxx";
$password = "yyyyyyyy";
$db       = "uolstest";

$dbConnection=mysqli_connect($hostname, $username, $password, $db);
if (! $dbConnection) {
  die("Database connection failed: " . mysqli_connect_errno());
}
mysqli_set_charset($dbConnection, 'utf8');

if (array_key_exists("age", $_GET) && $_GET['age'] !== '') {
  $age=$_GET['age'];
  $queryString = "SELECT first_name, last_name FROM user WHERE TIMESTAMPDIFF(YEAR, birthday, now()) > $age";
}
else {
  $queryString = "SELECT first_name, last_name FROM user";
}

$query = mysqli_query($dbConnection, $queryString)
   or die (mysqli_error($dbConnection));

?>
<html>
  <head>
    <meta charset="UTF-8">
    <title> Prueba simple de acceso a base de datos </title>
  </head>
  <body>
    <h1>Listado de usuarios</h1>
    <table cellspacing="2" cellpadding="2" border="1">
      <tr>
        <th bgcolor='#E0E0E0'>Nombre</th>
        <th bgcolor='#E0E0E0'>Apellidos</th>
      </tr>

<?php

while ($row = mysqli_fetch_array($query)) {
  echo
   "<tr>
      <td bgcolor='#FFFFD3'>{$row['first_name']}</td>
      <td bgcolor='#FFFFD3'>{$row['last_name']}</td>
   </tr>\n";
}

?>
    </table>
    <form action="<?php echo $scriptName ?>" method="get">
      Edad mínima de los usuarios a mostrar:
      <input type="text" maxlength="3" size="3" id="age" name="age" value=""><br/>
      <input type="submit" value="Submit">
    </form>
  </body>
</html>

<?php
mysqli_close($dbConnection);
