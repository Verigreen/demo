#!/bin/bash
#*******************************************************************************
# Copyright 2015 Hewlett Packard Enterprise Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#*******************************************************************************

# Refactor this into a separate script and use it in both docker-entrypoint and in this run.sh
function download_git_remote_ssh_key {

	SSH_KNOWN_HOSTS="$ROOT_SSH_DIR/known_hosts"

	# Grab the domain
	domain=$(echo "$1" | awk -F/ '{print $3}')

	# But it could have the username and port, so just extract the domain
	echo $domain | grep "@" > /dev/null

	if [ $? -eq 0 ]; then
		domain=$(echo $domain | awk -F@ '{print $2}') 
	else
		echo "No username found, continuing."
	fi

	# If it has the port, SSH needs that port to extract the fingerprint (e.g. from GitLab and not the sshd server)
	echo $domain | grep ":" > /dev/null
	[ $? -eq 0 ] && domain_port="$domain" && port=$(echo $domain | awk -F: '{print $2}')  && domain=$(echo $domain | awk -F: '{print $1}') || echo "No port found, continuing."

	# Do some verification that all ssh configuration is consistent.
	cat "$SSH_CONFIG_FILE" | grep "$domain" > /dev/null

	if [ $? -ne 0 ]; then
		echo "${VG_WARNING} $SSH_CONFIG_FILE does not have an entry for domain/IP address $domain. This could cause issues."
	fi

	# Determine if our domain is an IP address or a FQDN hostname.
	# Regular expression based on these restrictions: http://en.wikipedia.org/wiki/Hostname#Restrictions_on_valid_host_names
	# Most restrictions enforced.
	# Domains that are just one label are not supported (e.g. node1, verigreen).
	temp_domain=$(echo "$domain" | awk '/^([A-Za-z0-9]+([\-]{1}[A-Za-z0-9]+)*[A-Za-z0-9]*)([\.]{1}[A-Za-z0-9]+([\-]{1}[A-Za-z0-9]+)*[A-Za-z0-9]+)*$/ {print $1}')

	if [ ! -z "$temp_domain" ]; then
		# If it is a hostname with a domain name that is passed, retrieve the ip addresses.
		ip_addresses=($(host $domain | awk -F' has address ' '{print $2}'))
		ip_addresses+=("$domain")
	else
		# Determine if it looks like an IP address.
		temp_ip=$(echo $domain | awk '/^[0-9]{1,3}(\.[0-9]{1,3}){3}$/ {print $1}')
		if [ ! -z "$temp_ip" ]; then 
			# If it is an IP address that is being used in the url, then use that instead.
			ip_addresses=("$domain")
		else
			echo "ERROR: $domain does not look like a valid domain or IP address. Please verify your run.yml configuration."
			exit -1
		fi
	fi

	# Iterate over all IP addresses and domains and add them to the `~/.ssh/known_hosts` appropriately.
	for ip_address in "${ip_addresses[@]}"; do

		# Scan the Git server and save the fingerprint to the `~/.ssh/known_hosts` file
		# This will avoid SSH to ask the user for input upon a *new* host connection.
		# **WARNING**: `ssh-keyscan` outputs the key in a non-standard format. 
		# For this reason, we need to format the output so that `JGit/JCSH` likes the format of the key in `~./ssh/known_hsots` as explained [here](http://sourceforge.net/p/jsch/bugs/63/).
		if [ -z "$port" ]; then
			# No port option, no domain + port and no ip address + port will default `awk` `sub` to replace to same value.
			# domain_port="$domain"
			ip_address_port="$ip_address"
		else
			# Add port option
			# Format the entry correctly
			port_option="-p $port"
			# domain_port="[$domain]:$port"
			ip_address_port="[$ip_address]:$port"
		fi

		echo "SUCCESS: Found ip address or domain $ip_address_port"

		# Grab git remote's public key and store it in `$SSH_KNOWN_HOSTS` for `ip_address` + `port`
		ssh-keyscan -t ssh-rsa "$port_option" "$ip_address" | awk -v ip_address="$ip_address" -v ip_address_port="$ip_address_port" '{sub(ip_address,ip_address_port)}1' | tee -a $SSH_KNOWN_HOSTS > /dev/null
		if [ $? -ne 0 ]; then
			echo "ERROR: could not retrieve ssh key from $ip_address_port."
			exit -1
		else
			echo "SUCCESS: Retrieved ssh key from $ip_address_port and stored it in $SSH_KNOWN_HOSTS."
		fi

	done

	echo "SUCCESS: Retrieved ssh key for $ip_address_port and stored it in $SSH_KNOWN_HOSTS"	
}

if [ -z "$GITLAB_CONTAINER_HOSTNAME" ]; then
	echo "ERROR: please specify the hostname of the GitLab node in the GITLAB_CONTAINER_HOSTNAME environment variable."
	exit -1
fi

if [ -z "$JENKINS_CONTAINER_HOSTNAME" ]; then
	echo "ERROR: please specify the hostname of the Jenkins node in the JENKINS_CONTAINER_HOSTNAME environment variable."
	exit -1
fi

if [ ! -z "$http_proxy" ] || \
	[ ! -z "$https_proxy" ] || \
	[ ! -z "$ftp_proxy" ] || \
	[ ! -z "$no_proxy" ] || \
	[ ! -z "$HTTP_PROXY" ] || \
	[ ! -z "$HTTPS_PROXY" ] || \
	[ ! -z "$FTP_PROXY" ] || \
	[ ! -z "$NO_PROXY" ]
	then
	echo "WARNING: we found a proxy configured, adding hostnames to no_proxy."
	export no_proxy="${GITLAB_CONTAINER_HOSTNAME}, ${JENKINS_CONTAINER_HOSTNAME}, $HOSTNAME, ${no_proxy}"
	export NO_PROXY="${GITLAB_CONTAINER_HOSTNAME}, ${JENKINS_CONTAINER_HOSTNAME}, $HOSTNAME, ${NO_PROXY}"
	# TODO: revise these options
	export CATALINA_OPTS="$CATALINA_OPTS -Dhttp.nonProxyHosts=127.0.0.1\|localhost\|$JENKINS_CONTAINER_HOSTNAME\|192.168.*.*\|10.*.*.*"
	export JAVA_OPTS="$JAVA_OPTS -Dhttp.nonProxyHosts=127.0.0.1\|localhost\|$JENKINS_CONTAINER_HOSTNAME\|192.168.*.*\|10.*.*.*"
fi
#start sendmail
service sendmail start

nohup bash update_hosts.sh & 

# Loop until Jenkins is up
jenkins_response="1"
while [ "$jenkins_response" -eq "1" ]
do
	# TODO: should not hardcode port for Jenkins.
	# TODO: add time limit
	# TODO: probably should look for a better identifier than Log in
	# curl -SLs "${JENKINS_CONTAINER_HOSTNAME}:8081" | grep "log in" &> /dev/null
	curl -s --head --request GET "${JENKINS_CONTAINER_HOSTNAME}:8086" | grep "200 OK"
	jenkins_response=$?

	if [ "$jenkins_response" -eq "1" ] 
	then
		echo "INFO: waiting until Jenkins loads up at ${JENKINS_CONTAINER_HOSTNAME}:8086."
		sleep 30
	fi
done

echo "SUCCESS: jenkins loaded up correctly."

# Loop until GitLab is up
gitlab_response="1"
while [ "$gitlab_response" -eq "1" ]
do
	# TODO: should not hardcode port for GitLab.
	# TODO: add time limit
	# TODO: probably should look for a better identifier than Log in
	curl -SLs "${GITLAB_CONTAINER_HOSTNAME}:10080" | grep "email" &> /dev/null
	gitlab_response=$?

	if [ "$gitlab_response" -eq "1" ] 
	then
		echo "INFO: waiting until Gitlab loads up at ${GITLAB_CONTAINER_HOSTNAME}:10080."
		sleep 30
	fi
done

echo "SUCCESS: gitlab loaded up correctly."

remote_repository_url="$(cat $VG_HOME/run.yml | grep "remote_url" | awk -F': ' '{print $2}' | awk '{gsub(/\"/,""); print}' )"

# Wait until repo is created by GitLab startup script.
cp -Rf $VG_SSH/* $ROOT_SSH_DIR
chmod 600 $ROOT_SSH_DIR/*
download_git_remote_ssh_key "$remote_repository_url"
tmp_clone="/tmp/temp_repo"
git_clone_response="1"

git config --global user.email "verigreen@github.com"
git config --global user.name "Verigreen Verifier"

while [ ! -d "$tmp_clone/.git" ]
do
	rm -rf $tmp_clone
	git clone "$remote_repository_url" $tmp_clone
	echo "Verigreen is waiting for repository to be available..."
	sleep 30
done

# TODO: make check that the repository is blank before doing this.
back=$PWD
cd $tmp_clone && echo "Hello Verigreen!" > hello.txt && git add --all && git commit -m "Initial commit." && git push origin master

cd $back

rm -rf $tmp_clone


bash $APP_DIR/docker-entrypoint.sh
