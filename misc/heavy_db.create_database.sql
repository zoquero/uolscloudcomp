
CREATE DATABASE heavy_db;
CREATE USER 'heavy_db_admin'@'localhost' IDENTIFIED BY 'easypass';


CREATE DATABASE heavy_db;
CREATE USER 'heavy_db_admin'@'localhost' IDENTIFIED BY 'easypass';
GRANT ALL PRIVILEGES ON heavy_db.* TO 'heavy_db_admin'@'localhost';
FLUSH PRIVILEGES;
USE heavy_db
CREATE TABLE users (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    age INT(10) NOT NULL
);
