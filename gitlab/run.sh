#need to create the hook.properties file based on the yaml configuration

yaml_file='/var/gitlab/config/config.yml'

if [[ ! -e "$yaml_file" ]]; then
    echo "ERROR: Configuration file $yaml_file not found, unable to start gitlab."
    exit -1
fi
nohup bash update_hosts.sh &
python setup.py &
/app/init app:start