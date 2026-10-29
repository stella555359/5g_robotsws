*** Settings ***
Documentation     author: Charlotte Wu
...               contact: charlotte.wu@nokia-sbell.com
...               squad group: MMW_02
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Library    ../lib/CB008941.py
Library     taf.rfrl.bts.commissioning
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library           taf.hw.rf_attenuator    WITH NAME    attenuator
Library           taf.ue.pioneer.client       WITH NAME           pclient

*** Variables ***
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
@{group1}    ${0}    ${1}    ${2}    ${3}
${logs_path}    /tmp/8941_log/
${bip_log_path}    ${logs_path}l1l2bip/
@{NR_PHY_CELL_IDS}    6
${bip_prefix1}    BTS*_1011_mirroring_L2L1_
${srs_filter}    UlData_srsReceiveReqUes_t.symbolPosition
${srs_name0}     UlData_srsReceiveReqUes_t.symbolPosition
${bip_harqu_dtx_filter}    UlData_UePuschReceiveRespHarqUL1sw_t.dtx == 0
${bip_harqu_dtx_name}    UlData_UePuschReceiveRespHarqUL1sw_t.dtx
${bip_harqu_crc_filter}    (UlData_UePuschReceiveRespHarqUL1sw_t.crc == 0)&&(UlData_UePuschReceiveRespHarqUL1sw_t.dtx == 0)
${bip_harqu_crc_name}    UlData_UePuschReceiveRespHarqUL1sw_t.crc
${bip_harqu_dtx_filter_old}    UlData_UePuschReceiveRespHarqU_t.dtx == 0
${bip_harqu_dtx_name_old}    UlData_UePuschReceiveRespHarqU_t.dtx
${bip_harqu_crc_filter_old}    (UlData_UePuschReceiveRespHarqU_t.crc == 0)&&(UlData_UePuschReceiveRespHarqU_t.dtx == 0)
${bip_harqu_crc_name_old}    UlData_UePuschReceiveRespHarqU_t.crc

${bler_ratio_muting_off}    100
@{srs_PA_value}    ${1.0}    ${127.0}    ${127.0}    ${127.0}
${soap_sub_dir}    UnitOAM_SOAP_Startup_LBTS_*
${imei6}      865697040215607
${UE_index}    6
${testtime}    2400
${buffersize}    1024
${packetsize}    1280
${packetsize_ul}    500
${dl_port}    44165
@{cell_id_list}    185663491
${target_ul}    50
${target_dl}    10
${tshark_path}    /usr/bin/tshark
${L3call_count}    3

*** Keywords ***
Case_Setup
    [Documentation]    Author: Chen Helen
    ...                This keyword is setup
    [Arguments]    ${connection}=COAM    ${ue_index}=${0}
    Log To Console    \n *** ${connection} Case setup
	robot_common_operations.Common Case Setup
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=schtasks /run /tn dingli
    ...    connection=cygwin

Case_Teardown
    [Documentation]    Author: Chen Helen
    ...                This keyword is teardown
    [Arguments]    ${connection}=COAM
    Log To Console    \n *** ${connection} Case teardown
    Run Keyword And Ignore Error    pclient.teardown_service    service=pioneer
    Close the iperf process on APPserver    ${0}

UE_Prepare_And_Require
    [Arguments]    ${ue_alias}=mate20x    ${imei}=${imei}    ${alias}=pioneer    ${ue_index}=${0}
    Log to console    Prepare and require UE
	pclient.setup_service
    ...    host=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    port=30999
    ...    ssh_username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ssh_password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    alias=${alias}
    sleep    30s
    pclient.prepare_ues    service=${alias}
    sleep    5s
    pclient.require_ue    service=${alias}     imei=${imei}    ue_alias=${ue_alias}
    ${is_kirin}     pclient.is_kirin_chip    ue=${ue_alias}

UE_Attach_about_dingli
    [Arguments]    ${ue_alias}=mate20x
    log to console    UE poweron for attach
    pclient.poweroff     ue=${ue_alias}
    sleep    10s
    pclient.poweron     ue=${ue_alias}
    sleep    2s

UE_Attach_And_DL_UL_Traffic
    [Documentation]    Author: Charlotte Wu
    ...                This keyword is single UE attach and UL traffic
    [Arguments]    ${ul_throughput}    ${dl_throughput}    ${ue_index}=${6}
    log to console    Prepare dingli UE and Start Traffic
    csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin
    csn.Connect to    hostname=${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...    username=${tl.appserver.iperf_details.ssh_connection_details.username}
    ...    password=${tl.appserver.iperf_details.ssh_connection_details.password}
    ...    alias=APPserver
    ${dl_port_index}    Set Variable    ${0}
    UE_Prepare_And_Require    ue_alias=UE_${ue_index}    imei=${imei6}
    UE_Attach_about_dingli    ue_alias=UE_${ue_index}
    sleep    5s
    Log to Console    Start UL Traffic
    Dingli_UE_Start_UL_Traffic    address=${tl.appserver.iperf_details.network_interface_address}
    ...    port=${tl.appserver.iperf_details.port}    testtime=${testtime}
    ...    bandwidth=${ul_throughput}     buffersize=${buffersize}
    ...    packetsize=${packetsize_ul}    ue_index=${ue_index}
    Dingli_UE_Start_DL_Traffic    dl_time=${testtime}
    ...    dl_port=${dl_port}    dl_throughput=${dl_throughput}    ue_index=${ue_index}
    ...    dl_length=${packetsize}
	sleep    1min

Dingli_UE_Start_UL_Traffic
    [Documentation]    Author: Chen Helen
    ...                This keyword is for doing UL traffic (UDP)
    [Arguments]    ${address}    ${port}    ${testtime}    ${bandwidth}
    ...    ${buffersize}    ${packetsize}    ${ue_index}=${6}
    pclient.startultraffic     protocol=UDP    address=${address}
    ...    port=${port}    testtime=${testtime}
    ...    bandwidth=${bandwidth}    buffersize=${buffersize}
    ...    packetsize=${packetsize}    ue=UE_${ue_index}

Dingli_UE_Get_IP
    [Documentation]    Author: Charlotte Wu
    ...                This keyword is check the Single UE UL and DL tput
    [Arguments]    ${apn}     ${ue_index}=${6}
    ${ue_ip_dict}    pclient.getpduinfo    apn=${apn}    ue=UE_${ue_index}
    ${ue_ip}    set Variable    ${ue_ip_dict}[Param][IP]
    log to console    ${ue_ip}
    [Return]    ${ue_ip}

Dingli_UE_Start_DL_Traffic
    [Documentation]    Author: Charlotte Wu
    ...                This keyword is check the Single UE UL and DL tput
	[Arguments]    ${dl_time}
	...    ${dl_port}    ${dl_throughput}    ${dl_length}    ${ue_index}=${6}
	Log to Console    Get UE_${ue_index} ip
	${dingli_ue_addr}    Dingli_UE_Get_IP    apn=mdrb.nokia.com    ue_index=${ue_index}
    Start DL traffic via iperf on Appserver    ue_addr=${dingli_ue_addr}
	...    dl_time=${dl_time}    dl_port=${dl_port}
	...    dl_throughput=${dl_throughput}    dl_length=${dl_length}

UE_Stop_Traffic
    [Documentation]    Author: Chen Helen
    ...                This keyword is check the Single UE UL and DL tput
	[Arguments]    ${ue_index}=${6}
    pclient.stoptest    ue=UE_${ue_index}

Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF_dingliUE
    [Arguments]    ${ru_index}=${3}    ${asik_alias}=ASIK Master    ${bip_analyze}=false
    Case_Setup
    Run Keyword If    ${bler_ratio_muting_off}==100    L3call_Loki_based_DU_with_UL_PRB_muting_inactive_FDBF_dingliUE
    Modify Swconfig File    swconfig_path=${CURDIR}/swconfig.txt
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_3
    ${soap_log_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
    #Check point of Made2
    log to console    check endpointCapacitySharingGroup have 0-3
    ${group_list}    get_group_ids_from_soap    filepath=${soap_log_path}
    List Should Contain Sub List    ${group_list}    ${group1}
    log to console    check group 0
    ${status}    check_group_info    filepath=${soap_log_path}    group_id=${0}    maxUplaneSectionHeadersPerSymbol=${18}
    ...    maxUplaneSectionHeadersPerSlot=${252}    Endpoints=${16}
    Should Be Equal    ${status}    ${True}
    log to console    check group 2
    ${status}    check_group_info    filepath=${soap_log_path}    group_id=${2}    maxUplaneSectionHeadersPerSymbol=${26}
    ...    maxUplaneSectionHeadersPerSlot=${78}    Endpoints=${16}
    Should Be Equal    ${status}    ${True}
    log to console    check fragment disable
    ${status}    userPlaneFragmentationEnable_from_soap    filepath=${soap_log_path}
    #8D8U
    Should Be Equal    ${status}    ${32}
    log to console    L3 call
    FOR      ${n}      IN RANGE      ${L3call_count}
        ${bler_ratio_muting_on}=    Do_L3call_with_data_transfer_tp_check_from_gnb_dingliUE    ul_tp=50000  dl_tp=10000000  protocol=udp
        ...    traffic_duration=900    bip_analyze=${bip_analyze}
        ${status}=    Evaluate    ${bler_ratio_muting_on}<(1.2*${bler_ratio_muting_off})
        Exit For Loop If    ${status}
    END
    Should Be True    ${status}
    [Teardown]  run keywords  Case_Teardown    AND    run keyword and ignore error    csn.disconnect   connection=RU_${ru_index}    AND
    ...    run keyword and ignore error    csn.Disconnect   connection=${asik_alias}

Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF
    [Arguments]    ${ru_index}=${1}    ${asik_alias}=ASIK Master    ${bip_analyze}=false
    Run Keyword If    ${bler_ratio_muting_off}==100    L3call_Loki_based_DU_with_UL_PRB_muting_inactive_FDBF
    Modify Swconfig File    swconfig_path=${CURDIR}/swconfig.txt
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1
    ${soap_log_path}    Download soap Log from RU    ru_alias=RU_${ru_index}    sub_dir=${soap_sub_dir}
    #Check point of Made2
    log to console    check endpointCapacitySharingGroup have 0-3
    ${group_list}    get_group_ids_from_soap    filepath=${soap_log_path}
    List Should Contain Sub List    ${group_list}    ${group1}
    log to console    check group 0
    ${status}    check_group_info    filepath=${soap_log_path}    group_id=${0}    maxUplaneSectionHeadersPerSymbol=${18}
    ...    maxUplaneSectionHeadersPerSlot=${252}    Endpoints=${16}
    Should Be Equal    ${status}    ${True}
    log to console    check group 2
    ${status}    check_group_info    filepath=${soap_log_path}    group_id=${2}    maxUplaneSectionHeadersPerSymbol=${26}
    ...    maxUplaneSectionHeadersPerSlot=${78}    Endpoints=${16}
    Should Be Equal    ${status}    ${True}
    log to console    check fragment disable
    ${status}    userPlaneFragmentationEnable_from_soap    filepath=${soap_log_path}
    #8D4U
    Should Be Equal    ${status}    ${24}
    log to console    L3 call
    FOR      ${n}      IN RANGE      ${L3call_count}
        ${bler_ratio_muting_on}=    Do_L3call_with_data_transfer_tp_check_from_gnb    ul_tp=50M  dl_tp=10M  protocol=udp  traffic_duration=900
        ...    bip_analyze=${bip_analyze}
        ${status}=    Evaluate    ${bler_ratio_muting_on}<(1.05*${bler_ratio_muting_off})
        Exit For Loop If    ${status}
    END
    Should Be True    ${status}
    [Teardown]  run keywords  run keyword and ignore error    csn.disconnect   connection=RU_${ru_index}    AND
    ...    run keyword and ignore error    csn.Disconnect   connection=${asik_alias}

L3call_Loki_based_DU_with_UL_PRB_muting_active_PUSCH_mapping_typeB_with_SRS_FDBF
    [Arguments]    ${ru_index}=${1}    ${asik_alias}=ASIK Master    ${bip_analyze}=srs
    log to console    import scf
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _srs.xml
    Selenium Login And Disable Screen Lock
    Commissioning SCF And Check On Air    scf_path=${SCF_upload}
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${PA_original_value}=    Backup PA value    ${4}
    Set PA value    modify_list=${srs_PA_value}      port_num=${4}
    Backup PA value    ${4}
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1
    ${soap_log_path}    Download soap Log from RU    ru_alias=RU_${ru_index}    sub_dir=${soap_sub_dir}
    #Check point of Made2
    log to console    check endpointCapacitySharingGroup have 0-3
    ${group_list}    get_group_ids_from_soap    filepath=${soap_log_path}
    List Should Contain Sub List    ${group_list}    ${group1}
    log to console    check group 0
    ${status}    check_group_info    filepath=${soap_log_path}    group_id=${0}    maxUplaneSectionHeadersPerSymbol=${18}
    ...    maxUplaneSectionHeadersPerSlot=${252}    Endpoints=${16}
    Should Be Equal    ${status}    ${True}
    log to console    check group 2
    ${status}    check_group_info    filepath=${soap_log_path}    group_id=${2}    maxUplaneSectionHeadersPerSymbol=${26}
    ...    maxUplaneSectionHeadersPerSlot=${78}    Endpoints=${16}
    Should Be Equal    ${status}    ${True}
    log to console    check fragment disable
    ${status}    userPlaneFragmentationEnable_from_soap    filepath=${soap_log_path}
    Should Be Equal    ${status}    ${24}
    log to console    L3 call
    ${bler_ratio_muting_on}=    Do_L3call_with_data_transfer_tp_check_from_gnb    ul_tp=30M  dl_tp=10M  protocol=udp  traffic_duration=900
    ...    bip_analyze=${bip_analyze}
    [Teardown]    run keywords    Set PA value    modify_list=${PA_original_value}      port_num=${4}    AND    Selenium Logout And Close Browser


L3call_Loki_based_DU_with_short_PUCCH_FDBF
    [Arguments]    ${ru_index}=${1}    ${asik_alias}=ASIK Master
    log to console    import scf
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _shortpucch.xml
    Selenium Login And Disable Screen Lock
    Commissioning SCF And Check On Air    scf_path=${SCF_upload}
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1
    ${soap_log_path}    Download soap Log from RU    ru_alias=RU_${ru_index}    sub_dir=${soap_sub_dir}
    log to console    check fragment disable
    ${status}    userPlaneFragmentationEnable_from_soap    filepath=${soap_log_path}
    Should Be Equal    ${status}    ${0}
    log to console    L3 call
    Do_L3call_with_data_transfer_tp_check_from_gnb    ul_tp=50M  dl_tp=10M  protocol=udp  traffic_duration=900
    [Teardown]    Selenium Logout And Close Browser


L3call_Loki_based_DU_with_UL_PRB_muting_inactive_FDBF
    [Arguments]    ${ru_index}=${1}    ${asik_alias}=ASIK Master
    log to console    import scf
    Modify Swconfig File    swconfig_path=${CURDIR}/swconfig_new.txt
    Selenium Login And Disable Screen Lock
    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1
    ${soap_log_path}    Download soap Log from RU    ru_alias=RU_${ru_index}    sub_dir=${soap_sub_dir}
    log to console    check fragment disable
    ${status}    userPlaneFragmentationEnable_from_soap    filepath=${soap_log_path}
    Should Be Equal    ${status}    ${0}
    log to console    L3 call
    ${bler_ratio_muting_off}=    Do_L3call_with_data_transfer_tp_check_from_gnb    ul_tp=50M  dl_tp=10M  protocol=udp  traffic_duration=900
    Set Suite Variable    ${bler_ratio_muting_off}    ${bler_ratio_muting_off}
    [Teardown]    Run Keywords    Modify Swconfig File    swconfig_path=${CURDIR}/swconfig.txt    AND    Selenium Logout And Close Browser

L3call_Loki_based_DU_with_UL_PRB_muting_inactive_FDBF_dingliUE
    [Arguments]    ${ru_index}=${3}    ${asik_alias}=ASIK Master
    log to console    import scf
    Modify Swconfig File    swconfig_path=${CURDIR}/swconfig_new.txt
    Selenium Login And Disable Screen Lock
    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_3
    ${soap_log_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
    log to console    check fragment disable
    ${status}    userPlaneFragmentationEnable_from_soap    filepath=${soap_log_path}
    Should Be Equal    ${status}    ${0}
    log to console    L3 call
    ${bler_ratio_muting_off}=    Do_L3call_with_data_transfer_tp_check_from_gnb_dingliUE    ul_tp=50000  dl_tp=10000000  protocol=udp
	...    traffic_duration=900
    Set Suite Variable    ${bler_ratio_muting_off}    ${bler_ratio_muting_off}
    [Teardown]    Selenium Logout And Close Browser

Modify Swconfig File
    [Arguments]    ${swconfig_path}    ${asik_alias}=ASIK Master
    Connect to Common Unit Master    alias=${asik_alias}
    Upload Swconfig File    swconfig_path=${swconfig_path}
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=${asik_alias}

Upload Swconfig File
    [Arguments]    ${swconfig_path}    ${asik_alias}=ASIK Master
    ${swconfig_file_name}    Fetch from right    ${swconfig_path}    /
    log to console    upload swconfig file
    csn.Upload File    local_path=${swconfig_path}    remote_path=/ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    rename uploaded new swconfig file
    csn.execute    mv /ffs/run/${swconfig_file_name} /ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    crasign...
    csn.execute    crasign /ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    craverify...
    csn.execute    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7    connection=${asik_alias}
    sleep    1s
    log to console    reboot testline...
    Connect to gnb coam via ssl
    coam.reset_site    connection=GNB_OAM
    sleep    120s
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Do_L3call_with_data_transfer_tp_check_from_gnb
    [Documentation]
    ...    The purpose of this test is to verify L3 call.
    [Arguments]  ${ul_tp}=30M  ${dl_tp}=10M  ${protocol}=udp  ${traffic_duration}=900    ${bip_analyze}=false
    ...    ${ul_tp_target}=30  ${dl_tp_target}=10  ${check_duration}=5m
    step2: Prepare UE
    Step3: UE Attach
    Step4: Start traffic    ul_throughput=${ul_tp}    dl_throughput=${dl_tp}    protocol=${protocol}    duration=${traffic_duration}
    sleep    60s
    Step5: Check throughput    ultp=${ul_tp_target}    dltp=${dl_tp_target}    duration=${check_duration}
    ${bler_ratio}=    Collect Bip Log    ${logs_path}    ${bip_analyze}
    [Return]    ${bler_ratio}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Call_Common_Teardown    AND
    ...    OperatingSystem.Run    mv ${bip_log_path}* ${SAVE LOG DIRECTORY}

Do_L3call_with_data_transfer_tp_check_from_gnb_dingliUE
    [Documentation]
    ...    The purpose of this test is to verify L3 call.
    [Arguments]  ${ul_tp}=30000  ${dl_tp}=10000  ${protocol}=udp  ${traffic_duration}=900    ${bip_analyze}=false
    ...    ${ul_tp_target}=${target_ul}  ${dl_tp_target}=${target_dl}  ${check_duration}=5m
	Log To Console    \n Portocal is ${protocol} and traffic duration is ${traffic_duration}
    UE_Attach_And_DL_UL_Traffic    ul_throughput=${ul_tp}    dl_throughput=${dl_tp}    ue_index=${UE_index}
    sleep    60s
    Check throughput Dingli   ultp=${ul_tp_target}    dltp=${dl_tp_target}    duration=${check_duration}    ue_type=qct_dx50
    ${bler_ratio}=    Collect Bip Log    ${logs_path}    ${bip_analyze}    nr_phy_cell_ids=94
    [Return]    ${bler_ratio}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    UE_Stop_Traffic    ue_index=${UE_index}    AND
    ...    OperatingSystem.Run    mv ${bip_log_path}* ${SAVE LOG DIRECTORY}

step2: Prepare UE
    log to console      step2: Prepare UE
    power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}

Step3: UE Attach
    log to console      Step3: UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    #Preparation and execution for Commercial UE Attach    ue_index=${0}
    #Log    click Airplane mode switch to disable its function so that make UE attach

Step4: Start traffic
    [Arguments]   ${ul_throughput}=50M    ${dl_throughput}=300M    ${protocol}=udp    ${duration}=1200
    log to console      Step4: Start traffic
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=${ul_throughput}    duration=${duration}    ue_type=${UE_TYPE}
    ...    iperf_type=via_command
    ...    protocol=${protocol}
    sleep    1s
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${dl_throughput}    duration=${duration}    ue_type=${UE_TYPE}
    ...    protocol=${protocol}    buffer_size=1400B    process_num=${3}    seg_size=1350    window=16M
    sleep    2s

Get NR Cell Identity
    [Documentation]
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${cell_id_list}    Get Dictionary Keys    ${cell_mapping}
    ${nrCellIdentity_list}    Create List
    FOR    ${item}    IN     @{cell_id_list}
        ${nrCellIdentity}    Evaluate    int(${cell_mapping[${item}]['nrCellIdentity']})
        Append To List    ${nrCellIdentity_list}    ${nrCellIdentity}
    END
    [Return]    ${nrCellIdentity_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Step5: Check throughput
    [Arguments]    ${ultp}=35    ${dltp}=150    ${duration}=5m    ${ue_type}=${UE_TYPE}
    log to console      Step5: Check throughput
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    filter=L2Lo
    ${list_of_cell_ids}    Get NR Cell Identity
    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
      ...    ultarget_throughput=${ultp}    dltarget_throughput=${dltp}    actCarrierAggregation=${True}

Check throughput Dingli
    [Arguments]    ${ultp}=35    ${dltp}=150    ${duration}=5m    ${ue_type}=${UE_TYPE}
    log to console      Step5: Check throughput
    @{cell_id}    Create List    ${cell_id_list[0]}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    filter=L2Lo
    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${cell_id}
    ...    ultarget_throughput=${ultp}    dltarget_throughput=${dltp}    actCarrierAggregation=${True}

Step6: Stop traffic
    log to console      Step6: Stop traffic
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}    iperf_type=via_command
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}

Step7: UE Detach
    log to console      Step7: UE Detach
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

Call_Common_Teardown
    [Arguments]    ${connection}=COAM
    Log To Console    \n *** ${connection} Call_Common teardown
    Run Keyword And Ignore Error    Step6: Stop traffic
    Run Keyword And Ignore Error    Step7: UE Detach
    Run Keyword And Ignore Error    Teardown the Aasyslog save progress

Collect Bip Log
    [Arguments]       ${logs_path}    ${bip_analyze}    ${nr_phy_cell_ids}=${NR_PHY_CELL_IDS}
    Start to collect bip log new    ${nr_phy_cell_ids}
    Sleep  3  reason=Wait for log collection
    Stop to collect bip log new     target_dir=${logs_path}
    ${bip_log_path1}     Get BIP Filelist    log_path=${bip_log_path}
    ${filter_result}=    Run Keyword If    '${bip_analyze}' == 'srs'    Get srs from bip    bip_file=${bip_log_path}/${bip_log_path1}
    Run Keyword If    '${bip_analyze}' == 'srs'    Get and check srs field values
    ${bler_ratio}=    Run Keyword If    '${ENB_BRANCH}' == 'SBTS25R1'    Get ul bler from bip old   bip_file=${bip_log_path}/${bip_log_path1}
	...               ELSE IF    '${ENB_BRANCH}' == 'SBTS24R3'    Get ul bler from bip old    bip_file=${bip_log_path}/${bip_log_path1}
	...               ELSE IF    '${ENB_BRANCH}' == 'SBTS24R2'    Get ul bler from bip old    bip_file=${bip_log_path}/${bip_log_path1}
	...               ELSE    Get ul bler from bip    bip_file=${bip_log_path}/${bip_log_path1}
    [Return]    ${bler_ratio}


Get BIP Filelist
    [Arguments]    ${log_path}   ${connection}=UTE_CON   ${mergecap_wait}=120s
	Log To Console    \n merge cap wait ${mergecap_wait}
    csn.connect to
    ...               hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=UTE_CON
    @{list_log_names}     ssh_common_commands.get_file_names_under_directory    directory=${log_path}    connection=${connection}
    ...    file_indicator=${bip_prefix1}*.pcap
    Run Keyword And Ignore Error    Log to console   ${list_log_names}[0]
    [Return]    ${list_log_names}[0]

Start to collect bip log new
    [Arguments]    ${nr_phy_cell_ids}   ${host}=${tl.gnbs[${0}].dus[${0}].f1_m_ip_addr}   ${username}=Nemuadmin  ${password}=nemuuser  ${port}=443
    ${webservice}=  Create Dictionary
    ...  host=${host}
    ...  user=${username}
    ...  password=${password}
    ...  port=${port}
    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=l1l2bip
    ...  webservice=${webservice}
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    ...  timeout=1500
    core.setup_collectors    names=l1l2bip
    core.start_collectors    names=l1l2bip
    core.Set Suite Alias     l1l2bip

Stop to collect bip log new
    [Arguments]    ${target_dir}
    core.stop_collectors    names=l1l2bip
    core.collect_collectors    names=l1l2bip       target_dir=${target_dir}
    core.teardown_collectors    names=l1l2bip

Get srs from bip
    [Arguments]    ${bip_file}
    ${Parser}    cap.setup    infile=${bip_file}    display_filter=${srs_filter}
    ...    tshark_path=${tshark_path}    alias="Parser"
    [Return]    ${Parser}

Get and check srs field values
    ${srsvalue_0}    get_field_value_by_name    field_name=${srs_name0}    pcap_parser="Parser"
    sleep  3 sec
    FOR    ${item}    IN     @{srsvalue_0}
        Should Be Equal AS Strings   '${item}'    '13'
    END

Get ul bler from bip
    [Arguments]    ${bip_file}
    ${Parser}    cap.setup    infile=${bip_file}    display_filter=${bip_harqu_dtx_filter}
    ...    tshark_path=${tshark_path}    alias="Parser"
    ${bip_harqu_dtx_list}    get_field_value_by_name    field_name=${bip_harqu_dtx_name}    pcap_parser="Parser"
    ${dtx_counter}=    Get Length    ${bip_harqu_dtx_list}
    ${Parser}    cap.setup    infile=${bip_file}    display_filter=${bip_harqu_crc_filter}
    ...    tshark_path=${tshark_path}    alias="Parser"
    ${bip_harqu_crc_list}    get_field_value_by_name    field_name=${bip_harqu_crc_name}    pcap_parser="Parser"
    ${crc_ok_counter}=    Get Length    ${bip_harqu_crc_list}
    ${bler_ratio}=    Run Keyword If    ${dtx_counter}>0    Evaluate    float((${dtx_counter}-${crc_ok_counter}))/float(${dtx_counter})
    ...    ELSE    Set Variable    None
    [Return]    ${bler_ratio}

Get ul bler from bip old
    [Arguments]    ${bip_file}
    ${Parser}    cap.setup    infile=${bip_file}    display_filter=${bip_harqu_dtx_filter_old}
    ...    tshark_path=${tshark_path}    alias="Parser"
    ${bip_harqu_dtx_list}    get_field_value_by_name    field_name=${bip_harqu_dtx_name_old}    pcap_parser="Parser"
    ${dtx_counter}=    Get Length    ${bip_harqu_dtx_list}
    ${Parser}    cap.setup    infile=${bip_file}    display_filter=${bip_harqu_crc_filter_old}
    ...    tshark_path=${tshark_path}    alias="Parser"
    ${bip_harqu_crc_list}    get_field_value_by_name    field_name=${bip_harqu_crc_name_old}    pcap_parser="Parser"
    ${crc_ok_counter}=    Get Length    ${bip_harqu_crc_list}
    ${bler_ratio}=    Run Keyword If    ${dtx_counter}>0    Evaluate    float((${dtx_counter}-${crc_ok_counter}))/float(${dtx_counter})
    ...    ELSE    Set Variable    None
    [Return]    ${bler_ratio}

Backup PA value
    [arguments]    ${port_num}      ${vender}=HBTE
    attenuator.setup_attenuator    attenuator=${tl.attenuator[0]}    alias=${vender}
    ${PA_value}      create list
    FOR      ${n}      IN RANGE      ${port_num}
        ${value}    attenuator.read_attenuation
         ...      port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${n}]}    attenuator_device=${vender}
        append to list      ${PA_value}      ${value}
    END
    [Return]    ${PA_value}

Set PA value
    [arguments]    ${modify_list}      ${port_num}      ${vender}=HBTE
    attenuator.setup_attenuator    attenuator=${tl.attenuator[0]}    alias=${vender}
    FOR      ${n}      IN RANGE      ${port_num}
          attenuator.set_attenuation
          ...      port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${n}]}
          ...      value=${${modify_list}[${n}]}
          ...      attenuator_device=${vender}
    END

ERR check in BTSlog
    [arguments]    ${log_path}=/tmp/btslog2/
    ${output} =    OperatingSystem.Run    ls ${log_path}
    Log    ${output}
    ${output} =    OperatingSystem.Run    grep -i ERR/L2-PS/ ${log_path}*.LOG
    Should Be Empty    ${output}
    ${output} =    OperatingSystem.Run    grep -e l1_application_rt.*ERR/ ${log_path}*.LOG
    Should Be Empty    ${output}
    ${output} =    OperatingSystem.Run    rm -f ${log_path}*.LOG
    Log    ${output}

Check ulUPlaneFragmentation in BTSlog
    [Arguments]    ${log_path}=/tmp/btslog2/
    ${output} =    OperatingSystem.Run    grep -o '"ulUPlaneFragmentation":[^,]*' ${log_path}*.LOG | tail -n 1
    Log    ${output}
    Should Not Contain    ${output}    "ulUPlaneFragmentation":null
    ${output} =    OperatingSystem.Run    grep -o '"dlUPlaneFragmentation":[^,]*' ${log_path}*.LOG | tail -n 1
    Log    ${output}
    Should Not Contain    ${output}    "dlUPlaneFragmentation":null