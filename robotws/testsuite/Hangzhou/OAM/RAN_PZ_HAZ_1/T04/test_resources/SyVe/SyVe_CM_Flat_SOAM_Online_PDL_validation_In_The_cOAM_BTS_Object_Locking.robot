*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
TC__SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22139
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    New testcase transform from LTE4985-C_ST_05_04_Flat_SOAM_On-line PDL validation in the cOAM BTS_object locking.
    ...    To check the locking object parameters on validation when setting 'enableAutoLock' as Enable.
    ...
    ...    The main steps performed for the test are:
    ...    - Select Param And MO And Check Value
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Diable AutoLock Via NetAct
    ...    - Check Object Locking Param Validation Is Disable
    ...    - Enable AutoLock Via NetAct
    ...    - Check Object Locking Param Validation Is Enable
    ...    - Provision the backup plan
    ...    - Check recovered BTS state
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: create, edit, export, pre-activation and provision operation works as expected; states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22139 - New case
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-22139-SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking.png
    Set Tags    CM    AUTHOR-bin.7.liu@nokia.com    PHASE-SyVe    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 1: Select Param And MO And Check Value
    Step 2: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Upload configuration status
    Step 6: Diable AutoLock Via NetAct
    Step 7: Check Object Locking Param Validation Is Disable
    Step 8: Enable AutoLock Via NetAct
    Step 9: Check Object Locking Param Validation Is Enable
    Step 10: Provision the backup plan
    Step 11: Check Final BTS state
    Step 12: Check final alarms status from WebEM
    Step 13: Check final alarms status from Netact
    Step 14: Check final number and state of Cells and RMs

TC Setup
    Log    TC Setup    console=True
    Common Test Setup

TC Teardown
    Log    TC Teardown    console=True
    Particular Teardown

Particular Teardown
    ${dic_param_value}    Create Dictionary    enableAutoLock=Enabled    planFileActivationMode=totalServiceLossAllowed
    ${is_recovered}    Run Keyword And Return Status    NetAct Check Actual Configuration Parameters    PLMN-PLMN/${LNBTS_DN}    true
    ...     &{dic_param_value}
#    ${is_recovered}    Run Keyword Unless    ${is_recovered}    Run Keyword And Return Status    Step Recover: Provision the backup plan
    ${is_recovered}    Run Keyword If    not ${is_recovered}    Run Keyword And Return Status    Step Recover: Provision the backup plan
    FOR    ${plan_name}    IN    @{NAMES_OF_SYVE_PLAN}
        Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}
    END
    Run Keyword If    '${is_recovered}'=='${False}'    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=400
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC parameters check
    Log    TC parameters check started    console=True
    ${dic_param_value_check}    Create Dictionary    enableAutoLock=Disabled    planFileActivationMode=totalServiceLossAllowed
    ${same_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters    PLMN-PLMN/${LNBTS_DN}    true
    ...    &{dic_param_value_check}
    Set Test Variable    ${same_values}
    Run Keyword If    ${same_values}    Log    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!
    ...    level=WARN
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${same_values}

Select Param And MO Randomly
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${elements_to_select}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="NOKLTE:LNCEL_TDD"]
    ${dic_param_value}    Evaluate    {"actNoIntraBandIFMeasurements":["true","false"],"puschHopOffset":["4","5","6"]}
    ${tdd_count}    Get Length    ${elements_to_select}
    ${HAS_NO_TDD}    Set Variable If    '${tdd_count}'=='${0}'    ${True}    ${False}
    ${PARAM_NAME}    Set Variable If    ${has_no_tdd}    actNoIntraBandIFMeasurements    puschHopOffset
    ${lte_cell_elements}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="NOKLTE:LNCEL"]
    Run Keyword If    ${has_no_tdd}    Append To List    ${elements_to_select}    @{lte_cell_elements}
    ${count}    Get Length    ${elements_to_select}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${MO_DN}    L_XML.Get Element Attribute    ${elements_to_select[${index}]}    distName
    ${CUR_VAL}    L_XML.Get Element Text    ${scf_xml}    .//managedObject[@distName="${mo_dn}"]/p[@name="${param_name}"]
    ${LNBTS_DN}    Fetch From Left    ${MO_DN}    /LNCEL-
    ${MRBTS_DN}    Fetch From Left    ${MO_DN}    /LNBTS-
    Remove Values From List    ${dic_param_value["${PARAM_NAME}"]}    ${CUR_VAL}
    ${count}    Get Length    ${dic_param_value["${PARAM_NAME}"]}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${VAL_TO_SET}    Set Variable    ${dic_param_value["${PARAM_NAME}"][${index}]}
    ${NAMES_OF_SYVE_PLAN}    Create List
    Set Test Variable    ${NAMES_OF_SYVE_PLAN}
    Set Test Variable    ${HAS_NO_TDD}
    Set Test Variable    ${MO_DN}
    Set Test Variable    ${CUR_VAL}
    Set Test Variable    ${VAL_TO_SET}
    Set Test Variable    ${PARAM_NAME}
    Set Test Variable    ${LNBTS_DN}
    Set Test Variable    ${MRBTS_DN}

Step ${index}: Select Param And MO And Check Value
    Log    Step ${index}: Select Param And MO And Check Value    console=True
    Select Param And MO Randomly
    TC parameters check

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    5 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=PLMN-PLMN/${MRBTS_DN}

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    dist_name=${MRBTS_DN}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv    dist_names=PLMN-PLMN/${MRBTS_DN}
    ...    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=PLMN-PLMN/${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Diable AutoLock Via NetAct
    Log    Step ${index}: Diable AutoLock Via NetAct    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${mrbts_id}    Fetch From Right    ${MRBTS_DN}    -
    Set Test Variable    ${mrbts_id}
    Should Be String    ${MRBTS_DN}_${timestamp}
    Set Test Variable    ${name}    ${MRBTS_DN}_${timestamp}
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${name}
    ${dic_param_value}    Create Dictionary    enableAutoLock=${0}    planFileActivationMode=${0}
    ${plan}    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe disable autolock    mo_id=PLMN-PLMN/${LNBTS_DN}
    ...    scf_distName=${LNBTS_DN}    &{dic_param_value}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=PLMN-PLMN/${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/${MRBTS_DN}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    ${dic_param_value_check}    Create Dictionary    enableAutoLock=Disabled    planFileActivationMode=totalServiceLossAllowed
    NetAct Check Actual Configuration Parameters    PLMN-PLMN/${LNBTS_DN}    true    &{dic_param_value_check}

Step ${index}: Check Object Locking Param Validation Is ${enable}
    Log    Step ${index}: Check Object Locking Param Validation Is ${enable}    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    ${MRBTS_DN}_${timestamp}
    ${plan_name}    Set Variable    ${MRBTS_DN}_${timestamp}
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${plan_name}
    ${dic_param_value}    Create Dictionary    ${PARAM_NAME}=${VAL_TO_SET}
    ${plan}    NetAct Create And Edit Plan    name=${plan_name}    description=Automation SyVe check autolock is ${enable}
    ...    mo_id=PLMN-PLMN/${MO_DN}    scf_distName=${MO_DN}    &{dic_param_value}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${plan_name}.csv    dist_names=PLMN-PLMN/${MRBTS_DN}
    ...    plan_name=${plan_name}    operation_type=plan
    ${ret}    ${err_msg}    Run Keyword And Ignore Error    netact.Provision Plan    plan_name=${plan_name}    dist_names=PLMN-PLMN/${MRBTS_DN}
    ...    backup_plan_name=${plan_name}_backup
    ...    create_backup_plan=True    provisioning_operation=preactivate
    ${ret}    Set Variable If    '${ret}'=='PASS'    ${True}    ${False}
    ${expect_ret}    Run Keyword And Return Status    Should Be Equal As Strings    ${enable}    Enable    ignore_case=${True}
    Should Be Equal    ${ret}    ${expect_ret}
#    Run Keyword Unless    ${expect_ret}    Should Contain    ${err_msg}    Automatic locking not possible because enableAutoLock = disabled
    Run Keyword If    not ${expect_ret}    Should Contain    ${err_msg}    Automatic locking not possible because enableAutoLock = disabled
    Run Keyword If    ${expect_ret}    NetAct Activate Plan    plan_name=${plan_name}    dist_names=PLMN-PLMN/${MRBTS_DN}

Step ${index}: Enable AutoLock Via NetAct
    Log    Step ${index}: Enable AutoLock Via NetAct    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${mrbts_id}    Fetch From Right    ${MRBTS_DN}    -
    Set Test Variable    ${mrbts_id}
    Should Be String    ${MRBTS_DN}_${timestamp}
    ${tmp_name}    Set Variable    ${MRBTS_DN}_${timestamp}
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${tmp_name}
    ${dic_param_value}    Create Dictionary    enableAutoLock=${1}
    ${plan}    NetAct Create And Edit Plan    name=${tmp_name}    description=Automation SyVe \ enabled autolock    mo_id=PLMN-PLMN/${LNBTS_DN}
    ...     scf_distName=${LNBTS_DN}    &{dic_param_value}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${tmp_name}.csv    dist_names=PLMN-PLMN/${MRBTS_DN}
    ...    plan_name=${tmp_name}    operation_type=plan
    NetAct Provision Plan    plan_name=${tmp_name}    dist_names=PLMN-PLMN/${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    ${dic_param_value_check}    Create Dictionary    enableAutoLock=Enabled    planFileActivationMode=totalServiceLossAllowed
    NetAct Check Actual Configuration Parameters    PLMN-PLMN/${LNBTS_DN}    true    &{dic_param_value_check}
