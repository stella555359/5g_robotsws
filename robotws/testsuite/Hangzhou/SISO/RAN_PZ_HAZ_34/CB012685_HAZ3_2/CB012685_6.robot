*** Settings ***
Documentation     author: Zhang Lusha
...               contact: lusha.zhang@nokia-sbell.com
...               squad group: VRF HAZ3 2
...               feature: CB012685-C
Suite Setup       SISO Coam Suite Setup With Specify SCF    scf_suffix=_NL_CB012685_6
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012685_HAZ3_2/Resource/CB012685_resource.robot


*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
# ${if_commissioning}   False


*** Test Cases ***
General_SiSo_Commissioning_BTS_Template_Commissioning
    [Tags]    CRT_TRUNK    CRT_24R3    CRT_25R1
    [Setup]    SISO Coam Test Setup
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    SISO Coam Test Teardown

General_SiSo_Cell_block_and_unblock
    [Setup]    SISO Coam Test Setup
    General_SiSo_Cell_block_and_unblock    with_call=${False}
    Run Keyword And Ignore Error    CB012685 Throughput test
    [Teardown]    SISO Coam Test Teardown

Manual_SiSo_SM_BTS_Site_Reset
    [Setup]    SISO Coam Test Setup
    General_SiSo_Auto_BTS_site_reset
    # CB012685 Throughput test
    [Teardown]    SISO Coam Test Teardown

General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Setup]    SISO Coam Test Setup
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Teardown]    SISO Coam Test Teardown

General_SiSo_RU_module_reset_from_GUI
    [Setup]    SISO Coam Test Setup
    General_SiSo_RF_module_reset_from_GUI    with_call=False
    Run Keyword And Ignore Error    CB012685 Throughput test
    [Teardown]    SISO Coam Test Teardown

General_SiSo_Online_Cell_Addition_Deletion
    [Setup]    SISO Coam Test Setup
    Online Cell addition deletion    addition_deletion_cell=1
    [Teardown]    SISO Coam Test Teardown
