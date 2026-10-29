*** Settings ***
Documentation
...    Implementation of IQ_Data_Collect_by_L1high_Uplink_Suspicious_Event test case
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com

Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME      gnbbbu
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnbalarm
Library     taf.rfrl.bts.devices.du.logs_collecting.basic_logs.GnbLog    WITH NAME      gnblog
Library     ../python/DataTransferOperations.py    WITH NAME    data_transfer
Library     ../python/SnapshotOperations.py   WITH NAME    snapshot_keywords


*** Keywords ***
IQ_Data_Collect_by_L1high_Uplink_Suspicious_Event
    [Documentation]
    ...    Collect IQ Data by triggering L1high Uplink Suspicious Event.
    ...    ARGS:
    ...    - ul_nr_subcell_list (dict, mandatory): Dict containing list of nr cells to configure UPlane L1 IQ capture.
    ...        Example:
    ...        [{'nrcellDN': 'MRBTS-77777/NRBTS-77777/NRCELL-1', 'subcellId': 0}]
    ...    - capture_ru_list (dict, mandatory): Dict containing list of RUs to configure UPlane L1 IQ capture.
    ...        RU should be defined by params dedicated to its type/family.
    ...        Example for AWKUC:
    ...        [{'captureActivityTimer': 2, 'groupId': 2, 'targetRMOD': '/MRBTS-77777/EQM-1/APEQM-1/RMOD-3'}]
    ...    - dt_info (dict, mandatory): Dictionary containing data transer details for UL TCP.
    ...        Example:
    ...        {"lncel_id": "1",
    ...         "lnrelgnbcell_id": "0",
    ...         "uplink": "570 Mbits/sec",
    ...         "deviation": "25"}
    ...    - dt_duration (str, optional): Data Transfer duration in secons. Defaults to 60s.
    ...    - rad_domain_name (str, optional): Domain name of BTS R&D debug parameter. Defaults to NrUlPhy.
    ...    - rad_param_name (str, optional): BTS R&D debug parameter name. Defaults to phyEventEnableExt.
    ...    - rad_param_value (str, optional): BTS R&D debug parameter value (mask). Defaults to 2147483648.
    ...    - snapshot_dir (str, optional): Directory to save snapshot with IQ Data files. Defaults to LOG_PATH.
    ...    - regex_iq_data_file (str, optional): Regex pattern to search IQ Data files in snapshot.
    ...      Defaults to RMOD_.*fcpTriggeredCapture.*.
    ...    - profile (str, optional): L1-IQ capture configuration parameter aplicable since SBTS25R3.
    ...      Defaults to UL_PROFILE_3.
    [Arguments]
    ...    ${ul_nr_subcell_list}
    ...    ${capture_ru_list}
    ...    ${dt_info}
    ...    ${dt_duration}=60s
    ...    ${rad_domain_name}=NrUlPhy
    ...    ${rad_param_name}=phyEventEnableExt
    ...    ${rad_param_value}=2147483648
    ...    ${snapshot_dir}=${LOG_PATH}
    ...    ${regex_iq_data_file}=RMOD_.*fcpTriggeredCapture.*
    ...    ${profile}=UL_PROFILE_3
    ${sw_stream}=    gnbbbu.get_bts_sw_release_name
    ${profile} =	Set Variable If	"""${sw_stream}""">="""SBTS25R3"""    ${profile}    ${None}
    gnbalarm.allow_alarm    alarm=L1 IQ Data Suspicious Event
    gnbbbu.configure_uplane_l1_iq_data
    ...    ul_nr_subcell_list=${ul_nr_subcell_list}
    ...    capture_ru_list=${capture_ru_list}
    ...    capture_on_event=${True}
    ...    capture_on_event_bb_ru=${True}
    ...    buffer_cycle=1024frames
    ...    profile=${profile}
    gnbbbu.set_rad_debug_parameters
    ...    domain=${rad_domain_name}
    ...    name=${rad_param_name}
    ...    value=${rad_param_value}
    data_transfer.start_tcp_data_transfer
    ...    duration=${dt_duration}
    ...    expected_ul_tput=${dt_info['uplink']}
    ...    tolerance=${dt_info['deviation']}
    ...    lnrelgnbcell_id=${dt_info['lnrelgnbcell_id']}
    ...    lncel_id=${dt_info['lncel_id']}
    ${snapshot_path}=    gnblog.collect_snapshot
    ...    log_dir=${snapshot_dir}
    ...    snapshot_coverage=Full
    ...    snapshot_name=Snapshot_L1_IQ_Data.zip
    snapshot_keywords.search_file_in_snapshot
    ...    snapshot_path=${snapshot_path}
    ...    regex_pattern=${regex_iq_data_file}
    [Teardown]    Run Keywords
    ...    gnbbbu.disable_uplane_l1_iq_capture
    ...    AND    gnbbbu.reset_rad_debug_parameters    domain=${rad_domain_name}    name=${rad_param_name}
    ...    AND    gnbalarm.disallow_alarm    alarm=L1 IQ Data Suspicious Event
