# !/bin/bash
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

# Runs indefinitely updating the /etc/hosts entries 

cp /etc/hosts /etc/hosts.orig

forever_loop="0"
while [ "$forever_loop" -eq "0" ]
do
	docker0_ip=$(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}')
	echo "In $HOSTNAME: Updating Docker Bridge IP = $docker0_ip"
	verigreen_ip="$docker0_ip"
	cp /etc/hosts.orig /etc/hosts.temp
	echo "$verigreen_ip	$VERIGREEN_CONTAINER_HOSTNAME" | tee -a /etc/hosts.temp
	cp /etc/hosts.temp /etc/hosts
	rm -rf /etc/hosts.temp
	sleep 60
done