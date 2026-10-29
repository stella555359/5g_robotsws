*** Settings ***
Documentation     Test case for xx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
# WCDMA cell delete plan will provision on NetAct
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${plan_path}      /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/WCDMA_Cell_Delete_And_Add.xml
# Absolute path to commissioning file, should be a effective SCF file, otherwise might influence recovering of test line
${commissioning_path}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml

*** Keywords ***
SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-18440
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing provision WCDMA cell delete and add from NetAct based on prepare a delete Wcell-1 plan
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Import the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check final BTS state
    ...    - Check Wcell be deleted
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check Wcell be added
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: delete and add wcell provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18440 - SyVe_CM_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell_SR002086
    ...    - 17.01.2022 - change the plan name in plan_path from WCDMA_Cell_Delete_And_Add.csv to WCDMA_Cell_Delete_And_Add.xml
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...    - 30.06.2022 - Xu Yuyan - https://jiradc.ext.net.nokia.com/browse/TAT-23357
    ...    - add object action check for EDA Action for 02426735 - Operability
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-18440_SyVe_CM_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell_SR002086.png
    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    Maintainer–I_MN_SRAN_HZ_PROD_SRAN_SQUAD3@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Import the plan SyVe
    Step 6: Provision the plan SyVe
    Step 7: Check final BTS state
    Step 8: Check Wcell be deleted
    Step 9: Provision the backup plan
    Step 10: Check final alarms status from WebEM
    Step 11: Check final alarms status from Netact
    Step 12: Check final BTS state
    Step 13: Check Wcell be added
    Step 14: Check final number and state of Cells and RMs

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF
    Return From Keyword If    '${when}'!='initial'
    ${initial_wcells}    coam.Get Ids For All    WNCEL
    Set Test Variable    ${initial_wcells}
    ${initial_wcells_count}    Evaluate    len(${initial_wcells})
    Set Test Variable    ${initial_wcells_count}

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Import the plan SyVe
    Log    Step ${index}: Import the plan SyVe    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${mrbts_id}
    ${file_name}    Fetch From Right    ${plan_path}    /
    ${file_path}    Remove String    ${plan_path}    /${file_name}
    NetAct Import Plan    local_dir=${file_path}    file_name=${file_name}    plan_name=${name}

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmdstr1}    Set Variable    racclimx.sh -planName ${name} -DN ${MRBTS_DN} -createBackupPlan true -backupPlanName ${name}_backup
    ${cmdstr2}    Set Variable   -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command     ${cmdstr1} ${cmdstr2}
    Log    Check Action    console=True
    ${reset}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    120
        Sleep    3s
        ${result}    ${rat_status}=    run keyword and ignore error    Check WCDMA RAT status
        Check Other Cells Onair
        ${reset}    run keyword and return status    Should Be Equal As Strings    ${rat_status}    ALL_DISABLED
        exit for loop if    ${reset}
    END
    Should Be True    ${reset}
    ${WNcells_Status}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    120
        sleep    3s
        ${WNcells_Status}    Run Keyword And Return Status    coam.Assert Every    WNCEL    operationalState=${_Enabled_}    timeout=30
        Check Other Cells Onair
        exit for loop if    ${WNcells_Status}
    END
    Should Be True    ${WNcells_Status}
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}_backup    operation_type=plan
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmdstr1}    Set Variable    racclimx.sh -planName ${name}_backup -DN ${MRBTS_DN} -createBackupPlan false -v -provisioningOperation activate
    ${cmdstr2}    Set Variable    -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmdstr1} ${cmdstr2}
    Log    Check Action    console=True
    ${reset}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    120
        Sleep    3s
        ${result}    ${rat_status}=    run keyword and ignore error    Check WCDMA RAT status
        Check Other Cells Onair
        ${reset}    run keyword and return status    Should Be Equal As Strings    ${rat_status}    ALL_DISABLED
        exit for loop if    ${reset}
    END
    Should Be True    ${reset}
    ${WNcells_Status}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    120
        sleep    3s
        ${WNcells_Status}    Run Keyword And Return Status    coam.Assert Every    WNCEL    operationalState=${_Enabled_}    timeout=30
        Check Other Cells Onair
        exit for loop if    ${WNcells_Status}
    END
    Should Be True    ${WNcells_Status}
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful

Step ${index}: Check Wcell be deleted
    Log    Step ${index}: Check Wcell be deleted    console=True
    ${after_deleted_wcells}    coam.Get Ids For All    WNCEL
    Set Test Variable    ${after_deleted_wcells}
    ${deleted_wcells}    Copy List    ${initial_wcells}
    Set Test Variable    ${deleted_wcells}
    Remove Values From List    ${deleted_wcells}    @{after_deleted_wcells}
    Sort List    ${deleted_wcells}
    ${after_deleted_wcells_count}    Evaluate    len(${after_deleted_wcells})
    Should Be Equal As Integers    ${initial_wcells_count}    ${after_deleted_wcells_count+1}

Step ${index}: Check Wcell be added
    Log    Step ${index}: Check Wcell be added    console=True
    ${after_added_wcells}    coam.Get Ids For All    WNCEL
    ${added_wcells}    Copy List    ${after_added_wcells}
    Remove Values From List    ${added_wcells}    @{after_deleted_wcells}
    Sort List    ${added_wcells}
    Lists Should Be Equal    ${deleted_wcells}    ${added_wcells}
    ${after_added_wcells_count}    Evaluate    len(${after_added_wcells})
    Should Be Equal As Integers    ${initial_wcells_count}    ${after_added_wcells_count}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Check Other Cells Onair
    ${gncell}    Run Keyword And Return Status    coam.Assert Any    GNCEL
    ${lncell}    Run Keyword And Return Status    coam.Assert Any    LNCEL
    ${nrcell}    Run Keyword And Return Status    coam.Assert Any    NRCEL
    ${gncell_onair}    Run Keyword If    ${gncell}    Run Keyword And Return Status    coam.Assert Every
    ...    GNCEL    ${cells_GSM_expected_state}    timeout=30
    ${lncell_onair}    Run Keyword If    ${lncell}    Run Keyword And Return Status    coam.Assert Every
    ...    LNCEL    ${cells_LTE_expected_state}    timeout=30
    ${nrcell_onair}    Run Keyword If    ${nrcell}    Run Keyword And Return Status    coam.Assert Every
    ...    NRCEL    ${cells_NR_expected_state}    timeout=30
    Run Keyword If    ${gncell}    Should Be True    ${gncell_onair}
    Run Keyword If    ${lncell}    Should Be True    ${lncell_onair}
    Run Keyword If    ${nrcell}    Should Be True    ${nrcell_onair}

Check ${rat_techo} RAT status
    ${rat}    String.Convert To Lower Case    ${rat_techo}
    ${btsinfo_list}    coam.Get Bts Info
    ${rat_status}    set variable    ${btsinfo_list['ratState']['${rat}']}
    [Return]    ${rat_status}

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${final_wcells}    coam.Get Ids For All    WNCEL
    ${final_wcells_count}    Evaluate    len(${final_wcells})
    Run Keyword If    ${initial_wcells_count}!=${0} and ${initial_wcells_count}!=${final_wcells_count}
    ...    Admin Get bts_id and perform commissioning    ${commissioning_path}    ${True}
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
