*** Settings ***
Documentation
...   author:
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)
...   maintainers:
...    - Jakub Kowalczyk
...   contact:
...    - Jakub Kowalczyk
...    - Bartłomiej Dubiel (bartlomiej.dubiel@nokia.com)
...    - Justyna Michalik (justyna.michalik@nokia.com)

Library     taf/rfrl/uuf4all/resources/python/uuf_rfrl_common.py  WITH NAME  uuf_rfrl_common
Library     resources/keywords.py
Library     ../CB012194/resources/keywords.py    WITH NAME    CB012194_keywords
Library     taf.rfrl.csv4all.CSV4AllTestCases
Resource    resources/keywords.robot
Variables   resources/variables-A5.py
#Resource    taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot.robot
Library     taf.rfrl.csv4all.resources.utilities.utilities                WITH NAME    csv4all_utilities
Library     taf.ul.ue.sim.env_setup


Suite Setup       Custom Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***
${cus_yaml}=          ${CURDIR}/config/coco1.yaml

${5G_SOURCE_SW}        ${None}
${5G_TARGET_SW}        ${None}

@{CUSTOM_ALLOWED_ALARMS}=       61648    7115    4420    4123    4125    8150    4459    8000
@{CRITICAL_FAULTS}              10  1806  16  4341  4383  4352  1868  69
${REMOTE_VM_IP}=                ${tl.test_pcs[0].default_ssh_connection_details.addr}
${REMOTE_MPLANE}=               ${tl.gnbs[0].oam_ip.v4.split('/')[0]}
${HOSTNAME}=                    7_7_TSPY042
${TARGET_DIR}                   /home/ute/UUF_SW
${USE_REMOTE_NODE}=             ${False}
@{EMPTY}=

${UE_TYPE}                           quectel
${UE_CAPABILITIES}                   QUECTEL_UE
${UE_DEFAULT_ALIAS_NAME}             UE
${DEFAULT_PACKET_SIZE_DL}            1416
${DEFAULT_PACKET_SIZE_UL}            1416
${DEFAULT_PACKET_SIZE}               1416
${DEFAULT_SEGMENT_SIZE_NR}           ${DEFAULT_PACKET_SIZE}
${DEFAULT_PROTOCOL}                  tcp
${DEFAULT_DEVIATION}                 80%
${DEFAULT_TPUT_UL_NR}                250Mbits/sec
${DEFAULT_TPUT_DL_NR}                330Mbits/sec
${DEFAULT_TPUT_UL_LTE}               45Mbits/sec
${DEFAULT_TPUT_DL_LTE}               170Mbits/sec
${DATA_TRANSFER_DURATION}            100s
${DATA_TRANSFER_DEFAULT_DURATION}    100s

${TPUT_DL_NR_2x2_50MHz}              550Mbits/sec
${TPUT_UL_NR_50MHz}                  280Mbits/sec
${TPUT_DL_NR_4x4_40MHz}              700Mbits/sec
${TPUT_UL_NR_40MHz}                  240Mbits/sec
${TPUT_DL_LTE_4x4_20MHz}             370Mbits/sec
${TPUT_UL_LTE_20MHz}                 65Mbits/sec
${TPUT_DL_LTE_4x4_5MHz}              87Mbits/sec
${TPUT_UL_LTE_5MHz}                  18Mbits/sec
${NR_DEVIATION}                      40%
${LTE_DEVIATION}                     20%
${DEFAULT_BAND}                      7

@{TPUT_NR_4x4_40MHz}=                ${TPUT_DL_NR_4x4_40MHz}   ${TPUT_UL_NR_40MHz}
&{TPUT_NR_CELL_MAPPING}=             2=@{TPUT_NR_4x4_40MHz}    1=@{TPUT_NR_4x4_40MHz}    3=@{TPUT_NR_4x4_40MHz}

@{TPUT_LTE_4x4_20MHz}=               ${TPUT_DL_LTE_4x4_20MHz}    ${TPUT_UL_LTE_20MHz}
@{TPUT_LTE_4x4_5MHz}=                ${TPUT_DL_LTE_4x4_5MHz}     ${TPUT_UL_LTE_5MHz}
&{TPUT_LTE_CELL_MAPPING}=            1=@{TPUT_LTE_4x4_20MHz}    2=@{TPUT_LTE_4x4_20MHz}    3=@{TPUT_LTE_4x4_5MHz}    4=@{TPUT_LTE_4x4_5MHz}
...                                  5=@{TPUT_LTE_4x4_20MHz}    6=@{TPUT_LTE_4x4_20MHz}    7=@{TPUT_LTE_4x4_5MHz}    8=@{TPUT_LTE_4x4_5MHz}
...                                  9=@{TPUT_LTE_4x4_20MHz}    10=@{TPUT_LTE_4x4_20MHz}    11=@{TPUT_LTE_4x4_5MHz}    12=@{TPUT_LTE_4x4_5MHz}

# UUF variables
${UPDATE_TEST_ITERATION}            1         # To run test with different value add arg: -v UPDATE_TEST_ITERATION:5
${SITE_RESET_TEST_ITERATION}        1         # To run test with different value add arg: -v SITE_RESET_TEST_ITERATION:30
${OMIT_L3CALL}=                     ${False}  # To run test without L3 call add arg: -v OMIT_L3CALL:True

${SHOULD_BE_REPORTED}=  ${True}
@{CUSTOMERS_LIST}=      Generic
${UPDATE_TEST_FAILED}   ${False}
${QC_DOMAIN}=           MN_RAN
${QC_PROJECT}=          RAN_VRF
${QC_ID_UPGRADE}=       ${qc_id_mapping['${5G_TARGET_SW}'.split('_', 1)[0]]['qc_upgrade'] if 'SBTS' in '${5G_TARGET_SW}' else None}
${QC_ID_RESET}=         ${qc_id_mapping['${5G_TARGET_SW}'.split('_', 1)[0]]['qc_site_reset'] if 'SBTS' in '${5G_TARGET_SW}' else None}
@{CUSTOM_ALARMS}=       ${CUSTOM_ALLOWED_ALARMS}
${BTS_HOST_IP}          192.168.255.129
${RP_CA}                            VRF_SiSo
${RP_ORGANIZATION}                  VRF_KRK_T07
${RP_LOCATION}                      VRF_KRK

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${5G_SOURCE_SW}
...                                 target_sw=${5G_TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}

@{NODES}                            ${NODE1}

*** Test Cases ***
CB011086_05_E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]    05    CRT
    [Timeout]    96h
    [Setup]    Run Keywords
    ...    keywords.Check Sw Version And Rollback If Needed    expected_sw_ver=${5G_SOURCE_SW}    cell_timeout=${300}    AND
    ...    Custom UUF Test Setup

    log to console    SW_upgrade_rollback
    ${id}=    sg7keywords.get_mrbts_id
    set test variable    ${MRBTS_ID}    ${id}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${UPDATE_TEST_ITERATION}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_project=${QC_PROJECT}
    ...          qc_id=${QC_ID_UPGRADE}
    ...          sw_build=${5G_TARGET_SW}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          restore_to_target_sw=${True}
    ...          l3_call_method=L3 Call 07

    [Teardown]    Custom UUF Test Teardown


CB011086_01_Manual_SiSo_CM_Recommissioning
    [Tags]    01    CRT
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    BTS Reset Cause    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    Log To Console    01
    ${MRBTS_ID}=    sg7keywords.get_mrbts_id
    Set Test Variable    ${MRBTS_ID}     ${MRBTS_ID}

    Log To Console    Step 1 - parameter change require NR Rat reset
    Set parameter [enDcSyncStatus] from object [MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2] to value [asynchronous] and expect nr rat reset
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    L3 Call on NR Cells    2    cell_select_by=${None}

    Log To Console    Step 2 - parameter change require LTE Rat reset
    Set parameter [actExtN77Support] from object [MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}] to value [true] and expect lte rat reset
    gnbcell.Wait For All Cells To Be OnAir    timeout=400
    L3 Call CUS LTE with NR    cus_lte_cells=3,8,10

    Log To Console    Step 3 - parameter change require Site reset
    Set parameter [holdOverModeUsed] from object [MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1] to value [true] and expect bts reset
    Wait Until Keyword Succeeds    3x    30 sec
    ...    Wait For Site To Be Onair    timeout=300
    gnbcell.Wait For All Cells To Be OnAir    timeout=300


    Log To Console    Step 4 - online parameter change
    Set parameter [inactivityTimer] from object [MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-10] to value [200] and expect online modification
    Verify On-Air
    Log To Console    Step 5 - wrong parameter value
    ${msg}=    Run Keyword And Expect Error    STARTS: AdminApiProcedureFailureException
    ...        Perform Configuration Parameter Recommissioning On gNB    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-3/LNCEL_FDD-0
    ...                                                                  param_name=prachFreqOff
    ...                                                                  operation=update
    ...                                                                  param_value=-1
    Set Test Variable    ${search}    VALUE_IS_TOO_SMALL
    Should Contain    ${msg}    ${search}

    L3 Call CUS LTE with NR    cus_lte_cells=3,5,12    nr_cells=2    cell_select_by=${None}

    [Teardown]    Run Keywords
    ...    Cleanup After Test 01
    ...    Test Teardown
    ...    Common Postconditions With Watching Alarms


CB011086_07_Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    07    CRT
    [Timeout]    96h
    [Setup]    Custom UUF Test Setup

    E2E TL ACTIVATION RESET TEST
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_project=${QC_PROJECT}
    ...          qc_id=${QC_ID_RESET}
    ...          sw_build=${5G_TARGET_SW}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          l3_call_method=L3 Call 07

    [Teardown]    Custom UUF Test Teardown


CB011086_13_Manual_SiSo_SM_RU_Module_lock_unlock
    [Tags]    13    CRT
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    Lock Radio Unit on gNB    radio_unit_id=2
    Lock Radio Unit on gNB    radio_unit_id=101
    Sleep    10
    Log To Console    Radio Modules Locked
    CB012194_keywords.Log Alarms     also_console=${False}
    Unlock Radio Unit on gNB    radio_unit_id=2
    Unlock Radio Unit on gNB    radio_unit_id=101
    Log To Console    Radio Modules Unlocked
    Wait For Site To Be Onair  timeout=180
    gnbcell.Wait For All Cells To Be OnAir    timeout=180
    Log To Console    All Cells are Onair

    L3 Call CUS LTE with NR    cus_lte_cells=2,7,11    nr_cells=2    cell_select_by=${None}
    Sleep    1 min
    L3 Call on NR Cells    2    duration=300s    cell_select_by=${None}

    [Teardown]    Run Keywords
    ...    Test Teardown
    ...    Common Postconditions With Watching Alarms


CB011086_14_General_SiSo_stability_with_L3Call
    [Tags]    14    CRT
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    Log To Console    SiSo_stability_with_L3Call

    L3 Call on NR Cells    2    duration=300s    deviation=5%    cell_select_by=${None}

    L3 Call CUS LTE with NR    cus_lte_cells=1,3
    ...    duration=300s    lte_deviation=5%

    L3 Call CUS LTE with NR    cus_lte_cells=5,7
    ...    duration=300s    lte_deviation=5%

    L3 Call CUS LTE with NR    cus_lte_cells=9,11
    ...    duration=300s    lte_deviation=5%

    [Teardown]    Run Keywords
    ...    Test Teardown    AND
    ...    Common Postconditions With Watching Alarms


*** Keywords ***
Custom Suite Setup
    Custom Set Suite UUF Variables

    @{param_list}=    Set Variable    0x450027=1 #EnableDeveloperAccount
    ...                               0x980007=1 #PR804393 Fault 61675 "WiFi Configuration Issue"
    keywords.copy_and_modify_swconfig    ${param_list}
    ...                                  source_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...                                  target_path=/tmp/custom_swconfig.txt
    Prepare CUS environment
    Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
    ...                                                  should_5G_neighbour_be_changed=${False}
    ...                                                  increase_time_for_checking_bbmod=600
    ...                                                  increase_timeout_for_update_sw=1800
    ...                                                  increase_time_for_checking_radios=2100
    ...                                                  increase_time_for_checking_cells=700
    ...                                                  swconfig_from_path=/tmp/custom_swconfig.txt

Prepare CUS environment
    Log To Console    \nCUS Setup
    ${run_update}    get variable value      ${configure}        "True"
    Add simulator            sim_type=cus    config=${cus_yaml}
    Run keyword if  ${run_update}=="True"
    ...             Configure environment                         # to omit CUS configuration: -v configure:False
    Log To Console    CUS Setup done

