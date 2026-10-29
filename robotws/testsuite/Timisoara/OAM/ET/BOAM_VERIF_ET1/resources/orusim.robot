*** Settings ***
Library        String
Library        OperatingSystem
Library        BuiltIn
Library        DateTime
Library        OperatingSystem
Library        SSHLibrary
Library        taf.transport.ssh    WITH NAME    ssh

Library     XML    use_lxml=True
Library        Process
Library        taf.gnb.oam.coam.admin.interface.admin   WITH NAME   taf_admin


*** Variables ***

${O-RU_username}=                oru
${O-RU_password}=                orusim12
${SYSTEM_ALIAS_ORU}=             oru
${command_start_docker}  echo ${O-RU_password} | sudo -S docker run --rm --name=orusim --volume=/home/oru/docker_share/orusim:/etc/orusim
     ...     --detach --privileged --network=bridge airphone-docker-local.artifactory-espoo1.int.net.nokia.com/orusim:v2.0.18
${command_stop_docker}  echo ${O-RU_password} | sudo -S docker stop orusim    #sudo docker kill orusim
${command_enter_docker}  echo ${O-RU_password} | sudo docker exec -it orusim /bin/bash
${command_status_docker}  echo | supervisorctl status all
${ssh_alias}  sshenb
### !! for both oru1 default file is xranuser3.xml
${command_set_default_oru1}      sed -i 's/orusim.*/orusim\\/xranuser3.xml<\\/startup_snapshot>/g' ~/docker_share/orusim/orusim-config.xml
${command_set_default_oru2}      sed -i 's/orusim.*/orusim\\/default_snapshot_v2_for6943D.xml<\\/startup_snapshot>/g'
...  ~/docker_share/orusim/orusim-config.xml

*** Keywords ***

Configure_O-RU_default
    [Arguments]    ${oru}
    Run Keyword If  '${oru}' == '10.5.55.152' or '${oru}' == '10.5.53.235'
     ...   SYSTEM Start Command On o-ru  command=${command_set_default_oru1}  hostname=${oru1}
     ...   ELSE IF   '${oru}' == '10.5.53.238'
     ...   SYSTEM Start Command On o-ru  command=${command_set_default_oru2}  hostname=${oru2}
     ...   ELSE
     ...   Log to console  Oru not set by default !
     
Check_and_Start_O-RU_container
    [Arguments]    ${oru}
## *** Check if O-RU is started
     Log to console  Check status for :${oru}
     ${reply}=  SYSTEM Start Command On o-ru
     ...    hostname=${oru}
     ...    command=echo ${O-RU_password} | sudo -S docker ps -a     #sudo docker ps -a

## *** If O-RU is not started ... START O-RU !
     ${status}    Run Keyword And Return Status  Should contain  ${reply}  airphone-docker
     Log to console  O-RU status check is :${status}

     Run Keyword If  '${status}' == 'True'
     ...   Log to console  O-RU already started !
     ...   ELSE IF   '${status}' == 'False'
     ...   SYSTEM Start Command On o-ru  command=${command_start_docker}  hostname=${oru}
     ...   ELSE
     ...   Log to console  Wrong status !
## *** Check if O-RU is started
     ${reply}=  SYSTEM Start Command On o-ru
     ...    hostname=${oru}
     ...    command=echo ${O-RU_password} | sudo -S docker ps -a     #sudo docker ps -a
    Should contain  ${reply}  airphone-docker
    Log to console  O-RU is Started !

Check_and_Stop_O-RU_container
    [Arguments]    ${oru}
## *** Check if O-RU is started
     ${reply}=  SYSTEM Start Command On o-ru
     ...    hostname=${oru}
     ...    command=echo ${O-RU_password} | sudo -S docker ps -a     #sudo docker ps -a

## *** If O-RU is started ... stop O-RU
     ${status}    Run Keyword And Return Status  Should contain  ${reply}  airphone-docker
     Log to console  O-RU status check is :${status}

     Run Keyword If  '${status}' == 'True'
     ...   SYSTEM Start Command On o-ru  command=${command_stop_docker}  hostname=${oru}
     ...   ELSE IF   '${status}' == 'False'
     ...   Log to console  O-RU is already stopped !
     ...   ELSE
     ...   Log to console  Wrong status !
## *** Check if O-RU is stopped
     ${reply}=  SYSTEM Start Command On o-ru
     ...    hostname=${oru}
     ...    command=echo ${O-RU_password} | sudo -S docker ps -a     #sudo docker ps -a
     Should not contain  ${reply}  airphone-docker
     Log to console  O-RU is Stopped !

Check_and_Start_O-RU
    [Arguments]    ${oru}
### *** Check if O-RU is started

     SYSTEM Open SSH Connection To o-ru  ${oru}

     log to console      Ckeck and start ORU ${oru}

     SSHLibrary.Write            sudo docker exec -it orusim /bin/bash
     SSHLibrary.Read Until       password for ${O-RU_username}:
     SSHLibrary.Write            ${O-RU_password}
     ${output}  SSHLibrary.Read Until       :/opt/dev#
     Should contain  ${output}  /opt/dev#
     SSHLibrary.Write          supervisorctl status all
     ${reply}  SSHLibrary.Read Until       :/opt/dev#
#     ${status}    Run Keyword And Return Status  Should contain  ${reply}  RUNNING
    ${status}    Run Keyword And Return Status  Should not contain  ${reply}  STOPPED
     Run Keyword If  '${status}' == 'True'
     ...   Log to console  O-RU is already started !
     ...   ELSE IF   '${status}' == 'False'
     ...   SSHLibrary.Write          supervisorctl start all
     ...   ELSE
     ...   Log to console  Wrong status !
     sleep  5
#     SSHLibrary.Read Until       :/opt/dev#
     SSHLibrary.Write          supervisorctl status all
     ${reply1}  SSHLibrary.Read Until       :/opt/dev#
     ${status}  Wait Until Keyword Succeeds    60    5    Should not contain  ${reply1}  STOPPED
     Run Keyword If  '${status}' == 'False'
     ...   Log to console  O-RU start still contains STOPPED processes!

     log to console   ORUSim started successfully.

Check_and_Stop_O-RU
    [Arguments]    ${oru}
### *** Check if O-RU is started

     SYSTEM Open SSH Connection To o-ru  ${oru}

     log to console   Ckeck and stop ORU ${oru}

     SSHLibrary.Write            sudo docker exec -it orusim /bin/bash
     SSHLibrary.Read Until       password for ${O-RU_username}:
     SSHLibrary.Write            ${O-RU_password}
     ${output}  SSHLibrary.Read Until       :/opt/dev#
     Should contain  ${output}  /opt/dev#
     SSHLibrary.Write          supervisorctl status all
     ${reply}  SSHLibrary.Read Until       :/opt/dev#

     ${status}    Run Keyword And Return Status  Should not contain  ${reply}  RUNNING

     Run Keyword If  '${status}' == 'True'
     ...   Log to console  O-RU is already stopped !
     ...   ELSE IF   '${status}' == 'False'
     ...   SSHLibrary.Write          supervisorctl stop all
     ...   ELSE
     ...   Log to console  Wrong status !

#     SSHLibrary.Read Until       :/opt/dev#
     SSHLibrary.Write          supervisorctl status all
     ${reply}  SSHLibrary.Read Until       :/opt/dev#

     Wait Until Keyword Succeeds    60    5    Should not contain  ${reply}  RUNNING
     Wait Until Keyword Succeeds    60    5    Should not contain  ${reply}  STOPPING

     log to console   ORUSim stopped successfully.


SYSTEM Open SSH Connection To o-ru
    [Arguments]    ${O-RU_addr}
    SYSTEM Open SSH Connection    host=${O-RU_addr}
    ...                           port=22
    ...                           username=${O-RU_username}
    ...                           password=${O-RU_password}
    ...                           alias=oru

SYSTEM Open SSH Connection
    [Arguments]    ${host}    ${port}    ${username}    ${password}    ${alias}
    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=20    alias=${alias}
    SSHLibrary.Login    username=${username}    password=${password}    delay=1s

SYSTEM Start Command On o-ru
    [Arguments]    ${command}
    ...            ${hostname}=${O-RU_addr}
    ...            ${username}=${O-RU_username}
    ...            ${password}=${O-RU_password}
    ...            ${alias}=${SYSTEM_ALIAS_ORU}
    taf.transport.ssh.connect_to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=${alias}
     ${reply}=  taf.transport.ssh.execute
    ...    command=${command}
    ...    connection=${alias}
    [Return]    ${reply}

Delete safe files on gNB
    [Arguments]  ${file}=*
    ${result}  SYSTEM Execute Command On gNB
    ...    command=ls -l /ffs/run/config/safe
    ${safeExist}    Run Keyword And Return Status  Should not contain  ${result}  No such file or directory
    Run Keyword if  ${safeExist}    Run Keywords  Log to console   Safe files exist
    ...  AND  SYSTEM Execute Command On gNB   command=rm -rf /ffs/run/config/safe/*
    ...  AND  Log to console   ... safe files deleted
    ...  ELSE   Log to console   ... safe dir already deleted

#    ${output}  SYSTEM Execute Command On gNB   command=ls -l /ffs/run/config/safe
#    Run Keyword if   Should Contain  ${output}  total 0
#        ...  AND  Log to console   ... safe files deleted

Change_dir_rights_on_gNB
    [Arguments]  ${dir}=safe
    ...     ${rights}=777
    SYSTEM Execute Command On gNB
    ...    command=chmod ${rights} -R /ffs/run/config/${dir}
    ${output}  SYSTEM Execute Command On gNB
    ...    command=ls -ld /ffs/run/config/${dir}
    Run Keyword If      '${rights}' == '777'
    ...   Should contain  ${output}  drwxrwxrwx
	...   ELSE IF       '${rights}' == '555'
    ...   Should contain  ${output}  dr-xr-xr-x
    Log to console  Rights:${output}

Add xranuser1 to oru
    [Arguments]    ${oru}
     SYSTEM Open SSH Connection To o-ru  ${oru}

     log to console      Add new user

     SSHLibrary.Write            cd docker_share/orusim
     SSHLibrary.Read Until       orusim]$
     SSHLibrary.Write            sudo docker exec -it orusim /bin/bash
     SSHLibrary.Read Until       password for ${O-RU_username}:
     SSHLibrary.Write            ${O-RU_password}
     SSHLibrary.Read Until       /opt/dev#
     SSHLibrary.Write            sed -i 's/xranuser/xranuser1/g' /opt/dev/xml/o-ran-usermgt.xml
     SSHLibrary.Read Until       /opt/dev#
     SSHLibrary.Write            sed -i 's/xran-password/xran1-password/g' /opt/dev/xml/o-ran-usermgt.xml
     SSHLibrary.Read Until       /opt/dev#
     SSHLibrary.Write            supervisorctl stop all
     SSHLibrary.Read Until       /opt/dev#
     SSHLibrary.Write            sysrepocfg --verbosity 3 --edit=/opt/dev/xml/ietf-netconf-acm.xml --datastore=startup --format=xml
     ${reply}  SSHLibrary.Read Until       /opt/dev#
     Run Keyword And Return Status  Should not contain  ${reply}  ERROR
     SSHLibrary.Write            sysrepocfg --verbosity 3 --edit=/opt/dev/xml/o-ran-usermgt.xml --datastore=startup --format=xml
     ${reply}  SSHLibrary.Read Until       /opt/dev#
     Run Keyword And Return Status  Should not contain  ${reply}  ERROR
     SSHLibrary.Write            supervisorctl start all
     SSHLibrary.Read Until       /opt/dev#

     log to console   ORU xranuser1 added successfully.
