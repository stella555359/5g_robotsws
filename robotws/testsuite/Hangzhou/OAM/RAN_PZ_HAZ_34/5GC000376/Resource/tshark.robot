*** Settings ***
Documentation   AUTHOR:Menghua Luo(NSB)
Library    OperatingSystem
Library    Collections
Library    String
Library    taf.transport.ssh   WITH NAME   csn
Library    taf.analyzer.pcap   WITH NAME   wireshark
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/configuration_automation.py

*** Variables ***
${tshark_path}      /usr/bin/tshark
${nsetapx_addr}
...   https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X
#...   https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/nsetapx-1.13.4/nsetapx-4.0-0.7.0-1.13.4+bookworm.so
#...   https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/nsetapx-1.9.7/nsetapx-4.0-0.3.0-1.9.7+buster.so
${plugin_folder}   /usr/lib/x86_64-linux-gnu/wireshark/plugins
${plugin_folder_utevm}   /home/ute/.local/lib/wireshark/plugins
${arti_user}  ca_5Gauto
${arti_key}  AKCp5bBh9XG9iCkcCJLwt6CHuVdgHPyJVAuB7V6vSHfet7X6ZXfjZRqEMLxn36rfqRfhoQzKc

*** Keywords ***
Load Pcap File with Filter
    [Arguments]    ${pcap_file}    ${record_type}   ${input_type}    ${filter}
#   Download wireshark plugin
   # ${command_template_with_Y}   set variable
   # ...   {tshark_path} -r {input_file} -Y ${filter} -T pdml > {output_file}
     ${command_template_with_Y}   set variable
    ...   sudo {tshark_path} -o ntrstr.port:49148 -o ntrstr.defragment:TRUE -r {pcap_file} -Y ${filter} -T pdml
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${pcap_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_with_Y}
    ${filter_expression}   set variable   nsetapx.${record_type}VendorExtensionRecordDataType == ${input_type}
    ${filtered_packets}=    wireshark.filter_packets_by_expression
    ...   filter_expression=${filter_expression}
    [Return]   ${filtered_packets}

Load Pcap File with Filter for 1804
    [Arguments]    ${pcap_file}    ${filter}   ${TraceMessage}  ${nodeType}
    Download wireshark plugin
#    ${command_template_with_Y}   set variable
#    ...   {tshark_path} -r {input_file} -Y ${filter} -T pdml > {output_file}
     ${command_template_with_Y}   set variable
    ...   sudo {tshark_path} -o ntrstr.port:49148 -o ntrstr.defragment:TRUE -r {pcap_file} -Y ${filter} -T pdml
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${pcap_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_with_Y}
    ${filter_expression}=    Catenate    nsetapx.TraceMessage == ${TraceMessage}
    ...                     and nsetapx.nodeType == ${nodeType}
    ${filtered_packets}=    wireshark.filter_packets_by_expression
    ...   filter_expression=${filter_expression}
    [Return]   ${filtered_packets}

Load Pcap File with Filter any Expression
    [Arguments]    ${pcap_file}    ${filter}   ${any_expression}
    Download wireshark plugin
    # ${command_template_with_Y}   Set Variable
    # ...   {tshark_path} -r {pcap_file} -Y ${filter} -T pdml
    ${command_template_with_Y}   Set Variable
    ...   sudo {tshark_path} -o ntrstr.port:49148 -o ntrstr.defragment:TRUE -r {pcap_file} -Y ${filter} -T pdml
    wireshark.load_pcap_file
    ...   pcap_file=${pcap_file}
    ...   tshark_path=${tshark_path}
    ...   command_template=${command_template_with_Y}
    ${filter_expression}   Set Variable   ${any_expression}
    wireshark.filter_packets_by_expression   filter_expression=${filter_expression}

Download wireshark plugin
    ${wiresharkver}   Set Variable    4.4
    Run   sudo ls -l ${plugin_folder}/${wiresharkver}/epan/nsetapx*bookworm.so 2>&1
    Run   sudo rm -rf ${plugin_folder}/${wiresharkver}/epan/nsetapx*bookworm.so
    ${apx_p}   Run   curl -u ${arti_user}:${arti_key} -sL -m 15 ${nsetapx_addr}/ |grep "nsetapx" |cut -d '"' -f2 |cut -d '.' -f1 |sort -r |head -1
    ${apx_m}   Run   curl -u ${arti_user}:${arti_key} -sL -m 15 ${nsetapx_addr}/ |grep "${apx_p}" |cut -d '"' -f2 |cut -d '.' -f2 |sort -nr |head -1
    ${nsetapxv}   Run   curl -u ${arti_user}:${arti_key} -sL -m 15 ${nsetapx_addr}/ |grep "${apx_p}\.${apx_m}" |cut -d '"' -f2 |sort -r |head -1
    ${nsetapxlist}   Run   curl -u ${arti_user}:${arti_key} -sL ${nsetapx_addr}/${nsetapxv} |grep -w "${wiresharkver}" |grep 'bookworm.so</a'
    ${nsetapxbuild}   Run   echo '${nsetapxlist}' |cut -d '"' -f2
    @{nsetapxbuild_list}    Split String     ${nsetapxbuild}    \n
    Sort List    ${nsetapxbuild_list}
    ${nsetapxbuild}    Set Variable    ${nsetapxbuild_list}[-1]
    ${exist}   Run   ls -l ${plugin_folder}/${wiresharkver}/epan/${nsetapxbuild} 2>&1
    ${exist_utevm}   Run  ls -l ${plugin_folder_utevm}/${wiresharkver}/epan/${nsetapxbuild} 2>&1
    ${wget_nsetapx}  Set Variable  `sudo wget --user=${arti_user} --password=${arti_key} ${nsetapx_addr}/${nsetapxv}${nsetapxbuild}`
    Run Keyword If   ${exist.count('No such file or directory')}>0   Run  cd ${plugin_folder}/${wiresharkver}/epan; ${wget_nsetapx}
    Run Keyword If   ${exist_utevm.count('No such file or directory')}>0  Run  cd ${plugin_folder_utevm}/${wiresharkver}/epan; ${wget_nsetapx}
    ${exist}   Run   ls -l ${plugin_folder}/${wiresharkver}/epan/${nsetapxbuild} 2>&1
    ${exist_utevm}   Run  ls -l ${plugin_folder_utevm}/${wiresharkver}/epan/${nsetapxbuild} 2>&1
    ${noexist_str}    Set Variable    No such file or directory
    Run Keyword If    (${exist.count('${noexist_str}')}>0 and ${exist_utevm.count('${noexist_str}')}>0) or '${nsetapxbuild}'=="${EMPTY}"
    ...   FAIL    msg=wireshark plugin download failed!
