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
...    author: Pawel Konieczny
...    maintainer: Pawel Konieczny (pawel.konieczny@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
...    release: 22R3

Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Enable AiC Vonr And Rohc

Test Teardown     Run Keywords    Deregister Ue   ue_id=1
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
${ROHC_PROFILES}=     (nr-rrc.profile0x0002 == 1) && (nr-rrc.profile0x0001 == 0) && (nr-rrc.profile0x0000 == 0)
${UE_CAPA_PROFIL_2}=    01A01080010900000004D0100389A000001E000000000000045400000000000005400000400801022280

*** Test Cases ***
5GC000774-A-EC1_Check_of_VoNR_and_ROHC_UE_capabilities_partial_support_by_the_UE_profile_2
    Attach Ue And Set Pdu Session
    #Trigger Radio Capability And Check Reqexp
    Start Dl And Ul Data Traffic For All Packet Stream
    Display Stats

*** Keywords ***
Attach Ue And Set Pdu Session
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_PROFIL_2}
    Attach One 5g Ue Capable Of Supporting Rohc

Start Dl And Ul Data Traffic For All Packet Stream
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl trf_id=1 rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul trf_id=2 rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl trf_id=3 kbps=30
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul trf_id=4 kbps=30
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl trf_id=5 kbps=30 protocol=tcp
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul trf_id=6 kbps=30 protocol=tcp

Display Stats
    Sleep    ${TRAFFIC_DURATION_SEC}
    Rohc Statistic Equal To Given Value    rohc_statistic_prefix=control_pdu_sent    mode=am    value=0    enb_id=2    cell_id=1
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=3
    ...    expected_throughput=100    unit=kbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi