*** Settings ***
Documentation
...   Keywords file for CNI130136_ASIR
...   author:
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)

Variables  variables/asir_alarm_verification_table.py
Resource    CNI130136_ASiR_kw_common.robot

*** Keywords ***
Prepare KPI Alarm triggering for TC01
    Log   Prepare KPI Alarm triggering for TC01...    console=True
    gnbscf_custom.perform_bts_delta_commissioning    ${delta_kpi_configure}

Cleanup after KPI Alarm triggering for TC01
    Log   Cleanup after KPI Alarm triggering for TC01...    console=True
    gnbscf_custom.perform_bts_delta_commissioning    ${delta_kpi_deconfigure}


Set HUBMOD General Info for TC03
    gnb_asir.wait_for_asir_to_be_onair
    ${hubmod_gen_info}=   gnb_asir.get_hubmod_general_info    hubmod_sn=${APHA_0_sn}
    Set Test Variable    ${hubmod_gen_info}


Align Netact additionalText3 Content Based on SW Version on gNB
    [Arguments]    ${sw_version}

    ${legacy}    cni130136_kw.is_legacy_sw    ${sw_version}
    IF    $legacy
        Set To Dictionary
        ...    ${fid_4569_common['netact_expected'][0]}
        ...    value=${fid_4569_common['netact_expected'][0]['value']} FAN_R-{fan_id}
    END



Trigger Faults on BTS TC01
    Log   Trigger Faults on BTS TC01...    console=True
    IF    not $FAST_TRIGGER
        Prepare ANTANTL on APHA with sn:${APHA_0_sn} fault generation.
        Prepare ANTANTL on APHA with sn:${APHA_1_sn} fault generation.
    END
    Trigger prepared KPI alarms
    Fault_verifier.wait_for_alarm_activation    4569    awaiting_time=${300}
    Fault_verifier.wait_for_alarm_activation    4570    awaiting_time=${300}
    Fault_verifier.wait_for_alarm_activation    4571    awaiting_time=${300}



Trigger Faults on ASiR TC01
    Log    Trigger Faults on ASiR...    console=True
    gnb_asir.wait_for_asir_to_be_onair
    gnbcell.Wait For All Cells To Be OnAir    timeout=300

    Comment    Trigger ASiR Fault 4348
    Block ASiR Antenna    hubmod_sn=${APHA_0_sn}
    Fault_verifier.wait_for_alarm_activation    4479
    gnb_asir.wait_for_alarm_activation    4348

    Comment    Trigger ASiR Fault 1911
    Trigger ANTANTL fault 1911 on APHA with sn:${APHA_1_sn} from prrh 0 on antennas [0].
    Fault_verifier.wait_for_alarm_activation    4479
    gnb_asir.wait_for_alarm_activation    1911    timeout=120


Verify Alarms on BTS TC01
    [Arguments]
    ...    ${rmod_type}

    Log   Verify Alarms on BTS...    console=True

    Log   ...FID 4569...    console=True
    ${SERIAL_NO}=     cni130136_kw.get_fan_serialNo     ${${rmod_type}_0_sn}    ${RMOD_0_FAN_RUNTIME[0]}/FAN_R-${kpi_fan}
    ${DN_RUNTIME}=    Set Variable    ${RMOD_0_FAN_RUNTIME[1]}${kpi_fan}
    ${CONTAINER}=     Set Variable    ${webem_alarms}
    ${UNIT_NAME}=     Set Variable    FAN
    ${FID}=           Set Variable    ${fid_4569}
    #----------------------------------------------------------------------------------------
    &{query_placeholder}=        Create Dictionary    runtime_object=${DN_RUNTIME}
    &{expected_placeholder}=     Create Dictionary    serialNo=${SERIAL_NO}
    &{internal_queries_placeholder}=     Create Dictionary    serialNo=${SERIAL_NO}
                                                        ...   unitName=${UNIT_NAME}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${CONTAINER}
    ...    conditions=${FID}[webem]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}
    ...    internal_queries_ph=${internal_queries_placeholder}
    #----------------------------------------------------------------------------------------

    Log   ...FID 4479 related to FID 4348...    console=True
    &{query_placeholder}=        Create Dictionary    runtime_object=${RMOD_0_FAN_RUNTIME[0]}
    &{expected_placeholder}=     Create Dictionary    serialNo=${${rmod_type}_0_sn}
    &{internal_queries_placeholder}=     Create Dictionary    serialNo=${${rmod_type}_0_sn}
                                                        ...    conf_path=${RMOD_0_CONF_DN}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${webem_alarms}
    ...    conditions=${fid_4479}[webem]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}
    ...    internal_queries_ph=${internal_queries_placeholder}

    Log   ...FID 4479 related to FID 1911...    console=True
    &{query_placeholder}=        Create Dictionary    runtime_object=${RMOD_1_FAN_RUNTIME[0]}
    &{expected_placeholder}=     Create Dictionary    serialNo=${${rmod_type}_1_sn}
    &{internal_queries_placeholder}=     Create Dictionary    serialNo=${${rmod_type}_1_sn}
                                                        ...    conf_path=${RMOD_1_CONF_DN}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${webem_alarms}
    ...    conditions=${fid_4479}[webem]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}
    ...    internal_queries_ph=${internal_queries_placeholder}

    Log   ...FID 4570...    console=True
    ${SERIAL_NO}=     Set Variable    ${SFP_1_PARAMS}[1]
    ${DN_RUNTIME}=    Set Variable    ${SFP_1_PARAMS}[0]
    ${DN_CONF}=       Set Variable    ${SFP_1_PARAMS}[2]
    ${CONTAINER}=     Set Variable    ${webem_alarms}
    ${FID}=           Set Variable    ${fid_4570}
    #----------------------------------------------------------------------------------------
    &{query_placeholder}=        Create Dictionary    runtime_object=${DN_RUNTIME}
    &{expected_placeholder}=     Create Dictionary    serialNo=${SERIAL_NO}
    &{internal_queries_placeholder}=     Create Dictionary    serialNo=${SERIAL_NO}
                                                        ...    conf_path=${DN_CONF}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${CONTAINER}
    ...    conditions=${FID}[webem]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}
    ...    internal_queries_ph=${internal_queries_placeholder}
    #----------------------------------------------------------------------------------------
    Log   ...FID 4571...    console=True
    ${SERIAL_NO}=     Set Variable    ${LANE_1_PARAMS}[1]
    ${DN_RUNTIME}=    Set Variable    ${LANE_1_PARAMS}[0]
    ${DN_CONF}=       Set Variable    ${LANE_1_PARAMS}[2]
    ${FID}=           Set Variable    ${fid_4571}
    #----------------------------------------------------------------------------------------
    &{query_placeholder}=        Create Dictionary    runtime_object=${DN_RUNTIME}
    &{expected_placeholder}=     Create Dictionary    serialNo=${SERIAL_NO}
    &{internal_queries_placeholder}=     Create Dictionary    serialNo=${SERIAL_NO}
                                                        ...    conf_path=${DN_CONF}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${CONTAINER}
    ...    conditions=${FID}[webem]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}
    ...    internal_queries_ph=${internal_queries_placeholder}

Verify Alarms on ASiR TC01
    [Arguments]
    ...    ${rmod_type}

    Log    Verify Alarms on ASiR...    console=True

    Log   ...FID 4348...    console=True
    ${antmod_uid}=    gnb_asir.get_antmod_uid_connected_to_hubmod    hubmod_sn=${${rmod_type}_0_sn}
    ${antmod_gen_info}=    gnb_asir.get_antmod_general_info    ${antmod_uid}
    &{query_placeholder}=        Create Dictionary    so=${antmod_gen_info}[Runtime managed object]
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${webem_asir_alarms}
    ...    conditions=${fid_4348_asir}[webem]
    ...    query_ph=${query_placeholder}

    Log   ...FID 1911...    console=True
    ${antmod_uid}=    gnb_asir.get_antmod_uid_connected_to_hubmod    hubmod_sn=${${rmod_type}_1_sn}
    ${antmod_gen_info}=    gnb_asir.get_antmod_general_info    ${antmod_uid}
    &{query_placeholder}=        Create Dictionary    so=${antmod_gen_info}[Runtime managed object]/ANTRFSM_R-1/ANTANTL_R-1
                                                                                                       # due to chosen prrh and its phy antenna
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${webem_asir_alarms}
    ...    conditions=${fid_1911_asir}[webem]
    ...    query_ph=${query_placeholder}


Verify Alarms on Netact TC01
    [Arguments]
    ...    ${rmod_type}

    Log    Verify Alarms on Netact...    console=True

    ${DN_RMOD}=    Set Variable    PLMN-PLMN/${RMOD_0_FAN_RUNTIME[0]}

    Log   ...FID 4569...    console=True
    ${SERIAL_NO}=     cni130136_kw.get_fan_serialNo     ${${rmod_type}_0_sn}    ${RMOD_0_FAN_RUNTIME[0]}/FAN_R-${kpi_fan}
    ${DN_RUNTIME_WEBEM}=    Set Variable    ${RMOD_0_FAN_RUNTIME[1]}${kpi_fan}
    ${DN_RUNTIME_NETACT}=    Set Variable    ${DN_RMOD}/FAN_R-${kpi_fan}
    ${UNIT_NAME}=     Set Variable    FAN
    ${CONTAINER}=     Set Variable    ${netact_alarms}
    ${FID}=           Set Variable    ${fid_4569}
    #----------------------------------------------------------------------------------------
    ${alarm_definition}=    Set Variable    ${FID}[webem]
    ${query_parts}=    Format String    ${alarm_definition}[query]    runtime_object=${DN_RUNTIME_WEBEM}
    ${hwpath}=    get_value_of_key_from_alarm_that_fulfills_query
                            ...    ${query_parts}
                            ...    container=${webem_alarms}
                            ...    path_to_alarms=${alarm_definition}[path_to_alarms]
                            ...    path_to_key=${{['hwPath']}}
    #|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    &{query_placeholder}=        Create Dictionary    dn=${DN_RUNTIME_NETACT}
    &{expected_placeholder}=     Create Dictionary    serialNo=${SERIAL_NO}
                                               ...    unitName=${UNIT_NAME}
                                               ...    path=${hwpath}
                                               ...    fan_id=${kpi_fan}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${CONTAINER}
    ...    conditions=${FID}[netact_live]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}
    #----------------------------------------------------------------------------------------

    Log   ...FID 4479 related to FID 4348...    console=True
    ${alarm_definition}=    Set Variable    ${fid_4479}[webem]
    ${query_parts}=    Format String    ${alarm_definition}[query]    runtime_object=${RMOD_0_FAN_RUNTIME[0]}
    ${hwpath}=    get_value_of_key_from_alarm_that_fulfills_query
                            ...    ${query_parts}
                            ...    container=${webem_alarms}
                            ...    path_to_alarms=${alarm_definition}[path_to_alarms]
                            ...    path_to_key=${{['hwPath']}}
    ${suppl_alarm_info}=    get_value_of_key_from_alarm_that_fulfills_query
                            ...    ${query_parts}
                            ...    container=${webem_alarms}
                            ...    path_to_alarms=${alarm_definition}[path_to_alarms]
                            ...    path_to_key=${{['supplAlarmInfo']}}
    &{query_placeholder}=        Create Dictionary    dn=${DN_RMOD}
    &{expected_placeholder}=     Create Dictionary    serialNo=${${rmod_type}_0_sn}
                                                ...    conf_path=${RMOD_0_CONF_DN}
                                                ...    unitName=${rmod_type}
                                                ...    path=${hwpath}
                                                ...    supplAlarmInfo=${suppl_alarm_info}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${netact_alarms}
    ...    conditions=${fid_4479}[netact_live]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}

    Log   ...FID 4479 related to FID 1911...    console=True
    ${DN_RMOD}=    Set Variable    PLMN-PLMN/${RMOD_1_FAN_RUNTIME[0]}
    ${alarm_definition}=    Set Variable    ${fid_4479}[webem]
    ${query_parts}=    Format String    ${alarm_definition}[query]    runtime_object=${RMOD_1_FAN_RUNTIME[0]}
    ${hwpath}=    get_value_of_key_from_alarm_that_fulfills_query
                            ...    ${query_parts}
                            ...    container=${webem_alarms}
                            ...    path_to_alarms=${alarm_definition}[path_to_alarms]
                            ...    path_to_key=${{['hwPath']}}
    ${suppl_alarm_info}=    get_value_of_key_from_alarm_that_fulfills_query
                            ...    ${query_parts}
                            ...    container=${webem_alarms}
                            ...    path_to_alarms=${alarm_definition}[path_to_alarms]
                            ...    path_to_key=${{['supplAlarmInfo']}}
    &{query_placeholder}=        Create Dictionary    dn=${DN_RMOD}
    &{expected_placeholder}=     Create Dictionary    serialNo=${${rmod_type}_1_sn}
                                                ...    conf_path=${RMOD_1_CONF_DN}
                                                ...    unitName=${rmod_type}
                                                ...    path=${hwpath}
                                                ...    supplAlarmInfo=${suppl_alarm_info}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${netact_alarms}
    ...    conditions=${fid_4479}[netact_live]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}

    Log   ...FID 4570...    console=True
    ${SERIAL_NO}=     Set Variable    ${SFP_1_PARAMS}[1]
    ${DN_RUNTIME}=    Set Variable    ${SFP_1_PARAMS}[0]
    ${DN_CONF}=       Set Variable    ${SFP_1_PARAMS}[2]
    ${UNIT_NAME}=     Set Variable    SFP
    ${CONTAINER}=     Set Variable    ${netact_alarms}
    ${FID}=           Set Variable    ${fid_4570}
    #----------------------------------------------------------------------------------------
    ${alarm_definition}=    Set Variable    ${FID}[webem]
    ${query_parts}=    Format String    ${alarm_definition}[query]    runtime_object=${DN_RUNTIME}
    ${hwpath}=    get_value_of_key_from_alarm_that_fulfills_query
                            ...    ${query_parts}
                            ...    container=${webem_alarms}
                            ...    path_to_alarms=${alarm_definition}[path_to_alarms]
                            ...    path_to_key=${{['hwPath']}}
    #|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    &{query_placeholder}=        Create Dictionary    dn=PLMN-PLMN/${DN_RUNTIME}
    &{expected_placeholder}=     Create Dictionary    serialNo=${SERIAL_NO}
                                                ...    conf_path=${DN_CONF}
                                                ...    unitName=${UNIT_NAME}
                                                ...    path=${hwpath}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${CONTAINER}
    ...    conditions=${FID}[netact_live]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}
    #----------------------------------------------------------------------------------------
    Log   ...FID 4571...    console=True
    ${SERIAL_NO}=     Set Variable    ${LANE_1_PARAMS}[1]
    ${DN_RUNTIME}=    Set Variable    ${LANE_1_PARAMS}[0]
    ${DN_CONF}=       Set Variable    ${LANE_1_PARAMS}[2]
    ${UNIT_NAME}=     Set Variable    LANE
    ${FID}=           Set Variable    ${fid_4571}
    #----------------------------------------------------------------------------------------
    ${alarm_definition}=    Set Variable    ${FID}[webem]
    ${query_parts}=    Format String    ${alarm_definition}[query]    runtime_object=${DN_RUNTIME}
    ${hwpath}=    get_value_of_key_from_alarm_that_fulfills_query
                            ...    ${query_parts}
                            ...    container=${webem_alarms}
                            ...    path_to_alarms=${alarm_definition}[path_to_alarms]
                            ...    path_to_key=${{['hwPath']}}
    #|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    &{query_placeholder}=        Create Dictionary    dn=PLMN-PLMN/${DN_RUNTIME}
    &{expected_placeholder}=     Create Dictionary    serialNo=${SERIAL_NO}
                                                ...    conf_path=${DN_CONF}
                                                ...    unitName=${UNIT_NAME}
                                                ...    path=${hwpath}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${CONTAINER}
    ...    conditions=${FID}[netact_live]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}

Verify Asir Alarms on Netact TC01
    [Arguments]
    ...    ${rmod_type}

    Log    Verify Asir Alarms on Netact...    console=True

    Log   ...FID 4348...    console=True
    ${antmod_sn}=    gnb_asir.get_antmod_sn_connected_to_hubmod    hubmod_sn=${${rmod_type}_0_sn}
    ${antmod_uid}=    gnb_asir.get_antmod_uid_connected_to_hubmod    hubmod_sn=${${rmod_type}_0_sn}
    ${antmod_gen_info}=    gnb_asir.get_antmod_general_info    ${antmod_uid}
    &{query_placeholder}=        Create Dictionary    dn=PLMN-PLMN/${antmod_gen_info}[Runtime managed object]
    &{expected_placeholder}=     Create Dictionary
                                                ...    path=${antmod_gen_info}[Runtime managed object]
                                                ...    serialNo=${antmod_sn}
                                                ...    antPortRDN=${antmod_gen_info}[Managed object]
                                                ...    chainPosition=${antmod_gen_info}[Position in chain]
                                                ...    conf_path=${antmod_gen_info}[Paired managed object]
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${netact_asir_alarms}
    ...    conditions=${fid_4348_asir}[netact_live]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}

    Log   ...FID 1911...    console=True
    ${antmod_sn}=    gnb_asir.get_antmod_sn_connected_to_hubmod    hubmod_sn=${${rmod_type}_1_sn}
    ${antmod_uid}=    gnb_asir.get_antmod_uid_connected_to_hubmod    hubmod_sn=${${rmod_type}_1_sn}
    ${antmod_gen_info}=    gnb_asir.get_antmod_general_info    ${antmod_uid}
    &{query_placeholder}=        Create Dictionary    dn=PLMN-PLMN/${antmod_gen_info}[Runtime managed object]/ANTRFSM_R-1/ANTANTL_R-1
                                                                                                       # due to chosen prrh and its phy antenna
    &{expected_placeholder}=     Create Dictionary
                                                ...    path=${antmod_gen_info}[Runtime managed object]/ANTRFSM_R-1/ANTANTL_R-1
                                                ...    serialNo=${antmod_sn}-1-1                       # due to chosen prrh and its phy antenna
                                                ...    antPortRDN=${antmod_gen_info}[Managed object]
                                                ...    chainPosition=${antmod_gen_info}[Position in chain]
                                                ...    conf_path=${antmod_gen_info}[Paired managed object]/ANTRFSM-1/ANTANTL-1
                                                                                                       # due to chosen prrh and its phy antenna
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${netact_asir_alarms}
    ...    conditions=${fid_1911_asir}[netact_live]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}

Verify Alarms Netact Snapshot TC01
    [Arguments]
    ...    ${rmod_type}

    Log    Verify Alarms Netact Snapshot...    console=True

    ${DN_RMOD}=    Set Variable    PLMN-PLMN/${RMOD_0_FAN_RUNTIME[0]}

    Log   ...FID 4479 related to FID 4348...    console=True
    ${alarm_definition}=    Set Variable    ${fid_4479}[webem]
    ${query_parts}=    Format String    ${alarm_definition}[query]    runtime_object=${RMOD_0_FAN_RUNTIME[0]}
    ${hwpath}=    get_value_of_key_from_alarm_that_fulfills_query
                            ...    ${query_parts}
                            ...    container=${webem_alarms}
                            ...    path_to_alarms=${alarm_definition}[path_to_alarms]
                            ...    path_to_key=${{['hwPath']}}
    ${suppl_alarm_info}=    get_value_of_key_from_alarm_that_fulfills_query
                            ...    ${query_parts}
                            ...    container=${webem_alarms}
                            ...    path_to_alarms=${alarm_definition}[path_to_alarms]
                            ...    path_to_key=${{['supplAlarmInfo']}}
    &{query_placeholder}=        Create Dictionary    dn=${DN_RMOD}
    &{expected_placeholder}=     Create Dictionary    serialNo=${${rmod_type}_0_sn}
                                                ...    conf_path=${RMOD_0_CONF_DN}
                                                ...    unitName=${rmod_type}
                                                ...    path=${hwpath}
                                                ...    supplAlarmInfo=${suppl_alarm_info}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${netact_export}
    ...    conditions=${fid_4479}[netact_snap]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}

    Log   ...FID 4479 related to FID 1911...    console=True
    ${DN_RMOD}=    Set Variable    PLMN-PLMN/${RMOD_1_FAN_RUNTIME[0]}
    ${alarm_definition}=    Set Variable    ${fid_4479}[webem]
    ${query_parts}=    Format String    ${alarm_definition}[query]    runtime_object=${RMOD_1_FAN_RUNTIME[0]}
    ${hwpath}=    get_value_of_key_from_alarm_that_fulfills_query
                            ...    ${query_parts}
                            ...    container=${webem_alarms}
                            ...    path_to_alarms=${alarm_definition}[path_to_alarms]
                            ...    path_to_key=${{['hwPath']}}
    ${suppl_alarm_info}=    get_value_of_key_from_alarm_that_fulfills_query
                            ...    ${query_parts}
                            ...    container=${webem_alarms}
                            ...    path_to_alarms=${alarm_definition}[path_to_alarms]
                            ...    path_to_key=${{['supplAlarmInfo']}}
    &{query_placeholder}=        Create Dictionary    dn=${DN_RMOD}
    &{expected_placeholder}=     Create Dictionary    serialNo=${${rmod_type}_1_sn}
                                                ...    conf_path=${RMOD_1_CONF_DN}
                                                ...    unitName=${rmod_type}
                                                ...    path=${hwpath}
                                                ...    supplAlarmInfo=${suppl_alarm_info}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${netact_export}
    ...    conditions=${fid_4479}[netact_snap]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}

Verify Alarms on BTS TC03
    Log   Verify Alarms on BTS...    console=True
    Log   ...FID 10...    console=True
    ${SERIAL_NO}=     Set Variable    ${APHA_0_sn}
    ${DN_RUNTIME}=    Set Variable    ${RMOD_0_FAN_RUNTIME[0]}
    ${DN_CONF}=       Set Variable    ${RMOD_0_CONF_DN}
    ${RMOD_TYPE}=     Set Variable    APHA
    ${CONTAINER}=     Set Variable    ${webem_alarms}
    ${FID}=           Set Variable    ${fid_10}
    #----------------------------------------------------------------------------------------
    &{query_placeholder}=        Create Dictionary    runtime_object=${DN_RUNTIME}
    &{expected_placeholder}=     Create Dictionary    serialNo=${SERIAL_NO}
    &{internal_queries_placeholder}=     Create Dictionary    serialNo=${SERIAL_NO}
                                                        ...    conf_path=${DN_CONF}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${CONTAINER}
    ...    conditions=${FID}[webem]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}
    ...    internal_queries_ph=${internal_queries_placeholder}

Verify Alarms on ASiR TC03

    Log    Verify Alarms on ASiR...    console=True

    Log   ...FID 10...    console=True
    &{query_placeholder}=        Create Dictionary    so=${hubmod_gen_info}[Runtime Managed Object]
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${webem_asir_alarms}
    ...    conditions=${fid_10_asir}[webem]
    ...    query_ph=${query_placeholder}


Verify Alarms on Netact TC03
    Log    Verify Alarms Netact TC03...    console=True

    Log   ...FID 10...    console=True
    ${SERIAL_NO}=     Set Variable    ${APHA_0_sn}
    ${DN_RUNTIME}=    Set Variable    ${RMOD_0_FAN_RUNTIME[0]}
    ${DN_CONF}=       Set Variable    ${RMOD_0_CONF_DN}
    ${RMOD_TYPE}=     Set Variable    APHA
    ${CONTAINER}=     Set Variable    ${netact_alarms}
    ${FID}=           Set Variable    ${fid_10}
    #----------------------------------------------------------------------------------------
    ${alarm_definition}=    Set Variable    ${FID}[webem]
    ${query_parts}=    Format String    ${alarm_definition}[query]    runtime_object=${DN_RUNTIME}
    ${hwpath}=    get_value_of_key_from_alarm_that_fulfills_query
                            ...    ${query_parts}
                            ...    container=${webem_alarms}
                            ...    path_to_alarms=${alarm_definition}[path_to_alarms]
                            ...    path_to_key=${{['hwPath']}}
    ${supplAlarmInfo}=    get_value_of_key_from_alarm_that_fulfills_query
                            ...    ${query_parts}
                            ...    container=${webem_alarms}
                            ...    path_to_alarms=${alarm_definition}[path_to_alarms]
                            ...    path_to_key=${{['supplAlarmInfo']}}
    #|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    &{query_placeholder}=        Create Dictionary    dn=PLMN-PLMN/${DN_RUNTIME}
    &{expected_placeholder}=     Create Dictionary    serialNo=${SERIAL_NO}
                                                ...    conf_path=${DN_CONF}
                                                ...    unitName=${RMOD_TYPE}
                                                ...    path=${hwpath}
                                                ...    supplAlarmInfo=${supplAlarmInfo}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${CONTAINER}
    ...    conditions=${FID}[netact_live]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}
    #----------------------------------------------------------------------------------------

Verify Asir Alarms on Netact TC03

    Log    Verify Asir Alarms on Netact...    console=True

    Log   ...FID 10...    console=True
    &{query_placeholder}=        Create Dictionary    dn=PLMN-PLMN/${hubmod_gen_info}[Runtime Managed Object]
    &{expected_placeholder}=     Create Dictionary
                                                ...    path=${hubmod_gen_info}[Runtime Managed Object]
                                                ...    serialNo=Unknown
                                                ...    conf_path=${hubmod_gen_info}[Paired Managed Object]
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${netact_asir_alarms}
    ...    conditions=${fid_10_asir}[netact_live]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}


TC01 Teardown
    Log    TC01 Teardown...    console=True
    gnb_asir.wait_for_asir_to_be_onair
    Unblock ASiR Antenna    hubmod_sn=${APHA_0_sn}
    gnb_asir.wait_for_alarm_deactivation    4348
    Clear ANTANTL fault 1911 on APHA with sn:${APHA_1_sn} from prrh 0.
    gnb_asir.wait_for_alarm_deactivation    1911
    Clear KPI Alarms
    Fault_verifier.wait_for_alarm_deactivation    4570
    Fault_verifier.wait_for_alarm_deactivation    4571
    Cleanup after KPI Alarm triggering for TC01
    IF    not $FAST_CLEAR
        Clear ANTANTL on APHA with sn:${APHA_0_sn} fault generation, skip reboot.
        Clear Fault 1932 on APHA with sn:${APHA_0_sn} from fan(s) [1-4], skip reboot.
        Clear Fault 1933 on APHA with sn:${APHA_0_sn} from fan(s) [1-4].
        Clear ANTANTL on APHA with sn:${APHA_1_sn} fault generation.
    END
