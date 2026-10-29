*** Settings ***
Documentation
...   author: Ran Yin
...   contact: ran.yin@nokia-sbell.com
...   Description: This is CB009849-SR-C CRT in TMOUS configuration

Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource           ../../Resources/Classical/RRM_Common_Resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Common MultiBTS Suite Setup For RRM
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common MutliBTS Suite Teardown For RRM
Library            check_rules_ET.py
Library            XML   use_lxml=True
Test Timeout       120 minutes


*** Variables ***
#Reduce global paramter as possilbe and automatically got from gNB or __init__

@{mcs_setting}           ${19}    ${15}    ${12}
${TTI_TDD_cell}          NRCELL-1
${TTI_FDD_cell}          NRCELL-7
&{dcap_info}             host=127.0.0.1    port=9443    username=${None}    password=${None}
&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_4459}            faultId=${4459}
&{fault_4655}            faultId=${4655}
&{fault_4654}            faultId=${4654}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
&{fault_61616}           faultId=${61616}
&{fault_7529}            faultId=${7529}
&{fault_7107}            faultId=${7107}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_4459}    &{fault_8000}    &{fault_7300}
...    &{fault_61616}    &{fault_7529}    &{fault_7107}    &{fault_4655}    &{fault_4654}
# ${tti_path}           /home/ute/test_results/
${tag}                tti
@{tti_condition_1}    dlFdSchedData.scheduledBytesPerBearer[1]    >    0
@{tti_condition_2}    dlFdSchedData.scheduledBytesPerBearer[2]    >    0
@{tti_condition_3}    dlFdSchedData.scheduledBytesPerBearer[5]    >    0
@{tti_condition_4}    dlFdSchedData.scheduledBytesPerBearer[6]    >    0
@{tti_condition_5}    dlFdSchedData.scheduledBytesPerBearer[1]    ==    0
@{tti_condition_6}    dlFdSchedData.scheduledBytesPerBearer[2]    ==    0
@{tti_condition_7}    dlFdSchedData.scheduledBytesPerBearer[5]    ==    0
@{tti_condition_8}    dlFdSchedData.dciFormat    !=    DL_10_FORCE
@{tti_stat_condition_1}    max    dlFdSchedData.rrmDlUsedMcs    >    19
@{tti_stat_condition_2}    max    dlFdSchedData.rrmDlUsedMcs    >    15
@{tti_stat_condition_3}    max    dlFdSchedData.rrmDlUsedMcs    >    12
@{tti_stat_condition_4}    max    dlFdSchedData.rrmCorrAvgCqi    >    15
@{tti_stat_conditions_1}    or     ${tti_stat_condition_1}    ${tti_stat_condition_1}
@{tti_stat_conditions_2}    or     ${tti_stat_condition_2}    ${tti_stat_condition_2}
@{tti_stat_conditions_3}    or     ${tti_stat_condition_3}    ${tti_stat_condition_4}
@{tti_conditions_1}    or    ${tti_condition_1}    ${tti_condition_2}
@{tti_conditions_2}    and    ${tti_condition_5}    ${tti_condition_6}    ${tti_condition_3}
...                           ${tti_condition_8}
@{tti_conditions_3}    and    ${tti_condition_5}    ${tti_condition_6}    ${tti_condition_7}
...                           ${tti_condition_4}
&{tti_check_rules_1}         basic_rules=${tti_conditions_1}    statistics_rules=${tti_stat_conditions_1}
&{tti_check_rules_2}         basic_rules=${tti_conditions_2}    statistics_rules=${tti_stat_conditions_2}
&{tti_check_rules_3}         basic_rules=${tti_conditions_3}    statistics_rules=${tti_stat_conditions_3}
&{tti_analysis_1}       check_rules=${tti_check_rules_1}    row_count=${50}
&{tti_analysis_2}       check_rules=${tti_check_rules_2}    row_count=${50}
&{tti_analysis_3}       check_rules=${tti_check_rules_3}    row_count=${50}
@{tti_analysis_dict}     ${tti_analysis_1}    ${tti_analysis_2}    ${tti_analysis_3}
${DEBUG_MODE}            ${TRUE}
${Ignore_Cell_Id_For_Sib}    5    6    9    12

*** Test Cases ***
CB009849_C_05_Update VoNR downlink rank reduction algorithm for SRB, 5QI5 and 5QI1
    [Documentation]
    ...    author: Ran Yin
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to verify rank reduction algorithm for SRB, 5QI5 and 5QI1 on TDD.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_TMO_C
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Change CB009849_C_actDlForceRankDowng_to_dlVonrSrbVoNRCtrl
#    Start TTI trace for specific TDD cell
#    sleep    20 s
    Start GNB Ttitrace With Streaming Mode    lcr_cell_id=1
    Attach UE    ue_id=1
    Start traffic on UE    ue_id=1
    sleep    5 s
#    Stop TTI trace for specific cell
    ${tti_path}    Stop GNB Ttitrace With Streaming Mode
    Set Test Variable    ${tti_path}     ${tti_path}
    Log To Console    \nTTI log: ${tti_path}
    Detach UE    ue_id=1
    Analyze TTI log

CB009849_C_12_Update VoNR downlink rank reduction algorithm to use CQI data for SRB, 5QI5, 5QI1 and non-GBR
    [Documentation]    author: ran.yin@nokia-sbell.com
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to verify rank reduction algorithm for SRB, 5QI5, 5QI1 and non-GBR on FDD.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_TMO_C
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Change CB009849_C_actDlForceRankDowng_to_dlVonrSrbVoNRCtrNonGbrBr
    Start GNB Ttitrace With Streaming Mode    lcr_cell_id=10
    Attach UE on FDD    ue_id=2
    Start traffic on FDD UE    ue_id=2
    sleep    5 s
    ${tti_path}    Stop GNB Ttitrace With Streaming Mode
    Set Test Variable    ${tti_path}     ${tti_path}
    Log To Console    \nTTI log: ${tti_path}
    Detach UE    ue_id=2
    Analyze TTI log

*** Keywords ***
Attach UE
    [Arguments]    ${ue_id}=1
    Log To Console      ${\n}============= Set 5QI-5 as default QoS flow =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=5 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Select cell 1 for UE1 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_change_location id\=${ue_id} enb\=2 cell\=1
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start to Attach the UE1 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=${ue_id}
    ...    pass_regexp=UE NGAP ID 1 is now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=${ue_id} nwslice\=1 gw\=1
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s
    Log To Console      ${\n}============= Setup 5QI-7 for UE1 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=2 default\=on
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu\=2 trf_type\=internal
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu\=2 nwslice\=1 gw\=2
    ...    pass_regexp=PDU SESSION ID-2 setup/reestablishment complete
#    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=2 qfi\=1 dir\=dl mbps\=10
#    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Add 5QI-1 QoS flow =============${\n}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu\=1 qosflows_to_add\=6 by\=amf
    ...    pass_regexp=${None}
    sleep    2s

Attach UE on FDD
    [Arguments]    ${ue_id}=2
    Log To Console      ${\n}============= Set 5QI-5 as default QoS flow =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=5 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Select cell 10 for UE2 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_change_location id\=${ue_id} enb\=2 cell\=10
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start to Attach the UE2 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=${ue_id}
    ...    pass_regexp=UE NGAP ID 1 is now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=${ue_id} nwslice\=1 gw\=1
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s
    Log To Console      ${\n}============= Setup 5QI-7 for UE2 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=2 default\=on
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu\=2 trf_type\=internal
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu\=2 nwslice\=1 gw\=2
    ...    pass_regexp=PDU SESSION ID-2 setup/reestablishment complete
#    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=2 qfi\=1 dir\=dl mbps\=10
#    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Add 5QI-1 QoS flow =============${\n}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu\=1 qosflows_to_add\=6 by\=amf
    ...    pass_regexp=${None}
    sleep    2s

Start traffic on UE
    [Arguments]    ${ue_id}=1
    Log To Console      ${\n}============= Start DL/UL Data traffic on UE1 =============${\n}
    # Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=2
    # ...    pass_regexp=${None}
    # sleep    2s
    # Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=2
    # ...    pass_regexp=${None}
    # sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi\=1 dir\=dl period_ms\=80 burst\=2
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi\=2 dir\=dl rtp_codec\=amr_wb_23_85 period_ms\=20 burst\=5
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=2 qfi\=1 dir\=dl mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
#    Airphone.Airphone Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=2 qfi\=1 dir\=ul mbps\=2
#    ...    pass_regexp=${None}
#    sleep    2s

Start traffic on FDD UE
    [Arguments]    ${ue_id}=2
    Log To Console      ${\n}============= Start DL/UL Data traffic on UE2 =============${\n}
    # Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=2
    # ...    pass_regexp=${None}
    # sleep    2s
    # Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=2
    # ...    pass_regexp=${None}
    # sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi\=1 dir\=dl period_ms\=80 burst\=2
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi\=2 dir\=dl rtp_codec\=amr_wb_23_85 period_ms\=20 burst\=5
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=2 qfi\=1 dir\=dl mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
#    Airphone.Airphone Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=2 qfi\=1 dir\=ul mbps\=2
#    ...    pass_regexp=${None}
#    sleep    2s

Detach UE
    [Arguments]    ${ue_id}=1
    Log To Console      ${\n}============= Detach all UEs =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=all
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_deregister id\=${ue_id} ue_deregister_type\=switch_off
    ...    pass_regexp=${None}
    sleep    2s


Change CB009849_C_actDlForceRankDowng_to_dlVonrSrbVoNRCtrl
    &{staged_dict}    create dictionary   maxMcsForDlSrb=${mcs_setting[0]}  maxMcsForDlVoNRCtrl=${mcs_setting[1]}
    @{staged_param_list}     Create List   ${staged_dict}
    @{value_list}     Create List   ${staged_param_list}    dlVonrSrbVoNRCtrl    false    ${mcs_setting[2]}
    @{para_list}      Create List   dlForceRankDowngCtl    actDlForceRankDowng    actDlVoNrLimMaxMcsAndLayer
    ...                maxMCSVoNRRankAndMCSRestrict
    @{mo_list}        Create List   MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ...                MRBTS-1/NRBTS-1/NRCELL-1
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Change CB009849_C_actDlForceRankDowng_to_dlVonrSrbVoNRCtrNonGbrBr
    &{staged_dict}    create dictionary   maxMcsForDlSrb=${mcs_setting[0]}  maxMcsForDlVoNRCtrl=${mcs_setting[1]}
    @{staged_param_list}     Create List   ${staged_dict}
    @{value_list}     Create List   ${staged_param_list}    dlVonrSrbVoNRCtrNonGbrBr    false    ${mcs_setting[2]}    12    10
    @{para_list}      Create List   dlForceRankDowngCtl    actDlForceRankDowng    actDlVoNrLimMaxMcsAndLayer
    ...                maxMCSVoNRRankAndMCSRestrict    shortTermBlerThreshold1    shortTermBlerThreshold2
    @{mo_list}        Create List   MRBTS-1/NRBTS-1/NRCELL-10    MRBTS-1/NRBTS-1/NRCELL-10    MRBTS-1/NRBTS-1/NRCELL-10
    ...                MRBTS-1/NRBTS-1/NRCELL-10    MRBTS-1/NRBTS-1/NRCELL-10    MRBTS-1/NRBTS-1/NRCELL-10
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Start TTI trace for specific TDD cell
    Log To Console    start to capture tti with DCAP
    ${dcap_argument}   Create Dictionary   nrCells=${TTI_TDD_cell}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start    emil+tti+syslog    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}

Start TTI trace for specific FDD cell
    Log To Console    start to capture tti with DCAP
    ${dcap_argument}   Create Dictionary   nrCells=${TTI_FDD_cell}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start    emil+tti+syslog    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}

Stop TTI trace for specific cell
    Log To Console    stopping tti with DCAP
    ${local_file_path}    Log Collection    stop_and_download    emil+tti+syslog    product_type=gnb    bts_index=${0}
    Set Test Variable    ${tti_path}     ${local_file_path}
    Log To Console    \nTTI log: ${local_file_path}

Analyze TTI log
    ${tag}    Set Variable   tti
    Log To Console    \nStart Log Analysis for ${tti_path}
#    ${result}=    Log Analysis    check    tti    ${tti_path}    ${tti_analysis_dict}
#    ${dir_path}    Get File Directory    ${tti_path}
    Decoder Tttirace From Pcap To Csv     pcap_path=${tti_path}
    ...    output_path_with_tag=${TEST_LOG_DIRECTORY}/${tag}
    Log To Console    \nOutput TTI csv files are listed: ${TEST_LOG_DIRECTORY}
    ${status}    check_rules    ${TEST_LOG_DIRECTORY}    ${mcs_setting[0]}    ${mcs_setting[1]}    ${mcs_setting[2]}
    ...    direction=dl
    Log To Console    \nCheck rule log: ${status}
    should be true    ${status}