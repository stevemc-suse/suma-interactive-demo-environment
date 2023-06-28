# suma-demo-rodeo

# THIS IS BEING UPDATED (REWRITE)

Building out an interactive demo environment for SUMA.

To build out this environment you will need to know SUSE Manager or Uyuni.
You will also need access to AWS as this demo environment uses AWS EC2 machine, but can be adapted to use cloud in the future.



## 1. Edit the 'terraform.tfvars'

	# AWS access key used to create infrastructure
	aws_access_key = "<key>"

	# AWS secret key used to create AWS infrastructure
	aws_secret_key = "<key>"

	# AWS region used for all resources
	aws_region = "eu-west-1"

	# SUSE Manager Subscription Key
	suse_manager_subscription = "<key>"

##### [Note] The build has been currently tested on AWS eu-west-1 the ami images used might need to be changed for you local region.

##### [note]  SUSEConnect subscription registration of the SUSE Manager Server is part of the automation also the sle-module-public-cloud are loaded in the terraform deployment as well.

	Run 'terraform init'
	Run 'terraform plan' 
	Run 'terraform init'
	
The process will deploy the following. 

```mermaid 
flowchart 

A[SCC] -->|internet| B(Security Goups)
B --> C{SUMA}
C <-->|LAN| D[suma-monsrv]
C <-->|LAN| E[suma-proxy]
C <-->|LAN| G[suma-client x 40]

```

- SUSE Manager server 4CPU 16GB Mem, bootdisk, datadisk (suma)
- SUSE Manaer Proxy Server 1CPU 4GBMem, bootdisk, datadisk (suma-proxy)
- SUSE Manager Monitor Server 1CPU 4GB MeM, bootdisk (suma-monsrv)
- SUSE Manager Client Machines.  You the number of machine deployed can be changed int the 'infra.tf' look for 'count = 1' [# Tested with 50 instances]
	- SLE15SP3 
	- SLE15SP4
 
 Once the deployment has completed you will have several machines that are ready to go, all machines have has the /etc/hosts file updated with the SUSE Manager Server details as currently there is no DNS on the virtual machine network [Working on changing this.]

##### Now attach a AWS Elastic IP to the node.

Connect to the server via ssh using your 'demo-suma.pem' this is automaticly generated and located in the 'terraform.tfstate.d' directory within you deployment directory.

	- 'zypper up' patch and reboot the node.  (Note this is a BYOS deployment)


##### Prepare storage volumes [Future plan to automate this]

	-- hwinfo --disk | grep -E "Device File:"
	-- /usr/bin/suma-storage <devicename>

##### Example: 
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

Now run 'zypper up' and patch the system once done reboot the instance. 

Reconnect:

- Installing SUSE Manager follow the public cloud docs: 
	https://documentation.suse.com/suma/4.3/en/suse-manager/installation-and-upgrade/pubcloud-setup.html

