*** Settings ***

*** Variables ***

*** Keywords ***
Set traffic type to internal
    Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal

Attach ue with '${pattern}'capability to 5g cell
    Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
    ${ue_ability}    Obtain Ue Capability    ${pattern}
    Airphone SA Attach    ue_id=${UE_ID}    ue_capability=${ue_ability}
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
    Wait '1s' for stabible

Attach SA ue to 5g cell
    [Arguments]    ${pattern}    ${UE_ID}    ${PDU_ID}=1    ${GW_ID}=1    ${SLICE_ID}=1
    Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
    ${ue_ability}    Obtain Ue Capability    ${pattern}
    Airphone SA Attach    ue_id=${UE_ID}    ue_capability=${ue_ability}
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
    Wait '1s' for stabible

Internal send '${dl_data}' DL data and '${ul_data}' UL data
    Airphone SA Start Data Traffic    ${UE_ID}    DL    ${dl_data}    pdu_id=${PDU_ID}
    Airphone SA Start Data Traffic    ${UE_ID}    UL    ${ul_data}    pdu_id=${PDU_ID}
    Wait '1s' for stabible

Internal send mutiple trf '${number}' for each '${dl_data}' DL data
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${UE_ID}    DL    ${dl_data}    pdu_id=${PDU_ID}    duration=6000s    trf_id=${num}
    END

SA send mutiple trf dl data
    [Arguments]    ${ue_id}    ${number}    ${dl_data}    ${pdu_id}=1    ${protocol}=udp
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${ue_id}    DL    ${dl_data}    pdu_id=${pdu_id}    duration=6000s    trf_id=${num}    
        ...    protocol=${protocol}
    END

SA send mutiple trf ul data
    [Arguments]    ${ue_id}    ${number}    ${ul_data}    ${pdu_id}=1    ${protocol}=udp
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${ue_id}    UL    ${ul_data}    pdu_id=${pdu_iD}    duration=6000s    trf_id=${num}    
        ...    protocol=${protocol}
    END

SA send dl and ul data
    [Arguments]    ${ue_id}    ${number}=4    ${dl_data}=175M    ${ul_data}=20M    ${pdu_id}=1    ${protocol}=udp
    SA send mutiple trf dl data    ${ue_id}    ${number}    ${dl_data}    ${pdu_id}    ${protocol}
    SA send mutiple trf ul data    ${ue_id}    ${number}    ${ul_data}    ${pdu_id}    ${protocol}

NSA send mutiple trf dl data
    [Arguments]    ${ue_id}    ${number}    ${dl_data}    ${protocol}=udp
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone NSA Start Data Traffic    ${ue_id}    DL    ${dl_data}    duration=6000s    trf_id=${num}    
        ...    protocol=${protocol}
    END

NSA send mutiple trf ul data
    [Arguments]    ${ue_id}    ${number}    ${ul_data}    ${protocol}=udp
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone NSA Start Data Traffic    ${ue_id}     UL    ${ul_data}    duration=6000s    trf_id=${num}    
        ...    protocol=${protocol}
    END

NSA send dl and ul data
    [Arguments]    ${ue_id}    ${number}=4    ${dl_data}=175M    ${ul_data}=20M    ${protocol}=udp
    NSA send mutiple trf dl data    ${ue_id}    ${number}    ${dl_data}    ${protocol}    
    NSA send mutiple trf ul data    ${ue_id}    ${number}    ${ul_data}    ${protocol}

Detach UE
    airphone_sa_detach    ue_id=${UE_ID}    timeout=30

Detach UE '${id}'
    airphone_sa_detach    ue_id=${id}    timeout=30

Stop data transfer
    airphone_sa_stop_data_traffic    ue_id=${UE_ID}    direction=dl

UE send A1 event
    airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50

Attach '${uenum}' ue with '${pattern}'capability to 5g cell
    ${ue_ability}    Obtain Ue Capability    ${pattern}
    FOR    ${num}    IN RANGE    1    ${uenum}+1
        Airphone SA Attach    ue_id=${num}    ue_capability=${ue_ability}
        Wait '2s' for stabible
        Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}
        Wait '3s' for stabible
    END

Detach '${UENUM}' UE
    FOR    ${num}    IN RANGE    1    ${UENUM}+1
        airphone_sa_detach    ue_id=${num}    timeout=30
    END

NSA send ue '${ue_id}' mutiple trf '${number}' for each '${dl_data}' DL data
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone NSA Start Data Traffic    ${ue_id}     DL    ${dl_data}    duration=6000s    trf_id=${num}    protocol=tcp
    END
    Wait Throughput Timer    5s

NSA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone NSA Start Data Traffic    ${ue_id}     UL    ${ul_data}    duration=6000s    trf_id=${num}    protocol=tcp
    END
    Wait Throughput Timer    5s


NSA attach ue '${ue_id}' with '${nr_pat}' cap and '${eutra_nr_pat}' eutra cap to 5g cell
    Log To Console    attach ue
    ${nr_cap}    Obtain Ue Capability    ${nr_pat}
    ${eutra_nr_cap}    Obtain Ue Capability    ${eutra_nr_pat}
    Airphone Nsa Attach    ${ue_id}    ue_nr_capabilities=${nr_cap}    ue_eutra_nr_capabilities=${eutra_nr_cap}

Send ue '${ue_id}' A1 event
    airphone_execute_egate_command    ue_measurement_send_nr id\=${ue_id} meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50

Enable AP syslog debug
	# SYSLOG output severity prints (0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable)
	Modify AP swconfig	 0x10040:1
	# SYSLOG input severity prints: 0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable
	Add AP swconfig	 0x1003F:1