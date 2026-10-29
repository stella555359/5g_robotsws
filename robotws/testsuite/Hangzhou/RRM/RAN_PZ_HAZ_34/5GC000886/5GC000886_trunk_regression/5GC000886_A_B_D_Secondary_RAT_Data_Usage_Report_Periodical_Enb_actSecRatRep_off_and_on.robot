*** Settings ***
Documentation
...    author: Jack.zeng
...    contact:jack.zeng@nokia-sbell.com
...    squad group: SG_03
...   feature : 5GC0001544

Force Tags      5G_SISO    9.1800    10.1800    CRT_21A    CRT_20B    CRT_TRUNK    RAN_5G    RAN_5G_TDD
...    PY36
...    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AWHHI_ENB    SBTS00    5G_RAN_TDD

Suite Setup   Run Keywords
...           robot_common_operations.Common Suite Setup    AND
...           CI_interface.Common Suite Setup    AND
...           5GC000886_coam_common_keywords.Pre Condition

Suite Teardown   Run Keywords
...          robot_common_operations.Common Suite Teardown    AND
...          Run Keyword If Any Tests Failed
...          Run Keyword And Ignore Error    Common Suite Teardown for UTE Cloud

Resource    ./../Resources/5GC000886_coam_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/FGCR_4454/Resources/FGCR_4454_common_KW.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot

*** Variables ***
${MME_IP}    ${tl.ues[0].dmc_path}
${dl_port}      ${tl.ues[0].iperf_details.port}
${dl_time}    180
${dl_throughput}    5M
${dl_length}    1024B
${ul_time}    60
${ul_port}     ${tl.ues[0].iperf_details.ssh_connection_details.port}
${ue_ul_port}    ${tl.ues[0].iperf_details.port}
${ue_dl_port}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
${ul_throughput}     5M
${ul_length}    1024B
${appserver_addr}    ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${appserver_username}    ${tl.ues[0].iperf_details.ssh_connection_details.username}
${appserver_password}    ${tl.ues[0].iperf_details.ssh_connection_details.password}
${LKC_CLIENT_PATH}         /cygdrive/c/Users/tester/Desktop/QPM_LK1.3.1
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${tl_scf_filename}    Full_Configuration_SCF_1881_886_7657.xml
#${TESTLINE_NAME}    7_5_CLOUD402T${tl.enbs[0].instance_id}
${enbx2_dist}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNADJGNB-0
#${epc_log_path}    /tmp/

${5GRU_ANT11}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU_ANT12}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU_ANT21}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5GRU_ANT22}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
#${5GRU2_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
#${5GRU2_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}

##5GC000886_B_02_Secondary_RAT_Data_Usage_Report_Periodical_and_Stop
${gNB_UP_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[2].addr}
${E1log_B02}    886_B_02_E1.pcap
${periodicalDataUsageReportTimer}    10
${index0}    0
${index1}    1
${index2}    2
${QXDM_log_B02}    QXDM_log_B02


##5GC000886_D_14_verify_Pmconter_Secondary_RAT_Data_Usage_Report_Periodical
@{PM_counter_D14}    M55323C01007    M55323C03007
${E1log_D14}    886_D_14_E1.pcap
${PM_counter_D14_1}    M55110C02001
${PMfile_name_D14}    PMFile_D14.xml

##5GC000886_A_02_Secondary_RAT_Data_Usage_Report_by_MN_initiate_SGNB_Release
${s1log_A02}    886_A_02_S1.pcap
${dist_name_A02}    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${parameter_name_A02}    Timer for periodical data usage report
${new_value_A02}    0
${new_value_A02_Back}    10

##5GC000886_D_04_Verify_PMCounter_Secondary_RAT_Data_Usage_Report_by_MN_initiate_SGNB_Release
${E1log_D04}    886_D_04_E1.pcap
@{PM_counter_D04}    M55110C02001
${PMfile_name_D04}    PMFile_D04.xml

##5GC000886_B_04_Secondary_RAT_Data_Usage_Report_Periodical_Enb_actSecRatRep_off_and_on
${enb_dist_B04}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}
${enb_para_B04}    actSecRatRep
${s1log_B04_1}    886_B_04_S1_1.pcap
${s1log_B04_2}    886_B_04_S1_2.pcap
${s1log_B04_3}    886_B_04_S1_3.pcap
##5GC000886_D_12_Secondary_RAT_Data_Usage_Report_Modify_Periodical_Value
${dist_name_D12}    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${parameter_name_D12}    Timer for periodical data usage report
${new_value_D12_1}    20
${new_value_D12_2}    0
${E1log_D12_1}    886_D_12_E1_1.pcap
${E1log_D12_2}    886_D_12_E1_2.pcap

##5GC000886_A_05_Secondary_RAT_Data_Usage_Report_by_SN_initiate_SGNB_Release_UE_inactivity
${dist_name_A05}    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${parameter_name_A05}    Activate inactivity detection for NSA UE
${new_value_A05}    true
${new_value_A05_back}    false
${E1log_A05}    886_A_05_E1.pcap
${s1log_A05}    886_A_05_S1.pcap
${ue_type}     ${tl.ues[0].capabilities[0]}
${ue_index}     0
${sleep_time}    10
${tl_scf_filename_enb}     Full_Configuration_scf_TL349_886_eNB.xml
${filename_attach}    886_B04_attach.pcap
${filename_attach_ENB}    886_B04_attach_enb.pcap
@{allow_fault_list}    7311    7107    7523    4681

*** Test Cases ***
[1]5GC000886_B_04_Secondary_RAT_Data_Usage_Report_Periodical_Enb_actSecRatRep_off_and_on
    [Documentation]
    ...    This case is to verify Secondary RAT Data Usage Report generation and delivery periodical,
    ...    and it is not affected by wether Enb actSecRatRep is on or off.(TL233)
    [Tags]     classical    CRT_TRUNK    RAN_5G    RAN_5G_TDD    SBTS00    CRT_UTE
    [Timeout]    1 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,7523,4681
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Modify the COAM parameter with admin API    parameters=${parameters_AMF_Lock}
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
    Prepare the atten for trunk    value1=${0}    value2=${0}    value3=${0}    value4=${0}
    Prepare the enb atten for trunk    value1=${0}    value2=${0}
    Connect and Modify the parameter on enblte    dist_name=${enb_dist_B04}
    ...    parameter=${enb_para_B04}     value=false
    wait until keyword succeeds    3X    30s
    ...    5GC000886_coam_common_keywords.Attach and check power UE
    ...    ue_type=${ue_type}    filename=${filename_attach}    filename_ENB=${filename_attach_ENB}    4G_check=True
    Start To Capture ENB Logs    filename=${s1log_B04_1}   connection=ENB
    sleep    10s
    Stop and download ENB Logs    filename=${s1log_B04_1}    connection=ENB
    Start To Capture ENB Logs    filename=${s1log_B04_2}   connection=ENB
    Connect and Modify the parameter on enblte    dist_name=${enb_dist_B04}
    ...    parameter=${enb_para_B04}     value=true
    sleep    10s
    Stop and download ENB Logs    filename=${s1log_B04_2}    connection=ENB
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    Analysis ENB_B04 S1 log_1
    Analysis ENB_B04 S1 log_2
    Modify the COAM parameter with admin API    parameters=${parameters_AMF_UnLock}
    [Teardown]    Run Keywords
    ...    Classical_gNB.Common Case Teardown for COAM    AND
    ...    Run Keyword And Ignore Error    5GC000886_coam_common_keywords.Common UE teardown    AND
    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]5GC000886_D_04_Verify_PMCounter_Secondary_RAT_Data_Usage_Report_by_MN_initiate_SGNB_Release
#    [Documentation]
#    ...    This case is to verify the PMcunter of Secondary RAT Data Usage Report generation and delivery triggered by
#    ...    SgNB Release initiated by MN，PM counter name ENDC_X2_SEC_RAT_DATA_USAGE_REP,PI-ID is M55110C02001.
#    [Tags]     classical    CRT_TRUNK    RAN_5G    RAN_5G_TDD    SBTS00    CRT_UTE
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    RUN KEYWORD IF    '${cell_status}'=='FAIL'    5GC000886_coam_common_keywords.Prepare the classical COAM BTS cell onair
#    should be equal    ${cell_status}    PASS
#    sleep    240s
#    Change the COAM parameter online    dist_name=${dist_name_A02}    parameter_name=${parameter_name_A02}    new_value=${new_value_A02}
#    FGCR_4454_common_KW.Precondition for power UE    ue_type=${ue_type}
#    Prepare the atten for trunk    value1=${0}    value2=${0}    value3=${0}    value4=${0}
#    Prepare the enb atten for trunk    value1=${0}    value2=${0}
#    Record the counter action timer for TL356
#    wait until keyword succeeds    1min    30s
#    ...    5GC000886_coam_common_keywords.Attach and check power UE with TL356    ue_type=${ue_type}
#    Start the DL/UL data throughput with TL356    ue_type=${ue_type}    direction=dl    duration=${dl_time}
#    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
#    Start the DL/UL data throughput with TL356    ue_type=${ue_type}    direction=ul
#    ...    duration=${ul_time}   throughput=${ul_throughput}    iperf_port=${ue_ul_port}
#    sleep    15s
#    FGCR_4454_common_KW.Detach for power UE    ue_type=${ue_type}
#    sleep    10s
#    wait until keyword succeeds    10min    10s
#    ...   Check the PM counter should not be zero    counter_id=${PM_counter_D14_1}    exp_result=${1}
#    [Teardown]    Run Keywords
#    ...    Classical_gNB.Common Case Teardown for COAM    AND
#    ...    Run Keyword And Ignore Error    5GC000886_coam_common_keywords.Common UE teardown    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]5GC000886_D_14_verify_Pmconter_Secondary_RAT_Data_Usage_Report_Periodical
#    [Documentation]
#    ...    This case is to verify Secondary RAT Data Usage Report generation and delivery periodical,
#    ...    and after the last DRB from particular UE is deleted,periodical report stop,verify the PM counter v
#    ...    alue is right,PM counter name ENDC_X2_SEC_RAT_DATA_USAGE_REP,PI-ID is M55110C02001
#    [Tags]     classical    CRT_TRUNK    RAN_5G    RAN_5G_TDD    SBTS00    CRT_UTE
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    RUN KEYWORD IF    '${cell_status}'=='FAIL'    5GC000886_coam_common_keywords.Prepare the classical COAM BTS cell onair
#    should be equal    ${cell_status}    PASS
#    FGCR_4454_common_KW.Precondition for power UE    ue_type=${ue_type}
#    Prepare the atten for trunk    value1=${0}    value2=${0}    value3=${0}    value4=${0}
#    Prepare the enb atten for trunk    value1=${0}    value2=${0}
#    wait until keyword succeeds    10x    10s     Start To Capture Wireshark Logs and make sure success
#    ...    filename=${E1log_D14}    connection=gnb    interface=any
#    Record the counter action timer
#    wait until keyword succeeds    1min    30s
#    ...    5GC000886_coam_common_keywords.Attach and check power UE with TL356    ue_type=${ue_type}
#    Start the DL/UL data throughput with TL356    ue_type=${ue_type}    direction=dl    duration=${dl_time}
#    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
#    Start the DL/UL data throughput with TL356    ue_type=${ue_type}    direction=ul
#    ...    duration=${ul_time}   throughput=${ul_throughput}    iperf_port=${ue_ul_port}
#    sleep    15s
#    FGCR_4454_common_KW.Detach for power UE    ue_type=${ue_type}
#    sleep    10s
#    Stop and download Logs    logname=${E1log_D14}   connection=gnb
#    Analysis E1 log_D14
#    ${retry_attach_times}=    convert to integer    ${retry_attach_times}
#    ${Report_Times}=    convert to integer    ${Report_Times}
#    ${Report_Times}=     Evaluate      ${Report_Times}-${retry_attach_times}
#    #sleep    ${pm_utc_left}min
#    wait until keyword succeeds    10min    10s
#    ...    Check the PM counter equal    counter_id=${PM_counter_D14_1}    exp_result=${Report_Times}
#    [Teardown]    Run Keywords
#    ...    Classical_gNB.Common Case Teardown for COAM    AND
#    ...    Run Keyword And Ignore Error    5GC000886_coam_common_keywords.Common UE teardown    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

*** Keywords ***
Common Suite Teardown for UTE Cloud
    5GC000886_coam_common_keywords.Common Suite Teardown for COAM    epc_log_path=${ute_log_path_cloud}
    Connect and save snapshot for enb    epc_log_path=${ute_log_path_cloud}

Tests Recover_A02
    5GC000886_coam_common_keywords.Tests Recover
    Change the COAM parameter online    dist_name=${dist_name_A02}    parameter_name=${parameter_name_A02}    new_value=${new_value_A02_Back}


Tests Recover_B02
    5GC000886_coam_common_keywords.Tests Recover
    Drop License

Tests Recover_D12
    5GC000886_coam_common_keywords.Tests Recover
    Change the COAM parameter online    dist_name=${dist_name_A02}    parameter_name=${parameter_name_A02}
    ...     new_value=${periodicalDataUsageReportTimer}

Tests Recover_A05
    5GC000886_coam_common_keywords.Tests Recover
    Change the COAM parameter online    dist_name=${dist_name_A05}    parameter_name=${parameter_name_A05}    new_value=${new_value_A05_Back}

Tests Recover_B04
    Run keyword and ignore error    FGCR_4454_common_KW.Detach for power UE    ue_type=${ue_type}
    Run keyword and ignore error    Android UE release

Analysis E1 log_B02
    cap.read_cap    cap_file=${epc_log_path}${E1log_B02}    display_filter=x2ap||${e1ap}
    cap.Check Expression    condition_expression=x2ap.e_RAB_ID == 5 and x2ap.secondaryRATType == 0 and x2ap.id == 263
    ##  check the first secondaryRATDataUsageReport start time equal to A
    ${BearerContextSetupRequest} =    Catenate    ip.src == ${gNB_UP_IP} and ${e1ap}.procedureCode == 8
    ${timestamp_BearerSetupReq} =    cap.get_element_value    element_expression=frame_info.time
    ...    condition_expression=${BearerContextSetupRequest}    default_value=${True}      raw_data=${True}
    ${time_BearerSetupReq} =     Caculate the wireshark timevalue to seconds
    ...    input_value=${timestamp_BearerSetupReq}    index=${index0}
    @{startTimeStamp} =    cap.get_element_value    element_expression=x2ap.startTimeStamp
    ...    condition_expression=x2ap.e_RABUsageReportList == 1    default_value=${False}      raw_data=${False}
    @{endTimeStamp} =    cap.get_element_value    element_expression=x2ap.endTimeStamp
    ...    condition_expression=x2ap.e_RABUsageReportList == 1    default_value=${False}      raw_data=${False}
    @{timestamp_SecondaryRATDataUsageReport} =    cap.get_element_value    element_expression=frame_info.time
    ...    condition_expression=x2ap.secondaryRATType == 0    default_value=${True}      raw_data=${True}
    ${time_SecondaryRATDataUsageReport} =     Caculate the wireshark timevalue to seconds
    ...    input_value=${timestamp_SecondaryRATDataUsageReport}    index=${index0}
    ${time_dif} =    evaluate  float(${time_SecondaryRATDataUsageReport})-float(${time_BearerSetupReq})
    ${time_differ} =    convert_to_number    ${time_dif}	0
    should be true    ${time_differ}==${periodicalDataUsageReportTimer}
    ${startTimeStamp1} =    convert_to_number    ${startTimeStamp}[0]
    ${endTimeStamp1} =    convert_to_number    ${endTimeStamp}[0]
    ${time_dif} =    evaluate  float(${endTimeStamp1})-float(${startTimeStamp1})
    should be true    ${time_dif}==${periodicalDataUsageReportTimer}

    ##  check secondaryRATDataUsageReport time differ
    ${time_SecondaryRATDataUsageReport_2} =     Caculate the wireshark timevalue to seconds
    ...    input_value=${timestamp_SecondaryRATDataUsageReport}    index=${index1}
    ${time_dif} =    evaluate  float(${time_SecondaryRATDataUsageReport_2})-float(${time_SecondaryRATDataUsageReport})
    ${time_differ} =    convert_to_number    ${time_dif}	0
    should be true    ${time_differ}==${periodicalDataUsageReportTimer}
    ${startTimeStamp2} =    convert_to_number    ${startTimeStamp}[1]
    ${time_dif} =    evaluate  float(${startTimeStamp2})-float(${startTimeStamp1})
    should be true    ${time_dif}==${periodicalDataUsageReportTimer}
    ${endTimeStamp2} =    convert_to_number    ${endTimeStamp}[1]
    ${time_dif} =    evaluate  float(${endTimeStamp2})-float(${startTimeStamp1})
    should be true    ${time_dif}==2*${periodicalDataUsageReportTimer}

    ##  check the third secondaryRATDataUsageReport time differ
    ${startTimeStamp3} =    convert_to_number    ${startTimeStamp}[2]
    should be true    float(${startTimeStamp3})==float(${startTimeStamp1})+2*${periodicalDataUsageReportTimer}


#Analysis E1 log_D14
    #cap.read_cap    cap_file=${epc_log_path}${E1log_D14}    display_filter=x2ap||${e1ap}
    #@{DataUsageCountUL} =    cap.get_element_value    element_expression=x2ap.usageCountUL
    #...    condition_expression=x2ap.secondaryRATType == 0    default_value=${True}      raw_data=${True}
    #${Report_Times}    Get Length    ${DataUsageCountUL}
   #Set Suite Variable    ${Report_Times}

Analysis E1 log_D14
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${E1log_D14}
    ${filter_expression}=     Catenate    x2ap
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${DataUsageCountUL}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//x2ap.usageCountUL
    ${Report_Times}    Get Length    ${DataUsageCountUL}
    Set Suite Variable    ${Report_Times}

Analysis S1log A02
    cap.read_cap    cap_file=${epc_log_path}${s1log_A02}    display_filter=x2ap||s1ap
    ${ERABModificationIndication} =    Catenate    s1ap.procedureCode == 23 and s1ap.SecondaryRATDataUsageReportList == 1
    @{X2_SecondaryReport_startTime_last} =    cap.get_element_value    element_expression=x2ap.startTimeStamp
    ...    condition_expression=x2ap.procedureCode == 38    default_value=${False}      raw_data=${False}
    ${SecondaryReport_startTime_InErabMod} =    cap.get_element_value    element_expression=s1ap.startTimestamp
    ...    condition_expression=${ERABModificationIndication}    default_value=${False}      raw_data=${False}
    should be true    ${X2_SecondaryReport_startTime_last[-1]}==${SecondaryReport_startTime_InErabMod[0]}

Analysis ENB_B04 S1 log_1
    cap.read_cap      cap_file=${epc_log_path}${s1log_B04_1}    display_filter=(x2ap||s1ap)
    ${result}    Run keyword and ignore error    cap.Check Expression    condition_expression=(ip.dst == ${MME_IP} and s1ap.procedureCode == 62)
    should contain    ${result}    FAIL

Analysis ENB_B04 S1 log_2
    cap.read_cap      cap_file=${epc_log_path}${s1log_B04_2}    display_filter=(x2ap||s1ap)
    cap.Check Expression    condition_expression=(ip.dst == ${MME_IP} and s1ap.procedureCode == 62)

Analysis E1_D12 log_1
    cap.read_cap    cap_file=${epc_log_path}${E1log_D12_1}    display_filter=x2ap||${e1ap}
    @{Secondary_startTimeStamp} =    cap.get_element_value    element_expression=x2ap.startTimeStamp
    ...    condition_expression=x2ap.e_RABUsageReportList == 1    default_value=${False}      raw_data=${False}
    @{Secondary_endTimeStamp} =    cap.get_element_value    element_expression=x2ap.endTimeStamp
    ...    condition_expression=x2ap.e_RABUsageReportList == 1    default_value=${False}      raw_data=${False}
    ${startTimeStamp1} =    convert_to_number    ${Secondary_startTimeStamp}[0]
    ${endTimeStamp1} =    convert_to_number    ${Secondary_endTimeStamp}[0]
    ${time_dif} =    evaluate  float(${endTimeStamp1})-float(${startTimeStamp1})
    should be true    ${time_dif}==20

Analysis E1_D12 log_2
    cap.read_cap      cap_file=${epc_log_path}${E1log_D12_2}    display_filter=x2ap||${e1ap}
    ${result}    Run keyword and ignore error    cap.Check Expression    condition_expression=ip.dst == x2ap.procedureCode == 38
    should contain    ${result}    FAIL

Analysis S1log A05
    cap.read_cap      cap_file=${epc_log_path}${s1log_A05}    display_filter=x2ap||s1ap
    cap.Check Expression    condition_expression=s1ap.procedureCode == 50 and s1ap.SecondaryRATDataUsageReportList == 1

Check Volumn Value between report and UE side_B02
    [Arguments]    ${QXDM_log_name}    ${Log_name}
    ${SumUL_Volum}    ${SumDL_Volum}    Data Usage Report Volumn SUM    ${Log_name}
    ${SumUL_Volum} =    evaluate    ${SumUL_Volum}+2
    ${context} =    Get Binary File     ${epc_log_path}${QXDM_log_name}.txt
    ${regx expression} =    Set variable     Data PDU Bytes[\\w\\|\\s]+\\r\\n[\\w\\|\\#\\s]+\\r\\n[\\-\\s]+\\r\\n([\\d\\|\\s]+)\\r\\n
    ${filter data lines} =    Get Regexp Matches      ${context}    ${regx expression}      1
    ${value_list} =    create list    @{empty}
    FOR    ${data line}    IN    @{filter data lines[::-1]}
        ${filter values} =    Get Regexp Matches     ${data line}     \\d+
        ${item_vaule} =    convert to integer    ${filter values[8]}
        Append to list    ${value_list}    ${item_vaule}
    END
    should contain    ${value_list}    ${SumDL_Volum}
    ${regx expression} =    Set variable     Total Num RX Bytes[\\w\\|\\s]+\\r\\n[\\-\\s]+\\r\\n([\\w\\d\\|\\s]+)
    ${filter data lines} =    Get Regexp Matches      ${context}    ${regx expression}      1
    ${value_list} =    create list    @{empty}
    FOR    ${data line}    IN    @{filter data lines[::-1]}
        ${filter values} =    Get Regexp Matches     ${data line}     \\d+
        ${item_vaule} =    convert to integer    ${filter values[8]}
        Append to list    ${value_list}    ${item_vaule}
    END
    should contain    ${value_list}    ${SumUL_Volum}
