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

source /home/git/gitlab-shell/hooks/set_env.sh
[[ ! -e "$VG_HOOK/hook.properties" ]] && echo "ERROR: please verify that you VG_HOOK points to a directory with a hook.properties file." && exit -1
[[ ! -e "$VG_HOOK_HOME/git-hook.jar" ]] && echo "ERROR: please verify that you VG_HOOK_HOME points to a directory with a git-hook.jar file." && exit -1

REPO="Dummy" #dummy value for now
read LINE;
echo $LINE >> $VG_HOOK_HOME/vg-git-hook.log
java -jar "$VG_HOOK_HOME/git-hook.jar" $REPO $LINE
