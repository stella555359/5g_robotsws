*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for RAN_ST_CB013031_012_CM_Disabling CB0130131 with delta plan for an operational BTS
...                 having auto-configured parameters in actual configuration from NMS
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${NRCELL_ID}    0

*** Keywords ***
VRAN_SyVe_CM_CB013031_012_Disabling_CB0130131_With_Delta_Plan_For_BTS_Having_Auto-configured_Parameters_Via_NMS
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    18.09.2025, yuyan.xu@nokia-sbell.com
    Step 1: Prepare Delta Plan With CB013031 Enable
    Step 2: Provision the Delta Plan With CB013031 Enable
    Step 3: Check Auto-Config Parameters After Plan Provision
    Step 4: Disable CB013031 With REMOVE_VALUES
    Step 5: Check Parameters After Disable CB013031 With REMOVE_VALUES
    Step 6: Provision the Delta Plan With CB013031 Enable
    Step 7: Check Auto-Config Parameters After Plan Provision
    Step 8: Disable CB013031 With KEEP_VALUES
    Step 9: Check Parameters After Disable CB013031 With KEEP_VALUES

Step ${index}: Prepare Delta Plan With CB013031 Enable
    Log To Console    Step ${index}: Prepare Delta Plan With CB013031 Enable
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=init_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=None    operation_type=actual
    ${timestamp}    Get Time    epoch
    Set Test Variable    ${name_enable}    CB013031_012_MRBTS-${vDU_id}_${timestamp}_enable
    ${plan}    NetAct Create Plan    ${name_enable}    CB013031_012_MRBTS-${vDU_id}_${timestamp}_enable

    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1"]
    NetAct Create Managed Object    plan=${plan}   meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1    operation=update    actCondAutoConfValCalc=true

    ${MO_items_NRBTS}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}"]
    Set Test Variable    ${MO_items_NRBTS}
    #actRanSharingEnh=0  disabled
    #Legacy-y  CACV-y  default-y:
    ${param_dic}    Create Dictionary    rejectSuppBcs=${EMPTY}    actRanSharingEnh=${EMPTY}    actBcsCheck=0
    #actBbPoolExtensionTddFr1=${EMPTY}   actBtcOvlProt=${EMPTY}
    NetAct Create Managed Object    plan=${plan}   meta_class=${MO_items_NRBTS['class']}    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   operation=update    &{param_dic}

    #legacyopt-y(or n) cacv-y default-n  CACV work-> delete, will be CACV value false
    #MRBTS-11084/EQM-1/APEQM-1/RMOD-1/ANTL-1  useMeasuredRoundTripDelay
    ${MO_items_RMOD}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-1"]
    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.eqm:ANTL    meta_version=${MO_items_RMOD['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-1/ANTL-1   operation=update    useMeasuredRoundTripDelay=${EMPTY}

    #legacyopt-n cacv-n(or y) default-y  CACV work-> delete, will be default
    #MRBTS-11084/NRBTS-11084 actRanSharing:default:false
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items_NRBTS['class']}    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}   operation=update    actRanSharing=${EMPTY}

    #user config
    ${param_dic}    Create Dictionary    actDlOptMcsSelection=true    lowerMcsPowerBackoff=14    n310PubSafety=10
    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.nrbts:NRCELL    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}  operation=update    &{param_dic}

    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${name_enable}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=${name_enable}    operation_type=plan


Step ${index}: Provision the Delta Plan With CB013031 Enable
    Log To Console    Step ${index}: Provision the Delta Plan With CB013031 Enable
    NetAct Provision Plan    plan_name=${name_enable}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    backup_plan_name=${name_enable}_backup    create_backup_plan=True    provisioning_operation=activate
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${name_enable}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=${name_enable}_backup   operation_type=plan
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0


Step ${index}: Check Auto-Config Parameters After Plan Provision
    Log To Console    Step ${index}: Check Auto-Config Parameters After Plan Provision
    Wait Until Keyword Succeeds    5min    10s    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ${parameter}    Create Dictionary     actRanSharingEnh=${EMPTY}    rejectSuppBcs=${EMPTY}    # yuki should be rejectSuppBcs=none, is a issue?
    Wait Until Keyword Succeeds    2m    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   ui_values=true    &{parameter}

    ${parameter}    Create Dictionary     useMeasuredRoundTripDelay=false
    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-1/ANTL-1    ui_values=true    &{parameter}

    ${parameter}    Create Dictionary     actRanSharing=false
    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}    ui_values=true    &{parameter}

    ${parameter}    Create Dictionary    actDlOptMcsSelection=true    lowerMcsPowerBackoff=14    n310PubSafety=n10
    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}    ui_values=true    &{parameter}


Step ${index}: Disable CB013031 With REMOVE_VALUES
    Log To Console    Step ${index}: Disable CB013031 With REMOVE_VALUES
    ${timestamp}    Get Time    epoch
    Set Test Variable    ${name_disable_keep}    MRBTS-${vDU_id}_${timestamp}
    ${parameter}    Create Dictionary     actCondAutoConfValCalc=false   modeOfCondAutoConfValCalcDeact=2
    ${plan}    NetAct Create And Edit Plan    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    name=${name_disable_keep}
    ...    description=disable_feature_CB013031_MRBTS-${vDU_id}    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    scf_distName=MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1   &{parameter}

    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.nrbts:NRDLMUMIMO    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}/NRDLMUMIMO-1  operation=create
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${name_disable_keep}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=${name_disable_keep}   operation_type=plan
    NetAct Provision Plan    plan_name=${name_disable_keep}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=${name_disable_keep}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0


Step ${index}: Disable CB013031 With KEEP_VALUES
    Log To Console    Step ${index}: Disable CB013031 With KEEP_VALUES
    ${timestamp}    Get Time    epoch
    Set Test Variable    ${name_disable_keep}    MRBTS-${vDU_id}_${timestamp}
    ${parameter}    Create Dictionary     actCondAutoConfValCalc=false   modeOfCondAutoConfValCalcDeact=1
    ${plan}    NetAct Create And Edit Plan    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    name=${name_disable_keep}
    ...    description=disable_feature_CB013031_MRBTS-${vDU_id}    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    scf_distName=MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1   &{parameter}

    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.nrbts:NRDLMUMIMO    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}/NRDLMUMIMO-1  operation=create
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${name_disable_keep}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=${name_disable_keep}   operation_type=plan
    NetAct Provision Plan    plan_name=${name_disable_keep}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=${name_disable_keep}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0


Step ${index}: Check Parameters After Disable CB013031 With REMOVE_VALUES
    Log To Console    Step ${index}: Check Parameters After Disable CB013031 With REMOVE_VALUES
    Wait Until Keyword Succeeds    5min    10s    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ${parameter}    Create Dictionary     actRanSharingEnh=${EMPTY}    rejectSuppBcs=${EMPTY}    # yuki should be rejectSuppBcs=none, is a issue?
    Wait Until Keyword Succeeds    2m    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   ui_values=true    &{parameter}

    ${parameter}    Create Dictionary     useMeasuredRoundTripDelay=${EMPTY}
    Wait Until Keyword Succeeds    2m    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-1/ANTL-1    ui_values=true    &{parameter}

    ${parameter}    Create Dictionary     actRanSharing=false
    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}    ui_values=true    &{parameter}

    ${parameter}    Create Dictionary    actDlOptMcsSelection=true    lowerMcsPowerBackoff=14    n310PubSafety=n10
    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}    ui_values=true    &{parameter}

    ${parameter}    Create Dictionary    actDlMuPairingGroup=false    actExcludeLowBufferUser=false    actMuAwareTdSch=false
    ...    dlMuMimoZfCorrThd=0.6    highBufferThdMuPairingGroup=60    lowBufferThdMuPairingGroup=10
    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}/NRDLMUMIMO-1    ui_values=true    &{parameter}


Step ${index}: Check Parameters After Disable CB013031 With KEEP_VALUES
    Log To Console    Step ${index}: Check Parameters After Disable CB013031 With KEEP_VALUES
    Wait Until Keyword Succeeds    5min    10s    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ${parameter}    Create Dictionary     actRanSharingEnh=${EMPTY}    rejectSuppBcs=${EMPTY}    # yuki should be rejectSuppBcs=none, is a issue?
    Wait Until Keyword Succeeds    2m    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   ui_values=true    &{parameter}

    ${parameter}    Create Dictionary     useMeasuredRoundTripDelay=false
    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-1/ANTL-1    ui_values=true    &{parameter}

    ${parameter}    Create Dictionary     actRanSharing=false
    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}    ui_values=true    &{parameter}

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
    Common Test Teardown For AIC
    Teardown NetAct