*** Settings ***
Documentation     author: Bijiajian
...               contact: Jiajian.bi@nokia-sbell.com
...               squad group: SG_02
Suite Setup       Common Suite Setup for COAM
Suite Teardown    Common Suite Teardown
Force Tags        5G_RRM    QCD_MN_RAN    QCP_RAN_ST
...     PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/Resource_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          Resources/1347_common_keyword.robot
Resource          Resources/common_keyword_RRM_SG2.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_logs_Capture.robot
Library    taf.converters.twdecoder

*** Variables ***
${mcs_ip}    ${tl.mcses[0].ip_addr}
${mcs_model}    ${tl.mcses[0].model}
${tmp_swconfig_dir}    /home/ute/Downloads/SCF/swconfig.txt
${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs

${scf_path}    /home/ute/Downloads/SCF

@{beam_set_16D8U_horizontal}   -50.6   -50.6   -50.6   -50.6   -10.5   -10.5   -10.5   -10.5   10.5   10.5   10.5   10.5
...   50.6   50.6   50.6   50.6
@{beam_set_16D8U_vertical}   95.9   95.9   89.1   89.1   100.8   100.8   107.4   107.4   105.7   105.7   86.3   86.3
...   95.9   95.9   102.4  102.4
${tshark_path}    /usr/bin/tshark
@{num1}    0    1    2    3
@{num2}    4    5    6    7
@{num3}    0    2
${type}    nokia_fastmile

@{ue_suc}    0    1    2    3    4    5    6    7

@{check_print}    ERR/

*** Test Cases ***
CB007112_5G_A_1_L1_and_L2RT_instances_startup_successfully_based_on_internal_cell_set_ABIO
    [Tags]    CRT    CB007112
    [Setup]    Case Setup
    #MCS Set angle    horizontal_set=${beam_set_16D8U_horizontal}    vertical_set=${beam_set_16D8U_vertical}
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/CB007112.xml
    FOR    ${ue_index}    IN    @{num1}
        Reboot cpe for test    ue_index=${ue_index}
    END
    FOR    ${ue_index}    IN    @{num2}
        Reboot cpe for test    ue_index=${ue_index}
    END
    Sleep    1min
    Run Keyword And Continue On Failure    Multi UE Attach And Send Traffic
    Check counter    count=M55308C00001
    ...    count_path=[TL215] MRBTS-1031/NRBTS-1031/[N78Cell2] NRCELL-601/NCELA/DL_DATA_SLOTS
    Check counter    count=M55308C10005
    ...    count_path=[TL215] MRBTS-1031/NRBTS-1031/[N78Cell2] NRCELL-601/NCELA/PRB_AVAIL_PDSCH_BB_POOL
    Check counter    count=M55308C10003
    ...    count_path=[TL215] MRBTS-1031/NRBTS-1031/[N78Cell2] NRCELL-601/NCELA/PRB_AVAIL_PDSCH
    Check counter    count=M55308C10001
    ...    count_path=[TL215] MRBTS-1031/NRBTS-1031/[N78Cell2] NRCELL-601/NCELA/PRB_USED_PDSCH
    Check counter    count=M55308C17001
    ...    count_path=[TL215] MRBTS-1031/NRBTS-1031/[N78Cell2] NRCELL-601/NCELA/ACC_SCHED_UE_PDSCH
    [Teardown]    Case Teardown

CB007112_modify_celltype
    [Tags]    CRT    CB007112
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/CB007112.xml
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Modify parameter online 16D4U
    Wait until keyword succeeds    5 min    5 s    Delete Mo online 16D4U
    Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}
    Modify parameter online 8D8U
    Wait until keyword succeeds    5 min    5 s    Delete Mo online 8D8U
    Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}
    Modify parameter online 8D4U
    Wait until keyword succeeds    5 min    5 s    Delete Mo online 8D4U
    Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}
    Modify parameter online 4D4U
    Wait until keyword succeeds    5 min    5 s    Delete Mo online 4D4U
    Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}
    [Teardown]    Case Teardown without stop traffic

[1]CB010513_I_1_CB007112_E_Load-based_PRB_Pooling_with_Zero_Allocation_Bypass
    [Tags]    CRT    CB010513
    [Setup]    Case Setup
    #MCS Set angle    horizontal_set=${beam_set_16D8U_horizontal}    vertical_set=${beam_set_16D8U_vertical}
    #Recover swconfig file
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/CB010513.xml
    Reboot cpe for test    ue_index=${5}
    Sleep    1min
    Single UE Attach And Send Traffic
    Single UE GBR Call And Send Traffic
#    Check TTI Log    TTI_path=${tti_log_path_GBR}/format_output_dl.csv    filte_item=dlPsCellGbrLoadIndData
    Check gbrPrbLoad in TTI Log    log_file=${tti_log_path_GBR}/tcpdump_ttitrace_pcap_parqCsv_dl_0.csv
    [Teardown]    Case Teardown GBR


*** Keywords ***
Common Suite Setup for COAM
    Connect to gnb coam via ssl
    robot_common_operations.Common Suite Setup
    check pdl after sw update    download_dir=/home/ute/Downloads

Common Suite Teardown
    robot_common_operations.Common Suite Teardown
    #Reload Case SCF and Commission    scf_file=/home/ute/Downloads/SCF/T215_AEHC_AQQY.xml

Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    robot_common_operations.Common Case Setup
    Set Test Variable     ${version}     ${result}[0]

Case Teardown
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run keyword and ignore error    Multi UE Stop Traffic
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

Case Teardown without stop traffic
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

Case Teardown GBR
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run keyword and ignore error    recover ue apn
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

Common UE Attach and traffic
    [Arguments]    ${ue_index}=${0}    ${duration}=1800    ${dl_tp}=1500M    ${ul_tp}=150M    ${pci}=484
    log to console    \n***Attach UE_${ue_index}***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    log_type=Iperf    pci=${pci}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${duration}
    ...    ue_index=${ue_index}    process_num=5

Multi UE Attach And Send Traffic
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[1]
    ${cell2}    Create list    ${cells}[2]
	@{ue_suc}    Create list
    FOR    ${ue_index}    IN    @{num1}
        ${status}    Run Keyword And Return Status    Common UE Attach and traffic    ue_index=${ue_index}    duration=6000    pci=485
        Run keyword if    ${status}    Append to list    ${ue_suc}    ${ue_index}
    END
    FOR    ${ue_index}    IN    @{num2}
        ${status}    Run Keyword And Return Status    Common UE Attach and traffic    ue_index=${ue_index}    duration=6000
    ...                                                                               dl_tp=500M    ul_tp=50M    pci=484
        Run keyword if    ${status}    Append to list    ${ue_suc}    ${ue_index}
    END
#    &{tti_log_path}    Capture TTI log
    Connect to gnb coam via ssl
    ${tti_log_path}    Capture And Decode TTitrace Log TTI2    duration=0.1
    Run Keyword And Continue On Failure    Check DL UL Throughput On Site    cells=${cell1}    dl_target=2700    ul_target=120
    Run Keyword And Continue On Failure    Check DL UL Throughput On Site    cells=${cell2}    dl_target=500    ul_target=50
#    Check TTI Log 601    TTI_path=${tti_log_path}/format_output_dl.csv    filte_item=dlTdSchedSubcellData
#	Check TTI Log 501    TTI_path=${tti_log_path}/format_output_dl.csv    filte_item=dlTdSchedSubcellData
#    Run Keyword And Continue On Failure    Check numAllocCellPrbDl in TTI Log    log_file=${tti_log_path}/tcpdump_ttitrace_pcap_parqCsv_dl_000.csv
    Run Keyword And Continue On Failure    Check numAllocCellPrbDl in TTI Log    log_file=${tti_log_path}/tcpdump_ttitrace_pcap_parqCsv_dl_000.csv
    ...                                                                          pci=485    expected_value=${1092}
    [Teardown]    Set Test Variable    ${ue_suc}    ${ue_suc}

Single UE Attach And Send Traffic
    [Arguments]    ${ul_tp}=200M    ${dl_tp}=2000M    ${duration}=3000
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[2]
    log to console    \n***Prepare UE_5***
	${ue_type}    translate_power_ue_type_from_testline    ue_index=${5}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${5}
    ${status}    Run keyword and return status    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${5}
    ...    log_type=Iperf    pci=484
#    Run keyword if    '${status}'=='False'    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${5}
#    ...    log_type=Iperf    pci=484
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${duration}    ue_index=${5}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${duration}    ue_index=${5}
    ...    process_num=5
#    &{tti_log_path}    Capture TTI log
    Connect to gnb coam via ssl
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Test Variable    ${timestamp}
    TTI_logs_Capture.Start Ttitrace With Streaming Mode    collector_names=l2stream3_ttitrace    eth_port_on_ute=eth0
    Sleep    1s    reason=Wait for logs
    TTI_logs_Capture.Stop Ttitrace    collector_names=l2stream3_ttitrace     log_dir=${TS_CASE_LOG_PATH}/ttitrace_streaming_${timestamp}
    ${tti_log_path}    TTI_logs_Capture.Decode Ttitrace Logs    collector_names=l2stream3_ttitrace    by_filter=${False}
    ...    except_filter=${False}    filter=None    format_tti_log=${True}    log_dir=${TS_CASE_LOG_PATH}/ttitrace_streaming_${timestamp}
    Run Keyword And Continue On Failure    Check DL UL Throughput On Site    cells=${cell1}    dl_target=1400    ul_target=150
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${5}
	Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${5}

Single UE GBR Call And Send Traffic
    [Arguments]    ${ul_tp}=50M    ${ul_tp}=50M    ${dl_tp}=50M    ${duration}=3000    ${apn}=mdrb.nokia.com
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[2]
    log to console    \n***Prepare UE_5***
	${ue_type}    translate_power_ue_type_from_testline    ue_index=${5}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${5}
	ute_ue.set apn    UE_${5}    apn_name=${apn}
	${apn}    ute_ue.get apn    UE_${5}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${5}     log_type=Iperf    pci=484
    power_ue.Start traffic   ue_type=${ue_type}   direction=dl   throughput=${dl_tp}   duration=${duration}   ue_index=${5}   apn_address=${apn}
	power_ue.Start traffic   ue_type=${ue_type}   direction=ul   throughput=${ul_tp}   duration=${duration}   ue_index=${5}   apn_address=${apn}
#	&{tti_log_path_GBR}    Capture TTI log
    Connect to gnb coam via ssl
    ${tti_log_path_GBR}    Capture And Decode TTitrace Log TTI2    duration=1
	Set Test Variable    ${tti_log_path_GBR}
    Run Keyword And Continue On Failure    Check DL UL Throughput On Site    cells=${cell1}    dl_target=15    ul_target=15
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${5}
	Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${5}

recover ue apn
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${5}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${5}
	ute_ue.set apn    UE_${5}    apn_name=dxdata2

Multi UE Stop Traffic
    FOR    ${ue_index}    IN    @{ue_suc}
        log to console    \n***Stop traffic ***
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        power_ue.Prepare UE    ue_type=${type}    ue_index=${ue_index}
        power_ue.Stop traffic    ue_type=${type}    direction=dl    ue_index=${ue_index}
        power_ue.Stop traffic    ue_type=${type}    direction=ul    ue_index=${ue_index}
    END

Multi UE Attach And Send Traffic GBR
    [Arguments]    ${num}    ${send_traffic_ul}=50MKbits/sec   ${send_traffic_dl}=100MKbits/sec   ${send_duration}=1800   ${apn}=dxmdrb38
    ...    ${attach_mode}=5G_SA    ${power_reset}=true
    FOR    ${ue_no}    IN    @{num}
        ${ue_type}    Get UE type    ue_index=${ue_no}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_no}    power_reset=${power_reset}
        ${apn_result}    spark.send_at_command_on_ue    ue_alias=UE_${ue_no}    command=at+cgdcont?
        ${apn_origin}    String.split string    string=${apn_result}    separator="
        Set test variable    ${apn_value_${ue_no}}    ${apn_origin}[3]
        spark.configure_apn    ue_alias=UE_${ue_no}    apn=${apn}
        ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_no}    power_reset=${power_reset}    attach_mode=${attach_mode}
        Run keyword and ignore error    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
        sleep    3s
        Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_no}    process_num=5
        ...    throughput=${send_traffic_ul}   duration=${send_duration}   connection_type=current   apn_address=${apn}
        Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_no}
        ...    throughput=${send_traffic_dl}    duration=${send_duration}    apn_address=${apn}
    END

Check DL UL Throughput On Site AEHC
    [Arguments]    ${dl_target}=1300    ${ul_target}=0
	${cells}    Get NRcellid list
	${cell}    Create list    ${cells}[0]
    ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
    power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cell}    target_throughput=${dl_target}
    power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cell}    target_throughput=${ul_target}

Check DL UL Throughput On Site AQQY
    [Arguments]    ${dl_target}=1300    ${ul_target}=0
	${cells}    Get NRcellid list
	${cell}    Create list    ${cells}[2]
    ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
    power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cell}    target_throughput=${dl_target}
    power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cell}    target_throughput=${ul_target}

Lock Cell and Check Status
    Connect to gnb coam via ssl
    Perform cell lock via rest api    cell_idx=601
    Wait until keyword succeeds    3min    20 sec    Cell Should Be Locked    cell_idx=601    cell_group_idx=3

Unlock Cell and Check Status
    Connect to gnb coam via ssl
    Perform cell unlock via rest api    cell_idx=601
    sleep    60s
    COAM Wait for gnb ready and cell setup
    Wait until keyword succeeds    5min    20 sec    Cell Should Be Unlocked    cell_idx=601    cell_group_idx=3

Check counter
    [Arguments]    ${count}    ${count_path}=${None}
    ${counter}    Check BTS Counters via webUI    counter_id=${count}    count_path=${count_path}
    should be true    ${counter}[-1]>=${1} or ${counter}[-2]>=${1}

Check TTI Log
    [Arguments]    ${TTI_path}    ${filte_item}
    ${values}    check_newformat_tti_by_value    file_path=${TTI_path}    filte_item=${filte_item}    find_value=gbrPrbLoad
    ${values_pci}    check_newformat_tti_by_value    file_path=${TTI_path}    filte_item=${filte_item}    find_value=lcrId
    ${len}    get length    ${values}
    ${passrate}    Set Variable    0
    FOR    ${i}    IN RANGE    ${len}
        Run Keyword if    ${values_pci}[${i}]==${601} and 3<${values}[${i}]<8    Set Test Variable    ${passrate}    ${passrate}+1
    END
    ${passrate}    evaluate    ${passrate}
    ${gap_cell_len}=    Evaluate    ${len}*0.3
    should be true    ${passrate}>=${gap_cell_len}

Check TTI Log 601
    [Arguments]    ${TTI_path}    ${filte_item}
	${value_cellid}    check_newformat_tti_by_value    file_path=${TTI_path}    filte_item=${filte_item}    find_value=lcrId
    ${value_PrbDl}    check_newformat_tti_by_value    file_path=${TTI_path}    filte_item=${filte_item}    find_value=numAllocCellPrbDl
    ${passrate}    Create List
	${len}    get length    ${value_cellid}
	FOR    ${i}    IN RANGE    ${len}
        Run Keyword if    ${value_cellid}[${i}]==${601} and ${value_PrbDl}[${i}]==${819}
        ...               Append To List    ${passrate}    1
    END
    ${passrate}    get_sum_for_list    gap_list=${passrate}
    should be true    ${passrate}>=100

Check TTI Log 501
    [Arguments]    ${TTI_path}    ${filte_item}
	${value_cellid}    check_newformat_tti_by_value    file_path=${TTI_path}    filte_item=${filte_item}    find_value=lcrId
    ${value_PrbDl}    check_newformat_tti_by_value    file_path=${TTI_path}    filte_item=${filte_item}    find_value=numAllocCellPrbDl
    ${passrate}    Create List
	${len}    get length    ${value_cellid}
	FOR    ${i}    IN RANGE    ${len}
        Run Keyword if    ${value_cellid}[${i}]==${501} and ${value_PrbDl}[${i}]==${1092}
        ...           Append To List    ${passrate}    1
    END
    ${passrate}    get_sum_for_list    gap_list=${passrate}
    should be true    ${passrate}>=100

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file}    timeout=400
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Check DL UL Throughput On Site
    [Arguments]    ${cells}    ${dl_target}=2700    ${ul_target}=120
    ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
    power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cells}    target_throughput=${dl_target}
    power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cells}    target_throughput=${ul_target}

Modify parameter online 16D4U
	&{param1}    Create Dictionary    dist_name=dist_name=MRBTS-1031/NRBTS-1031/NRCELL-501    parameter=nrCellType    value=16DL4UL
	&{param2}    Create Dictionary    dist_name=MRBTS-1031/NRBTS-1031/NRCELL-501/NRULMUMIMO-0    parameter=ulMaxMuMimoLayer    value=2
    @{modify_param}    Create List    ${param1}    ${param2}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=${600}

Delete Mo online 16D4U
    [Arguments]    ${connection}=GNB_OAM
	&{param1}    Create Dictionary    dist_name=MRBTS-1031/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-501/CHANNELGROUP-2/CHANNEL-5
	&{param2}    Create Dictionary    dist_name=MRBTS-1031/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-501/CHANNELGROUP-2/CHANNEL-6
	&{param3}    Create Dictionary    dist_name=MRBTS-1031/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-501/CHANNELGROUP-2/CHANNEL-7
	&{param4}    Create Dictionary    dist_name=MRBTS-1031/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-501/CHANNELGROUP-2/CHANNEL-8
    @{delete_mos}    Create List    ${param1}    ${param2}    ${param3}    ${param4}
    ${para_file}    coam_parameter.create_delete_objects_delta
    ...    parameters=${delete_mos}
    ...    connection=${connection}
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file['updated']}
    ...    timeout=${300}
    ...    skip_parameter_relation_errors=false
    ...    connection=${connection}
    Should contain    ${update_via_api_status}    PASS
    ...    msg=parameters do not update successfully.    ignore_case=${True}
    [Return]   ${update_via_api_status}

Modify parameter online 8D8U
	&{param1}    Create Dictionary    dist_name=dist_name=MRBTS-1031/NRBTS-1031/NRCELL-601    parameter=nrCellType    value=8DL8UL
    @{modify_param}    Create List    ${param1}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=${600}

Delete Mo online 8D8U
    [Arguments]    ${connection}=GNB_OAM
	&{param1}    Create Dictionary    dist_name=MRBTS-1031/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-601/CHANNELGROUP-3
	&{param2}    Create Dictionary    dist_name=MRBTS-1031/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-601/CHANNELGROUP-4
    @{delete_mos}    Create List    ${param1}    ${param2}
    ${para_file}    coam_parameter.create_delete_objects_delta
    ...    parameters=${delete_mos}
    ...    connection=${connection}
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file['updated']}
    ...    timeout=${300}
    ...    connection=${connection}
    Should contain    ${update_via_api_status}    PASS
    ...    msg=parameters do not update successfully.    ignore_case=${True}
    [Return]   ${update_via_api_status}

Modify parameter online 8D4U
    &{param1}    Create Dictionary    dist_name=dist_name=MRBTS-1031/NRBTS-1031/NRCELL-301    parameter=nrCellType    value=8DL4UL
    &{param2}    Create Dictionary    dist_name=dist_name=MRBTS-1031/NRBTS-1031/NRCELL-501    parameter=nrCellType    value=8DL4UL
    @{modify_param}    Create List    ${param1}    ${param2}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=${600}

Delete Mo online 8D4U
    [Arguments]    ${connection}=GNB_OAM
	&{param1}    Create Dictionary    dist_name=MRBTS-1031/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-301/CHANNELGROUP-3
	&{param2}    Create Dictionary    dist_name=MRBTS-1031/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-301/CHANNELGROUP-4
    &{param3}    Create Dictionary    dist_name=MRBTS-1031/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-501/CHANNELGROUP-3
	&{param4}    Create Dictionary    dist_name=MRBTS-1031/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-501/CHANNELGROUP-4
    @{delete_mos}    Create List    ${param1}    ${param2}    ${param3}    ${param4}
    ${para_file}    coam_parameter.create_delete_objects_delta
    ...    parameters=${delete_mos}
    ...    connection=${connection}
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file['updated']}
    ...    timeout=${300}
    ...    connection=${connection}
    Should contain    ${update_via_api_status}    PASS
    ...    msg=parameters do not update successfully.    ignore_case=${True}
    [Return]   ${update_via_api_status}

Modify parameter online 4D4U
    &{param1}    Create Dictionary    dist_name=dist_name=MRBTS-1031/NRBTS-1031/NRCELL-301    parameter=nrCellType    value=4DL4UL
    &{param2}    Create Dictionary    dist_name=dist_name=MRBTS-1031/NRBTS-1031/NRCELL-501    parameter=nrCellType    value=4DL4UL
    @{modify_param}    Create List    ${param1}    ${param2}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=${600}

Delete Mo online 4D4U
    [Arguments]    ${connection}=GNB_OAM
	&{param1}    Create Dictionary    dist_name=MRBTS-1031/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-301/CHANNELGROUP-2
    &{param2}    Create Dictionary    dist_name=MRBTS-1031/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-501/CHANNELGROUP-2
    @{delete_mos}    Create List    ${param1}    ${param2}
    ${para_file}    coam_parameter.create_delete_objects_delta
    ...    parameters=${delete_mos}
    ...    connection=${connection}
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file['updated']}
    ...    timeout=${300}
    ...    connection=${connection}
    Should contain    ${update_via_api_status}    PASS
    ...    msg=parameters do not update successfully.    ignore_case=${True}
    [Return]   ${update_via_api_status}

Capture And Decode TTitrace Log TTI2
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${duration}=3
    ...    ${eth_port_on_ute}=eth0    ${log_dir}=${TS_CASE_LOG_PATH}/ttitrace_streaming
    TTI_logs_Capture.Start Ttitrace With Streaming Mode    collector_names=${collector_names}    eth_port_on_ute=${eth_port_on_ute}
    Sleep    ${duration}s    reason=Wait for logs
    TTI_logs_Capture.Stop Ttitrace    collector_names=${collector_names}    log_dir=${log_dir}
    Convert TTI Trace pcap file to parquetCsv format with options    pcap_file=${log_dir}/${collector_names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    [Return]    ${log_dir}/${collector_names}/tcpdump_ttitrace

Convert TTI Trace pcap file to parquetCsv format with options
    [Arguments]    ${pcap_file}
    Create Twdecoder Converter
    ...    name=twdecoder
    ...    input_file_path=${pcap_file}
    ...    tti_trace_decoder_options=parquetCsv  #--filter-physCellId 484
    ...    tti_dec_bin_path=/opt/tti-dec/tti-dec-bin-2

    taf.converters.twdecoder.convert  twdecoder

Check gbrPrbLoad in TTI Log
    [Arguments]    ${log_file}   ${item_name}=dlPsCellGbrLoadIndData.gbrPrbLoad    ${pci}=484
    ${value}    handle_csv_pandas.Read Csv Column    ${testline_name}    ${log_file}    ${item_name}
    ...                                              filter_conditions=`${item_name}`.notnull() and `physCellId`==${pci}    need_set=False
    ${len}    get length    ${value}
    should be true    ${len}>0
    FOR    ${i}    IN RANGE    ${len}
        should be true    3<${value}[${i}]<8
    END

Check numAllocCellPrbDl in TTI Log
    [Arguments]    ${log_file}   ${item_name}=dlAllocatedPooledResourcesData.numAllocCellPrbDl
    ...            ${pci}=484    ${expected_value}=${819}
    ${value}    handle_csv_pandas.Read Csv Column    ${testline_name}    ${log_file}    ${item_name}
    ...         filter_conditions=`${item_name}`.notnull() and `physCellId`==${pci} and `kind`=='dlAllocatedPooledResourcesData'
    ${len}    get length    ${value}
    should be true    ${len}>0
    FOR    ${i}    IN RANGE    ${len}
        should be true    ${value}[${i}]==${expected_value}
    END