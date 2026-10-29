*** Settings ***
Documentation     author:shuhui.lou
...               Group: HGZ_SG1
...               contact: shuhui.lou@nokia-sbell.com

Resource       ../../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
#Resource       ../../../../RAN_PZ_HAZ_2/resources/vdu_cloud_deployment.robot
Library           taf.transport.ssh    WITH NAME    tafssh
Library           taf.ul.vdu.helm                       WITH NAME    helm
Library           Process
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           taf.config.scf                        WITH NAME    scf
Library           taf.hw.fhgw.cli                       WITH NAME    issh
Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library           DateConversion.py
Library           testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
#Library         ../../../../RAN_PZ_HAZ_2/resources/py_tool/utils.py
*** Variables ***
${DU_SCF}                /home/ute/TAF/cfgfile/TL003_VDU_golden_scf.xml
${CU_SCF}                /home/ute/TAF/cfgfile/TL003_VCU_golden_scf.xml
${scf_path}              /tmp/
${vCU_TRUNK_BRANCH}     vCUCNF00
${vCU_TRUNK_BUILD}      0.250.
${vCU_TRUNK_JSON}       ${CURDIR}/params_master_vCU.json
${vDU_24R2_BRANCH}      vDUCNF24R2
${vDU_TRUNK_BRANCH}     vDUCNF00
${vDU_TRUNK_JSON}       ${CURDIR}/params_master_vDU.json
${vDU_25R1_BUILD}       24.300.
${vDU_TRUNK_BUILD}      0.300.
${G_VDU_NAME}           vdutest
${G_VCU_NAME}           vcu
${CFGFILE_PATH}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/

###### Internal useage , please do not change it if you do not know it well #############
@{IGNORED_ALARM_LIST}
@{VDU_REST_TAF_LIB_SUPPORTED_VERSION}   cuoam_19b   cuoam_21b  cuoam_22r2  cuoam_22r4  cuoam_23r1  cuoam_23r2
...                                     cuoam_23r3  cuoam_23r4  cuoam_24r1  cuoam_24r2
&{VDU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING}   16.300=cuoam_22r4  15.300=cuoam_22r2  17.300=cuoam_23r1    18.300=cuoam_23r2  19.300=cuoam_23r3
                                    ...  20.300=cuoam_23r4  21.300=cuoam_23r4  24.300=cuoam_25r1  0.300=${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}
@{VCU_REST_TAF_LIB_SUPPORTED_VERSION}   cuoam_19b   cuoam_21b   cuoam_22r4  cuoam_23r1  cuoam_23r2
&{VCU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING}   15.250=cuoam_21b    16.250=cuoam_22r4  17.250=cuoam_23r1   24.250=cuoam_25r1
                                          ...   0.250=${VCU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}
# ----------- VDU part --------------
#${VDU_CONTAINER_PROMPT}          sh-\\d\\.\\d\\$\\s
${VDU_CONTAINER_PROMPT}          bash-\\d\\.\\d\\$\\s
${VDU_CONTAINER_PROMPT_ROOT}     \\[root@\\S+:\\S+\\][\\r\\n]+#\\s
${VDU_OE_SERVER_PROMPT}          \\[core@\\S+\\s\\S+\\]\\$\\s
${VDU_OE_SERVER_PROMPT_TENANT}   \\[cranuser\\d+@\\S+\\s+\\S+\\]\\$
@{VDU_REDUNDENCY_POD_LIST}       up  rcpsdl  oamasm  oamcm  oamext  oamconfig  oamfm
@{VDU_REDUNDENCY_OAM_POD_LIST}   oamasm  oamcm  oamext  oamconfig  oamfm


# ----------- VCU part --------------
${VCU_CONTAINER_PROMPT}          bash-\\d\\.\\d\\$\\s
#${VCU_CONTAINER_PROMPT_ROOT}     #no root for vcu upue pod
#${VCU_OE_SERVER_PROMPT}          \\[core@\\S+\\s\\S+\\]\\$\\s
${VCU_OE_SERVER_PROMPT_TENANT}   \\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$

${vCU_ns}            ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
${vDU_ns}            ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}

${vDU_SSH_IP}            ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
${vDU_SSH_port}          ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}
${vDU_SSH_username}      ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
${vDU_SSH_password}      ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}


@{ng_links_ids}             1
@{network_slicing_ids}      1
##################define these variable for convenient############################

########################END of alias Define#######################################

*** Keywords ***

####Case Level  Keywords#####
TC.vCU_vDU_upgrade
#    KW.Reset VDU
#    sleep  5min
#    set test variable      ${vDU_SCF_PATH}  ${DU_SCF}
#    set test variable      ${vCU_SCF_PATH}  ${CU_SCF}
#    get vDU basic info about cell_id rmod_id_rannic_dist_name
#    wait until keyword succeeds     15min    20s     vDU Verify All Cells Status Should Be Onair
#    ${vCU_trunk_new_version}    Get Latest Released Build    ${vCU_TRUNK_JSON}    ${vCU_TRUNK_BRANCH}    ${vCU_TRUNK_BUILD}
#    ${VCU_VERSION}    vCU Get Active Build Version Without Branch
#    Run Keyword If    '${vCU_trunk_new_version}' != '${VCU_VERSION}'
#    ...   Deployment_vCU   VCU_VERSION=${vCU_trunk_new_version}
    ${trunk_new_version}    Get Latest Released Build    ${vDU_TRUNK_JSON}    ${vDU_TRUNK_BRANCH}    ${vDU_TRUNK_BUILD}
    ${active_version}    Get Active Build Version Without Branch
    Run Keyword If    '${trunk_new_version}' != '${active_version}'
    ...   Deployment_vDU  vDU_VERSION=${trunk_new_version}

TC.Test VDU cell block unblock
    AlarmWatchdog.add_allow_alarms    fault_id=49
    wait until keyword succeeds     5min    30s     get vDU basic info about cell_id rmod_id_rannic_dist_name
    wait until keyword succeeds     10min    30s     vDU Verify All Cells Status Should Be Onair
    ${alarm_num_before_test}  ${alarm_list_before_test}   vdu_get_active_alarms_before_test
    FOR  ${i}  IN RANGE  ${10}
        KW.Test VDU cell block unblock
#        vdu Compare alarms before and after testing   alarm_num_before_test=${alarm_num_before_test}
#          ...  alarm_list_before_test=${alarm_list_before_test}
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=49

TC.Test VDU cells lock unlock
    wait until keyword succeeds     5min    30s     get vDU basic info about cell_id rmod_id_rannic_dist_name
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    ${alarm_num_before_test}  ${alarm_list_before_test}   vdu_get_active_alarms_before_test
    FOR  ${i}  IN RANGE  ${10}
        KW.Test VDU cells lock unlock   cell_id_list=@{cell_id_list}
#        vdu Compare alarms before and after testing   alarm_num_before_test=${alarm_num_before_test}
#          ...  alarm_list_before_test=${alarm_list_before_test}
    END


TC.Test VDU Reset
#    KW.Reset VDU
#    sleep  5min
    AlarmWatchdog.add_allow_alarms    fault_id=4592
    wait until keyword succeeds     5min    30s     get vDU basic info about cell_id rmod_id_rannic_dist_name
#    wait until keyword succeeds     25min    30s     vDU Verify All Cells Status Should Be Onair
    sleep  3min
    ${alarm_num_before_test}  ${alarm_list_before_test}   vdu_get_active_alarms_before_test
    FOR  ${i}  IN RANGE  ${10}
        Test VDU Reset
        sleep  2min
#        vdu Compare alarms before and after testing   alarm_num_before_test=${alarm_num_before_test}
#          ...  alarm_list_before_test=${alarm_list_before_test}
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=4592

TC.Test RUs lock_unlock
    AlarmWatchdog.add_allow_alarms    fault_id=4592
    KW.Reset VDU
    sleep  6min
    wait until keyword succeeds     5min    30s     get vDU basic info about cell_id rmod_id_rannic_dist_name
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    sleep  1min
    ${alarm_num_before_test}  ${alarm_list_before_test}   vdu_get_active_alarms_before_test
    FOR  ${i}  IN RANGE  ${10}
        KW.Test RUs lock_unlock     rmod_id_list=@{rmod_id_list}
        vdu Compare alarms before and after testing   alarm_num_before_test=${alarm_num_before_test}
          ...  alarm_list_before_test=${alarm_list_before_test}
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=4592

TC.Test VDU RUs reset
 #   KW.Reset VDU
 #   sleep  5min
    wait until keyword succeeds     5min    30s     get vDU basic info about cell_id rmod_id_rannic_dist_name
    wait until keyword succeeds     25min    30s     vDU Verify All Cells Status Should Be Onair
    ${alarm_num_before_test}  ${alarm_list_before_test}   vdu_get_active_alarms_before_test
    FOR  ${i}  IN RANGE  ${10}
        KW.VDU RUs reset     rmod_id_list=@{rmod_id_list}
        vdu Compare alarms before and after testing   alarm_num_before_test=${alarm_num_before_test}
          ...  alarm_list_before_test=${alarm_list_before_test}
    END


TC.Test VDU rannic reset
#    KW.Reset VDU
#    sleep  6min
    AlarmWatchdog.add_allow_alarms    fault_id=4350
    AlarmWatchdog.add_allow_alarms    fault_id=16
    AlarmWatchdog.add_allow_alarms    fault_id=4405
    AlarmWatchdog.add_allow_alarms    fault_id=4298
    wait until keyword succeeds     5min    30s     get vDU basic info about cell_id rmod_id_rannic_dist_name
    wait until keyword succeeds     25min    30s     vDU Verify All Cells Status Should Be Onair
#    ${alarm_num_before_test}  ${alarm_list_before_test}   vdu_get_active_alarms_before_test
    FOR  ${i}  IN RANGE  ${10}
        KW.VDU rannic reset
#        vdu Compare alarms before and after testing   alarm_num_before_test=${alarm_num_before_test}
#          ...  alarm_list_before_test=${alarm_list_before_test}
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=4350
    AlarmWatchdog.remove_allow_alarms    fault_id=16
    AlarmWatchdog.remove_allow_alarms    fault_id=4405
    AlarmWatchdog.remove_allow_alarms    fault_id=4298

vDU.collect syslog by kuafu
    vDU SSH Login
	log to console     \n ***----Starting collect syslog by kuafu...
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./10-vdu-l3call-test.sh
    should contain  ${return}   90-collect-vdu-logs.sh
    ${return}    ssh.Execute  command=cd ${kuafu_dir}/scenarios/vdu_l3call;./90-collect-vdu-logs.sh syslog
    should contain  ${return}   stored in
    @{collect_syslog_process_output}=    Split String    ${return}   \r\n
    FOR   ${i}  IN    @{collect_syslog_process_output}
        ${matches}=  Get Regexp Matches  ${i}  tgz stored in /var/home/core
        ${matches_length}=  Get Length  ${matches}
        ${syslog_name_info_tmp}  run keyword If  ${matches_length}>=1  set variable  ${i}
        Exit For Loop If   ${matches_length}>=1
    END
    @{syslog_name_info}=    Split String    ${syslog_name_info_tmp}   ${SPACE}
    ${syslog_name}  set variable  ${syslog_name_info}[5]
    ${syslog_full_path}  set variable  ${kuafu_dir}/${syslog_name}
    log to console  ${syslog_full_path}
    [Teardown]    helm.helm_master_close

TC.Test syslog he historic alarms
    KW.Get DU historic alarms
    vDU.collect syslog by kuafu

TC.Test 1N pod critical container AHM l1commproxy failure
    FOR  ${i}  IN RANGE  ${10}
        Test container failure
        sleep  2min
    END

TC.Test 1N pod none critical container OAMASM failure
    FOR  ${i}  IN RANGE  ${10}
        Test container failure
    END

TC.Test 1N pod none critical container OAMCM failure
    FOR  ${i}  IN RANGE  ${10}
        Test container failure
    END

TC.Test 1N pod none critical container OAMCONFIG cpconfig failure
    FOR  ${i}  IN RANGE  ${10}
        Test container failure
    END

TC.Test 1N pod none critical container OAMCONFIG trsconfig failure
    FOR  ${i}  IN RANGE  ${10}
        Test container failure
    END

TC.Test 1N pod none critical container OAMCONFIG tas failure
    FOR  ${i}  IN RANGE  ${10}
        Test container failure
    END

TC.Test 1N pod none critical container OAMCONFIG ims failure
    Test container failure


TC.Test 1N pod none critical container L2RT failure
    FOR  ${i}  IN RANGE  ${20}
        Test container failure
    END


TC.Test 1N pod none critical container L2HI failure
    FOR  ${i}  IN RANGE  ${20}
        Test container failure
    END

TC.Test 1N pod critical container OAMEXT oamagent failure
    Test container failure
TC.Test 1N pod critical container OAMBB failure
    Test container failure

Test container failure
    get vDU basic info about cell_id rmod_id_rannic_dist_name
#    KW.Reset VDU
#    sleep  5min
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    vDU.kill container and check coredump
    ${duration}   Run keyword if    '${vDU_rest}'=='True'    Set waiting duration  target_duration=15min
    ...  ELSE IF    '${cell_status}'=='down'   Set waiting duration  target_duration=7min
    ...  ELSE  Set waiting duration  target_duration=3min
    sleep    1min
    wait until keyword succeeds     ${duration}    30s     vDU Verify All Cells Status Should Be Onair
    sleep  10s

Set waiting duration
    [Arguments]  ${target_duration}=25min
    ${duration}   Set Variable  ${target_duration}
    [Return]   ${duration}
vDU.kill container and check coredump
    Run Keyword And Ignore Error   helm.helm_master_close
    ${conn}  vDU SSH Login
    ${channel} =    Call Method    ${conn}    invoke_shell
    sleep   10s
    run keyword if   "${ministarter}"=="False"  vDU.query container process ID and kill  channel=${channel}
     ...  ELSE   vDU.kill container with command pkill ministarter  channel=${channel}
    sleep   15s
    ${process_output_tmp}  Call Method    ${channel}    recv      ${65535}
    ${process_output_tmp}    Convert To String   ${process_output_tmp}
    ${process_output_tmp}    Replace String  ${process_output_tmp}    \x1b[?2004h    ${SPACE}
    ${process_output_tmp}    Replace String  ${process_output_tmp}    \x1b[?2004l\r    ${SPACE}
    @{process_output}=    Split String    ${process_output_tmp}   \r\n
    ${kill_timestamp}  set variable  ${process_output}[1]
    ${kill_timestamp}    Replace String    ${kill_timestamp}    ${SPACE}${SPACE}   ${SPACE}
    ${kill_timestamp}    Evaluate    "${kill_timestamp}".lstrip()
    #log to console      ${kill_timestamp}
    ${kill_timestamp}    Convert Date obtained from OCP  ${kill_timestamp}
    log to console     OCP date: ${kill_timestamp}
    run keyword if  "${ministarter}"=="False"    vDU.exit pod  channel=${channel}
#    Call Method    ${channel}    send    sudo coredumpctl list|grep present|grep ${container_name}\n
    Call Method    ${channel}    send    sudo coredumpctl list|grep present\n
#    Call Method    ${channel}    send    sudo coredumpctl list  --since="2 hour ago"\n
    sleep    30s
    ${coredump_output_tmp}  Call Method    ${channel}    recv      ${65535}
    ${coredump_output_tmp}    Convert To String   ${coredump_output_tmp}
    @{coredump_output}=    Split String    ${coredump_output_tmp}   \r\n
    ${coredump_list}       Create List
    FOR  ${i}  IN  @{coredump_output}
       ${tmp}    Replace String  ${i}    \x1b[?2004l\r    ${SPACE}
       ${tmp}    Replace String  ${tmp}    \x1b[?2004h      ${SPACE}
       ${tmp}    Replace String  ${tmp}  \x1b[01;31m\x1b[K   ${SPACE}
       ${tmp}    Replace String  ${tmp}   \x1b[m\x1b[K    ${SPACE}
       ${new_string}    Replace String    ${tmp}     ${SPACE}${SPACE}     ${SPACE}
       ${trimmed_string}    Evaluate    "${new_string}".lstrip()
       Append To List  ${coredump_list}   ${trimmed_string}
    END
    log to console   ${coredump_list}
    FOR  ${i}  IN  @{coredump_list}
        ${index}    Evaluate    "${i}".find(" UTC ")
        Continue For Loop If    ${index} == -1
        ${coredump_date}     Get Substring    ${i}    0  ${index}
        ${coredump_timestamp}   Convert Date obtained from coredump   ${coredump_date}
        log to console     coredump date: ${coredump_date}
        ${compare_result}    Compare Dates    ${coredump_timestamp}   ${kill_timestamp}
        run keyword if     ${compare_result}  Fail  AND  log to console   coredump observed and case failed
    END
    log to console   coredump not observed
    [Teardown]   Run Keyword And Ignore Error   helm.helm_master_close
vDU.exit pod
    [Arguments]  ${channel}=default
    Call Method    ${channel}    send    exit\n
    sleep  3s
    ${initial_output}   Call Method    ${channel}    recv      ${65535}
vDU.kill container with command pkill ministarter
    [Arguments]  ${channel}=default
    Call Method    ${channel}   recv      ${65535}
    Call Method    ${channel}
        ...  send   date;kubectl exec -it -n ${vDU_ns} po-${pod_name}-0 -c ctr-${container_name} -- pkill ministarter\n
    sleep    3s
vDU.query container process ID and kill
    [Arguments]  ${channel}=default
    Call Method    ${channel}   recv      ${65535}
    Call Method    ${channel}
    ...  send   kubectl exec -it -n ${vDU_ns} po-${pod_name}-0 -c ctr-${container_name} -- bash\n
    sleep    3s
    ${initial_output}  Call Method    ${channel}    recv      ${65535}
#    Call Method    ${channel}    send     ps -ef|grep -i "\.sh" | grep -v pipefail | grep /bin/ |grep -i ${process_name}/\n
    Call Method    ${channel}    send     ps -ef| grep -v pipefail |grep -v /bin/bash | grep /SS_OAM/ |grep -i ${process_name}/\n
    sleep    3s
    ${process_output_tmp}  Call Method    ${channel}    recv      ${65535}
    ${process_output_tmp}    Convert To String   ${process_output_tmp}
    @{process_output}=    Split String    ${process_output_tmp}   \r\n
    FOR  ${i}  IN  @{process_output}
       ${matches}=         get regexp matches  ${i}          9999
       ${matches_length}=  get length          ${matches}
       @{process_info}  run keyword if  ${matches_length}>0   Split String  ${i}
       Exit For Loop If     ${matches_length}>0
    END
    Call Method    ${channel}    send    date;kill ${kill_signal} ${process_info[1]}\n
#    Call Method    ${channel}    send    date\n
    sleep   3s
    [Return]   ${process_info[2]}
Deployment_vCU
    [Arguments]  ${VCU_VERSION}
    log to console  \n Case Precondition deploy vCU and onair
    vCU SSH Login
    VCU Onboard By Kuafu    kuafu_dir=${kuafu_dir_for_vCU}    build_version=${VCU_VERSION}
    vCU Undeployment 3 times
    FOR    ${i}    IN RANGE    3
        ${deploy_status}=    Run Keyword And Return Status   VCU deployment By Kuafu    kuafu_dir=${kuafu_dir_for_vCU}    chart_name=${G_VCU_NAME}
        run keyword if  "${deploy_status}" =="False"    log to console  vCU deploy failed, try to redeploy
        Exit For Loop If     ${deploy_status}
        vCU Undeployment 3 times
    END
    sleep    4min
    CU Full Commission Fix Error     path_of_commission_file=${vCU_SCF_PATH}
#    wait until keyword succeeds     10min    30s     CU Verify All Cells Status Are Onair
    sleep    3min
    [Teardown]  Run Keyword And Ignore Error   helm.helm_master_close
vCU Undeployment 3 times
        FOR    ${i}    IN RANGE    3
            ${Undeploy_status}=    Run Keyword And Return Status    VCU Undeployment By Kuafu  kuafu_dir=${kuafu_dir_for_vCU}
            run keyword if  "${Undeploy_status}" =="False"    log to console  vDU undeploy failed, try again
            Exit For Loop If     ${Undeploy_status}
        END
vCU SSH Login
    [Arguments]  ${gnb_index}=0
    ${conn}=  helm.helm_master_connect
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.port}
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    [Return]   ${conn}
VCU Undeployment By Kuafu
    [Arguments]     ${kuafu_dir}    ${gnb_index}=0
    log to console     \n ***----Starting undeploy vCU by kuafu...
    ${ns}  Get vCU Namespace From TestLine  ${gnb_index}
    ${current_chart_name}=     tafssh.Execute    command=helm list -n ${ns} |grep 'aic-vcu-0.250'|awk '{print $1}'|tr -d '\r\n'
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=chart_name     new_value=${current_chart_name}
    log to console  \n chart_name Replace Complete
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./20-vcu-l3call-test.sh   timeout=600s
    should contain  ${return}   20-delete-vcu-and-pvc.sh
    ${return}   tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vcu_l3call;./20-delete-vcu-and-pvc.sh
    should contain  ${return}   Delete vCU successfully
    ${return}   tafssh.Execute  command=helm list -n ${ns}
    should not contain  ${return}   deployed
    log to console  \n Delete vCU successfully
Get vCU Namespace From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  get vdu namespace from testline init config file
    ...  return the value correct get from TL
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu index | Yes. | the vdu index config on TL |
    ...    *RETURN VALUE*
    ...    namespace
    ${vCU_ns}=   set variable
    ...   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    [Return]   ${vCU_ns}
Change Value In Kuafu vCU Config File
    [Arguments]     ${kuafu_dir}    ${value_name}    ${new_value}
    ${current_value}    tafssh.Execute
    ...     cat ${kuafu_dir}/artifacts/vcu_config.ini | grep -w ${value_name} | grep -v '#' | tr -d '\r\n'
    tafssh.Execute  command=sed -i 's/${current_value}/${value_name}=${new_value}/g' ${kuafu_dir}/artifacts/vcu_config.ini
VCU Onboard By Kuafu
    [Arguments]     ${kuafu_dir}    ${build_version}
	log to console     \n ***----Starting onboard vCU by kuafu...
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=build_version     new_value=${build_version}
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./20-vcu-l3call-test.sh
    should contain  ${return}   16-onboard-vcu.sh
    ${return}    tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vcu_l3call;./16-onboard-vcu.sh
    should not contain  ${return}   build is not supported

VCU deployment By Kuafu
    [Arguments]     ${kuafu_dir}    ${chart_name}=${G_VCU_NAME}
    log to console     \n ***----Starting deploy vCU by kuafu...
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=chart_name     new_value=${chart_name}
    #Deployment type for vCU    ${kuafu_dir}   ${CNF_LAYOUT}   ${CPUE_COUNT}   ${UPUE_COUNT}   ${MIN_CPUE}   ${MIN_UPUE}
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./20-vcu-l3call-test.sh
    should contain  ${return}   21-create-vcu.sh
    ${return}   tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vcu_l3call;./21-create-vcu.sh
    should contain  ${return}   Create vCU successfully
    log to console  \n [INFO] Create vCU successfully
Deployment type for vCU
    [Arguments]     ${kuafu_dir}   ${cnf_layout}  ${cpue_count}   ${upue_count}   ${min_capacity_cpue}   ${min_capacity_upue}
    log to console    \n     Set vCU deployment type
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=cnf_layout       new_value=${cnf_layout}
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=cpue_count       new_value=${cpue_count}
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=upue_count       new_value=${upue_count}
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=min_capacity_cpue       new_value=${min_capacity_cpue}
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=min_capacity_upue       new_value=${min_capacity_upue}

vDU.Set RestoreData Value
    [Arguments]   ${restoreData}   ${prerequisite_yaml_file_path}
    [Documentation]   Set RestoreData to true or false in prerequisite yaml file
    ...   *AUTHOR* unknown
    ...  history change: lijuan.1.wang@nokia-sbell.com
    ...   20.9.2023, lijuan.1.wang@nokia-sbell.com, add parameter restoreData
    ...   27.10.2023, chris.l.cao@nokia-sbell.com, add restoreData when it not exist in yaml file
    ...
    ...   | Input Parameters | Man. | Description |
    ...	  | restoreData      | yes | restoreData, true or false |
    ...	  | prerequisite_yaml_file_path | yes | yaml file name of prerequisite |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...   | Set RestoreData Value | restoreData=false | prerequisite_yaml_file_path=/tmp/prerequisite.yaml |
    ...   | Set RestoreData Value | restoreData=true  | prerequisite_yaml_file_path=/tmp/prerequisite.yaml |
    ...
    log to console  start to set RestoreData Value
#    vDU SSH Login
    ${cmd}    Set Variable    grep restoreData ${prerequisite_yaml_file_path}|wc -l
    ${out}    tafssh.Execute   command=${cmd}
    ${stripped_result}=    Strip String    ${out}
    ${out}=    Convert To Number    ${stripped_result}

    #replace
    ${cmd}  Run Keyword If  ${out}>0   Set Variable    sed -i -e "s/restoreData:.*/restoreData: ${restoreData}/" ${prerequisite_yaml_file_path}
    Run Keyword If  ${out}>0   tafssh.Execute   command=${cmd}
    Return From Keyword If   ${out}>0

    #add
#    ${cmd}    Set Variable    sed -n '/^global:/'= ${prerequisite_yaml_file_path}
#    ${out}    tafssh.Execute   command=${cmd}
#    ${line_num}    Strip Prompt   ${out}
#    ${line_num}   Evaluate   int(${line_num})+1
#    ${cmd}    Set Variable    sed -i '${line_num} s/^/${SPACE}${SPACE}restoreData: ${restoreData}\\n/' ${prerequisite_yaml_file_path}
#    ${out}    tafssh.Execute   command=${cmd}
#    [Teardown]   Run Keyword And Ignore Error    helm.helm_master_close

Change Admin Password After redeploy vDU
    [Arguments]  ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error    vDU Rest Logout
    [Documentation]    Change admin password after Clean Deploy VDU
    ...    author: lijuan.1.wang@nokia-sbell.com
    VDU Rest Login1      vdu_index=${vdu_index}  password=nemuuser

vDU Rest Login1
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0  ${alias}=default  ${delay}=${EMPTY}
    ...          ${username}=${EMPTY}   ${password}=${Empty}
    [Documentation]  login vdu webem by restful api.
    ...   *Author*: calla.wang@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-3-31 | r3li | Update documentation |
    ...   | 2022-7-27 | calwang | update restapi_version default value to cuoam_22r4; add restapi version autodetection
    ...                           based on vDU SW release stream, if 0.300, the latest restapi version will be selected,
    ...                           otherwise the previous version will be selected. |
    ...   | 2022-8-1 | r3li | code enhance |
    ...   | 2022-8-3 | chris.l.cao | add '_Get vDU Rest Api Version' |
    ...   | 2022-10-21 | calla | adding two parameters - username and passowrd to support
    ...                          users can rest login to vdu by special username and password. |
    ...   | 2023-7-1 | chris.l.cao | add gnb_index while calling 'vDU Rest Logout'
    ...
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | restapi_version | No | restapi_version, Current possibilities: [`cuoam_19b`, `cuoam_21b`, 'cuoam_22r2', 'cuoam_22r4',
    ...                            'cuoam_23r1']. Defaults to newest implemented release - cuoam_23r1 |
    ...   | vdu_index | No | the index of vdu, default value is 0 |
    ...   | gnb_index | No | the index of gnb, default value is 0 |
    ...   | alias | No | connect name |
    ...   | delay | No | whether is there need sleep, default is ${EMPTY} means not sleep |
    ...   | username | No | vdu webem username, default is EMPTY. If not given, the username will be get from testline configuration |
    ...   | passwork | No | vdu webem password, default is EMPTY. If not given, password is 'Nokia@123' from 23r1 release,
    ...                     'nemuuser' in those older releases than 23r1 |
    ...   *Return*
    ...   None
    ...   *Example*
    ...   | vDU Rest Login | cuoam_21b | 0 | 0 | default | ${EMPTY} |
    ...   | vDU Rest Login | cuoam_19b | 0 | 0 | default | 10s |
    ...
    ${alias}   VDU Get Alias   gnb_index=${gnb_index}  vdu_index=${vdu_index}   alias=${alias}
    run keyword and ignore error  vDU Rest Logout
    ${vdu_oam_http_connection_info}     Get VDU OAM Http Connection Info    ${gnb_index}  ${vdu_index}
    ${oam_httpaddr}   set variable   ${vdu_oam_http_connection_info["addr"]}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    ${http_username}  Run Keyword If  "${username}"=="${EMPTY}"  set variable  ${vdu_oam_http_connection_info["username"]}
    ...  ELSE  set variable   ${username}
    ${http_password}  Run Keyword If  "${password}"=="${EMPTY}"   Set Variable  ${vdu_oam_http_connection_info["password"]}
    ...  ELSE  set variable   ${password}
    vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${http_username}
    ...  password=${http_password}
    ...  vdu_version=${vdu_oam_http_connection_info["restapi_version"]}
    ...  secure=True
    ...  connection_name=${alias}
    ...  timeout=10
    Run Keyword If  "${delay}"!="${EMPTY}"  Sleep   ${delay}
    [Return]  ${alias}


VDU Get Alias
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0   ${alias}=default
    [Documentation]  VDU Get Alias
    ...    author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   1.7.2023, chris.l.cao@nokia-sbell.com, support multip VDU operation
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    |  vdu_index  | No |  gnb index to indicate which vdu will be used  |
    ...    |  alias | No. | alias that identifies this connection |

	...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...
    ...    Example
    ...    | ${alias} | VCU Get Alias   |  gnb_index=0   |
    ...
    Return From Keyword If   "${alias}"!="default"      ${alias}
    ${alias}   Set Variable If   ${gnb_index}==0 and ${vdu_index}==0   default   vdu_connection_${gnb_index}_${vdu_index}
    [Return]  ${alias}
Get VDU OAM Http Connection Info
    [Arguments]    ${gnb_index}=0     ${vdu_index}=0
    [Documentation]  Get vDU OAM Http Connection Info
     ...   *author*: chris.l.cao@nokia-sbell.com
     ...   *history change*:
     ...   | date | who | what and how |
     ...   | 11.12.2021 | chris.l.cao@nokia-sbell.com | convert robot KW to python KW |
     ...   | 13.9.2022 | rui.3li@nokia-sbell.com | add version judgment |
     ...   | 21.10.2022 | calla | adding restapi_version in the return value |
     ...
     ...    | Input Parameters | Man. | Description |
     ...	| gnb_index | no | gnb_index, default is 0 |
     ...	| vdu_index | no | vdu_index, default is 0 |
     ...
     ...    *RETURN VALUE*
     ...    Dictionary of OAM connection information defined in __init__.py,
     ...           dictionary keys are addr, username, password and port.
     ...    example: {'addr': '1.1.1.1', 'username': 'Nemuadmin', 'password': 'nemuuser', 'port': '443'}
     ...
     ...    Example
     ...    | ${vdu_oam_http_connection_info} | Get vDU OAM Http Connection Info |
     ...    | ${vdu_oam_http_connection_info} | Get vDU OAM Http Connection Info | vdu_index=1 |
     ...
    ${status}  ${restapi_version}  Run Keyword And Ignore Error   Get vDU Rest Api Version
    ${restapi_version}   Set Variable If    '${status}'=='FAIL'    ${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}     ${restapi_version}
    ${addr}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${username}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ${index}     Get Index From List     ${VDU_REST_TAF_LIB_SUPPORTED_VERSION}     ${restapi_version}
    ${password}    Set Variable If    ${index}>=${4}     Nokia@123
    ...    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ${result}    Create dictionary    addr=${addr}    username=${username}    password=${password}   port=443
    ...  restapi_version=${restapi_version}
    [Return]    ${result}

vdu Compare alarms before and after testing
    [Arguments]   ${alarm_num_before_test}  ${alarm_list_before_test}
    ${vdu_get_active_alarms}  KW.Get DU active alarms
    ${alarm_num_after_test}=    set variable    ${vdu_get_active_alarms['total']}
    ${alarm_num_after_test}=     Convert To Integer  ${alarm_num_after_test}
    ${alarm_num_before_test}=    Convert To Integer  ${alarm_num_before_test}
    run keyword if     ${alarm_num_after_test} == ${alarm_num_before_test} == 0   log to console  no alarm detected on WebEM, test passed.
    run keyword if     ${alarm_num_after_test} > ${alarm_num_before_test}  Fail
    run keyword if      0 < ${alarm_num_after_test} <= ${alarm_num_before_test}    vdu_get_detail_alarms_info1
     ...   alarm_num_after_test=${alarm_num_after_test}   vdu_get_active_alarms_after_test=${vdu_get_active_alarms}
     ...  alarm_list_before_test=${alarm_list_before_test}
vdu_get_detail_alarms_info1
    [Arguments]  ${alarm_num_after_test}  ${vdu_get_active_alarms_after_test}  ${alarm_list_before_test}
     FOR    ${index}    IN RANGE    ${alarm_num_after_test}
        ${alarm_info_after_test_tmp}       Create List
        ${fault_name}    Set Variable    ${vdu_get_active_alarms_after_test['alarms'][${index}]['fault_name']}
        ${alarming_object}    Set Variable    ${vdu_get_active_alarms_after_test['alarms'][${index}]['alarming_object']}
        Append To List   ${alarm_info_after_test_tmp}    ${fault_name}    ${alarming_object}
        List Should Contain Value    ${alarm_list_before_test}   ${alarm_info_after_test_tmp}
    END
    [Return]  ${alarm_list_before_test}
vdu_get_active_alarms_before_test
    ${vdu_get_active_alarms_before_test}  KW.Get DU active alarms
    ${alarm_num_before_test}=    set variable    ${vdu_get_active_alarms_before_test['total']}
    ${alarm_list_before_test}   run keyword if   "${alarm_num_before_test}"!="${0}"   vdu_get_detail_alarms_info
      ...   alarm_num_before_test=${alarm_num_before_test}   vdu_get_active_alarms_before_test=${vdu_get_active_alarms_before_test}
    [Return]   ${alarm_num_before_test}  ${alarm_list_before_test}
vdu_get_detail_alarms_info
    [Arguments]  ${alarm_num_before_test}  ${vdu_get_active_alarms_before_test}
    ${alarm_list_before_test}       Create List
    FOR    ${index}    IN RANGE    ${alarm_num_before_test}
        ${alarm_list_before_test_tmp}       Create List
        ${fault_name}    Set Variable    ${vdu_get_active_alarms_before_test['alarms'][${index}]['fault_name']}
        ${alarming_object}    Set Variable    ${vdu_get_active_alarms_before_test['alarms'][${index}]['alarming_object']}
        Append To List   ${alarm_list_before_test_tmp}    ${fault_name}    ${alarming_object}
        Append To List   ${alarm_list_before_test}  ${alarm_list_before_test_tmp}
    END
    [Return]  ${alarm_list_before_test}

Collect snapshot if test failed
    run keyword if    '${TEST_STATUS}'=='FAIL'    VDU Collect Snapshot To Local  compressed_or_not=True

get vDU basic info about cell_id rmod_id_rannic_dist_name
    [Arguments]  ${vdu_index}=0
    ${alias}    vDU Rest Login       vdu_index=${vdu_index}
    ${cell_info}     Run Keyword And Continue On Failure     vdu.get_vdu_cells_status    timeout=180
     @{cell_id_list}    create list
    FOR    ${elem}    IN    @{cell_info}
        Append to list    ${cell_id_list}   ${elem['id']}
    END
    Set Test Variable    ${cell_id_list}
    ${rmod_info}     Run Keyword And Continue On Failure    vdu.get_rmods_status   timeout=120
        @{rmod_id_list}    create list
    FOR    ${elem}    IN    @{rmod_info}
        Append to list    ${rmod_id_list}   ${elem['id']}
    END
    Set Test Variable    ${rmod_id_list}
    ${vdu_info}     Run Keyword And Continue On Failure     vdu.get_vdu_state_data
    @{du_id}    create list
    ${nr_du_id}   Get From Dictionary   ${vdu_info}   nr_du_id
    Append to list      ${du_id}  ${nr_du_id}
    Set Test Variable   @{du_id}
    ${mrbts_id}   Get From Dictionary   ${vdu_info}   mrbts_id
    Set Test Variable   ${mrbts_id}
    ${nrbts_id}   Get From Dictionary   ${vdu_info}   nrbts_id
    ${rannic_info}     Run Keyword And Continue On Failure    vdu.get_rnic_info_from_plan  mrbts_id=${mrbts_id}     timeout=180
    @{rannic_dist_name_list}    create list
    FOR    ${elem}    IN    @{rannic_info}
        Append to list    ${rannic_dist_name_list}   ${elem['r_nic_mod_dist_name']}
    END
    Set Test Variable    ${rannic_dist_name_list}
    [Teardown]   Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}

Deployment_vDU
    [Arguments]  ${vDU_VERSION}
    log to console  Case Precondition deploy vDU and onair
    vDU SSH Login
    VDU Onboard By Kuafu       build_version=${vDU_VERSION}
    ${prerequisite_yaml_file_path}    set variable    ${kuafu_dir}/charts/vdu/aic-vdu-${vDU_VERSION}/aic-vdu-prerequisite/values.yaml
    vDU.Set RestoreData Value   restoreData=false   prerequisite_yaml_file_path=${prerequisite_yaml_file_path}
    VDU Undeployment 3 times
    FOR    ${i}    IN RANGE    3
        ${deploy_status}=    Run Keyword And Return Status   VDU deployment By Kuafu      chart_name=${G_VDU_NAME}
        run keyword if  "${deploy_status}" =="False"    log to console  vDU deploy failed, try to redeploy
        Exit For Loop If     ${deploy_status}
        VDU Undeployment 3 times
    END
    sleep    4min
    Change Admin Password After redeploy vDU
    vDU Full Commission SCF Fix Error  path_of_commission_file=${vDU_SCF_PATH}
    ${status}   check alarm Incompatible SW version detected multi times
    Run Keyword If  '${status}' == 'False'  Fail  RU SW upgrade not completed
#    ${status}  Set Variable  True
#    ${return_status}  Get_Current_Plan_File_after_deployed
#    Run Keyword If  '${return_status}' == 'False'  vDU Full Commission SCF Fix Error  path_of_commission_file=${vDU_SCF_PATH}
#    ${status}   Run Keyword If   ${return_status}==True   check alarm Incompatible SW version detected multi times
#    Run Keyword If  '${status}' == 'False'  Fail  RU SW upgrade not completed
#    Run Keyword If  '${status}' == 'True'  vDU Full Commission SCF Fix Error  path_of_commission_file=${vDU_SCF_PATH}
    sleep    3min
    get vDU basic info about cell_id rmod_id_rannic_dist_name
    log to console  start to verify all cells status
    wait until keyword succeeds     30min    30s     vDU Verify All Cells Status Should Be Onair
    [Teardown]  Run Keyword And Ignore Error   helm.helm_master_close


Get_Current_Plan_File_after_deployed
    [Arguments]  ${vdu_index}=0    ${gnb_index}=0
    ${alias}   vDU Rest Login    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${return_status}  Run Keyword And Return Status    vdu.Get_Current_Plan_File
    ...   local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    [Return]  ${return_status}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}

check alarm Incompatible SW version detected multi times
    log to console     start to check alarm "Incompatible SW version detected" after vDU deployed
    FOR  ${i}  IN RANGE  8
        ${status}  check active alarm named Incompatible SW version detected
        run keyword if  "${status}"=="True"   log to console   [INFO] alarm "Incompatible SW version detected" cleared, RU SW upgrade done.
        exit for loop if    "${status}"=="True"
        sleep    5min
    END
    [Return]  ${status}
VDU Undeployment 3 times
        FOR    ${i}    IN RANGE    3
            ${Undeploy_status}=    Run Keyword And Return Status    VDU Undeployment By Kuafu
            run keyword if  "${Undeploy_status}" =="False"    log to console  vDU undeploy failed, try again
            Exit For Loop If     ${Undeploy_status}
        END

VDU Undeployment By Kuafu
    log to console     \n ***----Starting undeploy vDU by kuafu...
    ${current_chart_name}=  tafssh.Execute
    ...   command=helm list -n ${vDU_ns} |grep -e aic-vdu-24.300 -e aic-vdu-0.300|awk '{print $1}'|tr -d '\r\n'
    Change Value In Kuafu vDU Config File   ${kuafu_dir}    value_name=chart_name     new_value=${current_chart_name}
    log to console  \n chart_name Replace Complete
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./10-vdu-l3call-test.sh
    should contain  ${return}   20-delete-vdu.sh
    ${return}   tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vdu_l3call;./20-delete-vdu.sh
    should contain  ${return}   ${vDU_DELETE_RESULT}
    log to console  \n [INFO] Delete vDU successfully
VDU Onboard By Kuafu
    [Arguments]    ${build_version}
#    vDU SSH Login
	log to console     \n ***----Starting onboard vDU by kuafu...
    Change Value In Kuafu vDU Config File   ${kuafu_dir}    value_name=build_version     new_value=${build_version}
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./10-vdu-l3call-test.sh
    should contain  ${return}   16-onboard-vdu.sh
    ${return}    ssh.Execute  command=cd ${kuafu_dir}/scenarios/vdu_l3call;./16-onboard-vdu.sh
    should not contain  ${return}   build is not supported
#    [Teardown]    helm.helm_master_close
VDU deployment By Kuafu
    [Arguments]       ${chart_name}=${G_VDU_NAME}
    log to console     \n ***----Starting deploy vDU by kuafu...
    Change Value In Kuafu vDU Config File   ${kuafu_dir}    value_name=chart_name     new_value=${chart_name}
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./10-vdu-l3call-test.sh
    should contain  ${return}   21-create-vdu.sh
    ${return}   tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vdu_l3call;./21-create-vdu.sh   timeout=600s
    should contain  ${return}   ${vDU_CREATE_RESULT}
    log to console  \n [INFO] Create vDU successfully

vDU Verify All Cells Status Should Be Onair
    [Arguments]  ${vdu_index}=0    ${gnb_index}=0
    [Documentation]    Check the number of cells which are in ubnormal status should be 0.
    ...    the keyword only support rest api v2.
    ...    the checked status are operational_state--disabled
    ...                           administrative_state--locked
    ...                           administrative_state--shutting_down
    ...    author:  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  vDU Verify All Cells Status Should Be Onair  | 0 |
    ${cell_num}=    Get Length   ${cell_id_list}
    ${alias}    vDU Rest Login    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${vdu_cells_summary}=  vdu.get_vdu_cells_summary
    ${operational_state}   set variable     ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}
#    ${administrative_state}  set variable      ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}
#    ${administrative_state1}   set variable     ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}  0
#    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}  0
#    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}  0
    Should Be Equal As Numbers  ${vdu_cells_summary['availability_status']['on_line']}  ${cell_num}
    log to console  All cells are onair.
    [Teardown]   Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}

vDU Rest Login
    [Documentation]  Description:           Login to vDU RestAPI ${\n}
    ...              Return:                vDU RestAPI login alias ${\n}
    ...              Output:                ${alias} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     23-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${restapi_version}=cuoam_25r1  ${timeout}=30  ${alias}=default

    Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}
    ${status}  ${restapi_version}=  Run Keyword And Ignore Error    Get vDU Rest Api Version
    ${restapi_version}=  Set Variable If  '${status}'=='FAIL'
    ...  ${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}  ${restapi_version}
    ${index}=  Get Index From List  ${VDU_REST_TAF_LIB_SUPPORTED_VERSION}  ${restapi_version}
    ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${http_password}=  Set Variable If  ${index}>=${4}  Nokia@123
    ...  ${oam_http_connection["password"]}
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
    ${port}=  Set Variable  ${oam_http_connection["port"]}
    ${username}=  Set Variable  ${oam_http_connection["username"]}
    ${password}=  Set Variable  ${http_password}
    ${secure}=  Set Variable  True
    vdu.Connect To  host=${ip_addr}  port=${port}  username=${username}  password=${password}
    ...  vdu_version=${restapi_version}  secure=${secure}  connection_name=${alias}  timeout=${timeout}
    [Return]  ${alias}

vDU Rest Logout
    [Documentation]  Description:           vDU RestAPI logout ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     23-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${alias}=default

    vdu.Disconnect  vdu_connection=${alias}

Get vDU Rest Api Version
    [Documentation]  Description:           Get vDU RestAPI version from global variables file (variables.robot) ${\n}
    ...              Return:                vDU Rest Api version for example cuoam_23r3 ${\n}
    ...              Output:                ${restapi_version} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     23-02-2024 made by szymon.romanowski@nokia.com ${\n}
    ${active_version}    Get Active Build Version Without Branch
    ${build_number_list}=  Split String  string=${active_version}  separator=.
    ${built_stream}=  Set Variable  ${build_number_list[0]}.${build_number_list[1]}
    ${restapi_version}=  Set Variable  ${VDU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING['${built_stream}']}
    [Return]  ${restapi_version}

Get vCU Rest Api Version
    [Documentation]  Description:           Get vDU RestAPI version from global variables file (variables.robot) ${\n}
    ...              Return:                vDU Rest Api version for example cuoam_23r3 ${\n}
    ...              Output:                ${restapi_version} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     23-02-2024 made by szymon.romanowski@nokia.com ${\n}
    ${active_version}    vCU Get Active Build Version Without Branch
    ${build_number_list}=  Split String  string=${active_version}  separator=.
    ${built_stream}=  Set Variable  ${build_number_list[0]}.${build_number_list[1]}
    ${restapi_version}=  Set Variable  ${VCU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING['${built_stream}']}
    [Return]  ${restapi_version}
Get vDU Namespace From Init File
    [Documentation]  Description:           Keyword gets vDU namespace parameters from TL configuration init file ${\n}
    ...              Return:                vDU namespace ${\n}
    ...              Output:                ${namespace} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    ${namespace}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    [Return]  ${namespace}

vDU SSH Login
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0
    ${conn}=  helm.helm_master_connect
#    ...  10.64.174.186
#    ...  22
#    ...  core
#    ...  system123
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    [Return]   ${conn}

Change Value In Kuafu vDU Config File
    [Arguments]     ${kuafu_dir}    ${value_name}    ${new_value}
    ${current_value}    tafssh.Execute
    ...     cat ${kuafu_dir}/artifacts/vdu_config.ini | grep -w ${value_name} | grep -v '#' | tr -d '\r\n'
    tafssh.Execute  command=sed -i 's/${current_value}/${value_name}=${new_value}/g' ${kuafu_dir}/artifacts/vdu_config.ini

Get Active Build Version Without Branch
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2020.09.10 | vDU | Xie Yunyi | first create |
    ...    Get the active build version of vDU or vCU by helm.
	[Arguments]     ${product}=vdu
    vDU SSH Login
    ${chart_info}   tafssh.Execute   helm ls -n ${vDU_ns}|grep ${product} | grep -v prerequisite |grep -v cluster
    @{chart_info_splitted}    Split String    ${chart_info}    ${product}-
    @{version}    Split String    ${chart_info_splitted[-1]}
    ${active_version}    Strip String    ${version[0]}
    [Return]    ${active_version}
    [Teardown]   Run Keyword And Ignore Error    helm.helm_master_close

vCU Get Active Build Version Without Branch
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2020.09.10 | vDU | Xie Yunyi | first create |
    ...    Get the active build version of vDU or vCU by helm.
	[Arguments]     ${product}=vcu
    vCU SSH Login
    ${chart_info}   tafssh.Execute   helm ls -n ${vCU_ns}|grep ${product} | grep -v prerequisite |grep -v cluster
    @{chart_info_splitted}    Split String    ${chart_info}    ${product}-
    @{version}    Split String    ${chart_info_splitted[-1]}
    ${active_version}    Strip String    ${version[0]}
    [Return]    ${active_version}
    [Teardown]   Run Keyword And Ignore Error    helm.helm_master_close
Get vDU Oam Http Connection Parameters From Init File
    [Documentation]  Description:           Keyword gets vDU OAM Http connection parameters from TL configuration init file ${\n}
    ...              Return:                Http connection parameters ${\n}
    ...              Output:                ${http_connection_parameters} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
#    ${ip_addr}=  Set Variable  10.64.174.210
#    ${username}=  Set Variable  Nemuadmin
#    ${password}=  Set Variable  Nokia@123
    ${port}=  Set Variable  443
    ${ip_addr}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${username}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ${password}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
#    ${port}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.port}
    ${http_connection_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  password=${password}  port=${port}
    [Return]  ${http_connection_parameters}


Get Latest Released Build
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2021.03.20 | 5G | Jet Li | first create |
    ...    | 2022.01.06 | 5G | Jet Li | update for 22R2 |
    ...    | 2022.03.16 | 5G | Gao Huike | update for common |
    ...    Get Latest QT released Build from WFT
	...    ${branch}, for example: vDUCNF22R2, vDUCNF, vCUCNF22R2, vCUCNF
	...    ${build}, for example: 14.300. , 0.300. , 14.250.  , 0.250.
	[Arguments]    ${parameter_json}    ${branch}    ${build}
	#${TEST_LOG_DIR}  set variable  /home/ute/TAF/
    ${cmd}    Catenate    curl -H 'Accept: application/json' -H 'Content-Type:application/json'
    ...    -d@${parameter_json} https://wft.int.net.nokia.com:8091/all/api/v1/build_branch.json  -o ${LOG_PATH}/response.json
    Run    cd ${CURDIR} ; ${cmd}
    ${response}    Get File    ${LOG_PATH}/response.json
    Log    ${response}
    ${build}  run keyword if   "${branch}"=="vDUCNF00"    Get Regexp Matches    ${response}
    ...    vDUCNF00_(0.300.\\d+).?,\"quicktest_status\":\{\"state\":\"(released\"|released_with_restrictions\")    1
    ...  ELSE
    ...     Get Regexp Matches    ${response}
    ...    vCUCNF00_(0.250.\\d+).?,\"quicktest_status\":\{\"state\":\"(released\"|released_with_restrictions\")    1
    [Return]    ${build[0]}


KW.Test RUs lock_unlock
    [Arguments]    ${rmod_id_list}    ${vdu_index}=0
    ${alias}   vDU Rest Login        vdu_index=${vdu_index}
    ${out}     Run Keyword And Continue On Failure     vdu.lock_rmods    rmod_id_list=${rmod_id_list}    vdu_connection=${alias}
    Run Keyword And Continue On Failure    KW.Check lock RU operation success    operation_id=${out["id"]}
    sleep   1min
    Run Keyword And Continue On Failure     vdu.unlock_rmods    rmod_id_list=${rmod_id_list}    vdu_connection=${alias}
    Run Keyword And Continue On Failure    KW.Check unlock RU operation success    operation_id=${out["id"]}
#    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     25min    30s     vDU Verify All Cells Status Should Be Onair
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}

KW.Check lock RU operation success
    [Arguments]    ${operation_id}
    Wait Until Keyword Succeeds  300   10   KW.Lock RUs Should Be Successful   operation_id=${operation_id}  expected_status=success

KW.Check unlock RU operation success
    [Arguments]    ${operation_id}
    Wait Until Keyword Succeeds  300   10   KW.unlock RUs Should Be Successful   operation_id=${operation_id}  expected_status=success

KW.Lock RUs Should Be Successful
    [Arguments]  ${operation_id}   ${expected_status}
    ${out}   vdu.get_operation_state_of_locking_rmods   operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

KW.unlock RUs Should Be Successful
    [Arguments]  ${operation_id}   ${expected_status}
    ${out}   vdu.get_operation_of_unlocking_rmods   operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


KW.VDU rannic reset
    [Arguments]    ${vdu_index}=0
    ${alias}   vDU Rest Login       vdu_index=${vdu_index}
    FOR  ${idx}   IN    @{rannic_dist_name_list}
        Run Keyword And Continue On Failure     vdu.reset_rannic    rannic_r_dn=${idx}
        ...    vdu_connection=${alias}
    END
    Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}
    wait until keyword succeeds     25min    30s     vDU Verify All Cells Status Should Be Onair


CU Verify All Cells Status Are Onair
    [Arguments]  ${gnb_index}=0
    [Documentation]      Check all cells operational state are operational and unlocked.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:
    ...    | date | who | what or how |
    ...    | 19-Nov-2019 | f2huang | initial created |
    ...    | 07-Nov-2022 | r3li | add enable check |
    ...   | 2023-7-5 | r3li | correct error for CU Rest Login changed |
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Verify All Cells Status Are Onair  |     |
    #${cell_numbers}    Get VCU Cell Number From SCF   gnb_index=${gnb_index}
    ${alias}   CU Rest Login  ${gnb_index}
    ${cells_summary}=   cu.get_cells_summary   connection=${alias}
    run keyword and continue on failure  should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["shutting_down"]}   0   Some cells are shutting down!
    run keyword and continue on failure  should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["locked"]}   0   Some cells are locked!
    run keyword and continue on failure  should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["operational_state"]["disabled"]}    0   Some cells are disabled!
#    run keyword and continue on failure  should be equal as integers
#    ...    ${cells_summary["basic_cells_summary"]["operational_state"]["enabled"]}    ${cell_numbers}   Some cells are disabled!
    [Teardown]   run keyword and ignore error   CU Rest Logout   connection=${alias}

CU Rest Logout
    [Arguments]  ${connection}=${None}
    [Documentation]  Teardown rest session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Rest Logout |   |
    cu.disconnect   connection=${connection}


KW.VDU RUs reset
    [Arguments]    ${rmod_id_list}    ${vdu_index}=0
    ${alias}   vDU Rest Login      vdu_index=${vdu_index}
    ${out}     Run Keyword And Continue On Failure     vdu.reset_rmods    rmods_list=${rmod_id_list}    vdu_connection=${alias}
    Run Keyword And Continue On Failure    KW.Check reset RU operation success    operation_id=${out["operation_id"]}
    sleep    1min
    wait until keyword succeeds     25min    30s     vDU Verify All Cells Status Should Be Onair
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}

Test VDU Reset
    KW.Reset VDU
    sleep    5min
    wait until keyword succeeds     30min    30s     vDU Verify All Cells Status Should Be Onair

KW.Check reset RU operation success
    [Arguments]    ${operation_id}
    Wait Until Keyword Succeeds  300   10   KW.Reset RUs Should Be Successful   operation_id=${operation_id}


KW.Reset RUs Should Be Successful
    [Arguments]  ${operation_id}
    vdu.get_reset_rmods_operation_status   operation_id=${operation_id}
    [Return]


check active alarm named Incompatible SW version detected
    ${vdu_get_active_alarms}   KW.Get DU active alarms
    ${output_lenth}=    set variable    ${vdu_get_active_alarms['total']}
    ${status}=   set variable   True
    ${expected_fault_name}  set variable   Incompatible SW version detected
    FOR    ${index}    IN RANGE    ${output_lenth}
        ${fault_name}    Set Variable    ${vdu_get_active_alarms['alarms'][${index}]['fault_name']}
        ${status}=    set variable if    "${fault_name}"=="${expected_fault_name}"    False
        run keyword if  "${status}"=="False"   log to console   [INFO] alarm "Incompatible SW version detected" found
        exit for loop if    "${fault_name}"=="${expected_fault_name}"
    END
    [Return]  ${status}
KW.Get DU active alarms
    ${alias}   vDU Rest Login
    ${vdu_get_active_alarms}   Run Keyword And Continue On Failure     vdu.vdu_get_active_alarms    vdu_connection=${alias}
    [Return]  ${vdu_get_active_alarms}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}

KW.Get DU historic alarms
    ${alias}   vDU Rest Login
    ${vdu_get_historical_alarms}   Run Keyword And Continue On Failure     vdu.vdu_get_historical_alarms    vdu_connection=${alias}
    ${alarms}    Get From Dictionary    ${vdu_get_historical_alarms}    alarms
    FOR    ${his_alarm}    IN    @{alarms}
        Log To Console   FaultId: ${his_alarm['fault_id']}; FaultName: ${his_alarm['fault_name']};
        Log To Console   Severity: ${his_alarm['severity']}; appear_time: ${his_alarm['appear_time']}
    END
    [Return]  ${vdu_get_historical_alarms}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}

KW.Test VDU cell block unblock
    ${alias}   vDU Rest Login
    FOR    ${idx}    IN    @{cell_id_list}
        Run Keyword And Continue On Failure     vdu.block_cell    cell_id=${idx}
        sleep    10s
    END
    sleep    30s
    FOR    ${idx}    IN    @{cell_id_list}
        Run Keyword And Continue On Failure     vdu.unblock_cell    cell_id=${idx}
        sleep    10s
    END
    Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair



KW.Test VDU cells lock unlock
    [Arguments]    ${cell_id_list}
    ${alias}   vDU Rest Login
    Run Keyword And Continue On Failure     vdu.lock_cells    cell_id_list=${cell_id_list}
    sleep    60s
    Run Keyword And Continue On Failure     vdu.unlock_cells    cell_id_list=${cell_id_list}
    sleep    60s
    Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair

KW.Cloud Commission And Check On Air
    [Arguments]    ${CU_SCF}    ${DU_SCF}
    CU Full Commission Fix Error          path_of_commission_file=${CU_SCF}
    vDU Full Commission SCF Fix Error     path_of_commission_file=${DU_SCF}
    sleep    1min
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     30min    30s     vDU Verify All Cells Status Should Be Onair


CU Full Commission Fix Error
    [Arguments]    ${path_of_commission_file}    ${gnb_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vCU commission ***
    ${alias}   CU Rest Login  ${gnb_index}
    vCU Load And Active SCF   ${path_of_commission_file}
    [Teardown]    run keyword and ignore error   CU Rest Logout   connection=${alias}

CU Login
    [Arguments]     ${gnb_index}=0   ${solution}=rest   ${alias}=${None}   ${restapi_version}=cuoam_25r1
    [Documentation]  Login to CU via rest or webui.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    |  solution | No |  rest or webui, rest in default |
    ...    |  alias | No. | alias that identifies this connection, if the argument is given,
    ...                     the alias must be given to the CU Logout keyword as connection argumument. |

    ...    *RETURN VALUE*
    ...    the restapi connection alias
    ...    Example
    ...    |  CU Login  |     |
    ${alias}=   run keyword if  "${solution}"=="rest"    CU Rest Login   ${gnb_index}  ${alias}   ${restapi_version}
    #...   ELSE    CU Webui Login    ${gnb_index}
    [Return]   ${alias}

CU Rest Login
   [Arguments]   ${gnb_index}=0   ${alias}=${None}
   [Documentation]  Create rest session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | restapi_version | No | if you use 'get_counter' keyword in CU trunk build, the parameter should be given 'cuoam_21b'
    ...                             other senarios should be use default value - cuoam_19b |
    ...    |  alias | No. | alias that identifies this connection, if the argument is given,
    ...                     the alias must be given to the CU Logout keyword as connection argumument. |
    ...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...    Example
    ...    |  CU Rest Login   |    0   |
    ${host}   set variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    #${host}   set variable if   ':' in '''${host_ip}'''   [${host_ip}]    ${host_ip}
    cu.connect to    host=${host}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    #...    cu_version=${restapi_version}
    ...    secure=${True}
    ...    alias=${alias}
    [Return]  ${alias}

vDU Full Commission SCF Fix Error
    [Arguments]     ${path_of_commission_file}     ${vdu_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vDU commission ***
    ${alias}   vDU Rest Login      ${vdu_index}
#    vDU Load And Active SCF   ${path_of_commission_file}
    vdu.Perform Commissioning    scf_file=${path_of_commission_file}
    sleep    3min
    [Teardown]    Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}

vCU Load And Active SCF
    [Arguments]     ${path_of_commission_file}    ${wait_active}=${True}
    log to console   \n*** Start plan upload operation ***
    ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}
    log to console   \n*** Wait plan upload operation success ***
    wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
    ...    ${upload_operation_info["action_id"]}    success
    log to console   \n*** Start plan fix error ***
    ${fix_err_operation}=   cu.fix_plan_validation_errors    ${upload_operation_info['plan_id']}
    ...   add_missing_objects=${True}   fix_mandatory_parameters=${True}
    sleep   60s
    log to console   \n*** Start plan validate operation ***
    ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
    log to console   \n*** Wait plan validate operation success ***
    wait until keyword succeeds    60s   5s  CU Check Plan Validate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
    log to console   \n*** Start plan activate operation ***
    ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
    run keyword if    ${wait_active}==${True}    log to console   \n*** Wait plan activate operation success in 5 mins ***
    run keyword if    ${wait_active}==${True}    wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success

vDU Load And Active SCF
    [Arguments]     ${path_of_commission_file}
    [Documentation]   load SCF and active SCF
    log to console   \n*** Start plan upload operation ***
    ${upload_plan_response}=  vdu.upload_plan    ${path_of_commission_file}
    wait until keyword succeeds  10s  1s
    ...    Upload Plan Operation Should Be Successful  ${upload_plan_response['action_id']}
    log to console   \n*** Start plan fix error ***
    ${fix_err_response}=   vdu.fix_vdu_staged_plan_error    ${upload_plan_response['plan_id']}
    wait until keyword succeeds  30s  10s  Fix vDU SCF Validation Errors Should Be Successful
    ...    ${upload_plan_response['plan_id']}  ${fix_err_response['action_id']}
    log to console   \n*** Start plan validate operation ***
    ${validate_plan_response}=  vdu.validate_plan   ${upload_plan_response['plan_id']}
    wait until keyword succeeds  10s  1s  Validate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${validate_plan_response['action_id']}
    log to console   \n*** Start plan activate operation ***
    ${activate_plan_response}=  vdu.activate_plan  ${upload_plan_response['plan_id']}
    wait until keyword succeeds  10m  20s  Activate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${activate_plan_response['id']}

CU Check Plan Upload Status Should Be As Expected
   [Arguments]  ${operation_id}   ${expected_status}
   [Documentation]   Check plan upload status should be as expected.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <16-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...    |  operation_id  | Yes. |  Operation id for uploading plan file  |
        ...    |  expected_status  | Yes. |  Expected upload status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Upload Status Should Be As Expected   |  a_6cfa594f-0938-4732-a78c-16afdbd214d2 |    success   |
   ${operation_response}=  cu.get_operation_state_of_uploading_plan    ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"

CU Check Plan Validate Status Should Be As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
   [Documentation]   Check plan validate status should be as expected.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <16-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...    |  plan_id  | Yes. |  Plan file id  |
        ...    |  operation_id  | Yes. |  Operation id for validating plan file  |
        ...    |  expected_status  | Yes. |  Expected validate status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Validate Status Should Be As Expected  |  sp_39d02514-e65b-46db-9ad7  |  a_0c7769bd-78ae-4505-9ce1 |  success  |
   ${operation_response}=  cu.get_operation_state_of_validating_plan     ${plan_id}    ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"

CU Check Plan Activate Status Should Be As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
   [Documentation]   Check plan activate status should be as expected.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <16-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...    |  plan_id  | Yes. |  Plan file id  |
        ...    |  operation_id  | Yes. |  Operation id for activating plan file  |
        ...    |  expected_status  | Yes. |  Expected activate status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Activate Status Should Be As Expected   |  sp_39d02514-e65b-46db-9ad7 |  o_c1ca0de5-3225-46e4-86bd  |  success  |
   ${operation_response}=  cu.get_operation_state_of_activating_plan    ${plan_id}   ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"

Fix vCU SCF Validation Errors Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    ${fix_err_response}=   vdu.get_fix_vdu_staged_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${fix_err_response['status']}  success
    log to console    Fix SCF Errors Success

Upload Plan Operation Should Be Successful
     [Arguments]  ${upload_action_id}
    [Documentation]   checking upload plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | upload_action_id | yes | upload action id, get from upload_plan |
    ...    *RETURN VALUE*
    ...    None
    ${upload_operation_response}=  vdu.get_upload_plan_operation_status  ${upload_action_id}
    should be equal as strings  ${upload_operation_response['status']}  success
    log to console    Upload Plan Success

Validate Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   checking validate plan operation status should be successful
    ${validate_plan_response}=  vdu.get_validate_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${validate_plan_response['status']}  success
    log to console    Validate Plan Success

Fix vDU SCF Validation Errors Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    ${fix_err_response}=   vdu.get_fix_vdu_staged_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${fix_err_response['status']}  success
    log to console    Fix SCF Errors Success


Activate Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   checking activate plan operation status should be successful
    ${activate_plan_response}=  vdu.get_activate_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${activate_plan_response['status']}  success
    log to console    Activate Plan Success


KW.Reset VDU
    [Arguments]     ${vdu_index}=0
    ${alias}   vDU Rest Login  vdu_index=${vdu_index}
    vdu.reset_vdu    timeout=180  vdu_connection=${alias}
#    ${out}   vdu.reset_vdu    timeout=180  vdu_connection=${alias}
#    ${error_msg}   set variable  ${out["error_message"]}
#    should contain  ${error_msg}   No error
    [Teardown]    Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}


KW.lock cell
    [Arguments]    ${cell_idx}=2    ${vdu_index}=0
    ${alias}   vDU Rest Login      vdu_index=${vdu_index}
    Run Keyword And Continue On Failure     vdu.block_cell    cell_id=${cell_idx}    vdu_connection=${alias}
    [Teardown]    Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}

VDU Collect Snapshot To Local
    [Arguments]  ${vdu_index}=0   ${compressed_or_not}=${False}   ${operation_timeout}=1200
    [Documentation]    VDU Collect Snapshot To Local
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   modified by:
    ...   <24-4-2023>, <r3li>, <check status before start save snapshot>
    ...   <25-6-2023>, <r3li>, <add operation_timeout parameter>
    ...   <20-7-2023>, <chris.l.cao>, <add timestamp parameter>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | local_snapshot_location | No | local_snapshot_location  |
    ...    | compressed_or_not | No | a zip file if True, unzip files if False |
    ...    | operation_timeout | No | default value is 1200 seconds  |
    ...    | timestamp         | No |  If ${True}, it will add timestamp as folder suffix, default is ${False} |
    ...
    ...    *RETURN VALUE*
    ...   path of local snapshot if compressed_or_not is ${False}, else a compressed file of snapshot
    ...
    ...    Example
    ...    | ${snapshot_file} | VDU Collect Snapshot To Local |
    ...    | ${out} | Get Specific Log File Name From Snapshot | snapshot_path=${snapshot_file} | log_file_name_keyword=rcplog |
    ...    | Should Be True | ${out.__len__()}==2 |
    ...
    ${alias}   vDU Rest Login  vdu_index=${vdu_index}
    Wait Until Keyword Succeeds  ${operation_timeout}   30s   VDU Snapshot Status Should Be Idle
    log to console  VDU Collect Snapshot To Local...
    ${local_snapshot_location}  set variable    ${LOG_PATH}/snapshot_log
    Create Directory    ${local_snapshot_location}
    ${snapshot_full_path}  vdu.Get_Local_Snapshot   directory=${local_snapshot_location}
    ...  compressed_or_not=${compressed_or_not}  operation_timeout=${operation_timeout}
    ${zip_file_name}    Run Keyword If    "${compressed_or_not}"=="${True}"    OperatingSystem.Run    ls ${local_snapshot_location}
    Return From Keyword If    "${compressed_or_not}"=="${True}"    ${local_snapshot_location}/${zip_file_name}
    [Return]  ${local_snapshot_location}
    [Teardown]   Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}

VDU Snapshot Status Should Be Idle
    [Documentation]   If snap status is not idle, save snapshot, otherwise do nothing.
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   history change: <date>,<who>,<what and how>
    ...   29.6.2023,rui.3.li@nokia-sbell.com, optimize keyword
    ...
    ...   | Input Parameters    | Man. | Description |
    ...	  | gnb_index    | no | gnb_index, default is 0 |
    ...	  | vdu_index    | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...  | _Set Operation Id In Disk File | operation_id_folder_name=/tmp/tmp_vdu_cran1 |
    ...  | operation_id_file_name=vdu_operation_id.txt | operation_id=MRBTS-108201_20220429-115532-357  |
    ...
    ${status}   vdu.Check_snapshot_status
    Return From Keyword If  '${status}'=='idle'
    ${snapshot_info}   vdu.get_snapshot_operations_information
    ${length}   Get Length    ${snapshot_info}
    Should Be Equal As Numbers    ${length}   ${1}
    ${operation_id}   Set Variable   ${snapshot_info}[0][operation_id]
    ${myvdupath_previous_snapshot}  set variable    ${LOG_PATH}/vdu_snapshot_teardown_previous
    Create Directory    ${vdu_snapshot_teardown_previous}
    vdu.check_local_snapshot_status_and_save_it    directory=${vdu_snapshot_teardown_previous}  operation_id=${operation_id}


Setup Suite
    robot_common_operations.Common Suite Setup
    CI_interface.Common Suite Setup
    log to console     Suite start
    Import Variables        ${CFGFILE_PATH}TLConfiguration.py
#    set suite variable      ${network_connectivity_mode}    ${TLCommonConfig_CB010678['network_connectivity_mode']}
#    set suite variable      ${vDU_SCF_PATH}  ${TLCommonConfig['vDU_SCF_PATH']}
#    set suite variable      ${vCU_SCF_PATH}  ${TLCommonConfig['vCU_SCF_PATH']}
    set suite variable      ${vDU_SCF_PATH}        ${CFGFILE_PATH}VDU_golden_scf.xml
    set suite variable      ${vCU_SCF_PATH}        ${CFGFILE_PATH}VCU_golden_scf.xml
    set suite variable      ${kuafu_dir}           ${TLCommonConfig_CB010678['kuafu_dir']}
    set suite variable      ${kuafu_dir_for_vCU}   ${TLCommonConfig_CB010678['kuafu_dir_for_vCU']}
    Conn.ResetCache


Teardown Suite
    TestSuite.Stop
    log to console     Suite teardown


Setup case
    robot_common_operations.Common Case Setup
    log to console     Case Start
    set test variable     ${vDU_CREATE_RESULT}   ${TLCommonConfig_CB010678['vDU_CREATE_RESULT']}
    set test variable     ${vDU_DELETE_RESULT}   ${TLCommonConfig_CB010678['vDU_DELETE_RESULT']}


Teardown case
    TestCase.Stop
    Run Keyword And Ignore Error    run    command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Collect snapshot if test failed
    run keyword if    '${TEST_STATUS}'=='FAIL'    vDU.collect syslog by kuafu
    Conn.ResetCache
    log to console     Case teardown
    CI_interface.Common Case Teardown

Setup case OAMASM
    log to console     Case Start
    set test variable     ${pod_name}   oamasm
    set test variable     ${container_name}   oamasm
    set test variable     ${process_name}     ASM
    set test variable     ${vDU_rest}   ${TLCommonConfig_CB010678['OAMASM']['vDU_rest']}
    set test variable     ${kill_signal}   ${TLCommonConfig_CB010678['OAMASM']['kill_signal']}
    set test variable     ${ministarter}   ${TLCommonConfig_CB010678['OAMASM']['ministarter']}
    set test variable     ${cell_status}   ${TLCommonConfig_CB010678['OAMASM']['cell_status']['ASM']}
Setup case AHM l1commproxy
    log to console     Case Start

    set test variable     ${pod_name}   ahm-a
    set test variable     ${container_name}   l1commproxy
    set test variable     ${process_name}     l1proxy
    set test variable     ${vDU_rest}   ${TLCommonConfig_CB010678['AHM']['vDU_rest']}
    set test variable     ${kill_signal}   ${TLCommonConfig_CB010678['AHM']['kill_signal']}
    set test variable     ${ministarter}   ${TLCommonConfig_CB010678['AHM']['ministarter']}
    set test variable     ${cell_status}   ${TLCommonConfig_CB010678['AHM']['cell_status']['L1COMMPROXY']}
Setup case OAMCM
    log to console     Case Start
    set test variable     ${pod_name}   oamcm
    set test variable     ${container_name}   oamcm
    set test variable     ${process_name}     OAMCM
    set test variable     ${vDU_rest}   ${TLCommonConfig_CB010678['OAMCM']['vDU_rest']}
    set test variable     ${kill_signal}   ${TLCommonConfig_CB010678['OAMCM']['kill_signal']}
    set test variable     ${ministarter}   ${TLCommonConfig_CB010678['OAMCM']['ministarter']}
    set test variable     ${cell_status}   ${TLCommonConfig_CB010678['OAMCM']['cell_status']['OAMCM']}

Setup case OAMCONFIG cpconfig
    log to console     Case Start
    set test variable     ${pod_name}         oamconfig
    set test variable     ${container_name}   oamconfig
    set test variable     ${process_name}     CPCONFIG
    set test variable     ${vDU_rest}   ${TLCommonConfig_CB010678['OAMCONFIG']['vDU_rest']}
    set test variable     ${kill_signal}   ${TLCommonConfig_CB010678['OAMCONFIG']['kill_signal']}
    set test variable     ${ministarter}   ${TLCommonConfig_CB010678['OAMCONFIG']['ministarter']}
    set test variable     ${cell_status}   ${TLCommonConfig_CB010678['OAMCONFIG']['cell_status']['CPCONFIG']}

Setup case OAMCONFIG trsconfig
    log to console     Case Start
    set test variable     ${pod_name}         oamconfig
    set test variable     ${container_name}   oamconfig
    set test variable     ${process_name}     TRSCONFIG
    set test variable     ${vDU_rest}   ${TLCommonConfig_CB010678['OAMCONFIG']['vDU_rest']}
    set test variable     ${kill_signal}   ${TLCommonConfig_CB010678['OAMCONFIG']['kill_signal']}
    set test variable     ${ministarter}   ${TLCommonConfig_CB010678['OAMCONFIG']['ministarter']}
    set test variable     ${cell_status}   ${TLCommonConfig_CB010678['OAMCONFIG']['cell_status']['TRSCONFIG']}

Setup case OAMCONFIG tas
    log to console     Case Start
    set test variable     ${pod_name}         oamconfig
    set test variable     ${container_name}   oamconfig
    set test variable     ${process_name}     TAS
    set test variable     ${vDU_rest}   ${TLCommonConfig_CB010678['OAMCONFIG']['vDU_rest']}
    set test variable     ${kill_signal}   ${TLCommonConfig_CB010678['OAMCONFIG']['kill_signal']}
    set test variable     ${ministarter}   ${TLCommonConfig_CB010678['OAMCONFIG']['ministarter']}
    set test variable     ${cell_status}   ${TLCommonConfig_CB010678['OAMCONFIG']['cell_status']['TAS']}

Setup case OAMCONFIG ims
    log to console     Case Start
    set test variable     ${pod_name}         oamconfig
    set test variable     ${container_name}   oamconfig
    set test variable     ${process_name}     IMS
    set test variable     ${vDU_rest}   ${TLCommonConfig_CB010678['OAMCONFIG']['vDU_rest']}
    set test variable     ${kill_signal}   ${TLCommonConfig_CB010678['OAMCONFIG']['kill_signal']}
    set test variable     ${ministarter}   ${TLCommonConfig_CB010678['OAMCONFIG']['ministarter']}
    set test variable     ${cell_status}   ${TLCommonConfig_CB010678['OAMCONFIG']['cell_status']['IMS']}

Setup case OAMEXT oamagent
    log to console     Case Start
    set test variable     ${pod_name}         oamext
    set test variable     ${container_name}   oamagent
    set test variable     ${process_name}     oamagent
    set test variable     ${vDU_rest}   ${TLCommonConfig_CB010678['OAMEXT']['vDU_rest']}
    set test variable     ${kill_signal}   ${TLCommonConfig_CB010678['OAMEXT']['kill_signal']}
    set test variable     ${ministarter}   ${TLCommonConfig_CB010678['OAMEXT']['ministarter']}
    set test variable     ${cell_status}   ${TLCommonConfig_CB010678['OAMEXT']['cell_status']['OAMAGENT']}

Setup case OAMBB
    log to console     Case Start
    set test variable     ${pod_name}         oambb
    set test variable     ${container_name}   oambb
    set test variable     ${process_name}     oambb
    set test variable     ${vDU_rest}   ${TLCommonConfig_CB010678['OAMBB']['vDU_rest']}
    set test variable     ${kill_signal}   ${TLCommonConfig_CB010678['OAMBB']['kill_signal']}
    set test variable     ${ministarter}   ${TLCommonConfig_CB010678['OAMBB']['ministarter']}
    set test variable     ${cell_status}   ${TLCommonConfig_CB010678['OAMBB']['cell_status']['OAMBB']}

Setup case L2RT
    log to console     Case Start
    set test variable     ${pod_name}         l2rt-a
    set test variable     ${container_name}   l2rt
    set test variable     ${process_name}     l2rt
    set test variable     ${vDU_rest}   ${TLCommonConfig_CB010678['L2RT']['vDU_rest']}
    set test variable     ${kill_signal}   ${TLCommonConfig_CB010678['L2RT']['kill_signal']}
    set test variable     ${ministarter}   ${TLCommonConfig_CB010678['L2RT']['ministarter']}
    set test variable     ${cell_status}   ${TLCommonConfig_CB010678['L2RT']['cell_status']['L2RT']}

Setup case L2HI
    log to console     Case Start
    set test variable     ${pod_name}         l2nrt
    set test variable     ${container_name}   l2hi
    set test variable     ${process_name}     l2hi
    set test variable     ${vDU_rest}   ${TLCommonConfig_CB010678['L2RT']['vDU_rest']}
    set test variable     ${kill_signal}   ${TLCommonConfig_CB010678['L2HI']['kill_signal']}
    set test variable     ${ministarter}   ${TLCommonConfig_CB010678['L2HI']['ministarter']}
    set test variable     ${cell_status}   ${TLCommonConfig_CB010678['L2HI']['cell_status']['L2HI']}
