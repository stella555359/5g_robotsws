*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     keywords_ROHC.py
Documentation
...    author: Pawel Konieczny
...    maintainer: Bartlomiej Urbanowicz (bartlomiej.urbanowicz@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 22R3

Suite Setup     Run Keywords    Prepare Sa Test Environement And Reach Onair
...               perform_tl_reset=${RESET_TL}
...               cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
...               cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
...               cfg_filepath_tdd_fdd=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
...            AND    Enable Vonr And Rohc TDD FDD
...            AND    Enable Syslog Debug Prints For Rohc

Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

Test Teardown    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
${UE_ID_CS12_TDD}=    255
${UE_ID_CS12_FDD}=    254
${CELL_ID_FDD}=   3

*** Test Cases ***
5GC000774-A-B1_Successful_Setup_Of_Voice_Over_Nr_Call_With_Rohc_Profile_0x0002_Ipv4_TDD
    Attach One 5g Ue Capable Of Supporting Rohc    ${UE_ID_CS12_TDD}
    Start Dl And Ul Data Traffic For Udp Packet Stream For Certain Amount Of Packets
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Check That Amount Of Compressed And Decompressed Pdus For Profile 2 Is Incremented As Expected
    Check That Difference Between Compressed And Decompressed Bytes For Profile 2 Is As Expected
    Check That There Are No Packets Lost
    Verify If Rohc Dl And Ul Header Pm Counters Have Expected Values
    Verify Rohc Contexts Pm Counters Values
    Deregister Ue    ${UE_ID_CS12_TDD}

5GC000774-A-B1_Successful_Setup_Of_Voice_Over_Nr_Call_With_Rohc_Profile_0x0002_Ipv4_FDD
    Attach One 5g Ue Capable Of Supporting Rohc    ${UE_ID_CS12_FDD}
    Start Dl And Ul Data Traffic For Udp Packet Stream For Certain Amount Of Packets   ${UE_ID_CS12_FDD}
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics   ${UE_ID_CS12_FDD}    ${CELL_ID_FDD}
    Check That Amount Of Compressed And Decompressed Pdus For Profile 2 Is Incremented As Expected    ${CELL_ID_FDD}
    Check That Difference Between Compressed And Decompressed Bytes For Profile 2 Is As Expected    ${CELL_ID_FDD}
    Check That There Are No Packets Lost    ${UE_ID_CS12_FDD}
    Verify If Rohc Dl And Ul Header Pm Counters Have Expected Values
    Verify Rohc Contexts Pm Counters Values    ${CELL_ID_FDD}
    Deregister Ue    ${UE_ID_CS12_FDD}

*** Keywords ***
Display Ue Statistics
    [Arguments]    ${UE_ID}=${255}    ${CELL_ID}=${1}
    Display Qfi stats    ue_id=${UE_ID}    qfi_id=3
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=${CELL_ID} format=long

Start Dl And Ul Data Traffic For Udp Packet Stream For Certain Amount Of Packets
    [Arguments]    ${UE_ID}=${255}
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=dl trf_id=1 kbps=30 packets=50
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=ul trf_id=2 kbps=30 packets=50

Check That Amount Of Compressed And Decompressed Pdus For Profile 2 Is Incremented As Expected
    [Arguments]    ${CELL_ID}=${1}
    Rohc Statistic Equal To Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=50
    ...    enb_id=2    cell_id=${CELL_ID}
    Rohc Statistic Equal To Given Value    rohc_statistic_prefix=decompressed_profile_2_pdus    mode=am    value=50
    ...    enb_id=2    cell_id=${CELL_ID}

Check That Difference Between Compressed And Decompressed Bytes For Profile 2 Is As Expected
    [Arguments]    ${CELL_ID}=${1}
    Rohc Statistic Equal To Given Value    rohc_statistic_prefix=size_of_compressed_pdus    mode=am    value=54976
    ...    enb_id=2    cell_id=${CELL_ID}
    Rohc Statistic Equal To Given Value    rohc_statistic_prefix=decompressed_profile_2_bytes    mode=am    value=56250
    ...    enb_id=2    cell_id=${CELL_ID}

Check That There Are No Packets Lost
    [Arguments]    ${UE_ID}=${255}
    Check Number Of Total Packets Lost    ue_id=${UE_ID}    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi

Verify If Rohc Dl And Ul Header Pm Counters Have Expected Values
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_NUM_ROHC_COMP_HEADER}
    ...    value=50    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_VOL_ROHC_COMP_HEADER}
    ...    value=126    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_UL_NUM_ROHC_DECOMP_HEADER}
    ...    value=50    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_UL_VOL_ROHC_DECOMP_HEADER}
    ...    value=1400    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify Rohc Contexts Pm Counters Values
    [Arguments]    ${CELL_ID}=${1}
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_REQ_SENT}
    ...    value=5    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_RESP_RECD}
    ...    value=5    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_REQ_SENT}
    ...    value=5    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_CMP_RECD}
    ...    value=5    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}    filepath=${PM_COUNTERS}
