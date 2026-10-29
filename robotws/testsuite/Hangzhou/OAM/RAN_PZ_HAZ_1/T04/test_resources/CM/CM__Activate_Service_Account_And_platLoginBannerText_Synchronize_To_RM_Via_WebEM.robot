*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${CB006017_AFFECTED_RMOD_TYPE}    AZHL
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml

*** Keywords ***
CM__Activate_Service_Account_And_platLoginBannerText_Synchronize_To_RM_Via_WebEM
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   - Source case:Activate_Service_Account_And_platLoginBannerText_Synchronize_To_RM_Via_WebEM
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.05.2023 - Commit to robotws

    Set Tags    CM    UI    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    AUTHOR-bin.7.liu@nokia-sbell.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Check RMOD SSH Root User Forbidden
    Step 2: Check And Set Backgroud Parameter
    Step 3: Update And Check SSH Parameters After PWD Changed
    Step 4: Update SSH Parameters Without Sync

SetUp
    Log    SetUp    console=${True}
    ${win_index}    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}
    Status Of RAT Should Be OK
    SBTS WEM Enable Service Account SSH
    Reset Feature CB006017
    Set Test Variable    ${NEED_RECOVER}    ${False}
    ${pwd_1}    Generate Random String    12    [LETTERS]
    ${pwd_2}    Generate Random String    4    [NUMBERS]
    ${CB006017_AFFECTED_RMOD_TYPE}    Create List    AZHL
    Set Test Variable    ${CB006017_AFFECTED_RMOD_TYPE}
    Set Test Variable    ${RMOD_ROOT_SSH_PWD}    a2%FgSz3$fHmdusap354xujw7a
    Set Test Variable    ${RMOD_SERVICEUSER_SSH_USER}    serviceuser
    Set Test Variable    ${RMOD_SERVICEUSER_SSH_PWD}    Pl(FzaYj5~c5;q
    #${RMOD_SERVICEUSER_SSH_PWD} Factory password    wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=
    Set Test Variable    ${NEW_RMOD_SERVICEUSER_SSH_PWD}    ${pwd_1}${pwd_2}=
    Common Test Setup SBTS    alarms_check=${FALSE}    scf_check=${FALSE}

TearDown
    Log    Teardown    console=${True}
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    ${is_recovered}    Run Keyword If    ${NEED_RECOVER}    Run Keyword And Return Status    Recover SSH Parameters
    ${time}    Get Time    epoch
    Run Keyword If    '${is_recovered}' == '${False}'    Capture Page Screenshot    ${time}.png
    SBTS WEM Download Chrome Console Log
    Close All Browsers
    Return From Keyword If    '${is_recovered}' != '${False}'
    Admin Get bts_id and perform commissioning    ${COMMISSIONING_PATH}    ${True}
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Common Test Teardown SBTS

Get RMOD SSH Infor
    [Arguments]    ${pwd_serviceuser}    ${pwd_root}
    Log    ${pwd_root}
    Establish SSH to SBTS    192.168.255.129
    Execute CMD Via SSH connection    lxc-attach -n 0x1018    root\@FHNET00
    ${list_output}    Create List
    ${output}    Execute CMD Via SSH connection    cat /rom/config/FRIps.txt    root\@FHNET00
    ${lines}    Split To Lines    ${output}
    FOR    ${line}    IN    @{lines}
        ${type}    Fetch From Right    ${line}    ;
        ${not_CB006017_affected_type}    Run Keyword And Return Status    List Should Not Contain Value    ${CB006017_AFFECTED_RMOD_TYPE}
        ...    ${type.strip()}
        Continue For Loop If    ${not_CB006017_affected_type}
        ${dic_output}    Create Dictionary
        ${ip}    Should Match Regexp    ${line}    \\d+\\.\\d+\\.\\d+\\.\\d+
        ${output}    Execute CMD Via SSH connection    rm /user/toor4nsn/.ssh/known_hosts    root\@FHNET00
        ${output}    Execute CMD Via SSH connection    ssh serviceuser@${ip}    password\|yes/no    console_delay=1s
        ${output}    Run Keyword If    "yes/no" in """${output}"""    Execute CMD Via SSH connection    yes    password
        Set To Dictionary    ${dic_output}    platLoginBannerText    ${output}
        ${output}    Execute CMD Via SSH connection    ${pwd_serviceuser}    serviceuser\@stratix
        ${output}    Execute CMD Via SSH connection    sudo cat /etc/ssh/sshd_config |grep ClientAliveInterval    serviceuser\@stratix
        ${output}    Remove String    ${output}    ClientAliveInterval    serviceuser\@stratix
        ${sshClientAliveTimer}    Evaluate    ${output.strip()}/20
        Set To Dictionary    ${dic_output}    sshClientAliveTimer    ${sshClientAliveTimer}
        ${output}    Execute CMD Via SSH connection    sudo cat /etc/pam.d/sshd |grep delay    serviceuser\@stratix
        ${output}    Remove String    ${output}    auth required pam_faildelay.so delay=    serviceuser\@stratix
        ${sshSessionLoginDelayTimer}    Evaluate    ${output.strip()}/1000000
        Set To Dictionary    ${dic_output}    sshSessionLoginDelayTimer    ${sshSessionLoginDelayTimer}
        Append To List    ${list_output}    ${dic_output}
        ${output}    Execute CMD Via SSH connection    exit    root\@FHNET00
    END
    [Teardown]    SSHLibrary.Close All Connections
    [Return]    ${list_output}

Recover SSH Parameters
    Log    Recover SSH Parameters    console=${True}
    SBTS WEM Modify Parameters In PE Table    SECADM    Platform login banner text for service account login via SSH interface    ${DEFAULT_BANNER}
    SBTS WEM Modify Parameters In PE Table    SECADM    SSH client alive timer    ${DEFAULT_SSH_ACTIVE_TIMER}
    SBTS WEM Modify Parameters In PE Table    SECADM    SSH session login delay timer    ${DEFAULT_SSH_LOGIN_DELAY}
    SBTS WEM Modify Parameters In PE Table    SECADM    Activate service account synchronization to RU/RF devices    true
    SBTS WEM Validate Plan
    ${ret}    ${msg}    Run Keyword And Ignore Error    SBTS WEM Activate Plan
    Run Keyword If    '${ret}'=='FAIL'    Should Contain    ${msg}    Runtime plan has no modified objects
    ...    Failure is allowed only if the parameter has not been modified
    ${ret_msg}    SBTS WEM Update Service Account Password    ${RMOD_SERVICEUSER_SSH_USER}    ${NEW_RMOD_SERVICEUSER_SSH_PWD}
    ...    ${RMOD_SERVICEUSER_SSH_PWD}
    ${succeed}    Run Keyword And Return Status    SBTS WEM Synch To Raido Modules
    ${time}    Get Time    epoch
#    Run Keyword Unless    ${succeed}    Capture Page Screenshot    ${time}.png
    Run Keyword If    not ${succeed}    Capture Page Screenshot    ${time}.png
    ${succeed}    SBTS WEM Modify Parameters In PE Table    SECADM    Activate service account synchronization to RU/RF devices    false
    Should Be True    ${succeed}
    SBTS WEM Validate Plan
    SBTS WEM Activate Plan

Modify And Check SSH Parameters
    [Arguments]    ${need_sycn}    ${val_set}
    ${len}    Evaluate    random.randint(1, 200)    modules=random, sys
    ${random_platLoginBannerText}    Generate Random String    ${len}
    ${succeed}    SBTS WEM Modify Parameters In PE Table    SECADM    Platform login banner text for service account login via SSH interface
    ...    ${random_platLoginBannerText}
    Should Be True    ${succeed}
    Remove Values From List    ${val_set}    ${DEFAULT_SSH_ACTIVE_TIMER}    ${DEFAULT_SSH_LOGIN_DELAY}
    ${count}    Get Length    ${val_set}
    ${i}    Evaluate    random.randint(0, ${count-1})    modules=random, sys
    ${random_sshClientAliveTimer}    Set Variable    ${val_set[${i}]}
    ${succeed}    SBTS WEM Modify Parameters In PE Table    SECADM    SSH client alive timer    ${random_sshClientAliveTimer}
    Should Be True    ${succeed}
    ${i}    Evaluate    random.randint(0, ${count-1})    modules=random, sys
    ${random_sshSessionLoginDelayTimer}    Set Variable    ${val_set[${i}]}
    ${succeed}    SBTS WEM Modify Parameters In PE Table    SECADM    SSH session login delay timer    ${random_sshSessionLoginDelayTimer}
    Should Be True    ${succeed}
    SBTS WEM Validate Plan
    SBTS WEM Activate Plan
    Run Keyword If    ${need_sycn}    SBTS WEM Synch To Raido Modules
    ${list_rmod_ssh_infor}    Get RMOD SSH Infor    ${NEW_RMOD_SERVICEUSER_SSH_PWD}    ${RMOD_ROOT_SSH_PWD}
    FOR    ${dic_rmod_ssh_infor}    IN    @{list_rmod_ssh_infor}
        ${ret_1}    Run Keyword And Return Status    Should Contain    ${dic_rmod_ssh_infor['platLoginBannerText']}    ${random_platLoginBannerText}
        ${ret_2}    Run Keyword And Return Status    Should Be Equal As Integers    ${dic_rmod_ssh_infor['sshClientAliveTimer']}
        ...    ${random_sshClientAliveTimer}
        ${ret_3}    Run Keyword And Return Status    Should Be Equal As Integers    ${dic_rmod_ssh_infor['sshSessionLoginDelayTimer']}
        ...    ${random_sshSessionLoginDelayTimer}
        Run Keyword If    ${need_sycn}    Should Be True    ${ret_1} and ${ret_2} and ${ret_3}
        ...    ELSE    Should Not Be True    ${ret_1} or ${ret_2} or ${ret_3}
    END

Step ${index}: Check RMOD SSH Root User Forbidden
    Log    Step ${index}: Check RMOD SSH Root User Forbidden    console=${True}
    Establish SSH to SBTS    192.168.255.129
    Execute CMD Via SSH connection    lxc-attach -n 0x1018    root\@FHNET00
    ${list_output}    Create List
    ${output}    Execute CMD Via SSH connection    cat /rom/config/FRIps.txt    root\@FHNET00
    ${lines}    Split To Lines    ${output}
    FOR    ${line}    IN    @{lines}
        ${type}    Fetch From Right    ${line}    ;
        ${not_CB006017_affected_type}    Run Keyword And Return Status    List Should Not Contain Value
        ...    ${CB006017_AFFECTED_RMOD_TYPE}    ${type.strip()}
        Continue For Loop If    ${not_CB006017_affected_type}
        ${dic_output}    Create Dictionary
        ${ip}    Should Match Regexp    ${line}    \\d+\\.\\d+\\.\\d+\\.\\d+
        ${output}    Execute CMD Via SSH connection    rm /user/toor4nsn/.ssh/known_hosts    root\@FHNET00
        ${output}    Execute CMD Via SSH connection    ssh root@${ip}    password\|yes/no    console_delay=1s
        ${output}    Run Keyword If    "yes/no" in """${output}"""    Execute CMD Via SSH connection    yes    (P|p)ermission denied
    END
    [Teardown]    SSHLibrary.Close All Connections

Step ${index}: Check And Set Backgroud Parameter
    Log    Step ${index}: Check And Set Backgroud Parameter    console=${True}
    Run Keyword And Expect Error    *    Get RMOD SSH Infor    ${NEW_RMOD_SERVICEUSER_SSH_PWD}    ${RMOD_ROOT_SSH_PWD}
    ${list_rmod_ssh_infor}    Get RMOD SSH Infor    ${RMOD_SERVICEUSER_SSH_PWD}    ${RMOD_ROOT_SSH_PWD}
    ${count}    Get Length    ${list_rmod_ssh_infor}
    Should Not Be Equal As Integers    ${count}    ${0}    This SBTS has not RMOD affected by CB006017.
    ${dic_rmod_ssh_infor}    Set Variable    ${list_rmod_ssh_infor[0]}
    Set Test Variable    ${DEFAULT_BANNER}    ${dic_rmod_ssh_infor['platLoginBannerText']}
    Set Test Variable    ${DEFAULT_SSH_ACTIVE_TIMER}    ${dic_rmod_ssh_infor['sshClientAliveTimer']}
    Set Test Variable    ${DEFAULT_SSH_LOGIN_DELAY}    ${dic_rmod_ssh_infor['sshSessionLoginDelayTimer']}

Step ${index}: Update And Check SSH Parameters After PWD Changed
    Log    Step ${index}: Update And Check SSH Parameters After PWD Changed    console=${True}
    ${ret_msg}    SBTS WEM Update Service Account Password    ${RMOD_SERVICEUSER_SSH_USER}    ${RMOD_SERVICEUSER_SSH_PWD}
    ...    ${NEW_RMOD_SERVICEUSER_SSH_PWD}
    Should Be Equal As Strings    ${ret_msg.strip()}    Process completed.
    Run Keyword And Expect Error    *    Get RMOD SSH Infor    ${NEW_RMOD_SERVICEUSER_SSH_PWD}    ${RMOD_ROOT_SSH_PWD}
    ${succeed}    SBTS WEM Modify Parameters In PE Table    SECADM    Activate service account synchronization to RU/RF devices    true
    Should Be True    ${succeed}
    SBTS WEM Validate Plan
    Set Test Variable    ${NEED_RECOVER}    ${True}
    SBTS WEM Activate Plan
    SBTS WEM Synch To Raido Modules
    ${val_set}    Create List    ${1}    ${10}    ${20}    ${30}    ${60}
    Modify And Check SSH Parameters    ${True}    ${val_set}

Step ${index}: Update SSH Parameters Without Sync
    Log    Step ${index}: Update SSH Parameters Without Sync    console=${True}
    ${succeed}    SBTS WEM Modify Parameters In PE Table    SECADM    Activate service account synchronization to RU/RF devices    false
    Should Be True    ${succeed}
    SBTS WEM Validate Plan
    SBTS WEM Activate Plan
    ${val_set}    Create List    ${5}    ${15}    ${25}    ${35}    ${45}
    Modify And Check SSH Parameters    ${False}    ${val_set}

Reset Feature CB006017
    ${succeed}    SBTS WEM Modify Parameters In PE Table    SECADM    Activate service account synchronization to RU/RF devices    true
    Should Be True    ${succeed}
    SBTS WEM Validate Plan
    SBTS WEM Activate Plan
    ${succeed}    SBTS WEM Modify Parameters In PE Table    SECADM    Activate service account synchronization to RU/RF devices    false
    Should Be True    ${succeed}
    SBTS WEM Validate Plan
    SBTS WEM Activate Plan