# *** Settings ***
# Documentation     author: Bijiajian
# ...               contact: Jiajian.bi@nokia-sbell.com
# ...               squad group: SG_02
# Suite Setup       Common Suite Setup for COAM
# Suite Teardown    Common Suite Teardown
# Force Tags        5G_RRM    QCD_MN_RAN    QCP_RAN_ST
# Library           OperatingSystem
# Library           Collections
# Library           BuiltIn
# Library           String
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/Resource_common_keywords.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource          Resources/1347_common_keyword.robot
# 
# *** Variables ***
# ${mcs_ip}    ${tl.mcses.ip_addr}
# ${mcs_model}    ${tl.mcses.model}
# ${tmp_swconfig_dir}    /home/ute/Downloads/SCF/swconfig.txt
# ${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs
# ${scf_path_23R3}       /home/ute/Downloads/SCF/23R3
# ${scf_path_23R4}       /home/ute/Downloads/SCF/23R4
# ${scf_path_24R1}       /home/ute/Downloads/SCF/24R1
# ${scf_path_23R2}       /home/ute/Downloads/SCF/23R2
# @{beam_set_16D8U_horizontal}   -50.6   -50.6   -50.6   -50.6   -10.5   -10.5   -10.5   -10.5   10.5   10.5   10.5   10.5
# ...   50.6   50.6   50.6   50.6
# @{beam_set_16D8U_vertical}   95.9   95.9   89.1   89.1   100.8   100.8   107.4   107.4   105.7   105.7   86.3   86.3
# ...   95.9   95.9   102.4  102.4
# ${tshark_path}    /usr/bin/tshark
# @{num1}    2    4
# @{num2}    8    10    12    14
# @{num3}    16    18    20    22
# @{subcell1}    0    3    4    5
# @{subcell2}    1    6    7    8
# @{subcell3}    2    9    10    11
# ${DL_index}    22
# ${UL_index}    24
# 
# *** Test Cases ***
# CB007112_5G_A_1_L1_and_L2RT_instances_startup_successfully_based_on_internal_cell_set_ABIO
#     [Tags]    CRT    CB007112
#     [Setup]    Case Setup
#     MCS Set angle    horizontal_set=${beam_set_16D8U_horizontal}    vertical_set=${beam_set_16D8U_vertical}
#     Recover swconfig file
#     Reload Case SCF and Commission    scf_file=${scf_path}/CB007112.xml
#     Multi UE Attach And Send Traffic    num=${num1}
#     sleep    3s
#     Run keyword and ignore error    Multi UE Attach And Send Traffic    num=${num2}    send_traffic_ul=20MKbits/sec
#     ...    send_traffic_dl=200MKbits/sec
#     sleep    3s
#     Run keyword and ignore error    Multi UE Attach And Send Traffic    num=${num3}    send_traffic_ul=20MKbits/sec
#     ...    send_traffic_dl=200MKbits/sec
#     sleep    3s
#     Check counter    count=M55308C00001
#     Check counter    count=M55308C10005
#     #Common Capture BIP log and download
# 	&{tti_log_path}    Capture TTI log
#     Check TTI Log 301    TTI_path=&{tti_log_path}[DL]    filte_item=dlTdSchedSubcellData
#     Run Keyword And Continue On Failure    Check DL UL Throughput On Site AEHC    dl_target=2000
#     #Check BIP Log    @{subcell1}
#     Run keyword and ignore error    Multi UE Stop Traffic    num=${num1}
# 	Run keyword and ignore error    Multi UE Stop Traffic    num=${num2}
# 	Run keyword and ignore error    Multi UE Stop Traffic    num=${num3}
#     Multi UE Attach And Send Traffic    num=${num1}    send_traffic_ul=20MKbits/sec    send_traffic_dl=200MKbits/sec
#     ...    send_duration=2400
#     sleep    3s
#     Multi UE Attach And Send Traffic    num=${num2}    send_traffic_ul=20MKbits/sec    send_traffic_dl=200MKbits/sec
#     ...    send_duration=2400
#     sleep    3s
#     Multi UE Attach And Send Traffic    num=${num3}
#     sleep    3s
# 	&{tti_log_path}    Capture TTI log
#     Check TTI Log 601    TTI_path=&{tti_log_path}[DL]    filte_item=dlTdSchedSubcellData
#     Run Keyword And Continue On Failure    Check DL UL Throughput On Site AQQY    dl_target=2000
#     @{cell_list}    Create list    ${601}
#     Lock Cell and Check Status
#     Run keyword and ignore error    Multi UE Stop Traffic    num=${num3}
# 	#&{tti_log_path}    Capture TTI log
#     Unlock Cell and Check Status
#     sleep    3s
# 	Multi UE Attach And Send Traffic    num=${num3}
# 	&{tti_log_path}    Capture TTI log
#     Check TTI Log 601    TTI_path=&{tti_log_path}[DL]    filte_item=dlTdSchedSubcellData
#     [Teardown]    Case Teardown
# 
# CB007112_5G_E_1_Load-based_PRB_Pooling_with_Zero_Allocation_Bypass
#     [Tags]    CRT    CB007112
#     [Setup]    Case Setup
#     MCS Set angle    horizontal_set=${beam_set_16D8U_horizontal}    vertical_set=${beam_set_16D8U_vertical}
#     Recover swconfig file
#     Reload Case SCF and Commission    scf_file=${scf_path}/CB007112.xml
#     Multi UE Attach And Send Traffic    num=${num1}
#     sleep    3s
#     Run keyword and ignore error    Multi UE Attach And Send Traffic    num=${num2}    send_traffic_ul=20MKbits/sec
#     ...    send_traffic_dl=200MKbits/sec
#     sleep    3s
#     Run keyword and ignore error    Multi UE Attach And Send Traffic    num=${num3}    send_traffic_ul=20MKbits/sec
#     ...    send_traffic_dl=200MKbits/sec
#     sleep    3s
#     Check counter    count=M55308C00001
#     Check counter    count=M55308C10005
# 	&{tti_log_path}    Capture TTI log
#     Check TTI Log 301    TTI_path=&{tti_log_path}[DL]    filte_item=dlTdSchedSubcellData
#     Run Keyword And Continue On Failure    Check DL UL Throughput On Site AEHC    dl_target=2000
# 
# [1]CB010513_I_1_CB007112_E_Load-based_PRB_Pooling_with_Zero_Allocation_Bypass
#     [Tags]    CRT    CB010513
#     [Setup]    Case Setup
#     MCS Set angle    horizontal_set=${beam_set_16D8U_horizontal}    vertical_set=${beam_set_16D8U_vertical}
#     Recover swconfig file	
#     Reload Case SCF and Commission    scf_file=${scf_path}/CB010513.xml
#     Multi UE Attach And Send Traffic GBR    num=${num1}
#     sleep    3s
#     Run keyword and ignore error    Check DL UL Throughput On Site AEHC    dl_target=15
#     &{tti_log_path}    Capture TTI log
#     Check TTI Log    TTI_path=&{tti_log_path}[DL]    filte_item=psCellDlGbrLoadIndData    index=${DL_index}
#     #Check TTI Log    TTI_path=&{tti_log_path}[UL]    filte_item=psCellUlGbrLoadIndData    index=${UL_index}
#     sleep    3s
#     Run keyword and ignore error    Multi UE Attach And Send Traffic    num=${num3}
#     sleep    3s
#     Run keyword and ignore error    Check DL UL Throughput On Site AQQY
#     &{tti_log_path}    Capture TTI log
#     Check TTI Log 601    TTI_path=&{tti_log_path}[DL]    filte_item=dlTdSchedSubcellData
#     [Teardown]    Case Teardown GBR
# 
# *** Keywords ***
# Common Suite Setup for COAM
#     Connect to gnb coam via ssl
#     robot_common_operations.Common Suite Setup
# 
# Common Suite Teardown
#     robot_common_operations.Common Suite Teardown
# 
# Case Setup
#     COAM Create log directory
#     Connect to gnb coam via ssl
#     ${build}    Coam Get Active SW Version
#     ${result}    String.split string    string=${build}    separator=_
#     Run keyword if    'SBTS23R3' in ${result}    set test variable    ${scf_path}    ${scf_path_23R3}
#     ...    ELSE IF    'SBTS23R4' in ${result}    set test variable    ${scf_path}    ${scf_path_23R4}
#     ...    ELSE IF    'SBTS24R1' in ${result}    set test variable    ${scf_path}    ${scf_path_24R1}
#     ...    ELSE IF    'SBTS23R2' in ${result}    set test variable    ${scf_path}    ${scf_path_23R2}
#     robot_common_operations.Common Case Setup
# 
# Case Teardown
#     Run keyword and ignore error    COAM Teardown gnb connections
#     #Run keyword and ignore error    CI_interface.Common Case Teardown
#     robot_common_operations.Common Case Teardown
# 
# Case Teardown GBR
#     Run keyword and ignore error    COAM Teardown gnb connections
#     #Run keyword and ignore error    CI_interface.Common Case Teardown
#     robot_common_operations.Common Case Teardown
#     Run keyword and ignore error    Recover UE apn
# 
# Reload Case SCF and Commission
#     [Arguments]    ${scf_file}
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    scf_file_path=${scf_file}
#     COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'
# 
# Common UE Attach
#     [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_SA    ${power_reset}=true
#     ${ue_type}    Get UE type    ue_index=${ue_index}
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}    get_spark_license=false
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}    attach_mode=${attach_mode}
#     Run keyword and ignore error    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
# 
# Multi UE Attach And Send Traffic
#     [Arguments]    ${num}    ${send_traffic_ul}=100MKbits/sec    ${send_traffic_dl}=1000MKbits/sec    ${send_duration}=1800
#     : FOR    ${ue_no}    IN    @{num}
#     \    Run Keyword And Continue On Failure    Common UE Attach    ue_index=${ue_no}    power_reset=true
#     \    sleep    3s
#     \    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_ul}
#     \    ...    send_duration=${send_duration}
#     \    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_dl}
#     \    ...    send_duration=${send_duration}
# 
# Multi UE Attach And Send Traffic GBR
#     [Arguments]    ${num}    ${send_traffic_ul}=50MKbits/sec   ${send_traffic_dl}=100MKbits/sec   ${send_duration}=1800   ${apn}=dxmdrb38
#     ...    ${attach_mode}=5G_SA    ${power_reset}=true
#     : FOR    ${ue_no}    IN    @{num}
#     \    ${ue_type}    Get UE type    ue_index=${ue_no}
#     \    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_no}    power_reset=${power_reset}    get_spark_license=false
# 	\    ${apn_result}    spark.send_at_command_on_ue    ue_alias=UE_${ue_no}    command=at+cgdcont?
#     \    ${apn_origin}    String.split string    string=${apn_result}    separator="
#     \    Set test variable    ${apn_value_${ue_no}}    ${apn_origin}[3]
#     \    spark.configure_apn    ue_alias=UE_${ue_no}    apn=${apn}
#     \    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_no}    power_reset=${power_reset}    attach_mode=${attach_mode}
#     \    Run keyword and ignore error    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
#     \    sleep    3s
#     \    #Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_no}
#     \    #...    throughput=${send_traffic_ul}   duration=${send_duration}   connection_type=current   apn_address=${apn}
#     \    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_no}
#     \    ...    throughput=${send_traffic_dl}    duration=${send_duration}    apn_address=${apn}
# 
# Multi UE Stop Traffic
#     [Arguments]    ${num}
#     : FOR    ${ue_no}    IN    @{num}
#     \    Run Keyword And Continue On Failure    Common Stop traffic    direction=dl    ue_index=${ue_no}
#     \    Run Keyword And Continue On Failure    Common Stop traffic    direction=ul    ue_index=${ue_no}
# 
# Recover UE apn
#     FOR    ${ue_index}    IN    @{num1}
#         ${ue_type}    Get UE type    ue_index=${ue_index}
#         power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=true    detach_request=false    get_spark_license=false
#         spark.configure_apn    ue_alias=UE_${ue_index}    apn=${apn_value_${ue_index}}
#     END
# 
# Check DL UL Throughput On Site AEHC
#     [Arguments]    ${dl_target}=1300    ${ul_target}=0
# 	${cells}    Get NRcellid list
# 	@{cell}    Create list    @{cells}[0]
#     ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
#     power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cell}    target_throughput=${dl_target}
#     power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cell}    target_throughput=${ul_target}
# 
# Check DL UL Throughput On Site AQQY
#     [Arguments]    ${dl_target}=1300    ${ul_target}=0
# 	${cells}    Get NRcellid list
# 	@{cell}    Create list    @{cells}[2]
#     ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
#     power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cell}    target_throughput=${dl_target}
#     power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cell}    target_throughput=${ul_target}
# 
# Lock Cell and Check Status
#     Connect to gnb coam via ssl
#     Perform cell lock via rest api    cell_idx=601
#     Wait until keyword succeeds    3min    20 sec    Cell Should Be Locked    cell_idx=601    cell_group_idx=3
# 
# Unlock Cell and Check Status
#     Connect to gnb coam via ssl
#     Perform cell unlock via rest api    cell_idx=601
#     sleep    60s
#     COAM Wait for gnb ready and cell setup
#     Wait until keyword succeeds    5min    20 sec    Cell Should Be Unlocked    cell_idx=601    cell_group_idx=3
# 
# Check counter
#     [Arguments]    ${count}
#     ${counter}    Check BTS Counters via webUI    counter_id=${count}
#     should be true    @{counter}[-1]>=${1}
# 
# Check TTI Log
#     [Arguments]    ${TTI_path}    ${filte_item}    ${index}
# 	${values}    check_tti    file_path=${TTI_path}    filte_item=${filte_item}    index=${index}
#     ${values_pci}    check_tti    file_path=${TTI_path}    filte_item=${filte_item}    index=18
#     ${passrate}    Set Variable    0
#     ${len}    get length    ${values}
#     FOR    ${i}    IN RANGE    ${len}
#         Run Keyword if    @{values_pci}[${i}]==${301} and 16<@{values}[${i}]<24    Set Test Variable    ${passrate}    ${passrate}+1
#     END
#     ${passrate}    evaluate    ${passrate}
#     should be true    ${passrate}>=1
# 	
# Check TTI Log 301
#     [Arguments]    ${TTI_path}    ${filte_item}
#     ${result}    String.split string    string=${build}    separator=_
#     Run keyword if    'SBTS24R1' in ${result}    set test variable    ${index_cellid}    134
#     ...    ELSE    set test variable    ${index_cellid}    124
#     Run keyword if    'SBTS24R1' in ${result}    set test variable    ${index_prb}    141
#     ...    ELSE    set test variable    ${index_prb}    131
# 	${value_cellid}    check_tti    file_path=${TTI_path}    filte_item=${filte_item}    index=${index_cellid}
#     ${value_PrbDl}    check_tti    file_path=${TTI_path}    filte_item=${filte_item}    index=${index_prb}	
#     ${passrate}    Set Variable    0
# 	${len}    get length    ${value_cellid}
#     Run keyword if    ${len}>500    set test variable    ${len}    500
# 	FOR    ${i}    IN RANGE    ${len}
#         Run Keyword if    @{value_cellid}[${i}]==${301} and @{value_PrbDl}[${i}]==${1092}    Set Test Variable    ${passrate}    ${passrate}+1
#     END
#     ${passrate}    evaluate    ${passrate}
#     should be true    ${passrate}>=1
# 	
# Check TTI Log 601
#     [Arguments]    ${TTI_path}    ${filte_item}
#     ${result}    String.split string    string=${build}    separator=_
#     Run keyword if    'SBTS24R1' in ${result}    set test variable    ${index_cellid}    134
#     ...    ELSE    set test variable    ${index_cellid}    124
#     Run keyword if    'SBTS24R1' in ${result}    set test variable    ${index_prb}    141
#     ...    ELSE    set test variable    ${index_prb}    131
# 	${value_cellid}    check_tti    file_path=${TTI_path}    filte_item=${filte_item}    index=${index_cellid}
#     ${value_PrbDl}    check_tti    file_path=${TTI_path}    filte_item=${filte_item}    index=${index_prb}
#     ${passrate}    Set Variable    0
# 	${len}    get length    ${value_cellid}
#     Run keyword if    ${len}>500    set test variable    ${len}    500
# 	FOR    ${i}    IN RANGE    ${len}
#         Run Keyword if    @{value_cellid}[${i}]==${601} and @{value_PrbDl}[${i}]==${1092}    Set Test Variable    ${passrate}    ${passrate}+1
#     END
#     ${passrate}    evaluate    ${passrate}
#     should be true    ${passrate}>=1
# 
# Load BIP Log
#     [Arguments]    ${bip_file}=${bip_log_path}     ${alias}=CB7112
#     ${packets}    pcap.load_pcap_file   pcap_file=${bip_file}
# 	...                                 tshark_path=${tshark_path}
#     ...                                 command_template={tshark_path} -r ${bip_file} -Y 'dldata_pdschsendreq' -T pdml
#     ...                                 alias=${alias}
#     [Return]   ${packets}
# 
# Check BIP Log
#     [Arguments]    @{subcell}
#     Load BIP Log
#     ${slot}    Get value from Bip Log    field_name=_3gpp.slot    pcap_parser=CB7112
#     ${subcellid}    Get value from Bip Log    field_name=_3gpp.subcellid    pcap_parser=CB7112
#     ${layer}    Get value from Bip Log    field_name=DlData_PdschGrant.numOfLayers    pcap_parser=CB7112
#     ${prb}    Get value from Bip Log    field_name=DlData_PdschGrant.numOfPrb    pcap_parser=CB7112
#     ${len}    get length    ${slot}
# 	${num}    Set Variable    0
#     FOR  ${index}  IN RANGE  ${len}-${4}
# 	    ${index1}    evaluate    ${index}+1
# 		${index2}    evaluate    ${index}+2
# 		${index3}    evaluate    ${index}+3
# 	    ${cellid_l}    Create list    ${subcellid}[${index}]    ${subcellid}[${index1}]    ${subcellid}[${index2}]    ${subcellid}[${index3}]
# 		${cellid_s}    Run Keyword And Return Status    Should Contain    ${cellid_l}    @{subcell}
#         ${slot_s}    Run Keyword if    ${slot}[${index}]==${slot}[${index1}]==${slot}[${index2}]==${slot}[${index3}]    Set Variable    True
# 	    ${layer_s}    Run Keyword if    ${layer}[${index}]==${layer}[${index1}]==${layer}[${index2}]==${layer}[${index3}]==4    Set Variable    True
# 		${prb_s}    Run Keyword if    ${prb}[${index}]==${prb}[${index1}]==${prb}[${index2}]==${prb}[${index3}]==273    Set Variable    True
#         Run Keyword if    ${cellid_s}==${slot_s}==${layer_s}==${prb_s}==True    Set Test Variable    ${num}    ${num}+1
#     END
# 	${num}    evaluate    ${num}
#     should be true    ${num}>=1
