*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: CB012373_A test case

Library     on_air_tl_preparation/testline_preparation_resources.py
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB010925/Keywords.robot

Suite Setup         Suite Setup
Suite Teardown      Common Suite Teardown
Test Setup          Test Setup
Test Teardown       Test Teardown

*** Variables ***
@{rmod_power_off_allowed_alarms_bts0}
...    RRU power loss
...    No connection to unit
...    Unit power reset
@{rmod_power_off_allowed_alarms_bts1}
...    RRU power loss
...    No connection to unit
...    Antennas assignment not available
...    ToP reference missing
...    Unit synchronization failed
...    PPS reference missing
...    Unit power reset
@{rmod_power_off_allowed_alarms_bts2}
...    RRU power loss
...    No connection to unit
...    Antennas assignment not available
...    PPS reference missing
...    Antennas assignment not available

${SEND_CONFIGURATION_VALIDATION_EMAIL}    ${False}
${SEND_TRUCK_ROLL_EMAIL}    ${False}

${SW_DIR}             /home/ute/.ute-ca/cache/bts
${prefix_tag}         NEUTRAL_HOST

*** Test Cases ***
CB010925_08_Manual_SiSo_REC_Radio_Module_power_reset
    Set swconfig flag  flag=0x300001  value=1
    Set swconfig flag  flag=0x30001C  value=1
    Set swconfig flag  flag=0x1003f  value=1
    Set swconfig flag  flag=0x10040  value=1
    Set swconfig flag  flag=0x10041  value=5
    BuiltIn.log to console    \nConfig reset - SBTS2 and SBTS3\n
    gnbscf.reset_configuration    bts_id=${1}    timeout=1200  wait_for_admin_connection=${False}
    gnbscf.reset_configuration    bts_id=${2}    timeout=1200  wait_for_admin_connection=${False}

    BuiltIn.log to console    \nSBTS1 Commissioning\n
    Perform Full Commissioning on Classical gNB    prefix_tag=${prefix_tag}    verify_another_sw_upload=${False}
    Perform Full Commissioning on gNB ASIR hub     prefix_tag=${prefix_tag}
    sleep    60

    BuiltIn.log to console    \nDownload SW\n
    ${SW_VERSION}    Get gNB Sw Version
    ${SW_PATH}    download_sw_package    sw_version=${SW_VERSION}    target_dir=${SW_DIR}
    #${SW_PATH}  Set Variable
    #...  /home/ute/.ute-ca/cache/bts/SBTS00_ENB_9999_260326_1493878/SBTS00_ENB_9999_260326_1493878_release_BTSSM_downloadable_A54.zip

    BuiltIn.log to console    \nUpdate SBTS2 and SBTS3\n
    gnbswupdate.update_software    sw_package_dir=${SW_PATH}    timeout=${2400}    bts_id=${1}
    gnbswupdate.update_software    sw_package_dir=${SW_PATH}    timeout=${2400}    bts_id=${2}

    sleep    1560
    BuiltIn.log to console    \nUpdate SBTS1\n
    # gnbswupdate.wait_sw_update_possible    readiness_timeout=${600}
    gnbswupdate.update_software    sw_package_dir=${SW_PATH}    timeout=${2400}

    # sleep    30
    BuiltIn.log to console    \nSBTS2 and SBTS3 commissioning\n
    perform_bts_full_commissioning    scf_file=commissionings/Krakow/7_7_TSPY122/SBTS00/NEUTRAL_HOST_GNB1_SCF.xml
    ...    bts_id=${1}
    ...    skip_parameter_relation_errors=${True}
    sleep    60
    perform_bts_full_commissioning    scf_file=commissionings/Krakow/7_7_TSPY122/SBTS00/NEUTRAL_HOST_GNB2_SCF.xml
    ...    bts_id=${2}
    ...    skip_parameter_relation_errors=${True}

    BuiltIn.log to console    \nCheck RMODs and Cells\n
    wait until keyword succeeds    10x     1min
    ...    gnbru.verify_all_radio_units_are_online
    wait until keyword succeeds    10x     1min
    ...    Verify All NR and LTE Cells Are OnAir

    BuiltIn.log to console    \nStart watching alarms\n
    ${all_allowed_alarms_bts_0} = 	Combine Lists 	${allowed_alarms} 	${rmod_power_off_allowed_alarms_bts0}
    ${all_allowed_alarms_bts_1} = 	Combine Lists 	${allowed_alarms} 	${rmod_power_off_allowed_alarms_bts1}
    ${all_allowed_alarms_bts_2} = 	Combine Lists 	${allowed_alarms} 	${rmod_power_off_allowed_alarms_bts2}
    gnb_alarm.Start watching alarms      allowed_alarms=${all_allowed_alarms_bts_0}    gnb_id=${0}
    gnb_alarm.Start watching alarms      allowed_alarms=${all_allowed_alarms_bts_1}    gnb_id=${1}
    gnb_alarm.Start watching alarms      allowed_alarms=${all_allowed_alarms_bts_2}    gnb_id=${2}

    # BuiltIn.log to console    \nDelta commissioning\n
    # Perform Delta Commissionings    delta=${radio_module_power_reset_delta}

    BuiltIn.log to console    \nAttach verification\n
    # Verify attach    attach_configuration=${radio_module_power_reset_data_transfer_configuration}

    BuiltIn.log to console    \nRadio Unit Power Off\n
    Radio Unit Power Off on gNB    radio_unit_id=${0}
    sleep    30

    BuiltIn.log to console    \nRadio Unit Power Off\n
    Radio Unit Power ON on gNB    radio_unit_id=${0}
    sleep    30

    BuiltIn.log to console    \nCheck Cells\n
    wait until keyword succeeds    10x     1min
    ...    Verify All NR and LTE Cells Are OnAir

    BuiltIn.log to console    \nAttach verification\n
    # Verify attach   attach_configuration=${radio_module_power_reset_data_transfer_configuration}

*** Keywords ***
Perform Delta Commissionings
    [Arguments]    ${delta}
    FOR    ${index}    ${bts_delta}    IN ENUMERATE    @{delta}
        Continue For Loop IF    ${index} == ${0}
        Perform Delta Commissioning On gNB     delta=${bts_delta}    gnb_id=${index}
    END

Verify attach
    [Arguments]    ${attach_configuration}
    FOR    ${index}    ${cell}    IN ENUMERATE    @{attach_configuration}
        Continue For Loop IF    ${index} == ${0}
        Prepare UE
        ...    attenuator=${cell['attenuator']}
        ...    attenuator_ports=${cell['attenuator_ports']}
        ...    attenuator_values=${cell['attenuator_values']}
        ...    cell_id=${cell['cell_id']}
        ...    ue_index=${cell['ue_index']}
    END

Verify All NR and LTE Cells Are OnAir
    FOR    ${bts_id}    ${bts}    IN ENUMERATE    @{tl.gnbs}
        Continue For Loop IF    ${bts_id} == ${0}
        gnbcell.verify_all_cells_are_onair    ${bts_id}
    END

Test Setup
    Modify Moler Logging Directory      mode=test case
    Collect Logs During Test            collect_syslog=${True}
    ...                                 raise_exception_when_setup_ru_console_fail=${True}
    gnbbbu.Connect    force=${True}

Test Teardown
    gnbalarm.Wait Until Callback Logs Collection Finished
    Check TRUCK ROLL alarms
    Verify Default Allowed Alarms on gNB
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
    interface.Common step trigger
    gnb_alarm.Stop watching alarms    gnb_id=${0}
    gnb_alarm.Stop watching alarms    gnb_id=${1}
    gnb_alarm.Stop watching alarms    gnb_id=${2}
    Collect Logs    gnb_id=${0}
    Collect Logs    gnb_id=${1}
    Collect Logs    gnb_id=${2}

Suite Setup
    testline_preparation_resources.power_on_all_pdu_ports
    Setup Logs Collectors
    Set Suite Variable              ${SUITE_SETUP_STATUS}    ${True}
