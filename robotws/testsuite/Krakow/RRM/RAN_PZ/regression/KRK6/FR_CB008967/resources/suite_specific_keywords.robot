*** Settings ***
Documentation
...   author: Dawid Chuchnowski, dawid.chuchnowski@nokia.com
...   maintainer: Dawid Chuchnowski, dawid.chuchnowski@nokia.com

Library    DateTime
Library    taf.sbts.oam.coam.admin                                              WITH NAME    admin
Library    taf.rfrl.bts.commissioning                                           WITH NAME    commission
Library    taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations       WITH NAME    gnb_asir
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations            WITH NAME    gnbcell
Library    taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations                WITH NAME    gnbru
Library    taf.rfrl.utilities.test_config.DefaultFileLocation                   WITH NAME    dfl
Library    taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger
Library    CB008967_keywords.py
Library    snapshot_operations.py

*** Variables ***
${skip_commissioning}=     ${NONE}
@{allowed_alarms}    SSH enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  Service account root access is enabled
...                  Ethernet port security is disabled
${LSS_USERNAME}=    ute

*** Keywords ***
Suite Setup
    [Documentation]    Performs commissioning on gNB
    logger.Log Banner to Console    Suite Setup started
    Run Keyword If    '${skip_commissioning}'!='true'    Perform Commissioning on BTS   CB008967_MRBTS-77122_SCF.xml   CB008967_ASIR.xml
    Set MRBTS ID
    logger.Log Banner to Console    Suite Setup finished

Perform Commissioning on BTS
    [Arguments]     ${scfc_file}    ${asir_xml}
    [Documentation]    Perform full commissioning on gNB and waits for all cells to reach onAir state
    ...                :param scfc_file:    name of Site Commisioning File
    ...                :param asir_xml:    name of xml file for ASiR Commissioning
    ${commissioning_files_directory}=    dfl.Get Commissioning Dir
    logger.Log Info to Console    Upload default swconfig.txt
    commission.Upload swconfig on classical gnb      sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt
    logger.Log Info to Console    Perform Full Commissioning On Classical gNB with file ${scfc_file}
    commission.Perform Full Commissioning On Classical Gnb    bts_id=0    scf_path=${commissioning_files_directory}/${scfc_file}
    logger.Log Info to Console    Perform ASIR Commissioning On Classical gNB with file ${asir_xml}
    gnb_asir.Perform Asir Commissioning    scf_path=${commissioning_files_directory}/${asir_xml}    migrate_nidd=True
    logger.Log Info to Console    Wait until Setup is onAir
    Wait Until Keyword Succeeds    12min    15s    gnbcell.Verify All Cells Are Onair   du_id=0

Perform Commissioning on BTS without ASIR
    [Arguments]     ${scfc_file}
    [Documentation]    Perform full commissioning on gNB and waits for all cells to reach onAir state
    ...                :param scfc_file:    name of Site Commisioning File
    ${commissioning_files_directory}=    dfl.Get Commissioning Dir
    logger.Log Info to Console    Upload default swconfig.txt
    commission.Upload swconfig on classical gnb      sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt
    logger.Log Info to Console    Perform Full Commissioning On Classical gNB with file ${scfc_file}
    commission.Perform Full Commissioning On Classical Gnb    bts_id=0    scf_path=${commissioning_files_directory}/${scfc_file}
    logger.Log Info to Console    Wait until Setup is onAir
    Wait Until Keyword Succeeds    12min    15s    gnbcell.Verify All Cells Are Onair   du_id=0

Change Parameter On DU
    [Arguments]    ${value}  ${internal_dist_name}  ${name}  ${operation}=update
    [Documentation]     This keyword change selected parameter on gNB
    ...     :param value: value for parameter which will be set
    ...     :param internal_dist_name: distinguisive name for parameter which will be change
    ...     :param parameter name: name of parameter which will be change
    ...     :param operation: type of operation, "update" by default
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=${internal_dist_name}
    ...  param_name=${name}  param_value=${value}  skip_parameter_relation_errors=true  operation=${operation}
    ...  timeout=300
    Wait Until Keyword Succeeds    7min    10s    gnb_cells.Verify All Cells Are OnAir

Wait for a next PM interval
    Wait for next full pm interval

Wait for a next full PM interval
    Wait for next full pm interval
    Wait for next full pm interval

Check RaD counters
    [Documentation]    Downloads R&D counters and verifies TEMP_RANGE counters
    Wait for next full pm interval
    logger.Log Info to Console    Download and check R&D counters
    Run    rm -rf ${OUTPUT_DIR}/RD_BTS_counters
    Run    sshpass -p oZPS0POrRieRtu scp 192.168.255.129:/tmp/RD.BTS* ${OUTPUT_DIR}/RD_BTS_counters/
    Run    cd ${OUTPUT_DIR}/RD_BTS_counters/ && ls *.xml.gz | tail -n 1 | xargs gunzip
    Log full RD counters
    Check temp range RD counters    interval=5

Check RMOD RaD counters
    [Arguments]   ${rmod_no}=1
    [Documentation]    Downloads R&D counters and verifies RMOD TEMP_RANGE counters
    ...                :param rmod_no:     number of RMODs
    logger.Log Info to Console    Download and check R&D counters
    Run    rm -rf ${OUTPUT_DIR}/RD_BTS_counters
    Run    sshpass -p oZPS0POrRieRtu scp 192.168.255.129:/tmp/RD.BTS* ${OUTPUT_DIR}/RD_BTS_counters/
    Run    cd ${OUTPUT_DIR}/RD_BTS_counters/ && ls *.xml.gz | tail -n 1 | xargs gunzip
    Log full RD counters
    Check RMOD temp range RD counters    rmod_no=${rmod_no}

Check ASIRMOD RaD counters
    [Arguments]   ${asirmod_no}=2
    [Documentation]    Downloads R&D counters and verifies ASIRMOD TEMP_RANGE counters
    ...                :param asirmod_no:     number of ASIRMODs
    logger.Log Info to Console    Download and check R&D counters
    Run    rm -rf ${OUTPUT_DIR}/RD_BTS_counters
    Run    sshpass -p oZPS0POrRieRtu scp 192.168.255.129:/tmp/RD.BTS* ${OUTPUT_DIR}/RD_BTS_counters/
    Run    cd ${OUTPUT_DIR}/RD_BTS_counters/ && ls *.xml.gz | tail -n 1 | xargs gunzip
    Log full RD counters
    Check ASIRMOD temp range RD counters    interval=5    asirmod_no=${asirmod_no}

Collect snapshot from BTS
    [Documentation]    Downloads BTS snapshot with name dependent on date and time
    logger.Log Info to Console    Downloading BTS Snapshot
    ${date_full}=    get current date
    ${date}=    Convert date    ${date_full}    datetime
    ${name}=   set variable    Snapshot_${MRBTS_ID}_${date.year}_${date.month}_${date.day}_${date.hour}_${date.minute}.zip
    admin.Collect Snapshot    target_file_name=${OUTPUT_DIR}/${name}

Start syslog collecting
    [Documentation]    This keyword starts syslog collecting with name dependent on date and time
    logger.Log Info to Console    Syslog collecting started
    ${date_full}=    get current date
    ${date}=    Convert date    ${date_full}    datetime
    ${name}=   set variable    Syslog_${MRBTS_ID}_${date.year}_${date.month}_${date.day}_${date.hour}_${date.minute}.log
    Start syslog    log_dir=${OUTPUT_DIR}    log_name=${name}

Set MRBTS ID
    [Documentation]    This keywords reads MRBTS ID and stores it in variable
    admin.Setup admin
    ${out_mrbts_id}=    admin.Get Bts Info
    Set Suite Variable    ${MRBTS_ID}    ${out_mrbts_id['mrbtsID']}

Configure first KPI analyzer alarm
    [Documentation]    Configure first of KPI analyzer triggered alarm
    Activate lssConfig parameter    snap_dest=lss    lss_ip=192.168.255.126    lss_port=22
    ${LSS_PASSWORD}=    Get VM Password
    Configure LSS Account    lss_username=${LSS_USERNAME}    lss_password=${LSS_PASSWORD}
    Delete All Existing LSS Snapshots

    ${list_param_to_change2}=    Create Dictionary    faultNumber    4588
    Set To Dictionary    ${list_param_to_change2}    snapshotCoverageLevel=Full
    Set To Dictionary    ${list_param_to_change2}    triggerType=onFaultDetection
    @{list2}=    Create List    ${list_param_to_change2}
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    param_name=faultSnapshotTriggers
    ...    param_value=@{list2}
    ...    operation=update
    ...    timeout=300

    Change Parameter On DU
    ...    name=actKpiAlarms
    ...    internal_dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    value=true
    ...    operation=update

    ${list_param_to_change}=    Create Dictionary    faultID    4588
    Set To Dictionary    ${list_param_to_change}    formulaDescription=Cabinet_fan_speed_formula_1
    Set To Dictionary    ${list_param_to_change}    timeToTrigger=1
    Set To Dictionary    ${list_param_to_change}    triggeringFormula=SBTS_CAB_MIN_FANSPEED +SBTS_CAB_MAX_FANSPEED >= 0
    @{list}=    Create List    ${list_param_to_change}
    ${object_dict}=    Create Dictionary    parameterName    kpiAlarmTriggers
    Set To Dictionary    ${object_dict}    operation=update
    Set To Dictionary    ${object_dict}    value=@{list}
    @{object_list}=    Create List    ${object_dict}
    Perform Object Recommissioning On gNB
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=@{object_list}
    ...    operation=update
    ...    timeout=300

Configure first ASIRMOD KPI analyzer alarm
    [Documentation]    Configure first of ASIRMOD KPI analyzer triggered alarm
    Activate lssConfig parameter    snap_dest=lss    lss_ip=192.168.255.126    lss_port=22
    ${LSS_PASSWORD}=    Get VM Password
    Configure LSS Account    lss_username=${LSS_USERNAME}    lss_password=${LSS_PASSWORD}
    Delete All Existing LSS Snapshots

    ${list_param_to_change2}=    Create Dictionary    faultNumber    4579
    Set To Dictionary    ${list_param_to_change2}    snapshotCoverageLevel=Full
    Set To Dictionary    ${list_param_to_change2}    triggerType=onFaultDetection
    @{list2}=    Create List    ${list_param_to_change2}
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    param_name=faultSnapshotTriggers
    ...    param_value=@{list2}
    ...    operation=update
    ...    timeout=300

    Change Parameter On DU
    ...    name=actKpiAlarms
    ...    internal_dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    value=true
    ...    operation=update

    ${list_param_to_change}=    Create Dictionary    faultID    4579
    Set To Dictionary    ${list_param_to_change}    formulaDescription=ASIRMOD_fan_speed_formula_1
    Set To Dictionary    ${list_param_to_change}    timeToTrigger=1
    Set To Dictionary    ${list_param_to_change}    triggeringFormula=SBTS_ASIR_MIN_FANSPEED+SBTS_ASIR_MAX_FANSPEED >=0
    @{list}=    Create List    ${list_param_to_change}
    ${object_dict}=    Create Dictionary    parameterName    kpiAlarmTriggers
    Set To Dictionary    ${object_dict}    operation=update
    Set To Dictionary    ${object_dict}    value=@{list}
    @{object_list}=    Create List    ${object_dict}
    Perform Object Recommissioning On gNB
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=@{object_list}
    ...    operation=update
    ...    timeout=300


Configure KPI analyzer alarm
    [Arguments]    ${faultID}    ${formulaDescription}    ${triggeringFormula}    ${timeToTrigger}=1
    [Documentation]    Configure KPI analyzer triggered alarm
    ${list_param_to_change}=    Create Dictionary    faultID    ${faultID}
    Set To Dictionary    ${list_param_to_change}    formulaDescription=${formulaDescription}
    Set To Dictionary    ${list_param_to_change}    timeToTrigger=${timeToTrigger}
    Set To Dictionary    ${list_param_to_change}    triggeringFormula=${triggeringFormula}
    @{list}=    Create List    ${list_param_to_change}
    ${object_dict}=    Create Dictionary    parameterName    kpiAlarmTriggers
    Set To Dictionary    ${object_dict}    operation=update
    Set To Dictionary    ${object_dict}    value=@{list}
    @{object_list}=    Create List    ${object_dict}
    Perform Object Recommissioning On gNB
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=@{object_list}
    ...    operation=update
    ...    timeout=300

Check alarm 4588 was raised and snaphot collected
    [Documentation]    Check if KPI analyzer alarm was raised and snapshot collected
    ${first_kpi_alarm_name} =    catenate    SEPARATOR=
    ...    The following KPI formula SBTS_CAB_MIN_FANSPEED +SBTS_CAB_MAX_FANSPEED >= 0 has been eval
    ...     uated to true: Cabinet_fan_speed_formula_1
    Verify Alarm is Active on gNB    fault_name=${first_kpi_alarm_name}    fault_id=4588    alarm_id=7115
    ...    severity=Minor
    Check that LSS snapshot has been collected

Check alarm 4579 was raised and snaphot collected
    [Documentation]    Check if KPI analyzer alarm was raised and snapshot collected
    ${first_kpi_alarm_name} =    catenate    SEPARATOR=
    ...    The following KPI formula SBTS_ASIR_MIN_FANSPEED+SBTS_ASIR_MAX_FANSPEED >=0 has been eval
    ...    uated to true: ASIRMOD_fan_speed_formula_1
    Verify Alarm is Active on gNB    fault_name=${first_kpi_alarm_name}    fault_id=4579    alarm_id=7115
    ...    severity=Minor

    Check that LSS snapshot has been collected

Check KPI analyzer alarm was raised
    [Arguments]    ${faultID}    ${formulaDescription}    ${triggeringFormula}
    [Documentation]    Check KPI analyzer triggered alarm was raised
    ${second_kpi_alarm_name} =    catenate    SEPARATOR=
    ...    The following KPI formula ${triggeringFormula} has been eval
    ...     uated to true: ${formulaDescription}
    Verify Alarm is Active on gNB    fault_name=${second_kpi_alarm_name}    fault_id=${faultID}    alarm_id=7115
    ...    severity=Minor

Check KPI analyzer alarm was not raised
    [Arguments]    ${faultID}    ${formulaDescription}    ${triggeringFormula}
    [Documentation]    Check KPI analyzer triggered alarm was not raised
    ${second_kpi_alarm_name} =    catenate    SEPARATOR=
    ...    The following KPI formula ${triggeringFormula} has been eval
    ...     uated to true: ${formulaDescription}
    Verify Alarm is not Active on gNB    fault_name=${second_kpi_alarm_name}    fault_id=${faultID}   alarm_id=7115
    ...    severity=Minor
