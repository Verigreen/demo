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
