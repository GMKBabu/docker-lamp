<?php
/*
 * Generated configuration file
 * Generated by: phpMyAdmin 4.0.8 setup script
 * Date: Mon, 21 Oct 2013 22:58:41 +0000
 */

/* Servers configuration */
$i = 0;

/* Server: mysql [1] */
$i++;
$cfg['Servers'][$i]['verbose'] = 'mysql';
$cfg['Servers'][$i]['host'] = getenv('db_server'); // 'localhost';
$cfg['Servers'][$i]['port'] = '';
$cfg['Servers'][$i]['socket'] = '';
$cfg['Servers'][$i]['connect_type'] = 'tcp';
$cfg['Servers'][$i]['extension'] = 'mysqli';
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['user'] = 'root';
$cfg['Servers'][$i]['password'] = '';

/* End of servers configuration */

$cfg['blowfish_secret'] = '5265b17ca08312.13083125';
$cfg['DefaultLang'] = 'en';
$cfg['ServerDefault'] = 1;
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';

$cfg['PmaAbsoluteUri'] = getenv('absolute_uri'); //'https://ssl.example.org/pma.example.org/'
?>