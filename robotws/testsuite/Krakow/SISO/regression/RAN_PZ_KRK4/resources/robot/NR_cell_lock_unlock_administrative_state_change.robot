*** Settings ***
Documentation
...    Implementation of Manual_SiSo_SM_NR_cell_lock_unlock_administrative_state_change test case
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com

Library     taf/rfrl/utilities/logger/custom_logger.py    WITH NAME    logger
Library     ../python/DataTransferOperations.py    WITH NAME    data_transfer
Library     ../python/CellOperations.py   WITH NAME    cell_keywords


*** Keywords ***
NR_cell_lock_unlock_administrative_state_change
    [Documentation]
    ...    Test verifies BTS behavior and L3 call after locking and unlocking sector of NR cells (NRCELLGRP)
    ...    via administrative state.
    ...    ARGS:
    ...    - sectors_dt_info (dict, mandatory): Dictionary containing data transer details for Sector of NR Cells
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
    ...    - duration (str, optional): Data Transfer duration in secons. Defaults to 60s.
    [Arguments]    ${sectors_dt_info}    ${duration}=60s

    FOR  ${sector}  IN  @{sectors_dt_info}
        ${sector_dt}=    Get From Dictionary    ${sectors_dt_info}    ${sector}
        logger.log_info_to_console  \nStart verificatoin of Lock/Unlock NRCELLGRP-${sector_dt['nrcellgrp_id']}
        data_transfer.start_tcp_data_transfer
        ...    duration=${duration}
        ...    expected_dl_tput=${sector_dt['downlink']}
        ...    expected_ul_tput=${sector_dt['uplink']}
        ...    tolerance=${sector_dt['deviation']}
        ...    lnrelgnbcell_id=${sector_dt['lnrelgnbcell_id']}
        ...    lncel_id=${sector_dt['lncel_id']}
        cell_keywords.lock cell group
        ...    cell_group_id=${sector_dt['nrcellgrp_id']}
        ...    administrative_state=${True}
        cell_keywords.unlock cell group
        ...    cell_group_id=${sector_dt['nrcellgrp_id']}
        ...    administrative_state=${True}
        data_transfer.start_tcp_data_transfer
        ...    duration=${duration}
        ...    expected_dl_tput=${sector_dt['downlink']}
        ...    expected_ul_tput=${sector_dt['uplink']}
        ...    tolerance=${sector_dt['deviation']}
        ...    lnrelgnbcell_id=${sector_dt['lnrelgnbcell_id']}
        ...    lncel_id=${sector_dt['lncel_id']}
        logger.log_info_to_console  \nFinished verification of NRCELLGRP-${sector_dt['nrcellgrp_id']}
    END
