*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/10588_variables.py

Documentation    This is for SG8 common keywords
...              Author: wangqingqing
...              Squard: HZ SG8

*** Variables ***
@{cell_id}    ${2}
@{cell_id_1}    ${1}
*** Keywords ***
CB0010706-F_cell_Setup_NRTDD_4x80M_4T4R_NRFDD_6x40M_4T4R
    ${SCF_CB010706_F}    Replace String    ${Golden_SCF_Path}    .xml    _CB010706-F.xml
    set suite variable  ${SCF_CB010706_F}
    Commissioning SCF And Check On Air   scf_path=${SCF_CB010706_F}
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

remove RMOD and FDD cell
    selenium login and disable screen lock
    log to console  delete FDD cell
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2   timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-1    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-3   timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-2    timeout=15
    selenium_coam.remove_element
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    node_index=${2}
    selenium_coam.remove_element
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    node_index=${1}
    log to console  delete RMOD 7
	selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-7    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/EQM-1/HWTOP-1/CABLINK-11    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/EQM-1/HWTOP-1/CABLINK-12    timeout=15
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${600}
    sleep    180s
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    [Teardown]    Selenium Logout And Close Browser

add RMOD and FDD cell
    [Arguments]    ${file_path}    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
    selenium login and disable screen lock
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${file_path}    timeout=${300}
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    ${new_conf_name}    SG8_common.get_file_name    file_path=${file_path}
    ${new_conf}    Replace String    ${new_conf_name}    SCF_    CONF-1_SCF_
    ${release}    Get program version based on gNB active version
    ${new_conf_1}=   Run Keyword If   "${release}"=="SBTS24R3"
    ...     Set Variable     CONF-1
    ...     ELSE    Set Variable       ${new_conf}
    ${new_conf_1}=   Run Keyword If   "${release}"=="SBTS25R1"
    ...     Set Variable     CONF-1
    ...     ELSE    Set Variable       ${new_conf}
    log to console  add object
    FOR    ${TEST_LOOP}    IN RANGE    1    3
        ${cell_id}=   Evaluate    ${TEST_LOOP}+1
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
        ...    object_class_name=LCELNR    plan_to_copy_from=${new_conf_1}
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        ...    include_subobject=${True}   id_value=${cell_id}    timeout=15
        sleep    30s
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
        ...    object_class_name=NRCELL    plan_to_copy_from=${new_conf_1}
        ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    include_subobject=${True}   id_value=${cell_id}    timeout=15
        sleep    30s
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
        ...    object_class_name=NRCELLGRP    plan_to_copy_from=${new_conf_1}
        ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${TEST_LOOP}
        ...    id_value=${TEST_LOOP}    timeout=15
        sleep    30s
        ${lcrId}   Convert To Integer   ${cell_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrId}
        selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    timeout=15
    END
    FOR  ${i}  IN RANGE    0    3
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${i}
        ...    node_index=${i}
    END
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1
    ...    object_class_name=RMOD    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-7
    ...    include_subobject=${True}   id_value=${7}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/EQM-1/HWTOP-1
    ...    object_class_name=CABLINK    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/EQM-1/HWTOP-1/CABLINK-11
    ...    include_subobject=${True}   id_value=${11}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/EQM-1/HWTOP-1
    ...    object_class_name=CABLINK    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/EQM-1/HWTOP-1/CABLINK-12
    ...    include_subobject=${True}   id_value=${12}    timeout=15
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${600}
    sleep    120s
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    [Teardown]    Selenium Logout And Close Browser

General_SiSo_Online_FDD_Sector_Addition_Deletion_when_TDD_supercell_configured_on_half_ABIP
    ${SCF_CB010706_F_F}    Replace String    ${Golden_SCF_Path}    .xml    _CB010706-F-F.xml
    set suite variable  ${SCF_CB010706_F_F}
    Commissioning SCF And Check On Air   scf_path=${SCF_CB010706_F_F}
    remove RMOD and FDD cell
    coam.reset_site   connection=GNB_OAM
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    add RMOD and FDD cell    file_path=${SCF_CB010706_F_F}

Reconfiguration 3supercells to 1supercell
    [Documentation]
    [Arguments]    ${file_path}
    selenium login and disable screen lock
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${file_path}
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    ${new_conf_name}    SG8_common.get_file_name    file_path=${file_path}
    ${new_conf}    Replace String    ${new_conf_name}    SCF_    CONF-1_SCF_
    ${release}    Get program version based on gNB active version
    ${new_conf_1}=   Run Keyword If   "${release}"=="SBTS24R3"
    ...     Set Variable     CONF-1
    ...     ELSE    Set Variable       ${new_conf}
    ${new_conf_1}=   Run Keyword If   "${release}"=="SBTS25R1"
    ...     Set Variable     CONF-1
    ...     ELSE    Set Variable       ${new_conf}
    log to console  add CHANNELGROUP from cell2
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    ...    object_class_name=CHANNELGROUP    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2
    ...    include_subobject=${True}   id_value=${2}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    ...    object_class_name=CHANNELGROUP    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-4
    ...    include_subobject=${True}   id_value=${4}    timeout=15
    log to console  add CHANNELGROUP from cell3
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    ...    object_class_name=CHANNELGROUP    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-5
    ...    include_subobject=${True}   id_value=${5}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    ...    object_class_name=CHANNELGROUP    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-6
    ...    include_subobject=${True}   id_value=${6}    timeout=15
    log to console  delete cell
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2   timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-1    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-3   timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-2    timeout=15
    selenium_coam.remove_element
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    node_index=${2}
    selenium_coam.remove_element
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    node_index=${1}
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${600}
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    [Teardown]    Selenium Logout And Close Browser

Online remove channelgroup and check cell onair
    [Arguments]    ${cellID}=1		 ${remove}=2
    selenium login and disable screen lock
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellID}/CHANNELGROUP-${remove}  timeout=15
	selenium_coam.validate_plan
    selenium_coam.activate_plan		activate_plan_despite_errors=${True}    timeout=180
    sleep    60s
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    [Teardown]    Selenium Logout And Close Browser

Online add channelgroup and check cell onair
    [Arguments]    ${file_path}    ${cellID}=1    ${copy_cellID}=1    ${addition}=2
    selenium login and disable screen lock
    Online add channelgroup    file_path=${file_path}    cellID=${cellID}    copy_cellID=${copy_cellID}    addition_CHANNELGROUP=${addition}
	selenium_coam.validate_plan
    selenium_coam.activate_plan		activate_plan_despite_errors=${True}    timeout=180
    sleep    60s
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    [Teardown]    Selenium Logout And Close Browser

General_SiSo_SuperCell_Reconfiguration_3supercells_to_1supercell
    ${SCF_CB010706_C}    Replace String    ${Golden_SCF_Path}    .xml    _CB010706-C.xml
    set suite variable  ${SCF_CB010706_C}
    Commissioning SCF And Check On Air   scf_path=${SCF_CB010706_C}
    Reconfiguration 3supercells to 1supercell    file_path=${SCF_CB010706_C}
    FOR    ${TEST_LOOP}    IN RANGE    0    5
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Online remove channelgroup and check cell onair    cellID=1    remove=6
        Wait Until Keyword Succeeds   3min   30s    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        sleep    30s
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
        Online add channelgroup and check cell onair    file_path=${SCF_CB010706_C}    cellID=1    copy_cellID=3            addition=6
        Wait Until Keyword Succeeds   3min   30s    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    END

CB010588 all Cell Should Be degraded
    [Arguments]    ${cell_type}=nr    ${connection}=GNB_OAM
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Should be equal as Strings    ${cell['status']['operationalState']}    enabled
        Should be equal as Strings    ${cell['status']['availabilityStatus']}    degraded
    END

CB010588 all Cell Should Be normal
    [Arguments]    ${cell_type}=nr    ${connection}=GNB_OAM
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Should be equal as Strings    ${cell['status']['operationalState']}    enabled
        ${availability_not_in_dict}    check_availability_not_in_dict    availability=availabilityStatus    key_in_dict=${cell['status']}
        should be true    ${availability_not_in_dict}
    END

General_SiSo_SuperCell_Subcell_failure_statemangement_SG08
    ${SCF_CB010706_C}    Replace String    ${Golden_SCF_Path}    .xml    _CB010706-C.xml
    set suite variable  ${SCF_CB010706_C}
    Commissioning SCF And Check On Air   scf_path=${SCF_CB010706_C}
    FOR    ${TEST_LOOP}    IN RANGE    0    10
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Connect to gnb coam via ssl
        Perform RU Power Off
        Wait Until Keyword Succeeds   5min    30s   CB010588 all Cell Should Be degraded
        sleep    30s
        Perform RU Power On
        Wait until keyword succeeds    5min    30s    CB010588 all Cell Should Be normal
        Wait until keyword succeeds    3min    30s    Check all cells info should be onair
        Wait Until Keyword Succeeds   3min   30s    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        csn.reset_cache
        Sleep    30s
        Connect to gnb coam via ssl
        coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    force_radio_reset=${True}    timeout=180    connection=GNB_OAM
        Wait Until Keyword Succeeds   5min    10s   CB010588 all Cell Should Be degraded
	    Wait until keyword succeeds    8min    30s    CB010588 all Cell Should Be normal
        Wait until keyword succeeds    5min    30s    Check all cells info should be onair
        Wait Until Keyword Succeeds   3min   30s    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        csn.reset_cache
        Sleep    30s
        Connect to gnb coam via ssl
        coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    timeout=${120}    connection=GNB_OAM
        sleep    10s
        wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=1
        Wait Until Keyword Succeeds   5min    10s   CB010588 all Cell Should Be degraded
        sleep    30s
        coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    timeout=${120}    connection=GNB_OAM
        sleep    10s
        wait until keyword succeeds  5min  20sec  RU Should Be Unlocked    ru_index=1
        Wait until keyword succeeds    5min    30s    CB010588 all Cell Should Be normal
        Wait until keyword succeeds    5min    30s    Check all cells info should be onair
        Wait Until Keyword Succeeds   8min   30s    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        csn.reset_cache
    END
    Sleep    30s
    selenium login and disable screen lock
    log to console  modify actsupercell
    FOR    ${TEST_LOOP}    IN RANGE    0    3
        ${cell_id}=   Evaluate    ${TEST_LOOP}+1
	    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=Activate super cell    abbr=actSuperCell     new_value=false
	    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${TEST_LOOP}
	    ...    filter_param=Number of transmitted Synchronization Signal Blocks    abbr=numberOfTransmittedSsBlocks    new_value=1 beam
    END
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3  timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-4  timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-6  timeout=15
	selenium_coam.validate_plan
    selenium_coam.activate_plan		activate_plan_despite_errors=${True}    timeout=180
    sleep    60s
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    [Teardown]    Selenium Logout And Close Browser

Online add channelgroup
    [Documentation]
    [Arguments]    ${file_path}     ${cellID}=1    ${copy_cellID}=1    ${addition_CHANNELGROUP}=2
    ${new_conf_name}    SG8_common.get_file_name    file_path=${file_path}
    ${new_conf}    Replace String    ${new_conf_name}    SCF_    CONF-1_SCF_
    ${release}    Get program version based on gNB active version
    ${new_conf_1}=   Run Keyword If   "${release}"=="SBTS24R3"
    ...     Set Variable     CONF-1
    ...     ELSE    Set Variable       ${new_conf}
    ${new_conf_1}=   Run Keyword If   "${release}"=="SBTS25R1"
    ...     Set Variable     CONF-1
    ...     ELSE    Set Variable       ${new_conf}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${file_path}
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add cell ${cellID} CHANNELGROUP
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellID}
    ...    object_class_name=CHANNELGROUP    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cellID}/CHANNELGROUP-${addition_CHANNELGROUP}
    ...    include_subobject=${True}   id_value=${addition_CHANNELGROUP}    timeout=15

General_SiSo_SuperCell_Reconfiguration_normal_cells_to_supercell_when_combination_-A_and_-D
    ${SCF_CB010706_E}    Replace String    ${Golden_SCF_Path}    .xml    _CB010706-E.xml
    set suite variable  ${SCF_CB010706_E}
    ${SCF_CB010706_E_copy}    Replace String    ${Golden_SCF_Path}    .xml    _CB010706-E_copy.xml
    set suite variable  ${SCF_CB010706_E_copy}
    Commissioning SCF And Check On Air   scf_path=${SCF_CB010706_E}
    FOR    ${TEST_LOOP}    IN RANGE    0    5
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Connect to gnb coam via ssl
        coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    reset_type=Warm    force_radio_reset=${True}
        ...    timeout=300s    connection=GNB_OAM
        Wait until keyword succeeds    10min    30s    Check all cells info should be onair
        Sleep    60s
        csn.reset_cache
    END
    selenium login and disable screen lock
    Online add channelgroup    file_path=${SCF_CB010706_E_copy}    cellID=2    copy_cellID=2    addition_CHANNELGROUP=2
    log to console  modify actsupercell
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2
	...    filter_param=Activate super cell    abbr=actSuperCell     new_value=true
	selenium_coam.validate_plan
    selenium_coam.activate_plan		activate_plan_despite_errors=${True}    timeout=180
    sleep    60s
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    [Teardown]    Selenium Logout And Close Browser

General_SiSo_E2E_system_setup_with_data_transfer_A2_A12_mix_bandwidth_combination
    ${SCF_A2_A12}    Replace String    ${Golden_SCF_Path}    .xml    _A2_A12.xml
    set suite variable  ${SCF_A2_A12}
    Commissioning SCF And Check On Air   scf_path=${SCF_A2_A12}
    Set PA Value For Pointed Port    PA_Port_List=${PA_all_use_in_10588}    value=${63}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Cell_2_A2_A12}    value=${3}
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.98    min_percent=0.85
    sleep    30s
    Set PA Value For Pointed Port    PA_Port_List=${PA_all_use_in_10588}    value=${63}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Cell_1}    value=${3}
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id_1}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.98    min_percent=0.85

General_SiSo_RU_lock_unlock_A14_A16_combination
    ${SCF_A14_A16}    Replace String    ${Golden_SCF_Path}    .xml    _A14_A16.xml
    set suite variable  ${SCF_A14_A16}
    Commissioning SCF And Check On Air   scf_path=${SCF_A14_A16}
    ${ru_index_list}  Get All RU Index    connection=GNB_OAM
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to gnb coam via ssl
        log to console    \n***Lock RU ${ru_index}***
        ${ru_index}  Convert To Integer    ${ru_index}
        coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    timeout=${120}    connection=GNB_OAM
        sleep    10s
        wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${ru_index}
        csn.reset_cache
    END
    sleep    30s
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to gnb coam via ssl
        log to console    \n***unLock RU ${ru_index}***
        ${ru_index}  Convert To Integer    ${ru_index}
        coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    timeout=${120}    connection=GNB_OAM
        sleep    10s
        wait until keyword succeeds  5min  20sec  RU Should Be Unlocked    ru_index=${ru_index}
        csn.reset_cache
    END
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    Set PA Value For Pointed Port    PA_Port_List=${PA_all_use_in_10588}    value=${63}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Cell_lock_and_unlock_A10}    value=${5}
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.5    min_percent=0.2

CB010588 Cell Should Be Unblocked
    [Arguments]    ${cell_index}=${0}    ${cell_type}=nr    ${connection}=GNB_OAM
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run Keyword If     ${cell['globalCellId']} == ${cell_index}
        ...    Run Keywords    Should be equal as Strings    ${cell['status']['operationalState']}    enabled    AND
        ...    Should be equal as Strings    ${cell['status']['blockingState']}    Unblocked
        exit for loop if   ${cell['globalCellId']} == ${cell_index}
    END

CB010588 Cell Should Be blocked
    [Arguments]    ${cell_index}=${0}    ${cell_type}=nr    ${connection}=GNB_OAM
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run Keyword If     ${cell['globalCellId']} == ${cell_index}
        ...    Run Keywords    Should be equal as Strings    ${cell['status']['operationalState']}    disabled    AND
        ...    Should be equal as Strings    ${cell['status']['blockingState']}    Blocked
        exit for loop if   ${cell['globalCellId']} == ${cell_index}
    END

General_SiSo_Cell_lock_and_unlock_A10
    ${SCF_A10}    Replace String    ${Golden_SCF_Path}    .xml    _A10.xml
    set suite variable  ${SCF_A10}
    Commissioning SCF And Check On Air   scf_path=${SCF_A10}
    ${cell_id_list}    Get All Cell Id
    FOR    ${idx}    IN    @{cell_id_list}
        coam.block_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbts_id}/NRCELL-${idx}    connection=GNB_OAM
        sleep    10s
        Wait Until Keyword Succeeds   3 min  10 sec   CB010588 Cell Should Be blocked   cell_index=${idx}
    END
    sleep    30s
    FOR    ${idx}    IN    @{cell_id_list}
        coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbts_id}/NRCELL-${idx}    connection=GNB_OAM
        sleep    10s
        Wait Until Keyword Succeeds   3 min  10 sec   CB010588 Cell Should Be Unblocked   cell_index=${idx}
    END
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    Set PA Value For Pointed Port    PA_Port_List=${PA_all_use_in_10588}    value=${63}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Cell_lock_and_unlock_A10}    value=${3}
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.9    min_percent=0.85

Manual_SiSo_SM_LTE RAT reset_10times
    FOR    ${TEST_LOOP}    IN RANGE    0    5
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Connect to gnb coam via ssl
        coam.rat_reset       rat_type=LTE     timeout=300    connection=GNB_OAM
        Sleep    180s
        Wait until keyword succeeds    10min    30s    Check all cells info should be onair
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
        Sleep    60s
        coam.rat_reset       rat_type=NR     timeout=300    connection=GNB_OAM
        Sleep    180s
        Wait until keyword succeeds    10min    30s    Check all cells info should be onair
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
        Sleep    60s
        csn.reset_cache
    END

RF_module_reset_from_GUI_SG8
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM
    ${ru_index_list}  Get All RU Index    connection=${connection}
    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    FOR  ${ru_index}  IN  @{ru_index_list}
        log to console    \n***RF Module index ${ru_index} Reset from GUI***
        ${ru_index}  Convert To Integer    ${ru_index}
        selenium_coam.reset_ru  ru_index=${ru_index}
        Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
    END
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    gnb_index=${gnb_index}    connection=${connection}
    Check RF Startup and Gnb Status    ${ru_index_list}    gnb_index=${gnb_index}    connection=${connection}
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    [Teardown]  Selenium Logout And Close Browser

Set bbmodBoardConfigType
    [Arguments]    ${type}=NRTDD    ${index}=2
    log to console    begain to set bbmodBoardConfigType to ${type}...
    selenium login and disable screen lock
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${index}
    ...    filter_param=Baseband board configuration type
    ...    abbr=bbmodBoardConfigType    new_value=${type}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    selenium logout and close browser


General_SiSo_RF_module_reset_from_GUI_5times
#    &{fault_4590}     Create Dictionary     faultId=${4590}
#    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4590}
#    set test variable  ${ALLOWED_HISTORY_FAULT}
 	Wait until keyword succeeds    10min    30s    verify all cells should be onair
	Set bbmodBoardConfigType	type=NRFDD
    Wait until keyword succeeds    10min    20sec    Expect Fault Should Present    faultId=1868
	Set bbmodBoardConfigType	type=NRTDD
	Wait until keyword succeeds    10min    30s    verify all cells should be onair
	FOR    ${TEST_LOOP}    IN RANGE    0    2
        ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
        Log To Console    \n GNB Reset Iteration ${TEST_LOOP} in progress at: ${date}
        Perform BTS Site Reset
        Sleep    30s
        COAM Wait gnb And Cells ready    timeout=110min    gnb_type='${gNb_CuType}'
        Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
    END
    FOR    ${TEST_LOOP}    IN RANGE    0    2
        Connect to gnb coam via ssl
        RF_module_reset_from_GUI_SG8
        csn.reset_cache
    END



KPI_Auto_BTS_site_reset
    ${SCF_CB010706_F_F}    Replace String    ${Golden_SCF_Path}    .xml    _CB010706-F-F.xml
    set suite variable  ${SCF_CB010706_F_F}
    Commissioning SCF And Check On Air   scf_path=${SCF_CB010706_F_F}
    FOR    ${TEST_LOOP}    IN RANGE    0    20
        ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
        Log To Console    \n GNB Reset Iteration ${TEST_LOOP} in progress at: ${date}
        Perform BTS Site Reset
        Sleep    30s
        COAM Wait gnb And Cells ready    timeout=110min    gnb_type='${gNb_CuType}'
        Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
    END

Block_ublock_RAT
	[Arguments]    ${connection}=GNB_OAM
    ${SCF_CB010706_F_F}    Replace String    ${Golden_SCF_Path}    .xml    _CB010706-F-F.xml
    set suite variable  ${SCF_CB010706_F_F}
    Commissioning SCF And Check On Air   scf_path=${SCF_CB010706_F_F}
    FOR    ${TEST_LOOP}    IN RANGE    0    20
         ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
        Log To Console    \n GNB Reset Iteration ${TEST_LOOP} in progress at: ${date}
        coam.block_rat    rat=NR     timeout=600    connection=${connection}
        Wait For Expect Fault Present    faultId=4614    timeout=300
        check blcok cell status
        coam.unblock_rat    rat=NR     timeout=600    connection=${connection}
        Wait For Expect Fault To Disappear    faultId=4614    timeout=300
        Wait Until Keyword Succeeds    10 min    30 sec    Verify all cells should be onair    cell_type=nr
        Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
    END

check blcok cell status
        ${cell_list_nr}    Get All Cell Id    cell_type=nr
        FOR  ${cell_index}  IN  @{cell_list_nr}
            check single cell should be blocked    cell_type=nr
        END
