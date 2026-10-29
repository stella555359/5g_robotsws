*** Settings ***
Documentation     author: Zhang Lusha
...               contact: lusha.zhang@nokia-sbell.com
...               squad group: MMW_02
...               feature: CB006915-H US#8.1 16S-6CC-8D8U, BW mixed
Suite Setup       SISO Coam Suite Setup With Specify SCF    scf_suffix=_6CC_8D8U
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006915/Resource/CB006915_resource.robot



*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
# ${if_commissioning}   False
${if_commissioning}   True
${ultp}    50
${dltp}    300


*** Test Cases ***
[1][3.0] General_SiSo_Online_Cell_Addition_Deletion
    [Tags]    CRT_TRUNK    CRT_24R3    CRT_25R1
    [Setup]    SISO Coam Test Setup
    CB006915 Start Syslog
    Online Cell addition deletion    addition_deletion_cell=1
    # General_SiSo_Commissioning_BTS_Template_Commissioning
    CB006915 Stop Syslog And Check ERR WRN
    [Teardown]    SISO Coam Test Teardown

[2][2.0] General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_TRUNK    CRT_24R3    CRT_25R1
    [Setup]    SISO Coam Test Setup
    CB006915 Start Syslog
    General_SiSo_Cell_block_and_unblock    with_call=${False}
    # Do_L3call_with_data_transfer_tp_check_from_gnb    ul_tp=50M  dl_tp=300M  protocol=udp  traffic_duration=900
    #     ...    ul_tp_target=35  dl_tp_target=150  check_duration=5m
    CB006915 Stop Syslog And Check ERR WRN
    [Teardown]    Run Keyword And Ignore Error    SISO Coam Test Teardown

[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Tags]    CRT_TRUNK    CRT_24R3    CRT_25R1
    [Setup]    SISO Coam Test Setup
    ${ue_index_list}    create list    ${0, 1}
    ${list_of_cell_ids}    Create List    189775873    189775874    189775875    189775878    189775879    189775880
    CB006915 Start Syslog
    # Data Transfer DL UL    ue_index=${ue_index_list}    ul_throughput=50M    dl_throughput=1G
    # ...    list_of_cell_ids=${list_of_cell_ids}
    CB006915 Stop Syslog And Check ERR WRN
    [Teardown]    SISO Coam Test Teardown

[2][1.0] CB006915-SR-A_check_FID1868_when_configuration_exceeds_BB_cellset_capacity
    [Tags]    CRT_TRUNK    CRT_24R3    CRT_25R1
    [Setup]    SISO Coam Test Setup
    CB006915 Start Syslog
    Online Cell addition deletion    addition_deletion_cell=1
    # General_SiSo_Commissioning_BTS_Template_Commissioning
    CB006915 Stop Syslog And Check ERR WRN
    [Teardown]    SISO Coam Test Teardown

[1][2.0] General_SiSo_RU_module_reset_from_GUI
    [Tags]    CRT_TRUNK    CRT_24R3    CRT_25R1
    [Setup]    SISO Coam Test Setup
    CB006915 Start Syslog
    General_SiSo_RF_module_reset_from_GUI    with_call=False
    CB006915 Stop Syslog And Check ERR WRN
    [Teardown]    SISO Coam Test Teardown

[1][3.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CRT_TRUNK    CRT_24R3    CRT_25R1
    [Setup]    SISO Coam Test Setup
    CB006915 Start Syslog
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    CB006915 Stop Syslog And Check ERR WRN
    [Teardown]    SISO Coam Test Teardown

*** Keywords ***
