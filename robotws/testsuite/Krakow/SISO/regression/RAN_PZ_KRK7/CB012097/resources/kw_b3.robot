*** Settings ***
Documentation
...   Keywords file for CB012097
...   author:
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)

Library      Collections
Library      keywords_CB012097_b3.py                                    WITH NAME    lib01
Library      common.py
Library      SSHRMOD.py                               ${conn_level_map_b}            WITH NAME    SSHRMOD_B
Library      Fault_verifier.py
Variables    variables_b3.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/gnb.robot


*** Keywords ***
Prepare SSH connection to Container, AHLOA
    ${sshrmod}=    Get Library Instance    SSHRMOD_B
    Set Test Variable    ${sshrmod}
    SSHRMOD_B.Open Host Connection    ${SMOD_ADDR}    ${SMOD_USER}    ${SMOD_PASS}
    SSHRMOD_B.Attach To Container    0x1018
    Log To Console    Attached to container

Prepare RMOD ${rmod_type:AHEGA|AHLOA} with sn:${rmod_sn} environment
    common.Login To Rmod    ${sshrmod}    ${rmod_type}    ${rmod_sn}
    lib01.Prepare Tcs Json    ${sshrmod}    ${rmod_type}
    lib01.Prepare Fans Json    ${sshrmod}    ${rmod_type}
    SSHRMOD_B.Logout From Rmod    ${rmod_type}
    Log To Console    RMOD ${rmod_type} environment prepared

Set TCS ${desc} by change parameters ${variable} on ${rmod:AHEGA|AHLOA} with sn:${rmod_sn:\w+}${skip:, skip reboot|}.
    [Documentation]  Choose if reboot the RMOD afterwards
    Log To Console    Set TCS ${desc} on ${rmod}...
    ${rmod_ip}=    common.Login To Rmod    ${sshrmod}    ${rmod}    ${rmod_sn}
    lib01.Fetch Tcs    ${sshrmod}    ${rmod}
    SSHRMOD_B.Edit Rmod Json    ${variable}    ${rmod}    /ram/tcs_parameters.json    tcs
    lib01.Store Tcs    ${sshrmod}    ${rmod}
    Builtin.Sleep    2
    SSHRMOD_B.Logout From Rmod
    IF    not $skip
        ${radio_unit_id}=    common.get_rmod_id    ${rmod}    ${rmod_sn}
        Reset gNB Radio Unit    radio_unit_id=${radio_unit_id}
    END


${trigger:Trigger|Clear} Fault ${fault_id:1933|1934} on ${rmod:AHEGA|AHLOA} with sn:${rmod_sn} from fan.
    lib01.Fault 1933 1934 AHLOA Toggle    ${sshrmod}    trigger=${trigger}    rmod_sn=${rmod_sn}
    common.Alter Faulty Objects    fault_id=${fault_id}    rmod_type=${rmod}    fans=1    trigger=${trigger}


Quick Trigger Fault 1933 on ${rmod:AHEGA|AHLOA} with sn:${rmod_sn}.
    lib01.Fault 1933 1934 AHLOA Toggle    ${sshrmod}    trigger=${True}    prep=${False}    rmod_sn=${rmod_sn}
    common.Alter Faulty Objects    fault_id=1933    rmod_type=${rmod}    fans=1    trigger=${True}


Quick Trigger Fault 1934 on ${rmod:AHEGA|AHLOA} with sn:${rmod_sn}.
    lib01.Fault 1933 1934 AHLOA Toggle    ${sshrmod}    trigger=${True}    prep=${False}    trig_1934=${True}    rmod_sn=${rmod_sn}
    common.Alter Faulty Objects    fault_id=1934    rmod_type=${rmod}    fans=1    trigger=${True}


Add fid: ${fid:1932|1933|1934} on fans: [${fans:[0-9,-]+|}] for rmod: ${rmod:AHFIG|AHEGA|AHLOA} to Faulty Objects.
    [Documentation]  Use as "fans: []" for adding only RMOD objects
    common.Alter Faulty Objects    fault_id=${fid}    rmod_type=${rmod}    fans=${fans}    trigger=Trigger

Remove fid: ${fid:1932|1933|1934} on fans: [${fans:[0-9,-]+|}] for rmod: ${rmod:AHFIG|AHEGA|AHLOA} from Faulty Objects.
    [Documentation]  Use as "fans: []" for removing only RMOD objects
    common.Alter Faulty Objects    fault_id=${fid}    rmod_type=${rmod}    fans=${fans}    trigger=Clear
