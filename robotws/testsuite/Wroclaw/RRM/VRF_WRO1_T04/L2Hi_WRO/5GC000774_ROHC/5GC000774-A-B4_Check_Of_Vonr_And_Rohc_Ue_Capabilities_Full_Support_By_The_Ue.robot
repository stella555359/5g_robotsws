*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     keywords_ROHC.py
Documentation
...    author: Anna Chabik
...    maintainer: Anna Chabik (anna.chabik@nokia.com)
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
${ROHC_PROFILES}=    ((nr-rrc.profile0x0000 == 1) && (nr-rrc.profile0x0002 == 1)) && (nr-rrc.profile0x0001 == 1)
${UE_ID_TDD}=    1
${UE_ID_FDD}=    20
${CELL_ID_FDD}=   3

*** Test Cases ***
5GC000774-A-B4_Check_Of_Vonr_And_Rohc_Ue_Capabilities_Full_Support_By_The_Ue_TDD
    Attach One 5g Ue Capable Of Supporting Rohc
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${ROHC_PROFILES}
    #Trigger Radio Capability And Check Reqexp
    Start Dl And Ul Data Traffic For All Packet Stream
    Display Stats
    Deregister Ue    ${UE_ID_TDD}

5GC000774-A-B4_Check_Of_Vonr_And_Rohc_Ue_Capabilities_Full_Support_By_The_Ue_FDD
    Attach One 5g Ue Capable Of Supporting Rohc    ${UE_ID_FDD}
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${ROHC_PROFILES}
    #Trigger Radio Capability And Check Reqexp
    Start Dl And Ul Data Traffic For All Packet Stream    ${UE_ID_FDD}
    Display Stats    ${UE_ID_FDD}    ${CELL_ID_FDD}
    Deregister Ue    ${UE_ID_FDD}

*** Keywords ***
Start Dl And Ul Data Traffic For All Packet Stream
    [Arguments]    ${UE_ID}=${1}
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=dl trf_id=1 rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=ul trf_id=2 rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=dl trf_id=3 kbps=30
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=ul trf_id=4 kbps=30
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=dl trf_id=5 kbps=30 protocol=tcp
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=ul trf_id=6 kbps=30 protocol=tcp

Display Stats
    [Arguments]    ${UE_ID}=${1}    ${CELL_ID}=${1}
    Sleep    ${TRAFFIC_DURATION_SEC}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=650    enb_id=2    cell_id=${CELL_ID}
    Expected Throughput For Qfi Should Be Reached    ue_id=${UE_ID}    pdu_id=1    qfi_id=3
    ...    expected_throughput=100    unit=kbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=${UE_ID}    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi
