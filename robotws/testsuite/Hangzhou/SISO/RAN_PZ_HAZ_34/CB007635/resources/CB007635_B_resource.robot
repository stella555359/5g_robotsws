*** Settings ***
Documentation
...    author: nana zhao
...    contact: nana.zhao@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_2_SG
...    Feature CB007635-B


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    ../../common/siso_cloud_coam_common_keyword.robot
Library    ute_reporting_portal
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/kpi_reporter.py
Library    kpi_reporter.KpiReporter    WITH NAME    KpiReporter

*** Variables ***

${ue_type}    ${tl.ues[0].capabilities[1]}

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
    [Arguments]   ${ul_throughput}=100M    ${dl_throughput}=50M    ${protocol}=udp    ${ue_index}=${0}
    log to console      Step5: Start traffic
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=1200    ue_type=${ue_type}
  	...    iperf_type=via_command
    ...    protocol=${protocol}
    sleep    1s          
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}    duration=1200    ue_type=${ue_type}
  	...    protocol=${protocol}    buffer_size=1400B    process_num=${1}    seg_size=1350    window=16M
    sleep    2s

Step4: Check throughput
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
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}

 
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
    FOR    ${ue_index}    IN RANGE    ${ue_number}
        Run Keyword And Ignore Error    Step6: Stop traffic    ue_index=${ue_index}
        Run Keyword And Ignore Error    Step7: UE Detach    ue_index=${ue_index}
    END
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
    Run Keyword And Ignore Error    KpiReporter.report_tput_kpi    protocol=${protocol}    deviation=${deviation}    logs_dir=${logs_dir}
