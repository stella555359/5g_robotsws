*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CB010564

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../resources/cbrs_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/CB010564_variables.py

*** Variables ***
${CB0010564_json_path}    ${CURDIR}/json
${CB0010564_case19_v2}    ${CB0010564_json_path}/CB0010564_case19_v2.json
${CB0010564_case17_v2_cell2}    ${CB0010564_json_path}/CB0010564_case17_v2_cell2.json
${CB0010564_v2_all}    ${CB0010564_json_path}/CB0010564_v2_all.json
${CB0010564_case14_v2}    ${CB0010564_json_path}/CB0010564_case14_v2.json
${disable_actcbrs_actnrcbrs}    ${CB0010564_json_path}/disable_actcbrs_actnrcbrs.json
${enable_actcbrs_actnrcbrs}    ${CB0010564_json_path}/enable_actcbrs_actnrcbrs.json
${disable_actcbrs_actnrcbrs_12}    ${CB0010564_json_path}/disable_actcbrs_actnrcbrs_12.json
${CB0010564_conf_path}    ${CURDIR}/conf
${CB0010564_E_19}    ${CB0010564_conf_path}/CB0010564_E_19.conf
${CB0010564_E_17}    ${CB0010564_conf_path}/CB0010564_E_17.conf
${CB0010564_E_14}    ${CB0010564_conf_path}/CB0010564_E_14.conf
@{cell_id1}    ${1}
@{cell_id3}    ${3}

*** Keywords ***
CB010564-E_20_General_SiSo_E2E_system_setup_with_data_transfer_conducted_1CC_20MHz_when_one_RU_down
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=1815
    AlarmWatchdog.add_allow_alarms    fault_id=4003
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    ${SCF_Peak_SBTS00}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_Peak_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_Peak_SBTS00}
    Activate feature CBRS By Coam
    start SAS server
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Perform RU Power Off    ru_index=${1}
    Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${1}
    Sleep    120s
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
     Wait until keyword succeeds    5min    30s    check cell status by cellid    cellid=998    status=enabled    cell_type=nr
    Wait until keyword succeeds    5min    30s    check cell status by cellid    cellid=999    status=enabled    cell_type=nr
    Wait until keyword succeeds    5min    30s    check cell status by cellid    cellid=1000    status=enabled    cell_type=nr
    Wait until keyword succeeds    5min    30s    check cell availability status by cellid    cellid=998    status=degraded    cell_type=nr
    Wait until keyword succeeds    5min    30s    check cell availability status by cellid    cellid=999    status=degraded    cell_type=nr
    Sleep    60s
	data_transfer_common    tput_self_define=${tput_define_20M}    tput_from=self_define    cell_id=${cell_id1}   loop_times=${1}    duration=${120}
    ...    target_avg_percent=0.5    min_percent=0.2
    Sleep    60s
    CB010564 Power on RU
    [Teardown]    run keyword and ignore error    CB010564 Power on RU
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=1815
    AlarmWatchdog.remove_allow_alarms    fault_id=4003
    AlarmWatchdog.remove_allow_alarms    fault_id=4589

CB010564 Power on RU
    [Arguments]    ${ru_index}=1
    Perform RU Power On    ru_index=${ru_index}
    Sleep    120s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair

CB010564-E_16_General_SiSo_E2E_system_setup_with_data_transfer_conducted_(max_MCS_L3_call)_1CC_20MHz
    ${SCF_Peak_SBTS00}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_Peak_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_Peak_SBTS00}
    Activate feature CBRS By Coam
    start SAS server
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    data_transfer_common    tput_self_define=${tput_define_20M}    cell_id=${cell_id1}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.98    min_percent=0.85

Check HB 501 in SAS log
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 501.*
    [Teardown]    end_to_check

CB0010564 Check No relinquishmentRequest
    prepare_to_check_message_from_start
    Check if message is not found in saslog    tag={\"relinquishmentRequest\":.*
    [Teardown]    end_to_check

CB010564-E_14_Verify_cell_will_not_get_second_grant_when_one_RU_down_and_heartbeat_with_Grant_Suspended
    AlarmWatchdog.add_allow_alarms    fault_id=1815
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4003
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=1972
    coam.perform_delta_recommissioning    delta_file=${CB0010564_case14_v2}    connection=GNB_OAM
    start SAS server    config_name=${CB0010564_E_14}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Sleep    120s
    ${grant_info_cell1}    Get Grant Parameters By Coam
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
    ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3
    Should be True    '${grant_info_cell1}[grantId]'=='3550000000_3570000000'
    Should be True    '${grant_info_cell2}[grantId]'!='None'
    Should be True    '${grant_info_cell3}[grantId]'!='None'
    Perform RU Power Off    ru_index=${3}
    Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${3}
    Sleep    480s
    Check HB 501 in SAS log
    CB0010564 Check No relinquishmentRequest
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    ${grant_info_cell3_new}    Get Grant Parameters By Coam    cellID=3
    Should be True    '${grant_info_cell1}[grantId]'=='${grant_info_cell1_new}[grantId]'
    Should be True    '${grant_info_cell2}[grantId]'=='${grant_info_cell2_new}[grantId]'
    Should be True    '${grant_info_cell3}[grantId]'=='${grant_info_cell3_new}[grantId]'
    Wait until keyword succeeds    5min    30s    check cell status by cellid    cellid=998    status=enabled    cell_type=nr
    Wait until keyword succeeds    5min    30s    check cell status by cellid    cellid=999    status=enabled    cell_type=nr
    Wait until keyword succeeds    5min    30s    check cell status by cellid    cellid=1000    status=enabled    cell_type=nr
    Wait until keyword succeeds    5min    30s    check cell availability status by cellid    cellid=998    status=degraded    cell_type=nr
    Wait until keyword succeeds    5min    30s    check cell availability status by cellid    cellid=1000    status=degraded    cell_type=nr
    Perform RU Power On    ru_index=${3}
    Sleep    480s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    [Teardown]    run keyword and ignore error    Perform RU Power On    ru_index=${3}
    AlarmWatchdog.remove_allow_alarms    fault_id=1815
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4003
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    AlarmWatchdog.remove_allow_alarms    fault_id=1972

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

case 12 recovery ENV
    run keyword and ignore error    coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-3    timeout=${300}    connection=GNB_OAM
    Sleep    120s
    run keyword and ignore error    Perform RU Power On    ru_index=${1}
    Sleep    30s
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    verify all cells should be onair    cell_type=lte    connection=GNB_OAM
    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs_actnrcbrs_12}    connection=GNB_OAM
    Sleep    30s

CB010564-E_12_Recommission_from_M_type_to_Ne_type
    AlarmWatchdog.add_allow_alarms    fault_id=1815
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4003
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=1972
    ${SCF_12_M_type}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_12_M_type_
    ${SCF_Concurrent}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_Concurrent_
    start SAS server
    FOR    ${TEST_LOOP}    IN RANGE    0    1
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Commissioning SCF And Check RU On Air   scf_file_path=${SCF_12_M_type}
        Activate feature CBRS By Coam
        Wait until keyword succeeds    10min    30s    verify all cells should be onair
        Commissioning SCF And Check RU On Air   scf_file_path=${SCF_Concurrent}
        coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs}    connection=GNB_OAM
        Wait until keyword succeeds    8min    30s    verify all cells should be onair
        Wait until keyword succeeds    5min    30s    verify all cells should be onair    cell_type=lte    connection=GNB_OAM
        Sleep    120s
        Perform RU Power Off    ru_index=${1}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${1}
        Sleep    120s
        CB0010564 verify cell status not degrade or disable by cellid    cellid=667    administrative=Unlocked          operationalState=enabled
        CB0010564 verify cell status not degrade or disable by cellid    cellid=14    administrative=unlocked    operationalState=enabled
        ...    cell_type=lte
        CB0010564 verify cell status degrade or disable by cellid    cellid=666    administrative=Unlocked    operationalState=enabled
        ...    availabilityStatus=degraded
        CB0010564 verify cell status degrade or disable by cellid    cellid=668    administrative=Unlocked    operationalState=enabled
        ...    availabilityStatus=degraded
        CB0010564 verify cell status degrade or disable by cellid   cellid=13    administrative=unlocked    operationalState=enabled
        ...    availabilityStatus=degraded    cell_type=lte
        CB0010564 verify cell status degrade or disable by cellid   cellid=15    administrative=unlocked    operationalState=enabled
        ...    availabilityStatus=degraded    cell_type=lte
        Perform RU Power On    ru_index=${1}
        Sleep    480s
        Wait until keyword succeeds    8min    30s    verify all cells should be onair
        Wait until keyword succeeds    5min    30s    verify all cells should be onair    cell_type=lte    connection=GNB_OAM
    END
    FOR    ${index}    IN RANGE    1
        Sleep     60s
        coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-2    force_radio_reset=${True}
        ...    timeout=${600}    connection=GNB_OAM
        Wait until keyword succeeds    2min    5s    CB0010564 verify cell status degrade or disable by cellid    cellid=666
        ...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
        Wait until keyword succeeds    2min    5s    CB0010564 verify cell status degrade or disable by cellid    cellid=667
        ...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
        Wait until keyword succeeds    2min    5s    CB0010564 verify cell status degrade or disable by cellid   cellid=13
        ...    administrative=unlocked    operationalState=enabled    availabilityStatus=degraded    cell_type=lte
        Wait until keyword succeeds    2min    5s    CB0010564 verify cell status degrade or disable by cellid   cellid=14
        ...    administrative=unlocked    operationalState=enabled    availabilityStatus=degraded    cell_type=lte
        Wait until keyword succeeds    2min    5s    CB0010564 verify cell status not degrade or disable by cellid    cellid=668
        ...    administrative=Unlocked    operationalState=enabled
        Wait until keyword succeeds    2min    5s    CB0010564 verify cell status not degrade or disable by cellid    cellid=15
        ...    administrative=unlocked    operationalState=enabled    cell_type=lte
        Wait until keyword succeeds    6min    5s    CB0010564 verify cell status not degrade or disable by cellid    cellid=667
        ...    administrative=Unlocked    operationalState=enabled
        Wait until keyword succeeds    6min    5s    CB0010564 verify cell status not degrade or disable by cellid    cellid=14
        ...    administrative=unlocked    operationalState=enabled    cell_type=lte
       Wait until keyword succeeds    6min    5s    CB0010564 verify cell status not degrade or disable by cellid    cellid=666
        ...    administrative=Unlocked    operationalState=enabled
        Wait until keyword succeeds    6min    5s    CB0010564 verify cell status not degrade or disable by cellid    cellid=13
        ...    administrative=unlocked    operationalState=enabled    cell_type=lte
    END
    FOR    ${index}    IN RANGE    1
        Sleep     60s
        coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-3    timeout=${300}    connection=GNB_OAM
        sleep    5s
        CB0010564 verify cell status not degrade or disable by cellid    cellid=666    administrative=Unlocked    operationalState=enabled
        CB0010564 verify cell status not degrade or disable by cellid    cellid=13    administrative=unlocked    operationalState=enabled
        ...    cell_type=lte
        CB0010564 verify cell status degrade or disable by cellid    cellid=667    administrative=Unlocked    operationalState=enabled
        ...    availabilityStatus=degraded
        CB0010564 verify cell status degrade or disable by cellid    cellid=668    administrative=Unlocked    operationalState=enabled
        ...    availabilityStatus=degraded
        CB0010564 verify cell status degrade or disable by cellid   cellid=14    administrative=unlocked    operationalState=enabled
        ...    availabilityStatus=degraded    cell_type=lte
        CB0010564 verify cell status degrade or disable by cellid   cellid=15    administrative=unlocked    operationalState=enabled
        ...    availabilityStatus=degraded    cell_type=lte
        coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-3    timeout=${300}    connection=GNB_OAM
        wait until keyword succeeds    10min    20sec    RU Should Be Online    ru_index=3
        Wait until keyword succeeds    8min    30s    verify all cells should be onair
        Wait until keyword succeeds    5min    30s    verify all cells should be onair    cell_type=lte    connection=GNB_OAM
    END
    [Teardown]    case 12 recovery ENV
    AlarmWatchdog.remove_allow_alarms    fault_id=1815
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4003
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    AlarmWatchdog.remove_allow_alarms    fault_id=1972

CB010564-E_17_Verify_cell_will_not_get_a_grant_after_one_of_the_RU_down
    AlarmWatchdog.add_allow_alarms    fault_id=1815
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4003
	AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=1972
    coam.perform_delta_recommissioning    delta_file=${CB0010564_case19_v2}    connection=GNB_OAM
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    config_name=${CB0010564_E_17}
    Sleep    120s
    Wait until keyword succeeds    5min    30s    check cell status by cellid    cellid=998    status=enabled    cell_type=nr
    Wait until keyword succeeds    5min    30s    check cell status by cellid    cellid=1000    status=enabled    cell_type=nr
    Wait Until Keyword Succeeds    5min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    check cell status by cellid    cellid=999    status=disabled    cell_type=nr
    ${grant_info_cell1}    Get Grant Parameters By Coam
    ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3
    Should be True    '${grant_info_cell1}[grantId]'=='3550000000_3570000000'
    Should be True    '${grant_info_cell3}[grantId]'!='None'
    Perform RU Power Off    ru_index=${2}
    Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${2}
    Sleep    240s
    coam.perform_delta_recommissioning    delta_file=${CB0010564_case17_v2_cell2}    connection=GNB_OAM
    Sleep    200s
    ${grant_info_cell1_new}    Get Grant Parameters By Coam
    ${grant_info_cell2_new}    Get Grant Parameters By Coam    cellID=2
    ${grant_info_cell3_new}    Get Grant Parameters By Coam    cellID=3
    Should be True    '${grant_info_cell1_new}[grantId]'=='${grant_info_cell1}[grantId]'
    Should be True    '${grant_info_cell3_new}[grantId]'=='${grant_info_cell3}[grantId]'
    Should be True    '${grant_info_cell2_new}[grantId]'!='None'
    Wait until keyword succeeds    5min    30s    check cell status by cellid    cellid=998    status=enabled    cell_type=nr
    coam.perform_delta_recommissioning    delta_file=${CB0010564_v2_all}    connection=GNB_OAM
    Sleep    120s
    Perform RU Power On    ru_index=${2}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    [Teardown]    run keyword and ignore error    Perform RU Power On    ru_index=${2}
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=1815
    AlarmWatchdog.remove_allow_alarms    fault_id=4003
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    AlarmWatchdog.remove_allow_alarms    fault_id=1972

CB010564-E_9_NR_RAT_reset_when_all_cells_are_onair_Concurrent_Mode
    AlarmWatchdog.add_allow_alarms    fault_id=1815
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4003
    AlarmWatchdog.add_allow_alarms    fault_id=1972
    ${SCF_Concurrent_SBTS00}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_Concurrent_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_Concurrent_SBTS00}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs}    connection=GNB_OAM
    start SAS server
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    	FOR    ${TEST_LOOP}    IN RANGE    0    5
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Connect to gnb coam via ssl
    #   coam.rat_reset       rat_type=LTE     timeout=300    connection=GNB_OAM
    #    Sleep    180s
	#	Wait until keyword succeeds    8min    30s    verify all cells should be onair
	#	Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    #    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
    #    should be true    ${alarm_status}
    #    Sleep    60s
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
    [Teardown]    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs_actnrcbrs}    connection=GNB_OAM
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=1815
    AlarmWatchdog.remove_allow_alarms    fault_id=4003
    AlarmWatchdog.remove_allow_alarms    fault_id=1972

Check HB 500 in SAS log
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3550000000_3570000000\".*\"responseCode\": 500.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"3570000000_3590000000\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

CB010564-E_19_Verify_pre-TX_measurement_after_RU_reset
    AlarmWatchdog.add_allow_alarms    fault_id=4003
    coam.perform_delta_recommissioning    delta_file=${CB0010564_case19_v2}    connection=GNB_OAM
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    config_name=${CB0010564_E_19}
    Sleep    120s
    Wait until keyword succeeds    5min    30s    check cell status by cellid    cellid=998    status=enabled    cell_type=nr
    Wait until keyword succeeds    5min    30s    check cell status by cellid    cellid=1000    status=enabled    cell_type=nr
    Wait Until Keyword Succeeds    5min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    check cell status by cellid    cellid=999    status=disabled    cell_type=nr
    ${grant_info_cell1}    Get Grant Parameters By Coam
    Should be True    '${grant_info_cell1}[grantId]'=='3550000000_3570000000'
    Perform RU Reset    ru_index=${1}
    Wait Until Keyword Succeeds    90 sec    5 sec    RU Should Be Offline    ru_index=${1}    connection=GNB_OAM
    Sleep    400s
    Check HB 500 in SAS log
    Sleep    120s
    Wait until keyword succeeds    5min    30s    check cell status by cellid    cellid=998    status=enabled    cell_type=nr
    Wait until keyword succeeds    5min    30s    check cell status by cellid    cellid=1000    status=enabled    cell_type=nr
    Wait Until Keyword Succeeds    5min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    check cell status by cellid    cellid=999    status=disabled    cell_type=nr
    coam.perform_delta_recommissioning    delta_file=${CB0010564_v2_all}    connection=GNB_OAM
    Sleep    120s
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    AlarmWatchdog.remove_allow_alarms    fault_id=4003


10564_RU_reset
    AlarmWatchdog.add_allow_alarms    fault_id=4003
    &{fault_6832}     Create Dictionary     faultId=${6832}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_6832}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    ${SCF_Concurrent_SBTS00}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_Concurrent_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_Concurrent_SBTS00}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs}    connection=GNB_OAM
    start SAS server
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    FOR    ${loop}    IN RANGE    1    20
        Sleep   120s
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
        Perform all RU reset
		Wait until keyword succeeds    10min    30s    verify all cells should be onair
        Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    END
    [Teardown]    case 12 recovery ENV
    AlarmWatchdog.remove_allow_alarms    fault_id=4003

Perform all RU reset
    FOR    ${index}    IN RANGE    1    3
        coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${index}    force_radio_reset=${True}
        ...    timeout=${600}    connection=GNB_OAM
        Check RU Onair
        Wait Until Keyword Succeeds    2min    20s    check RU Availability    rmod_index=${index}
    END

10564_BB_reset
    &{fault_6832}     Create Dictionary     faultId=${6832}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_6832}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    ${SCF_Concurrent_SBTS00}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_Concurrent_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_Concurrent_SBTS00}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs}    connection=GNB_OAM
    start SAS server
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
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
        coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    reset_type=Warm    force_radio_reset=${True}
        ...    timeout=300s    connection=GNB_OAM
        Wait until keyword succeeds    8min    30s    verify all cells should be onair
        Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
        Sleep    60s
        csn.reset_cache
    END
    selenium login and disable screen lock
    [Teardown]    case 12 recovery ENV
