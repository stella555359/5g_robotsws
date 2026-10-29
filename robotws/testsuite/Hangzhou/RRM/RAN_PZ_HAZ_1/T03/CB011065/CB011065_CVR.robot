*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB011065-SR CVR in TMO configuration

Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource           ../../Resources/Classical/RRM_Common_Resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Run keywords    Common MultiBTS Suite Setup For RRM
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

${Ignore_Cell_Id_For_Sib}    5    6    9    12

*** Test Cases ***
CB011065_CVR_01_TMO_Configuration_Normal_Case
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to monitor CB011065-SR normal case.
    [Setup]
    ...    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TMO_CVR
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sansa
    Log To Console      ${\n}============= Subfeature -A inter-RAT HO with VoNR =============${\n}
    Counter collection CB011065_A
    Set 5QI-5 and 5QI-1 as initial DRB
    ATTACH UE    UE_ID=1
    Start traffic on UE    UE_ID=1     TRAFFIC_RATE=5
    Trigger inter-RAT handover from NR to LTE    UE_ID=1
    Log To Console      ${\n}============= Wait for -A counter update =============${\n}
    sleep    5 min
    Counter check
    DETTACH UE    UE_ID=1
    Log To Console      ${\n}============= Subfeature -B inter-gNB Xn HO Path Switch Request =============${\n}
    Counter collection CB011065_B
    ATTACH UE    UE_ID=2
    Start traffic on UE    UE_ID=2     TRAFFIC_RATE=5
    Trigger inter-gNB Xn handover    UE_ID=2
    Trigger inter-gNB Xn handover back to source    UE_ID=2
    Log To Console      ${\n}============= Wait for -B counter update =============${\n}
    sleep    5 min
    Counter check
    DETTACH UE    UE_ID=2
    RESET UE Location    UE_ID=2
    Log To Console      ${\n}============= Subfeature -C NSA Intra MeNB HO without PsCell change =============${\n}
    Counter collection CB011065_C
    ATTACH NSA UE    UE_ID=51
    SETUP SgNB link    UE_ID=51    SgNB_ID=2    SgNB_CELL_ID=1
    Trigger Intra-Cell Intra-MeNB HO    UE_ID=51
    Log To Console      ${\n}============= Wait for -C counter update =============${\n}
    sleep    5 min
    Counter check
    DETACH NSA UE    UE_ID=51
    Log To Console      ${\n}============= Subfeature -D B1 measurement report during Voice fallback =============${\n}
    Counter collection CB011065_D
    Disbale VoNR feature on gNB
    Reset SMF Param
    ATTACH UE    UE_ID=4
    Start traffic on UE    UE_ID=4     TRAFFIC_RATE=5
    Setup 5QI-1    UE_ID=4
    Trigger B1 measurement report    UE_ID=4
    Log To Console      ${\n}============= Wait for -D counter update =============${\n}
    sleep    5 min
    Counter check
    DETTACH UE    UE_ID=4

CB011065_CVR_02_TMO_Configuration_Failure_Case
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to monitor CB011065-SR failure mode case.
    [Setup]
    ...    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TMO_CVR
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sansa
    Log To Console      ${\n}============= Subfeature -A Xn HO preparation failure counter =============${\n}
    Counter collection CB011065_A failure mode
    Set 5QI-5 and 5QI-1 as initial DRB
    ATTACH UE    UE_ID=1
    Start traffic on UE    UE_ID=1     TRAFFIC_RATE=5
    Trigger inter-gNB intra-freq HO preparation failure    UE_ID=1
    Trigger inter-gNB inter-freq HO preparation failure    UE_ID=1
    Trigger inter-gNB HO cancellation    UE_ID=1
    Log To Console      ${\n}============= Wait for -A counter update =============${\n}
    sleep    5 min
    Counter check
    DETTACH UE    UE_ID=1
    Log To Console      ${\n}============= Subfeature -B Xn HO Path Switch Failure counter =============${\n}
    Counter collection CB011065_B failure mode
    Reset Xn handover preparation param
    ATTACH UE    UE_ID=2
    Start traffic on UE    UE_ID=2     TRAFFIC_RATE=5
    Trigger inter-gNB Xn handover    UE_ID=2
    Set Path Switch Failure Param    UE_ID=2
    Trigger inter-gNB Xn handover back to source    UE_ID=2
    DETTACH UE    UE_ID=2
    Log To Console      ${\n}============= Subfeature -B inter-RAT HO cancel =============${\n}
    ATTACH UE    UE_ID=3
    Start traffic on UE    UE_ID=3     TRAFFIC_RATE=5
    Trigger inter-RAT handover from NR to LTE    UE_ID=3
    Set UE context release during inter-RAT Handover    UE_ID=3
    Trigger inter-RAT handover from LTE to NR    UE_ID=3
    DETTACH UE    UE_ID=3
    Log To Console      ${\n}============= Wait for -B counter update =============${\n}
    sleep    5 min
    Counter check

*** Keywords ***
Disbale VoNR feature on gNB
    Log To Console      ${\n}============= Online deactivate VoNR feature =============${\n}
    [Documentation]    Disable VoNR function on gNB cell
    @{para_list}   Create List    actVoNR    actEnhancedVoNR
    @{value_list}   Create List   false    false
    @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Counter collection CB011065_A
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
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter collection CB011065_A failure mode
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55143C00025;
    ...    Counter rule: max(M55143C00025)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55143C00026;
    ...    Counter rule: max(M55143C00026)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55143C00033;
    ...    Counter rule: max(M55143C00033)==1;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55143C00035;
    ...    Counter rule: max(M55143C00035)==1;
    ${rule5}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55143C00028;
    ...    Counter rule: max(M55143C00028)==1;
    ${rule6}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55143C00030;
    ...    Counter rule: max(M55143C00030)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}    ${rule6}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter collection CB011065_B
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00013;
    ...    Counter rule: max(M55209C00013)==1;
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter collection CB011065_B failure mode
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00015;
    ...    Counter rule: max(M55209C00015)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00017;
    ...    Counter rule: max(M55209C00017)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter collection CB011065_C
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55128C00004;
    ...    Counter rule: max(M55128C00004)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55128C00009;
    ...    Counter rule: max(M55128C00009)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55128C00010;
    ...    Counter rule: max(M55128C00010)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter collection CB011065_D
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55145C00013;
    ...    Counter rule: max(M55145C00013)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01502;
    ...    Counter rule: max(M55124C01502)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C02501;
    ...    Counter rule: max(M55124C02501)==1;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01032;
    ...    Counter rule: max(M55124C01032)==1;
    ${rule5}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01033;
    ...    Counter rule: max(M55124C01033)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter check
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

Set 5QI-5 and 5QI-1 as initial DRB
    Log To Console      ${\n}============= Set 5QI-5 as Default DRB and setup 5QI-1 during ICS =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=qosflow_modify qos_flow=5 default=on
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=smf_param id=1 additional_qosflows_to_activate=6
    ...    pass_regexp=${None}
    sleep    1s

Reset SMF Param
    Log To Console      ${\n}============= Reset SMF Param =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=smf_param id=1 reset
    ...    pass_regexp=${None}
    sleep    1s

Reset Xn handover preparation param
    Log To Console      ${\n}============= Reset Xn handover preparation param =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id=3 reset
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

ATTACH NSA UE
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Attach NSA UE${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_attach id\=${UE_ID}
    ...    pass_regexp=UE performed EPS_ATTACH
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

DETACH NSA UE
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Detach NSA UE${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_detach id=${UE_ID}
    ...    pass_regexp=${None}
    sleep    2s

Setup 5QI-1
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Setup 5QI-1 as VoNR DRB =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${UE_ID} pdu=1 qosflows_to_add=6 by=amf
    ...    pass_regexp=${None}
    sleep    2s

Trigger B1 measurement report
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Trigger UE${UE_ID} B1 Measurement Report and fallback to LTE cell =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=5 event=B1 phycell_id=11 nrsrp_nr=19 nrsrq_nr=17
    ...    pass_regexp=Re-direction to 4G/LTE cell is not supported
    sleep    3s

RESET UE Location
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Reset UE${UE_ID} location =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_change_location id=${UE_ID} enb=2 cell=1
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

Trigger inter-gNB Xn handover
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Trigger UE${UE_ID} A2 Measurement Report on CELL-1 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger UE${UE_ID} A3 Measurement Report and handover to target =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=7 event=A3 srsrp_nr=19 phycell_id=8 nrsrp_nr=100
    ...    pass_regexp=Inter-eNB handover
    sleep    3s

Trigger inter-gNB Xn handover back to source
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Trigger UE${UE_ID} A3 Measurement Report and handover back to CELL-1 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A3 srsrp_nr=19 phycell_id=51 nrsrp_nr=100
    ...    pass_regexp=Inter-eNB handover
    sleep    3s

Trigger inter-RAT handover from NR to LTE
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Trigger UE${UE_ID} A2 Measurement Report on CELL-1 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger UE${UE_ID} inter-RAT handover to LTE =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=10 event=B2 phycell_id=11 nrsrp_nr=19 nrsrq_nr=17
    ...    pass_regexp=IRAT Handover from NR to EUTRA completed
    sleep    3s

Trigger inter-RAT handover from LTE to NR
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Trigger UE${UE_ID} inter-RAT handover back to NR =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_trigger_inter_rat_handover_to_5g ue=${UE_ID} target_gnb=2 target_cell=1 plmn=310:260
    ...    pass_regexp=${None}
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
    ...    cmd=gnb_xn_handover_preparation_param id=3 action=force_failure cause=no_radio_resources_available
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger UE${UE_ID} HO =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=3 event=A3 srsrp_nr=19 phycell_id=7 nrsrp_nr=100
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Reset preparation failure cause =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id=3 reset
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Set preparation failure cause as Invalid QoS Combination =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id=3 action=force_failure cause=invalid_QoS_combination
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger UE${UE_ID} HO =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=3 event=A3 srsrp_nr=19 phycell_id=7 nrsrp_nr=100
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Reset preparation failure cause =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id=3 reset
    ...    pass_regexp=${None}
    sleep    1s

Trigger inter-gNB inter-freq HO preparation failure
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Set preparation failure cause as O&M intervention =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id=3 action=force_failure cause=o_and_M_intervention
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger UE${UE_ID} HO =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=7 event=A3 srsrp_nr=19 phycell_id=8 nrsrp_nr=100
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Reset preparation failure cause =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id=3 reset
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Set preparation failure cause as other cause =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id=3 action=force_failure cause=time_critical_action
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger UE${UE_ID} HO =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=7 event=A3 srsrp_nr=19 phycell_id=8 nrsrp_nr=100
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Reset preparation failure cause =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id=3 reset
    ...    pass_regexp=${None}
    sleep    1s

Trigger inter-gNB HO cancellation
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Set drop handover preparation =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id=3 action=drop
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger UE${UE_ID} HO =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=3 event=A3 srsrp_nr=19 phycell_id=7 nrsrp_nr=100
    ...    pass_regexp=${None}
    sleep    10s

Set Path Switch Failure Param
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Set Path Switch Failure Param =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_path_switch_param id=1 ue=${UE_ID} action=path_switch_failure cause=MISC_not_enough_user_plane_processing_resources
    ...    pass_regexp=${None}
    sleep    1s

Set UE context release during inter-RAT Handover
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Set UE context release during inter-RAT Handover for UE${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_request_ack_param id=1 ue=${UE_ID} action=send_alternate_response msg=ng_ue_ctx_release_cmd cause=RN_redirection
    ...    pass_regexp=${None}
    sleep    1s

SETUP SgNB link
    [Arguments]    ${UE_ID}     ${SgNB_ID}    ${SgNB_CELL_ID}
    Log To Console      ${\n}============= Setup SgNB link for UE${UE_ID} to SgNB-${SgNB_ID} CELL-${SgNB_CELL_ID} =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=enb_ue_dc_start ue=${UE_ID} target_gnb=${SgNB_ID} target_cells=${SgNB_CELL_ID} bearer=2 type=split_scg
    ...    pass_regexp=Successfully reconfigured dual connectivity
    sleep    3s

Trigger Intra-Cell Intra-MeNB HO
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Trigger Intra-Cell Intra-MeNB Handover for UE${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_reauth id\=${UE_ID}
    ...    pass_regexp=SgNB Modification is successful
    sleep    3s