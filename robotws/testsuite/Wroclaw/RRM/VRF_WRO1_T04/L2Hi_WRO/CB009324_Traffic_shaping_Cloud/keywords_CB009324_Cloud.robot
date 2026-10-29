*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_keywords_vran.robot
Library     ../resources/common_keywords.py
Variables     ../resources/common_variables.py
Library     ta5g_pm_counters

Documentation
...    This file contains keywords used for testing Traffic Shaping and related functionalities on Cloud RINLINE TL.

*** Variables ***
${burst_size_divider}=    0x5A00AF

*** Keywords ***
Enable AiC Traffic Shaping
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Traffic_shaping_cloud/enable_traffic_shaping_CU_TDD.json
    Sleep    180s

Adapt AiC RLO Params
    Perform DU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Traffic_shaping_cloud/delta_adapt_DlHarqTreshold_DU.json
    Sleep    180s

Enable AiC FSTSCH Counters
    Perform DU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Traffic_shaping_cloud/enable_FTSCH_counters.json
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Traffic_shaping_cloud/enable_FTSCH_counters.json

Enable AiC Burst Size Divider
    Get TL config
    Perform R&D flag change on CU      pod_name=upue    rd_flag=${burst_size_divider}    rd_flag_value=64

Attach NSA MUe With SgNBAddition
    [Arguments]    ${first_ue_id}=${11}    ${last_ue_id}=${14}    ${cell_id}=1
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}    ${last_ue_id}+${1}
        Attach Ue To Enb    ue_id=${ue_id}
        Execute Egate Command    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
        Sleep    5s
        Execute Egate Command    cmd=debug_log level=6
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} id=2 dir=dl mbps=45
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} id=2 dir=ul mbps=10
    END

Start Dl And Ul Data Traffic
    [Arguments]    ${ue_id}=${11}
    Execute Egate Command    cmd=debug_log level=6
    Start Data Traffic    ues=${ue_id}    bearer_id=2    direction=dl    throughput=45mbps
    Start Data Traffic    ues=${ue_id}    bearer_id=2    direction=ul    throughput=15mbps

Verify If Downlink PDCP Pdu QoS Grp 9 Pm Counters Were Incremented
    Wait For Next PM counters Interval
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=M55323C01009
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=M55313C08009

Verify Pdcp Pdu Packet Lost On X2-U Cloud
    Verify CU Counter Value Is Exact As Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=M55313C04009

Verify Packet Drops At Transport First Level Scheduler Cloud
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/TNLSVC-1/TNL-3/IPNO-1/QOS-1/FSTSCH-1    counter_id=M51351C43
    Verify CU Counter Value Is Exact As Given Value
    ...    value=0    local_moid=MRBTS-1/TNLSVC-1/TNL-3/IPNO-1/QOS-1/FSTSCH-1    counter_id=M51351C45
