This infrastructure as a code project creates hadoop cluster of three nodes. 
On top is yarn resource manager. 
Hive is used to manage databases.
Flask app is created to upload pictures to hive.

Vagrantfile contains the ruby code that creates the infrastructure. 
The rest of provisioning scrips lie in bootstrap.sh.
xml files for hadoop are in hadoopxml and for hive they are in hivexml.
samplesite is the folder that contains the flask mini app files.

