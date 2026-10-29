*** Settings ***
Documentation
...   author: Dawid Chuchnowski, dawid.chuchnowski@nokia.com, Andrzej Pencak, andrzej.pencak@nokia.com
...   maintainer: Dawid Chuchnowski, dawid.chuchnowski@nokia.com

Library    DateTime
Library    taf.sbts.oam.coam.admin                                              WITH NAME    admin
Library    taf.rfrl.bts.commissioning                                           WITH NAME    commission
Library    taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations       WITH NAME    gnb_asir
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations            WITH NAME    gnbcell
Library    taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations                WITH NAME    gnbru
Library    taf.rfrl.utilities.test_config.DefaultFileLocation                   WITH NAME    dfl
Library    taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger

*** Variables ***
${skip_commissioning}=     ${NONE}
@{allowed_alarms}    SSH enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  Service account root access is enabled
...                  Ethernet port security is disabled

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


Decrease cooling fan speed
    [Documentation]    Keyword logs in to bts and decreses cooling fan speed to trigger fault 4079
    logger.Log Info to Console    Decrease cooling fan speed
    ${command}=    catenate    SEPARATOR=
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 'systemctl stop temp_ctrl;
    ...    for i in {1..1800}; do echo 100 > /dev/ddal/fan/0/pwm; echo 100 > /dev/ddal/fan/1/pwm; sleep 1;
    ...    done </dev/null &>/dev/null &'
    Run    ${command}


Restore normal cooling fan speed
    [Documentation]    Keyword logs in to bts and restores normal cooling fan speed
    logger.Log Info to Console    Restore normal cooling fan speed
    ${command}=    catenate    SEPARATOR=
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 'systemctl start temp_ctrl;
    ...    ps -elf | tr -s " " | grep "sleep 1" | cut -f 5 -d " " | xargs kill -9'
    Run    ${command}


Check fault 4079 is reported
    [Documentation]    Keyword checks that alarm with fault 4079 is reported in BTS
    logger.Log Info to Console    Wait until fault 4079 is reported
    Verify Alarm is Active on gNB    fault_name=Cooling fan speed decreased    fault_id=4079    severity=Minor
    logger.Log Info to Console    Fault 4079 is reported

Check fault 4079 is not reported
    [Documentation]    Keyword checks that alarm with fault 4079 is reported in BTS
    logger.Log Info to Console    Check that fault 4079 is not reported
    Verify Alarm is not Active on gNB    fault_name=Cooling fan speed decreased    fault_id=4079    severity=Minor


Set MRBTS ID
    [Documentation]    This keywords reads MRBTS ID and stores it in variable
    admin.Setup admin
    ${out_mrbts_id}=    admin.Get Bts Info
    Set Suite Variable    ${MRBTS_ID}    ${out_mrbts_id['mrbtsID']}
