*** Settings ***
Documentation
...    Implementation of Online_Sector_Addition_Deletion test case
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com

Resource  taf/rfrl/procedures/resources/robot/Connections.robot
Resource  taf/rfrl/procedures/resources/robot/BtsConfiguration.robot

Library   taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME      gnbbbu
Library   taf.rfrl.procedures.resources.python.json_delta_scf.JsonDeltaCommissioning  WITH NAME  json_delta
Library   ../python/DataTransferOperations.py    WITH NAME    data_transfer


*** Keywords ***
Online_Sector_Addition_Deletion
    [Documentation]
    ...    Test verifies BTS behavior and L3 call after adding and deleting a sector of NR cells.
    ...    ARGS:
    ...    - path_scf_base_sector (str, default): Path to SCF with base sector/NRCELLGRP.
    ...    - path_scf_added_sector (str, default): Path to SCF with added sector/NRCELLGRP.
    ...    - base_sector_dt (dict, default): Dictionary containing data transfer details for base sector L3 Call.
    ...         Example:
    ...         {"lncel_id": "1",
    ...         "lnrelgnbcell_id": "0",
    ...         "downlink": "4300 Mbits/sec",
    ...         "uplink": "570 Mbits/sec",
    ...         "deviation": "25"}
    ...    - added_sector_dt (dict, default): Dictionary containing data transfer details for added sector L3 Call.
    ...         Dictionary should have same structure as default_dt.
    ...    - dt_duration (str, optional): Data Transfer duration in seconds. Defaults to 60s
    [Arguments]
    ...    ${path_scf_base_sector}
    ...    ${path_scf_added_sector}
    ...    ${base_sector_dt}
    ...    ${added_sector_dt}
    ...    ${dt_duration}=60s

    ${delta}=    json_delta.generate_json_delta
    ...    base_scf=${path_scf_base_sector}
    ...    custom_scf=${path_scf_added_sector}
    ...    delta_file=json_delta
    ...    hostname=${LOG_PATH}

    Perform Online Sector Operation
    ...    operation_type=deletion
    ...    delta=${delta}
    Run Keyword And Continue On Failure    data_transfer.start_tcp_data_transfer
    ...    duration=${dt_duration}
    ...    expected_dl_tput=${base_sector_dt['downlink']}
    ...    expected_ul_tput=${base_sector_dt['uplink']}
    ...    tolerance=${base_sector_dt['deviation']}
    ...    lnrelgnbcell_id=${base_sector_dt['lnrelgnbcell_id']}
    ...    lncel_id=${base_sector_dt['lncel_id']}

    Perform Online Sector Operation
    ...    operation_type=addition
    ...    delta=${delta}
    ...    path_scf_base=${path_scf_base_sector}
    data_transfer.start_tcp_data_transfer
    ...    duration=${dt_duration}
    ...    expected_dl_tput=${added_sector_dt['downlink']}
    ...    expected_ul_tput=${added_sector_dt['uplink']}
    ...    tolerance=${added_sector_dt['deviation']}
    ...    lnrelgnbcell_id=${added_sector_dt['lnrelgnbcell_id']}
    ...    lncel_id=${added_sector_dt['lncel_id']}

Perform Online Sector Operation
    [Arguments]    ${operation_type}    ${delta}    ${path_scf_base}=${None}
    ${sw_stream}=    gnbbbu.get_bts_sw_release_name
    ${config_index}=    Set Variable  ${1}
    ${plan_name}=    Set Variable If  """${sw_stream}""">="""SBTS25R2"""
    ...              CONF-${config_index}_${delta.split("/")[-1].split(".")[0]}
    ...              CONF-${config_index}

    Create admin session with default alias
    ${connection}=    connections.get_default_admin_connection_alias
    Create Selenium Session    admin_connection=${connection}

    Run Keyword If    '${operation_type}' == 'addition'
    ...    Add Cells With Status Check
    ...    path_to_delta=${delta}
    ...    path_to_scf=${path_scf_base}
    ...    plan_to_copy_from=${plan_name}
    ...    ELSE IF    '${operation_type}' == 'deletion'
    ...    Delete Cells With Status Check
    ...    path_to_delta=${delta}
    ...    ELSE    Fail
    ...    Unknown operation '${operation_type}' given.
    ...    Supported operations: 'addition' and 'deletion'.
    [Teardown]    Close Selenium Session
