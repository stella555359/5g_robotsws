*** Settings ***
Documentation
...   Keywords file for CB012097
...   author:
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)

Library      Collections
Library      keywords_CB012097_a2.py                                    WITH NAME    lib01
Library      common.py
Library      SSHRMOD.py                               ${conn_level_map_a}            WITH NAME    SSHRMOD_A
Library      Fault_verifier.py
Variables    variables_a2.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/gnb.robot


*** Keywords ***
Custom Suite Setup A2
    IF    $CUSTOM_ADDITIONAL_ALARMS_DURING_PREP
        @{list_argument}=    Evaluate    [el.strip() for el in $CUSTOM_ADDITIONAL_ALARMS_DURING_PREP.split(',')]
        Log    list_argument=${list_argument}  console=True
        @{ADDITIONAL_ALARMS_DURING_PREP}=    Create List    @{ADDITIONAL_ALARMS_DURING_PREP}    @{list_argument}
        Log    ADDITIONAL_ALARMS_DURING_PREP=${ADDITIONAL_ALARMS_DURING_PREP}  console=True
    END
    @{param_list}=    Set Variable    0x450027=1 #EnableDeveloperAccount
    ...                               0x980007=1 #PR804393 Fault 61675 "WiFi Configuration Issue"
    lib01.copy_and_modify_swconfig       ${param_list}
    ...                                  source_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...                                  target_path=/tmp/custom_swconfig.txt
    Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
    ...                                                  should_5G_neighbour_be_changed=${False}
    ...                                                  increase_time_for_checking_bbmod=600
    ...                                                  increase_timeout_for_update_sw=1800
    ...                                                  increase_time_for_checking_radios=2100
    ...                                                  increase_time_for_checking_cells=700
    ...                                                  swconfig_from_path=/tmp/custom_swconfig.txt
    ...                                                  list_of_additional_allowed_alarms=${ADDITIONAL_ALARMS_DURING_PREP}


Prepare SSH connection to Container, AREA
    ${sshrmod}=    Get Library Instance    SSHRMOD_A
    Set Test Variable    ${sshrmod}
    SSHRMOD_A.Open Host Connection    ${SMOD_ADDR}    ${SMOD_USER}    ${SMOD_PASS}
    SSHRMOD_A.Attach To Container    0x1018
    Log To Console    Attached to container

Prepare RMOD ${rmod_type:AREA} environment
    common.Login To Rmod    ${sshrmod}    ${rmod_type}
    lib01.Prepare Tcs Json    ${sshrmod}    ${rmod_type}
    lib01.Prepare Fans Json    ${sshrmod}    ${rmod_type}    sw_version=SBTS26R2_ENB_9999_260128_000000
    SSHRMOD_A.Logout From Rmod    ${rmod_type}
    Log To Console    RMOD ${rmod_type} environment prepared

Set TCS parameter ${param} to value=${value} on ${rmod:AREA}${skip:, skip reboot|}.
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

Set TCS temperature threshold to ${thr:\d\d} degrees on ${rmod:AREA}${skip:, skip reboot|}.
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


Set TCS ${desc} by change parameters ${variable} on ${rmod:AREA}${skip:, skip reboot|}.
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


${trigger:Trigger|Clear} Fault 1932 on AREA from all 2 fans${skip:, skip reboot|}.
    lib01.Fault 1932 AREA Toggle    ${sshrmod}    trigger=${trigger}    skip_reboot=${skip}
    common.Alter Faulty Objects    fault_id=1932    rmod_type=AREA    fans=1,2    trigger=${trigger}


${trigger:Trigger|Clear} Fault 1933 on AREA from all 2 fans${temp_low:, temperature not exceeded threshold|}.
    lib01.Fault 1933 AREA Toggle    ${sshrmod}    trigger=${trigger}    temp_low=${temp_low}
    common.Alter Faulty Objects    fault_id=1933    rmod_type=AREA    fans=1,2    trigger=${trigger}


${trigger:Trigger|Clear} Fault 1934 on AREA from all 2 fans.
    lib01.Fault 1934 AREA Toggle    ${sshrmod}    trigger=${trigger}
    common.Alter Faulty Objects    fault_id=1934    rmod_type=AREA    fans=1,2    trigger=${trigger}


Add fid: ${fid:1932|1933|1934} on fans: [${fans:[0-9,-]+|}] for rmod: ${rmod:AREA} to Faulty Objects.
    [Documentation]  Use as "fans: []" for adding only RMOD objects
    common.Alter Faulty Objects    fault_id=${fid}    rmod_type=${rmod}    fans=${fans}    trigger=Trigger

Remove fid: ${fid:1932|1933|1934} on fans: [${fans:[0-9,-]+|}] for rmod: ${rmod:AREA} from Faulty Objects.
    [Documentation]  Use as "fans: []" for removing only RMOD objects
    common.Alter Faulty Objects    fault_id=${fid}    rmod_type=${rmod}    fans=${fans}    trigger=Clear

