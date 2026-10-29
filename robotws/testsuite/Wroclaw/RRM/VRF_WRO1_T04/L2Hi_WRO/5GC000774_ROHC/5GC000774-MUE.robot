*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     keywords_ROHC.py
Documentation
...    author: Pawel Konieczny
...    maintainer: Anna Chabik (anna.chabik@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_O_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    release: 22R2

Test Setup      Prepare Sa Test Environement And Reach Onair
...               perform_tl_reset=${RESET_TL}
...               cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
...               cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
...               cfg_filepath_tdd_fdd=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

Suite Setup    Run Keywords    Enable Vonr And Rohc
...            AND    Enable Syslog Debug Prints For Rohc

Test Teardown    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   40s

*** Test Cases ***
5GC000774-Multi_Ue
    Wait For Next Full Pm Interval
    Attach Multiple 5g Ues Capable Of Supporting Rohc    num_of_ues=${9}
    Start Dl And Ul Data Traffic For Tcp Udp And Rtp Packet Stream
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Verify If Rohc Dl And Ul Header Pm Counters Are Incremented
    Verify Rohc Contexts Pm Counters Values
    Check If Expected Throughout Is Reached For All Ues And There Are No Packets Lost

*** Keywords ***
Attach Multiple 5g Ues Capable Of Supporting Rohc
    Execute Egate Command    cmd=sim_debug_log level=6
    [Arguments]    ${num_of_ues}=${9}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Set Internal Traffic Type To UEs    ue_id=${ue_id}    pdu_id=${ue_id}
        Attach Ue    ue_id=${ue_id}
        Establish Pdu Session    ue_id=${ue_id}    pdu_id=${ue_id}    gw_id=${ue_id}
        Modify Pdu Session    ue_id=${ue_id}    pdu_id=${ue_id}    qos_to_add=2
        Modify Pdu Session    ue_id=${ue_id}    pdu_id=${ue_id}    qos_to_add=3
    END

Display Ue Statistics
    [Arguments]    ${num_of_ues}=${9}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Display Qfi stats    ue_id=${ue_id}    pdu_id=${ue_id}    qfi_id=3
    END
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Start Dl And Ul Data Traffic For Tcp Udp And Rtp Packet Stream
    FOR    ${ue_id}    IN RANGE    ${1}    ${3}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=dl kbps=30 protocol=tcp
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=ul kbps=30 protocol=tcp
    END
    FOR    ${ue_id}    IN RANGE    ${4}    ${6}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=dl rtp_codec=amr_wb_23_85
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=ul rtp_codec=amr_wb_23_85
    END
    FOR    ${ue_id}    IN RANGE    ${7}    ${9}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=dl kbps=30
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=ul kbps=30
    END

Check That Amount Of Compressed And Decompressed Pdus For Profile 1 Is Incremented As Expected For This Traffic Time
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=560    enb_id=2    cell_id=1
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_1_pdus    mode=am    value=560    enb_id=2    cell_id=1

Check That Difference Between Compressed And Decompressed Bytes For Profile 1 Is In Expected Range For This Traffic Time
    Rohc Statistic Smaller Than Given Value    rohc_statistic_prefix=size_of_compressed_pdus    mode=am    value=34000    enb_id=2    cell_id=1
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_1_bytes    mode=am    value=54000    enb_id=2    cell_id=1

Check If Expected Throughout Is Reached For All Ues And There Are No Packets Lost
    [Arguments]    ${num_of_ues}=${9}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Expected Throughput For Qfi Should Be Reached    ue_id=${ue_id}    pdu_id=${ue_id}    qfi_id=3
        ...    expected_throughput=30    unit=kbps    margin=1    direction=bi
        Check Number Of Total Packets Lost    ue_id=${ue_id}    pdu_id=${ue_id}    qfi_id=3    packet_loss=1
        ...    margin=1.0    direction=bi
    END

Verify If Rohc Dl And Ul Header Pm Counters Are Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_ROHC_COMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_ROHC_COMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_NUM_ROHC_DECOMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_VOL_ROHC_DECOMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify Rohc Contexts Pm Counters Values
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_REQ_SENT}
    ...    value=18    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_RESP_RECD}
    ...    value=18    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_REQ_SENT}
    ...    value=18    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_CMP_RECD}
    ...    value=18    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
