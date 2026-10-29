*** Settings ***
Documentation
...         author: n5liu
...         contact: ning.4.liu@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         DCAP test

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library     taf.sw.dcap.rd		WITH NAME	DCAP
Library     robot.libraries.DateTime
Library     OperatingSystem
Library     taf.transport.ssh.interface.ssh       WITH NAME    tafssh
Library     String
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/DCAP.robot
Resource    ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    ../../5GC002056-BGAN/Resources/5GC002056-BGAN_5GC001856_cOAM_Common_Keywords_Trunk.robot
Resource    ../../../../AIC/RAN_PZ_HAZ_34/RRM/CB009189/Resources/CB009189_Common_Keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${DCAP_server}     ${tl.nms[0].addr}
${DCAP_host}              ${DCAP_server['ip']}
${DCAP_USERNAME}        ${DCAP_server['user']}
${DCAP_port}        ${DCAP_server['port']}
&{bts}      host=${bts_host}    username=Nemuadmin    password=nemuuser    port=443
&{bts_vdu}      host=${vdu_host}    username=${du_admin_username}     password=${du_admin_password}    port=443
&{bts_vcu}      host=${vcu_host}    username=${cu_admin_username}     password=${cu_admin_password}    port=443
#${EMIL_HOST}    10.71.218.19
#${EMIL_USER}    nokia5G
#${EMIL_PASSWORD}    noki@123
${EMIL_server}     ${tl.nms[1].addr}
${EMIL_HOST}              ${EMIL_server['ip']}
${EMIL_USER}        ${EMIL_server['user']}
${EMIL_PASSWORD}        ${EMIL_server['password']}
${DCAP_FILE_PATH}      /home/ute/DCAP_FILE/
${ute_host}           ${tl.test_pc.default_ssh_connection_details.addr}
${ute_user}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}
${bts_host}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${vdu_host}    ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
${vcu_host}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${du_admin_username}        ${tl.gnbs[0].dus[0].oam_http_connection_details.username}
${du_admin_password}        ${tl.gnbs[0].dus[0].oam_http_connection_details.password}
${cu_admin_username}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
${cu_admin_password}        ${tl.gnbs[0].cu.oam_http_connection_details.password}
${profiles}    5G
${docker_cmd}    docker exec -it FlowTracer /bin/bash -c \'./fcmd ${DCAP_host}:50001
${profile_path}     C:\\\\Emil\\\\profiles\\\\5G
${scrambled_trace_path}    C:\\\\temp\\\\scrambled_trace
${emil_path}    C:\\\\Emil

*** Keywords ***
Suite setup
    Run Keyword And Ignore Error    robot_common_operations.Common Suite Setup
    Run Keyword And Ignore Error    CI_interface.Common Suite Setup
    csn.Connect to   hostname=${EMIL_HOST}    username=${EMIL_USER}    password=${EMIL_PASSWORD}    alias=Emil_decode
    csn.Execute    command=rm -rf "${scrambled_trace_path}"    connection=Emil_decode
    csn.Execute    command=mkdir "${scrambled_trace_path}"    connection=Emil_decode
    csn.Disconnect    connection=Emil_decode
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    csn.Execute   command=rm -rf ${DCAP_FILE_PATH}     connection=ute
    csn.Execute   command=mkdir ${DCAP_FILE_PATH}     connection=ute
    csn.Disconnect     connection=ute

Suite teardown
    Run Keyword And Ignore Error    DCAP.stop_trace    trace_id=${tracer_id}
    Run Keyword And Ignore Error    robot_common_operations.Common Suite teardown


Start DCAP log
    [Arguments]   ${bts}=${bts}
    log to console    \n Start DCAP log
    DCAP.connect_to     host=${DCAP_host}    port=${DCAP_port}     username=${None}
    ...     password=${None}     rd_version=dcapv3    secure=True
    ${gnb_custom_profile}=     Create List     cp_5g
    ${output}     DCAP.start_trace     bts=${bts}     gnb_custom_profile=${gnb_custom_profile}     wait_for_activation=${True}
    Log    ${output}[tracer_id]
    set test variable    &{output}
    sleep    5s
    [Return]     ${output}[tracer_id]

Stop DCAP log and check CNI81590 work
    [Arguments]    ${trace_id}
    log to console    \n Stop DCAP log and convert to txt type
    ${profile_file}    set variable    SourceProfileUser.ini
    DCAP.stop_trace    trace_id=${trace_id}
    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${trace_id}    target_dir=${DCAP_FILE_PATH}
    set suite variable     ${downloaded_emil_file_path}
    Get the exact emil log and convert to txt
    ...     profile_file=${profile_file}
    [Teardown]    run keyword and ignore error    csn.Disconnect     connection=ute


Get the exact emil log and convert to txt
    [Arguments]     ${profile_file}
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    csn.Execute   command=find ${DCAP_FILE_PATH} -type f -not -name '*.zip' -delete    connection=ute
    csn.Execute   command=unzip ${downloaded_emil_file_path} -d ${DCAP_FILE_PATH}dcap_tmp/    connection=ute
    csn.Execute   command=ls -R ${DCAP_FILE_PATH}dcap_tmp/ | grep .5gm > ${DCAP_FILE_PATH}dcap_log_name.txt
    ...    connection=ute
    csn.Execute   command=wc -l ${DCAP_FILE_PATH}dcap_log_name.txt >> ${DCAP_FILE_PATH}dcap_log_name.txt
    ...    connection=ute
    ${range}    csn.Execute   command=awk 'END{print $1}' ${DCAP_FILE_PATH}dcap_log_name.txt    connection=ute
    ${range}    Convert To Integer    ${range}
    ${range}=    Evaluate    ${range}+1
    FOR    ${i}    IN RANGE    1    ${range}
        ${emil_log_name}    csn.Execute    command=sed -n ${i}p ${DCAP_FILE_PATH}dcap_log_name.txt    connection=ute
        ${emil_log_name}    strip string    ${emil_log_name}
        csn.Execute   command=cp $(find ${DCAP_FILE_PATH}/ -name ${emil_log_name}) ${DCAP_FILE_PATH}
        ...    connection=ute
        convert to txt    emil_log_name=${emil_log_name}
        ...    profile_file=${profile_file}
        sleep    10s
    END
    [Teardown]      csn.Disconnect     connection=ute

convert to txt
    [Arguments]    ${emil_log_name}    ${profile_file}
    log to console    \n Upload emil script
    log to console     EMIL host is ${EMIL_HOST}
    Csn.Connect to   hostname=${EMIL_HOST}    username=${EMIL_USER}    password=${EMIL_PASSWORD}
    ...    alias=Emil_decode
    csn.Execute    command=rm -f "${profile_path}\\\\SourceProfileUser.ini"     connection=Emil_decode
    csn.Execute    command=rm -f "${emil_path}\\\\covert_to_txt_original.bat" "${emil_path}\\\\covert_to_txt_scrambled.bat"
    ...    connection=Emil_decode
    csn.Upload File   local_path=${DCAP_FILE_PATH}${emil_log_name}   remote_path=${scrambled_trace_path}\\\\${emil_log_name}
    ...    connection=Emil_decode
    log to console    \n Scramble cplane trace
    csn.Execute    command=cd "${emil_path}"    connection=Emil_decode
    ${result}     csn.Execute
    ...    command="Emil.exe" "${scrambled_trace_path}\\\\${emil_log_name}" -scramble -ScramblePath "${scrambled_trace_path}"   connection=Emil_decode
    should contain    ${result}	  emil saved successfully
    ${result}    Fetch From Left    ${result}    saved successfully
    ${result1}    Fetch From Right    ${result}    Info:
    ${Cplane_trace_scrambled}     Remove String    ${result1}    ${SPACE}
    log to console    \n scrambled_trace is ${Cplane_trace_scrambled}
    log to console    \n create bat command
    ${txt_original}=    set variable    ${emil_log_name}.txt
    ${txt_scrambled}=    set variable    ${emil_log_name}_S.txt
    ${cmd}=    catenate    start /wait Emil.exe "${scrambled_trace_path}\\\\${emil_log_name}"
    ...    -AutoClose -Profile SourceProfileUser.ini -ProfilePath "${profile_path}" -Variable OutPath "${scrambled_trace_path}\\\\${txt_original}"
    ${cmd1}=   catenate    start /wait Emil.exe "${scrambled_trace_path}\\\\${Cplane_trace_scrambled}"
    ...    -AutoClose -Profile SourceProfileUser.ini -ProfilePath "${profile_path}" -Variable OutPath "${scrambled_trace_path}\\\\${txt_scrambled}"
    set suite variable    ${cmd}
    set suite variable    ${cmd1}
    OperatingSystem.Create File     path=${DCAP_FILE_PATH}covert_to_txt_original.bat    content=${cmd}
    OperatingSystem.Create File     path=${DCAP_FILE_PATH}covert_to_txt_scrambled.bat    content=${cmd1}
    log to console    \n convert to txt
    csn.Upload File   local_path=${CURDIR}/${profile_file}   remote_path=${profile_path}\\\\SourceProfileUser.ini
    ...    connection=Emil_decode
    csn.Upload File   local_path=${DCAP_FILE_PATH}covert_to_txt_original.bat   remote_path=${emil_path}\\\\covert_to_txt_original.bat
    ...    connection=Emil_decode
    csn.Upload File   local_path=${DCAP_FILE_PATH}covert_to_txt_scrambled.bat    remote_path=${emil_path}\\\\covert_to_txt_scrambled.bat
    ...    connection=Emil_decode
    csn.Execute    command=cd "${emil_path}";cmd.exe /c covert_to_txt_original.bat    connection=Emil_decode
    csn.Execute    command=cd "${emil_path}";cmd.exe /c covert_to_txt_scrambled.bat    connection=Emil_decode
    Run keyword and ignore error
    ...    Check TMSI is not scrambled    txt_log_original=${scrambled_trace_path}\\\\${txt_original}
    ...    txt_log_scrambled=${scrambled_trace_path}\\\\${txt_scrambled}  connection=Emil_decode
    Run keyword and continue on failure
    ...    Check PLMN is not scrambled   txt_log_original=${scrambled_trace_path}\\\\${txt_original}
    ...    txt_log_scrambled=${scrambled_trace_path}\\\\${txt_scrambled}  connection=Emil_decode
    Run keyword and continue on failure
    ...    Check GUAMI is not scrambled   txt_log_original=${scrambled_trace_path}\\\\${txt_original}
    ...    txt_log_scrambled=${scrambled_trace_path}\\\\${txt_scrambled}  connection=Emil_decode
    Run keyword and continue on failure
    ...    Check NSSAI is not scrambled   txt_log_original=${scrambled_trace_path}\\\\${txt_original}
    ...    txt_log_scrambled=${scrambled_trace_path}\\\\${txt_scrambled}  connection=Emil_decode
    [Teardown]    run keywords    csn.Execute    command=rm -f "${profile_path}\\SourceProfileUser.ini"    connection=Emil_decode
    ...    AND    csn.Disconnect    connection=Emil_decode


######CNI81590#####
Check TMSI is not scrambled
    [Arguments]    ${txt_log_original}    ${txt_log_scrambled}    ${connection}
    log to console    \n Check TMSI is not scrambled
    @{filter_name}=    Create List    fiveG-TMSI \'       ng-5G-S-TMSI-Value ng-5G-S-TMSI-Part2      ue-Identity ng-5G-S-TMSI-Part1
    FOR     ${filter}      IN       @{filter_name}
        ${filter_original}    csn.Execute   command=cat ${txt_log_original} | grep "${filter}"
        ...    connection=${connection}
        ${filter_scrambled}    csn.Execute   command=cat ${txt_log_scrambled} | grep "${filter}"
        ...    connection=${connection}
        Should Not Contain Any    ${filter_original}    unexpected    error
        should be equal    ${filter_original}     ${filter_scrambled}
    END

Check PLMN is not scrambled
    [Arguments]    ${txt_log_original}    ${txt_log_scrambled}    ${connection}
    log to console    \n Check PLMN is not scrambled
    #@{filter_name}=    Create List    pLMNIdentity \'    servingPLMN \'    value PLMN-Identity \: \'    pLMN-Identity \'
    @{filter_name}=    Create List    pLMNIdentity \'    servingPLMN \'    value PLMN-Identity \: \'
    FOR     ${filter}      IN       @{filter_name}
        ${filter_original}    csn.Execute   command=cat ${txt_log_original} |grep "${filter}"
        ...    connection=${connection}
        ${filter_scrambled}    csn.Execute   command=cat ${txt_log_scrambled} |grep "${filter}"
        ...    connection=${connection}
        Should Not Contain Any    ${filter_original}    unexpected    error
        should be equal    ${filter_original}     ${filter_scrambled}
    END
    @{filter_name}=    Create List     PlmnId :      PlmnIdentity :
    FOR     ${filter}      IN       @{filter_name}
        ${filter_original}    csn.Execute   command=cat ${txt_log_original} |grep -A 3 -w "${filter}" |grep -v N/A
        ...    connection=${connection}
        ${filter_scrambled}    csn.Execute   command=cat ${txt_log_scrambled} |grep -A 3 -w "${filter}" |grep -v N/A
        ...    connection=${connection}
        Should Not Contain Any    ${filter_original}    unexpected    error
        should be equal    ${filter_original}     ${filter_scrambled}
    END

Check GUAMI is not scrambled
    [Arguments]    ${txt_log_original}    ${txt_log_scrambled}    ${connection}
    log to console    \n Check GUAMI is not scrambled
    @{filter_name}=    Create List    value GUAMI \: \{
    FOR     ${filter}      IN       @{filter_name}
        ${filter_original}    csn.Execute   command=cat ${txt_log_original} |grep -A 5 -w "${filter}"
        ...    connection=${connection}
        ${filter_scrambled}    csn.Execute   command=cat ${txt_log_scrambled} |grep -A 5 -w "${filter}"
        ...    connection=${connection}
        Should Not Contain Any    ${filter_original}    unexpected    error
        should be equal    ${filter_original}     ${filter_scrambled}
    END

Check NSSAI is not scrambled
    [Arguments]    ${txt_log_original}    ${txt_log_scrambled}    ${connection}
    log to console    \n Check NSSAI is not scrambled
    @{filter_name}=    Create List      s-NSSAI \{      Snssai \:       sNSSAI \{
    FOR     ${filter}      IN       @{filter_name}
        ${filter_original}    csn.Execute   command=cat ${txt_log_original} |grep -A 3 -w "${filter}"
        ...    connection=${connection}
        ${filter_scrambled}    csn.Execute   command=cat ${txt_log_scrambled} |grep -A 3 -w "${filter}"
        ...    connection=${connection}
        Should Not Contain Any    ${filter_original}    unexpected    error
        should be equal    ${filter_original}     ${filter_scrambled}
    END
        ${filter_original}    csn.Execute   command=cat ${txt_log_original} |grep -A 8 -w "SnssaiList :"
        ...    connection=${connection}
        ${filter_scrambled}    csn.Execute   command=cat ${txt_log_scrambled} |grep -A 8 -w "SnssaiList :"
        ...    connection=${connection}
        Should Not Contain Any    ${filter_original}    unexpected    error
        should be equal    ${filter_original}     ${filter_scrambled}

######CNI81590#####

CNI81590_CL_C4_Adaptive_Rank_PDSCH_Adaptive_PMI_Link_Adaptation_256QAM_Ideal_Radio_60MHz
    Log To Console    \n *** check SA senario
    Update the swconfig file    localFilePath=${swconfig_1856_case9}
    Prepare testline to cell onair    localFilePath=${case_scf_dir_path_1856_21A}    tl_scf_filename=${scf[0]}    type=SA
    #RANK1
    Adjust HBTE ATT Value  value_1=${${att_value[0]}}  value_2=${${att_value[2]}}  value_3=${${att_value[2]}}  value_4=${${att_value[2]}}
    ##########For CNI81590#################
    ${trace_id}    Start DCAP log     bts=${bts}
    ##########For CNI81590#################
    Log To Console    \n *** making call
    Power UE Attach and Start traffic     dl_throughput=${dl_tput}    type=SA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank1[2]}
    Adjust HBTE One ATT Value    value=${${att_value[0]}}    att_port=${att_ports_2}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank2[2]}
    Adjust HBTE One ATT Value    value=${${att_value[0]}}    att_port=${att_ports_3}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank3[2]}
    Adjust HBTE One ATT Value    value=${${att_value[1]}}    att_port=${att_ports_4}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank4[2]}
    Log To Console    \n *** stop call
    Power UE stop dl traffic and detach
    ##########For CNI81590#################
    Stop DCAP log and check CNI81590 work    trace_id=${trace_id}
    ##########For CNI81590#################
   # [Teardown]      Run Keyword And Ignore Error     Tests Recover for SA


CNI81590_CL_Rank_4_DL_4x4_MIMO_PDSCH_transmission_256QAM_with_port_selection_with_Wcsirs_is_not_Identity_100MHz
    Log To Console    \n *** check NSA senario
    Update the swconfig file    localFilePath=${swconfig_1856_case4}
    Log To Console    \n *** do commission for this case
    Prepare testline to cell onair    localFilePath=${case_scf_dir_path_1856_21A}    tl_scf_filename=${scf[2]}    type=NSA
    ##########For CNI81590#################
    ${trace_id}    Start DCAP log    bts=${bts}
    ##########For CNI81590#################
    Adjust HBTE ATT Value  value_1=${${att_value[0]}}  value_2=${${att_value[0]}}  value_3=${${att_value[0]}}  value_4=${${att_value[1]}}
    Power UE Attach and Start traffic     dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank4[0]}
    Power UE stop dl traffic and detach
    ##########For CNI81590#################
    Stop DCAP log and check CNI81590 work    trace_id=${trace_id}
    ##########For CNI81590#################
    #[Teardown]      Run Keyword And Ignore Error     Tests Recover for NSA

CNI81590.Teardown
    Run Keyword And Ignore Error    Prepare IWK testline to cell onair
    run keyword and ignore error    admin_cli.teardown    connection=${connection}