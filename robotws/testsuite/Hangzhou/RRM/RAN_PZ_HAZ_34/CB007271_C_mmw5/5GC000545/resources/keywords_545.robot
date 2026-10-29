*** Settings ***
Documentation     author: Yang Liqin
...               contact: liqin.yang@nokia-sbell.com
...               squad group: MMW_SG_05
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.collectors.snapshot     WITH NAME     snapshot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Library           taf.ul.parser.pcap        WITH NAME    pcap
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/wireshark_for_5gClassicalBTS.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/bip.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/csvanalyzer.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Library      testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.5GC000496_C.Resources.process_data_in_file.HtmlParser     WITH NAME    html
Resource               testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Variables ***
${MRBTS_ID}                          ${tl.gnbs[0].instance_id}
${cell_2}    207
${cell_1}    208
${plan_PA_value}    60
${ue_index}    ${0}
@{btslog_dirs}        /opt/btslog     /opt/ute/tools/btslog      none
${ul_expect}    0.9
${ul_expect_5M}    0.5
${link_to_Artifact_MCshark}    https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/
*** Keywords ***
Test Case Setup
    [Arguments]     ${case_name}
    ${TS_CASE_LOG_PATH}    catenate     SEPARATOR=/    ${PATH_Storage}    ${case_name}
    Set Test Variable    ${TS_CASE_LOG_PATH}
    Clear old log path

    Run keyword And Ignore Error  Remove Files  ${TS_CASE_LOG_PATH}/SCTP/*
    Run Keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}/SCTP
    Run Keyword And Ignore Error  Remove Files  ${TS_CASE_LOG_PATH}/btslog/*
    Run Keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}/btslog
    Run Keywords    Run Keyword And Ignore Error    Remove Files
    ...    ${TS_CASE_LOG_PATH}/SCTP1/*
    ...    AND    Run Keyword And Ignore Error    Remove Files    ${TS_CASE_LOG_PATH}/SCTP2/*
    Run Keywords    Run Keyword And Ignore Error    Remove Directory
    ...    ${TS_CASE_LOG_PATH}/SCTP1
    ...    AND    Run Keyword And Ignore Error    Remove Directory    ${TS_CASE_LOG_PATH}/SCTP2
    Run keyword And Ignore Error  Remove Files  ${TS_CASE_LOG_PATH}/*
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/${case_name}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${onair_status}    Run keyword and Return Status    COAM Check GNB cell on air
    ${exist_fault}    COAM Get active alarms
    Set test variable    ${exist_fault}
    Run keyword If    ${onair_status}==${False}    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20 min
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}    file_path=${TS_CASE_LOG_PATH}
    #${current_scf}=    Get Current SCF file    dir=${log_path}
    #Set test variable    ${current_scf}
    ${date}    Evaluate    datetime.datetime.now().strftime('%Y-%m-%d')    datetime
    Start Btslog With Path Check
    Set test variable    ${date}

Test Case Teardown
    Modify attenuator value      modify_list=@{Original_Value}      port_num=2
    Remove Files    ${OUTPUT_DIR}/*.pdml
    Run keyword And Ignore Error    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_index}
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
    Run keyword And Ignore Error    Collect logs after test    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}    file_path=${TS_CASE_LOG_PATH}
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error    csn.disconnect    connection=RU
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword If Test Passed  Run Keyword And Ignore Error    Remove Files  ${TS_CASE_LOG_PATH}/SCTP/*
    Run Keyword If Test Passed  Run Keyword And Ignore Error    Remove Directory  ${TS_CASE_LOG_PATH}/SCTP
    Run Keyword If Test Passed    Run Keywords    Run Keyword And Ignore Error    Remove Files
    ...    ${TS_CASE_LOG_PATH}/SCTP1/*
    ...    AND    Run Keyword And Ignore Error    Remove Files    ${TS_CASE_LOG_PATH}/SCTP2/*
    Run Keyword If Test Passed  Run Keywords    Run Keyword And Ignore Error    Remove Directory
    ...    ${TS_CASE_LOG_PATH}/SCTP1
    ...    AND    Run Keyword And Ignore Error    Remove Directory    ${TS_CASE_LOG_PATH}/SCTP2
    Run Keyword If Test Passed  Run Keyword And Ignore Error  Remove Files  ${TS_CASE_LOG_PATH}/btslog/*
    Run Keyword If Test Passed  Run Keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}/btslog
    Run Keyword If Test Passed  Run Keyword And Ignore Error    Remove Files  ${TS_CASE_LOG_PATH}/*

Collect logs after test
    [Arguments]    ${SAVE LOG DIRECTORY}
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}


Get Current SCF file
    [Arguments]    ${dir}    ${file_name}=SCF_backup.xml    ${timeout}=600s    ${connection}=GNB_OAM
    ${file}    coam.get_current_scf_file
    ...      local_dir_path=${dir}    file_name=${file_name}    timeout=${timeout}    connection=${connection}
    [Return]    ${file}

UE Attach and Start traffic
    [Arguments]     ${4G_check_needed}=False    ${throughput}=30M    ${duration}=120    ${attach_mode}=5G_SA
    ...    ${physCellId}=${cell_2}    ${protocol}=udp
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}    ue_index=${ue_index}
    Verify attach by adb    physCellId=${physCellId}    attach_mode=${attach_mode}    ue_index=${ue_index}
    Wait Until Keyword Succeeds    5 min    30 sec    power_ue.Verify attach
    ...    ue_type=${ue_type}      4G_check=${4G_check_needed}     5Grach_ed=${5Grach_ed}    ue_index=${ue_index}
    power_ue.Start traffic    direction=ul    throughput=${throughput}    duration=${duration}    ue_type=${ue_type}
    ...    iperf_type=via_command    protocol=${protocol}    ue_index=${ue_index}
    ${cell_id}    Set Variable If    ${physCellId}==${cell_2}    2    1
    sleep  3     reason=Wait for traffic stable
    Wait Until Keyword Succeeds     60s    3s    Check the UL throughput    ul_expected_throughput=0.0001    cell_id=${cell_id}

UE Dettach and Stop traffic
    [Arguments]    ${protocol}=udp
    power_ue.Stop traffic    direction=ul    ue_type=${ue_type}    iperf_type=via_command    protocol=${protocol}    ue_index=${ue_index}
    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_index}

Get value from Attenuator
    [arguments]    ${port_num}      ${ru_id}=0    ${vender}=HBTE
    #attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=${vender}
    ${PA_value}      create list
    FOR      ${n}      IN RANGE      ${port_num}
        ${value}    attenuator.read_attenuation
         ...      port=${tl.gnbs[0].dus[0].rus[${ru_id}].attenuation_ports[${n}]}    attenuator_device=${vender}
        append to list      ${PA_value}      ${value}
    END
    [Return]      ${PA_value}

Modify attenuator value
    [arguments]    ${modify_list}    ${port_num}    ${ru_id}=0    ${vender}=HBTE
    #attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=${vender}
    FOR      ${n}      IN RANGE      ${port_num}
          attenuator.set_attenuation
          ...      port=${tl.gnbs[0].dus[0].rus[${ru_id}].attenuation_ports[${n}]}
          ...      value=${${modify_list}[${n}]}
          ...      attenuator_device=${vender}
    END

Modify attenuator value by port
    [arguments]    ${modify_value}    ${port}    ${ru_id}=0    ${vender}=HBTE
    #attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=${vender}
    attenuator.set_attenuation
    ...      port=${tl.gnbs[0].dus[0].rus[${ru_id}].attenuation_ports[${port}]}
    ...      value=${modify_value}
    ...      attenuator_device=${vender}


Decrease radio conditions by mini step
    [Arguments]    ${target_value}      ${port_num}     ${flag}   ${ru_id}=0
    ${PA_original_value}=      Get value from Attenuator      port_num=${port_num}    ru_id=${ru_id}
    ${Step}      Evaluate    10
    ${port0_value}    Set Variable    ${PA_original_value}[0]
    ${port1_value}    Set Variable    ${PA_original_value}[1]
    ${port0_step}    Run Keyword If  ${ru_id}==0  Evaluate      (${activate_PA_value0}-${PA_original_value}[0])/10
    ...    ELSE    Evaluate      (${tmp_PA_value0}-${PA_original_value}[0])/10
    ${port1_step}    Run Keyword If  ${ru_id}==0  Evaluate      (${activate_PA_value1}-${PA_original_value}[1])/10
    ...    ELSE    Evaluate      (${tmp_PA_value1}-${PA_original_value}[1])/10
    ${port0_activate}    Set Variable If  ${ru_id}==0    ${activate_PA_value0}    ${tmp_PA_value0}
    ${port1_activate}    Set Variable If  ${ru_id}==0    ${activate_PA_value1}    ${tmp_PA_value1}

    Run Keyword If   '${flag}'=='22R3'      Captue Bip log on Loki
    ...    ELSE     Start to collect bip log new   nr_phy_cell_ids=208,207

    FOR      ${i}      IN RANGE      ${Step}
          ${port0_value}      Run keyword if      ${port0_value}<${port0_activate}    Evaluate
          ...      ${port0_step}+${port0_step}*${i}+${PA_original_value}[0]
          Run keyword if      ${port0_value}<=${port0_activate}     Modify attenuator value by port    modify_value=${port0_value}
          ...    port=0    ru_id=${ru_id}
          ${port1_value}      Run keyword if      ${port1_value}<${port1_activate}    Evaluate
          ...      ${port1_step}+${port1_step}*${i}+${PA_original_value}[1]
          Run keyword if      ${port1_value}<=${port1_activate}    Modify attenuator value by port    modify_value=${port1_value}
          ...    port=1    ru_id=${ru_id}
          Run keyword if      ${port0_value}>${port0_activate} and ${port1_value}>${port1_activate}    Exit For Loop
    END
    ${PA_end_value}=      Get value from Attenuator      port_num=${port_num}    ru_id=${ru_id}
    ${cell_id}    Set Variable If    ${ru_id}==0    2    1
    ${ul_tp_status}   run keyword and return status    Check the UL throughput    ul_expected_throughput=0.0001    cell_id=${cell_id}



Improve radio conditions by mini step
    [Arguments]    ${target_value}      ${port_num}     ${flag}    ${ru_id}=0
    ${cell_id}    Set Variable If    ${ru_id}==0    2    1
    ${ul_tp_status_af}   run keyword and return status    Check the UL throughput    ul_expected_throughput=0.0001    cell_id=${cell_id}
    ${PA_original_value}=      Get value from Attenuator      port_num=${port_num}    ru_id=${ru_id}
    ${port0_step}    Evaluate      (${PA_original_value}[0]-${target_value})/10
    ${port1_step}    Evaluate      (${PA_original_value}[1]-${target_value})/10
    ${Step}      Evaluate    10

    Run Keyword If   '${flag}'=='22R3'      Captue Bip log on Loki
    ...    ELSE     Start to collect bip log new     nr_phy_cell_ids=208,207

    FOR      ${i}      IN RANGE      ${Step}
          ${value_tmp}    Evaluate    ${PA_original_value}[0]-${port0_step}-${port0_step}*${i}
          ${port0_value}    Convert To Integer    ${value_tmp}
          Modify attenuator value by port    modify_value=${port0_value}
          ...    port=0    ru_id=${ru_id}
          ${value_tmp}    Evaluate    ${PA_original_value}[1]-${port1_step}-${port1_step}*${i}
          ${port1_value}    Convert To Integer    ${value_tmp}
          Modify attenuator value by port    modify_value=${port1_value}
          ...    port=1    ru_id=${ru_id}
          Run keyword if      ${port0_value}<=${target_value} and ${port1_value}<=${target_value}    Exit For Loop
    END
    ${PA_end_value}=      Get value from Attenuator      port_num=${port_num}    ru_id=${ru_id}
	Set Test Variable    ${ul_tp_status_af}



Enable mirror port on Loki
    [Documentation]    Mirror ABIN traffic to ASIB cpu.
    [Arguments]     ${mirror_port}=eths3    ${backplane_port}=C2B4(2)    ${slot_id}=5    ${asik_alias}=ASIK Master
    ${command1}=      Catenate      /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL
                 ...      -b "${backplane_port}" -s ${slot_id} -l ${mirror_port} -v 303
    ${command2}=      Catenate      /usr/bin//lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL
                 ...      -b "${backplane_port}" -s ${slot_id} -l ${mirror_port} -v 303
    csn.Execute     command=${command1}      connection=${asik_alias}
    csn.Execute     command=${command2}      connection=${asik_alias}
    csn.Execute     command=ncp_portmirror -p xgmac96 -r
    ...             connection=${asik_alias}
    csn.Execute     command=ncp_portmirror -d netdriver -p xgmac96
    ...             connection=${asik_alias}


Start Bip Log Capture
    [Arguments]     ${mirror_port}=eths2    ${asik_alias}=ASIK Master
    keywords_545.Enable mirror port on Loki    mirror_port=${mirror_port}
    csn.Send command     command=tcpdump -i ${mirror_port} -w /tmp/tcpdump_L2L1.pcap
    ...                  connection=${asik_alias}

Captue Bip log on Loki
    Connect to Common Unit Master
    Start Bip Log Capture

Convert BIP Log To CSV
    [Arguments]    ${bip_files}    ${csv_title_list}    ${filter}    ${suffix}=${none}
    ${csv_file}    Replace String    ${bip_files}    .pcap    ${suffix}.csv
    Convert BIP To CSV By MCShark    bip_file=${bip_files}
    ...    output_file=${csv_file}    filter=${filter}    csv_title_list=${csv_title_list}
    [Return]    ${csv_file}

Download MCShark file To UTE
    [Documentation]   Remove existing MCshark, download the SW-version specific MCshark, and retun the path of it
    [Arguments]    ${wirshark_plugin_dir}=/usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan
    ${MCShark}    Run    ls /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan/mcshark-*buster.so
    Connect to gnb coam via ssl
    ${sw_version}    coam.get_sw_version    connection=GNB_OAM
    ${first}    ${rest}    Split String    ${sw_version}    _    1
    ${build_version}    Set Variable If    '_9999_' in '${sw_version}'
    ...    SBTS00_${rest}      ${sw_version}
    ${mcshark_exist}  Run keyword and return status    html.get_download_link_by_ext    url=${link_to_Artifact_MCshark}/${build_version}   ext=so
    ${mcshark_name}   Run keyword If  ${mcshark_exist}  html.get_download_link_by_ext    url=${link_to_Artifact_MCshark}/${build_version}   ext=so
    ${mcshark_download_link}=    Set Variable If  ${mcshark_exist}   ${link_to_Artifact_MCshark}/${build_version}/${mcshark_name}[1]    ${None}
    ${status}    Run Keyword And Return Status    Should Not Be Equal    ${mcshark_download_link}    ${None}
    Run Keyword If    ${status}   Run keywords    Run    sudo rm -f ${MCShark}
    ...    AND    run    command=sudo wget -P ${wirshark_plugin_dir} ${mcshark_download_link}
    [Teardown]    COAM Teardown gnb connections


Get transformPrecoder values in wireshark log
    [Arguments]    ${target_dir}    ${name}=SCTP
    wait until keyword succeeds     2 min       5 s     cap.read_cap
    ...                             cap_file=${target_dir}/${name}/${name}.pcap
    ...                             display_filter=x2ap||f1ap
    ${Message_Type1} =    Catenate    nr-rrc.transformPrecoder == 1
    ${status1}    Run Keyword And Return Status    cap.Check Expression    condition_expression=${Message_Type1}
    ${Message_Type0} =    Catenate    nr-rrc.transformPrecoder == 0
    ${status2}    Run Keyword And Return Status    cap.Check Expression    condition_expression=${Message_Type0}
    [Return]    ${status1}    ${status2}


Check value in csv
    [Arguments]    ${output_csv}    ${item}    ${item_value}
    ${special_item_value_list}    get_the_special_item_value    ${output_csv}    ${item}
    Verify Special Item Value Exist    file_path=${output_csv}    item=${item}
    ...    item_value=${item_value}
    ${not_contain_value_list}    Remove Values From List    ${special_item_value_list}    ${item_value}
    Should Be Equal    ${not_contain_value_list}    ${None}


Check mcs and modulationOrder in csv
    [Arguments]    ${bip_log_path}
    @{csv_title_list}    Create List    frame.time    UlData_puschReceiveReqGrant_t.mcs
    ...    UlData_puschReceiveReqGrant_t.modulationOrder
    Log to console    p1/2-BPSK MCS0 and MCS1
    ${filter1}    Set Variable
    ...  (UlData_puschReceiveReqGrant_t.mcs==0||UlData_puschReceiveReqGrant_t.mcs==1)&&UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag==1
    ${output_csv1}    Convert BIP Log To CSV    bip_files=${bip_log_path}  csv_title_list=${csv_title_list}
    ...    filter=${filter1}    suffix=bpsk1
    ${status}    Get file size    ${output_csv1}
    Run keyword If    ${status}>116    Check value in csv    output_csv=${output_csv1}
    ...    item=UlData_puschReceiveReqGrant_t.modulationOrder    item_value=1

    Log to console    QPSK for MCS2_MCS9
    ${filter1}    Set Variable
    ...  UlData_puschReceiveReqGrant_t.mcs>=2&&UlData_puschReceiveReqGrant_t.mcs<=9&&UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag==1
    ${output_csv1}    Convert BIP Log To CSV    bip_files=${bip_log_path}  csv_title_list=${csv_title_list}
    ...    filter=${filter1}    suffix=qpsk1
    ${status}    Get file size    ${output_csv1}
    Run keyword If    ${status}>116    Check value in csv    output_csv=${output_csv1}
    ...    item=UlData_puschReceiveReqGrant_t.modulationOrder    item_value=2

    Log to console    64 QAM MCS table
    ${filter1}    Set Variable
    ...  UlData_puschReceiveReqGrant_t.mcs>=17&&UlData_puschReceiveReqGrant_t.mcs<=28&&UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag==1
    ${output_csv1}    Convert BIP Log To CSV    bip_files=${bip_log_path}  csv_title_list=${csv_title_list}
    ...    filter=${filter1}    suffix=64qam
    ${status}    Get File Size    ${output_csv1}
    Run keyword If    ${status}>116    Check value in csv    output_csv=${output_csv1}
    ...    item=UlData_puschReceiveReqGrant_t.modulationOrder    item_value=6


Check puschTransformPrecoderFlag in csv
    [Arguments]    ${bip_log_path}
    @{csv_title_list}    Create List    frame.time    UlData_puschReceiveReqGrant_t.ulDmrsAddPos
    ...    UlData_puschReceiveReqGrant_t.numOfLayers
    ...    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
    Log to console    Check puschTransformPrecoderFlag in csv
    ${filter1}    Set Variable    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag==0
    ${output_csv1}    Convert BIP Log To CSV    bip_files=${bip_log_path}  csv_title_list=${csv_title_list}
    ...    filter=${filter1}    suffix=dis
    File Should Not Be Empty    ${output_csv1}
    ${filter1}    Set Variable    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag==1
    ${output_csv1}    Convert BIP Log To CSV    bip_files=${bip_log_path}  csv_title_list=${csv_title_list}
    ...    filter=${filter1}    suffix=en
    Check value in csv    output_csv=${output_csv1}    item=UlData_puschReceiveReqGrant_t.ulDmrsAddPos    item_value=0
    Check value in csv    output_csv=${output_csv1}    item=UlData_puschReceiveReqGrant_t.numOfLayers    item_value=1

Check DCI0_0 and DCI0_1 in csv
    [Arguments]    ${bip_log_path}    ${545_DCI01_size}    ${DCI01_size}    ${DCI00_size}
    @{csv_title_list}    Create List    frame.time    DlData_DciInfo.dciSize
    Log to console    Check DCI in csv
    ${filter1}    Set Variable    dldata_pdcchsendreq
    ${output_csv1}    Convert BIP Log To CSV    bip_files=${bip_log_path}  csv_title_list=${csv_title_list}
    ...    filter=${filter1}    suffix=dci
    File Should Not Be Empty    ${output_csv1}
    Log to console    Check DCI 0_1 for Transform Precoder enabled
    Verify Special Item Value Exist    file_path=${output_csv1}    item=DlData_DciInfo.dciSize    item_value=${545_DCI01_size}
    Log to console    Check DCI 0_1 for Transform Precoder disabled
    Verify Special Item Value Exist    file_path=${output_csv1}    item=DlData_DciInfo.dciSize    item_value=${DCI01_size}
    Log to console    Check DCI 0_0 for Transform Precoder disabled
    Verify Special Item Value Exist    file_path=${output_csv1}    item=DlData_DciInfo.dciSize    item_value=${DCI00_size}

Check puschTransformPrecoderFlag on non_capable_cells in csv
    [Arguments]    ${bip_log_path}
    @{csv_title_list}    Create List    frame.time    UlData_puschReceiveReqGrant_t.ulDmrsAddPos
    ...    UlData_puschReceiveReqGrant_t.numOfLayers
    ...    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
    Log to console    Check puschTransformPrecoderFlag in csv
    ${filter1}    Set Variable    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag==0
    ${output_csv1}    Convert BIP Log To CSV    bip_files=${bip_log_path}  csv_title_list=${csv_title_list}
    ...    filter=${filter1}    suffix=discell
    File Should Not Be Empty    ${output_csv1}
    ${filter2}    Set Variable    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag==1
    ${output_csv2}    Convert BIP Log To CSV    bip_files=${bip_log_path}  csv_title_list=${csv_title_list}
    ...    filter=${filter2}    suffix=encell
    ${size}    Get file size    ${output_csv2}
    should be true    ${size}<=178

Get_parameter_value
    [Arguments]    ${abbr}    ${filter_param}
    ${current_scf}=    Get Current SCF file    dir=${log_path}
    ${mrbtsid}    ${nrbtsid}    ${nrcellid}    get_mrbtsid_from_scf    file_path=${current_scf}
    ${dist_name}    set variable    MRBTS-${mrbtsid}/NRBTS-${nrbtsid}/NRCELL-${nrcellid}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${value}    selenium_coam.get_parameter_value
    ...                                          abbr=${abbr}
    ...                                          filter_param=${filter_param}
    ...                                          dist_name=${dist_name}
    COAM selenium logout
    [Return]    ${value}


Start DLUL traffic and Capture Bip
    [Arguments]       ${PA_value}    ${throughput}    ${duration}    ${ru_id}=0    ${attach_mode}=5G_SA
    ...    ${physCellId}=${cell_2}    ${protocol}=udp
    Modify attenuator value      modify_list=@{Original_Value}      port_num=2     ru_id=0
    UE Attach and Start traffic    throughput=${throughput}    duration=${duration}    attach_mode=${attach_mode}
    ...    protocol=${protocol}

    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS

    #${log_path_local_be}    Capture Bip for Trunk    log_prefix=be    PA_value=${plan_PA_value}    port_num=${2}    ru_id=${ru_id}
    ${log_path_local_be}     Run keyword If  '${release_sbts}'=='SBTS22R3'
    ...    Capture Bip for 22R3    log_prefix=be    PA_value=${plan_PA_value}    port_num=${2}    ru_id=${ru_id}
    ...    ELSE      Capture Bip for Trunk     log_prefix=be    PA_value=${plan_PA_value}    port_num=${2}    ru_id=${ru_id}
    #${log_path_local_af}    Capture Bip for Trunk    log_prefix=af    PA_value=0    port_num=${2}    ru_id=${ru_id}
    ${log_path_local_af}    Run keyword If  '${release_sbts}'=='SBTS22R3'
    ...    Capture Bip for 22R3   log_prefix=af    PA_value=0    port_num=${2}    ru_id=${ru_id}
    ...    ELSE      Capture Bip for Trunk      log_prefix=af    PA_value=0    port_num=${2}    ru_id=${ru_id}
    [Return]    ${log_path_local_be}    ${log_path_local_af}



Confirm the PA value
    [Arguments]    ${protocol}=udp    ${attach_mode}=5G_SA    ${ru_id}=0    ${ul_expected_throughput}=${ul_expect}
    Log to console    Confirm the PA value
    ${ru_tmp}    Set Variable If    ${ru_id}==0    1    0
    Modify attenuator value      modify_list=@{End_Value}      port_num=2     ru_id=${ru_tmp}
    Modify attenuator value      modify_list=@{Original_Value}      port_num=2     ru_id=${ru_id}
    ${cell_tmp}    Set Variable If    ${ru_id}==0    ${cell_2}    ${cell_1}
    UE Attach and Start traffic    throughput=30M    duration=2000    physCellId=${cell_tmp}    attach_mode=${attach_mode}
    ...    protocol=${protocol}
    sleep  5     reason=Wait for traffic stable
    ${cell_id}    Set Variable If    ${ru_id}==0    2    1
    ${ul_tp_status}   run keyword and return status    Check the UL throughput
    ...    ul_expected_throughput=${ul_expect}    cell_id=${cell_id}
    Decrease radio conditions by mini step before testing    target_value=${plan_PA_value}
    ...    port_num=${2}    ru_id=${ru_id}    ul_expected_throughput=${ul_expected_throughput}
    [Teardown]    Run Keywords    run keyword and ignore error        UE Dettach and Stop traffic    protocol=${protocol}
    ...    AND    Modify attenuator value      modify_list=@{End_Value}      port_num=2     ru_id=${ru_id}



Decrease radio conditions by mini step before testing
    [Arguments]    ${target_value}      ${port_num}    ${ru_id}=0    ${ul_expected_throughput}=${ul_expect}
    ${PA_original_value}=      Get value from Attenuator      port_num=${port_num}    ru_id=${ru_id}
    ${Step}      Evaluate    10
    ${port0_value}    Set Variable    ${PA_original_value}[0]
    ${port1_value}    Set Variable    ${PA_original_value}[1]
    ${cell_id}    Set Variable If    ${ru_id}==0    2    1
    FOR      ${i}      IN RANGE      ${Step}
          ${port0_value}      Run keyword if      ${port0_value}<80    Evaluate      8+8*${i}+${PA_original_value}[0]
          Run keyword if      ${port0_value}<=80     Modify attenuator value by port    modify_value=${port0_value}
          ...    port=0    ru_id=${ru_id}
          ${port1_value}      Run keyword if      ${port1_value}<30    Evaluate      3+3*${i}+${PA_original_value}[1]
          Run keyword if      ${port1_value}<=30    Modify attenuator value by port    modify_value=${port1_value}
          ...    port=1    ru_id=${ru_id}
          ${ul_tp_status_be}   run keyword and return status    Check the UL throughput
          ...    ul_expected_throughput=${ul_expected_throughput}    cell_id=${cell_id}
          Run keyword If    '${ul_tp_status_be}'=='False' and ${ru_id}==0  Run Keywords  Set Test Variable  ${activate_PA_value0}  ${port0_value}
          ...    AND    Set Test Variable    ${activate_PA_value1}    ${port1_value}
          ...    AND    Exit For Loop
          Run keyword If    '${ul_tp_status_be}'=='False' and ${ru_id}==1  Run Keywords  Set Test Variable  ${tmp_PA_value0}  ${port0_value}
          ...    AND    Set Test Variable    ${tmp_PA_value1}    ${port1_value}
          ...    AND    Exit For Loop
          Run keyword if      ${port0_value}>80 and ${port1_value}>30    Exit For Loop
    END
    ${cell_id}    Set Variable If    ${ru_id}==0    2    1
    FOR    ${step_value}    IN RANGE    31    ${target_value}
          Run keyword If    '${ul_tp_status_be}'=='False'    Exit For Loop
          Modify attenuator value by port    modify_value=${step_value}
          ...    port=1    ru_id=${ru_id}
          ${ul_tp_status_be}   run keyword and return status    Check the UL throughput
          ...    ul_expected_throughput=${ul_expected_throughput}    cell_id=${cell_id}
          Run keyword If    '${ul_tp_status_be}'=='False' and ${ru_id}==0  Run Keywords  Set Test Variable  ${activate_PA_value1}  ${step_value}
          ...    AND    Set Test Variable    ${activate_PA_value0}    80
          ...    AND    Exit For Loop
          Run keyword If    '${ul_tp_status_be}'=='False' and ${ru_id}==1  Run Keywords  Set Test Variable  ${tmp_PA_value1}  ${step_value}
          ...    AND    Set Test Variable    ${tmp_PA_value0}    80
          ...    AND    Exit For Loop
    END
    ${PA_end_value}=      Get value from Attenuator      port_num=${port_num}    ru_id=${ru_id}



Start DLUL traffic and Capture Bip for HO
    [Arguments]       ${PA_value}    ${throughput}    ${duration}
    Modify attenuator value      modify_list=@{Original_Value}      port_num=2     ru_id=1
    Log To Console    Capture Wireshark Log From gnb
    Start to collect wireshark log for ASIB    name=SCTP1
    UE Attach and Start traffic    throughput=${throughput}    duration=${duration}    physCellId=${cell_1}

    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS

    ${log_path_local_1_be}   Run keyword If  '${release_sbts}'=='SBTS22R3'
    ...    Capture Bip for 22R3      log_prefix=be    PA_value=${PA_value}    port_num=${2}    ru_id=1
    ...    ELSE      Capture Bip for Trunk   log_prefix=be    PA_value=${PA_value}    port_num=${2}    ru_id=1

    Check the UL throughput    ul_expected_throughput=0.0001    cell_id=1
    Start to collect wireshark log for ASIB    name=SCTP2
    Modify attenuator value      modify_list=@{Original_Value}      port_num=2     ru_id=0
    Verify attach by adb    physCellId=${cell_2}    attach_mode=5G_SA    ue_index=${ue_index}
    #${log_path_local_be}    Capture Bip for Trunk    log_prefix=be    PA_value=${PA_value}    port_num=${2}    ru_id=0
    ${log_path_local_be}     Run keyword If  '${release_sbts}'=='SBTS22R3'
    ...    Capture Bip for 22R3    log_prefix=be    PA_value=${PA_value}    port_num=${2}    ru_id=0
    ...    ELSE    Capture Bip for Trunk    log_prefix=be    PA_value=${PA_value}    port_num=${2}    ru_id=0
    #${log_path_local_af}    Capture Bip for Trunk    log_prefix=af    PA_value=0    port_num=${2}    ru_id=0
    ${log_path_local_af}     Run keyword If  '${release_sbts}'=='SBTS22R3'
    ...    Capture Bip for 22R3    log_prefix=af    PA_value=0    port_num=${2}    ru_id=0
    ...    ELSE    Capture Bip for Trunk     log_prefix=af    PA_value=0    port_num=${2}    ru_id=0

    [Return]    ${log_path_local_1_be}    ${log_path_local_be}    ${log_path_local_af}
    [Teardown]    run keyword and ignore error    Run Keywords    Stop collecting wireshark log
    ...    target_dir=${TS_CASE_LOG_PATH}    name=SCTP1
    ...    AND    Stop collecting wireshark log
    ...    target_dir=${TS_CASE_LOG_PATH}    name=SCTP2


Clear old log path
    csn.connect to
    ...               hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=test
    #${TS_CASE_LOG_PATH}/l1l2bip

    csn.send_command    command=sudo rm -rf ${TS_CASE_LOG_PATH}/l1l2bip/*    connection=test
    Sleep    10s
    csn.disconnect    connection=test


#Start to collect bip log new
#
#    ${webservice}=  Create Dictionary
#    ...  host=192.168.255.129
#    ...  user=Nemuadmin
#    ...  password=nemuuser
#    ...  port=443
#
#    create_interface_mirroring_l1l2bip_collector
#    ...  name=l1l2bip
#    ...  webservice=${webservice}
#    ...  nr_phy_cell_ids=208,207
#    ...  timeout=500
#
#
#    core.setup_collectors    names=l1l2bip
#    core.start_collectors    names=l1l2bip
#    core.Set Suite Alias     l1l2bip
#
#Stop to collect bip log new
#    [Arguments]    ${target_dir}
#    core.stop_collectors    names=l1l2bip
#    core.collect_collectors    names=l1l2bip       target_dir=${target_dir}
#    core.teardown_collectors    names=l1l2bip
#
#
#Get BIP File List
#    [Arguments]    ${log_path}   ${connection}=UTE_CON      ${bip_prefix}=BTS1910_2011_mirroring_L2L1
#    csn.connect to
#    ...               hostname=${tl.test_pc.default_ssh_connection_details.addr}
#    ...               username=${tl.test_pc.default_ssh_connection_details.username}
#    ...               password=${tl.test_pc.default_ssh_connection_details.password}
#    ...               alias=UTE_CON
#
#    @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${log_path}    connection=${connection}
#    ...    file_indicator=${bip_prefix}*
#    should not be empty  ${list_log_names}   msg=No bip logs found with log prefix tcpdumpL2L1Bip
#    Sort List    ${list_log_names}
#
#    @{list_log_path_local}    Create list
#    FOR  ${log_name}  IN  @{list_log_names}
#      Append to list    ${list_log_path_local}    ${log_path}/${log_name}
#      sleep    1s
#    END
#
#    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
#    Set Suite Variable    ${list_log_path_local_all}    ${log_path}/${timestamp}.pcap
#    Run   mergecap -w ${list_log_path_local_all} ${log_path}/${bip_prefix}*
#    sleep  120s
#    Run   rm -rf ${log_path}/${bip_prefix}*
#    [Return]    ${list_log_path_local_all}


Capture Bip for 22R3
    [Arguments]    ${log_prefix}    ${PA_value}    ${port_num}    ${ru_id}   ${flag}=22R3
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${ret}    Run Keyword And Return Status    Should Contain    ${log_prefix}    be
    Run keyword If    ${ret}    Decrease radio conditions by mini step      target_value=${PA_value}
    ...    port_num=${2}    ru_id=${ru_id}    flag=${flag}
    ...    ELSE    Improve radio conditions by mini step    target_value=${PA_value}
    ...    port_num=${2}    ru_id=${ru_id}    flag=${flag}
    ${log_path_local}    Run Keyword And Ignore Error
    ...    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    ...    log_path=${TS_CASE_LOG_PATH}    log_prefix=${log_prefix}
    #Run keyword If    ${ret}    should be true    ${ul_tp_status_be}
	  #...    ELSE    should be true    ${ul_tp_status_af}
    ${log_path_local}    Evaluate    "".join(${log_path_local[1]})
    #${log_path_local}    Evaluate    ${log_path_local[1]}
    [Return]    ${log_path_local}



Capture Bip for Trunk
    [Arguments]    ${log_prefix}    ${PA_value}    ${port_num}    ${ru_id}   ${flag}=Trunk
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${ret}    Run Keyword And Return Status    Should Contain    ${log_prefix}    be
    Run keyword If    ${ret}    Decrease radio conditions by mini step      target_value=${PA_value}
    ...    port_num=${2}    ru_id=${ru_id}   flag=${flag}
    ...    ELSE    Improve radio conditions by mini step    target_value=${PA_value}
    ...    port_num=${2}    ru_id=${ru_id}   flag=${flag}

#    ${log_path_local}    Run Keyword And Ignore Error
#    ...    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
#    ...    log_path=${TS_CASE_LOG_PATH}    log_prefix=${log_prefix}
    Stop to collect bip log new     target_dir=${TS_CASE_LOG_PATH}
    ${log_path_local}     Get BIP File List    log_path=${TS_CASE_LOG_PATH}/l1l2bip

    [Return]    ${log_path_local}


Check the UL throughput
    [Arguments]    ${ul_expected_throughput}    ${cell_id}=${cell1_id}    ${sample}=${5}
    Run Keyword And Continue On Failure   power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${ul_expected_throughput}
    ...    cellid=${cell_id}    ue_index=${ue_index}    sample=${sample}

Check transformPrecoder Value In wireshark log
    [Arguments]    ${values}
    Should Be True    ${values}

Check result on transform Precoder capable cell
    [Arguments]    ${log_path_local}    ${545_DCI01_size}    ${DCI01_size}    ${DCI00_size}
    Run Keyword And Continue On Failure    Check puschTransformPrecoderFlag in csv    bip_log_path=${log_path_local}
    Run Keyword And Continue On Failure    Check mcs and modulationOrder in csv    bip_log_path=${log_path_local}
    Run Keyword And Continue On Failure    Check DCI0_0 and DCI0_1 in csv    bip_log_path=${log_path_local}    545_DCI01_size=${545_DCI01_size}
    ...    DCI01_size=${DCI01_size}    DCI00_size=${DCI00_size}


Check wireshark and bip log on transform Precoder capable cell
    [Arguments]    ${log_path_local_be}    ${log_path_local_af}    ${545_DCI01_size}    ${DCI01_size}    ${DCI00_size}
    ...    ${expect_enable}=${none}    ${expect_disable}=${none}    ${name}=SCTP
    Log To Console    Analyzing the bip log
    Check result on transform Precoder capable cell    log_path_local=${log_path_local_be}    545_DCI01_size=${545_DCI01_size}
    ...    DCI01_size=${DCI01_size}    DCI00_size=${DCI00_size}
    Run Keyword And Return Status    Check result on transform Precoder capable cell    log_path_local=${log_path_local_af}
    ...    545_DCI01_size=${545_DCI01_size}    DCI01_size=${DCI01_size}    DCI00_size=${DCI00_size}
    Log To Console    Get transformPrecoder values in wireshark log
    ${status1}    ${status2}    Get transformPrecoder values in wireshark log    target_dir=${TS_CASE_LOG_PATH}    name=${name}
    Log To Console    Check transformPrecoder disable In wireshark log
    Run Keyword And Continue On Failure    Check transformPrecoder Value In wireshark log    values=${status1}
    Log To Console    Check transformPrecoder enable In wireshark log
    Run Keyword And Continue On Failure    Check transformPrecoder Value In wireshark log    values=${status2}




Check wireshark and bip log on non transform Precoder capable cell
    [Arguments]    ${log_path_local}
    Run Keyword And Continue On Failure    Check puschTransformPrecoderFlag on non_capable_cells in csv    bip_log_path=${log_path_local}
    Log To Console    Get transformPrecoder values in wireshark log
    ${status1}    ${status2}    Get transformPrecoder values in wireshark log    target_dir=${TS_CASE_LOG_PATH}    name=SCTP1
    Log To Console    Check transformPrecoder disable In wireshark log
    ${status1}    Run Keyword and return status    Check transformPrecoder Value In wireshark log    values=${status1}
    Run Keyword And Continue On Failure    Should Be True    ${status1}
    Log To Console    Check transformPrecoder enable In wireshark log
    ${status2}    Run Keyword And Return Status    Check transformPrecoder Value In wireshark log    values=${status2}
    Run Keyword And Continue On Failure    Should Not Be True    ${status2}

Preconditon for testing
    [Arguments]    ${SCF_name}
    ${SCFPath}=                        catenate            ${CURDIR}/SCFs
    scf.scf uploading and commissioning    ${SCFPath}    ${SCF_name}
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    Modify attenuator value      modify_list=@{End_Value}      port_num=2     ru_id=1
    Modify attenuator value      modify_list=@{End_Value}      port_num=2     ru_id=2
    power_ue.Prepare UE      ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Ignore Error  UE Dettach and Stop traffic    protocol=tcp


Transform Precoder activation
    [Arguments]    ${target_dir}    ${attach_mode}=5G_SA    ${physCellId}=${cell_2}    ${protocol}=udp
    Log To Console    Capture Wireshark Log From gnb
    Start to collect wireshark log for ASIB
    Log To Console    Gathering L1L2 log
    ${log_path_local_be}    ${log_path_local_af}    Start DLUL traffic and Capture Bip
    ...      PA_value=${plan_PA_value}    throughput=30M    duration=200    attach_mode=${attach_mode}    physCellId=${physCellId}
    ...    protocol=${protocol}
    [Return]    ${log_path_local_be}    ${log_path_local_af}
    [Teardown]  Run Keywords  Stop collecting wireshark log    target_dir=${TS_CASE_LOG_PATH}
    ...  AND  Run Keyword And Ignore Error  UE Dettach and Stop traffic    protocol=${protocol}

Transform_Precoder_activation_64QAM_SA_UE
    Preconditon for testing    SCF_name=${SCF_545_B_01}
    Confirm the PA value
    ${log_path_local_be}    ${log_path_local_af}    Transform Precoder activation    target_dir=${TS_CASE_LOG_PATH}
    Check wireshark and bip log on transform Precoder capable cell    log_path_local_be=${log_path_local_be}
    ...    log_path_local_af=${log_path_local_af}    545_DCI01_size=${545_10M_DCI01_size}    DCI01_size=${10M_DCI01_size}
    ...    DCI00_size=${10M_DCI00_size}


Successul_SA_UE_handover_between_Transform_Precoder_capable_and_non-capable_cells
    Preconditon for testing    SCF_name=${SCF_545_B_02}
    Confirm the PA value    ul_expected_throughput=0.4
    Confirm the PA value    ru_id=1    ul_expected_throughput=2
    Log To Console    Attenuate set as 0 on first cell
    Modify attenuator value      modify_list=@{End_Value}      port_num=2     ru_id=0
    Log To Console    Gathering L1L2 log
    ${log_path_local_1_be}    ${log_path_local_be}    ${log_path_local_af}    Start DLUL traffic and Capture Bip for HO
    ...    PA_value=${plan_PA_value}    throughput=30M    duration=300
    UE Dettach and Stop traffic

    Log To Console    Checking ulTransPrecodeOnSinrThresh on cell doesn't support DFT-S-OFDM feature
    Check wireshark and bip log on non transform Precoder capable cell    log_path_local=${log_path_local_1_be}
    Log To Console    Checking ulTransPrecodeOnSinrThresh on cell support DFT-S-OFDM feature
    Check wireshark and bip log on transform Precoder capable cell    log_path_local_be=${log_path_local_be}
    ...    log_path_local_af=${log_path_local_af}    545_DCI01_size=${545_5M_DCI01_size}    DCI01_size=${5M_DCI01_size}
    ...    DCI00_size=${5M_DCI00_size}    name=SCTP2


Dynamic_Transform_Precoder_Switching_NSA_UE_DCI_0_1_20MHz_SRB3_TCP_Open_Loop_MIMO
    Preconditon for testing    SCF_name=${SCF_545_B_03}
    scf.gNB Get CellId and BTSId DN in SCF
    Log To Console    Lock AMF
    ${dist_name_1}    BuiltIn.Set Variable    ${CV_NRBTS}/SERVEDAMF-1
    scf.Activate Parameter Value    dist_name=${dist_name_1}    p_name=administrativeState    new_value=Locked
    Log To Console    Setting SRB3 at gNB
    scf.Activate Parameter Value    dist_name=${CV_NRBTS}    p_name=srb3SupportEnabled    new_value=true
    Confirm the PA value    protocol=tcp    attach_mode=5G_NSA
    Log To Console    Gathering L1L2 log
    ${log_path_local_be}    ${log_path_local_af}    Transform Precoder activation    target_dir=${TS_CASE_LOG_PATH}
    ...    attach_mode=5G_NSA    protocol=tcp

    Log To Console    Setting SRB3 at gNB
    scf.Activate Parameter Value    dist_name=${CV_NRBTS}    p_name=srb3SupportEnabled    new_value=false

    Log To Console    Analyzing the results
    Check wireshark and bip log on transform Precoder capable cell    log_path_local_be=${log_path_local_be}
    ...    log_path_local_af=${log_path_local_af}    545_DCI01_size=${545_20M_DCI01_size}    DCI01_size=${20M_DCI01_size}
    ...    DCI00_size=${20M_DCI00_size}
    [Teardown]    Run keyword and ignore error    scf.Activate Parameter Value    dist_name=${dist_name_1}
    ...    p_name=administrativeState    new_value=Unlocked

Dynamic_Transform_Precoder_Switching_SA_UE_DCI_0_1_5MHz_UDP
    Preconditon for testing    SCF_name=${SCF_545_B_04}
    Confirm the PA value    ul_expected_throughput=${ul_expect_5M}
    ${log_path_local_be}    ${log_path_local_af}    Transform Precoder activation    target_dir=${TS_CASE_LOG_PATH}
    Check wireshark and bip log on transform Precoder capable cell    log_path_local_be=${log_path_local_be}
    ...    log_path_local_af=${log_path_local_af}    545_DCI01_size=${545_5M_DCI01_size}    DCI01_size=${5M_DCI01_size}
    ...    DCI00_size=${5M_DCI00_size}
