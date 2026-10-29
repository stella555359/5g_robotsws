*** Settings ***
Documentation
...   author: Jing.Qu@nokia-sbell.com
...   contact: Jing.Qu@nokia-sbell.com
...   Description: Common Keyword

#Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/aic_common_resources.robot
#Library           testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/py_tool/common.py
Library           testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/py_tool/utils.py
Library           taf.hw.fhgw.cli                       WITH NAME    issh
Library           taf.analyzer.pcap                     WITH NAME    wireshark
Library           taf.selenium.gnb.oam.coam.cu          WITH NAME    scu
Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/variables.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/common_log.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/aic_common_resources_new.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_oam_cm.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_oam_state.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_trs_conn.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_trs_conn.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_oam_cm.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/common_pre_post_condition.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_cloud_deployment.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_cloud_deployment.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/new_power_UE.robot
#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/Attenuation_new.robot
#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/core_simulator.robot
#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/pcmd_cloud.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/new_power_UE.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/Attenuation_new.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/core_simulator.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/pcmd_cloud.robot
Variables         ../Common_resource/emil_vars.py
Resource          ../case_resource/CB009225_A_03_e2e_B02_Successful_SA_intra_gNB_inter_DU_handover_A3_trigger_cloud.robot
Resource          ../case_resource/CB009225_B_04_B02_e2e_gNB_CU_UeDuConectivity_PCMD_record_intra_gNB_inter_DU_mobility_for_NSA_Cloud_gNB.robot
Resource          ../case_resource/CB008187_Cloud.robot
Resource          ../case_resource/CB008208-5G-A-12_Classical_gNB-CU_Bearer_record_for_SA_Initial_Context_Setup.robot
Resource          ../case_resource/CB008208-5G-A-13_Classical_gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Setup.robot
Resource          ../case_resource/CB008208-5G-A-21_Classical_DU-Bearer_reporting_for_SA_UE_Context_Setup_scenarios_Initial_Context_Setup.robot
Resource          ../case_resource/CB008208-5G-A-15_Classical_gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Release.robot
Resource          ../case_resource/CB009881-CB009225_A_03_e2e_B02_Successful_SA_intra_gNB_inter_DU_handover_A3_trigger_cloud.robot
Resource          ../case_resource/CB009444_CB008208_SgnbInitiatedSgNBModRecord_for_NSA_intra_en_gNB_inter_DU_mobility.robot
Resource          ../case_resource/CB009444_CB008208_MenbConnectivityRecord_for_NSA_intra_en_gNB_inter_DU_mobility.robot
Resource          ../case_resource/CB009444_CB008208_gNBCubearerRecord_for_NSA_intra_en_gNB_inter_DU_mobility.robot
Resource          ../case_resource/CB009444_CB008208_UeDuConectivityRecord_for_NSA_intra_en_gNB_inter_DU_mobility.robot
Resource          ../case_resource/CB007227-SR-A_RAN_UE_ID_Sent_by_gNB-CU-UP_during_SgNB_Addition_NSA_or_initial_access_SA.robot
Resource          ../case_resource/CB007227-SR-E_gNB_Cplan_and_Uplan_PCMD_record_in_scenario_Initial_Context_Setup.robot
Resource          ../case_resource/CB007227-SR-E_gNB_Cplan_record_in_scenario_Intra-gNB_Intra_DU_handover_SA.robot
Resource          ../case_resource/CB007227-SR-C_varify_content_of_PCMD_measurements_for_U-Plane_DU_RLC_layer_DL_IP_Latency.robot
Resource          ../case_resource/CB007227-SR-B_PCMD_measurements_for_U-Plane_CU-UP_PDCP_layer_report_content_verify.robot
Resource          ../case_resource/CB007227-SR-F_varify_content_of_PCMD_measurements_for_RLC_layer_UL.robot
Resource          ../case_resource/PCMD_Check_Point.robot

*** Variables ***
${BTSID}    BTS-${tl.gnbs[0].cu.instance_id}
${fileName_CPIF}    ${BTSID}_cpif.pcap
${fileNmae_PCMD}    ${BTSID}_pcmd.pcap
${vCU_dump_path}    /var/home/core/
${Intra_gNB_Inter_DU_File_SA}    Intra_gNB_inter_DU_SA.pcap
${Intra_gNB_Inter_DU_File_NSA}    Intra_gNB_inter_DU_NSA.pcap
${nsetapx_plugin_addr}
...    https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/nsetapx-1.6.4/nsetapx-3.6-1.6.4+buster.so
${plugin_folder}   /usr/lib/x86_64-linux-gnu/wireshark/plugins
${tshark_path}      /usr/bin/tshark
${remote_dir_path}   /tmp
${vDU_dump_path}    /var/home/core
*** Keywords ***
Start Tcpdump On vCU
    Enable Tcpdump on vCU Container   pod_abbr=cpif   file_name=${fileName_CPIF}
    Enable Tcpdump on vCU Container   pod_abbr=oamext   file_name=${fileNmae_PCMD}

Enable Tcpdump on vCU Container
    [Arguments]   ${pod_abbr}   ${file_name}   ${gnb_index}=0
    ${TL_NAMESPACE}   Set Variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    ${alias}   Connect To CU K8S Master With Admin_TL   gnb_index=${gnb_index}
    # Set Suite Variable   ${alias}

    ${command_pre}   Set Variable   kubectl exec -it po-${TL_NAMESPACE}-${pod_abbr}-0 -n ${TL_NAMESPACE} -c ctr-${TL_NAMESPACE}-nwmgmt --

    issh.Execute
    ...   command=${command_pre} killall tcpdump
    ...   check_result=${False}
    ...   alias=${alias}

    issh.Execute_Bare
    ...   command=${command_pre} tcpdump -i any -s0 -w /tmp/${file_name} -vv
    ...   alias=${alias}
    ${out}   Send ENTER Interactively VCU CNF  alias=${alias}
    Sleep   5s

    [Teardown]   Disconnect Interactive Connection   alias=${alias}

Get Tcpdump From vCU And Combine
    [Arguments]  ${local_file}
    Disable Tcpdump on vCU And Download The File    pod_abbr=cpif    file_name=${fileName_CPIF}
    Disable Tcpdump on vCU And Download The File    pod_abbr=oamext    file_name=${fileNmae_PCMD}
    Combin Pcap File And Remove tempDump File
    ...    local_file=${local_file}    file1=${fileName_CPIF}    file2=${fileNmae_PCMD}

Disable Tcpdump on vCU And Download The File
    [Arguments]   ${pod_abbr}   ${file_name}   ${gnb_index}=0
    ${TL_NAMESPACE}   Set Variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    ${alias}   Connect To CU K8S Master With Admin_TL   gnb_index=${gnb_index}
    ${command_pre}   Set Variable   kubectl exec -it po-${TL_NAMESPACE}-${pod_abbr}-0 -n ${TL_NAMESPACE} -c ctr-${TL_NAMESPACE}-nwmgmt --
    ${cpif_pid}   issh.Execute
    ...   command=${command_pre} ps -ef | grep tcpdump | awk '{print $2}'
    ...   check_result=${False}
    ...   alias=${alias}
    ${cpif_pid}   Strip Prompt   ${cpif_pid}

    issh.Execute
    ...   command=${command_pre} /bin/bash -c "kill -9 ${cpif_pid}"
    ...   check_result=${False}
    ...   alias=${alias}

    ${cp_command_pre}   Set Variable   kubectl exec -n ${TL_NAMESPACE} po-${TL_NAMESPACE}-${pod_abbr}-0 -c ctr-${TL_NAMESPACE}-nwmgmt --
    issh.Execute
    ...   command=${cp_command_pre} cat /tmp/${file_name} > /var/home/${vcu_oam_ssh_username}/${file_name}
    ...   check_result=${False}
    ...   alias=${alias}
    ${out}   Send ENTER Interactively VCU CNF  alias=${alias}
    Sleep   5s
    issh.download_file   local_path=${OUTPUT_DIR}/${file_name}   remote_path=/var/home/${vcu_oam_ssh_username}/${file_name}   alias=${alias}
    issh.Execute
    ...   command=rm -f /var/home/${vcu_oam_ssh_username}/${file_name}
    ...   check_result=${False}
    ...   alias=${alias}

    [Teardown]  Disconnect Interactive Connection   alias=${alias}

Combin Pcap File And Remove tempDump File
    [Arguments]  ${local_file}    ${file1}    ${file2}
    OperatingSystem.Run    mergecap -w ${OUTPUT DIR}/${local_file} ${OUTPUT DIR}/${file1} ${OUTPUT DIR}/${file2}
    OperatingSystem.File Should Exist     ${OUTPUT_DIR}/${local_file}
    OperatingSystem.Remove Files     ${OUTPUT DIR}/${file1}    ${OUTPUT DIR}/${file2}

Initialize PA For SA Call
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=0    value=0
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=1    value=127
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=2    value=127
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=3    value=127
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=4    value=127

Initialize PA For NSA Call
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=0    value=0
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=1    value=127
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=2    value=127
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=3    value=127
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=4    value=0

Adjust PA For Intra-gNB Inter-DU Handover
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=1    value=20
    Sleep    5s
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=0    value=30
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=1    value=0
    Sleep    5s

UE Attach And Perform Intra-gNB Inter-DU Handover
    [Arguments]  ${ue_index}
    Sleep    5s
    new_power_UE.UE Attach    ue_index=${ue_index}
    Sleep    5s
    Adjust PA For Intra-gNB Inter-DU Handover
    Sleep    5s
    [Teardown]  New Commercial UE detach    ue_index=${ue_index}

SA UE Preparation At Case Setup
    [Arguments]  ${ue_index}=0
    Set Suite Variable    ${ue_${ue_index}_type}       ${tl.ues[${ue_index}].capabilities[1]}
    power_ue.Prepare UE    ue_type=${ue_${ue_index}_type}     ue_index=${ue_index}
    New Commercial UE detach    ue_index=${ue_index}

NSA UE Preparation At Case Setup
    [Arguments]  ${ue_index}=1
    Set Suite Variable    ${ue_${ue_index}_type}       ${tl.ues[${ue_index}].capabilities[1]}
    power_ue.Prepare UE    ue_type=${ue_${ue_index}_type}     ue_index=${ue_index}
    New Commercial UE detach    ue_index=${ue_index}

Initialize PA For SA INTER gNB HO
    Modify All Attenuation Ports Value For Specific RU For Cloud   gnb_id=0   RU_id=0   value=20
    Modify All Attenuation Ports Value For Specific RU For Cloud   gnb_id=0   RU_id=1   value=127
    Modify All Attenuation Ports Value For Specific RU For Cloud   gnb_id=0   RU_id=2   value=127
    Modify All Attenuation Ports Value For Specific RU For Cloud   gnb_id=0   RU_id=3   value=40
    Modify All Attenuation Ports Value For Specific RU For Cloud   gnb_id=0   RU_id=4   value=127

Start Tcpdump for VDU OCP
    [Arguments]   ${pcmd_file}   ${ctr_abbr}=oamagent   ${gnb_index}=0  ${vdu_index}=0  ${timeout}=150  ${alias}=default
#    ${alias}    Get Unique Id
    Connect To K8s Master Interactively   gnb_index=${gnb_index}   alias=${alias}
    ${pid}   Get PID For Container   ctr_abbr=oamagent    alias=${alias}   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${ssh_command}    Set Variable    sudo nsenter -r -n -t ${pid} tcpdump -i mcplane -s 0 -w ./${pcmd_file}
    issh.Execute_Bare   command=${ssh_command}   alias=${alias}
    ${out}   Send ENTER Interactively VCU CNF  alias=${alias}
    sleep   5s
#    [Teardown]  Disconnect Interactive Connection   alias=${alias}


Stop Tcpdump for VDU OCP
    [Arguments]   ${pcmd_file}   ${ctr_abbr}=oamagent   ${gnb_index}=0  ${vdu_index}=0  ${timeout}=150  ${alias}=default
#    ${alias}    Get Unique Id
#    Connect To K8s Master Interactively   gnb_index=${gnb_index}   alias=${alias}
    Send CTRL_C Interactively   alias=${alias}
    issh.download_file   local_path=${OUTPUT DIR}/${pcmd_file}    remote_path=${vDU_dump_path}/${pcmd_file}   alias=${alias}
    [Teardown]  Disconnect Interactive Connection   alias=${alias}

Enable Tcpdump on vDU Container
    [Arguments]   ${pod_abbr}   ${file_name}   ${gnb_index}=0   ${vdu_index}=0
    ${TL_NAMESPACE}   Set Variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    ${alias}   Connect To K8s Master Interactively   gnb_index=${gnb_index}
    # Set Suite Variable   ${alias}

    ${command_pre}   Set Variable   kubectl exec -it po-${TL_NAMESPACE}-${pod_abbr}-0 -n ${TL_NAMESPACE} -c ctr-${TL_NAMESPACE}-nwmgmt --

    issh.Execute
    ...   command=${command_pre} killall tcpdump
    ...   check_result=${False}
    ...   alias=${alias}

    issh.Execute_Bare
    ...   command=${command_pre} tcpdump -i any -s0 -w /tmp/${file_name} -vv
    ...   alias=${alias}
    ${out}   Send ENTER Interactively VCU CNF  alias=${alias}
    Sleep   5s

    [Teardown]   Disconnect Interactive Connection   alias=${alias}


Disable Tcpdump on vDU And Download The File
    [Arguments]   ${pod_abbr}   ${file_name}   ${gnb_index}=0   ${vdu_index}=0
    ${TL_NAMESPACE}   Set Variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    ${alias}   Connect To K8s Master Interactively   gnb_index=${gnb_index}

    Run Keyword And Ignore Error   issh.Execute
    ...   command=mkdir -p /var/home/core/${TL_NAMESPACE}
    ...   check_result=${False}
    ...   alias=${alias}

    ${command_pre}   Set Variable   kubectl exec -it po-${TL_NAMESPACE}-${pod_abbr}-0 -n ${TL_NAMESPACE} -c ctr-${TL_NAMESPACE}-nwmgmt --
    ${cpif_pid}   issh.Execute
    ...   command=${command_pre} ps -ef | grep tcpdump | awk '{print $2}'
    ...   check_result=${False}
    ...   alias=${alias}
    ${cpif_pid}   Strip Prompt   ${cpif_pid}
    issh.Execute
    ...   command=${command_pre} /bin/bash -c "kill -9 ${cpif_pid}"
    ...   check_result=${False}
    ...   alias=${alias}

    ${cp_command_pre}   Set Variable   kubectl exec -n ${TL_NAMESPACE} po-${TL_NAMESPACE}-${pod_abbr}-0 -c ctr-${TL_NAMESPACE}-nwmgmt --
    issh.Execute
    ...   command=${cp_command_pre} cat /tmp/${file_name} > /var/home/core/${TL_NAMESPACE}/${file_name}
    ...   check_result=${False}
    ...   alias=${alias}
    ${out}   Send ENTER Interactively VCU CNF  alias=${alias}
    Sleep   5s

    issh.download_file   local_path=${OUTPUT_DIR}/${file_name}   remote_path=/var/home/core/${TL_NAMESPACE}/${file_name}   alias=${alias}
    issh.Execute
    ...   command=rm -f /var/home/core/${TL_NAMESPACE}/${file_name}
    ...   check_result=${False}
    ...   alias=${alias}

    [Teardown]  Disconnect Interactive Connection   alias=${alias}

Trigger SA INTER gNB HO And Get ALL Tcpdump
    Initialize PA For SA INTER gNB HO
    SA UE Preparation At Case Setup
    Start Tcpdump for VDU OCP   ${source_VDU_OCP_file}   alias=sourceOCP
    Start Tcpdump for VDU OCP   pcmd_file=${target_VDU_OCP_file}   gnb_index=1    alias=TargetgNB
    Enable Tcpdump on vCU Container   pod_abbr=cpif   file_name=${source_VCU_CPIF_file}
    Enable Tcpdump on vCU Container   pod_abbr=oamext   file_name=${source_VCU_OAMAGENT_file}
    Enable Tcpdump on vCU Container   pod_abbr=cpif   file_name=${target_VCU_CPIF_file}   gnb_index=1
    Enable Tcpdump on vCU Container   pod_abbr=oamext   file_name=${target_VCU_OAMAGENT_file}   gnb_index=1
    new_power_UE.UE Attach    ue_index=${sa_ue_index}
    Modify All Attenuation Ports Value For Specific RU For Cloud   gnb_id=0   RU_id=3   value=10
    Sleep    5s
#    Modify All Attenuation Ports Value For Specific RU For Cloud   gnb_id=0   RU_id=3   value=20
#    Sleep    5s
    Disable Tcpdump on vCU And Download The File    pod_abbr=cpif    file_name=${source_VCU_CPIF_file}
    Disable Tcpdump on vCU And Download The File    pod_abbr=oamext    file_name=${source_VCU_OAMAGENT_file}
    Disable Tcpdump on vCU And Download The File    pod_abbr=cpif    file_name=${target_VCU_CPIF_file}   gnb_index=1
    Disable Tcpdump on vCU And Download The File    pod_abbr=oamext    file_name=${target_VCU_OAMAGENT_file}   gnb_index=1
    Stop Tcpdump for VDU OCP   ${source_VDU_OCP_file}   alias=sourceOCP
    Stop Tcpdump for VDU OCP   pcmd_file=${target_VDU_OCP_file}   gnb_index=1    alias=TargetgNB
#    Combin Pcap File And Remove tempDump File
    [Teardown]  New Commercial UE detach    ue_index=${sa_ue_index}

Get ALL Suite Variables on VCU
    Set Suite Variable   ${LOCAL_MRBTS_ID}   ${tl.gnbs[0].cu.instance_id}
    Set Suite Variable   ${LOCAL_NRBTS_ID}   ${tl.gnbs[0].cu.global_bts_id}
    Set Suite Variable   ${LOCAL_MRBTS}   MRBTS-${LOCAL_MRBTS_ID}
    Set Suite Variable   ${LOCAL_NRBTS}   NRBTS-${LOCAL_NRBTS_ID}
    Set Suite Variable   ${LOCAL_INSID}   ${LOCAL_MRBTS}/${LOCAL_NRBTS}
    ${dn_local_nrcellidentity}    Set Variable   ${LOCAL_INSID}/NRCELL-1
    ${nrcellid_source}=   CU Get Online Parameter Value     ${dn_local_nrcellidentity}   nrCellIdentity
    Set Suite Variable   ${LOCAL_NRCELLID}   ${nrcellid_source}
    ${2ndcell_local_nrcellidentity}    Set Variable   ${LOCAL_INSID}/NRCELL-2
    ${nrcellid_source_2ndcell}=   CU Get Online Parameter Value     ${2ndcell_local_nrcellidentity}   nrCellIdentity
    Set Suite Variable   ${LOCAL_NRCELLID_2NDCELL}   ${nrcellid_source_2ndcell}
    ${local_mcc}=   CU Get Online Parameter Value     ${LOCAL_INSID}/NRPLMN-1   mcc
    ${local_mnc}=   CU Get Online Parameter Value     ${LOCAL_INSID}/NRPLMN-1   mnc
    ${local_mnclength}=   CU Get Online Parameter Value     ${LOCAL_INSID}/NRPLMN-1   mncLength

    ${local_tmp}   Set Variable If
    ...   '${local_mnclength}'=='2'   ${local_mcc}f${local_mnc.zfill(int(${local_mnclength}))}
    ...   '${local_mnclength}'=='3'   ${local_mcc}${local_mnc.zfill(int(${local_mnclength}))}
    Set Suite Variable   ${LOCAL_PLMN_IDENTITY}   ${local_tmp[1]}${local_tmp[0]}${local_tmp[3]}${local_tmp[2]}${local_tmp[5]}${local_tmp[4]}
    [Teardown]   Run Keyword And Ignore Error   CU Rest Logout
Get Inter gnb HO Suite Variables on VCU
    Set Suite Variable   ${PEER_MRBTS_ID}   ${tl.gnbs[1].cu.instance_id}
    Set Suite Variable   ${PEER_NRBTS_ID}   ${tl.gnbs[1].cu.global_bts_id}
    Set Suite Variable   ${PEER_MRBTS}   MRBTS-${PEER_MRBTS_ID}
    Set Suite Variable   ${PEER_NRBTS}   NRBTS-${PEER_NRBTS_ID}
    Set Suite Variable   ${PEER_INSID}   ${PEER_MRBTS}/${PEER_NRBTS}
    ${dn_peer_nrcellidentity}    Set Variable   ${PEER_INSID}/NRCELL-1
    ${nrcellid_peer}=   CU Get Online Parameter Value     ${dn_peer_nrcellidentity}   nrCellIdentity   gnb_index=1
    Set Suite Variable   ${PEER_NRCELLID}   ${nrcellid_peer}
    ${peer_mcc}=   CU Get Online Parameter Value     ${PEER_INSID}/NRPLMN-1   mcc   gnb_index=1
    ${peer_mnc}=   CU Get Online Parameter Value     ${PEER_INSID}/NRPLMN-1   mnc   gnb_index=1
    ${peer_mnclength}=   CU Get Online Parameter Value     ${PEER_INSID}/NRPLMN-1   mncLength   gnb_index=1

    ${peer_tmp}   Set Variable If
    ...   '${peer_mnclength}'=='2'   ${peer_mcc}f${peer_mnc.zfill(int(${peer_mnclength}))}
    ...   '${peer_mnclength}'=='3'   ${peer_mcc}${peer_mnc.zfill(int(${peer_mnclength}))}
    Set Suite Variable   ${PEER_PLMN_IDENTITY}   ${peer_tmp[1]}${peer_tmp[0]}${peer_tmp[3]}${peer_tmp[2]}${peer_tmp[5]}${peer_tmp[4]}
    [Teardown]   Run Keyword And Ignore Error   CU Rest Logout


Connect To CU K8S Master With Admin_TL
    [Arguments]  ${gnb_index}=0    ${timeout}=150  ${width}=${None}
    ${host_ip}=  Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ${username}=  Set Variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ${password}=  Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
#    ${prompt}  set variable   \\[tl879@
    ${prompt}  set variable   \\[cranuser879@
    ${alias}=  get unique id

    issh.Connect_To
    ...   ip=${host_ip}
    ...   username=${username}
    ...   password=${password}
    ...   prompt=${prompt}
    ...   timeout=${timeout}
    ...   alias=${alias}
    ...   width=${width}

    [Return]  ${alias}


Check Real Fields for CU-RRCSetup Record
     [Documentation]   This keyword is used to get fields for CU-RRCSetup Record
     log to console     get fields for CU-RRCSetup Record
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${OUTPUT_DIR}/${source_VCU_OAMAGENT_file}
     ...                        any_expression=nsetapx.CuVendorExtensionRecordDataType == 18
     ...                        filter=sctp.dstport==49148
     ${data}   set variable   .//nsetapx.CuVendorExtensionRecordDataType/nsetapx.rrcSetupRecord/nsetapx.data_element
     ${cu_rrcsetup_result_xpath}   set variable   ${data}/nsetapx.result
     ${cu_rrcsetup_result}=   wireshark.get_field_value_by_xpath   xpath=${cu_rrcsetup_result_xpath}   attribute_name=showname

     ${cu_rrcsetup_estab_xpath}   set variable   ${data}/nsetapx.establishmentCauseType/nsetapx.establishmentCause
     ${cu_rrcsetup_estab}=   wireshark.get_field_value_by_xpath   xpath=${cu_rrcsetup_estab_xpath}   attribute_name=showname

     ${cu_rrcsetup_Trigger_rcvtime_xpath}   set variable   ${data}/nsetapx.rrcConnReqTriggerRcvTime_element/nsetapx.seconds
     ${cu_rrcsetup_Trigger_rcvtime_list}=   wireshark.get_field_value_by_xpath   xpath=${cu_rrcsetup_Trigger_rcvtime_xpath}
     ${cu_rrcsetup_Trigger_rcvtime_usec_xpath}   set variable   ${data}/nsetapx.rrcConnReqTriggerRcvTime_element/nsetapx.useconds
     ${cu_rrcsetup_Trigger_rcvtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${cu_rrcsetup_Trigger_rcvtime_usec_xpath}

     ${cu_rrcsetup_cmp_rcvtime_xpath}   set variable   ${data}/nsetapx.rrcConnSetupCmplRcvTime_element/nsetapx.seconds
     ${cu_rrcsetup_cmp_rcvtime_list}=   wireshark.get_field_value_by_xpath   xpath=${cu_rrcsetup_cmp_rcvtime_xpath}
     ${cu_rrcsetup_cmp_rcvtime_usec_xpath}   set variable   ${data}/nsetapx.rrcConnSetupCmplRcvTime_element/nsetapx.useconds
     ${cu_rrcsetup_cmp_rcvtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${cu_rrcsetup_cmp_rcvtime_usec_xpath}

#     Run Keyword And Continue On Failure   Should Contain   ${cu_rrcsetup_result}[0]   success
#     Run Keyword And Continue On Failure   List Should Contain Value   ${estab_cause}   establishmentCause: mo-Signalling (3)
#     Run Keyword And Continue On Failure   List Should Contain Value   ${cu_rrcsetup_estab}   establishmentCause: moSignalling (4)
#     Run Keyword And Continue On Failure   List Should Contain Value   ${estab_cause}   ${cu_rrcsetup_estab}[0]

     FOR   ${cu_rrcsetup_Trigger_rcvtime}   IN   @{cu_rrcsetup_Trigger_rcvtime_list}
       ${cu_rrcsetup_Trigger_rcvtime}   Convert To Integer   ${cu_rrcsetup_Trigger_rcvtime}
       Run Keyword And Continue On Failure   Should Be True   ${cu_rrcsetup_Trigger_rcvtime} != 0
       ${rrc_setup_request_timestamp_convert}   Convert To Integer   ${rrc_setup_request_timestamp}[0]
       Exit For Loop If   '${cu_rrcsetup_Trigger_rcvtime}'=='${rrc_setup_request_timestamp_convert}'
    END

    FOR   ${cu_rrcsetup_Trigger_rcvtime_usec}   IN   @{cu_rrcsetup_Trigger_rcvtime_usec_list}
        Run Keyword And Continue On Failure   Should Be True   ${cu_rrcsetup_Trigger_rcvtime_usec} != 0
    END


    FOR   ${cu_rrcsetup_cmp_rcvtime}   IN   @{cu_rrcsetup_cmp_rcvtime_list}
       ${cu_rrcsetup_cmp_rcvtime}   Convert To Integer   ${cu_rrcsetup_cmp_rcvtime}
       Run Keyword And Continue On Failure   Should Be True   ${cu_rrcsetup_cmp_rcvtime} != 0
    END

    FOR   ${cu_rrcsetup_cmp_rcvtime_usec}   IN   @{cu_rrcsetup_cmp_rcvtime_usec_list}
        Run Keyword And Continue On Failure   Should Be True   ${cu_rrcsetup_cmp_rcvtime_usec} != 0
    END

Check Real Fields for DU-RRCSetup Record
     [Documentation]   This keyword is used to get fields for DU-RRCSetup Record
     log to console     get fields for DU-RRCSetup Record
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${OUTPUT_DIR}/${source_VDU_OCP_file}
     ...                        any_expression=nsetapx.DuVendorExtensionRecordDataType == 16
     ...                        filter=sctp.dstport==49148
     ${data}   set variable   .//nsetapx.DuVendorExtensionRecordDataType/nsetapx.rrcSetupRecord/nsetapx.data_element
     ${du_rrcsetup_result_xpath}   set variable   ${data}/nsetapx.result
     ${du_rrcsetup_result}=   wireshark.get_field_value_by_xpath   xpath=${du_rrcsetup_result_xpath}   attribute_name=showname

     ${du_rrcsetup_estab_xpath}   set variable   ${data}/nsetapx.establishmentCauseType/nsetapx.establishmentCause
     ${du_rrcsetup_estab}=   wireshark.get_field_value_by_xpath   xpath=${du_rrcsetup_estab_xpath}   attribute_name=showname

     ${du_rrcsetup_Trigger_rcvtime_xpath}   set variable   ${data}/nsetapx.rrcConnReqTriggerRcvTime_element/nsetapx.seconds
     ${du_rrcsetup_Trigger_rcvtime_list}=   wireshark.get_field_value_by_xpath   xpath=${du_rrcsetup_Trigger_rcvtime_xpath}
     ${du_rrcsetup_Trigger_rcvtime_usec_xpath}   set variable   ${data}/nsetapx.rrcConnReqTriggerRcvTime_element/nsetapx.useconds
     ${du_rrcsetup_Trigger_rcvtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${du_rrcsetup_Trigger_rcvtime_usec_xpath}

     ${du_rrcsetup_cmp_rcvtime_xpath}   set variable   ${data}/nsetapx.rrcConnSetupCmplRcvTime_element/nsetapx.seconds
     ${du_rrcsetup_cmp_rcvtime_list}=   wireshark.get_field_value_by_xpath   xpath=${du_rrcsetup_cmp_rcvtime_xpath}
     ${du_rrcsetup_cmp_rcvtime_usec_xpath}   set variable   ${data}/nsetapx.rrcConnSetupCmplRcvTime_element/nsetapx.useconds
     ${du_rrcsetup_cmp_rcvtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${du_rrcsetup_cmp_rcvtime_usec_xpath}

#     Run Keyword And Continue On Failure   Should Contain   ${du_rrcsetup_result}[0]   success
#     Run Keyword And Continue On Failure   List Should Contain Value   ${estab_cause}   establishmentCause: mo-Signalling (3)
#     Run Keyword And Continue On Failure   List Should Contain Value   ${du_rrcsetup_estab}   establishmentCause: moSignalling (4)
#     Run Keyword And Continue On Failure   List Should Contain Value   ${estab_cause}   ${du_rrcsetup_estab}[0]

     FOR   ${du_rrcsetup_Trigger_rcvtime}   IN   @{du_rrcsetup_Trigger_rcvtime_list}
       ${du_rrcsetup_Trigger_rcvtime}   Convert To Integer   ${du_rrcsetup_Trigger_rcvtime}
       Run Keyword And Continue On Failure   Should Be True   ${du_rrcsetup_Trigger_rcvtime} != 0
       ${rrc_setup_request_timestamp_convert}   Convert To Integer   ${rrc_setup_request_timestamp}[0]
       Exit For Loop If   '${du_rrcsetup_Trigger_rcvtime}'=='${rrc_setup_request_timestamp_convert}'
    END

    FOR   ${du_rrcsetup_Trigger_rcvtime_usec}   IN   @{du_rrcsetup_Trigger_rcvtime_usec_list}
        Run Keyword And Continue On Failure   Should Be True   ${du_rrcsetup_Trigger_rcvtime_usec} != 0
    END

    FOR   ${du_rrcsetup_cmp_rcvtime}   IN   @{du_rrcsetup_cmp_rcvtime_list}
       ${du_rrcsetup_cmp_rcvtime}   Convert To Integer   ${du_rrcsetup_cmp_rcvtime}
       Run Keyword And Continue On Failure   Should Be True   ${du_rrcsetup_cmp_rcvtime} != 0
    END

    FOR   ${du_rrcsetup_cmp_rcvtime_usec}   IN   @{du_rrcsetup_cmp_rcvtime_usec_list}
        Run Keyword And Continue On Failure   Should Be True   ${du_rrcsetup_cmp_rcvtime_usec} != 0
    END
