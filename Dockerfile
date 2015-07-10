# MySQL Server with Apache and phpmyadmin
#
# VERSION               0.0.1
#
# Logging is performed via syslog to a server named beservices
#

FROM     centos:7
MAINTAINER Jonas Colmsjö "jonas@gizur.com"

RUN yum install -y wget nano curl git unzip which tar gcc


#
# Install supervisord (used to handle processes)
# ----------------------------------------------
#
# Installation with easy_install is more reliable. yum don't always work.

RUN yum install -y python python-setuptools
RUN easy_install supervisor
ADD ./etc-supervisord.conf /etc/supervisord.conf
ADD ./etc-supervisor-conf.d-supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor/


#
# Install rsyslog
# ---------------

RUN yum install -y rsyslog
ADD ./etc-rsyslog.conf /etc/rsyslog.conf


#
# Install web server
# -----------------

RUN etc-yum.repos.d-nginx.repo /etc/yum.repos.d/nginx.repo
RUN yum update -y

RUN yum install -y epel-release
RUN yum install -y nginx
RUN yum install -y php-fpm php-mysql php-mbstring dejavu-fonts-common dejavu-sans-fonts libmcrypt libtidy php-bcmath php-gd php-mcrypt php-php-gettext php-tcpdf php-tcpdf-dejavu-sans-fonts php-tidy t1lib

# PHP 5.4 - centos7 comes with 5.5 is also supported
#RUN wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
#RUN rpm -Uvh remi-release-7.rpm
#RUN yum --enablerepo=remi install -y php54


RUN echo -e "<?php\nphpinfo();\n " > /usr/share/nginx/html/info.php
RUN chown apache:apache -R /usr/share/nginx/html/


#
# Customized ini files
# ------------------
#

#ADD ./etc-php.ini /etc/php.ini
#ADD ./etc-httpd-conf-httpd.conf /etc/httpd/conf/httpd.conf


#
# Install MySQL
# -------------

RUN yum -y install mariadb-server mariadb
RUN /usr/bin/mysql_install_db --datadir="/var/lib/mysql" --user=mysql
#RUN /usr/bin/mysql_upgrade

# Add scripts, source code for SQL-scripts and vTiger instances
ADD ./init-mysql.sh /

# Setup admin user and load data
RUN /init-mysql.sh


#
# Misc modules
# ------------

RUN yum install -y php-pecl-redis php-curl


#
# Install phpMyAdmin
# ------------------
#

RUN yum install -y phpMyAdmin
RUN ln -s /usr/share/phpMyAdmin /usr/share/nginx/html/phpmyadmin
RUN mkdir /usr/share/phpMyAdmin/config
RUN chown apache:apache -R /usr/share/phpMyAdmin

RUN mkdir -p /var/lib/php/session
RUN chown apache:apache -R /var/lib/php
RUN chmod ug+w /var/lib/php/session
RUN chmod 777 /tmp

ADD ./src-phpmyadmin/phpMyAdmin-4.0.8-all-languages.tar.gz /usr/share/nginx/html/
ADD ./src-phpmyadmin/config.inc.php /usr/share/nginx/html/phpMyAdmin-4.0.8-all-languages/config.inc.php


#
# Install RDS Command Line Tools (for MySQL performance tuning of RDS MySQL)
# --------------------------------------------------------------------------
# http://docs.aws.amazon.com/AmazonRDS/latest/CommandLineReference/StartCLI.html

RUN yum install -y groff
RUN easy_install pip
RUN pip install awscli


#
# Setup S3
# ---------

RUN wget https://github.com/s3tools/s3cmd/archive/master.zip
RUN unzip /master.zip
RUN cd /s3cmd-master; python setup.py install
RUN yum install -y python-dateutil

ADD ./s3cfg /.s3cfg


#
# Install cron and batches
# ------------------------

#RUN yum install -y vixie-cron
RUN yum install -y cronie

# Add batches here since it changes often (use cache when building)
ADD ./batches.sh /

# Run backup job every hour
ADD ./backup.sh /
RUN echo '0 1 * * *  /bin/bash -c "/backup.sh"' > /mycron

RUN crontab /mycron


#
# Start apache and mysql using supervisord
# -----------------------------------------


RUN mkdir /apps

EXPOSE 80 443
CMD ["supervisord"]
