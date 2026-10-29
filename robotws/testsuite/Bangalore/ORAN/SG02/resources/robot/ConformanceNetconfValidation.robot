*** Settings ***

Documentation
...   author: Rubina Nath
...   contact: rubina.nath@nokia.com
...   Description: Netconf Validation Keyowrds as per Conformance Specification

Library     SSHLibrary
Library     Collections
Library     BuiltIn
Library     String
Library     OperatingSystem     WITH NAME    os
Library     taf.sbts.oam.coam.admin    WITH NAME    admin

*** Variables ***

${delete_cmd}=    rm -rf /tmp/node_FHNET00/tmp/${NetconfFileName}
${source}=        /tmp/node_FHNET00/tmp/${NetconfFileName}
${ssh_username}=      toor4nsn
${ssh_password}=      oZPS0POrRieRtu

@{AuthList}=      Password authentication    Authentication successful
...               Sending message:<hello xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
...               Received message:<hello xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">

@{param_eac}=     name    line-in    io-port
@{param_ald}=    port-id    status    frames-with-wrong-crc    frames-without-stop-flag    number-of-received-octets
@{param_sw1}=     name    status    active    running    product-code    vendor-code    access    build-id    build-name    build-version
@{param_sw2}=     name    version    local-path    integrity
@{param_uplane_rx}=    name    restricted-interfaces    array    endpoint-type    prach-group    static-config-supported
...                max-prach-patterns    configurable-tdd-pattern-supported    compression
@{param_uplane_tx}=    name    restricted-interfaces    array    endpoint-type    supported-reference-level
...                    configurable-tdd-pattern-supported    compression
@{param_hw}=     name    class    serial-num    mfg-name   product-code
@{param_fan}=    name    fan-location    present-and-operating    vendor-code    vendor-code   fan-speed    target-speed
@{param_int}=    name    description    type     enabled   admin-status    oper-status    if-index
...              phys-address    vlan-tagging    mac-address    statistics   port-reference     port-reference
@{param_band}=    band-number    max-supported-frequency-dl    min-supported-frequency-dl    max-supported-bandwidth-dl
...               max-num-carriers-dl    max-carrier-bandwidth-dl    min-carrier-bandwidth-dl
...               supported-technology-dl
...               max-supported-frequency-ul    min-supported-frequency-ul
...               max-supported-bandwidth-ul    max-num-carriers-ul
...               max-carrier-bandwidth-ul    min-carrier-bandwidth-ulsupported-technology-ul
...               supported-technology-ul
...               max-num-component-carriers    max-num-bands    max-num-sectors    max-power-per-antenna
...               min-power-per-antenna    codebook-configuration_n1    codebook-configuration_n2

@{param_ru}=    max-power-per-pa-antenna    min-power-per-pa-antenna    format-of-iq-sample
...             energy-saving-by-transmission-blanks
@{param_port}=    interface-name    port-number    name    present    vendor-id    vendor-part    vendor-rev
...               serial-no    SFF8472-compliance-code    connector-type    identifier
@{param_tx}=    name    number-of-rows    band-number    number-of-columns    number-of-array-layers
...             max-gain    independent-power-budget    polarisations
@{param_rx}=    name    number-of-rows    band-number    number-of-columns    number-of-array-layers
...             gain-correction-range    polarisations
@{param_endp}=    id    supported-section-types    supported-frame-structures    managed-delay-support
...               multiple-numerology-supported    max-remasks-per-section-id    max-beams-per-symbol
...               max-beams-per-slot    max-prb-per-symbol
@{param_txp}=    name    restricted-interfaces    array    endpoint-type
...              configurable-tdd-pattern-supported    compression    supported-reference-level
@{param_rxp}=    name    restricted-interfaces    array    endpoint-type    max-prach-patterns
...              prach-group    compression    static-config-supported    configurable-tdd-pattern-supported
@{param_alp}=    name    port-id    dc-control-support    dc-enabled-status    supported-connector
@{param_inp}=    name    port-in    line-in
@{param_out}=    name    port-out
@{param_ops}=    restart-cause    restart-datetime
@{param_res}=    bandwidth    subcarrier-spacing
${NetconfFileName}=        RMOD_L-1_NetconfRpcMessageTrace.log

*** Keywords ***

GetNetconfLogs
    [Arguments]    ${path}
    SSHLibrary.Open Connection    host=${BTS_ADDRESS}
    SSHLibrary.Login    ${ssh_username}    password=${ssh_password}    delay=10
    SSHLibrary.Get File
	...     source=${source}
	...     destination=${path}/${NetconfFileName}    scp=scp
    SSHLibrary.Close All Connections

DeleteNetconfLogs
    SSHLibrary.Open Connection    host=${BTS_ADDRESS}
    SSHLibrary.Login    ${ssh_username}    ${ssh_password}    delay=10
    SSHLibrary.Write    ${delete_cmd}
    SSHLibrary.Close All Connections

MessageVerification_eacIN
    [Arguments]    ${netconf_file}
    FOR    ${i}    IN    @{param_eac}
        ${eac}=    netconf_get_value     ${netconf_file}    notification    external-input-change    ${i}
        run keyword and continue on failure   Should not be empty    ${eac}
        log    ${eac}
    END

MessageVerification_ald
    [Arguments]    ${netconf_file}
    ${ald}=    netconf_get_value     ${netconf_file}    rpc    ald-communication    ald-req-msg
	run keyword and continue on failure   Should not be empty    ${ald}
    FOR    ${i}    IN    @{param_ald}
        ${ald}=    netconf_get_value     ${netconf_file}    rpc-reply    ${i}    ${i}
        run keyword and continue on failure   Should not be empty    ${ald}
        log    ${ald}
	END

Software_Inventory
    [Arguments]    ${netconf_file}
    ${sw}=    netconf_get__message_id     ${netconf_file}    get    software-inventory
    run keyword and continue on failure   Should not be empty    ${sw}
    FOR    ${i}    IN   @{param_sw1}
        ${sw}=    validate_netconf_reply_message      ${netconf_file}    get    software-inventory    ${i}
        run keyword and continue on failure   Should not be empty    ${sw}
	END
    FOR    ${i}    IN   @{param_sw2}
        ${sw}=    validate_netconf_reply_message      ${netconf_file}    get    software-inventory    files    ${i}
        run keyword and continue on failure   Should not be empty    ${sw}
    END

MessageVerification_alarm
    [Arguments]    ${netconf_file}    @{listoffaults}
    ${al}=    netconf_get_value     ${netconf_file}    notification    alarm-notif    fault-id
    ${len}=    Get Length    ${al}
    FOR    ${i}    IN RANGE    ${len}
        run keyword and continue on failure    should contain any    ${al}[${i}]    @{listoffaults}
    END
    ${al}=    netconf_get_value     ${netconf_file}    notification    alarm-notif    is-cleared
    FOR    ${i}    IN RANGE    ${len}
        run keyword and continue on failure    should contain any    ${al}[${i}]    true    false
    END
    ${al}=    netconf_get_value     ${netconf_file}    notification    alarm-notif    fault-severity
    FOR    ${i}    IN RANGE    ${len}
        run keyword and continue on failure    should contain any    ${al}[${i}]    MINOR    MAJOR    CRITICAL
    END

MessageVerification_eac_out
    [Arguments]    ${netconf_file}
    ${eac}=    netconf_get_value     ${netconf_file}    rpc    edit-config    line-out
    run keyword and continue on failure   Should not be empty    ${eac}
    ${eac}=    validate_netconf_reply_message      ${netconf_file}     edit-config    ok
    run keyword and continue on failure   Should not be empty    ${eac}

MessageVerification_reset
    [Arguments]    ${netconf_file}
    ${res}=    netconf_get_message_id     ${netconf_file}    reset
    run keyword and continue on failure   Should not be empty    ${res}
    log    ${res}
    ${res}=    validate_netconf_reply_message      ${netconf_file}     reset    ok
    run keyword and continue on failure   Should not be empty    ${res}

Authentication_check
    [Arguments]    ${netconf_file}
    ${auth}=    netconf_get_value     ${netconf_file}    rpc-reply     rpc-error    error-path
    @{schema}=    create list
    FOR    ${i}    IN   @{auth}
        ${r}=    run keyword and continue on failure     Should Match Regexp    ${i[1]}    schema
        Log     ${r}
        Run Keyword If   '${r}'=='None'   Append To List   ${schema}    ${i[1]}
    END
	Log    ${schema}
    run keyword and continue on failure   Should be empty    ${schema}
    ${cont}=    os.get file    ${netconf_file}
    run keyword and continue on failure    should not contain    ${cont}    Authentication denied
    FOR    ${i}    IN    @{AuthList}
        run keyword and continue on failure    should contain    ${cont}    ${i}
    END

AuthenticationTransport_checkfailure
    [Arguments]    ${netconf_file}
    ${auth}=    netconf_get_value     ${netconf_file}    rpc-reply     rpc-error    error-path
    @{schema}=    create list
    FOR    ${i}    IN   @{auth}
        ${r}=    run keyword and continue on failure     Should Match Regexp    ${i[1]}    schema
        Log     ${r}
        Run Keyword If   '${r}'=='None'   Append To List   ${schema}    ${i[1]}
    END
	Log    ${schema}
    run keyword and continue on failure   Should be empty    ${schema}
    ${cont}=    os.get file    ${netconf_file}
    run keyword and continue on failure    should contain    ${cont}    SSH channel unexpected EOF
    FOR    ${i}    IN    @{AuthList}
        run keyword and continue on failure    should contain    ${cont}    ${i}
    END

Authentication_checkfailure
    [Arguments]    ${netconf_file}
    ${auth}=    netconf_get_value     ${netconf_file}    rpc-reply     rpc-error    error-path
    @{schema}=    create list
    FOR    ${i}    IN   @{auth}
        ${r}=    run keyword and continue on failure     Should Match Regexp    ${i[1]}    schema
        Log     ${r}
        Run Keyword If   '${r}'=='None'   Append To List   ${schema}    ${i[1]}
    END
	Log    ${schema}
    run keyword and continue on failure   Should be empty    ${schema}
    ${cont}=    os.get file    ${netconf_file}
    run keyword and continue on failure    should contain    ${cont}    Authentication denied
    FOR    ${i}    IN    @{AuthList}
        run keyword and continue on failure    should contain    ${cont}    ${i}
    END

MessageVerification_sudo
    [Arguments]    ${netconf_file}
    ${file}=    os.get file    ${netconf_file}
    run keyword and continue on failure    should contain    ${file}    Password authentication (host "172.22.0.2", user "xranuser2")
    run keyword and continue on failure    should contain    ${file}    <user-name>xranuser2</user-name>
    ${sudo}=    validate_netconf_reply_message      ${netconf_file}    edit-config    ok
    run keyword and continue on failure   Should not be empty    ${sudo}
    ${sudo}=    validate_netconf_reply_message      ${netconf_file}     close-session    ok
    run keyword and continue on failure   Should not be empty    ${sudo}

MessageVerification_LBM
    [Arguments]    ${netconf_file}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    edit-config    name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    edit-config    interface-name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    edit-config    vlan-id
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    edit-config    ru-mac-address
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    edit-config    o-du-mac-address
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    edit-config    if:name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    edit-config    if:description
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    edit-config    if:type
    run keyword and continue on failure   Should not be empty    ${a}

MessageVerification_software
    [Arguments]    ${netconf_file}
    ${sw}=    netconf_get_value     ${netconf_file}    rpc    software-download    remote-file-path
    run keyword and continue on failure   Should not be empty    ${sw}
    ${sw}=    netconf_get_value     ${netconf_file}    rpc    software-install    slot-name
    run keyword and continue on failure   Should not be empty    ${sw}
    ${sw}=    netconf_get_value     ${netconf_file}    rpc    software-install    file-names
    run keyword and continue on failure   Should not be empty    ${sw}
    ${sw}=    netconf_get_value     ${netconf_file}    rpc    software-activate    slot-name
    run keyword and continue on failure   Should not be empty    ${sw}
    ${sw}=    netconf_get_value     ${netconf_file}    rpc-reply    status    status
    run keyword and continue on failure   Should not be empty    ${sw}
    ${sw}=    netconf_get_value     ${netconf_file}    notification    download-event     status
    run keyword and continue on failure   Should not be empty    ${sw}
    Log    ${sw}
    ${sw}=    netconf_get_value     ${netconf_file}    notification    activation-event    status
    run keyword and continue on failure   Should not be empty    ${sw}
    Log    ${sw}
    ${sw}=    netconf_get_value     ${netconf_file}    notification    install-event    status
    run keyword and continue on failure   Should not be empty    ${sw}
    Log    ${sw}

MessageVerification_neg_software
    [Arguments]    ${netconf_file}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    software-download    remote-file-path
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    software-install    slot-name
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    software-install    file-names
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    rpc-reply    status    status
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    notification    download-event     status
    run keyword and continue on failure   Should not be empty    ${a}
    Log    ${a}
    ${a}=    netconf_get_value     ${netconf_file}    notification    install-event    status
    run keyword and continue on failure   Should not be empty    ${a}
    Log    ${a}

MessageVerification_SFP_Check
    [Arguments]    ${netconf_file}
    ${trb}=    netconf_get_value     ${netconf_file}    rpc    retrieve-file-list    logical-path
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    rpc    retrieve-file-list    file-name-filter
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    rpc-reply    status    file-list
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    rpc    file-upload    local-logical-file-path
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    rpc    file-upload    remote-file-path
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    rpc    file-upload    public-key
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    rpc    file-upload    algorithm
    run keyword and continue on failure   Should not be empty    ${trb}
    FOR    ${i}    IN    @{sfp_list}
        ${var}=    validate_netconf_reply_message      ${netconf_file}     get    port-transceiver-data     ${i}
        run keyword and continue on failure   Should not be empty    ${var}
        log    ${var}
    END
    ${trb}=    netconf_get_value     ${netconf_file}    notification    eventTime    eventTime
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    notification    file-upload-notification    local-logical-file-path
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    notification    file-upload-notification    remote-file-path
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    notification    file-upload-notification    status
    run keyword and continue on failure   Should not be empty    ${trb}

MessageVerification_conf_subs_troubleshooting
    [Arguments]    ${netconf_file}
    ##################Get_Message#####################
    ${get}=    netconf_get_message_id     ${netconf_file}    get
    run keyword and continue on failure   Should not be empty    ${get}
    log    ${get}
    ##################Subscription#####################
    ${subs}=    netconf_get_value     ${netconf_file}    rpc    create-subscription    stream
    run keyword and continue on failure   Should not be empty    ${subs}
    ${subs}=    validate_netconf_reply_message      ${netconf_file}     create-subscription    ok
    run keyword and continue on failure   Should not be empty    ${subs}
    ##################Active_Alarms######################
    ${alr}=    netconf_get__message_id     ${netconf_file}    get    active-alarm-list
    run keyword and continue on failure   Should not be empty    ${alr}
    ${alr}=    validate_netconf_reply_message      ${netconf_file}    get    data
    run keyword and continue on failure   Should not be empty    ${alr}
    ##################Troubleshooting#####################
    ${trb}=    netconf_get_message_id     ${netconf_file}    start-troubleshooting-logs
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=     netconf_get_value     ${netconf_file}    rpc-reply    status    status
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    notification    troubleshooting-log-generated    log-file-name
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    rpc    file-upload    local-logical-file-path
    run keyword and continue on failure   Should not be empty    ${trb}
    ${trb}=    netconf_get_value     ${netconf_file}    notification    file-upload-notification    status
    run keyword and continue on failure   Should not be empty    ${trb}
    ##################Configurability#####################
    FOR    ${i}    IN   @{param_uplane_rx}
        ${conf}=    validate_netconf_reply_message      ${netconf_file}    get
	...    user-plane-configuration    static-low-level-rx-endpoints    ${i}
        run keyword and continue on failure   Should not be empty    ${conf}
	END
    FOR    ${i}    IN   @{param_uplane_tx}
        ${conf}=    validate_netconf_reply_message      ${netconf_file}    get
	...    user-plane-configuration    static-low-level-tx-endpoints    ${i}
        run keyword and continue on failure   Should not be empty    ${conf}
    END

MessageVerification_sup
    [Arguments]    ${netconf_file}
    ${sup}=    netconf_get_value     ${netconf_file}    rpc    supervision-watchdog-reset
	...    supervision-notification-interval
    run keyword and continue on failure   Should not be empty    ${sup}
    ${sup}=    netconf_get_value     ${netconf_file}    rpc    supervision-watchdog-reset    guard-timer-overhead
    run keyword and continue on failure   Should not be empty    ${sup}
    ${sup}=    netconf_get_value     ${netconf_file}    rpc-reply    supervision-watchdog-reset    next-update-at
    run keyword and continue on failure   Should not be empty    ${sup}

MessageVerification_wo_filter
    [Arguments]    ${netconf_file}

MessageVerification_filter
    [Arguments]    ${netconf_file}
    ##################MSG######################
    ${op}=    validate_netconf_reply_message      ${netconf_file}    get    operational-info
	...     supported-mplane-version
    run keyword and continue on failure   Should not be empty    ${op}
    ##################MSG######################
    ${hw}=    netconf_get__message_id     ${netconf_file}    get    hardware
    run keyword and continue on failure   Should not be empty    ${hw}
    FOR    ${i}    IN   @{param_sw1}
        ${hw}=    validate_netconf_reply_message      ${netconf_file}    get    hardware    ${i}
        run keyword and continue on failure   Should not be empty    ${hw}
	END
    ##################MSG######################
    #${f}=    netconf_get__message_id     ${netconf_file}    get
    #run keyword and continue on failure   Should not be empty    ${f}
    #${f}=    netconf_get__message_id     ${netconf_file}    get    fan-tray
    #run keyword and continue on failure   Should not be empty    ${f}
    #FOR    ${i}    IN   @{param_fan}
    #    ${f}=    validate_netconf_reply_message      ${netconf_file}    get    fan-tray     ${i}
    #    run keyword and continue on failure   Should not be empty    ${f}
    #END
    ##################MSG######################
    ${int}=    netconf_get__message_id     ${netconf_file}    get    interfaces
    run keyword and continue on failure   Should not be empty    ${int}
    FOR    ${i}    IN   @{param_fan}
        ${int}=    validate_netconf_reply_message      ${netconf_file}    get    interface    ${i}
        run keyword and continue on failure   Should not be empty    ${int}
	END
    ##################MSG1######################
    ${mod}=    netconf_get__message_id     ${netconf_file}    get    module-capability
    run keyword and continue on failure   Should not be empty    ${mod}
    FOR    ${i}    IN   @{param_band}
        ${mod}=    validate_netconf_reply_message      ${netconf_file}    get     band-capabilities    ${i}
        run keyword and continue on failure   Should not be empty    ${mod}
    END
    ##################MSG1######################
    ${ru}=    netconf_get__message_id     ${netconf_file}    get    ru-capabilities
    run keyword and continue on failure   Should not be empty    ${ru}
    FOR    ${i}    IN   @{param_ru}
        ${ru}=    validate_netconf_reply_message      ${netconf_file}    get     ru-capabilities    ${i}
        run keyword and continue on failure   Should not be empty    ${ru}
	END
    ##################MSG1######################
    ${port}=    netconf_get__message_id     ${netconf_file}    get    port-transceivers
    run keyword and continue on failure   Should not be empty    ${port}
    FOR    ${i}    IN   @{param_port}
        ${port}=    validate_netconf_reply_message      ${netconf_file}    get    port-transceiver-data    ${i}
        run keyword and continue on failure   Should not be empty    ${port}
	END
    ##################MSG######################
    ${tx}=    netconf_get__message_id     ${netconf_file}    get    user-plane-configuration
    run keyword and continue on failure   Should not be empty    ${tx}
    FOR    ${i}    IN   @{param_tx}
        ${tx}=    validate_netconf_reply_message      ${netconf_file}    get    user-plane-configuration
	...     tx-arrays    ${i}
        run keyword and continue on failure   Should not be empty    ${tx}
	END
    ##################MSG######################
    ${rx}=    netconf_get__message_id     ${netconf_file}    get    user-plane-configuration
    run keyword and continue on failure   Should not be empty    ${rx}
    FOR    ${i}    IN   @{param_rx}
        ${rx}=    validate_netconf_reply_message      ${netconf_file}    get
	...    user-plane-configuration    rx-arrays    ${i}
        run keyword and continue on failure   Should not be empty    ${rx}
	END
    ##################MSG######################
    ${endp}=    netconf_get__message_id     ${netconf_file}    get    user-plane-configuration
    run keyword and continue on failure   Should not be empty    ${endp}
    FOR    ${i}    IN   @{param_endp}
        ${endp}=    validate_netconf_reply_message      ${netconf_file}    get    user-plane-configuration
	...     endpoint-types    ${i}
        run keyword and continue on failure   Should not be empty    ${endp}
	END
    ##################MSG######################
    ${txp}=    netconf_get__message_id     ${netconf_file}    get    user-plane-configuration
    run keyword and continue on failure   Should not be empty    ${txp}
    FOR    ${i}    IN   @{param_endp}
        ${txp}=    validate_netconf_reply_message      ${netconf_file}    get    static-low-level-tx-endpoints    ${i}
        run keyword and continue on failure   Should not be empty    ${txp}
	END
    ##################MSG######################
    ${rxp}=    netconf_get__message_id     ${netconf_file}    get    user-plane-configuration
    run keyword and continue on failure   Should not be empty    ${rxp}
    FOR    ${i}    IN   @{param_rxp}
        ${rxp}=    validate_netconf_reply_message      ${netconf_file}    get    static-low-level-rx-endpoints    ${i}
        run keyword and continue on failure   Should not be empty    ${rxp}
	END
    ##################MSG######################
    ${ald}=    netconf_get__message_id     ${netconf_file}    get    ald-ports-io
    run keyword and continue on failure   Should not be empty    ${ald}
    FOR    ${i}    IN   @{param_alp}
        ${ald}=    validate_netconf_reply_message      ${netconf_file}    get    ald-ports-io    ${i}
        run keyword and continue on failure   Should not be empty    ${ald}
	END
    ##################MSG######################
    ${ext}=    netconf_get__message_id     ${netconf_file}    get    external-io
    run keyword and continue on failure   Should not be empty    ${ext}
    FOR    ${i}    IN   @{param_inp}
        ${inp}=    validate_netconf_reply_message      ${netconf_file}    get    external-io    input    ${i}
        run keyword and continue on failure   Should not be empty    ${inp}
	END
    FOR    ${i}    IN   @{param_out}
        ${out}=    validate_netconf_reply_message      ${netconf_file}    get    external-io    output    ${i}
        run keyword and continue on failure   Should not be empty    ${out}
	END
    ##################MSG######################
    ${var_sync}=    netconf_get__message_id     ${netconf_file}    get    sync
    run keyword and continue on failure   Should not be empty    ${var_sync}
    ${var_sync}=    validate_netconf_reply_message      ${netconf_file}    get    sync    sync-status    sync-state
    run keyword and continue on failure   Should not be empty    ${var_sync}
    ${var_sync}=    validate_netconf_reply_message      ${netconf_file}    get    sync
	...     sync-status    supported-reference-types
    run keyword and continue on failure   Should not be empty    ${var_sync}
    ${var_sync}=    validate_netconf_reply_message      ${netconf_file}    get    sync    ptp-status
    run keyword and continue on failure   Should not be empty    ${var_sync}
    ${var_sync}=    validate_netconf_reply_message      ${netconf_file}    get    sync
	...     synce-config    ssm-timeout
    run keyword and continue on failure   Should not be empty    ${var_sync}
    ##################MSG1######################
    FOR    ${i}    IN   @{param_ops}
        ${op}=    validate_netconf_reply_message      ${netconf_file}    get
	...     operational-info    operational-state    ${i}
        run keyword and continue on failure   Should not be empty    ${op}
	END
    ##################MSG1######################
    ${del}=    netconf_get__message_id     ${netconf_file}    get    delay-management
    run keyword and continue on failure   Should not be empty    ${del}
    FOR    ${i}    IN   @{param_res}
        ${res}=    validate_netconf_reply_message      ${netconf_file}    get
	...     delay-management    bandwidth-scs-delay-state    ${i}
        run keyword and continue on failure   Should not be empty    ${res}
    END
