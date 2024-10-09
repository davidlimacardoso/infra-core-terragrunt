# Vprofile - Project

DevOps tests, provisioning resources and infraestructure IaC. Web app Tomcat Java exposed behind loadbalancer, where the backend is inside private net Memcache DB, RabbitMQ and MariaDB behind Route53 intranet domain. 

# Prerequisites
#
- JDK 11 
- Maven 3 
- MySQL 8

# Technologies 
- Spring MVC
- Spring Security
- Spring Data JPA
- Maven
- JSP
- Tomcat
- MySQL
- Memcached
- Rabbitmq
- ElasticSearch
# Database
Here,we used Mysql DB 
sql dump file:
- /src/main/resources/db_backup.sql
- db_backup.sql file is a mysql dump file.we have to import this dump to mysql db server
- > mysql -u <user_name> -p accounts < db_backup.sql

## Reference
[vprofile-project](https://github.com/hkhcoder/vprofile-project/tree/aws-LiftAndShift)

[DevOps Beginners to Advanced with Projects](https://www.udemy.com/course/decodingdevops/?couponCode=PLOYALTY0923)