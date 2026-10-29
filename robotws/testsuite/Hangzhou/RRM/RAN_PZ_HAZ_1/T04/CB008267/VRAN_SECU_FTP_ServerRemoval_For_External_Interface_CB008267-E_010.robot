*** Settings ***
Documentation
...   Author: yuan.1.gao@nokia-sbell.com
...   Description: This robot cases is for to verify the port 2121 can not use in internal interface and external interface.
Library           SSHLibrary
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${VDU_SSH_IP}    ${tl.cloud_hostings[0].control_nodes[0].default_ssh_connection_details.addr}
${VDU_SSH_USERNAME}    ${tl.cloud_hostings[0].control_nodes[0].default_ssh_connection_details.username}
${VDU_SSH_PASSWORD}    ${tl.cloud_hostings[0].control_nodes[0].default_ssh_connection_details.password}
${CMD1}    oc exec -it -n cran1 po-cran1-oamfh-0 -c ctr-cran1-vsftp bash
#ctr-cran1-vsftp get from cmd "oc exec -it -n cran1 po-cran1-oamfh-0 -c ctr-cran1-vsftp bash"
${CMD2}    netstat -apnt|grep "ftp\\|192\\|127"|grep ":21"

*** Keywords ***
TC__VRAN_SECU_FTP_ServerRemoval_For_External_Interface_CB008267-E_010
    [Documentation]
    ...    Author: yuan.1.gao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    18.07.2023, yuan.1.gao@nokia-sbell.com, draft
    Log To Console    TC__VRAN_SECU_CB008267-E_010
    Step 1: VDU FTP Port Check

Case Precondition
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Run Keyword And Ignore Error    vDU Login By Rest

Case Postcondition
    Log To Console    Case Postcondition
    Run Keyword And Ignore Error    vDU Logout By Rest
    Common Test Teardown For AIC

Step ${index}: VDU FTP Port Check
    Log To Console    Step ${index}: VDU FTP Port Check
    SSHLibrary.Open Connection     host=${VDU_SSH_IP}    prompt=$
    SSHLibrary.Login    ${VDU_SSH_USERNAME}    ${VDU_SSH_PASSWORD}
    SSHLibrary.Write    ${CMD1}
    ${output}    Wait Until Keyword Succeeds    5x    8s    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    ${CMD2}
    ${stdout}    Wait Until Keyword Succeeds    5x    8s    SSHLibrary.Read Until Prompt
    Should Contain    ${stdout}    127.0.0.1:2121
    Should Contain    ${stdout}    192.168.254.33:21
    SSHLibrary.Close Connection