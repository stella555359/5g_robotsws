*** Settings ***
Documentation
...   Keywords file for CB012097
...   author:
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)

Library      common.py
Library      Fault_verifier.py
Library      on_air_tl_preparation.testline_preparation_resources
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/gnb.robot

*** Variables ***

${CUSTOM_ADDITIONAL_ALARMS_DURING_PREP}=    ${None}     # provide single alarm or comma separated list of alarms enclosed with ""

*** Keywords ***
Set RMOD Variables for Test Case
    [Documentation]
    ...    KW sets variables necessary to detemine which RMOD to test,
    ...    i.e. rmod_sn as APHG_sn for APHG , RMOD_RUNTIME, FAN_RUNTIME
    ...    rmod_type: radio_type from __init__ in tl.gnbs[0].dus[0].airscale.core_units[0].rus object, eg. APHG
    ...    rmod_id: entry of same rmod_type from __init__, 0..n-1 or 'random',
    ...    0 is first rmod in rmod list tl.gnbs[0].dus[0].airscale.core_units[0].rus
    ...    rmod_list: tl.gnbs[0].dus[0].airscale.core_units[0].rus object from __init__.py

    [Arguments]
    ...    ${rmod_type}
    ...    ${rmod_id}=0
    ...    ${rmod_list}=${RMOD_LIST}

    IF    '${${rmod_type}_sn}' == '${None}'
        ${rmod_sn}=    common.get_rmod_sn_from_rmod_list    ${rmod_type}    ${rmod_id}    ${rmod_list}
    ELSE
        ${rmod_sn}    Set Variable    ${${rmod_type}_sn}
    END
    Set Test Variable    ${${rmod_type}_sn}    ${rmod_sn}
    @{RMOD_FAN_RUNTIME}=    common.get_rmod_and_fan_dist_names    ${rmod_type}    ${rmod_sn}    id_type=runtime
    Set To Dictionary    ${RMOD_RUNTIME}     ${rmod_type}    ${RMOD_FAN_RUNTIME}[0]
    Set To Dictionary    ${FAN_RUNTIME}     ${rmod_type}    ${RMOD_FAN_RUNTIME}[1]
    Log    ${rmod_type} SN: ${${rmod_type}_sn}    console=True

Change FAF actRadioFanFailureEarlyNotif to ${value:false|true}
    Log To Console    Changing FAF actRadioFanFailureEarlyNotif to ${value}...    no_newline=True
    gnb_scf.Perform Configuration Parameter Recommissioning On gNB
        ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
        ...    param_name=actRadioFanFailureEarlyNotif
        ...    operation=update
        ...    param_value=${value}
    Log To Console    ${SPACE}Done!

Get Diagnostic Check
    Log To Console    Running Diagnostic Check...
    ${report}=    common.run_diagnostic_check
    [Return]    ${report}

Get Diagnostic Check and Wait for Alarm Deactivation
    [Arguments]    ${awaiting_time}=30
    ${report}=    Get Diagnostic Check
    Fault_verifier.wait_for_alarm_deactivation    4681    awaiting_time=${awaiting_time}
    RETURN    ${report}

Verify Diagnostic Check
    [Arguments]    ${report}    ${checkpoint}    ${status}    ${rmod}    ${negative_check}=${False}
    Log To Console    Verifying Diagnostic Check Report...
    common.verify_diagnostic_check    ${report}    ${checkpoint}    ${status}    ${rmod}    negative_check=${negative_check}


Allow Alarms
    [Arguments]    @{Alarms}
    FOR    ${alarm}    IN    @{Alarms}
        gnb_alarm.Allow Alarm    ${alarm}
    END

Disallow Alarms
    [Arguments]    @{Alarms}
    FOR    ${alarm}    IN    @{Alarms}
        gnb_alarm.Disallow Alarm    ${alarm}
    END

Verify All Fan Related ${obj:FAN|RMOD} Faults are Triggered as Expected
    Fault_verifier.verify_fault_present_for_exact_objects    fault_id=1932    objects=${FAULTY_1932_${obj}S}
    Fault_verifier.verify_fault_present_for_exact_objects    fault_id=1933    objects=${FAULTY_1933_${obj}S}
    Fault_verifier.verify_fault_present_for_exact_objects    fault_id=1934    objects=${FAULTY_1934_${obj}S}

Remove fid: ${fid:1932|1933|1934} on all fans for rmod: ${rmod} from Faulty Objects due to PR 05184468.
    # In PR 05184468 all FAN faults has been moved from Minor to Warnings
    common.remove_all_fan_objects_from_faulty_objects    fault_id=${fid}    rmod_type=${rmod}

Toggle OFF and ON FAF actRadioFanFailureEarlyNotif to refresh FAN alarms due to PR 05184468
    Change FAF actRadioFanFailureEarlyNotif to false
    Change FAF actRadioFanFailureEarlyNotif to true

Custom Suite Setup
    IF    $CUSTOM_ADDITIONAL_ALARMS_DURING_PREP
        @{list_argument}=    Evaluate    [el.strip() for el in $CUSTOM_ADDITIONAL_ALARMS_DURING_PREP.split(',')]
        Log    list_argument=${list_argument}  console=True
        @{ADDITIONAL_ALARMS_DURING_PREP}=    Create List    @{ADDITIONAL_ALARMS_DURING_PREP}    @{list_argument}
        Log    ADDITIONAL_ALARMS_DURING_PREP=${ADDITIONAL_ALARMS_DURING_PREP}  console=True
    END
    ${SCF_PATH} =    Get Variable Value    $SCF_PATH    ${False}
    &{TL_SUBDIR_SCF_MAPPING} =    Get Variable Value    $TL_SUBDIR_SCF_MAPPING    &{Empty}
    IF    not $SCF_PATH
        ${SCF_TEMP}     get_scf_path    ${ENB_BUILD}
        FOR    ${TL}    ${SUBDIR}    IN    &{TL_SUBDIR_SCF_MAPPING}
            IF    $TL in $SCF_TEMP
                Set Suite Variable    ${SCF_PATH}     ${SCF_TEMP}/${SUBDIR}
                Log     Setting scf path to: ${SCF_PATH}     console=True
            END
        END
    END
    Log     ${SCF_PATH}
    Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
    ...                                                  should_5G_neighbour_be_changed=${False}
    ...                                                  increase_time_for_checking_bbmod=600
    ...                                                  increase_timeout_for_update_sw=1800
    ...                                                  increase_time_for_checking_radios=2100
    ...                                                  increase_time_for_checking_cells=700
    ...                                                  swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...                                                  scfs_path=${SCF_PATH}
    ...                                                  list_of_additional_allowed_alarms=${ADDITIONAL_ALARMS_DURING_PREP}


Test Teardown
    Log To Console    Test Teardown...
    Wait For Site To Be Onair  timeout=300
    gnbcell.Wait For All Cells To Be OnAir    timeout=300


Test Teardown with Watching Alarms
    common_setups_and_teardowns.Common Postconditions With Watching Alarms    collect_syslog=${False}  collect_snapshot_from_ru=${False}
