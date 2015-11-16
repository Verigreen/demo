Verigreen Demo Environment
==========================

Setup
------

### Dependencies
- `docker`: Install `docker` for your distribution as described [here](https://docs.docker.com/installation/). The supported version of `docker` for this demo is **1.7.0**.
- `docker compose`: You need to install as it is explained [here](https://docs.docker.com/compose/#installation-and-set-up). The support version of `docker compose` for this demo is **1.3.1**.


### Download and Build

In order to run this demo. Clone it from our repository:

```
git clone https://github.com/Verigreen/demo.git
```


Then from the command line, run the following command to build the images in your local environment:

```
# Build images
sudo docker-compose -f demo.yml build
```

If you are building the demo behind your *corporate proxy* you will need to add your proxy settings to each of the docker files in the project *before your build*. This is to allow the statements in the docker files that download/install packages from the internet to work correctly. The lines should look something like this:

```
...
MAINTAINER Giovanni Matos http://github.com/gmatoshp

ENV HTTP_PROXY="http://<proxy-url>:<port>/" \
    HTTPS_PROXY="http://<proxy-url>:<port>/" \
    NO_PROXY="127.0.0.1, localhost, ..."

ENV VG_HOOK_HOME="/var/vg_hook/home" \
    VG_HOOK="/var/vg_hook/config" \
    VERIGREEN_VERSION="2.5.5" \
    ...
```

Add the list of internal ips/hostnames that you would like to access from your container to the `NO_PROXY` environment variable. The files that you need to modify are the following:

- `gitlab/Dockerfile`
- `jenkins/Dockerfile`
- `verigreen/Dockerfile`

### Bootstrap Assets

From the linux command line execute the following script:

```
./bootstrap-host.sh
```

This will bootstrap all the files (configuration files, ssh keys, etc) that you need to run the Verigreen demo containers under the `$HOME/.vg` directory and it will update your `$HOME/.ssh` with the demo ssh keys and configuration to interact with the demo repository. This script will attempt to **overwrite all files in `~/.vg`**, so please be careful.

Usage
-----

### Run
This demo environment uses [docker compose](https://docs.docker.com/compose/) to orchestrate the configuration and launch of the containers. You may run the demo environment as such:

```
# Run demo environment (all containers)
sudo docker-compose -f demo.yml up -d
```

You may access the container UIs at the following addresses:

- GitLab UI at [http://yourhostorip:10080](http://yourhostorip:10080)
- Jenkins UI at [http://yourhostorip:8086](http://yourhostorip:8086)
- Verigreen UI at [http://yourhostorip:8085](http://yourhostorip:8085)

If you would like to monitor the output of one of the containers you may tail its output by executing:

```
sudo docker logs -f <container-name>
```

> **IMPORTANT** The demo takes a few minutes to load all containers, so please be patient. One of the reasons is that we need the `gitlab` server to be up before loading the `verigreen` container.

### Stop

The following command will stop all containers in the demo.

```
sudo docker-compose -f demo.yml stop
```

To stop just one container, specify the name of the service in the `demo.yml` (e.g. `verigreen`, `gitlab`, or `jenkins`):

```
sudo docker-compose -f demo.yml stop verigreen
```


### Restart container

To ensure that we restart our containers correctly after a `docker-compose stop` you may issue the following command.

```
sudo docker-compose -f demo.yml up --no-recreate -d
```

This will restart all containers that were stopped. Note the `--no-recreate` flag which will restart the containers without creating them from scratch.

If you want to restart just one container that you stopped, you may do so by using the same command above.

### Cleanup Containers

```
# from the top of the verigreen/demo project run:
./reset_environment.sh
```


Getting with the Demo Environment
---------------------------------

|   service     |   username    |   password    |
| ------------- |   ----------  | ------------- |
| [GitLab UI](http://yourhostorip:10080)      |   verigreen_user  | verigreen     |
| [Jenkins Dashboard](http://yourhostorip:8086) | verigreen_user | verigreen |


- Visit the GitLab UI at [http://yourhostorip:10080](http://yourhostorip:10080) and make sure that the GitLab setup is complete. 
- Login to GitLab using the username and passwords listed *above*.
- Visit the demo repository's main page at `http://yourhostorip:10080/verigreen_user/verigreen-test-project`
- Click on the **SSH** option from the bottom right of the page and copy the ssh url (it should look something like this: `ssh://git@yourhostorip:10022/verigreen_user/verigreen-test-project.git`)
- Verify that your `$HOME/.ssh/config` file has the appropriate configuration to clone the repository. It should contain an entry similar to the following snippet. Please note that it is pointing to an ssh key that should be in your `$HOME/.ssh` directory. **All of these files should have been copied for you by the bootstrapping script**.

```
# Added by Verigreen demo bootstrap script
#-------------------------------------------------
Host localhost
User verigreen_user
IdentityFile ~/.ssh/vg_demo
#-------------------------------------------------
```


- Go to your command line in your Linux environment and clone the demo repository. To do it from the host where you are running the demo, run the following git command: `git clone ssh://git@yourhostorip:10022/verigreen_user/verigreen-test-project.git`.

> If you want to clone the repository from outside your current host, use a similar `~/.ssh/config` file as above, but adjust `localhost` to the **FQDN** or external IP of the host where the demo is running. Also, you need to copy the `vg_demo` private key and add it to the `~/.ssh` of the machine where you want to clone the git repository.

- Switch to the repository's directory `cd verigreen-test-project`
- For testing purposes, commit a new change to the local repository as such: `git commit --allow-empty --allow-empty-message`.
- Push the new commited change to the remote repository in GitLab: `git push origin master`
- You should get a message similar to this in your git output:

```
> git push origin master 
Counting objects: 5, done.
Writing objects: 100% (3/3), 277 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
remote: java -jar /var/vg_hook/home/git-hook.jar Dummy 5fee505aa739253139cb604583e48871780156e5 b89556da9610a94d22575f9657459da8c327c210 refs/heads/master
remote: =======================================
remote: 
remote: 
remote: Submitted for verification by Verigreen
remote: 
remote: 
remote: =======================================
remote: 
remote: 
To ssh://git@yourhostorip:10022/verigreen_user/verigreen-test-project.git
 ! [remote rejected] master -> master (pre-receive hook declined)
error: failed to push some refs to 'ssh://git@yourhostorip:10022/verigreen_user/verigreen-test-project.git'
>
```

- Now visit your Verigreen UI at [http://yourhostorip:8085](http://yourhostorip:8085) and check the status of your verification. You may inspect the **Status** column. It should reach a **FAILED** status eventually since the demo job that ships with this demo's Jenkins container is pre-configured to fail.

Known Issues
------------

Executing git commands through `ssh` protocol is sometimes blocked by corporate proxies. You might have to clone through `https` protocol which might be cumbersome in submitting commands to the Gitlab server.

TODO
----
- Add screenshots
- Advanced usage/configuration
