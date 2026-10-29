*** Settings ***
Documentation
...   author: Andrzej Pencak
...   contact: andrzej.pencak@nokia.com
...   maintainer: andrzej.pencak@nokia.com

Library    XML    use_lxml=True                                        WITH NAME    xml
Library    DateTime                                                    WITH NAME    dt
Library    ute_ue                                                      WITH NAME    ue
Library    taf.sbts.oam.coam.admin
Library    taf.rfrl.bts.devices.du.du_operations                       WITH NAME    du
Library    taf.rfrl.ue.ute_ue_config.UteUeConfig                       WITH NAME    uteueconfig
Library    taf.rfrl.bts.commissioning                                  WITH NAME    commission
Library    taf.rfrl.utilities.test_config.DefaultFileLocation          WITH NAME    dfl

Library    ./suite_specific_keywords.py                                WITH NAME    sskpy

Library    taf.ul.energy_efficiency_monitoring                         WITH NAME    monitoring
Library    taf.collectors.l2stream3
Library    ute_fsmaccess
Library    ta5g_pm_counters                                            WITH NAME    pmcount

Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../../../../resources/collect_logs.robot
Resource    taf/rfrl/bts/robot/gnb.robot

Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./variables.py

*** Variables ***
${skip_commissioning}=     ${NONE}
${bts_id}=     ${tl.gnbs[0].global_bts_id}
${abstract_lib_config}=    ${NONE}

*** Keywords ***

Suite Setup
    [Documentation]    Test Sletup, gets current SCF and performs commissioning on gNB
    Log Action To Console    Suite Setup ==========================================
    Log Action To Console    Download Current Config File from gNB
    ${list_of_alarms}=  Create List    WiFi Configuration Issue    No Xn link available    Xn SCTP setup fail
    Run Keyword And Ignore Error    Download gNB Configuration File    local_dir=${OUTPUT DIR}
    ...                                                                filename=gNB_SCF_before_test.xml    gnb_id=0
    ...                                                                du_id=0
    Run Keyword If    '${skip_commissioning}'!='true'   Common Suite Setup With OnAir Test Line Preparation
    ...    increase_timeout_for_update_sw=1800
    ...    swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT8SK189/swconfig.txt
    ...    list_of_additional_allowed_alarms=${list_of_alarms}
    &{abstract_lib_config}=    Get ute UE Configuration Dict
    Set Suite Variable    ${abstract_lib_config}
    Log Action To Console    End Suite Setup ======================================   new_line_after=True

Perform Commissioning on BTS
    [Documentation]    Perform full commissioning on gNB and waits BTS onAir
    Perform Commissioning on gNB     gnb_main.xml
    Log Action To Console    Wait until Setup is onAir
    Wait Until Keyword Succeeds    12min    15s    gnbcell.Verify All Cells Are Onair   du_id=0

Perform Commissioning on gNB
    [Arguments]     ${scfc_file}
    [Documentation]  Performs gNB commissioning with SCF file name given as argument
    ...              :scfc_file:    Name of scf file
    ${commissioning_files_directory}=    dfl.Get Commissioning Dir
    Log Action To Console    Perform Full Commissioning On Classical gNB with file ${scfc_file}
    commission.Perform Full Commissioning On Classical Gnb    bts_id=0    scf_path=${commissioning_files_directory}/${scfc_file}
    Sleep    240s

Test Setup
    Log Action To Console    Test Setup ==========================================
    taf.rfrl.utilities.test_config.Get Log Path
    Perform Commissioning on gNB    gnb_main.xml
    Wait until all cells are onair
    monitoring.configure_bts_connection
    monitoring.enable_energy_efficiency_monitoring
    Log Action To Console    End Setup
    Log Action To Console    Test Procedure ======================================   new_line_after=True

Test Setup with RU power off check
    Log Action To Console    Test Setup ==========================================
    taf.rfrl.utilities.test_config.Get Log Path
    Perform Commissioning on gNB    gnb_main.xml
    Wait until all cells are onair
    monitoring.configure_bts_connection
    monitoring.enable_energy_efficiency_monitoring
    ${result}=   Run Keyword And Return Status    gnb_rus.Verify Radio Unit Statuses     operational_state=disabled
    ...    availability_status=poweroff    power_state=POWEROFFBYES    usage_state=idle
    Run Keyword If   ${result}==False    Lock cell and check RU has been powered off for energy saving
    Log Action To Console    End Setup
    Log Action To Console    Test Procedure ======================================   new_line_after=True

Test Teardown
    Log Action To Console    Test Teardown =======================================   new_line_after=True
    Run Keyword and Ignore Error    Unlock gNB Cell    cell_id=1
    Wait until all cells are onair
    Common Postconditions

Test Teardown 24
    Log Action To Console    Test Teardown =======================================   new_line_after=True
    Common Postconditions

Attach UE for test
    [Documentation]    The keyword performs attach and checks if attach was performed to desired cell of 5G BTS.
    Log Action To Console    Require UE
    ue.Require Ue    UE_1    capabilities=REAL_UE
    Log Action To Console    Attach UE
    ue.Attach UE   UE_1
    ${CELL_ID}=    ue.Get Ue Info    UE_1   CELL_ID
    ${DESIRED_5G_CELL_ID}    Set Variable     ${abstract_lib_config.UE_POOLS.TafUeAndroidPool.inline_config.UE_1.STARTING_CELL}
    Should Be Equal    ${DESIRED_5G_CELL_ID}    ${CELL_ID}
    Sleep  5s

Detach UE after tput
    [Documentation]    The keyword performs UE detach.
    Log Action To Console    Require UE
    Log Action To Console    Detach UE
    ue.Detach Ue    UE_1

Collect counters from next interval
    Log Action To Console     Collect counters from next interval\n
    monitoring.start_measurement_period    ee_features_status=disabled    interval=15min
    monitoring.stop_measurement_period    ee_features_status=disabled
    monitoring.wait_for_next_pm_period    interval=15min
    monitoring.save_energy_consumption_counters_values    ee_features_status=disabled
    ...      filepath=${OUTPUT DIR}/disabled_features_log.json
    ${pm_counters_file}=    get_latest_unpacked_full_pm_counters_file
    ${samples_cell_avail_awake}    get_pm_counter_value    counter=${samples_cell_avail_counter.id}
    ...        localmoid=${samples_cell_avail_counter.localmoid}   filepath=${pm_counters_file}
    ${samples_cell_planned_unavail_awake}    get_pm_counter_value    counter=${samples_cell_planned_unavail_counter.id}
    ...        localmoid=${samples_cell_planned_unavail_counter.localmoid}   filepath=${pm_counters_file}
    ${energy_consumption_in_radio_modules_awake}    get_pm_counter_value
    ...        counter=${energy_consumption_in_radio_modules_counter.id}
    ...        localmoid=${energy_consumption_in_radio_modules_counter.localmoid}   filepath=${pm_counters_file}
    ${energy_consumption_in_sbts_awake}    get_pm_counter_value
    ...        counter=${energy_consumption_in_sbts_counter.id}
    ...        localmoid=${energy_consumption_in_sbts_counter.localmoid}   filepath=${pm_counters_file}
    ${energy_consumption_in_single_radio_awake}    get_pm_counter_value
    ...        counter=${energy_consumption_in_single_radio_counter.id}
    ...        localmoid=${energy_consumption_in_single_radio_counter.localmoid}   filepath=${pm_counters_file}
    Set Global Variable    ${samples_cell_avail_awake}    ${samples_cell_avail_awake}[0]
    Set Global Variable    ${samples_cell_planned_unavail_awake}    ${samples_cell_planned_unavail_awake}[0]
    Set Global Variable    ${energy_consumption_in_radio_modules_awake}
    ...    ${energy_consumption_in_radio_modules_awake}[0]
    Set Global Variable    ${energy_consumption_in_sbts_awake}    ${energy_consumption_in_sbts_awake}[0]
    Set Global Variable    ${energy_consumption_in_single_radio_awake}
    ...    ${energy_consumption_in_single_radio_awake}[0]

Check counters while RMOD poweroffbyes
    Log Action To Console     Collect counters while RMOD POWEROFFBYES\n
    monitoring.start_measurement_period    ee_features_status=enabled    interval=15min
    monitoring.stop_measurement_period    ee_features_status=enabled
    monitoring.wait_for_next_pm_period    interval=15min
    monitoring.save_energy_consumption_counters_values    ee_features_status=enabled
    ...      filepath=${OUTPUT DIR}/enabled_features_log.json
    ${ee_library_result}=      monitoring.get_counters_difference_for_enabled_disabled_features
    ${gain}=    Set Variable       ${ee_library_result}[M40002C2][percentage gain]
    ${percent_gain}=    Get Substring      ${gain}      0     -1
    Should be true     ${percent_gain}>0

    ${pm_counters_file_poweroffbyes}=    get_latest_unpacked_full_pm_counters_file
    pmcount.verify_if_latest_pm_counter_is_lower_than_the_given_value
    ...        counter_id=${samples_cell_avail_counter.id}   value=${samples_cell_avail_awake}
    ...        local_moid=${samples_cell_avail_counter.localmoid}
    ...        filepath=${pm_counters_file_poweroffbyes}

    pmcount.verify_if_latest_pm_counter_is_bigger_than_the_given_value
    ...        counter_id=${samples_cell_planned_unavail_counter.id}    value=${samples_cell_planned_unavail_awake}
    ...        local_moid=${samples_cell_planned_unavail_counter.localmoid}
    ...        filepath=${pm_counters_file_poweroffbyes}

    pmcount.verify_if_latest_pm_counter_is_lower_than_the_given_value
    ...        counter_id=${energy_consumption_in_radio_modules_counter.id}
    ...        value=${energy_consumption_in_radio_modules_awake}
    ...        local_moid=${energy_consumption_in_radio_modules_counter.localmoid}
    ...        filepath=${pm_counters_file_poweroffbyes}

    pmcount.verify_if_latest_pm_counter_is_lower_than_the_given_value
    ...        counter_id=${energy_consumption_in_sbts_counter.id}    value=${energy_consumption_in_sbts_awake}
    ...        local_moid=${energy_consumption_in_sbts_counter.localmoid}
    ...        filepath=${pm_counters_file_poweroffbyes}

    pmcount.verify_if_latest_pm_counter_is_lower_than_the_given_value
    ...        counter_id=${energy_consumption_in_single_radio_counter.id}
    ...        value=${energy_consumption_in_single_radio_awake}
    ...        local_moid=${energy_consumption_in_single_radio_counter.localmoid}
    ...        filepath=${pm_counters_file_poweroffbyes}

Check counters while RMOD awake
    Log Action To Console     Collect counters while RMOD AWAKE\n
    Wait For Next Full Pm Interval
    ${pm_counters_file_poweroffbyes}=    get_latest_unpacked_full_pm_counters_file

    pmcount.verify_if_latest_pm_counter_is_bigger_than_the_given_value
    ...        counter_id=${samples_cell_avail_counter.id}   value=${samples_cell_avail_awake}
    ...        local_moid=${samples_cell_avail_counter.localmoid}
    ...        filepath=${pm_counters_file_poweroffbyes}

    pmcount.verify_if_latest_pm_counter_is_lower_than_the_given_value
    ...        counter_id=${samples_cell_planned_unavail_counter.id}    value=${samples_cell_planned_unavail_awake}
    ...        local_moid=${samples_cell_planned_unavail_counter.localmoid}
    ...        filepath=${pm_counters_file_poweroffbyes}

    pmcount.verify_if_latest_pm_counter_is_bigger_than_the_given_value
    ...        counter_id=${energy_consumption_in_radio_modules_counter.id}
    ...        value=${energy_consumption_in_radio_modules_awake}
    ...        local_moid=${energy_consumption_in_radio_modules_counter.localmoid}
    ...        filepath=${pm_counters_file_poweroffbyes}

    pmcount.verify_if_latest_pm_counter_is_bigger_than_the_given_value
    ...        counter_id=${energy_consumption_in_sbts_counter.id}    value=${energy_consumption_in_sbts_awake}
    ...        local_moid=${energy_consumption_in_sbts_counter.localmoid}
    ...        filepath=${pm_counters_file_poweroffbyes}

    pmcount.verify_if_latest_pm_counter_is_bigger_than_the_given_value
    ...        counter_id=${energy_consumption_in_single_radio_counter.id}
    ...        value=${energy_consumption_in_single_radio_awake}
    ...        local_moid=${energy_consumption_in_single_radio_counter.localmoid}
    ...        filepath=${pm_counters_file_poweroffbyes}

Lock cell and check RU has been powered off for energy saving
    [Documentation]    The keyword locks cell, veryfies if RU enters Deep Sleep Mode and checks if RU has been
    ...                powered off.
    Lock cell on RU and check RU entered into Deep Sleep Mode
    Check RU has been powered off for energy saving
    ${faults_names}=    Create List    SSH enabled    R&D Service Port enabled    LMP access via port 443
    ...                                Ethernet port security is disabled    Service account root access is enabled
    ...                                Power on PDU port switched off remotely by user    Xn SCTP setup fail
    ...                                No Xn link available
    Verify Allowed Alarms on gNB    allowed_alarms=${faults_names}    gnb_id=0    du_id=${0}

Lock cell on RU and check RU entered into Deep Sleep Mode
    [Documentation]    The keyword locks cell and veryfies if RU enters Deep Sleep Mode.
    gnb_rus.Verify Radio Unit Statuses     operational_state=enabled  usage_state=active    power_state=AWAKE
    Lock gNB Cell    cell_id=1
    Wait Until Keyword Succeeds    5min    10s    gnb_cells.Verify All Cells Statuses    du_id=0
    ...    operational_state=Disabled    procedural_status=initialization required
    ...    availability_status=Offline    administrative_state=Locked
    Sleep    300s
    gnb_rus.Verify Radio Unit Statuses     operational_state=enabled  usage_state=idle    power_state=SLEEP

Unlock cell on RU and check RU woke up from energy saving
    Unlock gNB Cell    cell_id=1
    Sleep    120s
    Wait until all cells are onair
    gnb_rus.Verify Radio Unit Statuses     operational_state=enabled  usage_state=active    power_state=AWAKE

Check RU has been powered off for energy saving
    Sleep    180s
    gnb_rus.Verify Radio Unit Statuses     operational_state=disabled  availability_status=poweroff
    ...    power_state=POWEROFFBYES    usage_state=idle

Check RU woke up from energy saving
    Sleep    300s
    gnb_rus.Verify Radio Unit Statuses     operational_state=enabled  usage_state=idle    power_state=AWAKE

Try to reset RMOD DCPORT and FPFH when RU powered off for energy saving
    [Documentation]    The keyword tries to reset RMOD, DCPORT and FPFh and expects failure.
    Log Action To Console    Try to reset RMOD and expect error
    Reset and Expect Failure     dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1
    Log Action To Console    Try to reset DCPORT and expect error
    Reset and Expect Failure     dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/PWRMOD-2/DCPORT-1
    Log Action To Console    Try to reset PWRMOD and expect error
    Reset and Expect Failure     dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/PWRMOD-2

Change actAutoPwrOffDCPort to false
    [Documentation]    The keyword changes parameter MNL/MNLENT/FEATCADM.actAutoPwrOffDCPort to false.
    Log Action To Console    Change actAutoPwrOffDCPort to false
    gnbscf.perform_configuration_parameter_recommissioning    operation=update    bts_id=0    du_id=${0}
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/EQM-1/APEQM-1/PWRMOD-2/DCPORT-1
    ...    parameter=actAutoPwrOffForES   value=false
    ...    skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Change energySavingMode to DEEP SLEEP
    Log Action To Console    Change energy Saving Mode to Deep Sleep
    gnbscf.perform_configuration_parameter_recommissioning    operation=update    bts_id=0    du_id=${0}
    ...    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1
    ...    parameter=energySavingMode   value=DEEPSLEEP
    ...    skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Try to reset RMOD
    Log Action To Console    Try to reset RMOD and expect success
    Reset gNB Radio Unit from GUI    gnb_id=0    radio_unit_id=1    du_id=0
    Sleep      500s
    Run Keyword    gnb_rus.Verify Radio Unit Statuses     operational_state=enabled
    ...    availability_status=online    power_state=AWAKE   usage_state=Active
    Wait until all cells are onair

Reset gNB Radio Unit via WebEM
    [Arguments]    ${radio_unit_id}=0
    [Documentation]    Reset RU from GUI
    ...                :param radio_unit_id:    position of RU in rus table from Test Line configuration
    Log Action To Console    Reset RU via WebEM
    Reset gNB Radio Unit from GUI    gnb_id=0    radio_unit_id=${radio_unit_id}    du_id=0
    Sleep    5s

Wait until all cells are onair
    [Arguments]    ${waiting_time}=5min    ${checking_interval}=15s
    [Documentation]    The keyword waits until all cells will be in on air.
    ...                :param waiting_time:    time to wait
    ...                :param checking_interval: time between checking
    Log Action To Console    Wait until all cells are onair
    Wait Until Keyword Succeeds    ${waiting_time}    ${checking_interval}
    ...    gnb_cells.Verify All Cells Statuses    du_id=0
    ...                                 operational_state=Enabled    procedural_status=configured
    ...                                 availability_status=Online    administrative_state=Unlocked

Change advanceTimeForDCPortPwrOn from configuration
    ${advanceTimeForDCPortPwrOnValue}=  Get gNB Parameter Value via GUI
    ...    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/PWRMOD-2/DCPORT-1    param_name=The advance time to power on PDU port
    ...    param_abbr=advanceTimeForDCPortPwrOn    gnb_id=${0}    du_id=${0}

    ${xml}=    xml.Parse XML
    ...    /home/ute/MN/UTE/robotws/commissionings/Krakow/7_7_UTE5GCLOUDT8SK189/SBTS00/gnb_main.xml

    ${pwrOffDCPortTimeWin_xpath} =    Catenate  SEPARATOR=
    ...    /raml/cmData[@type="plan"]/managedObject[@distName="MRBTS-${bts_id}/EQM-1/APEQM-1/PWRMOD-2/DCPORT-1"]
    ...    //list[@name="pwrOffDCPortTimeWinList"]

    @{current_pwrOffDCPortTimeWin_list}=    xml.Get Elements    ${xml}    ${pwrOffDCPortTimeWin_xpath}

    ${current_pwrOffDCPortTimeWin_list}=    Convert xml pwrOffDCPortTimeWin to python object
    ...    ${current_pwrOffDCPortTimeWin_list[0]}

    ${current_time}=    Get Current Date     result_format=datetime
    ${day_of_week}=    Convert Date    ${current_time}    result_format=%a
    ${window_end}=    Subtract Time From Date    ${current_time}   00:00:00    result_format=datetime
    ${window_duration}=    Evaluate    60 * ${window_end.hour} + ${window_end.minute} + 20
    &{new_pwrOffDCPortTimeWin_structure} =    Create Dictionary    dayOfWeek=${day_of_week}   startTime=00:00
    ...    windowDuration=${window_duration}

    ${new_pwrOffDCPortTimeWin_list}=    Update pwrOffDCPortTimeWin list    items=${current_pwrOffDCPortTimeWin_list}
    ...    new_item=${new_pwrOffDCPortTimeWin_structure}

    gnbscf.perform_configuration_parameter_recommissioning    operation=update    bts_id=0    du_id=${0}
    ...    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/PWRMOD-2/DCPORT-1
    ...    parameter=pwrOffDCPortTimeWinList   value=${new_pwrOffDCPortTimeWin_list}
    ...    skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

    Log Action To Console    Changing DCPORT.advanceTimeForFCPortPwrOn configuration
    Run Keyword If     "25" in """${advanceTimeForDCPortPwrOnValue}"""
    ...    gnbscf.perform_configuration_parameter_recommissioning    operation=update    bts_id=0    du_id=${0}
    ...    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/PWRMOD-2/DCPORT-1
    ...    parameter=advanceTimeForDCPortPwrOn   value=20
    ...    skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}
    ...    ELSE
    ...    gnbscf.perform_configuration_parameter_recommissioning    operation=update    bts_id=0    du_id=${0}
    ...    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/PWRMOD-2/DCPORT-1
    ...    parameter=advanceTimeForDCPortPwrOn   value=25
    ...    skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Verify SA flow pcap
    [Arguments]    ${pcap_file}    ${5g_pci}
    [Documentation]    The keyword checks SA flow pcap for attach UE to desired cell,
    ...                and fails if cell is other than desired.
    ...                :param pcap_file:    pcap file to look for message in
    ...                :5g_pci:    desired cell to attach UE

    Log Action To Console    Verify SA Attach
    ${hex_5g_pci}=    Get Nr Cell Id In Hex    ${5g_pci}
    ${message_found}=    flow_verifier.Check If Message Is In Flow
    ...    awaited_message=UplinkNASTransport(contains(*nRCellIdentity=${hex_5g_pci}))
    ...    pcap_file=${LOG_PATH}/${pcap_file}
    Run Keyword If    ${message_found} == ${False}    Fail And Log Error    msg=Ue did not attach to expected cell.

Fail And Log Error
    [Arguments]   ${msg}
    [Documentation]    The keyword performs failure and logs error message.
    ...                :param msg:     message logged

    Log    message=${msg}    level=ERROR
    Fail   msg=${msg}

Start UDP DL and UL data transmission and verify results
    Start UDP DL and UL data transmission for specified time  dl_throughput=100 Mbits/sec    ul_throughput=7 Mbits/sec
    ...      data_transfer_time=60s    dl_dt_name=DT_1_DL    ul_dt_name=DT_1_UL
    Await DL and UL data transmission finish                    dl_dt_name=DT_1_DL    ul_dt_name=DT_1_UL
    Stop DL and UL data transmission                            dl_dt_name=DT_1_DL   ul_dt_name=DT_1_UL
    Verify UDP DL and UL data transmission                      dl_throughput_for_verify=100 Mbits/sec
    ...                                                         ul_throughput_for_verify=6 Mbits/sec
    ...                                                         dl_deviation=10%
    ...                                                         ul_deviation=30%
    ...                                                         dl_dt_name=DT_1_DL    ul_dt_name=DT_1_UL

Start UDP DL and UL data transmission for specified time
    [Arguments]    ${dl_throughput}    ${ul_throughput}     ${data_transfer_time}
    ...            ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL
    [Documentation]    Keyword starts UDP DL and UL traffic transmision for specified time.
    ...                Traffic is performed in downlink and uplink directions.
    ...                :dl_throughput:    throughput in downlink direction
    ...                :ul_throughput:    throughput in uplink direction
    ...                :param data_transfer_time:    data trasmission's time
    ...                :dl_dt_name:    name of throughput in downlink direction, default: DT_1_DL
    ...                :ul_dt_name:    name of throughput in downlink direction, default: DT_1_UL

    Log Action To Console     Start UDP DL and UL data transmission for ${data_transfer_time}
    ue.Start Data Transfer    dt_name=${dl_dt_name}    ue_alias=UE_1
    ...                       direction=dl    duration=${data_transfer_time}    protocol=udp
    ...                       throughput=${dl_throughput}    iperf_len=1320B    packet=1350B    buffer_server=16M
    ue.Start Data Transfer    dt_name=${ul_dt_name}    ue_alias=UE_1
    ...                       direction=ul    duration=${data_transfer_time}    protocol=udp
    ...                       throughput=${ul_throughput}    packet_size=1320    buffer_client=4M

Await DL and UL data transmission finish
    [Arguments]    ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL
    [Documentation]    The keyword awaits DL and UL data transmission.
    ...                :dl_dt_name:    name of throughput in downlink direction, default: DT_1_DL
    ...                :ul_dt_name:    name of throughput in downlink direction, default: DT_1_UL

    Log Action To Console    Await DL and UL data transmission finish
    ue.Await Data Transfer Finish    ${dl_dt_name}
    ue.Await Data Transfer Finish    ${ul_dt_name}

Stop DL and UL data transmission
    [Arguments]    ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL
    [Documentation]    The keyword stops DL and UL data transmission.
    ...                :dl_dt_name:    name of throughput in downlink direction, default: DT_1_DL
    ...                :ul_dt_name:    name of throughput in downlink direction, default: DT_1_UL

    Log Action To Console    Stop DL and UL data transmission
    ue.Stop Data Transfer    dt_name=${dl_dt_name}
    ue.Stop Data Transfer    dt_name=${ul_dt_name}

Verify UDP DL and UL data transmission
    [Arguments]    ${dl_throughput_for_verify}    ${ul_throughput_for_verify}    ${dl_deviation}    ${ul_deviation}
    ...            ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL
    [Documentation]    Keyword checks if UDP throughput datagram loss is below max_allowed_datagram_loss.
    ...                Checking is performed in uplink and downlink directions.
    ...                :param dl_throughput_for_verify:    tuput in downlink direction for verify
    ...                :param ul_throughput_for_verify:    tuput in uplink direction for verify
    ...                :param dl_deviation:   deviation of tuput in downlink direction in percentage
    ...                :param ul_deviation:   deviation of tuput in uplink direction in percentage
    ...                :dl_dt_name:    name of throughput in downlink direction, default: DT_1_DL
    ...                :ul_dt_name:    name of throughput in downlink direction, default: DT_1_UL

    Log Action To Console    Verify UDP DL and UL data transmission
    ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name}    tput=${dl_throughput_for_verify}
    ...                                            deviation=${dl_deviation}
    ue.Verify Average Throughput With Deviation    dt_name=${ul_dt_name}    tput=${ul_throughput_for_verify}
    ...                                            deviation=${ul_deviation}

Execute and verify UDP DL and UL data transfer for specified time
    [Arguments]    ${dl_throughput}    ${ul_throughput}    ${data_transfer_time}    ${dl_throughput_for_verify}
    ...            ${ul_throughput_for_verify}    ${dl_deviation}    ${ul_deviation}
    ...            ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL
    [Documentation]    The keyword executes UDP DL and UL data transmission for a specific time and checks if throughput
    ...                datagram loss is below max_allowed_datagram_loss.
    ...                Traffic is performed in downlink and uplink directions.
    ...                :param dl_throughput:    throughput in downlink direction
    ...                :param ul_throughput:    throughput in uplink direction
    ...                :param data_transfer_time:    data trasmission's time
    ...                :param dl_throughput_for_verify:    tuput in downlink direction for verify
    ...                :param ul_throughput_for_verify:    tuput in uplink direction for verify
    ...                :param dl_deviation:   deviation of tuput in downlink direction in percentage
    ...                :param ul_deviation:   deviation of tuput in uplink direction in percentage
    ...                :dl_dt_name:    name of throughput in downlink direction, default: DT_1_DL
    ...                :ul_dt_name:    name of throughput in downlink direction, default: DT_1_UL

    Start UDP DL and UL data transmission for specified time    dl_throughput=${dl_throughput}
    ...                                                         ul_throughput=${ul_throughput}
    ...                                                         data_transfer_time=${data_transfer_time}
    ...                                                         dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    Await DL and UL data transmission finish                    dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    Stop DL and UL data transmission                            dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    Verify UDP DL and UL data transmission                      dl_throughput_for_verify=${dl_throughput_for_verify}
    ...                                                         ul_throughput_for_verify=${ul_throughput_for_verify}
    ...                                                         dl_deviation=${dl_deviation}
    ...                                                         ul_deviation=${ul_deviation}
    ...                                                         dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    Logs message to console
    ...                :param msg:     message logged
    ...                :datatime:    determines if include timestamp in log
    ...                :new_line_before:    determines if include new line before log
    ...                :new_line_after:    determines if include new line after log

    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}
