*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Maintainer:

Library      Collections
Library      testsuite.Krakow.OAM.regression.RAN_PZ_KRK2.FR_CB008325_CB008827_CB009180.resources.GnbRuCustom
...          WITH NAME    GnbRuOp
Library      testsuite.Krakow.OAM.regression.RAN_PZ_KRK2.FR_CB009487.resources.ScfParser
...          WITH NAME    AsirScfParser
Library      testsuite/Krakow/OAM/regression/RAN_PZ_KRK2/FR_CB009487/resources/methods.py    WITH NAME
...          cusom_methods

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     ../../FR_CB009493_CB009055_CB009487/resources/keywords.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${VIRTUAL_DISPLAY}                                ${True}
${OAM_IP}                                         ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

&{EXPECTED_RMOD_STATUS}                           availabilityStatus=Online
...                                               administrativeState=Unlocked
...                                               operationalState=Enabled

&{BTSID_RAT}                                      nr=80058
...                                               lte=80058

&{EXPECTED_HUBMOD_STATUS}                         localState=unblocked
...                                               operationalState=enabled

&{EXPECTED_BTS_CELL_STATUS_AFTER_LOCK}            administrativeState=Unlocked
...                                               operationalState=Disabled
...                                               blockingState=Unblocked

&{EXPECTED_BTS_CELL_STATUS_AFTER_UNLOCK}          administrativeState=Unlocked
...                                               operationalState=Enabled
...                                               availabilityStatus=Online
...                                               blockingState=Unblocked

&{EXPECTED_ASIRMOD_STATUS_AFTER_LOCK}             administrativeState=Locked
...                                               operationalState=Enabled

&{EXPECTED_HUBMOD_STATUS_AFTER_LOCK}              localState=blocked
...                                               operationalState=enabled

&{EXPECTED_ASIRMOD_STATUS_AFTER_UNLOCK}           administrativeState=Unlocked
...                                               operationalState=Enabled

&{EXPECTED_CELL_STATUS_AFTER_BLOCK}               administrativeState=Unlocked
...                                               operationalState=Disabled
...                                               blockingState=Blocked

*** Keywords ***
Test Teardown For TC48
    Unblock Selected Cells For TC48
    Wait Until Keyword Succeeds    2 min    15 sec    Verify All Cells Are Operating Correctly
    Verify ASiR Alarms
    Common Postconditions

Test Teardown For TC83
    Unblock Selected Cells For TC83
    Wait Until Keyword Succeeds    2 min    15 sec    Verify All Cells Are Operating Correctly
    Verify ASiR Alarms
    Common Postconditions

Verify RMOD Status
    sbts_methods.check_rmod_status    expected_status_dict=${EXPECTED_RMOD_STATUS}

Reset BTS And Wait For All Online Statuses
    GnbDuOp.reset_bts
    Sleep    30 sec    reason=Waiting for BTS reset to take place
    GnbDuOp.wait_until_all_bbmods_are_online
    Wait For All Online Statuses On BTS And ASiR

Wait For All Online Statuses On BTS And ASiR
    Wait Until Keyword Succeeds    5 min    15 sec    Verify ASIRMOD Status
    Wait Until Keyword Succeeds    5 min    15 sec    Verify RMOD Status
    Wait Until All HUBs Are Operating Correctly
    Wait Until Keyword Succeeds    5 min    15 sec    Verify All Cells Are Operating Correctly
    Wait For All Cells To Be Operating Correctly On ASiR WebEM

Verify Active Alarms And Historic Alarms On BTS And ASiR After BTS Reset
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 10 61625 61074
    ...            ${allowed_faults_asir}=61648 10 4480
    ...            ${required_history_gnb_Reset}=4592
    ...            ${allowed_history_asir_Reset}=4480 61648
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    GnbAsirOp.check_asir_active_alarm    allowed_fault_id_list=${allowed_faults_asir}
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    required_fault_id_list=${required_history_gnb_Reset}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_history_asir_Reset}

Reset All BTS ASIRMODs
    GnbRuOp.reset_all_asirmod_radio_units    timeout=${180}

Wait For All BTS ASIRMOD Modules To Be Operational
    Wait Until Keyword Succeeds    5 min    15 sec    GnbRuOp.verify_all_asirmod_radio_module_status

Download ASiR Commissioning Via ASiR WebEM
    Prepare ASiR WebEM Browser
    ${asir_commissioning_file}    AsirWebEM.save_scf
    [Return]    ${asir_commissioning_file}
    [Teardown]    Close ASiR WebEM Browser

Get All BTS BBMOD IDs
    ${ids}    GnbDuOp.get_all_bbmod_ids
    Set Test Variable    ${BBMOD_ID}    ${ids}

Get ASiR BBMOD Cell Relation Mapping
    ${asir_scf}    Download ASiR Commissioning Via ASiR WebEM
    ${bbmod_cell_mapping}    cusom_methods.bbmod_cell_relation_mapping    bbmod_id_list=${BBMOD_ID}
    ...                                                                   oam_ip=${OAM_IP}
    ${all_asir_cell}    AsirScfParser.kw_get_cellid_list_by_rat    scf_file=${asir_scf}
    ${bbmod_asir_cell_mapping}    cusom_methods.bbmod_asir_cell_relation_mapping    all_asir_cell=${all_asir_cell}
    ...                                                                             dict_bbmod_cell_mapping=${bbmod_cell_mapping}
    ...                                                                             bts_cell_info=${BTSID_RAT}
    Set Test Variable    ${BTS_BBMOD_CELL_MAPPING}    ${bbmod_cell_mapping}
    Set Test Variable    ${ASIR_BBMOD_CELL_MAPPING}    ${bbmod_asir_cell_mapping}

Verify Selected Cell Red Status On ASiR WebEM
    [Arguments]    ${asir_cell_id_list}
    Prepare ASiR WebEM Browser
    ${asir_commissioning_file}    AsirWebEM.check_asir_cell_status    cell_type=BTS
    ...                                                               id_list=${asir_cell_id_list}
    ...                                                               expected_status=red
    [Teardown]    Close ASiR WebEM Browser

Verify Selected Cell Green Status On ASiR WebEM
    [Arguments]    ${asir_cell_id_list}
    Prepare ASiR WebEM Browser
    ${asir_commissioning_file}    AsirWebEM.check_asir_cell_status    cell_type=BTS
    ...                                                               id_list=${asir_cell_id_list}
    ...                                                               expected_status=green
    [Teardown]    Close ASiR WebEM Browser

Lock All BBMOD Units One By One And Verify Cell Status
    FOR    ${bbmod}    IN    @{BBMOD_ID}
        GnbDuOp.lock_bbmod    bbmod_id=${bbmod}
        Wait Until Keyword Succeeds    1 min    15 sec    GnbDuOp.verify_bbmod_locked_status    bbmod_id=${bbmod}

        ${macro_cell_id_list}    Set Variable    ${BTS_BBMOD_CELL_MAPPING['${bbmod}']}
        ${asir_cell_id_list}    Set Variable    ${ASIR_BBMOD_CELL_MAPPING['${bbmod}']}
        ${asir_list_length}    Get Length    ${asir_cell_id_list}
        Wait Until Keyword Succeeds    2 min    30s    sbts_methods.check_sbts_cell_status
        ...                                            cell_list=${macro_cell_id_list}
        ...                                            expected_status_dict=${EXPECTED_BTS_CELL_STATUS_AFTER_LOCK}
        Run Keyword If    ${asir_list_length} != 0    Verify Selected Cell Red Status On ASiR WebEM    asir_cell_id_list=${asir_cell_id_list}
    END

Unlock All BBMOD Units One By One And Verify Cell Status
    FOR    ${bbmod}    IN    @{BBMOD_ID}
        GnbDuOp.unlock_bbmod    bbmod_id=${bbmod}
        Wait Until Keyword Succeeds    1 min    15 sec    GnbDuOp.verify_bbmod_unlocked_status    bbmod_id=${bbmod}

        ${macro_cell_id_list}    Set Variable    ${BTS_BBMOD_CELL_MAPPING['${bbmod}']}
        ${asir_cell_id_list}    Set Variable    ${ASIR_BBMOD_CELL_MAPPING['${bbmod}']}
        ${asir_list_length}    Get Length    ${asir_cell_id_list}
        Wait Until Keyword Succeeds    2 min    30s    sbts_methods.check_sbts_cell_status
        ...                                            cell_list=${macro_cell_id_list}
        ...                                            expected_status_dict=${EXPECTED_BTS_CELL_STATUS_AFTER_UNLOCK}
       Run Keyword If    ${asir_list_length} != 0    Verify Selected Cell Green Status On ASiR WebEM    asir_cell_id_list=${asir_cell_id_list}
    END

Verify Active BTS And ASiR Alarms
    [Arguments]    ${allowed_faults_sbts}=61524 61648 61649 61652 4654 4655 4681 6261 6450 4297 6327 61510 10 61625 61074
    ...            ${allowed_faults_asir}=61648 10 4480
    sbts_methods.check_sbts_active_alarm    allowed_fault_id_list=${allowed_faults_sbts}
    GnbAsirOp.check_asir_active_alarm    allowed_fault_id_list=${allowed_faults_asir}

Block Selected Cells For TC48
    [Arguments]    ${selected_cells}=8
    sbts_methods.block_sbts_cell    cell_list=${selected_cells}
    Wait Until Keyword Succeeds    2 mins    15 sec    sbts_methods.check_sbts_cell_status
    ...                                                cell_list=${selected_cells}
    ...                                                expected_status_dict=${EXPECTED_CELL_STATUS_AFTER_BLOCK}

Unblock Selected Cells For TC48
    [Arguments]    ${selected_cells}=8
    sbts_methods.unblock_sbts_cell    cell_list=${selected_cells}

Block Selected Cells For TC83
    [Arguments]    ${selected_cells}=0
    sbts_methods.block_sbts_cell    cell_list=${selected_cells}
    Wait Until Keyword Succeeds    2 mins    15 sec    sbts_methods.check_sbts_cell_status
    ...                                                cell_list=${selected_cells}
    ...                                                expected_status_dict=${EXPECTED_CELL_STATUS_AFTER_BLOCK}

Unblock Selected Cells For TC83
    [Arguments]    ${selected_cells}=0
    sbts_methods.unblock_sbts_cell    cell_list=${selected_cells}
