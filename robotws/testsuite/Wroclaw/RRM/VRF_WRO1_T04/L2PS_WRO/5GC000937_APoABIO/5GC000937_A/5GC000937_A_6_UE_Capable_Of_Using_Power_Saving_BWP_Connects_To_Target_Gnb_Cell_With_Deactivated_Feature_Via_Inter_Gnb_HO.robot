*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGS_L2PS_WRO/LO_APoABIO/1_CELL_SA_TDD_5GC000937_ACTIVATED/iphy_and_scfc.yaml
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00    SBTS22R4    SBTS23R1

Documentation    :copyright: Nokia
...              :authors: Anna Roskosz
...              :contact: anna.roskosz@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Resource     5GC000937_variables.robot
Library      ../../resources/Python/webem_alarms.py
Library      5GC000937_keywords.py

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Start Xn And Ng Interfaces
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_1c_2_gnb_SA.lua
    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
    ...          AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC000937_A_6_UE_Capable_Of_Using_Power_Saving_BWP_Connects_To_Target_Gnb_Cell_With_Deactivated_Feature_Via_Inter_Gnb_HO
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=actPowerSavingBWP    value=false
    Wait For Sib1 Reception
    Trigger Xn Setup Request
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Verify Tcpdump Log       packet_filter=${UE_CONTEXT_SETUP_REQUEST_BWP_SWITCHING_DELAY}
    Verify Tcpdump Log       packet_filter=${UE_CONTEXT_SETUP_REQUEST_BWP_SAME_NUMEROLOGY}
    Verify Tshark For No Messages
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    packet_filter=${RRC_RECONFIGURATION_PDCCH_TDRA_K0_6}
    ${meas_id}=  Get Measurement Id    EventA5   ue_id=1
    Send Custom UE Measurement NR  id=1 meas_id=${meas_id} index=0 nrs_result=101:101:0 event=A5 phycell_id=127 nrsrp_nr=30 srsrp_nr=11 srsrq_nr=11
    ...                            pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ...                            timeout=10
    Add Item To UE History Information List    gnb_id=3
    ${meas_id}=  Get Measurement Id    EventA5   ue_id=1
    Send Custom UE Measurement NR  id=1 meas_id=${meas_id} event=A5 srsrp_nr=1 srsrq_nr=10 phycell_id=50 nrsrp_nr=85 nrsrq_nr=101
    ...                            pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    ...                            timeout=20
    Verify Tcpdump Log       packet_filter=${UE_CONTEXT_SETUP_REQUEST_BWP_SWITCHING_DELAY}    number_of_messages=2
    Verify Tcpdump Log       packet_filter=${UE_CONTEXT_SETUP_REQUEST_BWP_SAME_NUMEROLOGY}    number_of_messages=2
    Verify Tshark For No Messages
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    packet_filter=${RRC_RECONFIGURATION_PDCCH_TDRA_K0_6}

*** Keywords ***
Start Xn And Ng Interfaces
    Start Vm Ethernet Interface    if_name=eth3:xn    ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.102/24

Add Item To UE History Information List
    [Arguments]  ${gnb_id}
    Execute Egate Command
    ...  cmd=ue_history_information_list_add_ngran id=1 gnb_id=${gnb_id} cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute Egate Command
    ...  cmd=ue_history_information_list id=1 action=commit
    Execute Egate Command
    ...  cmd=ue_enb_param id=1 ue_history_list=1

Trigger Xn Setup Request
    Execute Egate Command    cmd=xn_gnb_link_up gnb=3 target=2
    Sleep    5s    Ensure Xn Setup Request Is Sent
    Execute Egate Command    cmd=xn_gnb_link_up gnb=3 target=2

Get Measurement Id
    [Arguments]  ${event_type}=EventA3  ${ue_id}=1  ${matching_line}=0
    ${measurements}=    Execute Egate Command And Wait For Data    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=${event_type}  timeout=10s
    ${matching_lines}=  Get Lines Containing String  ${measurements}  ${event_type}
    ${first_line}=  Get Line  ${matching_lines}  ${matching_line}
    @{words}=  Split String  ${first_line}
    Log to console  MeasId: ${words}[0] for event: ${words}[2] found for RAT: ${words}[1]
    [Return]  ${words}[0]
