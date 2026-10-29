*** Settings ***
Documentation
...   author: Dong tony
...   contact: tony.1.dong@nokia-sbell.com
...   Description: This is CB012582-D ET cases script

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
&{fault_61510}           faultId=${61510}
&{fault_4459}            faultId=${4459}
&{fault_7300}            faultId=${7300}
&{fault_8000}            faultId=${8000}
&{fault_7523}            faultId=${7523}
&{fault_7107}            faultId=${7107}
&{fault_61616}           faultId=${61616}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_7300}    &{fault_7523}    &{fault_4459}
...    &{fault_7107}    &{fault_61510}    &{fault_8000}    &{fault_61616}

${Ignore_Cell_Id_For_Sib}    5    6    9    12

*** Test Cases ***
CB012582_D_Counter update for successful RRC Connection procedures with setup request cause mo-signalling
    [Documentation]
    ...    Author: Tony Dong, Dacheng Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Configuration ID: fd8230c08511c170 TMO B-level configuration
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C09010;
    ...    Counter rule: max(M55124C09010)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01001;
    ...    Counter rule: max(M55124C01001)==1;
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Connect All VM
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}

	Log To Console      ${\n}============= Set RRC connect reason =============${\n}
	Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_setup_param id\=1 establishment_cause\=mo-Signalling
    ...    pass_regexp=${None}

    sleep    3s
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

	Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_D_Counter update for successful RRC Connection procedures with setup request cause mo-SMS
    [Documentation]
    ...    author: dong tony
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D
    ...    base_path=${CURDIR}/Airphone
#   Delete before PM counter file
#   ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#   ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C09014;
    ...    Counter rule: max(M55124C09014)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01014;
    ...    Counter rule: max(M55124C01014)==1;
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Connect All VM
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}

	Log To Console      ${\n}============= Set RRC connect reason =============${\n}
	Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_setup_param id\=1 establishment_cause\=mo-SMS
    ...    pass_regexp=${None}

    sleep    3s
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

	Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_D_Counter update for successful RRC Connection procedures with setup request cause mo-VideoCall
    [Documentation]
    ...    author: dong tony
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D
    ...    base_path=${CURDIR}/Airphone
#   Delete before PM counter file
#   ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#   ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C09015;
    ...    Counter rule: max(M55124C09015)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01017;
    ...    Counter rule: max(M55124C01017)==1;
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Connect All VM
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}

	Log To Console      ${\n}============= Set RRC connect reason =============${\n}
	Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_setup_param id\=1 establishment_cause\=mo-VideoCall
    ...    pass_regexp=${None}

    sleep    3s
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

	Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_D_Counter update for successful RRC Connection procedures with setup request cause mo-VoiceCall
    [Documentation]
    ...    author: dong tony
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D
    ...    base_path=${CURDIR}/Airphone
#   Delete before PM counter file
#   ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#   ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C09013;
    ...    Counter rule: max(M55124C09013)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01006;
    ...    Counter rule: max(M55124C01006)==1;
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Connect All VM
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}

	Log To Console      ${\n}============= Set RRC connect reason =============${\n}
	Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_setup_param id\=1 establishment_cause\=mo-VoiceCall
    ...    pass_regexp=${None}

    sleep    3s
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

	Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_D_Counter update for successful RRC Connection procedures with setup request cause mo-Data
    [Documentation]
    ...    author: dong tony
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D
    ...    base_path=${CURDIR}/Airphone
#   Delete before PM counter file
#   ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#   ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C09011;
    ...    Counter rule: max(M55124C09011)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01002;
    ...    Counter rule: max(M55124C01002)==1;
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Connect All VM
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}

	Log To Console      ${\n}============= Set RRC connect reason =============${\n}
	Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_setup_param id\=1 establishment_cause\=mo-Data
    ...    pass_regexp=${None}

    sleep    3s
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

	Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_D_Counter update for successful RRC Connection procedures with setup request cause mt-Access
    [Documentation]
    ...    author: dong tony
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D
    ...    base_path=${CURDIR}/Airphone
#   Delete before PM counter file
#   ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#   ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C09012;
    ...    Counter rule: max(M55124C09012)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01003;
    ...    Counter rule: max(M55124C01003)==1;
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Connect All VM
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}

	Log To Console      ${\n}============= Set RRC connect reason =============${\n}
	Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_setup_param id\=1 establishment_cause\=mt-Access
    ...    pass_regexp=${None}

    sleep    3s
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

	Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_D_counter not updated for UE in RRC_INACTIVE state to RRC_CONNECTED state with establishment cause mt-Access
    [Documentation]
    ...    author: dong tony
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D
    ...    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C09012;
    ...    Counter rule: max(M55124C09012)==0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01003;
    ...    Counter rule: max(M55124C01003)==0;
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Connect All VM
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}

     ${UE_setting}    Catenate    amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on
    ...    ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=7627107,100,200,201,788,0
    Airphone Execute Egate Command
    ...    cmd=${UE_setting}
    ...    pass_regexp=${None}

    sleep    1s
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
	Log To Console      ${\n}============= Wait UE change to inactive =============${\n}
    Sleep    1 min    reason=wait for UE change to inactive
    Log To Console      ${\n}============= change UE status from inactive to active =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id\=1 gnb\=2 cell\=1 cause\=mt-Access
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_resume id\=1
    ...    pass_regexp=${None}
    sleep    5s

	Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_D_counter not updated for UE in RRC_INACTIVE state to RRC_CONNECTED state with establishment cause mo-VideoCall
    [Documentation]
    ...    author: dong tony
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D
    ...    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C09015;
    ...    Counter rule: max(M55124C09015)==0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01017;
    ...    Counter rule: max(M55124C01017)==0;
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Connect All VM
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}

     ${UE_setting}    Catenate    amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on
    ...    ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=7627107,100,200,201,788,0
    Airphone Execute Egate Command
    ...    cmd=${UE_setting}
    ...    pass_regexp=${None}

    sleep    1s
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
	Log To Console      ${\n}============= Wait UE change to inactive =============${\n}
    Sleep    1 min    reason=wait for UE change to inactive
    Log To Console      ${\n}============= change UE status from inactive to active =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id\=1 gnb\=2 cell\=1 cause\=mo-VideoCall
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_resume id\=1
    ...    pass_regexp=${None}
    sleep    5s

	Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_D_counter not updated for UE in RRC_INACTIVE state to RRC_CONNECTED state with establishment cause mo-SMS
    [Documentation]
    ...    author: dong tony
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D
    ...    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C09014;
    ...    Counter rule: max(M55124C09014)==0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01014;
    ...    Counter rule: max(M55124C01014)==0;
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Connect All VM
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}

     ${UE_setting}    Catenate    amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on
    ...    ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=7627107,100,200,201,788,0
    Airphone Execute Egate Command
    ...    cmd=${UE_setting}
    ...    pass_regexp=${None}

    sleep    1s
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
	Log To Console      ${\n}============= Wait UE change to inactive =============${\n}
    Sleep    1 min    reason=wait for UE change to inactive
    Log To Console      ${\n}============= change UE status from inactive to active =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id\=1 gnb\=2 cell\=1 cause\=mo-SMS
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_resume id\=1
    ...    pass_regexp=${None}
    sleep    5s

	Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_D_counter not updated for UE in RRC_INACTIVE state to RRC_CONNECTED state with establishment cause mo-VoiceCall
    [Documentation]
    ...    author: dong tony
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D
    ...    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C09013;
    ...    Counter rule: max(M55124C09013)==0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01006;
    ...    Counter rule: max(M55124C01006)==0;
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Connect All VM
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}

     ${UE_setting}    Catenate    amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on
    ...    ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=7627107,100,200,201,788,0
    Airphone Execute Egate Command
    ...    cmd=${UE_setting}
    ...    pass_regexp=${None}

    sleep    1s
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
	Log To Console      ${\n}============= Wait UE change to inactive =============${\n}
    Sleep    1 min    reason=wait for UE change to inactive
    Log To Console      ${\n}============= change UE status from inactive to active =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id\=1 gnb\=2 cell\=1 cause\=mo-VoiceCall
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_resume id\=1
    ...    pass_regexp=${None}
    sleep    5s

	Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_D_counter not updated for UE in RRC_INACTIVE state to RRC_CONNECTED state with establishment cause mo-Data
    [Documentation]
    ...    author: dong tony
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D
    ...    base_path=${CURDIR}/Airphone
   ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C09011;
    ...    Counter rule: max(M55124C09011)==0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01002;
    ...    Counter rule: max(M55124C01002)==0;
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Connect All VM
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}

     ${UE_setting}    Catenate    amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on
    ...    ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=7627107,100,200,201,788,0
    Airphone Execute Egate Command
    ...    cmd=${UE_setting}
    ...    pass_regexp=${None}

    sleep    1s
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
	Log To Console      ${\n}============= Wait UE change to inactive =============${\n}
    Sleep    1 min    reason=wait for UE change to inactive
    Log To Console      ${\n}============= change UE status from inactive to active =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id\=1 gnb\=2 cell\=1 cause\=mo-Data
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_nr_rrc_resume id\=1
    ...    pass_regexp=${None}
    sleep    5s

	Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

*** Keywords ***
Counter Check CB012582
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}
