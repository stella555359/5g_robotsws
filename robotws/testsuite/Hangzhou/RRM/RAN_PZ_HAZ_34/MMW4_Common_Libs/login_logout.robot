*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library           taf.sbts.oam.coam.admin              WITH NAME    admin
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.selenium.gnb.oam.coam.cu    WITH NAME   selenium_cu



*** Keywords ***
################### Login DU ##############################
Login BaseStation By Selenium
    [Documentation]  1.login basestation by Web page;
    ...              2.Apply to gNB and eNB
    [Arguments]    ${hostname}    ${username}    ${password}    ${alias}=None
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${hostname}    username=${username}    password=${password}    alias=${alias}

Login BaseStation By Admin
    [Documentation]  1.login basestation by the background
    ...              2.Apply to gNB and eNB
    ...              3.hostname:TL IP
    [Arguments]    ${hostname}    ${connection}
    admin.connect_to    bts_host=${hostname}   name=${connection}

Login BaseStation By Ssh
    [Documentation]  1.login basestatin by ssh;
    ...              2.Apply to gNB\eNB\CUTestPC\ControlPC
    [Arguments]  ${hostname}    ${username}    ${password}    ${alias}
    ${connection}    csn.Connect To     hostname=${hostname}   username=${username}   password=${password}   alias=${alias}

################### Login CU ##############################
Logout BaseStation by Selenium
    [Documentation]  1.Disconnect BaseStation Web page connection;
    ...              2.Apply to gNB and eNB
    [Arguments]  ${alias}=None
    selenium_coam.logout    coam=${alias}

Logout BaseStation by Admin
    [Documentation]  1.Disconnect BaseStation background connection;
    ...              2.Apply to gNB and eNB
    [Arguments]   ${connection}
    admin.teardown      connection=${connection}

Disconnect Any SSH
    [Documentation]  1.Disconncect ssh;
    ...              2.Apply to gNB eNB CU TestPC ControlPC;
    ...              3.Important:'connection' value must be 'csn.Connect To' Return Value
    [Arguments]  ${connection}
    csn.Disconnect	connection=${connection}

Connect to control pc via cygwin
    [Documentation]  1.connect to control pc
    [Arguments]    ${ue_index}=${1}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}    ${alias}=cygwin
    ${connection}    csn.Connect to    hostname=${hostname}    username=${username}    password=${password}    alias=${alias}
    [Return]   ${connection}


############ Test PC  ##################################
Connect to TestPc
    [Documentation]  1.connect to testpc
    [Arguments]  ${hostname}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${username}=${tl.test_pc.default_ssh_connection_details.username}
    ...    ${password}=${tl.test_pc.default_ssh_connection_details.password}    ${alias}=TESTPC
    ${connection}    csn.Connect to     hostname=${hostname}    username=${username}    password=${password}  alias=${alias}
    [Return]   ${connection}