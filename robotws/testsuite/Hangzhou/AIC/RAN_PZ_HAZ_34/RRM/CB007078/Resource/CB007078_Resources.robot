*** Settings ***
Documentation     author:.yajli
...               Group: HGZ_SG1
...               contact:yajie.li@nokia-sbell.com

Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot

Resource       ../../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource       ../../CB009444_V_B3/Resource/CB009444_V_B3_Resources.robot
Resource       taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library        taf.transport.ssh    WITH NAME    csn
Library        Process


*** Variables ***
${CFGFILE_PATH}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/

${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}
${IMSI1}                     ${tl.ues[0].imsi}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${ENB_WEBUI_IP}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENBWEBUI_URL}             https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${CU_namespace}              ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
${CU_ssh_IP}                 ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${CU_username}              ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${CU_password}              ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${CU_OAM_IP}                ${tl.gnbs[0].cu.oam_http_connection_details.addr}

##################define these variable for convenient############################
${ALIAS_CU}                 CU
########################END of alias Define#######################################

*** Keywords ***

####Case Level  Keywords#####

TC.CB007078_N_11_Message check for internal plan update for CPNRT
    #KW.OnlineModifyCUParameter
    KW.connect_CU_server
    ${Command1}    Set Variable
    ...        ns=${CU_namespace} && kubectl logs po-$ns-cpnrt-0 -c ctr-$ns-cpnrt -n $ns | grep -E 'NetworkPlanUpdate'
    ${Command2}    Set Variable
    ...        ns=${CU_namespace} && kubectl logs po-$ns-cpnrt-1 -c ctr-$ns-cpnrt -n $ns | grep -E 'NetworkPlanUpdate'
    ${Response1}       ssh.Execute      command=${Command1}     connection=${ALIAS_CU}
    ${Response2}       ssh.Execute      command=${Command2}     connection=${ALIAS_CU}
    ${CPNRT}     Catenate     SEPARATOR=${SPACE}    ${Response1}   ${Response2}
    #should contain    ${CPNRT}    NetworkPlanUpdateRequired
    #should contain    ${CPNRT}    NetworkPlanUpdateConfirm
    KW.disconnect_CU_server

TC.CB007078_I_06_Message check between NRTS and Cplan for delta plan activation procedure
    #KW.OnlineModifyCUParameter
    KW.connect_CU_server
    ${Command1}    Set Variable
    ...       ns=${CU_namespace} && kubectl logs po-$ns-oamconfig-0 -c ctr-$ns-oamconfig -n $ns | grep -E 'NetworkPlanUpdate'
    ${Command2}    Set Variable
    ...       ns=${CU_namespace} && kubectl logs po-$ns-oamconfig-1 -c ctr-$ns-oamconfig -n $ns | grep -E 'NetworkPlanUpdate'
    ${Response1}      ssh.Execute      command=${Command1}     connection=${ALIAS_CU}
    ${Response2}      ssh.Execute      command=${Command2}     connection=${ALIAS_CU}
    ${CPOAM}     Catenate     SEPARATOR=${SPACE}     ${Response1}   ${Response2}
    #should contain    ${CPOAM}    NetworkPlanUpdateRequired
    #should contain    ${CPOAM}    NetworkPlanUpdateConfirm
    KW.disconnect_CU_server


TC.CB007078_F_03_Message check between NRTS and Cplan for initial configuration procedure
    KW.connect_CU_server
    ${Command1}    Set Variable
    ...     ns=${CU_namespace} && kubectl logs po-$ns-cpif-0 -c ctr-$ns-cpif -n $ns | grep -E 'F1LinkInfoUpdateInd'
    ${Command2}    Set Variable
    ...     ns=${CU_namespace} && kubectl logs po-$ns-cpif-1 -c ctr-$ns-cpif -n $ns | grep -E 'F1LinkInfoUpdateInd'
    ${Response1}       ssh.Execute      command=${Command1}     connection=${ALIAS_CU}
    ${Response2}       ssh.Execute      command=${Command2}     connection=${ALIAS_CU}
    ${CPIF}     Catenate     SEPARATOR=${SPACE}     ${Response1}   ${Response2}
    should contain    ${CPIF}    F1LinkInfoUpdateInd
    KW.disconnect_CU_server


TC.CB007078_M_10_Message check for internal plan update for CPNB
    KW.connect_CU_server
    ${Command1}    Set Variable
    ...     ns=${CU_namespace} && kubectl logs po-$ns-cpnb-0 -c ctr-$ns-cpnb -n $ns | grep -E 'NetworkPlanUpdate'
    ${Command2}    Set Variable
    ...     ns=${CU_namespace} && kubectl logs po-$ns-cpnb-1 -c ctr-$ns-cpnb -n $ns | grep -E 'NetworkPlanUpdate'
    ${Response1}       ssh.Execute      command=${Command1}     connection=${ALIAS_CU}
    ${Response2}       ssh.Execute      command=${Command2}     connection=${ALIAS_CU}
    ${CPNB}     Catenate     SEPARATOR=${SPACE}     ${Response1}   ${Response2}
    should contain    ${CPNB}    NetworkPlanUpdateRequired
    should contain    ${CPNB}    NetworkPlanUpdateConfirm
    KW.disconnect_CU_server


TC.CB007078_DGJKL_Message check for internal plan update
    [Documentation]  Will run case:
    ...      *********************Initial Plan&&Startup*********************************
    ...       D. CP-NB initial  plan activation
    ...           CpNbCm_ConfigurationReq/CpNbCm_ConfigurationResp
    ...           CpNbCm_NetworkPlanReq/CpNbCm_NetworkPlanResp
    ...           CpNbCm_PoolConfigurationReq/CpNbCm_PoolConfigurationResp
    ...       E.  vCU start-up CpNrtCm_ConfigurationReq/CpNrtCm_ConfigurationResp
    ...                     CpNrtCm_NetworkPlanReq/CpNrtCm_NetworkPlanResp
    ...                    CpNrtCm_PoolConfigurationReq/CpNrtCm_PoolConfigurationeResp
    ...       J. cell activation CpNbCm_CellConfigUpdateReq/CpNbCm_CellConfigUpdateResp
    ...            CpNbCm_CellStatusInd/CellStatusAck
    ...      *********************??*********************************
    ...       L. initial configuration  CpNrtCm_PoolConfigurationUpdateReq/CpNrtCm_PoolConfigurationUpdateResp
    ...      *********************Delta Plan**********************************************
    ...       G. CP-NB delta plan activation CpNbCm_NetworkPlanReq/CpNbCm_NetworkPlanResp
    ...       H. delta plan configuration CpNrtCm_NetworkPlanReq/CpNrtCm_NetworkPlanResp
    ...      ********************CuLink Operation*****************************************
    ...       K. CpNbCm_CuLinksBlockReq/CpNbCm_CuLinksUnBlockReq
    ${ns}    Set Variable    ${CU_namespace}
    KW.Reset_CU
    KW.Check_D_Msg      ns=${ns}
    KW.Check_E_Msg      ns=${ns}
    KW.Check_J_Msg      ns=${ns}
#    KW.Check_L_Msg      ns=${ns}
    #KW.OnlineModifyCUParameter
#    KW.Check_G_Msg      ns=${ns}
#    KW.Check_H_Msg      ns=${ns}
#    KW.Check_K_Msg      ns=${ns}

TC.CB007078_OPQ_HA_check
    [Documentation]  Will run case:
    ...      *********************Initial Plan&&Startup*********************************
    ...       OPQ, kill NRTS, CPNB, CPNRT service, check function
    ${ns}    Set Variable    ${CU_namespace}
#    ${Deploment_type}=     KW.Check_CU_Basic_Redundant
    @{cell}      create list    1
    KW.Check_NRTS_service_restart        ns=${ns}    cell_id_list=${cell}
    KW.Check_CPNB_service_restart        ns=${ns}    cell_id_list=${cell}
    KW.Check_CPNRT_service_restart       ns=${ns}    cell_id_list=${cell}

####Case Level Keywords#####
Setup Suite for CB007078
    log to console     Suite start
    Create Logs Folder For Test Case
    Import Variables       ${CFGFILE_PATH}TLConfiguration.py
    set suite variable     ${CASESTEP}    0
    set suite variable     ${MRBTS_ID}        MRBTS-${CASE_INPUT_CB007078['CB007078']['MRBTS_ID']}
    set suite variable     ${NRBTS_ID}        NRBTS-${CASE_INPUT_CB007078['CB007078']['NRBTS_ID']}
    KW.BackupSCF
#    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
#      ...    modified_cfgfile_CU=${LOG_PATH}/7078_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU1_GoldenSCF}
#      ...    modified_cfgfile_DU=${LOG_PATH}/7078_DU1_SCF.xml    ResourceFolder=${CURDIR}
#      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU    mo_to_add_CU=MOs_TO_ADD_CU
#      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU    list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU
#      ...    list_to_add_CU=LIST_TO_ADD_CU
#      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU    mo_to_add_DU=MOs_TO_ADD_DU
#      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU    list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY
#      ...    list_to_add_DU=LIST_TO_ADD_DU
    CU Verify All Cells Status Are Onair
#    KW.Cloud Commission And Check On Air For CB007078    CU_SCF=${LOG_PATH}/7078_CU_SCF.xml
    Conn.ResetCache

Teardown Suite for CB007078
    log to console     Suite teardown

Setup case for CB007078
    log to console     Case Start

Teardown case for CB007078
    run keyword and ignore error    CU Logout
    Run Keyword And Ignore Error    run    command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Conn.ResetCache
    log to console     Case teardown


KW.Cloud Commission And Check On Air For CB007078
    [Arguments]    ${CU_SCF}
    CU Full Commission Fix Error          path_of_commission_file=${CU_SCF}
    sleep    1min
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair


KW.BackupSCF
    CU Login      gnb_index=0    cu_version=cuoam_23r2
    ${time_stamp}=  Get Time   exclude_millis=yes
    ${time_stamp}=  replace string  ${time_stamp}  ${SPACE}  \
    ${time_stamp}=  replace string  ${time_stamp}  -   \
    ${time_stamp}=  replace string  ${time_stamp}  :   \
    ${backupscf}=   set variable    ${LOG_PATH}/${CU_namespace}CU_backupSCF_${time_stamp}.xml
    cu.get_current_plan_file    ${backupscf}
    [Return]     ${backupscf}
    [Teardown]   run keyword and ignore error   CU Logout


KW.connect_CU_server
    ssh.Connect to    hostname=${CU_ssh_IP}    username=${CU_username}
    ...  password=${CU_password}    alias=${ALIAS_CU}

KW.disconnect_CU_server
    run keyword and ignore error    ssh.disconnect    connection=${ALIAS_CU}

KW.Check_D_Msg
    [Documentation]  Will run 1 case:
    ...       D. CP-NB initial  plan activation
    ...           CpNbCm_ConfigurationReq/CpNbCm_ConfigurationResp
    ...           CpNbCm_NetworkPlanReq/CpNbCm_NetworkPlanResp
    ...           CpNbCm_PoolConfigurationReq/CpNbCm_PoolConfigurationResp
    [Arguments]    ${ns}
    KW.connect_CU_server
    ${Command1}   Catenate     SEPARATOR=${SPACE}
    ...     kubectl logs po-${ns}-oamconfig-1 -c ctr-${ns}-oamconfig -n ${ns} |
    ...     grep -E 'CpCm::Configuration|CpCm::NetworkPlan|CpCm::PoolConfiguration'
    ${Command2}    Catenate     SEPARATOR=${SPACE}
    ...     kubectl logs po-${ns}-oamconfig-0 -c ctr-${ns}-oamconfig -n ${ns} |
    ...     grep -E 'CpCm::Configuration|CpCm::NetworkPlan|CpCm::PoolConfiguration'
    ${Response1}      ssh.Execute      command=${Command1}     connection=${ALIAS_CU}
    ${Response2}      ssh.Execute      command=${Command2}     connection=${ALIAS_CU}
    ${CPNB}     Catenate     SEPARATOR=${SPACE}     ${Response1}   ${Response2}
#    should contain    ${CPNB}    CpCm::ConfigurationReq
#    should contain    ${CPNB}    CpCm::ConfigurationResp
#    should contain    ${CPNB}    CpCm::NetworkPlanReq
#    should contain    ${CPNB}    CpCm::NetworkPlanResp
#    should contain    ${CPNB}    CpCm::PoolConfigurationReq
#    should contain    ${CPNB}    CpCm::PoolConfigurationResp
    KW.disconnect_CU_server

KW.Check_G_Msg
    [Documentation]  Will run 1 case:
    ...       G. CP-NB delta plan activation CpNbCm_NetworkPlanReq/CpNbCm_NetworkPlanResp
    [Arguments]    ${ns}
    KW.connect_CU_server
    ${Command1}    Set Variable
    ...     kubectl logs po-${ns}-oamconfig-1 -c ctr-${ns}-oamconfig -n ${ns} | grep -E 'CpCm::NetworkPlan'
    ${Command2}    Set Variable
    ...     kubectl logs po-${ns}-oamconfig-0 -c ctr-${ns}-oamconfig -n ${ns} | grep -E 'CpCm::NetworkPlan'
    ${Response1}      ssh.Execute      command=${Command1}     connection=${ALIAS_CU}
    ${Response2}      ssh.Execute      command=${Command2}     connection=${ALIAS_CU}
    ${CPNB}     Catenate     SEPARATOR=${SPACE}     ${Response1}   ${Response2}
#    should contain    ${CPNB}    CpCm::NetworkPlanReq
#    should contain    ${CPNB}    CpCm::NetworkPlanResp
    KW.disconnect_CU_server

KW.Check_J_Msg
    [Documentation]  Will run 1 case:
    ...       J. cell activation  CpNbCm_CellConfigUpdateReq/CpNbCm_CellConfigUpdateResp
    ...            CpNbCm_CellStatusInd/CellStatusAck
    [Arguments]    ${ns}
    KW.connect_CU_server
    ${Command1}    Set Variable
    ...     kubectl logs po-${ns}-oamconfig-1 -c ctr-${ns}-oamconfig -n ${ns} | grep -E 'CpCm::NetworkPlan|CpCm::CellStatus'
    ${Command2}    Set Variable
    ...     kubectl logs po-${ns}-oamconfig-0 -c ctr-${ns}-oamconfig -n ${ns} | grep -E 'CpCm::NetworkPlan|CpCm::CellStatus'
    ${Response1}      ssh.Execute      command=${Command1}     connection=${ALIAS_CU}
    ${Response2}      ssh.Execute      command=${Command2}     connection=${ALIAS_CU}
    ${CPNB}     Catenate     SEPARATOR=${SPACE}     ${Response1}   ${Response2}
#    should contain    ${CPNB}    CpCm::NetworkPlanReq
#    should contain    ${CPNB}    CpCm::NetworkPlanResp
#    should contain    ${CPNB}    CpCm::CellStatusInd
#    should contain    ${CPNB}    CpCm::CellStatusAck
    KW.disconnect_CU_server

KW.Check_K_Msg
    [Documentation]  Will run 1 case:
    ...       K. CpNbCm_CuLinksBlockReq/CpNbCm_CuLinksUnBlockReq
    [Arguments]    ${ns}
    KW.connect_CU_server
    ${Command_CuLinksBlock}     Catenate     SEPARATOR=${SPACE}
    ...     ns=${ns} && kubectl exec -it -n $ns po-$ns-oamext-0 -c ctr-$ns-nwmgmt -- bash
    ...     -c "curl -X POST  "http://oam-cplaneconfig:9001/api/cp-config/v1/linksBlock""
    ${Command_CuLinksUnblock}     Catenate     SEPARATOR=${SPACE}
    ...     ns=${ns} && kubectl exec -it -n $ns po-$ns-oamext-0 -c ctr-$ns-nwmgmt -- bash
    ...     -c "curl -X POST  "http://oam-cplaneconfig:9001/api/cp-config/v1/linksUnblock""
    ${CuLinksBlock}      ssh.Execute
    ...    command=${Command_CuLinksBlock}
    ...    connection=${ALIAS_CU}
    should contain     ${CuLinksBlock}      Task is successful
    Sleep  30s
    ${CuLinksUnblock}      ssh.Execute
    ...    command=${Command_CuLinksUnblock}
    ...    connection=${ALIAS_CU}
    should contain     ${CuLinksUnblock}      Task is successful
    ${Command1}    Set Variable
    ...     kubectl logs po-${ns}-oamconfig-1 -c ctr-${ns}-oamconfig -n ${ns} | grep -E 'CpCm::CuLinks'
    ${Command2}    Set Variable
    ...     kubectl logs po-${ns}-oamconfig-0 -c ctr-${ns}-oamconfig -n ${ns} | grep -E 'CpCm::CuLinks'
    ${Response1}      ssh.Execute      command=${Command1}     connection=${ALIAS_CU}
    ${Response2}      ssh.Execute      command=${Command2}     connection=${ALIAS_CU}
    ${CPNB}     Catenate     SEPARATOR=${SPACE}     ${Response1}   ${Response2}
#    should contain    ${CPNB}    CpCm::CuLinksBlockReq
#    should contain    ${CPNB}    CpCm::CuLinksUnBlockReq
    wait until keyword succeeds  15min  30s     CU Verify All Cells Status Are Onair
    KW.disconnect_CU_server

KW.Check_L_Msg
    [Documentation]  Will run 1 case:
    ...       L. initial configuration  CpNrtCm_PoolConfigurationUpdateReq/CpNrtCm_PoolConfigurationUpdateResp
    [Arguments]    ${ns}
    KW.connect_CU_server
    ${Command1}    Set Variable
    ...     kubectl logs po-${ns}-oamconfig-1 -c ctr-${ns}-oamconfig -n ${ns} | grep -E 'CpNrtCm::PoolConfigurationUpdate'
    ${Command2}    Set Variable
    ...     kubectl logs po-${ns}-oamconfig-0 -c ctr-${ns}-oamconfig -n ${ns} | grep -E 'CpNrtCm::PoolConfigurationUpdate'
    ${Response1}      ssh.Execute      command=${Command1}     connection=${ALIAS_CU}
    ${Response2}      ssh.Execute      command=${Command2}     connection=${ALIAS_CU}
    ${CPNRT}     Catenate     SEPARATOR=${SPACE}     ${Response1}   ${Response2}
#    should contain    ${CPNRT}    CpNrtCm::PoolConfigurationUpdateReq
#    should contain    ${CPNRT}    CpNrtCm::PoolConfigurationUpdateResp
    Sleep   2min
    KW.disconnect_CU_server

KW.Check_E_Msg
    [Documentation]  Will run 1 case:
    ...       E.  vCU start-up CpNrtCm_ConfigurationReq/CpNrtCm_ConfigurationResp
    ...                     CpNrtCm_NetworkPlanReq/CpNrtCm_NetworkPlanResp
    ...                    CpNrtCm_PoolConfigurationReq/CpNrtCm_PoolConfigurationeResp
    [Arguments]    ${ns}
    KW.connect_CU_server
    ${Command1}    Catenate     SEPARATOR=${SPACE}
    ...     kubectl logs po-${ns}-oamconfig-1 -c ctr-${ns}-oamconfig -n ${ns} |
    ...     grep -E 'CpNrtCm::PoolConfiguration|CpNrtCm::Configuration|CpNrtCm::NetworkPlan'
    ${Command2}    Catenate     SEPARATOR=${SPACE}
    ...     kubectl logs po-${ns}-oamconfig-0 -c ctr-${ns}-oamconfig -n ${ns} |
    ...     grep -E 'CpNrtCm::PoolConfiguration|CpNrtCm::Configuration|CpNrtCm::NetworkPlan'
    ${Response1}      ssh.Execute      command=${Command1}     connection=${ALIAS_CU}
    ${Response2}      ssh.Execute      command=${Command2}     connection=${ALIAS_CU}
    ${CPNRT}     Catenate     SEPARATOR=${SPACE}     ${Response1}   ${Response2}
#    should contain    ${CPNRT}    CpNrtCm::NetworkPlanReq
#    should contain    ${CPNRT}    CpNrtCm::NetworkPlanResp
#    should contain    ${CPNRT}    CpNrtCm::PoolConfigurationReq
#    should contain    ${CPNRT}    CpNrtCm::PoolConfigurationResp
#    should contain    ${CPNRT}    CpNrtCm::ConfigurationReq
#    should contain    ${CPNRT}    CpNrtCm::ConfigurationResp
    Sleep   2min
    KW.disconnect_CU_server

KW.Check_H_Msg
    [Documentation]  Will run 1 case:
    ...       H. delta plan configuration CpNrtCm_NetworkPlanReq/CpNrtCm_NetworkPlanResp
    [Arguments]    ${ns}
    KW.connect_CU_server
    ${Command1}    Catenate     SEPARATOR=${SPACE}
    ...     kubectl logs po-${ns}-oamconfig-1 -c ctr-${ns}-oamconfig -n ${ns} |
    ...     grep -E 'CpNrtCm::NetworkPlan'
    ${Command2}    Catenate     SEPARATOR=${SPACE}
    ...     kubectl logs po-${ns}-oamconfig-0 -c ctr-${ns}-oamconfig -n ${ns} |
    ...     grep -E 'CpNrtCm::NetworkPlan'
    ${Response1}      ssh.Execute      command=${Command1}     connection=${ALIAS_CU}
    ${Response2}      ssh.Execute      command=${Command2}     connection=${ALIAS_CU}
    ${CPNRT}     Catenate     SEPARATOR=${SPACE}     ${Response1}   ${Response2}
#    should contain    ${CPNRT}    CpNrtCm::NetworkPlanReq
#    should contain    ${CPNRT}    CpNrtCm::NetworkPlanResp
    Sleep   2min
    KW.disconnect_CU_server

KW.Reset_CU
    CU Rest Login    gnb_index=0    cu_version=cuoam_25r1
    ${Reset_Status}=   cu.reset_cu
    CU Rest Logout
    wait until keyword succeeds  15min  30s     CU Verify All Cells Status Are Onair
    [Teardown]  run keyword and ignore error    CU Logout

KW.OnlineModifyCUParameter
    ${Parameter1}     Create Dictionary  operation_type=replace
    ...                                  parameter_path=/addHystSfHigh
    ...                                  value=dB-6
    ${Parameter2}     Create Dictionary  operation_type=replace
    ...                                  parameter_path=/addHystSfHigh
    ...                                  value=dB-2
    @{ParameterList}      create list    ${Parameter1}
    @{ParameterList2}      create list    ${Parameter2}
    CU Login
    Run keyword and ignore error     CU Online Parameter Change by rest    para_list=@{ParameterList}
    ...                                   mo_dn=${MRBTS_ID}/${NRBTS_ID}/NRSYSINFO_PROFILE-1
    CU Online Parameter Change by rest    para_list=@{ParameterList2}
    ...                                   mo_dn=${MRBTS_ID}/${NRBTS_ID}/NRSYSINFO_PROFILE-1
    [Teardown]  run keyword and ignore error    CU Logout

KW.Check_NRTS_service_restart
    [Documentation]  Will run 1 case, NRTS_service_restart and cell lock
    [Arguments]    ${ns}     ${cell_id_list}
    KW.connect_CU_server
    ${Command}     Catenate     SEPARATOR=${SPACE}
    ...    ns=${ns} && kubectl delete pod -n $ns po-$ns-oamconfig-0 --grace-period=0 --force &&
    ...    kubectl delete pod -n $ns po-$ns-oamconfig-1 --grace-period=0 --force
    ssh.Execute
    ...    command=${Command}
    ...    connection=${ALIAS_CU}
    sleep   5s
    CU Lock Cells           cell_id_list=${cell_id_list}
    CU Unlock Cells         cell_id_list=${cell_id_list}
    KW.disconnect_CU_server
#   [Teardown]  run keyword and ignore error    CU Unlock Cells  cell_id_list=${cell_id_list}

KW.Check_CPNB_service_restart
    [Documentation]  Will run 1 case, CPNB_service_restart and cell lock
    [Arguments]    ${ns}     ${cell_id_list}
    KW.connect_CU_server
    ${Command}     Catenate     SEPARATOR=${SPACE}
    ...    ns=${ns} && kubectl delete pod -n $ns po-$ns-cpnb-0 --grace-period=0 --force &&
    ...    kubectl delete pod -n $ns po-$ns-cpnb-1 --grace-period=0 --force
    ssh.Execute
    ...    command=${Command}
    ...    connection=${ALIAS_CU}
    sleep   5s
    CU Lock Cells         cell_id_list=${cell_id_list}
    CU Unlock Cells         cell_id_list=${cell_id_list}
    KW.disconnect_CU_server
#   [Teardown]  run keyword and ignore error    CU Unlock Cells  cell_id_list=${cell_id_list}

KW.Check_CPNRT_service_restart
    [Documentation]  Will run 1 case, CPNRT_service_restart and cell lock
    [Arguments]    ${ns}     ${cell_id_list}
    KW.connect_CU_server
    ${Command}     Catenate     SEPARATOR=${SPACE}
    ...    ns=${ns} && kubectl delete pod -n $ns po-$ns-cpnrt-0 --grace-period=0 --force &&
    ...    kubectl delete pod -n $ns po-$ns-cpnrt-1 --grace-period=0 --force
    ssh.Execute
    ...    command=${Command}
    ...    connection=${ALIAS_CU}
    sleep   5s
    CU Lock Cells         cell_id_list=${cell_id_list}
    CU Unlock Cells        cell_id_list=${cell_id_list}
    KW.disconnect_CU_server
#   [Teardown]  run keyword and ignore error    CU Unlock Cells  cell_id_list=${cell_id_list}

KW.Check_CU_Basic_Redundant
    KW.connect_CU_server
    ${Output}      ssh.Execute
    ...    command=kubectl exec -it -n ${ns} po-${ns}-cpnb-1 -c ctr-${ns}-cpnb -- bash -c "ps -ef"
    ...    connection=${ALIAS_CU}
    ${result}=    Run Keyword And Return Status     should contain    ${Output}    Error from server (NotFound)
    ${Deploment_type}     Set Variable If
    ...           '${result}'=='true'     Basic
    ...           '${result}'=='false'    Redundant
    KW.disconnect_CU_server
    [Return]    ${Deploment_type}