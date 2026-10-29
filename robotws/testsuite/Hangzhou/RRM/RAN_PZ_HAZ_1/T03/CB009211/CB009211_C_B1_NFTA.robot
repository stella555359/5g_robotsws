*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB009211-SR ET -C NFTA in Reliance JIO configuration

# Resource           ../Resources/common_resource.robot
# Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
# Resource           ../../Resources/Classical/RRM_Common_Resource.robot
# Resource           ../../Resources/Common/Airphone.robot
# Suite Setup        Run keywords    Common MultiBTS Suite Setup For RRM
# ...                AND    Update bsr package
# Test Setup         Common MultiBTS Test Setup For RRM
# Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
# ...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
# Suite Teardown     Common MutliBTS Suite Teardown For RRM

# Test Timeout       120 minutes

# *** Variables ***
# #Reduce global paramter as possilbe and automatically got from gNB or __init__
# ${cmd1}    ue_measurement_send_nr
# ...    id=1 meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7 srs_result=0:7:7:0 phycell_id=50
# ...    nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0

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
# CB009211-C_02_Too Late HO when inter-gNB HO is NOT in progress with CB012121
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_O_E_AP_LOOO
#     ...    Description:
#     ...    This case aims to monitor counter update for CB009211-SR-C late handover scenario.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_CA_C_CB012121
#     ...    base_path=${CURDIR}/APCFG
#     ...    call_type=sa
#     # 1st round, do not send gNB-2 Cell-2 A3 measurement
#     Counter Collection CB009211 FIM CB012121
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
#     Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Trigger A2 Measurement Report =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd1}
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Trigger A3 Measurement Report of gNB-3 Cell-1 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=52 nrsrp_nr\=100
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Trigger RRE to same gNB-2 CELL-2 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_rrc_reestablish id\=1 gnb\=2 cell\=2 cause\=otherFailure
#     ...    pass_regexp=NR RRC Reestablishment sucessfully completed
#     sleep    3s
#     Log To Console      ${\n}============= Stop Traffic and detach UE =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=trf_data_stop ue\=1 pdu\=all
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_deregister id\=1 ue_deregister_type\=switch_off
#     ...    pass_regexp=${None}
#     sleep    3s
#     # 2nd round, send gNB-2 Cell-2 A3 measurement
#     Log To Console      ${\n}============= Start to Attach the UE =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_change_location id\=1 enb\=2 cell\=1
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
#     ...    pass_regexp=UE NGAP ID 2 is now Registered
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
#     ...    pass_regexp=Initial Context Setup Successful
#     sleep    3s
#     Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Trigger A2 Measurement Report =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd1}
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Trigger A3 Measurement Report of gNB-2 Cell-2 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id=1 meas_id=6 event=A3 srsrp_nr=19 phycell_id=61 nrsrp_nr=100
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Trigger RRE to same gNB CELL-2 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_rrc_reestablish id\=1 gnb\=2 cell\=2 cause\=otherFailure
#     ...    pass_regexp=NR RRC Reestablishment sucessfully completed
#     sleep    3s
#     Log To Console      ${\n}============= Stop Traffic and detach UE =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=trf_data_stop ue\=1 pdu\=all
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Wait for counters =============${\n}
#     Sleep    5 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check counters =============${\n}
#     Counter Check CB009211

# CB009211-C_05_Too Late HO when inter-gNB HO is NOT in progress with unknown UE context
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_O_E_AP_LOOO
#     ...    Description:
#     ...    This case aims to monitor counter update for CB009211-SR-C late handover scenario.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_RJO_C
#     ...    base_path=${CURDIR}/APCFG
#     ...    call_type=sa
#     Counter Collection CB009211
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
#     Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Trigger A2 Measurement Report =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd1}
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Trigger RRE to same gNB CELL-2, but without UE context =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_rrc_reestablish id\=1 gnb\=2 cell\=2 cause\=otherFailure action\=invalid_short_mac_i
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Wait for counters =============${\n}
#     Sleep    5 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check counters =============${\n}
#     Counter Check CB009211

# CB009211-C_04_Too Late HO when inter-gNB HO is NOT in progress with unknown cell
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_O_E_AP_LOOO
#     ...    Description:
#     ...    This case aims to monitor counter update for CB009211-SR-C late handover scenario.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_RJO_C
#     ...    base_path=${CURDIR}/APCFG
#     ...    call_type=sa
#     Counter Collection CB009211
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
#     Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Trigger RRE to CELL-3, which has no NRREL configured on CELL-1 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_rrc_reestablish id\=1 gnb\=2 cell\=3 cause\=otherFailure
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Wait for counters =============${\n}
#     Sleep    5 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check counters =============${\n}
#     Counter Check CB009211

# CB009211-C_06_Too Late HO when intra-gNB HO is NOT in progress with reconfigFailure or handoverFailure
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_O_E_AP_LOOO
#     ...    Description:
#     ...    This case aims to monitor counter update for CB009211-SR-C late handover scenario.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_RJO_C
#     ...    base_path=${CURDIR}/APCFG
#     ...    call_type=sa
#     Counter Collection CB009211
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
#     Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Trigger RRE to CELL-2 with Handover Failure =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_rrc_reestablish id\=1 gnb\=2 cell\=2 cause\=handoverFailure
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Wait for counters =============${\n}
#     Sleep    5 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check counters =============${\n}
#     Counter Check CB009211

# CB009211-C_07_Too Late HO when intra-gNB HO is NOT in progress with A1 Pcell Switch
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_I_MP_AP_LO
#     ...    Description:
#     ...    This case aims to monitor counter update for CB009211-SR-C late handover scenario.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_CA_2CC_C
#     ...    base_path=${CURDIR}/APCFG
#     ...    call_type=sa
#     Counter Collection CB009211
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
#     Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Add Scell-1 through A1 Measurement Report =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=4 event\=A1 srsrp_nr\=50
#     ...    pass_regexp=SCellIndex 1 activated successfully at airphone
#     sleep    3s
#     Log To Console      ${\n}============= Trigger RRE to S-Cell with Other Failure =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_rrc_reestablish id\=1 gnb\=2 cell\=2 cause\=otherFailure
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Wait for counters =============${\n}
#     Sleep    5 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check counters =============${\n}
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
#     ...    Counter: M55142C00529;
#     ...    Counter rule: sum(M55142C00529)==0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55142C00527;
#     ...    Counter rule: sum(M55142C00527)==0;
#     ${rule_list}    Create List    ${rule1}     ${rule2}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}

# Counter Collection CB009211 FIM CB012121
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55142C00529;
#     ...    Counter rule: sum(M55142C00529)==2;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55142C00527;
#     ...    Counter rule: sum(M55142C00527)==0;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55200C00003;
#     ...    Counter rule: sum(M55200C00003)==2;
#     ${rule4}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55200C00001;
#     ...    Counter rule: sum(M55200C00001)==0;
#     ${rule_list}    Create List    ${rule1}     ${rule2}    ${rule3}    ${rule4}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}

# Counter Check CB009211
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}