*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     keywords_ROHC.py
Documentation
...    author: Michal Brychcy
...    maintainer: Michal Brychcy (michal.brychcy@nokia.com)
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
${TRAFFIC_DURATION_SEC}=   19s
${UE_ID_TDD}=    1
${UE_ID_FDD}=    20

*** Test Cases ***
5GC000774-A-B5_Successful_Intra_frequency_intra_cell_Voice_Over_Nr_handover_With_Rohc_Profile_0x0001_Ipv4_TDD
    Attach One 5g Ue Capable Of Supporting Rohc
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID_TDD} pdu=1 qfi=3 dir=dl rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID_TDD} pdu=1 qfi=3 dir=ul rtp_codec=amr_wb_23_85
    Sleep    ${TRAFFIC_DURATION_SEC}
    Expected Throughput For Qfi Should Be Reached    ue_id=${UE_ID_TDD}    pdu_id=1    qfi_id=3
    ...    expected_throughput=20    unit=kbps    margin=0.2    direction=bi
    Perform Intracell Handover With Nr Sec Cap Defined And Wait For Confirmation    ue_id=${UE_ID_TDD}    nr_sec_cap=zuc|zuc    timeout=5
    Display Qfi stats    qfi_id=3
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=0    enb_id=2    cell_id=1
    Expected Throughput For Qfi Should Be Reached    ue_id=${UE_ID_TDD}    pdu_id=1    qfi_id=3
    ...    expected_throughput=20    unit=kbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=${UE_ID_TDD}    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi
    Deregister Ue    ue_id=${UE_ID_TDD}

5GC000774-A-B5_Successful_Intra_frequency_intra_cell_Voice_Over_Nr_handover_With_Rohc_Profile_0x0001_Ipv4_FDD
    Attach One 5g Ue Capable Of Supporting Rohc    ue_id=${UE_ID_FDD}
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID_FDD} pdu=1 qfi=3 dir=dl rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID_FDD} pdu=1 qfi=3 dir=ul rtp_codec=amr_wb_23_85
    Sleep    ${TRAFFIC_DURATION_SEC}
    Expected Throughput For Qfi Should Be Reached    ue_id=${UE_ID_FDD}    pdu_id=1    qfi_id=3
    ...    expected_throughput=20    unit=kbps    margin=0.2    direction=bi
    Perform Intracell Handover With Nr Sec Cap Defined And Wait For Confirmation    ue_id=${UE_ID_FDD}    nr_sec_cap=zuc|zuc    timeout=5
    Display Qfi stats    ue_id=20    qfi_id=3
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=0    enb_id=2    cell_id=3
    Expected Throughput For Qfi Should Be Reached    ue_id=${UE_ID_FDD}    pdu_id=1    qfi_id=3
    ...    expected_throughput=20    unit=kbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=${UE_ID_FDD}    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi
    Deregister Ue    ue_id=${UE_ID_FDD}