*** Settings ***
Documentation
...   Keywords file for CNI130136_ASIR
...   author:
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)

Variables  variables/asir_alarm_verification_table.py
Resource    CNI130136_ASiR_kw_common.robot
Library     taf.rfrl.csv4all.CSV4AllTestCases
Library     taf.rfrl.csv4all.resources.utilities.utilities                WITH NAME    csv4all_utilities

Library    OperatingSystem
Library    taf/rfrl/procedures/resources/python/sw_update/SW_update.py                  WITH NAME  sw_update
Resource    taf/rfrl/procedures/resources/robot/SwUpdate.robot

*** Keywords ***
Custom Suite C ASIR Setup
    Log Variables
    Custom Set Suite UUF Variables
    Custom Suite ASIR Setup

Try set 5G_SOURCE_SW
    TRY
        ${build}=    csv4all_utilities.Get Source SW
    EXCEPT    FatalError: No Build selected
        Log    Unable to set 5G_SOURCE_SW based on CM_TAGS, setting from 5G_TARGET_SW    level=WARN
        ${build}=    Set Variable  ${5G_TARGET_SW}
    END
    RETURN    ${build}

Custom Set Suite UUF Variables
    Run Keyword And Ignore Error
    ...    Log    CM_EXECUTION_ID: %{CM_EXECUTION_ID}\nCM_ARTIFACTS: %{CM_ARTIFACTS}\nCM_TAGS: %{CM_TAGS}
    ${5G_TARGET_SW}=    Run Keyword If  '${5G_TARGET_SW}'=='${None}'
    ...                     csv4all_utilities.Get Target SW
    ...                 ELSE
    ...                     Set Variable  ${5G_TARGET_SW}
    Set Suite Variable    $5G_TARGET_SW
    ${5G_SOURCE_SW}=    Run Keyword If  '${5G_SOURCE_SW}'=='${None}'
    ...                     Try set 5G_SOURCE_SW
    ...                 ELSE
    ...                     Set Variable  ${5G_SOURCE_SW}
    Set Suite Variable    $5G_SOURCE_SW

    &{NODE1}    Create Dictionary    testline_object=${tl.gnbs[0]}
    ...                              source_sw=${5G_SOURCE_SW}
    ...                              target_sw=${5G_TARGET_SW}
    ...                              custom_allowed_alarms=${CUSTOM_ALARMS}
    Set Suite Variable    $NODE1

    @{NODES}    Create List    ${NODE1}
    Set Suite Variable    $NODES

    Log    5G_SOURCE_SW: ${5G_SOURCE_SW}\n5G_TARGET_SW: ${5G_TARGET_SW}
    Log    NODES: ${NODES}

Update SW
    [Arguments]      ${sw_version}
    ...              ${sw_target}
    ...              ${timeout}
    ...              ${path}
    ...              ${connection}
    ...              ${bts_type}=GNB

    Robot Log Operation                                   Updating SW and waiting for BTS to reach OnAir state...

    OperatingSystem.Create Directory    ${path}
    Download And Update SW                                path=${path}
    ...                                                   sw_version=${sw_version}
    ...                                                   sw_target=${sw_target}
    ...                                                   timeout=${timeout}

    Robot Log Step                                        Software has been updated, waiting for BTS startup...

    Wait Until Keyword Succeeds                           10min
    ...                                                   20sec
    ...                                                   Check if SW target version is uploaded
    ...                                                   sw_version=${sw_version}
    ...                                                   sw_target=${sw_target}

    Wait Until Keyword Succeeds                           10min
    ...                                                   20sec
    ...                                                   Confirm RFSW Compability
    ...                                                   bts_type=${bts_type}

    Check Statuses of BTS Components after SW update      connection=${connection}
    ...                                                   bts_type=${bts_type}

    Robot Log Result                                      BTS in OnAir state.
    ...                                                   to_console=${True}

Check if SW target version is uploaded
    [Arguments]      ${sw_version}
    ...              ${sw_target}

    Robot Log Operation                                   Veryfing if SW tagrget version is currently uploaded...
    ${current_sw_version}                                 sw_update.get_sw_version
    ${type}    Evaluate    type($current_sw_version)
    ${current_sw_version}    Evaluate    $current_sw_version.raw
    ${expected_sw_version}                                sw_update.get_sw_version_with_test_package_variant
    ...                                                   sw_version=${sw_version}
    ...                                                   test_package_variant=${sw_target}
    ${type}    Evaluate    type($expected_sw_version)
    ${expected_sw_version}    Evaluate    $expected_sw_version.raw
    ${current_sw_version}    cni130136_kw.correct_sw_version    ${current_sw_version}

    Should Be Equal As Strings    ${current_sw_version}   ${expected_sw_version}
    ...                                                   msg=Current sw_version should be ${current_sw_version} but is ${expected_sw_version}
    Robot Log Result                                      Current SW version is ${current_sw_version}


Trigger Initial Faults, Get Netact Snapshot and Upgrade SW if needed

    Log    Trigger Initial Faults, Get Netact Snapshot and Upgrade SW if needed...    console=True
    ${base_snapshot}=    Get Variable Value    ${{[None, None, $base_snapshot]}}    ${{$tl.base_snapshot_25R3}}
    ${old_snapshot}=    Get Variable Value    ${old_snapshot}    ${base_snapshot}
    ${fid10_triggered}=    Set Variable    ${False}

    IF    not $old_snapshot
        Log    ... old_snapshot was set to ${old_snapshot} so Get Alarms and Netact Snap...    console=True
        Trigger FID 10 on ${RMOD_1_CONF_DN} by lane locking.
        ${fid10_triggered}=    Set Variable    ${True}
        Get alarms from BTS
        Builtin.Sleep    20
        Get alarms from Netact
        ${old_snapshot}=    Trigger and Get Netact Report Snapshot    report_ident=old_build

        Set Suite Variable    ${old_snapshot}
        Clear FID 10 on ${RMOD_1_CONF_DN} by lane unlocking.
        ${fid10_triggered}=    Set Variable    ${False}
        gnbcell.Wait For All Cells To Be OnAir    timeout=300
        Log    ... and do SW Upgrade. old_snapshot is now: ${old_snapshot}    console=True

        ${connection}    connections.get_default_admin_connection_alias
        ${download_path}    Set Variable    /home/ute/Downloads
        Check if SW target version is uploaded
        ...          sw_version=${NODE1}[source_sw]
        ...          sw_target=basic_sw

        Update SW    sw_version=${NODE1}[target_sw]
        ...          sw_target=basic_sw
        ...          timeout=600
        ...          path=${download_path}
        ...          connection=${connection}
        ...          bts_type=GNB
    ELSE
        Log    ... old_snapshot was already set to ${old_snapshot}, getting Alarm, Snap and SW Upgrade not needed.    console=True
        Set Suite Variable    ${old_snapshot}
    END
    Wait For Site To Be Onair  timeout=300
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    Builtin.Sleep    10

    [Teardown]    Run Keyword If    $fid10_triggered == True    Clear FID 10 on ${RMOD_1_CONF_DN} by lane unlocking.


Trigger Fault 4479 on BTS by blocking ASiR Antenna
    [Arguments]    ${hubmod_sn}

    Log    Trigger Fault 4479 on BTS by blocking ASiR Antenna...    console=True
    gnb_asir.wait_for_asir_to_be_onair

    Comment    Trigger ASiR Fault 4348
    Block ASiR Antenna    ${hubmod_sn}
    Fault_verifier.wait_for_alarm_activation    4479
    gnb_asir.wait_for_alarm_activation    4348



Clear Fault 4479 on BTS by unblocking ASiR Antenna
    [Arguments]    ${hubmod_sn}

    Log    Clear Fault 4479 on BTS by unblocking ASiR Antenna...    console=True
    gnb_asir.wait_for_asir_to_be_onair
    Unblock ASiR Antenna    ${hubmod_sn}
    gnb_asir.wait_for_alarm_deactivation    4348
    gnb_asir.wait_for_alarm_deactivation    4479


Change ASIRMOD ID
    [Arguments]    ${asir_sn}    ${asir_conf_dn}    ${new_id}
    gnb_asir.wait_for_asir_to_be_onair
    ${hubmod_id}=    gnb_asir.get_hubmod_id    ${asir_sn}
    gnb_asir.change_asirmod_id_in_hubmod    ${hubmod_id}    ${new_id}
    gnbscf_custom.change_object_id    ${asir_conf_dn}    ${new_id}


Exchange ASIRMODs
    [Arguments]    ${asir_sn1}    ${asir_conf_dn1}    ${asir_sn2}    ${asir_conf_dn2}
    gnb_asir.wait_for_asir_to_be_onair
    ${hubmod_id1}=    gnb_asir.get_hubmod_id    ${asir_sn1}
    ${hubmod_id2}=    gnb_asir.get_hubmod_id    ${asir_sn2}
    gnb_asir.change_asirmods_id_in_2_hubmods_at_once
                                                ...    ${hubmod_id1}    ${asir_conf_dn2.rsplit('-', 1)[1]}
                                                ...    ${hubmod_id2}    ${asir_conf_dn1.rsplit('-', 1)[1]}
    gnbscf_custom.exchange_objects    ${asir_conf_dn1}    ${asir_conf_dn2}


Netact Get Snapshot Compare
    [Arguments]
    ...    ${report1_name}
    ...    ${report2_name}

    Log    Netact Get Snapshot Compare...    console=True
    @{time} = 	Builtin.Get Time 	year month day hour min sec    time_=UTC
    ${time_suffix}=    Set Variable    _${time[0]}${time[1]}${time[2]}_${time[3]}${time[4]}${time[5]}_UTC
    ${out}=   netact_custom.reports_compare
    ...    ${report1_name}
    ...    ${report2_name}
    ...    compare_report_name=${WORKING_SET}_cmp${time_suffix}
    ...    description=CNI130136 Netact get snapshot compare
    ...    alias=${NETACT_NAME}
    Log    ${out}  #  console=True
    ${file_path}=   netact_custom.reports_export_and_get_file    report_name=${WORKING_SET}_cmp${time_suffix}
    ...  local_dir=${NETACT_EXPORTS}    cleanup=True    alias=${NETACT_NAME}
    ${out}=   netact_custom.reports_list    alias=${NETACT_NAME}
    Log    ${out}    console=False

    [Return]    ${file_path}


Verify Alarms Netact Compare TC09
    [Arguments]
    ...    ${file_path}

    Log    Verify Alarms Netact Compare TC09...    console=True

    ${netact_compare}=    cni130136_kw.get_data_from_json_file
                ...    ${file_path[0]}/${file_path[1]}

    Log   ...FID 61648...    console=True
    ${DN_RMOD}=    Set Variable    PLMN-PLMN/${RMOD_0_FAN_RUNTIME[0]}
    ${alarm_definition}=    Set Variable    ${fid_61648}[webem]
    ${query_parts}=    Format String    ${alarm_definition}[query]    runtime_object=${RMOD_0_FAN_RUNTIME[0]}
    ${hwpath}=    get_value_of_key_from_alarm_that_fulfills_query
                            ...    ${query_parts}
                            ...    container=${webem_alarms}
                            ...    path_to_alarms=${alarm_definition}[path_to_alarms]
                            ...    path_to_key=${{['hwPath']}}
    &{query_placeholder}=        Create Dictionary    dn=${DN_RMOD}
    &{expected_placeholder}=     Create Dictionary    serialNo=${APHA_0_sn}
                                                ...    conf_path=${RMOD_0_CONF_DN}
                                                ...    unitName=APHA
                                                ...    path=${hwpath}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${netact_compare}
    ...    conditions=${fid_61648}[netact_compare_remaining]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}

Verify Alarms Netact Compare TC10
    [Arguments]
    ...    ${file_path}

    Log    Verify Alarms Netact Compare TC10...    console=True

    ${netact_compare}=    cni130136_kw.get_data_from_json_file
                ...    ${file_path[0]}/${file_path[1]}

    Log   ...FID 10...    console=True
    ${DN_RMOD2}=    Set Variable    PLMN-PLMN/${RMOD_2_FAN_RUNTIME[0]}
    ${alarm_definition}=    Set Variable    ${fid_10}[webem]
    ${query_parts}=    Format String    ${alarm_definition}[query]    runtime_object=${RMOD_2_FAN_RUNTIME[0]}
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
    &{query_placeholder}=        Create Dictionary    dn=${DN_RMOD2}
    &{expected_placeholder}=     Create Dictionary    serialNo=${APHA_2_sn}
                                                ...    conf_path=${RMOD_2_CONF_DN}
                                                ...    unitName=APHA
                                                ...    path=${hwpath}
                                                ...    supplAlarmInfo=${supplAlarmInfo}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${netact_compare}
    ...    conditions=${fid_10}[netact_compare_new]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}                                    # TODO: add cancelledAlarms

Verify Alarms Netact Compare TC11
    [Arguments]
    ...    ${file_path}

    Log    Verify Alarms Netact Compare TC11...    console=True

    ${netact_compare}=    cni130136_kw.get_data_from_json_file
                ...    ${file_path[0]}/${file_path[1]}

    Log   ...FID 4479 related to FID 4348...    console=True
    ${DN_RMOD}=    Set Variable    PLMN-PLMN/${RMOD_0_FAN_RUNTIME[0]}
    ${alarm_definition}=    Set Variable    ${fid_4479}[webem]
    ${query_parts}=    Format String    ${alarm_definition}[query]    runtime_object=${RMOD_0_FAN_RUNTIME[0]}
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
    &{query_placeholder}=        Create Dictionary    dn=${DN_RMOD}
    &{expected_placeholder}=     Create Dictionary    serialNo=${APHA_0_sn}
                                                ...    conf_path=${RMOD_0_CONF_DN}
                                                ...    unitName=APHA
                                                ...    path=${hwpath}
                                                ...    supplAlarmInfo=${supplAlarmInfo}
    cni130136_kw.verify_value_of_key_from_alarm
    ...    container=${netact_compare}
    ...    conditions=${fid_4479}[netact_compare_new]
    ...    query_ph=${query_placeholder}
    ...    expected_ph=${expected_placeholder}

Verify Dist Names Change after ASIRMOD ID Change and set New RMOD Variables for Test Case TC09
    ${APHA_0_sn_old}=            Set Variable    ${APHA_0_sn}
    ${RMOD_0_FAN_RUNTIME_old}=    Set Variable    ${RMOD_0_FAN_RUNTIME}
    ${RMOD_0_CONF_DN_old}=        Set Variable    ${RMOD_0_CONF_DN}

    Set RMOD Variables for Test Case    rmod_type=APHA    rmod_id=0    rmod_list=${RMOD_LIST}

    Should Be Equal    ${APHA_0_sn_old}    ${APHA_0_sn}
    Should Not Be Equal    ${RMOD_0_FAN_RUNTIME_old[0]}    ${RMOD_0_FAN_RUNTIME[0]}
    Should Not Be Equal    ${RMOD_0_CONF_DN_old}    ${RMOD_0_CONF_DN}


Verify Dist Names Change after ASIRMOD Exchange and set New RMOD Variables for Test Case TC10
    ${APHA_1_sn_old}=             Set Variable    ${APHA_1_sn}
    ${RMOD_1_FAN_RUNTIME_old}=    Set Variable    ${RMOD_1_FAN_RUNTIME}
    ${RMOD_1_CONF_DN_old}=        Set Variable    ${RMOD_1_CONF_DN}
    ${APHA_2_sn_old}=             Set Variable    ${APHA_2_sn}
    ${RMOD_2_FAN_RUNTIME_old}=    Set Variable    ${RMOD_2_FAN_RUNTIME}
    ${RMOD_2_CONF_DN_old}=        Set Variable    ${RMOD_2_CONF_DN}

    Set RMOD Variables for Test Case    rmod_type=APHA    rmod_id=1    rmod_list=${RMOD_LIST}
    Set RMOD Variables for Test Case    rmod_type=APHA    rmod_id=2    rmod_list=${RMOD_LIST}

    Should Be Equal    ${APHA_1_sn_old}                ${APHA_1_sn}
    Should Be Equal    ${RMOD_2_FAN_RUNTIME_old[0]}    ${RMOD_1_FAN_RUNTIME[0]}
    Should Be Equal    ${RMOD_2_CONF_DN_old}           ${RMOD_1_CONF_DN}

    Should Be Equal    ${APHA_2_sn_old}                ${APHA_2_sn}
    Should Be Equal    ${RMOD_1_FAN_RUNTIME_old[0]}    ${RMOD_2_FAN_RUNTIME[0]}
    Should Be Equal    ${RMOD_1_CONF_DN_old}           ${RMOD_2_CONF_DN}


TC09 Teardown
    [Arguments]    ${hubmod_sn}

    Log    TC09 Teardown ${hubmod_sn}...    console=True
    gnb_asir.wait_for_asir_to_be_onair
    IF    $ASIRMOD_ID_CHANGED
        Change ASIRMOD ID    asir_sn=${APHA_0_sn}
        ...    asir_conf_dn=MRBTS-78155/EQM-1/APEQM-1/ASIRMOD-10    new_id=1
        Set Suite Variable    ${ASIRMOD_ID_CHANGED}    ${False}
    END
    gnbcell.Wait For All Cells To Be OnAir    timeout=300

TC10 Teardown

    Log    TC10 Teardown...    console=True
    IF    $ASIRMOD_ID_CHANGED
        Clear FID 10 on ${RMOD_2_CONF_DN} by lane unlocking.
        Exchange ASIRMODs    asir_sn1=${APHA_1_sn}    asir_conf_dn1=MRBTS-78155/EQM-1/APEQM-1/ASIRMOD-3
                      ...    asir_sn2=${APHA_2_sn}    asir_conf_dn2=MRBTS-78155/EQM-1/APEQM-1/ASIRMOD-2
        Set Suite Variable    ${ASIRMOD_ID_CHANGED}    ${False}
    END
    gnbcell.Wait For All Cells To Be OnAir    timeout=300

TC11 Teardown
    [Arguments]    ${hubmod_sn}

    Log    TC11 Teardown ${hubmod_sn}...    console=True
    Clear Fault 4479 on BTS by unblocking ASiR Antenna    ${hubmod_sn}
