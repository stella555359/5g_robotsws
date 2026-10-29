*** Settings ***
Documentation     Test case for xx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_SR002086_SBTS_Configuration_Plan_Upload
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-18579
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing upload SBTS configuration plan
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: upload plan operation works as expected; uploded plan on NetAct increase 1; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 16.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18579 - SyVe_CM_SBTS_Configuration_Plan_Upload_SR002086
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-18579_SyVe_CM_SBTS_Configuration_Plan_Upload_SR002086.png


    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    Maintainer–I_MN_SRAN_HZ_PROD_SRAN_SQUAD3@internal.nsn.com

    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Check final alarms status from WebEM
    Step 6: Check final alarms status from Netact
    Step 7: Check final BTS state
    Step 8: Check final number and state of Cells and RMs


Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF
    Return From Keyword If    '${when}'!='initial'
    ${initial_plan_number}    Get Uploaded Plan Number on NetAct
    Set Test Variable    ${initial_plan_number}

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}
    ${final_plan_number}    Get Uploaded Plan Number on NetAct
    Should Be Equal As Integers    ${initial_plan_number+1}    ${final_plan_number}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Get Uploaded Plan Number on NetAct
    [Documentation]    Get Uploaded Plan Number on NetAct
    Log    Get Uploaded Plan Number on NetAct    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${result}    SSHLibrary.Execute Command    cd /var/opt/nokia/oss/global/cmmne3s/work && ls -l | grep MRBTS${mrbts_id} | grep UL
    ...    return_stderr=${True}
    ${lines}    Split To Lines    ${result[0]}
    ${count}    Evaluate    len(${lines})
    SSHLibrary.close_connection
    [Return]    ${count}


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown


