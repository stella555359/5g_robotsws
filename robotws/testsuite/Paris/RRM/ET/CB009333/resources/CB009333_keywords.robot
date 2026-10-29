*** Settings ***

Documentation
...   author: Damian Zak
...   maintainer: Damian Zak, Mateusz Pajor
...   contact: damian.zak@nokia.com, mateusz.pajor@nokia.com
...   description: CB009333 common keywords

Library    ta5g_pm_counters

Library    CB009333_keywords.py
Library    CB009333_wts_config.py
Library    CB009333_attach_traffic.py
Library    CB009333_iphy_modification.py
Library    CB009333_tti_trace.py
Library    ute_syslog
Library    testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb            WITH NAME    common_gnb
Library    testsuite.Paris.RRM.ET.resources_KRK.python.common_wts            WITH NAME    common_wts
Library    testsuite.Paris.RRM.ET.resources_KRK.python.common_airphone       WITH NAME    common_airphone
Library    testsuite.Paris.RRM.ET.resources_KRK.python.pm_counters           WITH NAME    pm_counters
Library    taf.sw.scout                                                      WITH NAME    scout
Library    taf.sw.reporting_portal                                           WITH NAME    reporting_portal

Resource   ../../../../resources/SWENG/robot/Setup.robot

Resource   taf/rfrl/common_resources/robot/libraries_instances.robot
Resource   ../../resources_KRK/robot/TtiTrace/tti_trace_collector.robot

Variables    variables.py

*** Keywords ***
CB009333 Suite Setup
    Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}
    common_airphone.Log Airphone Build
    common_gnb.Log Gnb Build
    common_wts.Configure IPs On Vm Interfaces
    ...    cfg_filepath=/opt/iphy/latest/basic_setup.cfg
    common_gnb.Collect SCF File
    ...    final_path=${OUTPUT_DIR}/${SUITE_NAME}/default_scf.xml

CB009333 Test Setup
    [Arguments]    ${delta_path}=${None}    ${net_arch}=SA    ${nr_ue_caps}=${None}    ${mrdc_ue_caps}=${None}
    ...            ${arfcn_gscn_change}=${None}    ${slice_scheduler}=${False}    ${gscn_value}=${None}
    ...            ${sib_reception_dict}=${None}
    Log    \nStart setup    console=True
    Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    Change Gscn In Iphy
    ...    gscn_value=${gscn_value}
    Modify Iphy To Single RU Configuration
    Log To Console  Sending delta commissioning ${delta_path}
    common_gnb.Check If Delta Is Already Uploaded
    ...    path_to_delta=${delta_path}
    common_gnb.Wait For All Radio Modules To Be Online
    Wait Until Keyword Succeeds    5min    30s    common_gnb.Assert BTS In State
    ...    bts_state=configured
    ${wts_config_path}=    Prepare Wts Config
    ...    target_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/new_basic_setup.cfg
    ...    net_arch=${net_arch}
    ...    nr_ue_caps=${nr_ue_caps}
    ...    mrdc_ue_caps=${mrdc_ue_caps}
    ...    arfcn_gscn_change=${arfcn_gscn_change}
    ...    slice_scheduler=${slice_scheduler}
    common_wts.Wait For Environment Prepared For Wts Ready State
    ...    wts_config_filename=${wts_config_path}
    ...    allow_first_reboot=${True}
    ...    timeout=${60}
    ...    sib_reception_dict=${sib_reception_dict}
    ute_syslog.Start Syslog
    ...   log_dir=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    ...   log_name=syslog.log
    ...   ip=192.168.255.126
    ...   ports=51000
    ...   add_line_number=True
    common_wts.Start Collecting Ueapp Sosreport

CB009333 Test Teardown
    Log To Console  \nStart Teardown
    Setup.Produce Scout Data
    ute_syslog.Stop Syslog
    common_gnb.Collect SCF File
    ...    final_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/modified_scf.xml
    Run Keyword If Test Passed    common_wts.Stop Collecting Ueapp Sosreport
    ...    destination_path_for_sosreport=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}
    ...    ue_app_options=-o
    Run Keyword If Test Failed    common_wts.Stop Collecting Ueapp Sosreport
    ...    destination_path_for_sosreport=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}
    common_wts.Stop WTS And clear
    CB009333_iphy_modification.Upload Default Iphy File
    Wait Until Keyword Succeeds    5min    30s    common_gnb.Perform gNB Commissioning
    ...    scf_file=${OUTPUT_DIR}/${SUITE_NAME}/default_scf.xml
    common_gnb.Wait For All Radio Modules To Be Online


Start Collecting TTItrace
    Start TTI trace collection
    ...    collector_name=${COLLECTOR_NAME}
    ...    yaml_config_path=${CURDIR}/tti_config.yaml

Stop Collecting TTItrace
    Stop TTI trace collection
    ...  collector_name=${COLLECTOR_NAME}
    ...  target_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    Relocate TTI traces collected
    ...  collector_name=${COLLECTOR_NAME}
    ...  target_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    Move File
    ...    source=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tcpdump.pcap
    ...    destination=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tti_trace.pcap

Convert TTItrace
    [Arguments]    ${format}=excelCsv    ${pcap_file_name}=tti_trace.pcap
    Convert TTI trace from pcap
    ...    format=${format}
    ...    target_filename=ttiTrace
    ...    source_file_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/${pcap_file_name}
    ...    target_files_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}

Validate TTITrace Logs
    [Arguments]   ${pcap_file_name}=tti_trace.pcap
    Convert TTItrace
    ...    format=excelCsv
    ...    pcap_file_name=${pcap_file_name}
    Convert TTItrace
    ...    format=json
    ...    pcap_file_name=${pcap_file_name}
    Validate TTI Trace
    ...    tti_trace_json_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/ttiTrace.json

Convert TTItrace Slice Scheduler
    Convert TTI trace from pcap
    ...    format=excelCsv
    ...    target_filename=ttiTrace_attach
    ...    source_file_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tti_trace_attach.pcap
    ...    target_files_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    Convert TTI trace from pcap
    ...    format=excelCsv
    ...    target_filename=ttiTrace_large_traffic
    ...    source_file_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tti_trace_large_traffic.pcap
    ...    target_files_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}

Attach With Traffic And Logs
    [Arguments]    ${net_arch}=SA    ${traffic_direction}=dl    ${num_of_ues}=1    ${cells}=1    ${burst}=2
    ...            ${size_dl}=6000    ${size_ul}=1000    ${period_ms}=10    ${bearer}=${None}    ${qfi}=${None}    ${traffic_duration}=5
    ...            ${delay_traffic_stop}=${None}
    ta5g_pm_counters.Wait For Next Full Pm Interval
    Start Collecting TTItrace
    Attach With Traffic
    ...    net_arch=${net_arch}
    ...    traffic_direction=${traffic_direction}
    ...    num_of_ues=${num_of_ues}
    ...    cells=${cells}
    ...    qfi=${qfi}
    ...    burst=${burst}
    ...    size_dl=${size_dl}
    ...    size_ul=${size_ul}
    ...    period_ms=${period_ms}
    ...    bearer=${bearer}
    ...    traffic_duration=${traffic_duration}
    ...    delay_traffic_stop=${delay_traffic_stop}
    Stop Collecting TTItrace
    ta5g_pm_counters.Wait For Next Full Pm Interval

Attach With Traffic And Logs For Slice Aware Scheduler
    [Arguments]    ${net_arch}=SA    ${num_of_ues}=1    ${burst}=2    ${size_dl}=6000    ${size_ul}=1000    ${period_ms}=10
    ...            ${bearer}=${None}    ${qfi}=${None}    ${nwslice}=${None}    ${traffic_duration}=15    ${cells}=3
    ${ue_ids}=    Generate UE IDs
    ...    num_of_ues=${num_of_ues}
    ta5g_pm_counters.Wait For Next Full Pm Interval
    Start Collecting TTItrace
    Perform 5G Attach
    ...    net_arch=${net_arch}
    ...    ue_ids=${ue_ids}
    ...    nwslice=${nwslice}
    ...    cells=${cells}
    Stop Collecting TTItrace
    Move File
    ...    source=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tti_trace.pcap
    ...    destination=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tti_trace_attach.pcap
    Start Traffic
    ...    net_arch=${net_arch}
    ...    ue_ids=${ue_ids}
    ...    period_ms=${period_ms}
    ...    burst=${burst}
    ...    size_dl=${size_dl}
    ...    size_ul=${size_ul}
    ...    qfi=${qfi}
    ...    bearer=${bearer}
    ...    traffic_duration=${traffic_duration}
    ta5g_pm_counters.Wait For Next Full Pm Interval
    Validate SA Non GBR Counters Slice Scheduler
    Start Collecting TTItrace
    Allow Traffic To Run For    5s
    Stop Collecting TTItrace
    Move File
    ...    source=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tti_trace.pcap
    ...    destination=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tti_trace_large_traffic.pcap
    ta5g_pm_counters.Wait For Next Full Pm Interval
    Stop Traffic
    ...    net_arch=${net_arch}
    ...    ue_ids=${ue_ids}
    ...    qfi=${qfi}
    ...    bearer=${bearer}
    Start Traffic
    ...    net_arch=${net_arch}
    ...    ue_ids=${ue_ids}
    ...    period_ms=${period_ms}
    ...    burst=1
    ...    size_dl=3000
    ...    qfi=${qfi}
    ...    bearer=${bearer}
    ...    traffic_duration=5
    Start Collecting TTItrace
    Allow Traffic To Run For    5s
    Stop Collecting TTItrace
    Move File
    ...    source=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tti_trace.pcap
    ...    destination=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tti_trace_traffic.pcap
    Stop Traffic
    ...    net_arch=${net_arch}
    ...    ue_ids=${ue_ids}
    ...    qfi=${qfi}
    ...    bearer=${bearer}

Attach With Traffic And Logs For Long Traffic
    [Arguments]    ${net_arch}=SA    ${num_of_ues}=1    ${burst}=2    ${size}=6000    ${period_ms}=10
    ...            ${bearer}=${None}    ${qfi}=${None}    ${traffic_duration}=900
    ${ue_ids}=    Generate UE IDs
    ...    num_of_ues=${num_of_ues}
    Start Collecting TTItrace
    Perform 5G Attach
    ...    net_arch=${net_arch}
    ...    ue_ids=${ue_ids}
    Stop Collecting TTItrace
    Move File
    ...    source=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tcpdump.pcap
    ...    destination=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tti_trace_attach.pcap
    Start Traffic
    ...    net_arch=${net_arch}
    ...    ue_ids=${ue_ids}
    ...    period_ms=${period_ms}
    ...    burst=${burst}
    ...    size=${size}
    ...    qfi=${qfi}
    ...    bearer=${bearer}
    ...    traffic_duration=${traffic_duration}
    Allow Traffic To Run For    ${traffic_duration}s
    Start Collecting TTItrace
    Allow Traffic To Run For    5s
    Stop Collecting TTItrace
    Move File
    ...    source=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tcpdump.pcap
    ...    destination=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tti_trace_long_traffic.pcap
    Stop Traffic
    ...    net_arch=${net_arch}
    ...    ue_ids=${ue_ids}
    ...    qfi=${qfi}
    ...    bearer=${bearer}
    Perform 5G Detach
    ...    net_arch=${net_arch}
    ...    ue_ids=${ue_ids}
    Validate SA Non GBR Counters
    Validate Micro DTX Counters

Allow Traffic To Run For
    [Arguments]    ${traffic_duration}=15s
    BuiltIn.Sleep  ${traffic_duration}

Repeated Attach Traffic Detach
    [Arguments]    ${repeat}=5
    Repeat Keyword
    ...    ${repeat} times
    ...    Attach With Traffic And Logs
