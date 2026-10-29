*** Settings ***
Documentation   This is a very first suite to hold commissioning
...             this is preparing hand over scenarios
...
...             NRBTS.NRCELL.sMeasConfigSsbRsrp
...             -------------------------------
...             This parameter defines the threshold for PCell or PSCell (when UE is in EN-DC)
...             measurement controlling when the UE is required to perform measurements
...             associated to neighbouring cells for RS type SS/PBCH blocks and measurement quantities RSRP.
...
...


Library     ute_wtssim

Resource    ../../resources/Common/wts_ue.robot
Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/connect.robot
Resource    AI_Common.robot
Resource    commission_handover.robot
Resource    handover_operations.robot

Library     taf.sbts.oam.coam.admin   WITH NAME    admin
Library     determine_ue_ids.py

Suite Setup     Run Keywords    AI_Common.Bring Airphone to on Air status
...             AND             Prepare Test Data

*** Variables ***
# Directory for AI analysis results
${ai_result_dir}          /tmp/
# Number of handover operations to perform
${number_of_operations}   20

# Default UE ID for operations
${UE_ID}   1

# Global dictionaries for cell and UE management
${UE_DATA}            ${None}              # Dictionary storing UE state and cell information
${GCID_TO_PCID}       ${None}              # Global Cell ID to Physical Cell ID mapping
${PCID_TO_GCID}       ${None}              # Physical Cell ID to Global Cell ID mapping
${TECHNOLOGY}         ${None}              # Cell technology mapping (LTE/NR)
${AVAILABLE_UE_IDS}   ${None}              # List of all available UE IDs

*** Test Cases ***
Perform Several Handover Steps
    [Documentation]   Perform the Commissioning for Handover Scenarios

    commission_handover.Perform Commissioning
    ${wts_status}=    Run Keyword and Return Status    Bring Airphone TL to on Air status without reboot
    IF    ${wts_status} == False             Bring Airphone TL to on Air status

    ${log_alias}    Prepare Syslogs
    ${target_dir}   testline.Get Testcase Log Directory

    taf.ul.log_collection.Setup Collectors     names=${log_alias}
    taf.ul.log_collection.Start Collectors     names=${log_alias}

    Perform Random UE Handovers    amount=${number_of_operations}

    taf.ul.log_collection.Stop Collectors      names=${log_alias}
    taf.ul.log_collection.Collect Collectors   names=${log_alias}    target_dir=${target_dir}
    taf.ul.log_collection.Teardown Collectors  names=${log_alias}

    ${syslog_files}=   taf.ul.log_collection.Get Log File    log_type=syslog
    ...                                                      target_dir=${target_dir}
    ...                                                      network_element=gnb_0

    Log To Console    Collected Syslog: ${syslog_files}
    Copy Files        @{syslog_files}    ${ai_result_dir}
    Copy Files        @{syslog_files}    ${OUTPUT DIR}

*** Keywords ***

Prepare Test Data
    Initialize GCID To PCID Mapping
    Initialize UE Data


Initialize GCID To PCID Mapping
    [Documentation]   This keyword creates two mapping tables for global cell id and for
    ...               physical cell id. For simple accessing the following global dictionaries are
    ...               created (Data is obtained from admin):
    ...
    ...               ${GCID_TO_PCID}   mapping with key: global cell id    value: physical cell id
    ...               ${PCID_TO_GCID}   mapping with key: physical cell id   value: global cell id
    ...               ${TECHNOLOGY}     mapping with key: global cell id    value: technology
    ${oam_alias}     connect.Setup OAM HTTP Session
    ${cell_info}     admin.Get Cells Info   connection=${oam_alias}

    ${GCID_TO_PCID}    Create Dictionary
    ${PCID_TO_GCID}    Create Dictionary
    ${TECHNOLOGY}      Create Dictionary

    FOR   ${cell_item}   IN   @{cell_info}
        Log To Console   Global Cell ID: ${cell_item}[globalCellId]
        Log To Console   Physical Cell ID: ${cell_item}[physicalCellId]
        Log To Console   Physical Cell ID: ${cell_item}[technology]

        Set To Dictionary   ${GCID_TO_PCID}   ${cell_item}[globalCellId]     ${cell_item}[physicalCellId]
        Set To Dictionary   ${PCID_TO_GCID}   ${cell_item}[physicalCellId]   ${cell_item}[globalCellId]
        Set To Dictionary   ${TECHNOLOGY}     ${cell_item}[globalCellId]     ${cell_item}[technology]
    END
    Set Suite Variable    ${GCID_TO_PCID}
    Set Suite Variable    ${PCID_TO_GCID}
    Set Suite Variable    ${TECHNOLOGY}


Initialize UE Data
    [Documentation]   All available ue ids in the current basic configuration are fetched. For each UE
    ...               the current state and current cell is retrieved and saved to a list of dictionaries,
    ...               where the keys are the ue_ids and the values are dictionaries containing the data.
    ${UE_DATA}             Create Dictionary
    ${AVAILABLE_UE_IDS}    Get All UE IDs

    FOR   ${all_ue_id_item}   IN   @{available_ue_ids}
        ${state}       common_ue_operations.Get UE State             ${all_ue_id_item}
        ${cell}        common_ue_operations.Get Current Cell of UE   ${all_ue_id_item}
        ${item_data}   Create Dictionary   state   ${state}
        ...                                cell    ${state}
        Set To Dictionary    ${UE_DATA}   ${all_ue_id_item}   ${item_data}
    END

    Set Suite Variable   ${UE_DATA}
    Set Suite Variable   ${AVAILABLE_UE_IDS}








