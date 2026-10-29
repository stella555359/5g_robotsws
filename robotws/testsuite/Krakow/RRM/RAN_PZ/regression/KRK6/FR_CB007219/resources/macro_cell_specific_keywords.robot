*** Settings ***

Documentation
...  author:  Krzysztof Michalski, Jakub Bąk, Szymon Mastalski
...  contact: jakub.1.bak@nokia.com, krzysztof.michalski@nokia.com, szymon@mastalski@nokia.com


Library     SSHLibrary
Library     taf.sw.qualcomm.license   WITH NAME   license
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    Alarms

Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB007219/resources/suite_specific_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   taf/rfrl/bts/alarms/classical_alarms_definition.py

*** Variables ***
${skip_commissioning}    false
${current_ext_config}    none
@{CUSTOM_ALLOWED_ALARMS}
...    ${CLASSICAL_FAULT_7311}

*** Keywords ***

Macro Cell Suite Setup
    [Documentation]    This keyword prepares environment for each test suite.
    Run Keyword If    '${skip_commissioning}' != 'true'    Run Keywords
    ...    Log Action To Console     Perform commissioning on primary gNB                                       AND
    ...    Perform Full Commissioning on Classical gNB    bts_id=0    awaiting_time=600    prefix_tag=pri_94    AND
    ...    Log Action To Console    Perform commissioning on external gNB with config      ${current_ext_config}    AND
    ...    Perform Full Commissioning on Classical gNB    bts_id=1    awaiting_time=600    prefix_tag=ext_97    AND
    ...    Set Global Variable    ${current_ext_config}    ext_97
    Suite Setup

Test Setup With Ext-gNB Preparation
    [Arguments]    ${scf_prefix}=ext_97
    [Documentation]    Perform commissioning on external gNB
    ...                :param scf_prefix: scf_prefix to upload on gNB with id 1
    Run Keyword If    '${scf_prefix}' != '${current_ext_config}'     Run Keywords
    ...     Log Action To Console    Perform commissioning on external gNB with config ${scf_prefix}            AND
    ...     Perform Full Commissioning on Classical gNB    bts_id=1
    ...                           awaiting_time=600    prefix_tag=${scf_prefix}                                 AND
    ...     Set Global Variable    ${current_ext_config}    ${scf_prefix}
    sleep    100s
    Log Action to Console    Test Setup
    Common Preconditions With Watching Alarms
    ue.Require Ue    SDX_75  capabilities=REAL_UE

Test Setup With n77 USA Config Preparation
    [Documentation]    Upload n77 USA cells configuration on ext gNB before test setup
    ...    and activate actExtN77Support flag on prime gNB.
    Test Setup With Ext-gNB Preparation    scf_prefix=ext_n77_USA_97
    Toggle actExtN77Support flag    isActive=${true}

Test Teardown With n77 USA Flag Clean
    [Documentation]    Common test teardwon with deactivate of actExtn77Support flag on primary gNB
    Toggle actExtN77Support flag    isActive=${false}
    Common Test Teardown

Test Setup With n77 Canada Config Preparation
    [Documentation]    Upload n77 Canada cells configuration on ext gNB before test setup
    ...    and activate actExt2n77Support flag on prime gNB.
    Test Setup With Ext-gNB Preparation    scf_prefix=ext_n77_Canada_97
    Toggle actExt2N77Support flag    isActive=${true}

Test Teardown With n77 Canada Flag Clean
    [Documentation]    Common test teardwon with deactivate of actExt2N77Support flag on primary gNB
    Toggle actExt2N77Support flag    isActive=${false}
    Common Test Teardown

Test Setup Without CA MFBI
    [Documentation]    Common test setup with change PCell for test and set actMfbiNrCaSupportFr1 flag to false.
    Change PCell    1    4
    Test Setup With Ext-gNB Preparation
    Toggle actMfbiNrCaSupportFr1 flag    isActive=${false}

Test Teardown Without CA MFBI
    [Documentation]    Common test teardwon with change PCell abd actMfbiNrCaSupportFr1 flag activation.
    Change PCell    4    1
    Toggle actMfbiNrCaSupportFr1 flag    isActive=${true}
    Common Test Teardown

Open Connection And Log In
    [Arguments]    ${host}    ${username}    ${password}
    [Documentation]   Open a ssh connection to given host.
    ...    :param host:  Host to connect with.
    ...    :param username:  Host user login
    ...    :param password:   Host user password
    Log Action To Console    Open ssh connection to ${host} UE PC
    SSHLibrary.Open Connection         host=${host}
    SSHLibrary.Login               username=${username}        password=${password}

Move EFS File between PC and UE
    [Arguments]    ${from}    ${to}    ${device}
    [Documentation]    Move a file between PC and UE by PCAT and reboot UE to save changes. Overrite file if exsist.
    ...                Require open ssh connection to UE-PC and pcat license.
    ...    :param from: location from move EFS file
    ...    :param to: location where to move EFS file
    ...    :param device: adb device number
    Log Action To Console    Move efs mcc2arfcn file from ${from} to ${to}
    ${pcat_command}=    Set Variable    PCAT -PLUGIN EE -DEVICE ${device} -FS PRI -MODE COPY -TYPE FILE
    SSHLibrary.Execute Command     ${pcat_command} -FROM ${from} -TO ${to} -OVERRIDE TRUE
    Log Action To Console    Reboot UE to save efs change
    SSHLibrary.Execute Command    adb reboot
    Log Action To Console    Wait 30 seconds for UE reboot
    Sleep      30s

Change mcc2arfcn file
    [Arguments]     ${file}
    [Documentation]    Change mcc2arfcn.mdb file inside efs /mdb/nr folde on UE to another.
    ...    :param file: postfix of the mcc2arfcn file name on ue-pc
    macro_cell_specific_keywords.Open Connection And Log In   host=${ue_pc.host}
    ...                                username=${ue_pc.user}    password=${ue_pc.password}
    Move EFS File between PC and UE    from=${ue_pc.efs_location}mcc2arfcn-${file}.mdb
    ...                                to=${ue_pc.ue_mdb_file_location}mcc2arfcn.mdb
    ...                                device=${ue_pc.device}
    [Teardown]    Log Action To Console    Close ssh conection
    ...           AND                SSHLibrary.Close All Connections

Test Setup With n77-ext-2 band disable
    [Documentation]    Turn off n77-ext2 flag on pri-gNB. Disable n77-ext2 band on UE.
    Log Action To Console    Test Setup
    Change mcc2arfcn file    file=NoExt
    Test Setup With n77 Canada Config Preparation


Test Teardown With n77-ext-2 band enable
    [Documentation]    Change ext-gNB config to cell with n77-ext2 band.
    ...                Turn on n77-ext2 flag on pri-gNB. Enable n77-ext2 band on UE.
    Test Teardown With n77 Canada Flag Clean
    Change mcc2arfcn file    file=Canada
