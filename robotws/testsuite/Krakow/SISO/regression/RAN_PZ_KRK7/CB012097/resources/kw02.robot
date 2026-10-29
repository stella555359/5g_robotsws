*** Settings ***
Documentation
...   Keywords file for CB012097
...   author:
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)

Library      Collections
Library      keywords_CB012097_02.py                                    WITH NAME    lib02
Library      common.py
Library      SSHRMOD.py                               ${conn_level_map}
Library      Fault_verifier.py
Variables    variables02.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/gnb.robot


*** Keywords ***
Prepare SSH connection to Container
    ${sshrmod}=    Get Library Instance    SSHRMOD
    Set Test Variable    ${sshrmod}
    SSHRMOD.Open Host Connection    ${SMOD_ADDR}    ${SMOD_USER}    ${SMOD_PASS}
    SSHRMOD.Attach To Container
    Log To Console    Attached to container

Prepare RMOD ${rmod_type:APHG|APHA} environment
    common.Login To Rmod    ${sshrmod}    ${rmod_type}
    lib02.Prepare Rmod Swconfig    ${sshrmod}    ${rmod_type}
    lib02.Prepare Tcs    ${sshrmod}    ${rmod_type}
    SSHRMOD.Logout From Rmod    ${rmod_type}
    Log To Console    RMOD ${rmod_type} environment prepared

${trigger:Trigger|Clear} Fault 1932 on ${rmod_type:APHA|APHG} from fan(s) [${fans}]${skip:, skip reboot|}.
    lib02.Fault 1932 Toggle    ${sshrmod}    ${rmod_type}    ${fans}    trigger=${trigger}    skip_reboot=${skip}
    common.Alter Faulty Objects    fault_id=1932    rmod_type=${rmod_type}    fans=${fans}    trigger=${trigger}

${trigger:Trigger|Clear} Fault 1933 on ${rmod_type:APHA} from fan(s) [${fans}]${skip:, skip reboot|}.
    lib02.Fault 1933 APHA Toggle    ${sshrmod}    ${rmod_type}    ${fans}    trigger=${trigger}    skip_reboot=${skip}
    common.Alter Faulty Objects    fault_id=1933    rmod_type=${rmod_type}    fans=${fans}    trigger=${trigger}

${trigger:Trigger|Clear} Fault 1933 on ${rmod_type:APHG} from fan(s) [${fans}].
    lib02.Fault 1933 APHG Toggle    ${sshrmod}    ${rmod_type}    ${fans}    trigger=${trigger}
    common.Alter Faulty Objects    fault_id=1933    rmod_type=${rmod_type}    fans=${fans}    trigger=${trigger}

${trigger:Trigger|Clear} Fault 1934 on APHG from all 4 fans${skip:, skip reboot|}.
    lib02.Fault 1934 APHG Toggle    ${sshrmod}    trigger=${trigger}    skip_reboot=${skip}
    common.Alter Faulty Objects    fault_id=1934    rmod_type=APHG    fans=1-4    trigger=${trigger}

Wait ${timeout} seconds for IP connectivity with ${rmod:APHA|APHG}
    ${ip}=    SSHRMOD.Get Rmod Ip    ${rmod}
    SSHRMOD.Wait For Ip Connectivity    ${ip}    timeout=${timeout}

Set TCS parameter ${param} to value=${value} on ${rmod:APHA|APHG}${skip:, skip reboot|}.
    [Documentation]  Choose if reboot the RMOD afterwards. Example: Set TCS parameter Nrpm_fail to value=1 on APHA.
    ${rmod_ip}=    common.Login To Rmod    ${sshrmod}    ${rmod}
    lib02.Fetch Tcs    ${sshrmod}    ${rmod}
    SSHRMOD.Edit Rmod Json    {'${param}': ${value}}    ${rmod}
    lib02.Store Tcs    ${sshrmod}    ${rmod}
    SSHRMOD.Logout From Rmod
    IF    not $skip
        ${radio_unit_id}=    common.get_rmod_id    ${rmod}
        Reset gNB Radio Unit    radio_unit_id=${radio_unit_id}
    END

Set TCS temperature threshold to ${thr:\d\d} degrees on ${rmod:APHA|APHG}${skip:, skip reboot|}.
    [Documentation]  Choose if reboot the RMOD afterwards
    ${rmod_ip}=    common.Login To Rmod    ${sshrmod}    ${rmod}
    lib02.Fetch Tcs    ${sshrmod}    ${rmod}
    SSHRMOD.Edit Rmod Json    {'Nrpm_fail': 1, 'Tblock': ${thr}}    ${rmod}
    lib02.Store Tcs    ${sshrmod}    ${rmod}
    SSHRMOD.Logout From Rmod
    IF    not $skip
        ${radio_unit_id}=    common.get_rmod_id    ${rmod}
        Reset gNB Radio Unit    radio_unit_id=${radio_unit_id}
    END

Add fid: ${fid:1932|1933|1934} on fans: [${fans:[0-9,-]+|}] for rmod: ${rmod:APHA|APHG} to Faulty Objects.
    [Documentation]  Use as "fans: []" for adding only RMOD objects
    common.Alter Faulty Objects    fault_id=${fid}    rmod_type=${rmod}    fans=${fans}    trigger=Trigger

Remove fid: ${fid:1932|1933|1934} on fans: [${fans:[0-9,-]+|}] for rmod: ${rmod:APHA|APHG} from Faulty Objects.
    [Documentation]  Use as "fans: []" for removing only RMOD objects
    common.Alter Faulty Objects    fault_id=${fid}    rmod_type=${rmod}    fans=${fans}    trigger=Clear

