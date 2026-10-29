*** Settings ***
Documentation
...   author: Andrzej Pencak, andrzej.pencak@nokia.com
...   maintainer: Andrzej Pencak, andrzej.pencak@nokia.com

Library    DateTime
Library    OperatingSystem
Library    Process
Library    taf.sbts.oam.coam.admin                                              WITH NAME    admin
Library    taf.rfrl.bts.commissioning                                           WITH NAME    commission
Library    taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations       WITH NAME    gnb_asir
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations            WITH NAME    gnbcell
Library    taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations                WITH NAME    gnbru
Library    taf.rfrl.utilities.test_config.DefaultFileLocation                   WITH NAME    dfl
Library    taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger



*** Variables ***
${HOST}         192.168.255.129
${USERNAME}     toor4nsn
${PASSWORD}     oZPS0POrRieRtu
${skip_commissioning}=     ${NONE}
@{allowed_alarms}    SSH enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  Service account root access is enabled
...                  Ethernet port security is disabled
@{ADDITIONAL_ALLOWED_ALARMS}=    4078    4079

${GNB_IP}=    192.168.255.129

*** Keywords ***
Suite Setup
    [Documentation]    Performs commissioning on gNB
    logger.Log Banner To Console    Suite Setup started
    Run Keyword If    '${skip_commissioning}'!='true'    Perform Commissioning on BTS   CB008967_MRBTS-77122_SCF.xml   CB008967_ASIR.xml
    Set MRBTS ID
    logger.Log Banner To Console    Suite Setup finished

Perform Commissioning on BTS
    [Arguments]     ${scfc_file}    ${asir_xml}
    [Documentation]    Perform full commissioning on gNB and waits for all cells to reach onAir state
    ...                :param scfc_file:    name of Site Commisioning File
    ...                :param asir_xml:    name of xml file for ASiR Commissioning
    ${commissioning_files_directory}=    dfl.Get Commissioning Dir
    logger.Log Info To Console    Upload default swconfig.txt
    commission.Upload swconfig on classical gnb      sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt
    logger.Log Info To Console    Perform Full Commissioning On Classical gNB with file ${scfc_file}
    commission.Perform Full Commissioning On Classical Gnb    bts_id=0    scf_path=${commissioning_files_directory}/${scfc_file}
    logger.Log Info To Console    Perform ASIR Commissioning On Classical gNB with file ${asir_xml}
    gnb_asir.Perform Asir Commissioning    scf_path=${commissioning_files_directory}/${asir_xml}    migrate_nidd=True
    logger.Log Info To Console    Wait until Setup is onAir
    Wait Until Keyword Succeeds    12min    15s    gnbcell.Verify All Cells Are Onair   du_id=0

Decrease cooling fan speed
    [Documentation]    Keyword logs in to bts and decreses cooling fan speed to trigger fault 4079
    logger.Log Info To Console    Decrease cooling fan speed
    ${command}=    catenate    SEPARATOR=
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 '
    ...    for i in {1..1800}; do echo 100 > /dev/ddal/fan/0/pwm; echo 100 > /dev/ddal/fan/1/pwm; sleep 1;
    ...    done </dev/null &>/dev/null &'
    Run    ${command}
    logger.Log Info To Console    Cooling fan speed decreased

Decrease cooling fan speed to zero
    [Documentation]    Keyword logs in to bts and decreses cooling fan speed to trigger fault 4078
    logger.Log Info To Console    Decrease cooling fan speed to zero
    ${command}=    catenate    SEPARATOR=
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 '
    ...    for i in {1..1800}; do echo 0 > /dev/ddal/fan/0/pwm; echo 0 > /dev/ddal/fan/1/pwm; sleep 1;
    ...    done </dev/null &>/dev/null &'
    Run    ${command}

Restore cooling fan speed
    [Documentation]    Keyword logs in to bts and stops decresed cooling fan speed
    ${command}=    catenate    SEPARATOR=
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 '
    ...    ps -elf | tr -s " " | grep "sleep 1" | cut -f 5 -d " " | xargs kill -9'
    Run    ${command}
    logger.Log Info To Console    Cooling fan speed restored.

Set MRBTS ID
    [Documentation]    This keywords reads MRBTS ID and stores it in variable
    admin.Setup admin
    ${out_mrbts_id}=    admin.Get Bts Info
    Set Suite Variable    ${MRBTS_ID}    ${out_mrbts_id['mrbtsID']}

Perform site reset in the background
    logger.Log Info To Console    Starting site reset in the background
    ${pid}=    Start Process    python    ${CURDIR}/site_reset.py

Check if background process finished
    ${res}=    Wait For Process    timeout=5min    on_timeout=terminate
    Log    Background process with site reset finished (rc=${res.rc}).

Wait until connection to BTS is restored
    Wait Until Keyword Succeeds    5min    3s     Check if BTS is not pingable
    Wait Until Keyword Succeeds    5min    3s     Check if BTS is pingable
    logger.Log Info To Console    BTS is pingable

Check if BTS is pingable
    ${rc}=    Run And Return RC    ping -c 1 192.168.255.129
    Should Be Equal As Integers    ${rc}    0    msg=BTS is not pingable, BTS did not recovered yet after Site Reset:

Check if BTS is not pingable
    ${rc}=    Run And Return RC    ping -c 1 192.168.255.129
    Should Be Equal As Integers    ${rc}    1    msg=BTS is still pingable, Site Reset was not done yet:
