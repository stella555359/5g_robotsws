*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${DOWNLOAD_DURATION_STANDARD}    20
${DELTA_PROVISION_DURATION_STANDARD}    160
${FULL_PROVISION_DURATION_STANDARD}    600
${SCF_FILE_BACKUP_DURATION_STANDARD}    30

*** Keywords ***
CM__CB012803_CB012663_CM_Verify_Duration_via_WebEM
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   New case for CB012663 performance testing
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.07.2023 - New case for
    ...   RAN_SyVe_CB012663_001_CM_Verify duration of download with delta Plan via WebEM
    ...   RAN_SyVe_CB012663_002_CM_Verify duration of download with full Plan via WebEM
    ...   RAN_SyVe_CB012663_010_CM_Verify duration of provision with delta Plan via WebEM
    ...   RAN_SyVe_CB012663_011_CM_Verify duration of provision with full Plan via WebEM
    ...   RAN_ST_CB012803-A_012_CM_Verify duration of provision with delta Plan via WebEM
    ...   RAN_ST_CB012803-A_010_CM_Verify duration of provision with full Plan via WebEM
    ...   RAN_ST_CB012803-A_014_CM_Verify duration of SCF file backup via WebEM
    Set Tags    CM    UI    AUTHOR-lixin.kang@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    #SCF file backup via WebEM   14.RAN_ST_CB012803-A_014_CM_Verify duration of SCF file backup via WebEM
    ${start_time}    Get Time
    coam.get_current_scf_file    local_dir_path=${BTSFiles}    file_name=${mrbts_id}_scf_backup.xml
    ${end_time}      Get Time
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${time}<${SCF_FILE_BACKUP_DURATION_STANDARD}
    ${cell_list}    coam.Get Cell List
    ${selected_cell}    Evaluate    random.choice(${cell_list['cells']['nr']})    modules=random, sys
    Set Test Variable    ${selected_nrcell}    ${selected_cell['id']['configuration']}
    ${timestamp}    Generate Formatted Timestamp
    ${delta_id}    Set Variable    ${mrbts_id}_${timestamp}
    coam.Create Delta    ${delta_id}
    coam.Append Parameter Update To Delta    MRBTS-${mrbts_id}     btsName    testing12663    ${delta_id}
    coam.Append Parameter Update To Delta    ${selected_nrcell}     actCceSplit    false    ${delta_id}  # object locking
    coam.Append Parameter Update To Delta    ${selected_nrcell}   nrofHARQProcessesForPDSCH    16    ${delta_id}
    ${delta_json}    coam.Get Delta    ${delta_id}
    Log To Console     ${delta_json}

#    # delta download  RAN_SyVe_CB012663_001_CM_Verify duration of download with delta Plan
#    ${start_time}    Get Time
#    coam.Perform Delta Recommissioning    ${delta_json}    True    False
#    ${end_time}      Get Time
#    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
#    Should Be True    ${time}<${DOWNLOAD_DURATION_STANDARD}

    # delta provision   10.RAN_SyVe_CB012663_010_CM_Verify duration of provision with delta Plan via WebEM
    #                   12.RAN_ST_CB012803-A_012_CM_Verify duration of provision with delta Plan via WebEM
    ${start_time}    Get Time
    coam.Perform Delta Recommissioning    ${delta_json}    True    True
    ${end_time}      Get Time
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${time}<${DELTA_PROVISION_DURATION_STANDARD}

#    # full download   2.RAN_SyVe_CB012663_002_CM_Verify duration of download with full Plan via WebEM
#    ${start_time}    Get Time
#    coam.Perform Commissioning      ${mrbts_id}     ${BTS_scf_initial}    skip_parameter_relation_errors=${True}    should_activate=False
#    ${end_time}      Get Time
#    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
#    Should Be True    ${time}<${DOWNLOAD_DURATION_STANDARD}

    # full provision  11.RAN_SyVe_CB012663_011_CM_Verify duration of provision with full Plan via WebEM
    #                 10.RAN_ST_CB012803-A_010_CM_Verify duration of provision with full Plan via WebEM
    ${start_time}    Get Time
    coam.Perform Commissioning      ${mrbts_id}     ${BTS_scf_initial}    skip_parameter_relation_errors=${True}
    ...    should_activate=True    timeout=600
    ${end_time}      Get Time
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${time}<${FULL_PROVISION_DURATION_STANDARD}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

SetUp
    Log To Console    SetUp
    Common Test Setup SBTS    scf_check=${FALSE}
    ${mrbts_id}    Admin Get BTS ID
    Set Test Variable    ${mrbts_id}

TearDown
    Log To Console     Teardown
    ${timestamp}    Generate Formatted Timestamp
    ${delta_id}    Set Variable    ${mrbts_id}_${timestamp}
    coam.Create Delta    ${delta_id}
    coam.Append Parameter Update To Delta    MRBTS-${mrbts_id}     btsName    ${mrbts_id}    ${delta_id}
    coam.Append Parameter Update To Delta    ${selected_nrcell}     actCceSplit    true    ${delta_id}
    coam.Append Parameter Update To Delta    ${selected_nrcell}   nrofHARQProcessesForPDSCH    10    ${delta_id}
    ${delta_json}    coam.Get Delta    ${delta_id}
    coam.Perform Delta Recommissioning    ${delta_json}    True    True
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown SBTS