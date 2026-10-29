*** Settings ***
Documentation
...    author: Paulina Jedras
...    contact: paulina.jedras@nokia.com

Library     ute_syslog
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     ../resources/former_l2_sw1/python/traffic_handling.py
Library     ../resources/former_l2_sw1/python/ue_handling.py
Library     ./resources/CB013338_logs_verification.py

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../resources/former_l2_sw1/robot/common_keywords.robot
Resource    ../resources/former_l2_sw1/robot/collectors.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Prepare Test Environment

*** Variables ***
${wts_cfg}=         ${CURDIR}/config/wts_212_UEs.lua
${scfc}=            ${CURDIR}/config/scfc_FR2_8CC_TDD_NSA.xml
${iphy}=            ${CURDIR}/config/AP_AWEUB_8cells.xml
@{set_RADs}=        0x580581=0x8000    0x58057A=3
                    #0x580581=0x8000    rdFeatureFlagBitmap6.L1L2TIMING (bitmask)
                    #0x58057A=3    rdFeatureFlagBitmapLevel = INFO (enum)
                    #0x58022F=1    rdL1L2TimingCheckEnable = true (bool); enabled by default
${TA_MESSAGING_DISABLE_CSV_LOGGING}=		${True}
${logcollector}=    False
${TRAFFIC_DURATION}=    300


*** Test Cases ***
CB013338-SR-B_FR2_NSA_Multi_UE_Low_Load_DL_UL
    [Documentation]
    ...  Description:
    ...    This test case verifies, that specific L1-L2 BIP messages contains field timestamp
    ...    0xE113 - dldata_pdcchsendreql1sw
    ...    0xE126 - dldata_pdschpayloadtbsendreql1sw
    ...    0xE20B - uldata_puschreceiverespharqul1sw
    ...    Test verifies, that L2PS counters for above messages are present in syslog
    ...    Test verifies, that during low load scenario rate of accepted early/late messages number in not reached

    [Setup]    Common Preconditions
    Start collecting GNB syslog
    Sleep    30s    reason=Collect syslog without attached UEs
    Attach multi ues   first_ue_id=107  last_ue_id=111
    Sleep    30s    reason=Collect syslog with attached UEs without traffic
    Start NSA traffic for multiple UEs  ues=107-111  traffic_rate=40Mbps  dir=DL
    Sleep    15s    reason=Wait for env stabilization
    Start NSA traffic for multiple UEs  ues=107-111  traffic_rate=6Mbps  dir=UL
    Log to console    *** Started 40Mbps DL and 6Mbps UL for each of 5 UEs
    Sleep    15s    reason=Wait for env stabilization

    Check if UE traffic is on expected level

    Start collecting BIP logs    alias=L1L2_BIP_Logs
    Stop collecting BIP logs    dir_path=${OUTPUT_DIR}    alias=L1L2_BIP_Logs    delay=5

    Sleep    ${TRAFFIC_DURATION}s    reason=Collect longer syslog with traffic ongoing
    ${Syslog_file}    Stop collecting GNB syslog

    ${BIP_csv_file}    Convert BIP logs    alias=L1L2_BIP_Logs
    Verify timestamps in BIP    ${BIP_csv_file}

    Run keyword and continue on failure
    ...    Verify early late L1L2 msgs rate    ${Syslog_file}

    Start collecting GNB syslog    alias=short_syslog
    Sleep    60    reason=Collect in syslog at least 5 intervals with L2PS counters
    ${Syslog_file}    Stop collecting GNB syslog    alias=short_syslog
    verify_l2ps_counters_printed_for_each_cell  ${Syslog_file}    intervals=5

    [Teardown]  Run keywords
    ...           Run Keyword If Test Failed    Stop collecting GNB syslog
    ...    AND    Detach multi UEs    first_ue_id=107  last_ue_id=111
    ...    AND    Common Postconditions


*** Keywords ***
Prepare Test Environment
    Prepare suite environment
    ...    scfc=${scfc}  egate_config=${wts_cfg}  ap_xml=${iphy}  rad_params=@{set_RADs}    x2=True

Start collecting GNB syslog
    [Arguments]  ${alias}=GNB_syslog
    Log to console    Starting GNB Syslog Collection...
    Run keyword and ignore error    ute_syslog.Start syslog
    ...    log_dir=${OUTPUTDIR}/${alias}/    log_name=GNB_syslog.log    ip=192.168.255.126    alias=${alias}
    Log to console    * * * * * * * * * * * * * * * * * * * * * * * *

Stop collecting GNB syslog
    [Arguments]  ${alias}=GNB_syslog
    Log to console    Stopping GNB Syslog Collection
    ute_syslog.Collect syslog results    alias=${alias}    unzip=True
    [Return]    ${OUTPUTDIR}/${alias}/GNB_syslog.log

Convert BIP logs
    [Arguments]  ${alias}

    @{BIP_columns}  Create List
    Append To List  ${BIP_columns}  swe.T
    Append To List  ${BIP_columns}  swe.Timestamp
    Append To List  ${BIP_columns}  swe.MessageID
    Set test variable  @{BIP_columns}

    Convert BIP logs pcap to csv
    ...  pcap_path=${OUTPUT_DIR}/${alias}/tcpdump.pcap
    ...  filter=dldata_pdcchsendreql1sw || dldata_pdschpayloadtbsendreql1sw || uldata_puschreceiverespharqul1sw
    ...  dir_path=${OUTPUT_DIR}/${alias}
    ...  columns=@{BIP_columns}
    ...  csv_log_name=BIP_with_timestamps.csv

    [Return]   ${OUTPUT_DIR}/${alias}/BIP_with_timestamps.csv

Check if UE traffic is on expected level
    ${all_ues_traffic_dl}=    Get summarize data rate for multiple NSA UEs
    ...    dir=dl    first_ue=107    last_ue=111    data_rate_type=Average    bearer_type=scg    bearer=2
    ${all_ues_traffic_ul}=    Get summarize data rate for multiple NSA UEs
    ...    dir=ul    first_ue=107    last_ue=111    data_rate_type=Average    bearer_type=mcg    bearer=2
    Run keyword and continue on failure
    ...    Should Be True    ${all_ues_traffic_dl}>${195}    Too low DL traffic
    Run keyword and continue on failure
    ...    Should Be True    ${all_ues_traffic_ul}>${25}    Too low UL traffic
