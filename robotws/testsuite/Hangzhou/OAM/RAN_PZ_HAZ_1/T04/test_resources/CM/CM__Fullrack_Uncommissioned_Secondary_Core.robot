*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
 # Absolute path to commissioning file, should be a effective SCF file, otherwise might influence recovering of test line
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${SKIP_PARAM_RELATION_ERRORS}    ${False}    # Should relation errors be skipped (True, False)
${NEED_RECOVER}    ${False}    # The flag for SBTS recovery
${BTS_USERNAME}    toor4nsn    # The ssh account username to access secondary SMOD
${BTS_PASSWORD_Sec}    oZPS0POrRieRtu    # The ssh account password to access secondary SMOD
${SSH_USERNAME}    ute         # Secondary core control pc access user name
${SSH_PASSWORD}    uteUTE!    # Secondary core control pc access user password

*** Keywords ***
CM__Fullrack_Uncommissioned_Secondary_Core
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...    Check SBTS Status Should Be OK
    ...    Clear Configuration Of Secondary Core
    ...    Check Alarm Raised Correctly
    ...    Recover SBTS
    ...  Pass criteria: The fault 4352 will raise when the configuration of the secondary core is cleared. It will be recovered after full commission
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.04.2021 - Commit to GIT
    ...  -11.05.2022 - Optimize due to PR636607

    Set Tags    CA-CM    OWNER-lixin.kang@nokia-sbell.com    MAINTAINER-lixin.kang@nokia-sbell.com    AUTHOR-bin.7.liu@nokia-sbell.com
    ...    PHASE-CRT    SW-SBTS21B    API    GROUP_IN_CHARGE-SRAN_PROD_HZ1
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Check SBTS Status Should Be OK
    Step 2: Clear Configuration Of Secondary Core
    Step 3: Check Alarm Raised Correctly
    Step 4: Wait SBTS Recovery

Case Special Teardown
    Log    Case Special Teardown    console=${True}
    Run Keyword If    ${NEED_RECOVER}    Admin Get bts_id and perform commissioning    ${COMMISSIONING_PATH}
    Wait Until Keyword Succeeds    20 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Common Test Teardown SBTS

Establish SSH To Secondary Core And Remove Commissioning
    Should Be True    ${SMOD2_exists}
        ${smod_reset_cmd_map}    Create Dictionary    FSMF=ddal -s ddal_reboot_graceful
    ...    ASIA=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    ...    ASIB=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    ...    ASIL=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    ...    ASIM=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    SSHLibrary.Open Connection    host=${PC_IP2}
#    SSHLibrary.Login    ${SSH_USERNAME}    ${SSH_PASSWORD}
    _SSHLibrary_Login_multiway    ${SSH_USERNAME}    ${SSH_PASSWORD}
    SSHLibrary.Write    ssh ${BTS_USERNAME}@192.168.255.119
    ${output}    Wait Until Keyword Succeeds    5x    5s    SSHLibrary.Read Until Regexp    \[P\|p\]assword:
    SSHLibrary.Write    ${BTS_PASSWORD_Sec}
    Wait Until Keyword Succeeds    5x    5s    SSHLibrary.Read Until     >
    SSHLibrary.Write    cd ../../ffs/run/config
    Wait Until Keyword Succeeds    3x    1s    SSHLibrary.Read Until    /ffs/run/config >
    SSHLibrary.Write    rm -rf *
    Set Suite Variable    ${NEED_RECOVER}    ${True}
    Wait Until Keyword Succeeds    3x    2s    SSHLibrary.Read Until    >
    SSHLibrary.Write    ${smod_reset_cmd_map['${SMOD2}[HW_TYPE]']}
    ${output}    Wait Until Keyword Succeeds    6x    10s    SSHLibrary.Read Until    Connection to 192.168.255.119 closed
    Sleep    60s    #This sleep is needed to wait for reset
    SSHLibrary.Close Connection

Set Parameter caClusterMemberId As ${ID}
    LOG    Set Parameter caClusterMemberId As ${ID}    console=${True}
    Set Test Variable    ${NEED_RECOVER}    ${True}
    Get LNBTS Obj
    coam.Perform parameter recommissioning    ${MRBTS}/${LNBTS}    caClusterMemberId    update    ${ID}    ${False}
    ...    ${True}    600s
    Wait Until Keyword Succeeds    10 min    1 min    Check_SBTS_SMOD_RMOD_Cells_Alarms

Step ${index}: Check SBTS Status Should Be OK
    Log    Step ${index}: Check SBTS Status Should Be OK    console=${True}
    Check_SBTS_SMOD_RMOD_Cells_Alarms

Step ${index}: Clear Configuration Of Secondary Core
    Log    Step ${index}: Clear Configuration Of Secondary Core    console=${True}
    ${clusterid}    Evaluate    random.randint(1, 4)    modules=random, sys
    ${clusterid}    Convert To String    ${clusterid}
    Set Parameter caClusterMemberId As ${clusterid}
    Establish SSH To Secondary Core And Remove Commissioning

Step ${index}: Check Alarm Raised Correctly
    Log    Step ${index}: Check Alarm Raised Correctly    console=${True}
    ${alarm_dic}    Create Dictionary    faultId    ${4352}
    ${expected_patterns}    Create List    ${alarm_dic}
    ${alarm_dic_6327}    Create Dictionary    alarmId=${7107}    faultId=${6327}
    ${ignored_patterns}    Create List    ${alarm_dic_6327}
    Wait Until Keyword Succeeds    2 min    15 sec    Admin Check Active Alarms TAF     print_alarms=${False}
    ...    expected_patterns=${expected_patterns}    ignored_patterns=${ignored_patterns}

Step ${index}: Wait SBTS Recovery
    Log    Step ${index}: Wait SBTS Recovery    console=${True}
    Wait Until Keyword Succeeds    30 min    1 min    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Set Suite Variable    ${NEED_RECOVER}    ${False}