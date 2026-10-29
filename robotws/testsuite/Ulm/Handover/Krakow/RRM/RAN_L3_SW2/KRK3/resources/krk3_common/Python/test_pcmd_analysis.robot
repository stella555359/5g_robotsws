*** Settings ***
Documentation    Unknow purpase, to be checked or removed

Resource   ../verificators.robot
Library    OperatingSystem



*** Test Cases ***
Test the Analysis of PCMD Files

    ${data_file}=    Set Variable   testsuite/Ulm/Handover/Krakow/RRM/RAN_L3_SW2/KRK3/resources/krk3_common/Python/recorded_data_example.json
    # ${file_content}=     OperatingSystem.Get File    ${data_file}
    # ${records}           Evaluate    json.loads(${file_content})   json
    ${records}     Load Json File   ${data_file}


    ${DuCaConfigurationTraceRecord_A59}    Create Dictionary
    ...    record_name=caConfigurationRecord
    ...    setupSCells=1
    ...    setupSCells.*Item 0.*DuSCellSetupItem.*scellIndex=9
    ...    setupSCells.*Item 0.*DuSCellSetupItem.*subCarrierSpacing=1
    ...    setupSCells.*Item 0.*DuSCellSetupItem.*cellId=1
    ...    setupSCells.*Item 0.*DuSCellSetupItem.*cellId.*nrcgi.*plmn_Identity=13:41:98
    ...    setupSCells.*Item 0.*DuSCellSetupItem.*cellId.*nrcgi.*cellIdentity=00:00:04:00:30
    ...    setupSCells.*Item 0.*DuSCellSetupItem.*nrArfcnDl=640000
    ...    setupSCells.*Item 0.*DuSCellSetupItem.*sCellDirectionConfig=0
    ...    setupSCells.*Item 0.*DuSCellSetupItem.*tagId=0

    ${du_ca_released}     create dictionary
    ...    record_name=caConfigurationRecord
    ...    releasedSCells=1
    ...    releasedSCells.*Item 0.*DuSCellReleaseItem.*cellId=1
    ...    releasedSCells.*Item 0.*DuSCellReleaseItem.*cellId.*nrcgi.*plmn_Identity=13:41:98
    ...    releasedSCells.*Item 0.*DuSCellReleaseItem.*cellId.*nrcgi.*cellIdentity=00:00:04:00:30

    ${CuCaConfigurationTraceRecord_A59}    Create Dictionary
    ...    record_name=caConfigurationRecord
    ...    failedToSetupSCells=1
    ...    failedToSetupSCells.*Item 0.*CuSCellFailedToSetupItem.*scellIndex=9
    ...    failedToSetupSCells.*Item 0.*CuSCellFailedToSetupItem.*cellId=1
    ...    failedToSetupSCells.*Item 0.*CuSCellFailedToSetupItem.*cellId.*nrcgi.*plmn_Identity=13:41:98
    ...    failedToSetupSCells.*Item 0.*CuSCellFailedToSetupItem.*cellId.*nrcgi.*cellIdentity=00:00:04:00:30
    ...    failedToSetupSCells.*Item 0.*CuSCellFailedToSetupItem.*nrArfcnDl=640000
    ...    failedToSetupSCells.*Item 0.*CuSCellFailedToSetupItem.*sCellDirectionConfig=0

    # ${PCMD_seq_A59}    Create List    ${DuCaConfigurationTraceRecord_A59}   ${du_ca_released}   ${CuCaConfigurationTraceRecord_A59}

    ${PCMD1}   Create List   ${DuCaConfigurationTraceRecord_A59}
    # ${PCMD2}   Create List   ${du_ca_released}
    ${PCMD3}   Create List   ${CuCaConfigurationTraceRecord_A59}  ${du_ca_released}



    # ${PCMD_seq_A59}    Create List    ${PCMD1}   ${PCMD2}   ${PCMD3}
    ${PCMD_seq_A59}    Create List    ${PCMD1}        ${PCMD3}


    # Verify extended PCMD Records Sequence in Collection    ${records}    ${PCMD_seq_A59}    strict_fields_check=yes
    Verify extended PCMD Records Sequence in Collection    ${records}    ${PCMD_seq_A59}   strict_fields_check=yes
