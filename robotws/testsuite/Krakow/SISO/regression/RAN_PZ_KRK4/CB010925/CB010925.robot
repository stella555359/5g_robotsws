*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: CB010925 test cases

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_BTS_Site_Reset.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/resources/NJ_Resources/Resources/robot/DevNJ_UE_keywords.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB010925/Keywords.robot
Library     taf/rfrl/procedures/resources/python/connections.py           WITH NAME  connections
Library     taf/rfrl/procedures/resources/python/swconfig/swconfig_operations.py
Library     taf.hw.rf_attenuator
Library     taf.sbts.oam.coam.admin                      WITH NAME  admin
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/data_transfer_configuration.py
Variables   ./resources/delta.py
Variables   ./resources/cells.py

Suite Setup         Suite Setup
Suite Teardown      Common Suite Teardown
Test Setup          Test Setup
Test Teardown       Test Teardown

*** Variables ***
${global_bts0_id}  ${tl.gnbs[0].global_bts_id}
${global_bts1_id}  ${tl.gnbs[1].global_bts_id}
${BTS122_addr}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${BTS150_addr}     ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${BTS129_addr}     ${tl.gnbs[2].cu.oam_http_connection_details.addr}

@{rmod_power_off_allowed_alarms_bts0}
...    RRU power loss
...    No connection to unit
...    Unit power reset
@{rmod_power_off_allowed_alarms_bts1}
...    RRU power loss
...    No connection to unit
@{rmod_power_off_allowed_alarms_bts2}
...    RRU power loss
...    No connection to unit
...    Antennas assignment not available

@{SBTS3_powered_off_allowed_alarms_bts0}
...    BTS Reset Cause

@{SBTS3_powered_off_allowed_alarms_bts1}
...    No connection to unit
...    ToP reference missing
...    Unit synchronization failed
...    Antennas assignment not available
...    PPS reference missing
...    BTS Reset Cause
...    TD-LTE radio disabled

@{SBTS3_powered_off_allowed_alarms_bts2}
...    BTS Reset Cause

@{site_reset_allowed_alarms}
...    No connection to unit
...    ToP reference missing
...    PPS reference missing
...    BTS Reset Cause
...    Antennas assignment not available
...    Unit synchronization failed
...    TD-LTE radio disabled

&{actEcpriRuMPlaneSecurity_disabled_value}  actEcpriRuMPlaneSecurity=RuProtectDisabled
&{actEcpriRuMPlaneSecurity_disabled_bts0}    MRBTS-${global_bts0_id}/MNL-1/MNLENT-1/FEATCADM-1=${actEcpriRuMPlaneSecurity_disabled_value}
&{actEcpriRuMPlaneSecurity_disabled_bts1}    MRBTS-${global_bts1_id}/MNL-1/MNLENT-1/FEATCADM-1=${actEcpriRuMPlaneSecurity_disabled_value}

@{EcpriRuMPlaneSecurity_allowed_alarms}
...    No connection to unit
...    Antennas assignment not available

${SEND_CONFIGURATION_VALIDATION_EMAIL}    ${False}
${SEND_TRUCK_ROLL_EMAIL}    ${False}

*** Test Cases ***
CB010925_03_Manual_SiSo_SM_BTS_Site_Reset
    ${alias}    connections.get_default_admin_connection_alias
    gnb_alarm.Allow Alarm    alarm=${site_reset_allowed_alarms}    gnb_id=0
    gnb_alarm.Allow Alarm    alarm=${site_reset_allowed_alarms}    gnb_id=1
    gnb_alarm.Allow Alarm    alarm=${site_reset_allowed_alarms}    gnb_id=2
    OperatingSystem.Run  pidof node | xargs kill
    admin.connect_to  bts_host=${BTS122_addr}  name=${alias}
    General_SiSo_Auto_BTS_Site_Reset
    wait until keyword succeeds    10x     1min
    ...    Verify All Cells Are OnAir On all Bts
    admin.teardown    connection=${alias}
    OperatingSystem.Run  pidof node | xargs kill
    admin.connect_to  bts_host=${BTS150_addr}  name=${alias}
    General_SiSo_Auto_BTS_Site_Reset
    wait until keyword succeeds    10x     1min
    ...    Verify All Cells Are OnAir On all Bts
    admin.teardown   connection=${alias}
    OperatingSystem.Run  pidof node | xargs kill
    admin.connect_to  bts_host=${BTS129_addr}  name=${alias}
    General_SiSo_Auto_BTS_Site_Reset
    wait until keyword succeeds    10x     1min
    ...    Verify All Cells Are OnAir On all Bts
    [Teardown]    run keywords
    ...    admin.teardown   connection=${alias}
    ...    AND    Test Teardown

#CB010925_03_Manual_SiSo_SM_BTS_Site_Reset
#    ${alias}    connections.get_default_admin_connection_alias
#    gnb_alarm.Allow Alarm    alarm=${site_reset_allowed_alarms}    gnb_id=0
#    gnb_alarm.Allow Alarm    alarm=${site_reset_allowed_alarms}    gnb_id=1
#    gnb_alarm.Allow Alarm    alarm=${site_reset_allowed_alarms}    gnb_id=2
#    Perform Delta Commissioning on all BTS    delta=${site_reset_delta}
#    Perform Bidirectional Data Transfer With Throughput Verification on all BTS    ${site_reset_data_transfer_configuration}
#    OperatingSystem.Run  pidof node | xargs kill
#    admin.connect_to  bts_host=${BTS122_addr}  name=${alias}
#    General_SiSo_Auto_BTS_Site_Reset
#    wait until keyword succeeds    10x     1min
#    ...    Verify All Cells Are OnAir On all Bts
#    admin.teardown    connection=${alias}
#    Perform Bidirectional Data Transfer With Throughput Verification on all BTS    ${site_reset_data_transfer_configuration}
#    Prepare UE
#    ...    attenuator=${tl.attenuator[0]}
#    ...    attenuator_ports=${attenuator_ports}
#    ...    attenuator_values=${NRCELL_12_attenuation_list}
#    # ...    apn=${NR_apn}
#    ...    cell_id=${NRCELL_12_id}
#    ...    ue_index=1
#    Start Bidirectional Data Transfer
#    ...    ue_index=1
#    ...    duration=${NRCELL_12_tput_duration}
#    ...    dl_throughput=${NRCELL_12_dl_throughput}
#    ...    ul_throughput=${NRCELL_12_ul_throughput}
#    OperatingSystem.Run  pidof node | xargs kill
#    admin.connect_to  bts_host=${BTS150_addr}  name=${alias}
#    General_SiSo_Auto_BTS_Site_Reset
#    wait until keyword succeeds    10x     1min
#    ...    Verify All Cells Are OnAir On all Bts
#    admin.teardown   connection=${alias}
#    Verify Bidirectional Data Transfer Throughput
#    ...    ue_index=1
#    ...    dl_throughput=${NRCELL_12_dl_throughput}
#    ...    ul_throughput=${NRCELL_12_ul_throughput}
#    ...    max_deviation=${NRCELL_12_max_deviation}
#    Perform Bidirectional Data Transfer With Throughput Verification on all BTS    ${site_reset_data_transfer_configuration}
#    Prepare UE
#    ...    attenuator=${tl.attenuator[0]}
#    ...    attenuator_ports=${attenuator_ports}
#    ...    attenuator_values=${NRCELL_12_attenuation_list}
#    # ...    apn=${NR_apn}
#    ...    cell_id=${NRCELL_12_id}
#    ...    ue_index=1
#    Start Bidirectional Data Transfer
#    ...    ue_index=1
#    ...    duration=${NRCELL_12_tput_duration}
#    ...    dl_throughput=${NRCELL_12_dl_throughput}
#    ...    ul_throughput=${NRCELL_12_ul_throughput}
#    OperatingSystem.Run  pidof node | xargs kill
#    admin.connect_to  bts_host=${BTS129_addr}  name=${alias}
#    General_SiSo_Auto_BTS_Site_Reset
#    wait until keyword succeeds    10x     1min
#    ...    Verify All Cells Are OnAir On all Bts
#    Verify Bidirectional Data Transfer Throughput
#    ...    ue_index=1
#    ...    dl_throughput=${NRCELL_12_dl_throughput}
#    ...    ul_throughput=${NRCELL_12_ul_throughput}
#    ...    max_deviation=${NRCELL_12_max_deviation}
#    [Teardown]    run keywords
#    ...    admin.teardown   connection=${alias}
#    ...    AND    Test Teardown

CB010925_08_Manual_SiSo_REC_Radio_Module_power_reset
    Perform Delta Commissioning on all BTS    delta=${radio_module_power_reset_delta}
    Verify attach on all BTS    attach_configuration=${radio_module_power_reset_data_transfer_configuration}
    gnb_alarm.Allow Alarm    alarm=${rmod_power_off_allowed_alarms_bts0}    gnb_id=0
    gnb_alarm.Allow Alarm    alarm=${rmod_power_off_allowed_alarms_bts1}    gnb_id=1
    gnb_alarm.Allow Alarm    alarm=${rmod_power_off_allowed_alarms_bts2}    gnb_id=2
    Radio Unit Power Off on gNB    radio_unit_id=${0}
    sleep    30
    Radio Unit Power ON on gNB    radio_unit_id=${0}
    sleep    30
    wait until keyword succeeds    10x     1min
    ...    Verify All Cells Are OnAir On all Bts
    gnb_alarm.Disallow Alarm    alarm=${rmod_power_off_allowed_alarms_bts0}    gnb_id=0
    gnb_alarm.Disallow Alarm    alarm=${rmod_power_off_allowed_alarms_bts1}    gnb_id=1
    gnb_alarm.Disallow Alarm    alarm=${rmod_power_off_allowed_alarms_bts2}    gnb_id=2
    Verify attach on all BTS    attach_configuration=${radio_module_power_reset_data_transfer_configuration}

CB010925_29_IPsec_reconfiguration
    gnbbbu.Verify Configuration Parameters Values
    ...    param_dict=${actEcpriRuMPlaneSecurity_disabled_bts0}
    ...    bts_id=0
    gnbbbu.Verify Configuration Parameters Values
    ...    param_dict=${actEcpriRuMPlaneSecurity_disabled_bts1}
    ...    bts_id=1
    Allow Alarms on all BTS    alarms=${EcpriRuMPlaneSecurity_allowed_alarms}
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${global_bts0_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    param_name=actEcpriRuMPlaneSecurity
    ...    param_value=RuProtectEnabled
    ...    gnb_id=0
    ...    timeout=${180}
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${global_bts1_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    param_name=actEcpriRuMPlaneSecurity
    ...    param_value=RuProtectEnabled
    ...    gnb_id=1
    ...    timeout=${180}
    sleep    20
    wait until keyword succeeds    10x     1min
    ...    Verify All Cells Are OnAir On all Bts
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${global_bts0_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    param_name=actEcpriRuMPlaneSecurity
    ...    param_value=RuProtectDisabled
    ...    gnb_id=0
    sleep    20
    wait until keyword succeeds    10x     1min
    ...    Verify All Cells Are OnAir On all Bts
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${global_bts1_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    param_name=actEcpriRuMPlaneSecurity
    ...    param_value=RuProtectDisabled
    ...    gnb_id=1
    sleep    20
    wait until keyword succeeds    10x     1min
    ...    Verify All Cells Are OnAir On all Bts
    Disallow Alarms on all BTS    alarms=${EcpriRuMPlaneSecurity_allowed_alarms}


CB010925_34_Site_reset_with_SBTS3_powered_off
    gnb_alarm.Allow Alarm    alarm=${SBTS3_powered_off_allowed_alarms_bts0}    gnb_id=0
    gnb_alarm.Allow Alarm    alarm=${SBTS3_powered_off_allowed_alarms_bts1}    gnb_id=1
    gnb_alarm.Allow Alarm    alarm=${SBTS3_powered_off_allowed_alarms_bts2}    gnb_id=2
    wait until keyword succeeds    10x     1min
    ...    Verify All Cells Are OnAir On all Bts
    gnbbbu.bts_power_off    bts_id=2
    sleep    20
    gnbcell.verify_all_cells_are_onair    bts_id=0
    gnbcell.verify_all_cells_are_onair    bts_id=1
    gnbbbu.reset_bts    bts_id=0
    gnbbbu.wait_for_site_to_be_onair    bts_id=0
    gnbbbu.wait_for_site_to_be_onair    bts_id=1
    gnbbbu.reset_bts    bts_id=1
    sleep    10
    gnbcell.verify_all_cells_are_onair    bts_id=0
    gnbbbu.wait_for_site_to_be_onair    bts_id=1
    gnbbbu.bts_power_on    bts_id=2
    sleep    120
    wait until keyword succeeds    10x     1min
        ...    Verify All Cells Are OnAir On all Bts
    gnb_alarm.Disallow Alarm    alarm=${SBTS3_powered_off_allowed_alarms_bts0}    gnb_id=0
    gnb_alarm.Disallow Alarm    alarm=${SBTS3_powered_off_allowed_alarms_bts1}    gnb_id=1
    gnb_alarm.Disallow Alarm    alarm=${SBTS3_powered_off_allowed_alarms_bts2}    gnb_id=2
