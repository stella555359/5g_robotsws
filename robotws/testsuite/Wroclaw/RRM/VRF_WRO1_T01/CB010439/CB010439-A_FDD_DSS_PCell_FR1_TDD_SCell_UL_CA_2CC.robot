*** Settings ***
Resource    keywords_CB010439.robot

Documentation
...    author: Lukasz Filipek (lukasz.filipek@nokia.com)
...    maintainer: Lukasz Filipek
...    testline: CLOUD_5G_O_H_AP_LOO
...    release: 26R2

Suite Setup      Run Keywords    Enable Syslog Info Level Prints
    ...       AND    Get and Update BSR File
    ...       AND    Update And Put Iphy Xml         input_filepath=${CURDIR}/config/iphy_4cc_dss.xml
    ...       AND    With Gnb Configuration    commissioning=full_scfc_4cc_dss.xml
    ...       AND    Wait for gNB Configured state
    ...       AND    Configure SA VM interfaces
    ...       AND    Reach Onair Without Confirmation    lua_cfg=${CURDIR}/config/cfg_4cc_dss.lua
    ...       AND    Activate XP Link
    ...       AND    Proceed With DSS Activation Script
    ...       AND    Wait For Next Full Pm Interval

Test Teardown    Send Configuration ID To Scout
Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TRAFFIC_DURATION_SEC}=    180s
${EN_DSS_UL_PRBS_NR}=    M55332C01001
${EN_DSS_NBR_AVLBL_UL_PRBS}=    M55332C02002
${NUM_UE_SCHD_SB_BF}=    M55330C00018

*** Test Cases ***
CB010439-A_FDD_DSS_PCell_FR1_TDD_SCell_UL_CA_2CC
    Register Ue With Pdu Session
    UE Sends A1 Measurement For CA 4CC SCell Addition
    Start High DL And DL Data Traffic
    Check Data Traffic On PCell And Scell
#    Verify If Pm Counters Were Incremented

*** Keywords ***
Start High DL And DL Data Traffic
    [Arguments]    ${ue_id}=1
    Execute egate command  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
    Execute egate command  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=100 trf_id=2
    Execute egate command  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
    Execute egate command  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Execute egate command  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3
    Execute egate command  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4
    Execute egate command  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=5

Check Data Traffic On PCell And Scell
    [Arguments]    ${ue_id}=1
    Sleep    ${TRAFFIC_DURATION_SEC}
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id} scell=0-9 type=pusch
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id} scell=0-9 type=pdsch
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=${ue_id} pdu=1 qfi=1
    Expected Throughput For Qfi Should Be Reached    ue_id=${ue_id}    pdu_id=1    qfi_id=1
    ...    expected_throughput=750    unit=mbps    margin=0.2    direction=dl
    Expected Throughput For Qfi Should Be Reached    ue_id=${ue_id}    pdu_id=1    qfi_id=1
    ...    expected_throughput=170    unit=mbps    margin=0.2    direction=ul

UE Sends A1 Measurement For CA 4CC SCell Addition
    Execute egate command  cmd=ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=100 srsrq_nr=50

Verify If Pm Counters Were Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value    counter_list=${EN_DSS_UL_PRBS_NR}
    ...    value=25000000    local_moid=/MRBTS-1/NRBTS-1/NRCELL-3    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counters In Counter Id List Have Exact Value    counter_id_list=${EN_DSS_NBR_AVLBL_UL_PRBS}
    ...    value=31800000    local_moid=/MRBTS-1/NRBTS-1/NRCELL-3    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counters In Counter Id List Have Exact Value    counter_id_list=${NUM_UE_SCHD_SB_BF}
    ...    value=0    local_moid=/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
