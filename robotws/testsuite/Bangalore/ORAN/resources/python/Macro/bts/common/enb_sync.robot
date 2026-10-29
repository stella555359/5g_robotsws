*** Settings ***

Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.sync.EnbSync    WITH NAME      enbsync



*** Keywords ***
Verify eNB Sync Status
    [Arguments]    ${enb_id}=0    ${sync_source}=1pps/ToD from external GNSS receiver    ${timeout}=60    ${du_id}=${0}
    [Documentation]    Check synchronization source and if it is working.
    ...     :param enb_id:    ENB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param sync_source:    Type of synchronization source - related to Test Line configuration e.g. "1pps/ToD from external GNSS receiver",
    ...                            "1pps/ToD from Sync Hub Master",default set to "1pps/ToD from Sync Hub Master".
    ...     :param timeout:    Timeout for the operation
    enbsync.verify_bts_sync_status    bts_id=${enb_id}    sync_source=${sync_source}    timeout=${timeout}
    ...    du_id=${du_id}
