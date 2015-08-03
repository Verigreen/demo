sudo docker rm -fv $(sudo docker ps -aq)
sudo rm -rf $HOME/.vg
./bootstrap-host.sh
