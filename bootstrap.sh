# Install hadoop
if [ ! -d "/home/vagrant/hadoop" ]; then
    wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz
    tar -xvzf hadoop-3.3.4.tar.gz
    mv hadoop-3.3.4 hadoop 
    sleep 2   
fi

# Hadoop Permission to Allow User to create folders
sudo chown -R vagrant:vagrant /home/vagrant/hadoop

# Hadoop Environment variables
sudo echo "export HADOOP_HOME=/home/vagrant/hadoop" >> /home/vagrant/.bashrc
sudo echo "export PATH=\${PATH}:\${HADOOP_HOME}/bin:\${HADOOP_HOME}/sbin" >> /home/vagrant/.bashrc

# Install Java
apt-get update
ufw disable
sudo apt-get -y install openjdk-8-jdk 

# Java Environment variables
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /home/vagrant/hadoop/etc/hadoop/hadoop-env.sh

# Hadoop XML Files
# Replace xml config files
sudo ln -sf /vagrant/hadoopxml/core-site.xml /home/vagrant/hadoop/etc/hadoop/core-site.xml
sudo cat /vagrant/hadoopxml/hdfs-site.xml | sudo tee /home/vagrant/hadoop/etc/hadoop/hdfs-site.xml > /dev/null  
sudo cat /vagrant/hadoopxml/mapred-site.xml | sudo tee /home/vagrant/hadoop/etc/hadoop/mapred-site.xml > /dev/null   

if [ "$HOSTNAME" == "node1" ]; then
    sudo cat /vagrant/hadoopxml/master-yarn-site.xml | sudo tee /home/vagrant/hadoop/etc/hadoop/yarn-site.xml > /dev/null   
else
    sudo cat /vagrant/hadoopxml/worker-yarn-site.xml | sudo tee /home/vagrant/hadoop/etc/hadoop/yarn-site.xml > /dev/null   
fi
# Add Worker Nodes
sudo echo "node2" | sudo tee /home/vagrant/hadoop/etc/hadoop/workers > /dev/null
sudo echo "node3" | sudo tee -a /home/vagrant/hadoop/etc/hadoop/workers

# Install Mariadb only on Master node
if [ "$HOSTNAME" == "node1" ]; then
    sudo apt install -y mariadb-server
    sudo apt-get update
    sudo service mysql start
fi

# Download and install Hive
wget http://www-eu.apache.org/dist/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz
tar -xzf apache-hive-3.1.2-bin.tar.gz
mv apache-hive-3.1.2-bin hive
sleep 2

# Configure Hive
sudo chown -R vagrant:vagrant /home/vagrant/hive
echo "export HIVE_HOME=/home/vagrant/hive" >> /home/vagrant/.bashrc
echo "export PATH=\${PATH}:\${HIVE_HOME}/bin" >> /home/vagrant/.bashrc
cp /home/vagrant/hive/conf/hive-env.sh.template /home/vagrant/hive/conf/hive-env.sh
echo "export HADOOP_HOME=/home/vagrant/hadoop" >> /home/vagrant/hive/conf/hive-env.sh

# Hive xml file
sudo cat /vagrant/hivexml/hive-site.xml | sudo tee /home/vagrant/hive//conf/hive-site.xml > /dev/null   