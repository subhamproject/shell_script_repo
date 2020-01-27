# check if job exists
curl -XGET 'http://jenkins/checkJobName?value=yourJobFolderName' --user user.name:YourAPIToken

# with folder plugin
curl -s -XPOST 'http://jenkins/job/FolderName/createItem?name=yourJobName' --data-binary @config.xml -H "Content-Type:text/xml" --user user.name:YourAPIToken

# without folder plugin
curl -s -XPOST 'http://jenkins/createItem?name=yourJobName' --data-binary @config.xml -H "Content-Type:text/xml" --user user.name:YourAPIToken

# create folder
curl -XPOST 'http://jenkins/createItem?name=FolderName&mode=com.cloudbees.hudson.plugins.folder.Folder&from=&json=%7B%22name%22%3A%22FolderName%22%2C%22mode%22%3A%22com.cloudbees.hudson.plugins.folder.Folder%22%2C%22from%22%3A%22%22%2C%22Submit%22%3A%22OK%22%7D&Submit=OK' --user user.name:YourAPIToken -H "Content-Type:application/x-www-form-urlencoded"


# see http://jenkins/api/
#https://support.cloudbees.com/hc/en-us/articles/218353308-How-to-update-job-config-files-using-the-REST-API-and-cURL-




# check if job exists
curl -XGET 'http://jenkins/checkJobName?value=yourJobFolderName' --user user.name:YourAPIToken

# with folder plugin
curl -s -XPOST 'http://jenkins/job/FolderName/createItem?name=yourJobName' --data-binary @config.xml -H "Content-Type:text/xml" --user user.name:YourAPIToken

# without folder plugin
curl -s -XPOST 'http://jenkins/createItem?name=yourJobName' --data-binary @config.xml -H "Content-Type:text/xml" --user user.name:YourAPIToken

# create folder
curl -XPOST 'http://jenkins/createItem?name=FolderName&mode=com.cloudbees.hudson.plugins.folder.Folder&from=&json=%7B%22name%22%3A%22FolderName%22%2C%22mode%22%3A%22com.cloudbees.hudson.plugins.folder.Folder%22%2C%22from%22%3A%22%22%2C%22Submit%22%3A%22OK%22%7D&Submit=OK' --user 'user.name:YourAPIToken' -H "Content-Type:application/x-www-form-urlencoded"

# remove folder / job
curl -XPOST 'http://jenkins/job/FolderName/doDelete' --user 'user.name:YourAPIToken'

# trigger remote job
curl 'http://jenkins/job/yourJobName/build?delay=0sec' --user 'user.name:YourAPIToken'


# Get current config
curl -X GET http://developer:developer@localhost:8080/job/test/config.xml -o mylocalconfig.xml

# Post updated config
curl -X POST http://developer:developer@localhost:8080/job/test/config.xml --data-binary "@mymodifiedlocalconfig.xml"

curl "http://localhost:18080/jenkins/job/npm-package-aaa/config.xml" -si --data-binary "$XML" -H "Content-Type: text/xml" 


curl -X GET http://anthony:anthony@localhost:8080/jenkins/job/pof/config.xml -o config.xml
curl -X POST http://anthony:anthony@localhost:8080/jenkins/job/pof/config.xml --data-binary "@config.xml"


#Get the current configuration and save it locally
curl -X GET http://user:password@hudson.server.org/job/myjobname/config.xml -o mylocalconfig.xml
 
#Update the configuration via posting a local configuration file
curl -X POST http://user:password@hudson.server.org/job/myjobname/config.xml --data-binary "@mymodifiedlocalconfig.xml"
 
#Creating a new job via posting a local configuration file
curl -X POST "http://user:password@hudson.server.org/createItem?name=newjobname" --data-binary "@newconfig.xml" -H "Content-Type: text/xml"
