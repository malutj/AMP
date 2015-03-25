/*
 * create the miller database
 */
CREATE DATABASE IF NOT EXISTS amp;

/*
 * create the user account that will connect to the AMP database
 */
CREATE USER 'dev1'@'localhost' IDENTIFIED BY 'dev1';

/*
 * grant the appropriate permissions to dev1 user
 */
GRANT ALL ON amp.* TO 'dev1'@'localhost';

/*
 * switch to the amp database
 */
USE amp;

/*
 * create the user table
 */
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id     INT(32)     UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(15) UNIQUE NOT NULL,
    password    VARCHAR(50) NOT NULL
) ENGINE=InnoDB; 

/*
 * add admin user to table
 */
INSERT INTO users (username, password) VALUES ('admin', PASSWORD('@mp@dm1n'));

/*
 * create the client table
 */
DROP TABLE IF EXISTS clients;
CREATE TABLE clients (
	client_id	INT(32)		UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	client_name VARCHAR(30) UNIQUE NOT NULL,
	client_code VARCHAR(10) UNIQUE NOT NULL
) ENGINE=InnoDB; 
