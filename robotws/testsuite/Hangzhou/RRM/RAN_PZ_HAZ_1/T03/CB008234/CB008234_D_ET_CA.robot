*** Settings ***
Documentation
...   author: Sijia Zhang
...   contact: sijia.zhang@nokia-sbell.com
...   Description: This is CB008234-SR ET -D CRT cases (Tester: Zhang Sijia(NSB))

Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Common/Airphone.robot
# Resource          ../Resources/top50_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Test Setup            Common MultiBTS Test Setup For RRM
Test Teardown     Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown    Common MutliBTS Suite Teardown For RRM
Force Tags        CRT/CIT/CDRT     #Tag Item
# ...   PY27
...      RAN_5G                    #Product [RAN_5G]
...      SBTS00/SBTS21B           # it is for auto trigger by ute cloud with the release
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20?TA_LEVEL_21? TA_LEVEL_22]
Test Timeout       40 minutes

*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__
&{fault_7300}             faultId=${7300}
@{Ohter_Allow_Alarms}     &{fault_7300}
${APC_Index}    -1
${total_throughput}    ${0}
${parameter}           act5qiAndUlNguTnlQosFlowMod
${parameter_8379}      actNonVoNRGbrService
${dist_name}           MRBTS-1/NRBTS-1
&{RAD_HEXs}                     rdOverloadHighThreshold=0x89006f
...                             rdFailDuAdmissionControl=0x590249
# ${REMOTE_MODE}           ${TRUE}
${PATH2}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T03/CB008234/Airphone

*** Test Cases ***
CB008234_D_DL UE AMBR interworking with F+T 6CC
    [Documentation]
    ...    author: Sijia Zhang
    ...    Description:
    ...    CB011081 4F2T 6CC are limated after DL UE-AMBR are activation
    [Setup]    Run Keywords    Configure IP For UEC2    AND    Common MultiBTS Test Setup For RRM
    ...    airphone_config_tag=SA_FDD_6c_1gNBSim_D_B10    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12009;
    ...    Counter rule: max(M55319C12009)<3933000;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-3;
    ...    Counter: M55138C03507;
    ...    Counter rule: max(M55138C03507)==1;
    ${6CC_rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${6CC_rule_list}
    Start Multi Bts Log
    ${ue_id} =    Set Variable    3
    Set Test Variable    ${ue_id}    3
    Log    ${ue_id}
    Airphone Execute Egate Command
    ...    cmd=smf_ue_pdu_param id=1 ue=3 pdu=1 session_ambr_dl=100:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
    Airphone Execute Egate Command
    ...    cmd=amf_ue_param ue=3 ue_ambr_dl=2:Gbps pass_regexp=${None}
    Log To Console      ${\n}============= set ue dl ambr. =============${\n}
    Airphone Execute Egate Command    cmd=set_pdu_param ue=3 pdu=1 trf_type=internal pass_regexp=${None}
    sleep    1s
    Airphone Attach    ue_id=3    call_type=SA
    Log To Console      ${\n}============= Setup PDU1 5qi9. =============${\n}
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
    Log To Console      ${\n}============= Check the Tput =============${\n}
    Airphone Execute Egate Command     cmd=bearer_stats ue=3 pdu=1 qfi=1 dir=dl dc_cell_group=all
    Run Keyword And Ignore Error       Get F+T Scellindex
    sleep    10 min
    Check KPI
    Run Keyword And Ignore Error       Get Tput for scell
    Airphone Execute Egate Command     cmd=sim_log_set flush
    Airphone Execute Egate Command     cmd=ue_deregister id=3 ue_deregister_type=switch_off
    ...    pass_regexp=${None}

CB008234_D_DL UE AMBR interworking with T+F 6CC
    [Documentation]
    ...    author: Sijia Zhang
    ...    Description:
    ...    CB011080 4F2T 6CC are limated after DL UE-AMBR are activation
    [Setup]    Run Keywords    Configure IP For UEC2    AND    Common MultiBTS Test Setup For RRM
    ...    airphone_config_tag=SA_TDD_6c_1gNBSim_D_B10    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12006;
    ...    Counter rule: max(M55319C12006)<3933000;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-7;
    ...    Counter: M55138C03507;
    ...    Counter rule: max(M55138C03507)==1;
    ${6CC_rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${6CC_rule_list}
    Start Multi Bts Log
    ${ue_id} =    Set Variable    1
    Set Test Variable    ${ue_id}    1
    Log    ${ue_id}
    Airphone Execute Egate Command
    ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_dl=100:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
    Airphone Execute Egate Command
    ...    cmd=amf_ue_param ue=1 ue_ambr_dl=2:Gbps pass_regexp=${None}
    Log To Console      ${\n}============= set ue dl ambr. =============${\n}
    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal pass_regexp=${None}
    sleep    1s
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Start DL traffic on 5QI-9 =============${\n}
    Airphone Start Traffic    mbps=175m    dir=dl     pdu_id=1    qfi_id=1
    sleep    3s
    Log To Console      ${\n}============= Check the Tput =============${\n}
    Airphone Execute Egate Command     cmd=bearer_stats ue=1 pdu=1 qfi=1 dir=dl dc_cell_group=all
    Run Keyword And Ignore Error       Get T+F Scellindex
    sleep    10 min
    Check KPI
    Run Keyword And Ignore Error       Get Tput for scell
    Airphone Execute Egate Command     cmd=sim_log_set flush
    Airphone Execute Egate Command     cmd=ue_deregister id=1 ue_deregister_type=switch_off
    ...    pass_regexp=${None}


CB008234_D_DL UE AMBR interworking with intra-gNB NRDC
    [Documentation]
    ...    author: Sijia Zhang
    ...    Description:
    ...    both of the two legs in NRDC are limated after DL UE-AMBR are activation
    [Setup]    Run Keywords    case NRDC setup    AND    Common MultiBTS Test Setup For RRM
    ...    airphone_config_tag=SA_NRDC_2c_1gNBSim_D_B10     base_path=${CURDIR}/Airphone
    Start Multi Bts Log
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12009;
    ...    Counter rule: max(M55319C12009)<3933000;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55118C00067;
    ...    Counter rule: max(M55118C00067)>=1;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Start Multi Bts Log
    Log To Console      ${\n}============= Initial DL session-AMBR is 300Mbps =============${\n}
    Airphone Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report=true
    Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
    Airphone Execute Egate Command    cmd=smf_ue_pdu_param id=1 ue=2 pdu=1 session_ambr_dl=100:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set ue dl ambr. =============${\n}
    Airphone Execute Egate Command    cmd=amf_ue_param ue=2 ue_ambr_dl=1024:Mbps
    Log To Console      ${\n}============= Start to Attach one UE =============${\n}
    Airphone Attach    ue_id=2    call_type=SA
    sleep    2s
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=3
    ...    pass_regexp=${None}
    sleep    3s
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 phycell_id=53 event=A4
    ...    pass_regexp=${None}
    sleep    3s
    Run Keyword And Ignore Error       Get T+F Scellindex
    sleep    3s
    Log To Console      ${\n}============= Start DL traffic on 5QI-9 =============${\n}
    Airphone Execute Egate Command     cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
    Airphone Execute Egate Command     cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
    Airphone Execute Egate Command     cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
    sleep    3s
    Log To Console      ${\n}============= Wait for throughput and counter =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Run Keyword And Ignore Error       Get Tput for scell
    Log To Console      ${\n}============= Check throughput and DLCG counter =============${\n}
    Check KPI
    Log To Console      ${\n}============= Check is done. Case is passed. =============${\n}


*** Keywords ***
case NRDC setup
    ${ue_id} =    Set Variable    2
    Set Test Variable    ${ue_id}    2
    Log    ${ue_id}
    ${need_sib_check}=     Set Variable     ${False}
    Set Test Variable     ${need_sib_check}     ${False}
    Log    ${need_sib_check}
Kw For AP Operation
    COAM_Admin.Login
    ${cell_info}    COAM_Admin.getcellinfo    cell_type=nr
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=3    pdu_id=1    profile_id=1
    ...                                         gnb_id=${None}    cell_id=${None}    bearer_id=${None}
    Wait Until Keyword Succeeds     3x    1min    Airphone Operation    operation=attach
    ...                   product_type=gnb
    ...                   traffic_info_dic=${traffic_info_dic}
    ...                   timeout=30s
    Airphone Operation    operation=aplog
    ...                   product_type=gnb
    ...                   timeout=30s
    ${psy_cellid_list}    Create List    ${50}    ${51}    ${53}    ${54}    ${55}
    FOR    ${psy_id}    IN    @{psy_cellid_list}
        ${scell_status}    ${scellidx}    Run Keyword And Ignore Error    Get ScellIdx With UE Id From Egate Log    ${0}    ${psy_id}
        Exit For Loop If    '${scell_status}'=='PASS'
    END
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=3
    Airphone Operation    operation=detach
    ...                   product_type=gnb
    ...                   traffic_info_dic=${traffic_info_dic}
    ...                   timeout=30s
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=3    bearer_id=2    dir=dl
    ...                                         pdu_id=1    time_len=5s    trf_id=1    mbps_dl=450m
    ...                                         qfi_id=1    time=999    type=l3    profile_id=1
    ...                                         gnb_id=0    cell_id=1    protocol=udp
    ${Tput_dict}    Airphone Operation    operation=start_traffic
    ...                                   product_type=gnb
    ...                                   traffic_info_dic=${traffic_info_dic}
    ...                                   timeout=600s
    Sleep    30s
    ${min_tput}    ${max_tput}    ${avg_tput}
    ...    Airphone Get Detail Throughput For Per Scell    scell_index=${scellidx}
    ${Tput_dict}    Airphone Operation    operation=stop_traffic
    ...                                   product_type=gnb
    ...                                   traffic_info_dic=${traffic_info_dic}
    ...                                   timeout=600s

Check Ave Tput via bearer stats
    [Documentation]     check the average of two tput value
    [Arguments]    ${ue_id}=3    ${pdu_id}=1   ${qfi_id}=1
    ...    ${dir}=dl   ${expected_tput_max}=10000000    ${expected_tput_min}=0
    ${tput_v1}    Airphone Get Average Throughput    ue_id=${ue_id}
    ...    pdu_id=${pdu_id}    qfi=${qfi_id}    dir=${dir}
    sleep    2s
    ${tput_v2}    Airphone Get Average Throughput    ue_id=${ue_id}
    ...    pdu_id=${pdu_id}    qfi=${qfi_id}    dir=${dir}
    ${arg_tput}=    Evaluate    (${tput_v1} + ${tput_v2})/2
    Should be true    ${arg_tput}<=${expected_tput_max}
    Should be true    ${arg_tput}>=${expected_tput_min}
    [Return]    ${arg_tput}

Configure IP For UEC2
    OperatingSystem.Run      sudo ip addr add 10.0.2.3/24 dev eth4
    OperatingSystem.Run      sudo ip addr add 10.0.1.61/24 dev eth3
Check 5QI Initial Setup In NGAP
    [Arguments]  ${capture_file_path}    ${5qi}=9
    Check NGAP InitialContextSetup By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.PDUSessionResourceSetupListCxtReq == 1'
    ...    filter_expression='ngap.QosFlowSetupRequestList == 1 && ngap.qosFlowIdentifier == 1'
    Check NGAP InitialContextSetup By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.PDUSessionResourceSetupListCxtReq == 1'
    ...    filter_expression='ngap.QosFlowSetupRequestList == 1 && ngap.fiveQI == ${5qi}'
Check DLAMBR In E1AP By Expression
    [Arguments]  ${capture_file_path}    ${ambr_dl}=10485760
    Check E1AP BearerContextSetupRequest By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.BitRate == ${ambr_dl}'
    ...    filter_expression='e1ap.BitRate == ${ambr_dl}'
Check KPI
    ${rule_list}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${rule_list}

Get F+T Scellindex
    Airphone Operation    operation=aplog
    ...                   product_type=gnb
    ...                   timeout=30s
    ${psy_cellid_list}    Create List    ${50}    ${51}    ${53}    ${54}    ${55}
    FOR    ${psy_id}    IN    @{psy_cellid_list}
        ${scell_status}    ${scellidx}    Run Keyword And Ignore Error
     ...    Get ScellIdx With UE Id From Egate Log    ${ue_id}    ${psy_id}
        Exit For Loop If    '${scell_status}'=='PASS'
        Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=${scellidx}
    END

Get T+F Scellindex
    Airphone Operation    operation=aplog
    ...                   product_type=gnb
    ...                   timeout=30s
    ${psy_cellid_list}    Create List    ${51}    ${52}    ${53}    ${54}    ${55}
    FOR    ${psy_id}    IN    @{psy_cellid_list}
        ${scell_status}    ${scellidx}    Run Keyword And Ignore Error
     ...    Get ScellIdx With UE Id From Egate Log    ${ue_id}    ${psy_id}
        Exit For Loop If    '${scell_status}'=='PASS'
        Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=${scellidx}
    END

Get Tput for scell
    ${min_tput}    ${max_tput}    ${avg_tput}
    ...    Airphone Get Detail Throughput For Per Scell    scell_index=${scellidx}