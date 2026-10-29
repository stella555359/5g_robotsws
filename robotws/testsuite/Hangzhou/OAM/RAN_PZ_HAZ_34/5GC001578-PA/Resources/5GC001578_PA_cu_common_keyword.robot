*** Settings ***
Documentation
...    author: Guo Zhenzhen
...    contact: yuanyuan.liu@nokia-sbell.com
...    squad group: MMW_HZ_SG_03

Library    ArchiveLibrary
Library    OperatingSystem
Library    taf.selenium.gnb.oam.coam.cu    WITH NAME   coam_cu
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
${ue_type}    ${tl.ues[0].capabilities[1]}
${web_url}    https://${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

*** Keywords ***
Prepare and attach UE
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
	
Perform a call with some UL/DL traffic
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=100M    duration=600    ue_type=${ue_type}    iperf_type=via_command
    sleep    1s          
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=100M    duration=600    ue_type=${ue_type}
    sleep    20s
 
Stop UL/DL traffic and detach UE	
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command 
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

Login CU WebEM
    log to console    Login CU WebEM
    ${version}    Get version based on stream version
    coam_cu.enable_virtual_display
    sleep    5s
    coam_cu.login    url=${web_url}
    ...    username=Nemuadmin    password=nemuuser      browser=firefox    timeout=60    version=${version}
    run keyword and ignore error    Run Process    sudo rm -rf /tmp/snapshot/*
    
Logout CU WebEM
    log to console    Logout CU WebEM
    coam_cu.logout
    coam_cu.disable_virtual_display 
	
Get version based on stream version
    Connect to Common Unit Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    ${sw_version}    Strip string    ${sw_version_list[0]}
    #${program_version}    Replace string using regexp    string=${sw_version}    pattern=SBTS|5G    replace_with=${EMPTY}
    ssh.disconnect  connection=ASIK Master
    [Return]    ${sw_version}	

     
     
