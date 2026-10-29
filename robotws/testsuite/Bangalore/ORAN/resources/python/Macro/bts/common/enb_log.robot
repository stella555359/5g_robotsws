*** Settings ***

Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.log.EnbLog    WITH NAME      enblog



*** Keywords ***
Collect Snapshot From eNB
    [Arguments]    ${log_dir}=${OUTPUT DIR}    ${enb_id}=0    ${timeout}=${900}  ${du_id}=${0}
    [Documentation]    Collect snapshot via API and save to local machine.
    ...     :param log_dir:   TDirectory where snapshot will be collected.
    ...     :param enb_id:    ENB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param timeout:   Timeout for the operation
    enblog.collect_snapshot    log_dir=${log_dir}    bts_id=${enb_id}    timeout=${timeout}    du_id=${du_id}

Collect IM Snapshot From eNB
    [Arguments]    ${log_dir}=${OUTPUT DIR}    ${enb_id}=0    ${timeout}=${900}  ${du_id}=${0}
    [Documentation]    Collect IM snapshot via API and save to local machine.
    ...     :param log_dir:   TDirectory where snapshot will be collected.
    ...     :param enb_id:    ENB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param timeout:   Timeout for the operation
    enblog.collect_im_snapshot    log_dir=${log_dir}    bts_id=${enb_id}    timeout=${timeout}    du_id=${du_id}

Collect IMS Log From eNB
    [Arguments]    ${log_dir}=${OUTPUT DIR}    ${enb_id}=0    ${timeout}=${900}  ${du_id}=${0}
    [Documentation]    Collect IMS Log via API and save to local machine.
    ...     :param log_dir:   TDirectory where snapshot will be collected.
    ...     :param enb_id:    ENB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param timeout:   Timeout for the operation
    enblog.collect_ims_log    log_dir=${log_dir}    bts_id=${enb_id}    timeout=${timeout}    du_id=${du_id}

Collect aashell snapshot from eNB
    [Arguments]    ${log_dir}=${OUTPUT DIR}    ${enb_id}=0  ${du_id}=${0}
    [Documentation]    Collect snapshot via API and save to local machine.
    ...     :param log_dir:   TDirectory where snapshot will be collected.
    ...     :param enb_id:    eNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]

    enblog.collect_aashell_snapshot  logs_path=${log_dir}    bts_id=${enb_id}  du_id=${du_id}

Setup eNB Btslog Collector
    [Arguments]    ${enb_id}=0  ${du_id}=0  ${common_unit_id}=0
    [Documentation]  Setup BtsLog collector - using taf.collectors
    ...              It could be called one on Suite Setup section
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: Id of DistributionUnit
    ...     :param common_unit_id: Id of CommonUnit
    enblog.setup_btslog_collector    bts_id=${enb_id}  du_id=${du_id}  common_unit_id=${common_unit_id}

Start Collecting eNB Btslog
    [Arguments]    ${enb_id}=0  ${du_id}=0  ${common_unit_id}=0
    [Documentation]  Start collecting btslog - using taf.collectors
    ...     :param gnb_id:    eNB id - related to Test Line configuration.
    ...     :param du_id: Id of DistributionUnit
    ...     :param common_unit_id: Id of CommonUnit
    enblog.start_collecting_btslog    bts_id=${enb_id}  du_id=${du_id}  common_unit_id=${common_unit_id}

Stop Collecting eNB Btslog
    [Arguments]    ${enb_id}=0  ${du_id}=${0}
    [Documentation]  Stop collecting btslog - using taf.collectors
    ...     :param gnb_id:    eNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    enblog.stop_collecting_btslog    bts_id=${enb_id}    du_id=${du_id}

Teardown eNB Btslog Collector
    [Arguments]    ${enb_id}=0  ${du_id}=0
    [Documentation]  Teardown BtsLog collector - using taf.collectors
    ...              It could be called one on Suite Setup section
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: Id of DistributionUnit
    enblog.teardown_btslog_collector    bts_id=${enb_id}  du_id=${du_id}
