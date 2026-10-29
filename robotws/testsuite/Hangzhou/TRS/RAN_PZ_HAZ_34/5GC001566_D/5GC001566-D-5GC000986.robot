#*** Settings ***
#Force Tags    PY36
#Documentation     author: fengyi Liu
#...               contact: feng.y.liu@nokia-sbell.com
#...               squad group: mmw_SG_04
#
#Suite Setup    Input default SCF
#Library    String
#Library    OperatingSystem
#Library    taf.transport.ssh    WITH NAME    csn
#Library    taf.analyzer.pcap    WITH NAME    cap
#Variables    ./Resources/5GC001566_modify_para.py
#Resource    ./Resources/1566_D_Keywords.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#
#*** Variables ***
#${MRBTS}    MRBTS-${tl.gnbs[0].global_bts_id}
#${ID}       1
#${interface}    fp0
#${filename}    bfd_tcpdump.pcap
#${bfd_false_filename}    bfd_false_tcpdump.txt
#${up_filename}    trigger_bfd_up.pcap
#${dowm_filename}    trigger_bfd_down.pcap
#${remote_path}    /tmp
#${local_path}    ${output_dir}
#${src_ip_value}     10.57.243.129
#${dst_ip_value}     10.57.243.130
#${bfd_ip_notok}    10.57.243.12
#${Dst_Port_value}    3784
#${bfd_state_true}    bfd.sta == 0x3
#${bfd_state_down}    bfd.sta == 0x1
#${BFD_state_is_up}    ip.src == ${src_ip_value} && ip.dst == ${dst_ip_value} && udp.dstport == ${Dst_Port_value}
#${IPRT_distname_1}    ${MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1
#${BFD_distname_1}    ${MRBTS}/TNLSVC-1/TNL-1/IPAPP-1/BFD-1
#${ip_flag}    -4
#
#*** Test Case ***
#[1]5GC001566-5GC000986_002_BFD_admin_down_state_control_FALSE_transmission_continue
#    [Documentation]    configuration BFD parameters collect tcpdump log check BFD state
#    ...    then modify parameter bfdAdminUp False and collect tcpdump log check BFD state
#    [Tags]    5G_TRS    5GC001566    CRT_20B
#    [Setup]
#    ${dict_ipappid}    Create IPAA object    ID=${ID}
#    ${dict_bfd}    Create BFD object    ID=${ID}
#    BFD TCPDUMP LOG    filename=${filename}    interface=${interface}    remote_path=${remote_path}    local_path=${local_path}
#    Another Check bfd state in tcpdump    local_path=${local_path}    filename=${filename}    condition_expression=${BFD_state_is_up}
#    Modify bfdAdminUp Parameters    ID=${ID}
#    BFD False TCPDUMP LOG    filename=${bfd_false_filename}    interface=${interface}    remote_path=${remote_path}    local_path=${local_path}
#    run keyword and continue on failure   Delete BFD and IPAPP parameters   ID=${ID}    dict_bfd=${dict_bfd}    dict_ipappid=${dict_ipappid}
#    [Teardown]    CI_interface.Common Case Teardown
#
#[1]5GC001566-5GC000986_009_Action_trigger_shall_trigger_removing_route
#    [Documentation]    This TC check if action trigger can modify routing table
#    [Tags]    5G_TRS    5GC001566    CRT_20B    CRT_TRUNK   CRT_21B
#    [Setup]
#    ${dict_ipappid}    step1:Creat parameters for bfd and trigger    ID=${ID}    PARAMS_TRIGGER=${PARAMS_TRIGGER}
#    step2:Modify IPRT-1 triggerDN parameter    IPRT_distname_1=${IPRT_distname_1}    PARAMS=${PARAMS_staticRoutes_3}
#    step3:Check bfd state is up and trigger route
#    ${bfdDestIpAddr}    step4:Modify bfdDestIpAddr Parameters    BFD_distname_1=${BFD_distname_1}    bfd_ip_notok=${bfd_ip_notok}
#    step5:Check bfd state is down
#    [Teardown]    Recover the test ENV    PARAMS_TRIGGER=${PARAMS_TRIGGER}    bfdDestIpAddr=${src_ip_value}
#    ...    PARAMS=${PARAMS_recover_staticRoutes_1}    dict_ipappid=${dict_ipappid}
#
#*** Keywords ***
#BFD False TCPDUMP LOG
#    [Arguments]     ${filename}    ${interface}    ${remote_path}    ${local_path}
#    ${conn}   Connect to ASOD
#    BuiltIn.Log    \n Start To Capture tcpdump \n    console=yes
#    csn.send command    command=tcpdump -i ${interface} udp -vvv > ${remote_path}/${filename}    connection=${conn}
#    sleep    40s
#    BuiltIn.Log    \n Stop To Capture tcpdump \n    console=yes
#    csn.send command    command=killall tcpdump     connection=${conn}
#    csn.send command    command=cat ${remote_path}/${filename}    connection=${conn}
#    ${output}=    csn.Read Output    connection=${conn}
#    should be true    '${output.split('\n')[0]}'=='${Empty}'
#
#Delete BFD and IPAPP parameters
#    [Arguments]    ${ID}    ${dict_bfd}    ${dict_ipappid}
#    BuiltIn.Log    \n Delete BFD and IPAPP parameters \n    console=yes
#    run keyword and continue on failure    Delete BFD parameters    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-1/BFD-${ID}    dict_bfd=${dict_bfd}
#    run keyword and continue on failure    Delete IPAPP parameters    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-${ID}    dict_ipappid=${dict_ipappid}
#
#Modify bfdAdminUp Parameters
#    [Arguments]    ${ID}
#    ${conn}    Connect to DU
#    ${get_managed_objects}=    coam.get_managed_objects    class_name=BFD_A    connection=${conn}
#    ${bfd_parameters}    get from dictionary    @{get_managed_objects}[0]    parameters
#    ${bfdAdminUp}    get from dictionary    ${bfd_parameters}    bfdAdminUp
#    modify parameter    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-1/BFD-${ID}    parameter=bfdAdminUp
#    ...    value=${False}    connection=${conn}
#    [Teardown]    Disconnect from DU
#
#step1:Creat parameters for bfd and trigger
#    [Arguments]    ${ID}    ${PARAMS_TRIGGER}
#    ${dict_ipappid}    Create IPAA object    ID=${ID}
#    Create BFD object    ID=${ID}
#    Create trigger object    ID=${ID}    para_trigger=${PARAMS_TRIGGER}
#    [Return]    ${dict_ipappid}
#
#step2:Modify IPRT-1 triggerDN parameter
#    [Arguments]    ${IPRT_distname_1}    ${PARAMS}
#    ${conn}    Connect to DU
#    modify parameter    dn=${IPRT_distname_1}    parameter=staticRoutes    value=${PARAMS}    connection=${conn}
#    [Teardown]    Disconnect from DU
#
#step3:Check bfd state is up and trigger route
#    BFD TCPDUMP LOG    filename=${up_filename}    interface=${interface}    remote_path=${remote_path}    local_path=${local_path}
#    Download Log    filename=${up_filename}
#    Another Check bfd state in tcpdump    local_path=${local_path}    filename=${up_filename}    condition_expression=${bfd_state_true}
#    Check ipv4 route about trigger    ip_flag=${ip_flag}    gateway=${src_ip_value}    interface=${interface}
#
#Download Log
#     [Arguments]     ${filename}
#    csn.connect_to    hostname=${test_ute}    username=${ute_name}    password=${test_password}    alias=connection_ute
#    csn.send command   command=sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "${DU_IP}"     connection=connection_ute
#    csn.send command   command=sudo sshpass -p oZPS0POrRieRtu scp toor4nsn@${DU_IP}:/tmp/${filename} ${output_dir}
#    ...     connection=connection_ute
#    sleep    10s
#    csn.Disconnect    connection=connection_ute
#    log to console  Download Log successful
#
#step4:Modify bfdDestIpAddr Parameters
#    [Arguments]    ${BFD_distname_1}    ${bfd_ip_notok}
#    ${conn}    Connect to DU
#    ${get_managed_objects}=    coam.get_managed_objects    class_name=BFD_A    connection=${conn}
#    ${bfd_parameters}    get from dictionary    @{get_managed_objects}[0]    parameters
#    ${bfdDestIpAddr}    get from dictionary    ${bfd_parameters}    bfdDestIpAddr
#    modify parameter    dn=${BFD_distname_1}    parameter=bfdDestIpAddr    value=${bfd_ip_notok}    connection=${conn}
#    [Teardown]    Disconnect from DU
#    [Return]    ${bfdDestIpAddr}
#
#step5:Check bfd state is down
#    BFD TCPDUMP LOG    filename=${dowm_filename}    interface=${interface}    remote_path=${remote_path}    local_path=${local_path}
#    Download Log   filename=${dowm_filename}
#    Another Check bfd state in tcpdump    local_path=${local_path}    filename=${dowm_filename}    condition_expression=${bfd_state_down}
#    Check ipv4 route not have about trigger    ip_flag=${ip_flag}    gateway=${src_ip_value}    interface=${interface}
#    Check trigger state is false
#
#Check trigger state is false
#    Login Page Via WebUI
#    Log To Console      \n start get trig_stat
#    ${trig_state}    selenium_coam.get parameter value    dist_name=${Trigger_distname_1_1}
#    ...                              filter_param=State of the trigger
#    should be equal    ${trig_state}    FALSE
#    [Teardown]    selenium_coam.logout
#
#Login Page Via WebUI
#    selenium_coam.Enable Virtual Display
#    FOR    ${var}    IN RANGE    10
#        ${login_result}    ${error}    Run Keyword And Ignore Error    selenium_coam.Login
#        ...    url=https://${DU_IP}
#        ...    username=${WEBEM_USERNAME}
#        ...    password=${WEBEM_PASSWORD}
#        ${logout_result}    ${error}    Run Keyword If    '${login_result}'=='FAIL'    Run Keyword And Ignore Error    selenium_coam.Logout
#        Exit For Loop If    '${login_result}'=='PASS'
#        Sleep    5s
#    END
#    selenium_coam.Disable Message Box
#    selenium_coam.Disable Screen Lock
#
#Create trigger object
#    [Arguments]    ${ID}    ${para_trigger}
#    BuiltIn.Log    \n Create trigger parameters \n    console=yes
#    Create object    dn=${MRBTS}/TNLSVC-1/TNL-1/TRIGGER-${ID}    para_name=${para_trigger}
#
#Recover the test ENV
#    [Arguments]    ${PARAMS_TRIGGER}    ${bfdDestIpAddr}    ${PARAMS}    ${dict_ipappid}
#    ${conn}    Connect to DU
#    BuiltIn.Log    \n Recover bfdDestIpAddr Parameters \n    console=yes
#    modify parameter    dn=${BFD_distname_1}    parameter=bfdDestIpAddr    value=${bfdDestIpAddr}    connection=${conn}
#    BuiltIn.Log    \n Delete IPRT-1 triggerDN parameter \n    console=yes
#    modify parameter    dn=${IPRT_distname_1}    parameter=staticRoutes    value=${PARAMS}    connection=${conn}
#    Disconnect from DU
#    run keyword and continue on failure    Delete trigger object    para_name=${PARAMS_TRIGGER}
#    run keyword and continue on failure    Delete IPAPP parameters    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-${ID}    dict_ipappid=${dict_ipappid}
#
#Delete trigger object
#    [Arguments]    ${para_name}
#    Delete object    dn=${MRBTS}/TNLSVC-1/TNL-1/TRIGGER-1    para_name=${para_name}
