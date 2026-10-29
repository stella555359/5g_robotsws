*** Settings ***

Documentation
...   author: Velu P
...   contact: velu.p@nokia.com
...   Description: Test Suite for CB008205-C


Library           Process
Library           String
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.collectors.tshark    WITH NAME    tshark
Library           String      WITH NAME   str
Library           taf.ue    WITH NAME    ue
Library           OperatingSystem     WITH NAME    os
Library           ./testsuite/Bangalore/ORAN/resources/python/deletefiles.py
Library           ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
#Library           ta_attenuator
Library           testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Library           ute_ue
Library           Collections
Library           DateTime
Library           taf.selenium.sbts    WITH NAME    soam
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.collectors.simple    WITH NAME    simple
Resource    ./testsuite/Bangalore/ORAN/resources/python/Macro/bts/common/gnb_log.robot
Resource    ./testsuite/Bangalore/ORAN/resources/python/Macro/bts/common/gnb_bbu.robot


Test Setup      Test Setup
Test Teardown   Test Teardown
Force Tags       CRT  SBTS24R3    FL00    QCD_MN_RAN   QCP_RAN_VRF

*** Variables ***
&{CB008205-C_Verification_of_SA_L3_TCP_call_for_FDD_NR_via_10Gbps_eCPRI_link_with_3rd_party_O-RU_when_mimo_is_configured_as_4DL4UL}
...     QC_ID_FL00=QC_31512   QC_ID_SBTS24R3=QC_774142
${CELL_ID}          1
@{LOG_NAME_LIST}    btslog    snapshot
@{capabilities}    Legacy_1
@{throughput_dl}=   400
@{throughput_ul}=   60
@{dt_name}=   iperf_dl_test
@{UE_alias}=  UE_1
@{direction_dl}=  dl
@{direction_ul}=  ul
@{duration}=  700s
@{timeout}      180
@{tcpcalltype}=    TCP
@{udpcalltype}=    UDP
@{deviation_dl}=  100
@{deviation_ul}=  100
${packet_size}=  1400
${tput}=   400Mbits/sec
${ASP_BOARD_TYPE}     ABIO0
${SCF_PATH}         ${CURDIR}/resources/
${DELTA_FILE}       ${CURDIR}/resources/Configuration_scf_MRBTS-990.xml
${scf_file}=        ${DELTA_FILE}
${CONFIG_PATH}      /home/ute/testline_configuration_5G/Bangalore/7_2_UTE5GTLBTS9/ta_ue_config.yaml
${port_val_list}     9
${counter_initial_value_1}      M55301C
${value1}    18020
${a}     1
${Timestamp}=    1
${tc}=    Verify_the_TCP_call_with_10Gbps_eCPRI_link_speed

*** Test Cases ***
CB008205-C_Verification_of_SA_L3_TCP_call_for_FDD_NR_via_10Gbps_eCPRI_link_with_3rd_party_O-RU_when_mimo_is_configured_as_4DL4UL
    delete_files_netconf
    Step1: O-RU reset
    Netconf File Collection
    Step2: Validate the O_RU Call home procedure    /home/ute/${Timestamp}/${tc}/RMOD_L-1_NetconfRpcMessageTrace.log
    Step3: Initiate the TCP Downlink and uplink data transfer

*** Keywords ***

Test Setup
    Log to console   --Starting Test setup and syslog--
    coam.setup_admin    bts_host=192.168.255.129
    Log to console   --Test setup--
    btslog.create_btslog_collector
    ...    name=btslog
    ...    log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.set_suite_alias      btslog
    core.start_collectors      names=btslog
    ${mrbts_state}=    coam.Get Mrbts State
    Log to console    \MRBTS state: ${mrbts_state}
    coam.collect_snapshot     /home/ute/robotws/${Timestamp}/pre_snapshot.zip

Test Teardown
    Log to console   --Test teardown--
    #Run Keyword And Continue On Failure    Stop Collecting gNB BtsLog    gnb_id=0    du_id=0    log_dir=/home/ute/${Timestamp}/${tc}
    #Verify Syslog Anomalies
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog      target_dir=/home/ute/robotws/${Timestamp}/${tc}
    core.teardown_collectors      names=btslog
	${mrbts_state}=    coam.Get Mrbts State
    Log to console    \MRBTS state: ${mrbts_state}
    coam.collect_snapshot     /home/ute/robotws/${Timestamp}/post_snapshot.zip
    coam.Teardown All Aliases For Admin

Step1: O-RU reset
    Log to console   --\n RU startup\n--
    soam.enable_virtual_display
    soam.login    https://192.168.255.129    Nemuadmin    nemuuser    browser=Chrome
    sleep    40
    soam.reset_ru
    sleep    360
    soam.disable_virtual_display
    #Verify gNB is onAir

Netconf File Collection
    ${proxy}       Create Dictionary    host=10.41.209.165    user=ute    password=BT5l@bus3rl0g1n
    ${executor}    Create Dictionary    host=192.168.255.129    user=toor4nsn    password=oZPS0POrRieRtu
    ...     proxy=${proxy}
    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET00/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    sleep    30
    core.collect_collectors    names=coredump    target_dir=/home/ute/${Timestamp}/${tc}
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf /home/ute/${Timestamp}/${tc}/coredump/coredump1.log.tgz -C /home/ute/${Timestamp}/${tc}/coredump
    os.Copy File    /home/ute/${Timestamp}/${tc}/coredump/RMOD_L-*.log
	...    /home/ute/${Timestamp}/${tc}/RMOD_L-1_NetconfRpcMessageTrace.log
    sleep    100
	#return    /home/ute/${Timestamp}/${tc}/RMOD_L-1_NetconfRpcMessageTrace.log

Step2: Validate the O_RU Call home procedure
    [Arguments]    ${netconf_file}
    ###############example validations usign netcinf keywords#############################
    #validate_netconf_reply_message    ${netconf_file}    get    hardware     o-ran-name
    #netconf_get_message_id     ${netconf_file}     get    software-inventory
    #validate_netconf_reply_message      ${netconf_file}     fan-tray    name
    #${a}=    netconf_get_value     ${netconf_file}    rpc    software-install      file-names
    #${a}=    netconf_get_value     ${netconf_file}    rpc    edit-config    vlan-id
    #run keyword and continue on failure  Should Contain    ${result}    Message ID: 0x0b0a
    #run keyword and continue on failure   should be true    ${duration_for_alarm_upload}<=55
    ##################O-RU message 6 ######################
    ${a}=    validate_netconf_reply_message      ${netconf_file}     create-subscription    ok
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    supervision-watchdog-reset    supervision-notification-interval
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    supervision-watchdog-reset    guard-timer-overhead
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    supervision-watchdog-reset    guard-timer-overhead
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     supervision-watchdog-reset    next-update-at
    run keyword and continue on failure   Should not be empty    ${a}
    ##################O-RU message 7 ######################
    ### commenting fan-tray info as FJT doesn't support FAN
    #${a}=    netconf_get__message_id     ${netconf_file}    get    fan-tray
    #run keyword and continue on failure   Should not be empty    ${a}
    #${a}=    validate_netconf_reply_message      ${netconf_file}    get    fan-tray    name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id     ${netconf_file}    get    hardware
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    hardware     o-ran-name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    hardware     product-code
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id     ${netconf_file}    get    interfaces
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    interfaces     name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id     ${netconf_file}    get    band-capabilities
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    band-capabilities     band-number
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    band-capabilities
    ...    max-supported-frequency-dl
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    band-capabilities     min-supported-frequency-dl
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    band-capabilities     max-supported-bandwidth-dl
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    band-capabilities     max-supported-frequency-ul
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    band-capabilities     min-supported-frequency-ul
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    band-capabilities     max-supported-bandwidth-ul
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id     ${netconf_file}    get    ru-capabilities
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    ru-capabilities     max-power-per-pa-antenna
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id     ${netconf_file}    get    software-inventory
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    software-inventory    name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id     ${netconf_file}    get    port-transceivers
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    port-transceivers    vendor-id
    run keyword and continue on failure   Should not be empty    ${a}
    ##################O-RU message 9 ######################
    ${a}=    netconf_get_message_id     ${netconf_file}    get    user-plane-configuration
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    tx-arrays    name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    rx-arrays    name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    user-plane-configuration    endpoint-types
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    static-low-level-tx-endpoints    name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    static-low-level-rx-endpoints    name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id     ${netconf_file}    get    hardware
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    hardware     o-ran-name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    hardware     product-code
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    hardware     serial-num
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    hardware     mfg-name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id     ${netconf_file}   get    ald-ports-io
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    ald-port     o-ran-name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id     ${netconf_file}    get    external-io
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    external-io     name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id     ${netconf_file}    get    active-alarm-list
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    data     active-alarm-list
    run keyword and continue on failure   Should not be empty    ${a}
    ##################O-RU message 10 ######################
    ${a}=    netconf_get_message_id    ${netconf_file}    get    software-inventory
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    software-inventory     name
    run keyword and continue on failure   Should not be empty    ${a}
    ##################O-RU message 11 ######################
    ${a}=    netconf_get_message_id     ${netconf_file}    get    sync
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    sync-status     sync-state
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    ptp-config     ptp-profile
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id    ${netconf_file}    get    ptp-status
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    ptp-status     lock-state
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    synce-config     acceptance-list-of-ssm
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id     ${netconf_file}    get    synce-status
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    synce-status     lock-state
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id     ${netconf_file}    get    operational-info
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    operational-info     restart-cause
    run keyword and continue on failure   Should not be empty    ${a}

Step3: Initiate the TCP Downlink and uplink data transfer
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}     #UE detach step
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}     #UE attach step
	Log to console    \nattach is success
    Log to console    \nStarting data transfer
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction_dl}
    sleep    300
    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}     #Throughput check
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction_ul}
    sleep    300
    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
    ...     thrughtput=${throughput_ul}    deviation=${deviation_ul}      #Throughput check
    Log to console    \nWaiting for data transfer
    Log to console    \nData transfer completed
