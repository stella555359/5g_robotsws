*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.1.godlewski@nokia.com
...   Test cases execute on T-Mobile US #17 setup

Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/uuf_utils.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/admin_session.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/utilities.py
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod     WITH NAME    Tcpdump
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/TOL_TMO_DALLAS/resources/snapshot_check.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/DynamicRegression/resources/dynamic_regression.py
Resource        ./regression_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/TOL_TMO_DALLAS/tol_tmo_dallas.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_keywords.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/global_variables.py
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/UUF/resources/variables.py

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/TOL_TMO_DALLAS/csv_tol17_tcs.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/TOL_TMO_DALLAS/resources/sfp_monitoring.py

Suite Setup    Set Global Variable    ${CURRENT_SCF}    SCF_DEFAULT


Test Setup      Run Keywords
...    Clear Test Config Keys
...    Change Configuration If Needed

Test Teardown    Delete Snapshot From Passed Test    ${OUTPUT_DIR}

*** Variables ***
${CALCULATE_KPI}     ${True}
${CRITICAL_FAULTS}   ${VARIABLE['critical_faults']}
${custom_alarms}     ${VARIABLE['custom_alarms']}
@{customers}=         TMO US
${delta_file}        testsuite/Wroclaw/RRM/WRO_4/UUF/resources/delta.json
${L3_call_keyword}   ${None}
${SERIAL_CONSOLE}=   ${False}
${STOP_TEST_AFTER_FAIL}               ${False}
${USE_DCAP}    ${False}
${RESTORE_TARGET_SW}    ${True}
${USE_BUILDS_STORAGE}    ${False}
${DOWNLOAD_PATH}               /home/ute/UUF_SW/SBTS/SBTS26R1

${RP_CA}   VRF_RRM
${RP_LOCATION}    VRF_WRO2
${RP_ORGANIZATION}    VRF_WRO2_T04
${QC_DOMAIN}                   ${None}
${LABEL}                       VRF_WRO2_4_CSV4ALL
${TEST_QC_ID}                  ${None}
${QC_PROJECT}                  ${None}
${report_comment}    VRF_WRO2_T04

${SHOULD_BE_REPORTED}=          ${False}
${MUMIN_CONFIG_FILE}=           ${None}

${SOURCE_SW}               SBTS25R3_ENB_0000_000334_000096
${TARGET_SW}               SBTS26R1_ENB_0000_000434_000015

${UPGRADE_ITERATIONS}           ${VARIABLE['UPGRADE_ITERATIONS']}
${SITE_RESET_ITERATIONS}        ${VARIABLE['SITE_RESET_ITERATIONS']}
${RU_RESET_ITERATIONS}           ${VARIABLE['RU_RESET_ITERATIONS']}
${BBMOD_RESET_ITERATIONS}        ${VARIABLE['BBMOD_RESET_ITERATIONS']}
${LOCK_UNLOCK_ITERATIONS}       ${VARIABLE['LOCK_UNLOCK_ITERATIONS']}
${DELTA_ITERATIONS}             ${VARIABLE['DELTA_ITERATIONS']}


&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         node_vm=${tl.test_pc.default_ssh_connection_details.addr}
...                         node_alias=NR
...                         source_sw=${SOURCE_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${custom_alarms}
...                         critical_alarms=${CRITICAL_FAULTS}
@{NODES}                    ${NODE1}
@{BANDS_AHLOA}         ${12}
@{BANDS_AHFIB}         ${2}
@{BANDS_AEHC}          ${41}

*** Keywords ***
Prepare List Of Modules For Test
    [Arguments]    ${module}
    @{modules}    Create List    ${module}
    [Return]    ${modules}

Run Csv Test With Common Arguments
    [Arguments]    ${keyword}    &{extra_args}
    &{kw_args}    Create Dictionary
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  &{extra_args}
    Run Keyword    ${keyword}    &{kw_args}

Clear Test Config Keys
    @{TEST_CONFIG_KEYS}    Create List    modules_for_test    cells_to_block    bands_for_test
    FOR    ${key}    IN    @{TEST_CONFIG_KEYS}
        Remove From Dictionary    ${NODE1}    ${key}
    END

*** Test Cases ***
[1]OAM_5_Upgrade_ASIL_Webem
    [Tags]    OAM    UPGRADE_ROLLBACK
    Run Csv Test With Common Arguments    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...  use_external_storage=${USE_BUILDS_STORAGE}
    ...  download_path=${DOWNLOAD_PATH}
    ...  restore_to_target_sw=${RESTORE_TARGET_SW}
    ...  l3_call_method=${None}
    [Teardown]    Set Suite Variable    ${UPGRADE_ROLLBACK_STATUS}    ${TEST_STATUS}

[1]OAM_11_Rollback_ASIL_Webem
    [Tags]    OAM    UPGRADE_ROLLBACK
    Run Keyword If    '${UPGRADE_ROLLBACK_STATUS}' == 'FAIL'  Fail  UpgradeRollback test Failed
    ...  ELSE  Pass Execution  UpgradeRollback test Passed

[1]OAM_15_Full_commisioning_2G_LTE_5G_Webem
    [Tags]    OAM
    Load Scf    /home/ute/testline_init_results/execution/configs/topology_configs/node_1/SBTS26R1/scf_NR_LTE_GSM.xml
    ...    skip_relation_errors=${FALSE}

[1]OAM_20_BTS_OnAir_ASIL_Webem
    [Tags]    OAM
    Wait For Online State

[1]OAM_26_BTS_Block_Unblock_ASIL_Webem
    [Tags]    OAM
    Run Csv Test With Common Arguments    E2E TL BTS BLOCK UNBLOCK

[1]OAM_32_BTS_Power_Reset_ASIL_Webem
    [Tags]    OAM
    Run Csv Test With Common Arguments    E2E TL POWER SITE RESET WITH OAM KPI

[1]OAM_38_BTS_Reset_Site_ASIL_Webem
    [Tags]    OAM
    Run Csv Test With Common Arguments    E2E TL SITE RESET WITH OAM KPI

[1]OAM_41_RAT_Block_Unblock_NR_ASIL_Webem
    [Tags]    OAM
    Run Csv Test With Common Arguments    E2E TL RAT BLOCK UNBLOCK NR

[1]OAM_46_RAT_Block_Unblock_LTE_ASIL_Webem
    [Tags]    OAM
    Run Csv Test With Common Arguments    E2E TL RAT BLOCK UNBLOCK LTE

[1]OAM_49_RAT_Block_Unblock_GSM_ASIL_Webem
    [Tags]    OAM
    Run Csv Test With Common Arguments    E2E TL RAT BLOCK UNBLOCK GSM

[1]OAM_53_RAT_LTE_Reset_ASIL_Webem
    [Tags]    OAM
    Run Csv Test With Common Arguments    E2E TL RAT RESET LTE

[1]OAM_58_BBMOD_Lock_Unlock_ASIL_ABIA_Webem
    [Tags]    OAM
    ${bbmod}    Select Random Bbmod With Name    ABIA
    @{bbmods}    Prepare List Of Modules For Test    ${bbmod}
    Set To Dictionary    ${NODE1}    modules_for_test    ${bbmods}
    Run Csv Test With Common Arguments    E2E TL CAPACITY MODULE LOCK UNLOCK

[1]OAM_62_BBMOD_Lock_Unlock_ASIL_ABIO_Webem
    [Tags]    OAM
    ${bbmod}    Select Random Bbmod With Name    ABIO
    @{bbmods}    Prepare List Of Modules For Test    ${bbmod}
    Set To Dictionary    ${NODE1}    modules_for_test    ${bbmods}
    Run Csv Test With Common Arguments    E2E TL CAPACITY MODULE LOCK UNLOCK

[1]OAM_72_BBMOD_Reset_ASIL_ABIO_Webem
    [Tags]    OAM
    ${bbmod}    Select Random Bbmod With Name    ABIO
    @{bbmods}    Prepare List Of Modules For Test    ${bbmod}
    Set To Dictionary    ${NODE1}    modules_for_test    ${bbmods}
    Run Csv Test With Common Arguments    E2E TL CAPACITY MODULE RESET WITH OAM KPI

[1]OAM_79_RMOD_Lock_Unlock_ASIL_AHLOA_Webem
    [Tags]    OAM    AHLOA
    @{ahloa_rmods}    Get All Rmods Distnames With Name    AHLOA
    Set To Dictionary    ${NODE1}    modules_for_test    ${ahloa_rmods}
    Run Csv Test With Common Arguments    E2E TL RU LOCK UNLOCK

[1]OAM_83_RMOD_Lock_Unlock_ASIL_AHFIB_Webem
    [Tags]    OAM    AHFIB
    @{ahfib_rmods}    Get All Rmods Distnames With Name    AHFIB
    Set To Dictionary    ${NODE1}    modules_for_test    ${ahfib_rmods}
    Run Csv Test With Common Arguments    E2E TL RU LOCK UNLOCK

[1]OAM_163_RMOD_Lock_Unlock_ASIL_AEHC_Webem
    [Tags]    OAM    AEHC
    @{aehc_rmods}    Get All Rmods Distnames With Name    AEHC
    Set To Dictionary    ${NODE1}    modules_for_test    ${aehc_rmods}
    Run Csv Test With Common Arguments    E2E TL RU LOCK UNLOCK

[1]OAM_90_RMOD_Reset_ASIL_AHLOA_Webem
    [Tags]    OAM    AHLOA
    @{ahloa_rmods}    Get All Rmods Distnames With Name    AHLOA
    Set To Dictionary    ${NODE1}    modules_for_test    ${ahloa_rmods}
    Run Csv Test With Common Arguments    E2E TL RU RESET WITH OAM KPI

[1]OAM_94_RMOD_Reset_ASIL_AHFIB_Webem
    [Tags]    OAM    AHFIB
    @{ahfib_rmods}    Get All Rmods Distnames With Name    AHFIB
    Set To Dictionary    ${NODE1}    modules_for_test    ${ahfib_rmods}
    Run Csv Test With Common Arguments    E2E TL RU RESET WITH OAM KPI


[1]OAM_101_RMOD_Power_Reset_ASIL_AHLOA_Webem
    [Tags]    OAM    AHLOA
    @{ahloa_rmods}    Get All Rmods Distnames With Name    AHLOA
    Set To Dictionary    ${NODE1}    modules_for_test    ${ahloa_rmods}
    @{RMOD_PDU}    Prepare Rmod Pdu Info By Name    AHLOA
    Run Csv Test With Common Arguments    E2E TL RU POWER RESET    rmods_with_pdu_ports=${RMOD_PDU}

[1]OAM_105_RMOD_Power_Reset_ASIL_AHFIB_Webem
    [Tags]    OAM    AHFIB
    @{ahfib_rmods}    Get All Rmods Distnames With Name    AHFIB
    Set To Dictionary    ${NODE1}    modules_for_test    ${ahfib_rmods}
    @{RMOD_PDU}    Prepare Rmod Pdu Info By Name    AHFIB
    Run Csv Test With Common Arguments    E2E TL RU POWER RESET    rmods_with_pdu_ports=${RMOD_PDU}

[1]OAM_114_LNCELL_Block_Unblock_ASIL_AHLOA_Webem
    [Tags]    OAM    AHLOA
    ${cell}    Select Random Cell On Rmod    AHLOA    LTE
    @{cells}    Prepare List Of Modules For Test    ${cell}
    Set To Dictionary    ${NODE1}    cells_to_block    ${cells}
    Run Csv Test With Common Arguments    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI

[1]OAM_115_LNCELL_Block_Unblock_ASIL_AHFIB_Webem
    [Tags]    OAM    AHFIB
    ${cell}    Select Random Cell On Rmod    AHFIB    LTE
    @{cells}    Prepare List Of Modules For Test    ${cell}
    Set To Dictionary    ${NODE1}    cells_to_block    ${cells}
    Run Csv Test With Common Arguments    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI

[1]OAM_124_LNCELL_Lock_Unlock_ASIL_AHLOA_Webem
    [Tags]    OAM    AHLOA
    Set To Dictionary    ${NODE1}    bands_for_test    ${BANDS_AHLOA}
    Run Csv Test With Common Arguments    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI

[1]OAM_125_LNCELL_Lock_Unlock_ASIL_AHFIB_Webem
    [Tags]    OAM    AHFIB
    Set To Dictionary    ${NODE1}    bands_for_test    ${BANDS_AHFIB}
    Run Csv Test With Common Arguments    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI

[1]OAM_132_Snapshot_ASIL_Webem
    [Tags]    OAM    SNAPSHOT
    AdminUtils.Collect Snapshot    ${OUTPUT_DIR}/snapshot.zip
    Unzip Snapshot   ${OUTPUT_DIR}/snapshot.zip    ${OUTPUT_DIR}/Snapshot_ASIL_Webem
    Set Suite Variable    ${SNAPSHOT_LOCATION}    ${OUTPUT_DIR}/Snapshot_ASIL_Webem

[1]OAM_137_Snapshot_ASIL_AHLOA_Webem
    [Tags]    OAM    SNAPSHOT
    Verify Snapshot    AHLOA    ${SNAPSHOT_LOCATION}

[1]OAM_141_Snapshot_ASIL_AHFIB_Webem
    [Tags]    OAM    SNAPSHOT
    Verify Snapshot    AHFIB    ${SNAPSHOT_LOCATION}

[1]OAM_165_Snapshot_ASIL_AEHC_Webem
    [Tags]    OAM    SNAPSHOT
    Verify Snapshot    AEHC    ${SNAPSHOT_LOCATION}

[1]OAM_148_SCF_Validate_ASIL_Webem
    [Tags]    OAM
    AdminUtils.Download Current Scf    ${OUTPUT_DIR}    full_commissioning.xml
    admin_session.Validate Scf With Hw And Nidd   ${OUTPUT_DIR}/full_commissioning.xml

[1]Voice_3_Emergency_Call_ASIL_ABIO_AHLOA
    [Tags]    VOICE    LTE    AHLOA
    Set Attach Cell DN   ${ATTACH_CELL_N71_21}
    Deattenuate Attach Cell   ${tl.attenuators}
    Require UE   UE_2   capabilities=UE_2
    Enable Band Config    UE_2    LTE_${BANDS_AHLOA}[0]
    Attach UE    UE_2
    Verify Cell Id    UE_2    21
    Start Voice Call    vc_alias=call_1    ue_alias=UE_2    to=911    duration=${VOICE_CALL_DURATION}
    BuiltIn.Sleep    60
    Stop Voice Call    call_1
    [Teardown]    Detach UE    UE_2

[1]Voice_9_VoLTE_Call_ASIL_ABIO_AHLOA
    [Tags]    VOICE    LTE    AHLOA
    Set Attach Cell DN   ${ATTACH_CELL_N71_21}
    Deattenuate Attach Cell   ${tl.attenuators}
    Require UE   UE_2   capabilities=UE_2
    Enable Band Config    UE_2    LTE_${BANDS_AHLOA}[0]
    Attach UE    UE_2
    Verify Cell Id    UE_2    21
    Start Voice Call    vc_alias=call_1    ue_alias=UE_2    to=0105    duration=${VOICE_CALL_DURATION}
    BuiltIn.Sleep    60
    Stop Voice Call    call_1
    [Teardown]    Detach UE    UE_2


[1]Voice_4_Emergency_Call_ASIL_ABIA_AHFIB
    [Tags]    VOICE    LTE    AHFIB
    Set Attach Cell DN   ${ATTACH_CELL_N25_11}
    Deattenuate Attach Cell   ${tl.attenuators}
    Require UE   UE_2   capabilities=UE_2
    Enable Band Config    UE_2    LTE_${BANDS_AHFIB}[0]
    Attach UE    UE_2
    Verify Cell Id    UE_2    11
    Start Voice Call    vc_alias=call_1    ue_alias=UE_2    to=911    duration=${VOICE_CALL_DURATION}
    BuiltIn.Sleep    60
    Stop Voice Call    call_1
    [Teardown]    Detach UE    UE_2

[1]Voice_10_VoLTE_Call_ASIL_ABIA_AHFIB
    [Tags]    VOICE    LTE    AHFIB
    Set Attach Cell DN   ${ATTACH_CELL_N25_11}
    Deattenuate Attach Cell   ${tl.attenuators}
    Require UE   UE_2   capabilities=UE_2
    Enable Band Config    UE_2    LTE_${BANDS_AHFIB}[0]
    Attach UE    UE_2
    Verify Cell Id    UE_2    11
    Start Voice Call    vc_alias=call_1    ue_alias=UE_2    to=0105    duration=${VOICE_CALL_DURATION}
    BuiltIn.Sleep    60
    Stop Voice Call    call_1
    [Teardown]    Detach UE    UE_2

[1]GSM_004_2G_MOC_CS_call_ASIL_AHFIB
    [Tags]    VOICE    GSM    AHFIB
    Set Attach Cell DN   ${ATTACH_CELL_GSM_1481}
    Deattenuate Attach Cell   ${tl.attenuators}
    Require UE   UE_2   capabilities=UE_2
    Enable Band Config    UE_2    GSM_1900
    Attach UE    UE_2
    Verify Cell Id    UE_2    1481    cell_type=GSM
    Start Voice Call    vc_alias=call_1    ue_alias=UE_2    to=0105    duration=60s
    Await voice Call Finish    call_1
    [Teardown]    Detach UE    UE_2

[1]GSM_005_2G_MTC_CS_call_ASIL_AHFIB
    [Tags]    VOICE    GSM    AHFIB
    Set Attach Cell DN   ${ATTACH_CELL_GSM_1481}
    Deattenuate Attach Cell   ${tl.attenuators}
    Require UE   UE_1   capabilities=UE_1
    Require UE   UE_2   capabilities=UE_2
    Enable Band Config    UE_1    GSM_1900
    Enable Band Config    UE_2    GSM_1900
    Attach UE    UE_1
    Attach UE    UE_2
    Verify Cell Id    UE_1    1481    cell_type=GSM
    Verify Cell Id    UE_2    1481    cell_type=GSM
    Start Voice Call    vc_alias=call_1    ue_alias=UE_2    to=00358485600002681    duration=100s
    Await Incoming Voice Call     vc_alias=call_1   ue_alias=UE_1    action=answer    timeout=60s
    BuiltIn.Sleep    60
    Stop Voice Call    call_1
    [Teardown]    Run Keywords
    ...    Detach UE    UE_1    AND
    ...    Detach UE    UE_2

[1]GSM_006_BTS_Lock_Unlock_from_BSC_ASIL_AHFIB
    [Tags]    OAM    GSM
    @{bands}    Create List    PCS-1900
    Set To Dictionary    ${NODE1}    bands_for_test    ${bands}
    Run Csv Test With Common Arguments    E2E TL CELL LOCK UNLOCK GSM

[1]OAM_156_SFP_Monitoring_ASIL_AHFIB_Webem
    [Tags]    OAM    ADDITIONAL
    Validate Sfp Monitoring    AHFIB

[1]OAM_157_SFP_Monitoring_ASIL_AHLOA_Webem
    [Tags]    OAM    ADDITIONAL
    Validate Sfp Monitoring    AHLOA

[1]OAM_160_RET_ASIL_AHLOA_Webem
    [Tags]    OAM    ADDITIONAL
    Verify Ald Retu Status    ald_id=2

[1]OAM_161_RET_ASIL_AHFIB_Webem
    [Tags]    OAM    ADDITIONAL
    Verify Ald Retu Status    ald_id=1

#[1]5G20B_0501_RRM_001
#    [Tags]    RRM
#    5G20B_0501_RRM_001
#
#[1]23R2_8745_OAM_002
#    [Tags]    RRM
#    23R2_8745_OAM_002
#
#[1]23R2_8745_OAM_003
#    [Tags]    RRM
#    23R2_8745_OAM_003
#
#[1]5G23R2_8133_RRM_002
#    [Tags]    RRM
#    5G23R2_8133_RRM_002
#
#[1]5G23R2_8133_RRM_003
#    [Tags]    RRM
#    5G23R2_8133_RRM_003
#
#[1]23R1_8662_RRM_001
#    [Tags]    RRM
#    23R1_8662_RRM_001
#
#[1]23R1_8662_RRM_002
#    [Tags]    RRM
#    23R1_8662_RRM_002
#
#[1]TDD_17_100+90
#    [Tags]    SCF_DEFAULT
#    Log To Console    TDD CONFIG: 100_90
#    @{TDD_CELLS}    Create List    301    311    302    312
#    Perform L3 Call On Cells    ${TDD_CELLS}
#
#[1]TDD_17_90+15
#    [Tags]    SCF_90_15
#    Log To Console    TDD CONFIG: 90_15
#    @{TDD_CELLS}    Create List    301    311    302    312
#    Perform L3 Call On Cells    ${TDD_CELLS}
#
#[1]TDD_17_100+40(38)
#    [Tags]    SCF_100_38
#    Log To Console    TDD CONFIG: 100_38
#    @{TDD_CELLS}    Create List    301    311    302    312
#    Perform L3 Call On Cells    ${TDD_CELLS}
#
#[1]TDD_17_100+30+15
#    [Tags]    SCF_100_30_15
#    Log To Console    TDD CONFIG: 100_30_15
#    @{TDD_CELLS}    Create List    301    311    321    302    312    322
#    Perform L3 Call On Cells    ${TDD_CELLS}
