*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Samik Sarkar
...              :contact: samik.sarkar@nokia.com


Variables    ta5g_global_var

Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../resources/robot/TTI_Traces.robot
Resource         ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          luashark_tools.analyzer       WITH NAME       analyzer
Library          	taf.sbts.oam.coam.admin                      WITH NAME   ute_adm
Library          Collections
Library          OperatingSystem
Library          ta5g_tshark
Library          ta5g_commissioning
Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library          taf.transport.ssh                 WITH NAME    csn
#Library          OperatingSystem
Library          String
Library          ../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../resources/NPS/SWENG/python_libs/luashark_tools.py
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ././resources/python/PM_Counter_Verify.py    WITH NAME     pm_analyzer

Library          ../CB008379/resources/python/utility.py
Library          ../CB008379/resources/python/tti_trace_utility.py
Library          ../CB008379/resources/python/increase_buffer_size.py
Library          ../CB008379/resources/python/execute_command.py


*** Variables ***
&{GNB_ASIK}                ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${BIP_SCRIPT_PATH}         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/config/script/
${port}                    22

#   Add your vonr codec speed
&{vonr_codec_rate}         amr_wb_18_25=18.6      amr_wb_23_85=21.4
@{gbr_qfi_list_cfg}        3	4	5 	6	7	8	9	10	11	12	13	14	15


*** Keywords ***
## Delta Commissioning
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Set CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture init        ${capture_var_cprt}
    Capture start       ${capture_var_cprt}

Set L1L2 capture
    [Arguments]         ${capture_var_l1l2}
#    CB008200_Resource.Get Base Band Board Type
#    Run Keyword If      '${ASP_BOARD_TYPE}'=='ABIO'      Modify BIP Script File For ABIO
    Modify BIP Script File
    Capture init        ${capture_var_l1l2}
    Capture start       ${capture_var_l1l2}

Stop CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture stop        ${capture_var_cprt}

Stop L1L2 capture
    [Arguments]         ${capture_var_l1l2}
    Capture stop        ${capture_var_l1l2}

Start CPRT Trace Capturing
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set suite variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}

Start L2 BIP Trace Capturing
    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set suite variable    ${CaptureL1L2}    ${capture_l1l2}
    Set L1L2 capture  ${CaptureL1L2}

Get Base Band Board Type
    [Documentation]    this keyword is used to get base band board Type, ABIL?ABIO?ABIN etc.
    ute_fsmaccess.Setup Enb Fsm Access
    ${cmd}=    Set Variable    bsh 1:0 cat /proc/device-tree/module-identity/unit-id
    ${board_type}=    ute_fsmaccess.Execute Command On Enb    ${cmd}
    ${board_type}=    String.Replace String Using Regexp    ${board_type}    \x00    ${EMPTY}
    Set Suite Variable    ${ASP_BOARD_TYPE}    ${board_type}
#    Log    Base Band Board Type: ${ASP_BOARD_TYPE}     console=${True}
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access
    [Return]    ${board_type}Get

Modify BIP Script File For ABIO
    ${gnb_hostname}=    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 hostname 2>/dev/null
    ${slot_id}=    Set Variable If    '${gnb_hostname}'=='fct-4a'    5    1
    Run Keyword If     '${slot_id}'=='5'    Modify BB Slots

Modify BIP Script File
    ${gnb_hostname}=    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 hostname 2>/dev/null
    ${slot_id}=    Set Variable If    '${gnb_hostname}'=='fct-4a'    5    1
    Run Keyword If     '${slot_id}'=='5'    Modify BB Slots

Modify BB Slots
    Modify File Parameters    ${BIP_SCRIPT_PATH}/gnbMirroringConfig.sh    BB_SLOT_1='true'    BB_SLOT_1='false'
    Modify File Parameters    ${BIP_SCRIPT_PATH}/gnbMirroringConfig.sh    BB_SLOT_5='false'    BB_SLOT_5='true'

Modify File Parameters
    [Arguments]    ${file_path}    ${old_value}    ${new_value}
    [Documentation]    This keyword is to replace string for file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | No | the file path which need to modify |
    ...    | ${old_value} | No | the value need to be replaced |
    ...    | ${new_value} | No | the new value |
    ...
    ...    Examples:
    ...    | ${delta_path} | OperatingSystem.Join Path | ${scf_path} | ${SW_BRANCH} | SCF | Delta_Conf_5GC002504.json |
    ...    | Modify File Parameter | ${delta_path} | MRBTS-[0-9]+/NRBTS-[0-9]+ | ${NRBTS_DISTNAME} |
    ${content}=    OperatingSystem.Get File    path=${file_path}
    ${content}=    String.Replace String Using Regexp    string=${content}    pattern=${old_value}    replace_with=${new_value}
    OperatingSystem.Create File    path=${file_path}    content=${content}

Start Collecting Syslog
    [Arguments]    ${NAME}      ${VM_IP}=${tl.test_pc.default_ssh_connection_details.addr}
    ${ports}=   Create List   51000    51001    51003    50011
    ${CURRENT_SYSLOG_PATH}  Set Variable     ${LOG_PATH}/
    set suite variable      ${CURRENT_SYSLOG_PATH}
    set suite variable      ${logname}     syslog_${NAME}.log
    ta5g_syslog.Start Syslog  log_dir=${CURRENT_SYSLOG_PATH}  log_name=${logname}   ip=192.168.255.126
    ...    host_ip=${VM_IP}   ssh_username=ute    ssh_password=ute    ports=${ports}  alias=${NAME}

Stop Collecting Syslog
    [Arguments]    ${NAME}
    ${file_path}    ta5g_syslog.Collect Syslog Results    alias=${NAME}
    [Return]      ${file_path}

Start Syslog CPRT BIP Logs
    Start Collecting Syslog     NAME=vonr_call
    Start CPRT Trace Capturing
#	Bip Mon Start AP ASIK ABIL
    Start L2 BIP Trace Capturing

Stop Syslog CPRT BIP Logs
	Stop Collecting Syslog       NAME=vonr_call
	Stop L1L2 capture   ${CaptureL1L2}
	Stop CPRT capture   ${CaptureCPRT}
    @{files}=    List Files In Directory    ${LOG_PATH}    *.pcap
    Log to Console    @{files}
    FOR     ${ELEMENT}    IN    @{files}
        ${str}=       String.Split String    ${ELEMENT}    .
        ${str2} =   Catenate    SEPARATOR=_   ${str}[0]   VoNR
        ${str3} =   Catenate    SEPARATOR=.   ${str2}   ${str}[1]
        Move File    ${LOG_PATH}/${ELEMENT}    ${LOG_PATH}/${str3}
    END

Stop Syslog CPRT BIP Logs for ABIO_L1B
	Stop Collecting Syslog       NAME=vonr_call
	Stop L1L2 capture  ${CaptureL1L2}
    Move File    ${LOG_PATH}/L1L2_GNB_L1B_BO.pcap    ${LOG_PATH}/L1L2_GNB_L1B_BO_VoNR.pcap
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_VoNR.pcap

#Counter Verification Part

Wait for PM Interval to begin
    Wait until the next Measurement Period starts  additional_time=${0}



Validate UL Active UE PM Counters
    ${pi_list}=  Create List  M55308C01001  M55308C02002  M55308C02003
    ${index_list}=  Create List  0  1  2  3  4  5  #Extracts PM Counter values from last 6 PM Intervals
    ${actual_pm_values}=  Get Counter Value  pi_dir=${OUTPUT_DIR}/PMC/gnb_pm_counters  dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...  pi_list=${pi_list}  index=${index_list}
    ${ues_in_pm_interval}=  Create Dictionary  0=${0}  1=${2}  2=${4}  3=${4}  4=${4}  5=${0}
    ${verdict}=  pm_analyzer.counter_verdict_generator_ul  actual_pm_values=${actual_pm_values}  ues_in_pm_interval=${ues_in_pm_interval}
    Should contain  True  ${verdict}

Validate DL Active UE PM Counters
    ${pi_list}=  Create List  M55308C01000  M55308C02000  M55308C02001
    ${index_list}=  Create List  0  1  2  3  4  5  #Extracts PM Counter values from last 6 PM Intervals
    ${actual_pm_values}=  Get Counter Value  pi_dir=${OUTPUT_DIR}/PMC/gnb_pm_counters  dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...  pi_list=${pi_list}  index=${index_list}
    ${ues_in_pm_interval}=  Create Dictionary  0=${0}  1=${2}  2=${4}  3=${4}  4=${4}  5=${0}
    ${verdict}=  pm_analyzer.counter_verdict_generator_dl  actual_pm_values=${actual_pm_values}  ues_in_pm_interval=${ues_in_pm_interval}
    Should contain  True  ${verdict}

Convert Tti To Csv Mode
    [Arguments]         ${path}
    Format Tti In Stream Mode         ${path}/output_dl.csv     ${path}/output_dl_formated.csv
    Format Tti In Stream Mode         ${path}/output_ul.csv     ${path}/output_ul_formated.csv

#Counter Verification Code
Get buffer counters and validate
    [Arguments]    ${ACC_UE_DL_DRB_DATA_5QI}    ${ACC_UE_UL_DRB_DATA_5QI}    ${MAX_UE_DL_DRB}    ${MAX_UE_UL_DRB}
    ...    ${SAMPLE_CNT_DL}    ${SAMPLE_CNT_UL}
    @{pi_list}=  Create List  ${ACC_UE_DL_DRB_DATA_5QI}  ${ACC_UE_UL_DRB_DATA_5QI}  ${MAX_UE_DL_DRB}  ${MAX_UE_UL_DRB}
    ...    ${SAMPLE_CNT_DL}  ${SAMPLE_CNT_UL}    M55308C02000    M55308C02002
    @{counter_value} =  Create List
    FOR    ${counter}    IN    @{pi_list}
        ${actual_pm_values}=    Run Keyword If
        ...    '${counter}' == 'M55356C00000' or '${counter}' == 'M55356C00001' or '${counter}' == 'M55356C00002' or '${counter}' == 'M55356C00003'
        ...    Get PM counter value modified    pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters
        ...    moc=MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-1    pi_id=${counter}
        ...    ELSE
        ...    Get PM counter value modified    pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters
        ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${counter}
        ${actual_pm_values}=   convert to integer    ${actual_pm_values}
        Should Be True    ${actual_pm_values}
        Append To List    ${counter_value}    ${actual_pm_values}
    END
    ${avg_ue_dl}=  PM_Counter_Verify.ue_count_from_counters     ${counter_value}[0]  ${counter_value}[4]
    ${avg_ue_ul}=  PM_Counter_Verify.ue_count_from_counters     ${counter_value}[1]  ${counter_value}[5]
    ${5QI_to_legacy_ratio_dl}=  PM_Counter_Verify.ue_count_from_counters     ${counter_value}[0]  ${counter_value}[6]
    ${5QI_to_legacy_ratio_ul}=  PM_Counter_Verify.ue_count_from_counters     ${counter_value}[1]  ${counter_value}[7]
    ${condition1}=     evaluate  (${counter_value}[2]-${avg_ue_dl}<=0.50)
    ${condition2}=     evaluate  (${counter_value}[3]-${avg_ue_ul}<=0.50)
    ${condition3}=     evaluate  (0.90<=${5QI_to_legacy_ratio_dl}<=1)
    ${condition4}=     evaluate  (0.90<=${5QI_to_legacy_ratio_ul}<=1)
    ${flag}=    Set variable    'True'
    Run keyword If    '${condition1}'=='False' and '${condition3}'=='False'
    ...    should contain    ${flag}    'False'
    Run keyword If    '${condition2}'=='False' and '${condition4}'=='False'
    ...    should contain    ${flag}    'False'

Get PM counter value modified
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=PM*
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Be Equal  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   console=${P_console}
    [Return]    ${pi_value}

One more multiUE PDU Addition should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}     ${nw_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${gyw}=    Evaluate    int(${end_ue_id}) + int(${ue_idx}) + int(${end_ue_id})
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${gyw}
    Read WTS Output For Pattern And Print matching Lines    ${pdu_addition_pattern}    ${Timeout_SA}
    BuiltIn.Log          ue=${ue_idx} pdu=${pdu_id} added with pdu_gateway id=${gyw} successfully
	Log to Console       ue=${ue_idx} pdu=${pdu_id} added with pdu_gateway id=${gyw} successfully
	END
	BuiltIn.Log       All_ue_added_their_pdu_successfuly
	Log to Console    All_ue_added_their_pdu_successfuly

Trigger MultiUE VoNR DL Traffic with multiple trfids
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${pdu_id}=1     ${num_trf_id}=1
	...     ${qfi_id}=1   ${rtp_codec}=custom
    [Documentation]    This keyword starts the VoNR DL Traffic for the SA variant having some rtp codec
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning VoNR DL Traffic for ue=${ue_idx} with ${rtp_codec}...
    Start dl traffic with multiple trfids    ${ue_idx}    ${pdu_id}   ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic Receiver*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ue=${ue_idx} ${output} VoNR_DL_traffic_data_is_started_successfully
    BuiltIn.Log       ue=${ue_idx} VoNR_DL_traffic_data_is_started_successfully
	END
	sleep       10s
	BuiltIn.Log       All_ue_started_DL_VoNR_traff_succesfully
	Log to Console    All_ue_started_DL_VoNR_traff_succesfully

Start dl traffic with multiple trfids
    [Arguments]    ${ue_idx}    ${pdu_id}    ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    FOR     ${traffic_id}   IN RANGE    ${1}    ${num_trf_id}+1
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    trf_id=${traffic_id}    rtp_codec=${rtp_codec}
    ...     rtp_ps=900 period_ms=10 rtp_voice_silence=200:1 rtp_send_silence_period=10 rtp_silence_ps=900
    END
Start ul traffic with multiple trfids
    [Arguments]    ${ue_idx}    ${pdu_id}    ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    FOR     ${traffic_id}   IN RANGE    ${1}    ${num_trf_id}+1
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    trf_id=${traffic_id}    rtp_codec=${rtp_codec}
    ...     rtp_ps=900 period_ms=10 rtp_voice_silence=200:1 rtp_send_silence_period=10 rtp_silence_ps=900
    END
Trigger MultiUE VoNR UL Traffic with multiple trfids
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${pdu_id}=1     ${num_trf_id}=1
	...     ${qfi_id}=1   ${rtp_codec}=custom
    [Documentation]    This keyword starts the VoNR UL Traffic for the SA variant having some rtp codec
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning VoNR UL Traffic for ue=${ue_idx} with ${rtp_codec}...
    Start ul traffic with multiple trfids    ${ue_idx}    ${pdu_id}   ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*      timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ue=${ue_idx} ${output} VoNR_UL_traffic_data_is_started_successfully
    BuiltIn.Log       ue=${ue_idx} VoNR_UL_traffic_data_is_started_successfully
	END
	sleep       10s
	BuiltIn.Log       All_ue_started_UL_VoNR_traff_succesfully
	Log to Console    All_ue_started_UL_VoNR_traff_succesfully
Get 256QAM cqi counters and validate
    [Arguments]    ${cqi_start}=1     ${cqi_end}=15	${ttitrace_path}=ttitrace_streaming
    CB008200_Resource.Collect PM Counters
    Convert Ttitrace From Pcap To Excelcsv        ${LOG_PATH}/${ttitrace_path}/
    Convert Tti To Csv Mode          ${LOG_PATH}/${ttitrace_path}
   # Get legacy cqi counters
    ${pi_list}=  Create List  M55301C22000  M55301C22001  M55301C22002  M55301C22003  M55301C22004  M55301C22005  M55301C22006
    ...    M55301C22007  M55301C22008  M55301C22009  M55301C22010  M55301C22011  M55301C22012  M55301C22013  M55301C22014  M55301C22015
#    ${actual_pm_values}=  Get Counter Value  pi_dir=${OUTPUT_DIR}/PMC/gnb_pm_counters  dist_name=MRBTS-1/NRBTS-1/NRCELL-1
#    ...  pi_list=${pi_list}  index=0
    ${actual_tti_values}=       check_cqi_from_ttitrace     ${LOG_PATH}/${ttitrace_path}/output_ul_formated.csv
    FOR     ${cqi}       IN RANGE     ${cqi_start}     10
    #${cqi_from_pm}=     Get From Dictionary    ${actual_pm_values}    M55301C2200${cqi}
    ${cqi_from_pm}=     Get PM counter value      pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters  moc=MRBTS-1/NRBTS-1/NRCELL-1
    ...  pi_id=M55301C2200${cqi}
    ${cqi_from_pm}=   convert to integer    ${cqi_from_pm}
    log to console   M55301C2200${cqi} ${cqi_from_pm}
    ${cqi_from_tti}=    Get From Dictionary    ${actual_tti_values}    ${cqi}
    #should be equal     ${cqi_from_pm}      ${cqi_from_tti}
    ${condition}=   Evaluate  abs(${cqi_from_pm}-${cqi_from_tti})<=0.1*${cqi_from_pm}
    should be true      ${condition}
    END
    FOR     ${cqi}       IN RANGE     10     ${cqi_end}
   #${cqi_from_pm}=     Get From Dictionary    ${actual_pm_values}    M55301C220${cqi}
    ${cqi_from_pm}=     Get PM counter value      pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters  moc=MRBTS-1/NRBTS-1/NRCELL-1
    ...  pi_id=M55301C220${cqi}
    ${cqi_from_pm}=   convert to integer    ${cqi_from_pm}
    log to console   M55301C220${cqi} ${cqi_from_pm}
    ${cqi_from_tti}=    Get From Dictionary    ${actual_tti_values}    ${cqi}
    #should be equal     ${cqi_from_pm}      ${cqi_from_tti}
    ${condition}=   Evaluate  abs(${cqi_from_pm}-${cqi_from_tti})<=0.1*${cqi_from_pm}
    should be true      ${condition}
    END
Get 64QAM cqi counters and validate
    [Arguments]    ${cqi_start}=1     ${cqi_end}=15		${ttitrace_path}=ttitrace_streaming
    CB008200_Resource.Collect PM Counters
    Convert Ttitrace From Pcap To Excelcsv        ${LOG_PATH}/${ttitrace_path}/
    Convert Tti To Csv Mode          ${LOG_PATH}/${ttitrace_path}
   # Get legacy cqi counters
    ${pi_list}=  Create List  M55301C21000  M55301C21001  M55301C21002  M55301C21003  M55301C21004  M55301C21005  M55301C21006
    ...    M55301C21007  M55301C21008  M55301C21009  M55301C21010  M55301C21011  M55301C21012  M55301C21013  M55301C21014  M55301C21015
#    ${actual_pm_values}=  Get Counter Value  pi_dir=${OUTPUT_DIR}/PMC/gnb_pm_counters  dist_name=MRBTS-1/NRBTS-1/NRCELL-1
#    ...  pi_list=${pi_list}  index=0
    ${actual_tti_values}=       check_cqi_from_ttitrace     ${LOG_PATH}/${ttitrace_path}/output_ul_formated.csv
    FOR     ${cqi}       IN RANGE     ${cqi_start}     10
   # ${cqi_from_pm}=     Get From Dictionary    ${actual_pm_values}    M55301C2100${cqi}
    ${cqi_from_pm}=     Get PM counter value      pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters  moc=MRBTS-1/NRBTS-1/NRCELL-1
    ...  pi_id=M55301C2100${cqi}
    ${cqi_from_pm}=   convert to integer    ${cqi_from_pm}
    log to console   M55301C2100${cqi} ${cqi_from_pm}
    ${cqi_from_tti}=    Get From Dictionary    ${actual_tti_values}    ${cqi}
    #should be equal     ${cqi_from_pm}      ${cqi_from_tti}
    ${condition}=   Evaluate  abs(${cqi_from_pm}-${cqi_from_tti})<=0.1*${cqi_from_pm}
    should be true      ${condition}
    END
    FOR     ${cqi}       IN RANGE     10     ${cqi_end}
   # ${cqi_from_pm}=     Get From Dictionary    ${actual_pm_values}    M55301C210${cqi}
    ${cqi_from_pm}=     Get PM counter value      pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters  moc=MRBTS-1/NRBTS-1/NRCELL-1
    ...  pi_id=M55301C210${cqi}
    ${cqi_from_pm}=   convert to integer    ${cqi_from_pm}
    log to console   M55301C210${cqi} ${cqi_from_pm}
    ${cqi_from_tti}=    Get From Dictionary    ${actual_tti_values}    ${cqi}
    #should be equal     ${cqi_from_pm}      ${cqi_from_tti}
    ${condition}=   Evaluate  abs(${cqi_from_pm}-${cqi_from_tti})<=0.1*${cqi_from_pm}
    should be true      ${condition}
    END

Get 64QAM cqi-15 counter and validate
    [Arguments]     ${ttitrace_path}=ttitrace_streaming
    ${pi_list}=  Create List  M55301C21015
    ${actual_pm_values}=  Get Counter Value  pi_dir=${OUTPUT_DIR}/PMC/gnb_pm_counters  dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...  pi_list=${pi_list}  index=0
    ${actual_tti_values}=       check_cqi_from_ttitrace     ${LOG_PATH}/${ttitrace_path}/output_ul_formated.csv
    ${cqi_from_pm}=     Get From Dictionary    ${actual_pm_values}    M55301C21015
    ${cqi_from_tti}=    Get From Dictionary    ${actual_tti_values}    ${15}
    should be equal     ${cqi_from_pm}      ${cqi_from_tti}

Get 256QAM cqi-15 counter and validate
    [Arguments]     ${ttitrace_path}=ttitrace_streaming
    ${pi_list}=  Create List  M55301C22015
#    ${pi_list}=  Create List  M55301C22000  M55301C22001  M55301C22002  M55301C22003  M55301C22004  M55301C22005  M55301C22006
#    ...    M55301C22007  M55301C22008  M55301C22009  M55301C22010  M55301C22011  M55301C22012  M55301C22013  M55301C22014  M55301C22015
   # ${index_list}=  Create List  0 #Extracts PM Counter values from last 6 PM Intervals
    ${actual_pm_values}=  Get Counter Value  pi_dir=${OUTPUT_DIR}/PMC/gnb_pm_counters  dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...  pi_list=${pi_list}  index=0
    ${actual_tti_values}=       check_cqi_from_ttitrace     ${LOG_PATH}/${ttitrace_path}/output_ul_formated.csv
    ${cqi_from_pm}=     Get From Dictionary    ${actual_pm_values}    M55301C22015
    ${cqi_from_tti}=    Get From Dictionary    ${actual_tti_values}    ${15}
    should be equal     ${cqi_from_pm}      ${cqi_from_tti}

Get legacy cqi counters
    ${pi_list}=  Create List  M55301C19020  M55301C19021  M55301C19022  M55301C19023  M55301C19024  M55301C19025  M55301C19026
    ...    M55301C19027  M55301C19028  M55301C19029  M55301C19030  M55301C19031  M55301C19032  M55301C19033  M55301C19034  M55301C19035
    ${actual_pm_values}=  Get Counter Value  pi_dir=${OUTPUT_DIR}/PMC/gnb_pm_counters  dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...  pi_list=${pi_list}  index=0

Set varying cqi for multiple UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${cqi_min}=1     ${cqi_max}=15
	...     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
    wtsrunner.csi_override_testmode_nr		profile_id=1	 cqi=0     cqi_mode=oscillating		cqi_min=${cqi_min} cqi_max=${cqi_max}
    ...     cqi_step=1 cqi_period=10
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        wtsrunner.ue_testmode_set_nr	id=${ue_idx} 	profile_id=1 	action=activate	 testmode=csi_override
    END
    Log to Console    ${qfi_id}
    Log to Console    ${rtp_codec}
    Log to Console    ${cqi_min}
Set fixed cqi for multiple UEs
   [Arguments]    ${start_ue_id}    ${end_ue_id}    ${cqi}     ${cqi_min}=1     ${cqi_max}=15
	...     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
    wtsrunner.csi_override_testmode_nr		profile_id=1	 cqi=${cqi}     cqi_mode=fixed      cqi_min=${cqi_min}      cqi_max=${cqi_max}
    ...     cqi_step=1 cqi_period=10
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        wtsrunner.ue_testmode_set_nr	id=${ue_idx} 	profile_id=1 	action=activate	 testmode=csi_override
    END
    Log to Console    ${qfi_id}
    Log to Console    ${rtp_codec}
    Log to Console    ${cqi_min}

Remove varying cqi for multiple UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${cqi_min}=1     ${cqi_max}=15
	...     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        wtsrunner.ue_testmode_set_nr	id=${ue_idx} 	profile_id=1 	action=deactivate	 testmode=csi_override
    END
    Log to Console    ${qfi_id}
    Log to Console    ${rtp_codec}
    Log to Console    ${cqi_min}
    Log to Console    ${cqi_max}
#Keywords for CB008200_C3_C4.robot cases

Initial Attach with SIP and VoNR Signalling
    MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}
    MultiUE PDU Addition should be Successful        ${st_ue_id}    ${en_ue_id}    nw_id=1    pdu_id=2
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=2   qosflows_to_add=2
    sleep    2s
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}      pdu_id=2      qosflows_to_add=3
	sleep    1s

VoNR Traffic stop and Deregistration
    Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

VoNR Traffic for counter DL_INACT_VONR_BIN_01
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=dl    trf_id=2    rtp_codec=custom
    ...    period_ms=700    rtp_send_silence_period=700    packets=10
    sleep    7s

VoNR Traffic for counter DL_INACT_VONR_BIN_02
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=dl    trf_id=2    rtp_codec=custom
    ...    period_ms=1200    rtp_send_silence_period=1200    packets=10
    sleep    12s

VoNR Traffic for counter DL_INACT_VONR_BIN_03
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=dl    trf_id=2    rtp_codec=custom
    ...    period_ms=1700    rtp_send_silence_period=1700    packets=10
    sleep    17s


VoNR Traffic for counter DL_INACT_VONR_BIN_04
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=dl    trf_id=2    rtp_codec=custom
    ...    period_ms=2200    rtp_send_silence_period=2200    packets=10
    sleep    22s


VoNR Traffic for counter DL_INACT_VONR_BIN_05
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=dl    trf_id=2    rtp_codec=custom
    ...    period_ms=2700    rtp_send_silence_period=2700    packets=10
    sleep    27s

VoNR Traffic for counter DL_INACT_VONR_BIN_06
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=dl    trf_id=2    rtp_codec=custom
    ...    period_ms=3200    rtp_send_silence_period=3200    packets=10
    sleep    32s

VoNR Traffic for counter DL_INACT_VONR_BIN_07
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=dl    trf_id=2    rtp_codec=custom
    ...    period_ms=3700    rtp_send_silence_period=3700    packets=10
    sleep    37s


VoNR Traffic for counter DL_INACT_VONR_BIN_08
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=dl    trf_id=2    rtp_codec=custom
    ...    period_ms=4200    rtp_send_silence_period=4200    packets=10
    sleep    42s


VoNR Traffic for counter DL_INACT_VONR_BIN_09
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=dl    trf_id=2    rtp_codec=custom
    ...    period_ms=4700    rtp_send_silence_period=4700    packets=10
    sleep    47s

VoNR Traffic for counter DL_INACT_VONR_BIN_10
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=dl    trf_id=2    rtp_codec=custom
    ...    period_ms=5200    rtp_send_silence_period=5200    packets=10
    sleep    52s

VoNR Traffic for counter UL_INACT_VONR_BIN_01
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=ul    trf_id=2    rtp_codec=custom
    ...    period_ms=700    rtp_send_silence_period=700    packets=10
    sleep    7s


VoNR Traffic for counter UL_INACT_VONR_BIN_02
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=ul    trf_id=2    rtp_codec=custom
    ...    period_ms=1200    rtp_send_silence_period=1200    packets=10
    sleep    12s

VoNR Traffic for counter UL_INACT_VONR_BIN_03
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=ul    trf_id=2    rtp_codec=custom
    ...    period_ms=1700    rtp_send_silence_period=1700    packets=10
    sleep    17s

VoNR Traffic for counter UL_INACT_VONR_BIN_04
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=ul    trf_id=2    rtp_codec=custom
    ...    period_ms=2200    rtp_send_silence_period=2200    packets=10
    sleep    22s

VoNR Traffic for counter UL_INACT_VONR_BIN_05
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=ul    trf_id=2    rtp_codec=custom
    ...    period_ms=2700    rtp_send_silence_period=2700    packets=10
    sleep    27s

VoNR Traffic for counter UL_INACT_VONR_BIN_06
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=ul    trf_id=2    rtp_codec=custom
    ...    period_ms=3200    rtp_send_silence_period=3200    packets=10
    sleep    32s


VoNR Traffic for counter UL_INACT_VONR_BIN_07
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=ul    trf_id=2    rtp_codec=custom
    ...    period_ms=3700    rtp_send_silence_period=3700    packets=10
    sleep    37s

VoNR Traffic for counter UL_INACT_VONR_BIN_08
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=ul    trf_id=2    rtp_codec=custom
    ...    period_ms=4200    rtp_send_silence_period=4200    packets=10
    sleep    42s

VoNR Traffic for counter UL_INACT_VONR_BIN_09
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=ul    trf_id=2    rtp_codec=custom
    ...    period_ms=4700    rtp_send_silence_period=4700    packets=10
    sleep    47s

VoNR Traffic for counter UL_INACT_VONR_BIN_10
    wtsrunner.trf_data_start     ue=1    pdu=2    qfi=3    dir=ul    trf_id=2    rtp_codec=custom
    ...    period_ms=5200    rtp_send_silence_period=5200    packets=10
    sleep    52s

Get BIN counters and validate
    [Arguments]    @{args}
    ${length}=    Get length    ${args}
    FOR     ${id}       IN RANGE     0     ${length}-1
    ${cnt_from_pm}=     Get PM counter value      pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters  moc=MRBTS-1/NRBTS-1/NRCELL-1
    ...  pi_id=@{args}[${id}]
    ${cnt_from_pm}=   convert to integer    ${cnt_from_pm}
    log to console   ${cnt_from_pm}
    should be true    @{args}[-1]-1 <= ${cnt_from_pm} <= @{args}[-1]+2
    END


VoNR Call Setup and Counter Update from DL_INACT_BIN_01 to DL_INACT_BIN_04
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter DL_INACT_VONR_BIN_01
    VoNR Traffic stop and Deregistration
    Sleep     2s
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter DL_INACT_VONR_BIN_02
    VoNR Traffic stop and Deregistration
    Sleep     2s
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter DL_INACT_VONR_BIN_03
    VoNR Traffic stop and Deregistration
    Sleep     2s
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter DL_INACT_VONR_BIN_04
    VoNR Traffic stop and Deregistration
    Sleep     2s
VoNR Call Setup and Counter Update from DL_INACT_BIN_05 to DL_INACT_BIN_08
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter DL_INACT_VONR_BIN_05
    VoNR Traffic stop and Deregistration
    Sleep     2s
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter DL_INACT_VONR_BIN_06
    VoNR Traffic stop and Deregistration
    Sleep     2s
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter DL_INACT_VONR_BIN_07
    VoNR Traffic stop and Deregistration
    Sleep     2s
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter DL_INACT_VONR_BIN_08
    VoNR Traffic stop and Deregistration
    Sleep     2s
VoNR Call Setup and Counter Update from DL_INACT_BIN_09 to DL_INACT_BIN_10
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter DL_INACT_VONR_BIN_09
    VoNR Traffic stop and Deregistration
    Sleep     2s
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter DL_INACT_VONR_BIN_10
    VoNR Traffic stop and Deregistration
    Sleep     2s
VoNR Call Setup and Counter Update from UL_INACT_BIN_01 to UL_INACT_BIN_02
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter UL_INACT_VONR_BIN_01
    VoNR Traffic stop and Deregistration
    Sleep     2s
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter UL_INACT_VONR_BIN_02
    VoNR Traffic stop and Deregistration
    Sleep     2s
VoNR Call Setup and Counter Update from UL_INACT_BIN_03 to UL_INACT_BIN_06
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter UL_INACT_VONR_BIN_03
    VoNR Traffic stop and Deregistration
    Sleep     2s
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter UL_INACT_VONR_BIN_04
    VoNR Traffic stop and Deregistration
    Sleep     2s
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter UL_INACT_VONR_BIN_05
    VoNR Traffic stop and Deregistration
    Sleep     2s
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter UL_INACT_VONR_BIN_06
    VoNR Traffic stop and Deregistration
    Sleep     2s
VoNR Call Setup and Counter Update from UL_INACT_BIN_07 to UL_INACT_BIN_10
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter UL_INACT_VONR_BIN_07
    VoNR Traffic stop and Deregistration
    Sleep     2s
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter UL_INACT_VONR_BIN_08
    VoNR Traffic stop and Deregistration
    Sleep     2s
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter UL_INACT_VONR_BIN_09
    VoNR Traffic stop and Deregistration
    Sleep     2s
    Initial Attach with SIP and VoNR Signalling
    VoNR Traffic for counter UL_INACT_VONR_BIN_10
    VoNR Traffic stop and Deregistration
    Sleep     2s
Check Cell On Air
    [Arguments]             ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                   file=${wts_cfg_file}
    wtsrunner.read_wtsemu_output_until_re    expected=Airphone: Cell Setup completed     timeout=240

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

MultiUE Register should be Successful with Fetch Bearer ID
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    ${ue_to_bearer_list}=    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
#    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    ${output}=  Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    ${bearer_list}       Create List
    Create File	    ${OUTPUT_DIR}/bearer.txt	    ${output}
    ${bearer_id}=    Run     cat ${OUTPUT_DIR}/bearer.txt |grep -i "servedRadioBearer drb-Identity" |awk '{print $4}'|sed 's/,//g'
    Append To List	   ${bearer_list}        ${bearer_id}
    Set To Dictionary	${ue_to_bearer_list} 	${ue_idx}	    ${bearer_list}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}     ${ue_to_bearer_list}


Create Modify PDU session
    [Arguments]     ${st_ue_id}     ${en_ue_id}    ${qos_profile}   ${pdu_id}     ${gfbr_mfbr_profile}=-1
         ...        ${num_ues}=${en_ue_id}          ${ue_to_bearer_list}=${bearer_list}
	builtin.Log    ${gfbr_mfbr_profile}
    [Documentation]    This keyword is wrepar for the ADD PDU  session and modification
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${QOS_prof}=      Set Variable  ${qos_profile}[${ue_id}][1:]
        ${len}=     Get Length  ${QOS_prof}
        ${QOS_strng}=    Run Keyword If  ${len} >0   Evaluate    ",".join(${QOS_prof})  #Got the QOS string
        ${pdu_id}=   Set Variable If      '2' in ${QOS_prof} or '3' in ${QOS_prof} or '4' in ${QOS_prof}   2   1

        ${gw_id}=       Evaluate    ${ue_id}+${num_ues}
        Run Keyword if  ${len} >0   Add PDU session     ${ue_id}      ${pdu_id}      ${gw_id}     ${QOS_strng}
        ...    ue_to_bearer_list=${ue_to_bearer_list}
    END

Start Data Transfer After GFBR Update
    [Arguments]    ${st_ue_id}     ${en_ue_id}    ${init_duration}   ${trigger_point_dur}    ${Dir}  ${trf_id}   ${qos_profile_unit}
    ...   ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}    ${updated_ue_list}    ${updated_qos_profile_speed_ul}
    ...   ${updated_qos_profile_speed_dl}   ${updated_dirct}      ${gfbr_mfbr_profile}    ${ttitrace_streaming}   ${update}=0    ${tti_dur}=${3}
    [Documentation]    This keyword is used to start the data transfer in UL and DL
    ${ul_ue_time_stamp}=    Create Dictionary
    ${dl_ue_time_stamp}=    Create Dictionary
    ${ul_ue_time_stamp1}=   Create Dictionary
    ${dl_ue_time_stamp1}=   Create Dictionary
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${ul_timestamp}=    Run Keyword If  '${Dir}' == 'ul'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_ul}[${ue_id}]    dir=${Dir}    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
        ...    sec=${init_duration}
         ${dl_timestamp}=   Run Keyword If  '${Dir}' == 'dl'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_dl}[${ue_id}]    dir=${Dir}    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
        ...    sec=${init_duration}
        ${ul_timestamp1}=    Run Keyword If  '${Dir}' == 'both'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_ul}[${ue_id}]    dir=ul    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
        ...    sec=${init_duration}
        ${dl_timestamp1}=    Run Keyword If  '${Dir}' == 'both'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_dl}[${ue_id}]    dir=dl    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
        ...    sec=${init_duration}

        Run Keyword If  '${Dir}' == 'ul'    Set To Dictionary	${ul_ue_time_stamp}	    ${ue_id}    ${ul_timestamp}
        Run Keyword If  '${Dir}' == 'dl'    Set To Dictionary	${dl_ue_time_stamp}	    ${ue_id}    ${dl_timestamp}

        Run Keyword If  '${Dir}' == 'both'    Set To Dictionary	    ${ul_ue_time_stamp}	    ${ue_id}    ${ul_timestamp1}
        Run Keyword If  '${Dir}' == 'both'    Set To Dictionary	    ${dl_ue_time_stamp}	    ${ue_id}    ${dl_timestamp1}
    END
    sleep    ${trigger_point_dur}s      # Sleep tiil updated point
    Run Keyword If  '${update}' == '1'    Create Modify PDU session for GFBR Update   ${st_ue_id}     ${en_ue_id}    ${qos_profile}
    ...    pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    # Updated QOS file
    ${dur}=     Evaluate    ${init_duration} - ${trigger_point_dur}
    FOR     ${ue_id}    IN  @{updated_ue_list}
        ${ul_timestamp_2nd}=    Run Keyword If  '${updated_dirct}' == 'ul'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${updated_qos_profile_speed_ul}[${ue_id}]    dir=${Dir}    pdu_id=1
        ...    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]    sec=${dur}

         ${dl_timestamp_2nd}=   Run Keyword If  '${updated_dirct}' == 'dl'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${updated_qos_profile_speed_dl}[${ue_id}]    dir=${Dir}    pdu_id=1    trf_id=${trf_id}
        ...    qfi_id=${qos_profile}[${ue_id}]    sec=${dur}

        ${ul_timestamp1_2nd}=       Run Keyword If  '${updated_dirct}' == 'both'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${updated_qos_profile_speed_ul}[${ue_id}]    dir=ul    pdu_id=1    trf_id=${trf_id}
        ...    qfi_id=${qos_profile}[${ue_id}]    sec=${dur}

        ${dl_timestamp1_2nd}=      Run Keyword If  '${updated_dirct}' == 'both'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${updated_qos_profile_speed_dl}[${ue_id}]    dir=dl    pdu_id=1    trf_id=${trf_id}
        ...    qfi_id=${qos_profile}[${ue_id}]    sec=${dur}

        Run Keyword If  '${Dir}' == 'ul'    Set To Dictionary	${ul_ue_time_stamp1}	${ue_id}    ${ul_timestamp_2nd}
        Run Keyword If  '${Dir}' == 'dl'    Set To Dictionary	${dl_ue_time_stamp1}	${ue_id}    ${dl_timestamp_2nd}

        Run Keyword If  '${Dir}' == 'both'    Set To Dictionary	    ${ul_ue_time_stamp1}	    ${ue_id}    ${ul_timestamp1_2nd}
        Run Keyword If  '${Dir}' == 'both'    Set To Dictionary	    ${dl_ue_time_stamp1}	    ${ue_id}    ${dl_timestamp1_2nd}
    END
    Start and Stop TTI TRACE    ${tti_dur}
    sleep    ${dur}s
    ${new_path}        Collect TTI Trace   ${ttitrace_streaming}
    ${ue_to_delta_time_ul}=    Get Time Diff     ${ul_ue_time_stamp1}      ${ul_ue_time_stamp}
    ${ue_to_delta_time_dl}=    Get Time Diff     ${dl_ue_time_stamp1}      ${dl_ue_time_stamp}
    [Return]    ${ue_to_delta_time_ul}    ${ue_to_delta_time_dl}    ${new_path}

Get Received Sent Bytes New
   [Arguments]    ${st_ue_id}    ${en_ue_id}    ${qos_profile}      ${dir}
   ${ue_sent_recv_qos_wise}         Create Dictionary
   FOR     ${x}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${pdu_id}=   Set Variable If      '2' in ${qos_profile}[${x}] or '3' in ${qos_profile}[${x}]   2   1
        ${len}=     Get Length      ${qos_profile}[${x}]

        ${Ue_tp}=    Get Bearer Stats New     ${x}    ${len}      ${pdu_id}     ${dir}	${qos_profile}
        Set To Dictionary	${ue_sent_recv_qos_wise} 	${x}	${Ue_tp}
        ${Ue_tp}         Create List  #Empty the list
    END
    [Return]    ${ue_sent_recv_qos_wise}


Add PDU session
     [Arguments]     ${ue_id}      ${pdu_id}      ${gw_id}     ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}
     [Documentation]    This keyword starts the ADD PDU  session and modification
        Run Keyword If   ${pdu_id} == 2
        ...     Modified UE PDU Addition should be Successful       ${ue_id}     ${pdu_id}     1   ${gw_id}
       ${x}=   Run Keyword If    ${pdu_id} != ${2}  execute_command.modify_pdu_session_verify     ${ue_id}    ${pdu_id}
       ...     qosflows_to_add=${Q_O_ADD}   ue_to_bearer_list=${ue_to_bearer_list}
        ...    ELSE
        ...    VONR GBR NON GBR Add PDU session    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ue_to_bearer_list=${ue_to_bearer_list}
        Should Contain    ${x}   Pass
UE Trigger Traffic for SA QFI Based
    [Arguments]     ${ue_idx}      ${Traffic_rate}    ${data_rate}    ${dir}=${Dir}    ${sec}=-1    ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    ${idx}=     Set Variable    ${1}
    ${unit_idx}=     Set Variable    ${0}
    ${data_start_time}=     Create List
    FOR     ${Q_id}   IN    @{qfi_id}   #replace with QOS 1,2,3,4 or one by one
    Log to Console    \nRunning DL Traffic for ${data_rate} ${Traffic_rate}...
    ${pdu_id}=         Set Variable If      '${Q_id}' == '2' or '${Q_id}' == '3' or '${Q_id}' == '4'     2     1
    #${expected_str}=       Set Variable If   '${dir}' == 'dl'    Started Downlink Internal traffic Receiver*    Started Uplink Internal traffic*
    ${expected_str}=       Set Variable If   '${dir}' == 'dl'    Started Downlink*    Started Uplink*
    ${expected_trf}=       Set Variable If   '${dir}' == 'dl'    DL TRF:    UL TRF:   # U is in new Line
    ${t_idx}=       Set Variable If      '${Q_id}' == '2' or '${Q_id}' == '3' or '${Q_id}' == '4'   ${Q_id}     ${idx}
    ${unit}     Set variable if    '${Traffic_rate[${unit_idx}]}' == 'mbps'      ${1048576}      ${1024}
    ${spd}=   Run Keyword If   'amr' in '${data_rate[${unit_idx}]}' or 'g7' in '${data_rate[${unit_idx}]}' or 'custom' in '${data_rate[${unit_idx}]}'
    ...       Set Variable   ${data_rate[${unit_idx}]}
    ...      ELSE
    ...      Evaluate     (${unit} * ${data_rate[${unit_idx}]})
    ${rate}     Set variable if    '${Traffic_rate[${unit_idx}]}' == 'rtp_codec'    rtp_codec    bps
    Run Keyword If      ${sec}==-1 #QOS{5,6,5} 1-3
    ...    wtsrunner.trf_data_start     ue=${ue_idx}     pdu=${pdu_id}   qfi=${t_idx}    dir=${dir}    trf_id=${trf_id}    ${rate}=${spd}
    ...    ELSE
    ...    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${t_idx}    dir=${dir}    trf_id=${trf_id}    seconds=${sec}
    ...    ${rate}=${spd}
    ${time}=    DateTime.Get Current Date
    Append To List	${data_start_time}	    ${time}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${expected_str}    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    ${expected_trf}    partial_match=${TRUE}
    #   Log to Console    ${output}
    ${m} =    utility.check_op      ${output}
    Run Keyword If      ${m} != ${1}
    ...    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${t_idx}    dir=${dir}    trf_id=${trf_id}    seconds=${sec}
    ...    ${Traffic_rate[${unit_idx}]}=${data_rate[${unit_idx}]}
    ${output1}=      Run Keyword If      ${m} != ${1}
    ...        wtsrunner.read_wtsemu_output_until_re    expected=${expected_str}    timeout=10
    ${output}=      Set Variable If   ${m} != ${1}    ${output1}    ${output}
    ${output}    Get Lines Matching Regexp    ${output}    ${expected_trf}    partial_match=${TRUE}
    Log to Console    ${output}
    ${unit_idx}=    Evaluate    ${unit_idx}+${1}
    Continue For Loop If    '${Q_id}' == '2' or '${Q_id}' == '3' or '${Q_id}' == '4'
    ${idx}=     Evaluate    ${idx}+${1}
	END
    BuiltIn.Log    traffic_data_is_started_successfully
    [Return]        ${data_start_time}

Create Modify PDU session for GFBR Update
    [Arguments]     ${st_ue_id}     ${en_ue_id}    ${qos_profile}   ${pdu_id}     ${gfbr_mfbr_profile}
    [Documentation]    This keyword is wrepar for the ADD PDU  session and modification
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${QOS_prof}=      Set Variable  ${qos_profile}[${ue_id}][1:]
        ${len}=     Get Length  ${QOS_prof}
        ${QOS_strng}=    Run Keyword If  ${len} >0   Evaluate    ",".join(${QOS_prof})
        ${pdu_id}=   Set Variable If      '2' in ${QOS_prof} or '3' in ${QOS_prof} or '4' in ${QOS_prof}   2   1
        ${gw_id}=       Evaluate    ${ue_id}+${en_ue_id}
        Run Keyword if  ${len} >0   Update QOS Flow GFBR MFBR    ${ue_id}   ${pdu_id}    ${QOS_prof}     ${gfbr_mfbr_profile}
    END


Get Time Diff
    [Arguments]    ${ue_time2}      ${ue_time1}
    ${ue_list}=     Get Dictionary Keys     ${ue_time1}
    ${ue_time_dev}=     Create Dictionary
    FOR     ${ue_id}    IN      @{ue_list}
        ${diff}    Get Delta Time in list   ${ue_time2}[${ue_id}]       ${ue_time1}[${ue_id}]
        Set To Dictionary	    ${ue_time_dev}      ${ue_id}    ${diff}
    END
    [Return]     ${ue_time_dev}


Get Bearer Stats New
    [Arguments]    ${ue_id}     ${len}        ${pdu_id}   ${dir}	${qos_profile}
	${qoslist_ue}=      Set Variable    ${qos_profile}[${ue_id}]
    ${sent_rcv}         Create List
    ${idx}=     Set Variable    ${1}
    FOR     ${ue_qfi}    IN RANGE    ${len}
		${pdu_id}=   Set Variable If    '2' == '${qoslist_ue[${ue_qfi}]}' or '3' == '${qoslist_ue[${ue_qfi}]}' or '4' == '${qoslist_ue[${ue_qfi}]}'
		...	    2   1
		#[1,2,3]
        ${t_idx}=    utility.get_qfi    ${qoslist_ue}   ${ue_qfi}   ${idx}
        ${reading}=    Read Bearer stats Command New    ${ue_id}    ${dir}    ${pdu_id}      ${t_idx}
        Append To List  ${sent_rcv}     ${reading}
        Continue For Loop If    '2' == '${qoslist_ue[${ue_qfi}]}' or '3' == '${qoslist_ue[${ue_qfi}]}' or '4' == '${qoslist_ue[${ue_qfi}]}'
        ${idx}=     Evaluate    ${idx}+${1}
    END
    [Return]    ${sent_rcv}


#    [Arguments]    ${start_ue_id}   ${end_ue_id}
#    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
#        wtsrunner.ue_pdu_session_release    ue=${ue_idx}    pdu=1    by=amf
#        wtsrunner.ue_pdu_session_release    ue=${ue_idx}    pdu=2    by=amf
#        wtsrunner.read_wtsemu_output_until    expected=Received Pdu Session Resource Release Response Message
#        ...                     timeout=30
#        BuiltIn.Log          ue=${ue_idx} pdu=1 release with successfully
#        Log to Console       ue=${ue_idx} pdu=1 release with successfully
#	END
#	BuiltIn.Log       All_ue_release_their_pdu_successfuly
#	Log to Console    All_ue_release_their_pdu_successfuly

Modified UE PDU Addition should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}     ${nw_id}    ${gw_id}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${RAN_UE_NGAP_ID}=      Evaluate    ${ue_id}-${1}
    ${pdu_addition_pattern}=    Set Variable    Pdu Session Resource Setup Response Message with RAN UE NGAP ID ${RAN_UE_NGAP_ID} handled
    ${output}=      Read WTS Output For Pattern And Print matching Lines    ${pdu_addition_pattern}    ${Timeout_SA}
    ${str_len}=     Get Length     ${output}
    Should Not Be Equal     ${str_len}      ${0}
    BuiltIn.Log                ue_pdu_addition_is_ok

VONR GBR NON GBR Add PDU session
    [Arguments]    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}

      ${x}=		execute_command.modify_pdu_session_verify    ${ue_id}    ${pdu_id}   qosflows_to_add=${Q_O_ADD}
      ...   ue_to_bearer_list=${ue_to_bearer_list}
      Should Contain    ${x}   Pass
      [Return]      ${x}

Get Delta Time in list
    [Arguments]    ${time2_list}      ${time1_list}
    ${length}=     Get Length  ${time2_list}
    ${delta_list}=     Create List
    FOR    ${idx}   IN RANGE    ${length}
        ${diff} =	DateTime.Subtract Date From Date   ${time2_list[${idx}]}     ${time1_list[${idx}]}
        Append To List  ${delta_list}     ${diff}
    END
    [Return]      ${delta_list}

Read Bearer stats Command New
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL/DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}    ${dir}   ${pdu_id}   ${qfi_id}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=${dir}
    ${bearer_stat}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
	${rcv_bytes}     Get Regexp Matches    ${bearer_stat}    Bytes received +(\\d+)    1
    ${sent_byts}     Get Regexp Matches    ${bearer_stat}    Bytes sent +(\\d+)    1
    ${ratio_rcv_sent}    Evaluate    ${rcv_bytes[0]}/${sent_byts[0]}
    Should be true     0.99<=${ratio_rcv_sent}<=1     #receive bytes equal to sent bytes
    [Return]    ${rcv_bytes[0]}	        ${sent_byts[0]}

MultiUE PDU Release should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        wtsrunner.ue_pdu_session_release    ue=${ue_idx}    pdu=1    by=amf
        wtsrunner.ue_pdu_session_release    ue=${ue_idx}    pdu=2    by=amf
        wtsrunner.read_wtsemu_output_until    expected=Received Pdu Session Resource Release Response Message
        ...                     timeout=30
        BuiltIn.Log          ue=${ue_idx} pdu=1 release with successfully
        Log to Console       ue=${ue_idx} pdu=1 release with successfully
	END
	BuiltIn.Log       All_ue_release_their_pdu_successfuly
	Log to Console    All_ue_release_their_pdu_successfuly

Collect PM Counters
    ${pm_counters_dir}=  Collect PM Counter  target_dir=${OUTPUT_DIR}/PMC
    Set Suite variable  ${pm_counters_dir}

Get 8955 counters and validate
    [Arguments]    ${PRB_USED_PDSCH_IA}    ${DL_SLT_IA}
    @{pi_list}=  Create List  ${PRB_USED_PDSCH_IA}  ${DL_SLT_IA}
    @{counter_value} =  Create List
    FOR    ${counter}    IN    @{pi_list}
        ${actual_pm_values}=    Run Keyword If
        ...    '${counter}' == 'M55308C10008' or '${counter}' == 'M55308C00019'
        ...    Get PM counter value modified    pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters
        ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${counter}
        ${actual_pm_values}=   convert to integer    ${actual_pm_values}
        Should Be True    ${actual_pm_values}
        Append To List    ${counter_value}    ${actual_pm_values}
    END

Update QOS Flow GFBR MFBR
    [Arguments]     ${ue_id}   ${pdu_id}    ${QOS_prof}     ${gfbr_mfbr_profile}
        ${result}=      execute_command.update_pdu_session_gfbr_mfbr    ${ue_id}    ${pdu_id}    ${QOS_prof}
        ...     ${gbr_qfi_list_cfg}     ${gfbr_mfbr_profile}
#        Should Contain    ${result}   Pass
Start and Stop TTI TRACE
    [Arguments]    ${duration}=${3}
    Start Ttitrace With Streaming Mode
    sleep    ${duration}s
    Stop Ttitrace

Collect TTI Trace
    [Arguments]    ${ttitrace_path}
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${new_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}/
    Convert Ttitrace From Pcap To Excelcsv        ${new_path}
    Convert Tti To Csv Mode          ${new_path}
    [Return]        ${new_path}

Start TTI_TRACE custom

    [Arguments]    ${cell_id}=${50}

    Common Start Ttitrace With Streaming Mode_3 custom        pysical_cell_ids=${cell_id}

Common Start Ttitrace With Streaming Mode_3 custom

    [Arguments]    ${pysical_cell_ids}=50    ${names}=l2stream3_ttitrace

    [Documentation]    This keyword is used to start ttitrace with streaming mode.

    ...    examples 1: catch 1 cell

    ...    Start Ttitrace With Streaming Mode

    ...    examples 2: catch 2 cells

    ...    Start Ttitrace With Streaming Mode    50,51

    ${executor}=  Create Dictionary

    ...  host=192.168.255.129

    ...  user=Nemuadmin

    ...  password=nemuuser

    ...  port=443

#    ${nr_phy_cell_ids}=    Common Get PhysCellId Of GNB Runtime

    ${nr_phy_cell_ids}    Create List    ${pysical_cell_ids}

    ${nr_phy_cell_ids}=    Evaluate  map(int, $nr_phy_cell_ids)

    Log Many    ${pysical_cell_ids}       ${nr_phy_cell_ids}

#    ${localIpAddr}=    Get localIpAddr Of GNB

#10.0.1.2 for ute

    ${localIpAddr}=    set variable    10.0.1.2

#    ${web_card}    ${dest_ip}=    Get EIF Info Of Control PC

    ${web_card}    ${dest_ip}=    Common Get EIF Info Of Control PC

    ${l2_stream_config_1}=  Create Dictionary

    ...  nr_phy_cell_ids=${nr_phy_cell_ids}

    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}

    TCPDUMP.create tcpdump collector

    ...  name=tcpdump_ttitrace

    ...  options=-i ${web_card} udp and dst ${dest_ip} and dst port 5678

    ...  sudo_password=ute

    L2STREAM3.Create Sbts L2stream Collector

    ...  name=${names}

    ...  destination_ip_addr=${dest_ip}

    ...  collector=tcpdump_ttitrace

    ...  l2_stream_configuration=${l2_stream_configuration}

    ...  webservice=${executor}

    L2STREAM3.Set Suite Alias

    ...  alias=${names}

    CORE.setup_collectors

    ...  names=${names}

    CORE.start_collectors

    ...  names=${names}
