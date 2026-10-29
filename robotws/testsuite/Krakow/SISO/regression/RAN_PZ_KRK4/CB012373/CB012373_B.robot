*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: CB012373_B test case

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library     on_air_tl_preparation/testline_preparation_resources.py
Library     ./resources/wft.py
Library     ./resources/asihub.py
Library     ./resources/delta.py
Library     OperatingSystem

Suite Setup         Run Keywords
...    testline_preparation_resources.power_on_all_pdu_ports
...    AND    Common Suite Setup With Commissioning  asir_hub=${True}
Suite Teardown      Common Suite Teardown
Test Setup          Test Setup
Test Teardown       Test Teardown

*** Variables ***
${TARGET_SW}    SBTS25R2_ENB_0000_000382_000000
${SW_DIR}    /home/ute/.ute-ca/cache/bts
${global_bts0_id}  ${tl.gnbs[0].global_bts_id}
${global_bts1_id}  ${tl.gnbs[1].global_bts_id}
${BTS150_addr}     ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${BTS129_addr}     ${tl.gnbs[2].cu.oam_http_connection_details.addr}
@{additional_allowed_alarms}
...    NG SCTP endpoint broken
...    No connection to unit
...    ToP reference missing
...    Unit synchronization failed

@{additional_allowed_alarms_SBTS2}
...    Incompatible SW version detected
...    No connection to unit
...    PPS reference missing
...    TD-LTE radio disabled
...    ToP reference missing
...    Unit synchronization failed
...    Antennas assignment not available

@{additional_allowed_alarms_SBTS3}
...    PPS reference missing
...    No connection to unit
...    Antennas assignment not available
...    No usable time reference available

*** Test Cases ***
CB012373_051_SW_upgrade_and_rollback_primary_and_secondary_SBTS
    # get sw versions
    log to console    \nGet BTS and HUBs sw versions\n
    ${SOURCE_SW}    Get gNB Sw Version
    ${source_asihub_sw}    get_asihub_versions_from_wft    sw_version=${SOURCE_SW}
    ${target_asihub_sw}    get_asihub_versions_from_wft    sw_version=${TARGET_SW}
    compare_subbuilds    source_asihub=${source_asihub_sw}    target_asihub=${target_asihub_sw}

    #config reset SBTS2 and SBTS3
    log to console    \nConfig reset\n
    gnbscf.reset_configuration    bts_id=${1}    timeout=1200  wait_for_admin_connection=${False}
    gnbscf.reset_configuration    bts_id=${2}    timeout=1200  wait_for_admin_connection=${False}

    #download source SW
    log to console    \nDownload source SW\n
    ${SOURCE_SW_PATH}    download_sw_package    sw_version=${SOURCE_SW}    target_dir=${SW_DIR}

    #Update SBTS1 SW to source
    sleep    120
    log to console    \nUpdate SBTS2 SW to source\n
    gnbbbu.wait_until_smod_is_online    bts_id=${1}
    gnbbbu.verify_bts_is_not_commissioned    bts_id=${1}
    gnbswupdate.wait_sw_update_possible    readiness_timeout=${600}    bts_id=${1}
    gnbswupdate.update_software    sw_package_dir=${SOURCE_SW_PATH}    bts_id=${1}    timeout=${2400}
    sleep    180
    Perform Full Commissioning on Classical gNB    bts_id=${1}    force_reconnect=${True}    verify_another_sw_upload=${False}
    wait until keyword succeeds    10x     1min
    ...    gnbcell.verify_all_cells_are_onair    bts_id=${1}

    #Update SBTS2 SW to source
    log to console    \nUpdate SBTS3 SW to source\n
    gnbbbu.wait_until_smod_is_online    bts_id=${2}
    gnbbbu.verify_bts_is_not_commissioned    bts_id=${2}
    gnbswupdate.wait_sw_update_possible    readiness_timeout=${600}    bts_id=${2}
    gnbswupdate.update_software    sw_package_dir=${SOURCE_SW_PATH}    bts_id=${2}    timeout=${2400}
    sleep    300
    Perform Full Commissioning on Classical gNB    bts_id=${2}    force_reconnect=${True}        verify_another_sw_upload=${False}
    wait until keyword succeeds    10x     1min
    ...    gnbcell.verify_all_cells_are_onair    bts_id=${2}

    Run    rm -rf /home/ute/.ute-ca/cache/bts

    Verify All Cells Are OnAir On all Bts

    # enable actIndSw
    log to console    \nEnable actIndSwUpgradeForSharedASIR\n
    @{delta_actIndSw_true_bts0}    prepare_actIndSw_delta    value=true    bts_id=${0}
    @{delta_actIndSw_true_bts1}    prepare_actIndSw_delta    value=true    bts_id=${1}
    @{delta_actIndSw_true_bts2}    prepare_actIndSw_delta    value=true    bts_id=${2}
    Perform Delta Commissioning On gNB    delta=${delta_actIndSw_true_bts0}    gnb_id=${0}
    Perform Delta Commissioning On gNB    delta=${delta_actIndSw_true_bts1}    gnb_id=${1}
    Perform Delta Commissioning On gNB    delta=${delta_actIndSw_true_bts2}    gnb_id=${2}

    #download target sw
    log to console    \nDownload Target SBTS software\n
    ${TARGET_SW_PATH}    download_sw_package    sw_version=${TARGET_SW}    target_dir=${SW_DIR}

    # disable actIndSw
    log to console    \nDisable actIndSwUpgradeForSharedASIR\n
    @{delta_actIndSw_false}    prepare_actIndSw_delta    value=false
    Perform Delta Commissioning On gNB    delta=${delta_actIndSw_false}

    # SBTS2 upgrade to target sw
    log to console     \nupgrade SBTS2 SW\n
    gnbswupdate.update_software    sw_package_dir=${TARGET_SW_PATH}    bts_id=${1}    timeout=${1200}
    sleep    360
    wait until keyword succeeds    10x     1min
    ...    Verify All Cells Are OnAir On all Bts

    # enable actIndSw
    log to console    \nEnable actIndSwUpgradeForSharedASIR\n
    @{delta_actIndSw_true}    prepare_actIndSw_delta    value=true
    Perform Delta Commissioning On gNB    delta=${delta_actIndSw_true}

    # FID:23 detected on SBT2 and SBTS3
    log to console    \nWait for FID:23 on SBT2\n
    wait until keyword succeeds    4x     30sec
    ...    gnbalarm.verify_alarm_is_active    fault_name=Incompatible SW version detected    bts_id=${1}

    # SBTS2 upgrade to target sw
    log to console     \nupgrade SBTS2 SW\n
    gnbswupdate.update_software    sw_package_dir=${TARGET_SW_PATH}    bts_id=${1}
    sleep    300

    # FID:23 canceled on SBT2 and SBTS3
    log to console    \nWait for FID:23 canceled on SBT2\n
    wait until keyword succeeds    4x     30sec
    ...    gnbalarm.verify_alarm_is_not_active    fault_name=Incompatible SW version detected    bts_id=${1}
    wait until keyword succeeds    10x     1min
    ...    Verify All Cells Are OnAir On all Bts

    # Check sHUB SW version - newer
    log to console     \nCheck sHUB SW version\n
    verify_expected_asihub_sw_version    expected_sw=${target_asihub_sw}

    # SBTS2 rollback to source sw
    log to console     \nrollback SBTS2 SW\n
    gnbbbu.rollback_software        bts_id=${1}
    sleep    120
    wait until keyword succeeds    10x     1min
    ...    Verify All Cells Are OnAir On all Bts

    # Check sHUB SW version - older
    log to console     \nCheck sHUB SW version\n
    verify_expected_asihub_sw_version    expected_sw=${source_asihub_sw}

    # SBTS1 upgrade to target
    log to console     \nupgrade SBTS1 SW\n
    gnbswupdate.update_software    sw_package_dir=${TARGET_SW_PATH}    bts_id=${0}    timeout=${3600}
    sleep    300
    wait until keyword succeeds    10x     1min
    ...    Verify All Cells Are OnAir On all Bts

    # Check sHUB SW version - newer
    log to console     \nCheck sHUB SW version\n
    verify_expected_asihub_sw_version    expected_sw=${target_asihub_sw}

    # SBTS2 upgrade to target
    log to console     \nupgrade SBTS2 SW\n
    gnbswupdate.update_software    sw_package_dir=${TARGET_SW_PATH}    bts_id=${1}
    sleep    300
    wait until keyword succeeds    10x     1min
    ...    Verify All Cells Are OnAir On all Bts

    # SBTS1 rollback to source
    log to console     \nrollback SBTS1 SW\n
    gnbbbu.rollback_software        bts_id=${0}
    sleep    180
    wait until keyword succeeds    10x     1min
    ...    Verify All Cells Are OnAir On all Bts

    # Check sHUB SW version - newer
    log to console     \nCheck sHUB SW version\n
    verify_expected_asihub_sw_version    expected_sw=${target_asihub_sw}

*** Keywords ***
Verify All Cells Are OnAir On all Bts
    FOR    ${bts_id}    ${bts}    IN ENUMERATE    @{tl.gnbs}
        gnbcell.verify_all_cells_are_onair    ${bts_id}
    END

Collect Logs
    [Arguments]    ${gnb_id}
    Collect IM Snapshot From gNB    log_dir=${LOG_PATH}    gnb_id=${gnb_id}
    Collect IMS Log From gNB        log_dir=${LOG_PATH}    gnb_id=${gnb_id}
    Collect Snapshot From gNB       log_dir=${LOG_PATH}    gnb_id=${gnb_id}

Test Setup
    Common Preconditions With Watching Alarms
    Append To List  ${additional_allowed_alarms_SBTS2}  @{allowed_alarms}
    Append To List  ${additional_allowed_alarms_SBTS3}  @{allowed_alarms}
    wait until keyword succeeds    3x     30sec
    ...    gnb_alarm.Start watching alarms      allowed_alarms=${additional_allowed_alarms_SBTS2}  interface=${BTS150_addr}    gnb_id=${1}
    wait until keyword succeeds    3x     30sec
    ...    gnb_alarm.Start watching alarms      allowed_alarms=${additional_allowed_alarms_SBTS3}  interface=${BTS129_addr}    gnb_id=${2}

Test Teardown
    gnb_alarm.Stop watching alarms    gnb_id=${1}
    gnb_alarm.Stop watching alarms    gnb_id=${2}
    Collect Logs    gnb_id=${1}
    Collect Logs    gnb_id=${2}
    Common Postconditions With Watching Alarms
