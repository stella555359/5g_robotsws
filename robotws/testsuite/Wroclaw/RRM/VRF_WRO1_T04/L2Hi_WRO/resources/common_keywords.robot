*** Settings ***
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    common_variables.robot
Resource    feature_activation.robot
Resource    logs_collection.robot

Library     Collections
Library     DateTime
Library     OperatingSystem
Library     Process
Library     String
Library     Telnet
Library     XML    use_lxml=true
Library     ute_fsmaccess
Library     ute_tshark
Library     ute_wtssim
Library     ta_emss
Library     ta5g_aashell
Library     ta5g_admin_operations
Library     ta5g_cell_operations
Library     ta5g_commissioning
Library     ta5g_egate
Library     ta5g_enb
Library     ta5g_iperf_traffic
Library     ta5g_iphy
Library     ta5g_pm_counters
Library     ta5g_setups_and_teardowns
Library     ta5g_syslog
Library     ta5g_testline_management
Library     ta5g_throughput
Library     ta5g_tshark
Library     ta5g_ue_mobility
Library     taf.ccs.aashell
Library     taf.config.wts                   WITH NAME    wts
Library     taf.hw.pdu
Library     taf.sbts.oam.coam.admin          WITH NAME    admin
Library     taf.trafficgenerator.iperf       WITH NAME    iperf
Library     taf.transport.ssh                WITH NAME    ssh

Library     common_keywords.py
Library     statistic_validator.py


Documentation
...    This file contains general keywords used for testing on Classical TL.

*** Variables ***
${BTS_ADDRESS}    192.168.255.129
${BTS_PORT}       443
${USE_SSL}        True

*** Keywords ***
Common Test Setup
    [Arguments]    ${cfg_filepath}
    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    Reach Onair    lua_cfg=${cfg_filepath}
    Set Internal Traffic Type To UEs
    Wait For Next Full Pm Interval

Common Test Teardown
    [Arguments]    ${scf_filepath}
    Check For An Unexpected Alarm
    Stop Default Processes And Gather Logs And Compress Logs
    Send Full Commissioning    ${scf_filepath}
    Wait For GNB Configured State

Get Current SCF
    [Arguments]    ${dir_path}    ${file_name}
    admin.Setup Admin
    ${scf_filepath}=    admin.Get Current Scf File    local_dir_path=${dir_path}    file_name=${file_name}     timeout=120
    Set Suite Variable    ${DEFAULT_SCF_FILEPATH}    ${scf_filepath}
    admin.Teardown Admin

Attach Ue With Sgnb
    [Arguments]    ${ue_id}=11    ${target_gnb}=2    ${target_cells}=1    ${bearer}=2    ${type}=split_scg
    Execute Egate Command And Wait For Data    cmd=ue_attach id=${ue_id}
    ...                      pass_regexp=UE${ue_id}: === UE IS ACTIVE
    ...                      timeout=10
    Execute Egate Command And Wait For Data
    ...    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer} type=${type}
    ...                      pass_regexp=UE${ue_id}: Successfully reconfigured dual connectivity
    ...                      timeout=10

Register Ue With Default Pdu Session
    [Arguments]    ${ue_id}=1     ${pdu_id}=1    ${gw}=1    ${session_type}=ipv4
    Set Internal Traffic Type To UEs    ${ue_id}
    Execute Egate Command And Wait For Data    cmd=ue_register id=${ue_id}
    ...                      pass_regexp=UE${ue_id}: UE performed Registration type INITIAL_REGISTRATION
    ...                      timeout=10
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw} session_type=${session_type}
    ...                      pass_regexp=UE-${ue_id} PDU SESSION ID-${pdu_id} setup/reestablishment complete
    ...                      timeout=10

Modify Pdu Session And Wait For Regexp
    [Arguments]    ${ue_id}=1     ${pdu_id}=1    ${qos_id}=2    ${qfi_id}=2    ${5qi_id}=5
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_id}
    ...                      pass_regexp=Added QosFlow with QFI:${qfi_id} fiveQI:${5qi_id}
    ...                      timeout=10

Attach One 5g Ue Capable Of Supporting Rohc
    [Arguments]    ${ue_id}=1    ${session_type}=ipv4
    Execute Egate Command    cmd=ue_param id=${ue_id} ue_nr_capabilities=${UE_CAPA_SUPPORTING_ROHC}
    Set Internal Traffic Type To UEs    ${ue_id}
    Register Ue With Default Pdu Session    ${ue_id}    session_type=${session_type}
    Modify Pdu Session And Wait For Regexp    ${ue_id}    qos_id=2    qfi_id=2    5qi_id=5
    Modify Pdu Session And Wait For Regexp    ${ue_id}    qos_id=3    qfi_id=3    5qi_id=1

Enable Syslog Info Level Prints
    Change Rad Param With Aashell    param=${ERadCcs_AaSysLogOutputLevel}    value=2
    Change Rad Param With Aashell    param=${ERadCcs_AaSysLogInputLevel}    value=2
    Change Rad Param With Aashell    param=${ERadCcs_AaSysLogOutputMode}    value=5

Enable Syslog Debug Prints For Rohc
    Enable Syslog Info Level Prints
    Change Rad Param With Aashell    param=${L2_ROHC_DEBUG}    value=1

Prepare Sa Test Environement And Reach Onair
    [Arguments]    ${perform_tl_reset}     ${cfg_filepath_fdd}    ${cfg_filepath_tdd}
    ...    ${cfg_filepath_tdd_fdd}=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...    ${cfg_filepath_tdd_mmwv}=${EPCSIM_CFG_PATH_SA_TDD_MMWV}
    ...    ${output_dirpath}=${OUTPUT_DIR}
    Start Default Logging    output_dirpath=${output_dirpath}
    Run Keyword If    ${perform_tl_reset}    Reset Testline And Wait For Rmods
    Configure SA VM interfaces
    Modify SCTP Timeout
    Wait for gNB Configured state
    Choose Lue File Based On Detected Configuration And Reach Onair
    ...    lua_fdd=${cfg_filepath_fdd}    lua_tdd=${cfg_filepath_tdd}    lua_tdd_fdd=${cfg_filepath_tdd_fdd}    lua_tdd_mmwv=${cfg_filepath_tdd_mmwv}

Prepare Nsa Test Environement And Reach Onair
    [Arguments]    ${perform_tl_reset}     ${cfg_filepath_fdd}    ${cfg_filepath_tdd}
    ...    ${cfg_filepath_tdd_fdd}=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...    ${cfg_filepath_tdd_mmwv}=${EPCSIM_CFG_PATH_NSA_TDD_MMWV}
    ...    ${output_dirpath}=${OUTPUT_DIR}
    Start Default Logging    output_dirpath=${output_dirpath}
    Run Keyword If    ${perform_tl_reset}    Reset Testline And Wait For Rmods
    Configure NSA VM interfaces
    Wait for gNB Configured state
    Choose Lue File Based On Detected Configuration And Reach Onair
    ...    lua_fdd=${cfg_filepath_fdd}    lua_tdd=${cfg_filepath_tdd}    lua_tdd_fdd=${cfg_filepath_tdd_fdd}    lua_tdd_mmwv=${cfg_filepath_tdd_mmwv}

Prepare Sa Test Environement
    [Arguments]    ${perform_tl_reset}=${RESET_TL}    ${output_dirpath}=${OUTPUT_DIR}
    Start Default Logging    output_dirpath=${output_dirpath}
    Run Keyword If    ${perform_tl_reset}    Reset Testline And Wait For Rmods
    Configure SA VM interfaces
    Modify SCTP Timeout
    Wait for gNB Configured state

Choose Lue File Based On Detected Configuration And Reach Onair
    [Arguments]    ${lua_fdd}    ${lua_tdd}     ${lua_tdd_fdd}=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}    ${lua_tdd_mmwv}=${EPCSIM_CFG_PATH_NSA_TDD_MMWV}
    ...    ${cell_id}=1
    ${TDD_CONFIGURATION}=    Check If Tdd Cell    global_cell_id=${cell_id}
    ${band}=    Get Band Type
    ${cell_number}=    Check Cell List
    ${LUA}=    Run Keyword If
    ...     '${TDD_CONFIGURATION}'=='True' and '${band}'=='cmWv' and '${cell_number}'=='4'                Set Variable    ${lua_tdd_fdd}
    ...     ELSE IF  '${TDD_CONFIGURATION}'=='True' and '${band}'=='cmWv'            Set Variable    ${lua_tdd}
    ...     ELSE IF  '${TDD_CONFIGURATION}'=='False' and '${band}'=='cmWv'            Set Variable    ${lua_fdd}
    ...     ELSE IF  '${TDD_CONFIGURATION}'=='True' and '${band}'=='mmWv'             Set Variable    ${lua_tdd_mmwv}
    ...     ELSE     Fail    Unsupported Configuration
    Reach Onair    lua_cfg=${LUA}    align_tac_values=False

Get Band Type
    [Arguments]    ${cell_id}=1    ${param}=band
    ${nBandIndicator}=     Check Cell Parameter Value    global_cell_id=${cell_id}    parameter=${param}
    ${BandIndicator}=   Remove String    ${nBandIndicator}    n
    ${bandId}=    Set Variable If     ${BandIndicator} > 256    mmWv  cmWv
    [Return]    ${bandId}

Wait for gNB Configured state
    Check Radios Availability
    Check Bts Is In Given State    bts_state=@{ACCEPTED_BTS_STATES}    timeout=900

Check Dl Cell Traffic
    [Arguments]    ${expected_throughput_dl_mbps}    ${cell_id}=1
    Print Bearer Tput
    Expected Throughput For Cell Should Be Reached
    ...    enb_id=2    cell_id=${cell_id}    throughput=${expected_throughput_dl_mbps}
    ...    direction=dl    selection_type=average    layer=data

Print Bearer Tput
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2 dir=dl dc_cell_group=scg

Display Qfi stats
    [Arguments]    ${ue_id}=1     ${pdu_id}=1     ${qfi_id}=1
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=1 dir=bi

Disable Debug Logs In Egate
    Execute Egate Command    cmd=debug_log level=6

Set Internal Traffic Type To UEs
    [Arguments]    ${ue_id}=1     ${pdu_id}=1
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Configure NSA VM interfaces
    Run Process  sudo ifconfig eth3:SGW 10.0.1.21/24 up  shell=yes
    Start Vm Ethernet Interface    if_name=eth3:xn    ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.102/24
    Start Vm Ethernet Interface    if_name=eth3:x2    ip_with_mask=10.0.1.3/24

Configure SA VM interfaces
    Run and return rc and output     sudo ip addr add 10.0.1.131/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.132/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.133/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.134/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.135/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.136/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.99/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.121/24 dev eth3
    Configure VM interfaces For Second Gnb

Configure VM interfaces For Second Gnb
    Start Vm Ethernet Interface    if_name=eth3:xn    ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.102/24
    Start Vm Ethernet Interface    if_name=eth3:x2    ip_with_mask=10.0.1.3/24

Modify SCTP Timeout
    Run    sudo sysctl -w net.sctp.sack_timeout=10
    Run    sudo sysctl -w net.sctp.rto_min=200
    Run    sudo sysctl -w net.sctp.rto_initial=200
    Run    sudo sysctl -w net.sctp.rto_max=800
    Run    sshpass -p ${NOKIA_PASS} ssh toor4nsn@${AP_IP} 'sysctl -w net.sctp.sack_timeout=10'
    Run    sshpass -p ${NOKIA_PASS} ssh toor4nsn@${AP_IP} 'sysctl -w net.sctp.rto_min=200'
    Run    sshpass -p ${NOKIA_PASS} ssh toor4nsn@${AP_IP} 'sysctl -w net.sctp.rto_initial=200'
    Run    sshpass -p ${NOKIA_PASS} ssh toor4nsn@${AP_IP} 'sysctl -w net.sctp.rto_max=800'

Resources Usage At Test Begining
    Create AaShell CLI    name=aashell
    taf.ccs.aashell.Setup    aashell
    ${resources_usage1}=    Get Resources Usage    aashell
    Set Test Variable    ${resources_usage1}

Resources Usage At Suite Begining
    Create AaShell CLI    name=aashell
    taf.ccs.aashell.Setup    aashell
    ${resources_usage1}=    Get Resources Usage    aashell
    Set Suite Variable    ${resources_usage1}

Resources Usage At Test End
    Create AaShell CLI    name=aashell
    taf.ccs.aashell.Setup    aashell
    ${resources_usage2}=    Get Resources Usage    aashell
    Should Be Equal As Resources
    ...    ${resources_usage1}
    ...    ${resources_usage2}
    ...    exclude=${RESOURCES_EXCLUDED}
    taf.ccs.aashell.Teardown    aashell

Update Gscn In Iphy File
    [Arguments]    ${GSCN_1}    ${GSCN_2}
    BuiltIn.log to console    Setting New GSCN Value
    ${ACU_alias}    SSH.connect to    192.168.200.1   toor4nsn    oZPS0POrRieRtu   alias=iphy
    ssh.Download File    /rom/simmode/iphy.xml    /tmp/new_iphy.xml    connection=${ACU_alias}

    Replace Gscn    /tmp/new_iphy.xml    ${GSCN_1}    ${GSCN_2}

    ssh.Upload File    /tmp/new_iphy.xml    /rom/simmode/new_iphy.xml   connection=${ACU_alias}
    ssh.execute    reboot    connection=${ACU_alias}

Modify Config Addr To Ipv6
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    wts.Modify    set          UPF_ADDR="1.2.4.1,2001::1/48"
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

Modify Config To 8 Cells
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    wts.Modify    set_cell id=3 gnb=2           nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=17:1
    wts.Modify    set_cell id=4 gnb=2           nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=17:2
    wts.Insert    set_cell id=5 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=18:0 tac=200    after    set_cell id=4 gnb=2
    wts.Modify    set_cell id=5        proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nrci=0x05 tdd_cell=off mandatory_for_activation=off
    wts.Insert    set_cell id=6 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=18:1 tac=200    after    set_cell id=5 gnb=2
    wts.Modify    set_cell id=6        proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nrci=0x05 tdd_cell=off mandatory_for_activation=off
    wts.Insert    set_cell id=7 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=18:2 tac=200    after    set_cell id=6 gnb=2
    wts.Modify    set_cell id=7        proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nrci=0x05 tdd_cell=off mandatory_for_activation=off
    wts.Insert    set_cell id=8 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=19:0 tac=200    after    set_cell id=7 gnb=2
    wts.Modify    set_cell id=8        proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nrci=0x05 tdd_cell=off mandatory_for_activation=off
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

Modify Config To Emergency Call
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    wts.Modify    set_qosflow id=1          5qi=8 default=off
    wts.Modify    set_qosflow id=2          5qi=5 default=on
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

Modify Config For External Traffic For Ue14 In Nsa Call
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    wts.Modify    ue_param id=14             ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    wts.Modify    set_bearer id=2 ue=14      qci=6 trf_type=external
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

Prepare Iperf Environment And Start Traffic
    [Arguments]    ${server_cmd_options}    ${iperf_service}    ${client_cmd_options}    ${iperf_ue_service}
    Create Iperf Server    cmd_options=${server_cmd_options}    iperf_alias=${iperf_service}    log_path=${OUTPUT_DIR}/ue_iperf2_log_dl_ser.txt
    Create Iperf Client    cmd_options=${client_cmd_options}    iperf_alias=${iperf_ue_service}    log_path=${OUTPUT_DIR}/ue_iperf2_log_dl_cli.txt
    ${iperf_list}=    Create List    ${iperf_service}    ${iperf_ue_service}
    Set Test Variable   ${iperf_list}
    iperf.Setup    iperfs=${iperf_list}
    Execute Egate Command    cmd=sim_debug_log level=6
    Sleep    3s
    iperf.Start    iperfs=${iperf_list}
    Sleep    ${TRAFFIC_DURATION_SEC}

Kill Iperf Processes
    ${result}                         Run    sudo pgrep iperf
    Run                               sudo kill -9 ${result}
    Sleep                             5 sec

Increase WTS Buffer Size
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_max=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_default=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_max=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_default=20971520

Modify UPF And UEC Buff Size
    [Arguments]    ${lua_cfg}
    wts.Load Wts Cfg        ${lua_cfg}
    wts.Modify    set_upf id=1    ngu_snd_buff_size=20M ngu_rcv_buff_size=20M
    wts.Modify    set_uec id=1    proxy_snd_buf_size=20000000 proxy_rcv_buf_size=20000000
    wts.Save Wts Cfg        ${lua_cfg}

Reset Airphone
    BuiltIn.log to console    Reseting Airphone
    ssh.connect_to   hostname=192.168.200.1   username=toor4nsn   password=oZPS0POrRieRtu
    ssh.send command   system-module-reboot
    ssh.disconnect
    Wait for gNB Configured state

Reset Testline And Wait For Rmods
    admin.Setup Admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}
    admin.Reset Site
    Check Radios Availability

Trigger Radio Link Outage
    Execute Egate Command    cmd=forced_dtx_testmode_nr profile_id=1 force_dtx_pusch=8000:1 force_dtx_pucch=9000:1
    Execute Egate Command    cmd=ue_testmode_set_nr id=11 testmode=forced_dtx action=activate profile_id=1 scell=8

Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Log to console  Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Configure  {'MOC': '${MOC}', 'ID': '${ID}', '${parameter}': '${value}'}

Check Traffic On Mcg And Scg Leg
    [Arguments]    ${dir}    ${ue_id}=11
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=${ue_id} id=2 dir=${dir} dc_cell_group=mcg
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=${ue_id} id=2 dir=${dir} dc_cell_group=scg