*** Settings ***
#Force Tags   CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD    CLOUD_5G_I_BO_AP_KL_SA_FS_CPRI_CMWV_FDD
#...          CIT    SBTS00    SBTS21B    RAN_5G    RAN_5G_TDD    RAN_5G_FDD

Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Library     ../resources/common_keywords.py
Library     keywords_ROHC.py

Documentation
...    author: Anna Chabik
...    maintainer: Anna Chabik (anna.chabik@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 22R3

Test Setup      Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

Suite Setup    Run Keywords    Enable Vonr And Rohc
...            AND    Enable Syslog Debug Prints For Rohc

*** Variables ***
${TRAFFIC_DURATION_SEC}=   19s

*** Test Cases ***
Basic_1ue_ROHC
    Set Internal Traffic Type To UEs
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1   gw_id=1
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${ICS_SETUP_RESP_SUCCESS}
    Modify Pdu Session    ue_id=1    pdu_id=1    qos_to_add=2
    Modify Pdu Session    ue_id=1    pdu_id=1    qos_to_add=3
    Sleep    3s
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul rtp_codec=amr_wb_23_85
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Qfi stats    qfi_id=3
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=0    enb_id=2    cell_id=1
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=3
    ...    expected_throughput=20    unit=kbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi
    Deregister Ue    ue_id=1


