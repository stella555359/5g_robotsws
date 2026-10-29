*** Settings ***
Documentation
...   author: Lukasz Klosinski
...   contact: lukasz.klosinski@nokia.com
...   Test suite for basic UUF OAM Tests in loop:
...   - perform oam stress test,
...   - gather logs: snapshot, syslog,
...   - check HW state, faults, crashes in syslog,
...   - if iteration is failed it will try to recover BTS by performing site reset.
...   In order to run on NON UTE Line with reporting few Test Variables need to be provided.
...   There are 2 Mandatory Parameters
...   ${label}= Reporting Portal Test Line Type Parameter in format <TEAM_ID>_<SMOD>_<BBMOD>_<RMOD>  i.e. WRO8_E2E_ASIK_3xABIL_6xAEQN
...   ${hostname}=  Reporting Portal Test Line Parameter  unique test line ID with reporting portal prefix 5G_<Location> e.g.
...   5G_Wroclaw_PZ2_WRO8_E2E_50845
...   To Run SW Upgrade Test, BTS should be OnAir with given source SW on active partition.
...   SW Package file is by default taken from external drive, if it is not present there it will be download to that
...   drive. To prevent external storage mount flag ${use_builds_storage} need to be set to ${False}, then file
...   will be downloaded to VM on which test is executed.
...   To restore target software build at the end of the test flag ${restore_to_target_sw} need to be set to ${True}
...   In case test packages T1 T2 should be used during update ${use_test_packages} need to be set to ${True}
...
...    Parameters Description
...    Mandatory parameter:
...    test_iteration= Number of test iteration which should be performed
...
...    Mandatory Non UTE Parameters:
...    label= Reporting Portal Test Line Type Parameter in format <TEAM_ID>_<SMOD>_<BBMOD>_<RMOD>  i.e. WRO8_E2E_ASIK_3xABIL_6xAEQN
...    hostname=Reporting Portal Test Line Parameter unique test line ID with reporting portal prefix 5G_<Location>
...    e.g. 5G_Wroclaw_PZ2_WRO8_E2E_50845
...    remote_mplane= Should Be filled if any action like log collection or SW update should be executed on Remote Node
...    remote_vm_ip= Should Be filled if any action like log collection or SW update should be executed on Remote Node
...
...    Optional Common parameters:
...    custom_alarms= Additional Custom Allowed alarms, it should be provided either as List of Fault IDs in
...    Robot Framework list format or as list of watchdog Alarm objects.
...    i.e. custom_alarms= @{7307, 62003, 1898, 7115} or by earlier defined Global Variables like in Example Suite
...    with at least 2 white spaces between each of values.
...    critical_faults= List of faults IDs, if any of given fault's appears during test, test case will be stopped
...    without any recovery action. List Should be provided in Robot Framework Format similar like custom alarms
...    should_be_reported= Flag for turning on reporting to Reporting Portal, by default it is set to True
...    customers_list=List of Customers for Given TL i.e  SKT  KT  TMO US, if no specific customer is set to TL then it
...    should be set to Generic. List Should be provided in Robot Framework Format List similar like custom alarms
...
...    SW Update Test Specific parameters:
...    5g_source_sw=5G Source SW
...    5g_target_sw= 5G Target SW
...    5g_target_sw_path= Path to file with 5G Target SW if set to None, file with target SW will be downloaded
...    4g_source_sw= 4G Source SW
...    4g_target_sw= 4G Target SW
...    4g_target_sw_path= Path to file with 4G Target SW if set to None, file with target SW will be downloaded
...    use_builds_storage= Flag to determine if SW external storage should be mounted if set to False then SW package
...    will be downloaded to VM to Downloads directory, by default set to True
...    restore_to_target_sw= Flag to determine if Target SW should be downloaded to BTS after SW Update test by default set to True
...    remote_node_update= Flag to determine if SW upgrade test should be perform on Remote Node
...    restore_to_target_sw= Flag to determine if Target SW should be downloaded to BTS after SW Update test by default set to True
...    use_test_packages = Flag to determine if test packages T1 and T2 should be used durign SW Update test by default set to False.
...
...    Delta Commissioning Test Specific parameters:
...    delta_file= path to delta file or delta in json format with proper delta plan based on test case
...    (with online parameter modification or modified parameters to cause proper action i.e., Site Reset or specific rat reset).



Resource        testsuite/Paris/UUF/ST/UUF4All/resources/uuf_rfrl_common_keywords.robot

*** Keywords ***
UUF4ALL_SITE_RESET_TEST
    [Documentation]
    ...   author: Lukasz Klosinski
    ...   contact: lukasz.klosinski@nokia.com
    ...   Keyword for basic UUF site reset in loop:
    ...   - add proper HWF base on current sw flag to swconfig file,
    ...   - perform site reset of BTS,
    ...   - gather logs: snapshot, syslog,
    ...   - check HW state, faults, crashes in syslog,
    ...   - if iteration is failed it will try to recover BTS by performing site reset.

    [Arguments]  ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${True}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}
    ...          ${attach_test_keyword}=${None}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.UUF Site Reset Test Setup
    uuf_rfrl_common_keywords.Attach Test Setup  ${attach_test_keyword}
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}
    ...  ${should_be_reported}  uuf_rfrl_common_keywords.Reset Site Test
    [Teardown]  uuf_rfrl_common_keywords.UUF Site Reset Test Teardown


UUF4ALL_SW_UPGRADE_TEST
    [Documentation]
    ...   author: Lukasz Klosinski
    ...   contact: lukasz.klosinski@nokia.com
    ...   Keyword for basic UUF Upgrade in loop:
    ...   - perform update to target SW and rollback to source SW,
    ...   - check HW state, faults, crashes in syslog,
    ...   - gather logs: snapshot, syslog,

    [Arguments]  ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${True}
    ...          ${customers_list}=@{EMPTY}
    ...          ${5g_source_sw}=${None}
    ...          ${5g_target_sw}=${None}
    ...          ${5g_target_sw_path}=${None}
    ...          ${4g_source_sw}=${None}
    ...          ${4g_target_sw}=${None}
    ...          ${4g_target_sw_path}=${None}
    ...          ${use_test_packages}=${False}
    ...          ${use_builds_storage}=${True}
    ...          ${restore_to_target_sw}=${False}
    ...          ${remote_node_update}=${False}
    ...          ${use_remote_node}=${True}
    ...          ${download_path}=${None}
    ...          ${local_node_attach_test_keyword}=${None}
    ...          ${remote_node_attach_test_keyword}=${None}


    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.Update Rollback Test Setup  ${5g_source_sw}  ${5g_target_sw}  ${5g_target_sw_path}
    ...  ${4g_source_sw}  ${4g_target_sw}  ${4g_target_sw_path}  ${use_builds_storage}  ${remote_node_update}
    ...  ${download_path}  ${use_test_packages}
    Attach Test Setup   ${local_node_attach_test_keyword}  ${remote_node_attach_test_keyword}
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}
    ...  ${should_be_reported}  uuf_rfrl_common_keywords.Upgrade Test
    [Teardown]  Run Keywords  Run Keyword If  ${restore_to_target_sw}  uuf_rfrl_common_keywords.Restore To Target SW
    ...  AND  Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin  AND
    ...  uuf_rfrl_common.Log Update Results



OAM_RMOD_RESET
    [Arguments]  ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}
    ...          ${attach_test_keyword}=${None}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.RMOD Test Setup
    uuf_rfrl_common_keywords.Attach Test Setup  ${attach_test_keyword}
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  False
    ...  uuf_rfrl_common_keywords.Reset RMOD Test
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

OAM_NRCEL_LOCK
    [Arguments]  ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.Lock Cells Test Setup  NR
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  False
    ...  uuf_rfrl_common_keywords.Lock Unlock NRCells Test
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

OAM_LNCEL_LOCK
    [Arguments]  ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.Lock Cells Test Setup  LTE
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  False
    ...  uuf_rfrl_common_keywords.Lock Unlock LNCells Test
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

OAM_BBMOD_RESET
    [Arguments]  ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}
    ...          ${attach_test_keyword}=${None}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.BBMOD Reset Test Setup
    uuf_rfrl_common_keywords.Attach Test Setup  ${attach_test_keyword}
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  False
    ...  uuf_rfrl_common_keywords.Reset BBMOD Test
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

OAM_LNCEL_BLOCK
    [Arguments]  ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.Block Cells Test Setup  LNCEL
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  False
    ...  uuf_rfrl_common_keywords.Block Unblock Cells Test
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

OAM_NRCEL_BLOCK
    [Arguments]  ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.Block Cells Test Setup  NRCEL
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  False
    ...  uuf_rfrl_common_keywords.Block Unblock Cells Test
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

OAM_GNCEL_BLOCK
    [Arguments]  ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.Block Cells Test Setup  GNCEL
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  False
    ...  uuf_rfrl_common_keywords.Block Unblock Cells Test
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

OAM_WNCEL_BLOCK
    [Arguments]  ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.Block Cells Test Setup  WNCEL
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  False
    ...  uuf_rfrl_common_keywords.Block Unblock Cells Test
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION

    [Arguments]  ${delta_file}=${None}
    ...          ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.Delta Commissioning Test Setup  ${delta_file}  ${False}  ${None}
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  False
    ...  uuf_rfrl_common_keywords.Delta Commissioning Without Site Reset
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED

    [Arguments]  ${delta_file}=${None}
    ...          ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.Delta Commissioning Test Setup  ${delta_file}  ${True}  ${None}
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  False
    ...  uuf_rfrl_common_keywords.Delta Commissioning With Site Reset
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

DELTA_COMMISSIONING_WITH_GSM_RAT_RESET

    [Arguments]  ${delta_file}=${None}
    ...          ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.Delta Commissioning Test Setup  ${delta_file}  ${False}  GSM
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  False
    ...  uuf_rfrl_common_keywords.Delta Commissioning With Rat Reset
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

DELTA_COMMISSIONING_WITH_WCDMA_RAT_RESET

    [Arguments]  ${delta_file}=${None}
    ...          ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.Delta Commissioning Test Setup  ${delta_file}  ${False}  WCDMA
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  False
    ...  uuf_rfrl_common_keywords.Delta Commissioning With Rat Reset
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

DELTA_COMMISSIONING_WITH_LTE_RAT_RESET

    [Arguments]  ${delta_file}=${None}
    ...          ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.Delta Commissioning Test Setup  ${delta_file}  ${False}  LTE
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  False
    ...  uuf_rfrl_common_keywords.Delta Commissioning With Rat Reset
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

DELTA_COMMISSIONING_WITH_NR_RAT_RESET

    [Arguments]  ${delta_file}=${None}
    ...          ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    uuf_rfrl_common_keywords.Delta Commissioning Test Setup  ${delta_file}  ${False}  NR
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  False
    ...  uuf_rfrl_common_keywords.Delta Commissioning With Rat Reset
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown
