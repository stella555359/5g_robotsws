*** Settings ***
Documentation     author:shuhui.lou
...               Group: HGZ_SG1
...               contact: shuhui.lou@nokia-sbell.com

Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource       ../../../../RAN_PZ_HAZ_34/Resources/AIC_BTS.robot

Resource       ../../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource       taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
#Resource       ../../../../RAN_BOAM_RD_OMUI/Resource/aic_common_vcu_resources.robot
Resource       ../../../../RAN_PZ_HAZ_34/Resources/cu_log_wireshark.robot
Library        taf.transport.ssh    WITH NAME    csn
Library        taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library        taf.gnb.oam.coam.cu    WITH NAME    vcu
Library        Process


*** Variables ***
${CU_8698_SCF}              /home/ute/SCF/CU_8698_SCF.xml
${DU_8698_SCF}              /home/ute/SCF/DU_8698_SCF.xml
${CU_8698_A_2_SCF}              /home/ute/SCF/CU_8698_A_2_SCF.xml
${DU_8698_A_2_SCF}              /home/ute/SCF/DU_8698_A_2_SCF.xml
${CU_8698_B_1_SCF}              /home/ute/SCF/CU_8698_B_1_SCF.xml
${DU_8698_B_1_SCF}              /home/ute/SCF/DU_8698_B_1_SCF.xml
${CU_8698_C_1_SCF}              /home/ute/SCF/CU_8698_C_1_SCF.xml
${DU_8698_C_1_SCF}              /home/ute/SCF/DU_8698_C_1_SCF.xml

${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${CFGFILE_PATH}             /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
${DeltaPath}                ${CURDIR}/CaseSCFDelta.py

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${ENB_WEBUI_IP}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENBWEBUI_URL}             https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${PA1_INFO}                  ${tl.attenuators[0]}
${PA2_INFO}                  ${tl.attenuators[1]}

${UE_TYPE}                   ${tl.ues[1].capabilities[-1]}

##################define these variable for convenient############################

########################END of alias Define#######################################

*** Keywords ***
TC.CB008698_A_2_Lower priority SA UE was released and higher priority UE admitted by cell level ue context preemption
    VRAN20.L3_CALL    UECFG=${TLCommonConfig['MultiUECFG']}  tl_name=${tl_name}  pod_abbr=${pod_abbr}  pacp_name=${pacp_name}
    ...    expression=ngap.procedureCode == 42 && ngap.radioNetwork == 46

TC.CB008698_C_1_Lower priority SA UE was released and higher priority UE admitted by cell level DRB preemption
    VRAN20.L3_CALL    UECFG=${TLCommonConfig['MultiUECFG']}   tl_name=${tl_name}   pod_abbr=${pod_abbr}
    ...    pacp_name=${pacp_name}   expression=ngap.procedureCode == 42 && ngap.radioNetwork == 46

TC.CB008698_B_1_Higher priority SA Inter gNB HO UE admitted by cell level ue context preemption
    VRAN20.L3_CALL_For_HO    UECFG=${TLCommonConfig_for_Handover['MultiUECFG']}  tl_name=${tl_name}  pod_abbr=${pod_abbr}
    ...    pacp_name=${pacp_name}   expression=ngap.procedureCode == 42 && ngap.radioNetwork == 46

TC.CB008698_D_9_Intra gNB HO SA UE is admitted by cell level DRB preemption
    Run Keyword And Continue On Failure     KW.Adjust PA To Default Value For CB008698
    Run Keyword And Continue On Failure    KW.Cloud Commission And Check On Air For CB008698_D_9
    set suite variable    ${UECFG}    ${TLCommonConfig_for_Handover['MultiUECFG']}
    Run Keyword And Continue On Failure    MultiUE.PrepareUE    UECFG=${UECFG}
    Run Keyword And Continue On Failure    KW.UE_Attach_With_DL_Traffic    UECFG=${UECFG}
    ...    ue_index=${UECFG['ue_index_for_call'][0]}   default_ue_index=${0}
    Run Keyword And Continue On Failure    KW.UE_Attach_With_DL_Traffic    UECFG=${UECFG}
    ...    ue_index=${UECFG['ue_index_for_call'][1]}   default_ue_index=${1}
    sleep  5s
    Run Keyword And Continue On Failure     KW.Adjust PA To Handover Value For CB008698
    sleep  15s
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl   ue_index=${0}    apn_address=dxdata1
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl   ue_index=${1}    apn_address=dxdata1
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${1}
    Run Keyword And Continue On Failure     wait until keyword succeeds   16min   2min    VRAN20.Check vCU PM Counter Result
    ...     measurement_id=55125     dist_name=${8698_D9_dist_name}    counter_id=M55125C11501    expected_value=1
    Run Keyword And Continue On Failure     KW.Adjust PA To Default Value For CB008698


####Case Level Keywords#####
VRAN20.Check vCU PM Counter Result
    [Arguments]   ${measurement_id}     ${dist_name}    ${counter_id}    ${expected_value}    ${gnb_index}=0    ${how_many}=1
    [Documentation]  For example: M55157C00003, measurement_id is 55157
    ...     CU Login is use cu_version=cuoam_19b, counter check will fail
    CU Login      gnb_index=${gnb_index}    cu_version=cuoam_21b
    ${res}=  cu.get_counter    measurement_id=${measurement_id}     dimension_dist_name=${dist_name}    counter_id=${counter_id}
    ${counter_values}=  set variable    ${res["values"]}
    ${num}=  get length   ${counter_values}
    ${expected_counter_values}=   set variable   ${counter_values[${num}-${how_many}:${num}]}
    ${flag}=   set variable   False
    FOR   ${counter_item}   IN   @{counter_values[${num}-${how_many}:${num}]}
          ${flag}=   set variable if  ${counter_item['value']}>=${expected_value}   True
          exit for loop if    ${counter_item['value']}>=${expected_value}
          should be equal    ${flag}  True   Check counter value failed!
    END
    [Teardown]   CU Logout

VRAN20.L3_CALL
    [Arguments]   ${expression}    ${UECFG}=NULL   ${gnb_index}=0    ${tl_name}=tl1126      ${pod_abbr}=cpif
    ...      ${pacp_name}=1126_Case_A2_cpif.pcap    ${default_ue_index}=0
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    Run Keyword And Continue On Failure    VRAN20.Start to collect the tcpdump log on CU   gnb_index= ${gnb_index}
    ...    tl_name=${tl_name}    pod_abbr=${pod_abbr}   ctr_abbr=${ctr_abbr}  pacp_name=${pacp_name}
    set suite variable    ${UECFG}    ${UECFG}
    MultiUE.PrepareUE    UECFG=${UECFG}
    MultiUE.Detach       UECFG=${UECFG}
    Log To Console   start to attach first SA UE
    Run Keyword And Continue On Failure    Single_UE.AttachAndStartDLULTrafficAndCheck_tput    UECFG=${UECFG}
    ...    ue_index=${UECFG['ue_index_for_call'][0]}   default_ue_index=${UECFG['ue_index_for_call'][0]}
    sleep  3s
    Log To Console   start to attach second SA UE
    Run Keyword And Continue On Failure    Single_UE.AttachAndStartDLULTrafficAndCheck_tput    UECFG=${UECFG}
    ...    ue_index=${UECFG['ue_index_for_call'][1]}   default_ue_index=${UECFG['ue_index_for_call'][1]}
    Run Keyword And Continue On Failure    VRAN20.Stop and download tcpdump Logs on CU
    ...   tl_name=${tl_name}    pod_abbr=${pod_abbr}   ctr_abbr=${ctr_abbr}   pacp_name=${pacp_name}
    run keyword and ignore error    MultiUE.StopDLTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
    run keyword and ignore error    MultiUE.Detach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    KW.Wireshark Analyse result    filename=${pacp_name}   expression=${expression}

VRAN20.L3_CALL_For_HO
    [Arguments]   ${expression}    ${UECFG}=NULL   ${gnb_index}=0    ${tl_name}=tl1126      ${pod_abbr}=cpif
     ...    ${pacp_name}=1126_Case_A6_cpif.pcap    ${default_ue_index}=0
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    Run Keyword And Continue On Failure    VRAN20.Start to collect the tcpdump log on CU   gnb_index= ${gnb_index}
    ...    tl_name=${tl_name}    pod_abbr=${pod_abbr}   ctr_abbr=${ctr_abbr}  pacp_name=${pacp_name}
    set suite variable    ${UECFG}    ${UECFG}
    MultiUE.PrepareUE    UECFG=${UECFG}
    MultiUE.Detach       UECFG=${UECFG}
    Log To Console   start to attach first SA UE
    Run Keyword And Continue On Failure    KW.UE_Attach_With_DL_Traffic    UECFG=${UECFG}
    ...    ue_index=${UECFG['ue_index_for_call'][0]}   default_ue_index=${0}
    sleep  3s
    Adjust Attenuation Ports for second UE
    Log To Console   start to attach second SA UE
    Run Keyword And Continue On Failure    KW.UE_Attach_With_DL_Traffic    UECFG=${UECFG}
    ...    ue_index=${UECFG['ue_index_for_call'][1]}   default_ue_index=${1}
    Run Keyword And Continue On Failure    Adjust PA To Handover Value
#    Run Keyword And Continue On Failure    Check UE2 Handover successful   ue_index=${UECFG['ue_index_for_call'][1]}
    Run Keyword And Continue On Failure    VRAN20.Stop and download tcpdump Logs on CU
    ...   tl_name=${tl_name}    pod_abbr=${pod_abbr}   ctr_abbr=${ctr_abbr}   pacp_name=${pacp_name}
    run keyword and ignore error    MultiUE.StopDLTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
    run keyword and ignore error    MultiUE.Detach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
#    Run Keyword And Continue On Failure    Single_UE.Stop_traffic_and_Detach  UECFG=${UECFG}
#    ...    ue_index=${UECFG['ue_index_for_call'][0]}    default_ue_index=${0}
    Run Keyword And Continue On Failure    KW.Wireshark Analyse result    filename=${pacp_name}   expression=${expression}


Check UE2 Handover successful
    [Arguments]       ${ue_index}=0
    ${output}   Get Param Value on Spark   param=NR PCI   ue_index=${ue_index}   ue_alias=UE_${ue_index}
    Run Keyword If   ${output} == ${PCI_for_UE1}    Log To Console   UE2 Handover successful.

KW.UE_Attach_With_DL_Traffic
    [Arguments]    ${UECFG}=NULL    ${ue_index}=0   ${default_ue_index}=0
    Log To Console   start to UE attach
    Run Keyword And Continue On Failure    Single_UE.Attach     UECFG=${UECFG}    ue_index=${ue_index}   default_ue_index=${default_ue_index}
#    FOR    ${i}     IN RANGE   5
#        Log To Console   Try to attch to correct Cell for ${i}time(s)
#        Run Keyword And Continue On Failure    Single_UE.Attach     UECFG=${UECFG}    ue_index=${ue_index}   default_ue_index=${default_ue_index}
#        sleep    5s
#        ${output}   Get Param Value on Spark   param=NR PCI   ue_index=${ue_index}   ue_alias=UE_${ue_index}
#        Run Keyword If   ${output} == ${PCI_for_UE${ue_index}}    Exit For Loop
#        ...   ELSE      Single_UE.Dttach    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
#        ...    power_reset=${UECFG['${ue_index}']['power_reset']}
#    END
    Run Keyword And Continue On Failure   Single_UE.StartDLTraffic    UECFG=${UECFG}  ue_index=${ue_index}   default_ue_index=${default_ue_index}
    #Run Keyword And Continue On Failure   Single_UE.StartULTraffic    UECFG=${UECFG}  ue_index=${ue_index}   default_ue_index=${default_ue_index}
    sleep    15s
#    Log To Console   start to check UE Thoughput
#    Run Keyword And Continue On Failure    MultiUE._CheckOneUEThoughput    UECFG=${UECFG}  ue_index=${ue_index}    ue_index=${ue_index}
#    ...    check_tput_on_ue=${UECFG['${ue_index}']['check_tput_on_ue']}


Get Param Value on Spark
    [Arguments]       ${ue_index}=${0}    ${param}=[]   ${ue_alias}=UE_${ue_index}
    [Documentation]     Prepare UE for L3 call test.
    ...  :param   ue_alias: <str> store ue by ue_alias
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    ${param_value}    spark.get_parm_value_on_ue    param=${param}   ue_alias=${ue_alias}
    [Return]    ${param_value}

Adjust PA To Handover Value
    [Arguments]
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_3']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for RU1 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_1']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU2 default value.


Adjust Attenuation Ports for second UE
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_3']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for RU1 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for RU1 default value.

VRAN20.Start to collect the tcpdump log on CU
    [Arguments]     ${gnb_index}=0    ${tl_name}=tl1126    ${pod_abbr}=cpif    ${ctr_abbr}=ctr-tl1126-cpif
    ...   ${pacp_name}=1126_Case_A6_cpif.pcap
    [Teardown]  Run Keyword If   "${real_alias}"=="${EMPTY}"  Run Keyword And Ignore Error   Disconnect Interactive Connection
    ...   alias=${real_alias}
    [Documentation]    Connect to cloud CU OAM VM. addr, username, password are from testline_configuration.
    ${real_alias}   cloud_cu.Connect To CU Node    pod_abbr=${pod_abbr}
    ${container_id}   Get CU Container ID   pod_abbr=${pod_abbr}  ctr_abbr=${ctr_abbr}  alias=${real_alias}
    ${ssh_command}   Set Variable   sudo crictl inspect --output yaml ${container_id}| grep 'pid:'|awk -F ':' '{print $2}'
    ${out}  issh.Execute  command=${ssh_command}  alias=${real_alias}
    ${out}  Strip Prompt  ${out}
    ${pid}  Set Variable  ${out.strip()}
    ${cmd}  Set Variable  tcpdump -i any -s 0 -w ./${pacp_name}
    Log To Console   start container tcpdump
    #start capture
    ${full_cmd}   set variable  sudo nsenter -r -n -t ${pid} ${cmd}
    Log To Console   ${full_cmd}
    issh.Execute_Bare   command=${full_cmd}   alias=${real_alias}
    ${out}   Send ENTER Interactively VCU CNF  alias=${real_alias}
    Sleep   2s

VRAN20.Stop and download tcpdump Logs on CU
    [Arguments]    ${gnb_index}=0    ${tl_name}=tl1126  ${pod_abbr}=cpif  ${ctr_abbr}=ctr-tl1126-cpif
    ...   ${pacp_name}=111126_Case_A6_cpif.pcap
    ${local_file}  Set Variable   /var/home/core/${pacp_name}
    ${remote_file}   Set Variable  /var/home/core/${tl_name}/
    ${real_alias}   cloud_cu.Connect To CU Node    pod_abbr=${pod_abbr}
    ${out}    issh.Execute   command=sudo ps -ef|grep nsenter|grep -v grep|grep ${pacp_name} |awk '{print $2}'   alias=${real_alias}
    ${out}  Strip Prompt  ${out}
    ${tcpdump_ID}   Set Variable  ${out.strip()}
#    @{tcpdump_ID_tmp}   Split String	   ${tcpdump_ID}   separator=\r\n
#    ${tcpdump_ID}  Set Variable   @{tcpdump_ID_tmp}[1]
    issh.Execute   command=sudo kill ${tcpdump_ID}     alias=${real_alias}
    Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${real_alias}
    ${alias}    Do vCU SSH Login   gnb_index=${gnb_index}
    ${Namespace}  Get CU Namespace From Testline  ${gnb_index}
    ${full_pod_name}  ssh.execute  kubectl get pods -n ${Namespace}|egrep -w "${pod_abbr}" |awk '{print $1}'     connection=${alias}
    ${nodeName}  ssh.execute  command=kubectl get pod ${full_pod_name.strip()} -o yaml -n ${Namespace}|grep nodeName | awk '{print $2}'
    ...    connection=${alias}
    ssh.Execute   scp ${nodeName.strip()}:${local_file} ${remote_file}     connection=${alias}
    Wireshark.DownloadLogToUTE   log_dir=${remote_file}  filename=${pacp_name}  connection=${alias}
    Do vCU SSH Logout    alias=${alias}

Single_UE.AttachAndStartDLULTrafficAndCheck_tput
    [Arguments]    ${UECFG}=NULL    ${ue_index}=0   ${default_ue_index}=0
    Log To Console   start to UE attach
    Run Keyword And Continue On Failure    Single_UE.Attach     UECFG=${UECFG}    ue_index=${ue_index}   default_ue_index=${default_ue_index}
    sleep    5s
    ${res}  run keyword and ignore error   power_ue.Verify attach
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    4G_check=False    5Grach_ed=${res[1]}
    Run Keyword And Continue On Failure   Single_UE.StartDLTraffic    UECFG=${UECFG}  ue_index=${ue_index}   default_ue_index=${default_ue_index}
    #Run Keyword And Continue On Failure   Single_UE.StartULTraffic    UECFG=${UECFG}  ue_index=${ue_index}   default_ue_index=${default_ue_index}
    sleep    5s
#    Log To Console   start to check UE Thoughput
#    Run Keyword And Continue On Failure    MultiUE._CheckOneUEThoughput    UECFG=${UECFG}  ue_index=${ue_index}    ue_index=${ue_index}
#    ...    check_tput_on_ue=${UECFG['${ue_index}']['check_tput_on_ue']}


Single_UE.Attach
    [Arguments]    ${UECFG}=NULL    ${ue_index}=0   ${default_ue_index}=0
        ${res}  run keyword and ignore error   power_ue.UE Attach
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
        ...    power_reset=${UECFG['${ue_index}']['power_reset']}

Single_UE.Dttach
    [Arguments]    ${UECFG}=NULL    ${ue_index}=0   ${power_reset}=true
    ${res}  run keyword and ignore error  power_ue.UE Detach
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    power_reset=${UECFG['${ue_index}']['power_reset']}

Single_UE.StartDLTraffic
    [Arguments]    ${UECFG}=NULL    ${ue_index}=0   ${default_ue_index}=0   ${protocol}=udp
        ${duration}    Evaluate    ${UECFG['${ue_index}']['check_throughput_duration']}+${UEnum}*600
        ${throughput for DL}=    Run Keyword If   '${tl.ues[${ue_index}].capabilities[-1].count('spark')}'=='0'
        ...    Set Variable if    '${tl.ues[${ue_index}].capabilities[-1].count('lte')}'=='0'
        ...    ${UECFG['${ue_index}']['dl']['target_throughput']}M    ${UECFG['${ue_index}']['dl']['target_throughput']}
        ...    ELSE
        ...    Set Variable    ${UECFG['${ue_index}']['dl']['target_throughput']}Mbps/sec
        Run Keyword And Continue On Failure   power_ue.Start traffic
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=dl
        ...    throughput=${throughput for DL}
        ...    duration=${duration}
        ...    apn_address=${UECFG['${ue_index}']['apn']}
        ...    ue_mode=${UECFG['${ue_index}']['ue_mode']}
        ...    iperf_port=${UECFG['${ue_index}']['iperf_port']}
        ...    multidrb_QoS_dest=${UECFG['${ue_index}']['multidrb_QoS_dest']}
        ...    iperf_type=${UECFG['${ue_index}']['iperf_type']}
        ...    protocol=${UECFG['${ue_index}']['protocol']}

Single_UE.StartULTraffic
    [Arguments]    ${UECFG}=NULL    ${ue_index}=0    ${default_ue_index}=0  ${protocol}=udp
        run keyword if  '${UECFG['${ue_index}']['ul']['target_throughput']}'=='0'   Continue For Loop
        ${duration}    Evaluate    ${UECFG['${ue_index}']['check_throughput_duration']}+${UEnum}*600
        ${throughput for UL}    Set Variable if  ${tl.ues[${ue_index}].capabilities[-1].count('lte')}==0
        ...   ${UECFG['${ue_index}']['ul']['target_throughput']}Mbps/sec   ${UECFG['${ue_index}']['ul']['target_throughput']}
        Run Keyword And Continue On Failure   power_ue.Start traffic
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=ul
        ...    throughput=${throughput for UL}
        ...    duration=${duration}
        ...    apn_address=${UECFG['${ue_index}']['apn']}
        ...    ue_mode=${UECFG['${ue_index}']['ue_mode']}
        ...    iperf_port=${UECFG['${ue_index}']['iperf_port']}
        ...    multidrb_QoS_dest=${UECFG['${ue_index}']['multidrb_QoS_dest']}
        ...    iperf_type=${UECFG['${ue_index}']['iperf_type']}

Single_UE.StopDLTraffic
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
        Run Keyword And Continue On Failure   power_ue.Stop traffic
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=dl
        ...    apn_address=${UECFG['${ue_index}']['apn']}
        ...    ue_mode=${UECFG['${ue_index}']['ue_mode']}
        ...    iperf_port=${UECFG['${ue_index}']['iperf_port']}


Single_UE.StopULTraffic
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
        Run Keyword And Continue On Failure   power_ue.Stop traffic
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=ul
        ...    apn_address=${UECFG['${ue_index}']['apn']}
        ...    ue_mode=${UECFG['${ue_index}']['ue_mode']}
        ...    iperf_port=${UECFG['${ue_index}']['iperf_port']}

Single_UE.Stop_traffic_and_Detach
    [Arguments]    ${UECFG}=NULL    ${ue_index}=0   ${default_ue_index}=0
    UE.One_UE_Stop_traffic_and_Detach
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
        ...    apn_address=${UECFG['${ue_index}']['apn']}
        ...    ue_mode=${UECFG['${ue_index}']['ue_mode']}
        ...    iperf_port=${UECFG['${ue_index}']['iperf_port']}
        ...    power_reset=${UECFG['${ue_index}']['power_reset']}
    Sleep   2s

KW.Wireshark Analyse result
    [Arguments]    ${filename}   ${expression}
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=ngap
    Run Keyword And Continue On Failure    Wireshark.CheckExpression    expression=${expression}


Do vCU SSH Login
    [Arguments]   ${gnb_index}=0    ${alias}=default
    ${ip}=    Get vCU SSH IPv4 Address    ${gnb_index}
    ${username}=    Get vCU SSH Username    ${gnb_index}
    ${password}=    Get vCU SSH Password    ${gnb_index}
        ${prompt}  set variable   \\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt}  set variable   ${prompt}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt}  Set Variable  ${prompt}|\\[core@\\S+\\s\\S+\\]\\$

    ${alias}=  get unique id
    ssh.connect_to     hostname=${ip}   username=${username}     password=${password}     alias=${alias}
    [Return]  ${alias}

Do vCU SSH Logout
    [Arguments]    ${alias}=${None}
    Run Keyword And Ignore Error    ssh.disconnect    connection=${alias}


Get vCU SSH IPv4 Address
    [Arguments]   ${gnb_index}=0
    [Return]    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}

Get vCU SSH Username
    [Arguments]   ${gnb_index}=0
    [Return]    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}

Get vCU SSH Password
    [Arguments]   ${gnb_index}=0
    [Return]    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}



VCU Get Current Plan File
    [Arguments]  ${gnb_index}=0   ${log_dir}=/tmp    ${vcu_scf_backup_name}=vcu_scf_backup_name
    [Documentation]    This keyword is to save vcu plan file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the path to save scf file |
    ...    | ${scf_backup_name} | Yes | the name for saved scf file,eg. before_suite_vcu_scf.xml |
    ...    | ${gnb_index} | No | gnb index, the default value is 0 |
    ...
    ...    Examples:
    ...    | ${vcu_scf_file} | VCU Get Current Plan File | ${output_dir} | before_suite_vcu_scf.xml |
    #VCU Login    ${gnb_index}
    CU Login     gnb_index=${gnb_index}
    vcu.get_current_plan_file    ${log_dir}//${vcu_scf_backup_name}.xml
    ${vcu_scf_file_path}    Set Variable    ${log_dir}//${vcu_scf_backup_name}.xml
    #[Teardown]    Run Keyword And Ignore Error    VCU Logout
    [Teardown]    Run Keyword And Ignore Error    CU Logout
    [Return]    ${vcu_scf_file_path}

VDU Get Current Plan File
    [Arguments]    ${gnb_index}=0   ${log_dir}=/tmp  ${vdu_scf_backup_name}=vdu_scf_backup_name
    vDU Login
    ${vdu_scf_file_path}   vdu.get_current_plan_file    local_dir_path=${log_dir}   filename=${vdu_scf_backup_name}.xml
    Set suite Variable   ${vdu_scf_file_path}
    [Teardown]    Run Keyword And Ignore Error   vDU Logout


VCU Login
    [Arguments]    ${gnb_index}=0    ${alias}=${None}    ${restapi_version}=cuoam_21b    ${delay}=${EMPTY}
    [Documentation]    Create rest session to CU.
    ...    Example
    ...    |    CU Rest Login    |    |
    ...    |    CU Rest Login    |    delay=3    |
    Run Keyword And Ignore Error    VCU Logout
    vcu.Connect To    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.port}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    cu_version=${restapi_version}
    ...    secure=${true}
    ...    alias=${alias}
    ...    timeout=120
    Run Keyword If    "${delay}"!="${EMPTY}"    Sleep    ${delay}

VCU Logout
    [Arguments]    ${connection}=${none}
    [Documentation]    Teardown rest session to CU.
    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |
    ...    Example
    ...    |    CU Rest Logout |    |
    vcu.Disconnect    connection=${connection}


Send ENTER Interactively VCU CNF
    [Arguments]  ${alias}=default
    [Documentation]    it sends ENTER key
    ...    within current active ssh connection. it should be used
    ...    Example
    ...    | Send ENTER Interactively VCU CNF | alias=default |
    ${enter}    Evaluate    chr(int(13))
    ${out}   issh.Execute_Bare   command=${enter}     alias=${alias}
    Sleep    2s
    [Return]  ${out}


Disconnect Interactive Connection
    [Arguments]  ${alias}=default
    [Documentation]   Disconnect Interactive Connection for specifical connection identified by alias name
    ...   *Author*:chris.l.cao@nokia-sbell.com
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To K8s Master Interactively |
    ...    | ${out} | issh.Execute | command=pwd |
    ...    | Disconnect Interactive Connection |
    ...
    ...    | Connect To K8s Master Interactively | alias=alias2 |
    ...    | ${out} | issh.Execute | command=pwd | alias=alias2 |
    ...    | Disconnect Interactive Connection | alias=alias2 |
    ...
    should not be empty   ${alias}

    Run Keyword And Ignore Error   _Exit Container If Necessary   alias=${alias}
    issh.disconnect  alias=${alias}

_Exit Container If Necessary
    [Arguments]  ${alias}
    [Documentation]   _Exit Container If Necessary
    ...    *Author*:chris.l.cao@nokia-sbell.com
    ${r}  ${cur_prompt}=    Run Keyword And Ignore Error   issh.get_prompt   alias=${alias}
    Return From Keyword If    '${r}'=='FAIL'
    ${expr_vdu_admin}    Set Variable   "${cur_prompt}"!="${VDU_OE_SERVER_PROMPT}|${VDU_CONTAINER_PROMPT}|${VDU_CONTAINER_PROMPT_ROOT}"
    ${expr_vdu_tenant}   Set Variable   "${cur_prompt}"!="${VDU_OE_SERVER_PROMPT_TENANT}|${VDU_CONTAINER_PROMPT}|${VDU_CONTAINER_PROMPT_ROOT}"
    ${expr_vcu_tenant}   Set Variable   "${cur_prompt}"!="${VCU_OE_SERVER_PROMPT_TENANT}|${VCU_CONTAINER_PROMPT}"
    Return From Keyword If   ${expr_vdu_admin} and ${expr_vdu_tenant} and ${expr_vcu_tenant}
    ${out}    issh.Execute   command=ls  check_result=${False}  alias=${alias}
    ${match}  Get Regexp Matches  ${out}   ${VDU_CONTAINER_PROMPT}|${VDU_CONTAINER_PROMPT_ROOT}|${VCU_CONTAINER_PROMPT}
    ${out}    Run Keyword If   ${match.__len__()}>0    issh.Execute   command=exit  check_result=${False}  alias=${alias}

VRAN20.Judge Whether The Parameter Needs To Be Modified
    [Arguments]    ${mo_dn}    ${mo_parameter_dict}
    [Documentation]    Judge Whether The Parameter Needs To Be Modified
    ...    Author: mengli yang
    ...    Example
    ...    | Judge Whether The Parameter Needs To Be Modified |
    ...    | ${mo} |  set variable |  MRBTS-5460/NRBTS-5460/NRDU-1 |
    ...    | ${mo_parameter_dict} | create dictionary | drxProfile1/0/drxInactivityTimer=MRBTS-5460/NRBTS-5460/NRCELL-1 |
    ...
    vDU Login By Rest
    &{parameter_dict}    Create Dictionary
    FOR    ${para_name}    IN    @{mo_parameter_dict}
        ${value}=    cloud_vdu.Online Get VDU Parameter Value     ${mo_dn}    ${para_name}
        run keyword if    "${value}" != "${mo_parameter_dict}[${para_name}]"
        ...    Set to Dictionary    ${parameter_dict}    ${para_name}    ${value}
    END
    [Return]    &{parameter_dict}
    [Teardown]    vDU Logout By Rest    vdu_index=0


TL_Backup_SCF_and_Commission_Case_SCF
    [Arguments]     ${CU_SCF}=${CU_8698_SCF}   ${DU_SCF}=${DU_8698_SCF}
#    log to console  start to backup CU and DU SCF
#    Run Keyword And Continue On Failure    VCU Get Current Plan File    log_dir=${LOG_PATH}  vcu_scf_backup_name=vcu_scf_backup_name
#    sleep   5s
#    Run Keyword And Continue On Failure    VDU Get Current Plan File    log_dir=${LOG_PATH}   vdu_scf_backup_name=vdu_scf_backup_name
    Run Keyword And Continue On Failure    TL_Full_Commission    CU_SCF=${CU_SCF}   DU_SCF=${DU_SCF}
    sleep    1min
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair

TL_Full_Commission
    [Arguments]   ${CU_SCF}=NULL   ${DU_SCF}=NULL
    sleep   5s
    log to console  start to commsion
    CU Full Commission for 8698           path_of_commission_file=${CU_SCF}
    vDU Full Commission SCF Fix Error     path_of_commission_file=${DU_SCF}

CU Full Commission for 8698
    [Arguments]    ${path_of_commission_file}    ${gnb_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vCU commission ***
    CU Login  ${gnb_index}
    VRAN20.vCU Load And Active SCF   ${path_of_commission_file}
    [Teardown]    run keyword and ignore error   CU Logout

VRAN20.vCU Load And Active SCF
    [Arguments]     ${path_of_commission_file}    ${wait_active}=${True}
    log to console   \n*** Start plan upload operation ***
    ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}
    log to console   \n*** Wait plan upload operation success ***
    wait until keyword succeeds    60s   5s  cloud_cu.CU Check Plan Upload Status Should Be As Expected
    ...    ${upload_operation_info["action_id"]}    success
    log to console   \n*** Start plan fix error ***
    ${fix_err_operation}=   cu.fix_plan_validation_errors    ${upload_operation_info['plan_id']}
    ...   add_missing_objects=${True}   fix_mandatory_parameters=${True}
    sleep   60s
    log to console   \n*** Start plan validate operation ***
    ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
    log to console   \n*** Wait plan validate operation success ***
    wait until keyword succeeds    60s   5s  cloud_cu.CU Check Plan Validate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
    log to console   \n*** Start plan activate operation ***
    ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
    run keyword if    ${wait_active}==${True}    log to console   \n*** Wait plan activate operation success in 5 mins ***
    run keyword if    ${wait_active}==${True}    wait until keyword succeeds    600s   30s
    ...    cloud_cu.CU Check Plan Activate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success

TL_Full_Commission_and_check_onair
    Run Keyword And Continue On Failure    TL_Full_Commission
    ...    CU_SCF=${LOG_PATH}/vcu_scf_backup_name.xml   DU_SCF=${LOG_PATH}/vdu_scf_backup_name.xml
    sleep    1min
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair

Backup SCF and Online Set vDU Parameters
    [Arguments]    ${MRBTS_ID}=10550    ${NRBTS_ID}=10550   ${case_parameters_list}=@{case_parameters_list}
     ...    ${mo_dn_BTS}=null  ${mo_dn_CELL}=null
    log to console  start to backup CU and DU SCF
    Run Keyword And Continue On Failure    VCU Get Current Plan File    log_dir=${LOG_PATH}  vcu_scf_backup_name=vcu_scf_backup_name
    sleep   5s
    Run Keyword And Continue On Failure    VDU Get Current Plan File    log_dir=${LOG_PATH}   vdu_scf_backup_name=vdu_scf_backup_name
    Run Keyword And Continue On Failure    VRAN20.Set case Parameter on CU and DU    case_parameters_list=@{case_parameters_list}
    ...    mo_dn_CELL=${mo_dn_CELL}  mo_dn_BTS=${mo_dn_BTS}

check Parameter on CU and DU for CB008698_A_2
    [Arguments]    ${MRBTS_ID}=10550    ${NRBTS_ID}=10550  ${NRCELL_ID}=NRCELL-1  ${parameter_dict}=NULL  #${mo_parameter}=null  ${value}=1
    ${CU_modify_parameter}    Run Keyword And Continue On Failure     VRAN20.CU Get Single Parameter Value
     ...    parameter_dict=${parameter_dict}   mo_dn=${mo_dn}  mo_parameter=${mo_parameter}  value=${value}
    ${DU_modify_parameter}    Run Keyword And Continue On Failure     VRAN20.DU Get Single Parameter Value
     ...    mo_parameter=${mo_parameter}  value=${value}   mo_dn=${mo_dn}
    Run keyword if  "${CU_modify_parameter}" == "True" or "${DU_modify_parameter}" == "True"   set test variable  ${need_commssion}   True
     ...    ELSE    set test variable  ${need_commssion}   False
    [Return]    ${need_commssion}

VRAN20.check case Parameter on CU and DU
    [Arguments]     ${case_parameters_list}=@{case_parameters_list}  ${mo_dn_CELL}=null  ${mo_dn_BTS}=null
    #@{case_parameters_list}    create list     @{CASE_INPUT_CB008698['CB008698_C_1']['case_parameters']}
    &{parameter_dict_CU}    Create Dictionary
    &{parameter_dict_DU}    Create Dictionary

    ${len}    Get Length    ${case_parameters_list}
    FOR  ${i}    IN RANGE    ${len}
        ${case_parameters}    Set Variable    ${case_parameters_list}[${i}]
        ${mo_parameter}       Set Variable    ${case_parameters}[0]
        ${value}              Set Variable    ${case_parameters}[1]
        ${checkpoint}         Set Variable    ${case_parameters}[2]
        ${par_level}          Set Variable    ${case_parameters}[3]
        Run keyword if      "${par_level}" == "Cell_Level"     Set suite Variable   ${mo_dn}    ${mo_dn_CELL}
        ...    ELSE IF      "${par_level}" == "BTS_Level"      Set suite Variable   ${mo_dn}    ${mo_dn_BTS}
        ${need_commssion}    Run Keyword And Continue On Failure     VRAN20.check per_case parameter on CU and DU
        ...    mo_parameter=${mo_parameter}    value=${value}   checkpoint=${checkpoint}   mo_dn=${mo_dn}
        Run keyword if      "${need_commssion}" == "True"   Exit For Loop
        ...    ELSE     Continue For Loop
    END

    [Return]    ${need_commssion}
add to dictionary
    [Arguments]  ${parameter_dict_CU}=null  ${parameter_dict_DU}=null   ${case_parameters}=1   ${case_value}=1
        Set to dictionary   ${parameter_dict_CU}  ${case_parameters}   ${case_value}
        Set to dictionary   ${parameter_dict_DU}  ${case_parameters}   ${case_value}
VRAN20.check per_case parameter on CU and DU
    [Arguments]    ${checkpoint}=BOTH   ${MRBTS_ID}=10550    ${NRBTS_ID}=10550    ${mo_parameter}=null  ${value}=1  ${mo_dn}=null
    #${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${need_commssion}  Run keyword if  "${checkpoint}" == "BOTH"   VRAN20.check Parameter on CU and DU
    ...    mo_parameter=${mo_parameter}  value=${value}    mo_dn=${mo_dn}
    ...    ELSE IF   "${checkpoint}" == "CU"  VRAN20.CU Get Single Parameter Value
    ...    mo_parameter=${mo_parameter}  value=${value}   mo_dn=${mo_dn}
    ...    ELSE   "${checkpoint}" == "DU"  VRAN20.DU Get Single Parameter Value
    ...    mo_parameter=${mo_parameter}  value=${value}   mo_dn=${mo_dn}
    [Return]    ${need_commssion}

VRAN20.check Parameter on CU and DU
    [Arguments]    ${MRBTS_ID}=10550    ${NRBTS_ID}=10550   ${mo_parameter}=null    ${value}=1   ${mo_dn}=null
    ${need_commssion}  Run Keyword And Continue On Failure   vran20.CU Get Single Parameter Value
     ...      mo_parameter=${mo_parameter}  value=${value}   mo_dn=${mo_dn}
    ${need_commssion}  Run keyword if   ${need_commssion} != True     vran20.DU Get Single Parameter Value
     ...    mo_parameter=${mo_parameter}  value=${value}   mo_dn=${mo_dn}
     ...    ELSE    Exit For Loop
#    Run keyword if  ${CU_modify_parameter} == True or ${DU_modify_parameter} == True   set suite variable  ${need_commssion}   True
#     ...    ELSE    set suite variable  ${need_commssion}   False
    [Return]    ${need_commssion}

VRAN20.DU Get Single Parameter Value
    [Arguments]    ${gnb_index}=0   ${mo_dn}=null   ${mo_parameter}=null  ${value}=1  ${parameter_dict_DU}=NULL
    [Documentation]    Judge Whether The Parameter Needs To Be Modified
    ...    Author: mengli yang
    ...    Example
    ...    | Judge Whether The Parameter Needs To Be Modified |
    ...    | ${mo} |  set variable |  MRBTS-5460/NRBTS-5460/NRDU-1 |
    ...    | ${mo_parameter_dict} | create dictionary | drxProfile1/0/drxInactivityTimer=MRBTS-5460/NRBTS-5460/NRCELL-1 |
    ...
    vDU Login By Rest
    &{parameter_dict}    Create Dictionary   ${mo_parameter}=${value}
    FOR    ${para_name}    IN    @{parameter_dict}
        ${para_value}    cloud_vdu.Online Get VDU Parameter Value     mo_dn=${mo_dn}    para_name=${para_name}
        run keyword if    "${para_value}" != "${parameter_dict}[${mo_parameter}]"
        ...    run keywords        set suite variable  ${DU_modify_parameter}  True
        ...    AND   log to console  The current value of ${mo_parameter} on DU is ${para_value} and the expect value is ${value}.
        ...    AND   log to console  The parameter need to be modified.
        ...    ELSE   run keywords       set suite variable  ${DU_modify_parameter}   False
        ...    AND   log to console  The current value of ${mo_parameter} on DU is ${para_value} and the expect value is ${value}.
        ...    AND   log to console  The parameter do not need to be modified.
    END
    Run keyword if  ${DU_modify_parameter} == True   set suite variable  ${need_commssion}   True
     ...    ELSE    set suite variable  ${need_commssion}   False
    [Return]    ${need_commssion}
    [Teardown]    vDU Logout By Rest    vdu_index=0

VRAN20.CU Get Single Parameter Value
   [Arguments]     ${gnb_index}=0    ${mo_dn}=null     ${mo_parameter}=null  ${value}=1
   [Documentation]    this kw is used to vCU Online Get Parameters Of Current Plan Via Rest
    ...    Author: Yang Mengli
    ...
    Login To vCU By Rest    gnb_index=${gnb_index}
    &{parameter_dict}    Create Dictionary   ${mo_parameter}=${value}
    FOR    ${para_name}    IN    @{parameter_dict}
        ${para_value}    Online Get VCU Parameter Value   mo_dn=${mo_dn}    parameter_name=${para_name}    gnb_index=${gnb_index}
        run keyword if    "${para_value}" != "${parameter_dict}[${para_name}]"
        ...    run keywords      set suite variable   ${CU_modify_parameter}   True
        ...    AND   log to console  The current value of ${para_name} on CU is ${para_value} and the expect value is ${value}.
        ...    AND   log to console  The parameter need to be modified.
        ...    ELSE  run keywords       set suite variable   ${CU_modify_parameter}   False
        ...    AND   log to console  The current value of ${para_name} on CU is ${para_value} and the expect value is ${value}.
        ...    AND   log to console  The parameter do not need to be modified.
    END
    Run keyword if  ${CU_modify_parameter} == True   set suite variable  ${need_commssion}   True
     ...    ELSE    set suite variable  ${need_commssion}   False
    [Return]    ${need_commssion}
    [Teardown]    Logout To vCU By Rest

Online Get VCU Parameter Value
   [Arguments]       ${gnb_index}=0   ${mo_dn}=null   ${parameter_name}=administrativeState
    ${para_result}    cu.search_parameters_of_current_plan    parameter_name=${parameter_name}
    ...                                                        items_per_page=${30}
    ${result_length}          get length    ${para_result['items']}
    ${result_fault_length}    Evaluate      ${result_length} - ${1}
    FOR    ${index}    IN RANGE    ${result_length}
        ${distname}    set variable    ${para_result['items'][${index}]['distname']}
        ${para}        set variable    ${para_result['items'][${index}]['parameter_name']}
        Run Keyword If    "${distname}" == "${mo_dn}" and "${para}" == "${parameter_name}"
        ...                 Set Variable    ${index}    ${index}
        exit for loop if    "${distname}" == "${mo_dn}" and "${para}" == "${parameter_name}"
        Run Keyword If      ${index}==${result_fault_length}    fail    get parameter is failed
    END
    ${para_value}    set variable    ${para_result['items'][${index}]['parameter']['simple_parameter']['value']}
    [Return]   ${para_value}


VRAN20.Set case Parameter on CU and DU
    [Arguments]     ${gnb_index}=0   ${case_parameters_list}=null   ${mo_dn_CELL}=NULL   ${mo_dn_BTS}=null   ${activate}=${True}
    #@{case_parameters_list}    create list     @{CASE_INPUT_CB008698['CB008698_C_1']['case_parameters']}
    ${len}    Get Length      ${case_parameters_list}
    FOR     ${i}  IN RANGE    ${len}
        ${case_parameters}    Set Variable    ${case_parameters_list}[${i}]
        ${mo_parameter}       Set Variable    ${case_parameters}[0]
        ${value}              Set Variable    ${case_parameters}[1]
        ${checkpoint}         Set Variable    ${case_parameters}[2]
        ${par_level}          Set Variable    ${case_parameters}[3]
        Run keyword if    "${par_level}" == "Cell_Level"     VRAN20.Set per_case parameter on CU and DU   mo_dn_target=${mo_dn_CELL}
        ...    mo_parameter=${mo_parameter}  value=${value}   checkpoint=${checkpoint}
        ...    ELSE IF    "${par_level}" == "BTS_Level"      VRAN20.Set per_case parameter on CU and DU    mo_dn_target=${mo_dn_BTS}
        ...    mo_parameter=${mo_parameter}  value=${value}   checkpoint=${checkpoint}

    END
    Login To vCU By Rest    gnb_index=${gnb_index}
    #Validate and Activate Delata Plan For vCU    delta_plan_id=${CU_delta_plan_id}
    ${active_res}=    cu.activate_delta_plan    plan_id=${CU_delta_plan_id}
    Wait until keyword succeeds    9x    30s
    ...  _Check Activating Delta Plan Operation Should Be Successful    plan_id=${CU_delta_plan_id}
    ...                                                                operation_id=${active_res['operation_id']}
    Logout To vCU By Rest

    vDU Login By Rest
    run keyword if    "${activate}"=="${True}"   Activate Delta Plan By REST    plan_id=${DU_delta_plan_id}  # Activate vDU Delta Plan By REST
    vDU Logout By Rest
VRAN20.Set per_case parameter on CU and DU
    [Arguments]    ${checkpoint}=BOTH   ${MRBTS_ID}=10550    ${NRBTS_ID}=10550    ${mo_parameter}=null  ${value}=1   ${mo_dn_target}=null
    Set suite Variable   ${mo_dn}    ${mo_dn_target}
    #${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    Run keyword if  "${checkpoint}" == "BOTH"   VRAN20.Online Set vCU and vDU Parameters
    ...    mo_parameter=${mo_parameter}    value=${value}    mo_dn=${mo_dn}
    ...   ELSE IF   "${checkpoint}" == "CU"  VRAN20.Online Set vCU Parameters
    ...    mo_parameter=${mo_parameter}    value=${value}   mo_dn=${mo_dn}
    ...   ELSE   "${checkpoint}" == "DU"     VRAN20.Online Set vDU Parameters
    ...    mo_parameter=${mo_parameter}    value=${value}   mo_dn=${mo_dn}

VRAN20.Online Set vCU and vDU Parameters
    [Arguments]    ${MRBTS_ID}=10550    ${NRBTS_ID}=10550   ${mo_parameter}=NULL   ${value}=NULL  ${mo_dn}=NULL
    VRAN20.Online Set vCU Parameters   mo_parameter=${mo_parameter}   value=${value}  mo_dn=${mo_dn}
    VRAN20.Online Set vDU Parameters   mo_parameter=${mo_parameter}   value=${value}  mo_dn=${mo_dn}


VRAN20.Online Set vCU Parameters
    [Arguments]     ${mo_parameter}=NULL   ${value}=NULL  ${mo_dn}=NULL    ${gnb_index}=${0}
    &{param_dict}    create dictionary    operation_type=replace    parameter_path=/${mo_parameter}    value=${value}
    @{updated_paras_dict}    Create List    ${param_dict}
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${para_value}=    Get Parameters Of Current Plan Via Rest    parameter_name=${mo_parameter}    gnb_index=${gnb_index}
    ...                                        mo_dn=${mo_dn}
    Run Keyword If    "${para_value}"!="${value}"    Online Modify Single Mo Parameters
    ...                                                            para_list=${updated_paras_dict}
    ...                                                            mo_dn=${mo_dn}
    [Teardown]    Logout To vCU By Rest

Online Modify Single Mo Parameters
    [Arguments]    ${para_list}    ${mo_dn}    ${delta_plan_name}=delta_plan
    ${delta_plan_id}=    Online Generate Delta Plan Via Rest In vCU    delta_plan_name=${delta_plan_name}
    Online Update Single Mo Parameters Via Rest In vCU    para_list=${para_list}    mo_dn=${mo_dn}
    ...                                                   delta_plan_id=${delta_plan_id}
    ${validate_res}=    cu.validate_delta_plan    plan_id=${delta_plan_id}
    Wait until keyword succeeds    9x    5s
    ...  _Check Validating Delta Plan Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                              action_id=${validate_res['action_id']}
    Set suite Variable   ${CU_delta_plan_id}    ${delta_plan_id}
    [Return]    ${delta_plan_id}



VRAN20.Online Set vDU Parameters
    [Arguments]     ${mo_parameter}=NULL   ${value}=NULL  ${mo_dn}=NULL
    Set suite Variable   ${START_TIME}  1    #This parameter is used for creating a tmp file on UTE to save delta_plan file
    &{parameter_dict}    Create Dictionary   ${mo_parameter}=${value}
    &{parameter_dict1}    VRAN20.Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    ${len}    Get Length    ${parameter_dict1}
    Run Keyword If     "${len}" != "0"    VDU Online Modify Parameters    mo_dn=${mo_dn}
    ...                                          updated_paras_list=${parameter_dict}
    ...                                          operation=replace
    vDU Logout By Rest
    [Teardown]    Run Keyword And Ignore error    vDU Logout By Rest


VDU Online Modify Parameters
    [Arguments]    ${mo_dn}    ${updated_paras_list}    ${operation}=replace    ${activate}=${True}  ${timeout}=60
    ${timeout}    convert to integer    ${timeout}
    ${delta_plan_name}    get unique id    prefix=TA_delta_plan    precise=LOW
    #Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${plan_id}    ${action_id}    Generate Delta Plan    plan_name=${delta_plan_name}    plan_description=TA
    ${out}    Update Delta Plan Parameter    plan_id=${planid}    mo_dn=${mo_dn}
    ...                 updated_paras_dict=${updated_paras_list}    operation=${operation}
    ${validation_id}    Validate Delta Plan By REST    plan_id=${planid}
    Set suite Variable   ${DU_delta_plan_id}    ${plan_id}
    [Return]    ${plan_id}


Adjust PA To Default Value for L3CALL
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${eNBRU_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_2']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for eNB default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${eNBRUother_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_2']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for eNB default value.
#    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRUother_PA_Ports}
#    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_2']}   attenuator=${PA1_INFO}
#    ...    logging_message=Setting PA max values for TL1125 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_2']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA max values for RU1 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for RU2 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports_for_UE2}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA min values for UE2 default value.

Adjust PA To Default Value for HO
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${eNBRU_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_2']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for eNB default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${eNBRUother_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_2']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for eNB default value.
#    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRUother_PA_Ports}
#    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_2']}   attenuator=${PA1_INFO}
#    ...    logging_message=Setting PA max values for TL1125 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for RU1 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_2']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA max values for RU2 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports_for_UE2}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA min values for UE2 default value.
Setup case for CB008698_A_2
    log to console     Case Start
    set test variable     ${pacp_name}       ${CASE_INPUT_CB008698['CB008698_A_2']['pacp_name']}
    set test variable     ${NRCELL_ID}       ${CASE_INPUT_CB008698['CB008698_A_2']['NRCELL_ID']}
    Set test Variable     ${mo_dn_CELL}       MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL_ID}
    Run Keyword And Continue On Failure    Adjust PA To Default Value for L3CALL
    @{case_parameters_list}    create list     @{CASE_INPUT_CB008698['CB008698_B_1']['case_parameters']}
#    ${need_commssion}    VRAN20.check case Parameter on CU and DU   case_parameters_list=@{case_parameters_list}
#    ...    mo_dn_CELL=${mo_dn_CELL}     mo_dn_BTS=${mo_dn_BTS}
    run keyword if    '${commission}'=='true'    TL_Backup_SCF_and_Commission_Case_SCF  CU_SCF=${CU_8698_A_2_SCF}   DU_SCF=${DU_8698_A_2_SCF}
#    ...    ELSE IF    ${need_commssion}==True    Backup SCF and Online Set vDU Parameters    MRBTS_ID=${MRBTS_ID}  NRBTS_ID=${NRBTS_ID}
#    ...    case_parameters_list=@{case_parameters_list}   mo_dn_BTS=${mo_dn_BTS}   mo_dn_CELL=${mo_dn_CELL}
    ...    ELSE
    ...    log to console   commsion bypass

Teardown case
    Run Keyword And Ignore Error    run    command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Conn.ResetCache
    log to console     Case teardown



Setup case for CB008698_B_1
    set suite variable     ${PCI_for_UE0}      ${CASE_INPUT_CB008698['CB008698']['PCI_for_UE0']}
    set suite variable     ${PCI_for_UE1}      ${CASE_INPUT_CB008698['CB008698']['PCI_for_UE1']}
    set test variable      ${pacp_name}        ${CASE_INPUT_CB008698['CB008698_B_1']['pacp_name']}
    set test variable      ${NRCELL_ID}        ${CASE_INPUT_CB008698['CB008698_B_1']['NRCELL_ID']}
    Set test Variable      ${mo_dn_CELL}       MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL_ID}
    Run Keyword And Continue On Failure     Adjust PA To Default Value for HO
    #This Variable is used for chenck parameter on vCU and vDU
    @{case_parameters_list}    create list      @{CASE_INPUT_CB008698['CB008698_B_1']['case_parameters']}
#    ${need_commssion}    VRAN20.check case Parameter on CU and DU   case_parameters_list=@{case_parameters_list}
#    ...    mo_dn_CELL=${mo_dn_CELL}   mo_dn_BTS=${mo_dn_BTS}
    run keyword if    '${commission}'=='true'    TL_Backup_SCF_and_Commission_Case_SCF  CU_SCF=${CU_8698_B_1_SCF}   DU_SCF=${DU_8698_B_1_SCF}
#    ...    ELSE IF   ${need_commssion}==True     Backup SCF and Online Set vDU Parameters    MRBTS_ID=${MRBTS_ID}  NRBTS_ID=${NRBTS_ID}
#    ...    case_parameters_list=@{case_parameters_list}   mo_dn_BTS=${mo_dn_BTS}   mo_dn_CELL=${mo_dn_CELL}
    ...    ELSE
    ...    log to console   commsion bypass


Setup case for CB008698_C_1
    set test variable     ${pacp_name}          ${CASE_INPUT_CB008698['CB008698_C_1']['pacp_name']}
    set test variable     ${NRCELL_ID}          ${CASE_INPUT_CB008698['CB008698_C_1']['NRCELL_ID']}
    Set test Variable     ${mo_dn_CELL}         MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL_ID}
    @{case_parameters_list}    create list      @{CASE_INPUT_CB008698['CB008698_C_1']['case_parameters']}
    Run Keyword And Continue On Failure    Adjust PA To Default Value for L3CALL
#    ${need_commssion}    VRAN20.check case Parameter on CU and DU   case_parameters_list=@{case_parameters_list}
#    ...    mo_dn_CELL=${mo_dn_CELL}  mo_dn_BTS=${mo_dn_BTS}
    run keyword if    '${commission}'=='true'     TL_Backup_SCF_and_Commission_Case_SCF   CU_SCF=${CU_8698_C_1_SCF}   DU_SCF=${DU_8698_C_1_SCF}
#    ...    ELSE IF     ${need_commssion}==True    Backup SCF and Online Set vDU Parameters    MRBTS_ID=${MRBTS_ID}  NRBTS_ID=${NRBTS_ID}
#    ...    case_parameters_list=@{case_parameters_list}   mo_dn_BTS=${mo_dn_BTS}   mo_dn_CELL=${mo_dn_CELL}
    ...    ELSE
    ...    log to console   commsion bypass


Setup case for CB008698_D_9
    set test variable     ${8698_D9_dist_name}          ${CASE_INPUT_CB008698['CB008698_D_9']['8698_D9_dist_name']}
    set test variable     ${pacp_name}          ${CASE_INPUT_CB008698['CB008698_D_9']['pacp_name']}
    set test variable     ${NRCELL_ID}          ${CASE_INPUT_CB008698['CB008698_D_9']['NRCELL_ID']}
    Set test Variable     ${mo_dn_CELL}         MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL_ID}
    @{case_parameters_list}    create list      @{CASE_INPUT_CB008698['CB008698_D_9']['case_parameters']}


KW.Cloud Commission And Check On Air For CB008698_D_9
    [Arguments]
    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
      ...    modified_cfgfile_CU=${LOG_PATH}/8698_D9_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU_GoldenSCF}
      ...    modified_cfgfile_DU=${LOG_PATH}/8698_D9_DU_SCF.xml    ResourceFolder=${CURDIR}
      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU_8698_D9     mo_to_add_CU=MOs_TO_ADD_CU_8698_D9
      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU_8698_D9     list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU_8698_D9
      ...    list_to_add_CU=LIST_TO_ADD_CU_8698_D9
      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU_8698_D9     mo_to_add_DU=MOs_TO_ADD_DU_8698_D9
      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU_8698_D9     list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY_DU_8698_D9
      ...    list_to_add_DU=LIST_TO_ADD_DU_8698_D9
    TL_Backup_SCF_and_Commission_Case_SCF     CU_SCF=${LOG_PATH}/8698_D9_CU_SCF.xml   DU_SCF=${LOG_PATH}/8698_D9_DU_SCF.xml


Setup Suite for 8698
    Import Variables        ${CFGFILE_PATH}TLConfiguration.py
    set suite variable     ${commission}      ${CASE_INPUT_CB008698['CB008698']['commission']}
    set suite variable     ${pod_abbr}        ${CASE_INPUT_CB008698['CB008698']['pod_abbr']}
    set suite variable     ${ctr_abbr}        ${CASE_INPUT_CB008698['CB008698']['ctr_abbr']}
    set suite variable     ${tl_name}         ${CASE_INPUT_CB008698['CB008698']['tl_name']}
    set suite variable     ${MRBTS_ID}        ${CASE_INPUT_CB008698['CB008698']['MRBTS_ID']}
    set suite variable     ${NRBTS_ID}        ${CASE_INPUT_CB008698['CB008698']['NRBTS_ID']}
    set suite variable     ${eNBRU_PA_Ports}        ${CASE_INPUT_CB008698['CB008698']['eNBRU_PA_Ports']}
    set suite variable     ${eNBRUother_PA_Ports}   ${CASE_INPUT_CB008698['CB008698']['eNBRUother_PA_Ports']}
    set suite variable     ${5GRUother_PA_Ports}    ${CASE_INPUT_CB008698['CB008698']['5GRUother_PA_Ports']}
    set suite variable     ${5GRU2_PA_Ports_for_UE2}    ${CASE_INPUT_CB008698['CB008698']['5GRU2_PA_Ports_for_UE2']}
    set suite variable     ${5GRU1_PA_Ports}        ${CASE_INPUT_CB008698['CB008698']['5GRU1_PA_Ports']}
    set suite variable     ${5GRU2_PA_Ports}        ${CASE_INPUT_CB008698['CB008698']['5GRU2_PA_Ports']}
    set suite Variable     ${mo_dn_BTS}             MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    TestSuite.Start
    Conn.ResetCache

Teardown Suite for 8698
    TestSuite.Stop


KW.Adjust PA To Default Value For CB008698
    [Arguments]
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${eNBRU_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_1']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for eNB default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_3']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU1 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_2']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU2 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRUother_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_1']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU other ports default value.


KW.Adjust PA To Handover Value For CB008698
    [Arguments]
#    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
#    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_3']}   attenuator=${PA2_INFO}
#    ...    logging_message=Setting PA values for RU2 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008698['CB008698']['PA_Value_1']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU1 default value.
