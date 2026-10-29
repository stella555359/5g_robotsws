*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot
*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${REPEAT_TIME}    5

*** Keywords ***
VRAN_SyVe_CM_CB013031_010_CM_Enabling_Feature_1st_Time_for_An_Existing_Operational_BTS_from_NMS
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing configuration plan provisioning changes from the Network Element perspective with processing of
    ...    setting default values parameters
    ...
    ...    Pass criteria: parameters are auto config correctly
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 26.08.2025 - New Case by Kang Lixin
    ...    *******************
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Prepare Delta Plan With Feature CB013031 Enable
    Step 2: Provision the plan
    Step 3: Check Auto-Config Parameters After Plan Provision
    Step 4: Disable Enable Feature CB013031 Multiple Times

Step ${index}: Prepare Delta Plan With Feature CB013031 Enable
    Log To Console    Step ${index}: Prepare Delta Plan With Feature CB013031 Enable
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=init_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=None    operation_type=actual
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Set Test Variable    ${target_plan_name}    vran_CB013031_010_delta_plan_with_param_change_${timestamp}
    ${plan}    NetAct Create Plan    ${target_plan_name}    vran_CB013031_010_delta_plan
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1"]
    NetAct Create Managed Object    plan=${plan}   meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1    operation=update    actCondAutoConfValCalc=true
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-1"]
    #legacyopt-y cacv-y default-y -> assign value
    ${param_dic}    Create Dictionary    alVoltHighThreshold=${EMPTY}    alVoltUnstableThreshold=10
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-1   operation=update    &{param_dic}
    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.eqm:ALD   meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/EQM-1/APEQM-1/ALD-255   operation=create
    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.eqm:LNA   meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/EQM-1/APEQM-1/ALD-255/LNA-1   operation=create    subunitNumber=1
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${target_plan_name}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=${target_plan_name}    operation_type=plan

Step ${index}: Provision the plan
    Log To Console    Step ${index}: Provision the plan
    NetAct Provision Plan    plan_name=${target_plan_name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    backup_plan_name=${target_plan_name}_backup    create_backup_plan=True    provisioning_operation=activate
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${target_plan_name}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=${target_plan_name}_backup   operation_type=plan
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Check Auto-Config Parameters After Plan Provision
    Log To Console    Step ${index}: Check Auto-Config Parameters After Plan Provision
    Wait Until Keyword Succeeds    5min    10s    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ${parameter}    Create Dictionary     controlProtocol=CWA    mhaType=WMHA
    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/EQM-1/APEQM-1/ALD-255    ui_values=true    &{parameter}
    ${parameter}    Create Dictionary    alVoltHighThreshold=107    alVoltUnstableThreshold=10
    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-1    ui_values=true    &{parameter}

Step ${index}: Disable Enable Feature CB013031 Multiple Times
    Log To Console    Step ${index}: Disable Enable Feature CB013031 Multiple Times
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Set Test Variable    ${name}    MRBTS-${vDU_id}_${timestamp}
    ${parameter}    Create Dictionary     actCondAutoConfValCalc=false   modeOfCondAutoConfValCalcDeact=1
    ${plan}    NetAct Create And Edit Plan    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    name=${name}
    ...    description=disable_feature_CB013031_MRBTS-${vDU_id}    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    scf_distName=MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1   &{parameter}
    FOR    ${index}    IN RANGE    1    ${${REPEAT_TIME}+1}
        NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=${name}_backup
        ...    create_backup_plan=True    provisioning_operation=activate
        Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
        NetAct Provision Plan    plan_name=${name}_backup   dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=None
        ...    create_backup_plan=False    provisioning_operation=activate
        Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    END

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${cu_ip}    PLMN-PLMN/MRBTS-${vCU_id}    ${cu_release}    ${cu_mr}
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}
    @{para_list}    Create List    alVoltHighThreshold    alVoltUnstableThreshold
    @{value_list}    Create List    107     5
    @{mo_list}    Create List    MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-1    MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}

Case Postcondition
    Log To Console    Case Postcondition
    NetAct Provision Plan    plan_name=${target_plan_name}_backup   dist_names=PLMN-PLMN/MRBTS-${vDU_id}   backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
	Wait Until Keyword Succeeds    15m    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Common Test Teardown For AIC
    vDU Login By Rest
    Run Keyword And Ignore Error    vDU Logout By Rest
    Teardown NetAct
