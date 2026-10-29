*** Settings ***
Documentation     This file contains keywords used for CB013544 automation cases.

Library      ta5g_pm_counters
Library      taf.sbts.oam.coam.admin         WITH NAME    admin
Library      taf.sw.syslog                   WITH NAME    slog
Library      taf.collectors.tcpdump    WITH NAME    tcpdump
Library      taf.collectors.core    WITH NAME    core
Library      taf.collectors.tshark        WITH NAME    tshark
Resource     ${CURDIR}/tsharkPcapVerifyKeywords.robot
Resource     ${CURDIR}/enb_Keywords.robot
Resource     ${CURDIR}/../../../T12/resources/Keywords/generic_kw.robot

*** Variables ***
${local_cell_id_1}=                 DN:NE-LNBTS-1/LNCEL-1/MCC-244/MNC-08/CMCC-555/CMNC-12
${local_cell_id_2}=                 DN:NE-LNBTS-1/LNCEL-1/MCC-244/MNC-08
${Log_Path}=         /home/ute/logs
${pcap_file_path}    /home/ute/logs
${BFac_3}    (((cus.cell_index == 1) && (lte-rrc.ac_BarringFactor == 3)) && (lte-rrc.ac_BarringTime == 0)) && (lte-rrc.ac_BarringForSpecialAC == 00:)
${BFac_2}    (((cus.cell_index == 1) && (lte-rrc.ac_BarringFactor == 2)) && (lte-rrc.ac_BarringTime == 2)) && (lte-rrc.ac_BarringForSpecialAC == 00:)
${BFac_1}    (((cus.cell_index == 1) && (lte-rrc.ac_BarringFactor == 1)) && (lte-rrc.ac_BarringTime == 5)) && (lte-rrc.ac_BarringForSpecialAC == 00:)
${BFac_0}    (((cus.cell_index == 1) && (lte-rrc.ac_BarringFactor == 0)) && (lte-rrc.ac_BarringTime == 7)) && (lte-rrc.ac_BarringForSpecialAC == 00:)
${stepwise_increase}           stepwise_increase
${stepwise_decrease}           stepwise_decrease
${start_HO}            start_HO
${HO_failure}          HO_failure
${HO_success}          HO_success

*** Keywords ***
HO_Failure
     [Documentation]   This keyword simulates a Handover (HO) failure scenario
     [Arguments]       ${UE_ID}     ${CELL_ID}
     Start pcap collection in eth4      name=HO_failure
     Run UEx command   ue_measurement_send     id=${UE_ID}    phycell_id=${CELL_ID}       event=A3
     ...     nrsrp=97    nrsrq=20     tac=123     ecgi=244:08|769     son=true    amount=1
     sleep    60s
     ${pcap_file_path}     Stop pcap collection in gNB 13544   ${HO_failure}    ${Log_Path}
     Count Of Messages Matching Filter Should Be Equal to zero    ${pcap_file_path}    lte-rrc.handoverType == 0
     ...    RRCConnectionReconfiguation     0
     Log to Console    \n HO failure scenario completed

HO_Success
     [Documentation]    This keyword simulates a successful Handover (HO) scenario
     [Arguments]       ${UE_ID}     ${CELL_ID}
     Start pcap collection in eth4      name=HO_success
     Run UEx command   ue_measurement_send     id=${UE_ID}    phycell_id=${CELL_ID}       event=A3    nrsrp=97    nrsrq=20
     ...     tac=123     ecgi=244:08|769     son=true    amount=1
     sleep    60s
     ${pcap_file_path}     Stop pcap collection in gNB 13544   ${HO_success}    ${Log_Path}
     Count Of Messages Matching Filter Should Be Equal to one    ${pcap_file_path}    lte-rrc.handoverType == 0
     ...    RRCConnectionReconfiguration     1
     Log to Console    \n HO success scenario completed

Check counter value is less than max threshold
    [Documentation]     This keyword is used to verify if a counter value is less than a specified maximum threshold
    [Arguments]   ${Counter_on}
    Run keyword and continue on failure  Should be true  ${Counter_on} < 300

Check counter value is equal to max threshold
    [Documentation]    This keyword is used to verify if a counter value is equal to the specified maximum threshold
    [Arguments]   ${Counter_on}
    Run keyword and continue on failure  Should be true  ${Counter_on} == 300

Check counter value is non zero
    [Documentation]     This keyword is to used to verify that a counter value is greater than zero
    [Arguments]   ${Counter_on}
    Run keyword and continue on failure  Should be true  ${Counter_on} > 0

Check counter value is zero
    [Documentation]     This keyword is used to verify that a counter value is equal to zero
    [Arguments]   ${Counter_on}
    Run keyword and continue on failure  Should be true  ${Counter_on} == 0

Setup testline with yaml
    [Documentation]    This keyword is used configure coco.yaml, scf then adds syslog flags in swconfig file followed by site reset
    Add Simulator   sim_type=cus    config=${cus_yaml}
    Add Enb Configuration           scfc=${scfc}
    Configure environment
    Add RD Parameters Directly On GNB      ${SYSLOG_FlAG1}
    Add RD Parameters Directly On GNB      ${SYSLOG_FlAG2}
    Add RD Parameters Directly On GNB      ${SYSLOG_FlAG3}
    Site Reset For Gnb
    sleep    300s

Stop Default Logging For CUS And Compress Test Logs
    Run UEx command    ue_detach  all

Prepare For Test Case CB013544_A
    [Documentation]    test case setup for CB013544_A
    run keyword and continue on failure    configuration_id.Link SCOUT SCF to Configuration ID for Reporting
    slog.Start Syslog     ${Log_Path1}   SYSLOG_1.LOG
    Log to Console    \nSyslog started
    Monitor Alarm
    taf.ul.alarms_watchdog.get_active_alarms

Prepare For Test Case CB013544_C
    [Documentation]    test case setup for CB013544_C
    run keyword and continue on failure    configuration_id.Link SCOUT SCF to Configuration ID for Reporting
    slog.Start Syslog     ${Log_Path2}   SYSLOG_2.LOG
    Log to Console    \nSyslog started
    Monitor Alarm
    taf.ul.alarms_watchdog.get_active_alarms

Start pcap collection in eth4
    [Documentation]    Start Pcap collection In GNB CU
    [Arguments]    ${name}=gnbTcpdump    ${options}=-i eth4
    tcpdump.Create Tcpdump Collector
    ...     name=${name}
    ...     options=${options}
    core.Setup Collectors    names=${name}
    core.Start Collectors    names=${name}
    tcpdump.Set test Alias    ${name}
    Log to Console    \nWireshark started

Stop pcap collection in gNB 13544
    [Documentation]    Stop Pcap collection In GNB CU
    [Arguments]     ${name}   ${Log_Path}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${Log_Path}
    core.teardown_collectors    names=${name}
    ${pcap_file_path}=   set variable    ${Log_Path}/${name}/${name}.pcap
    [Return]     ${pcap_file_path}
    Log to Console    \nWireshark stopped

Site Reset For Gnb
    [Documentation]     This keyword is used to Site Reset
    Log to Console    \n site reset is started
    admin.Setup Admin
    admin.reset_site      reset_coverage=Site     wait_for_reconnection=True    graceful_cell_shutdown=True
    [Teardown]      admin.Teardown Admin

Teardown for CB013544_A
    [Documentation]    This keyword is to bring down the test environment for CB013544
    Log to Console    \n Teardown is started
    syslog validation for error prints for TC1
    Collect Syslog Results                destination=${Log_Path1}
    check_detected_alarms
    taf.ul.alarms_watchdog.get_active_alarms
    stop_watching_alarms
    Snapshot Collection     ${Log_Path1}     Snapshot.zip

Teardown for CB013544_C
    [Documentation]    This keyword is to bring down the test environment for CB013544
    Log to Console    \n Teardown is started
    syslog validation for error prints for TC2
    Collect Syslog Results                destination=${Log_Path2}
    check_detected_alarms
    taf.ul.alarms_watchdog.get_active_alarms
    stop_watching_alarms
    Snapshot Collection     ${Log_Path2}     Snapshot.zip

Accepted_alarm_list
    [Documentation]     This keyword creates a list of accepted alarms.
    ${allowed_alarm_1}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4655
    ...                    fault_name=Service account root access is enabled
    ${allowed_alarm_2}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4654
    ...                    fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61524
    ...                    fault_name=SSH enabled
    ${allowed_alarm_4}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61652
    ...                    fault_name=R&D Service Port enabled
    ${allowed_alarm_5}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61649
    ...                    fault_name=LMP access via port 443
    ${allowed_alarm_6}=    Create alarm
    ...                    alarm_id=7115
    ...                    fault_id=4592
    ...                    fault_name=BTS Reset Cause
    ${allowed_alarms}=     Create list
    ...                    ${allowed_alarm_1}
    ...                    ${allowed_alarm_2}
    ...                    ${allowed_alarm_3}
    ...                    ${allowed_alarm_4}
    ...                    ${allowed_alarm_5}
    ...                    ${allowed_alarm_6}
    [Return]    ${allowed_alarms}

Monitor Alarm
    [Documentation]     This keyword is to check current alarms on gnB and return list of alarms
    ${allowed_alarms}=      Accepted_alarm_list
    Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=oam

Calculate average tput for UE
    [Documentation]     This keyword calculates the average throughput for a UE (User Equipment) and verifies if it meets the expected threshold
    [Arguments]       ${trf_id}       ${ue_id}     ${dir}     ${exp_tput}
    ${trf_stats}=  Run UEx command   get_trf_data_stats    trf_id=${trf_id}    ue=${ue_id}    unit=Mbps
    ${tputs_ue}=   Get From Dictionary  ${trf_stats}  ${dir}
    ${tput_avg}=   Get From Dictionary  ${tputs_ue}  avg
    ${tput_success_rate}=  Evaluate  ${tput_avg}/${exp_tput} * 100
    Should Be True    "${tput_success_rate}" >= "95"
    Log To Console  Achieved AVG UE${ue_id} ${dir} tput: ${tput_avg}Mbps (${tput_success_rate}%) / Expected: ${exp_tput}Mbps
    [Return]  ${tput_success_rate}

syslog validation for error prints for TC1
    [Documentation]     This keyword is used to validate that there are no error prints in the syslog file
    run keyword and expect error    ParsingError: Cannot find any string matching regexp (ERR/) in file (/home/ute/logs/CB013344_A/SYSLOG_1.LOG)
    ...         Wait for message in syslog file       regexp=ERR/    timeout=1min 5s
    ${result}   Count syslog messages       regexp=ERR/
    ${result1}   Count syslog messages       regexp=Fatal
    Should Be True    "${result}" == "0"
    Should Be True    "${result1}" == "0"

syslog validation for error prints for TC2
    [Documentation]     This keyword is used to validate that there are no error prints in the syslog file, here as ho blocked scenario is
    ...                 performed for ONE UE SO IT IS EXPECTED ERR/ PRINT (WRN/UEC/UecHoPrepTgt.cpp#1391)
    ${result}   Count syslog messages       regexp=ERR/
    ${result1}   Count syslog messages       regexp=Fatal
    Should Be True    "${result}" == "0"
    Should Be True    "${result1}" == "0"

Checking for SIB2 in pcap
     [Documentation]     This keyword is to check be checking for the presence of System Information Block Type 2 (SIB2) messages in a PCAP file
     ...                  at different barring factor (BFac)
     [Arguments]       ${path}
     Count Of Messages Matching Filter Should Be Equal     ${path}        ${BFac_3}       SIB2        1
     Count Of Messages Matching Filter Should Be Equal     ${path}        ${BFac_2}       SIB2        1
     Count Of Messages Matching Filter Should Be Equal     ${path}        ${BFac_1}       SIB2        1
     Count Of Messages Matching Filter Should Be Equal     ${path}        ${BFac_0}       SIB2        1
