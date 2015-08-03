sudo docker stop gitlab
sudo docker rm gitlab
sudo docker stop redis-gitlab
sudo docker rm redis-gitlab
sudo docker stop postgresql-gitlab
sudo docker rm postgresql-gitlab
sudo rm -rf /srv/docker/gitlab/*
