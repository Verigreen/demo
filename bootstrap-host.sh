#!/bin/bash
# # Bootstrap Vergireen Demo
# 
# ## Author(s)
# - Ricardo Quintana <ricardo.quintana@hp.com>
# 
# ## Description:
#
# This script creates a directory with all the necessary asset files that you need to run
# the Verigreen demo environment which is comprised of Verigreen container, GitLab container
# (with Verigreen Git-Hook), and a Jenkins master container.
#

assets_dir="$HOME/.vg"

echo "WARNING: Bootstrapping actions are not reversible."
echo "Make sure that you backup your configuration/data before continuing."
echo "Would like to continue? (Y/y for Yes, any other key for No):"

read continue_boot
if [[ "$continue_boot" == "y" || "$continue_boot" == "Y" ]]; then
	echo "Bootstrapping in progress..."
else
	echo "Exiting bootstrap process."
	exit -1
fi


function create_assets_dir {
	echo "Creating $assets_dir"
	mkdir -p "$assets_dir"
}

function bootstrap_vg {
	cp -Ri assets/vg $assets_dir
	echo "Finished bootstrapping for Verigreen!"
}

function bootstrap_jenkins {
	cp -Ri assets/jenkins $assets_dir
	echo "Finished bootstrapping for Jenkins!"
}

function bootstrap_gitlab {	
	cp -Ri assets/gitlab $assets_dir
	echo "Finished bootstrapping for GitLab!"
}

function bootstrap_data {
	# TODO: need to add cacheloader directory
	mkdir -p $assets_dir/data/jenkins
	mkdir -p $assets_dir/data/gitlab
	echo "Finished bootstrapping for data directories for Jenkins and GitLab!"
}

function cleanup_data {
	# TODO: need to add cacheloader directory
	sudo rm -rf $assets_dir/data
	echo "Finished cleaning up data directories for Jenkins and GitLab!"
}

function cleanup_assets {
	rm -rf $assets_dir/jenkins
	rm -rf $assets_dir/gitlab
	rm -rf $assets_dir/vg
	echo "Finished cleaning up assets for GitLab, Verigreen, and Jenkins"
}

function cleanup {
	cleanup_data
	cleanup_assets
}

function bootstrap_dot_ssh {
	mkdir -p $HOME/.ssh
	chmod 700 $HOME/.ssh
	cp -Ri assets/vg/ssh/vg_demo $HOME/.ssh
	cp -Ri assets/vg/ssh/vg_demo.pub $HOME/.ssh
	[[ -z "$(cat $HOME/.ssh/config | grep -m 1 vg_demo)" ]] && echo -e "\n" >> $HOME/.ssh/config && \
		cat assets/vg/ssh/config_external | tee -a $HOME/.ssh/config
	chmod 600 $HOME/.ssh/config
	chmod 600 $HOME/.ssh/vg_demo
	chmod 600 $HOME/.ssh/vg_demo.pub
}

case $1 in
	vg)
		create_assets_dir
		bootstrap_vg
	;;
	jenkins)
		create_assets_dir
		bootstrap_jenkins
	;;
	gitlab)
        create_assets_dir
        bootstrap_gitlab
    ;;
	data)
		create_assets_dir
		bootstrap_data
	;;
	ssh)
		bootstrap_dot_ssh
	;;	
	cleanup_data)
		cleanup_data
	;;	
	cleanup_assets)
		cleanup_assets
	;;	
	cleanup)
		cleanup
	;;
	*)
		create_assets_dir
		bootstrap_vg
		bootstrap_jenkins
		bootstrap_data
		bootstrap_dot_ssh
		bootstrap_gitlab
	;;	
esac

exit 0