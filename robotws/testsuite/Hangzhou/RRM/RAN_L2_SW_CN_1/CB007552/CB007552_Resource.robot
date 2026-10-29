*** Settings ***
Documentation    Author :
...              Squad group : SG_06
...              Feature : CB007552
Library          ute_reporting_portal
Resource         ./../CUDU_L2/common_setup_teardown.robot

*** Keywords ***
Convert TL Mode And Suite Setup
    Suite Setup Update GNB    swconfig_param=${rd_param}    scf_file=${delta_file}    iphy_file=${iphy_file}
    Suite Setup Copy WTS Config Files From Local    ${local_wts_dir}
    Suite Setup Start WTS And Check OnAir

Capture Ttitrace And Convert Format
    common_log_capture.Start Ttitrace With Streaming Mode
    Sleep    6s    reason=get ttitrace
    common_log_capture.Stop Ttitrace
    common_log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${output_dir}/ttitrace_streaming/
    common_log_analyzer.Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_dl.csv
    ...    ${output_dir}/ttitrace_streaming/output_dl_formated.csv
    common_log_analyzer.Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_ul.csv
    ...    ${output_dir}/ttitrace_streaming/output_ul_formated.csv

Modify Iphy Xml
    [Arguments]    ${wts_ap_xml}    ${xml_params_dict}
    Get Iphy Xml From Airphone    ${output_dir}
    Modify Xml File    ${wts_ap_xml}    ${xml_params_dict}
    Send Iphy Xml To Airphone    ${output_dir}/iphy.xml