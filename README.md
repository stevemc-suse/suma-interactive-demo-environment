# suma-demo-rodeo
Building out an interactive demo environment for SUMA.

To build out this environment you will need to know SUSE Manager or Uyuni.
You will also need access to AWS as this demo environment uses AWS EC2 machine, but can be adapted to use cloud in the future.

** suma-server
	- semi-automated deployment of suse manager

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
'zypper up' patch and reboot the node.  (Note this is a BYOS deployment)