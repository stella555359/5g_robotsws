*** Settings ***
Documentation
...   author: Sara Nowak
...   contact: sara.nowak@nokia.com
...   maintainer: sara.nowak@nokia.com

Library     DateTime                                                     WITH NAME    dt
Library     taf.ue                                                       WITH NAME    ue
Library     taf.rfrl.procedures.resources.python.common_allowed_alarms   WITH NAME    alarm
Library     taf.rfrl.bts.commissioning                                   WITH NAME    commission
Library     taf.rfrl.utilities.logger.custom_logger                      WITH NAME    logger
Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning       WITH NAME    gnb_scf
Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations        WITH NAME    gnb_du
Library     taf.rfrl.utilities.test_config.DefaultFileLocation           WITH NAME    dfl
Library     taf.sbts.oam.coam.admin                                      WITH NAME    admin_cli
Library     sfp_operations.py                                            WITH NAME    sfp_operations

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${skip_commissioning}          ${false}
${skip_common_steps}           ${false}

${used_cell_nrcellidentity}    20246019

@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  7107  61673
# 7107 Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
# 61673 Wifi Enabled Alarm in un-commissioned state

*** Keywords ***

Suite Setup
    [Documentation]    KW for Suite Setup. Performs full comissioning and common steps

    logger.Log Info To Console    Suite Setup Start
    Run Keyword If    '${skip_commissioning}'!='true'   Common Suite Setup With OnAir Test Line Preparation
    ...    increase_timeout_for_update_sw=1800
    ...    swconfig_from_path=commissionings/Krakow/7_7_T08SK042/CB012453_swconfig.txt
    ...    list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
    ...    should_LTE_neighbour_be_changed=${True}
    Run Keyword If    '${skip_common_steps}' != 'true'      Common Suite Setup    check_truck_roll=${True}
    logger.Log Info To Console    Suite Setup End\n


Suite Teardown
    [Documentation]    KW for Suite Teardown. Performs common steps

    logger.Log Info To Console    Suite Teardown Start
    Run Keyword If    '${skip_common_steps}' != 'true'     Common Suite Teardown
    logger.Log Info To Console    Suite Teardown End\n


Test Setup
    [Documentation]    KW for Test Setup. Performs common steps, prepares UE and attenuator
    ...    :param ue_alias: taf.ue UE alias
    ...    :param ue_caps: cababilites bases on which proper UE is choosen in taf.ue

    logger.Log Info To Console    Test Setup Start
    Run Keyword If    '${skip_common_steps}' != 'true'
    ...    Common Preconditions With Watching Alarms    raise_exception_when_setup_ru_console_fail=${False}
    logger.Log Info To Console    Test Setup End\n


Test Teardown
    [Documentation]    KW for Test Teardown. Detaches UE and performs common steps
    ...                :param ue_alias: taf.ue UE alias

    logger.Log Info To Console    Test Teardown Start
    Run Keyword If    '${skip_common_steps}' != 'true'    Run Keywords
    ...           Common Postconditions With Watching Alarms   collect_snapshot_from_ru=${False}
    ...    AND    Run Keyword If Test Failed       Collect Snapshot From gNB      gnb_id=0    log_dir=${LOG_PATH}
    logger.Log Info To Console    Test Teardown End\n


Attach ${ue_alias} With Cell Verification
    [Documentation]    KW perfroms UE attach with cell verification using taf.ue KWs
    ...    :param ue_alias: taf.ue UE alias

    logger.Log Info To Console    Attach ${ue_alias}
    ue.Attach Ue    ${ue_alias}
    ${CELL_ID}=    ue.Get Ue Info    ${ue_alias}   CELL_ID
    Should Be Equal    ${used_cell_nrcellidentity}     ${CELL_ID}

Detach UEs
    [Documentation]    KW perfroms UEs dettach using taf.ue KWs
    #Run Keyword and Ignore Error    ue.Detach Ue    UE1
    Run Keyword and Ignore Error    ue.Detach Ue    UE2
    Run Keyword and Ignore Error    ue.Detach Ue    UE3

Detach ${ue_alias}
    [Documentation]    KW perfroms UE dettach using taf.ue KWs
    Run Keyword and Ignore Error    ue.Detach Ue    ${ue_alias}

Prepare UEs for L3 Call
    [Documentation]    KW for preparing UEs for L3 call.
    #Prepare Ue for L3 Call    alias=UE1    capabilities=MTP_UE   reboot_ue=False
    Prepare Ue for L3 Call    alias=UE2    capabilities=COMMERCIAL_UE   reboot_ue=False
    Prepare Ue for L3 Call    alias=UE3    capabilities=COMMERCIAL_UE   reboot_ue=False

Prepare 16 Cells and 10 Cells Deltas
    [Documentation]    KW uploads 16-cell and 10-cell configurations and generates addition/deletion delta JSON files.
    ${target_scf_path}    Set Variable    ${OUTPUTDIR}/BTS0_DU0_target_scf.xml
    ${actual_scf_path}    Set Variable    ${OUTPUTDIR}/BTS0_DU0_actual_scf.xml

    logger.Log Info To Console    Create delta addon and delta deletion.
    Upload configuration CB012455_16_Cells
    gnb_du.get_bts_configuration_file    bts_id=0    du_id=0    filename=BTS0_DU0_target_scf.xml    local_dir=${OUTPUTDIR}
    Upload configuration CB012455_10_Cells
    ${delta_addition}    gnb_scf.generate_delta_json_from_scf_files    target_scf_path=${target_scf_path}
    ...                                                                delta_scf_path=${OUTPUTDIR}/delta_sector_addition.json
    ${delta_deletion}    gnb_scf.generate_delta_json_from_scf_files    target_scf_path=${actual_scf_path}
    ...                                                                actual_scf_path=${target_scf_path}
    ...                                                                delta_scf_path=${OUTPUTDIR}/delta_sector_deletion.json

    Set Suite Variable    ${delta_config_addition}    ${delta_addition}
    Set Suite Variable    ${delta_config_deletion}    ${delta_deletion}
    logger.Log Info To Console    Delta addon and delta deletion created successfully.


Upload configuration ${prefix_tag}
    [Documentation]    KW perfroms commissioning on gNB to onair state.
    logger.Log banner to console    Upload configuration ${prefix_tag}
    commission.Perform Commissioning On Gnb To Onair State    prefix_tag=${prefix_tag}    update_timeout=1800
    logger.Log Info To Console    BTS is onair    log_hierarchy=2


Upload Swconfig And Commission BTS
    [Documentation]    KW uploads swconfig and perfroms full comissoning on 2 BTSes. Commissioning is done in parallel

    commission.Upload Swconfig On Classical Gnb    bts_id=0    prefix_tag=CB012453
    logger.Log Info To Console    Comissioning BTS
    commission.Perform Commissioning On Gnb To Onair State    prefix_tag=CB012453-SR-E


Verify Allowed Alarms
    [Arguments]     ${allowed_alarms}=${None}
    [Documentation]    Keyword verifies if there are no any alarms despite of allowed alarms gNB.
    ...                :param faults_names:    List of allowed alarms.

    ${default_alarms}=    alarm.get_variables
    Set Suite Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]

    Sleep    60s
    logger.Log Info To Console    Verify Allowed Alarms on gNB    log_hierarchy=2
    Verify Allowed Alarms on gNB    allowed_alarms=${allowed_alarms}    gnb_id=0    du_id=${0}


Start and Verify UDP 8CC DL and 4CC UL data transfer for ${ue_alias}
    [Documentation]    The keyword executes UDP 8CC DL and 4CC UL data transmission for UE.

    logger.Log Info To Console    Start and verify 8CC DL 4CC UL data transfer
    Start and Verify TCP DL and UL data transfer for UE    ue_alias=${ue_alias}    dl_tput=4200 Mbits/sec
    ...                                                    ul_tput=550 Mbits/sec


Start and Verify UDP 4CC DL and 2CC UL data transfer for ${ue_alias}
    [Documentation]    The keyword executes UDP 4CC DL and 2CC UL data transmission for UE2.

    logger.Log Info To Console    Start and verify 4CC DL 2CC UL data transfer
    Start and Verify TCP DL and UL data transfer for UE    ue_alias=${ue_alias}    dl_tput=2200 Mbits/sec
    ...                                                    ul_tput=280 Mbits/sec


Start and Verify bidirectional 8CC DL and 4CC UL data transfer for ${ue_alias}
    [Documentation]    The keyword executes UDP 8CC DL and 4CC UL data transmission for UE.

    logger.Log Info To Console    Start and verify 8CC DL 4CC UL data transfer
    Start and Verify bidirectional TCP data transfer for UE    ue_alias=${ue_alias}   dl_tput=4200 Mbits/sec
    ...                                                        ul_tput=550 Mbits/sec   deviation=10%


Start and Verify TCP DL and UL data transfer for UE
    [Arguments]     ${ue_alias}=UE1
    ...             ${apn}=${None}
    ...             ${dl_tput}=4200 Mbits/sec
    ...             ${ul_tput}=530 Mbits/sec
    ...             ${data_transfer_time}=30s
    ...             ${omit}=5
    ...             ${deviation}=20%
    ...             ${protocol}=tcp
    ...             ${parallel_streams}=4
    ...             ${max_segment_size}=1310

    [Documentation]    The keyword executes TCP DL and UL data transmission for a specific time and checks if throughput
    ...                was within allowed deviation
    ...    :param ue_alias: taf.ue UE alias
    ...    :param dl_tput: DL throughput value of data transfer
    ...    :param ul_tput: UL throughput value of data transfer
    ...    :param data_transfer_time: for how data transfer will last
    ...    :param omit: it is a delay in seconds to start counting the tput ex. '20'
    ...                 1st 20 seconds of datatransfer will be omited.

    ${dl_dt_name}=            Set Variable    TCP_DL_DataTransfer_1
    ${ul_dt_name}=            Set Variable    TCP_UL_DataTransfer_1

    ue.Start Data Transfer    dt_name=${dl_dt_name}    ue_alias=${ue_alias}    apn=${apn}    direction=dl
    ...                       duration=${data_transfer_time}    protocol=${protocol}   max_segment_size=${max_segment_size}
    ...                       parallel_streams=${parallel_streams}    deviation=${deviation}    omit=${omit}
    logger.Log Info To Console    DL TCP data transfer started    log_hierarchy=2
    ue.Await Data Transfer Finish    ${dl_dt_name}
    ue.Stop Data Transfer    dt_name=${dl_dt_name}
    ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name}    tput=${dl_tput}    omit=${omit}
    ...                                            deviation=${deviation}
    logger.Log Info To Console    DL TCP data transfer OK    log_hierarchy=3

    ue.Start Data Transfer    dt_name=${ul_dt_name}    ue_alias=${ue_alias}    apn=${apn}    direction=ul
    ...                       duration=${data_transfer_time}    protocol=${protocol}    max_segment_size=${max_segment_size}
    ...                       parallel_streams=${parallel_streams}    deviation=${deviation}    omit=${omit}
    logger.Log Info To Console    UL TCP data transfer started    log_hierarchy=2
    ue.Await Data Transfer Finish    ${ul_dt_name}
    ue.Stop Data Transfer    dt_name=${ul_dt_name}
    ue.Verify Average Throughput With Deviation    dt_name=${ul_dt_name}    tput=${ul_tput}     omit=${omit}
    ...                                            deviation=${deviation}
    logger.Log Info To Console    UL TCP data transfer OK    log_hierarchy=3


Start and Verify bidirectional TCP data transfer for UE
    [Arguments]     ${ue_alias}=UE1
    ...             ${apn}=${None}
    ...             ${dl_tput}=4200 Mbits/sec
    ...             ${ul_tput}=530 Mbits/sec
    ...             ${data_transfer_time}=30s
    ...             ${omit}=5
    ...             ${deviation}=20%
    ...             ${protocol}=tcp
    ...             ${parallel_streams}=4
    ...             ${max_segment_size}=1310

    [Documentation]    The keyword executes TCP bidirectional DL and UL data transmission for a specific time and checks
    ...                if throughput was within allowed deviation
    ...    :param ue_alias: taf.ue UE alias
    ...    :param dl_tput: DL throughput value of data transfer
    ...    :param ul_tput: UL throughput value of data transfer
    ...    :param data_transfer_time: for how data transfer will last
    ...    :param omit: it is a delay in seconds to start counting the tput ex. '20'
    ...                 1st 20 seconds of datatransfer will be omited.

    ${dl_dt_name}=            Set Variable    TCP_DL_DataTransfer_1
    ${ul_dt_name}=            Set Variable    TCP_UL_DataTransfer_1

    ue.Start Data Transfer    dt_name=${dl_dt_name}    ue_alias=${ue_alias}    apn=${apn}    direction=dl
    ...                       duration=${data_transfer_time}    protocol=${protocol}    max_segment_size=${max_segment_size}
    ...                       parallel_streams=${parallel_streams}    deviation=${deviation}    omit=${omit}
    logger.Log Info To Console    DL TCP data transfer started    log_hierarchy=2
    ue.Start Data Transfer    dt_name=${ul_dt_name}    ue_alias=${ue_alias}    apn=${apn}    direction=ul
    ...                       duration=${data_transfer_time}    protocol=${protocol}    max_segment_size=${max_segment_size}
    ...                       parallel_streams=${parallel_streams}    deviation=${deviation}    omit=${omit}
    logger.Log Info To Console    UL TCP data transfer started    log_hierarchy=2

    ue.Await Data Transfer Finish    ${dl_dt_name}
    ue.Await Data Transfer Finish    ${ul_dt_name}

    ue.Stop Data Transfer    dt_name=${dl_dt_name}
    ue.Stop Data Transfer    dt_name=${ul_dt_name}

    ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name}    tput=${dl_tput}    omit=${omit}
    ...                                            deviation=${deviation}
    logger.Log Info To Console    DL TCP data transfer OK    log_hierarchy=3
    ue.Verify Average Throughput With Deviation    dt_name=${ul_dt_name}    tput=${ul_tput}     omit=${omit}
    ...                                            deviation=${deviation}
    logger.Log Info To Console    UL TCP data transfer OK    log_hierarchy=3


Attach and Verify DL&UL data transfer
    [Arguments]     ${cells}

    [Documentation]    The keyword performs UE attach and executes TCP DL and UL data transmission for a specific time
    ...                 and checks if throughput was within allowed deviation
    ...    :param ue_alias: taf.ue UE alias

    logger.Log Info To Console   Verify attach to ${cells}
    Attach UE2 With Cell Verification
    Start and Verify UDP 8CC DL and 4CC UL data transfer for UE2
    Run Keyword and Ignore Error    ue.Detach Ue    UE2


Add 6 Cells to NRCELLGRP-70
    [Documentation]    Adds NRCELLGRP-70 configuration with 8 cells using a predefined delta file.
    ...                Ensures all cells are on-air after commissioning.
    logger.Log Info To Console    Add NRCELLGRP-70 with 8 Cells

    gnb_scf.perform_bts_delta_json_commissioning    delta_file=${delta_config_addition}
    ...     bts_id=0  du_id=0   skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${180}
    logger.Log Info To Console    NRCELLGRP-70 added successfully    log_hierarchy=2
    Wait Until Keyword Succeeds       300 sec    30 sec    gnbcell.Verify All Cells Are Onair


Remove 6 Cells from NRCELLGRP-70
    [Documentation]    Removes NRCELLGRP-70 configuration with 8 cells using a predefined delta file.
    ...                Ensures all cells are on-air after deletion.
    logger.Log Info To Console    Remove NRCELLGRP-70 with 8 Cells
    gnb_scf.perform_bts_delta_json_commissioning    delta_file=${delta_config_deletion}
    ...     bts_id=0  du_id=0   skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${120}
    logger.Log Info To Console    NRCELLGRP-70 removed successfully    log_hierarchy=2
    Wait Until Keyword Succeeds       300 sec    30 sec    gnbcell.Verify All Cells Are Onair


Get delta configuration path
    [Documentation]    Sets suite variables with paths to delta JSON files for cell addition and deletion.
    ...                The paths are based on the release returned by BTS API.
    ${release}=    dfl.Get Commissioning Branch

    Set Suite Variable    ${delta_config_addition}       ${CURDIR}/delta/${release}/delta_sector_addition.json
    Set Suite Variable    ${delta_config_deletion}       ${CURDIR}/delta/${release}/delta_sector_deletion.json


Set additional alarms
    [Arguments]    ${alarms_for_test}
    [Documentation]    Sets allowed alarms for the current test case based on input and default variables.
    ...                Adds custom alarms if provided.
    ...
    ...                :param alarms_for_test:   List of additional alarms for current test case.

    ${default_alarms}=    alarm.get_variables
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

    Add Custom Allowed Alarms If Defined


Check Link Mode And Set Additional Alarms
    [Arguments]    ${sfp_id}=1
    [Documentation]    Verifies link mode synchronization for given SFP port and sets additional alarms accordingly.
    ...
    ...                :param sfp_id:   ID of SFP port to be verified. Default is 1.

    ${link_mode_parameters}=    sfp_operations.check_link_mode_parameters    cablink_id=100${sfp_id}

    ${is_synchronized}=    Set Variable    ${link_mode_parameters['linkModeSynchronization']}

    Run Keyword If    '${is_synchronized}' != 'True'        Run Keywords
    ...    logger.Log Info To Console    Lock SFP-${sfp_id} port with data link    AND
    ...    Set Test Variable    @{ADDITIONAL_ALARMS_FOR_TESTS}    BTS configuration error (not enough HW for LCR)
    ...                                                           Not able to synchronize baseband bus
    Run Keyword If    '${is_synchronized}' == 'True'        Run Keywords
    ...    logger.Log Info To Console    Lock SFP-${sfp_id} port with synchronization link    AND
    ...    Set Test Variable    @{ADDITIONAL_ALARMS_FOR_TESTS}    BTS configuration error (not enough HW for LCR)
    ...                                                           Not able to synchronize baseband bus
    ...                                                           No connection to unit

    Set Test Variable    @{ALL_ADDITIONAL_ALARMS_FOR_TESTS}    BTS configuration error (not enough HW for LCR)
    ...                                                        Not able to synchronize baseband bus
    ...                                                        No connection to unit

    Set Additional Alarms    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}


Lock and unlock SFP
    [Arguments]    ${sfp_id}=1
    [Documentation]    Locks and then unlocks the given SFP port.
    ...                Verifies allowed alarms after each action and waits until all cells are on-air.
    ...
    ...                :param sfp_id:   ID of SFP port to be locked/unlocked. Default is 1.

    sfp_operations.lock_sfp    sfp_id=${sfp_id}
    Sleep       120s
    Verify Allowed Alarms on gNB    allowed_alarms=${allowed_alarms}
    Sleep       120s
    sfp_operations.unlock_sfp    sfp_id=${sfp_id}
    Sleep       120s
    Verify Allowed Alarms on gNB    allowed_alarms=${allowed_alarms}
    Wait Until Keyword Succeeds       300 sec    30 sec    gnbcell.Verify All Cells Are Onair

