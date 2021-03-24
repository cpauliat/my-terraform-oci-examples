#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Get argument(s) passed thru metadata"
OPC_PASSWORD=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_opc_password`
OL7_PRIVATE_IP=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_ol7_private_ip`

echo "========== Set opc password"
echo $OPC_PASSWORD | passwd --stdin -f opc

echo "========== Install zsh"
yum install -y zsh

echo "========== Create 2 applications in SGD and publish it to all users"
# icons in /opt/tarantella/webserver/tomcat/default/webapps/sgd/resources/images/icons
tarantella object new_host --name "o=appservers/cn=OL7_private" --address $OL7_PRIVATE_IP --available true

tarantella object new_xapp --name "o=applications/cn=OL7: Terminal" --description "Terminal on OL7 private instance" \
                           --app /usr/bin/gnome-terminal --width 800 --height 400 --appserv "o=appservers/cn=OL7_private" \
                           --icon graphterm.gif --method ssh #--allowunsecuressh true
tarantella object add_member --name "o=applications/cn=applications" --member "o=applications/cn=OL7: Terminal"

tarantella object new_xapp --name "o=applications/cn=OL7: Graphical session" --description "Gnome session on OL7 private instance" \
                           --app /usr/bin/gnome-session --width 1800 --height 800 --appserv "o=appservers/cn=OL7_private" \
                           --icon graphapp.gif --method ssh #--allowunsecuressh true
tarantella object add_member --name "o=applications/cn=applications" --member "o=applications/cn=OL7: Graphical session"

tarantella object new_xapp --name "o=applications/cn=OL7: Firefox" --description "Firefox on OL7 private instance" \
                           --app /usr/bin/firefox --width 1000 --height 800 --appserv "o=appservers/cn=OL7_private" \
                           --icon firefox.gif --method ssh \      
                           --xrandr true --resumable always --displayusing multiplewindows --winmgr /usr/bin/mwm
tarantella object add_member --name "o=applications/cn=applications" --member "o=applications/cn=OL7: Firefox"

echo "========== Rename some exising applications in SGD"
tarantella object rename --name "o=applications/cn=Firefox" --newname "o=applications/cn=SGD: Firefox"
tarantella object rename --name "o=applications/cn=Terminal" --newname "o=applications/cn=SGD: Terminal"

echo "========== Remove some exising applications in SGD"
tarantella object remove_member --name "o=applications/cn=applications" --member "o=applications/cn=Text Editor"
tarantella object remove_member --name "o=applications/cn=applications" --member "o=applications/cn=SSH Console"

echo "========== Apply latest OS updates"
yum update -y

echo "========== Final reboot (needed by yum update)"
reboot


