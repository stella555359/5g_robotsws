*** Settings ***
Documentation     Test case for xx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
# lncell delete plan will provision on NetAct
${lock_lncel_plan_path}      /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/CELL_LOCK_TEST_TEMPLATE.xml

*** Keywords ***
SyVe_CM_Sanity_Check
    [Documentation]   This case is for NetAct DevOps Sanity Check
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing plan activation from NetAct
    ...    based on selected PLAN_TAT-18772
    ...    The main steps performed for the test are:
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Import the plan SyVe
    ...    - Provision the plan
    ...    - Check modified parameter in Netact after provision plan
    ...    - Check modified parameter in Admin after provision plan
    ...    - Provision the backup plan
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: create, edit, export, download and activation operation works as expected; states and alarms are as expected.
    ...    Plan file generated or deletet from SBTS local as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 11.06.2021 - commit
    ...
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer-I_NSB_MN_SRAN_PROD_HZH_OPER1_VRF@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Random select LNCEL
    Step 6: Import the plan SyVe
    Step 7: Provision the plan
    Step 8: Check modified parameter in Netact after provision plan
    Step 9: Check modified parameter in Admin after provision plan
    Step 10: Provision the backup plan
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
    Admin Check Overall BTS Procedural State

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

Step ${index}: Random select LNCEL
    Log    Step ${index}: Random Select LNCEL    console=True
    ${mrbts_name}    Fetch From Right    ${MRBTS_DN}    /
    Set Test Variable    ${MRBTS}    ${mrbts_name}
    ${lncel_ids}    coam.Get Ids For All    LNCEL
    ${lncel_count}    Get Length    ${lncel_ids}
    ${random}    Evaluate    random.randint(0, ${lncel_count-1})    modules=random, sys
    ${lncel_id_selected}    Set Variable    ${lncel_ids[${random}]}
    ${cells_mapping}    Fetch ID Mapping From Admin For Cells    LTE    ${lncel_id_selected}    internal
    ${lncel_id_conf_selected}    Get From Dictionary    ${cells_mapping}    configuration
    Set Test Variable    ${lncel_id_conf_selected}

Step ${index}: Import the plan SyVe
    Log    Step ${index}: Import the plan SyVe    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${file_name}    Fetch From Right    ${lock_lncel_plan_path}    /
    ${file_path}    Remove String    ${lock_lncel_plan_path}    /${file_name}
    ${file_content}    OperatingSystem.Get File    ${lock_lncel_plan_path}
    ${file_content}    Replace Variables    ${file_content}
    Create File    ${Test Results Dir}/NetActLogs/LNCEL_Lock.xml    ${file_content}
    NetAct Import Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=LNCEL_Lock.xml    plan_name=${name}

Step ${index}: Provision the plan
    Log    Step ${index}: Provision the plan    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup    create_backup_plan=True
    ...    provisioning_operation=activate

Step ${index}: Check modified parameter in Netact after provision plan
    Log    Step ${index}: Check modified parameter in Netact after provision plan   console=True
    NetAct Check Actual Configuration Parameters     PLMN-PLMN/${lncel_id_conf_selected}    ui_values=true    administrativeState=locked

Step ${index}: Check modified parameter in Admin after provision plan
    Log    Step ${index}: Check modified parameter in Admin after provision plan    console=True
    Check WebEM After Modify Parameters    ${lncel_id_conf_selected}    administrativeState=locked

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${current_plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${lncel_id_conf_selected}    ui_values=true     administrativeState=unlocked
    Run Keyword If    not ${current_plan_values}    Run Keywords    Log
    ...    Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform delta commissioning with initial scf!
    ...    level=WARN
    ...    AND    ute_admin.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown

