*** Settings ***
Documentation
...    author: Guo Zhenzhen
...    contact: yuanyuan.liu@nokia-sbell.com
...    squad group: MMW_HZ_SG_03

Library           ../../libraries/get_bts_info.py   WITH NAME    lib
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           XML  lxml=True
Library           taf.transport.ssh    WITH NAME    csn
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
${source_ip}                    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WebEM_URL}                    https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${WebEM_User}                   Nemuadmin
${WebEM_Password}               nemuuser
${dcapuser_addr}                10.57.167.35
${dcapuser_username}            dcapuser
${dcapuser_password}            dcapuser123
${uplane_destination}           10.57.167.35:1234
${dscp}                         0
${pcap_path}                    /sharedvolume/udptracer/_data/
${udptracer_path}               /sharedvolume/udptracer/
${luashark_load_path}           /home/ute/Downloads
${wget_link}                    https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${start_udptracer_cmd}          docker start udptracer
${stop_udptracer_cmd}           docker stop udptracer
${udptracer_status_file}        test.txt
${decode_file}                  decode.txt
${host_tshark}                  10.57.157.135
${username_tshark_}             ute
${passwd_tshark_}               ute
${trace_bak}                    /sharedvolume/udptracer/data_bak/
${bts_host}                     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${ue_type}    ${tl.ues[0].capabilities[1]}



*** Keywords ***
Get the DCAP file and check its size is not zero
    csn.connect_to    hostname=${dcapuser_addr}    username=${dcapuser_username}    password=${dcapuser_password}    alias=DCAP
    ${all_pcap_file}    csn.execute    command=cd ${pcap_path} && ls    connection=DCAP
    ${pcap_file_name}    Get Lines Containing String    ${all_pcap_file}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
    Should not be empty    ${pcap_file_name}
    ${pcap_file_path}    join path    ${pcap_path}    ${pcap_file_name}
    set suite variable    ${pcap_file_path}
    ${pcap_file_path}    Replace String    ${pcap_file_path}    \r\n    ${EMPTY}
    set test variable    ${pcap_file_name}
    set suite variable    ${pcap_file_path}
    ${pcap_size}    csn.execute    stat ${pcap_path}/*.pcap | grep "Size:" |cut -d":" -f2 |cut -c2-12     connection=DCAP
    log    ${pcap_size}
    ${pcap_size}    Convert To Integer     ${pcap_size}
    set suite variable    ${pcap_size}
    Should not Be Equal    ${pcap_size}    ${0}
    csn.execute    cp ${pcap_file_path} ${trace_bak}    connection=DCAP

Load corresponding luashark
    log to console    Load corresponding luashark
    set suite variable    ${luashark_package}    luashark-${SW_vesion}.zip
    ${package_load_link}    set variable    ${wget_link}/${SW_vesion}/${luashark_package}
    ${luashark_file_path}    join path    ${luashark_load_path}    ${luashark_package}
    csn.connect_to    hostname=${host_tshark}    username=${username_tshark_}    password=${passwd_tshark_}    alias=tsharkSer
    csn.execute    command=mkdir ${luashark_load_path}    connection=tsharkSer
    run keyword and ignore error    csn.execute    command=sudo rm -rf ${luashark_load_path}/generated_luashark    connection=tsharkSer
    Run And Return Rc And Output    wget --no-proxy ${package_load_link} -P ${luashark_load_path}
    sleep    30s
    log to console    unzip
    csn.execute    command=unzip -d ${luashark_load_path} ${luashark_file_path}    connection=tsharkSer
    csn.disconnect    connection=tsharkSer


Stop uplane component traces
    [Arguments]    ${uplane_component_name}    ${source}=${EMPTY}
    ${stop_status}    run keyword and ignore error    selenium_coam.stop_component_trace    uplane_component_name=${uplane_component_name}
...    source=${source}
    should contain    ${stop_status[1]}    Stop succeeded


Stop uplane sherpa traces
    [Arguments]    ${uplane_sherpa_name}    ${source}=${EMPTY}
    ${stop_status}    run keyword and ignore error    selenium_coam.stop_sherpa_trace    uplane_sherpa_name=${uplane_sherpa_name}    source=${source}
    should contain    ${stop_status[1]}    Stop succeeded


Delete generated DCAP file
    log to console    Delete DCAP file
    csn.connect_to    hostname=${dcapuser_addr}    username=${dcapuser_username}    password=${dcapuser_password}    alias=DCAP
    #run keyword and ignore error    csn.execute    command=sudo rm -rf ${pcap_file_path}    connection=DCAP
    run keyword and ignore error    csn.execute    command=sudo rm -rf ${pcap_path}${tl.gnbs[0].dus[0].f1_m_ip_addr}*    connection=DCAP
    csn.disconnect    connection=DCAP
    sleep    2s

Suite setup
    admin_cli.connect to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}

Suite teardown
    admin_cli.teardown    connection=default
    Run Keyword And Ignore Error    COAM WEBUI Logout    display=${true}

Snapshot cases suite teardown
    Run Keyword And Ignore Error    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command
    Run Keyword And Ignore Error    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}
    admin_cli.teardown    connection=default

Get current active version
    ${version}    wait until keyword succeeds    2min    30s    selenium_coam.check_current_software_version
    ${result}    split string    string=${version}[Active]    separator=_
    ${result1}    convert to integer    ${result}[-1]
    ${result2}    convert to integer    ${result}[-2]
    ${result3}    convert to integer    ${result}[-3]
    ${trunk_build}     convert to string    ${result}[-5]
    set suite variable     ${trunk_build}
    set test variable    ${SW_vesion}    ${result3}.${result2}.${result1}


COAM WEBEM Login
    [Documentation]    login the coam webem
    [Arguments]   ${url}=https://${WEBEM_ADDR}   ${username}=${WEBEM_USER}   ${password}=${WEBEM_PASSWORD}   ${display}=${false}
    Return From Keyword If   ${selenium_gnb_login}
    OperatingSystem.Run   ps -ef | grep firefox | grep -v grep | awk '{print $2}' | xargs kill -9
    OperatingSystem.Run   ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs kill -9
    run keyword if  not ${display}   selenium_coam.enable_virtual_display
    selenium_coam.login   url=${url}   username=${username}   password=${password}   timeout=${120}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock
    Set Global Variable   ${selenium_gnb_login}   ${true}

COAM WEBEM Logout
    [Documentation]   Logout the coam webem
    [Arguments]   ${display}=${false}
    Return From Keyword If   not ${selenium_gnb_login}
    selenium_coam.logout
    Set Global Variable   ${selenium_gnb_login}   ${false}
    run keyword if  not ${display}   selenium_coam.disable_virtual_display
    Sleep   2s
    OperatingSystem.Run   ps -ef | grep firefox | grep -v grep | awk '{print $2}' | xargs kill -9
    OperatingSystem.Run   ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs kill -9
