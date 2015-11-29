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

#FROM verigreen/jenkins:jenkins_v1.596.2-tomcat_v7.0.55-nginx_v1.7.12
FROM verigreen/jenkins:latest
MAINTAINER Ricardo Quintana http://github.com/rqc

RUN apt-get update && apt-get install -y \
										--fix-missing  \
										curl \
										unzip \
										bash \
										host \
										dnsutils \
										# supervisor \
										net-tools \
										&& \
										apt-get clean

ADD pre-entrypoint.sh $JENKINS_HOME/
ADD update_hosts.sh $JENKINS_HOME/
RUN chmod +x $JENKINS_HOME/pre-entrypoint.sh
RUN chmod +x $JENKINS_HOME/update_hosts.sh

CMD ./$JENKINS_HOME/pre-entrypoint.sh