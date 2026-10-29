*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    keywords_CNI-86916.robot
Resource    ../resources/common_configuration.robot
Library     ../5GC000774_ROHC/keywords_ROHC.py
Library     ../resources/common_keywords.py
Documentation
...    author: Bartlomiej Urbanowicz
...    maintainer: Bartlomiej Urbanowicz (bartlomiej.urbanowicz@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    release: 23R4

Suite Setup    Run Keywords    Enable Inter Gnb Ho
...            AND    Start Xn And Ng Interfaces For Second Gnb
...            AND    Enable PDCP Status Handling

Test Setup      Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...         AND    Reach OnAir    lua_cfg=${CURDIR}/config/egate_2cc_2gNB_TDD.lua
    ...         AND    Set Internal Traffic Type To UEs

Test Teardown    Send Configuration ID To Scout
Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TRAFFIC_DURATION_SEC}=   10s
${HO_PARAM_GNB2}=    event=A5 srsrp_nr=19 srsrq_nr=10 phycell_id=50 nrsrp_nr=85 nrsrq_nr=50

*** Test Cases ***
CNI-86916_B9_SA_Intra_gNB_Intra_Cell_Handover_Security_Key_Refresh-PDCP_Re-establishment
    Register Ue With Default Pdu Session On Sim Gnb3
    Start 5Mbps Udp Dl And Ul Traffic
    Check DL And Ul Traffic
    Trigger Ue Reauthentication
    Start L1l2bip Mirroring
    Trigger Handover To Gnb 2
    Stop L1l2bip Mirroring
    Check DL And Ul Traffic
    Check First Missing Count From L1L2 bip log
    Deregister Ue    ue_id=1

*** Keywords ***
Register Ue With Default Pdu Session On Sim Gnb3
    Execute Egate Command    cmd=ue_change_location id=1 enb=3 cell=1
    ...                      pass_regexp=location updated to eNB-3 cell 1
    ...                      timeout=10
    Attach Ue    ue_id=1
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
    ...                      pass_regexp=UE-1 PDU SESSION ID-1 setup/reestablishment complete
    ...                      timeout=10

Add Item To UE History Information List
    Execute Egate Command    cmd=ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute Egate Command And Wait For Data    cmd=ue_history_information_list id=1 action=commit
    Execute Egate Command    cmd=ue_enb_param id=1 ue_history_list=1

Trigger Handover To Gnb 2
    Add Item To UE History Information List
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 ${HO_PARAM_GNB2}

Trigger Ue Reauthentication
    Execute Egate Command    cmd=ue_reauth id=1 nr_sec_cap=zuc|zuc
    ...                      pass_regexp=Reauthentication procedure is complete
    ...                      timeout=10

Start 5Mbps Udp Dl And Ul Traffic
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=5
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=5

Check DL And Ul Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1    expected_throughput=5    unit=mbps    margin=0.2    direction=dl
    Run Keyword And Continue On Failure    Check Number Of Total Packets Lost    ue_id=1
    ...    pdu_id=1    qfi_id=1    packet_loss=0    margin=1.0    direction=dl
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1    expected_throughput=5    unit=mbps    margin=0.2    direction=ul
    Run Keyword And Continue On Failure    Check Number Of Total Packets Lost    ue_id=1
    ...    pdu_id=1    qfi_id=1    packet_loss=0    margin=1.0    direction=ul






