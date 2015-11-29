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

#need to create the hook.properties file based on the yaml configuration

yaml_file='/var/gitlab/config/config.yml'

if [[ ! -e "$yaml_file" ]]; then
    echo "ERROR: Configuration file $yaml_file not found, unable to start gitlab."
    exit -1
fi
nohup bash update_hosts.sh &
python setup.py &
/app/init app:start