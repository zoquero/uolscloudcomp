--
-- DDL para creación de BD y tablas y SQL para carga de datos iniciales
-- de una aplicación demostrativa
--
-- angel.galindo@uols.org
-- 2020/02/15
--
create database uolstest;
use uolstest;

create table user (
  id int auto_increment not null primary key,
  first_name varchar(255),
  last_name varchar(255),
  birthday date
);

insert into user (first_name, last_name, birthday) values ('Emilia',     'Davis',      '1926-05-26');
insert into user (first_name, last_name, birthday) values ('Berta',      'Hancock',    '1940-04-12');
insert into user (first_name, last_name, birthday) values ('Jaime',      'Hendricks',  '1942-11-27');
insert into user (first_name, last_name, birthday) values ('Leonor',     'Kilminster', '1945-12-24');
insert into user (first_name, last_name, birthday) values ('Luz',        'Interiores', '1946-10-21');
insert into user (first_name, last_name, birthday) values ('María José', 'Monje',      '1950-12-05');
insert into user (first_name, last_name, birthday) values ('Josefa',     'Strummer',   '1952-08-21');
insert into user (first_name, last_name, birthday) values ('Ricardo',    'Stallman',   '1953-03-16');
insert into user (first_name, last_name, birthday) values ('Juan',       'Satriano',   '1956-06-15');
insert into user (first_name, last_name, birthday) values ('Ian',        'McKay',      '1962-04-16');
insert into user (first_name, last_name, birthday) values ('Rigoberta',  'Iniesta',    '1962-05-16');
insert into user (first_name, last_name, birthday) values ('Miguel',     'Monroe',     '1962-06-17');
insert into user (first_name, last_name, birthday) values ('Julio',      'Hammet',     '1962-11-18');
insert into user (first_name, last_name, birthday) values ('Josefina',   'Newsted',    '1963-03-04');
insert into user (first_name, last_name, birthday) values ('Chris',      'Cornelio',   '1964-06-20');
insert into user (first_name, last_name, birthday) values ('Jane',       'Spencer',    '1965-01-01');
insert into user (first_name, last_name, birthday) values ('Sen',        'Reyes',      '1965-11-22');
insert into user (first_name, last_name, birthday) values ('Lina',       'Torval',     '1969-12-28');
insert into user (first_name, last_name, birthday) values ('Lana',       'Staley',     '1967-08-22');
insert into user (first_name, last_name, birthday) values ('Scottish',   'Weiland',    '1967-10-27');
insert into user (first_name, last_name, birthday) values ('Máximo',     'Calavera',   '1969-08-04');
insert into user (first_name, last_name, birthday) values ('Francisca',  'Te',         '1973-04-10');
insert into user (first_name, last_name, birthday) values ('Olivia',     'Gallego',    '1976-01-01');
