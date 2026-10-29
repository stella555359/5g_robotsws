*** Settings ***
Documentation
...    Launch_Radio_Module_Troubleshooting_Script_Via_GUI
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com

Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME      gnbbbu
Library     ../python/DataTransferOperations.py    WITH NAME    data_transfer
Library     ../python/RadioOperations.py   WITH NAME    radio_keywords
Library     ../python/SnapshotOperations.py   WITH NAME    snapshot_keywords


*** Keywords ***
Launch_Radio_Module_Troubleshooting_Script_Via_GUI
    [Documentation]
    ...    Launch troubleshooting script via GUI with verification of result snapshot.
    ...    ARGS:
    ...    - script_name (str, mandatory): Name of radio module troubleshooting script
    ...    - rmods_name (list, mandatory): List of radio modules as troubleshooting script input.
    ...         Example: ['RMOD-3/RMOD_R-1 (AWKUC)']
    ...    - dt_info (dict, mandatory): Dictionary containing data transfer details for L3 Call.
    ...         Example:
    ...         {"SECTOR_0": {
    ...         "nrcellgrp_id": "0",
    ...         "lnrelgnbcell_id": "1",
    ...         "lncel_id": "1",
    ...         "downlink": "4300 Mbits/sec",
    ...         "uplink": "570 Mbits/sec",
    ...         "deviation": "20"
    ...         },
    ...         "SECTOR_1": {
    ...         "nrcellgrp_id": "1",
    ...         "lnrelgnbcell_id": "2",
    ...         "lncel_id": "1",
    ...         "downlink": "4300 Mbits/sec",
    ...         "uplink": "570 Mbits/sec",
    ...         "deviation": "20"
    ...         }}
    ...    - ru_id (int, optional): The id of radio unit based on Test Line configuration. Defaults to 0.
    ...    - dt_duration (str, optional): Data Transfer duration in seconds. Defaults to 60s.
    ...    - cells_name (list, optional): List of Cells as troubleshooting script input. All configured cells passed to
    ...      script if cells_name="all".
    ...         Example: ['NRCELL-1', 'NRCELL-2']
    ...    - regex_snapshot_name (str, optional): Regex pattern to validate the name of script result snapshot.
    ...      Defaults to "SCRIPT_RESULT_RU_Common_capture_.*[\\d]{8}-[\\d]{4}.zip"
    ...    - regex_snapshot_content_name (str, optional): Regex pattern to search particular files in result snapshot.
    ...      Defaults to "BTS_.*_RMOD_.*SCRIPT_RESULT_RU_Common_capture"
    ...    - timeout (int, optional): Troubleshooting script execution timeout in seconds. Defaults to 900.
    [Arguments]
    ...    ${script_name}
    ...    ${rmods_name}
    ...    ${dt_info}
    ...    ${ru_id}=${0}
    ...    ${dt_duration}=60s
    ...    ${cells_name}=all
    ...    ${regex_snapshot_name}=SCRIPT_RESULT_RU_Common_capture_.*[\\d]{8}-[\\d]{4}.zip
    ...    ${regex_snapshot_content_name}=BTS_.*_RMOD_.*SCRIPT_RESULT_RU_Common_capture
    ...    ${timeout}=${900}

    data_transfer.start_multi_sector_tcp_data_transfer_dl_and_ul
    ...    sectors_dt_info=${dt_info}
    ...    duration=${dt_duration}
    ${cells_name}=    Run Keyword If    '${cells_name}' == 'all'    radio_keywords.get_cell_info_from_ru    ru_id=${ru_id}
    ...                                                                                                     info=id
    ${snapshot_path}=    gnbbbu.launch_troubleshooting_script_via_gui
    ...    script_name=${script_name}
    ...    cells_name=${cells_name}
    ...    mods_name=${rmods_name}
    ...    script_owner_module=Radio module
    ...    timeout=${timeout}
    snapshot_keywords.verify_snapshot_name
    ...    file_path=${snapshot_path['Collection file']}
    ...    regex=${regex_snapshot_name}
    snapshot_keywords.search_file_in_snapshot
    ...    snapshot_path=${snapshot_path['Collection file']}
    ...    regex_pattern=${regex_snapshot_content_name}
