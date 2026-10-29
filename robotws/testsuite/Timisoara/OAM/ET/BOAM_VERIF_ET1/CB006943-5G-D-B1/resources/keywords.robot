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

Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/selenium_oru.robot

*** Variables ***

${O-RU_username}=                oru
${O-RU_password}=                orusim12
${SYSTEM_ALIAS_ORU}=             oru

#${command_start_docker}  echo ${O-RU_password} | sudo -S docker run --rm --name=orusim --detach --privileged
#     ...    --network=bridge airphone-docker-local.artifactory-espoo1.int.net.nokia.com/orusim:v1.22.10
#${command_stop_docker}  echo ${O-RU_password} | sudo -S docker stop orusim    #sudo docker kill orusim
#${command_enter_docker}  echo ${O-RU_password} | sudo docker exec -it orusim /bin/bash
${command_status_docker}  echo | supervisorctl status all

${ssh_alias}  sshenb


*** Keywords ***

Delete Credentials To First Account in WebEM Success
    SELENIUM Delete Credentials Of First O-RU Account Success

Delete Credentials To First Account in WebEM Fail
    SELENIUM Delete Credentials Of First O-RU Account Fail

Add Credentials To First Account
    SELENIUM Set Name Of First O-RU Account  user
    SELENIUM Set Pasword Of First O-RU Account  xranuser-password
    SELENIUM Send O-RU Account Configuration And Check State Success

Recreate Credentials To First Account in WebEM
    SELENIUM Set Name Of First O-RU Account  user
    SELENIUM Set Pasword Of First O-RU Account  xranuser-password
    SELENIUM Send O-RU Account Configuration And Check State Failed


Check User Name Entry Do Not Accept 2 Characters
    ${result_code}=  SELENIUM Set Name Of First O-RU Account  na
    Should Contain  ${result_code}  Account name format is invalid

Check User Name Entry Do Not Accept First Leter Capital
    ${result_code}=  SELENIUM Set Name Of First O-RU Account  Name
    Should Contain  ${result_code}  Account name format is invalid

Check User Name Entry Do Not Accept 33 Characters
    ${result_code}=  SELENIUM Set Name Of First O-RU Account  abcdefghijabcdefghijabcdefghij033
    Should Contain  ${result_code}  Value is too long;Account name

Check User Name Entry Accept 4 Characters
    ${result_code}=  SELENIUM Set Name Of First O-RU Account  abcd
    Should Contain  ${result_code}  ${Empty}

Check User Name Entry Accept 32 Characters
    ${result_code}=  SELENIUM Set Name Of First O-RU Account  abcdefghijABCDEFGHIJabcdefghij32
    Should Contain  ${result_code}  ${Empty}

Set Name Of First Account
    [Arguments]    ${account_name}
    ${result_code}=   SELENIUM Set Name Of First Account  ${account_name}
    [return]  ${result_code}

#Add New O-RU Account
#    SELENIUM Add New O-RU Account

Add New Second O-RU Account
    SELENIUM Add New Second O-RU Account

#Go To Netconf Radio Management Menu
#    SELENIUM Go To Netconf Radio Management

#Logout And Close Browser
#    SELENIUM Logout User From Web Element Manager
#    SELENIUM Teardown Environment

#SELENIUM Setup
##    Log To Console    SELENIUM Setup
##    SELENIUM Prepare Enviroment
##    SELENIUM Run Xvfb
##    SELENIUM Export DISPLAY
#    SELENIUM Login To Web Element Manager

#Check_and_Start_O-RU_container
#    [Arguments]    ${oru}
### *** Check if O-RU is started
#     ${reply}=  SYSTEM Start Command On o-ru
#     ...    hostname=${oru}
#     ...    command=echo ${O-RU_password} | sudo -S docker ps -a     #sudo docker ps -a
#
### *** If O-RU is not started ... START O-RU !
#     ${status}    Run Keyword And Return Status  Should contain  ${reply}  airphone-docker
#     Log to console  O-RU status check is :${status}
#
#     Run Keyword If  '${status}' == 'True'
#     ...   Log to console  O-RU already started !
#     ...   ELSE IF   '${status}' == 'False'
#     ...   SYSTEM Start Command On o-ru  command=${command_start_docker}  hostname=${oru}
#     ...   ELSE
#     ...   Log to console  Wrong status !
### *** Check if O-RU is started
#     ${reply}=  SYSTEM Start Command On o-ru
#     ...    hostname=${oru}
#     ...    command=echo ${O-RU_password} | sudo -S docker ps -a     #sudo docker ps -a
#    Should contain  ${reply}  airphone-docker
#    Log to console  O-RU is Started !
#
#Check_and_Stop_O-RU_container
#    [Arguments]    ${oru}
### *** Check if O-RU is started
#     ${reply}=  SYSTEM Start Command On o-ru
#     ...    hostname=${oru}
#     ...    command=echo ${O-RU_password} | sudo -S docker ps -a     #sudo docker ps -a
#
### *** If O-RU is started ... stop O-RU
#     ${status}    Run Keyword And Return Status  Should contain  ${reply}  airphone-docker
#     Log to console  O-RU status check is :${status}
#
#     Run Keyword If  '${status}' == 'True'
#     ...   SYSTEM Start Command On o-ru  command=${command_stop_docker}  hostname=${oru}
#     ...   ELSE IF   '${status}' == 'False'
#     ...   Log to console  O-RU is already stopped !
#     ...   ELSE
#     ...   Log to console  Wrong status !
### *** Check if O-RU is stopped
#     ${reply}=  SYSTEM Start Command On o-ru
#     ...    hostname=${oru}
#     ...    command=echo ${O-RU_password} | sudo -S docker ps -a     #sudo docker ps -a
#     Should not contain  ${reply}  airphone-docker
#     Log to console  O-RU is Stopped !
#
#Check_and_Start_O-RU
#    [Arguments]    ${oru}
#### *** Check if O-RU is started
#
#     SYSTEM Open SSH Connection To o-ru  ${oru}
#
#     log to console      Ckeck and start ORU
#
#     SSHLibrary.Write            sudo docker exec -it orusim /bin/bash
#     SSHLibrary.Read Until       password for ${O-RU_username}:
#     SSHLibrary.Write            ${O-RU_password}
#     ${output}  SSHLibrary.Read Until       :/opt/dev#
#     Should contain  ${output}  /opt/dev#
#     SSHLibrary.Write          supervisorctl status all
#     ${reply}  SSHLibrary.Read Until       :/opt/dev#
#
#     ${status}    Run Keyword And Return Status  Should contain  ${reply}  RUNNING
#
#     Run Keyword If  '${status}' == 'True'
#     ...   Log to console  O-RU is already started !
#     ...   ELSE IF   '${status}' == 'False'
#     ...   SSHLibrary.Write          supervisorctl start all
#     ...   ELSE
#     ...   Log to console  Wrong status !
#
#     log to console   ORUsim  started successfully.
#
#Check_and_Stop_O-RU
#    [Arguments]    ${oru}
#### *** Check if O-RU is started
#
#     SYSTEM Open SSH Connection To o-ru  ${oru}
#
#     log to console   Ckeck and stop ORU
#
#     SSHLibrary.Write            sudo docker exec -it orusim /bin/bash
#     SSHLibrary.Read Until       password for o-ru_simulation:
#     SSHLibrary.Write            ${O-RU_password}
#     ${output}  SSHLibrary.Read Until       :/opt/dev#
#     Should contain  ${output}  /opt/dev#
#     SSHLibrary.Write          supervisorctl status all
#     ${reply}  SSHLibrary.Read Until       :/opt/dev#
#
#     ${status}    Run Keyword And Return Status  Should contain  ${reply}  STOPPED
#
#     Run Keyword If  '${status}' == 'True'
#     ...   Log to console  O-RU is already stopped !
#     ...   ELSE IF   '${status}' == 'False'
#     ...   SSHLibrary.Write          supervisorctl stop all
#     ...   ELSE
#     ...   Log to console  Wrong status !
#
##     SSHLibrary.Write          supervisorctl status all
##     ${reply}  SSHLibrary.Read Until       :/opt/dev#
##     Should contain  ${reply}  STOPPED
#
#     log to console   ORUsim  stopped successfully.
#
#
#SYSTEM Open SSH Connection To o-ru
#    [Arguments]    ${O-RU_addr}
#    SYSTEM Open SSH Connection    host=${O-RU_addr}
#    ...                           port=22
#    ...                           username=${O-RU_username}
#    ...                           password=${O-RU_password}
#    ...                           alias=oru
#SYSTEM Open SSH Connection
#    [Arguments]    ${host}    ${port}    ${username}    ${password}    ${alias}
#    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=20    alias=${alias}
#    SSHLibrary.Login    username=${username}    password=${password}    delay=1s
#SYSTEM Start Command On o-ru
#    [Arguments]    ${command}
#    ...            ${hostname}=${O-RU_addr}
#    ...            ${username}=${O-RU_username}
#    ...            ${password}=${O-RU_password}
#    ...            ${alias}=${SYSTEM_ALIAS_ORU}
#    taf.transport.ssh.connect_to
#    ...    hostname=${hostname}
#    ...    username=${username}
#    ...    password=${password}
#    ...    alias=${alias}
#     ${reply}=  taf.transport.ssh.execute
#    ...    command=${command}
#    ...    connection=${alias}
#    [Return]    ${reply}

#Delete safe files on gNB
#    [Arguments]  ${file}=*
#    SYSTEM Execute Command On gNB
#    ...    command=rm /ffs/run/config/safe/${file}
#    ${output}  SYSTEM Execute Command On gNB
#    ...    command=ls -l /ffs/run/config/safe
#    Should Not contain  ${output}  btssw
#    Log to console  File ${file} deleted

#Change_dir_rights_on_gNB
#    [Arguments]  ${dir}=safe
#    ...     ${rights}=777
#    SYSTEM Execute Command On gNB
#    ...    command=chmod ${rights} -R /ffs/run/config/${dir}
#    ${output}  SYSTEM Execute Command On gNB
#    ...    command=ls -ld /ffs/run/config/${dir}
#    Run Keyword If      '${rights}' == '777'
#    ...   Should contain  ${output}  drwxrwxrwx
#	...   ELSE IF       '${rights}' == '555'
#    ...   Should contain  ${output}  dr-xr-xr-x
#    Log to console  Rights:${output}

