*** Settings ***
Documentation
...    author: meng yan
...    contact: meng.yan@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_2_SG
...    Feature 5GC001796

#Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/asod.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    ../../common/siso_cloud_coam_common_keyword.robot
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Library    ute_reporting_portal
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/kpi_reporter.py
Library    kpi_reporter.KpiReporter    WITH NAME    KpiReporter
#Library    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007326_2060/Resources/TTI_Trace_ASOE.py    WITH NAME    ttiASOE
Library    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007326_2060/Resources/Read_laIniDelta.py    WITH NAME    LAINI
Library     taf.collectors.l2stream3    WITH NAME    L2STREAM3
Library     taf.converters.eventdecoder    WITH NAME    EVENTDECODER
#Library     ./lib/tti_stream_mode_convert.py    WITH NAME    TtiSMConvert
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/tti_stream_mode_convert.py   WITH NAME    TtiSMConvert



*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
${ue_type}    ${tl.ues[0].capabilities[1]}
${gnb_BTS_host}           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${gnb_BTS_username}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gnb_BTS_password}       ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gNB_ip}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${tl_scf_dir_path}    /home/ute/MN/UTE/robotws/commissionings/HGZ/7_5_UTE5G402T159/
&{TTITRACE_CONFIG_L2PS}            up_sw=L2Ps    trace_type=Component
&{TTITRACE_CONFIG_L2LO}            up_sw=L2Lo    trace_type=Component
&{TTITRACE_CONFIG_L2HIPDCP}        up_sw=L2HiPdcp    trace_type=Component
&{TTITRACE_CONFIG_L2HIRLC}         up_sw=L2HiRlc    trace_type=Component
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2HIPDCP}    &{TTITRACE_CONFIG_L2HIRLC}    &{TTITRACE_CONFIG_L2PS}    &{TTITRACE_CONFIG_L2LO}
@{L2STREAM_L2_PS_CONFIG}           &{TTITRACE_CONFIG_L2PS}
${SSH_CMD}                         sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1

*** Keywords ***
SISO Coam Suite Setup for CLOUD UTE
    [Arguments]    ${enb_flag}=${True}    ${gnb_index}=0
    robot_common_operations.Common Suite Setup
    log to console    \n*** SISO Coam Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    set suite variable    ${suite_setup_fail_flag}    ${True}
    run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup    gnb_index=${gnb_index}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB    connection=${connection}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    set suite variable    ${scf_path}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    run keyword if    '${gNb_CuType}'=='NSA' and '${enb_flag}'=='${True}' or '${gNb_CuType}'=='SA+NSA' and '${enb_flag}'=='${True}'
    ...    Run Keyword And Ignore Error    get eNB active version
    set suite variable    ${suite_setup_fail_flag}    ${False}

Common Setup
    [Documentation]    Author: zhao nana
    ...                This keyword is check onair status
    Run keyword and continue on failure    Coam Du Check cell on air

Prepare testline to cell onair for SA 1796
    [Arguments]      ${localFilePath}    ${tl_scf_filename}    ${tl_scf_dir_path}=${tl_scf_dir_path}    ${gnb_index}=${0}
    ...     ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Update the swconfig file  gnb_index=${gnb_index}    localFilePath=${localFilePath}
    Prepare with COAM classical BTS cell onair for SA    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_filename=${tl_scf_filename}
    ...    bts_host=${bts_host}    username=${username}    password=${password}

Update the swconfig file
    [Arguments]    ${localFilePath}    ${gnb_index}=${0}
    wait until keyword succeeds    5min    10s    Connect to Common Unit Master with gnbindex   gnb_index=${gnb_index}    alias=ASIK Master
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=ASIK Master
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=ASIK Master

Prepare with COAM classical BTS cell onair for SA
    [Arguments]    ${tl_scf_dir_path}    ${tl_scf_filename}    ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}
    ...    ${password}=${gnb_BTS_password}
    Perform full commission for COAM gnb     scf=${tl_scf_dir_path}${tl_scf_filename}
      ...    gnb_ip=${bts_host}    username=${username}    password=${password}
    COAM Wait for gnb ready    bts_host=${bts_host}    username=${username}    password=${password}
    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air

Perform full commission for COAM gnb
    [Arguments]    ${scf}    ${gnb_ip}    ${username}    ${password}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}    username=${username}      password=${password}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=1000    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections

COAM Wait for gnb ready
    [Timeout]  30 min
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM    ${bts_host}=${bts_host}    ${username}=${username}    ${password}=${password}
    Wait until keyword succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                    bts_host=${bts_host}
    ...                    username=${username}
    ...                    password=${password}

restore swConfig to default
    [Arguments]     ${localFilePath}
    Update the swconfig file    localFilePath=${localFilePath}

COAM gNB Reset site
    Connect to gnb coam via ssl    connection=coam_admin
    coam.reset_site         connection=coam_admin
    COAM Teardown gnb connections    coam_admin
    COAM Wait for gnb ready    bts_host=${gnb_BTS_host}    username=${gnb_BTS_username}    password=${gnb_BTS_password}
    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air

step1: Prepare UE
    [Documentation]    Author: zhao nana
    ...                This keyword is prepare UE
    [Arguments]    ${ue_index}=${0}
    log to console      step1: Prepare UE
    #power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    ui_version=S21UI4.0
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}

Step2: UE Attach
    [Documentation]    Author: zhao nana
    ...                This keyword is attach UE
    [Arguments]    ${ue_index}=${0}
    log to console      Step2: UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    #Preparation and execution for Commercial UE Attach    ue_index=${ue_index}
    #Log    click Airplane mode switch to disable its function so that make UE attach

Step3: Start traffic
    [Documentation]    Author: zhao nana
    ...                This keyword is start traffic
    [Arguments]   ${ul_throughput}=100M    ${dl_throughput}=50M    ${protocol}=udp    ${ue_index}=${1}
    log to console      Step5: Start dl traffic
    #power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=1200
    #...    ue_type=${ue_type}
  	#...    iperf_type=via_command
    #...    protocol=${protocol}
    #sleep    1s
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}    duration=1200
    ...    ue_type=${ue_type}
  	...    protocol=${protocol}    buffer_size=1400B    process_num=${1}    seg_size=1350    window=16M
    sleep    2s

Step4: Check dl throughput
    [Documentation]    Author: zhao nana
    ...                This keyword is check troughput
    [Arguments]    ${traffic_time}=90s
    log to console      Step6: Check throughput
    Login via Web
    ${cell_number}    selenium_coam.get_number_of_cells
    Run Keyword And Ignore Error    Logout via Web
    AAsys log captrue    stop_aasys_flag=${False}
    sleep      ${traffic_time}
    ${cell_id}    Get nrcellid from aasys log
    ${dl_traffic_data}    Get traffic data from aasys log
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}


Step6: Stop traffic
    [Documentation]    Author: zhao nana
    ...                This keyword is Stop traffic
    [Arguments]    ${ue_index}=${0}
    log to console      Step7: Stop traffic
    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=via_command
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}


Step7: UE Detach
    [Documentation]    Author: zhao nana
    ...                This keyword is UE Detach
    [Arguments]    ${ue_index}=${0}
    log to console      Step7: UE Detach
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

Common Capture BIP log and download
    [Documentation]    Author: zhao nana
    ...                This keyword is Capture BIP log and download
    [Arguments]    ${duration}=5s    ${log_path}=${logPath}
    Connect to Common Unit Master
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts
    sleep    ${duration}
    ${list_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_path=${log_path}
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    ssh.Disconnect    connection=ASIK Master
    [Return]    ${bip_log_path}

BIP log Check
    [Documentation]    Author: zhao nana
    ...                This keyword is check BIP log
    log to console      BIP log Check
    ${log_path}    BIP log capture and download
    ...    save_time_interval=2    filter=ether[0x18:2]==0x133 or ether[0x18:2]==0x249 or ether[0x18:2]==0x135
    ${msc_and_beam_id}    Get ul dl mcs and beam id    log_path=${log_path}    sample=5

Case_Teardown
    [Documentation]    Author: zhao nana
    ...                This keyword is teardown
    [Arguments]    ${connection}=COAM    ${ue_number}=1
    Log To Console    \n *** Case teardown
    #FOR    ${ue_index}    IN RANGE    ${ue_number}
        #Run Keyword And Ignore Error    Step6: Stop traffic    ue_index=${ue_index}
        ##END
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    admin_cli.teardown    connection=${connection}
    Run Keyword And Ignore Error    Teardown the Aasyslog save progress
    Run Keyword And Ignore Error    Stop BIP Capture On ASOD
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

BOTH TPUT Upload
    [Documentation]    Author: zhao nana
    ...                This keyword is ul and dl thouthput upload
    [Arguments]     ${exp_dl}    ${dl_avg}    ${dl_max}    ${dl_min}    ${exp_ul}    ${ul_avg}    ${ul_max}    ${ul_min}
    ...    ${protocol}    ${deviation}=10%    ${logs_dir}=${None}
    Run Keyword And Ignore Error    KpiReporter.add_dl_throughput_into_report_list    exp_dl=${exp_dl}
    ...                                               dl_avg=${dl_avg}
    ...                                               dl_max=${dl_max}
    ...                                               dl_min=${dl_min}
    Run Keyword And Ignore Error    KpiReporter.add_ul_throughput_into_report_list    exp_ul=${exp_ul}
    ...                                               ul_avg=${ul_avg}
    ...                                               ul_max=${ul_max}
    ...                                               ul_min=${ul_min}
    Run Keyword And Ignore Error    KpiReporter.report_tput_kpi    protocol=${protocol}    deviation=${deviation}
    ...    logs_dir=${logs_dir}


#*******modify NIDD parameter*********

Get Filter actEnhanced
    [Documentation]  Author: meng.yan
    ...              Description: get actEnhancedLinkAdaptation
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    ${actEnhanced_value}    selenium_coam.get_parameter_value
    ...   dist_name=${MRBTS_ID}/NRBTS-1
    ...   abbr=actEnhancedLinkAdaptation
    ...   filter_param=Activate the enhanced link adaptation procedures
    set suite variable    ${actEnhanced_value}

Restore actEnhanced in webui
    [Documentation]  Author:meng.yan
    ...              Description: restore actEnhancedLinkAdaptation value
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1
    ...    abbr=actEnhancedLinkAdaptation
    ...    new_value=true
    ...    filter_param=Activate the enhanced link adaptation procedures
    sleep    1s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Modify actEnhancedLinkAdaptation false
    [Documentation]  Author: meng.yan
    ...              Description: modify actEnhancedLinkAdaptation value
    Du login page via webUI
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-159
    ...    abbr=actEnhancedLinkAdaptation
    ...    new_value=false
    ...    filter_param=Activate the enhanced link adaptation procedures
    sleep    1s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    DU COAM selenium logout


#*******tti trace *********

__Keywords only for searching should not use
    [Documentation]    this keyword only for searching keywords in the robot, should not use.
    Start Ttitrace With Streaming Mode
    Stop Ttitrace
    Decode Ttitrace Log

start tti
    [Arguments]    ${bts_ip}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_ip}    username=${gnb_BTS_username}    password=${gnb_BTS_password}    connection=${connection}
    Start Ttitrace With Streaming Mode

Start Ttitrace With Streaming Mode
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    ...    This keyword is used to start ttitrace with streaming mode.
    ...    Start Ttitrace With Streaming Mode
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${l2_stream_configuration}=${L2STREAM_COMPONENT_CONFIG}
    ...    ${gnb_index}=0   ${SW_BRANCH}=None
    ...    ${eth_port_on_ute}=eth0
    ...    ${eth_ip_addr_on_ute}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${localIpAddr}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    log to console    setup admin for ttitrace...

    Run Keyword If    '${SW_BRANCH}'=='None'    Get Software Version_ASOE
    ${executor}=  Create Dictionary
    ...  host=${localIpAddr}
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}

    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${eth_port_on_ute} udp and dst ${eth_ip_addr_on_ute} and dst port 5678
    ...  sudo_password=${tl.test_pc.default_ssh_connection_details.password}
    L2STREAM3.create_sbts_l2stream_collector
    ...  name=${collector_names}
    ...  destination_ip_addr=${eth_ip_addr_on_ute}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    ...  dscp=10
    L2STREAM3.Set Suite Alias
    ...  alias=${collector_names}
    CORE.setup_collectors
    ...  names=${collector_names}
    CORE.start_collectors
    ...  names=${collector_names}
    log to console    finish admin process for ttitrace,start to catch ttitrace log...

Stop Ttitrace
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${log_dir}=${TS_CASE_LOG_PATH}/ttitrace_streaming/
    log to console    stop catching ttitrace...
    CORE.stop_collectors
    ...  names=${collector_names}
    CORE.collect_collectors
    ...  names=${collector_names}    target_dir=${log_dir}
    CORE.teardown_collectors
    ...  names=${collector_names}
    ${file_path}    Set Variable    ${log_dir}/${collector_names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    [Return]   ${file_path}

Decode Ttitrace Log
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${log_dir}=${TS_CASE_LOG_PATH}/ttitrace_streaming    ${format_tti_log}=${False}
    log to console    Start to decode ttitrace...
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${csv_file_path}   Convert Ttitrace From Pcap To Excelcsv    log_path=${log_dir}    collector_names=${collector_names}
    run keyword if   ${format_tti_log}   log to console    Start to format ttitrace...
    run keyword if   ${format_tti_log}   Format Tti In Stream Mode    ${csv_file_path}/tcpdump_ttitrace_dl.csv
    ...    ${csv_file_path}/format_output_dl.csv
    run keyword if   ${format_tti_log}   Format Tti In Stream Mode    ${csv_file_path}/tcpdump_ttitrace_ul.csv
    ...    ${csv_file_path}/format_output_ul.csv
    log to console    decode ttitrace finished.
    [Return]    ${csv_file_path}

Capture And Decode TTitrace
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    [Arguments]    ${collector_names}=l2stream3_ttitrace
    Stop Ttitrace    collector_names=${collector_names}
    ${csv_file_path}    Decode Ttitrace Log    collector_names=${collector_names}
    [Return]    ${csv_file_path}

Convert Ttitrace From Pcap To Excelcsv
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}/ttitrace_streaming    ${collector_names}=l2stream3_ttitrace
    ${file_path}=    Set Variable    ${log_path}/${collector_names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    ${output_file_path}   ${file_name}    OperatingSystem.Split Path    ${file_path}

    EVENTDECODER.Create Eventdecoder Converter
    ...    name=converter
    ...    input_file_path=${file_path}
    ...    output_file_format=excelCsv
    ...    excel_csv_options=-w
    ...    output_file_path=${output_file_path}
    EVENTDECODER.Convert
    ...    name=converter
    ${csv_file_path}    Set Variable    ${log_path}/${collector_names}
    [Return]     ${csv_file_path}

Capture TTI log_ASOE
    [Arguments]    ${bts_ip}=${gNB_ip}    ${connection}=GNB_OAM
    #Connect to gnb coam via ssl    bts_host=${bts_ip}    username=${gnb_BTS_username}    password=${gnb_BTS_password}    connection=${connection}
    ${csv_path}    Capture And Decode TTitrace
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    ${UL_DL_csv_file_path_dict}=  Create Dictionary
    ...    DL=${csv_path}/tcpdump_ttitrace_dl.csv
    ...    UL=${csv_path}/tcpdump_ttitrace_ul.csv
    ${dl_path}=    get_from_dictionary    ${UL_DL_csv_file_path_dict}    DL
    ${ul_path}=    get_from_dictionary    ${UL_DL_csv_file_path_dict}    UL
    Set Suite Variable    ${TTI_CVS_PATH_DL}    ${dl_path}
    Set Suite Variable    ${TTI_CVS_PATH_UL}    ${ul_path}

Format Tti In Stream Mode
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    ...   This keyword is to convert tti collected by stream mode.
    [Arguments]    ${input_csv_name}    ${output_csv_name}    ${filters}=${EMPTY}
    Run Keyword If    '${filters}'=='${EMPTY}'    TtiSMConvert.Format Tti Stream Mode No Filters    ${input_csv_name}    ${output_csv_name}
    ...    ELSE    TtiSMConvert.Format Tti Stream Mode With Filters    ${input_csv_name}    ${output_csv_name}    ${filters}

Get Software Version_ASOE
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    [Arguments]    ${coam_connection}=GNB_OAM
    ${software_info_1}=    coam.Get Sw Version    connection=${coam_connection}
    Set Suite Variable    ${SOFTWARE_INFO}    ${software_info_1}
    Log    Software Version: ${SOFTWARE_INFO}    console=${True}    #5G21B_GNB_0000_000800_004084_0oeo9    5G21A_GNB_0011_000800_000601
    @{words}=    String.Split String    ${SOFTWARE_INFO}    _
    ${ENB_BUILD}=    Set Variable    ${words[0][0:4]}
    ${IS_SOFTWARE_KNIFE}=    Set Variable If    "${words[-1][0:3]}"=="000"    ${False}    ${True}
    #${ENB_BUILD}=    String.Get Substring    ${SOFTWARE_INFO}    0    4
    Set Suite Variable    ${ENB_BUILD}
    Set Suite Variable    ${IS_SOFTWARE_KNIFE}
    Get Software Version Total

Get Software Version Total
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    ...    This keyword is to get gNB software version including below 3 suite variables.
    ...
    ...    | Suite variable | Example | Description |
    ...    | ${SW_VERSION} | SBTS00 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | SBTS21B_ENB_9999_210324_000019 | total sw version |
    ...    | ${SW_BRANCH} | SBTS21B | the folder to stort config files for case |
    ...
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==9999 or ${sw_list[2]}==9990
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION}    SBTS00
    ...    ELSE    Set Suite Variable    ${SW_VERSION}    ${sw_list[0]}
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION_TOTAL}
    ...    SBTS00_${sw_list[1]}_${sw_list[2]}_${sw_list[3]}_${sw_list[4]}
    ...    ELSE    Set Suite Variable    ${SW_VERSION_TOTAL}    ${SOFTWARE_INFO}
    Set Suite Variable    ${SW_BRANCH}    ${sw_list[0]}
    Log    Software Version Total: ${SW_VERSION_TOTAL}    console=${True}

Parse laIniDelta Event_ASOE
    [Arguments]         ${target}=UPDATE    ${tti_path}=${TTI_CVS_PATH_DL}    ${traffic_direction}=DL
    # tti parse in B200 and B300
    ${laIniDelta}=   run keyword if   '${traffic_direction}'=='DL'   LAINI.read_lainidelta    ${tti_path}
#    ...                        ELSE       Read Lainidelta     ${tti_path}/combined_ul_trace.csv
	log 		  laIniDelta=${laIniDelta}
	log           even found=${laIniDelta['event']}
	Should Match    ${laIniDelta['event']}    ${target}
