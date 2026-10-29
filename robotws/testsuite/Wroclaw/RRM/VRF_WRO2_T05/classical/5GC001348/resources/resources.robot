*** Settings ***
Documentation
...   author: PZ_2_WRO_5

#Library     OperatingSystem
#Library     taf.analyzer.pdml
Library     CSI_in_pcap.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources/1348_kw.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_2534.robot

*** Keywords ***
Check adb devices
    [Arguments]  ${user}=wro5grrm
    ...          ${pass}=5gpass!1
    ...          ${alias}=uepc
    ${tl_host}=  Get TL hostname
    ${ip}=  ip_giver  ${tl_host}
    ssh.Connect_to    hostname=${ip}  username=${user}  password=${pass}  alias=${alias}
    Sleep  5s
    ssh.Send command    adb devices    connection=${alias}
    ${UEs}=  ssh.Read output  connection=${alias}
    Log  ${UEs}  console=yes
    ${check}=  kill_server    ${UEs}
    Run keyword if  ${check}==False  ssh.Send command    adb kill-server    connection=${alias}
    Run keyword if  ${check}==False  ssh.Send command    adb start-server    connection=${alias}
    ssh.disconnect  connection=${alias}


Verify CSI reports
    [Arguments]  ${dir}=${OUTPUT DIR}/tcpdump_L2L1_filtering_on.pcap  ${presence}=false
    ${msgs}    check_CSI_reports  ${dir}
    Run keyword if  '${presence}'=='false'  should not be true    ${msgs}
    ...    ELSE     should be true    ${msgs}


Check L1L2 harqd
    [Arguments]  ${dir}=${OUTPUT DIR}/tcpdumpL2L1_filtering_on.pcap
    ${msgs}    check_harqd_in_slot  ${dir}
    should be true    ${msgs}



Load scf for LTE
    [Arguments]         ${resource_path_1348-B}  ${folder_name}  ${scf_lte_name}
    ${host_name}=       Get TL hostname
    log to console      Start commissioning LTE
    ${conn}=    Connect to admin    ip_address=${mplane_lte_ipaddr}
    Log    Commissioning ${mplane_lte_ipaddr} BTS with ${scf_lte_name}    console=True
    coam.perform_commissioning      scf_file=${resource_path_1348-B}/${folder_name}/${host_name}/${scf_lte_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=600
    ...   connection=${conn}
    log to console      Commissioning LTE complete
    [Teardown]    Disconnect from admin  ${conn}

Check L1L2 dtx
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}.pcap
    ${msgs}    check dtx   ${dir}
    should be true    ${msgs}

Check L1L2 sfn
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}.pcap
    ${msgs}    check sfn   ${dir}
    should be true    ${msgs}
