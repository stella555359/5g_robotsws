*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin      WITH NAME    coam
Library    taf.collectors.btslog        WITH NAME    btslog
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Library    ../../CB007841/Resources/CB007841_common.py
Resource    ../../../../OAM/RAN_PZ_HAZ_34/CB007308-5G-AB/Resources/CB007308-5G-AB_FID4657_keywords.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${DU_OAM_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_WEBUI_URL}    https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${DU_OAM_WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UTE_ADDRESS}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
${BTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${default_scf_path}     ${CURDIR}/../../../../../../commissionings/HGZ/7_5_UTE5G402T700/
${LOG_PATH}    ${OUTPUT DIR}
@{ignore_history_fault}    ${7319}    ${7300}    ${9000}    ${61524}    ${61652}    ${61649}
...    ${61074}    ${61618}    ${4592}    ${1932}    ${4420}    ${4340}    ${4655}    ${4654}

*** Keywords ***
SBTS Login
    [Arguments]    ${ip_address}=${DU_OAM_IP}    ${username}=${DU_OAM_WEBUI_USER}
    ...    ${password}=${DU_OAM_WEBUI_PASSWORD}    ${alias}=default
    [Documentation]   SBTS Login
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${connection}    set variable    ${alias}
    [Return]    ${connection}

SBTS Logout
    [Arguments]   ${alias}=default
    [Documentation]   SBTS Logout
    coam.Teardown    connection=${alias}

Check BTS Should Be Normal
    Log To Console  Check BTS Should Be Normal
    SBTS Login
    Wait Until BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   SBTS Logout

Wait Until BTS Should Be Normal
    [Arguments]    ${retry}=1000s    ${retry_interval}=10s    ${alias}=default
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    comm_9260.Gnb Cell Should Be Onair    alias=${alias}

Gnb Cell Should Be Onair
    [Arguments]    ${alias}=default    ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    should be equal as strings    ${operationalState}    Enabled    ignore_case=${True}
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    should be equal as strings    ${blockingState}    Unblocked    ignore_case=${True}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    should be equal as strings    ${proceduralState}    OnAir    ignore_case=${True}
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}    connection=${alias}
    FOR    ${item}    IN    @{cell_status}
        ${Status}    Get From Dictionary    ${item}    status
        ${tmp}   Get From Dictionary    ${status}    operationalState
        should be equal as strings    ${tmp}    Enabled    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  administrativeState
        should be equal as strings    ${tmp}    Unlocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  blockingState
        should be equal as strings    ${tmp}    Unblocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  usageState
        should be equal as strings    ${tmp}    Active    ignore_case=${True}
    END

suite setup to prepare default scf
    [Arguments]    ${SBTS_scf_name}    ${Branch_scf_name}    ${branch_version}=SBTS23R1
    Log To Console    Set Default Scf
    ${connection}    SBTS Login
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_branch_load}     run keyword and return status    should contain    ${version_list[0]}    ${branch_version}
    ${default_scf}    set variable if    ${if_branch_load}    ${default_scf_path}${Branch_scf_name}
    ...    ${default_scf_path}${SBTS_scf_name}
    log to console   ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${default_scf}

Commission Default SCF
    [Arguments]    ${default_scf}
    Log To Console    Commission Default SCF
    ${connection}    SBTS Login
    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}    is_pdl_checking_needed=${False}
    Wait Until BTS Should Be Normal
    Check if Unexpected History Alarm Exist
    [Teardown]    coam.Teardown   connection=${connection}

Check if Unexpected History Alarm Exist
    ${fault_id_list}    Get BTS History Alarm FaultID
    return from keyword if    '${fault_id_list}' == '[]'
    ${ignore_fault}    set variable    ${ignore_history_fault}
    FOR    ${item}    IN    @{fault_id_list}
        run keyword and continue on failure    list should contain value    ${ignore_fault}    ${item}
    END

Get BTS History Alarm FaultID
    [Arguments]    ${connection}=default
    Log To Console    get history alarm faultid
    ${alarm_info}    coam.get_historic_alarms    timeout=60    connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${fault_id_list}    ${fault_id_dic}
    END
    sort list    ${fault_id_list}
    [Return]    ${fault_id_list}

Save Snapshot Log
    [Arguments]    ${connection}=default    ${timeout}=600s
    Log To Console    Save Snapshot Log
    ${timestamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_file_path}    set variable    ${LOG_PATH}/${timestamp}_snapshot.zip
    coam.get_snapshot    target_file_name=${snapshot_file_path}    connection=${connection}    timeout=${timeout}
    sleep    30s
    [Return]    ${snapshot_file_path}

Extract logs from snapshot
    [Arguments]    ${snapshot_file}    ${RMOD_SN}    ${filter_para}='{print $3}'|cut -d "<" -f 2|cut -d ">" -f 1|cut -d "." -f 1|cut -d "T" -f 2
    ...    ${Ready}="Initializing, to: Ready"    ${Cooled}="Cooled transceiver detected"
    ...    ${file}=snapshot_file_list.txt    ${f_length}=-E -w "[^[:space:]]{36}"
    ${timestamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${zipout}    Set Variable    zipout_${timestamp}
    Run    command=unzip ${snapshot_file} -d ${LOG_PATH}/${zipout}
    ${searchName}    Run
    ...    command=cd ${LOG_PATH}/${zipout};find . -name ${file} |xargs grep "_startup" |grep "${RMOD_SN}_RMOD" |grep ${f_length}
    ${searchName}   split string   ${searchName}    \n
    log to console     ${searchName}
    FOR     ${item}    IN     @{searchName}
        ${item}    Remove String    ${item}     ${SPACE}
        ${result_zip}    searchFile      filename=${LOG_PATH}/${zipout}/snapshot_file_list.txt      searchName=${item}
        Run    command=unzip ${LOG_PATH}/${zipout}/${result_zip.split(":")[0]} -d ${LOG_PATH}/${zipout}
        Run    command=unzip ${LOG_PATH}/${zipout}/${item} -d ${LOG_PATH}/${zipout}
        Run    command=cd ${LOG_PATH}/${zipout};unxz startup_DEFAULT.log.xz
        ${Initializing_time}    Run    command=cat ${LOG_PATH}/${zipout}/startup_DEFAULT.log |grep ${Ready}|tail -1 |awk ${filter_para}
        ${Detecting_time}    Run    command=cat ${LOG_PATH}/${zipout}/startup_DEFAULT.log |grep ${Cooled} |tail -1 |awk ${filter_para}
        ${Initializing_time}    DateTime.Convert Time    ${Initializing_time}
        ${Detecting_time}      DateTime.Convert Time      ${Detecting_time}
        ${return_deviation}      Evaluate    ${Initializing_time}-${Detecting_time}
        should be true    ${return_deviation}<90
   END

Check CooledTransceiverDeclaration
    [Arguments]    ${connection}=default    ${BBMOD_runtime}=CABINET_R-1/BBMOD_R-1    ${S_RF_physicalPort}=S_RF2    ${Q_RF_physicalPort}=Q_RF2
    ...    ${RMOD_runtime}=RMOD_R-2    ${IF0_physicalPort}=OPT_IF0    ${IF1_physicalPort}=OPT_IF1
    Log To Console    check port S_RF
    _check SFP cooledTransceiverDeclaration    connection=${connection}    expected_physicalPort=${S_RF_physicalPort}    runtime=${BBMOD_runtime}
    Log To Console    check port Q_RF
    _check SFP cooledTransceiverDeclaration    connection=${connection}    expected_physicalPort=${Q_RF_physicalPort}    runtime=${BBMOD_runtime}
    Log To Console    check port OPT_IF0
    _check SFP cooledTransceiverDeclaration    connection=${connection}    expected_physicalPort=${IF0_physicalPort}    runtime=${RMOD_runtime}
    Log To Console    check port OPT_IF1
    _check SFP cooledTransceiverDeclaration    connection=${connection}    expected_physicalPort=${IF1_physicalPort}    runtime=${RMOD_runtime}

_check SFP cooledTransceiverDeclaration
    [Arguments]    ${connection}    ${expected_physicalPort}    ${runtime}
    FOR     ${i}    IN RANGE    ${1}    ${20}
        ${SFP_status}    run keyword and return status    coam.get_parameters
        ...   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/${runtime}/SFP_R-${i}
        ...   connection=${connection}
        ${expected_SFP_status}    run keyword if    ${SFP_status}
        ...    coam.get_parameters
        ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/${runtime}/SFP_R-${i}
        ...    connection=${connection}    ELSE    Continue For Loop
        ${physicalPort}    get from dictionary    ${expected_SFP_status}     physicalPort
        ${if_phyport}     run keyword and return status    should be equal     ${physicalPort}   ${expected_physicalPort}
        ${SFP_status}    set variable if    ${if_phyport}    ${expected_SFP_status}
        Exit For Loop If    '${if_phyport}'=='${True}'
    END
    ${cooledTrans_status}    get from dictionary    ${SFP_status}     cooledTransceiverDeclaration
    should be equal as strings    ${cooledTrans_status}    True    ignore_case=${True}

Check Port ModTemp
    [Arguments]    ${connection}=default    ${EIF_runtime}=CABINET_L-1/SMOD_L-1    ${port_EIF}=EIF1    ${SRF_runtime}=CABINET_L-1/BBMOD_L-1
    ...    ${port_SRF}=S_RF2    ${OPT_IF_runtime}=RMOD_L-2    ${port_OPT_IF0}=OPT_IF0    ${port_OPT_IF1}=OPT_IF1
    ...    ${QRF_runtime}=BBMOD_L-1    ${port_QRF}=Q-RF2
    Log To Console    check port EIF
    _check modtemp    connection=${connection}    runtime=${EIF_runtime}    expected_con_Label=${port_EIF}
    Log To Console    check port SRF
    _check modtemp    connection=${connection}    runtime=${SRF_runtime}    expected_con_Label=${port_SRF}
    Log To Console    check port OPT_IF
    _check modtemp    connection=${connection}    runtime=${OPT_IF_runtime}    expected_con_Label=${port_OPT_IF0}
    _check modtemp    connection=${connection}    runtime=${OPT_IF_runtime}    expected_con_Label=${port_OPT_IF1}
    Log To Console    check port QRF
    _check QRF modtemp    connection=${connection}    runtime=${QRF_runtime}    expected_con_Label=${port_QRF}

_check modtemp
    [Arguments]    ${connection}    ${runtime}    ${expected_con_Label}
    FOR     ${i}    IN RANGE    ${1}    ${20}
        ${CONNECTOR_status}    run keyword and return status    coam.get_parameters
        ...   dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/${runtime}/CONNECTOR_L-${i}    connection=${connection}
        ${expected_CONNECTOR_status}    run keyword if    ${CONNECTOR_status}
        ...    coam.get_parameters
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/${runtime}/CONNECTOR_L-${i}    connection=${connection}
        ...    ELSE    Continue For Loop
        ${connectorLabel}    get from dictionary    ${expected_CONNECTOR_status}     connectorLabel
        ${if_label}     run keyword and return status    should be equal     ${connectorLabel}   ${expected_con_Label}
        ${SFP_status}    run keyword if    ${if_label}
        ...    coam.get_parameters
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/${runtime}/CONNECTOR_L-${i}/SFP_L-1/SFP_PARAMS_L-1    connection=${connection}
        Exit For Loop If    '${if_label}'=='${True}'
    END
    ${modTemp}    get from dictionary    ${SFP_status}     modTemp
    ${temperatureHighAlarmThreshold}    get from dictionary    ${SFP_status}     temperatureHighAlarmThreshold
    ${temperatureLowAlarmThreshold}    get from dictionary    ${SFP_status}     temperatureLowAlarmThreshold
    should be true    ${temperatureLowAlarmThreshold} < ${modTemp} < ${temperatureHighAlarmThreshold}

_check QRF modtemp
    [Arguments]    ${connection}    ${runtime}    ${expected_con_Label}
    FOR     ${i}    IN RANGE    ${1}    ${20}
        ${CONNECTOR_status}    run keyword and return status    coam.get_parameters
        ...   dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/${runtime}/CONCENTRATOR_L-${i}    connection=${connection}
        ${expected_CONNECTOR_status}    run keyword if    ${CONNECTOR_status}
        ...    coam.get_parameters
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/${runtime}/CONCENTRATOR_L-${i}    connection=${connection}
        ...    ELSE    Continue For Loop
        ${connectorLabel}    get from dictionary    ${expected_CONNECTOR_status}     concentratorLabel
        ${if_label}     run keyword and return status    should be equal     ${connectorLabel}   ${expected_con_Label}
        ${SFP_status}    run keyword if    ${if_label}
        ...    coam.get_parameters
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/${runtime}/CONCENTRATOR_L-${i}/CONNECTOR_L-1/SFP_L-1/SFP_PARAMS_L-1
        ...    connection=${connection}
        Exit For Loop If    '${if_label}'=='${True}'
    END
    ${modTemp}    get from dictionary    ${SFP_status}     modTemp
    ${temperatureHighAlarmThreshold}    get from dictionary    ${SFP_status}     temperatureHighAlarmThreshold
    ${temperatureLowAlarmThreshold}    get from dictionary    ${SFP_status}     temperatureLowAlarmThreshold
    should be true    ${temperatureLowAlarmThreshold} < ${modTemp} < ${temperatureHighAlarmThreshold}

Delete sfp in sfpwhitelist
    [Arguments]    ${sfp_model1}=FOTB    ${sfp_model2}=AOZEA
    Log To Console    Set SFPWhiteList File Name
    Set SFPWhiteList File Name
    Create dir
    Download whitelist file
    Log To Console    Delete parameter in sfpwhitelist
    Delete parameter in sfpwhitelist    sfp_model=${sfp_model1}
    Delete parameter in sfpwhitelist    sfp_model=${sfp_model2}
    Upload whitelist file    upload_whitelist_path=${SFPwhitelist_PATH}${SFPwhitelist_NAME}

Reset BTS And Wait Until On Air
    [Arguments]    ${connection}=default
    Log To Console    Reset BTS And Wait Until On Air
    sleep    2s
    coam.reset_site    connection=${connection}
    Log To Console    wait until bts should be normal
    wait until bts should be normal    retry=648s

Get Alarm HwPath List
    [Arguments]    ${faultID}    ${connection}=default
    Log To Console    Get Alarm HwPath List
    ${alarm_info}    coam.get_active_alarms    timeout=60    connection=${connection}
    ${hwPath_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${dic_fault_id}    get from dictionary    ${item}    additionalFaultID
        ${hwPath}    run keyword if    '${dic_fault_id}' == '${faultID}'    get from dictionary    ${item}    hwPath
        ...    ELSE    Continue For Loop
        append to list    ${hwPath_list}    ${hwPath}
    END
    [Return]    ${hwPath_list}

Check SFP Status
    [Arguments]    ${connection}=default    ${EIF_runtime}=CABINET_L-1/SMOD_L-1    ${port_EIF}=EIF1    ${SRF_runtime}=CABINET_L-1/BBMOD_L-1
    ...    ${port_SRF}=S_RF2    ${OPT_IF_runtime}=RMOD_L-1    ${port_OPT_IF0}=OPT_IF0    ${port_OPT_IF1}=OPT_IF1
    ...    ${QRF_runtime}=BBMOD_L-1    ${port_QRF}=Q-RF2    ${expected_status}=Degraded
    Log To Console    check EIF1 status
    _check bts sfp availabilityStatus    connection=${connection}    runtime=${EIF_runtime}    expected_con_Label=${port_EIF}
    ...    expected_status=${expected_status}
    Log To Console    check S_RF2 status
    _check bts sfp availabilityStatus    connection=${connection}    runtime=${SRF_runtime}    expected_con_Label=${port_SRF}
    ...    expected_status=${expected_status}
    Log To Console    check OPT_IF0 status
    _check bts sfp availabilityStatus    connection=${connection}    runtime=${OPT_IF_runtime}    expected_con_Label=${port_OPT_IF0}
    ...    expected_status=${expected_status}
    Log To Console    check OPT_IF1 status
    _check bts sfp availabilityStatus    connection=${connection}    runtime=${OPT_IF_runtime}    expected_con_Label=${port_OPT_IF1}
    ...    expected_status=${expected_status}
    Log To Console    check Q-RF2 status
    _check QRF availabilityStatus    connection=${connection}    runtime=${QRF_runtime}    expected_con_Label=${port_QRF}
    ...    expected_status=${expected_status}

_check bts sfp availabilityStatus
    [Arguments]    ${connection}    ${runtime}    ${expected_con_Label}   ${expected_status}
    FOR     ${i}    IN RANGE    ${1}    ${20}
        ${CONNECTOR_status}    run keyword and return status    coam.get_parameters
        ...   dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/${runtime}/CONNECTOR_L-${i}    connection=${connection}
        ${expected_CONNECTOR_status}    run keyword if    ${CONNECTOR_status}
        ...    coam.get_parameters
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/${runtime}/CONNECTOR_L-${i}    connection=${connection}
        ...    ELSE    Continue For Loop
        ${connectorLabel}    get from dictionary    ${expected_CONNECTOR_status}     connectorLabel
        ${if_label}     run keyword and return status    should be equal     ${connectorLabel}   ${expected_con_Label}
        ${SFP_status}    run keyword if    ${if_label}
        ...    coam.get_parameters
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/${runtime}/CONNECTOR_L-${i}/SFP_L-1    connection=${connection}
        Exit For Loop If    '${if_label}'=='${True}'
    END
    ${stateInfo_dic}    get from dictionary    ${SFP_status}     stateInfo
    ${availabilityStatus}    get from dictionary    ${stateInfo_dic}     availabilityStatus
    should be equal as strings    ${availabilityStatus}    ${expected_status}    ignore_case=${True}

_check QRF availabilityStatus
    [Arguments]    ${connection}    ${runtime}    ${expected_con_Label}   ${expected_status}
    FOR     ${i}    IN RANGE    ${1}    ${20}
        ${CONNECTOR_status}    run keyword and return status    coam.get_parameters
        ...   dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/${runtime}/CONCENTRATOR_L-${i}    connection=${connection}
        ${expected_CONNECTOR_status}    run keyword if    ${CONNECTOR_status}
        ...    coam.get_parameters
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/${runtime}/CONCENTRATOR_L-${i}    connection=${connection}
        ...    ELSE    Continue For Loop
        ${connectorLabel}    get from dictionary    ${expected_CONNECTOR_status}     concentratorLabel
        ${if_label}     run keyword and return status    should be equal     ${connectorLabel}   ${expected_con_Label}
        ${SFP_status}    run keyword if    ${if_label}
        ...    coam.get_parameters
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/${runtime}/CONCENTRATOR_L-${i}/CONNECTOR_L-1/SFP_L-1
        ...    connection=${connection}
        Exit For Loop If    '${if_label}'=='${True}'
    END
    ${stateInfo_dic}    get from dictionary    ${SFP_status}     stateInfo
    ${availabilityStatus}    get from dictionary    ${stateInfo_dic}     availabilityStatus
    should be equal as strings    ${availabilityStatus}    ${expected_status}    ignore_case=${True}

Check No Expected Fault
    [Arguments]    ${fault_id}    ${connection}=default
    Log To Console    Check No Expected Fault
    ${alarm_info}    coam.get_active_alarms    timeout=60    connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${fault_id_list}    ${fault_id_dic}
    END
    sort list    ${fault_id_list}
    list should not contain value    ${fault_id_list}    ${fault_id}

Modify Parameter SfpOperatorMode
    [Arguments]    ${Actual_value}    ${connection}=default
    Log To Console     Modify Parameter SfpOperatorMode
    ${dict}    create dictionary    parameterName=sfpOperatorMode    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1    parameter=${list}
    ...    operation=update     skip_parameter_relation_errors=${False}    should_activate=${True}    connection=${connection}
    sleep    3s
    Wait Until BTS Should Be Normal    alias=${connection}
