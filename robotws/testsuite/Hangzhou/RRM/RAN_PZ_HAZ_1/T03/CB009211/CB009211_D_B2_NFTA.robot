*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is the script for CB009211-D_B2 NFTA.
...   Test ENV: CLOUD_5G_I_[LO][LO]_AP_[LOO]

# Resource           ../Resources/common_resource.robot
# Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
# Resource           ../../Resources/Classical/RRM_Common_Resource.robot
# Resource           ../../Resources/Common/Airphone.robot
# Suite Setup        Common Suite Setup For RRM
# Test Setup         Common Test Setup For RRM
# Test Teardown      Run Keywords    Case Postcondition    AND
# ...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
# Suite Teardown     Common Suite Teardown For RRM

# Test Timeout       120 minutes

# *** Variables ***
# ${cmd1}    ue_history_information_list_add_ngran
# ...    id=1 gnb_id=2 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=30
# ...    time_ue_stayed_in_cell_enchanced_granularity=304 cause=RN_handover_desirable_for_radio_reason
# ${cmd2}    ue_history_information_list_add_ngran
# ...    id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x05 time_ue_stayed_in_cell=30
# ...    time_ue_stayed_in_cell_enchanced_granularity=304 cause=RN_handover_desirable_for_radio_reason
# ${cmd3}    ue_history_information_list_add_eutran
# ...    id=1 cell_type=medium ecgi=311:489|0x01 time_ue_stayed_in_cell=30 time_ue_stayed_in_cell_enchanced_granularity=304
# ...    s1_ho_cause_rnl=time_critical_handover

# &{fault_4334}            faultId=${4334}
# &{fault_4293}            faultId=${4293}
# &{fault_61510}           faultId=${61510}
# &{fault_4459}            faultId=${4459}
# &{fault_8000}            faultId=${8000}
# &{fault_7300}            faultId=${7300}
# &{fault_61616}           faultId=${61616}
# &{fault_7529}            faultId=${7529}
# @{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_4459}    &{fault_8000}    &{fault_7300}
# ...    &{fault_61616}    &{fault_7529}

# *** Test Cases ***
# CB009211-D_01_Ping-pong HO detection for inter-gNB Xn
#     Case Precondition
#     Counter Collection CB009211-D-B2-IRAT
#     ATTACH UE1
#     Start DL Traffic on UE
#     Trigger Xn Handover to GNB-2
#     Trigger Xn Handover to GNB-1
#     Counter Check CB009211

# CB009211-D_02_Ping-pong HO detection for inter-gNB Xn including interRat
#     Case Precondition
#     Counter Collection CB009211-D-B2-IRAT
#     Commit UE history information
#     ATTACH UE1
#     Start DL Traffic on UE
#     Trigger Xn Handover to GNB-2
#     Trigger inter-RAT Handover to LTE
#     Trigger inter-RAT Handover back to 5G
#     Counter Check CB009211

# CB009211-D_05_Ping-pong HO detection for inter-gNB Xn with A1 Pcell Switch
#     Case Precondition P-Cell Switch
#     Counter Collection CB009211-D-B2 EC
#     ATTACH UE1
#     Start DL Traffic on UE
#     Trigger S-Cell addition
#     Trigger P-Cell Switch
#     Trigger Xn Handover to GNB-2 CELL-5
#     Trigger Xn Handover to GNB-1 CELL-1
#     Counter Check CB009211

# *** Keywords ***
# Case Precondition
#     Airphone Operation    operation=edaemon_egate_setup
#     ...                   product_type=${None}
#     ...                   traffic_info_dic=${None}
#     ...                   tag=${None}
#     ...                   cmd=${None}
#     ...                   pass_regexp=${None}
#     ...                   timeout=100s
#     Airphone Operation    operation=env_setup_sa
#     ...                   product_type=gnb
#     ...                   traffic_info_dic=${None}
#     ...                   tag=D_IRAT
#     ...                   cmd=${None}
#     ...                   pass_regexp=${None}
#     ...                   timeout=1800s

# Case Precondition P-Cell Switch
#     Airphone Operation    operation=edaemon_egate_setup
#     ...                   product_type=${None}
#     ...                   traffic_info_dic=${None}
#     ...                   tag=${None}
#     ...                   cmd=${None}
#     ...                   pass_regexp=${None}
#     ...                   timeout=100s
#     Airphone Operation    operation=env_setup_sa
#     ...                   product_type=gnb
#     ...                   traffic_info_dic=${None}
#     ...                   tag=D_Pcell_Switch
#     ...                   cmd=${None}
#     ...                   pass_regexp=${None}
#     ...                   timeout=1800s

# Case Postcondition
#     Airphone Operation    operation=edaemon_egate_teardown
#     ...                   product_type=${None}
#     ...                   traffic_info_dic=${None}
#     ...                   tag=${None}
#     ...                   cmd=${None}
#     ...                   pass_regexp=${None}
#     ...                   timeout=200s

# Counter Collection CB009211-D-B2-IRAT
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55142C00535;
#     ...    Counter rule: sum(M55142C00535)==1;
#     ${rule_list}    Create List    ${rule1}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}

# Counter Collection CB009211-D-B2 EC
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55142C00535;
#     ...    Counter rule: sum(M55142C00535)==0;
#     ${rule_list}    Create List    ${rule1}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}

# Counter Check CB009211
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}

# ATTACH UE1
#     Log To Console      ${\n}============= Start to Attach the UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
#     ...    pass_regexp=UE NGAP ID 1 is now Registered
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
#     ...    pass_regexp=Initial Context Setup Successful
#     sleep    3s

# Start DL Traffic on UE
#     Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s

# Trigger Xn Handover to GNB-2
#     Log To Console      ${\n}============= Trigger A2 Measurement Report on CELL-1 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 srsrp_nr\=11 srsrq_nr\=11 srs_result\=0:11:11:0
#     ...    pass_regexp=${None}
#     sleep    1s
#     Log To Console      ${\n}============= Trigger A3 Measurement Report and handover to CELL-5 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=5 event\=A3 srsrp_nr\=19 phycell_id\=54 nrsrp_nr\=100
#     ...    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to EXT_ENB-3.5 performed
#     sleep    3s

# Trigger Xn Handover to GNB-1
#     Log To Console      ${\n}============= Trigger A2 Measurement Report on CELL-5 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=8 event\=A2 srsrp_nr\=11 srsrq_nr\=11 srs_result\=0:11:11:0
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Trigger A3 Measurement Report and handover to CELL-1 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=13 event\=A3 srsrp_nr\=19 phycell_id\=50 nrsrp_nr\=100
#     ...    pass_regexp=Inter-eNB handover from EXT_ENB-3.5 to EXT_ENB-2.1 performed
#     Log To Console      ${\n}============= Handover is done, wait for counter update =============${\n}
#     sleep    5 min    reason=wait for counter ready

# Trigger inter-RAT Handover to LTE
#     Log To Console      ${\n}============= Trigger A2 Measurement Report on CELL-5 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=8 event\=A2 srsrp_nr\=11 srsrq_nr\=11 srs_result\=0:11:11:0
#     ...    pass_regexp=${None}
#     sleep    1s
#     Log To Console      ${\n}============= Trigger B2 Measurement Report and handover to LTE =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=14 event\=B2 phycell_id\=11 nrsrp_nr\=19 nrsrq_nr\=17
#     ...    pass_regexp=IRAT Handover from NR to EUTRA completed
#     sleep    2s

# Trigger inter-RAT Handover back to 5G
#     Log To Console      ${\n}============= Trigger Handover back to 5G CELL-1 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=gnb_trigger_inter_rat_handover_to_5g ue\=1 target_gnb\=2 target_cell\=1 plmn\=311:489
#     ...    pass_regexp=Inter-eNB handover
#     sleep    2s
#     Log To Console      ${\n}============= Handover is done, wait for counter update =============${\n}
#     sleep    5 min    reason=wait for counter ready

# Trigger Xn Handover to GNB-1 after inter-RAT HO
#     Log To Console      ${\n}============= Trigger A2 Measurement Report on CELL-5 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 srsrp_nr\=11 srsrq_nr\=11 srs_result\=0:11:11:0
#     ...    pass_regexp=${None}
#     sleep    1s
#     Log To Console      ${\n}============= Trigger A3 Measurement Report and handover to CELL-1 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=6 event\=A3 srsrp_nr\=19 phycell_id\=50 nrsrp_nr\=100
#     ...    pass_regexp=Inter-eNB handover from EXT_ENB-3.5 to EXT_ENB-2.1 performed
#     sleep    2s
#     Log To Console      ${\n}============= Handover is done, wait for counter update =============${\n}
#     sleep    5 min    reason=wait for counter ready

# Trigger S-Cell addition
#     Log To Console      ${\n}============= Trigger A1 Measurement Report to add S-Cell =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=4 event\=A1 srsrp_nr\=50
#     ...    pass_regexp=SCellIndex 1 activated successfully at airphone
#     sleep    2s

# Trigger P-Cell Switch
#     Log To Console      ${\n}============= Trigger A1 Measurement Report and P-Cell swtich =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=5 event\=A1 srsrp_nr\=50 scell\=1 scell_rsrp\=80
#     ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
#     sleep    2s

# Trigger Xn Handover to GNB-2 CELL-5
#     Log To Console      ${\n}============= Trigger A2 Measurement Report on CELL-2 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=6 event\=A2 srsrp_nr\=11 srsrq_nr\=11 srs_result\=0:11:11:0
#     ...    pass_regexp=${None}
#     sleep    1s
#     Log To Console      ${\n}============= Trigger A3 Measurement Report and Handover to CELL-5 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=10 event\=A3 srsrp_nr\=19 phycell_id\=54 nrsrp_nr\=100
#     ...    pass_regexp=Inter-eNB handover from EXT_ENB-2.2 to EXT_ENB-3.5 performed
#     sleep    3s

# Trigger Xn Handover to GNB-1 CELL-1
#     Log To Console      ${\n}============= Trigger A2 Measurement Report on CELL-5 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=11 event\=A2 srsrp_nr\=11 srsrq_nr\=11 srs_result\=0:11:11:0
#     ...    pass_regexp=${None}
#     sleep    1s
#     Log To Console      ${\n}============= Trigger A3 Measurement Report and Handover to CELL-1 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=16 event\=A3 srsrp_nr\=19 phycell_id\=50 nrsrp_nr\=100
#     ...    pass_regexp=Inter-eNB handover from EXT_ENB-3.5 to EXT_ENB-2.1 performed
#     Log To Console      ${\n}============= Handover is done, wait for counter update =============${\n}
#     sleep    5 min    reason=wait for counter ready

# Commit UE history information
#     Log To Console      ${\n}============= Commit UE history information =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd1}
#     ...    pass_regexp=${None}
#     sleep    1s
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd2}
#     ...    pass_regexp=${None}
#     sleep    1s
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd3}
#     ...    pass_regexp=${None}
#     sleep    1s
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_history_information_list id=1 action=commit
#     ...    pass_regexp=${None}
#     sleep    1s
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_enb_param id=1 ue_history_list=1
#     ...    pass_regexp=${None}
#     sleep    1s
