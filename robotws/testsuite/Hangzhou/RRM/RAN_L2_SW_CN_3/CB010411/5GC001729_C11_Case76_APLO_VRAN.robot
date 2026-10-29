*** Settings ***
Documentation    add case
Suite Setup       AiC Common Suite Setup
Suite Teardown    AiC Common Suite Teardown
Test Setup        AiC Common Test Setup
Test Teardown     AiC Common Test Teardown
Force Tags        CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    SBTS00
Resource          ../resources/KISS/robot/common_resource.robot
Resource          ../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}         ${CURDIR}/config
${UE_ID}          1
${PDU_ID}         1
${GW_ID}          1
${SLICE_ID}       1
${DU_SCF}        5GC001729_case76_SCFC_VDU.xml
${CU_SCF}        5GC001729_case76_SCFC_VCU.xml
${AIRPHONE_NAME}    iphy_2aeqe_case2.xml
${WTS_CFG}       basic_cni70851.cfg
@{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
${EGATE_TAG}    ADD
${UE1_A1_EVENT}    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
@{Rdparameter}    0x10041:5
${Block_Num}   2
${cell1_as_pcell_tp}    740000  #1300000
${cell2_as_Pcell_tp}    740000  #1050000
${cell2_as_Pcell_tp_block}    200000  #200000
${cell2_as_scell_tp}    740000   #1050000
${cell1_as_scell_tp}    740000   #1300000
${cell1_as_pcell_tp_block}    740000.0

*** Test Cases ***
5GC001729_Case76_C11_Cell_Unlock_of_TDD_SCell
    step1:Vran prepare for on air
#    step2:Attach SA UE with full buffer
    step3：block cell'51' ‘${Block_Num}’ times

*** Keywords ***
step1:Vran prepare for on air
    #Modify Swconfig for AP
    AIC Perform Full Commission And Reach Onair    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}
	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}
    airphone_cleanup_egate_console_log

step2:Attach SA UE with full buffer
    log to console   step2:Attach SA UE with full buffer
    Start capture gnb and ap syslog in 'before_block_cell50Pcell' file
    airphone_cleanup_egate_console_log
    Set traffic type to internal
    Airphone SA Attach    ue_id=${UE_ID}
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
    airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50   #a1 report for scelladd
    Internal send mutiple trf '12' for each '175M' DL data
    Collect AP egate log    step2_before_block_cell51
    Analyse scelladd in rrclog    step2_before_block_cell51    RRC_scelladd_cell51.ini
    Check throughput    ${UE_ID}     Pcell_TP=${cell1_as_pcell_tp}   Scell_TP=${cell2_as_Pcell_tp}
    Capture tti and check bler   step2_before_block_cell51
    Detach UE     ${UE_ID}
    Stop capture gnb and ap syslog in 'before_block_cell50Pcell' file

step3：block cell'${cellid}' ‘${NUM}’ times
    log to console    step3：block cell'${cellid}' ‘${NUM}’ times
    FOR    ${num}    IN RANGE    1    ${NUM}+1
        airphone_cleanup_egate_console_log
        Log To Console   ${\n}-----block cell${cellid} ${num} time ------
        Start capture gnb and ap syslog in 'block_unblock_cell${cellid}_${num}' file
        Block Cell In vDU    cell_id=2
        Set traffic type to internal
        Airphone SA Attach    ue_id=${UE_ID}
        Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
        Internal send mutiple trf '12' for each '175M' DL data
        Collect AP egate log      block_cell${cellid}_${num}
        run keyword and continue on failure     Analyse scelladd in rrclog     block_cell${cellid}_${num}     RRC_non_CA_cell51.ini
        Wait until keyword succeeds    60s    5s    Verify Pcell throughput    ${UE_ID}   Pcell_TP=${cell1_as_pcell_tp}
        Stop data transfer    ${UE_ID}
        Detach UE     ${UE_ID}

        Log To Console   ${\n}-----unblock cell${cellid} ${num} time ------
        airphone_cleanup_egate_console_log
        Unblock Cell In vDU    cell_id=2
        Wait '5s' for stable
        Set traffic type to internal
        Airphone SA Attach    ue_id=${UE_ID}
        Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
        airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50   #a1 report for scelladd
        Internal send mutiple trf '12' for each '175M' DL data
        Collect AP egate log      unblock_cell${cellid}_${num}
        run keyword and continue on failure     Analyse scelladd in rrclog     unblock_cell${cellid}_${num}     RRC_scelladd_cell51.ini
        run keyword and continue on failure     Check throughput    ${UE_ID}     Pcell_TP=${cell1_as_pcell_tp}   Scell_TP=${cell2_as_Pcell_tp}
        run keyword and continue on failure    Capture tti and check bler   unblock_cell51_${num}
        Stop data transfer    ${UE_ID}
        Detach UE     ${UE_ID}
        Stop capture gnb and ap syslog in 'block_unblock_cell${cellid}_${num}' file
        Wait '2s' for stable
    END


Block Cell In vDU
    [Arguments]    ${cell_id}=1    ${timeout}=${60}    ${alias}=default
    [Documentation]    this kw is used to Block Cell In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  cell_id  | No | define which cell id is blocked |
    ...    |  timeout  | No | define time of timeout |
    ...    |  alias  | No | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Block Cell In vDU | cell_id=1 | timeout=${60} |
    ...
    vDU Login By Rest
    ${out}    vdu.block_cell    cell_id=${cell_id}
    ...                                                 timeout=${timeout}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Block Cell Should Be Expected   operation_id=${out["id"]}
    ...                                                                          expected_status=success
    [Teardown]    vDU Logout By Rest

_Check Block Cell Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}
    ${out}    get_block_cell_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...                                          vdu_connection=default
    Should Be True    "${out["status"]}"=="${expected_status}"

_Check Unblock Cell Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}
    ${out}    get_unblock_cell_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...                                          vdu_connection=default
    Should Be True    "${out["status"]}"=="${expected_status}"

Unblock Cell In vDU
    [Arguments]    ${cell_id}=1    ${timeout}=${60}    ${alias}=default
    [Documentation]    this kw is used to Unblock Cell In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  cell_id  | No | define which cell id is unblocked |
    ...    |  timeout  | No | define time of timeout |
    ...    |  alias  | No | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Unblock Cell In vDU | cell_id=1 | timeout=${60} |
    ...
    vDU Login By Rest
    ${out}    vdu.unblock_cell    cell_id=${cell_id}
    ...                                                     timeout=${timeout}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Unblock Cell Should Be Expected   operation_id=${out["id"]}
    ...                                                                          expected_status=success
    [Teardown]    vDU Logout By Rest


vDU Login By Rest
    [Arguments]    ${restapi_version}=cuoam_21b    ${vdu_index}=0    ${gnb_index}=0    ${alias}=default
    [Documentation]    this kw is used to Login vDU By Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | restapi_version | yes | define api version |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Login By Rest |
    ...
    ${oam_httpaddr}    set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    Run keyword and ignore error    vDU Logout By Rest    vdu_index=${vdu_index}
    ${vdu_connection}=    Run Keyword If    '${restapi_version}'=='cuoam_21b'    vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}
    ...  ELSE    vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=8081
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}

vDU Logout By Rest
    [Arguments]    ${alias}=default
    [Documentation]  this kw is used to Logout vDU By Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Logout By Rest  |
    ...
    vdu.disconnect    ${alias}

Get vDU K8s Master SSH Connection Info
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0
    [Documentation]    this kw is used to Get vDU K8s Master SSH Connection Info
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | ${du_info} | return addr/usename/password/port |
    ...
    ...    Example
    ...    | ${du_info} | Get vDU K8s Master SSH Connection Info |
    ...
    ${result}    ${addr}        Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    Should Be True    "${result}"=="PASS"    Please give K8s Master SSH ip in __init__.py for vdu_index=${vdu_index}

    ${result}    ${username}    Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    Should Be True  "${result}"=="PASS"    Please give K8s Master SSH username in __init__.py for vdu_index=${vdu_index}

    ${result}    ${password}    Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    Should Be True  "${result}"=="PASS"    Please give K8s Master SSH password in __init__.py for vdu_index=${vdu_index}

    ${result}    ${port}        Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.port}
    Should Be True    "${result}"=="PASS"    Please give K8s Master SSH port in __init__.py for vdu_index=${vdu_index}

    ${du_info}    create dictionary    addr=${addr}    username=${username}    password=${password}    port=${port}
    [Return]  ${du_info}

Get vDU Namespace From Config File
    [Arguments]    ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]    this kw is used to Get vDU Namespace From Config File
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | ${vdu_namespace} | return vdu namespace|
    ...
    ...    Example
    ...    | ${vdu_namespace} | Get vDU Namespace From Config File |
    ...
    ${vdu_namespace}=    set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    [Return]    ${vdu_namespace}

Connect To K8s Master In vDU
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    [Documentation]   Connect To K8s Master In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...    | alias      | no   | alias, default value is default |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Connect To K8s Master In vDU  | alias=${alias} |
    ...
    ${vdu_k8s_master_ssh_connection_info}    Get vDU K8s Master SSH Connection Info    gnb_index=${gnb_index}
    ...                                                                             vdu_index=${vdu_index}
    ${ip}    set variable    ${vdu_k8s_master_ssh_connection_info["addr"]}
    ${username}    set variable    ${vdu_k8s_master_ssh_connection_info["username"]}
    ${password}    set variable    ${vdu_k8s_master_ssh_connection_info["password"]}

    ${prompt}    set variable    \\[cloudadmin@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt}    set variable    ${prompt}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt}    set variable    ${prompt}|\\[core@\\S+\\s\\S+\\]\\$
    ${prompt}  set variable   ${prompt}|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$
    issh.Connect_To    ip=${ip}    username=${username}    password=${password}
       ...   prompt=${prompt}
       ...   alias=${alias}
       ...   width=200
       ...   timeout=150

Verify Pcell throughput
   [Arguments]    ${UE_ID}    ${Pcell_TP}
    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#    ${dl_throughput_Scell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_pcell}>=${Pcell_TP}
    log to console    dl_throughput_pcell result is ${dl_throughput_pcell} and target is ${Pcell_TP}

Check throughput
    [Arguments]    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
    Wait until keyword succeeds    48s    6s    Verify throughput    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}

Verify throughput
    [Arguments]    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
    run keyword and continue on failure    should_be_true    ${dl_throughput_pcell}>=${Pcell_TP}
    run keyword and continue on failure    should_be_true    ${dl_throughput_scell1}>=${Scell_TP}
    log to console    dl_throughput_pcell result is ${dl_throughput_pcell} and target is ${Pcell_TP}
    log to console    dl_throughput_scell1 result is ${dl_throughput_scell1} and target is ${Scell_TP}

Analyse scelladd in rrclog
    [Arguments]    ${tag}    ${ini}
    check_log_with_au2anlysis    ${CURDIR}/ini/${ini}    p
    ...  save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tag}_egate

Collect AP egate log
    [Arguments]    ${tag}
    Wait '2s' for stabible
    airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/${tag}_egate    unzip=TRUE

Capture tti and check bler
    [Arguments]    ${tti_log}
    ${id}    VDU Start TTiTrace Log
    Wait '1s' for stable
    VDU Stop TTiTrace Log    ${id}
    VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}/All/${tti_log}/tti1
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_log}/

Modify Swconfig for AP
    Modify AP swconfig    @{Rdparameter}


Stop data transfer
    [Arguments]    ${UE_ID}
    airphone_sa_stop_data_traffic    ue_id=${UE_ID}    direction=dl

Detach UE
    [Arguments]    ${UE_ID}
    airphone_sa_detach    ue_id=${UE_ID}    timeout=30

