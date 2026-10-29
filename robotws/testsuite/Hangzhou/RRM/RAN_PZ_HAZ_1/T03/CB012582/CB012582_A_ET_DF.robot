*** Settings ***
Documentation
...   author: Dong tony
...   contact: tony.1.dong@nokia-sbell.com
...   Description: This is CB012582-A ET cases script

Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource           ../../Resources/Classical/RRM_Common_Resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Common MultiBTS Suite Setup For RRM
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common MutliBTS Suite Teardown For RRM
Force Tags         CRT/CIT/CDRT     #Tag Item
# ...              PY39
...                RAN_5G                    #Product [RAN_5G]
...                SBTS00           # it is for auto trigger by ute cloud with the release
...                RAN_PZ_HAZ_1             #Competence Area
...                RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...                TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20, TA_LEVEL_21, TA_LEVEL_22]

Test Timeout       40 minutes

*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__

&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_7300}            faultId=${7300}
&{fault_7523}            faultId=${7523}
&{fault_7107}            faultId=${7107}
&{fault_61510}           faultId=${61510}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_7300}    &{fault_7523}    &{fault_7107}

*** Test Cases ***
CB012582_A_3_SA Intra-gNB Intra-DU Intra-Freq HO Interruption time High Range
    [Documentation]
    ...    author: dong tony
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_H
    ...    base_path=${CURDIR}/Airphone

    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55379C00004;
    ...    Counter rule: max(M55379C00004)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-2;
    ...    Counter: M55379C00004;
    ...    Counter rule: max(M55379C00004)==1;
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Connect All VM
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
    Log To Console      ${\n}============= Start to Attach 1st UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=${None}
    sleep    5s
    Log To Console      ${\n}============= Intra-HO from cell1 to cell2 and then back =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=51 nrsrp_nr\=30 nrsrq_nr\=30
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=30 nrsrq_nr\=30
    ...    pass_regexp=${None}
    sleep    3s
	Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_A_1_SA Intra-gNB Intra-DU Intra-Freq HO Interruption time Target Range
    [Documentation]
    ...    author: dong tony
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_T
    ...    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55379C00006;
    ...    Counter rule: max(M55379C00006)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-2;
    ...    Counter: M55379C00006;
    ...    Counter rule: max(M55379C00006)==1;
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Connect All VM
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
    Log To Console      ${\n}============= Start to Attach 1st UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=${None}
    sleep    5s
	Log To Console      ${\n}============= Intra-HO from cell1 to cell2 and then back =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=51 nrsrp_nr\=30 nrsrq_nr\=30
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=30 nrsrq_nr\=30
    ...    pass_regexp=${None}
    sleep    3s
	Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_A_2_SA Intra-gNB Intra-DU Intra-Freq HO Interruption time Moderate Range
    [Documentation]
    ...    author: dong tony
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_M
    ...    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55379C00005;
    ...    Counter rule: max(M55379C00005)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-2;
    ...    Counter: M55379C00005;
    ...    Counter rule: max(M55379C00005)==1;
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Connect All VM
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
    Log To Console      ${\n}============= Start to Attach 1st UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=${None}
    sleep    5s
	Log To Console      ${\n}============= Intra-HO from cell1 to cell2 and then back =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=51 nrsrp_nr\=30 nrsrq_nr\=30
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=30 nrsrq_nr\=30
    ...    pass_regexp=${None}
    sleep    3s
	Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

*** Keywords ***
Counter Check CB012582
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}