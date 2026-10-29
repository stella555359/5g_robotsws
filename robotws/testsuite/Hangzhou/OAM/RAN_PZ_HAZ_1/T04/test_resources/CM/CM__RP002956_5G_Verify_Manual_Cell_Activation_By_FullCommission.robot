*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
 # Absolute path to commissioning file, should be a effective SCF file, otherwise might influence recovering of test line
${COMMISSIONING_PATH}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml

*** Keywords ***
CM__RP002956_5G_Verify_Manual_Cell_Activation_By_FullCommission
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    - Verify NRCELL locking through fullcommission
    ...    The main steps performed for the test are:
    ...    - Get And Modify Current SCF
    ...    - Perform Commission And Check NR Cells Locked
    ...    - Unlock NR Cells
    ...    Pass criteria: All operations are as expected.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 18.06.2021 - Commit to GIT
    ...    - 20.01.2022 - Modified by Kang Lixin  - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...    - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin

    Set Tags    CA-CM    MAINTAINER-lixin.kang@nokia-sbell.com
    ...    AUTHOR-bin.7.liu@nokia-sbell.com    PHASE-CRT    SW-SBTS21B
    ...    GROUP_IN_CHARGE-SRAN_PROD_HZ1    API
    Step 1: Get And Modify Current SCF
    Step 2: Perform Commission And Check NR Cells Locked
    Step 3: Unlock NR Cells

TC Setup
    Common Test Setup    scf_check=${FALSE}    syslog_launch=${FALSE}

TC Teardown
    Run Keyword If    ${NEED_RECOVER}    Admin Get bts_id and perform commissioning    ${COMMISSIONING_PATH}    ${True}
    Wait Until Keyword Succeeds    20 mins    30 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Common Test Teardown SBTS

Step ${index}: Get And Modify Current SCF
    Log    Step ${index}: Get And Modify Current SCF    console=True
    Set Test Variable    ${NEED_RECOVER}    ${False}
    ${cur_scf}    coam.Get Scf
    ${cur_scf_xml}    XML.Parse XML    ${cur_scf}
    ${mrbts_dn}    XML.Get Element Attribute    ${cur_scf_xml}    distName    cmData/managedObject[@class="com.nokia.srbts:MRBTS"]
    ${MRBTS_ID}    Fetch From Right    ${mrbts_dn}    -
    ${nr_cell_elements}    XML.Get Elements    ${cur_scf_xml}    cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    Should Not Be Empty    ${nr_cell_elements}
    ${NR_CELL_DNs}    Create List
    FOR    ${element}    IN    @{nr_cell_elements}
       ${status}    XML.Get Element Text    ${element}    p[@name="administrativeState"]
       Should Be Equal As Strings    Unlocked    ${status}
       ${DN}    XML.Get Element Attribute    ${element}    distName
       Append To List    ${NR_cell_DNs}    ${DN}
    END
    ${configed_actManualCellActivation}    ${origin_actManualCellActivation}    Run Keyword And Ignore Error    XML.Get Element Text
    ...    ${cur_scf_xml}    cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="actManualCellActivation"]
    ${origin_actManualCellActivation}    Set Variable If    '${configed_actManualCellActivation}'=='PASS'
    ...    ${origin_actManualCellActivation}    ${EMPTY}
    ${NRBTS_DN}    XML.Get Element Attribute    ${cur_scf_xml}    distName    cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
    Run Keyword If    '${configed_actManualCellActivation}'=='PASS'    XML.Set Element Text    ${cur_scf_xml}    true    None
    ...    cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="actManualCellActivation"]
    ...    ELSE    XML.Add Element    ${cur_scf_xml}    <p name="actManualCellActivation">true</p>    None
    ...    cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
    XML.Save XML    ${cur_scf_xml}    ${OUTPUT DIR}/tmp_scf.xml
    Set Test Variable    ${SCF_PATH}    ${OUTPUT DIR}/tmp_scf.xml
    Set Test Variable    ${MRBTS_ID}
    Set Test Variable    ${NR_CELL_DNs}
    Set Test Variable    ${NRBTS_DN}

Step ${index}: Perform Commission And Check NR Cells Locked
    Log    Step ${index}: Perform Commission And Check NR Cells Locked    console=True
    Set Test Variable    ${NEED_RECOVER}    ${True}
    coam.Perform Commissioning    ${MRBTS_ID}    ${SCF_PATH}    skip_parameter_relation_errors=${False}    timeout=600
    Wait Until Keyword Succeeds    20 mins    30 sec    Check_RMOD_SMOD_Cell_Status_And_Alarms_After_NRDU_Locked_Via_Admin

Step ${index}: Unlock NR Cells
    Log    Step ${index}: Unlock NR Cells    console=True
    ${delta_param_list}    Create List
    FOR    ${DN}    IN    @{NR_CELL_DNs}
        &{dic}    Evaluate
        ...  {"distName":"${DN}","operation":"update","parameters":[{"parameterName":"administrativeState","value":"Unlocked","operation":"update"}]}
        Append To List    ${delta_param_list}    ${dic}
    END
    ${tmp_str}    Set Variable   [{"parameterName": "actManualCellActivation", "operation": "update", "value": "false"}]
    &{dic}    Evaluate
    ...   {"distName": "${NRBTS_DN}", "operation": "update", "parameters": ${tmp_str}}
    Append To List    ${delta_param_list}    ${dic}
    ${delta_json}    Convert To String    ${delta_param_list}
    ${delta_json}    Replace String    ${delta_json}    '    "
    coam.Perform delta recommissioning    ${delta_json}
    Wait Until Keyword Succeeds    10 mins    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Set Test Variable    ${NEED_RECOVER}    ${False}

Check_RMOD_SMOD_Cell_Status_And_Alarms_After_NRDU_Locked_Via_Admin
    ${are_smods_online}    ${smods_statuses}=    Check If All Objects Are Online    SMOD    10 sec
    ${are_rmods_online}    ${rmods_statuses}=    Check If All Objects Are Online    RMOD    10 sec
    ${are_gcells_online}    ${gcells_statuses}=    Check If All Objects Are Online    GNCEL    10 sec
    ...    administrativeState=${_Com_Unlocked_}    operationalState=${_Enabled_}    blockingState=${_Unblocked_}
     ...    usageState=${_Active_}
    ${are_wcells_online}    ${wcells_statuses}=    Check If All Objects Are Online    WNCEL    10 sec
    ...    operationalState=${_Enabled_}    blockingState=${_Unblocked_}    usageState=${_Active_}
    ${are_lcells_online}    ${lcells_statuses}=    Check If All Objects Are Online    LNCEL    10 sec
    ...    administrativeState=${_Unlocked_}    operationalState=${_Enabled_}    blockingState=${_Unblocked_}
    ${are_nrcells_disabled}    ${cells}    Run Keyword And Ignore Error    coam.Assert Every    NRCEL
    ...    administrativeState=${_Com_Locked_}, operationalState=${_Disabled_},availabilityStatus="${_Offline_}",blockingState=${_Unblocked_}
    Admin Check Active Alarms    print_alarms=${False}
    ${condition1}    Set Variable   "${are_gcells_online}"=="PASS" and "${are_wcells_online}"=="PASS"
    ${condition2}    Set Variable   "${are_lcells_online}"=="PASS" and "${are_nrcells_online}"=="PASS"
    Should be true    ${condition1} and ${condition2}    Not all conditions were satisfied!