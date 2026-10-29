*** Settings ***
Suite Setup          CB012611-ute_cloud Suite Setup
Suite Teardown       CB012611-G Suite Teardown



Documentation
...    Author: Na Li
...    Contact: na.li@nokia-sbell.com
...    squad group:Mmw_SG04
...    Feature Owner: Shu Zhichao
...    Feature CB012611

Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012611-SG4/Resource/CB012611_common_keyword.robot


Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED
*** Variables ***
@{ru_serial_list}    EB2245R1272

*** Test Cases ***
[1]CB012611-SR-G-15_Delta_recommissioning_on_supcercell_with single_all Loki(s)_failed_for_boot_failure
    [Setup]    CB012611-G Case Setup
    Reset ABIO
    ${fault_id}    Create List    252    10    1868
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
    Trigger LOKI B boot failure and check alarm
    3Supercell with 2subcell change to 2Supercell with 3subcell
    Wait until keyword succeeds    15 min    10 sec    Cell status Should Be enabled    cell_list=${cell_list_G[0:1]}
    Cell status Should Be Disabled and AvailabilityStatus Failed    cell_list=${cell_list_G[1:2]}
    UE Start Traffic And Check Tp 12611    ul_throughput=34    dl_throughput=300    ul_list=${NR_cell_id_list_1}
    ...    dl_list=${NR_cell_id_list_1}    ue_index=${0}    target_avg_percent=0.5    log_time=60s
    [Teardown]    CB012611-G Case Teardown


[1]CB012611-SR-G-08_robustness_2supercell_3subcells_Single_ABIO_reset_Repeats_with_single_Loki_failed_supported_for_OIP_I2C_failure
    [Setup]    CB012611-G Case Setup
    default SCF 3supercell change to 2supercell
    ${fault_id}    Create List    252    10
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
    trigger loki-B HW failure by OIP I2C failure    slot_value=2
    Reset BBMOD-1 5 times
    UE Start Traffic And Check Tp 12611    ul_throughput=34    dl_throughput=300    ul_list=${NR_cell_id_list_1}
    ...    dl_list=${NR_cell_id_list_1}    ue_index=${0}    target_avg_percent=0.5    log_time=60s
    [Teardown]    CB012611-G Case Teardown


[1]CB012611-SR-G-05_3supercell_2subcells_Single_loki_permanent_start_up_failed_supported_for_OIP_I2C_failure
    [Setup]    CB012611-G Case Setup
    ${fault_id}    Create List    252    10
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
    trigger loki-B HW failure by OIP I2C failure    slot_value=2
    ...    cell_list_disable=${cell_list_G[0:1]}    cell_list_enable=${cell_list_G[2:3]}    loki_type=A
    ...    supplementary=SoC_B:3
    coam.connect_to    bts_host=${gnb_ip}   name=GNB_OAM
    Cell status Should Be Degraded    cell_list=${cell_list_G[1:2]}
    coam.teardown    connection=GNB_OAM
    AlarmWatchdog.add_allow_alarms    fault_id=1868
    Reset BTS And check cell status
    UE Start Traffic And Check Tp 12611    ul_throughput=34    dl_throughput=300    ul_list=${NR_cell_id_list_3}
    ...    dl_list=${NR_cell_id_list_3}    ue_index=${0}    target_avg_percent=0.5    log_time=60s
    [Teardown]    CB012611-G Case Teardown


[1]CB012611-SR-G-03_3supercell_2subcells_Single_loki_permanent_failure_at_runtime_supported_for_OIP_I2C_failure_after_loki_reset
    [Setup]    CB012611-G Case Setup
    default SCF 3supercell change to 2supercell
    ${fault_id}    Create List    252    10
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
    Reset loki
    trigger loki-B HW failure by OIP I2C failure    slot_value=2
    ...    cell_list_disable=${cell_list_G[0:1]}    cell_list_enable=${cell_list_G[1:2]}    loki_type=A_HB
    ...    supplementary=SoC_B:3
    Reset loki    loki_type=B
    trigger loki-B HW failure by OIP I2C failure    slot_value=2
    ...    cell_list_disable=${cell_list_G[0:2]}   cell_list_enable=${cell_empty_list}    loki_type=B
    ...    supplementary=SoC_B:3, SoC_C:3
    [Teardown]    CB012611-G Case Teardown


[1]CB012611-SR-G-09_1supercell_6subcells_Single_ABIO_reset_with_single_Loki_failed_supported_for_clock_Loki_failure
    [Setup]    CB012611-G Case Setup
    3Supercell with 2subcell change to 1Supercell with 6subcell
    Check the GNB on air
    ${fault_id}    Create List    252    10
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
    Trigger clock failure and check alarm    cell_list_disable=${cell_list_G[0:1]}    slot_value=2
    ...    cell_list_enable=${cell_empty_list}    loki_type=A
    AlarmWatchdog.add_allow_alarms    fault_id=1868
    Reset BBMOD-1 1 time
    Wait until keyword succeeds    60 sec    10 sec    Expect Fault Should Present    faultId=252    severity=Critical
    ...    alarmId=7100    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_B:4
    [Teardown]    CB012611-G Case09/04 Teardown    slot_value=2    bbmod_index=2
