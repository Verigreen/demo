#!/bin/bash

if [ -z "$GITLAB_CONTAINER_HOSTNAME" ]; then
	echo "ERROR: please specify the hostname of the Gitlab node in the GITLAB_CONTAINER_HOSTNAME environment variable."
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
	export no_proxy="$GITLAB_CONTAINER_HOSTNAME, $HOSTNAME, ${no_proxy}"
	export NO_PROXY="$GITLAB_CONTAINER_HOSTNAME, $HOSTNAME, ${NO_PROXY}"
fi

nohup bash $JENKINS_HOME/update_hosts.sh &
/usr/bin/supervisord