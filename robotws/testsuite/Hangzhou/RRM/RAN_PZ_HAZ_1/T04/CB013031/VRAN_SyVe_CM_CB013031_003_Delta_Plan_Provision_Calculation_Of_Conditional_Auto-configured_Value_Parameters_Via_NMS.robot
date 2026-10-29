*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for RAN_ST_CB013031_003_CM_Delta configuration plan provisioning
...                 (calculation and recalculation of conditional auto-configured value parameters) from NMS
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${NRCELL_ID}    0

*** Keywords ***
VRAN_SyVe_CM_CB013031_003_Delta_Plan_Provision_Calculation_Of_Conditional_Auto-configured_Value_Parameters_Via_NMS
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    04.09.2025, yuyan.xu@nokia-sbell.com
    Step 1: Prepare Env To Enable CB013031
    Step 2: Prepare Delta Plan With Optional Params Has CACV Rule
    Step 3: Provision the plan
    Step 4: Check Auto-Configured Parameter Values
    Step 5: Modify Depend Parameter And Check Auto-Config Parameter Value

Step ${index}: Prepare Env To Enable CB013031
    Log To Console    Step ${index}: Prepare Env To Enable CB013031
#    @{para_list}    Create List    actCondAutoConfValCalc
#    @{value_list}    Create List    true
#    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1
    Log To Console    Modify actCondAutoConfValCalc to true
#    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
#    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    ${timestamp}    Get Time    epoch
    Set Test Variable    ${name}    MRBTS-${vDU_id}_${timestamp}
    ${parameter}    Create Dictionary     actCondAutoConfValCalc=true
    ${plan}    NetAct Create And Edit Plan    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    name=${name}
    ...    description=enable_feature_CB013031_MRBTS-${vDU_id}    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    scf_distName=MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1   &{parameter}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate

    vDU Login By Rest
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Prepare Delta Plan With Optional Params Has CACV Rule
    Log To Console    Step ${index}: Prepare Delta Plan With Optional Params Has CACV Rule
    ###Legacy-y  CACV-y  default-y:
    #NRBTS:
    #actRanSharingEnh(not match, set empty)
    #rejectSuppBcs (match set defaultnone,default:0 none )
    #EQM:
    #new EQM/APeQM/ALD mhaType(match set default WMHA,default:WMHA)
    #advanceTimeForRURestore (not match, set empty)

    ###Legacy-y  CACV-y  default-n:
    #NRBTS:
    #new MRBTS-11084/NRBTS-11084/NRCELL-0/NRRIM_PROFILE-1  rsPattern1Period (not match, set empty)
    #MNL:
    #phaseJumpDetectionThreshold (not match, set empty)
    #remoteSyslogConfig
    #EQM:
    #useMeasuredRoundTripDelay (match set false)

    ###Legacy-n  CACV-y  default-y:
    #NRBTS:
    #actBbPoolExtensionTddFr1/actBbPoolTddFr1Enh/actBbPoolTddFr1/actBbPoolTddFr1AlgEnh/actLargeBbPoolTddFr1
    #/actScheUePooling(match set true,default:false)
    #actBtcOvlProt/actSlowPrbPoolingFddFr1Enh/actTddCsiRsOpt(not match, set default:false)
    #EQM:
    #new EQM/APeQM/ALD controlProtocol(match set CWA, no match set default:AISG 2.0)

    ###Legacy-n  CACV-y  default-n:
    #NRBTS:
    #scs(not match, set empty)


    ${timestamp}    Get Time    epoch
    Set Test Variable    ${name_deltaplan}    CB013031_003_delta_plan_${timestamp}
    ${plan}    NetAct Create Plan    ${name_deltaplan}    CB013031_003_delta_plan
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ${MO_items_NRBTS}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}"]
    #actRanSharingEnh=0  disabled
    ${param_dic}    Create Dictionary    rejectSuppBcs=${EMPTY}    actRanSharingEnh=0    actBbPoolExtensionTddFr1=${EMPTY}   actBtcOvlProt=${EMPTY}
    NetAct Create Managed Object    plan=${plan}   meta_class=${MO_items_NRBTS['class']}    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   operation=update    &{param_dic}

    ${param_dic}    Create Dictionary    actDlOptMcsSelection=${EMPTY}    lowerMcsPowerBackoff=${EMPTY}    n310PubSafety=10
    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.nrbts:NRCELL    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}  operation=update    &{param_dic}

    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.nrbts:NRDLMUMIMO    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}/NRDLMUMIMO-1  operation=create

    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${name_deltaplan}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=${name_deltaplan}    operation_type=plan


Step ${index}: Provision the plan
    Log To Console    Step ${index}: Provision the plan
    NetAct Provision Plan    plan_name=${name_deltaplan}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    backup_plan_name=${name_deltaplan}_backup    create_backup_plan=True    provisioning_operation=activate
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${name_deltaplan}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=${name_deltaplan}_backup    operation_type=plan
    Wait Until Keyword Succeeds    10m    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Check Auto-Configured Parameter Values
    Log To Console    Step ${index}: Check Auto-Configured Parameter Values
    ${parameter}    Create Dictionary     rejectSuppBcs=none    actRanSharingEnh=disabled    actBbPoolExtensionTddFr1=true   actBtcOvlProt=false
    Wait Until Keyword Succeeds    2m    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   ui_values=true    &{parameter}
    ${parameter}    Create Dictionary    actDlOptMcsSelection=true    lowerMcsPowerBackoff=14    n310PubSafety=n10
    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}    ui_values=true    &{parameter}
    ${parameter}    Create Dictionary    actDlMuPairingGroup=false    actExcludeLowBufferUser=false    actMuAwareTdSch=false
    ...    dlMuMimoZfCorrThd=0.6    highBufferThdMuPairingGroup=60    lowBufferThdMuPairingGroup=10
    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}/NRDLMUMIMO-1    ui_values=true    &{parameter}

Step ${index}: Modify Depend Parameter And Check Auto-Config Parameter Value
    Log To Console    Step ${index}: Modify Depend Parameter And Check Auto-Config Parameter Value
    #Legacy-y  CACV-y  default-y:
    #maxBtsTimeError(not match, set empty, match set default:1000)
    #CACV rule:If NRCELL.actEdrx is not equal to 'None' then SET NRBTS.maxBtsTimeError to DEFAULT.
    ${timestamp}    Get Time    epoch
    Set Test Variable    ${name_depend_param1}    CB013031_003_depend_param_${timestamp}
    ${plan}    NetAct Create Plan    ${name_depend_param1}    CB013031_003_depend_param
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ${MO_items_NRBTS}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}"]
    ${param_dic}    Create Dictionary    maxBtsTimeError=${EMPTY}
    NetAct Create Managed Object    plan=${plan}   meta_class=${MO_items_NRBTS['class']}    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   operation=update    &{param_dic}
    ${param_dic}    Create Dictionary    actEdrx=0
    NetAct Create Managed Object    plan=${plan}   meta_class=com.nokia.srbts.nrbts:NRCELL    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}    operation=update    &{param_dic}
    NetAct Provision Plan    plan_name=${name_depend_param1}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    backup_plan_name=${name_depend_param1}_backup    create_backup_plan=True    provisioning_operation=activate
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${name_depend_param1}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=${name_depend_param1}    operation_type=plan
    Wait Until Keyword Succeeds    10m    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

    ${parameter}    Create Dictionary     maxBtsTimeError=${EMPTY}
    Wait Until Keyword Succeeds    2m    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   ui_values=true    &{parameter}
    ${parameter}    Create Dictionary     actEdrx=None
    Wait Until Keyword Succeeds    2m    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}    ui_values=true    &{parameter}

    ${timestamp}    Get Time    epoch
    Set Test Variable    ${name_depend_param2}    CB013031_003_depend_param_${timestamp}
    ${plan}    NetAct Create Plan    ${name_depend_param2}    CB013031_003_depend_param
    ${param_dic}    Create Dictionary    maxBtsTimeError=${EMPTY}
    NetAct Create Managed Object    plan=${plan}   meta_class=${MO_items_NRBTS['class']}    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   operation=update    &{param_dic}
    ${param_dic}    Create Dictionary    actEdrx=1
    NetAct Create Managed Object    plan=${plan}   meta_class=com.nokia.srbts.nrbts:NRCELL    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}    operation=update    &{param_dic}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${name_depend_param2}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=${name_depend_param2}    operation_type=plan
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark_oam    product_type=vdu    bts_index=${0}    cudu_index=${0}    #dict_argument=${dict_argument}

    NetAct Provision Plan    plan_name=${name_depend_param2}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    backup_plan_name=${name_depend_param2}_backup    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    10m    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    sleep    10s
    ${local_file_path}    Log Collection    stop_and_download    wireshark_oam    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nwireshark log: ${local_file_path}
    ${parameter}    Create Dictionary     maxBtsTimeError=1000
    Wait Until Keyword Succeeds    2m    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   ui_values=true    &{parameter}
    ${parameter}    Create Dictionary     actEdrx=Idle
    Wait Until Keyword Succeeds    2m    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}   ui_values=true    &{parameter}


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
    Common Test Teardown For AIC
    Teardown NetAct