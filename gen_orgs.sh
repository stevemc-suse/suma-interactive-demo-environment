# This script need to be copied and ran on the SUSE Manager to automaticly generate the 'Orgnisations' 'Users & Passwords' for the external users.
##
# By Steve McBride - SUSE 
# steve.mcbride@suse.com 
##

#!/bin/bash

# Set the SUSE Manager server credentials
SM_USER="admin"
SM_PASSWORD="<suse manager password"

# Set the number of organizations and user details
NUM_ORGS=20
USER_PASSWORD="us3rPassw0rd"

# Function to execute spacecmd commands
execute_spacecmd() {
  spacecmd -q -u "$SM_USER" -p "$SM_PASSWORD" <<< "$1"
}

# Create organizations and users
for ((i=1; i<=NUM_ORGS; i++))
do
  ORG_NAME="Org$i"
  ORG_LABEL="org$i"
  USER_NAME="User$i"
  USER_FNAME="User$i"
  USER_LNAME="Org$i"
  USER_EMAIL="User$1@Org$i.net"

  # Create organization
  echo "Creating organization: $ORG_NAME"
  execute_spacecmd "org_create -n '$ORG_NAME' -u '$USER_NAME' -f '$USER_FNAME' -l '$USER_LNAME' -p '$USER_PASSWORD' -e '$USER_EMAIL'"
done
