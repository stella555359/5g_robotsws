*** Settings ***

Documentation     Keywords For interface robot

Library     taf.ul.oam.selenium_coam        WITH NAME    selenium_coam
Library     taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
Library     taf.gnb.oam.coam.admin          WITH NAME    coamadmin
Library     taf.gnb.oam.megazone_client     WITH NAME    megazone_client
Library     taf.gnb.oam.commissioning       WITH NAME    commissioning
#Library     taf.collectors.tcpdump      WITH NAME   tcpdump
Library     taf.collectors.core         WITH NAME   core
Library     taf.transport.ssh           WITH NAME   SSH
Library     taf.collectors.btslog       WITH NAME   btslog
Library     taf.gnb.oam.coam.cu         WITH NAME    cu
Library     Telnet


*** Variables ***
${CFG_PATH}    /opt/iphy/latest
${SCF_NAME}    scf.xml
${ECPRI_SCF_NAME}    scf_ecpri.xml
${CU_SCF_NAME}    cu_scf.xml
${DU_SCF_NAME}    du_scf.xml
${DU_MODIFIED_SCF}    modified_du_scf.xml
${CU_MODIFIED_SCF}    modified_cu_scf.xml
${SUITE_MODIFED_SCF}    suite_modified_scf.xml
${CFG_FILE}    basic_setup.cfg
${l2PS_NAME}    l2PSNodeId
@{SCF_PARAMS}
@{SCF_PARAMS_CU}
@{SW_PARAMS}
${TL_TYPE}
&{USER_CONFIG}
@{pci_gscn_list}
${GNBIP}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#${AirPhoneIP}    ${tl.ues[0].l1.common_units[0].lmp_connection.addr}
${USER}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${PW}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${APStartSosReportFile}    AP_Classical_Fullstack_startTestwithSosReport.sh
${APStopSosReportFile}    AP_Classical_Fullstack_stopTestwithSosReport.sh
${LOG_DIR_ON_DEVICE}    /ffs/run/config/toor4nsn/logs/
@{pcapFileList}    gnb:${LOG_DIR_ON_DEVICE}/BTS_traffic_L1L2*.pcap*
...    gnb:${LOG_DIR_ON_DEVICE}/BTS_traffic_rlan0_FPGA*.pcap.*
...    ap:${LOG_DIR_ON_DEVICE}/AP_traffic_L1L2*.pcap.*
...    ap:${LOG_DIR_ON_DEVICE}/AP_traffic_rlan0_FPGA*.pcap.*
${localPcapPath}    /home/ute/pcap_download/
${ignore_pci}     none
@{ENABLE_DEBUG_FLAGS}    0x590072=1    0x41001b=1     0x340000=15
@{ENABLE_DEBUG_FLAGS_CLOUD_DU}    0x590072=1    0x340000=15
@{SA_AP_FLAGS}
@{AP_FLAGS_ASIB}
@{AP_FLAGS_L2RT}    0x420028=0
@{GNB_FLAGS}    classical:TDD::SA:::0x580010=0x3F    classical::GNB_ASIL:::5G21B:0x20109=1    classical::GNB_ASIL:::SBTS21B:0x20109=1
...    classical::GNB_ASIB:::5G21B:0x20109=1    0x10041=5    classical::GNB_ASIB:::SBTS21B:0x20109=1    0x340003=1    0x34000E=55120
@{AP_FLAGS}    0x420028=0    0x200f0=0
@{AP_CFG_PARA_LINES}
${DEBUG_MODE}     ${False}
&{HW_Adapt_parameters}    ASIB_ABIL_Right_FS=${asib_abil_right_fs}
&{asib_abil_right_fs}    scf_xml=${aarf_scf}    iphy_xml=${aarf_iphy}    wts_xml=${aarf_wts}
&{aarf_scf}    dist_name=MRBTS-1/EQM-1/APEQM-1/CABINET-1/SMOD-1    p_name=positionInSubrack      p_value=RightSide
${AEUB_RMOD_PROCODE}    474608A
${AEQE_RMOD_PROCODE}    474750A
${AEQN_RMOD_PROCODE}    474736A
${AEQA_RMOD_PROCODE}    474021A
${AHLOA_RMOD_PROCODE}    474331A
${AEUA_RMOD_PROCODE}    474214A
${AAHF_RMOD_PROCODE}    474020A
&{aarf_iphy}    l2PsNodeId=8778
&{aarf_wts}    l2PSNodeId=8778
@{FAULT_WHITE_LIST}
@{FAULT_START}
@{FAULT_END}
${SCENARIO}
${REPORT_TO_REP}    False


*** Keywords ***
CP Common Suite Setup
    [Documentation]
    ...    :Author:
    ...
    ...     This is the CP common suite setup, It works in processing
    ...
    BuiltIn.log    Start CP Common Suite Setup
    Set Suite Variable    ${SUITE_RUN_STATUS}    START
    prepare suite info
    gen_dynamic_full_commission_data
    run keyword if   ${DEBUG_MODE}==${False}   Prepare Test Configuration
    [Teardown]    run keyword if   ${DEBUG_MODE}==${False}   Teardown For Suite Setup

prepare suite info
    [Documentation]
    ...    :Author:
    ...
    ...    This keyword is used to collect the suite level information, all the information will be stored at one
    ...    object
    should not be empty    ${TL_TYPE}
    ${SUITE_INF}    get_suite_info    tl_type=${TL_TYPE}    scf_name=${SCF_NAME}    ecpri_scf_name=${ECPRI_SCF_NAME}
    ...    cu_scf_name=${CU_SCF_NAME}    du_scf_name=${DU_SCF_NAME}    scf_params=${SCF_PARAMS}
    ...    scf_params_cu=${SCF_PARAMS_CU}    sw_params=${SW_PARAMS}    user_config=${USER_CONFIG}
    ...    gnb_flags=${GNB_FLAGS}    ap_flags=${AP_FLAGS}    golden_cfg_dir=${CURDIR}/../config
    ...    ap_cfg_para_lines=${AP_CFG_PARA_LINES}
    Set Suite Variable    \${SUITE_INF}
    set suite Variable    ${HW_TYPE}    ${SUITE_INF.gnb_bbu_type}_${SUITE_INF.rack_position}_${SUITE_INF.l1_mode}
    set suite Variable    ${SUITE_LOG_DIRECTORY}    ${SUITE_INF.suite_log_dir}/
    set suite Variable    ${BOARD_POSITION}    ${SUITE_INF.rack_position}
    Set Suite Variable    ${ENV_TYPE}    ${SUITE_INF.network_mode}
    Set Suite Variable    ${TL_CONFIG_TYPE}    UTE
    Set Suite Variable    ${SMOD}    ${SUITE_INF.gnb_smod}
    Set Suite Variable    ${BBMOD}    ${SUITE_INF.gnb_bbmod}
    ${CONFIG_PATH}    set variable if    "${SUITE_INF.cfg_mode}"=="default"    ${EMPTY}    ${SUITE_INF.cfg_dir}
    Set Suite Variable    \${CONFIG_PATH}
    ${ap_file_name}    set variable if    "${SUITE_INF.cfg_mode}"=="default"    ${EMPTY}    ${SUITE_INF.modify_wts_xml}
    Set Suite Variable    \${ap_file_name}

gen_dynamic_full_commission_data
    ${full_data}    gen_full_commission_data    ${SUITE_INF}    ${SCENARIO}    user_cm=${SCF_PARAMS}
    ...    user_cfg=${AP_CFG_PARA_LINES}
    ${SUITE_INF.ap_cfg_para_lines}   set variable    ${full_data.cfg_data}
    ${SUITE_INF.scf_params}   set variable    ${full_data.cm_data}

gen_verify_data
        [Arguments]    ${scenario}
        ${wireshark_msgs}    Gen Wireshark Msg Verify Data    ${SUITE_INF}    ${scenario}
        ${wireshark_msg_flow}    Gen Wireshark Msg Flow Verify Data    ${SUITE_INF}    ${scenario}
        ${counters}    Gen Measurement Verify Data    ${SUITE_INF}    ${scenario}
        [RETURN]    ${wireshark_msgs}    ${wireshark_msg_flow}    ${counters}

Prepare Test Configuration
    Run keyword if    'cloud' in '${TL_TYPE}'    set suite variable    ${GNBIP}
    ...    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    Run keyword if    'cloud' in '${TL_TYPE}'    set suite variable    ${USER}
    ...    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    Run keyword if    'cloud' in '${TL_TYPE}'    set suite variable    ${PW}
    ...    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    start log collection
    Set Suite Variable    ${DUMP_STATUS}    START
    Golden And Default Config
    Start egate
    ${result}  run keyword and return status    wait cell on air and mib sib ready
    run keyword if  '${result}'== 'False'    run keywords
    ...             Kill egate before commission    AND
    ...             ute_wtssim.Teardown All Aliases For Wts    AND
    ...             frt_common.Reboot DU and Reconnect    AND
    ...             wait until keyword succeeds    15 min    30 sec    Check RU Number And Status Are Correct    AND
    ...             Start egate    AND
    ...             wait cell on air and mib sib ready
    Set Suite Variable    ${DUMP_STATUS}    STOP
    Set Suite Variable    ${SUITE_RUN_STATUS}    STOP

start log collection
    Enable Debug Log For gNB
    Start_Tcpdump_For_Eth3_Eth4
    run keyword if    "${SMOD}" != "ASOE"    Start Collect AP sosReport
    Start Collect Btslog    suite_btslog

Get the RU Number
    [Arguments]    ${iphy_file}=${SUITE_INF.ori_iphy}
    ${ru_num_in_iphy}    get_ru_number_from_iphy    ${iphy_file}
    set suite variable    ${RU_NUM}    ${ru_num_in_iphy}

Teardown For Suite Setup
    get_bbu_adets    ap
    get_bbu_adets    du
    Stop_Tcpdump_For_Eth3_Eth4
    Stop and Collect Btslog     btslog_name=suite_btslog      target_dir=${SUITE_LOG_DIRECTORY}
    Run    cp ${eth3_dump} ${SUITE_LOG_DIRECTORY}/eth3startup_tcpdump.pcap
    Run    cp ${eth4_dump} ${SUITE_LOG_DIRECTORY}/eth4startup_tcpdump.pcap
    Run keyword if  "${SUITE_RUN_STATUS}"=="STOP" and "${SMOD}" != "ASOE"    Stop And Collect AP sosReport    collect_pcap.sh
    Run keyword if  "${SUITE_RUN_STATUS}"!="STOP" and "${SMOD}" != "ASOE"    Stop And Collect AP sosReport    ${APStopSosReportFile}

Stop And Collect AP sosReport
    [Arguments]    ${collect_file}
    Stop Collect AP sosReport    ${collect_file}
    Collect AP sosReport    ${collect_file}

CP Common Suite Teardown
    [Documentation]
    ...    :Author:
    ...
    ...     This is the CP common suite Teardown, It works in processing
    ...
    BuiltIn.log    Start CP Common Suite Teardown
    execute_on_ne    ls -lt --time-style=+'%Y-%m-%d %H:%M:%S' /tmp |grep PM.BTS |grep xml    gnb
    run keyword if   ${DEBUG_MODE}==${False}   Collect Suite Teardown Log
    frt_common.disconnect_all_connections


Collect Suite Teardown Log
    #Run Keyword If   "${SUITE_RUN_STATUS}"!="STOP"    Run keywords    Get WTS sosreport
    #...    AND    Run    cp ${CFG_PATH}/${Sosreport_name} ${SUITE_LOG_DIRECTORY}/
    Run Keyword If   "${SUITE_RUN_STATUS}"!="STOP"    Get AirPhone snapshot    local_path=${SUITE_LOG_DIRECTORY}/
    Run Keyword If   "${SUITE_RUN_STATUS}"!="STOP" and "cloud" not in "${TL_TYPE}"    Run keywords    save_snapshot_from_bts
    ...    AND    Run   cp ${snapshot_name} ${SUITE_LOG_DIRECTORY}/
    Run Keyword If   "${SUITE_RUN_STATUS}"!="STOP" and "cloud" in "${TL_TYPE}"   Run keyword    Save Snapshot in Cloud


Collect Journal Log In CU
    [Arguments]    ${cu_host}    ${cu_username}    ${cu_password}     ${log_path}     @{nodes}
    collect_node_journal_log_in_CU    ${cu_host}    ${cu_username}    ${cu_password}     @{nodes}
    Run    sshpass -p ${cu_password} scp ${cu_username}@${cu_host}:/tmp/*_journal_cu.log ${log_path}


CP Common Test Teardown Cloud
    Collect Journal Log In CU    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}     ${TEST_LOG_DIR}


CP Common Test Setup
    [Documentation]
    ...    :Author:
    ...
    ...     This is the CP common Test Setup, It works in processing
    ...
    BuiltIn.log    Start CP Common Test Setup
    Create Test Log Directory
    Get current active coam alarm list at start
    #run keyword if   ${DEBUG_MODE}==${False}   Start GNB BIP tcpdump
    run keyword if   ${DEBUG_MODE}==${False}   Start Collect AP sosReport
    Start Collect Btslog

CP Common Test Teardown
    [Documentation]
    ...    :Author:
    ...
    ...     This is the CP common Test Teardown, It works in processing
    ...
    BuiltIn.log    Start CP Common Test Teardown
    run keyword and ignore error    Stop Tcpdump with all SMOD
    run keyword and ignore error    Dettach All
    run keyword and ignore error    lock_unlock_cells    Unlocked
    run keyword if   ${DEBUG_MODE}==${False}   Collect Test Teardown Log
    run keyword and ignore error     Stop and Collect Btslog
    get_Loglist    log_dir=${TEST_LOG_DIR}
    frt_common.disconnect_all_connections
    run keyword if   "${REPORT_TO_REP}"=="True"   Report test result to reporting portal    log_dir=${TEST_LOG_DIR}    gnb_id=${0}

Collect Test Teardown Log
    #${bip_pcap}    Stop GNB BIP tcpdump
    #Run     cp ${bip_pcap} ${TEST_LOG_DIR}/gnb_bip_tcpdump.pcap
    run keyword and ignore error      Backup Config File To Test Dir
    Save egate console log
    run keyword if    'cloud' in '${TL_TYPE}'    CP Common Test Teardown Cloud
    Run keyword if  "${TEST_STATUS}"=="PASS" and "${SMOD}" != "ASOE"    Stop And Collect AP sosReport    collect_pcap.sh
    Run keyword if  "${TEST_STATUS}"=="FAIL" and "${SMOD}" != "ASOE"   Stop And Collect AP sosReport    ${APStopSosReportFile}
    Run Keyword If Test Failed    Get AirPhone snapshot    local_path=${TEST_LOG_DIR}/
    Run Keyword If Test Failed    Save Snapshot For gNB

Save Snapshot For gNB
    Run keyword If    'cloud' in '${TL_TYPE}'    Save Snapshot in Cloud
    Run keyword If    'cloud' not in '${TL_TYPE}'
    ...    Run keywords    save_snapshot_from_bts    AND    Run    cp ${snapshot_name} ${TEST_LOG_DIR}/

Start Collect Btslog
    [Arguments]      ${btslog_name}=btslog
    run keyword and ignore error     core.teardown_collectors      names=${btslog_name}
    btslog.create_btslog_collector     name=${btslog_name}
    btslog.set suite Alias              ${btslog_name}
    core.setup_collectors      names=${btslog_name}
    core.start_collectors      names=${btslog_name}

Stop and Collect Btslog
    [Arguments]      ${btslog_name}=btslog    ${target_dir}=${TEST_LOG_DIR}
    core.stop_collectors      names=${btslog_name}
    core.collect_collectors      names=${btslog_name}     target_dir=${target_dir}
    [Teardown]      run keyword and ignore error     core.teardown_collectors      names=${btslog_name}

Update GNB3 to SA
    Run    sed -i 's/#SA#//g' ${SUITE_INF.modify_wts_cfg}

Update GNB3 to NSA
    Run    sed -i 's/#NSA#//g' ${SUITE_INF.modify_wts_cfg}

Update GNB3 in Cfg for a workaround
     run keyword if     '${SUITE_INF.network_mode}' == 'SA'    update GNB3 to SA
     run keyword if     '${SUITE_INF.network_mode}' == 'NSA'    update GNB3 to NSA

update configuration files
    Modify Swconfig
    update iphy xml
    Update GNB3 in Cfg for a workaround
    Modify Airphone Cfg    ${SUITE_INF.ap_cfg_para_lines}    ${SUITE_INF.modify_wts_cfg}
    #wait SCTP link ready
    builtin.sleep    5s
    run keyword if    "${SUITE_INF.product_type}"=="cloud"    update du scf    ELSE    update classcial scf
    update cu scf
    run keyword if    "${SUITE_INF.product_type}"=="cloud"    Modify Startuplogsize CPNRT Cloud    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    Copy cfg and aiphone config file

Start Commission
    run keyword if    "${SUITE_INF.product_type}"=="cloud"   commission_cu    ${SUITE_INF.modify_cu_scf}
    run keyword if    "${SUITE_INF.product_type}"=="cloud"    Commission DU with AP restart    ${SUITE_INF.modify_scf}
    ...    ELSE    Commission Scf with AP restart    ${SUITE_INF.modify_scf}

Get targetBD file By Command
    Run    sshpass -p ${PW} scp ${USER}@${GNBIP}:/ffs/run/TargetBD*.xml ${SUITE_LOG_DIRECTORY}/TargetBD.xml

update iphy xml
    Get targetBD file By Command
#    Setup Enb Fsm Access     host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}    alias="gnb"
#    Get Enb Targetbd File     destination=${SUITE_INF.suite_log_dir}/TargetBD.xml    alias="gnb"
    ${card_name}=    Change Iphy Xml From Targetbd     iphy_src=${SUITE_INF.ori_iphy}    iphy_dst=${SUITE_INF.modify_iphy}
    ...    targetbd=${SUITE_INF.suite_log_dir}/TargetBD.xml
    Set suite variable    ${RMOD_PRODCODEPLAN}    ${card_name.strip()}
    modify_gscn_iphy     ${pci_gscn_list}     iphy_file=${SUITE_INF.modify_iphy}
    Set the iphy file according to hardware    ${SUITE_INF.modify_iphy}
#    Put Iphy Xml Wts Config File     ${SUITE_INF.modify_iphy}
#    ...    iphy_lmp_ip=${tl.ues[0].l1.common_units[0].lmp_connection.addr}
    Run    sshpass -p ${PW} scp ${SUITE_INF.modify_iphy} ${USER}@${AirPhoneIP}:/ffs/run/simmode/iphy.xml

Modify Swconfig
    modify_swconfig_and_crasign    modify_paramsList=${SUITE_INF.modify_ap_flags}    targetBTS=ap
    ...    local_filePath=${SUITE_INF.modify_ap_swconfig}
    modify_swconfig_and_crasign    modify_paramsList=${SUITE_INF.modify_gnb_flags}
    ...    local_filePath=${SUITE_INF.modify_gnb_swconfig}

Enable Debug Log For gNB
    Run keyword If    'cloud' in '${TL_TYPE}'    Enable Debug Log For Cloud gNB
    Run keyword If    'cloud' not in '${TL_TYPE}'    Enable Debug Log

Enable Debug Log For Cloud gNB
    Enable Debug Log In CU OAM
    Enable Debug Log In CU
    Enable Debug Log In DU

Enable Debug Log In CU OAM
    connection_alias.Connect to Cloud OAM
    ${date_stamp}    Run    date +%Y%m%d%H%M%S
    SSH.execute    sudo cp /rpram/swconfig.txt /rpram/swconfig_bak_${date_stamp}.txt    connection=OAM
    SSH.execute    sudo su -c 'echo -e "0x690000\=1\r\n0x6A0000\=1\r\n0x6B0000\=1\r\n" > /rpram/swconfig.txt'    connection=OAM
    [Teardown]    ssh.disconnect     connection=OAM

Enable Debug Log In CU
    connection_alias.Connect to Cloud OAM
    ${vnfc_list}    vnfc_common.get_all_vnfcs_from_gNBCU    OAM
    FOR    ${vnfc}    IN     @{vnfc_list}
         Run Keyword If    '-cp' in '${vnfc}'.lower()    Enable Debug Log In Cplane Instance    host_name=${vnfc}
         Run Keyword If    'cpnrt' in '${vnfc}'.lower()    Enable Debug Log In CPNRT    host_name=${vnfc}
    END
    [Teardown]    ssh.disconnect     connection=OAM

Enable Debug Log In Cplane Instance
    [Arguments]      ${host_name}
    ${command}    set variable    sudo su -c 'echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini'
    ssh.connect to    hostname=${host_name}.local    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}    proxy=OAM    alias=vnfc_connection
    SSH.execute    ${command}    connection=vnfc_connection
    [Teardown]    ssh.disconnect     connection=vnfc_connection

Enable Debug Log In CPNRT
    [Arguments]      ${host_name}
    ${gnb_build}    Get Gnb Branch
    ${is_newer_21A}     gnb_build_cmp     ${gnb_build}
    ${parameter}    set variable if     ${is_newer_21A}    0x66001b    0x41001C
    ${swconfig_path}    set variable    /mnt/ccs/${host_name}/preserve/swconfig.txt
    ${command}    set variable    sudo su -c 'echo -e "${parameter}\=1" >> ${swconfig_path}'
    ssh.connect to    hostname=${host_name}.local    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}    proxy=OAM    alias=CPNRT
    ${result}    SSH.execute    sudo cat /mnt/ccs/${host_name}/preserve/swconfig.txt | grep ${parameter}\=1    connection=CPNRT
    ${len}    Get Length    ${result.strip('\r\n')}
    run keyword if    ${len}==0    SSH.execute    ${command}    connection=CPNRT
    ssh.disconnect     connection=CPNRT

Enable Debug Log In DU
    modify_swconfig_and_crasign    modify_paramsList=${ENABLE_DEBUG_FLAGS_CLOUD_DU}    local_filePath=${SUITE_INF.modify_gnb_swconfig}

Enable Debug Log
    ${gnb_build}    Get Gnb Branch
    ${is_newer_21A}     gnb_build_cmp     ${gnb_build}
    @{flag_list}     create list      0x590072=1    0x340000=15    0x66001b=1
    ${ENABLE_DEBUG_FLAGS}     set variable if     ${is_newer_21A}     ${flag_list}    ${ENABLE_DEBUG_FLAGS}
    modify_swconfig_and_crasign    modify_paramsList=${ENABLE_DEBUG_FLAGS}    local_filePath=${SUITE_INF.modify_gnb_swconfig}
    Connect To Classic Gnb Asik
    csn.send_command    command= rm -rf /rom/cp_runtime.ini*;echo -e "[control]\nLoggingSeverity=trace" >> /rom/cp_runtime.ini
    ...    connection=GNB_ASIK
    sleep    3s
    csn.send_command    command=crasign /rom/cp_runtime.ini    connection=GNB_ASIK


Crasign Swconfig
    [Arguments]      ${host}
    ssh.connect to    hostname=${host}     username=toor4nsn     password=oZPS0POrRieRtu    port=22    alias=gnb
    SSH.execute      crasign /ffs/run/swconfig.txt && craverify /ffs/run/swconfig.txt*     connection=gnb
    ssh.disconnect     connection=gnb

User Config
    [Documentation]    if you nned use this keyword, you should define the variables firstly, such as, in the 'Variables':
    ...    &{USER_CONFIG}     AP_CFG_FILE=/your/full/path/AirPhoneConfig.xml     WTS_CFG_FILE=/your/full/path/basic_inetr_gNB.cfg
    ...                       AP_SWCONFIG_FILE=/your/full/path/swconfig.txt    GNB_SWCONFIG_FILE=/your/full/path/swconfig.txt
    ...                       IPHY_FILE=/your/full/path/iphy.xml
    ...                       SCF_FILE=/your/full/path/scf.xml     # for classic
    ...                       CU_SCF_FILE=/your/full/path/cu_scf.xml    DU_SCF_FILE=/your/full/path/du_scf.xml   # for cloud
    Clear log files under latest folder
    Run Keyword If    '${TL_CONFIG_TYPE}'=='UTE' and "${ENV_TYPE}"=="NSA"    Config WTS Ip On UTE NSA
    Run Keyword If    '${TL_CONFIG_TYPE}'=='UTE' and "${ENV_TYPE}"=="SA"    Config WTS Ip On UTE SA
    Run Keyword If    '${TL_CONFIG_TYPE}'=='UTE' and "${ENV_TYPE}"=="both"    Config WTS Ip On UTE both

    # check AP and GNB swconfig
    ${user_ap_swconfig}     Run keyword and return status      BuiltIn.log      ${USER_CONFIG['AP_SWCONFIG_FILE']}
    run keyword if   ${user_ap_swconfig}    set suite variable     ${cmd_ap_swconfig}
    ...    sshpass -p ${PW} scp ${USER_CONFIG['AP_SWCONFIG_FILE']} ${USER}@${AirPhoneIP}:/ffs/run/swconfig.txt
    run keyword if     ${user_ap_swconfig}    Run     ${cmd_ap_swconfig}
    run keyword if     ${user_ap_swconfig}    Crasign Swconfig    ${AirPhoneIP}

    ${user_gnb_swconfig}     Run keyword and return status      BuiltIn.log      ${USER_CONFIG['GNB_SWCONFIG_FILE']}
    run keyword if   ${user_gnb_swconfig}    set suite variable     ${cmd_gnb_swconfig}
    ...      sshpass -p ${PW} scp ${USER_CONFIG['GNB_SWCONFIG_FILE']} ${USER}@${GNBIP}:/ffs/run/swconfig.txt
    run keyword if     ${user_gnb_swconfig}    Run     ${cmd_gnb_swconfig}
    run keyword if     ${user_gnb_swconfig}    Crasign Swconfig    ${GNBIP}

    # check WTS cfg and AP cfg
    ${user_ap_cfg}     Run keyword and return status      BuiltIn.log      ${USER_CONFIG['AP_CFG_FILE']}
    ${user_ap_cfg_name}     run keyword if    ${user_ap_cfg}    get_file_name_from_user_config      ${USER_CONFIG}     AP_CFG_FILE
    ${user_wts_cfg}     Run keyword and return status      BuiltIn.log      ${USER_CONFIG['WTS_CFG_FILE']}
    ${user_wts_cfg_name}     run keyword if   ${user_wts_cfg}   get_file_name_from_user_config      ${USER_CONFIG}     WTS_CFG_FILE
    run keyword if    ${user_ap_cfg} and ${user_wts_cfg}     Copy File     ${USER_CONFIG['AP_CFG_FILE']}     ${CFG_PATH}/${user_ap_cfg_name}
    run keyword if    ${user_ap_cfg} and ${user_wts_cfg}     Copy File     ${USER_CONFIG['WTS_CFG_FILE']}     ${CFG_PATH}/${user_wts_cfg_name}
    ...    ELSE     Copy cfg and aiphone config file
    run keyword if    ${user_ap_cfg} and ${user_wts_cfg}     modify_airphone_cfg     ${AP_CFG_PARA_LINES}    ${CFG_PATH}/${user_wts_cfg_name}
    run keyword if    ${user_ap_cfg} and ${user_wts_cfg}     set suite variable      ${CFG_FILE}      ${CFG_PATH}/${user_wts_cfg_name}

    # check IPHY
    ${user_iphy}     Run keyword and return status      BuiltIn.log      ${USER_CONFIG['IPHY_FILE']}
    run keyword if    ${user_iphy}    set suite variable      ${cmd_iphy}
    ...    sshpass -p ${PW} scp ${USER_CONFIG['IPHY_FILE']} ${USER}@${AirPhoneIP}:/ffs/run/simmode/iphy.xml
    run keyword if     ${user_iphy}     Run    ${cmd_iphy}     ELSE    Update Iphy

    # check SCF file
    Kill egate process
    Kill Edaemon process
    Run keyword if    'cloud' in '${TL_TYPE}'    User SCF Config Cloud     ELSE    User SCF Config Classic
# ${vlanid_flag}     Run keyword and return status      BuiltIn.log      ${tl.gnbs[0].cu.x2c.vlan_id}
# run keyword if    ${vlanid_flag} and '${tl.gnbs[0].cu.x2c.vlan_id}'!='None'    set suite variable    &{valnid_para_dict}
# ...    dist_name=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1    p_name=vlanId      p_value=${tl.gnbs[0].cu.x2c.vlan_id}
# Run keyword if    ${vlanid_flag} and '${tl.gnbs[0].cu.x2c.vlan_id}'!='None'    Collections.append to list    ${SCF_PARAMS}
# ...    ${valnid_para_dict}
# ${user_scf}     Run keyword and return status      BuiltIn.log      ${USER_CONFIG['SCF_FILE']}
# run keyword if    ${user_scf}    Copy File    ${USER_CONFIG['SCF_FILE']}    ${SUITE_LOG_DIRECTORY}/${SUITE_MODIFED_SCF}
# ${nidd_json_file}     run keyword if     ${user_scf} and ${SCF_PARAMS}     Get nidd File
# Run Keyword If   ${user_scf} and ${SCF_PARAMS}   modify_scf_ece   ${SCF_PARAMS}   ${SUITE_LOG_DIRECTORY}/${SUITE_MODIFED_SCF}   ${nidd_json_file}
# Run Keyword If    ${user_scf}     Commission Scf with AP restart     ${SUITE_LOG_DIRECTORY}    ${SUITE_MODIFED_SCF}
# ...    ELSE     Modify And Commission Scf
    #Run keyword and ignore error    Reboot Airphone OAM without check
    ${flag}    Run Keyword And Return Status
    ...    wait until keyword succeeds    15 min    30 sec    Check RU Number And Status Are Correct
    Run keyword if   not ${flag}    Reboot Airphone and wait for RU correct
    wait until keyword succeeds    1 min    10 sec    Connect to Airphone OAM
    Config Sctp
    Start and configure epcsim    ${CFG_FILE}
    Run keyword if    "${ENV_TYPE}"=="NSA"    Establish X2 link
    Run keyword if    "${ENV_TYPE}"=="SA"    wait until keyword succeeds     10 min    20 sec    Check NG link is up
    Run keyword if    "${ENV_TYPE}"=="both"    Establish X2 link and wait XN link up

Establish X2 link and wait XN link up
    #Establish X2 link
    wait until keyword succeeds     10 min    20 sec    Check NG link is up
    Establish X2 link

User SCF Config Cloud
    ${user_CU_scf}     Run keyword and return status      BuiltIn.log      ${USER_CONFIG['CU_SCF_FILE']}
    ${user_DU_scf}     Run keyword and return status      BuiltIn.log      ${USER_CONFIG['DU_SCF_FILE']}
    run keyword if    ${user_CU_scf}    Copy File    ${USER_CONFIG['CU_SCF_FILE']}    ${SUITE_LOG_DIRECTORY}/${CU_MODIFIED_SCF}
    run keyword if    ${user_DU_scf}    Copy File    ${USER_CONFIG['DU_SCF_FILE']}    ${SUITE_LOG_DIRECTORY}/${DU_MODIFIED_SCF}
    Run Keyword If    ${SCF_PARAMS_CU}     modify_scf_ece    ${SCF_PARAMS_CU}    ${SUITE_LOG_DIRECTORY}/${CU_MODIFIED_SCF}    node_type=cu
    Run Keyword If    ${SCF_PARAMS}     modify_scf_ece    ${SCF_PARAMS}    ${SUITE_LOG_DIRECTORY}/${DU_MODIFIED_SCF}    node_type=du
    commission_cu    ${SUITE_LOG_DIRECTORY}/${CU_MODIFIED_SCF}
    Commission DU with AP restart    ${SUITE_LOG_DIRECTORY}    ${DU_MODIFIED_SCF}

User SCF Config Classic
    ${vlanid_flag}     Run keyword and return status      BuiltIn.log      ${tl.gnbs[0].cu.x2c.vlan_id}
    run keyword if    ${vlanid_flag} and '${tl.gnbs[0].cu.x2c.vlan_id}'!='None'    set suite variable    &{valnid_para_dict}
    ...    dist_name=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1    p_name=vlanId      p_value=${tl.gnbs[0].cu.x2c.vlan_id}
    Run keyword if    ${vlanid_flag} and '${tl.gnbs[0].cu.x2c.vlan_id}'!='None'    Collections.append to list    ${SCF_PARAMS}
    ...    ${valnid_para_dict}
    ${user_scf}     Run keyword and return status      BuiltIn.log      ${USER_CONFIG['SCF_FILE']}
    run keyword if    ${user_scf}    Copy File    ${USER_CONFIG['SCF_FILE']}    ${SUITE_LOG_DIRECTORY}/${SUITE_MODIFED_SCF}
    ${nidd_json_file}     run keyword if     ${user_scf} and ${SCF_PARAMS}     Get nidd File
    Run Keyword If   ${user_scf} and ${SCF_PARAMS}   modify_scf_ece   ${SCF_PARAMS}   ${SUITE_LOG_DIRECTORY}/${SUITE_MODIFED_SCF}   ${nidd_json_file}
    Run Keyword If    ${user_scf}     Commission Scf with AP restart     ${SUITE_LOG_DIRECTORY}    ${SUITE_MODIFED_SCF}
    ...    ELSE     Modify And Commission Scf

Golden And Default Config
    Run Keyword If    "default" in "${TL_TYPE}"    Default Config    ELSE    Config Gnb And Airphone

Default Config
    Run Keyword If    '${TL_TYPE}'=='default'    BuiltIn.Log    !!! Do nothing on configuration,only check UTE cell status.
    Run Keyword If    '${TL_TYPE}'!='default'    Only Config Wts

Config Gnb And Airphone
    Clear log files under latest folder
    #Run Keyword If    '${TL_CONFIG_TYPE}'=='UTE' and "${ENV_TYPE}"=="NSA"    Config WTS Ip On UTE NSA
    #Run Keyword If    '${TL_CONFIG_TYPE}'=='UTE' and "${ENV_TYPE}"=="SA"    Config WTS Ip On UTE SA
    #Run Keyword If    '${TL_CONFIG_TYPE}'=='UTE' and "${ENV_TYPE}"=="both"    Config WTS Ip On UTE both
	Config WTS Ip On UTE both
    Kill egate before commission
    update configuration files
    Start Commission
    Make sure RU online

Kill egate before commission
    Config Sctp
    run keyword and ignore error     Run    sudo pkill -9 sim_enb
    Kill egate process
    Kill Edaemon process

Make sure RU online
    [Documentation]    Reboot of Gnb is added because in P1 runs we are seeing RU is failing to come up online.
    ...                PR information -PR537457:[Airphone_QT][INTERMITANT][UTE] Failure in RuStateError observed
    ...                due to node sync issue where node is not ready. Reboot of Gnb will be reverted when the
    ...                issue is fixed. If RU online after manual reboot AP, if would cause the later MIB/SIB missig,
    ...                reboot gNB to make AP auto restart then this issue will not happen
    ${radio_state_reset_required_flag}    Run Keyword And Return Status
    ...    wait until keyword succeeds    15 min    30 sec    Check RU Number And Status Are Correct
    Run keyword if   not ${radio_state_reset_required_flag}    Reboot GNB and Airphone and wait for RU correct
    Run keyword if   ${radio_state_reset_required_flag} and not ${IS_AP_AUTO_RESTART}    Reboot GNB and wait for RU correct
    wait until keyword succeeds    1 min    10 sec    Connect to Airphone OAM

Start egate
    Start and configure epcsim    ${CFG_FILE}

wait cell on air and mib sib ready
    @{sansa_tl_type}    create list     fs_tdd_nsa_cmwv    l1bypass_tdd_both_cmwv    l1bypass_tdd_sa_cmwv
    @{tl_type_list}    split string     ${TL_TYPE}     -
    ${sansa_con}    set variable if    '@{tl_type_list}[1]' in ${sansa_tl_type} and '@{tl_type_list}[2]' < '4cell' and 'cloud' not in '${TL_TYPE}'
    ...    ${True}    ${False}
    Run keyword if    'cloud' in '${TL_TYPE}' and ${sansa_con} != ${True}    waite_until_all_f1_link_avaiable
    Run keyword if    "${ENV_TYPE}"=="NSA" and ${sansa_con} != ${True}    Establish X2 link
    Run keyword if    "${ENV_TYPE}"=="SA" and ${sansa_con} != ${True}    wait until keyword succeeds
    ...    10 min    20 sec    Check NG link is up
    Run keyword if    "${ENV_TYPE}"=="both" and ${sansa_con} != ${True}    Establish X2 link and wait XN link up
    Run keyword if     ${sansa_con}     Establish X2 link and wait XN link up
    wait until keyword succeeds    3 min    10 sec        cells should be on air
    Check Airphone Should Be Onair

Download Default Wts Cfg File
    Kill egate process
    Kill Edaemon process
    Run    cd ${CFG_PATH};sudo ./edaemon --port 22222; sleep 5; ./egate --port 20000;
    ${wts_cfg_name}    ${wts_ap_xml_name}    get_wts_default_cfg_files    ${TL_TYPE}
    execute_egate_command_without_kargs    cp airphone_cfg/${wts_cfg_name} .
    execute_egate_command_without_kargs    cp airphone_cfg/${wts_ap_xml_name} .
    Set Suite Variable    ${CFG_FILE}    ${wts_cfg_name}

Only Config Wts
    Clear log files under latest folder
    ${wts_cfg_name}    ${wts_ap_xml_name}    get_wts_default_cfg_files    ${TL_TYPE}
    Download Default Wts Cfg File
    Run Keyword If    '${TL_CONFIG_TYPE}'=='UTE' and "${ENV_TYPE}"=="NSA"    Config WTS Ip On UTE NSA
    Run Keyword If    '${TL_CONFIG_TYPE}'=='UTE' and "${ENV_TYPE}"=="SA"    Config WTS Ip On UTE SA
    Run Keyword If    '${TL_CONFIG_TYPE}'=='UTE' and "${ENV_TYPE}"=="both"    Config WTS Ip On UTE both
    ${flag}    Run Keyword And Return Status
    ...    wait until keyword succeeds    5 min    30 sec    Check All RU Status Are Online
    Run keyword if   not ${flag}    Reboot GNB and Airphone and wait for RU correct
    wait until keyword succeeds    1 min    10 sec    Connect to Airphone OAM

Check NG link is up
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${egate_content}    Run    cat ${CFG_PATH}/egate_console.log
    Should contain     ${egate_content}    NG link is Up
    Should contain     ${egate_content}    NR updated

Check Airphone Should Be Onair
    Connect to Airphone DU
    ${on_air_status_ap}    csn.execute    grep -i "cell setup completed" /tmp/APL3.log    connection=DU_AIRPHONE
    Should Not Be Empty    ${on_air_status_ap}

Get nidd File
    Run    sshpass -p ${PW} scp ${USER}@${GNBIP}:/ffs/run/swpool/OAM/nidd*.json ${SUITE_LOG_DIRECTORY}/nidd.json
    ${nidd_json_file}    set variable     ${SUITE_LOG_DIRECTORY}/nidd.json
    [Return]     ${nidd_json_file}

update classcial scf
    ${nidd_json_file}     Get nidd File
    ${flag}     Run keyword and return status      BuiltIn.log      ${tl.gnbs[0].cu.x2c.vlan_id}
    run keyword if    ${flag} and '${tl.gnbs[0].cu.x2c.vlan_id}'!='None'   set suite variable    &{para_dict}
    ...    dist_name=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1    p_name=vlanId      p_value=${tl.gnbs[0].cu.x2c.vlan_id}
    ${vlanid_list}    BuiltIn.create list
    Set Suite Variable      ${vlanid_list}
    run keyword if    ${flag} and '${tl.gnbs[0].cu.x2c.vlan_id}'!='None'    append to list
    ...    ${vlanid_list}      ${para_dict}
    Set the SCF file according to hardware
    ${paras_add}    BuiltIn.get length     ${vlanid_list}
    Run keyword if   ${paras_add}!=0     modify_scf_ece
    ...    ${vlanid_list}     ${SUITE_INF.modify_scf}    ${nidd_json_file}
    Run Keyword If    ${SCF_PARAMS}     modify_scf_ece     ${SCF_PARAMS}     ${SUITE_INF.modify_scf}    ${nidd_json_file}
    Run Keyword If    "${SCENARIO}"!="${EMPTY}"    modify_scf_ece     ${SUITE_INF.scf_params}     ${SUITE_INF.modify_scf}    ${nidd_json_file}

update du scf
    ${nidd_json_file}     Get nidd File
    ${flag}     Run keyword and return status      BuiltIn.log      ${tl.gnbs[0].cu.f1u.vlan_id}
    run keyword if    ${flag} and '${tl.gnbs[0].cu.f1u.vlan_id}'!='None'   set suite variable    &{para_dict}
    ...    dist_name=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1    p_name=vlanId      p_value=${tl.gnbs[0].cu.f1u.vlan_id}
    ${vlanid_list}    BuiltIn.create list
    Set Suite Variable      ${vlanid_list}
    run keyword if    ${flag} and '${tl.gnbs[0].cu.f1u.vlan_id}'!='None'    append to list
    ...    ${vlanid_list}      ${para_dict}
    Set the SCF file according to hardware
    ${paras_add}    BuiltIn.get length     ${vlanid_list}
    Run keyword if   ${paras_add}!=0     modify_scf_ece
    ...    ${vlanid_list}     ${SUITE_INF.modify_scf}    ${nidd_json_file}
    Run Keyword If    ${SCF_PARAMS}     modify_scf_ece     ${SCF_PARAMS}     ${SUITE_INF.modify_scf}    ${nidd_json_file}
    Run Keyword If    "${SCENARIO}"!="${EMPTY}"    modify_scf_ece     ${SUITE_INF.scf_params}     ${SUITE_INF.modify_scf}    ${nidd_json_file}

update cu scf
    Run Keyword If    ${SCF_PARAMS_CU}     modify_scf_ece    ${SCF_PARAMS_CU}    ${SUITE_INF.modify_cu_scf}

modify and commission cloud gNB
    Copy File    ${CONFIG_PATH}/Gnb/${CU_SCF_NAME}    ${SUITE_LOG_DIRECTORY}/${CU_MODIFIED_SCF}
    Copy File    ${CONFIG_PATH}/Gnb/${DU_SCF_NAME}    ${SUITE_LOG_DIRECTORY}/${DU_MODIFIED_SCF}
    Run Keyword If    ${SCF_PARAMS_CU}     modify_scf_ece    ${SCF_PARAMS_CU}    ${SUITE_LOG_DIRECTORY}/${CU_MODIFIED_SCF}    node_type=cu
    Run Keyword If    ${SCF_PARAMS}     modify_scf_ece    ${SCF_PARAMS}    ${SUITE_LOG_DIRECTORY}/${DU_MODIFIED_SCF}    node_type=du
    commission_cu    ${SUITE_LOG_DIRECTORY}/${CU_MODIFIED_SCF}
    Commission DU with AP restart    ${SUITE_LOG_DIRECTORY}    ${DU_MODIFIED_SCF}

Dettach All
    ${active_ue}    get_active_ue    env_type=${ENV_TYPE}
    #@{flag}    evaluate    set(${flag.split()})
    FOR     ${i}     IN     @{active_ue}
          Run keyword and ignore error     Run keyword if    "${ENV_TYPE}"=="NSA"
         ...    nsa_dettach_ue    ue=${i.strip()}
          Run keyword and ignore error     Run keyword if    "${ENV_TYPE}"=="SA"
         ...    execute_egate_command_without_kargs    ue_deregister id=${i.strip()} ue_deregister_type=switch_off    pass_regexp=detached
          Run keyword and ignore error     Run keyword if    "${ENV_TYPE}"=="both"
         ...    nsa_dettach_ue    ue=${i.strip()}
          Run keyword and ignore error     Run keyword if    "${ENV_TYPE}"=="both"
         ...    execute_egate_command_without_kargs    ue_deregister id=${i.strip()} ue_deregister_type=switch_off    pass_regexp=detached

    END
Config Sctp
    Config Sctp On Wts
    Connect to Airphone OAM
    Configure sctp on airphone

Configure sctp on airphone
    SSH.execute     sysctl -w net.sctp.rto_min\=200;      connection=OAM_AIRPHONE
    SSH.execute     sysctl -w net.sctp.rto_initial\=200;      connection=OAM_AIRPHONE
    SSH.execute     sysctl -w net.sctp.rto_max\=500;      connection=OAM_AIRPHONE
    SSH.execute     sysctl -w net.sctp.sack_timeout\=20      connection=OAM_AIRPHONE

Copy cfg and aiphone config file
    Run     cp ${SUITE_INF.modify_wts_cfg} ${CFG_PATH}/${CFG_FILE}
    Run     cp ${SUITE_INF.modify_wts_xml} ${CFG_PATH}

Reboot GNB and Airphone and wait for RU correct
    frt_common.Reboot DU and Reconnect
   # Run keyword and ignore error    Reboot Airphone OAM without check
    wait until keyword succeeds    15 min    30 sec    Check RU Number And Status Are Correct

Reboot GNB and wait for RU correct
    frt_common.Reboot DU and Reconnect
    ${AP restart}    Waite Until Restarted    ${AirPhoneIP}    120
    should be true    ${AP restart}    Airphone does not restart after gNB restart
    wait until keyword succeeds    15 min    30 sec    Check RU Number And Status Are Correct

Reboot Airphone and wait for RU correct
    Reboot Airphone OAM without check
    wait until keyword succeeds    15 min    30 sec    Check RU Number And Status Are Correct

Reboot Airphone
    Run keyword and ignore error    Reboot Airphone OAM without check

Save egate console log
    execute_egate_command_without_kargs    sim_log_set flush
    #ute_wtssim.Execute Egate Command    sim_log_set flush
    Run    cp ${CFG_PATH}/egate_console.log* ${TEST_LOG_DIR}/

Create Suite Log Directory
    ${timestamp}    Get Timestamp
    ${FILE_NAME} =    Replace String Using Regexp    ${SUITE_NAME[:50]}    \\s+$   ${EMPTY}
    ${SUITE_LOG_DIRECTORY} =    Catenate    SEPARATOR=${/}    ${OUTPUT_DIR}    collect_logs    ${FILE_NAME}_${timestamp}
    ${SUITE_LOG_DIRECTORY}    Replace String    ${SUITE_LOG_DIRECTORY}/    ${SPACE}    _
    Create Directory    ${SUITE_LOG_DIRECTORY}
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}

Create Test Log Directory
    ${TEST_LOG_DIR}    Catenate    SEPARATOR=${/}    ${SUITE_LOG_DIRECTORY}    ${TEST_NAME[:50]}
    ${TEST_LOG_DIR}    Remove String    ${TEST_LOG_DIR}    [
    ${TEST_LOG_DIR}    Remove String    ${TEST_LOG_DIR}    ]
    ${TEST_LOG_DIR}    Remove String    ${TEST_LOG_DIR}    .
    ${TEST_LOG_DIR}    Replace String    ${TEST_LOG_DIR}    ${SPACE}    _
    Create Directory    ${TEST_LOG_DIR}
    Set Suite Variable    ${TEST_LOG_DIR}

Modify sosReport Cfg
    ${l1_mode}    Set Variable If    "${SUITE_INF.l1_mode}"=="L1B"    l1bypass    fullstack
    Run    sed -i 's/LONER_VERSION=.*$/LONER_VERSION=E/g' /opt/iphy/latest/sosReport.cfg
    Run    sed -i 's/PHONER_VERSION=.*$/PHONER_VERSION=PH7/g' /opt/iphy/latest/sosReport.cfg
    Run    sed -i 's/L1_MODE=.*$/L1_MODE=${l1_mode}/g' /opt/iphy/latest/sosReport.cfg

Prepare Pcap Collect Script
    Run    cd /opt/iphy/latest/;rm -rf collect_pcap.sh;cp ${APStopSosReportFile} collect_pcap.sh
    Run    sed -i '/sosReport.sh/d' /opt/iphy/latest/collect_pcap.sh

Start Collect AP sosReport
    Modify sosReport Cfg
    Prepare Pcap Collect Script
    Run    cd /opt/iphy/latest/;rm -rf SosReport*.tgz startSos.log stopSos.log
    kill_linux_process    AP_Classical
    kill_linux_process    sosReport
    check_abil_loner_started     ${AirPhoneIP}
    run keyword if    '${SMOD}' != 'ASOE'    check_abil_loner_started     ${GNBIP}
    Clear sosReport On Gnb And Ap
    Run    cd /opt/iphy/latest/;./${APStartSosReportFile} > startSos.log 2>&1 &

Clear sosReport On Gnb And Ap
    ${l1_mode}    Set Variable If    "l1bypass" in "${TL_TYPE}"    l1bypass    fullstack
    run keyword if    '${SMOD}' != 'ASOE'    clear_sosReport_pcap_files_uder_userDir    l1_mode=${l1_mode}

Stop Collect AP sosReport
    [Arguments]    ${stop_file}
    wait until keyword succeeds    3 min    10 sec    Check AP sosReport Pid End    startTestwithSosReport
    Run    cd /opt/iphy/latest/;./${stop_file} > stopSos.log 2>&1 &
    builtin.sleep    2s

Check AP sosReport Pid End
    [Arguments]    ${pid_name}
    [Timeout]    10min
    ${sos_pid}    Run    ps -ef | grep ${pid_name} |grep -v grep | awk '{print $2}'
    Should Be Empty    ${sos_pid}

Collect AP sosReport
    [Arguments]    ${pid_name}
    wait until keyword succeeds    30 min    10 sec    Check AP sosReport Pid End    ${pid_name}
    Run    cat /opt/iphy/latest/stopSos.log
    Run Keyword If    "collect_pcap" in "${pid_name}"    Only Collect Pcap Files
    Run Keyword If    "AP_Classical" in "${pid_name}"    Run    cd /opt/iphy/latest/;ls -al *.tgz;cp SosReport*.tgz ${SUITE_LOG_DIRECTORY}/

Only Collect Pcap Files
    ${down_pcap}    download_files_from_asik    local_dir=${SUITE_LOG_DIRECTORY}    file_list=${pcapFileList}    zipped=True

Start_Tcpdump_For_Eth3_Eth4
    interface.start_tcpdump    testPC    interface=eth3    collector=ute_testpc_eth3_tcpdump
    interface.start_tcpdump    testPC    interface=eth4    collector=ute_testpc_eth4_tcpdump

Stop_Tcpdump_For_Eth3_Eth4
    ${eth3_dump}    interface.stop_tcpdump    testPC    interface=eth3    target_dir=/tmp/    collector=ute_testpc_eth3_tcpdump
    set suite variable     ${eth3_dump}
    ${eth4_dump}    interface.stop_tcpdump    testPC    interface=eth4    target_dir=/tmp/    collector=ute_testpc_eth4_tcpdump
    set suite variable     ${eth4_dump}

Login Webui
    [Arguments]    ${host}=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    ${user}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}   ${type}=coam
    [Documentation]
    ...    :Author:  yonggang.miao@nsn-sbell.com
    ...
    ...     Login on web by selenium
    ...
    ...     :param host: default=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...     :param user: default=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...     :param password: default=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...     :param type: default=coam
    ...
    ...     **Example:**
    ...
    ...     | Login Webui
    ...
    Run keyword if    "${type}"=="coam"    coam login     host=${host}
    ...    user=${user}
    ...    password=${password}
    ...     ELSE   megazone login    host=${host}
    ...    user=${user}
    ...    password=${password}

Logout Webui
    [Arguments]   ${type}=coam
    [Documentation]
    ...    :Author:  yonggang.miao@nsn-sbell.com
    ...
    ...     Logout web by selenium
    ...
    ...     **Example:**
    ...
    ...     | Logout Webui
    ...
    Run keyword if    "${type}"=="coam"      selenium_coam.logout
    ...     ELSE    selenium_megazone.logout


check cells should be on air
    [Arguments]   ${type}=coam
    [Documentation]
    ...    :Author:  yonggang.miao@nsn-sbell.com
    ...
    ...     check cells should be on air
    ...
    ...     **Example:**
    ...
    ...     | check cells should be on air
    ...
    Run keyword if    "${type}"=="coam"      check coam cells should be on air
    ...     ELSE    check megazone cells on air

cells should be on air
    run keyword if    'cloud' in '${TL_TYPE}'    check DU cells should be on air
    ...    ELSE    check coam cells should be on air     ignore_pci=${ignore_pci}


Get active alarm list at start
    [Arguments]   ${type}=coam
    [Documentation]
    ...    :Author:  yonggang.miao@nsn-sbell.com
    ...
    ...     Get active alarm list at start
    ...
    ...     **Example:**
    ...
    ...     | Get active alarm list at start
    ...
    Run keyword if    "${type}"=="coam"      Get active coam alarm list at start
    ...     ELSE    Get active megazone alarm list at start


Get active alarm list at end
    [Arguments]  ${type}=coam    ${gnb_id}=0    ${alias}=cOAM
    [Documentation]
    ...    :Author:  yonggang.miao@nsn-sbell.com
    ...
    ...     Get active alarm list at end
    ...
    ...     **Example:**
    ...
    ...     | Get active alarm list at end
    ...
    Run keyword if    "${type}"=="coam"
    ...    Get active coam alarm list at end    gnb_id=${gnb_id}    alias=${alias}
    ...     ELSE    Get active megazone alarm list at end


There should be no unexpected alarm
    [Documentation]    This keyword is to compare two alarm list.
    ...    ${ACTIVE_ALARM_start} ${ACTIVE_ALARM_end} are suite variable
    ...
    ...    :Author:  yonggang.miao@nsn-sbell.com
    ...
    ...     **Example:**
    ...
    ...    | There should be no unexpected alarm
    ...
    Lists Should Be Equal    ${ACTIVE_ALARM_start}    ${ACTIVE_ALARM_end}


Modify Swconfig with parameter list
    [Documentation]
    ...     Modify swconfig file with given paramter, if no such parameter, it will added in the end.
    ...     it supported in cloud and classical.
    ...
    ...     :param parameters: the modified paramter , such as 0XA1003=2
    ...     :param swfile: swconfig file path
    ...
    ...    :Author:  yonggang.miao@nsn-sbell.com
    ...
    ...     **Example:**
    ...
    ...     | Modify Swconfig with parameter list   0XA1003=3    0XA1004=1
    ...
    [Arguments]    ${parameters}    ${swfile}
    FOR    ${i}    IN     @{parameters}
         ${temp}    Split String    ${i}    =
         Modify Swconfig with parameter    ${temp[0]}    ${temp[1]}      ${swfile}

    END
Modify Swconfig with parameter
    [Documentation]
    ...     Modify swconfig file with given paramter, if no such parameter, it will added in the end.
    ...     it supported in cloud and classical.
    ...
    ...     :param parameter: the modified paramter , such as 0XA1003
    ...     :param value: the modified value
    ...     :param swfile: swconfig file path
    ...
    ...    :Author:  yonggang.miao@nsn-sbell.com
    ...
    ...     **Example:**
    ...
    ...     | Modify Swconfig with parameter    0XA1003    1    /swconfig.txt
    ...
    [Arguments]    ${parameter}    ${value}    ${swfile}
    Run   sed -i "/^${parameter}/d" ${swfile}
    Run   echo ${parameter}\=${value} >> ${swfile}


Check PM counter with given list
    [Arguments]     ${counterlist}    ${pm_name}    ${connection}    ${type}=coam
    [Documentation]
    ...     Modify swconfig file with given paramter, if no such parameter, it will added in the end.
    ...     it supported in cloud and classical.
    ...
    ...     :param counterlist: the counterlist which need to be checked
    ...     :param pm_name: pm name
    ...     :param connection: connection alias name.
    ...     :param type: coam or megazone type.
    ...
    ...    :Author:  yonggang.miao@nsn-sbell.com
    ...
    ...     **Example:**
    ...
    ...     | Check megazone PM counter with given list    ${counterlist}
    ...     MRBTS-1900_PM_20191123_063100_SRAN.xml    OAM
    ...
    Run keyword if    "${type}"=="coam"      Check coam PM counter with given list
    ...    counterlist=${counterlist}    pm_name=${pm_name}    connection=${connection}
    ...     ELSE    Check megazone PM counter with given list
    ...    counterlist=${counterlist}    pm_name=${pm_name}    connection=${connection}

perform delta commissioning
    [Arguments]     ${delta_scf_path}=${None}    ${delta_operation}=update    ${timeout}=60    ${alias}=cOAM
    ...    ${oam_ip}=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    ${oam_reboot_time}=360    ${type}=coam
    [Documentation]
    ...     perform delta commissioning with given paramter.
    ...     it supported in coam and megazone.
    ...
    ...     :param delta_scf_path: scf file
    ...     :param delta_operation: commission operation
    ...     :param timeout: timeout.
    ...     :param alias: connection alias name.
    ...     :param oam_ip: ip.
    ...     :param oam_reboot_time: the time for reboot.
    ...     :param type: coam or megazone type.
    ...
    ...    :Author:  yonggang.miao@nsn-sbell.com
    ...
    ...     **Example:**
    ...
    ...     | perform delta commissioning    scf_xml=MRBTS-1900_PM_20191123_063100_SRAN.xml    type=megazone
    ...
    Run keyword if    "${type}"=="coam"      Perform Delta SCF xml recommission
    ...    ${delta_scf_path}=${None}      ${delta_operation}=update    ${timeout}=60      ${alias}=cOAM
    ...     ELSE    commissioning.Commission
    ...    ${oam_ip}=${oam_ip}   ${scf_xml}=${delta_scf_path}   ${oam_reboot_time}=${oam_reboot_time}

save_snapshot_from_bts
    [Arguments]  ${type}=coam    ${default_gnb_id}=0
    [Documentation]
    ...     this keyword is to save snapshot from webUI.
    ...     it supported in coam and megazone.
    ...
    ...     :param type: coam or megazone type, default is coam.
    ...
    ...    :Author:  yonggang.miao@nsn-sbell.com
    ...
    ...     **Example:**
    ...
    ...     | save_snapshot_from_bts    alias=Coam    type=coam
    ...
    ${date_stamp}    Run    date +%Y%m%d%H%M%S
    Set suite variable    ${snapshot_name}    /tmp/snapshot_file/${date_stamp}_Snapshot.zip
    Run    mkdir -p /tmp/snapshot_file
    Run keyword if    "${type}"=="coam"    save snapshot by coam client    ${default_gnb_id}
    ...    ELSE    Save Snapshot by megazone client


Save Snapshot in Cloud
    Save Snapshot by Cloud CU
    ${date_stamp}    Run    date +%Y%m%d%H%M%S
    ${snapshot_name}     set variable    ${TEST_LOG_DIR}${date_stamp}_du_Snapshot.zip
    run keyword and ignore error      Teardown cOAM session     alias=du_cOAM
    coam.Connect To   bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}    bts_port=443    name=du_cOAM
    coamadmin.get_snapshot    target_file_name=${snapshot_name}    coverage=Full    force=True    timeout=1800     connection=du_cOAM
    run keyword and ignore error      Teardown cOAM session    alias=du_cOAM


Save Snapshot by Cloud CU
    [Arguments]        ${gnb_id}=0    ${time_out}=1200
#    cu.connect_to    host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}     port=443
    run keyword and ignore error     cu.disconnect
    cu.connect_to    host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}     port=443
    ...    username=Nemuadmin    password=nemuuser    cu_version=cuoam_19b    secure=${True}     login_disabled=${False}
    cu.get_local_snapshot     ${TEST_LOG_DIR}      request_timeout=600      operation_timeout=${time_out}
    run keyword and ignore error     cu.disconnect

Save Snapshot by megazone client
    [Timeout]       15 minute
    [Documentation]
    ...     this keyword is to save snapshot from webUI.
    ...     it supported in megazone.
    ...
    ...    :Author:  yonggang.miao@nsn-sbell.com
    ...
    ...     **Example:**
    ...
    ...     | Save Snapshot by megazone client
    ...
    Connect to OAM via Https
    megazone_client.make_snapshot       save_location=SBTS    timeout=900    rap=['RAP 1']
    megazone_client.Save Snapshot From Bts     ${snapshot_name}
    [Teardown]    Run keyword and ignore error    megazone_client.teardown_session

save snapshot by coam client
    [Timeout]       30 minute
    [Arguments]  ${gnb_id_default}=0
    [Documentation]
    ...     this keyword is to save snapshot from webUI.
    ...     it supported in coam.
    ...
    ...    :Author:  yonggang.miao@nsn-sbell.com
    ...
    ...     **Example:**
    ...
    ...     | save snapshot by coam client
    ...
    Log    ${gnb_id_default}
    Create cOAM session with alias    port=443      alias=cOAM
    coamadmin.get_snapshot
    ...    target_file_name=${snapshot_name}    coverage=Full    force=True    timeout=1800    connection=cOAM
    [Teardown]    Teardown cOAM session

Get AirPhone snapshot
    [Documentation]    :Author: yonmiao
    ...     get the snapshot of airphone
    ...
    ...     :param interval: the sleep duration, e.g: sleep    10s
    ...     :param snapshot_name: (default=snapshot_ap.zip) The name of ap snapshot
    ...
    ...     **Example:**
    ...
    ...     | Get AirPhone snapshot
    ...
    [Arguments]    ${interval}=120    ${snapshot_name}=snapshot_ap.zip    ${local_path}=/tmp
    [timeout]    150s
    Connect to AirPhone OAM
    ${result}    SSH.execute    rm /ram/${snapshot_name}    connection=OAM_AIRPHONE
    ${command}    Catenate    (sleep 1 ; echo "log -a -z ${snapshot_name}" ;
    ...      sleep ${interval}; echo "quit") | telnet 0 15007
    ${result}    SSH.execute    ${command}    connection=OAM_AIRPHONE
    Should contain    ${result}    AaSysComUserDeregister succeed
    ${result}    SSH.execute    ls -lrth /ram/ | grep ${snapshot_name}    connection=OAM_AIRPHONE
    Should contain    ${result}    ${snapshot_name}
    SSH.download_file   remote_path=/ram/${snapshot_name}
    ...    local_path=${local_path}/${snapshot_name}    connection=OAM_AIRPHONE
    [Teardown]    Run keyword    ssh.Disconnect    connection=OAM_AIRPHONE

Clear log files under latest folder
    Run    sudo rm ${CFG_PATH}/*.log.*
    Run    sudo rm ${CFG_PATH}/*.tgz

Get WTS sosreport
    [Documentation]    :Author: yonmiao
    ...     get the Sos report of WTS, return the report name
    ...
    ...     **Example:**
    ...
    ...     | ${resport_name}    Get WTS sosreport
    ...
    [timeout]    600s
    Run    rm ${CFG_PATH}/*.tgz
    Run    cd ${CFG_PATH}; ./sosReport.sh -nr
    ${Sosreport_name}    Run    ls -lrt ${CFG_PATH}/ | grep tgz$ | awk \'{print $9}\'
    Should not be empty    ${Sosreport_name.strip()}
    Set suite variable     ${Sosreport_name}    ${Sosreport_name.strip()}
    [Teardown]    Run   pkill -9 "sosReport.sh -nr"

Check RU Number And Status Are Correct
    Check RU Number Are Correct
    Check All RU Status Are Online

Check RU Number Are Correct
    run keyword if    'cloud' in '${TL_TYPE}'    Create cOAM session to DU    ELSE
    ...    Create cOAM session with alias    port=443      alias=cOAM
    ${ru_list}    get_list_of_all_rus
    ${ru_num_web}    Get Length    ${ru_list}
    Get the RU Number    ${SUITE_INF.modify_iphy}
    Should Be Equal    ${ru_num_web}    ${RU_NUM}
    [Teardown]    Teardown cOAM session

Get the config file path
    Should not be empty    ${TL_TYPE}
    ${filepath}=    Replace String    string=${TL_TYPE}    search_for=-    replace_with=/
    ${branch}    Get Gnb Branch
    BuiltIn.Log        ${CURDIR}/../config/${branch}/${filepath}
    set suite variable    ${CONFIG_PATH}    ${CURDIR}/../config/${branch}/${filepath}
    ${check}    Run    if test -d ${CONFIG_PATH} ; then echo "true" ; else echo "false" ;fi
    Run Keyword If    "default" not in "${TL_TYPE}"    Should be true    "${check}"=="true"    Config file not exist!
    #${flag}    Run Keyword And Return Status     Should contain    ${TL_TYPE}    _sa_
    Run Keyword If    "_sa_" in "${TL_TYPE}"    Set suite variable    ${ENV_TYPE}    SA
    ...    ELSE IF    "_nsa_" in "${TL_TYPE}"    Set suite variable    ${ENV_TYPE}    NSA
    ...    ELSE IF    "_both_" in "${TL_TYPE}"    Set suite variable    ${ENV_TYPE}    both
    ...    ELSE    Fail    ENV_TYPE not support.

Get Gnb Branch
    run keyword if    'cloud' in '${TL_TYPE}'    Connect to DU for cloud    alias=ASIK
    ...    ELSE    frt_common.Connect To ASIK    alias=ASIK
    ${targetBD_file}    csn.execute    ls /ffs/run/TargetBD_*.xml    connection=ASIK
    BuiltIn.log    ${targetBD_file.split('_')[1]}
    [Return]    ${targetBD_file.split('_')[1]}

Get domain id with alias
    [Documentation]
    ...    :Author:
    ...
    ...    **Examples:**
    ...
    ...    | Get domain id with alias    BB1
    ...
    [Arguments]     ${alias}
    ${systemifo}    Create Dictionary
    #Connect to BB1 master
    ${result}    csn.Execute    ddal -s ddal_sysinfo_module_get_domain_id 0    connection=${alias}
    @{result}    Split String    ${result.strip()}    \r\n
    FOR    ${i}    IN    @{result}
         @{temp}    Split String    ${i}    \=
         set to dictionary    ${systemifo}    ${temp[0]}    ${temp[1]}
    END
    Set Suite variable    ${DMID}    ${systemifo["dmid"]}

Modify 5G Node Init
    [Documentation]
    ...     "5g_node" value is one of "cp_ue/cp_cl/cp_nb/cp_if/CPNRT/CPRT"
    [Arguments]      ${5g_node}      ${new_value}
    run keyword and ignore error    ssh.Disconnect    gnb_tmp
    ssh.Connect to                      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                                 ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                                 ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                                 alias=gnb_tmp
#    ${smod_result}    SSH.execute   ddal -s ddal_sysinfo_module_get_unit_id 0      connection=gnb_tmp
    ${bbu_result}     SSH.execute   bsh 1:0 "ddal -s ddal_sysinfo_module_get_unit_id 0"    connection=gnb_tmp
    ${_tmp}     Get Regexp Matches     ${bbu_result}     .*value=\'(.*)\'
    ${_bbu}     Split String     @{_tmp}[0]     =
    ${BBU_tmp}    strip string     @{_bbu}[-1]    characters='

    ${gnb_build}    SSH.execute    command=cd /ffs/run && ls -l |grep TargetBD*.xml     connection=gnb_tmp
    ${gnb_build}    Split String    ${gnb_build}    \r\n
    ${temp}    Remove String     ${5g_node}    _
    ${temp}    Remove String     ${temp}    -
    ${5g_node}   run keyword if   '21B' not in '${gnb_build}[0]'    replace_string    ${5g_node}    _    *    ELSE    set variable    ${5g_node}
    ${NODE_NAME}    run keyword if     'RT' not in '${5g_node}'     Convert To Uppercase    ${temp}   ELSE    set variable   ${5g_node}

    ssh.connect_to    ${GNBIP}    ${USER}    ${PW}     alias=${5g_node}
    SSH.execute    mkdir ${5g_node}     connection=${5g_node}
    @{_node_list_temp}    create list     CPUE     UPUE
    ${in_node_temp}    run keyword and return status    list should contain value    ${_node_list_temp}    ${NODE_NAME}
    ${NODE_PATH}   set variable if   '${BBU_tmp}'=='ABIO' and '${in_node_temp}'=='${True}'    ${NODE_NAME}NODE_ABINO     ${NODE_NAME}NODE
    SSH.execute    cp /ffs/run/swpool/5G/${NODE_PATH}/addons/${5g_node}_*.txz /user/toor4nsn/${5g_node}/     connection=${5g_node}
    ${output}    SSH.execute    ls /user/toor4nsn/${5g_node}     connection=${5g_node}
    ${temp}     Strip String    ${output}
    ${temp_list}     Split String    ${temp}    \n
    ${5g_node_name}     set variable     @{temp_list}[-1]
    SSH.execute    cd /user/toor4nsn/${5g_node} && rm -f ${5g_node_name} && tar xvf /ffs/run/swpool/5G/${NODE_PATH}/addons/${5g_node_name}
    ...    connection=${5g_node}    timeout=240
    Run  sshpass -p ${PW} scp ${USER}@${GNBIP}:/user/toor4nsn/${5g_node}/opt/nokia/SS_CPLANE/etc/${5g_node}.enb_conf.ini /tmp/${5g_node}.enb_conf.ini
    replace_node_ini    /tmp/${5g_node}.enb_conf.ini     ${new_value}
    Run  sshpass -p ${PW} scp /tmp/${5g_node}.enb_conf.ini ${USER}@${GNBIP}:/user/toor4nsn/${5g_node}/opt/nokia/SS_CPLANE/etc/${5g_node}.enb_conf.ini
    SSH.execute    cd /user/toor4nsn/${5g_node} && tar czvf ${5g_node_name} opt/ usr/    connection=${5g_node}    timeout=120
    SSH.execute    cp /user/toor4nsn/${5g_node}/${5g_node_name} /ffs/run/swpool/5G/${NODE_PATH}/addons/     connection=${5g_node}
    SSH.execute    crasign /ffs/run/swpool/5G/${NODE_PATH}/addons/${5g_node_name}     connection=${5g_node}      timeout=120
    SSH.execute    craverify /ffs/run/swpool/5G/${NODE_PATH}/addons/${5g_node_name}*     connection=${5g_node}    timeout=120
    SSH.execute    rm -rf /user/toor4nsn/${5g_node}     connection=${5g_node}
    SSH.execute    rm -rf /ffs/run/HashContainer*     connection=${5g_node}
    [Teardown]     Modify 5G Node INI Teardown      ${5g_node}

Modify 5G Node INI Teardown
    [Arguments]      ${5g_node}
    run keyword and ignore error    SSH.execute    rm -rf /user/toor4nsn/${5g_node}    connection=${5g_node}
    ssh.disconnect     ${5g_node}

Commission Scf with AP restart
    [Arguments]  ${scf_file}
    ${ap_old_time}    get_ne_time    ap
    Create cOAM session with alias    port=443      alias=cOAM
    ${commissioning_result}    coamadmin.perform_commissioning   scf_file=${scf_file}    skip_parameter_relation_errors=True    connection=cOAM
    ...    timeout=600
    get_commissioning_results    ${commissioning_result}
    ${AP_restarted}    waite_until_restarted    ${AirPhoneIP}    45
    ${ap_already_restart}    Run Keyword IF    ${AP_restarted}    set variable    ${AP_restarted}
    ...    ELSE    is_system_already_restart    ${ap_old_time}    ap
    Wait Until Keyword Succeeds     5min    10s    frt_common.Connect To ASIK
    Run Keyword Unless    ${ap_already_restart}    Reboot Airphone OAM without check
    set suite variable    ${IS_AP_AUTO_RESTART}    ${ap_already_restart}
    [Teardown]    Teardown cOAM session

Commission DU with AP restart
    [Arguments]  ${scf_file}
    Create cOAM session to DU    port=443
    coamadmin.perform_commissioning   scf_file=${scf_file}
    ...    skip_parameter_relation_errors=True    connection=cOAM
    ...    timeout=600
    ${AP_restarted}    waite_until_restarted    ${AirPhoneIP}    40
    Sleep    30s
    Wait Until Keyword Succeeds     5min    10s    frt_common.Connect to DU for cloud
    Run Keyword Unless    ${AP_restarted}    Reboot Airphone OAM without check
    set suite variable    ${IS_AP_AUTO_RESTART}    ${AP_restarted}
    [Teardown]    Teardown cOAM session

Set the SCF file according to hardware
    #update the scf configuration file
    ${POSITION_CONFIG}    Set Variable If     '${BOARD_POSITION}'=='LEFT'    ${LEFT_POSITION_CONFIG}    ${RIGHT_POSITION_CONFIG}
    Collections.append to list    ${vlanid_list}    ${POSITION_CONFIG}
    Update the prodCodePlanned according to hardware

Update the prodCodePlanned according to hardware
    Get the RU Number
    FOR    ${index}     IN RANGE    0    ${RU_NUM}
         ${num}     evaluate    ${index}+1
         set suite variable    &{PRODCODEPLAN}
         ...    dist_name=MRBTS-1/EQM-1/APEQM-1/RMOD-${num}    p_name=prodCodePlanned      p_value=${${RMOD_PRODCODEPLAN}_RMOD_PROCODE}
         Collections.append to list    ${vlanid_list}     ${PRODCODEPLAN}

    END
Set the Airphone configuration file according to hardware
	#update the iphy.xml, PLZ make sure the golden l2PSNodeId value correct
    Get the RU Number
    FOR    ${index}     IN RANGE    0    ${RU_NUM}
         modify_xml_text_by_tag    ${ap_file_name}    l1UlNodeId
         ...    ${${L1_TYPE}_CONFIG[0]['l1UlNodeId'][${index}]}    ${index}
         modify_xml_text_by_tag    ${ap_file_name}    l1DlNodeId
         ...    ${${L1_TYPE}_CONFIG[0]['l1DlNodeId'][${index}]}    ${index}

    END
Get current active coam alarm list at start for classical
    [Arguments]  ${gnb_id}=0     ${alias}=cOAM
    [Documentation]    This keyword is to get active fault id list,recommend to be used in case setup.
    ...    used for classical testline
    ...    :Author:  zhuoyan.xu@nsn-sbell.com
    ...     **Example:**
    ...    | Get current active coam alarm list at start for classical
    Log    ${gnb_id}
    Create cOAM session with alias    port=443      alias=${alias}
    @{alarm_list_details}    coamadmin.get_active_alarms    connection=${alias}
	FOR    ${alarm}    IN    @{alarm_list_details}
	      Append To List    ${FAULT_START}    ${alarm["additionalFaultID"]}
	END
	BuiltIn.Log Many    ${FAULT_START}
    [Teardown]    Teardown cOAM session    alias=${alias}

Get current active coam alarm list at start for cloud
    [Documentation]    This keyword is to get active fault id list,recommend to be used in case setup.
    ...    used for classical testline
    ...    :Author:  zhuoyan.xu@nsn-sbell.com
    ...     **Example:**
    ...    | Get current active coam alarm list at start for cloud
    ${fault_id_cloud_start}    get_current_alarm_for_cloud
    BuiltIn.Log Many    ${fault_id_cloud_start}
    Set Suite Variable    ${FAULT_START}    ${fault_id_cloud_start}
	BuiltIn.Log Many    ${FAULT_START}

Get current active coam alarm list at start
    run keyword if    'cloud' not in '${TL_TYPE}'    Get current active coam alarm list at start for classical
    run keyword if    'cloud' in '${TL_TYPE}'    Get current active coam alarm list at start for cloud

Get current active coam alarm list at end for classical
    [Arguments]  ${gnb_id}=0     ${alias}=cOAM
    [Documentation]    This keyword is to get active fault id list,recommend to be used in case teardown.
    ...    used for classical testline
    ...    :Author:  zhuoyan.xu@nsn-sbell.com
    ...     **Example:**
    ...    | Get current active coam alarm list at end for classical
    Log    ${gnb_id}
    Create cOAM session with alias    port=443      alias=${alias}
    @{alarm_list_details}    coamadmin.get_active_alarms    connection=${alias}
	FOR    ${alarm}    IN    @{alarm_list_details}
	      Append To List    ${FAULT_END}    ${alarm["additionalFaultID"]}
	END
	BuiltIn.Log Many    ${FAULT_END}
    [Teardown]    Teardown cOAM session    alias=${alias}

Get current active coam alarm list at end for cloud
    [Documentation]    This keyword is to get active fault id list,recommend to be used in case teardown.
    ...    used for classical testline
    ...    :Author:  zhuoyan.xu@nsn-sbell.com
    ...     **Example:**
    ...    | Get current active coam alarm list at end for cloud
    ${fault_id_cloud_end}    get_current_alarm_for_cloud
    BuiltIn.Log Many    ${fault_id_cloud_end}
    Set Suite Variable    ${FAULT_END}    ${fault_id_cloud_end}
	BuiltIn.Log Many    ${FAULT_END}

No new active alarm raised
    [Documentation]    This keyword is to check no new active alarm raised,recommend to be used in case teardown.
    ...    used for classical testline
    ...    :Author:  zhuoyan.xu@nsn-sbell.com
    ...     **Example:**
    ...    | No new Active alarm raised
    run keyword if    'cloud' not in '${TL_TYPE}'    Get current active coam alarm list at end for classical
    run keyword if    'cloud' in '${TL_TYPE}'    Get current active coam alarm list at end for cloud
    ${unexpect_list}    Check_whether_fault_id_in_white_list    ${FAULT_START}    ${FAULT_END}    ${FAULT_WHITE_LIST}
    Should Be Empty    ${unexpect_list}

Start tcpdump gnb slave
    [Arguments]    ${slave_pcap_name}
    run keyword and ignore error    ssh.Disconnect    gnb_master
    set suite variable     ${slave_pcap_name}
    run keyword if    'cloud' in '${TL_TYPE}'    ssh.Connect to
    ...    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=gnb_master
    ...    ELSE    ssh.Connect to
    ...    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...    alias=gnb_master
    SSH.execute    command=rm -rf /tmp/${slave_pcap_name}    connection=gnb_master
    run keyword and ignore error    ssh.Disconnect    gnb_slave
    ${slave_ip}      set variable if     "${BOARD_POSITION}" == "LEFT"     192.168.253.17     192.168.253.33
    ssh.Connect to     hostname=${slave_ip}    username=toor4nsn    password=oZPS0POrRieRtu     proxy=gnb_master    alias=gnb_slave
    ${cmd1}    set variable    bash -mc touch '/tmp/${slave_pcap_name}';
    ${cmd2}    set variable    tcpdump -i any sctp -w '/tmp/${slave_pcap_name}' -vvv < /dev/null > /dev/null 2>&1 & echo $!
    ${cmd}    Catenate     ${cmd1}     ${cmd2}
    ${gnb_slave_pid}    SSH.execute    command=${cmd}    connection=gnb_slave
    ${gnb_slave_pid}=   String.Get Line    ${gnb_slave_pid}   -1
    ${gnb_slave_pid}    Strip String   ${gnb_slave_pid}
    set suite variable  ${gnb_slave_pid}
    [Teardown]     run keyword and ignore error    ssh.Disconnect    gnb_master

Stop tcpdump gnb slave
    run keyword and ignore error    ssh.Disconnect    gnb_master
    run keyword if    'cloud' in '${TL_TYPE}'    ssh.Connect to
    ...    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=gnb_master
    ...    ELSE    ssh.Connect to
    ...    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...    alias=gnb_master
    SSH.execute    command=rm -rf /tmp/${slave_pcap_name}    connection=gnb_master
    run keyword and ignore error    ssh.Disconnect    gnb_slave
    ${slave_ip}      set variable if     "${BOARD_POSITION}" == "LEFT"     192.168.253.17     192.168.253.33
    ssh.Connect to     hostname=${slave_ip}    username=toor4nsn    password=oZPS0POrRieRtu     proxy=gnb_master    alias=gnb_slave
    SSH.execute    command=kill -TERM ${gnb_slave_pid}    connection=gnb_slave
    sleep      10s
    SSH.execute    bget 0:1 /tmp/${slave_pcap_name} /tmp    connection=gnb_master
    SSH.download_file    remote_path=/tmp/${slave_pcap_name}    local_path=${TEST_LOG_DIR}/${slave_pcap_name}    connection=gnb_master
    ${log_path}    set variable     ${TEST_LOG_DIR}/${slave_pcap_name}
    [Return]   ${log_path}
    [Teardown]       run keyword and ignore error    ssh.Disconnect    gnb_master

Start tcpdump gnb master
    [Arguments]    ${master_pcap_name}
    run keyword and ignore error    ssh.Disconnect    gNB
    set suite variable    ${master_pcap_name}
    ssh.Connect to                      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                                 ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                                 ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                                 alias=gNB
    SSH.execute    command=rm -rf /tmp/${master_pcap_name}    connection=gNB
    ${cmd1}    set variable    bash -mc touch '/tmp/${master_pcap_name}';
    ${cmd2}    set variable    tcpdump -i any sctp -w '/tmp/${master_pcap_name}' -vvv < /dev/null > /dev/null 2>&1 & echo $!
    ${cmd}    Catenate     ${cmd1}     ${cmd2}
    #${cmd}  set variable  bash -mc touch '/tmp/${master_pcap_name}';
    #...    tcpdump -i any sctp -w '/tmp/${master_pcap_name}' < /dev/null > /dev/null 2>&1 & echo $!
    ${gNB_pid}    SSH.execute    command=${cmd}    connection=gNB
    ${gNB_pid}=   String.Get Line   ${gNB_pid}   -1
    ${gNB_pid}    Strip String   ${gNB_pid}
    set suite variable  ${gNB_pid}
    [Teardown]     run keyword and ignore error    ssh.Disconnect    gNB

Stop tcpdump gnb master
    run keyword and ignore error    ssh.Disconnect    gNB
    ssh.Connect to                      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                                 ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                                 ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                                 alias=gNB
    SSH.execute    command=kill -TERM ${gNB_pid}    connection=gNB
    sleep      10s
    SSH.download_file    remote_path=/tmp/${master_pcap_name}    local_path=${TEST_LOG_DIR}/${master_pcap_name}    connection=gNB
    ${log_path}    set variable     ${TEST_LOG_DIR}/${master_pcap_name}
    [Return]   ${log_path}
    [Teardown]       run keyword and ignore error    ssh.Disconnect    gNB

Start Tcpdump with all SMOD
    [Documentation]  for SMOD: ASIK, [Move all CP components to slave Xeon]
    ...    Only happens in 5G21A (for Classical)/5G21B (for Cloud). And no change to 5G20A/5G20B.
    ...    For SMOD: ASIL/ABIO, no change in master Xeon.
    [Arguments]      ${pcap_file_name}
    run keyword and ignore error    ssh.Disconnect    gnb_build
    ssh.Connect to                      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                                 ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                                 ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                                 alias=gnb_build
    ${gnb_build}    SSH.execute    command=cd /ffs/run && ls -l |grep TargetBD*.xml     connection=gnb_build
    ${gnb_build}    Split String    ${gnb_build}    \r\n
    run keyword and ignore error    ssh.Disconnect    gnb_build
    ${is_gnb_build}    set variable if    "5G20B" in "@{gnb_build}[0]"    ${True}    ${False}
#    ${is_gnb_build}    set variable if    "5G21B" in "@{gnb_build}[0]"    ${True}
    set suite variable     ${is_gnb_build}
    set suite variable     ${pcap_file_name}
    run keyword if  '${SMOD}' == 'ASIK' and '${is_gnb_build}'=='${True}'    Start tcpdump gnb master      ${pcap_file_name}
    run keyword if  '${SMOD}' == 'ASIK' and '${is_gnb_build}'=='${False}'    Start tcpdump gnb slave     ${pcap_file_name}
    run keyword if  '${SMOD}' != 'ASIK'    Start tcpdump gnb master      ${pcap_file_name}

Stop Tcpdump with all SMOD
    [Arguments]     ${delay_time}=10
    Sleep     ${delay_time}
    run keyword if  '${SMOD}' == 'ASIK' and '${is_gnb_build}'=='${True}'    Stop tcpdump gnb master
    run keyword if  '${SMOD}' == 'ASIK' and '${is_gnb_build}'=='${False}'    Stop tcpdump gnb slave
    run keyword if  '${SMOD}' != 'ASIK'    Stop tcpdump gnb master

Get Default WTS Cfg To Test Dir
    Kill egate process
    Kill Edaemon process
    Run    cd ${CFG_PATH};sudo ./edaemon --port 22222; sleep 5; ./egate --port 20000;
    ${wts_cfg_name}    ${wts_ap_xml_name}    get_wts_default_cfg_files    ${TL_TYPE}
    execute_egate_command_without_kargs    cp airphone_cfg/${wts_cfg_name} .
    execute_egate_command_without_kargs    cp airphone_cfg/${wts_ap_xml_name} .
    Run    cp ${CFG_PATH}/${wts_cfg_name} ${TEST_LOG_DIR}
    Run    cp ${CFG_PATH}/${wts_ap_xml_name} ${TEST_LOG_DIR}

Backup Config File To Test Dir
    Run    sshpass -p ${PW} scp ${USER}@${AirPhoneIP}:/ffs/run/swconfig.txt ${TEST_LOG_DIR}/swconfig_ap.txt
    Run    sshpass -p ${PW} scp ${USER}@${GNBIP}:/ffs/run/swconfig.txt ${TEST_LOG_DIR}/swconfig_gnb.txt
    Run    sshpass -p ${PW} scp ${USER}@${AirPhoneIP}:/ffs/run/simmode/iphy.xml ${TEST_LOG_DIR}/iphy.xml
    ${user_ap_cfg}     Run keyword and return status      BuiltIn.log      ${USER_CONFIG['AP_CFG_FILE']}
    ${ap_file_temp}    Run    ls -l ${CONFIG_PATH}/wts/*.xml
    @{ap_file_name_temp}     Split String     ${ap_file_temp}     /
    ${ap_file_temp_name}    set variable      @{ap_file_name_temp}[-1]
    run keyword if    "${user_ap_cfg}" != "${True}" and "default" not in "${TL_TYPE}"     Copy File     ${CFG_PATH}/${ap_file_temp_name}
    ...    ${TEST_LOG_DIR}/${ap_file_temp_name}
    ${user_wts_cfg}     Run keyword and return status      BuiltIn.log      ${USER_CONFIG['WTS_CFG_FILE']}
    run keyword if    "${user_wts_cfg}" != "${True}" and "default" not in "${TL_TYPE}"     Copy File     ${CFG_PATH}/${CFG_FILE}
    ...    ${TEST_LOG_DIR}/${CFG_FILE}
    run keyword if    "${user_ap_cfg}" != "${True}" and "${user_wts_cfg}" != "${True}" and "default" in "${TL_TYPE}"
    ...    Get Default WTS Cfg To Test Dir

Modify Startuplogsize CPNRT Cloud
    [Arguments]      ${cu_host}    ${cu_username}    ${cu_password}
    Run   ssh-keygen -f "/home/ute/.ssh/known_hosts" -R ${cu_host}
    change_startuplogsize_cpnrt_cloud     ${cu_host}    ${cu_username}    ${cu_password}

Report test result to reporting portal
    [Arguments]    ${log_dir}    ${gnb_id}=${0}    ${isForDebugging}=No
    ${tsResult}=    Set variable if    "${TEST_STATUS}"=="PASS"    passed    failed
    ${qcFilePathA}=    Replace string using regexp    ${SUITE_SOURCE}    .robot    .qc
    ${casePath}=    get_case_path    ${SUITE_SOURCE}
    ${qcFilePathB}=    find any qc file    ${casePath}
    ${qcFileExist}=    check file exist    ${qcFilePathA}
    ${qcFilePath}=    Set variable if    "${qcFileExist}"=="True"    ${qcFilePathA}    ${qcFilePathB}
    ${qcFilePath}=    Replace string using regexp    ${qcFilePath}    .*testsuite    testsuite
    Online Reporting to ReP    tcName=${TEST_NAME}    tsResult=${tsResult}    resultDir=${log_dir}    isForDebugging=${isForDebugging}
    ...    qcFilePath=${qcFilePath}    gnb_id=${gnb_id}

Online Reporting to ReP
    [Documentation]    :Author: Nikolay Shkulepov
    ...
    ...    :param tcName: STRING - QC Test Instance name including the instance number (approval version could be omitted),
    ...           e.g. "[1]5GC000510-C_D_UL_open_loop_power_control"
    ...    :param tsResult: STRING - verification verdict, possible values: "passed" or "failed" (case insensitive)
    ...    :param pmCounters: STRING (default=EMPTY) - PM Counters under test,
    ...           e.g. "[{'piid': 'M55319C00001', 'result': 'Passed', 'value': 30}, {'piid': 'M55320C00001', 'result': 'Passed', 'value' 30}]"
    ...    :param resultDir: STRING (default=EMPTY) - result directory if it is different from the current one (e.g. for the offline reporting)
    ...    :param isForDebugging: STRING (default=no) - it helps to omit the communication to the ReP,
    ...                           possible values: "no", "yes", "true", or "false" (case insensitive)
    ...    :param qcFilePath: STRING (default=EMPTY) - path to .qc file starting from "testsuite/.."
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param enb_id: (default=0) Id/Number of eNB
    ...    :param swPostFix: STRING (default=EMPTY) - post-fix string for the SW Branch in .qc file, e.g. ASIL_Parity
    ...    :Example:
    ...         online Reporting to ReP   [1]5GC000510-C_D_UL_open_loop_power_control   passed
    ...     IMPORTANT: please see the examples
    ...         /resources/sites/Ulm/Common/Examples/reporting_example.robot
    ...         /resources/sites/Ulm/Common/Examples/reporting_example.qc
    ...
    [Arguments]  ${tcName}  ${tsResult}  ${pmCounters}=${EMPTY}  ${resultDir}=${EMPTY}  ${featuresCovered}=${EMPTY}  ${isForDebugging}=No
    ...          ${qcFilePath}=${EMPTY}   ${gnb_id}=0   ${enb_id}=0   ${swPostFix}=${EMPTY}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Log    ${enb_id}
    ${gnbSwVersion}=   get gNB SW Version   ${gnb_id}
    ${testLine}    get TESTLINE from
    ${testLine}=     Replace string using regexp    ${testLine}    -    _
    @{qcInfo}=   get Info from QC File   ${resultDir}   ${qcFilePath}   ${gnbSwVersion}   ${tcName}   ${swPostFix}
    report Results to ReP   tcName=${tcName}
    ...                     tsResult=${tsResult}
    ...                     swBuild=${gnbSwVersion}
    ...                     testLine=${testLine}
    ...                     suitePath=${SUITE SOURCE}
    ...                     qcTestlabPath=@{qcInfo}[0]
    ...                     qcTestSetName=@{qcInfo}[1]
    ...                     pmCounters=${pmCounters}
    ...                     featuresCovered=${featuresCovered}
    ...                     isForDebugging=${isForDebugging}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]

