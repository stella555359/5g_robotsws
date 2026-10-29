*** Settings ***
Documentation    Author: yonna.yao@nokia-sbell.com
...              \n AIC common operate keywords.
Resource    internal_CN1_vdu_oam.robot
Library	    ../python/vran_operate.py


*** Keywords ***
Get TL Config
    [Arguments]    ${filename}=${None}
    ${variables}=    Get variables
    Run Keyword Unless    "\${tl}" in $variables    _Get TL Config From File    ${filename}
    Set suite variable    ${VLAN_IDS}    ${tl.gnbs[0].dus[0].fhuc_vlans}
    Set suite variable    ${NAMESPACE_CU}    ${tl.cloud_hostings[0].namespace}
    Set suite variable    ${NAMESPACE_VDU}    ${tl.cloud_hostings[1].namespace}
    Set Suite Variable    &{MASTER_CU}
    ...    hostname=${tl.cloud_hostings[0].master_node.ssh_connection_details.addr}
    ...    username=${tl.cloud_hostings[0].master_node.ssh_connection_details.username}
    ...    password=${tl.cloud_hostings[0].master_node.ssh_connection_details.password}
    ...    alias=cu_master
    Set Suite Variable    &{MASTER_VDU}
    ...    hostname=${tl.cloud_hostings[1].master_node.ssh_connection_details.addr}
    ...    username=${tl.cloud_hostings[1].master_node.ssh_connection_details.username}
    ...    password=${tl.cloud_hostings[1].master_node.ssh_connection_details.password}
    ...    alias=vdu_master
    Set Suite Variable    &{OAM_CU}
    ...    host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    port=${tl.gnbs[0].cu.oam_http_connection_details.port}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=cu_admin
    Set Suite Variable  &{OAM_VDU}
    ...    host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...    port=${tl.gnbs[0].dus[0].oam_http_connection_details.port}
    ...    username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ...    secure=${True}
    ...    connection_name=vdu_admin
	set suite variable    ${VDU_RANNIC1_SERIAL_NUMBER}  ${tl.gnbs[${0}].dus[${0}].rannics[${0}].serial_number}
    set suite variable    ${VDU_RANNIC1_PRODUCT_CODE}  ${tl.gnbs[${0}].dus[${0}].rannics[${0}].product_code}

CU Master Login
    SSH.Connect To
    ...    hostname=${tl.cloud_hostings[0].master_node.ssh_connection_details.addr}
    ...    username=${tl.cloud_hostings[0].master_node.ssh_connection_details.username}
    ...    password=${tl.cloud_hostings[0].master_node.ssh_connection_details.password}
    ...    alias=cu_master

CU Master Logout
    SSH.Disconnect    cu_master

VDU Master Login
    SSH.Connect To
    ...    hostname=${tl.cloud_hostings[1].master_node.ssh_connection_details.addr}
    ...    username=${tl.cloud_hostings[1].master_node.ssh_connection_details.username}
    ...    password=${tl.cloud_hostings[1].master_node.ssh_connection_details.password}
    ...    alias=vdu_master

VDU Master Logout
    SSH.Disconnect    vdu_master

CU OAM Login
    [Arguments]    ${obj}=SSH
    Run Keyword If    '${obj}'=='SSH'    SSH.Connect To
    ...    host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    port=${tl.gnbs[0].cu.oam_http_connection_details.port}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...    alias=cu_admin
    ...    ELSE    CU.Connect To
    ...    host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    port=${tl.gnbs[0].cu.oam_http_connection_details.port}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=cu_admin

CU OAM Logout
    [Arguments]    ${obj}=SSH
    Run Keyword If    '${obj}'=='SSH'    SSH.Disconnect    cu_admin
    ...    ELSE    CU.Disconnect    cu_admin

VDU OAM Login
    [Arguments]    ${obj}=SSH
    Run Keyword If    '${obj}'=='SSH'    SSH.Connect To
    ...    host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...    port=${tl.gnbs[0].dus[0].oam_http_connection_details.port}
    ...    username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ...    ELSE    VDU.Connect To
    ...    host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...    port=${tl.gnbs[0].dus[0].oam_http_connection_details.port}
    ...    username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ...    secure=${True}
    ...    connection_name=vdu_admin

VDU OAM Logout
    [Arguments]    ${obj}=SSH
    Run Keyword If    '${obj}'=='SSH'    SSH.Disconnect    vdu_admin
    ...    ELSE    VDU.Disconnect    vdu_admin

VDU Get SW Info

    ${ret1}    ${ret2}=    Should Match Regexp    ${output}    vDUCNF([0-9A-Za-z]+).xml
    @{version_list}    Split String    ${output}    TargetBD_
    ${BRANCH}    Set Variable If    '${version_list[0]}'=='0'    Trunk    Branch
    Log To Console     ${BRANCH}

Get ${unit} SW Version
    ${unit}    String.Convert To Uppercase    ${unit}
    ${alias}=      Run Keyword If
    ...    "${unit}" == "CU"    Set variable    cu_master      ELSE IF
    ...    "${unit}" == "VDU"    Set variable    vdu_master    ELSE
    ...    Fail  \${unit}\=\"${unit}\" not in [\"CU\", \"VDU\"].
    Run Keyword If
    ...    "${unit}" == "CU"    CU Master Login      ELSE IF
    ...    "${unit}" == "VDU"    VDU Master Login    ELSE
    ...    Fail  \${unit}\=\"${unit}\" not in [\"CU\", \"VDU\"].
    ${output}=    SSH.Execute
    ...    helm list -n ${NAMESPACE_${unit}} | grep -Po "aic-v(c|d)u-(cnf-)?\\K\\d{1,2}.\\d{3}.\\d{1,6}" -m1
    ...    connection=${alias}
    ${output}=    Replace String	${output}    \r\n    ${EMPTY}
    Log To Console    ${unit}: ${output}
    [Return]    ${output}
    [Teardown]  SSH.Disconnect  connection=${alias}

Activate CU and VDU plan
    [Documentation]     This Keyword is to Activate CU and VDU plan.
    ...    | Input Parameters | Man. | Description |
    ...    | ${cu_scf} | Yes | cu scf file  |
    ...    | ${vdu_scf} | Yes | vdu scf file |
    ...    Examples:
    ...    | Activate CU and VDU plan | CB008876/resources/cu_trunk_scf.xml | CB008876/resources/vdu_trunk_scf.xml |
    [Arguments]    ${cu_scf}    ${vdu_scf}
    Upload And Activate CU Plan    ${cu_scf}
    Upload And Activate VDU Plan    ${vdu_scf}

Upload And Activate CU Plan
    [Documentation]     This Keyword is to upload and activate CU plan.
    ...    | Input Parameters | Man. | Description |
    ...    | ${cu_scf} | Yes | cu scf file  |
    ...    Examples:
    ...    | Upload And Activate CU Plan | CB008876/resources/cu_trunk_scf.xml |
    [Arguments]    ${cu_scf}
    ${cu_plan_id}=    _Upload CU Plan    ${cu_scf}
    _Validate CU Plan    ${cu_plan_id}
    _Activate CU Plan    ${cu_plan_id}

Upload And Activate VDU Plan
    [Documentation]     This Keyword is to upload and activate VDU plan.
    ...    | Input Parameters | Man. | Description |
    ...    | ${vdu_scf} | Yes | vdu scf file  |
    ...    Examples:
    ...    | Upload And Activate VDU Plan | CB008876/resources/vdu_trunk_scf.xml |
    [Arguments]    ${vdu_scf}
    ${vdu_plan_id}=    _Upload VDU Plan    ${vdu_scf}
    _Validate VDU Plan    ${vdu_plan_id}
    _Activate VDU Plan    ${vdu_plan_id}

VDU Get SW Branch
    [Documentation]     This Keyword is to get sw branch for vran 2.0.
    VDU Master Login
    ${command}=  Catenate
    ...    oc exec -it ute-oamfh-0 -n ${NAMESPACE_VDU} -c ctr-oamfh --
    ...    find /ffs/run/RFSW -type f -name "TargetBD*.xml"
    ${output}=    SSH.Execute    ${command}    connection=vdu_master
    ${ret1}    ${ret2}=    Should Match Regexp    ${output}    vDUCNF([0-9A-Za-z]+)_
    Set Suite Variable    ${VDU_SW_BRANCH}    ${ret2}
    @{version_list}    Split String    ${output}    TargetBD_
    @{vdu_ver}    Split String   ${version_list}[1]    .xml
    Set Global Variable    @{SOFTWARE_INFO}     ${vdu_ver}[0]
    [Return]    ${ret2}
    [Teardown]    VDU Master Logout

VDU Get Pods
    [Arguments]      ${filter}=l2nrt
    VDU Master Login
    ${output}=    SSH.Execute    kubectl -n ${NAMESPACE_VDU} get pod | grep ${filter}    connection=vdu_master
    @{ret}=    Split String    ${output}
    Set Suite Variable    ${VDU_PODS}    ${ret}[0]
    [Return]    ${ret}[0]
    [Teardown]    VDU Master Logout

VDU Get F1uplane IP
    CU Master Login
    ${common_cmd}    Set Variable    kubectl exec -it ute-${NAMESPACE_VDU}-upue-0 -c ctr-${NAMESPACE_VDU}-nwmgmt -n ${NAMESPACE_VDU}
    ${cmd}    Set Variable    ${common_cmd} -- ip addr show f1u |grep -Po '\\d+.\\d+.\\d+.\\d+'/24 | tr -d \r\n
    ${ret}    ssh.Execute    command=${cmd}    connection=cu_master
    CU Master Logout
    ${f1u_ip}    Get Regexp Matches    ${ret}    (\\d+.\\d+.\\d+.\\d+)

    [Return]    ${f1u_ip[0]}

VDU Change Parameters Online
    [Arguments]    ${mo_dn_list}    ${updated_paras_dict_list}    ${operation}=replace
    ...    ${activate}=${True}    ${force_reset}=${True}    ${auto_lock_cells}=${True}
    ...    ${wait_vdu_up}=${False}    ${timeout}=30
    VDU Online Change Parameters       ${mo_dn_list}    ${updated_paras_dict_list}    operation=${operation}
    ...    activate=${activate}    force_reset=${force_reset}    auto_lock_cells=${auto_lock_cells}
    ...    wait_vdu_up=${wait_vdu_up}    timeout=${timeout}

AIC Perform Full Commission And Reach Onair
    [Arguments]     ${vdu_scfc}      ${wts_config}      ${cu_scfc}
    ${status}    ${msg}    Run Keyword And Ignore Error    Variable Should Exist    ${AP_SWCONFIG_NAME}
    run Keyword If    '${status}'=='PASS'    Airphone Upload Swconfig     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SWCONFIG/${AP_SWCONFIG_NAME}
	${new_vdu_scfc}    vdu_change_vlan_ids_in_scfc    ${vdu_scfc}    ${test_log_directory()}/full_commission/    &{OAM_VDU}
    Activate CU and VDU plan       ${cu_scfc}     ${new_vdu_scfc}
    Reboot ap via ssh
    Start AP Syslog    ${TEST_LOG_DIRECTORY()}/All/ap_syslog_beforeonair
    Wait until RMODs availability status is 'on line'
    Wait until F1 link is available
    AIC Configure TL VM ETH IP
    Airphone Start Wtssim With Cfg File    ${wts_config}    true
    _wait_until_sib1_received_for_all_cells    timeout=2000
    Airphone Setup X2 Connection    20    1    2
    Stop Collect AP Syslog    ${TEST_LOG_DIRECTORY()}/All/ap_syslog_beforeonair

AIC Perform Full Commission And Reach Onair DC
    [Arguments]     ${vdu_scfc}      ${wts_config}      ${cu_scfc}
    ${status}    ${msg}    Run Keyword And Ignore Error    Variable Should Exist    ${AP_SWCONFIG_NAME}
    run Keyword If    '${status}'=='PASS'    Airphone Upload Swconfig     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SWCONFIG/${AP_SWCONFIG_NAME}

    Log to console    ----namespace:---${NAMESPACE_VDU}
	Log to console    ----VDU_RANNIC1_SERIAL_NUMBER:---${VDU_RANNIC1_SERIAL_NUMBER}
	Log to console    ----VDU_RANNIC1_PRODUCT_CODE:---${VDU_RANNIC1_PRODUCT_CODE}
    Log to console    ----cu_scfc:---${cu_scfc}

	${new_vdu_scfc}   change_VDU_TLconfig_in_scf    ${VDU_RANNIC1_SERIAL_NUMBER}   ${VDU_RANNIC1_PRODUCT_CODE}   ${vdu_scfc}
    Log to console   ---new_DU_scf:---${new_vdu_scfc}

	Activate CU and VDU plan       ${cu_scfc}     ${new_vdu_scfc}
	#Upload And Activate VDU Plan   ${new_vdu_scfc}
    Reboot ap via ssh
    Start AP Syslog    ${TEST_LOG_DIRECTORY()}/All/ap_syslog_beforeonair
    Wait until RMODs availability status is 'on line'
    Wait until F1 link is available
    ## AIC Configure TL VM ETH IP
    Airphone Start Wtssim With Cfg File    ${wts_config}    true
    _wait_until_sib1_received_for_all_cells    timeout=2000
    Airphone Setup X2 Connection    20    1    2
    Stop Collect AP Syslog    ${TEST_LOG_DIRECTORY()}/All/ap_syslog_beforeonair

Wait until RMODs availability status is 'on line'
    [Arguments]  ${retry}=10m  ${retry_interval}=5s
    Wait until keyword succeeds    ${retry}    ${retry_interval}    Verify RMODs availability status is 'on line'
    Log to console    DU: All RMODs are \'on line\'

Verify RMODs availability status is 'on line'
    VDU OAM Login    VDU
    ${rmods_statuses}=  vdu.Get RMODs status  vdu_connection=vdu_admin
    FOR  ${status}  IN  @{rmods_statuses}
        Dictionary should contain item  ${status}  availability_status  on line  msg=RMOD status is not \'on line\':${\n}${status}
    END
    [Teardown]  VDU OAM Logout    VDU

Wait until F1 link is available
    [Arguments]  ${retry}=10m  ${retry_interval}=5s
    Wait until keyword succeeds  ${retry}  ${retry_interval}  F1 link should be available

F1 link should be available
    ${du_state}=  Get DU state
    Should be equal  ${du_state}[f1_link_status][available]  ${1}
    Log to console  CU: F1 link is available

Get DU state
    CU OAM Login    CU
    ${du_state}=  CU.Get du state  connection=cu_admin
    [Return]  ${du_state}
    [Teardown]  CU OAM Logout    CU

Collet VDU and VCU syslog
    vran syslog capture    hostname=${tl.cloud_hostings[0].master_node.ssh_connection_details.addr}
    ...                    username=${tl.cloud_hostings[0].master_node.ssh_connection_details.username}
    ...                    password=${tl.cloud_hostings[0].master_node.ssh_connection_details.password}
    ...                    alias=cu_master
    vran syslog capture    hostname=${tl.cloud_hostings[1].master_node.ssh_connection_details.addr}
    ...                    username=${tl.cloud_hostings[1].master_node.ssh_connection_details.username}
    ...                    password=${tl.cloud_hostings[1].master_node.ssh_connection_details.password}
    ...                    alias=vdu_master
Collect all logs
    [Arguments]  ${args}=${EMPTY}  ${path}=${OUTPUT DIR}/${TEST NAME}/${TIMESTAMP}
    Collect logs from pods  ${MASTER_CU}  ${NAMESPACE_CU}  ${args}  ${path}/vCU_logs
    Collect logs from pods  ${MASTER_DU}  ${NAMESPACE_VDU}  ${args}  ${path}/vDU_logs
    Get all snapshots  ${OAM_DU}  ${OAM_CU}

AIC Configure TL VM ETH IP
    Log To Console    Configure NSA VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.11.100/24 dev eth8
    OperatingSystem.Run    sudo ip addr add 10.0.1.138/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.139/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.141/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.142/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.143/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.2.99/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.127/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.106/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.102/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.125/24 dev eth3

AIC Get Counter Values
    [Arguments]         ${counter_id}          ${dimension_dn}      ${value_index}=-1
    [Documentation]    AIC Get Counter Values
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id | Yes | such as 'M55308C23002' |
    ...    | dimension_dn | Yes | such as 'MRBTS-1/NRBTS-1/NRCELL-1' |
    ...    | value_index | No | the index of value, default value is -1 |
    ...    *Return*
    ...    *Example*
    ...    | ${value} |aic get counter values | M55308C23002 | dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1  |
    vdu.connect to    ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}      username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
    ...     password=Nokia@123      connection_name=vdu_https     port=${EMPTY}     timeout=10    secure=True
    ${value}    vdu.Get Counter Values    ${counter_id}    ${dimension_dn}    vdu_connection=vdu_https
    [return]    ${value[${value_index}]['value']}
    [Teardown]    vdu.Disconnect    vdu_https

AIC Get Counter File Remaining Time
    [Arguments]    ${counter_refresh_period}=15min
    VDU Master Login
    ${output}=    SSH.Execute    date "+%Y-%m-%d %H:%M:%S"    connection=vdu_master
    ${remaining_time}    get_counter_file_remaining_time    ${counter_refresh_period}    date_time=${output}
    [Return]    ${remaining_time}
    [Teardown]    VDU Master Logout
