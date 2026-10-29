*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CB012475

Library       taf.selenium.sbts    WITH NAME    selenium_coam
Resource    ../../resources/cbrs_common_keywords.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Library    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/12475_variables.py

*** Variables ***
@{cell_id1}    ${1}
@{cell_id2}    ${2}
${CB012475_conf_path}    ${CURDIR}/conf
${CB012475_A_22_conf}    ${CB012475_conf_path}/CB012475-A_22.conf
${CB012475_B_39_conf}    ${CB012475_conf_path}/CB012475-B_39.conf
${CB012475_B_31_conf}    ${CB012475_conf_path}/CB012475-B_31.conf
${CB012475_B_28_conf}    ${CB012475_conf_path}/CB012475-B_28.conf
${CB012475_B_32_conf}    ${CB012475_conf_path}/CB012475-B_32.conf
${CB012475_B_42_conf}    ${CB012475_conf_path}/CB012475-B_42.conf
${CB012475_B_45_conf}    ${CB012475_conf_path}/CB012475-B_45.conf
${CB012475_B_41_conf}    ${CB012475_conf_path}/CB012475-B_41.conf
${CB012475_json_path}    ${CURDIR}/json
${CB012475_case45}    ${CB012475_json_path}/CB012475_case45.json
${CB012475_case45_maxGrantPwrRed}    ${CB012475_json_path}/CB012475_case45_maxGrantPwrRed.json
${CB012475_case45_desiredPmax}    ${CB012475_json_path}/CB012475_case45_desiredPmax.json


*** Keywords ***
CB012475 check cell always keep degrade
    [Arguments]    ${cellid}=188
    FOR    ${index}    IN RANGE    30
        verify cell status degrade or disable by cellid    cellid=${cellid}
        ...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
        Sleep    5s
    END

Check CB012475-B_41 SAS step by cbsdid
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    [Teardown]    end_to_check

12475_load_scf
    &{fault_4681}     Create Dictionary     faultId=${4681}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4681}
    set test variable  ${ALLOWED_HISTORY_FAULT}
	start SAS server
	FOR    ${TEST_LOOP}    IN RANGE    0    20
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
        Activate feature CBRS By Coam
        Wait until keyword succeeds    6min    30s    verify all cells should be onair
        Sleep    300s
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
        csn.reset_cache
    END


CB012475-B_32_SISO_supercell_setup_with_degradation_1-3_PAL_second_grant_bring_up_more_subcells
    &{fault_4681}     Create Dictionary     faultId=${4681}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4681}
    &{fault_4741}     Create Dictionary     faultId=${4741}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4741}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    config_name=${CB012475_B_41_conf}    path=${sas_3}
    Wait until keyword succeeds    10min    10s    verify cell status not degrade or disable by cellid    cellid=188
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    6min    10s    verify all cells should be onair
    ${nrcell1_subcell1}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${nrcell1_subcell2}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=1
    ${nrcell1_subcell3}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=2
    Should be True    '${nrcell1_subcell1}'=='3550000000_3570000000'
    Should be True    '${nrcell1_subcell2}'=='3550000000_3570000000'
    Should be True    '${nrcell1_subcell3}'=='3550000000_3570000000'
    Wait until keyword succeeds    10min    20s    verify cell status degrade or disable by cellid    cellid=188
	...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
    Wait Until Keyword Succeeds    6min    5s    Check Alarm in Alarm List    type=History    faultId=6825
    ...    stamp_case_start=${stamp_case_start}    Supplementary=Heartbeat Exception with Reason: 501. ResponseMessage: The grant is suspended.
    ...    expect=${True}
    Wait until keyword succeeds    10min    10s    verify cell status not degrade or disable by cellid    cellid=188
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    6min    10s    verify all cells should be onair
    ${nrcell1_subcell1}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${nrcell1_subcell2}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=1
    ${nrcell1_subcell3}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=2
    Should be True    '${nrcell1_subcell1}'=='3570000000_3590000000'
    Should be True    '${nrcell1_subcell2}'=='3570000000_3590000000'
    Should be True    '${nrcell1_subcell3}'=='3570000000_3590000000'
    Check CB012475-B_41 SAS step by cbsdid    cbsdid=1125_Nokia_EB2331R0726.NR
    Check CB012475-B_41 SAS step by cbsdid    cbsdid=1125_Nokia_EB2331R0728.NR
    Check CB012475-B_41 SAS step by cbsdid    cbsdid=1125_Nokia_EB2331R0730.NR

CB012475-B_45_Supercell_Online_Change_Parameters_desiredPmax_maxGrantPwrRed
    &{fault_4681}     Create Dictionary     faultId=${4681}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4681}
    &{fault_4741}     Create Dictionary     faultId=${4741}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4741}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    coam.perform_delta_recommissioning    delta_file=${CB012475_case45}    connection=GNB_OAM
    sleep    30s
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    config_name=${CB012475_B_45_conf}    path=${sas_3}
    Wait until keyword succeeds    8min    20s    verify cell status degrade or disable by cellid    cellid=188
	...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
    ${nrcell1_subcell1}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Should be True    '${nrcell1_subcell1}'=='3550000000_3570000000'
    ${grantmaxeirp}    Get NRCBSDCELL_R value via COAM    pattern=grantMaxEirp
    Should be True    '${grantmaxeirp}'=='32'
    ${current_Pmax}    Get pMax By Coam
    Should be True    '${current_Pmax}'=='33'
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    coam.perform_delta_recommissioning    delta_file=${CB012475_case45_maxGrantPwrRed}    connection=GNB_OAM
    sleep    180s
    ${stamp_case_start}    Get Timestamp For Current Time
    ${nrcell1_subcell1}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${nrcell1_subcell2}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=1
    Should be True    '${nrcell1_subcell1}'=='3550000000_3570000000'
    Should be True    '${nrcell1_subcell2}'=='3550000000_3570000000'
    ${grantmaxeirp}    Get NRCBSDCELL_R value via COAM    pattern=grantMaxEirp
    Should be True    '${grantmaxeirp}'=='32'
    ${current_Pmax}    Get pMax By Coam
    Should be True    '${current_Pmax}'=='31.9'
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    coam.perform_delta_recommissioning    delta_file=${CB012475_case45_desiredPmax}    connection=GNB_OAM
    Wait until keyword succeeds    10min    30s    verify cell status not degrade or disable by cellid    cellid=188
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    6min    30s    verify all cells should be onair
    sleep    180s
    ${nrcell1_subcell1}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${nrcell1_subcell2}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=1
    ${nrcell1_subcell3}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=2
    Should be True    '${nrcell1_subcell1}'=='3570000000_3590000000'
    Should be True    '${nrcell1_subcell2}'=='3570000000_3590000000'
    Should be True    '${nrcell1_subcell3}'=='3570000000_3590000000'
    ${grantmaxeirp}    Get NRCBSDCELL_R value via COAM    pattern=grantMaxEirp
    Should be True    '${grantmaxeirp}'=='28'
    ${current_Pmax}    Get pMax By Coam
    Should be True    '${current_Pmax}'=='27.9'
    Check CB012475-B_45 step subcell1    cbsdid=1125_Nokia_EB2331R0726.NR
    Check CB012475-B_45 step subcell2    cbsdid2=1125_Nokia_EB2331R0728.NR
    Check CB012475-B_45 step subcell3    cbsdid2=1125_Nokia_EB2331R0726.NR     cbsdid3=1125_Nokia_EB2331R0730.NR
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell0}    value=${29}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell1}    value=${120}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell2}    value=${120}
    data_transfer_common    tput_self_define=${tput_define_9}    cell_id=${cell_id1}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.5    min_percent=0.2
    Sleep    30s
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell0}    value=${120}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell1}    value=${29}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell2}    value=${120}
    data_transfer_common    tput_self_define=${tput_define_9}    cell_id=${cell_id1}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.5   min_percent=0.2
    Sleep    30s
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell0}    value=${120}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell1}    value=${120}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell2}    value=${29}
    data_transfer_common    tput_self_define=${tput_define_9}    cell_id=${cell_id1}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.5    min_percent=0.2

Check CB012475-B_45 step subcell1
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check CB012475-B_45 step subcell2
    [Arguments]    ${cbsdid2}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid2}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid2}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid2}\".*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*"cbsdId": "${cbsdid2}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid2}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid2}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check CB012475-B_45 step subcell3
    [Arguments]    ${cbsdid2}    ${cbsdid3}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid2}\".*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*"cbsdId": "${cbsdid2}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid3}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid3}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

CB012475-B_42_Supercell becomes degraded in runtime_grant_terminated_second_grant_not_used
    &{fault_4681}     Create Dictionary     faultId=${4681}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4681}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    ${SCF_12475}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_12475_
    Commissioning SCF And Check RU On Air    scf_file_path=${SCF_12475}
    start SAS server    config_name=${CB012475_B_42_conf}    path=${sas_3}
    Wait until keyword succeeds    10min    30s    verify cell status not degrade or disable by cellid    cellid=188
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    6min    30s    verify all cells should be onair
    ${nrcell1_subcell1}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${nrcell1_subcell2}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=1
    ${nrcell1_subcell3}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=2
    Should be True    '${nrcell1_subcell1}'=='3550000000_3570000000'
    Should be True    '${nrcell1_subcell2}'=='3550000000_3570000000'
    Should be True    '${nrcell1_subcell3}'=='3550000000_3570000000'
    Wait until keyword succeeds    10min    20s    verify cell status degrade or disable by cellid    cellid=188
	...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
    ${nrcell1_subcell1}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${nrcell1_subcell2}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=1
    ${nrcell1_subcell3}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=2
    Should be True    '${nrcell1_subcell1}'=='3550000000_3570000000'
    Should be True    '${nrcell1_subcell2}'=='3550000000_3570000000'
    Should be True    '${nrcell1_subcell3}'=='None'
    Sleep    180s
    Check CB012475-B_42 no grant request after subcell3 500 by cbsdid    cbsdid=1125_Nokia_EB2331R0748.NR
    ...    cbsdid_500=1125_Nokia_EB2331R0748.NR
    Check CB012475-B_42 no relinquishment Request after subcell3 500 by cbsdid    cbsdid=1125_Nokia_EB2331R0748.NR
    ...    cbsdid_500=1125_Nokia_EB2331R0748.NR
    Deactivate feature CBRS By Coam
    Sleep    30s
    Connect to gnb coam via ssl
    Supercell Online delete channel
    Sleep    300s
    Activate feature CBRS By Coam
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    10s    verify cell status not degrade or disable by cellid    cellid=188
    ...    administrative=Unlocked    operationalState=enabled
    Commissioning SCF And Check RU On Air    scf_file_path=${SCF_12475}

Supercell Online delete channel
    [Documentation]
    [Arguments]    ${lcellnr}=1    ${index}=3
    selenium login and disable screen lock
    log to console  delete object
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcellnr}/CHANNELGROUP-${index}    timeout=15
    selenium_coam.validate_plan
    selenium_coam.activate_plan		activate_plan_despite_errors=${True}    timeout=180
	[Teardown]    Selenium Logout And Close Browser




Check CB012475-B_42 no relinquishment Request after subcell3 500 by cbsdid
    [Arguments]    ${cbsdid}    ${cbsdid_500}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid_500}".*\"responseCode\": 500.*
    Check if message is not found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    [Teardown]    end_to_check

Check CB012475-B_42 no grant request after subcell3 500 by cbsdid
    [Arguments]    ${cbsdid}    ${cbsdid_500}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid_500}".*\"responseCode\": 500.*
    Check if message is not found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    [Teardown]    end_to_check

CB012475-B_41_Supercell becomes degraded in runtime_grant_suspend_second_grant_used
    AlarmWatchdog.add_allow_alarms    fault_id=4741
    &{fault_4681}     Create Dictionary     faultId=${4681}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4681}
    &{fault_4741}     Create Dictionary     faultId=${4741}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4741}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    ${stamp_case_start}    Get Timestamp For Current Time
    ${SCF_12475}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_12475_
    Commissioning SCF And Check RU On Air    scf_file_path=${SCF_12475}
    start SAS server    config_name=${CB012475_B_32_conf}    path=${sas_3}
    Wait until keyword succeeds    8min    20s    verify cell status degrade or disable by cellid    cellid=188
	...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
    Sleep    180s
    ${nrcell1_subcell1}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${nrcell1_subcell2}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=1
    Should be True    '${nrcell1_subcell1}'=='3570000000_3590000000'
    Should be True    '${nrcell1_subcell2}'=='3570000000_3590000000'
    Wait Until Keyword Succeeds    2min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    Wait until keyword succeeds    10min    30s    verify cell status not degrade or disable by cellid    cellid=188
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    6min    30s    verify all cells should be onair
    ${nrcell1_subcell1}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${nrcell1_subcell2}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=1
    ${nrcell1_subcell3}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=2
    Should be True    '${nrcell1_subcell1}'=='3550000000_3570000000'
    Should be True    '${nrcell1_subcell2}'=='3550000000_3570000000'
    Should be True    '${nrcell1_subcell3}'=='3550000000_3570000000'
    FOR    ${TEST_LOOP}    IN RANGE    0    2
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Connect to gnb coam via ssl
        Selenium Logout And Close Browser
        selenium login and disable screen lock
        selenium_coam.reset_nr
        Sleep    120s
        Wait until keyword succeeds    10min    30s    Check all cells info should be onair
        csn.reset_cache
    END
    FOR    ${index}    IN RANGE    1
        Sleep     60s
        coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-2    force_radio_reset=${True}
        ...    timeout=${600}    connection=GNB_OAM
		Wait until keyword succeeds    8min    20s    verify cell status degrade or disable by cellid    cellid=188
		...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
		Sleep    180s
		Wait until keyword succeeds    10min    30s    verify cell status not degrade or disable by cellid    cellid=188
		...    administrative=Unlocked    operationalState=enabled
    csn.reset_cache
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]    Selenium Logout And Close Browser

Check CB012475-B_28 SAS step temp by cbsdid
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 103.*
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

CB012475-B_28_supercell_degraded startup_one_CBSD_HB_failure
    &{fault_4681}     Create Dictionary     faultId=${4681}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4681}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    start SAS server    config_name=${CB012475_B_28_conf}    path=${sas_3}
#    Wait until keyword succeeds    8min    20s    verify cell status degrade or disable by cellid    cellid=188
#	...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
    Wait until keyword succeeds    10min    30s    verify cell status not degrade or disable by cellid    cellid=188
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    6min    30s    verify all cells should be onair
    Sleep    60s
    ${nrcell1_subcell1}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${nrcell1_subcell2}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=1
    Should be True    '${nrcell1_subcell1}'=='${nrcell1_subcell2}'
    ${nrcell1_subcell3}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=2
    Should be True    '${nrcell1_subcell2}'=='${nrcell1_subcell3}'
    Check CB012475-B_28 SAS step temp by cbsdid    cbsdid=1125_Nokia_EB2331R0730.NR

CB012475-B_31_SISO_supercell_setup_with_degradation_two_subcells_not get_grant_1-3
    &{fault_4681}     Create Dictionary     faultId=${4681}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4681}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    ${SCF_12475}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_12475_
    Commissioning SCF And Check RU On Air    scf_file_path=${SCF_12475}
    start SAS server    config_name=${CB012475_B_31_conf}    path=${sas_3}
    Wait until keyword succeeds    8min    20s    verify cell status degrade or disable by cellid    cellid=188
	...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
    Sleep    60s
#    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell0}    value=${29}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell1}    value=${120}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell2}    value=${120}
#    data_transfer_common    tput_self_define=${tput_define_9}    cell_id=${cell_id1}   loop_times=${1}    duration=${300}
#    ...    target_avg_percent=0.5    min_percent=0.2

CB012475-B_39_SISO_supercell_setup_with_degradation_RU_reset_2-3
    &{fault_4681}     Create Dictionary     faultId=${4681}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4681}
    &{fault_6828}     Create Dictionary     faultId=${6828}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_6828}
    &{fault_4741}     Create Dictionary     faultId=${4741}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4741}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    ${SCF_12475}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_12475_
    Commissioning SCF And Check RU On Air    scf_file_path=${SCF_12475}
    start SAS server    config_name=${CB012475_B_39_conf}    path=${sas_3}
    Wait until keyword succeeds    8min    20s    verify cell status degrade or disable by cellid    cellid=188
	...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
    FOR    ${loop}    IN RANGE    1    3
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
        Perform all RU reset
        verify cell status degrade or disable by cellid    cellid=188    administrative=Unlocked    operationalState=enabled
	    ...    availabilityStatus=degraded
    END


Perform all RU reset
    FOR    ${index}    IN RANGE    1    3
        coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${index}    force_radio_reset=${True}
        ...    timeout=${600}    connection=GNB_OAM
        CB012475 check cell always keep degrade
        Check RU Onair
        Wait Until Keyword Succeeds    2min    20s    check RU Availability    rmod_index=${index}
    END

10564_RU_reset
    &{fault_4741}     Create Dictionary     faultId=${4741}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4741}
    ${SCF_10564}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_10564_
    start SAS server
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_10564}
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    FOR    ${index}    IN RANGE    5
        Sleep     60s
        coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-2    force_radio_reset=${True}
        ...    timeout=${600}    connection=GNB_OAM
        Wait until keyword succeeds    2min    5s    CB0010564 verify cell status degrade or disable by cellid    cellid=643
        ...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
        Wait until keyword succeeds    2min    5s    CB0010564 verify cell status degrade or disable by cellid    cellid=645
        ...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
        Wait until keyword succeeds    2min    5s    CB0010564 verify cell status not degrade or disable by cellid    cellid=644
        ...    administrative=Unlocked    operationalState=enabled
        Wait until keyword succeeds    10min    10s    CB0010564 verify cell status not degrade or disable by cellid    cellid=643
        ...    administrative=Unlocked    operationalState=enabled
        Wait until keyword succeeds    10min    10s    CB0010564 verify cell status not degrade or disable by cellid    cellid=645
        ...    administrative=Unlocked    operationalState=enabled
    END


CB0010564 verify cell status degrade or disable by cellid
    [Arguments]    ${cellid}    ${administrative}    ${operationalState}    ${availabilityStatus}    ${cell_type}=nr    ${connection}=GNB_OAM
    Log to console    CB0010564 verify cell status degrade or disable by cellid
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run Keyword If     ${cell["physicalCellId"]} == ${cellid}
        ...    Run keywords    Should Be Equal As Strings    ${cell["status"]["administrativeState"]}    ${administrative}    AND
        ...    Should Be Equal As Strings    ${cell["status"]["operationalState"]}    ${operationalState}    AND
        ...    Should Be Equal As Strings    ${cell["status"]["availabilityStatus"]}    ${availabilityStatus}
        exit for loop if   ${cell["physicalCellId"]} == ${cellid}
    END

CB0010564 verify cell status not degrade or disable by cellid
    [Arguments]    ${cellid}    ${administrative}    ${operationalState}    ${cell_type}=nr    ${connection}=GNB_OAM
    Log to console    CB0010564 verify cell status not degrade or disable by cellid
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run Keyword If     ${cell['physicalCellId']} == ${cellid}
        ...    Run keywords    Should Be Equal As Strings    ${cell['status']['administrativeState']}    ${administrative}    AND
        ...    Should Be Equal As Strings    ${cell['status']['operationalState']}    ${operationalState}    AND
        ...    Dictionary Should Not Contain Key    ${cell['status']}     availabilityStatus    msg=cell is disable or degraded, please check.
        exit for loop if   ${cell['physicalCellId']} == ${cellid}
    END


10564_BB_reset
    ${SCF_10564}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_10564_
    start SAS server
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_10564}
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    FOR    ${TEST_LOOP}    IN RANGE    0    20
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Connect to gnb coam via ssl
        coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1    reset_type=Warm    force_radio_reset=${True}
        ...    timeout=300s    connection=GNB_OAM
        Wait until keyword succeeds    10min    30s    Check all cells info should be onair
        Sleep    60s
        csn.reset_cache
    END
    selenium login and disable screen lock


Check CB012475-B_40 SAS step temp by cbsdid
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is not found in saslog    tag={\"relinquishmentRequest\":.*
    [Teardown]    end_to_check

Check CB012475-B_40 SAS step by cbsdid
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*\"cbsdId\": \"${cbsdid}\".*
    [Teardown]    end_to_check

CB012475-B case 40 recovery ENV
    run keyword and ignore error    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1    connection=GNB_OAM    timeout=300
    run keyword and ignore error    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2    connection=GNB_OAM    timeout=300
    sleep    30

CB012475-B_40_SISO_supercell_setup_with_degradation_supercell_block_unblock_mix_normal_CBRS_cell
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=4741
    &{fault_4681}     Create Dictionary     faultId=${4681}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4681}
    &{fault_4741}     Create Dictionary     faultId=${4741}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4741}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    ${CB012475_B_2cc}    Replace String    ${Golden_SCF_Path}    SCF_    CB012475_B_2cc_
    Commissioning SCF And Check RU On Air   scf_file_path=${CB012475_B_2cc}
    Activate feature CBRS By Coam
    start SAS server    config_name=${CB012475_B_39_conf}    path=${sas_3}
    Wait until keyword succeeds    8min    20s    verify cell status degrade or disable by cellid    cellid=188
	...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
    Wait until keyword succeeds    5min    20s    verify cell status not degrade or disable by cellid    cellid=189
    ...    administrative=Unlocked    operationalState=enabled
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Set Test Variable    ${cell_list_nr}
    FOR    ${cell_index}    IN    @{cell_list_nr}
        coam.block_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=GNB_OAM
        ...    timeout=300
        sleep    5
    END
    Sleep    60s
    Check CB012475-B_40 SAS step temp by cbsdid    cbsdid=1125_Nokia_EB2331R0728.NR
    Check CB012475-B_40 SAS step temp by cbsdid    cbsdid=1125_Nokia_EB2331R0730.NR
    FOR    ${cell_index}    IN    @{cell_list_nr}
        coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=GNB_OAM
        ...    timeout=300
        sleep    5
    END
    Wait until keyword succeeds    8min    20s    verify cell status degrade or disable by cellid    cellid=188
	...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
    Wait until keyword succeeds    5min    20s    verify cell status not degrade or disable by cellid    cellid=189
    ...    administrative=Unlocked    operationalState=enabled
    FOR    ${cell_index}    IN    @{cell_list_nr}
        coam.block_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=GNB_OAM
        ...    timeout=300
        sleep    5
    END
    Sleep    300s
    Check CB012475-B_40 SAS step by cbsdid    cbsdid=1125_Nokia_EB2331R0728.NR
    Check CB012475-B_40 SAS step by cbsdid    cbsdid=1125_Nokia_EB2331R0730.NR
    FOR    ${cell_index}    IN    @{cell_list_nr}
        coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=GNB_OAM
        ...    timeout=300
        sleep    5
    END
    Wait until keyword succeeds    8min    20s    verify cell status degrade or disable by cellid    cellid=188
	...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
    Wait until keyword succeeds    5min    20s    verify cell status not degrade or disable by cellid    cellid=189
    ...    administrative=Unlocked    operationalState=enabled
    [Teardown]    CB012475-B case 40 recovery ENV
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    AlarmWatchdog.remove_allow_alarms    fault_id=4741

CB012475-A_9_General_SiSo_E2E_system_setup_with_data_transfer_conducted_2-3_2CC
    &{fault_4681}     Create Dictionary     faultId=${4681}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4681}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    start SAS server    path=${sas_3}
    Wait until keyword succeeds    6min    30s    verify all cells should be onair
    Sleep    60s
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell0}    value=${29}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell1}    value=${120}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell2}    value=${120}
    Sleep    60s
    data_transfer_common    tput_self_define=${tput_define_9}    cell_id=${cell_id1}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.9    min_percent=0.85
    Sleep    60s
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell0}    value=${120}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell1}    value=${29}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell2}    value=${120}
    Sleep    60s
    data_transfer_common    tput_self_define=${tput_define_9}    cell_id=${cell_id1}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.9    min_percent=0.85
    Sleep    30s
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell0}    value=${120}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell1}    value=${120}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_subcell2}    value=${29}
    Sleep    60s
    data_transfer_common    tput_self_define=${tput_define_9}    cell_id=${cell_id1}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.9    min_percent=0.85

Check CB012475-A_22 SAS step by cbsdid
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is not found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    [Teardown]    end_to_check

CB012475-A_22_Supercell_CBRS_disable_enable_TS2.0
    &{fault_4681}     Create Dictionary     faultId=${4681}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4681}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    start SAS server    config_name=${CB012475_A_22_conf}    path=${sas_3}
    Wait until keyword succeeds    6min    30s    verify all cells should be onair
    Sleep    30s
    ${nrcell1_subcell1}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${nrcell1_subcell2}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=1
    Should be True    '${nrcell1_subcell1}'=='${nrcell1_subcell2}'
    ${nrcell1_subcell3}    Get subGrantInfo Item by Coam    pattern=grantIdSub    index=2
    Should be True    '${nrcell1_subcell2}'=='${nrcell1_subcell3}'
    Should be True    '${nrcell1_subcell2}'!='3590000000_3610000000'
    ${grantmaxeirp}    Get NRCBSDCELL_R value via COAM    pattern=grantMaxEirp
    Should be True    '${grantmaxeirp}'=='32'
    Sleep    30s
    Check CB012475-A_22 SAS step by cbsdid    cbsdid=1125_Nokia_EB2331R0726.NR
    Check CB012475-A_22 SAS step by cbsdid    cbsdid=1125_Nokia_EB2331R0728.NR
    Check CB012475-A_22 SAS step by cbsdid    cbsdid=1125_Nokia_EB2331R0730.NR

12475_RAT_reset
    ${CB012475_B_2cc}    Replace String    ${Golden_SCF_Path}    SCF_    CB012475_B_2cc_
    Commissioning SCF And Check RU On Air   scf_file_path=${CB012475_B_2cc}
    Activate feature CBRS By Coam
    start SAS server
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
	FOR    ${TEST_LOOP}    IN RANGE    0    10
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Connect to gnb coam via ssl
        coam.rat_reset       rat_type=NR     timeout=300    connection=GNB_OAM
        Sleep    180s
		Wait until keyword succeeds    8min    30s    verify all cells should be onair
		Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        Sleep    60s
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
        csn.reset_cache
    END
    selenium login and disable screen lock
