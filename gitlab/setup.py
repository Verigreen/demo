#this will eventually be a full blown setup program

import time
import yaml
import os
import sys
import requests
import re
import json

#define access levels, as per the gitlab documentation
access_levels = {}
access_levels['GUEST'] = 10
access_levels['REPORTER'] = 20
access_levels['DEVELOPER'] = 30
access_levels['MASTER'] = 40
access_levels['OWNER'] = 50

try:
   config_file = os.environ['GITLAB_CONFIG_PATH'] + "/config.yml"
   with open(config_file,'r') as configuration_file:      
      config = yaml.load(configuration_file) 
      if config is None:
         print "no config"
         exit(-1)
except Exception as e:
# If the config file cannot be imported as a dictionary, bail!
   print e
   sys.exit(-1)

#setup proxy settings
if 'http_proxy' in config or 'https_proxy' in config:
   if 'http_proxy' in config:
      os.environ['http_proxy'] = config['http_proxy']
      os.environ['HTTP_PROXY'] = config['http_proxy']
   else:
      os.environ['http_proxy'] = config['https_proxy']
      os.environ['HTTP_PROXY'] = config['https_proxy']
   if 'https_proxy' in config:
      os.environ['https_proxy'] = config['https_proxy']
      os.environ['HTTPS_PROXY'] = config['https_proxy']
   else:
      os.environ['https_proxy'] = config['http_proxy']
      os.environ['HTTPS_PROXY'] = config['http_proxy']
   if 'no_proxy' in config:
      os.environ['no_proxy'] = config['no_proxy']
      os.environ['NO_PROXY'] = config['no_proxy']
   else: 
      os.environ['no_proxy'] = "127.0.0.1,localhost"
      os.environ['NO_PROXY'] = "127.0.0.1,localhost"
if not 'collector_address' in config:
   print "[Error]: Collector address not found in configuration file" 
   sys.exit(-1)

with open(os.environ['VG_HOOK']+"/hook.properties",'w') as f:
   f.write("collector.address="+ config['collector_address'])


limit = 600 #10 minute timeout by default
total_time =0
wait_time = 10
url = "http://localhost"
preg = re.compile('/sign_in\Z')
success = False
while total_time < limit:    
   try: 
      r = requests.get(url)   
      if preg.search(r.url):
         success = True
         break
      if r:
         print r.url   
   except Exception as e:
      pass
   total_time+=wait_time
   time.sleep(wait_time) 
   
if not success:
    print "gitlab failed to start"
    sys.exit(-1)
print "Gitlab is up, starting setup"
api = "http://localhost/api/v3/"
com = "session"
req = api + com      

auth = {'login':'root',
        'password':'5iveL!fe'
       }
try:
   r = requests.post(req,
                data = auth
                )
   token =  r.json()['private_token']
   print "got token"
except Exception as e:
   print "failure" 
   print e
   print r.text
   sys.exit(-1)

header = {'PRIVATE-TOKEN':token}

# Modify root
if 'admin' in config and 'password' in config['admin']:
   #first get root id(i'm guessing zero....but who knows...)
   com =  "/users?search=root"
   req = api + com
   try:
      r = requests.get(req, headers = header)
      root_id = r.json()[0]['id']
   except Exception as e:
      print e   
   if 200 == r.status_code:
      com = "users/"+str(root_id)
      req = api + com
      try:
         root_data = {'name':config['admin']['name'],
                      'password':config['admin']['password'],
                      'admin':'true'
                     }
         r = requests.put(req,root_data,headers = header) 
      except Exception as e:
         print e

# Create the users
com = "users"
req = api + com
user_ids = {}
for user in config['users']:
   user_data = {'email':user['email'],
               'password':user['password'],
               'username':user['username'],
               'name':user['name'],
               'confirm':'false'} 
   try:
      r = requests.post(req,data = user_data, headers = header)
      if 201 == r.status_code:
         print "User successfully created"
         user_ids[user['username']] = r.json()['id']
      else:
         print "Unable to create user:"   
         print r.text
         print r.json()['id']
   except Exception as e:
      print e
   #add user ssh key(if available)
   if 'ssh_key' in user:
      if os.path.isfile('/var/gitlab/config/'+user['ssh_key']):
         with open('/var/gitlab/config/'+user['ssh_key'],"r") as myfile:
            ssh_key_command = "users/"+str(user_ids[user['username']])+"/keys"
            ssh_key_req = api + ssh_key_command
            data=myfile.read().replace('\n','')
            ssh_key_data = {'id':user_ids[user['username']],
                            'title':user['username'],
                            'key':data
                            }
            r = requests.post(ssh_key_req,data = ssh_key_data,headers = header)
            if 201 == r.status_code:
               print "SSH key successfully added"
            else:
               print "Unable to add ssh key:"
               print r.text


# Create projects
com = "projects"
req = api + com
for project in config['projects']:
   print project
   com = "projects"
   req = api + com
   project_data = {'name':project['name'],
                   'namespace_id':user_ids[project['owner']]
   }
   try:
      r = requests.post(req, data = project_data, headers = header)
      if 201 == r.status_code:
         print "Project successfully created" 
         project_id = r.json()['id']
      else:
         print "Unable to create project:"   
         print r.text
   except Exception as e:
      print e

    #add team members, if any, with their respective levels of access
    # valid levels of access are: Master, Developer, Reporter, Guest
   for member in project['team_members']:
      com = "projects/"+str(project_id)+"/members"
      req = api + com
    #need to find the user id based on the username
      member_data = {'id':str(project_id),
                      'user_id':str(user_ids[member['username']]),
                      'access_level':access_levels[member['access']]
                       } 
      try:
         r = requests.post(req, data = member_data, headers = header)
         if 201 == r.status_code:
            print "Member successfully added" 
         else:
            print "Unable to add member:"
            print r.status_code
            print r.text
      except Exception as e:
         print e

print "setup complete"        
#curl http://localhost/api/v3/session --data-urlencode 'login=root' --data-urlencode 'password=verigreen' | jq --raw-output .private_token
