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