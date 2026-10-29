*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...      == MAINTAINER ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>

Resource    ../../../resources/Robot/common_settings.robot
Library     taf.ul.ue.sim.env_setup
Library     taf.sbts.oam.coam.admin      WITH NAME    coam
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library     taf.rfrl.bts.devices.ru.ru_operations.GenericRuOperations            WITH NAME   GnbRadio
Library     SSHLibrary

*** Variables ***
${log_directory}=      /home/ute/logs/
@{faults_list}    1907    1908    1910    1911    1920    2922    2923
${ap_host}        192.168.200.1
${username}       toor4nsn
${password}       oZPS0POrRieRtu
${oamTermCmd}     /opt/UE_APP-OAM/service/OamTerm/oamTerm.py

*** Keywords ***
Test cleanup
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Metadata to Report for All BTSs

Run Setup
    [Arguments]
    Log To Console    Setup started
    Setup emss    node_id=1
    ${run_update}    get variable value      ${configure}    "True"    # do not ever change that line!

    Run Keyword if   ${run_update} != ${False}
    ...    Prepare TL with config files

    Setup egate  egate_port=20000  alias=default
    Setup devices aliases

Prepare TL with config files
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     Add gNB configuration    scfc=${SCFC}
     Add simulator    sim_type=airphone    config=${AP_XML}
     Add 5gc  config=${LUA_CFG}  edaemon_ports=10000
     Configure environment       rmod_detection_timeout=420s    validate_gnb=False
     Log To Console    After Configure ENV

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Verify that RU is in enabled state
    [Arguments]    ${ru_id}
    GnbRadio.verify_radio_unit_statuses
    ...    bts_id=0
    ...    ru_id=${ru_id}
    ...    operational_state=enabled
    ...    availability_status=online

Verify that RU is in degraded state
    [Arguments]    ${ru_id}
    GnbRadio.verify_radio_unit_statuses
    ...    bts_id=0
    ...    ru_id=${ru_id}
    ...    operational_state=enabled
    ...    availability_status=degraded

Verify that RU is in failed state
    [Arguments]    ${ru_id}
    GnbRadio.verify_radio_unit_statuses
    ...    bts_id=0
    ...    ru_id=${ru_id}
    ...    operational_state=disabled
    ...    availability_status=failed

Wait for RU to perform autonomus recovery
    [Arguments]    ${ru_id}
    Sleep    200s
    GnbRadio.wait_for_radio_unit_statuses    bts_id=0    ru_id=${ru_id}    availability_status=degraded

Trigger FID on AEHC mMIMO RU
    [Arguments]    ${ru_id}

    FOR  ${iterator}  IN RANGE    0    17
         Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1907 txArray1:${iterator} CRI persistent
         Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1907 txArray2:${iterator} CRI persistent
         Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1911 rxArray1:${iterator} CRI persistent
         Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1911 rxArray2:${iterator} CRI persistent
    END

Trigger FID on remaining AEHC mMIMO RU pipelines
    [Arguments]    ${ru_id}

    FOR  ${iterator}  IN RANGE    16    32
         Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1907 txArray1:${iterator} CRI persistent
         Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1907 txArray2:${iterator} CRI persistent
         Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1911 rxArray1:${iterator} CRI persistent
         Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1911 rxArray2:${iterator} CRI persistent
    END

Cancel FID on AEHC mMIMO RU
    [Arguments]    ${ru_id}

    FOR  ${iterator}  IN RANGE    0    32
         Execute AP AaShell Command    cancel_rf_fault ${ru_id} 1907 txArray1:${iterator}
         Execute AP AaShell Command    cancel_rf_fault ${ru_id} 1907 txArray2:${iterator}
         Execute AP AaShell Command    cancel_rf_fault ${ru_id} 1911 rxArray1:${iterator}
         Execute AP AaShell Command    cancel_rf_fault ${ru_id} 1911 rxArray2:${iterator}
    END

Trigger FID on AHFII RU
    [Arguments]    ${ru_id}

    FOR  ${iterator}  IN RANGE    1    5
        Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1907 antenna${iterator}a CRI persistent
        Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1907 antenna${iterator}b CRI persistent
        Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1911 antenna${iterator}a CRI persistent
        Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1911 antenna${iterator}b CRI persistent
    END

Trigger FID on remaining AHFII RU antennas
    [Arguments]    ${ru_id}

    FOR  ${iterator}  IN RANGE    4    5
        Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1907 antenna${iterator}a CRI persistent
        Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1907 antenna${iterator}b CRI persistent
        Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1911 antenna${iterator}a CRI persistent
        Execute AP AaShell Command    trigger_rf_fault ${ru_id} 1911 antenna${iterator}b CRI persistent
    END

Cancel FID on AHFII RU
    [Arguments]    ${ru_id}

    FOR  ${iterator}  IN RANGE    1    5
        Execute AP AaShell Command    cancel_rf_fault ${ru_id} 1907 antenna${iterator}a
        Execute AP AaShell Command    cancel_rf_fault ${ru_id} 1907 antenna${iterator}b
        Execute AP AaShell Command    cancel_rf_fault ${ru_id} 1911 antenna${iterator}a
        Execute AP AaShell Command    cancel_rf_fault ${ru_id} 1911 antenna${iterator}b
    END

Trigger additional FID 2922 on RU
    [Arguments]    ${ru_id}    ${array}
    Execute AP AaShell Command    trigger_rf_fault ${ru_id} 2922 ${array} MAJ persistent

Cancel additional FID 2922 on RU
    [Arguments]    ${ru_id}    ${array}
    Execute AP AaShell Command    cancel_rf_fault ${ru_id} 2922 ${array}

Execute AP AaShell Command
    [Arguments]    ${command}
    Log To Console    Executing ${command} on AP
    SSHLibrary.Open Connection     host=${ap_host}
    SSHLibrary.Login               username=${username}    password=${password}
    ${stdout}    SSHLibrary.Execute Command    command=${oamTermCmd} ${command}
    Sleep    2s    reason=Wait for the command to take effect
    [Teardown]    SSHLibrary.Close All Connections


