*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: CB010925 test cases

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_BTS_Site_Reset.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/resources/NJ_Resources/Resources/robot/DevNJ_UE_keywords.robot
Resource    ./resources/pdu.robot
Library     taf/rfrl/procedures/resources/python/connections.py           WITH NAME  connections
Library     taf/rfrl/procedures/resources/python/swconfig/swconfig_operations.py
Library     taf.hw.rf_attenuator
Library     taf.sbts.oam.coam.admin                      WITH NAME  admin
Library     on_air_tl_preparation/testline_preparation_resources.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/data_transfer_configuration.py
Variables   ./resources/delta.py
Variables   ./resources/cells.py

*** Variables ***
${BTS122_addr}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${BTS150_addr}     ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${BTS129_addr}     ${tl.gnbs[2].cu.oam_http_connection_details.addr}
${SW_DIR}    /home/ute/.ute-ca/cache/bts
@{additional_allowed_alarms}
...  PPS reference missing
...  TD-LTE radio disabled

*** Keywords ***
Perform Bidirectional Data Transfer With Throughput Verification
    [Arguments]    ${ue_index}    ${duration}    ${dl_throughput}    ${ul_throughput}    ${max_deviation}
    UE Attach And Start ADB Log    ue_index=${ue_index}
    Set Default Gateway    ue_index=1
    Sleep    15s
    wait until keyword succeeds    4x     10sec
    ...    Start DL Async Process    ${ue_index}    ${dl_throughput}    ${duration}
    Start UL Async Process    ${ue_index}    ${ul_throughput}    ${duration}
    Sleep    ${duration}
    Calculate and Verify DL Async Tput    ${ue_index}    ${dl_throughput}    ${max_deviation}    0s
    Calculate and Verify UL Async Tput    ${ue_index}    ${ul_throughput}    ${max_deviation}    0s
    Postconditions_ForUE

Start Bidirectional Data Transfer
    [Arguments]    ${ue_index}    ${duration}    ${dl_throughput}    ${ul_throughput}
    UE Attach And Start ADB Log    ue_index=${ue_index}
    Set Default Gateway    ue_index=1
    Sleep    15s
    Start DL Async Process    ${ue_index}    ${dl_throughput}    ${duration}
    Start UL Async Process    ${ue_index}    ${ul_throughput}    ${duration}

Verify Bidirectional Data Transfer Throughput
    [Arguments]    ${ue_index}    ${dl_throughput}    ${ul_throughput}    ${max_deviation}
    Calculate and Verify DL Async Tput    ${ue_index}    ${dl_throughput}    ${max_deviation}    0s
    Calculate and Verify UL Async Tput    ${ue_index}    ${ul_throughput}    ${max_deviation}    0s
    Postconditions_ForUE

Prepare UE
    [Arguments]    ${attenuator}    ${attenuator_ports}    ${attenuator_values}    ${cell_id}    ${ue_index}
    setup_attenuator    attenuator=${attenuator}  alias=att
    set_ports_attenuation    ports=${attenuator_ports}  values=${attenuator_values}  attenuator_device=att
    #    Set APN
    #    ...    ue_index=${ue_index}
    #    ...    apn_name=${apn}
    #    Reboot UEs    ${ue_index}
    log to console    UE Power reset
    Power Reset UE
    sleep    60
    UE Attach Only  ${ue_index}
    Wait until keyword succeeds  12x    15 sec    Verify attached Cell ID
    ...    ue_index=${ue_index}
    ...    cell_id=${cell_id}

Perform Bidirectional Data Transfer With Throughput Verification on all BTS
    [Arguments]    ${data_transfer_configuration}
    FOR    ${cell}    IN    @{data_transfer_configuration}
        Prepare UE
        ...    attenuator=${cell['attenuator']}
        ...    attenuator_ports=${cell['attenuator_ports']}
        ...    attenuator_values=${cell['attenuator_values']}
        # ...    apn=${cell['apn']}
        ...    cell_id=${cell['cell_id']}
        ...    ue_index=${cell['ue_index']}
        sleep    20
        Perform Bidirectional Data Transfer With Throughput Verification
        ...    ue_index=${cell['ue_index']}
        ...    duration=${cell['duration']}
        ...    dl_throughput=${cell['dl_throughput']}
        ...    ul_throughput=${cell['ul_throughput']}
        ...    max_deviation=${cell['max_deviation']}
    END

Verify attach on all BTS
    [Arguments]    ${attach_configuration}
    FOR    ${cell}    IN    @{attach_configuration}
        Prepare UE
        ...    attenuator=${cell['attenuator']}
        ...    attenuator_ports=${cell['attenuator_ports']}
        ...    attenuator_values=${cell['attenuator_values']}
        # ...    apn=${cell['apn']}
        ...    cell_id=${cell['cell_id']}
        ...    ue_index=${cell['ue_index']}
    END

Suite Setup
     testline_preparation_resources.power_on_all_pdu_ports
     Prepare Neighbours
     Common Suite Setup With OnAir Test Line Preparation
     ...              swconfig_from_path=${CURDIR}/resources/swconfig.txt
     ...              increase_time_for_checking_cells=600
     # ...              neighbour_increase_timeout_for_update_sw=1800
     # ...              should_5G_neighbour_be_changed=${True}
     # ...              upload_swconfig_to_neighbour=${True}


Perform Delta Commissioning on all BTS
    [Arguments]    ${delta}
    FOR    ${index}    ${bts_delta}    IN ENUMERATE    @{delta}
        Perform Delta Commissioning On gNB     delta=${bts_delta}    gnb_id=${index}
    END

Verify Cells Down
    [Arguments]    ${cells}
    FOR    ${bts_id}    ${cell_ids}    IN ENUMERATE     @{cells}
        FOR    ${cell_id}    IN    @{cell_ids}
            gnbcell.Verify Cell Statuses
            ...    ${bts_id}    cell_id=${cell_id}    du_id=0
            ...    operational_state=disabled    procedural_status=not initialized    availability_status=failed
            ...    administrative_state=unlocked  blocking_state=unblocked  barring_status=unbarred
        END
    END

Verify All Cells Are OnAir On all Bts
    FOR    ${bts_id}    ${bts}    IN ENUMERATE    @{tl.gnbs}
        gnbcell.verify_all_cells_are_onair    ${bts_id}
    END

Test Setup
    OperatingSystem.Run  pidof node | xargs kill
    Common Preconditions With Watching Alarms
    Run Keyword If  ${additional_allowed_alarms}    Append To List  ${allowed_alarms}  @{additional_allowed_alarms}
    gnb_alarm.Start watching alarms      allowed_alarms=${allowed_alarms}  interface=${BTS150_addr}    gnb_id=${1}
    gnb_alarm.Start watching alarms      allowed_alarms=${allowed_alarms}  interface=${BTS129_addr}    gnb_id=${2}

Collect Logs
    [Arguments]    ${gnb_id}
    Collect IM Snapshot From gNB    log_dir=${LOG_PATH}    gnb_id=${gnb_id}
    Collect IMS Log From gNB        log_dir=${LOG_PATH}    gnb_id=${gnb_id}
    Collect Snapshot From gNB       log_dir=${LOG_PATH}    gnb_id=${gnb_id}

Test Teardown
    gnb_alarm.Stop watching alarms    gnb_id=${1}
    gnb_alarm.Stop watching alarms    gnb_id=${2}
    Collect Logs    gnb_id=${1}
    Collect Logs    gnb_id=${2}
    Common Postconditions With Watching Alarms

Allow Alarms on all BTS
    [Arguments]    ${alarms}
    FOR    ${bts_id}    ${bts}    IN ENUMERATE    @{tl.gnbs}
        gnb_alarm.Allow Alarm    alarm=${alarms}    gnb_id=${bts_id}
    END

Disallow Alarms on all BTS
    [Arguments]    ${alarms}
    FOR    ${bts_id}    ${bts}    IN ENUMERATE    @{tl.gnbs}
        gnb_alarm.Disallow Alarm    alarm=${alarms}    gnb_id=${bts_id}
    END

Prepare Neighbours
    [Arguments]    ${prefix_tag}=${None}
    ${SW_VERSION}    Get gNB Sw Version
    Set Global Variable  ${SW_VERSION}
    ${SW_VERSION_GNB_1}    Get gNB Sw Version    gnb_id=1
    # ${SW_VERSION_GNB_2}    Get gNB Sw Version    gnb_id=2
    # ${UPGRADE_NEEDED}    Evaluate    not ( '${SW_VERSION}' == '${SW_VERSION_GNB_1}' == '${SW_VERSION_GNB_2}')
    ${UPGRADE_NEEDED}    Evaluate    not ( '${SW_VERSION}' == '${SW_VERSION_GNB_1}')
    Run Keyword If    ${UPGRADE_NEEDED}    Update Neighbours
    Perform Full Commissioning on Classical gNB  bts_id=${1}    force_reconnect=${True}    prefix_tag=${prefix_tag}
    ...    verify_another_sw_upload=${False}
    Perform Full Commissioning on Classical gNB  bts_id=${2}    force_reconnect=${True}    prefix_tag=${prefix_tag}
    ...    verify_another_sw_upload=${False}

Update Neighbours
    gnbscf.reset_configuration                   bts_id=${1}    timeout=1200  wait_for_admin_connection=${False}
    gnbscf.reset_configuration                   bts_id=${2}    timeout=1200  wait_for_admin_connection=${False}
    ${SW_PATH}       download_sw_package         sw_version=${SW_VERSION}    target_dir=${SW_DIR}
    gnbbbu.wait_until_smod_is_online             bts_id=${1}
    gnbbbu.verify_bts_is_not_commissioned        bts_id=${1}
    gnbswupdate.wait_sw_update_possible          readiness_timeout=${600}    bts_id=${1}
    gnbswupdate.update_software                  sw_package_dir=${SW_PATH}    bts_id=${1}    timeout=${2400}
    gnbswupdate.update_software                  sw_package_dir=${SW_PATH}    bts_id=${2}    timeout=${2400}
    sleep    180
