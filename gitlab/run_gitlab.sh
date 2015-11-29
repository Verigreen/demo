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

sudo docker run --name=postgresql-gitlab -d \
  --env='DB_NAME=gitlabhq_production'\
  --env='DB_USER=gitlab' --env='DB_PASS=password'\
  --volume=/srv/docker/gitlab/postgresql:/var/lib/postgresql \
  sameersbn/postgresql:9.4

sudo docker run --name=redis-gitlab -d \
  --volume=/srv/docker/gitlab/redis:/var/lib/redis \
  sameersbn/redis:latest

#sudo docker run --name='gitlab' -d \
sudo docker run --name='gitlab' -it \
  --link=postgresql-gitlab:postgresql --link=redis-gitlab:redisio \
  --publish=10022:22 --publish=10080:80 \
  --env='GITLAB_PORT=10080' --env='GITLAB_SSH_PORT=10022'\
  --volume=/srv/docker/gitlab/gitlab:/home/git/data \
  --volume=/home/giovanni/gitlab/config:/var/gitlab/config \
  gitlab 
