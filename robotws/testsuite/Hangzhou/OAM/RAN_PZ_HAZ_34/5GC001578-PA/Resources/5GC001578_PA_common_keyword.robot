*** Settings ***
Documentation
...    author: Guo Zhenzhen
...    contact: yuanyuan.liu@nokia-sbell.com
...    squad group: MMW_HZ_SG_03

Library           ../../libraries/get_bts_info.py   WITH NAME    lib
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
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
${dcapuser_addr}                10.57.150.41
${dcapuser_username}            lab5g
${dcapuser_password}            system123
${uplane_destination}           10.57.150.41:55900
${dscp}                         0
${pcap_path}                    /home/sharedvolume/udptracer/_data/20201105/0110/
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
${UE_TYPE}                      qct_dx50

*** Keywords ***
Check cells onAir
    Log To Console    Check cells onAir
    COAM Check All Cells Onair    connection=default

Configure common configuration for DU
    Log To Console    Configure common configuration for DU
    selenium_coam.configure_logging_agent    source_ip=${source_ip}    dscp=${dscp}    uplane_destination=${uplane_destination}
    sleep    3s

Prepare UE and attach UE
    Log To Console    Prepare UE and attach UE
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    #run keyword and ignore error    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False
    run keyword and ignore error    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Perform a UL/DL call
    log to console    Perform a UL/DL call
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=500M    duration=120s
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=500M    duration=120s



Stop uplane component traces
    [Arguments]    ${uplane_component_name}    ${source}=${EMPTY}
    ${stop_status}    run keyword and ignore error    selenium_coam.stop_component_trace    uplane_component_name=${uplane_component_name}
...    source=${source}
    should contain    ${stop_status[1]}    Stop succeeded


Stop uplane sherpa traces
    [Arguments]    ${uplane_sherpa_name}    ${source}=${EMPTY}
    ${stop_status}    run keyword and ignore error    selenium_coam.stop_sherpa_trace
    ...    uplane_sherpa_name=${uplane_sherpa_name}    source=${source}
    should contain    ${stop_status[1]}    Stop succeeded


Delete generated DCAP file
    log to console    Delete DCAP file
    csn.connect_to    hostname=${dcapuser_addr}    username=${dcapuser_username}    password=${dcapuser_password}    alias=DCAP
    run keyword and ignore error    csn.execute    command=sudo rm -rf ${pcap_path}${tl.gnbs[0].dus[0].f1_m_ip_addr}*    connection=DCAP
    csn.disconnect    connection=DCAP


Suite setup
    admin_cli.connect to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    COAM WEBEM Login    url=${WebEM_URL}    username=${WebEM_User}   password=${WebEM_Password}   display=${false}

Suite teardown
    Stop UL/DL traffic and detach UE
	  Delete generated DCAP file
    admin_cli.teardown    connection=default
    Run Keyword And Ignore Error    COAM WEBUI Logout    display=${false}

Stop UL/DL traffic and detach UE
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    run keyword and ignore error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

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
