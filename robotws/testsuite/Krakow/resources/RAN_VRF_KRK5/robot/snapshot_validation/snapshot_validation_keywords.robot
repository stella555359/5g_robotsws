*** Settings ***
Documentation
...  authors: Mateusz Bugaj, Pawel Grabania
...  contact: mateusz.bugaj@nokia.com, pawel.grabania@nokia.com

Resource    taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource    taf/rfrl/bts/robot/common/gnb_log.robot
Resource    taf/rfrl/procedures/resources/robot/LogCollection.robot
#Resource    taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot.robot
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                                                          WITH NAME    gnb_cells
Library     testsuite.Krakow.resources.RAN_VRF_KRK5.python.snapshot_validation.asir_snapshot_validator.AsirSnapshotValidator   WITH NAME   asir_snap


*** Keywords ***
Verify additionally snapshot for asir files
    [Arguments]    ${snapshot_file}
    ...    ${asir_variables_file}=testsuite/Krakow/resources/RAN_VRF_KRK5/python/snapshot_validation/asir_variables.py
    ...    ${expected_missing_files}=${None}
    TRY
        asir_snap.check_for_asir_files_in_snapshot    snapshot_file=${snapshot_file}
        ...                                           asir_variables_file=${asir_variables_file}
    EXCEPT    AS    ${error}
        asir_snap.check_snapshot_status    status=${error}    expected_missing_files=${expected_missing_files}
    ELSE
        ${result}=    asir_snap.verify_if_missing_files_defined_for_asirhubs    expected_missing_files=${expected_missing_files}
        Run Keyword If    ${result}
        ...    logger.log_warn_to_console
        ...    Expected missing files for ASIR hubs defined, but no missing files were reported compare to files defined in asir_variables.py
    END

Verify snapshot
    [Arguments]
    ...    ${asir_csv_file}=testsuite/Krakow/resources/RAN_VRF_KRK5/python/snapshot_validation/ASIR.csv
    ...    ${asir_variables_file}=testsuite/Krakow/resources/RAN_VRF_KRK5/python/snapshot_validation/asir_variables.py
    ...    ${expected_missing_files}=${None}
    [Documentation]    Main keyword which verifies if collected BTS snapshot contains mandatory files.
    ...    param asir_csv_file: path to CSV file which is used by `General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot`
    ...                         procedure to verify only common mandatory files for ASIR HUBS when connected to BTS
    ...    param asir_variables_file: path to python file which contains definition of common mandatory files for ASIR
    ...                               HUBS and also definition of mandatory files which depends on PICO HW connected
    ...                               to ASIR HUBS, file is used by `Verify additionally snapshot for asir files` KW
    ...    param expected_missing_files: dictionary which contains lists of expected missing files for specified RUs.

    LogCollection.Prepare logs path
    ${asir_csv_file_path}=   asir_snap.get_asir_csv_path    asir_csv_file=${asir_csv_file}

    logger.log_info_to_console    Performing 2 gNB resets before snapshot collection
    Reset gNB
    Wait Until Keyword Succeeds    900 sec    30 sec    gnb_cells.Verify All Cells are OnAir
    Reset gNB
    Wait Until Keyword Succeeds    900 sec    30 sec    gnb_cells.Verify All Cells are OnAir
    ${snapshot_file}=    Collect Snapshot From gNB    log_dir=${logs_path}/Full
    logger.log_info_to_console    Snapshot file: ${snapshot_file}

#    TRY
#        General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
#        ...    additional_documentation_path=${asir_csv_file_path}
#    EXCEPT    AS    ${error}
#        asir_snap.check_snapshot_status    status=${error}    expected_missing_files=${expected_missing_files}
#    ELSE
#        Run Keyword If    "${expected_missing_files}"!="${None}"
#        ...    logger.log_warn_to_console
#        ...    Expected missing files defined, but no missing files were reported compare to mandatory files defined in ASIR.csv
#    END
    Run Keyword If    "${asir_csv_file_path}"!="${None}"    Verify additionally snapshot for asir files
#    ...    snapshot_file=${logs_path}/Full/Full_snapshot.zip
    ...    snapshot_file=${snapshot_file}
    ...    asir_variables_file=${asir_variables_file}
    ...    expected_missing_files=${expected_missing_files}
