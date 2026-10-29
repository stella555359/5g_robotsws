*** Settings ***
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/alarms/alarms.robot
Resource        taf/rfrl/cbts/utilities/init_variables.robot
Resource        ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource        ../../../../cloud_common_resources/mantaray/mantaray.robot
Resource        taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource        ../../../resources/common.robot
Resource        ../../../../cloud_common_resources/logs/logs.robot
Resource        taf/rfrl/cbts/robot/vdu/vdu_operations.robot

Library         taf.ul.vdu.helm.interface.helm   WITH NAME    helm
Library         taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library         Collections

Documentation
...  TEST NAME:     UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    VRF_WRO3_T01
...  *****************
...  Basic information
...  *****************
...  This test verifies intra-release software upgrade of the vDU comprising the K8s vDU application with parallel RFSW activation in one
...  single LCM operation using MantaRay. During this test case power saving feature is activated.
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  16.10.2025 - TC Creation

*** Keywords ***
UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade
    UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade:0 Test Preparation
    UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade:1 Activation Of Power Saving Features If Needed
    UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade:1 Perform NMS Upgrade With Download RU SW
    UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade:2 Final Recovery

UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    add_additional_data_to_nertc_for_wft
    mantaray.Integrate Cloud BTS with NMS Lab    nms_lab_ip=${NMS_LAB_IP}  hw_type=vDU  blue_green=${True}
    mantaray._Prepare SW on NMS lab  sw_version=${VDU_SW_VERSION}-amd64_rfsw  nms_lab_ip=${nms_lab_ip}  mo_type=MRBTS
    ${rmods}  ${deep_sleep}=  _Deside Deep Sleep Activation Based On Rf Sharing Status  connection=${admin_connection}
    ${selected_ru}=           Select Random RU From List             ru_list=${rmods}
    ${selected_ru_cells}=     Get Cells From Selected Rmod           rmod_dn=${selected_ru}         connection=${admin_connection}
    ${active_rmod_sw_build}=  Get Rmod Active Sw Version             rmod_dist_name=${selected_ru}  vdu_connection=${admin_connection}
    ${component}=             Get Rmod Active Sw Version Component   rmod_sw_build=${active_rmod_sw_build}
    ${rmod_sw_version_after_upgr}=  Get Expected Rmod Sw Build After Update  rmod_sw_build_component=${component}  vdu_sw_build=${VDU_SW_VERSION}
    ${allowed_faults}=              Create List   7104    7114
    Set Test Variable  ${allowed_faults}
    Set Test Variable  ${selected_ru}
    Set Test Variable  ${deep_sleep}
    Set Test Variable  ${selected_ru_cells}
    Set Test Variable  ${rmod_sw_version_after_upgr}
    Set Test Variable  ${active_rmod_sw_build}

UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade:1 Activation Of Power Saving Features If Needed
    Decorate Print  Step: 1 Activation Of Power Saving Features If Needed
    IF  ${deep_sleep}
        Create NRPGR For Power Saving vDU     selected_cells=${selected_ru_cells}  connection=${admin_connection}
        Set Feature Under Given Object    object_DN=MRBTS-${MRBTS}/NRBTS-${MRBTS}
        ...                               feature_flags=actNrLBPowerSaving
        ...                               value=true
        ...                               connection=${admin_connection}
        Wait Until keyword Succeeds       13min    30sec    Check Power Saving NR Vdu               cells=${selected_ru_cells}
        ...                                                                                         expected_operational_state=DISABLED
        ...                                                                                         expected_energy_saving_state=ENERGYSAVING
        ...                                                                                         connection=${admin_connection}
        Add Alarms To Watchdog            ${allowed_faults}  ${non_upgraded_cnf}
        Set Feature Under Given Object    object_DN=${selected_ru}
        ...                               feature_flags=energySavingMode
        ...                               value=DEEPSLEEP
        ...                               connection=${admin_connection}
        Wait Until keyword Succeeds       7min    30sec    Check Deep Sleep On Selected Rmod Vdu    selected_rmod=${selected_ru}
        ...                                                                                         expected_operational_state=ENABLED
        ...                                                                                         expected_deep_sleep_state=SLEEP
        ...                                                                                         connection=${admin_connection}
    END

UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade:1 Perform NMS Upgrade With Download RU SW
    Decorate Print  Step: 1 Perform NMS Upgrade With Download RU SW
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw} during test execution.
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    mantaray.Perform CNF Upgrade  nms_lab_ip=${NMS_LAB_IP}  sw_version=${VDU_SW_VERSION}-amd64  hw_type=vDU  download_ru_sw=${True}
    Wait Until Keyword Succeeds   10min  30s  VDU Pod Status Should Be Normal
    Sleep  30s
    Wait Until Keyword Succeeds   13min  30s  Check If All Cells On Air  hw_type=vDU  connection=${admin_connection}
    Start Cloud Watchdog          hw_type=${hw}  add_temporary_allowed_faults=${True}
    Delete Alarms From Watchdog    ${allowed_faults}  ${non_upgraded_cnf}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
    ${active_rmod_sw_build}=  Get Rmod Active Sw Version  rmod_dist_name=${selected_ru}  vdu_connection=${admin_connection}
    Should Be Equal  '${active_rmod_sw_build}'  '${rmod_sw_version_after_upgr}'

UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade:2 Final Recovery
    Decorate Print  Step: 2 Final Recovery
    IF  ${deep_sleep}
        Set Feature Under Given Object    object_DN=${selected_ru}
        ...                               feature_flags=energySavingMode
        ...                               value=NORMAL
        ...                               connection=${admin_connection}
        Set Feature Under Given Object    object_DN=MRBTS-${MRBTS}/NRBTS-${MRBTS}
        ...                               feature_flags=actNrLBPowerSaving
        ...                               value=false
        ...                               connection=${admin_connection}
        Delete NRPGRP Objects             connection=${admin_connection}
    END

UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Run Keyword And Ignore Error  Set Feature Under Given Object    object_DN=${selected_ru}
    ...                                                             feature_flags=energySavingMode
    ...                                                             value=NORMAL
    ...                                                             connection=${admin_connection}
    Run Keyword And Ignore Error  Set Feature Under Given Object    object_DN=MRBTS-${MRBTS}/NRBTS-${MRBTS}
    ...                                                             feature_flags=actNrLBPowerSaving
    ...                                                             value=false
    ...                                                             connection=${admin_connection}
    Run Keyword And Ignore Error  Delete NRPGRP Objects  connection=${admin_connection}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade.Test Case Teardown
    Run Keyword If Test Failed  UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade.Test Specific Teardown
    Run Keywords  common.Common Test Teardown Cloud



_Deside Deep Sleep Activation Based On Rf Sharing Status
    [Arguments]  ${connection}=${None}
    ${not_shared_rmods}  ${shared_rmods}=  Radio Modules Sharing Status  connection=${connection}
    ${deep_sleep}=  Set Variable If   ${not_shared_rmods}  ${True}  ${False}
    ${rmods}=       Set Variable If   ${not_shared_rmods}  ${not_shared_rmods}  ${shared_rmods}
    [Return]  ${rmods}  ${deep_sleep}

Get All Rmods Dist Names
    [Arguments]   ${rmods_info}
    ${rmods_dn}=  Create List
    FOR  ${key}  ${value}  IN   &{rmods_info}
        Append To List  ${rmods_dn}  ${value}
    END
    [Return]  ${rmods_dn}

Select Random RU From List
    [Arguments]  ${ru_list}
    ${selected_dict}  Evaluate  random.choice(list(${ru_list}))  random
    [Return]   ${selected_dict}
