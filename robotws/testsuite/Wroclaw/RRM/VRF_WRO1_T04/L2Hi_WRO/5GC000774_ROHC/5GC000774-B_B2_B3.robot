*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     keywords_ROHC.py
Documentation
...    author: Anna Chabik
...    maintainer: Anna Chabik (anna.chabik@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 22R2

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
${UE_ID_TDD}=    1
${UE_ID_FDD}=    20
${CELL_ID_FDD}=   3

*** Test Cases ***
5GC000774-B-B3_Verification_Of_Pm_Counters_Dl_Sdu_Disc_During_Rohc_Comp_And_Dl_Vol_Disc_During_Rohc_Comp_TDD
    Wait For Next Full Pm Interval
    Attach One 5g Ue Capable Of Supporting Rohc
    Start Packet Corrupted Dl Data Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Deregister Ue    ${UE_ID_TDD}
    Verify If Rohc Compr Failed Rd Counters Were Incremented

5GC000774-B-B3_Verification_Of_Pm_Counters_Dl_Sdu_Disc_During_Rohc_Comp_And_Dl_Vol_Disc_During_Rohc_Comp_FDD
    Wait For Next Full Pm Interval
    Attach One 5g Ue Capable Of Supporting Rohc    ${UE_ID_FDD}
    Start Packet Corrupted Dl Data Traffic    ${UE_ID_FDD}
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics    ${UE_ID_FDD}   ${CELL_ID_FDD}
    Deregister Ue    ${UE_ID_FDD}
    Verify If Rohc Compr Failed Rd Counters Were Incremented

5GC000774-B-B2_Verification_Of_Pm_Counters_Ul_Pdu_Disc_Rohc_Decomp_Failed_And_Ul_Vol_Disc_Rohc_Decomp_Failed_TDD
    Wait For Next Full Pm Interval
    Set Support For Ul Packet Corruption
    Attach One 5g Ue Capable Of Supporting Rohc
    Start Ul Data Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Deregister Ue    ${UE_ID_TDD}
    Verify If Rohc Decompr Failed Rd Counters Were Incremented

5GC000774-B-B2_Verification_Of_Pm_Counters_Ul_Pdu_Disc_Rohc_Decomp_Failed_And_Ul_Vol_Disc_Rohc_Decomp_Failed_FDD
    Wait For Next Full Pm Interval
    Set Support For Ul Packet Corruption    ${UE_ID_FDD}
    Attach One 5g Ue Capable Of Supporting Rohc    ${UE_ID_FDD}
    Start Ul Data Traffic    ${UE_ID_FDD}
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics    ${UE_ID_FDD}   ${CELL_ID_FDD}
    Deregister Ue    ${UE_ID_FDD}
    Verify If Rohc Decompr Failed Rd Counters Were Incremented


*** Keywords ***
Set Support For Ul Packet Corruption
    [Arguments]    ${UE_ID}=${1}
    Execute Egate Command    cmd=ue_param id=${UE_ID} rohc_hdr_corruption=2:4:6

Display Ue Statistics
    [Arguments]    ${UE_ID}=${1}    ${CELL_ID}=${1}
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=${UE_ID} pdu=1 qfi=3 trf_id=1 dir=bi type=l3_trf include_corruption_stats=on
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=${CELL_ID} format=long

Start Ul Data Traffic
    [Arguments]    ${UE_ID}=${1}
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=ul rtp_codec=amr_wb_23_85

Start Packet Corrupted Dl Data Traffic
    [Arguments]    ${UE_ID}=${1}
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 trf_id=1 kbps=40 dir=dl dl_packet_corruption=2 corruption_threshold=0

Verify If Rohc Decompr Failed Rd Counters Were Incremented
    ${RD_COUNTERS}=    Get Next Unpacked Raw Rd Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=UL_PDU_DISC_ROHC_DECOMP_FAILED
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${RD_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=UL_VOL_DISC_ROHC_DECOMP_FAILED
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${RD_COUNTERS}

Verify If Rohc Compr Failed Rd Counters Were Incremented
    ${RD_COUNTERS}=    Get Next Unpacked Raw Rd Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=DL_SDU_DISC_ROHC_COMP_FAILED
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${RD_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=DL_VOL_DISC_ROHC_COMP_FAILED
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${RD_COUNTERS}
