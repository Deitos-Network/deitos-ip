#!/bin/bash

export KERBEROS_ADMIN=admin/admin
export KERBEROS_ADMIN_PASSWORD=admin
export KERBEROS_ROOT_USER_PASSWORD=password
export KRB_REALM=DEITOS.NETWORK
export KEYTAB_DIR=/opt/hadoop/etc/hadoop/keytabs

export SPARK_PUBLIC_DNS=$(hostname -f)
# export SPARK_MASTER_HOST=0.0.0.0

kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "addprinc -pw password root@$KRB_REALM"

kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "addprinc -randkey nn/$(hostname -f)@$KRB_REALM"
kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "addprinc -randkey hive/$(hostname -f)@$KRB_REALM"
kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "addprinc -randkey dn/$(hostname -f)@$KRB_REALM"
kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "addprinc -randkey HTTP/$(hostname -f)@$KRB_REALM"
kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "addprinc -randkey HTTP/localhost@$KRB_REALM"

kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "addprinc -randkey jhs/$(hostname -f)@$KRB_REALM"
kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "addprinc -randkey yarn/$(hostname -f)@$KRB_REALM"
kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "addprinc -randkey rm/$(hostname -f)@$KRB_REALM"
kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "addprinc -randkey nm/$(hostname -f)@$KRB_REALM"

kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "xst -k $HOME/nn.keytab nn/$(hostname -f) HTTP/$(hostname -f) hive/$(hostname -f) HTTP/localhost"
kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "xst -k $HOME/dn.keytab dn/$(hostname -f)"
kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "xst -k $HOME/spnego.keytab HTTP/$(hostname -f)"
kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "xst -k $HOME/jhs.keytab jhs/$(hostname -f)"
kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "xst -k $HOME/hive.keytab hive/$(hostname -f)"

kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "xst -k $HOME/yarn.keytab yarn/$(hostname -f)"
kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "xst -k $HOME/rm.keytab rm/$(hostname -f)"
kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "xst -k $HOME/nm.keytab nm/$(hostname -f)"

mkdir -p $KEYTAB_DIR
mv $HOME/nn.keytab $KEYTAB_DIR
mv $HOME/dn.keytab $KEYTAB_DIR
mv $HOME/spnego.keytab $KEYTAB_DIR
mv $HOME/jhs.keytab $KEYTAB_DIR
mv $HOME/yarn.keytab $KEYTAB_DIR
mv $HOME/rm.keytab $KEYTAB_DIR
mv $HOME/nm.keytab $KEYTAB_DIR
mv $HOME/hive.keytab $KEYTAB_DIR
chmod 400 $KEYTAB_DIR/nn.keytab
chmod 400 $KEYTAB_DIR/dn.keytab
chmod 400 $KEYTAB_DIR/spnego.keytab
chmod 400 $KEYTAB_DIR/jhs.keytab
chmod 400 $KEYTAB_DIR/yarn.keytab
chmod 400 $KEYTAB_DIR/rm.keytab
chmod 400 $KEYTAB_DIR/nm.keytab
chmod 400 $KEYTAB_DIR/hive.keytab

echo 'Checking Credentials ...'
until kinit -kt $KEYTAB_DIR/nn.keytab nn/$(hostname -f)@$KRB_REALM; do sleep 2; done 
until kinit -kt $KEYTAB_DIR/dn.keytab dn/$(hostname -f)@$KRB_REALM; do sleep 2; done 
until kinit -kt $KEYTAB_DIR/spnego.keytab HTTP/$(hostname -f)@$KRB_REALM; do sleep 2; done 
until kinit -kt $KEYTAB_DIR/jhs.keytab jhs/$(hostname -f)@$KRB_REALM; do sleep 2; done 
until kinit -kt $KEYTAB_DIR/yarn.keytab yarn/$(hostname -f)@$KRB_REALM; do sleep 2; done 
until kinit -kt $KEYTAB_DIR/rm.keytab rm/$(hostname -f)@$KRB_REALM; do sleep 2; done 
until kinit -kt $KEYTAB_DIR/nm.keytab nm/$(hostname -f)@$KRB_REALM; do sleep 2; done 
until kinit -kt $KEYTAB_DIR/hive.keytab hive/$(hostname -f)@$KRB_REALM; do sleep 2; done 

echo $(hostname -f)

kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "addprinc -randkey test_user/$(hostname -f)@$KRB_REALM"
kadmin -p $KERBEROS_ADMIN -w $KERBEROS_ADMIN_PASSWORD -q "xst -k /home/jovyan/keytabs/current-master.keytab test_user/$(hostname -f)@$KRB_REALM HTTP/localhost"
kinit -kt /home/jovyan/keytabs/current-master.keytab test_user/$(hostname -f)@$KRB_REALM

ldapadd -x  -w admin  -H ldap://ldap.deitos.network:389 -D "cn=admin,dc=deitos,dc=network"  -f $HOME/ou.ldif 
ldapadd -x  -w admin  -H ldap://ldap.deitos.network:389 -D "cn=admin,dc=deitos,dc=network"  -f $HOME/group.ldif 
ldapadd -x  -w admin  -H ldap://ldap.deitos.network:389 -D "cn=admin,dc=deitos,dc=network"  -f $HOME/person.ldif 

keytool -genkey -alias $(hostname -f) -keyalg rsa -dname "CN=$(hostname -f)" -keypass changeme -keystore $KEYTAB_DIR/keystore.jks -storepass changeme

chmod 700 $KEYTAB_DIR/keystore.jks
chown jovyan $KEYTAB_DIR/keystore.jks

if [ -z "$(ls -A "$NAMEDIR")" ]; then
  echo "Formatting namenode name directory: $NAMEDIR"
  hdfs namenode -format
fi  

echo "Starting Hadoop name node..."
hdfs --daemon start namenode

#echo "Starting Hadoop secondary name node..."
#hdfs --daemon start secondarynamenode

echo "Starting Hadoop resource manager..."
yarn --daemon start resourcemanager

echo "Starting Spark master node..."
# spark-class org.apache.spark.deploy.master.Master --ip "$SPARK_MASTER_HOST" &
spark-class org.apache.spark.deploy.master.Master --ip "$SPARK_MASTER_HOST"  &

if [ ! -f "$NAMEDIR"/initialized ]; then
  echo "Configuring Hive..."
  until kinit -kt $KEYTAB_DIR/hive.keytab hive/$(hostname -f)@$KRB_REALM; do sleep 2; done 
  hdfs dfs -mkdir -p  /user/hive/warehouse
  schematool -dbType postgres -initSchema
  touch "$NAMEDIR"/initialized
fi

if ! hdfs dfs -test -d /tmp
then
  echo "Formatting directory: /tmp"
  hdfs dfs -mkdir -p  /tmp
fi
if ! hdfs dfs -test -d "$SPARK_LOGS_HDFS_PATH"
then
  echo "Formatting directory: $SPARK_LOGS_HDFS_PATH"
  hdfs dfs -mkdir -p  "$SPARK_LOGS_HDFS_PATH"
fi
if ! hdfs dfs -test -d "$SPARK_JARS_HDFS_PATH"
then
  echo "Formatting directory: $SPARK_JARS_HDFS_PATH"
  hdfs dfs -mkdir -p  "$SPARK_JARS_HDFS_PATH" 
  hdfs dfs -put "$SPARK_HOME"/jars/* "$SPARK_JARS_HDFS_PATH"/
fi

echo "Setting Permissions for Users"
hdfs dfs -chown -R  root:users  /
hdfs dfs -chmod -R 775 /user
hdfs dfs -chmod -R 775 /var

if ! hdfs dfs -test -d "/data"
then
  echo "Generating HOME Path for Users: /data"
  hdfs dfs -mkdir /data
  hdfs dfs -mkdir /data/test_user
  hdfs dfs -chown -R test_user:root /data/test_user
fi

echo "Starting Hive Metastore..."
hive --service metastore &

echo "Starting Hive server2..."
hiveserver2 &

# echo "Starting Hadoop KMS Service ..."
# hadoop --daemon start kms   

while true; do sleep 1000; done
