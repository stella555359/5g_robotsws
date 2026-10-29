*** Settings ***
Documentation
...    Author: mateusz.kowalczyk@nokia.com; adam.superczynski@nokia.com
...    Maintainer: adrian.stawiany@nokia.com
...    Test Description: O-RU startup procedure
...    Confluence link: link
...    Group in charge: I_MN_RAN_BOAM_PZ_OM_ET_1_GMS <I_MN_RAN_BOAM_PZ_OM_ET_1@internal.nsn.com>
...    References: https://gates.nsn-net.net/view/00025e9a#o=0
...    QualityCenter: tds://ran_et.mn_ran.qc-prod.ext.net.nokia.com/qcbin/TestLabModule-000000003649890581?EntityType=ITestSet&EntityID=41006
...    Sample execution: pybot --variable CONFIGURATION:Wroclaw.XXX -b debug.log -d /home/ute/results/ /home/ute/robotlte/
...    testsuite/WMP/SOAM1/CB008480-A/general.robot
...    Review:
...    AC/REQ: LTE_OPR_REQ_18980;LTE_OPR_REQ_31749;LTE_OPR_REQ_30420

*** Variables ***
@{BEAMS_ID}    <beam-id>1</beam-id>    <beam-id>2</beam-id>    <beam-id>3</beam-id>    <beam-id>4</beam-id>
@{ORU_CAPABILITES}    writable-running    candidate    confirmed-commit    rollback-on-error    validate    startup    xpath    with-defaults
...    notification    interleave
@{OPT_MODULES_AND_FEATURES_IN_RU_L}=    ENERGYSAVING    OVERCURRENT-SUPPORTED    o-ran-ald-port    GRANULARITY-TRANSPORT-MEASUREMENT
...    GRANULARITY-EAXC-ID-MEASUREMENT    o-ran-beamforming    o-ran-externalio     o-ran-fan
@{OPT_FEATURES}    oranFeatEnergySaving    oranFeatGranularityEaxcMeas    oranFeatGranularityTransportMeas    oranFeatOverCurrentSupp
@{EAC_IN}    EAC_R-3    EAC_R-5
@{EAC_OUT}    EAC_R-4    EAC_R-6
@{CARRIER_FIRST_TYPE}    RX_PU_L-1/RX_L-8    RX_PU_L-3/RX_L-0    TX_PU_L-1/TX_L-0    TX_PU_L-2/TX_L-1    TX_PU_L-3/TX_L-8    TX_PU_L-4/TX_L-9
@{CARRIER_SECOND_TYPE}    RX_PU_L-1/RX_L-8    RX_PU_L-3/RX_L-9    TX_PU_L-1/TX_L-8    TX_PU_L-2/TX_L-0    TX_PU_L-3/TX_L-9    TX_PU_L-4/TX_L-1
@{LINK_FIRST_TYPE}    RX_PU_L-1/LOW_LEVEL_RX_LINK-8    RX_PU_L-1/LOW_LEVEL_RX_LINK-15    RX_PU_L-3/LOW_LEVEL_RX_LINK-0
...    RX_PU_L-3/LOW_LEVEL_RX_LINK-7    TX_PU_L-1/LOW_LEVEL_TX_LINK-0    TX_PU_L-2/LOW_LEVEL_TX_LINK-1    TX_PU_L-3/LOW_LEVEL_TX_LINK-8
...    TX_PU_L-4/LOW_LEVEL_TX_LINK-9
@{LINK_SECOND_TYPE}    RX_PU_L-1/LOW_LEVEL_RX_LINK-8    RX_PU_L-1/LOW_LEVEL_RX_LINK-12    RX_PU_L-3/LOW_LEVEL_RX_LINK-9
...    RX_PU_L-3/LOW_LEVEL_RX_LINK-13    TX_PU_L-1/LOW_LEVEL_TX_LINK-8    TX_PU_L-2/LOW_LEVEL_TX_LINK-0    TX_PU_L-3/LOW_LEVEL_TX_LINK-9
...    TX_PU_L-4/LOW_LEVEL_TX_LINK-1
@{TRANSCEIVER_PARAMETERS}    port-number    vendor-id    vendor-part    vendor-rev    serial-no    connector-type    interface-name
@{FAN_PARAMETERS}    name    fan-location     present-and-operating    vendor-code
@{HW_PARAMETERS}    model-name     product-code    serial-num    hardware-rev    mfg-name
@{SOFTWARE_PARAMETERS}    build-name    build-version    build-id    vendor-code    active    running
@{TX_ARRAYS}    Tx-Array-0    Tx-Array-1    Tx-Array-2    Tx-Array-3
@{RX_ARRAYS}    Rx-Array-0    Rx-Array-1    Rx-Array-2    Rx-Array-3
@{TX_ENDPOINTS}    Low-Level-Tx-Endpoint-0    Low-Level-Tx-Endpoint-1    Low-Level-Tx-Endpoint-2    Low-Level-Tx-Endpoint-3
@{RX_ENDPOINTS}    Low-Level-Rx-Endpoint-8    Low-Level-Rx-Endpoint-9    Low-Level-Rx-Endpoint-10    Low-Level-Rx-Endpoint-11
@{RX_ENDPOINTS_2}    Low-Level-Rx-Endpoint-0    Low-Level-Rx-Endpoint-1    Low-Level-Rx-Endpoint-2    Low-Level-Rx-Endpoint-3
@{RX_ENDPOINTS_3}    Low-Level-Rx-Endpoint-8    Low-Level-Rx-Endpoint-9    Low-Level-Rx-Endpoint-10    Low-Level-Rx-Endpoint-11
@{LBM_PARAM}    id    name    md-level
@{HW_STATE_PARAM}    admin-state    oper-state    usage-state    availability-state
@{IQ_COMPRESSION_PARAM}    iq-bitwidth    compression-type    exponent
@{RSL_PARAMETERS}=    dcVoltageEnabled    operationalState    availabilityStatus
${WebEM IP}                             https://192.168.255.1:3600
${CUSTOMER_LOGIN}=                      Nemuadmin
${CUSTOMER_PASSWORD}=                   nemuuser
${INPUT_NAME_FIELD}=                    login-username
${INPUT_PASSWORD_FIELD}=                login-password
${LOGIN_BUTTON}=                        //span[contains(text(), 'Login')]
${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
#${CONFIGURATION_TAB}=                   //div[@aria-describedby="admin.navigationBar.configuration.TITLE"]
${NETCONF_RADIO_MANAGEMENT_BUTTON}=     //span[contains(text(),'Netconf Radio Management')]
${CONFIGURE_ADDITIONAL_ACCOUNT_BUTTON}=    //span[contains(text(),'Configure Additional Netconf Account')]
${SEND_BUTTON}=                         //span[contains(text(), 'Send')]
#${CHECKBOX_RMOD_1}=                     //div[@class="ui-chkbox-box ui-widget ui-state-default"]
${CONFIGURE_RADIO_SUCCEEDED}=           //span[contains(text(), 'Configure netconf radio succeeded')]
#${ACCOUNTS_CONFIGURATION}=    //div[contains(text(),'Accounts configuration')]
${PLUS_BUTTON}
...  //button[@class="p-element p-button-secondary p-button-text p-button-sm p-button p-component p-button-icon-only"]
${SPLITTED_LOGS_DEFAULT_ACC}=    /home/supervisord_default_acc.log
${SPLITTED_LOGS_NON_DEFAULT_ACC}=    /home/supervisord_non_default_acc.log
${SPLITTED_TRACES_DEFAULT_ACC}=    /tmp/node_FHNET00/tmp/netconf_default_acc.log
${SPLITTED_TRACES_NON_DEFAULT_ACC}=    /tmp/node_FHNET00/tmp/netconf_non_default_acc.log
${DEFAULT_ACCOUNT_NAME}=                xranuser
${DEFAULT_ACCOUNT_PASS}=                xran-password
${ADDITIONAL_ACCOUNT_NAME}=             xranuser2
${ADDITIONAL_ACCOUNT_PASS}=             Xran-Password11$$
*** Keywords ***
TC4 Preconditions
    Add Additional Netconf Account
    ADMIN Perform Commissioning    bts_id=${mrbts_id}
    ...                            scf_file=${SCF_PATH}/Beamforming_LBM.xml
    Docker Container Setup
    Send Cmd To Docker Shell    supervisorctl stop all
    Copy Snapshot To Container    beamforming_snapshot.xml
    Send Cmd To Docker Shell    oranrestart 1 2

TC3 Preconditions
     ADMIN Perform Commissioning    bts_id=${mrbts_id}
#    ...                            scf_file=/home/ute/Downloads/CB008957.xml
    ...                            scf_file=/home/ute/Downloads/SCF_LTE_FDD.xml
    Docker Container Setup
    Wait Until Mplane Is Connected
    Check If Gnb Is In On Air State And If Cell Is Enabled

Check Close Session Message
    ${close_id}    Check Message Id In Oru
    ...    <close-session
    Should Not Be Empty    ${close_id}
    ${close}    Check Message In Logs On Oru    ${close_id}
    Should Contain     ${close}
    ...    <ok/></rpc-reply>

Check DHCP During Oru Startup
    ${dhcp}    Check Message In Logs On Oru    Got IP Address Lease Time
    ${dhcp}     Replace String Using Regexp     ${dhcp}    \x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])    ${EMPTY}
    Should Contain    ${dhcp}    Got IP Address Lease Time    : 360
    ${ip}    Check Message In Logs On Oru    Got ipv4 O-RU from O-DU
    Should Contain    ${ip}    Got ipv4 O-RU from O-DU      : 172.22.56.2
    ${vlan}    Check Message In Logs On Oru    /etc/opt/vlan-id.txt

Check Starts Synchronization Of The Oru Against A Primary Reference Clock
    ${sync}    Check Message In Logs On Oru    becomes the PARENT Synchronization source of O-RU
    ${sync_synce_parent}    Run Keyword And Return Status    Should Contain    ${sync}
    ...    SYNCE becomes the PARENT Synchronization source of O-RU
    ${sync_ptp_parent}    Run Keyword And Return Status    Should Contain     ${sync}
    ...    PTP becomes the PARENT Synchronization source of O-RU
    Run Keyword If    ${sync_synce_parent}    Log To Console    SYNCE is PARENT Synchronization source
    Run Keyword If    ${sync_ptp_parent}    Log To Console    PTP is PARENT Synchronization source

Check Call Home To Gnb
    ${call_home}    Check Message In Logs On Oru    Call Home
    ${call_home}     Replace String Using Regexp     ${call_home}    \x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])    ${EMPTY}
    Should Contain    ${call_home}    Call Home client "NC-Client-1" endpoint "default-ssh" connecting...
    Should Contain    ${call_home}    Call Home client "NC-Client-1" session 1 established

Check Call Home To Gnb With Non Default Account
    ${call_home}    Check Message In Logs On Oru    Call Home
    ${call_home}     Replace String Using Regexp     ${call_home}    \x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])    ${EMPTY}
    Should Contain    ${call_home}    Call Home client "NC-Client-1" session 2 established

Check Hello Message During Startup
    ${hello}    Check Message In Logs On Oru    <hello
    ${hello}     Replace String Using Regexp     ${hello}    \x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])    ${EMPTY}
    FOR    ${capability}    IN    @{ORU_CAPABILITES}
        Should Contain    ${hello}    capability:${capability}
    END

Check Get Message For Optional Modules
    ${opt_modules_id}    Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><modules-state xmlns
    Should Not Be Empty    ${opt_modules_id}
    ${opt_modules}    Check Message In Netconf Trace File    ${opt_modules_id}
    Should Contain    ${opt_modules}    <data><modules-state xmlns="urn:ietf:params:xml:ns:yang:ietf-yang-library">
    FOR    ${module}    IN    @{OPT_MODULES_AND_FEATURES_IN_RU_L}
        Should Contain    ${opt_modules}    ${module}
    END

Check Ssh Connection To Oru
    ${ssh}    Check Message In Logs On Oru    xranuser
    ${ssh}     Replace String Using Regexp     ${ssh}    \x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])    ${EMPTY}
    Should Contain    ${ssh}    User "xranuser" authenticated
    Should Contain    ${ssh}    username xranuser connected

Check Ssh Connection To Oru With Non Default Account
    ${ssh}    Check Message In Logs On Oru    xranuser2
    ${ssh}     Replace String Using Regexp     ${ssh}    \x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])    ${EMPTY}
    Should Contain    ${ssh}    User "xranuser2" authenticated
    Should Contain    ${ssh}    username xranuser2 connected

Check Create Subscription Message
    ${subscription}    Check Message In Netconf Trace File    <create-subscription xmlns=
    Should Contain    ${subscription}
    ...    <create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>NETCONF</stream></create-subscription></rpc>

Check Start Supervision Of M-Plane Connection
    ${supervision_id}    Check Message Id In Oru    <supervision-watchdog-reset
    Should Not Be Empty    ${supervision_id}
    ${supervision}    Check Message In Logs On Oru    ${supervision_id}
    ${supervision}     Replace String Using Regexp     ${supervision}    \x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])    ${EMPTY}
    Should Contain     ${supervision}
    ...    <supervision-notification-interval>60</supervision-notification-interval><guard-timer-overhead>10</guard-timer-overhead>
    Should Contain     ${supervision}    <next-update-at xmlns="urn:o-ran:supervision:1.0">
    ${supervision_id}    Fetch From Right    ${supervision_id}    "
    Set Test Variable    ${SUPERVISION_ID}    ${supervision_id}

Check Beamforming Message
    ${beamforming_namespace}    Check Message In Netconf Trace File    o-ran:beamforming
    Should Contain    ${beamforming_namespace}    <namespace>urn:o-ran:beamforming:1.0</namespace>
    ${beamforming_id}    Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><beamforming-config
    Should Not Be Empty    ${beamforming_id}
    ${beamforming}    Check Message In Netconf Trace File    ${beamforming_id}
    Should Contain     ${beamforming}
    ...    <data><beamforming-config xmlns="urn:o-ran:beamforming:1.0"><per-band-config><band-number>78</band-number>
    FOR    ${beam}    IN    @{BEAMS_ID}
        Should Contain    ${beamforming}    ${beam}
    END

Check Carrier Configuration Messages
    ${output}    Check Message Id In Oru    edit-config.*create
    ${output}    Fetch From Right    ${output}    "
    FOR    ${index}    IN RANGE    0    10
        ${message_id}    Evaluate    ${output}+${index}
        ${message_id}    Set Variable    message-id="${message_id}"
        ${message_output}    Check Message In Logs On Oru   ${message_id}
        Should Contain    ${message_output}    
		...		<edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/></target><config><user-plane-configuration
        Should Contain    ${message_output}    <ok/></rpc-reply>
    END
    ${message}    Check Message In Logs On Oru    edit-config.*create
    FOR    ${carrier}    IN    @{CARRIER_NAME}
        Should Contain    ${message}    ${carrier}
    END
    Should Contain    ${message}    ${PROC_ELEM}
    FOR    ${link}    IN    @{LINK_NAME}
        Should Contain    ${message}    ${link}
    END
    FOR    ${endpoint}    IN    @{ENDPOINT_NAME}
        Should Contain    ${message}    ${endpoint}
    END

Check Externalio Message
    ${externalio_namespace}    Check Message In Netconf Trace File    o-ran:external-io
    Should Contain    ${externalio_namespace}    <namespace>urn:o-ran:external-io:1.0</namespace>
    ${externalio_id}    Check Message Id In Oru
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><external-io xmlns="urn:o-ran:external-io
    Should Not Be Empty    ${externalio_id}
    ${externalio}    Check Message In Logs On Oru    ${externalio_id}
    Should Contain     ${externalio}
    ...    <data><external-io xmlns="urn:o-ran:external-io:1.0">
    Should Contain    ${externalio}
    ...    <input><name>External-Input-1</name><port-in>1</port-in><line-in>true</line-in></input>
    Should Contain    ${externalio}
    ...    <input><name>External-Input-2</name><port-in>2</port-in><line-in>true</line-in></input>
    Should Contain    ${externalio}
    ...    <output><name>External-Output-1</name><port-out>1</port-out></output>
    Should Contain    ${externalio}
    ...    <output><name>External-Output-2</name><port-out>2</port-out>

Check Ald Message
    ${ald_namespace}    Check Message In Netconf Trace File    o-ran:ald-port
    Should Contain    ${ald_namespace}    <namespace>urn:o-ran:ald-port:1.0</namespace>
    ${ald_namespace}    Check Message In Netconf Trace File    o-ran:ald
    Should Contain    ${ald_namespace}    <namespace>urn:o-ran:ald:1.0</namespace>
    ${ald_id}    Check Message Id In Oru
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><ald-ports-io xmlns= "urn:o-ran:ald-port
    Should Not Be Empty    ${ald_id}
    ${ald}    Check Message In Logs On Oru    ${ald_id}
    Should Contain     ${ald}
    ...    <data><ald-ports-io xmlns="urn:o-ran:ald-port:1.0">
    Should Contain    ${ald}
    ...    Ald-Port-0</name><port-id>0</port-id><dc-control-support>true</dc-control-support><dc-enabled-status>false</dc-enabled-status><supported-
#    Should Contain    ${ald}
#    ...    Ald-Port-1</name><port-id>1</port-id><dc-control-support>true</dc-control-support><dc-enabled-status>false</dc-enabled-status><supported-

Check Alarm List Message
    ${fm_id}    Check Message Id In Oru
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><active-alarm-list xmlns="urn:o-ran:fm
    ...    tail -1
    Should Not Be Empty    ${fm_id}
    ${fm}    Check Message In Logs On Oru    ${fm_id}
    Should Contain     ${fm}
    ...    <data/></rpc-reply>
    ${fm_id}    Fetch From Right    ${fm_id}    "
    ${result}    Evaluate    ${fm_id} > ${SUPERVISION_ID}
    Run Keyword If    '${result}' == 'False'    Fail    The M-Plane connection was not established before receiving the active alarm list

Check Synce Configuration Message
    ${synce_id}    Check Message Id In Oru
#    ...    <synce-config nc:operation="replace">
    ...    <synce-config><acceptance-list-of-ssm>
    Should Not Be Empty    ${synce_id}
    ${synce}    Check Message In Logs On Oru    ${synce_id}
    Should Contain     ${synce}
    ...    <edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/>
    Should Contain     ${synce}
    ...    <ok/></rpc-reply>

Check Ptp Configuration Message
    ${ptp_id}    Check Message Id In Oru
#    ...    <ptp-config nc:operation="replace">
    ...    <ptp-config><domain-number>
    Should Not Be Empty    ${ptp_id}
    ${ptp}    Check Message In Logs On Oru    ${ptp_id}
    Should Contain     ${ptp}
    ...    <edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/>
    Should Contain     ${ptp}
    ...    <ok/></rpc-reply>

Check Fan Message
    ${fan_namespace}    Check Message In Netconf Trace File    o-ran:fan
    Should Contain    ${fan_namespace}    <namespace>urn:o-ran:fan:1.0</namespace>
    ${fan_id}    Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><fan-tray
    ...    tail -n 1
    Should Not Be Empty    ${fan_id}
    ${fan}    Check Message In Logs On Oru    ${fan_id}
    Should Contain     ${fan}
    ...    <data><fan-tray xmlns="urn:o-ran:fan:1.0"><fan-state>
    @{fan_param}    Create List
    FOR    ${parameter}    IN    @{FAN_PARAMETERS}
        ${output}    Get Parameter Value From Message With The Following Id    ${parameter}    ${fan_id}
        Append To List    ${fan_param}    ${output}
    END
    Set Test Variable    ${FAN_PARAM}    ${fan_param}

Check Port Transceiver Message
    ${transceiver_id}    Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><port-transceivers
    ...    tail -n 1
    Should Not Be Empty    ${transceiver_id}
    ${transceiver}    Check Message In Logs On Oru    ${transceiver_id}
    Should Contain     ${transceiver}
    ...    <port-transceivers xmlns="urn:o-ran:transceiver:1.0">
    @{sfp_1_param}    Create List
    @{sfp_2_param}    Create List
    FOR    ${parameter}    IN    @{TRANSCEIVER_PARAMETERS}
        ${output}    Get First Parameter Value From Message With The Following Id    ${parameter}    ${transceiver_id}
        Append To List    ${sfp_1_param}    ${output}
    END
    Set Test Variable    ${SFP_1_PARAM}    ${sfp_1_param}
    FOR    ${parameter}    IN    @{TRANSCEIVER_PARAMETERS}
        ${output}    Get Parameter Value From Message With The Following Id    ${parameter}    ${transceiver_id}
        Append To List    ${sfp_2_param}    ${output}
    END
    Set Test Variable    ${SFP_2_PARAM}    ${sfp_2_param}

Check Iq Compression Message
    ${iq_compression_id}    Check Message Id
    ...    <ru-capabilities><min-power-per-pa-antenna/><max-power-per-pa-antenna/><format-of-iq-sample><compression-method-supported/>
    Should Not Be Empty    ${iq_compression_id}
    ${iq_compression}    Check Message In Netconf Trace File    ${iq_compression_id}
    Should Contain    ${iq_compression}
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><module-capability xmlns="urn:o-ran:module-cap
    Should Contain    ${iq_compression}     <data><module-capability xmlns="urn:o-ran:module-cap:1.0"><ru-capabilities>
    FOR    ${param}    IN    @{IQ_COMPRESSION_PARAM}
        Should Contain    ${iq_compression}    ${param}
    END

Check Software Slots Message
    ${software_id}    Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><software-inventory
    ...    tail -n 1
    Should Not Be Empty    ${software_id}
    ${software}    Check Message In Logs On Oru    ${software_id}
    Should Contain     ${software}
    ...    <data><software-inventory xmlns="urn:o-ran:software-management:1.0"><software-slot>
    @{software_param}    Create List
    FOR    ${parameter}    IN    @{SOFTWARE_PARAMETERS}
        ${output}    Get First Parameter Value From Message With The Following Id    ${parameter}    ${software_id}
        Append To List    ${software_param}    ${output}
    END
    Set Test Variable    ${SOFTWARE_PARAM}    ${software_param}

Check Tx Arrays Message
    ${tx_array_id}    Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><t
    ...    tail -n 1
    Should Not Be Empty    ${tx_array_id}
    ${tx_array}    Check Message In Netconf Trace File    ${tx_array_id}
    Should Contain     ${tx_array}
    ...    <data><user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><tx-arrays>
    FOR    ${array}    IN    @{TX_ARRAYS}
        Should Contain    ${tx_array}    ${array}
    END

Check Rx Arrays Message
    ${rx_array_id}    Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><r
    ...    tail -n 1
    Should Not Be Empty    ${rx_array_id}
    ${rx_array}    Check Message In Netconf Trace File    ${rx_array_id}
    Should Contain     ${rx_array}
    ...    <data><user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><rx-arrays>
    FOR    ${array}    IN    @{RX_ARRAYS}
        Should Contain    ${rx_array}    ${array}
    END

Check Tx Endpoints Message
    ${tx_endpoint_id}    Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><s
    ...    tail -n 1
    Should Not Be Empty    ${tx_endpoint_id}
    ${tx_endpoint}    Check Message In Netconf Trace File    ${tx_endpoint_id}
    Should Contain     ${tx_endpoint}
    ...    <data><user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><static-low-level-tx-endpoints>
    FOR    ${endpoint}    IN    @{TX_ENDPOINTS}
        Should Contain    ${tx_endpoint}    ${endpoint}
    END

Check Rx Endpoints Message
    ${rx_endpoint_id}    Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><s
    ...    tail -n 1
    Should Not Be Empty    ${rx_endpoint_id}
    ${rx_endpoint}    Check Message In Netconf Trace File    ${rx_endpoint_id}
    Should Contain     ${rx_endpoint}
    ...    <data><user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><static-low-level-rx-endpoints>
    FOR    ${endpoint}    IN    @{RX_ENDPOINTS}
        Should Contain    ${rx_endpoint}    ${endpoint}
    END

Check Restart Cause Message
    ${restart_id}    Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><operational-info xmlns="urn:o-ran:operations:1.0"><operation
    ...    tail -n 1
    Should Not Be Empty    ${restart_id}
    ${restart}    Check Message In Netconf Trace File    ${restart_id}
    Should Contain     ${restart}
    ...    <operational-info xmlns="urn:o-ran:operations:1.0"><operational-state><restart-cause>
    ${restart_cause}    Get Parameter Value From Message With The Following Id    restart-cause    ${restart_id}
    Set Test Variable    ${RESTART_CAUSE}    ${restart_cause}

Check Mplane Vlan Message
    ${mplane_id}    Check Message Id
    ...    <mplane-info xmlns="urn:o-ran:mplane-interfaces:1.0"><searchable-mplane-access-vlans-info>
    ...    tail -n 1
    Should Not Be Empty    ${mplane_id}
    ${mplane}    Check Message In Netconf Trace File    ${mplane_id}
    Should Contain     ${mplane}
    ...    <ok/></rpc-reply>
    Should Contain     ${mplane}
    ...    <edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/>
    ${mplane_vlan}    Get Parameter Value From Message With The Following Id    searchable-access-vlans    ${mplane_id}
    Set Test Variable    ${MPLANE_VLAN}    ${mplane_vlan}

Check Cplane Vlan Message
    ${cplane_id}    Check Message Id
    ...    xmlns:o-ran-int="urn:o-ran:interfaces:1.0" xmlns:ianaift="urn:ietf:params:xml:ns:yang:iana-if-type"><if:interface><if:name>vlan
    ...    tail -n 1
    Should Not Be Empty    ${cplane_id}
    ${cplane}    Check Message In Netconf Trace File    ${cplane_id}
    Should Contain     ${cplane}
    ...    <ok/></rpc-reply>
    Should Contain     ${cplane}
    ...    <edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/></target><config><if:interfaces xmlns:if="urn:ietf:params:
    ${cplane_vlan}    Get Parameter Value From Message With The Following Id    o-ran-int:vlan-id    ${cplane_id}
    Set Test Variable    ${CPLANE_VLAN}    ${cplane_vlan}
    ${transceiver}    Get Parameter Value From Message With The Following Id    o-ran-int:base-interface    ${cplane_id}
    Should Be Equal As Strings    ${transceiver}    @{SFP_1_PARAM}[6]

Check Processing Element Configuration Message
    ${proc_elem_id}    Check Message Id
    ...    <processing-elements xmlns="urn:o-ran:processing-element:1.0" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" nc:operation="merge">
    ...    tail -n 1
    Should Not Be Empty    ${proc_elem_id}
    ${proc_elem}    Check Message In Netconf Trace File    ${proc_elem_id}
    Should Contain     ${proc_elem}
    ...    <ok/></rpc-reply>
    Should Contain     ${proc_elem}
    ...    <edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/>
    ${proc_element}    Get Parameter Value From Message With The Following Id    name    ${proc_elem_id}
    Set Test Variable    ${PROC_ELEM}    ${proc_element}
    ${proc_elem_id}    Fetch From Right    ${proc_elem_id}    "
    Set Test Variable    ${PROC_ELEM_ID}    ${proc_elem_id}

Check LBM Message
    ${lbm_id}    Check Message Id
    ...    <md-data-definitions xmlns="urn:o-ran:lbm:1.0" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
    ...    tail -n 1
    Should Not Be Empty    ${lbm_id}
    ${lbm}    Check Message In Netconf Trace File    ${lbm_id}
    Should Contain     ${lbm}
    ...    <ok/></rpc-reply>
    Should Contain     ${lbm}
    ...    <edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/>
    @{lbm_parameters}    Create List
    FOR    ${param}    IN    @{LBM_PARAM}
        ${output}    Get Parameter Value From Message With The Following Id    ${param}    ${lbm_id}
        Append To List    ${lbm_parameters}    ${output}
    END
    Set Test Variable    ${LBM_PARAMETERS}    ${lbm_parameters}
    ${lbm_id}    Fetch From Right    ${lbm_id}    "
    ${result}    Evaluate    ${lbm_id} > ${PROC_ELEM_ID}
    Run Keyword If    '${result}' == 'False'    Fail    The LBM configuration message was sent before the processing-element configuration

Check Hardware States Message
    ${hw_state_id}    Check Message Id
    ...    <hardware xmlns="urn:ietf:params:xml:ns:yang:ietf-hardware" xmlns:o-ran-hw="urn:o-ran:hardware:1.0"><component><class>o-ran-hw:O-RAN-RADIO
    ...    tail -n 1
    Should Not Be Empty    ${hw_state_id}
    ${hw_state}    Check Message In Netconf Trace File    ${hw_state_id}
    Should Contain     ${hw_state}
    ...    <data><hardware xmlns="urn:ietf:params:xml:ns:yang:ietf-hardware">
    Should Contain     ${hw_state}
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><hardware
    @{hw_states}    Create List
    FOR    ${param}    IN    @{HW_STATE_PARAM}

        ${output}    Run Keyword If    '${param}' == 'availability-state'    Get First Parameter Value From Message With The Following Id
                                                                            ...    ${param} xmlns="urn:o-ran:hardware:1.0"
                                                                            ...    ${hw_state_id}
                                                                            ...    ${param}
        ...    ELSE    Get Parameter Value From Message With The Following Id    ${param}    ${hw_state_id}
        Append To List    ${hw_states}    ${output}
    END
    Set Test Variable    ${HW_STATES}    ${hw_states}

Check Sync Status Message
    ${sync_id}    Check Message Id
    ...    <filter type="subtree"><sync xmlns="urn:o-ran:sync:1.0"><sync-status>
    ...    tail -n 1
    Should Not Be Empty    ${sync_id}
    ${sync}    Check Message In Netconf Trace File    ${sync_id}
    Should Contain     ${sync}
    ...    <data><sync xmlns="urn:o-ran:sync:1.0"><sync-status>
    Should Contain     ${sync}
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><sync
    ${sync_status}    Get Parameter Value From Message With The Following Id    sync-state    ${sync_id}
    Set Test Variable    ${SYNC_STATUS}    ${sync_status}
    ${sync_id}    Fetch From Right    ${sync_id}    "
    Set Test Variable    ${SYNC_ID}    ${sync_id}

Check Ptp Status Message
    ${ptp_id}    Check Message Id
    ...    <filter type="subtree"><sync xmlns="urn:o-ran:sync:1.0"><ptp-status>
    ...    tail -n 1
    Should Not Be Empty    ${ptp_id}
    ${ptp}    Check Message In Netconf Trace File    ${ptp_id}
    Should Contain     ${ptp}
    ...    <data><sync xmlns="urn:o-ran:sync:1.0"><ptp-status>
    Should Contain     ${ptp}
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><sync
    ${ptp_status}    Get Parameter Value From Message With The Following Id    lock-state    ${ptp_id}
    Set Test Variable    ${PTP_STATUS}    ${ptp_status}

Check SyncE Status Message
    ${synce_id}    Check Message Id
    ...    <filter type="subtree"><sync xmlns="urn:o-ran:sync:1.0"><synce-status>
    ...    tail -n 1
    Should Not Be Empty    ${synce_id}
    ${synce}    Check Message In Netconf Trace File    ${synce_id}
    Should Contain     ${synce}
    ...    <data><sync xmlns="urn:o-ran:sync:1.0"><synce-status>
    Should Contain     ${synce}
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><sync
    ${synce_status}    Get Parameter Value From Message With The Following Id    lock-state    ${synce_id}
    Set Test Variable    ${SYNCE_STATUS}    ${synce_status}

Check Iq Compression Parameter
    [Arguments]    ${parameter}=supportOfIqCompression
    ...            ${distname}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RMOD_BP_L-1
    ${state}    Get Parameters    ${parameter}    ${distname}
    Should Be Equal As Strings    ${state['${parameter}']}    ['ECPRI_IQ_14']

Check Iq Compression Parameter LTE
    [Arguments]    ${parameter}=iqCompression
    ...            ${distname}=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/HWTOP_R-1/CABLINK_R-1001
    ${state}    Get Parameters    ${parameter}    ${distname}
    Should Be Equal As Strings    ${state['${parameter}']}    eCPRI IQ14

Check Carrier Activation Message
    ${carrier_id}    Check Message Id
    ...    <user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0"><tx-array-carriers>
    ...    tail -n 1
    Should Not Be Empty    ${carrier_id}
    ${carrier_activation}    Check Message In Netconf Trace File    ${carrier_id}
    Should Contain     ${carrier_activation}
    ...    <ok/></rpc-reply>
    Should Contain     ${carrier_activation}
    ...    <edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/></target><config><user-plane-configuration
    FOR    ${carrier}    IN    @{CARRIER_NAME}
        Should Contain    ${carrier_activation}    ${carrier}
    END
    ${carrier_id}    Fetch From Right    ${carrier_id}    "
    Run Keyword If    ${carrier_id} > ${SYNC_ID}    Should Be Equal As Strings    LOCKED    ${SYNC_STATUS}
    ...    ELSE    Fail    sync-state = LOCKED message was not sent before activating carrier

Check Sync Status In WebEM
    [Arguments]    ${clock_path}=${MRBTS_PATH}/MNL_CONF_M-1/MNLENT_CONF_M-1/SYNC_CONF_M-2/CLOCK_CONF_M-1/CLOCK_R-1
    ...    ${topp_path}=${MRBTS_PATH}/MNL_CONF_M-1/MNLENT_CONF_M-1/SYNC_CONF_M-2/CLOCK_CONF_M-1/TOP_CONF_M-1/TOPP_CONF_M-1/TOPP_R-1
    ...    ${synce_path}=${MRBTS_PATH}/MNL_CONF_M-1/MNLENT_CONF_M-1/SYNC_CONF_M-2/CLOCK_CONF_M-1/SYNCE_CONF_M-1/SYNCE_R-1
    ${clock_info}    Get Parameters    .*    ${clock_path}
    Should Be Equal As Strings    ${clock_info['syncStatus']}    ${SYNC_STATUS}    ignore_case=True
    ${topp_info}    Get Parameters    .*    ${topp_path}
    Should Be Equal As Strings    ${topp_info['lockState']}    ${PTP_STATUS}    ignore_case=True
    ${synce_info}    Get Parameters    .*    ${synce_path}
    Should Be Equal As Strings    ${synce_info['lockState']}    ${SYNCE_STATUS}    ignore_case=True

Check Hardware State In WebEM
    [Arguments]    ${rmod_r_path}=${EQM_PATH}/APEQM_R-1/RMOD_R-1
    ${rmod_param}    Get Parameters    .*    ${rmod_r_path}
    Should Be Equal As Strings    ${rmod_param['administrativeState']}    @{HW_STATES}[0]    ignore_case=True
    Should Be Equal As Strings    ${rmod_param['operationalState']}    @{HW_STATES}[1]    ignore_case=True
    Should Be Equal As Strings    ${rmod_param['usageState']}    @{HW_STATES}[2]    ignore_case=True
    Run Keyword If    '@{HW_STATES}[3]' == 'NORMAL'
    ...    Should Be Equal As Strings    ${rmod_param['availabilityStatus']}    None
    ...    ELSE    Fail    availabilityStatus != NORMAL

Check LBM In WebEM
    [Arguments]    ${oammd_path}=${BTS_L_PATH}/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-1/TNLSVC_A-1/TNL_A-2/ETHAPP_A-1/OAMMD_A-1
    ${oammd_info}    Get Parameters    .*    ${oammd_path}
    Should Be Equal As Integers    1    @{LBM_PARAMETERS}[0]
    Should Be Equal As Strings    ${oammd_info['mdName']}    @{LBM_PARAMETERS}[1]
    Should Be Equal As Integers   ${oammd_info['mdLevel']}    @{LBM_PARAMETERS}[2]

Check Processing Element In WebEM
    [Arguments]    ${proc_element_path}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/PROCESSING_ELEMENT-1
    ${proc_element_param}    Get Parameters    .*    ${proc_element_path}
    Should Be Equal As Strings    ${proc_element_param['processingElementName']}    ${PROC_ELEM}

Check Cplane Vlan In WebEM
    [Arguments]    ${proc_element_path}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/PROCESSING_ELEMENT-1
    ${proc_element_param}    Get Parameters    .*    ${proc_element_path}
    Should Be Equal As Integers    ${proc_element_param['vlanId']}    ${CPLANE_VLAN}

Get Connector Path
    [Arguments]    ${connector_path}
    FOR    ${index}    IN RANGE    1    100
        ${final_path}=    Catenate    SEPARATOR=    ${connector_path}    ${index}
        ${connector_params}=    taf.sbts.oam.coam.admin.Get Parameters    ${final_path}/REF-1    alias=${ADMIN_ALIAS}
        ${passed}=    Run Keyword And Return Status    Should Contain    ${connector_params['distName']}    CONNECTOR_L-1
        Run Keyword If    ${passed}    Exit For Loop
    END
    [Return]    ${final_path}

Check Mplane Vlan In WebEM
    ${connector_path}=    Get Connector Path    ${EQM_PATH}/APEQM_R-1/CABINET_R-1/BBMOD_R-1/CONNECTOR_R-
    ${connector_ref_param}    Get Parameters    .*    ${connector_path}/REF-1
    ${path}    Set Variable    ${connector_ref_param['distName']}
    ${vlan_info}    Get Parameters    .*    ${path}
    Should Be Equal As Strings    ${vlan_info['vlanIds'][0]}    ${MPLANE_VLAN}

Check Restart Cause In WebEM
    [Arguments]    ${rmod_r_path}=${EQM_PATH}/APEQM_R-1/RMOD_R-1
    ${rmod_param}    Get Parameters    .*    ${rmod_r_path}
    ${RESTART_CAUSE}    Replace String    ${RESTART_CAUSE}    -    _
    Should Be Equal As Strings    ${rmod_param['restartCause']}    ${RESTART_CAUSE}

Check Tx Endpoints In WebEM
    [Arguments]    ${low_level_endpoint_1_path}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/LOW_LEVEL_ENDPOINT_TYPE-1
    FOR    ${index}    IN RANGE    0    4
        ${endpoints_info}    Get Parameters    .*    ${low_level_endpoint_1_path}
        ${endpoint}    Set Variable    ${endpoints_info['endpoints'][${index}]}
        List Should Contain Value    ${TX_ENDPOINTS}    ${endpoint}
        Remove Values From List    ${TX_ENDPOINTS}    ${endpoint}
    END
    Should Be Empty    ${TX_ENDPOINTS}

Check Rx Endpoints In WebEM
    [Arguments]    ${low_level_endpoint_2_path}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/LOW_LEVEL_ENDPOINT_TYPE-2
    ...            ${low_level_endpoint_3_path}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/LOW_LEVEL_ENDPOINT_TYPE-3
    FOR    ${index}    IN RANGE    0    4
        ${endpoints_info}    Get Parameters    .*    ${low_level_endpoint_2_path}
        ${endpoint}    Set Variable    ${endpoints_info['endpoints'][${index}]}
        List Should Contain Value    ${RX_ENDPOINTS_2}    ${endpoint}
        Remove Values From List    ${RX_ENDPOINTS_2}    ${endpoint}
    END
    Should Be Empty    ${RX_ENDPOINTS_2}
    FOR    ${index}    IN RANGE    0    4
        ${endpoints_info}    Get Parameters    .*    ${low_level_endpoint_3_path}
        ${endpoint}    Set Variable    ${endpoints_info['endpoints'][${index}]}
        List Should Contain Value    ${RX_ENDPOINTS_3}    ${endpoint}
        Remove Values From List    ${RX_ENDPOINTS_3}    ${endpoint}
    END
    Should Be Empty    ${RX_ENDPOINTS_3}

Check Rx Arrays Object
    [Arguments]    ${rx_arrays_path}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/RX_PU_L-
    FOR    ${index}    IN RANGE    1    5
        ${rx_arrays_info}    Get Parameters    .*    ${rx_arrays_path}${index}
        ${array}    Set Variable    ${rx_arrays_info['rp1Name']}
        List Should Contain Value    ${RX_ARRAYS}    ${array}
        Remove Values From List    ${RX_ARRAYS}    ${array}
    END
    Should Be Empty    ${RX_ARRAYS}

Check Tx Arrays Object
    [Arguments]    ${tx_arrays_path}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/TX_PU_L-
    FOR    ${index}    IN RANGE    1    5
        ${tx_arrays_info}    Get Parameters    .*    ${tx_arrays_path}${index}
        ${array}    Set Variable    ${tx_arrays_info['rp1Name']}
        List Should Contain Value    ${TX_ARRAYS}    ${array}
        Remove Values From List    ${TX_ARRAYS}    ${array}
    END
    Should Be Empty    ${TX_ARRAYS}

Check Software Parameters In WebEM
    [Arguments]    ${rmod_r_path}=${EQM_PATH}/APEQM_R-1/RMOD_R-1
    ${sw_info}    Get Parameters    .*    ${rmod_r_path}
    Run Keyword If    '@{SOFTWARE_PARAM}[5]' == 'true'    Run Keywords
    ...    Should Be Equal As Strings    ${sw_info['runningSwVersion']}    @{SOFTWARE_PARAM}[0]_@{SOFTWARE_PARAM}[1]    AND
    ...    Should Be Equal As Strings    ${sw_info['runningSwBuild']}    @{SOFTWARE_PARAM}[2]
    Run Keyword If    '@{SOFTWARE_PARAM}[4]' == 'true'    Run Keywords
    ...    Should Be Equal As Strings    ${sw_info['activeSwVersion']}    @{SOFTWARE_PARAM}[0]_@{SOFTWARE_PARAM}[1]    AND
    ...    Should Be Equal As Strings    ${sw_info['activeSwBuild']}    @{SOFTWARE_PARAM}[2]
    Should Be Equal As Strings    ${sw_info['vendorCode']}    @{SOFTWARE_PARAM}[3]

Check Parameters Under SFP_R Object
    [Arguments]    ${sfp_r_1_path}=${EQM_PATH}/APEQM_R-1/RMOD_R-1/SFP_R-1
    ...            ${sfp_r_2_path}=${EQM_PATH}/APEQM_R-1/RMOD_R-1/SFP_R-2
    ${sfp_info}    Get Parameters    .*    ${sfp_r_1_path}
    ${physical_port_1}    Evaluate    @{SFP_1_PARAM}[0]+1
    Should Be Equal As Strings    ${sfp_info['physicalPort']}    OPT_IF${physical_port_1}
    Should Be Equal As Strings    ${sfp_info['vendorName']}    @{SFP_1_PARAM}[1]
    Should Be Equal As Strings    ${sfp_info['vendorPartNumber']}    @{SFP_1_PARAM}[2]
    Should Be Equal As Strings    ${sfp_info['vendorRevision']}    @{SFP_1_PARAM}[3]
    Should Be Equal As Strings    ${sfp_info['serialNumber']}    @{SFP_1_PARAM}[4]
    ${connector_type}    Replace String    @{SFP_1_PARAM}[5]    -    _
    ${connector_type}    Replace String		@{SFP_1_PARAM}[5]	lucent-connector	LC
    Should Be Equal As Strings    ${sfp_info['connectorType']}    ${connector_type}    ignore_case=True
    #${physical_port_2}    Evaluate    @{SFP_2_PARAM}[0]+1
    #${sfp_info}    Get Parameters    .*    ${sfp_r_2_path}
    #Should Be Equal As Strings    ${sfp_info['physicalPort']}    OPT_IF${physical_port_2}
    #Should Be Equal As Strings    ${sfp_info['vendorName']}    @{SFP_2_PARAM}[1]
    #Should Be Equal As Strings    ${sfp_info['vendorPartNumber']}    @{SFP_2_PARAM}[2]
    #Should Be Equal As Strings    ${sfp_info['vendorRevision']}    @{SFP_2_PARAM}[3]
    #Should Be Equal As Strings    ${sfp_info['serialNumber']}    @{SFP_2_PARAM}[4]
    #${connector_type}    Replace String    @{SFP_2_PARAM}[5]    -    _
	#${connector_type}    Replace String		lucent_connector	LC
    #Should Be Equal As Strings    ${sfp_info['connectorType']}    ${connector_type}    ignore_case=True

Check Fan
    Check Parameters Under FAN_R Object
    ${rmod_fan_invunit_path}=    Get Invunit Path Belonging To Rmod    FAN    ${MRBTS_PATH}/HW_R-1/INVUNIT_R-
    Check Fan Under INVUNIT Object    ${rmod_fan_invunit_path}

Check Parameters Under FAN_R Object
    [Arguments]    ${fan_r_path}=${EQM_PATH}/APEQM_R-1/RMOD_R-1/FAN_R-1
    ${fan_info}    Get Parameters    .*    ${fan_r_path}
    Should Be Equal As Strings    ${fan_info['fanName']}    @{FAN_PARAM}[0]
    Should Be Equal As Integers    ${fan_info['fanLocation']}    @{FAN_PARAM}[1]
    Should Be Equal As Strings    ${fan_info['fanPresent']}    @{FAN_PARAM}[2]    ignore_case=True
    Run Keyword If    '@{FAN_PARAM}[2]' == 'true'    Run Keywords
    ...    Should Be Equal As Strings    ${fan_info['operationalState']}    enabled    AND
    ...    Should Be Equal As Strings    ${fan_info['availabilityStatus']}    None

Check Fan Under INVUNIT Object
    [Arguments]    ${invunit_path}
    ${fan_info}    Get Parameters    .*    ${invunit_path}
    Should Be Equal As Integers    ${fan_info['unitPosition']}    @{FAN_PARAM}[1]
    Should Be Equal As Integers    ${fan_info['vendorName']}    @{FAN_PARAM}[3]

Get Invunit Path Belonging To Rmod
    [Arguments]    ${type}    ${inv_path}
    FOR    ${index}    IN RANGE    1    100
        ${final_path}=    Catenate    SEPARATOR=    ${inv_path}    ${index}
        &{invunit_params}=    taf.sbts.oam.coam.admin.Get Parameters    ${final_path}    alias=${ADMIN_ALIAS}
        ${passed}=    Run Keyword And Return Status    Assert Invunit Type Is Correct And RuntimeDN Contains Rmod
                                                        ...    type=${type}
                                                        ...    parameters=${invunit_params}
        Run Keyword If    ${passed}    Exit For Loop
    END
    [Return]    ${final_path}

Assert Invunit Type Is Correct And RuntimeDN Contains Rmod
    [Arguments]    ${type}    ${parameters}
    ${inv_type}=    Get From Dictionary    dictionary=${parameters}    key=inventoryUnitType
    ${runtime_dn}=    Get From Dictionary    dictionary=${parameters}    key=runtimeDN
    Should Match Regexp       ${inv_type}    ${type}
    Should Contain    ${runtime_dn}    RMOD

Check Carrier Status
    ${state}    Check Array Carriers In Netconf Traces
    @{objects}=    Run Keyword If    '${state}' == 'True'    Set Variable    ${CARRIER_SECOND_TYPE}
    ...    ELSE    Set Variable    ${CARRIER_FIRST_TYPE}
    @{carrier_name}    Create List
    FOR    ${carrier}    IN    @{objects}
            ${carrier_info}    Get Parameters    .*    ${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/${carrier}
            Should Be Equal As Strings    ${carrier_info['stateInfo']['availabilityStatus']}    Online
            Should Be Equal As Strings    ${carrier_info['stateInfo']['proceduralState']}    carrierActivated
            ${status}    Run Keyword And Return Status    Should Contain    ${carrier}    RX
            Run Keyword If    ${status}    Append To List    ${carrier_name}    ${carrier_info['ecpriRxArrayCarrier']['rxArrayCarrierName']}
            ...    ELSE    Append To List    ${carrier_name}    ${carrier_info['ecpriTxArrayCarrier']['txArrayCarrierName']}
    END
    Set Test Variable    ${CARRIER_NAME}    ${carrier_name}

Check Link Name And Endpoint Name In WebEM
    ${state}    Check Array Carriers In Netconf Traces
    @{objects}=    Run Keyword If    '${state}' == 'True'    Set Variable    ${LINK_SECOND_TYPE}
    ...    ELSE    Set Variable    ${LINK_FIRST_TYPE}
    @{link_name}    Create List
    @{endpoint_name}    Create List
    FOR    ${links}    IN    @{objects}
            ${links_info}    Get Parameters    .*    ${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/${links}
            ${status}    Run Keyword And Return Status    Should Contain    ${links}    RX
            Run Keyword If    ${status}    Run Keywords
            ...    Append To List    ${endpoint_name}    ${links_info['rxEndPointName']}    AND
            ...    Append To List    ${link_name}    ${links_info['rxLinkName']}
            ...    ELSE    Run Keywords
            ...    Append To List    ${endpoint_name}    ${links_info['txEndPointName']}    AND
            ...    Append To List    ${link_name}    ${links_info['txLinkName']}
    END
    Set Test Variable    ${LINK_NAME}    ${link_name}
    Set Test Variable    ${ENDPOINT_NAME}    ${endpoint_name}

Check Array Carriers In Netconf Traces
    ${msg}    Check Message In Netconf Trace File    <state>READY</state>
    ${state}    Run Keyword And Return Status    Should Contain    ${msg}    NR1.TX1_1_1_3_9
    [Return]    ${state}

Check Externalio Objects In WebEM
    [Arguments]    ${distname}=${EQM_PATH}/APEQM_R-1/RMOD_R-1/
    FOR    ${EAC_ID}    IN    @{EAC_IN}
        ${eac_info}    Get Parameters    .*    ${distname}${EAC_ID}
        Should Be Equal As Strings    ${eac_info['direction']}    input
        Should Be Equal As Strings    ${eac_info['lineState']}    On
        Run Keyword If     '${EAC_ID}' == 'EAC_R-3'    Should Be Equal As Strings
        ...    ${eac_info['portId']}
        ...    2
        ...    ELSE IF    '${EAC_ID}' == 'EAC_R-5'    Should Be Equal As Strings
        ...    ${eac_info['portId']}
        ...    3
    END
    FOR    ${EAC_ID}    IN    @{EAC_OUT}
        ${eac_info}    Get Parameters    .*    ${distname}${EAC_ID}
        Should Be Equal As Strings    ${eac_info['direction']}    output
        Should Be Equal As Strings    ${eac_info['lineState']}    Off
        Run Keyword If     '${EAC_ID}' == 'EAC_R-4'    Should Be Equal As Strings
        ...    ${eac_info['portId']}
        ...    2
        ...    ELSE IF    '${EAC_ID}' == 'EAC_R-6'    Should Be Equal As Strings
        ...    ${eac_info['portId']}
        ...    3
    END

Check Parameters Under RSL Object
    [Arguments]    ${distname}=${EQM_PATH}/APEQM_R-1/RMOD_R-1/RSL_R-1
    FOR    ${item}    IN    @{RSL_PARAMETERS}
        ${state}    Get Parameters    ${item}    ${distname}
        Run Keyword If     "${item}" == "dcVoltageEnabled"
            ...    Should Be Equal As Strings    ${state}[${item}]    False
        ...    ELSE IF    "${item}" == "operationalState" and "22R3" in "${OUT_ACTIVE_SW}"
            ...    Should Match Regexp    ${state}[${item}]    Disabled|disabled
        ...    ELSE IF    "${item}" == "operationalState" and "22R2" in "${OUT_ACTIVE_SW}"
            ...    Should Match Regexp    ${state['stateInfo']['${item}']}    Disabled|disabled
        ...    ELSE IF     "${item}" == "availabilityStatus" and "22R3" in "${OUT_ACTIVE_SW}"
            ...    Should Match Regexp    ${state}[${item}]    PowerOff|power off
        ...    ELSE IF     "${item}" == "availabilityStatus" and "22R2" in "${OUT_ACTIVE_SW}"
            ...    Should Match Regexp    ${state['stateInfo']['${item}']}    PowerOff|power off
    END

Check Information About Optional Features And Modules In Webem
    Check Under RU_L That All Optional Modules Are Supported
    Check Optional Features Under RMOD_R

Check Beamforming Parameters In WebEM
    ${beamforming_state}    Get Parameters    actBeamforming    ${BTS_L_PATH}/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-1/NRBTS_A-1/NRCELL_A-1
    Should Be Equal As Strings    ${beamforming_state['actBeamforming']}    True
    ${beamset_state}    Get Parameters    beamSetInUse    ${NRTS_PATH}/NRBTS_L-1/NRCELL_L-1
    Should Be Equal As Strings    ${beamset_state['beamSetInUse']}    beamSet_2_2
    FOR    ${beam}    IN RANGE    0    4
         ${beam_id}    Evaluate    ${beam}+1
         ${state}    Get Parameters    oRuSupportedBeamIdList    ${NRTS_PATH}/NRBTS_L-1/NRCELL_L-1
         Should Be Equal As Integers    ${state['oRuSupportedBeamIdList'][${beam}]}    ${beam_id}
    END

Check Oru Capabilities
    ${ru}=    taf.sbts.oam.coam.admin.Get Parameters    ${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1    alias=${ADMIN_ALIAS}
    @{capabilities}=    Get From Dictionary    dictionary=&{ru}    key=capabilities
    @{oru_cap_list}=    Set Variable    @{ORU_CAPABILITES}
    FOR    ${capability}     IN    @{capabilities}
        ${uri}=     Get From Dictionary    dictionary=&{capability}    key=uri
        @{oru_cap_list}=    Check Capability    ${oru_cap_list}    ${uri}
    END
    Should Be Empty    ${oru_cap_list}
    Log    \n+ ORU capabilities checked    console=yes

Check Capability
    [Arguments]    ${list}    ${uri}
    FOR    ${value}    IN   @{list}
        ${passed}=    Run Keyword And Return Status    Should Contain    ${uri}    ${value}
        Run Keyword If    ${passed}    Remove Values From List    ${list}    ${value}
        Run Keyword If    ${passed}    Exit For Loop
    END
    [Return]    ${list}

Check Under RU_L That All Optional Modules Are Supported
    FOR    ${module}    IN    @{OPT_MODULES_AND_FEATURES_IN_RU_L}
        Check Under RU_L That Module Is Supported  ${module}
    END

Check Under RU_L That Module Is Supported
    [Arguments]    ${module}
    ...            ${parameter}=capabilities
    ...            ${distname}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1
    ${state}    Get Parameters    ${parameter}    ${distname}
    ${state_string}    Convert To String    ${state}
    Should Contain    ${state_string}    ${module}

Check Optional Features Under RMOD_R
    [Arguments]    ${expected_value}=True
    ...            ${distname}=${EQM_PATH}/APEQM_R-1/RMOD_R-1
    FOR    ${feature}    IN    @{OPT_FEATURES}
        ${state}    Get Parameters    ${feature}    ${distname}
        Should Be Equal As Strings    ${state['oRanFeaturesSupport']['${feature}']}    ${expected_value}
    END

Get Parameter Value From Message With The Following Id
    [Arguments]    ${parameter_name}
    ...            ${message_id}
    ...            ${grep_option}=tail -n 1
    ${output}    Run     grep -o 'id=${message_id}.*>.*</${parameter_name}' ${NETCONF_TRACE_LOCAL_PATH} | ${grep_option}
    ${value_tmp}=    Fetch From Right    ${output}    >
    ${value}=    Fetch From Left    ${value_tmp}    </${parameter_name}
    Log To Console     Value of parameter '${parameter_name}' read from Netconf trace file: ${value}
    [Return]    ${value}

Get First Parameter Value From Message With The Following Id
    [Arguments]    ${parameter_name}
    ...            ${message_id}
    ...            ${parameter_name_2}=${parameter_name}
    ...            ${grep_option}=tail -n 1
    ${output}    Run     grep -o -P 'id="${message_id}.*?<${parameter_name}>.*?</${parameter_name_2}>' ${NETCONF_TRACE_LOCAL_PATH} | ${grep_option}
    ${value_tmp}=    Fetch From Right    ${output}    <${parameter_name}>
    ${value}=    Fetch From Left    ${value_tmp}    </${parameter_name_2}>
    Log To Console     Value of parameter '${parameter_name_2}' read from Netconf trace file: ${value}
    [Return]    ${value}

Check HW Message
    ${hw_namespace}    Check Message In Netconf Trace File    o-ran:hardware
    Should Contain    ${hw_namespace}    <namespace>urn:o-ran:hardware:1.0</namespace>
    ${hw_id}    Check Message Id
    ...    get.*<serial-num/><hardware-rev/><software-rev/><mfg-name/><model-name/>.*/get>
    ...    tail -n 1
    Should Not Be Empty    ${hw_id}
    ${hw}    Check Message In Logs On Oru    ${hw_id}
    Should Contain     ${hw}
    ...    <class xmlns:o-ran-hw="urn:o-ran:hardware:1.0">o-ran-hw:O-RAN-RADIO</class><hardware-rev>
    @{hw_param}    Create List
    FOR    ${parameter}    IN    @{HW_PARAMETERS}
        ${output}    Get Parameter Value From Message With The Following Id    ${parameter}    ${hw_id}
        Append To List    ${hw_param}    ${output}
    END
    Set Test Variable    ${HW_PARAM}    ${hw_param}

Check PM Counter Activation Message
    ${message_id}    Check Message Id In Oru
    ...    edit-config.*performance-management.*<active>true</active><object-unit>TRANSPORT</object-unit>
    Should Not Be Empty    ${message_id}
    ${message}    Check Message In Logs On Oru    ${message_id}
    Should Contain    ${message}    <ok/></rpc-reply>

Check HW Parameters
    Check HW Parameters Under RMOD_R Object
    ${rmod_fan_invunit_path}=    Get Invunit Path Belonging To Rmod    RADIOGEN1    ${MRBTS_PATH}/HW_R-1/INVUNIT_R-
    Check HW Parameters Under INVUNIT Object    ${rmod_fan_invunit_path}

Check HW Parameters Under RMOD_R Object
    [Arguments]    ${rmod_r_path}=${EQM_PATH}/APEQM_R-1/RMOD_R-1
    ${hw_info}    Get Parameters    .*    ${rmod_r_path}
    Should Be Equal As Strings    ${hw_info['productName']}    @{HW_PARAM}[0]
    Should Be Equal As Strings    ${hw_info['productCode']}    @{HW_PARAM}[1]
    Should Be Equal As Strings    ${hw_info['serialNumber']}    @{HW_PARAM}[2]
    Should Be Equal As Strings    ${hw_info['hwVersion']}    @{HW_PARAM}[3]
    Should Be Equal As Strings    ${hw_info['vendorName']}    @{HW_PARAM}[4]

Check HW Parameters Under INVUNIT Object
    [Arguments]    ${invunit_path}
    ${hw_info}    Get Parameters    .*    ${invunit_path}
    Should Be Equal As Strings    ${hw_info['vendorUnitTypeNumber']}    @{HW_PARAM}[1]
    Should Be Equal As Strings    ${hw_info['serialNumber']}    @{HW_PARAM}[2]
    Should Be Equal As Strings    ${hw_info['versionNumber']}    @{HW_PARAM}[3]
    Should Be Equal As Strings    ${hw_info['vendorName']}    @{HW_PARAM}[4]

Assert Trrws Counter Is Set To 5min
    ${pmmnl}=    Get Pmmnl
    ${interval}=    Get From Dictionary    dictionary=&{pmmnl}    key=miTrRxWindowStats
    Should Contain    ${interval}    5min

Get Pmmnl
    ${conf}=    taf.sbts.oam.coam.admin.Get Parameters    ${BTS_L_PATH}/BTS_CONF-1    alias=${ADMIN_ALIAS}
    ${np}=    Get From Dictionary    dictionary=&{conf}    key=currentNp
    ${path}=    Catenate    SEPARATOR=    ${np}    /SCF-1/MRBTS_A-1/MNL_A-1/MNLENT_A-1/PMMNL_A-1
    ${pmmnl}=    taf.sbts.oam.coam.admin.Get Parameters    ${path}    alias=${ADMIN_ALIAS}
    [Return]    ${pmmnl}

Split Supervisord Logs
    [Arguments]    ${split_line}
    ...            ${path_default_acc}=${SPLITTED_LOGS_DEFAULT_ACC}
    ...            ${path_non_default_acc}=${SPLITTED_LOGS_NON_DEFAULT_ACC}
    ...            ${supervisord_path}=${SUPERVISORD_PATH}
    ${split_line}    Evaluate    ${split_line}-1
    Send Cmd To Docker Shell    cat ${supervisord_path} | sed -n '1,${split_line}p' >> ${path_default_acc}
    Send Cmd To Docker Shell    cat ${supervisord_path} | sed -n '${split_line},$p' >> ${path_non_default_acc}

Split Netconf Traces
    [Arguments]    ${split_line}
    ...            ${path_default_acc}=${SPLITTED_TRACES_DEFAULT_ACC}
    ...            ${path_non_default_acc}=${SPLITTED_TRACES_NON_DEFAULT_ACC}
    ...            ${nc_traces_path}=${NETCONF_TRACE_REMOTE_PATH}
    SYSTEM Open SSH Connection To Enb
    ${split_line}    Evaluate    ${split_line}-1
    SSHLibrary.Write    cat ${nc_traces_path} | sed -n '1,${split_line}p' >> ${path_default_acc}
    SSHLibrary.Read Until    :~ >
    SSHLibrary.Write    cat ${nc_traces_path} | sed -n '${split_line},$p' >> ${path_non_default_acc}
    SSHLibrary.Read Until    :~ >
    [Teardown]    SYSTEM Close SSH Connection To Enb

Get Line Number Of Message From Oru File
    [Arguments]    ${message_to_find}
    ...            ${supervisord_path}=${SUPERVISORD_PATH}
    ...            ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.Write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until    root@
    SSHLibrary.Write    awk '/${message_to_find}/ {print FNR}' ${supervisord_path}
    ${number}    SSHLibrary.Read Until    root@
    Should Not Be Empty     ${number}
    ${number}    Get Line    ${number}    0
    [Return]    ${number}
    [Teardown]  Clear SSH Session To Docker

Get Line Number Of Message From gNB File
    [Arguments]    ${message_to_find}
    ...            ${file_path}=${NETCONF_TRACE_REMOTE_PATH}
    SYSTEM Open SSH Connection To Enb
    ${number}     SSHLibrary.Execute Command    awk '/${message_to_find}/ {print FNR}' ${file_path}
    Should Not Be Empty     ${number}
    ${number}    Get Line    ${number}    0
    [Return]    ${number}
    [Teardown]    SYSTEM Close SSH Connection To Enb

Move File In Oru
    [Arguments]    ${source}
    ...            ${destination}
    ...            ${docker_name}=${DOCKER_NAME}
    send cmd to docker shell    mv ${source} ${destination}     ${docker_name}

Move File In gNB
    [Arguments]    ${source}
    ...            ${destination}
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Execute Command    mv ${source} ${destination}
    [Teardown]    SYSTEM Close SSH Connection To Enb

#Add Additional Netconf Account
#    Prepare Enviroment
#    Login To Web Element Manager
#    Go To Netconf Radio Management Tab
#    Configure Additional Netconf Account In Webem
#    Teardown Environment
#    Log    \n+ Additional Netconf Account Added    console=yes

#Login To Web Element Manager
#    [Arguments]    ${login}=${CUSTOMER_LOGIN}
#    ...            ${password}=${CUSTOMER_PASSWORD}
#    Set Selenium Implicit Wait    5
#    Open Browser    ${WebEM IP}   chrome
#    Check Privacy Error
#    Proceed Unsafe Connection
#    Run Keyword And Ignore Error    Maximize Browser Window
#    Input Text    locator=${INPUT_NAME_FIELD}
#    ...           text=${login}
#    Input Password    locator=${INPUT_PASSWORD_FIELD}
#    ...               password=${password}
#    Click Element   locator=${LOGIN_BUTTON}
#    Wait Until Element Is Visible    locator=${CONFIRM_BUTTON}    timeout=100
#    Click Element    locator=${CONFIRM_BUTTON}
#    Close BTS Startup View

#Go To Netconf Radio Management Tab
#    Wait Until Element Is Visible   locator=${CONFIGURATION_TAB}
#    Click Element   locator=${CONFIGURATION_TAB}
#    Mouse Over  locator=${NETCONF_RADIO_MANAGEMENT_BUTTON}
#    Click Element   locator=${NETCONF_RADIO_MANAGEMENT_BUTTON}
#    Wait Until Element Is Visible    locator=${ACCOUNTS_CONFIGURATION}

#Configure Additional Netconf Account In Webem
#    [Arguments]    ${name}=${ADDITIONAL_ACCOUNT_NAME}
#    ...            ${password}=${DEFAULT_ACCOUNT_PASS}
#    ${account_configured}=    Run Keyword And Return Status    Wait Until Element Is Visible
#    ...    locator=//span[contains(text(), 'SSDORU-1')]
#    ...    timeout=20
#    Run Keyword If    '${account_configured}' == 'False'    Run Keyword
#    ...    Configure Default Netconf Account In Webem Without Sending The Configuration
#    Click Element
#    ...    locator=//span[contains(text(), 'SSDORU-1')]
#    Wait Until Element Is Visible    locator=${CONFIGURE_ADDITIONAL_ACCOUNT_BUTTON}
#    Click Element    locator=${CONFIGURE_ADDITIONAL_ACCOUNT_BUTTON}
#    Wait Until Element Is Visible    locator=//div[contains(text(),'Additional netconf account')]
#    Input Text    locator=additional-netconf-account-name
#    ...           text=${name}
#    Input Password   locator=additional-netconf-account-pwd
#    ...              password=${password}
#    Input Password   locator=confirm-additional-netconf-account-pwd
#    ...              password=${password}
#    Wait Until Element Is Enabled    locator=${SEND_BUTTON}    timeout=20
#    Click Element    locator=${SEND_BUTTON}
#    Wait Until Element Is Visible    locator=${CONFIGURE_RADIO_SUCCEEDED}
#    ...                              timeout=90

Prepare Enviroment
    Chmod Chromedriver
    Run Xvfb
    Export DISPLAY

#Chmod Chromedriver
#    Run  sudo chmod +x /usr/bin/chromedriver

#Run Xvfb
#    Start Process  /usr/bin/Xvfb :99 -screen 0 1920x1080x16   shell=yes

#Export DISPLAY
#    Set Environment Variable  DISPLAY  :99

#Teardown Environment
#	Close All Browsers
#    Terminate All Processes

#Close BTS Startup View
#    ${close}=    Run Keyword And Return Status    Wait Until Element Is Visible
#    ...    locator=//button[contains(text(),'Close')]
#    ...    timeout=100
#    Run Keyword If    '${close}' == 'True'    Run Keyword    Click Element    locator=//button[contains(text(),'Close')]

#Check Privacy Error
#    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
#    ...                                           xpath=//*[@id="main-message"]/h1
#    ...                                           timeout=30
#    ${privacy_error}    Run Keyword If    ${status}    Get Text    locator=//*[@id="main-message"]/h1
#    ${privacy_error}    Run Keyword And Return Status    Should Contain    ${privacy_error}    is not private
#    Run Keyword If    ${privacy_error}    Proceed Unsafe Connection

#Proceed Unsafe Connection
#    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
#    ...                                           xpath=//*[@id="details-button"]
#    ...                                           timeout=30
#    Run Keyword If    ${status}    Click Element  xpath=//*[@id="details-button"]
#    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
#    ...                                           xpath=//*[@id="proceed-link"]
#   ...                                           timeout=30
#    Run Keyword If    ${status}    Click Element  xpath=//*[@id="proceed-link"]

#Add Default Netconf Account
#    Prepare Enviroment
#    Login To Web Element Manager
#    Go To Netconf Radio Management Tab
#    Configure Default Netconf Account In Webem
#    Teardown Environment
#    Log    \n+ Default Netconf Account Added    console=yes

#Configure Default Netconf Account In Webem
#    [Arguments]    ${name}=${DEFAULT_ACCOUNT_NAME}
#    ...            ${password}=${DEFAULT_ACCOUNT_PASS}
#    Click Element    ${PLUS_BUTTON}
#    Wait Until Element Is Visible    locator=//span[contains(text(),'Default netconf account')]
#    Input Text    locator=account-name
#    ...           text=${name}
#    Input Password   locator=account-pwd
#    ...              password=${password}
#    Input Password   locator=confirm-account-pwd
#    ...              password=${password}

#    Wait Until Element Is Enabled    locator=${SEND_BUTTON}    timeout=20
#    Click Element    locator=${SEND_BUTTON}
#    Wait Until Element Is Visible    locator=${CONFIGURE_RADIO_SUCCEEDED}
#    ...                              timeout=20

#Configure Default Netconf Account In Webem Without Sending The Configuration
#    [Arguments]    ${name}=${DEFAULT_ACCOUNT_NAME}
#    ...            ${password}=${DEFAULT_ACCOUNT_PASS}
#    Click Element    ${PLUS_BUTTON}
#    Wait Until Element Is Visible    locator=//span[contains(text(),'Default netconf account')]
#    Input Text    locator=account-name
#    ...           text=${name}
#    Input Password   locator=account-pwd
#    ...              password=${password}
#    Input Password   locator=confirm-account-pwd
#    ...              password=${password}
