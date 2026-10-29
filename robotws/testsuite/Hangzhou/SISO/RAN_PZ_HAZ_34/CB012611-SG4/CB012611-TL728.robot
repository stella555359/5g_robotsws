*** Settings ***
Documentation
...   author: zhichao.shu@nokia-sbell.com
...   contact: zhichao.shu@nokia-sbell.com
...   SISO

Suite Setup          CB012611-G Suite Setup
Suite Teardown       CB012611-G Suite Teardown

Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012611-SG4/Resource/CB012611_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008434-SR/resources/variables_8434.robot
*** Variables ***
${PB_IP_GNB}            ${tl.attenuator[0].addr}
${PB_PORT_GNB}          ${tl.attenuator[0].port_numbers[6]}
@{cell_list_728}          1    2   3    4
${call_cell_id}    187564035
@{ru_serial_list}    EB2232R0689    EB2232R0703    EB2232R0707
*** Test Cases ***
[1]CB012611-SR-B-01_single_Loki_for_power_failure_at_runtime
     [Setup]    CB012611-G Case Setup
     AlarmWatchdog.add_allow_alarms    fault_id=252
     Trigger single loki power failure    loki_type=B    slot_value=2
     Wait until keyword succeeds    90 sec    10 sec    Expect Fault Should Present    faultId=252    severity=Major
     ...    alarmId=7100    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_C:1
     Verify bbmod Should Be degraded    bbmod_index=2
     Cell status Should Be Degraded    cell_list=${cell_list_728[2:3]}
     Start Traffic And Check Throughput TL728    tp_ul=100M    tp_dl=300M    target_tp_ul=30    target_tp_dl=100
         ...    nrcell_id=${call_cell_id}
     Stop Traffic And UE Detach TL728
     [Teardown]    CB012611-G Case Teardown

[1]CB012611-SR-G-02_single_Loki_for_Boot_failure_at_startup
     [Setup]    CB012611-G Case Setup
     Reset ABIO
     ${fault_id}    Create List    252    1868    10
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
     Wait until keyword succeeds    15 min    3 sec    Trigger LOKI A boot failure    alarmId=7100     severity=Critical
     ...     loki_value=1    slot_value=2
     Verify bbmod Should Be degraded    bbmod_index=2
#     Wait until keyword succeeds    5 min    10 sec    Expect Fault Should Present    faultId=1868    severity=Critical
#         ...    alarmId=7114    configObjectName=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-3
#         ...    supplementary=Not enough DSP or baseband pool resources for cell detected
     Wait until keyword succeeds    5 min    10 sec    Cell status Should Be enabled    cell_list=${cell_list_728[0:2]}
     [Teardown]    CB012611-G Case Teardown

[1]CB012611-SR-G-03_single_Loki_for_OIP_I2C_failure_at_runtime_and_startup
     [Setup]    CB012611-G Case Setup
     AlarmWatchdog.add_allow_alarms    fault_id=252
     Trigger OIP I2C failure    loki_type=B    slot_value=2
     Wait until keyword succeeds    180 sec    10 sec    Expect Fault Should Present    faultId=252    severity=Major
     ...    alarmId=7100    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_C:3
     Verify bbmod Should Be degraded    bbmod_index=2
     Cell status Should Be Degraded    cell_list=${cell_list_728[2:3]}
     Cell status Should Be enabled    cell_list=${cell_list_728[0:2]}
     Start Traffic And Check Throughput TL728   tp_ul=100M    tp_dl=300M    target_tp_ul=30    target_tp_dl=100
         ...    nrcell_id=${call_cell_id}
     Stop Traffic And UE Detach TL728
     Sleep    30s
     AlarmWatchdog.add_allow_alarms    fault_id=1868
     Reset BTS And check cell status TL728    cell_list_disable=${cell_list_728[2:3]}   cell_list_enable=${cell_list_728[0:2]}
     [Teardown]    CB012611-G Case Teardown

[1]CB012611-SR-G-04_single_Loki_for_Clock_failure_at_runtime_after_loki_reset
     [Setup]    CB012611-G Case Setup
     ${fault_id}    Create List    252    10
     AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
     Trigger clock failure    loki_type=B    slot_value=2
     Reset ABIO
     Wait until keyword succeeds    180 sec    10 sec    Expect Fault Should Present    faultId=252    severity=Critical
     ...    alarmId=7100    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_C:4
     Cell status Should Be Disabled and AvailabilityStatus Failed    cell_list=${cell_list_728[2:3]}
     Cell status Should Be enabled    cell_list=${cell_list_728[0:2]}
     sleep    20s
     Verify bbmod Should Be degraded    bbmod_index=2
     AlarmWatchdog.add_allow_alarms    fault_id=1868
     [Teardown]    CB012611-G Case09/04 Teardown    slot_value=2    loki_value=2    bbmod_index=2

[1]CB012611-SR-G-05_Delta_recommissioning_single_Loki_for_OIP_I2C_failure
    [Setup]    CB012611-G Case Setup
    ${fault_id}    Create List    252    10
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
    Trigger OIP I2C failure    loki_type=B    slot_value=2
    Wait until keyword succeeds    180 sec    10 sec    Expect Fault Should Present    faultId=252    severity=Major
    ...    alarmId=7100    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_C:3
    Verify bbmod Should Be degraded    bbmod_index=2
    Cell status Should Be Degraded    cell_list=${cell_list_728[2:3]}
    AlarmWatchdog.add_allow_alarms    fault_id=1868
    1Supercell with 3subcell change to 1Supercell with 2subcell and normal cell
    Wait until keyword succeeds    5 min    10 sec    Expect Fault Should Present    faultId=252    severity=Minor
    ...    alarmId=7115    configObjectName=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    supplementary=SoC_C:3
    Wait until keyword succeeds    5 min    10 sec    Expect Fault Should Present    faultId=1868    severity=Critical
        ...    alarmId=7114    configObjectName=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-4
        ...    supplementary=Not enough DSP or baseband pool resources for cell detected
    Wait until keyword succeeds    5 min    10 sec    Cell status Should Be enabled    cell_list=${cell_list_728[0:3]}
    Start Traffic And Check Throughput TL728   tp_ul=100M    tp_dl=300M    target_tp_ul=30    target_tp_dl=100
        ...    nrcell_id=${call_cell_id}
    Stop Traffic And UE Detach TL728
    Sleep    30s
    Reset BTS And check cell status TL728    cell_list_disable=${cell_list_728[3:4]}   cell_list_enable=${cell_list_728[0:3]}
    [Teardown]    CB012611-G Case Teardown