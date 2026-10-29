*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB009211-SR ET -D NFTA in Reliance JIO configuration

# Resource           ../Resources/common_resource.robot
# Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
# Resource           ../../Resources/Classical/RRM_Common_Resource.robot
# Resource           ../../Resources/Common/Airphone.robot
# Suite Setup        Run keywords    Common MultiBTS Suite Setup For RRM
# ...                AND    Update bsr package
# # Test Setup         Common MultiBTS Test Setup For RRM
# Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
# ...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
# Suite Teardown     Common MutliBTS Suite Teardown For RRM

# Test Timeout       120 minutes

# *** Variables ***
# #Reduce global paramter as possilbe and automatically got from gNB or __init__
# ${cmd1}    ue_measurement_send_nr
# ...    id=1 meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7 srs_result=0:7:7:0 phycell_id=60 nrsrp_nr=30 nrsrq_nr=30
# ...    rs_type=ssb index=0 nrs_result=30:30:0

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
# CB009211-D_02_Ping-pong HO detection for intra-gNB with 3cells
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_O_E_AP_LOOO
#     ...    Description:
#     ...    This case aims to monitor counter update for CB009211-SR-D ping-pong handover scenario.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_D_B1
#     ...    base_path=${CURDIR}/APCFG
#     ...    call_type=sa
#     Counter Collection CB009211
#     ATTACH UE1
#     Start DL Traffic on UE
#     Trigger Handover to CELL-2
#     Trigger Handover to CELL-3
#     Trigger Handover back to CELL-1
#     Counter Check CB009211

# CB009211-D_03_Ping-pong HO detection for intra-gNB with tPingPong expired
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_O_E_AP_LOOO
#     ...    Description:
#     ...    This case aims to monitor counter update for CB009211-SR-D ping-pong handover scenario with timer expiration
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_D_B1
#     ...    base_path=${CURDIR}/APCFG
#     ...    call_type=sa
#     Counter Collection CB009211 EC
#     ATTACH UE1
#     Start DL Traffic on UE
#     Trigger Handover to CELL-2
#     Log To Console      ${\n}============= Trigger ping-pong timer expiration =============${\n}
#     sleep    25s
#     Trigger Handover to CELL-1
#     Counter Check CB009211

# CB009211-D_04_Ping-pong HO detection for intra-gNB with A1 Pcell Switch
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_I_MP_AP_LO
#     ...    Description:
#     ...    This case aims to monitor counter update for CB009211-SR-D ping-pong handover scenario with P-Cell Switch
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_D_B1_CA
#     ...    base_path=${CURDIR}/APCFG
#     ...    call_type=sa
#     Counter Collection CB009211 EC
#     ATTACH UE1
#     Start DL Traffic on UE
#     Trigger Handover to S-Cell
#     Trigger S-Cell Addition
#     Trigger P-Cell Switch to CELL-1
#     Counter Check CB009211

# *** Keywords ***
# Update bsr package
#     ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
#     ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
#     Run     wget ${dllink}/${filename} -P /home/ute
#     coam.setup admin
#     ${ret}     coam.Update Software      /home/ute/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
#     coam.teardown admin

# Counter Collection CB009211
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55142C00535;
#     ...    Counter rule: sum(M55142C00535)==1;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-2;
#     ...    Counter: M55142C00535;
#     ...    Counter rule: sum(M55142C00535)==0;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-3;
#     ...    Counter: M55142C00535;
#     ...    Counter rule: sum(M55142C00535)==0;
#     ${rule_list}    Create List    ${rule1}     ${rule2}    ${rule3}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}

# Counter Collection CB009211 EC
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55142C00535;
#     ...    Counter rule: sum(M55142C00535)==0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-2;
#     ...    Counter: M55142C00535;
#     ...    Counter rule: sum(M55142C00535)==0;
#     ${rule_list}    Create List    ${rule1}     ${rule2}
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

# Trigger Handover to CELL-2
#     Log To Console      ${\n}============= Trigger A3 Measurement Report and handover to CELL-2 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=100 nrsrq_nr=30
#     ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
#     sleep    3s

# Trigger Handover to CELL-3
#     Log To Console      ${\n}============= Trigger A3 Measurement Report and handover to CELL-3 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52 nrsrp_nr=100 nrsrq_nr=30
#     ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.3 performed
#     sleep    3s

# Trigger Handover back to CELL-1
#     Log To Console      ${\n}============= Trigger A3 Measurement Report and handover to CELL-1 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=100 nrsrq_nr=30
#     ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.1 performed
#     Log To Console      ${\n}============= Handover is done, wait for counter update =============${\n}
#     sleep    5 min    reason=wait for counter ready

# Trigger Handover to CELL-1
#     Log To Console      ${\n}============= Trigger A3 Measurement Report and handover to CELL-1 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=100 nrsrq_nr=30
#     ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
#     Log To Console      ${\n}============= Handover is done, wait for counter update =============${\n}
#     sleep    5 min    reason=wait for counter ready

# Trigger Handover to S-Cell
#     Log To Console      ${\n}============= Trigger A2 Measurement Report on CELL-1 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd1}
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Trigger A3 Measurement Report and Handover to CELL-2 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=6 event\=A3 srsrp_nr\=19 phycell_id\=61 nrsrp_nr\=100
#     ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
#     sleep    3s

# Trigger S-Cell Addition
#     Log To Console      ${\n}============= Trigger A1 Measurement Report to add S-Cell =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=11 event\=A1 srsrp_nr\=50
#     ...    pass_regexp=SCellIndex 1 activated successfully at airphone
#     sleep    3s

# Trigger P-Cell Switch to CELL-1
#     Log To Console      ${\n}============= Trigger A1 Measurement Report and P-Cell swtich =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=12 event\=A1 srsrp_nr\=50 scell\=1 scell_rsrp\=80
#     ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
#     Log To Console      ${\n}============= P-Cell Switch is done, wait for counter update =============${\n}
#     sleep    5 min    reason=wait for counter ready
