# suma-demo-rodeo
Building out an interactive demo environment for SUMA.

To build out this environment you will need to know SUSE Manager or Uyuni.
You will also need access to AWS as this demo environment uses AWS EC2 machine, but can be adapted to use cloud in the future.

 suma-server
	 semi-automated deployment of suse manager

1. Edit the 'terraform.tfvars'
	- AWS Key
	- AWS Secret 
	- SUSE Manager Subscription Key

You will need to generate a 'suma-demo.pem' file in aws and makesure to download this to root of the deployment directory replaceing dummy.pem

Run 'terraform init' and wait for the modules to load. 
(optional) Run terraform plan 

Now deploy the SUSE Manager Server. 

Run 'terrform apply' monitor the AWS portal, your machine should now be deploying. 

Once done: 

Now attach a AWS Elastic IP to the node.

connect to the server via ssh using your 'demo-suma.pem' One in run the folowing to update your SUSE Manager server. 

- 'zypper up' patch and reboot the node.  (Note this is a BYOS deployment)
-  update /etc/hosts with the local IP fqdn hostname (https://documentation.suse.com/suma/4.3/en/suse-manager/installation-and-upgrade/pubcloud-requirements.html)
-  Prepare storage volumes
-- hwinfo --disk | grep -E "Device File:"
-- /usr/bin/suma-storage <devicename>

Now run 'zypper up' and patch the system once done reboot the instance. 

Reconnect:

- Installing SUSE Manager follow the public cloud docs: 
	https://documentation.suse.com/suma/4.3/en/suse-manager/installation-and-upgrade/pubcloud-setup.html

[note]  SUSEConnect subscription registration and the sle-module-public-cloud are done in the terraform deployment.

example: 
suma:~ # hwinfo --disk | grep -E "Device File:"
  Device File: /dev/nvme0n1
  Device File: /dev/nvme1n1

suma:~ # /usr/bin/suma-storage /dev/nvme1n1
--> Checking disk for content signature
--> Creating partition on disk /dev/nvme1n1
--> Creating xfs filesystem
--> Mounting storage at /manager_storage
--> Syncing SUSE Manager Server directories to storage disk(s)
--> Creating entry in /etc/fstab





