*** Settings ***
Documentation
...          	author:  tong,weichao
...          	contact: weichao.tong@nokia-sbell.com
...          	description: env health check
Library         taf.hw.rf_attenuator    WITH NAME    att
Library      	BuiltIn
Library         ute_admin_infomodel
Library         OperatingSystem
Library         Collections
Library         String
Library      	taf.transport.ssh                     WITH NAME    ssh
Library      	taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library      	taf.sbts.oam.coam.admin                WITH NAME    coam
Library      	taf.gnb.oam.coam.cu                   WITH NAME    coam_cu
Library         taf.ul.vdu.helm.interface.helm   WITH NAME    helm
Library      	${CURDIR}/../SRAN/resources/python/TestCaseRequirement.py
Library      	${CURDIR}/../SRAN/resources/python/QTListener.py
Library         ${CURDIR}/../SRAN/resources/python/common.py
Library         ${CURDIR}/../SRAN/resources/python/plugin.py
Library         ${CURDIR}/../SRAN/resources/python/classical_keywords.py
Library         ${CURDIR}/../SRAN/resources/python/attenuator.py
Resource        ${CURDIR}/../SRAN/resources/robot/classical_keywords.robot
Resource        ${CURDIR}/../SRAN/resources/robot/common_l3call.robot
Resource        ${CURDIR}/../SRAN/resources/robot/allowed_alarms.robot
Resource        ${CURDIR}/../SRAN/resources/robot/common_variables.robot
Resource        ${CURDIR}/../SRAN/resources/robot/common.robot
Resource        ${CURDIR}/../SRAN/resources/robot/AIC_common_keywords.robot

Suite Setup        Run Keyword And Ignore Error     Env Health Check Setup
Suite Teardown     Run Keyword And Ignore Error    Env Health Check Teardown

*** Variables ***
${config_query}         [Oo]n[Aa]ir|[Ii]ntegrated[Tt]o[Rr]an|[Cc]onfigured
${specified_cmd}
${OC_VERSION_CU_DU}
${EXECUTE_CMD_CU_DU}
${battery_threshold}    30
@{skip_cpc_check_list}    huawei_router
@{skip_adb_check_ue_list}    quectel    simcom
@{proxy_ue_type_list}    android    quectel    simcom    askey

*** Test Cases ***
Check Site Onair
    [Tags]    ONAIR_CALL    ONAIR    CU    vCU_VNF   CellOnAir    DU_FULL    ONAIR_CALL_5G    ONAIR_CALL_4G
    ...       ONAIR_CALL_CM    ONAIR_CALL_MRAT    Clean_DEPL_to_CALL_4G
    ...       ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...       ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T
    ...       CNF_LCM_ONAIR_CALL_5G
    [Timeout]    6 min
    IF    '300' in '${stream}'
        Run Keyword and continue on failure    Check Vdu Onair
    ELSE
        Run Keyword and continue on failure    Check Classical Onair
    END
    Check enb Onair

Check Ue Status
    [Tags]    ONAIR_CALL    ATT_DT    TELECOM
    ...       ONAIR_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT    Clean_DEPL_to_CALL_4G
    ...       ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...       ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    ...       CNF_LCM_ONAIR_CALL_5G
    [Timeout]    8 min
    &{cpc_dict}    Create Dictionary
    ${ue_types_list}    Create List
    FOR  ${ue}  IN  @{tl.ues}
        IF    '${ue.ue_type}'=='fastmile'
            Check Fastmile Status    device=${ue}
        ELSE IF    '${ue.ue_type}' not in ${skip_cpc_check_list}
            ${cpc_addr}=        Get Variable Value    ${ue.ssh_connection_details.addr}    ${ue.ue_pc_address}
            ${cpc_username}=    Get Variable Value    ${ue.ssh_connection_details.username}    ${ue.ue_pc_login}
            ${cpc_password}=    Get Variable Value    ${ue.ssh_connection_details.password}    ${ue.ue_pc_password}
            IF    '${ue.ue_type}' in ${skip_adb_check_ue_list}
                Log To Console      Skip adb check for ${ue.ue_type}
            ELSE
                Log to Console      \n\t#################### UE ENV HEALTH CHECK FOR ${ue.serial_number} ####################\n
                check_and_recover_ue_devices    host=${cpc_addr}
                ...                             username=${cpc_username}
                ...                             password=${cpc_password}
                ...                             device=${ue.serial_number}   ue_type=${ue.ue_type}
                check_battery_level_below_threshold    host=${cpc_addr}
                ...                             username=${cpc_username}
                ...                             password=${cpc_password}
                ...                             device=${ue.serial_number}   threshold=${battery_threshold}
            END
            ${cpc_addr_list}    Get Dictionary keys    ${cpc_dict}
            IF     '${ue.ue_type}'=='android'
                Check And Upgrade NAA Plugin Version
                ...    cpc_addr=${cpc_addr}
                ...    cpc_username=${cpc_username}
                ...    cpc_password=${cpc_password}
                ...    device_model=${ue.serial_number}
            END
            IF    '${cpc_addr}' in ${cpc_addr_list}
                Log To Console    ${cpc_addr} has been checked, skip kill sshd process in CPC
                IF    '${ue.ue_type}' not in ${ue_types_list}
                    Append To List    ${ue_types_list}    ${ue.ue_type}
                    Set To Dictionary    ${cpc_dict}    ${cpc_addr}=${ue_types_list}
                    Plugin UE Healthy Check    ue=${ue}
                END
            ELSE
                Connect to controlPC
                ...    cpc_addr=${cpc_addr}
                ...    cpc_username=${cpc_username}
                ...    cpc_password=${cpc_password}
                ...    alias=cpc
                Append To List    ${ue_types_list}    ${ue.ue_type}
                Set To Dictionary    ${cpc_dict}    ${cpc_addr}=${ue_types_list}
                Get CPC OS
                ...    cpc_addr=${cpc_addr}
                ...    cpc_username=${cpc_username}
                ...    cpc_password=${cpc_password}
                IF   '${cpc_type}'=='Windows'
                    check_and_recover_if_cygwin_disabled
                    ...    cpc_addr=${cpc_addr}
                    ...    cpc_username=${cpc_username}
                    ...    cpc_password=${cpc_password}
                    Kill sshd process in controlPC   cpc
                END
                Plugin UE Healthy Check    ue=${ue}
            END
        END
    END
    ${pa_status}    Run Keyword If    '${site}'=='WRO'    Run Keyword And Return Status    Variable Should Exist    ${tl.attenuation}
    ...                 ELSE    Get Variable Value    ${tl.attenuator.ip_addr}    ${False}
    IF    '${pa_status}'=='False'
        Log To Console    test line doesn't have PA
    ELSE
        Wait Until Keyword Succeeds    5x    1 min    Check PA reachable
    END
    Check If Appserver Is Pingable
    [Teardown]    Run Keywords  Run Keyword And Ignore Error    ssh.disconnect    connection=cpc
    ...            AND  Run Keyword And Ignore Error    ssh.reset_cache

Perform Commands on CuDu
    [Tags]    EXECUTE_CMD
    Execute Commands on CuDu  ${EXECUTE_CMD_CU_DU}  ${specified_cmd}

Check OC version
    [Tags]    OC_VERSION
    @{OC_VERSION_CU_DU}    Split String  ${OC_VERSION_CU_DU}  ,
    FOR  ${unit}  IN  @{OC_VERSION_CU_DU}
        IF   ${is_LTE} and '${unit}'=='CU'    CONTINUE
        ssh.Connect to   hostname=${${unit}_k8s_addr}   username=${${unit}_k8s_user}
        ...    password=${${unit}_k8s_pwd}  alias=RM_alias
        ${output}=    ssh.execute
        ...    command=oc get nokiaclusters.nokia.com -o yaml |grep -i '${SPACE}${SPACE}NokiaRelease'
        ...    connection=RM_alias
        ${output}=  strip string  ${output}
        ${has_nokia_cluster}=  Run Keyword And Return Status    Should Not Contain    ${output}  error
        ${oc_version}=    Run Keyword If    ${has_nokia_cluster}    set Variable  ${output}
        ...    ELSE
        ...    ssh.execute
        ...    command=oc version
        ...    connection=RM_alias
        Log To Console    \nOC Version on ${unit}:
        log    ${oc_version}    console=true
        IF    'ocp' in """${output}"""
            Append To file
            ...    ${OUTPUT_DIR}/../../cloud_components_info_${node}.txt    OC Version on ${unit}: ${oc_version.split(':')[-1].strip()}\n
        END
    END


Check FHGW version
    [Tags]    FHGW_VERSION
    Import Library    taf.hw.fhgw.cli    WITH NAME    FHGW_SSH
    IF   not ${FHGW_Exist}
        Log     -->Testline doesn't have FHGW, skip FHGW related checking!
    ELSE
        FHGW_SSH.Connect To    ip=${FHGW_IP}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}
        ${output}=    FHGW_SSH.Execute    fhgwcli swm show status    check_result=${False}
        ${is_cmd_not_supported}=    Run Keyword And Return Status    Should Contain    ${output}    is not a fhgwcli command
        ${output}=     Run Keyword If    ${is_cmd_not_supported}
        ...    FHGW_SSH.Execute    fhgwcli swm show node    check_result=${False}
        ...    ELSE    Set Variable    ${output}
        Log To Console      \nSW version:
        log    \n${output}    console=true
        ${FHGW_version}    Get Lines Containing String    ${output}    SW release    ignore_case=True
        Append To File
        ...    ${OUTPUT_DIR}/../../cloud_components_info_${node}.txt
        ...    FHGW SW version: ${FHGW_version.replace('|', '').split()[-1].strip()}\n
    END


Check Rannic Version
    [Tags]    RANNIC   NOP_VERSION
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ${output}=    ssh.execute
    ...    command=helm list -n ran-nic-sw-controller|awk 'NR==2'|awk '{print $9}'
    ...    connection=RM_alias
    Log To Console      \nRannic version:
    log    \n${output}    console=true
    IF    'ran-nic-sw-controller' in """${output}"""
        Append To file
        ...    ${OUTPUT_DIR}/../../cloud_components_info_${node}.txt
        ...    RANNIC version: ${output.strip().replace('controller-', 'controller_').replace("-amd64", "")}\n
    END


Check Sync Operator Version
    [Tags]    SYNC    NOP_VERSION
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ${output}=    ssh.execute
    ...    command=helm list -n nokia-sync-operator|awk 'NR==2'|awk '{print $9}'
    ...    connection=RM_alias
    Log To Console      \nSync Operator version:
    log    \n${output}    console=true
    IF    'nokia-sync-operator' in """${output}"""
        Append To File
        ...    ${OUTPUT_DIR}/../../cloud_components_info_${node}.txt
        ...    SYNC OPERATOR version: ${output.strip().replace('operator-', 'operator_').replace("-amd64", "")}\n
    END

Check Koredump Operator Version
    [Tags]    KOREDUMP    NOP_VERSION
    @{OC_VERSION_CU_DU}    Split String  ${OC_VERSION_CU_DU}  ,
    FOR    ${unit}    IN    @{OC_VERSION_CU_DU}
        ssh.Connect to   hostname=${${unit}_k8s_addr}   username=${${unit}_k8s_user}
        ...    password=${${unit}_k8s_pwd}  alias=RM_alias
        ${koredump_ns}    Get Koredump Operator namespace
        ${output}=    ssh.execute
        ...    command=helm list -n ${koredump_ns}|awk 'NR==2'|awk '{print $9}'
        ...    connection=RM_alias
        Log To Console    \nKoredump Operator Version On ${unit}:
        log    \n${output}    console=true
        IF    'koredump-operator' in """${output}"""
            Append To File
            ...    ${OUTPUT_DIR}/../../cloud_components_info_${node}.txt
            ...    Koredump Operator Version On ${unit}: ${output.strip().replace('operator-', 'operator_')}\n
        END
    END
    [Teardown]

Check CNF LCM Operator Version
    [Tags]    CNF_LCM    NOP_VERSION
    @{OC_VERSION_CU_DU}    Split String  ${OC_VERSION_CU_DU}  ,
    FOR    ${unit}    IN    @{OC_VERSION_CU_DU}
        ssh.Connect to   hostname=${${unit}_k8s_addr}   username=${${unit}_k8s_user}
        ...    password=${${unit}_k8s_pwd}  alias=RM_alias
        ${output}=    ssh.execute
        ...    command=helm list -n cnf-lcm-operator|awk 'NR==2'|awk '{print $9}'
        ...    connection=RM_alias
        Log To Console    \nCNF LCM Operator Version On ${unit}:
        log    \n${output}    console=true
        IF    'cnf-lcm-operator' in """${output}"""
            Append To File
            ...    ${OUTPUT_DIR}/../../cloud_components_info_${node}.txt
            ...    CNF LCM Operator Version On ${unit}: ${output.strip().replace('operator-', 'operator_').replace("-amd64", "")}\n
        END
    END
    [Teardown]

*** Keywords ***
Execute Commands on CuDu
    [Arguments]  ${EXECUTE_CMD_CU_DU}  ${specified_cmd}
    @{EXECUTE_CMD}    Split String  ${EXECUTE_CMD_CU_DU}  ,
    FOR    ${unit}    IN    @{EXECUTE_CMD}
        ssh.Connect to   hostname=${${unit}_k8s_addr}   username=${${unit}_k8s_user}   password=${${unit}_k8s_pwd}  alias=RM_alias
        ${output}  ssh.execute    command=${specified_cmd}    connection=RM_alias
        ${output}=   Strip String  ${output}
        Set Test Variable   ${output}
        Log To Console      \nExecuted command on ${unit}: ${specified_cmd}
        log    \n${output}    console=true
    END

Env Health Check Setup
    ${tl.tl_cloud_topology}    Get Variable Value    ${tl.tl_cloud_topology}    NotKnown
    Log To Console      \t- TestLine: ${tl.tl_cloud_topology}
    ${UEs}    Run Keyword And Return Status    Variable Should Exist    ${tl.ues}
    Run Keyword If    ${UEs}    Print All Ues info
    ...    ELSE        Log To Console      \t- Test line doesn't have UE \n
    Run Keyword If    '300' in '${stream}' or '250' in '${stream}'
    ...   Common variables setup
    ${cpc_addr}=  Get Variable Value    ${tl.ues[0].ssh_connection_details.addr}    ${tl.ues[0].ue_pc_address}
    ${cpc_username}=  Get Variable Value    ${tl.ues[0].ssh_connection_details.username}    ${tl.ues[0].ue_pc_login}
    ${cpc_password}=  Get Variable Value    ${tl.ues[0].ssh_connection_details.password}    ${tl.ues[0].ue_pc_password}
    ${attenuation_port}    Get Variable Value    ${tl.attenuation['attenuation_port']}    3001
    Set Suite Variable  ${attenuation_port}
    set suite variable  ${cpc_addr}
    set suite variable  ${cpc_username}
    set suite variable  ${cpc_password}

Env Health Check Teardown
    Run Keyword And Ignore Error    coam.teardown          connection=coam_admin
    ${connected}=     Is infomodel connected
    Run Keyword If    ${connected}    Run Keywords
    ...    Disconnect infomodel    AND
    ...    Teardown infomodel

Check Vdu Onair
    Check If CCR reachable
    CU And DU Server Connection Check
    FHGW Status Check
    Kublet Service Check
    Run Keyword If    not ${is_LTE}    Loki Driver Status Check
    Run Keyword If    not ${DU_ACM_based_installation}    Podman Login Check
    Check System Pod status
    NOP Status Check
    ${vdu_web_connection}    ${vcu_web_connection}    CU and DU Web Connection Check
    ${rf_status}    RF Status Check    ${vdu_web_connection}
    ${F1_status}    E1 and F1 Status Check    ${rf_status}    ${vdu_web_connection}    ${vcu_web_connection}
    DU Cell OnAir Check and Power Check    ${vdu_web_connection}    ${F1_status}
    CU and DU Alarm Check    ${vdu_web_connection}    ${vcu_web_connection}
    BuiltIn.Set Global Variable    &{not_allowed_alarms}    &{EMPTY}
    [Teardown]  Run Keywords    Run Keyword And Ignore Error  ssh.disconnect      connection=RM_alias
    ...    AND    Run Keyword And Ignore Error    ssh.disconnect      connection=cu_RM_alias

CU And DU Server Connection Check
    ${Du_status}=  Run keyword and return status  Check AIC Connection Status    ${DU_k8s_addr}  ${DU_k8s_user}  ${DU_k8s_pwd}
    IF    not ${is_LTE}
        ${Cu_status}=  Run keyword and return status  Check AIC Connection Status    ${CU_k8s_addr}  ${CU_k8s_user}  ${CU_k8s_pwd}
    ELSE
        ${Cu_status}    Set Variable    True
    END
    Should Be True    ${Du_status} and ${Cu_status}    Cannot connect to OCP control IP

FHGW Status Check
    ${FHGW_status}=    Run Keyword If    ${FHGW_Exist}    Run keyword and return status
    ...    Check AIC Connection Status  ${FHGW_IP}  ${FHGW_USERNAME}   ${FHGW_PASSWORD}
    ...    ELSE    Set Variable    True
    Should Be True    ${FHGW_status}   Cannot connect to FHGW control IP

Kublet Service Check
    ${kubelet_res}=    Run Keyword And Return Status   Check And Recover kublnet service
    Run Keyword If  ${kubelet_res}!=${True}  Fail  ${\n}!!!Warning!!! kubelet service recovery failure, please manaully check:${\n}

Loki Driver Status Check
    ${loki_driver_status}=   Run Keyword And Return Status    Check Loki driver service
    Should Be True    ${loki_driver_status}     Loki driver startup issue!!!

Podman Login Check
    ${podman_login_status}=    Check Podman Login    ${DU_k8s_addr}  ${DU_k8s_user}  ${DU_k8s_pwd}
    Should Be True    ${podman_login_status}     Podman Login Failed!!!

NOP Status Check
    ${koredump_ns}    Get Koredump Operator namespace
    ${nop_list}    Create List    ran-nic-sw-controller    nokia-sync-operator    ${koredump_ns}    cnf-lcm-operator
    ${nop_pods_not_running}    Set Variable    ${False}
    FOR    ${nop}    IN    @{nop_list}
        ${nop_status}    Check NOP pod status    ${nop}
        Run Keyword If    not ${nop_status['result']}    Log    ${nop.replace('-', ' ')} pods are not running on DU!!!    WARN
        ${nop_pods_not_running}    Evaluate    ${nop_pods_not_running} or (not ${nop_status['result']})
    END
    Should Not Be True    ${nop_pods_not_running}    NOP pods are not running!!!
    IF    not ${is_LTE}
        ssh.Connect to   hostname=${CU_k8s_addr}   username=${CU_k8s_user}   password=${CU_k8s_pwd}  alias=cu_RM_alias
        ${cu_koredump_operator_status}    Check NOP pod status    ${koredump_ns}    connection=cu_RM_alias
        Should Be True    ${cu_koredump_operator_status['result']}    Koredump Operator pods are not running on CU!
    END

CU and DU Web Connection Check
    ${vdu_web_connection}    Run Keyword And Return Status    vdu.connect to
    ...    host=${DU_WEBUI_IP}
    ...    port=${EMPTY}
    ...    username=Nemuadmin
    ...    password=Nokia@123
    ...    secure=True
    ...    timeout=30
    Run Keyword And Continue On Failure    Should Be True     ${vdu_web_connection}    vDU web connection NOK!!!
    IF    ${vdu_web_connection} and not ${is_LTE}
        Run Keyword And Continue On Failure     Selenium Login And Version Check On WebEM    DU    loop_check=1
    END
    IF    not ${is_LTE}
        ${vcu_web_connection}    Run Keyword And Return Status    vdu.connect to
        ...    host=${CU_WEBUI_IP}
        ...    port=${EMPTY}
        ...    username=Nemuadmin
        ...    password=Nokia@123
        ...    secure=True
        ...    timeout=30
        Run Keyword And Continue On Failure    Should Be True     ${vcu_web_connection}    vCU web connection NOK!!!
        IF    ${vcu_web_connection}
            Run Keyword And Continue On Failure     Selenium Login And Version Check On WebEM    CU    loop_check=1
        END
    ELSE
        ${vcu_web_connection}    Set Variable    False
    END
    RETURN    ${vdu_web_connection}    ${vcu_web_connection}

RF Status Check
    [Arguments]    ${vdu_connection}
    IF    ${vdu_connection}
        ${rf_status}=    Run Keyword And Return Status    Verify RF status on WebEm    log_to_console=True    loop_check=1
        Run Keyword And continue On Failure    Run Keyword If    not ${rf_status}    Fail    \nRF check failed!!!\n
    ELSE
        ${rf_status}    Set Variable    SKIPPED
    END
    RETURN    ${rf_status}

E1 and F1 Status Check
    [Arguments]    ${rf_status}    ${vdu_connection}    ${vcu_connection}
    IF    not ${vcu_connection}
        RETURN    SKIPPED
    END
    ${e1_status}=    Run Keyword If    ${vcu_connection}    Run Keyword And Return Status
    ...    Verify E1 Status on OAM_CU   ${CU_WEBUI_IP}
    Run Keyword And Continue On Failure    Run Keyword If    not ${e1_status}    Fail      \nE1 link setup failed!!!\n
    IF    ${e1_status} and '${rf_status}'=='True' and ${vdu_connection}
        ${F1_status}=    Run Keyword And Return Status    Verify vDU_OAM F1 Setup
        Run Keyword And Continue On Failure    Run Keyword If    not ${F1_status}    Fail      \nF1 link setup failed!!!\n
        RETURN    ${F1_status}
    END
    RETURN    SKIPPED

DU Cell OnAir Check and Power Check
    [Arguments]    ${vdu_connection}    ${F1_status}
    IF    ${vdu_connection} and '${F1_status}' != 'False'
        ${cell_onair}    Run Keyword And Return Status    Check Cell setup for vDU    loop_check=1
        IF  ${cell_onair} and ${is_FDD}
            ${rf_power_check}    Run Keyword And Return Status    Check RF Power for FDD
            Run Keyword If    not ${rf_power_check}    Fail    FDD RF power check failed!!!
        ELSE IF    not ${cell_onair}
            Run Keyword And Continue On Failure    Fail    \nCell setup for vDU is NOK!!!
        ELSE
            Log to Console    vDU Cell Onair!!!
        END
    END

CU and DU Alarm Check
    [Arguments]    ${vdu_connection}    ${vcu_connection}
    IF    ${vdu_connection}
        ${vdu_alarm}    Run Keyword And Return Status    Check Unexpected Active Alarms On vDU    DU_WEBUI_IP=${DU_WEBUI_IP}
        Run Keyword And continue On Failure    Run Keyword If    not ${vdu_alarm}   Fail    \nUnexpected alarm appears on vdu!!!\n
    END
    IF    not ${is_LTE}
        IF    ${vcu_connection}
            Run Keyword And Continue On Failure    Check Unexpected Active Alarms On vCU    CU_WEBUI_IP=${CU_WEBUI_IP}
        ELSE
            Log to Console    vCU web connection NOK!!!
        END
    END

Check System Pod status
    IF    ${is_LTE}
        ${CU_DU}    Create List    DU
    ELSE
        ${CU_DU}    Create List    CU    DU
    END
    FOR   ${CU_DU}   IN    @{CU_DU}
        ssh.Connect to   hostname=${${CU_DU}_k8s_addr}   username=${${CU_DU}_k8s_user}   password=${${CU_DU}_k8s_pwd}  alias=RM_alias
        ${res_bool}=  get_system_pod_status  command=kubectl get po -A|grep -v "openshift-machine-config-operator"  alias=RM_alias
        Run Keyword If  '${res_bool}' == 'False'  Fail
        ...    Some ${CU_DU} System Pods are in CrashLoopBackOff state, Manual recovery needed!
    END

Check AIC Connection Status
    [Documentation]    Check cu du or fhgw Connection Status on aic env
    [Arguments]    ${addr}  ${user}  ${pwd}
    Wait Until Keyword Succeeds    2x    10s     helm.helm_master_connect
    ...  ${addr}
    ...  22
    ...  ${user}
    ...  ${pwd}
    BuiltIn.Sleep    3s
    helm.helm_master_close
    ssh . Connect To
    ...    hostname=${addr}
    ...    username=${user}
    ...    password=${pwd}
    ...    alias=RM_alias
    ssh.disconnect      connection=RM_alias

Check And Recover kublnet service
    IF    ${is_LTE}
        ${CU_DU}    Create List    DU
    ELSE
        ${CU_DU}    Create List    CU    DU
    END
    FOR   ${CU_DU}   IN    @{CU_DU}
        OE Authentication  par_prefix=${CU_DU}
        ssh.Connect to   hostname=${${CU_DU}_k8s_addr}   username=${${CU_DU}_k8s_user}   password=${${CU_DU}_k8s_pwd}  alias=RM_alias
        ${result}=  kubectl_get_pods
        ...   namespace=${${CU_DU}_tenant}
        ...   conn=RM_alias
        ${bool_res}=  Run Keyword And Return Status   Should Contain Any  ${result}    error:	was refused
        Run Keyword If   ${bool_res}    Run Keywords   ssh.execute
        ...  command=cp /var/home/core/kubeconfig ~/.kube/config  connection=RM_alias  timeout=30s
        ...  AND  ssh.execute  command=sudo systemctl restart kubelet   connection=RM_alias  timeout=70s
        ...  AND  Run Keyword And Continue on Failure
        ...  wait until keyword succeeds    3min   30s    OE Authentication  par_prefix=${CU_DU}
        ...  AND  Log To Console   \n kubelet restart works, test continue...
    END

vDU recovery by restarting services in FHGW
    [Documentation]  TL recovery action will be performed when fault16 occurred
    ${is_16_visible}=    Check If alarm exist on WebUI  faultid=16
    ${is_4298_visible}=    Check If alarm exist on WebUI  faultid=4298
    Run Keyword If  ${is_16_visible} or ${is_4298_visible}    Run Keywords   Restart FPGA service
    ...  cmd=systemctl restart switch-manager syncApp gpsd
    ...  AND  Wait Until Keyword Succeeds    1min    20s   vdu.connect to  host=${DU_WEBUI_IP}
    ...  port=${EMPTY}  username=Nemuadmin  password=Nokia@123    secure=${True}    connection_name=du_admin
    ...  AND    vdu.reset_vdu   vdu_connection=du_admin
    ...  AND    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ...  AND    ssh.send_command
    ...  command=kubectl get pods -n openshift-ptp | grep linuxptp-daemon| awk '{print $1}' | xargs kubectl delete pods -n openshift-ptp
    ...  connection=RM_alias  timeout=60s
    ...  AND  Wait Until Keyword Succeeds    3min    30s    Verify vDU_OAM F1 Setup  value='unavailable'
    ...  AND  wait until keyword succeeds    3min   1min    Get eCpriMasterClockState
    ...  AND  Verify RF status on WebEm    loop_check=6
    ${is_16_visible_after_recovery}=    Run Keyword If    ${is_16_visible}    Check If alarm exist on WebUI  faultid=16
    Run Keyword If  ${is_16_visible_after_recovery}  Fail  ${\n}!!!Warning!!! fault16 is still visible on WebUI, please manaully check:${\n}
    [Teardown]  Run Keyword And Ignore Error  vdu.disconnect   vdu_connection=du_admin

Check If alarm exist on WebUI
    [Arguments]  ${faultid}=None
    &{not_allowed_alarms}    Create Dictionary
    Set test Variable    &{not_allowed_alarms}
    Run Keyword And Continue On Failure   Run Keyword And Ignore Error  Check Unexpected Active Alarms On vDU
    ...    DU_WEBUI_IP=${DU_WEBUI_IP}    log_to_console=False
    ${alarm_visible}=    Run Keyword And Return Status  Dictionary Should Contain Key  ${not_allowed_alarms}  ${FaultID}
    Set Test Variable    ${alarm_visible}
    RETURN     ${alarm_visible}

Check Classical Onair
    [Documentation]   This keyword will Verify classical Cell Setup.
    ${ratname}         Get Variable Value    ${RAT}    default
    WA for coam connect    bts_host=192.168.255.129
    Run Keyword and continue on failure    Check Access To WebEm
    Run Keyword And Continue On Failure    Check Active and Passive SW versions
    ${is_ASOG_A101}     is_ASOG_A101
    # Run Keyword And Continue On Failure    BTS recovery with snapshot collection
    ${moxa_ip_addr}     Get Variable Value    ${tl.custom['moxa_ip_addr']}    None
    ${moxa_port}        Get Variable Value    ${tl.custom['moxa_port']}    None
    IF    '${moxa_ip_addr}'!='None' and '${moxa_port}'!='None'
        Append To List             ${CLASSICAL_ALLOWED_ACITVE_ALARMS}    4334
        ${expected_availabilityStatus}   Set Variable    Degraded|Online
    ELSE
        ${expected_availabilityStatus}   Set Variable    Online
    END
    IF     ${is_ASOG_A101}
        Append To List    ${CLASSICAL_ALLOWED_ACITVE_ALARMS}    61675
    END
    Run Keyword If    '${ratname}'=='iphy'    Run Keywords
    ...    Append To List    ${CLASSICAL_ALLOWED_ACITVE_ALARMS}     6202
    ...    AND       Run Keyword And Continue On Failure    Check Iphy Configed
    ...    ELSE      Run Keyword And Continue On Failure
    ...              Infomodel Check If All Cells Are Online And Perform Pmax Check If Cells Online
    ...              expected_availabilityStatus=${expected_availabilityStatus}
    Check Unexpected Active Alarms    host=192.168.255.129    skip_coam_connection_setup=${True}
    ${sfp_result}    ${sfp_msg}    get_all_sfp_info    connection=coam_admin
    Save SFP File Data    ${sfp_msg}
    ${sfp_warning}    Run Keyword And Return Status    Should Match Regexp    '${sfp_msg}'    WARN:
    Run Keyword If    not ${sfp_result} and ${sfp_warning}    Fail    Warning detected during SFP check${\n}${sfp_msg}
    Run Keyword If    not ${sfp_result}    Fail    SFP check failed!!!${\n}${sfp_msg}

Reinstall taf ue lib if android version lower than 10
    [Documentation]   http_proxy is not offically supported on UE with Android OS lower than 10
    ...   The safest way is to hard code taf_ue lib before test ok
    Get CPC OS    cpc_addr=${cpc_addr}    cpc_username=${cpc_username}    cpc_password=${cpc_password}
    # ${is_android_version_low}    check android version lower than 10    alias=cpc
    Run Keyword If    '${cpc_type}'=='Windows'  Run Keywords
    ...    reinstall taf lib    taf_lib_name=taf.ue    taf_lib_version=0.23.15
    ...    AND   reinstall taf lib    taf_lib_name=taf.ue.android    taf_lib_version=0.6.5
    [Teardown]  Run Keyword And Ignore Error  ssh.disconnect    connection=cpc

ADB devices
    [Arguments]         ${connectionalias}=cpc    ${adbdevice}=${tl.ues[${0}]}
    ssh.send_command    adb devices    connection=${connectionalias}    timeout=10
    BuiltIn.Sleep               2s
    ${result}           ssh.read_output    connection=${connectionalias}
    Should Contain      ${result}    ${adbdevice.serial_number}  UE is not detected!
    Set Suite Variable     ${result}

Check enb connection
    [Arguments]            ${enb_host}
    ${enb_connection}=    Run Keyword And Return Status    coam.connect to    bts_host=${enb_host}    name=coam_admin
    Run Keyword If    '${enb_connection}'=='False'    Run Keywords
    ...    Log    NSA enb check failed    WARN
    ...    AND    Fail

Check enb Onair
    [Documentation]   This keyword will Verify enb Cell Setup.
    ${enb_oam}    Get Variable Value    ${tl.enbs[0].oam_ip}
    ${enb_lmp}    Get Variable Value    ${tl.enbs[0].system_module.common_units[0].lmp_connection.addr}
    ${enb_host}    Set Variable If    '${enb_oam}'=='None'    ${enb_lmp}    ${enb_oam}
    Set Suite Variable    ${enb_host}
    Run Keyword If    '${enb_host}'=='None'    Log To Console     \n --> INFO: it's not nsa site, doesn't have enb
    ...     ELSE IF    '192.168.255.' in '${enb_host}'
    ...     Log To Console     \n --> INFO: nsa site, eNB ip is: ${enb_host} so skip enb cell setup check
    ...     ELSE    Run Keywords    Log To Console     \n --> INFO: nsa site, eNB ip is: ${enb_host}
    ...     AND     Check enb connection    enb_host=${enb_host}
    ...     AND     Verify COAM 4G Cell Setup      connection=coam_admin
    ...     AND     coam.teardown          connection=coam_admin

Verify COAM 4G Cell Setup
    [Arguments]            ${connection}=coam_admin
    ${cell_info}           coam.get_cells_info    cell_type=lte    timeout=30    connection=${connection}
    Log Many               ${cell_info}
    Should Not Be Empty    ${cell_info}
    ${index}               Set Variable    ${1}
    FOR    ${elem}   IN    @{cell_info}
        ${operationalState}=    Run Keyword and return status
        ...    Should contain     ${elem['status']['operationalState']}      Enabled       ignore_case=True
        ${administrativeState}=    Run Keyword and return status
        ...    Should contain     ${elem['status']['administrativeState']}   Unlocked      ignore_case=True
        Log To Console     \n RF${index} => ${elem['status']['operationalState']}
        Run Keyword If    not (${operationalState} and ${administrativeState})      Run Keywords
        ...    Log    NSA enb check failed    WARN
        ...    AND    Fail
        #Should contain     ${elem['status']['availabilityStatus']}    Online        ignore_case=True
        ${index}           Set Variable    ${index + 1}
    END

Check Iphy Configed
    [Documentation]   This keyword will Verify iphy status.
    Setup infomodel    address=192.168.255.129    port=443
    Connect infomodel    timeout=60
    ${rf_is_online}    Query infomodel  query=every //RMOD_L-* is [stateInfo.availabilityStatus=regex"[Oo]nline"]
    ${at_least_configured}    Query infomodel  query=every //MRBTS_M-* is [stateInfo.proceduralState=regex"${config_query}"]
    Should Be True    ${rf_is_online}
    Should Be True    ${at_least_configured}

Infomodel Check If All Cells Are Online And Perform Pmax Check If Cells Online
    [Documentation]   This keyword will Verify cells status.
    [Arguments]       ${expected_availabilityStatus}=Online
    Setup infomodel    address=192.168.255.129    port=443
    Connect infomodel    timeout=60
    @{parameters_list}    create list
    ...    availabilityStatus=regex"${expected_availabilityStatus}"
    ...    operationalState=Enabled
    ...    proceduralState=regex"[oO]n[aA]ir*"
    ${string}    catenate    SEPARATOR=,stateInfo.    @{parameters_list}
    ${string}    catenate    SEPARATOR=    stateInfo.    ${string}
    ${status}=  Run keyword and return status  query infomodel  every //MRBTS_M-*//CELL_M-* is [${string}]  timeout=2min
    IF    ${status}
        ${rf_cell_power_map}    ${rf_cell_power_check_failed_map}    get_and_check_cell_power    connection=coam_admin
        log    ${rf_cell_power_map}
        Should Be Empty    ${rf_cell_power_check_failed_map}    Pmax Value Check Failed!!!
    ELSE
        Fail    cells status is not onair
    END

Print All Ues info
    [Documentation]   This keyword print all ues info.
    ${uename}    Set Variable    ${empty}
    FOR  ${ue}  IN  @{tl.ues}
         ${uename}    Catenate    ${uename}    ${ue.ue_type}
    END
    Log To Console      \t- UEs: ${uename}
    Set Suite Variable    ${uename}

Check Fastmile Status
    [Documentation]   check fastmile ue status.
    [Arguments]       ${device}=${tl.ues[${0}]}
    ${Fastmile_user}    Set Variable                                      hguser
    ${Fastmile_pwd}=    Set Variable if    '${device.version}'=='3.1'     bkIt0@Uq    Hp@9wYs2d%t7
    ${status}    Run keyword and return status    ssh.Connect to
    ...    hostname=${device.ue_manage_ip}   username=${Fastmile_user}   password=${Fastmile_pwd}  alias=fastmile
    Should be true    ${status}    fastmile is not reachable!
    [Teardown]    Run Keyword If    ${status}    ssh.disconnect      connection=fastmile

BTS recovery with snapshot collection
    [Documentation]   Trigger snapshot collection if there is 6450 alarm
    ${no_alarm}    Run Keyword and return status    Check Unexpected Active Alarms    host=192.168.255.129    console=False
    Set Test Variable    ${sw_d}    default
    Set Test Variable    ${smod_type}    default
    ${not_allowed_alarms_classical_str}=    Run Keyword If   ${no_alarm}==${False}    Evaluate    ",".join(${not_allowed_alarms_classical})
    ${is_6450_alarm_visible}=    Run Keyword If   ${no_alarm}==${False}      Run Keyword and return status
    ...    Should Contain    ${not_allowed_alarms_classical_str}     6450
    ...    ELSE    Set Variable    ${False}
    Run Keyword If    ${is_6450_alarm_visible}    Run Keywords
    ...    Log to console    6450 is visible, BTS recovery with snapshot collection triggered
    ...    AND    WA for coam connect    bts_host=192.168.255.129
    ...    AND    Save Snapshot For Classical

Check and recover loki driver
    ${res_bool}=   Run Keyword And Return Status   Wait Until Keyword Succeeds   5x  2s   check loki-service status
    Run Keyword If  ${res_bool}  Log To Console   ----> ${\n}Loki driver restart ok.${\n}
    ...  ELSE   Run Keywords  Pull loki driver image
    ...  AND   Delete the old loki driver and install new one
    ...  AND  Check if loki driver updated

check loki-service status
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ssh.send_command   command=systemctl status loki-driver-load.service|grep Active:   connection=RM_alias  timeout=60s
    ${output}=   ssh.read_output   connection=RM_alias
    Should Contain   ${output}   Active: active    Loki driver startup failed!!!

Check Loki driver service
    Run Keyword If  '300' in '${stream}'  Run Keywords
    ...  ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ...  AND  Execute Commands on CuDu  EXECUTE_CMD_CU_DU=DU
    ...  specified_cmd=systemctl status loki-driver-load.service|grep Active:
    Run Keyword If  'Active: failed' in '${output}'    Run Keywords
    ...   Log To Console   ----> ${\n}!!!Warning!!! Loki driver status is nok, start to undeploy du and restart loki driver service!${\n}   WARN
    ...   AND  Get controller host name  ${DU_k8s_addr}  ${DU_k8s_user}  ${DU_k8s_pwd}
    ...   AND  helm.helm_delete   release_name=${DU_cnfname}  namespace=cran1  fail_on_error=False  conn=RM_alias
    ...   AND  Run Keyword And Ignore Error  Pull loki driver image
    ...   AND  ssh.send_command   command=sudo systemctl restart loki-driver-load.service   connection=RM_alias
    ...   AND  BuiltIn.Sleep   1s
    ...   AND  Check and recover loki driver

Get Koredump Operator namespace
    ${koredump_ns}=    ssh.execute
    ...    command=helm list |grep koredump|awk '{print $1}'
    ...    connection=RM_alias
    IF    '${koredump_ns.strip()}' == ''
        RETURN    koredump-operator
    ELSE
        RETURN    ${koredump_ns.strip()}
    END

Plugin UE Healthy Check
    [Arguments]    ${ue}=${ue}    ${cpc_addr}=${cpc_addr}
    ...    ${cpc_username}=${cpc_username}    ${cpc_password}=${cpc_password}    ${alias}=cpc
    IF   '${ue.ue_type}' in ${proxy_ue_type_list}
        Log to console     \n\t==================== Proxy check for ${ue.ue_type} ====================
        Log to console      \t --------- PC INFO: ${cpc_addr} / ${cpc_username} / ${cpc_password} / ${cpc_type} ---------
        Connect to controlPC
        ...    cpc_addr=${cpc_addr}
        ...    cpc_username=${cpc_username}
        ...    cpc_password=${cpc_password}
        ...    alias=${alias}
        IF   '${cpc_type}'=='Linux'
            Check if DNS configed in cpc  site=${site}  alias=${alias}
        END
        ${proxy_mngr_version}    get_taf_proxy_mngr_version
        ...    cpc_addr=${cpc_addr}    ue=${ue}
        ${skip_proxy_mngr_update}    Get Variable Value    ${skip_proxy_mngr_update}    ${False}
        ${skip_ue_proxy_restart}    Get Variable Value    ${skip_ue_proxy_restart}    ${False}
        IF    not ${skip_proxy_mngr_update}
            ${target_proxy_manager_version}    Get Variable Value    ${target_proxy_manager_version}    ${EMPTY}
            Run Keyword And Continue On Failure    check_and_upgrade_proxy_mngr_in_cpc
            ...    site=${site}
            ...    OS=${cpc_type}
            ...    target_proxy_manager_version=${target_proxy_manager_version}
            ...    proxy_mngr_version=${proxy_mngr_version}
            ...    alias=${alias}
            ...    user=${cpc_username}
        END
        is_ue_interface_visible_in_cpc    OS=${cpc_type}    alias=${alias}    ue=${ue}
        proxy_check_and_recovery    OS=${cpc_type}    alias=${alias}    user=${cpc_username}    #ensure proxy manager is running before ue proxy check
        IF    ${skip_ue_proxy_restart}
            ${running_ueproxy_info}     get_running_ueproxy
            ...   cpc_addr=${cpc_addr}    proxy_mngr_port=${ue.proxy_mngr_port}    ue_type=${ue.ue_type}
            IF    '${running_ueproxy_info[1]}' != ''
                RETURN
            END
        END
        start_latest_ue_proxy    OS=${cpc_type}    site=${site}    alias=${alias}    ue=${ue}
    END

Save SFP File Data
    [Documentation]    The keyword saves ${sfp_data} dictionary into the ${sfp_json_file} json file which is being
    ...    used for Env Heath Checker.

    [Arguments]    ${sfp_data}    ${sfp_json_file}=${OUTPUT_DIR}/../../rf_sfp_data.json
    ${json_data}    Evaluate    json.dumps(${sfp_data}, indent=4)    json
    Create File    ${sfp_json_file}    ${json_data}

Check If Appserver Is Pingable
    @{appserver_info}    get_appserver_info
    FOR    ${item}    IN    @{appserver_info}
        ${bool_res}    Run Keyword And Return Status    Check If IP Is Pingable    ip=${item['address']}
        IF    not ${bool_res}
            ${conn_bool}    Run Keyword And Return Status    Connect to host    hostname=${item['address']}
            ...                                                                 username=${item['user']}
            ...                                                                 password=${item['password']}
            IF    not ${conn_bool}
                Fail    appserver:${item['address']} is not pingable, pls check!!!
            END
        END
    END

Check Active and Passive SW versions
    [Documentation]    Check SBTS active and passive sw version. Fail TC is passive sw version is empty.
    Get BTS SW Version    bts_host=192.168.255.129    check_times=1
    IF    $passive_SW is None or ${{len($passive_SW)}} == 0
        Fail    Passive SW version is empty, please check!
    END

Check If CCR reachable
    ${local_ccr_status}    is_host_reachable    ${${site}_local_registry_url.split(':')[0]}
    ${global_ccr_status}   is_host_reachable    ${${site}_global_registry_url}
    IF    not ${local_ccr_status} and not ${global_ccr_status}
        Fail    Both local CCR and global CCR are not reachable, please check!
    END