*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    New case for RAN_SyVe_CB005891_007_CM_Incorrect input verify when provision actions from NMS
    ...    This case is to verify user’s incorrect input shall be reported or fixed by NMS.
    ...
    ...    The main steps performed for the test are:
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Trigger Scenario1: Two Reset Actions In One Command
    ...    - Trigger Scenario2: One Reset Action But Target Object Not Support
    ...    - Trigger Scenario3: BTS Site Reset Action But Missing Mandatory Parameter Values
    ...    - Trigger Scenario4: BTS Site Reset Action With Wrong Mandatory Parameter Values
    ...    - Trigger Scenario7: BTS Site Reset Action Including Unknown Parameters
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.05.2023 - New case
    Set Tags    SyVe    AUTHOR-lixin.kang@nokia.com    PHASE-CRT    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Trigger Scenario1: Two Reset Actions In One Command
    Step 6: Trigger Scenario2: One Reset Action But Target Object Not Support
    Step 7: Trigger Scenario3: BTS Site Reset Action But Missing Mandatory Parameter Values
    Step 8: Trigger Scenario4: BTS Site Reset Action With Wrong Mandatory Parameter Values
    Step 9: Trigger Scenario7: BTS Site Reset Action Including Unknown Parameters
    Step 10: Check final alarms status from WebEM
    Step 11: Check final alarms status from Netact
    Step 12: Check final BTS state
    Step 13: Check final number and state of Cells and RMs

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=MRBTS-${mrbts_id}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Trigger Scenario1: Two Reset Actions In One Command
    Log    Step ${index}: Trigger Scenario1: Two Reset Actions In One Command    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cmd}    Set Variable
    ...    racclimx.sh -op Reset_NE -DN MRBTS-${mrbts_id}/NRBTS-${nrBtsId},MRBTS-${mrbts_id} -v
    SSHLibrary.Start Command    ${cmd}
    ${operation_result}    SSHLibrary.Read Command Output
    Should Contain    ${operation_result}    Reset plan creation failed
    Should Contain    ${operation_result}    Network element supports only one type of reset in one provisioning operation
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Step ${index}: Trigger Scenario2: One Reset Action But Target Object Not Support
    Log    Step ${index}: Trigger Scenario2: One Reset Action But Target Object Not Support    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cmd}    Set Variable    racclimx.sh -op Reset_NE -DN MRBTS-${mrbts_id}/MNL-1 -v
    SSHLibrary.Start Command    ${cmd}
    ${operation_result}    SSHLibrary.Read Command Output
    Should Contain    ${operation_result}    Reset plan creation failed
    Should Contain    ${operation_result}    Network element does not support reset via com.nokia.actions for com.nokia.srbts.mnl:MNL
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Step ${index}: Trigger Scenario3: BTS Site Reset Action But Missing Mandatory Parameter Values
    Log    Step ${index}: Trigger Scenario3: BTS Site Reset Action But Missing Mandatory Parameter Values    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cmd}    Set Variable    racclimx.sh -op Reset_NE -DN MRBTS-${mrbts_id} -v
    SSHLibrary.Start Command    ${cmd}
    Check SBTS Has Restarted Successful
    ${operation_result}    SSHLibrary.Read Command Output
    Should Contain    ${operation_result}    Reset plan creation successful
    Should Contain    ${operation_result}    btsResetType=btsSiteReset
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Step ${index}: Trigger Scenario4: BTS Site Reset Action With Wrong Mandatory Parameter Values
    Log    Step ${index}: Trigger Scenario4: BTS Site Reset Action With Wrong Parameter Values    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cmd}    Set Variable    racclimx.sh -op Reset_NE -DN MRBTS-${mrbts_id} -parameters btsResetType=wrongvalue -v
    SSHLibrary.Start Command    ${cmd}
    ${operation_result}    SSHLibrary.Read Command Output
    Should Contain    ${operation_result}    Reset plan creation failed
    Should Contain    ${operation_result}    Parameter value defined in -parameters attribute is not supported
    Should Contain    ${operation_result}    Details: Invalid parameter: btsResetType=wrongvalue
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Step ${index}: Trigger Scenario7: BTS Site Reset Action Including Unknown Parameters
    Log    Step ${index}: Trigger Scenario6: BTS Site Reset Action Including Unknown Parameters    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cmd}    Set Variable    racclimx.sh -op Reset_NE -DN MRBTS-${mrbts_id} -parameters btsname=testing -v
    SSHLibrary.Start Command    ${cmd}
    ${operation_result}    SSHLibrary.Read Command Output
    Should Contain    ${operation_result}    Reset plan creation failed
    Should Contain    ${operation_result}    Parameter name defined in -parameters attribute is not a valid parameter for reset
    Should Contain    ${operation_result}    Details: Invalid parameter: btsname=testing
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

TC Setup
    Common Test Setup
    ${dic_bts_info}    coam.Get Bts Info
    ${nrBtsId}    Pop From Dictionary    ${dic_bts_info}    nrBtsId
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${nrBtsId}
    Set Test Variable    ${mrbts_id}

TC Teardown
    Common Test Teardown