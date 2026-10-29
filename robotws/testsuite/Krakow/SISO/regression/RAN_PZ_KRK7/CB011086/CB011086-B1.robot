*** Settings ***
Documentation
...   author:
...    - Nelsandro Sampaio (nelsandro.sampaio@nokia.com)
...    - Mateusz Matusik (mteusz.matusik@nokia.com)
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)


Library     taf/rfrl/uuf4all/resources/python/uuf_rfrl_common.py  WITH NAME  uuf_rfrl_common
Library     resources/keywords.py
Library     Collections
Library     ../CB012194/resources/keywords.py    WITH NAME    CB012194_keywords
Library     taf.rfrl.csv4all.CSV4AllTestCases
Variables   resources/variables-B1.py
Resource    resources/keywords.robot
Resource    resources/keywords-11086.robot


Suite Setup       Setup Test Suite for TL019
Suite Teardown    Common Suite Teardown

*** Variables ***
${5G_SOURCE_SW}        ${None}
${5G_TARGET_SW}        ${None}

@{CUSTOM_ALARMS}       61648    7115    4420    4123    4125    8150    4694    6450    4479
@{ADDITIONAL_ALARMS_DURING_PREP}    WiFi Configuration Issue
...                                 Failure detected on assigned antennas
@{CRITICAL_FAULTS}     0010  0016  1806  1868  4341  4352  4383
${TARGET_DIR}          /home/ute/UUF_SW/
${HOSTNAME}            7_7_TSPY019
${USE_REMOTE_NODE}     ${False}
${QC_DOMAIN}=          MN_RAN
${QC_PROJECT}=         RAN_VRF
${RP_CA}                            VRF_SiSo
${RP_ORGANIZATION}                  VRF_KRK_T07
${RP_LOCATION}                      VRF_KRK
${UPDATE_TEST_ITERATION}            1         # To run test with different value add arg: -v UPDATE_TEST_ITERATION:5
${SITE_RESET_TEST_ITERATION}        1         # To run test with different value add arg: -v SITE_RESET_TEST_ITERATION:30
${OMIT_L3CALL}=                     ${False}  # To run test without L3 call add arg: -v OMIT_L3CALL:True
${SHOULD_BE_REPORTED}=          ${True}
${REMOTE_VM_IP}=                ${tl.test_pcs[0].default_ssh_connection_details.addr}
${REMOTE_MPLANE}=               ${tl.gnbs[0].oam_ip.v4.split('/')[0]}
@{EMPTY}=

@{CUSTOMERS_LIST}=              Generic
${REMOTE_NODE_UPDATE}=          ${True}
${DOWNLOAD_PATH}=               ${None}
${USE_BUILDS_STORAGE}=          ${True}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${ALARM_TIMEOUT}=               120
${HARDWARE_CHECK_TIMEOUT}=      900
${DISABLE_KPI}=                 ${False}
@{SYSLOG_IGNORED_PRINTS}=       INF
${EMAIL_RECIPIENTS}=            ${None}   # email or emails separate by comma eg. name@nokia.com,name@nokia.com
${MUMIN_CONFIG_FILE}=           ${None}   # PATH TO MUMIN/LMI BOARD CONFIG YAML FILE
${VIRTUALENV_DIR}=              ${None}   # path to virtual env used in starting syslog on remote vm
${SERIAL_CONSOLE}=              ${False}  # set to True if testing with serial console
${VM_USERNAME}=                 ute       # vm username used in syslog
${VM_PASSWORD}=                 ute       # vm password used in syslog
${BTS_HOST_IP}=                 192.168.255.1  #  IP used in admin setup
${QC_ID_UPGRADE}=       ${qc_id_mapping['${5G_TARGET_SW}'.split('_', 1)[0]]['qc_upgrade'] if 'SBTS' in '${5G_TARGET_SW}' else None}
${QC_ID_RESET}=         ${qc_id_mapping['${5G_TARGET_SW}'.split('_', 1)[0]]['qc_site_reset'] if 'SBTS' in '${5G_TARGET_SW}' else None}
${QC_ID_RESET29}=       ${qc_id_mapping['${5G_TARGET_SW}'.split('_', 1)[0]]['qc_site_reset29'] if 'SBTS' in '${5G_TARGET_SW}' else None}

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${5G_SOURCE_SW}
...                                 target_sw=${5G_TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}

@{NODES}                            ${NODE1}


*** Test Cases ***
CB011086_05_E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]    05    CRT    jk
    [Setup]    Run Keywords
    ...    keywords.Check Sw Version And Rollback If Needed    expected_sw_ver=${5G_SOURCE_SW}    cell_timeout=300    AND
    ...    Custom UUF Test Setup

    Set Test Variable    ${TEST_ITERATION}    1
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
    ...          l3_call_method=L3 Call TC_B1-05

    [Teardown]    Custom UUF Test Teardown


CB011086_01_Manual_SiSo_CM_Recommissioning
    [Tags]    01    CRT    jk
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    BTS Reset Cause    Cell blocked
    ...    Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    ...    High interference to UL subframe    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    Log To Console    01
    ${MRBTS_ID}=    sg7keywords.get_mrbts_id
    Set Test Variable    ${MRBTS_ID}     ${MRBTS_ID}

    ${DURATION}         Set Variable    100s
    ${DEVIATION_NR}     Set Variable    40%
    ${DEVIATION_LTE}    Set Variable    20%


    Log To Console    Step 1 - parameter change require NR Rat reset
    Set parameter [enDcSyncStatus] from object [MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-12] to value [asynchronous] and expect nr rat reset
    gnbcell.Wait For All Cells To Be OnAir    timeout=300

    Prepare UE for NSA L3 Call     band_lte=1     band_nr=5
    Wait Until Keyword Succeeds    3x    3 min    ute_ue.reboot_ue    ${UE_DEFAULT_ALIAS_NAME}    timeout=${170}
    Sleep    10
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=10dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_11_3_ATT_PORTS}
    Attach UE and Start DL and UL traffic    throughput_DL=205 Mbits/sec
    ...                                throughput_UL=105 Mbits/sec
    ...                                duration=${DURATION}
    ...                                deviation=${DEVIATION_NR}
    ...                                protocol=tcp
    ...                                ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                                cells_to_block=[12,13,15]
    ...                                desired_pci=${11}
    ...                                log_throughput=${True}

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{EMPTY}

    Log To Console    Step 2 - parameter change require LTE Rat reset
    Set parameter [actExtN77Support] from object [MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}] to value [true] and expect lte rat reset
    gnbcell.Wait For All Cells To Be OnAir    timeout=500

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=quectel
    Set Active Bands       ${UE_DEFAULT_ALIAS_NAME}    LTE     5

    Attach UE and Start DL and UL traffic    throughput_DL=38 Mbits/sec
    ...                                throughput_UL=19 Mbits/sec
    ...                                duration=${DURATION}
    ...                                deviation=${DEVIATION_LTE}
    ...                                protocol=tcp
    ...                                ue_alias=${UE_DEFAULT_ALIAS_NAME}
#    ...                                cells_to_block=[12,13]
    ...                                desired_pci=${1}
    ...                                log_throughput=${True}

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_11_3_ATT_PORTS}
    Run Keyword And Warn On Failure    ute_ue.Stop Using UE    ${UE_DEFAULT_ALIAS_NAME}

    Log To Console    Step 3 - parameter change require Site reset
    Set parameter [holdOverModeUsed] from object [MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1] to value [true] and expect bts reset
    Wait Until Keyword Succeeds    3x    1 min
    ...    Wait For Site To Be Onair    timeout=300
    gnbcell.Wait For All Cells To Be OnAir    timeout=300


    Log To Console    Step 4 - online parameter change
    Set parameter [inactivityTimer] from object [MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2] to value [20] and expect online modification
    Verify On-Air
    Log To Console    Step 5 - wrong parameter value
    ${msg}=    Run Keyword And Expect Error    STARTS: AdminApiProcedureFailureException
    ...        Perform Configuration Parameter Recommissioning On gNB    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2/LNCEL_FDD-0
    ...                                                                  param_name=prachFreqOff
    ...                                                                  operation=update
    ...                                                                  param_value=-1
    Set Test Variable    ${search}    VALUE_IS_TOO_SMALL
    Should Contain    ${msg}    ${search}

    Prepare UE for NSA L3 Call     band_lte=1     band_nr=5
    Wait Until Keyword Succeeds    3x    3 min    ute_ue.reboot_ue    ${UE_DEFAULT_ALIAS_NAME}    timeout=${170}
    Sleep    10
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=10dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_16_3_ATT_PORTS}
    Attach UE and Start DL and UL traffic    throughput_DL=205 Mbits/sec
    ...                                throughput_UL=105 Mbits/sec
    ...                                duration=${DURATION}
    ...                                deviation=${DEVIATION_NR}
    ...                                protocol=tcp
    ...                                ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                                cells_to_block=[12,13]
    ...                                desired_pci=${16}
    ...                                log_throughput=${True}


    [Teardown]    Run Keywords
    ...    Cleanup After TC_B1-01    AND
    ...    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
            ...      lte_cell_list=@{EMPTY}
            ...      nr_cell_list=@{CELL_ALL_PORTS}
            ...    AND
    ...    keywords.Test Teardown    AND
    ...    Common Postconditions With Watching Alarms


CB011086_07_Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    07    CRT    jk
    [Setup]    Custom UUF Test Setup

    E2E TL SITE RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_project=${QC_PROJECT}
    ...          qc_id=${QC_ID_RESET}
    ...          sw_build=${5G_TARGET_SW}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          l3_call_method=L3 Call TC_B1-05

    [Teardown]    Custom UUF Test Teardown


CB011086_13_Manual_SiSo_SM_RU_Module_lock_unlock
    [Tags]    13    CRT    jk
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Cell blocked    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    Lock Radio Unit on gNB    radio_unit_id=4
    Sleep    10
    Log To Console    Radio Modules Locked
    CB012194_keywords.Log Alarms     also_console=${False}
    Unlock Radio Unit on gNB    radio_unit_id=4
    Log To Console    Radio Modules Unocked
    Wait For Site To Be Onair  timeout=180
    gnbcell.Wait For All Cells To Be OnAir    timeout=180
    Log To Console    All Cells are Onair

    ${DURATION}         Set Variable    400s
    ${DEVIATION_NR}     Set Variable    40%
    Prepare UE for NSA L3 Call     band_lte=1     band_nr=3
    Wait Until Keyword Succeeds    3x    3 min    ute_ue.reboot_ue    ${UE_DEFAULT_ALIAS_NAME}    timeout=${170}
    Sleep    10
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=10dB     db_level_lte=50dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_15_3_ATT_PORTS}
    Attach UE and Start DL and UL traffic    throughput_DL=600 Mbits/sec
    ...                                throughput_UL=170 Mbits/sec
    ...                                duration=${DURATION}
    ...                                deviation=${DEVIATION_NR}
    ...                                protocol=tcp
    ...                                ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                                cells_to_block=[12,13,11]
    ...                                desired_pci=${15}
    ...                                log_throughput=${True}


    [Teardown]    Run Keywords
    ...     Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
            ...      lte_cell_list=@{EMPTY}
            ...      nr_cell_list=@{CELL_ALL_PORTS}
            ...    AND
    ...    keywords.Test Teardown    AND
    ...    Common Postconditions With Watching Alarms


CB011086_14_General_SiSo_stability_with_L3Call
    [Tags]    14    CRT    jk
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Cell blocked    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    Log To Console    SiSo_stability_with_L3Call

    ${DURATION}         Set Variable    300s
    ${DEVIATION_NR}     Set Variable    5%
    ${DEVIATION_LTE}    Set Variable    5%

    Prepare UE for NSA L3 Call     band_lte=1     band_nr=3
    Wait Until Keyword Succeeds    3x    3 min    ute_ue.reboot_ue    ${UE_DEFAULT_ALIAS_NAME}    timeout=${170}
    Sleep    10

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=9dB     db_level_lte=59dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_15_3_ATT_PORTS}

    Attach UE and Start DL and UL traffic    throughput_DL=620 Mbits/sec
    ...                                throughput_UL=170 Mbits/sec
    ...                                duration=${DURATION}
    ...                                deviation=${DEVIATION_NR}
    ...                                protocol=tcp
    ...                                ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                                cells_to_block=[12,13,11]
    ...                                desired_pci=${15}
    ...                                log_throughput=${True}

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_15_3_ATT_PORTS}

    Set Active Bands       ${UE_DEFAULT_ALIAS_NAME}    NSA_NR5G     5
    Wait Until Keyword Succeeds    3x    3 min    ute_ue.reboot_ue    ${UE_DEFAULT_ALIAS_NAME}    timeout=${170}
    Sleep    10

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=10dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_14_3_ATT_PORTS}
    Attach UE and Start DL and UL traffic    throughput_DL=202 Mbits/sec
    ...                                throughput_UL=105 Mbits/sec
    ...                                duration=${DURATION}
    ...                                deviation=${DEVIATION_NR}
    ...                                protocol=tcp
    ...                                ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                                cells_to_block=[12,13]
    ...                                desired_pci=${14}
    ...                                log_throughput=${True}

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_14_3_ATT_PORTS}

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=10dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_11_3_ATT_PORTS}
    Attach UE and Start DL and UL traffic    throughput_DL=207 Mbits/sec
    ...                                throughput_UL=105 Mbits/sec
    ...                                duration=${DURATION}
    ...                                deviation=${DEVIATION_NR}
    ...                                protocol=tcp
    ...                                ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                                cells_to_block=[12,13,15]
    ...                                desired_pci=${11}
    ...                                log_throughput=${True}

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_11_3_ATT_PORTS}

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=10dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_16_3_ATT_PORTS}
    Attach UE and Start DL and UL traffic    throughput_DL=202 Mbits/sec
    ...                                throughput_UL=105 Mbits/sec
    ...                                duration=${DURATION}
    ...                                deviation=${DEVIATION_NR}
    ...                                protocol=tcp
    ...                                ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                                cells_to_block=[12,13]
    ...                                desired_pci=${16}
    ...                                log_throughput=${True}

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_16_3_ATT_PORTS}

# LTE Part
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=quectel
    Set Active Bands       ${UE_DEFAULT_ALIAS_NAME}    LTE     5

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=10dB
    ...      lte_cell_list=@{CELL_NSA_14_3_ATT_PORTS}
    ...      nr_cell_list=@{EMPTY}
    Attach UE and Start DL and UL traffic    throughput_DL=38.5 Mbits/sec
    ...                                throughput_UL=19 Mbits/sec
    ...                                duration=${DURATION}
    ...                                deviation=${DEVIATION_LTE}
    ...                                protocol=tcp
    ...                                ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                                desired_pci=${2}
    ...                                log_throughput=${True}


    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{CELL_NSA_14_3_ATT_PORTS}
    ...      nr_cell_list=@{EMPTY}

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=10dB
    ...      lte_cell_list=@{CELL_LTE_6}
    ...      nr_cell_list=@{EMPTY}
    Attach UE and Start DL and UL traffic    throughput_DL=89 Mbits/sec
    ...                                throughput_UL=48 Mbits/sec
    ...                                duration=${DURATION}
    ...                                deviation=${DEVIATION_LTE}
    ...                                protocol=tcp
    ...                                ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                                desired_pci=${6}
    ...                                log_throughput=${True}


    [Teardown]    Run Keywords
    ...     Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
            ...      lte_cell_list=@{EMPTY}
            ...      nr_cell_list=@{CELL_ALL_PORTS}
            ...    AND
    ...    keywords.Test Teardown
    ...    AND
    ...    Common Postconditions With Watching Alarms



CB011086_06_General_SiSo_NR_Cell_block_and_unblock
    [Tags]    06    CRT   mm
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Cell blocked    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    sg7keywords.Block cells    [11,12,13,14,15,16]
    Verify Alarm is Active on gNB    fault_name=Cell blocked
    Sleep    60
    sg7keywords.Unblock cells        [11,12,13,14,15,16]
    gnbcell.Wait For All Cells To Be OnAir    timeout=600
    Verify Alarm is not Active on gNB    fault_name=Cell blocked

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=12dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_12_3_ATT_PORTS}
    Attach UE, check bi-directional traffic and detach UE on timeout
    ...      traffic_duration=100s
    ...      protocol=tcp
    ...      nr_cell_id=${12}
    ...      max_tput_dl=580 Mbits/sec
    ...      max_tput_ul=180 Mbits/sec
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_12_3_ATT_PORTS}

    [Teardown]  Run Keywords
    ...         Run Keyword If Test Failed    sg7keywords.Unblock cells    [11,12,13,14,15,16]    ignore_error=${True}
    ...   AND   Run Keyword If Test Failed    sg7keywords.Unblock cells    [1,2,4,5,6,7,8,9,20,21,22]    ignore_error=${True}
    ...   AND   Set attenuation level in dB for NR and LTE Cells     db_level_nr=70dB     db_level_lte=70dB
    ...         lte_cell_list=@{EMPTY}
    ...         nr_cell_list=@{CELL_ALL_PORTS}
    ...   AND   Common Postconditions With Watching Alarms

CB011086_08_General_SiSo_SM_LTE_Cell_block_unblock
    [Tags]    08    CRT   mm
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Cell blocked    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    sg7keywords.Block cells    [1,2,4,5,6,7,8,9,20,21,22]
    Verify Alarm is Active on gNB    fault_name=Cell blocked
    Sleep    60
    sg7keywords.Unblock cells    [1,2,4,5,6,7,8,9,20,21,22]
    gnbcell.Wait For All Cells To Be OnAir    timeout=600
    Verify Alarm is not Active on gNB    fault_name=Cell blocked

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=12dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_12_3_ATT_PORTS}
    Attach UE, check bi-directional traffic and detach UE on timeout
    ...      traffic_duration=100s
    ...      protocol=tcp
    ...      nr_cell_id=${12}
    ...      max_tput_dl=580 Mbits/sec
    ...      max_tput_ul=180 Mbits/sec
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_12_3_ATT_PORTS}

    [Teardown]  Run Keywords
    ...         sg7keywords.Unblock cells    [11,12,13,14,15,16,1,2,4,5,6,7,8,9,20,21,22]    ignore_error=${True}
    ...   AND   Set attenuation level in dB for NR and LTE Cells     db_level_nr=70dB     db_level_lte=70dB
    ...         lte_cell_list=@{EMPTY}
    ...         nr_cell_list=@{CELL_ALL_PORTS}
    ...   AND   Common Postconditions With Watching Alarms

CB011086_11_Manual_SiSo_SM_NR_cell_lock_unlock_administrative_state_change_from_GUI
    [Tags]    11    CRT   mm
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Cell blocked    Setup of X2 connectivity to gNB failed    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    keywords-11086.Lock gNB Cells And Verify Results    11  13  15  16

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=12dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_12_3_ATT_PORTS}
    Attach UE, check bi-directional traffic and detach UE witohut cell check
    ...      traffic_duration=100s
    ...      protocol=tcp
    ...      nr_cell_id=${12}
    ...      max_tput_dl=580 Mbits/sec
    ...      max_tput_ul=180 Mbits/sec
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_12_3_ATT_PORTS}

    sg7keywords.Unlock gNB Cell    cell_id=13
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=12dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_13_3_ATT_PORTS}
    Attach UE, check bi-directional traffic and detach UE witohut cell check
    ...      traffic_duration=100s
    ...      protocol=tcp
    ...      nr_cell_id=${13}
    ...      max_tput_dl=600 Mbits/sec
    ...      max_tput_ul=160 Mbits/sec
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_13_3_ATT_PORTS}

    Log To Console    Reset BTS..    no_newline=True
    Reset gNB
    Log To Console    . Done

    Wait For Site To Be Onair     timeout=300
    Wait for cell to be locked    timeout=300    cell_id=11
    Wait for cell to be locked    timeout=300    cell_id=15
    Wait for cell to be locked    timeout=300    cell_id=16

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=12dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_13_3_ATT_PORTS}
    Attach UE, check bi-directional traffic and detach UE witohut cell check
    ...      traffic_duration=100s
    ...      protocol=tcp
    ...      nr_cell_id=${13}
    ...      max_tput_dl=600 Mbits/sec
    ...      max_tput_ul=160 Mbits/sec
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_13_3_ATT_PORTS}

    sg7keywords.Unlock gNB Cell    cell_id=15
    sg7keywords.Unlock gNB Cell    cell_id=11

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=12dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_12_3_ATT_PORTS}
    Attach UE, check bi-directional traffic and detach UE witohut cell check
    ...      traffic_duration=100s
    ...      protocol=tcp
    ...      nr_cell_id=${12}
    ...      max_tput_dl=580 Mbits/sec
    ...      max_tput_ul=180 Mbits/sec
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_12_3_ATT_PORTS}

    sg7keywords.Unlock gNB Cell    cell_id=16

    [Teardown]    Run Keywords
    ...         Run Keyword If Test Failed    Unlock gNB cells after FAIL in TC11
    ...   AND   sg7keywords.Unblock cells    [11,12,13,14,15,16,1,2,4,5,6,7,8,9,20,21,22]    ignore_error=${True}
    ...   AND   Set attenuation level in dB for NR and LTE Cells     db_level_nr=70dB     db_level_lte=70dB
    ...         lte_cell_list=@{EMPTY}
    ...         nr_cell_list=@{CELL_ALL_PORTS}
    ...   AND   Common Postconditions With Watching Alarms

CB011086_12_Manual_SiSo_SM_BTS_Block_Site
    [Tags]    12    CRT   mm
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Cell blocked    BTS blocked    BTS Reset Cause        AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    Log To Console    Block Site..    no_newline=True
    gnbbbu.block_bts
    Log To Console    . Site blocked
    keywords.Log Alarms    also_console=${False}

    Sleep    60
    Log To Console    Unblock Site..    no_newline=True
    gnbbbu.unblock_bts    timeout=300
    Log To Console    . Site unblocked, ..
    keywords.Log Alarms    also_console=${False}
    Wait For Site To Be Onair  timeout=600
    gnbcell.Wait For All Cells To Be Onair    timeout=300
    Log To Console    . Cells OnAir    no_newline=True

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=12dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_12_3_ATT_PORTS}
    Attach UE, check bi-directional traffic and detach UE on timeout
    ...      traffic_duration=100s
    ...      protocol=tcp
    ...      nr_cell_id=${12}
    ...      max_tput_dl=580 Mbits/sec
    ...      max_tput_ul=180 Mbits/sec
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_12_3_ATT_PORTS}

    [Teardown]    Run Keywords
    ...          Run Keyword If Test Failed    gnbbbu.unblock_bts    timeout=300
    ...   AND    sg7keywords.Unblock cells    [11,12,13,14,15,16,1,2,4,5,6,7,8,9,20,21,22]    ignore_error=${True}
    ...   AND    Run Keyword If Test Failed    Set attenuation level in dB for NR and LTE Cells     db_level_nr=70dB
    ...          db_level_lte=70dB    lte_cell_list=@{EMPTY}   nr_cell_list=@{CELL_ALL_PORTS}
    ...   AND    Common Postconditions With Watching Alarms

CB011086_29_E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]    29    CRT   ns
    [Documentation]       Verify gNB can go back to on air after reset with customer configuration.
    [Setup]    Custom UUF Test Setup
    E2E TL SITE RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=1
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_project=${QC_PROJECT}
    ...          qc_id=${QC_ID_RESET29}
    ...          sw_build=${5G_TARGET_SW}
    ...          customers_list=@{CUSTOMERS_LIST}

    [Teardown]    Custom UUF Test Teardown

CB011086_25_sHUB_reset_WEM
    [Tags]    25    CRT   ns
    [Documentation]      Test verifies that after sHUB/ASIRMOD is able to get back to Online status
    ...                  after module reset from WebEM
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Cell blocked    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    gnbasir.Verify Status Of All Asir Cells Is Operational
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=12dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_12_3_ATT_PORTS}
    Attach UE, check bi-directional traffic and detach UE on timeout
    ...      traffic_duration=60s
    ...      protocol=tcp
    ...      nr_cell_id=${12}
    ...      max_tput_dl=465 Mbits/sec
    ...      max_tput_ul=160 Mbits/sec
    Reset ASIRMOD-1 via WebEM for MRBTS-75019
    gnbcell.wait_for_all_cells_to_be_onair      timeout=350
    Attach UE, check bi-directional traffic and detach UE on timeout
    ...      traffic_duration=60s
    ...      protocol=tcp
    ...      nr_cell_id=${12}
    ...      max_tput_dl=465 Mbits/sec
    ...      max_tput_ul=160 Mbits/sec
    [Teardown]    Run Keywords
    ...    Test Teardown    AND
    ...    Common Postconditions With Watching Alarms

CB011086_28_Block_unblock_sHUB_WEM
    [Tags]    28    CRT   ns
    [Documentation]     Verify sHUB is fully operable after sHUB block/unblock with OBSAI/CPRI link used.
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Cell blocked    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    ${cells_to_unblock}      Create List      1     2      4      5      6     7    8
    ...                      9     10    11     13     14     15    16
    ...                      17    18    19     20     21    22    23

    gnbasir.Verify Status Of All Asir Cells Is Operational
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=12dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_12_3_ATT_PORTS}
    Attach UE, check bi-directional traffic and detach UE on timeout
    ...      traffic_duration=60s
    ...      protocol=tcp
    ...      nr_cell_id=${12}
    ...      max_tput_dl=465 Mbits/sec
    ...      max_tput_ul=160 Mbits/sec
    Lock ASIRMOD-1 via WebEM for MRBTS-75019
    ${result}     ${message}     run keyword and ignore error      Attach UE, check bi-directional traffic and detach UE on timeout
    ...      traffic_duration=60s
    ...      protocol=tcp
    ...      nr_cell_id=${12}
    ...      max_tput_dl=465 Mbits/sec
    ...      max_tput_ul=160 Mbits/sec
    should be equal      ${result}      FAIL
    Unlock ASIRMOD-1 via WebEM for MRBTS-75019
    sg7keywords.unblock cells     ${cells_to_unblock}     ignore_error=${True}
    gnbcell.wait_for_all_cells_to_be_onair      timeout=350
    Attach UE, check bi-directional traffic and detach UE on timeout
    ...      traffic_duration=120s
    ...      protocol=tcp
    ...      nr_cell_id=${12}
    ...      max_tput_dl=465 Mbits/sec
    ...      max_tput_ul=160 Mbits/sec

    [Teardown]    Run Keywords
    ...    Test Teardown    AND
    ...    Common Postconditions With Watching Alarms


*** Keywords ***

Test Teardown
    Log To Console      Test Teardown
    sg7keywords.Unblock cells    [11,12,13,14,15,16,1,2,4,5,6,7,8,9,20,21,22]    ignore_error=${True}
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...    lte_cell_list=@{EMPTY}     nr_cell_list=@{CELL_ALL_PORTS}
