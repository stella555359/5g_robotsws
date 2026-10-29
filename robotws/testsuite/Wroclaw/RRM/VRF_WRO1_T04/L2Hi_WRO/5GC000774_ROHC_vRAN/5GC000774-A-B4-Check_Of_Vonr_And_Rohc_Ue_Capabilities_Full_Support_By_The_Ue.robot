*** Settings ***
Resource     ../resources/common_keywords.robot
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_variables.robot
Variables     ../resources/common_variables_vran.py
Library     ../resources/common_keywords.py
Library     ../resources/common_keywords_vran.py
Library     ../5GC000774_ROHC/keywords_ROHC.py
Library     ../resources/pm_counters_validator_vran.py
Documentation
...    author: Anna Chabik
...    maintainer: Anna Chabik (anna.chabik@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
...    release: 22R3

Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Enable AiC Vonr And Rohc

Test Teardown     Run Keywords    Deregister Ue   ue_id=1
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
${ROHC_PROFILES}=    ((nr-rrc.profile0x0000 == 1) && (nr-rrc.profile0x0002 == 1)) && (nr-rrc.profile0x0001 == 1)

*** Test Cases ***
5GC000774-A-B4_Check_Of_Vonr_And_Rohc_Ue_Capabilities_Full_Support_By_The_Ue
    Attach One 5g Ue Capable Of Supporting Rohc
    #Trigger Radio Capability And Check Reqexp
    Start Dl And Ul Data Traffic For All Packet Stream
    Display Stats

*** Keywords ***
Start Dl And Ul Data Traffic For All Packet Stream
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl trf_id=1 rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul trf_id=2 rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl trf_id=3 kbps=30
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul trf_id=4 kbps=30
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl trf_id=5 kbps=30 protocol=tcp
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul trf_id=6 kbps=30 protocol=tcp

Display Stats
    Sleep    ${TRAFFIC_DURATION_SEC}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=650    enb_id=2    cell_id=1
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=3
    ...    expected_throughput=80    unit=kbps    margin=0.2    direction=dl
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=3
    ...    expected_throughput=80    unit=kbps    margin=0.2    direction=ul
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=dl
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=ul