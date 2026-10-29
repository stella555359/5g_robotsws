*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Library     ../resources/common_keywords.py
Library     ../5GC000774_ROHC/keywords_ROHC.py
Variables     ../resources/common_variables.py
Library     ta5g_pm_counters

Documentation
...    This file contains keywords used for testing Traffic Shaping and related functionalities on Classical TL.

*** Keywords ***
Enable Traffic Shaping
    ${TDD_CONFIGURATION}=    Check If Tdd Cell    global_cell_id=1
    Run Keyword If
    ...      '${TDD_CONFIGURATION}'=='True'               Enable Traffic Shaping TDD
    ...       ELSE IF  '${TDD_CONFIGURATION}'=='False'    Enable Traffic Shaping FDD

Enable Traffic Shaping TDD
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Traffic_shaping/delta_enable_traffic_shaping_TDD.json
    BuiltIn.Sleep    180s
    Wait for gNB Configured state

Enable Traffic Shaping FDD
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Traffic_shaping/delta_enable_traffic_shaping_FDD.json
    BuiltIn.Sleep    180s
    Wait for gNB Configured state

Adapt RLO Params
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Traffic_shaping/delta_adapt_DlHarqTreshold_and_rlpRecCsiBsiThreshold_values.json
    BuiltIn.Sleep    180s
    Wait for gNB Configured state

Enable FSTSCH Counters
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_FSTSCH_coutners.json

Enable Burst Size Divider
    Change Rad Param With Aashell    param=0x5A00AF    value=64

Attach 4 Nsa Ues With Sgnb And Start Traffic
    [Arguments]    ${first_ue}=${11}    ${last_ue}=${14}    ${cell_id}=${1}    ${dl_tput}=${10}    ${ul_tput}=${5}
    Execute Egate Command    cmd=sim_debug_log level=6
    Attach Multiple Nsa Ues With Sgnb Addition    first_ue_id=${first_ue}    number_of_ues=4    cell_id=${cell_id}
    Start Data Traffic To Multiple Nsa Ues    first_ue_id=${first_ue}    last_ue_id=${last_ue}    direction=dl    throughput=${dl_tput}
    Start Data Traffic To Multiple Nsa Ues    first_ue_id=${first_ue}    last_ue_id=${last_ue}    direction=ul    throughput=${ul_tput}

Attach Multi Sa Ues And Start Traffic
    [Arguments]    ${num_of_sa_ues}=${10}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_sa_ues}+${1}
        Set Internal Traffic Type To UEs    ue_id=${ue_id}    pdu_id=${ue_id}
        Register Ue With Default Pdu Session    ue_id=${ue_id}    pdu_id=${ue_id}     gw=${ue_id}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=1 dir=dl mbps=10 protocol=udp
        BuiltIn.Sleep    2s
    END

Display Sa Ue Statistics
    [Arguments]    ${num_of_sa_ues}=${10}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_sa_ues}+${1}
        Display Qfi stats    ue_id=${ue_id}    pdu_id=${ue_id}    qfi_id=1
    END
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Display Bearer Statistics
    [Arguments]    ${first_ue_id}=${11}    ${last_ue_id}=${14}
    Display Bearer Statistics For Multiple Nsa Ue    first_ue_id=${first_ue_id}    last_ue_id=${last_ue_id}    cell_group=mcg
    Display Bearer Statistics For Multiple Nsa Ue    first_ue_id=${first_ue_id}    last_ue_id=${last_ue_id}    cell_group=scg

Clear Bearer Statistics
    [Arguments]    ${last_nsa_ue_id}=${14}
    FOR    ${ue_id}    IN RANGE    ${11}    ${last_nsa_ue_id}+${1}
        Execute Egate Command    cmd=bearer_stats_clear ue=${ue_id} id=2
    END

Trigger Radio Link Outage Multiple Ues
    [Arguments]    ${first_ue_id}=${11}    ${last_nsa_ue_id}=${14}
    Execute Egate Command    cmd=forced_dtx_testmode_nr profile_id=1 force_dtx_pusch=4000:1 force_dtx_pucch=4000:1
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}    ${last_nsa_ue_id}+${1}
        Execute Egate Command And Wait For Data    cmd=ue_testmode_set_nr id=${ue_id} testmode=forced_dtx action=activate profile_id=1
        ...    pass_regexp=UE${ue_id}: Successfully reconfigured dual connectivity
        ...    timeout=30
    END

Perform Sgnb Release
    [Arguments]    ${last_nsa_ue_id}=${14}
    FOR    ${ue_id}    IN RANGE    ${13}    ${last_nsa_ue_id}+${1}
        Execute Egate Command And Wait For Data    cmd=enb_ue_dc_release ue=${ue_id} bearer=2 by=enb cause=off
        ...    pass_regexp=UE${ue_id}:  === Bearer-type change from SCG-split to MCG is successful ===
        ...    timeout=20
    END

Verify If Downlink PDCP Pdu QoS Grp 6 Pm Counters Were Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=M55323C01006
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=M55313C08006
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify Pdcp Pdu Packet Lost On X2-U
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=M55313C04006
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify Packet Drops At Transport First Level Scheduler
    ${TRS_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=M51351C43
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/QOS-1/FSTSCH-1    filepath=${TRS_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=M51351C45
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/QOS-1/FSTSCH-1    filepath=${TRS_COUNTERS}
