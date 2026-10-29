*** Settings ***
Documentation
...   author: Tong Chen
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02
Resource     Resources/Resource_common_keywords.robot
Library      taf.hw.mcs    WITH NAME    mcs

*** Variables ***
${mcs_ip}    ${tl.mcses.ip_addr}
${mcs_model}    ${tl.mcses.model}
&{fault_10}       faultId=${10}    source=RMOD_R-1    severity=Critical    # No connection to unit
&{fault_4687}       faultId=${4687}    source=RMOD_R-1    # CPRI RU Migration to eCPRI Mode Required
&{fault_61524}    faultId=${61524}    source=SMOD_R-1    #faultId:SSH_ENABLED  source:RU1
&{fault_61652}    faultId=${61652}    source=SMOD_R-1    #faultId:R&D_SERVICE_PORT_ENABLED  source:RU1
&{fault_9000}    faultId=${9000}    source=SMOD_R-1    #faultId:BTS booted due to software restart  source:RU1
&{fault_7319}    faultId=${7319}    source=NRBTS     #faultId:EFaultId_X2LinkNotAvailableAl
&{fault_7300}    faultId=${7300}    source=NRBTS     #faultId:EFaultId_NoneX2LinkAvailableAl
&{fault_4527}    faultId=${4527}    source=RMOD_R-1    # Radio diagnostic files collected
&{fault_6450}    faultId=${6450}    source=SMOD_R-1    # diagnostic files collected
&{fault_61649}   faultId=${61649}   source=SMOD_R-1    #LMP access via port 443
&{fault_4592}    faultId=${4592}    source=SMOD_R-1    # BTS booted due to Power On.
&{fault_4654}    faultId=${4654}    source=SMOD_R-1     #Ethernet port security is disabled
&{fault_4655}    faultId=${4655}    source=-    #Service account root access is enabled
&{fault_4681}    faultId=${4681}    source=MRBTS    #Sanity Check Error
@{ALLOWED_FAULT_LIST}    &{fault_61524}    &{fault_61652}    &{fault_9000}    &{fault_4527}    &{fault_6450}
...                      &{fault_61649}    &{fault_4592}    &{fault_4654}    &{fault_4655}    &{fault_4687}    &{fault_4681}
${TS_CASE_LOG_PATH}   ${OUTPUT DIR}
${btslog_path}    /opt/btslog/btslog
${btslog_launcher_path}    /opt/btslog/btslog_launcher
${btslog_folder}    /tmp/btslog2

*** Keywords ***
Common Suite setup
    [Arguments]    ${if_commissioning}=${False}    ${swconfig_path}=${None}
    ...            ${gnb_type}='SA'
    robot_common_operations.Common Suite Setup
    run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup
    Connect to Common Unit Master    alias=ASIK Master
    log to console    ${gnb_type}
    run keyword if    '${swconfig_path}'!='${None}'    swconf.Upload swConfig file to asik and crasign
    ...               localFilePath=${swconfig_path}    asik_alias=ASIK Master
    ${UE_status}    run keyword and return status    ue.translate_power_ue_type_from_testline
    ${UE_TYPE}   run keyword if   ${UE_status}   ue.translate_power_ue_type_from_testline
    run keyword if   ${UE_status}    set suite variable    ${UE_TYPE}
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    COAM Teardown gnb connections

Common Case setup
    [Timeout]    20 min
    [Arguments]    ${scf_path}=${None}    ${is_pdl_checking_needed}=${False}    ${swconfig_path}=${None}
    ...            ${gnb_type}='SA'    ${need_Btslog}=${False}
    robot_common_operations.Common Case Setup
    COAM Wait for gnb ready and cell setup    gnb_type=${gnb_type}
    run keyword if    '${swconfig_path}'!='${None}'    swconf.Upload swConfig file to asik and crasign
    ...               localFilePath=${swconfig_path}    asik_alias=ASIK Master
    run keyword if    '${scf_path}'!='${None}'    COAM Commission with scf file
    ...               scf_file_path=${scf_path}    timeout=480    is_pdl_checking_needed=${is_pdl_checking_needed}
    COAM Wait for gnb ready and cell setup    gnb_type=${gnb_type}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}/SCF
    ${backup_scf_file}    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    Set Test Variable    ${backup_scf_file}
    COAM selenium close browser
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    Connect to Common Unit Slave
    ${status}    @{RUS_ALIAS}    Run keyword and ignore error    Connect to all rus with allocated IP
    Set suite variable    ${RUS_ALIAS}
    ${ue_reboot_dict}    create dictionary
    set test variable    ${ue_reboot_dict}
    Run keyword If    ${need_Btslog}==${True}    Common Case Capture BTS log

Common Case teardown
    [Timeout]    20 min
    [Arguments]     ${is_need_to_teardown_l3_call}=${False}    ${is_onair_check}=${False}
    ...             ${is_need_to_recover}=${False}    ${need_Btslog}=${False}
    robot_common_operations.Common Case Teardown
    Run keyword if    ${is_need_to_teardown_l3_call}    Teardown l3 call
    Run keyword If    ${need_Btslog}==${True}     Common Case Stop BTS log
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
    Run keyword if    ${is_need_to_recover}
    ...               SG2_Common_setup_teardown.COAM commission scf and wait cell setup    scf_file_path=${backup_scf_file}
    ...    ELSE    Run Keyword If Test Failed
    ...               SG2_Common_setup_teardown.COAM commission scf and wait cell setup    scf_file_path=${backup_scf_file}
    Run keyword if    ${is_onair_check}    Wait until cluster is on cell on air status    timeout=15 min    is_all_cells_checking_needed=${True}
    Run keyword and ignore error    COAM selenium logout
    Teardown all SISO connections
    CI_interface.Common Case Teardown

Teardown all SISO connections
    [Documentation]  Author: Ding Binmei
    ...              Description: Release all connections
    robot_common_operations.Common Suite Teardown
    coam_gnb_classical.COAM Teardown gnb connections
    enb_lte.Enblte close down    connection=enblte
    @{ru_alias}    Create list    RU    RU_1    RU_2    RU_3
    Disconnect ssh connections    list_alias=${ru_alias}
    Run keyword and ignore error    csn.disconnect    connection=SERVICE
    Run keyword and ignore error    csn.disconnect    connection=Container
    @{ssh_alias}    Create list    ABIL Loner_1    ABIL Master    ASIK Master    ABIL Slave    ABIL Loner    ENB    OAM    ASIK Slave
    Disconnect ssh connections    list_alias=${ssh_alias}
    csn.Reset Cache

Teardown l3 call
    [Arguments]    ${ue_type}=${UE_TYPE}
    Close iperf progress
    power_ue.UE Detach    ue_type=${ue_type}

COAM commission scf and wait cell setup
    [Arguments]    ${scf_file_path}    ${is_pdl_checking_needed}=${False}    ${gnb_type}='SA'
    COAM Commission with scf file    scf_file_path=${scf_file_path}    timeout=480    is_pdl_checking_needed=${is_pdl_checking_needed}
    Wait Until Keyword Succeeds   20 min  5min   COAM Wait for gnb ready and cell setup    gnb_type=${gnb_type}

Close iperf progress
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${data_transfer_direction}=both     ${ue_type}=${UE_TYPE}
    run keyword if     '${ue_type}' == 'huawei'    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP
    ${iperf_ul}    Set variable if    '${ue_type}' == 'inseego' or '${ue_type}' == 'mtk'
    ...    ${None}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
    ${iperf_dl}    Set variable if      '${ue_type}' == 'inseego' or '${ue_type}' == 'mtk'
    ...    ${None}    ${tl.ues[0].iperf_details.port}
    Run keyword if    '${data_transfer_direction}'=='both'
    ...    Run keywords     power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    ...            dt_name=dt_ul    iperf_port=${iperf_ul}    AND
    ...                     power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    ...            dt_name=dt_dl    iperf_port=${iperf_dl}
    ...    ELSE IF    '${data_transfer_direction}'=='ul'
    ...        power_ue.Stop traffic    ue_type=${ue_type}    direction=${data_transfer_direction}
    ...            dt_name=dt_${data_transfer_direction}    iperf_port=${iperf_ul}
    ...    ELSE IF    '${data_transfer_direction}'=='dl'
    ...        power_ue.Stop traffic    ue_type=${ue_type}    direction=${data_transfer_direction}
    ...            dt_name=dt_${data_transfer_direction}    iperf_port=${iperf_dl}
    ...    ELSE    Should be true    ${False}    msg=Invalid input for data_transfer_direction, supported values are: both, ul, dl

MCS Set angle
    [Arguments]    ${horizontal_set}    ${vertical_set}    ${port_num}=${16}
    MCS Setup    ip=${mcs_ip}    model=${mcs_model}    vendor=hbte
    ${port}      Set Variable    ${1}
    FOR    ${i}    IN RANGE    ${port_num}
        ${vertical}    Convert To Number    ${vertical_set}[${i}]
        ${horizontal}    Convert To Number    ${horizontal_set}[${i}]
        mcs.set_phases_according_to_angles    vertical_angle=${vertical}    horizontal_angle=${horizontal}
        ...    vertical_distance=${2.1}    horizontal_distance=${0.5}    output_group_id=${port}
        ${port}      Evaluate    ${port}+1
    END
    MCS Teardown

MCS Setup
    [Arguments]    ${ip}    ${model}    ${vendor}=HBTE
    mcs.setup    ip=${ip}    model=${model}    vendor=${vendor}

MCS Teardown
    mcs.teardown

Common Case Capture BTS log
    ${date}    Evaluate    datetime.datetime.now().strftime('%Y-%m-%d-%H%M%S')    datetime
    Run keyword and ignore Error    Common Case Btslog Setup    name=btslog_${date}    path=${btslog_path}
    ...    launcher_path=${btslog_launcher_path}    log_folder=${btslog_folder}
    Set test variable    ${date}

Common Case Stop BTS log
    [Arguments]    ${btslog_name}=btslog_${date}
    Run keyword And Ignore Error    Common Case Btslog Teardown    name=${btslog_name}

Common Case Btslog Setup
    [Arguments]    ${name}      ${path}    ${launcher_path}    ${log_folder}
    ${executor_test_vm}=      Create Dictionary
    ...    host=${tl.test_pc.default_ssh_connection_details.addr}
    ...    user=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}
    ${command}     Catenate     rm -rf ${log_folder}/SYSLOG*.LOG
    Run    ${command}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    btslog_path=${path}
    ...    btslog_launcher_path=${launcher_path}
    ...    executor=${executor_test_vm}
    ...    log_dir=${log_folder}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}
    btslog.Set Suite Alias     ${name}

Common Case Btslog Teardown
    [Arguments]    ${name}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}
    core.teardown_collectors    names=${name}
