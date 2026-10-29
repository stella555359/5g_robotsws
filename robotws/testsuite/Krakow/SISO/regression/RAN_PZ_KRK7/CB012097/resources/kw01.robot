*** Settings ***
Documentation
...   Keywords file for CB012097
...   author:
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)

Library      Collections
Library      keywords_CB012097_01.py                                    WITH NAME    lib01
Library      common.py
Library      SSHRMOD.py                               ${conn_level_map_a}            WITH NAME    SSHRMOD_A
Library      SSHRMOD.py                               ${conn_level_map_b}            WITH NAME    SSHRMOD_B
Library      Fault_verifier.py
Variables    variables01.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/gnb.robot


*** Keywords ***
Prepare SSH connection to Container, AHFIG
    ${sshrmod}=    Get Library Instance    SSHRMOD_A
    Set Test Variable    ${sshrmod}
    SSHRMOD_A.Open Host Connection    ${SMOD_ADDR}    ${SMOD_USER}    ${SMOD_PASS}
    SSHRMOD_A.Attach To Container    0x2018
    Log To Console    Attached to container

Prepare RMOD ${rmod_type:AHFIG} environment
    common.Login To Rmod    ${sshrmod}    ${rmod_type}
    lib01.Prepare Tcs Json    ${sshrmod}    ${rmod_type}
    lib01.Prepare Fans Json    ${sshrmod}    ${rmod_type}    sw_version=SBTS26R2_ENB_9999_260128_000000
    SSHRMOD_A.Logout From Rmod    ${rmod_type}
    Log To Console    RMOD ${rmod_type} environment prepared

Prepare SSH connection to Container, AHEGA
    ${sshrmod}=    Get Library Instance    SSHRMOD_B
    Set Test Variable    ${sshrmod}
    SSHRMOD_B.Open Host Connection    ${SMOD_ADDR}    ${SMOD_USER}    ${SMOD_PASS}
    SSHRMOD_B.Attach To Container    0x2018
    Log To Console    Attached to container

Prepare RMOD ${rmod_type:AHEGA} environment
    common.Login To Rmod    ${sshrmod}    ${rmod_type}
    lib01.Prepare Tcs Json    ${sshrmod}    ${rmod_type}
    lib01.Prepare Fans Json    ${sshrmod}    ${rmod_type}
    SSHRMOD_B.Logout From Rmod    ${rmod_type}
    Log To Console    RMOD ${rmod_type} environment prepared

Set TCS parameter ${param} to value=${value} on ${rmod:AHFIG}${skip:, skip reboot|}.
    [Documentation]  Choose if reboot the RMOD afterwards. Example: Set TCS parameter Nrpm_fail to value=1 on APHA.
    ${rmod_ip}=    common.Login To Rmod    ${sshrmod}    ${rmod}
    lib01.Fetch Tcs    ${sshrmod}    ${rmod}
    SSHRMOD_A.Edit Rmod Json    {'${param}': ${value}}    ${rmod}    /ram/tcs_parameters.json    tcs
    lib01.Store Tcs    ${sshrmod}    ${rmod}
    Builtin.Sleep    2
    SSHRMOD_A.Logout From Rmod
    IF    not $skip
        ${radio_unit_id}=    common.get_rmod_id    ${rmod}
        Reset gNB Radio Unit    radio_unit_id=${radio_unit_id}
    END

Set TCS temperature threshold to ${thr:\d\d} degrees on ${rmod:AHFIG}${skip:, skip reboot|}.
    [Documentation]  Choose if reboot the RMOD afterwards
    ${rmod_ip}=    common.Login To Rmod    ${sshrmod}    ${rmod}
    lib01.Fetch Tcs    ${sshrmod}    ${rmod}
    SSHRMOD_A.Edit Rmod Json    {'Nrpm_fail': 1, 'Tblock': ${thr}}    ${rmod}    /ram/tcs_parameters.json    tcs
    lib01.Store Tcs    ${sshrmod}    ${rmod}
    Builtin.Sleep    2
    SSHRMOD_A.Logout From Rmod
    IF    not $skip
        ${radio_unit_id}=    common.get_rmod_id    ${rmod}
        Reset gNB Radio Unit    radio_unit_id=${radio_unit_id}
    END


Set TCS ${desc} by change parameters ${variable} on ${rmod:AHEGA}${skip:, skip reboot|}.
    [Documentation]  Choose if reboot the RMOD afterwards
    Log To Console    Set TCS ${desc} on ${rmod}...
    ${rmod_ip}=    common.Login To Rmod    ${sshrmod}    ${rmod}
    lib01.Fetch Tcs    ${sshrmod}    ${rmod}
    SSHRMOD_B.Edit Rmod Json    ${variable}    ${rmod}    /ram/tcs_parameters.json    tcs
    lib01.Store Tcs    ${sshrmod}    ${rmod}
    Builtin.Sleep    2
    SSHRMOD_B.Logout From Rmod
    IF    not $skip
        ${radio_unit_id}=    common.get_rmod_id    ${rmod}
        Reset gNB Radio Unit    radio_unit_id=${radio_unit_id}
    END


Set TCS ${desc} by change parameters ${variable} on ${rmod:AHFIG}${skip:, skip reboot|}.
    [Documentation]  Choose if reboot the RMOD afterwards
    Log To Console    Set TCS ${desc} on ${rmod}...
    ${rmod_ip}=    common.Login To Rmod    ${sshrmod}    ${rmod}
    lib01.Fetch Tcs    ${sshrmod}    ${rmod}
    SSHRMOD_A.Edit Rmod Json    ${variable}    ${rmod}    /ram/tcs_parameters.json    tcs
    lib01.Store Tcs    ${sshrmod}    ${rmod}
    Builtin.Sleep    2
    SSHRMOD_A.Logout From Rmod
    IF    not $skip
        ${radio_unit_id}=    common.get_rmod_id    ${rmod}
        Reset gNB Radio Unit    radio_unit_id=${radio_unit_id}
    END


${trigger:Trigger|Clear} Fault 1932 on AHFIG from all 2 fans${skip:, skip reboot|}.
    lib01.Fault 1932 AHFIG Toggle    ${sshrmod}    trigger=${trigger}    skip_reboot=${skip}
    common.Alter Faulty Objects    fault_id=1932    rmod_type=AHFIG    fans=1,2    trigger=${trigger}


${trigger:Trigger|Clear} Fault 1933 on AHFIG from all 2 fans${temp_low:, temperature not exceeded threshold|}.
    lib01.Fault 1933 AHFIG Toggle    ${sshrmod}    trigger=${trigger}    temp_low=${temp_low}
    common.Alter Faulty Objects    fault_id=1933    rmod_type=AHFIG    fans=1,2    trigger=${trigger}


${trigger:Trigger|Clear} Fault 1934 on AHFIG from all 2 fans.
    lib01.Fault 1934 AHFIG Toggle    ${sshrmod}    trigger=${trigger}
    common.Alter Faulty Objects    fault_id=1934    rmod_type=AHFIG    fans=1,2    trigger=${trigger}


${trigger:Trigger|Clear} Fault ${fault_id:1933|1934} on AHEGA from fan.
    lib01.Fault 1933 1934 AHEGA Toggle    ${sshrmod}    trigger=${trigger}
    common.Alter Faulty Objects    fault_id=${fault_id}    rmod_type=AHEGA    fans=1    trigger=${trigger}


Quick Trigger Fault 1933 on AHEGA.
    lib01.Fault 1933 1934 AHEGA Toggle    ${sshrmod}    trigger=${True}    prep=${False}
    common.Alter Faulty Objects    fault_id=1933    rmod_type=AHEGA    fans=1    trigger=${True}


Quick Trigger Fault 1934 on AHEGA.
    lib01.Fault 1933 1934 AHEGA Toggle    ${sshrmod}    trigger=${True}    prep=${False}    trig_1934=${True}
    common.Alter Faulty Objects    fault_id=1934    rmod_type=AHEGA    fans=1    trigger=${True}


Add fid: ${fid:1932|1933|1934} on fans: [${fans:[0-9,-]+|}] for rmod: ${rmod:AHFIG|AHEGA} to Faulty Objects.
    [Documentation]  Use as "fans: []" for adding only RMOD objects
    common.Alter Faulty Objects    fault_id=${fid}    rmod_type=${rmod}    fans=${fans}    trigger=Trigger

Remove fid: ${fid:1932|1933|1934} on fans: [${fans:[0-9,-]+|}] for rmod: ${rmod:AHFIG|AHEGA} from Faulty Objects.
    [Documentation]  Use as "fans: []" for removing only RMOD objects
    common.Alter Faulty Objects    fault_id=${fid}    rmod_type=${rmod}    fans=${fans}    trigger=Clear

