# vg-hook-gitlab
GitLab Docker Image with easy YAML configuration and Verigreen hook installed. 

# Setup:
This image is based on the GitLab image by Sameer Naik. Please follow the instructions in : ```https://github.com/sameersbn/docker-gitlab```
That should give you a working environment with a Postgres container, a Redis container and the GitLab container.

In order to get it working correctly you need to have a directory with any ssh keys you plan to use and a configuration file in yaml with the following format:

```yaml
admin:
   username: admin    
   password: verigreen 
   name: Gitlab Admin
   email: admin@yourcompany.com

# gitlab regular users(for pushing code)
users:
   - username: gitlab_user
     password: verigreen
     name: Original gitlab User
     email: gitlab_user@yourcompany.com
     ssh_key: user_id_rsa.pub

   - username: user1
     password: verigreen
     name: gitlab User Copy 1
     email: gitlab_user1@yourcompany.com
     #ssh_key: user1_id_rsa.pub

   - username: user2
     password: verigreen
     name: gitlab User Copy 2
     email: gitlab_user2@yourcompany.com
     #ssh_key: user2_id_rsa.pub

   - username: user3
     password: verigreen
     name: gitlab User Copy 3
     email: gitlab_user3@yourcompany.com
     #ssh_key: user3_id_rsa.pub

   - username: user4
     password: verigreen
     name: gitlab User Copy 4
     email: gitlab_user4@yourcompany.com
     #ssh_key: user4_id_rsa.pub

# Project and repository information
projects:
   - key: vg_test_project_1
     name: Verigreen Test Project
     desc: Project created to demonstrate Verigreen + Gitlab integration.
     owner: gitlab_user
     team_members:
        - username: user1
          access: MASTER

        - username: user2
          access: DEVELOPER

        - username: user3
          access: REPORTER

        - username: user4
          access: GUEST


#Proxy settings(optional)
#if either http or https proxy is set, and no_proxy is not set it defaults to 127.0.0.1,localhost
#if http is set but https isnt, then https is set to the same value as http.

http_proxy: your-http-proxy
https_proxy: your-https-proxy
no_proxy: your-no_proxy-string

# Hook properties
collector_address: your-verigreen-collector-address
``` 
To start the whole ecosystem first start the Postgres container:

```
sudo docker run --name=postgresql-gitlab -d \
  --env='DB_NAME=gitlabhq_production'\
  --env='DB_USER=gitlab' --env='DB_PASS=password'\
  --volume=/srv/docker/gitlab/postgresql:/var/lib/postgresql \
  sameersbn/postgresql:9.4
```
Then start the Redis container:
```
sudo docker run --name=redis-gitlab -d \
  --volume=/srv/docker/gitlab/redis:/var/lib/redis \
  sameersbn/redis:latest
```

Finally start the GitLab container:
```
sudo docker run --name='gitlab' -d \
  --link=postgresql-gitlab:postgresql --link=redis-gitlab:redisio \
  --publish=10022:22 --publish=10080:80 \
  --env='GITLAB_PORT=10080' --env='GITLAB_SSH_PORT=10022'\
  --volume=/srv/docker/gitlab/gitlab:/home/git/data \
  --volume=/path/to/config/directory:/var/gitlab/config \
  gitlab 

```

Give it a few minutes to start and setup.
Enjoy your very own GitLab server which automatically verifies your code with Verigreen!