*** Settings ***
Documentation   This is common keyword for 5GC001681 cases coam parts.
...              Author: Han Ruiyu
...              Contact: ruiyu.han@nokia-sbell.com
...              Squard: HZ SG7
Resource   ../../common/taf_coam.robot
Resource   ../../common/gnb.robot
Resource   ../../UUF/Resource/webui_coam.robot
Resource   ../../UUF/Resource/common.robot
Library   ../libraries/ui_operation.py
Library   taf.transport.ssh   WITH NAME   csn
Variables  ../../libraries/global_vars.py
Variables  ../libraries/dcap_server_1.py
Variables  ../libraries/xn_gnb.py

*** Variables ***
${dscp}   32
${cmd_CCS}    netstat -tunlp|grep CCSTestPort
#${asik}    gnb

*** Keywords ***

Check Dynamic CCS Test Port
    csn.Connect To   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=gnb
    Command to Check Test Port   times=1   first_port=15067
    [Teardown]    csn.Disconnect   connection=gnb

Command to Check Test Port
    [Arguments]   ${alias}=gnb   ${times}=3   ${first_port}=15060
    ${PortNum}    Create List
    FOR   ${index}    IN RANGE    ${times}
       ${TMP_Master_Port}   csn.execute   command=${cmd_CCS}|grep ${${first_port}+${index}}   connection=${alias}
       Append To List   ${PortNum}   ${TMP_Master_Port}
       Should Contain   ${PortNum[${index}]}   :${${first_port}+${index}}
    END
    Log To Console   Test Port:${PortNum}
