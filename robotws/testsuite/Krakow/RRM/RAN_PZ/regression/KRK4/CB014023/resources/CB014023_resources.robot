*** Settings ***

Documentation
...   author: Przemyslaw Herian
...   maintainer:
...   contact:
...   description: Setups and Teardowns for CB014023

Library    BuiltIn
Library    OperatingSystem

Library    ute_wtssim
Library    ta5g_enb
Library    ta5g_egate
Library    ta5g_pm_counters
Library    ute_fsmaccess

Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_wts    WITH NAME    common_wts
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_gnb    WITH NAME    common_gnb
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB014023.resources.env_resources.EnvResources    WITH NAME    _env
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB014023.resources.logs_collection.LogsCollectorWrapper    WITH NAME    _logs
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB014023.resources.wts_resources.WtsSetup        WITH NAME    _wts_cfg
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB014023.resources.validation.Validation        WITH NAME    _val
Library    taf.rfrl.common_resources.reporting_portal.bts_metadata
Library    taf/rfrl/procedures/resources/python/setups_and_teardowns_keywords.py

Variables  variables.py

*** Keywords ***
Suite Setup
    Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}
    _logs.Collect Default SCFs
    _logs.Collect Default Iphy
    _env.Add IPs
    _env.create_link_to_wts

Test Setup
    [Arguments]    ${reboot}=${False}
    _logs.Create Test Log Directory
    common_gnb.Wait For All Radio Modules To Be Online
    Wait Until Keyword Succeeds     300 sec     10 sec    _env.Perform Iphy Reconfiguration
    _env.Update Vlan ID In SCF
    _env.Perform SCF Commissioning    ${scf_RAN_sharing}
    common_gnb.Wait For All Radio Modules To Be Online
    _wts_cfg.Setup WTS Environment
    ...    allow_first_reboot=${reboot}

Test Teardown
    common_wts.Stop WTS And Clear
    Wait Until Keyword Succeeds     300 sec     10 sec    _env.Restore Default Iphy
    _env.Restore Default SCFs
