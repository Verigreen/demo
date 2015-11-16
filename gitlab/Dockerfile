FROM sameersbn/gitlab:7.11.4-1
MAINTAINER Giovanni Matos http://github.com/gmatoshp

ENV VG_HOOK_HOME="/var/vg_hook/home" \
    VG_HOOK="/var/vg_hook/config" \
    VERIGREEN_VERSION="2.5.5" \
    VG_HOOK_EXE="vg_hook.sh" \
    GITLAB_CONFIG_PATH="/var/gitlab/config"
 
# Install packages
RUN apt-get update && \
    apt-get install -y openjdk-7-jdk nano \
            python-yaml python-requests

# Setup the hook
RUN mkdir -p $VG_HOOK && \
    mkdir -p $VG_HOOK_HOME && \
    mkdir -p $GITLAB_CONFIG_PATH && \

    curl -sSL https://github.com/Verigreen/verigreen/releases/download/verigreen-$VERIGREEN_VERSION/verigreen-git-hook.tar.gz -o /tmp/verigreen-git-hook.tar.gz && \
    cd /tmp && \
    tar -xzvf verigreen-git-hook.tar.gz -C /tmp/git-hook && \
    chmod +x /tmp/git-hook/* && \
    cp git-hook/* $VG_HOOK_HOME

ADD vg_hook.sh vg_hook.sh

# Create source file for setting environmental variables as it's not inherited in gitlab
RUN echo "export VG_HOOK=$VG_HOOK" > set_env.sh && \
    echo "export VG_HOOK_HOME=$VG_HOOK_HOME" >> set_env.sh && \
    chmod a+x set_env.sh && \
    chown git.git set_env.sh && \
    mv set_env.sh /home/git/gitlab-shell/hooks

# Overwrite the default pre-receive hook
RUN mv vg_hook.sh pre-receive && \ 
    chown git.git pre-receive && \
    chmod a+x pre-receive && \
    mv pre-receive /home/git/gitlab-shell/hooks/ 
RUN chown -R git.git $VG_HOOK_HOME
ADD run.sh run.sh
ADD setup.py setup.py
ADD update_hosts.sh update_hosts.sh
RUN chmod a+x run.sh
CMD ["/home/git/gitlab/run.sh"]
