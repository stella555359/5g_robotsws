*** Settings ***
Documentation     Author: Chen Yin
...               Email: yin.1.chen@nokia-sbell.com
...               Squad group: SG_02
Force Tags         5G_RRM
...    PY36
Suite Setup       Setup enviornment with relevant configuration    scf_path=545_SCF.xml
Suite Teardown       robot_common_operations.Common Suite Teardown
Library            OperatingSystem
Library            Collections
Library            BuiltIn
Library            String
Library            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource           Resources/5GC000545_common_keyword.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot


*** Variables ***
${ue_index}     0
${ul_port}     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
${puschreceivereq_msg}      \"uldata_puschreceivereq&&3gpp.rnti!=65521\"
${command_template_puschreceivereq_msg}      {tshark_path} -r {pcap_file} -Y
...      ${puschreceivereq_msg} -T pdml
${puschreceiverRespHarqU_msg}      \"uldata_puschreceiverespharqul1sw\"
${command_template_puschreceiverRespHarqU_msg}      {tshark_path} -r {pcap_file}
...      -Y ${puschreceiverRespHarqU_msg} -T pdml
${SCF_545_C_01}     ${commissionings_path}/HGZ/${testline_name}/SCF_545_C_01.xml
${tshark_path}    /usr/bin/tshark
${pusch_mcs_filed_name}    UlData_puschReceiveReqGrant_t.mcs
${uldmrsflag_filed_name}    UlData_puschReceiveReqGrant_t.numOfDmrsCdmGroupWithoutData
${uldmrsflag_filed_name_filter}      UlData_puschReceiveReqGrant_t.numOfDmrsCdmGroupWithoutData==1
${puschTransformPrecoderFlag_field_name}    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
${puschTransformPrecoderFlag_field_enable_filter}    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag==1
${command_template_puschreceivereq_enable_msg}      {tshark_path} -r {pcap_file} -Y
...      ${puschTransformPrecoderFlag_field_enable_filter} -T pdml
${command_template_msg}      {tshark_path} -r {pcap_file}
...       -T pdml -Y
${TS_LOG_PATH_BASE}       ${OUTPUT DIR}/Case_Logs


*** Test Cases ***
[1]5GC000545_C_001_dynamic_transform_precoder_switching_successfully_in_SA_mode
    [Tags]    5GC000545-C      CIT_TRUNK
    [Setup]     Test Case Setup
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    Set test variable    ${ue_type}
    ${log_path_local}=      Start DLUL traffic and Capture Bip      PA_value=70
    ${bip_path}      Evaluate     "".join(${log_path_local[1]})
    ${packets}    Load BIP with Luashark    bip_file=${bip_path}
    ...           command_template=${command_template_puschreceivereq_enable_msg}
    ${rnti_list}    pcap.get_field_value_by_name    pdml_list=${packets}
    ...      field_name=_3gpp.rnti
    Set Test Variable    ${rnti}    ${rnti_list}[0]
    ${puschreceivereq_msg}    Set Variable    \"uldata_puschreceivereq and 3gpp.rnti==${rnti}\"
    ${packets}    Load BIP with Luashark    bip_file=${bip_path}
    ...           command_template=${command_template_msg} ${puschreceivereq_msg}
    ${status}=      Run keyword and return status      Verify puschTransformPrecode status in BIP
    ...      packets=${packets}      expect_staus='enable'
    Run Keyword And Continue On Failure    Run Keyword If      ${status}==False      Fail
    ...    Failed, puschTransformPrecode flag checks failed.j
    Run Keyword And Continue On Failure    Check UL DMRS enable
    Run Keyword And Continue On Failure    Check 7782 case keypoints
    ...                          ulDmrsMappingType=0
    ...                          ulDmrsTypeAPos=2
    ...                          ulDmrsAddPos=1
    ...                          ulPtrsFlag=1
    ...                          ulPtrsTimeDensity=1
    ...                          ulPtrsFrequencyDensity=4
    ...                          numOfLayers=1
    [Teardown]  Test Case Teardown

[1][1.0] 5GC000545_C_025_DFT-S-OFDM_activation_in_SA_mode
    [Tags]    5GC000545-C      CIT_TRUNK
    [Setup]     Test Case Setup
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    Set test variable    ${ue_type}
    ${Original_Value}    Get value from Attenuator    port_num=${4}
    Set Test variable    ${Original_Value}
    power_ue.Prepare UE      ue_type=${ue_type}      ui_version=S24UI5.1
    UE Attach and Start traffic
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Start Bip Log with Suitable Means      target_file_name=l1l2bip_log_${date}
    Modidy Attenuator by step      target_value=${70}      port_num=${4}
    Modidy Attenuator by decrease steps      target_value=${Original_Value}      port_num=${4}
    UE Dettach and Stop traffic
    ${log_path_local}    Run Keyword And Ignore Error    Stop Bip Log with Suitable Means
    ...    target_file_name=l1l2bip_log_${date}
    ${bip_path}      Evaluate     "".join(${log_path_local[1]})
    ${packets}=      Load BIP with Luashark      bip_file=${bip_path}
    ...      command_template=${command_template_puschreceiverRespHarqU_msg}
    Run Keyword And Continue On Failure    Verify DTX and CRC in HarqU message      package=${packets}
    [Teardown]  Test Case Teardown

[1][1.0] 5GC000545_C_003_DFT-S-OFDM_activation_AZQO_Non-BF_in_SA_mode_bandwith_80M
    [Tags]    5GC000545-C      CIT_TRUNK
    [Setup]     Test Case Setup
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    Set test variable    ${ue_type}
    ${log_path_local}=      Start DLUL traffic and Capture Bip      PA_value=70    throutput=3M
    ${bip_path}      Evaluate     "".join(${log_path_local[1]})
    ${packets}    Load BIP with Luashark    bip_file=${bip_path}
    ...           command_template=${command_template_puschreceivereq_enable_msg}
    ${rnti_list}    pcap.get_field_value_by_name    pdml_list=${packets}
    ...      field_name=_3gpp.rnti
    Set Test Variable    ${rnti}    ${rnti_list}[0]
    ${puschreceivereq_msg}    Set Variable    \"uldata_puschreceivereq and 3gpp.rnti==${rnti}\"
    ${packets}    Load BIP with Luashark    bip_file=${bip_path}
    ...           command_template=${command_template_msg} ${puschreceivereq_msg}
    ${status}=      Run keyword and return status      Verify puschTransformPrecode status in BIP
    ...      packets=${packets}      expect_staus='enable'
    Run Keyword And Continue On Failure    Run Keyword If      ${status}==False      Fail
    ...    Failed, puschTransformPrecode flag checks failed.
    [Teardown]  Test Case Teardown

*** Keywords ***
Start DLUL traffic and Capture Bip
    [Arguments]       ${PA_value}    ${throutput}=150M
    ${Original_Value}    Get value from Attenuator    port_num=${4}
    Set Test variable    ${Original_Value}
    power_ue.Prepare UE      ue_type=${ue_type}      ui_version=S24UI5.1
    UE Attach and Start traffic    TPut=${throutput}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${date}    Evaluate    datetime.datetime.now().strftime('%Y%m%d%H%M%S')    datetime
    Start Bip Log with Suitable Means      target_file_name=l1l2bip_log_${date}
    Modidy Attenuator by step      target_value=${PA_value}      port_num=${4}
    UE Dettach and Stop traffic
    ${log_path_local}    Run Keyword And Ignore Error    Stop Bip Log with Suitable Means
    ...    target_file_name=l1l2bip_log_${date}
    [Return]    ${log_path_local}

Setup enviornment with relevant configuration
    [Arguments]   ${scf_path}
    ...    ${cur_relative_dir}=testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000545
    robot_common_operations.Common Suite Setup
    COAM Navigate to login page via webUI    download_dir=${OUTPUT DIR}
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    @{stream_list}=    Split String    ${current_version['Active']}    _    3
    ${steam}       Set Variable If      '${stream_list}[2]'=='9999'      SBTS00
    ...      ${stream_list}[0]
    Connect to gnb coam via ssl
    ${exist_fault}    COAM Get active alarms
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    Commissioning with Template Commission      scf_file=${scf_base_path}/7_5_UTE5G402T555/${steam}/${scf_path}
    [Teardown]  Selenium Logout And Close Browser

Test suite teardown
    [Arguments]   ${scf_path}
    ...    ${cur_relative_dir}=testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000545
    COAM Navigate to login page via webUI    download_dir=${OUTPUT DIR}
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    @{stream_list}=    Split String    ${current_version['Active']}    _    3
    ${steam}       Set Variable If      '${stream_list}[2]'=='9999'      SBTS00
    ...      ${stream_list}[0]
    Connect to gnb coam via ssl
    ${exist_fault}    COAM Get active alarms
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    Commissioning with Template Commission      scf_file=${scf_base_path}/7_5_UTE5G402T555/${steam}/${scf_path}
    robot_common_operations.Common Suite Teardown
