*** Settings ***
Documentation     TCs
#Resource    ../ttitrace.robot
#Resource    ../testline.robot
#Resource    ../connect.robot
#Resource    ../wts_ue.robot
#Resource    ../ute_workarounds.robot
#Library    OperatingSystem
#
#Suite Setup     Prepare pre-condition for TTI trace test
#
#*** Test Cases ***
#Test Tti Trace Collection in Streaming mode with default name
#    [TAGS]  TTI
#    Collect TTI Traces in Streaming mode
#    ${target_dir}=    testline.Get Testcase Log Directory
#    File Should Exist           ${target_dir}/ttitrace_streaming.pcap
#    File Should not be empty    ${target_dir}/ttitrace_streaming.pcap
#
#
#Test Start Stop TTI Traces in Streaming mode
#    [TAGS]  TTI
#    Start TTI Traces in Streaming mode
#    Sleep   10
#    ${tti_trace}=    Stop TTI Traces in Streaming Mode  tti_trace_filename=ttitrace_streaming
#    File Should Exist           ${tti_trace}
#    File Should not be empty    ${tti_trace}
#    Set Suite Variable  ${tti_trace}
#
#
#Test Convert pcap to udp
#    [TAGS]  TTI
#    Convert pcap to udp         source=${tti_trace}   target=${tti_trace}_.udp
#    OperatingSystem.File Should Exist           ${tti_trace}_.udp
#    # OperatingSystem.File Should not be empty    ${tti_trace}_.udp
#
#
#Test Convert TTI trace from pcap to excelCsv with Ue Action
#    [TAGS]  TTI2CSV
#    Start TTI Traces in Streaming mode
#    Ue Register
#    Sleep   5 sec
#    Ue Deregister
#    ${tti_trace}=    Stop TTI Traces in Streaming Mode  tti_trace_filename=ttitrace_streaming
#
#    ${target_dir}=    testline.Get Testcase Log Directory
#    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${target_dir}/sample_ttitrace
#    File Should Exist           ${target_dir}/sample_ttitrace_dl_and_ul.csv
#    File Should not be empty    ${target_dir}/sample_ttitrace_dl_and_ul.csv
#    Get File Size               ${target_dir}/sample_ttitrace_dl_and_ul.csv
#
#
#*** Keywords ***
#Prepare pre-condition for TTI trace test
#    UTE Cloud Workaround
#
#    Set Suite Variable    ${wts_alias}      ap_egate
#    Set Suite Variable    ${egate_port}     ${tl.core.egate_port}
#    Set Suite Variable    ${edaemon_alias}  ap_edaemon
#    Set Suite Variable    ${edaemon_port}   ${tl.core.edaemon_port}
#
#    ute_wtssim.setup_egate    egate_port=${egate_port}  host_ip=${tl.core.default_ssh_connection_details.addr}
#    ...    tool_dir=${tl.core.dir_path}  alias=${wts_alias}
#    ute_wtssim.setup_edaemon    edaemon_port=${edaemon_port}  host_ip=${tl.core.default_ssh_connection_details.addr}
#    ...    tool_dir=${tl.core.dir_path}  alias=${edaemon_alias}
#    ${wts_status}=    Run Keyword and Return Status
#    ...    Send Egate Command and verify output    cmd=sim_info    pass_regexp=Process ID    wts_alias=${wts_alias}
#    ${sim_status}=    Run Keyword and Return Status
#    ...    Send Egate Command and verify output    cmd=sim_state_disp    pass_regexp=The state is ACTIVE    wts_alias=${wts_alias}
#    Run Keyword If    $wts_status == False or $sim_status == False  Run Keywords
#    ...   Kill WTS services
#    ...   AND   Bring Airphone TL to on Air status without reboot
#
