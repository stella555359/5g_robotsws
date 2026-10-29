*** Settings ***
Documentation
...    Test suite for regression testing for feature CB008021-FR2
...    authors: Lubomir Krzeminski, Jakub Bialon
...    maintainer: Lubomir Krzeminski
...    group: RAN_PZ_KRK_SG_7
...    contact: lubomir.krzeminski@nokia.com

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    resources/variablesFR1.robot
Resource    resources/keywordsFR1.robot
Resource    taf/rfrl/bts/robot/recovery_gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Library    OperatingSystem
Library    Process
Library    Telnet    prompt=>    WITH NAME    generator
Library    taf.nms.netact
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.ue
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library    taf.sbts.oam.coam.admin.interface    WITH NAME    coamInterface
Library    taf.rfrl.bts.devices.asir.generic_asir.GenericAsirHub    WITH NAME    AsirAdmin
Library    taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations    WITH NAME    AsirOperations
Library    resources/toolsFR1.py    WITH NAME   tools

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                  should_5G_neighbour_be_changed=${False}
...                                                  increase_time_for_checking_bbmod=600
...                                                  increase_timeout_for_update_sw=1800
...                                                  increase_time_for_checking_radios=2100
...                                                  increase_time_for_checking_cells=700
Test Setup    Common Preconditions With Watching Alarms
Test Teardown    Run Keywords    Custom Test Teardown    bts_connection=${bts_connection}   AND
...                              Common Postconditions With Watching Alarms

*** Variables ***
@{additional_allowed_alarms}=    Create List    Service account root access is enabled
...    Ethernet port security is disabled
...    LMP connectivity detected
...    LMP access via port 443
...    SSH enabled
...    Cell blocked

*** Test Cases ***
PM_counters_are_enabled_without_PRACH_PUCCH_F1
    [Tags]    TC_12
    ${bts_connection}=    coam.connect_to
    keywordsFR1.Perform Delta Recommissioning And Log Output
    ...    ${bts_connection}
    ...    ${delta_TC_12}
    coam.Block Cell    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    Prepare Ue for L3 Call
    keywordsFR1.Start Generating Max Tput
    ...    direction=UL
    ...    duration=1100s
    ...    tput=115 Mbits/sec
    ...    bts_connection=${bts_connection}
    ...    cell_dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    tools.run_generator    generator_ip=${generator_ip_addres}
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=1871.81MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=2.7MHZ
    ...    TC_out_dir=${TC_12_UL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithoutPRACH_PUCCH_F1
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=7
    ...    transmission_technology=FDD
    ...    snap_file_name=snap_TC_12_UL.zip
    keywordsFR1.Await Tput Finish And Detach UE
    ...    direction=UL
    ...    tput=115 Mbits/sec
    ...    deviation=50%
    tools.turn_off_generator    generator_ip=${generator_ip_addres}
    # --------------------------------DL--------------------------------
    coam.Block Cell    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    keywordsFR1.Start Generating Max Tput
    ...    direction=DL
    ...    duration=1100s
    ...    tput=525 Mbits/sec
    ...    bts_connection=${bts_connection}
    ...    cell_dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    tools.run_generator    generator_ip=${generator_ip_addres}
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=1872.08MHZ
    ...    amplitude_val=-35DBM
    ...    bandwidth_val=0.18MHZ
    ...    TC_out_dir=${TC_12_DL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithoutPRACH_PUCCH_F1
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=7
    ...    transmission_technology=FDD
    ...    snap_file_name=snap_TC_12_DL.zip
    keywordsFR1.Await Tput Finish And Detach UE
    ...    direction=DL
    ...    tput=525 Mbits/sec
    ...    deviation=10%

PM_counters_are_enabled_with_PRACH_PUCCH_F1
    [Tags]    TC_13
    ${bts_connection}=    coam.connect_to
    coam.Block Cell    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    Prepare Ue for L3 Call
    keywordsFR1.Start Generating Max Tput
    ...    direction=UL
    ...    duration=1100s
    ...    tput=115 Mbits/sec
    ...    bts_connection=${bts_connection}
    ...    cell_dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    tools.run_generator    generator_ip=${generator_ip_addres}
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=1871.81MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=2.7MHZ
    ...    TC_out_dir=${TC_13_UL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithPRACH_PUCCH_F1
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=7
    ...    transmission_technology=FDD
    ...    snap_file_name=snap_TC_13_UL.zip
    keywordsFR1.Await Tput Finish And Detach UE
    ...    direction=UL
    ...    tput=115 Mbits/sec
    ...    deviation=50%
    tools.turn_off_generator    generator_ip=${generator_ip_addres}
    # --------------------------------DL--------------------------------
    coam.Block Cell    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    keywordsFR1.Start Generating Max Tput
    ...    direction=DL
    ...    duration=1100s
    ...    tput=525 Mbits/sec
    ...    bts_connection=${bts_connection}
    ...    cell_dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    tools.run_generator    generator_ip=${generator_ip_addres}
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=1872.08MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=0.18MHZ
    ...    TC_out_dir=${TC_13_DL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithPRACH_PUCCH_F1
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=7
    ...    transmission_technology=FDD
    ...    snap_file_name=snap_TC_13_DL.zip
    keywordsFR1.Await Tput Finish And Detach UE
    ...    direction=DL
    ...    tput=525 Mbits/sec
    ...    deviation=50%

PM_counters_are_enabled_without_PRACH
    [Tags]    TC_14
    ${bts_connection}=    coam.connect_to
    coam.Block Cell    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    Prepare Ue for L3 Call
    keywordsFR1.Start Generating Max Tput
    ...    direction=UL
    ...    duration=1100s
    ...    tput=125 Mbits/sec
    ...    bts_connection=${bts_connection}
    ...    cell_dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    tools.run_generator    generator_ip=${generator_ip_addres}
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=1871.81MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=2.7MHZ
    ...    TC_out_dir=${TC_14_UL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithoutPRACH
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=7
    ...    transmission_technology=FDD
    ...    snap_file_name=snap_TC_14_UL.zip
    keywordsFR1.Await Tput Finish And Detach UE
    ...    direction=UL
    ...    tput=115 Mbits/sec
    ...    deviation=50%
    tools.turn_off_generator    generator_ip=${generator_ip_addres}
    # --------------------------------DL--------------------------------
    coam.Block Cell    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    keywordsFR1.Start Generating Max Tput
    ...    direction=DL
    ...    duration=1100s
    ...    tput=525 Mbits/sec
    ...    bts_connection=${bts_connection}
    ...    cell_dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    tools.run_generator    generator_ip=${generator_ip_addres}
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=1872.08MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=0.18MHZ
    ...    TC_out_dir=${TC_14_DL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithoutPRACH
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=7
    ...    transmission_technology=FDD
    ...    snap_file_name=snap_TC_14_DL.zip
    keywordsFR1.Await Tput Finish And Detach UE
    ...    direction=DL
    ...    tput=525 Mbits/sec
    ...    deviation=50%

PM_counters_are_enabled_without_PUCCH_F1
    [Tags]    TC_15
    ${bts_connection}=    coam.connect_to
    coam.Block Cell    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    Prepare Ue for L3 Call
    keywordsFR1.Start Generating Max Tput
    ...    direction=UL
    ...    duration=1100s
    ...    tput=125 Mbits/sec
    ...    bts_connection=${bts_connection}
    ...    cell_dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    tools.run_generator    generator_ip=${generator_ip_addres}
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=1871.81MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=2.7MHZ
    ...    TC_out_dir=${TC_15_UL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithoutPUCCH_F1
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=7
    ...    transmission_technology=FDD
    ...    snap_file_name=snap_TC_15_UL.zip
    keywordsFR1.Await Tput Finish And Detach UE
    ...    direction=UL
    ...    tput=115 Mbits/sec
    ...    deviation=50%
    tools.turn_off_generator    generator_ip=${generator_ip_addres}
    # --------------------------------DL--------------------------------
    coam.Block Cell    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    keywordsFR1.Start Generating Max Tput
    ...    direction=DL
    ...    duration=1100s
    ...    tput=525 Mbits/sec
    ...    bts_connection=${bts_connection}
    ...    cell_dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    tools.run_generator    generator_ip=${generator_ip_addres}
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=1872.08MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=0.18MHZ
    ...    TC_out_dir=${TC_15_DL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithoutPUCCH_F1
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=7
    ...    transmission_technology=FDD
    ...    snap_file_name=snap_TC_15_DL.zip
    keywordsFR1.Await Tput Finish And Detach UE
    ...    direction=DL
    ...    tput=525 Mbits/sec
    ...    deviation=50%

Verification_PM_counters_for_scheduled_vs_non-scheduled_PRB_values_PRB_blanking
    [Tags]    TC_16
    ${bts_connection}=    coam.connect_to
    keywordsFR1.Perform Delta Recommissioning And Log Output
    ...    ${bts_connection}
    ...    ${delta_TC_16}
    tools.Set Generator
    ...    generator_ip=${generator_ip_addres}
    ...    frequency_val=1871.81MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=2.7MHZ
    coam.Block Cell    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    Prepare Ue for L3 Call
    ${WEB_time_stamp}=    tools.Schedule Delay    delay=235
    keywordsFR1.Start Generating Max Tput
    ...    direction=UL
    ...    duration=130s
    ...    tput=115 Mbits/sec
    ...    bts_connection=${bts_connection}
    ...    cell_dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    tools.run_generator    generator_ip=${generator_ip_addres}
    ${gnb_logs_zip_name}=    keywordsFR1.Run Bip Log Collecting    100    ${TC_16_UL_out_dir}
    keywordsFR1.Await Tput Finish And Detach UE
    ...    direction=UL
    ...    tput=115 Mbits/sec
    ...    deviation=50%
    tools.Schedule Delay    delay=270
    ${required_counters}=    keywordsFR1.Download And Find Required Pm Counters
    ...    ${WEB_time_stamp}
    ...    ${bts_connection}
    ...    ${TC_16_UL_out_dir}
    tools.Schedule Delay    delay=270
    ${WEB_time_stamp2}=    Add Time To Date    ${WEB_time_stamp}    5min    exclude_millis=yes
    ${required_counters_2}=    keywordsFR1.Download And Find Required Pm Counters
    ...    ${WEB_time_stamp}
    ...    ${bts_connection}
    ...    ${TC_16_UL_out_dir}
    keywordsFR1.Convert Pcap To SCVs    ${TC_16_UL_out_dir}    ${gnb_logs_zip_name}    FDD
    tools.split_csv_by_subcellid    path_to_dir=${TC_16_UL_out_dir}/${gnb_logs_zip_name}
    ${bip_logs_counters_186}=    keywordsFR1.Parse Bip Logss
    ...    ${TC_16_UL_out_dir}
    ...    ${gnb_logs_zip_name}
    ...    short
    ...    ${WEB_time_stamp}
    ...    FDD
    ...    12
    ...    ${FALSE}
    ...    cell186
    ...    2s
    ${bip_logs_counters_86}=    keywordsFR1.Parse Bip Logss
    ...    ${TC_16_UL_out_dir}
    ...    ${gnb_logs_zip_name}
    ...    short
    ...    ${WEB_time_stamp}
    ...    FDD
    ...    12
    ...    ${FALSE}
    ...    cell86
    ...    2s
    ${is_compatible}=    tools.compare_counters_and_bip_logs_result
    ...    ${required_counters}
    ...    ${bip_logs_counters_186}
    ...    ${TC_16_UL_out_dir}
    ...    ${WEB_time_stamp}
    ...    186
    ...    2s
    ${is_compatible}=    tools.compare_counters_and_bip_logs_result
    ...    ${required_counters}
    ...    ${bip_logs_counters_86}
    ...    ${TC_16_UL_out_dir}
    ...    ${WEB_time_stamp}
    ...    86
    ...    2s

Verification_PM_counters_for_different_interference_levels
    [Tags]    TC_17
    ${bts_connection}=    coam.connect_to
    keywordsFR1.Perform Delta Recommissioning And Log Output
    ...    ${bts_connection}
    ...    ${delta_TC_17}
    coam.Block Cell    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-86
    Prepare Ue for L3 Call
    keywordsFR1.Start Generating Max Tput
    ...    direction=DL
    ...    duration=2500s
    ...    tput=525 Mbits/sec
    ...    bts_connection=${bts_connection}
    ...    cell_dist_name=MRBTS-75086/NRBTS-75086/NRCELL-86
    tools.run_generator    generator_ip=${generator_ip_addres}
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=3550.53MHZ
    ...    amplitude_val=-10DBM
    ...    bandwidth_val=5.76MHZ
    ...    TC_out_dir=${TC_17_DL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithoutPRACH_PUCCH_F1
    ...    pucchModeSelect=short
    ...    msg1FrequencyStart=0
    ...    transmission_technology=TDD
    ...    snap_file_name=snap_TC_17_DL_1.zip
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=3550.53MHZ
    ...    amplitude_val=-13DBM
    ...    bandwidth_val=5.76MHZ
    ...    TC_out_dir=${TC_17_DL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithoutPRACH_PUCCH_F1
    ...    pucchModeSelect=short
    ...    msg1FrequencyStart=0
    ...    transmission_technology=TDD
    ...    snap_file_name=snap_TC_17_DL_2.zip
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=3550.53MHZ
    ...    amplitude_val=-33DBM
    ...    bandwidth_val=5.76MHZ
    ...    TC_out_dir=${TC_17_DL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithoutPRACH_PUCCH_F1
    ...    pucchModeSelect=short
    ...    msg1FrequencyStart=0
    ...    transmission_technology=TDD
    ...    snap_file_name=snap_TC_17_DL_3.zip
    keywordsFR1.Await Tput Finish And Detach UE
    ...    direction=DL
    ...    tput=525 Mbits/sec
    ...    deviation=50%

Verification_PM_counters_for_different_interference_locations
    [Tags]    TC_18
    ${bts_connection}=    coam.connect_to
    keywordsFR1.Perform Delta Recommissioning And Log Output
    ...    ${bts_connection}
    ...    ${delta_TC_18}
    coam.Block Cell    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-86
    Prepare Ue for L3 Call
    keywordsFR1.Start Generating Max Tput
    ...    direction=UL
    ...    duration=2500s
    ...    tput=125 Mbits/sec
    ...    bts_connection=${bts_connection}
    ...    cell_dist_name=MRBTS-75086/NRBTS-75086/NRCELL-86
    tools.run_generator    generator_ip=${generator_ip_addres}
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=3506.43MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=11.16MHZ
    ...    TC_out_dir=${TC_18_UL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithPRACH_PUCCH_F1
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=30
    ...    transmission_technology=TDD
    ...    snap_file_name=snap_TC_18_UL_1.zip
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=3515.79MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=0.36MHZ
    ...    TC_out_dir=${TC_18_UL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithPRACH_PUCCH_F1
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=30
    ...    transmission_technology=TDD
    ...    snap_file_name=snap_TC_18_UL_2.zip
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=3593.55MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=11.16MHZ
    ...    TC_out_dir=${TC_18_UL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithPRACH_PUCCH_F1
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=30
    ...    transmission_technology=TDD
    ...    snap_file_name=snap_TC_18_UL_2.zip
    keywordsFR1.Await Tput Finish And Detach UE
    ...    direction=UL
    ...    tput=125 Mbits/sec
    ...    deviation=50%
    tools.turn_off_generator    generator_ip=${generator_ip_addres}
# -------------------------------------------------------------------
    coam.Block Cell    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-86
    keywordsFR1.Start Generating Max Tput
    ...    direction=DL
    ...    duration=2500s
    ...    tput=525 Mbits/sec
    ...    bts_connection=${bts_connection}
    ...    cell_dist_name=MRBTS-75086/NRBTS-75086/NRCELL-86
    tools.run_generator    generator_ip=${generator_ip_addres}
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=3506.43MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=11.16MHZ
    ...    TC_out_dir=${TC_18_DL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithPRACH_PUCCH_F1
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=30
    ...    transmission_technology=TDD
    ...    snap_file_name=snap_TC_18_DL_2.zip
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=3515.79MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=0.36MHZ
    ...    TC_out_dir=${TC_18_DL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithPRACH_PUCCH_F1
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=30
    ...    transmission_technology=TDD
    ...    snap_file_name=snap_TC_18_DL_2.zip
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=3593.55MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=11.16MHZ
    ...    TC_out_dir=${TC_18_DL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithPRACH_PUCCH_F1
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=30
    ...    transmission_technology=TDD
    ...    snap_file_name=snap_TC_18_DL_2.zip
    keywordsFR1.Await Tput Finish And Detach UE
    ...    direction=DL
    ...    tput=525 Mbits/sec
    ...    deviation=50%

Verification_PM_counters_for_scheduled_vs_non-scheduled_PRB_values_average_vs_max_counter_values
    [Tags]    TC_19
    ${bts_connection}=    coam.connect_to
    keywordsFR1.Perform Delta Recommissioning And Log Output
    ...    ${bts_connection}
    ...    ${delta_TC_19}
    coam.Block Cell    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-86
    Prepare Ue for L3 Call
    keywordsFR1.Start Generating Max Tput
    ...    direction=UL
    ...    duration=1100s
    ...    tput=115 Mbits/sec
    ...    bts_connection=${bts_connection}
    ...    cell_dist_name=MRBTS-75086/NRBTS-75086/NRCELL-86
    tools.run_generator    generator_ip=${generator_ip_addres}
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=3550.53MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=5.76MHZ
    ...    TC_out_dir=${TC_19_UL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithoutPRACH_PUCCH_F1
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=30
    ...    transmission_technology=TDD
    ...    snap_file_name=snap_TC_19_UL_1.zip
    keywordsFR1.Await Tput Finish And Detach UE
    ...    direction=UL
    ...    tput=115 Mbits/sec
    ...    deviation=50%
    tools.turn_off_generator    generator_ip=${generator_ip_addres}
    # ----------------------------------------------------------------
    coam.Block Cell    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-86
    keywordsFR1.Start Generating Max Tput
    ...    direction=UL
    ...    duration=1100s
    ...    tput=115 Mbits/sec
    ...    bts_connection=${bts_connection}
    ...    cell_dist_name=MRBTS-75086/NRBTS-75086/NRCELL-86
    tools.run_generator    generator_ip=${generator_ip_addres}
    Collect BIPlog and Download Pm Counters For Different Generator Setups
    ...    bts_connection=${bts_connection}
    ...    frequency_val=3550.53MHZ
    ...    amplitude_val=-20DBM
    ...    bandwidth_val=5.76MHZ
    ...    TC_out_dir=${TC_19_UL_out_dir}
    ...    actNrUlRipMeasurement=enabledWithoutPRACH_PUCCH_F1
    ...    pucchModeSelect=long
    ...    msg1FrequencyStart=30
    ...    transmission_technology=TDD
    ...    snap_file_name=snap_TC_19_UL_2.zip
    keywordsFR1.Await Tput Finish And Detach UE
    ...    direction=UL
    ...    tput=115 Mbits/sec
    ...    deviation=10%
