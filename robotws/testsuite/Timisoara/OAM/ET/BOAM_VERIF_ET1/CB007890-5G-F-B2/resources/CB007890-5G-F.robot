*** Settings ***

Library        String
Library        OperatingSystem
Library        Process
Library        taf.transport.ssh   WITH NAME    taf_ssh
Library        taf.gnb.oam.coam.admin.interface.admin   WITH NAME   taf_admin
#Library        taf.sw.ping      WITH NAME   taf_ping
Library        DateTime

Resource          ../../vduResourcesAIC/vdu_oam_cm.robot
Resource          ../../vduResourcesAIC/common_setup_teardown.robot
Resource          ../../vduResourcesAIC/aic_common_resources.robot
Resource          ../../vduResourcesAIC/fm.robot
Resource          ../../vduResourcesAIC/aic_common_vcu_resources.robot
Resource          ../../vduResourcesAIC/cu_oam_state.robot
Resource          ../../CB007800-H/resources/CB007800-H.robot
Resource          ../../CB007800-H/resources/xpath_7800-H.robot

*** Variables ***
${G_VDU_NAME}         vcu25
${CLUSTER_NAME}       ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
${G_OAM_PODS_NAME}    po-${CLUSTER_NAME}-oamcm-0
${G_vDUOAM_PODS_NAME}    po-${CLUSTER_NAME}-oam-0
${G_CPRT_PODS_NAME}   po-${CLUSTER_NAME}-cprt-0
${G_USER}             core
${SCF_PATH}           ${tl.gnbs[0].dus[0].cloud_deployment.default_cfg_dir}/cran8.xml
${NEW_YAML}           ${tl.gnbs[0].dus[0].cloud_deployment.default_cfg_dir}/kuafu_vcu_config.ini
${OAM_IP}             ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
${WEBUI_URL}          https://${tl.gnbs[0].dus[0].oam_http_connection_details.addr}/dashboard
${WEBUI_USER}         Nemuadmin
${WEBUI_PASSWORD}     nemuuser
${MRBTS_ID}           1
${NRBTS_ID}           1

*** Keywords ***
vCU_Fault_4592_BTS_precommissioned
    Step1 Restart CU In WebEM
    Step2 Check alarm

Step1 Restart CU In WebEM
#    CU WEBEM LOGIN
    Login vCU Webem
    Reset CU By REST
    Verify all CU containers are running
#    CU WEBEM LOGOUT

Step2 Check alarm
    log to console  Step 2:Check alarm
    Uncommissioned VCU Check fault 4592 was triggered  user request

Uncommissioned VCU Check fault 4592 was triggered
    [Arguments]     ${last_reset_reason}
    log to console  \n Check fault 4592 was triggered
    Check last BTS restart from HC
    Login vCU Webem
    wait until keyword succeeds  2min  30s    VCU Check Historical Alarm Should Contain Fault  4592
    ${alarm_list}    VCU Get Historical Alarm Fault by REST API
    should contain    '@{alarm_list}'    'alarm_id': 7115
    should contain    '@{alarm_list}'    'alarm_name': 'BASE STATION INFORMATION'
    should contain    '@{alarm_list}'    'fault_name': 'BTS Reset Cause'
    should contain    '@{alarm_list}'    'alarming_object': 'MRBTS'
    should contain    '@{alarm_list}'
    ...               'additional_info': 'supplAlarmInfo=BTS booted at ${RST_TIMESTAMP} due to ${last_reset_reason}; affected_cells=NR:unknown;'
    log to console    Fault ${4592} was successfully raised after vCU site reset!

Generate fault 4001 when vCU is precommissioned
    log to console  /n Trigger OAM recovery for 3 times
    repeat keyword   3 times   OAM recovery reset when VCU is uncommissioned
    log to console  /n Trigger fault 4001
    Trigger fault 4001

OAM recovery reset when VCU is uncommissioned
    Log To Console  \n ...Trigger OAM recovery reset...
#    CB007800-H.Login SSH
#    SSHLibrary.Write  nohup watch -n 0 kubectl delete pod po-${CRANNAME}-upue-0 -n ${CRANNAME} --grace-period=0 &
#    SSHLibrary.Write  nohup watch -n 0 kubectl delete pod po-${CRANNAME}-upue-1 -n ${CRANNAME} --grace-period=0 &
#    SSHLibrary.Write  nohup watch -n 0 kubectl delete pod po-${CRANNAME}-upue-2 -n ${CRANNAME} --grace-period=0 &
    Login vCU Webem
    Crash all UPUE pods
    wait until keyword succeeds  2min  5s    Fault 4350 with recovery reset and VCU Uncommissioned
    Verify all CU containers are running  #Verify All Pods Are Running
    Uncommissioned VCU Check fault 4592 was triggered  oam recovery reset

Fault 4350 with recovery reset and VCU Uncommissioned
    #    wait until keyword succeeds  2min  5s   VCU Check Active Alarm Should Contain Fault   '4350'
    ${alarm_list}    VCU Get Active Alarm Fault by REST API
    should contain    '@{alarm_list}'    'fault_id': '4350'
    should contain    '@{alarm_list}'    'alarm_id': 7101
    should contain    '@{alarm_list}'    'alarm_name': 'BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION'
    should contain    '@{alarm_list}'    'fault_name': 'BTS site autonomous reset as recovery action'
    should not contain    '@{alarm_list}'    'alarming_object': 'MRBTS'

Fault 4001 when VCU is uncommissioned
    Login vCU Webem
    ${alarm_list}    VCU Get Active Alarm Fault by REST API
    should contain    '@{alarm_list}'    'fault_id': '4001'
    should contain    '@{alarm_list}'    'alarm_id': 7116
    should contain    '@{alarm_list}'    'alarm_name': 'BASE STATION SERVICE PROBLEM'
    should contain    '@{alarm_list}'    'fault_name': 'BTS reset required'
    should contain    '@{alarm_list}'    'alarming_object': 'MRBTS'

Trigger fault 4001
#    SSHLibrary.Write  nohup watch -n 0 kubectl delete pod po-${CRANNAME}-upue-0 -n ${CRANNAME} --grace-period=0 &
#    SSHLibrary.Write  nohup watch -n 0 kubectl delete pod po-${CRANNAME}-upue-1 -n ${CRANNAME} --grace-period=0 &
#    SSHLibrary.Write  nohup watch -n 0 kubectl delete pod po-${CRANNAME}-upue-2 -n ${CRANNAME} --grace-period=0 &
    Login vCU Webem
    Crash all UPUE pods
    Wait until keyword succeeds   2min  5s   Fault 4001 when VCU is uncommissioned
    log to console    Fault ${4001} was successfully raised after three OAM recovery reset!
#    CU Alarm Should Not Exist In Active Alarms  fault_id=4350  fault_name=BTS site autonomous reset as recovery action
#        ...               alarm_id=7101  alarm_name=BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION

Clear fault 4001
    log to console  \n Clear fault 4001
    Login vCU Webem
    Reset CU By REST
    Verify all CU containers are running  #Verify All Pods Are Running
    Log to console    Check if fault 4001 is not active
    Login vCU Webem
    ${alarm_list}    VCU Get Active Alarm Fault by REST API
    should not contain    '@{alarm_list}'    'fault_id': '4001'
    should not contain    '@{alarm_list}'    'alarm_id': 7116
    should not contain    '@{alarm_list}'    'alarm_name': 'BASE STATION SERVICE PROBLEM'
    should not contain    '@{alarm_list}'    'fault_name': 'BTS reset required'
    should not contain    '@{alarm_list}'    'alarming_object': 'MRBTS'
#    CU Alarm Should Not Exist In Active Alarms  fault_id=4001  fault_name=BTS reset required
#        ...               alarm_id=7116  alarm_name=BASE STATION SERVICE PROBLEM
    log to console  \n Fault ${4001} is succesfully cleared after vCU site reset!

Fault_4695_N+_cancelation_commissioned
    [Arguments]     ${gnb_index}=0
    log to console  \n  Trigger fault 4695 when vCU is uncommissioned
    Trigger fault 4695   cpue   cpue    cpue
    Trigger fault 4695   upue   l2hicu   l2hi
    VCU Uncommissioned check fault 4695 is raised in webEM
#    scf.Save_Scf  file_path=${scf_updated}
    ${scf_path}   OperatingSystem.Join Path    ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}   ${SCF_FILE}
    Commission VCU with SCF file     ${scf_path}   ${SCF_FILE}
#    vCU Full Commission
    wait until keyword succeeds   10 min   30s     VCU commissioned check fault 4695 is raised in webEM

Trigger fault 4695
    [Arguments]   ${pod}   ${ctr}  ${img}
    log to console  \n Fail ${pod} pods
    ${cmd1}=  catenate  SEPARATOR=   kubectl patch pod po-${CRANNAME}-${pod}-1 -n ${CRANNAME} -p '{"spec":{"containers":[{"name":"ctr-${CRANNAME}-
     ...     ${ctr}","image":"image-registry.openshift-image-registry.svc:5000/${CRANNAME}/${img}:0.250.4242-fail"}]}}'
    ${cmd2}=  catenate  SEPARATOR=   kubectl patch pod po-${CRANNAME}-${pod}-2 -n ${CRANNAME} -p '{"spec":{"containers":[{"name":"ctr-${CRANNAME}-
    ...      ${ctr}","image":"image-registry.openshift-image-registry.svc:5000/${CRANNAME}/${img}:0.250.4242-fail"}]}}'
    log to console    ${cmd1}
    log to console    ${cmd2}
    vCU Cluster Login With Admin
    tafssh.Execute    command=${cmd1}
    tafssh.Execute    command=${cmd2}
    [Teardown]    helm.helm_master_close

Commission VCU with SCF file
    [Arguments]   ${NEW_SCF}  ${plan_name}
    [Documentation]   It commissions the vCU with the SCF file when 2 CPUE pods and 2 UPUE pods are crashed

    Check vCU Maximum Plan Number And Delete One If Reach Maximum Number    #########this keyword should be verify
    VCU Full Commssion when CPUE and UPUE pods are crashed  path_of_commission_file=${NEW_SCF}  plan_name=${plan_name}  gnb_index=0

VCU Full Commssion when CPUE and UPUE pods are crashed
    [Arguments]    ${path_of_commission_file}   ${plan_name}  ${gnb_index}=0
    [Documentation]   Send BTS commission via rest.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  path_of_commission_file  | Yes. | Path of commission file |
        ...	   |  plan_name  | Yes. |   Plan file name displayed on weebui after scf load   |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Full Commssion By Rest  |   /tmp/commission.xml  |    3219_plan_file   |
     CU Login  ${gnb_index}
     log to console   \n*** Start plan upload operation ***
     ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}   plan_name=${plan_name}
     log to console   \n*** Wait plan upload operation success ***
     wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
     ...    ${upload_operation_info["action_id"]}    success
     log to console   \n*** Start plan validate operation ***
     ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
     log to console   \n*** Wait plan validate operation success ***
     wait until keyword succeeds    60s   5s  CU Check Plan Validate Status Should Be As Expected
     ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
     log to console   \n*** Start plan activate operation ***
     ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
     log to console   \n*** Wait until CPUE and UPUE pods are running and crash them again ***
     run keyword and ignore error    CU Check Plan Activate Status Should Be As Expected
     ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success
    @{cpue_pod_list}     create list     cpue-0   cpue-1   cpue-2
    FOR  ${pod}  IN  @{cpue_pod_list}
        Check if VCU pods are running   ${pod}
    END
    Trigger fault 4695   cpue   cpue    cpue
    @{upue_pod_list}     create list     upue-0   upue-1   upue-2
    FOR  ${pod}  IN  @{upue_pod_list}
        Check if VCU pods are running   ${pod}
    END
    CU Login  ${gnb_index}
    Trigger fault 4695   upue   l2hicu   l2hi
    log to console   \n*** Wait plan activate operation success in 20 mins ***
    wait until keyword succeeds    20min   30s  CU Check Plan Activate Status Should Be As Expected
     ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success
     [Teardown]    run keyword and ignore error   CU Logout

Check if VCU pods are running
    [Arguments]     ${pod}
    ${alias_cu}=    Connect To CU K8S Master With Admin
    wait until keyword succeeds    15min  10s     CU Pods Status Should Be Normal  ${pod}  alias=${alias_cu}

VCU Uncommissioned check fault 4695 is raised in webEM
    log to console  \n Check if fault 4695 is raised in webEM when vCU is uncommissioned
    Login vCU Webem
    wait until keyword succeeds    2min    5s       VCU Check Active Alarm Should Contain Fault   4695
    wait until keyword succeeds    2min    5s       Fault 4695 is raised when VCU is uncommissioned
    log to console    Fault 4695 was successfully raised!

Fault 4695 is raised when VCU is uncommissioned
    ${alarm_list}    VCU Get Active Alarm Fault by REST API
    should contain    '@{alarm_list}'    'fault_id': '4695'
    should contain    '@{alarm_list}'    'alarm_id': 7115
    should contain    '@{alarm_list}'    'alarm_name': 'BASE STATION INFORMATION'
    should contain    '@{alarm_list}'    'fault_name': 'gNB Capacity Degraded'
    should contain    '@{alarm_list}'    'severity': 'minor'
    should contain    '@{alarm_list}'    'alarming_object': 'NRBTS'

VCU commissioned check fault 4695 is raised in webEM
    log to console  \n Check if fault 4695 is raised in webEM when VCU is commissioned
    Login vCU Webem
    Fault 4695 is raised when VCU is commissioned
    log to console    Fault 4695 was successfully raised!

Fault 4695 is raised when VCU is commissioned
    ${alarm_list}    VCU Get Active Alarm Fault by REST API
    should contain    '@{alarm_list}'    'fault_id': '4695'
    should contain    '@{alarm_list}'    'alarm_id': 7115
    should contain    '@{alarm_list}'    'alarm_name': 'BASE STATION INFORMATION'
    should contain    '@{alarm_list}'    'fault_name': 'gNB Capacity Degraded'
    should contain    '@{alarm_list}'    'severity': 'minor'
    should contain    '@{alarm_list}'    'alarming_object': 'MRBTS-1/NRBTS-1'
    should not contain    '@{alarm_list}'    'alarming_object': 'NRBTS'

Clear fault 4350 and fault 4695
    @{pods_list}   create list     cpue-1    cpue-2   upue-1   upue-2
    vCU Cluster Login With Admin
    FOR  ${pod}  IN  @{pods_list}
        Log to console    \n   Delete ${pod} pod
        tafssh.Execute    command=oc delete pod po-${CRANNAME}-${pod} -n ${CRANNAME}
    END
    wait until keyword succeeds    2min    30s     Verify all CU containers are running  #Verify All Pods Are Running
    Login vCU Webem
    ${alarm_list}    VCU Get Active Alarm Fault by REST API
    should not contain    '@{alarm_list}'    'fault_id': '4350'
    should not contain    '@{alarm_list}'    'alarm_id': 7116
    should not contain    '@{alarm_list}'    'alarm_name': 'BASE STATION SERVICE PROBLEM'
    should not contain    '@{alarm_list}'    'fault_name': 'VNFC unavailable'
#    should not contain    '@{alarm_list}'    'severity': 'major'
    should not contain    '@{alarm_list}'    'alarming_object': 'MRBTS'
    should not contain    '@{alarm_list}'    'fault_id': '4695'
    should not contain    '@{alarm_list}'    'alarm_id': 7115
    should not contain    '@{alarm_list}'    'alarm_name': 'BASE STATION INFORMATION'
    should not contain    '@{alarm_list}'    'fault_name': 'gNB Capacity Degraded'
    should not contain    '@{alarm_list}'    'severity': 'minor'
#    should not contain    '@{alarm_list}'    'alarming_object': 'MRBTS-1/NRBTS-1'
#    wait until keyword succeeds    3min    15s     CU Alarm Should Not Exist In Active Alarms
#            ...               fault_id=4695  fault_name=gNB Capacity Degraded
#            ...               alarm_id=7115   alarm_name=BASE STATION INFORMATION
#    wait until keyword succeeds    3min    15s     CU Alarm Should Not Exist In Active Alarms
#            ...               fault_id=4350  fault_name=VNFC unavailable
#            ...               alarm_id=7116   alarm_name=BASE STATION SERVICE PROBLEM
    log to console    Fault 4695 and fault 4350 were successfully cleared!
