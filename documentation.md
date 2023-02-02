***
## Big Data Infrastructure with Hadoop
***
#### Introduction
Big data refers to large, complex sets of data that are too large or too complex to be processed and analyzed using traditional data processing techniques. It is typically characterized by a high volume, high velocity, and high variety of data, which can come from a variety of sources such as social media, sensors, logs, and transactional data.

Big data has the potential to provide valuable insights and drive innovation in a variety of fields, including business, science, and government. However, handling and analyzing big data requires specialized tools and techniques of processing as well as the ability to store and manage large amounts of data.

Hadoop is an open-source framework for storing and processing large amounts of data in a distributed manner. It consists of two core components: the Hadoop Distributed File System (HDFS) and the MapReduce processing engine.

Hadoop is widely used for big data analytics and has become a standard for storing and processing large amounts of data in a distributed manner. It is often used in conjunction with other big data tools, such as Spark, Hive and Pig, to perform tasks such as data ingestion, transformation, and analysis.

A typical hadoop ecosystem is shown in figure1.

<br>
<figure>
  <img title="Hadoop Ecosystem" alt="Hadoop Ecosystem Diagram" src="/images/hadoop_ecosystem.png">
  <caption> Figure 1: Hadoop Ecosystem </caption>
</figure>
<br>

Hadoop infrastructure can be set up using Infrastructure as code (IaC) approach. IaC is a practice in which infrastructure is managed and provisioned using code, rather than manually configuring hardware and software. It enables us to automate the process of provisioning, managing, and maintaining infrastructure, making it easier to deploy and scale applications.

IaC involves writing code that defines and configures the infrastructure, such as servers, networking, and other resources. This code can be stored in a version control system, such as Git, and used to automate the provisioning and management of infrastructure.

Benefits of using IaC include:

* Improved efficiency: Automating the process of provisioning and managing infrastructure can save time and reduce the risk of errors.

* Version control: Storing infrastructure configuration in version control allows us to track changes and roll back to previous versions if needed.

* Collaboration: IaC enables teams to work together on infrastructure configuration, making it easier to manage and maintain infrastructure in a consistent way.

* Reproducibility: IaC enables organizations to easily reproduce infrastructure in different environments, such as development, staging, and production.


In this project, I am using hadoop for a picture archive site. This site is expected to handle data sets that may grow rapidly. HDFS is particularly well-suited for this purpose because it is designed to handle data sets that are too large to be stored and processed on a single machine. HDFS scales horizontally, meaning that it can store and process large amounts of data by distributing it across a large number of nodes, even when the data sets are growing rapidly .

In addition, HDFS is designed to be fault-tolerant, meaning that it can continue to operate even when some of the servers in the cluster fail. This is important for a picture archive site, where it is critical to ensure that the pictures are available and accessible to users at all times.

Therefore, HDFS will be used for this picture archive site, as it can help to store and manage the large volume of pictures in a scalable and fault-tolerant manner.

## Design
On this project I am using IaC to design hadoop big data infrastructure. This design involves setting up a Hadoop cluster with three nodes, using MapReduce and YARN to process and manage data, and building a Flask web application that can access HDFS through Hive. It uses Vagrant and VirtualBox to create and manage the virtual development environment, and relies on Hive and HDFS to query and process data stored in the cluster. At the end of this document, I plan to have a working hadoop infrastructure similar to figure 2.

<br>
<figure>
  <img title="IaC Concept Design" alt="IaC Concept Design" src="/images/concept.jpg">
  <caption> Figure 2: Hadoop IaC Design Concept </caption>
</figure>
<br>

The components of the concept design are:

* <b>VirtualBox</b>: VirtualBox is a virtualization software that allows us to create and run virtual machines on our local machine. 

* <b>Vagrant</b>: Vagrant allows us to define a configuration for a virtual machine, including the operating system, packages, and other settings, and then automate the process of creating and provisioning the virtual machine.

* <b>HDFS</b>: HDFS (Hadoop Distributed File System) is a distributed file system that is used to store data in a Hadoop cluster. It is designed to be scalable and fault-tolerant, allowing it to store and process large amounts of data quickly and efficiently.

* <b>MapReduce</b>: MapReduce is a programming model that is used to process large amounts of data in a distributed manner. It consists of two main functions: Map and Reduce. The Map function processes data in parallel and produces a set of intermediate key-value pairs, while the Reduce function combines the intermediate results and produces the final output.

* <b>YARN</b>: YARN (Yet Another Resource Negotiator) is a resource management platform that is used to allocate resources, such as CPU and memory, to applications running on a Hadoop cluster. It enables us to run a variety of applications on the same cluster.

* <b>Flask</b>: Flask is a web framework for Python that is used to build web applications. 

* <b>Hive</b>: Hive is a data warehousing and SQL-like query language for Hadoop. It is used to query and manage data stored in HDFS and to analyze large datasets using SQL-like queries.

* <b>Mariadb</b>: MariaDB is an open-source database management system.It enables Hive to efficiently store and manage the metadata required for querying and processing data stored in HDFS.

## Configuration
##### Basic Configuration
We start by installing Oracle Virtualbox, Vagrant and gitbash, a tool which provides an emulation layer for a Git command line experience. We then create a directory for our project go to that directory and use `vagrant init` to initialize our vagrant. 

`vagrant init` initializes vagrant and creates 'Vagrantfile'. The Vagrantfile is written in Ruby and specifies the configuration for our infrastructure. 

We start by editing Vagrantfile to create three nodes.
```
Vagrant.configure("2") do |config|
  (1..3).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.box = "ubuntu/focal64"
      node.vm.hostname = "node#{i}"
      node.vm.network "private_network", ip: "10.0.0.#{i*10}"  
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "3072"
        vb.cpus = "2"
      end
    end
  end
end

```
Once the Vagrantfile has been written, we run the `vagrant up` command. Vagrant will create and boot three virtual machines with ubuntu 20.04. The hostnames of the nodes will be node1, node2 and node3 with IP addresses 10.0.0.10, 10.0.0.20 and 10.0.0.30 respectively. The allocated resources are 3 GB RAM and 2 cpus.

<br>
<figure>
  <img title="Three Nodes Running" alt="Three Nodes Running" src="/images/three_vms.jpg">
  <caption> Figure 3: Three Nodes Running </caption> 
</figure>
<br>

These three nodes should be able to communicate remotely without passwords. To make that happen, we have to configure ssh. The nodes should also be able to identify each other not only with their IP Addresses but with their hostnames. Therefore, we have to add the hostnames to each nodes hosts file. Lets edit our Vagrantfile to include this.
```
Vagrant.configure("2") do |config|
  (1..3).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.box = "ubuntu/focal64"
      node.vm.hostname = "node#{i}"
      node.vm.network "private_network", ip: "10.0.0.#{i*10}"  
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "3072"
        vb.cpus = "2"
      end

      # Add hostnames to /etc/hosts  
      (1..3).each do |j|
        node.vm.provision "shell", inline: <<-SHELL
          echo "10.0.0.#{j*10} node#{j}" >> /etc/hosts
        SHELL
      end

      # Configure SSH Keys across nodes
      config.vm.provision "file", source: "id_rsa", destination: "/home/vagrant/.ssh/id_rsa"
      public_key = File.read("id_rsa.pub")
      config.vm.provision "shell" do |s|
        s.inline = <<-SHELL
          mkdir -p /home/vagrant/.ssh
          chmod 700 /home/vagrant/.ssh
          echo '#{public_key}' >> /home/vagrant/.ssh/authorized_keys
          chmod 600 /home/vagrant/.ssh/id_rsa
          chmod 600 /home/vagrant/.ssh/authorized_keys
          echo 'Host 10.0.0.*' >> /home/vagrant/.ssh/config
          echo 'StrictHostKeyChecking no' >> /home/vagrant/.ssh/config
          echo 'UserKnownHostsFile /dev/null' >> /home/vagrant/.ssh/config
          chmod 600 /home/vagrant/.ssh/config
        SHELL
      end        
    end
  end
end
```
The nodes can now communicate using ssh.

<br>
<figure>
  <img title="Cross Node Communicationn" alt="Cross Node Communication" src="/images/ping_ssh.jpg">
  <caption> Figure 4: Cross Node Communication </caption> 
</figure>
<br>

We have three virtual machines that can communicate with each other.  

#### Provisioning
The next step is to install Java and Hadoop on these virtual machines. To do this, we can edit our Vagrantfile and add a provisioning script.
```
node.vm.provision "shell", inline: <<-SHELL
  sudo apt-get -y install openjdk-8-jdk 
SHELL
```
For clarity, we can create a separate shell script file in the same directory as our Vagrantfile, called bootstrap.sh, which contains all of our provisioning scripts. We can then call these scripts from our Vagrantfile using `node.vm.provision "shell", path:"bootstrap.sh"`. This will run the provisioning scripts in the <b>bootstrap.sh</b> file on each of our virtual machines. Here is the shellscript in <b>bootstrap.sh</b> that installs java and hadoop.

```
#Install Hadoop
wget https:\//dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz
tar -xvzf hadoop-3.3.4.tar.gz
mv hadoop-3.3.4 hadoop 

#Install Java
apt-get update
ufw disable
sudo apt-get -y install openjdk-8-jdk 
```

Lets also add environment variables. 

```
#Hadoop Environment variables
sudo echo "export HADOOP_HOME=/home/vagrant/hadoop" >> /home/vagrant/.bashrc
sudo echo "export PATH=\${PATH}:\${HADOOP_HOME}/bin:\${HADOOP_HOME}/sbin" >> /home/vagrant/.bashrc

# Java Environment variables
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /home/vagrant/hadoop/etc/hadoop/hadoop-env.sh
```
Now, we will use `vagrant provision` command, to execute any provisioning scripts that have been specified in the Vagrantfile. 

<br>
<figure>
  <img title="Vagrant Provision" alt="Vagrant Provision" src="/images/vagrant_provision.jpg">
  <caption> Figure 5: Vagrant Provision </caption> <br>
</figure>
<br>

Lets confirm the installations of java and hadoop.

<br>
<figure>
  <img title="Confirming Installation" alt="Confirming Installation" src="/images/confirm_installation.jpg">
  <caption> Figure 6: Confirming Installation </caption> 
</figure>
<br>

#### Hadoop Configuration Files
Masternode in a hadoop cluster is a node that manages the work of other nodes in the cluster. It is responsible for coordinating the processing of data and distributing the work among the other nodes, known as slave nodes.

The masternode maintains the metadata for the data stored in the cluster, including the location of the data blocks and the status of the processing tasks. It also manages the job scheduling and resource allocation for the slave nodes.

The slave nodes are responsible for performing the actual processing tasks assigned to them by the masternode. They store and process the data blocks, and communicate the status of their tasks back to the masternode.

In hadoop, xml configuration files are used to set various parameters that control the behavior of the cluster. We need to make changes to the xml files. The primary configuration files are: <b>core-site.xml, hdfs-site.xml, mapred-site.xml, and yarn-site.xml.

* <b>core-site.xml</b> is the core-site.xml file that informs Hadoop daemon where NameNode runs in the cluster.
* <b>hdfs-site.xml</b> file contains settings related to the HDFS component of Hadoop. The location of the NameNode and DataNode processes are set here. 
* <b>mapred-site.xml</b> is one of the important configuration files which is required for runtime environment settings of a Hadoop. It contains configuration settings for MapReduce.
* <b>yarn-site.xml</b> is another file that contains the configuration settings related to YARN. It contains settings for Node Manager, Resource Manager, and other components.

For clarity, we keep these four xml files in a separate folder - hadoopxml. We can access them with shell scripts. This is core-site.xml file.
```
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://node1:9000</value>
  </property>
  <property>
    <name>hadoop.tmp.dir</name>
    <value>/home/vagrant/hadoop/tmp</value>
  </property>
</configuration>
```
We need to copy the contents of these files to replace the contents in /hadoop/etc folder. Here is the shell script in <b>`bootstrap.sh`</b>command.
```
sudo ln -sf /vagrant/hadoopxml/core-site.xml /home/vagrant/hadoop/etc/hadoop/core-site.xml
```
We have to do these for these four files.

#### Starting Services
Now, we have completed the configuration of hadoop. We will login to the master node and start the services. To do so, we need to initialize hdfs first with `hdfs namenode -format`.

<br>
<figure>
  <img title="Format Namenode" alt="Format Namenode" src="/images/namenode_format.jpg">
  <caption> Figure 7: Confirming Installation </caption> 
</figure>
<br>

We now start hdfs with `start-dfs.sh`.

<br>
<figure>
  <img title="Start hdfs" alt="Start hdfs" src="/images/start_dfs.jpg">
  <caption> Figure 8: Start hdfs </caption> 
</figure>
<br>

Lets start yarn as well with `start-yarn.sh` and run `jps` command to make sure namenodes and datanodes have started.

<figure>
  <img title="JPS" alt="jps" src="/images/jps.jpg">
  <caption> Figure 9: Status with jps </caption> 
</figure>
<br>

We can access hdfs as well as yarn resource manager through their web interface. For hdfs, we can use its default port `9780` and for yarn we will use `8088`. The full address on our host machine will be `masternodeip:port`. On this project, we are using <b>10.0.0.10</b> for master node. Therefore, the address we have to use for hdfs is <b>10.0.0.10:9870</b>.

<br>
<figure>
  <img title="hdfs web" alt="hdfs web" src="/images/hdfs_web.jpg">
  <caption> Figure 10: hdfs web </caption> 
</figure>
<br>

Lest also see the resource manager on <b>10.0.0.10:8088</b>.

<figure>
  <img title="Resource Status" alt="Resource Status" src="/images/yarn_web.jpg">
  <caption> Figure 11: Resource Status </caption> 
</figure>
<br>

#### Hive
Now we have hdfs with yarn and mapreduce. Next, we will install hive for data management. Hive requires mysql service for its metadata. So, let us first install mariadb. We need this only on masternode. 

```
# Install Mariadb only on Master node
if [ "$HOSTNAME" == "node1" ]; then
    sudo apt install -y mariadb-server
    sudo apt-get update
    sudo service mysql start
fi
```
<br>
<figure>
  <img title="mysql service" alt="mysql service" src="/images/mysql_service.jpg">
  <caption> Figure 12: mysql service </caption> 
</figure>
<br>

 Here is the shell script in <b>bootstrap.sh</b> that installs hive and add required environment variables.

```
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
sudo cat /vagrant/hivexml/hive-site.xml | sudo tee /home/vagrant/hive//conf/hive-site.xml > /dev/null  
```

Let us start hive service with `hiveserver2` command.

<br>
<figure>
  <img title="hive service" alt="hive service" src="/images/hive_service.jpg">
  <caption> Figure 13: hive service </caption> 
</figure>
<br>


#### Data Processing with Webapp

At this point, we have hive running. The next step is to store and retrieve data to hdfs through hive. For, this project we will create a small web app that with a form to upload file. Since, the main objective of this project is on big data infrastructure, we will not focus on the web development. Since our web app is a flask app, we have to install flask with `sudo apt install python3-flask`. We also need `pyhive`, `thrift` and `sasl` libraries for the connection with hive. All of them can be installed with `pip` command once `pip` itself is installed.

```
sudo apt install -y python3-pip
sudo pip install flask
sudo pip install pyhive
sudo pip install thrift
sudo pip install sasl
```

Lets see the upload form before adding the connection string to hive. We can access the upload interface from our browser. By default, it runs on port 5000. To ron the app we run `flask run --host=0.0.0.0` from the app directory.

<br>
<figure>
  <img title="upload form" alt="upload form" src="/images/upload_form.jpg">
  <caption> Figure 14: Upload Form </caption> 
</figure>
<br>

Here is the main `app.py` file that has the connection string to hive. 

```
from pyhive import hive
import os
import sasl
from flask import Flask, render_template, request

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

# Connect to the Hive server
conn = hive.Connection(host='10.0.0.10', port=10000, auth='CUSTOM',database = 'hive', username='hiveuser', password='thepassword')

@app.route('/upload', methods=['POST'])
def upload():
    if 'file' not in request.files:
        return 'No file uploaded.'
    file = request.files['file']
    if file.filename == '':
        return 'No file selected.'
    if file:
        # Connect to Hive
        cursor = conn.cursor()

        # Create a table to store the pictures
        cursor.execute('CREATE TABLE IF NOT EXISTS pictures (name STRING, data BLOB)')

        # Read the picture data and insert it into the table
        data = file.read()
        cursor.execute('INSERT INTO pictures VALUES (%s, %s)', (file.filename, data))

        # Close the connection
        cursor.close()
        conn.close()

        return 'Picture uploaded.'
    return 'An error occurred.'
if __name__ == '__main__':
    app.run()

``` 

<br>
<figure>
  <img title="Connection Failed" alt="Connection Failed" src="/images/hiveconnectionfailed.jpg">
  <caption> Figure 15: Connection Failed </caption> 
</figure>
<br>

<b>At this point, I could not connect to the mariadb account that hive uses. </b>

## References
[Hadoop Ecosystem Components](https://www.projectpro.io/article/hadoop-ecosystem-components-and-its-architecture/114)
[Components of Hadoop](https://www.simplilearn.com/tutorials/hadoop-tutorial/what-is-hadoop)
[Hadoop Configuration Files](https://data-flair.training/forums/topic/what-are-the-configuration-files-in-hadoop/#:~:text=Configuration%20Files%20are%20the%20files,Daemon%20(bin%2Fhadoop))
[Apache Yarn](https://hadoop.apache.org/docs/r2.7.3/hadoop-yarn/hadoop-yarn-common/yarn-default.xml)
[Set up 3 Node Cluster](https://www.linode.com/docs/guides/how-to-install-and-set-up-hadoop-cluster/)
[Python with Hive](https://www.softkraft.co/python-with-hive/)
[Hive by Example](https://sparkbyexamples.com/apache-hive-tutorial/)
[momijiame on github](https://gist.github.com/momijiame/0ff814ce4c3aa659723c6b5b0fc85557)
