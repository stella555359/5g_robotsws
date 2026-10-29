*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${NRCELL_ID}    0

*** Keywords ***
VRAN_SyVe_CM_CB013031_019_Delta_Configuration_Plan_Provisioning_Setting_of_Default_Value_Parameters_from_NMS
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
    ...    - 25.08.2025 - New Case by Kang Lixin
    ...    *******************
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Prepare Env To Enable CB013031
    Step 2: Prepare Delta Plan With Optional Params Has Default Value
    Step 3: Provision the plan
    Step 4: Check Auto-Config Parameters After Plan Provision

Step ${index}: Prepare Env To Enable CB013031
    Log To Console    Step ${index}: Prepare Env To Enable CB013031
#    @{para_list}    Create List    actCondAutoConfValCalc
#    @{value_list}    Create List    true
#    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1
    Log To Console    Modify actCondAutoConfValCalc to true
#    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
#    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Set Test Variable    ${name}    MRBTS-${vDU_id}_${timestamp}
    ${parameter}    Create Dictionary     actCondAutoConfValCalc=true
    ${plan}    NetAct Create And Edit Plan    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    name=${name}
    ...    description=enable_feature_CB013031_MRBTS-${vDU_id}    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    scf_distName=MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1   &{parameter}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate

    vDU Login By Rest
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Prepare Delta Plan With Optional Params Has Default Value
    Log To Console    Step ${index}: Prepare Delta Plan With Optional Params Has Default Value
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Set Test Variable    ${target_plan_name}    vran_CB013031_019_delta_plan_with_param_change_${timestamp}
    ${plan}    NetAct Create Plan    ${target_plan_name}    CB013031_019_cran_delta_plan
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}"]
    ${param_dic}    Create Dictionary    act3gppBL22R2=${EMPTY}    actBbPoolExtensionTddFr1=${EMPTY}    actBcsCheck=0
    NetAct Create Managed Object    plan=${plan}   meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   operation=update    &{param_dic}
    ${param_dic}    Create Dictionary    actDlOptMcsSelection=${EMPTY}    lowerMcsPowerBackoff=${EMPTY}    n310PubSafety=10
    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.nrbts:NRCELL    meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}  operation=update    &{param_dic}
    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.nrbts:NRDLMUMIMO    meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}/NRDLMUMIMO-1  operation=create
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${target_plan_name}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=${target_plan_name}    operation_type=plan

Step ${index}: Provision the plan
    Log To Console    Step ${index}: Provision the plan
    NetAct Provision Plan    plan_name=${target_plan_name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    backup_plan_name=${target_plan_name}_backup    create_backup_plan=True    provisioning_operation=activate
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${target_plan_name}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=${target_plan_name}_backup    operation_type=plan
    Wait Until Keyword Succeeds    10m    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Check Auto-Config Parameters After Plan Provision
    Log To Console    Step ${index}: Check Auto-Config Parameters After Plan Provision
    ${parameter}    Create Dictionary     act3gppBL22R2=true    actBbPoolExtensionTddFr1=true   actBcsCheck=disabled
    Wait Until Keyword Succeeds    2m    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   ui_values=true    &{parameter}
    ${parameter}    Create Dictionary    actDlOptMcsSelection=true    lowerMcsPowerBackoff=14    n310PubSafety=n10
    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}    ui_values=true    &{parameter}
    ${parameter}    Create Dictionary    actDlMuPairingGroup=false    actExcludeLowBufferUser=false    actMuAwareTdSch=false
    ...    dlMuMimoZfCorrThd=0.6    highBufferThdMuPairingGroup=60    lowBufferThdMuPairingGroup=10
    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}/NRDLMUMIMO-1    ui_values=true    &{parameter}

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

Case Postcondition
    Log To Console    Case Postcondition
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${target_plan_name}_backup
    Run Keyword If    '${status}' == 'PASS'
    ...    NetAct Provision Plan    plan_name=${target_plan_name}_backup   dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    backup_plan_name=None    create_backup_plan=False    provisioning_operation=activate
   # @{para_list}    Create List    actCondAutoConfValCalc
   # @{value_list}    Create List    false
   # @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1
    Log To Console    Modify actCondAutoConfValCalc to false
   # ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
   # ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    NetAct Provision Plan    plan_name=${name}_backup  dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
	Wait Until Keyword Succeeds    15m    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Common Test Teardown For AIC
    vDU Login By Rest
    Run Keyword And Ignore Error    vDU Logout By Rest
    Teardown NetAct
