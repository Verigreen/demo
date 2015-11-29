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

FROM verigreen/vg-collector:2.5.5
MAINTAINER Ricardo Quintana http://github.com/rqc

RUN apt-get update && apt-get install -y \
										--fix-missing  \
										curl \
										unzip \
										bash \
										host \
										dnsutils \
										net-tools \
                                        sendmail \
										&& \
										apt-get clean

WORKDIR $VG_ROOT

ADD pre-entrypoint.sh pre-entrypoint.sh
ADD update_hosts.sh update_hosts.sh
RUN chmod +x pre-entrypoint.sh
RUN chmod +x update_hosts.sh

CMD ["./pre-entrypoint.sh"]