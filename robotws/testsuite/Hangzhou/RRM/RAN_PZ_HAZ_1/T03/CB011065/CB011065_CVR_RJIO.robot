*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB011065-SR CVR test in Reliance JIO configuration

Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource           ../../Resources/Classical/RRM_Common_Resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Run keywords    Common MultiBTS Suite Setup For RRM
...                AND    Update bsr package
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common MutliBTS Suite Teardown For RRM

Test Timeout       120 minutes

*** Variables ***
#Reduce global paramter as possilbe and automatically got from gNB or __init__

&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_4459}            faultId=${4459}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
&{fault_61616}           faultId=${61616}
&{fault_7529}            faultId=${7529}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_4459}    &{fault_8000}    &{fault_7300}
...    &{fault_61616}    &{fault_7529}

*** Test Cases ***
CB011065_CVR_04_Counter_Update_check_in_RJIO_configuration
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_O_E_AP_LOOO
    ...    Description:
    ...    This case aims to monitor CB011065-SR in RJIO configuration.
    [Setup]
    ...    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_RJIO_CVR
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sa
    Counter Collection CB011065
    Log To Console      ${\n}============= Subfeature -A inter-RAT HO with VoNR =============${\n}
    Set 5QI-5 and 5QI-1 as initial DRB
    ATTACH UE    UE_ID=1
    Start traffic on UE    UE_ID=1     TRAFFIC_RATE=5
    Trigger inter-RAT handover from NR to LTE    UE_ID=1
    DETTACH UE    UE_ID=1
    Log To Console      ${\n}============= Subfeature -A NG HO preparation failure counter =============${\n}
    ATTACH UE    UE_ID=2
    Start traffic on UE    UE_ID=2     TRAFFIC_RATE=5
    Trigger inter-gNB intra-freq HO preparation failure    UE_ID=2
    Trigger inter-gNB inter-freq HO preparation failure    UE_ID=2
    DETTACH UE    UE_ID=2
    Log To Console      ${\n}============= Subfeature -B Path Switch counter =============${\n}
    Modify gNB parameter to enable XnAP Handover
    ATTACH UE    UE_ID=3
    Start traffic on UE    UE_ID=3     TRAFFIC_RATE=5
    Trigger inter-gNB Xn handover    UE_ID=3
    Set Path Switch Failure Param    UE_ID=3
    Trigger inter-gNB Xn handover back to source    UE_ID=3
    DETTACH UE    UE_ID=3
    Log To Console      ${\n}============= Wait for counter update =============${\n}
    sleep    5 min
    Counter Check CB011065

*** Keywords ***
Update bsr package
    ${dllink}   Set Variable     https://artifactory-espoo1.int.net.nokia.com/artifactory/mnpute-rotta-local/BSR/
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     wget ${dllink}/${filename} -P /home/ute
    coam.setup admin
    ${ret}     coam.Update Software      /home/ute/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    coam.teardown admin

Counter Collection CB011065
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55144C00010;
    ...    Counter rule: max(M55144C00010)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55144C00011;
    ...    Counter rule: max(M55144C00011)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55144C00012;
    ...    Counter rule: max(M55144C00012)==1;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00001;
    ...    Counter rule: max(M55209C00001)==1;
    ${rule5}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00002;
    ...    Counter rule: max(M55209C00002)==1;
    ${rule6}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00009;
    ...    Counter rule: max(M55209C00009)==1;
    ${rule7}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00011;
    ...    Counter rule: max(M55209C00011)==1;
    ${rule8}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00013;
    ...    Counter rule: max(M55209C00013)==1;
    ${rule9}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00016;
    ...    Counter rule: max(M55209C00016)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}
    ...    ${rule6}    ${rule7}    ${rule8}    ${rule9}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter Check CB011065
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

Set 5QI-5 and 5QI-1 as initial DRB
    Log To Console      ${\n}============= Set 5QI-5 as Default DRB and setup 5QI-1 during ICS =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=qosflow_modify qos_flow=11 default=on
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=smf_param id=1 additional_qosflows_to_activate=1
    ...    pass_regexp=${None}
    sleep    1s

Reset SMF Param
    Log To Console      ${\n}============= Reset SMF Param =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=smf_param id=1 reset
    ...    pass_regexp=${None}
    sleep    1s

ATTACH UE
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Attach UE${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=${UE_ID}
    ...    pass_regexp=now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=${UE_ID} pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=${UE_ID} nwslice\=1 gw\=${UE_ID}
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s

DETTACH UE
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Detach UE${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_stop ue\=${UE_ID} pdu\=all
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_deregister id\=${UE_ID}
    ...    pass_regexp=${None}
    sleep    2s

Start traffic on UE
    [Arguments]    ${UE_ID}    ${TRAFFIC_RATE}
    Log To Console      ${\n}============= Start traffic on UE ${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${UE_ID} pdu\=1 qfi\=1 dir\=dl mbps\=${TRAFFIC_RATE}
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${UE_ID} pdu\=1 qfi\=1 dir\=ul mbps\=${TRAFFIC_RATE}
    ...    pass_regexp=${None}
    sleep    2s

Trigger inter-RAT handover from NR to LTE
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Trigger UE${UE_ID} A2 Measurement Report on CELL-1 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger UE${UE_ID} inter-RAT handover to LTE =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=6 event=B2 phycell_id=11 nrsrp_nr=19 nrsrq_nr=17
    ...    pass_regexp=IRAT Handover from NR to EUTRA completed
    sleep    3s

Trigger inter-gNB intra-freq HO preparation failure
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Trigger UE${UE_ID} A2 Measurement Report on CELL-1 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Set preparation failure cause as No radio resources =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id=1 action=ho_preparation_failure cause=RN_no_radio_resources_available_in_target_cell
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger UE${UE_ID} HO =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=3 event=A3 srsrp_nr=19 phycell_id=7 nrsrp_nr=100
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Reset preparation failure cause =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id=1 reset
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Set preparation failure cause as Invalid QoS Combination =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id=1 action=ho_preparation_failure cause=RN_invalid_qos_combination
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger UE${UE_ID} HO =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=3 event=A3 srsrp_nr=19 phycell_id=7 nrsrp_nr=100
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Reset preparation failure cause =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id=1 reset
    ...    pass_regexp=${None}
    sleep    1s

Trigger inter-gNB inter-freq HO preparation failure
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Set preparation failure cause as O&M intervention =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id=1 action=ho_preparation_failure cause=MISC_om_intervention
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger UE${UE_ID} HO =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=5 event=A3 srsrp_nr=19 phycell_id=8 nrsrp_nr=100
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Reset preparation failure cause =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id=1 reset
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Set preparation failure cause as other cause =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id=1 action=ho_preparation_failure cause=RN_insufficient_ue_capabilities
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger UE${UE_ID} HO =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=5 event=A3 srsrp_nr=19 phycell_id=8 nrsrp_nr=100
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Reset preparation failure cause =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id=1 reset
    ...    pass_regexp=${None}
    sleep    1s

Modify gNB parameter to enable XnAP Handover
    Log To Console      ${\n}============= Online enable XnAP handover =============${\n}
    [Documentation]    Enable XnAP Handover by modifying handoverAllowedSA to allowed
    @{para_list}   Create List    handoverAllowedSA    handoverAllowedSA
    @{value_list}   Create List   allowed    allowed
    @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-4
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Set Path Switch Failure Param
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Set Path Switch Failure Param =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_path_switch_param id=1 ue=${UE_ID} action=path_switch_failure cause=MISC_unspecified
    ...    pass_regexp=${None}
    sleep    1s

Trigger inter-gNB Xn handover
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Trigger UE${UE_ID} A3 Measurement Report and handover to target =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=3 event=A3 srsrp_nr=19 phycell_id=7 nrsrp_nr=100
    ...    pass_regexp=XN Handover Successfully completed
    sleep    3s

Trigger inter-gNB Xn handover back to source
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Trigger UE${UE_ID} A3 Measurement Report and handover back to CELL-1 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100
    ...    pass_regexp=${None}
    sleep    3s