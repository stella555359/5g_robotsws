*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
# nrcell delete plan will provision on NetAct
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${CHANGED_TRX_NUM}    2
@{CHANNELGROUP_TO_REMOVE}    LCELC-1/CHANNELGROUP-2    LCELC-1/CHANNELGROUP-3    LCELC-2/CHANNELGROUP-3    LCELC-2/CHANNELGROUP-2
...    LCELC-3/CHANNELGROUP-2    LCELC-3/CHANNELGROUP-3

*** Keywords ***
TC__SyVe_CM_Provision_To_Add_And_Delete_TRX
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    EDA Action for CAS-298659-K1B0 - Operability: https://jiradc.ext.net.nokia.com/browse/MNRCA-31586
    ...    Transfer from case RmtOAM_CM_Provision_SBTS_Delta_Plan_To_Add_And_Delete_TRX_Automated.robot
    ...    Difference from old case: 1. Remove plan file, create syve plan in code instead.
    ...    Difference from old case: 2. Delete TRx first.
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Get Original TRX Number
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check SBTS Status and TRX Number After Delete
    ...    - Provision the backup plan
    ...    - Check SBTS Status and TRX Number After Add
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.12.2023 - New case created.
    Set Tags    AUTHOR-bin.7.liu@nokia-sbell.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 6: Get Original TRX Number
    Step 5: Upload configuration status
    Step 6: Create and edit plan SyVe
    Step 7: Export the plan SyVe
    Step 8: Provision the plan SyVe
    Step 9: Check SBTS Status and TRX Number After Delete
    Step 10: Provision the backup plan
    Step 11: Check SBTS Status and TRX Number After Add
    Step 12: Check final alarms status from WebEM
    Step 13: Check final alarms status from Netact

Step ${index}: Get Original TRX Number
    Log    Step ${index}: Get Original TRX Number   console=${True}
    SBTS WEM Open RunTime View    C
    Wait Until Page Contains    TRX status:    10
    ${elemetns}    Get WebElements
    ...    //ng-view//div[@cell-element]//div[contains(@class,"cell-element-container")]//div[contains(@class,"cell-element-text")]//span
    FOR    ${element}    IN    @{elemetns}
        ${text}    Get Text    ${element}
        ${is_not_TRX}    Run Keyword And Return Status    Should not Contain    ${text}    TRX status:
        Continue For Loop If    ${is_not_TRX}
        ${TRX1}    Fetch from Right    ${text}    /
        ${TRX2}    Fetch from Left    ${text}    /
        ${TRX2}    Fetch from Right    ${TRX2}    :
        ${TRX2}    evaluate    '${TRX2}'.strip()
        set test variable    ${original_onair_TRX_num}    ${TRX2}
        set test variable    ${original_total_TRX_num}    ${TRX1}
        Exit For Loop
    END

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    20 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAf

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

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected LNCELL
    Log    Step ${index}: Create and edit plan SyVe    console=True
    Set Test Variable    ${name}    ${TEST_NAME}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${e_to_remove}    Create List
    FOR    ${channelGroup}    IN    @{CHANNELGROUP_TO_REMOVE}
        ${es}    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@distName,"${channelGroup}")]
        Append To List    ${e_to_remove}    @{es}
    END
    FOR    ${e}    IN    @{e_to_remove}
        ${MO_items}    L_XML.Get Element Attributes    ${e}
        ${managed_object}    netact.create_managed_object    plan=${plan}    meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
        ...    mo_id=PLMN-PLMN/${MO_items["distName"]}    operation=DELETE
        netact.Get Managed Object    configuration=${plan}    mo_id=PLMN-PLMN/${MO_items["distName"]}
    END

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    Set Test Variable    ${NEED_RECOVER}    ${True}
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup    create_backup_plan=True
    ...    provisioning_operation=activate

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    Set Test Variable    ${NEED_RECOVER}    ${False}

Step ${index}: Check SBTS Status and TRX Number After ${operation}
    LOG    Step ${index}: Check SBTS Status and TRX Number After ${operation}    console=${True}
    Wait Until Keyword Succeeds    300s    60s    Status Of RAT Should Be OK
    ${delete_onair_TRX_num}    evaluate    ${original_onair_TRX_num} - ${CHANGED_TRX_NUM}
    ${deleted_total_TRX_num}    evaluate    ${original_total_TRX_num}
    ${added_TRX_num}    create list    ${original_onair_TRX_num}    ${original_total_TRX_num}
    ${deleted_TRX_num}    create list    ${delete_onair_TRX_num}    ${deleted_total_TRX_num}
    ${expected_TRX_num}    set variable if    '${operation}'=='Add'    ${added_TRX_num}    ${deleted_TRX_num}
    Wait Until Keyword Succeeds    600s    60s    SBTS WEM Check TRX Number    ${expected_TRX_num[0]}    ${expected_TRX_num[1]}
    Verify RATs State Changed From IMS2    ${BTSFiles}/InfoModel_log_for_status_check_${operation}.ims2    GSM

Particular Teardown
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    Run Keyword If    ${NEED_RECOVER}    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=400
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown
    Close All Browsers

TC Setup
    Common Test Setup
    ${win_index}    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}    setup_param=${False}

TC Teardown
    Particular Teardown
