*** Settings ***

Documentation
...   author: Velu P
...   contact: velu.p@nokia.com
...   Description: Test Suite for CB008205-C


Resource          ./testsuite/Bangalore/ORAN/resources/robot/common_setup_teardown.robot
Resource          ./testsuite/Bangalore/ORAN/resources/python/Macro/bts/common/gnb_scf.robot
Library           Process
Library           String
Library           taf.collectors.core    WITH NAME    CORE
Library           taf.collectors.btslog  WITH NAME   BTSLOG
Library           taf.collectors.tshark    WITH NAME    tshark
Library           String      WITH NAME   str
Library           taf.ue    WITH NAME    ue
Library           ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Library           testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Library           ute_ue
Library           Collections
Library           DateTime
Library           taf.selenium.sbts    WITH NAME    soam
Library           taf.sbts.oam.coam.admin    WITH NAME    coam


Test Setup      Test Setup
Test Teardown   Test Teardown
Force Tags       CRT  SBTS24R1    FL00    QCD_MN_RAN   QCP_RAN_ST 

*** Variables ***

${CELL_ID}          1
@{LOG_NAME_LIST}    BTSLOG    snapshot
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
@{deviation_dl}=  20
@{deviation_ul}=  30
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


*** Test Cases ***
Verify the Commissioning of of mixed mode.
    Step1: Commission the SBTS mixed mode configuration
	Step2: Validate the O_RU Call home procedure
    Step3: Initiate the TCP Downlink and uplink data transfer 

*** Keywords ***

Test Setup
    Log to console   --Test setup--
    BTSLOG.create_BTSLOG_collector
    ...    name=BTSLOG
    ...    log_dir=/tmp/BTSLOG2

    CORE.setup_collectors      names=BTSLOG
    CORE.set_suite_alias      BTSLOG
    CORE.start_collectors      names=BTSLOG
	
	

Test Teardown
    Log to console   --Test teardown--
    CORE.stop_collectors      names=BTSLOG
    CORE.collect_collectors      names=BTSLOG      target_dir=/home/ute/robotws5g/${TIMESTAMP}/${tc}
    CORE.teardown_collectors      names=BTSLOG
	
	

Step1: Commission the SBTS mixed mode configuration
    Set Suite Variable    ${scfc_file}    /home/ute/a.xml
    gnb_scf.Perform Full Commissioning on gNB    scf_file=${scfc_file}
    sleep    600
 

Step2: Validate the O_RU Call home procedure
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
    ${a}=    netconf_get__message_id     ${netconf_file}    get    fan-tray
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file}    get    fan-tray    name
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
    sleep    200
    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}     #Throughput check
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction_ul}
    sleep    200
    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
    ...     thrughtput=${throughput_ul}    deviation=${deviation_ul}      #Throughput check
    Log to console    \nWaiting for data transfer
    Log to console    \nData transfer completed



