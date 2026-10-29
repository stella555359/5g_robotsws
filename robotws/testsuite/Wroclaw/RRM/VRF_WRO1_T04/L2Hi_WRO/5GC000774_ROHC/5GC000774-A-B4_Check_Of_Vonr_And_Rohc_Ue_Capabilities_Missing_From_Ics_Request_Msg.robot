*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     keywords_ROHC.py
Documentation
...    author: Bartosz Wlodowski, Anna Chabik
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 22R3

Suite Setup     Run Keywords    Prepare Sa Test Environement And Reach Onair
...               perform_tl_reset=${RESET_TL}
...               cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
...               cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
...               cfg_filepath_tdd_fdd=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
...            AND    Enable Vonr And Rohc
...            AND    Enable Syslog Debug Prints For Rohc

Test Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs
...            AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
${ROHC_PROFILES}=    ((nr-rrc.profile0x0000 == 1) && (nr-rrc.profile0x0002 == 1)) && (nr-rrc.profile0x0001 == 1)

*** Test Cases ***
5GC000774-A-B4_Check_Of_Vonr_And_Rohc_Ue_Capabilities_Missing_From_Ics_Request_Msg
    Set Internal Traffic Type To UEs
    Attach Ue And Set Pdu Session
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${ROHC_PROFILES}
    #Trigger Radio Capability And Check Reqexp
    Start Dl And Ul Data Traffic For All Packet Stream
    Display Stats
    Deregister Ue    ue_id=1

*** Keywords ***
Attach Ue And Set Pdu Session
    Attach Ue    ue_id=1
    Execute Egate Command    cmd=amf_ue_ics_param id=1 ue=1 include_ue_capabilities=off
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${ICS_SETUP_RESP_SUCCESS}
    Sleep    3s   Waiting for procedure complete
    Modify Pdu Session And Wait For Regexp    qos_id=2    qfi_id=2    5qi_id=5
    Modify Pdu Session And Wait For Regexp    qos_id=3    qfi_id=3    5qi_id=1

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
    ...    expected_throughput=100    unit=kbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi
