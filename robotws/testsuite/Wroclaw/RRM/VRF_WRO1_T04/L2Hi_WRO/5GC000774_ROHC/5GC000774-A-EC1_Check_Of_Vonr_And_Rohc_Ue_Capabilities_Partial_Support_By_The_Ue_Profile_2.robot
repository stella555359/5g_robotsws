*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     keywords_ROHC.py
Documentation
...    author: Pawel Konieczny
...    maintainer: Pawel Konieczny (pawel.konieczny@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 22R3

Suite Setup     Run Keywords    Prepare Sa Test Environement And Reach Onair
...               perform_tl_reset=${RESET_TL}
...               cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
...               cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
...               cfg_filepath_tdd_fdd=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
...            AND    Enable Vonr And Rohc
...            AND    Enable Syslog Debug Prints For Rohc

Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

Test Teardown    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
${ROHC_PROFILES}=     (nr-rrc.profile0x0002 == 1) && (nr-rrc.profile0x0001 == 0) && (nr-rrc.profile0x0000 == 0)
${UE_CAPA_PROFIL_2}=    01A01080010900000004D0100389A000001E000000000000045400000000000005400000400801022280

*** Test Cases ***
5GC000774-A-EC1_Check_Of_Vonr_And_Rohc_Ue_Capabilities_Partial_Support_By_The_Ue_Profile_2
    Attach Ue And Set Pdu Session
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${ROHC_PROFILES}
    #Trigger Radio Capability And Check Reqexp
    Start Dl And Ul Data Traffic For All Packet Stream
    Display Stats
    Deregister Ue    ue_id=1

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
