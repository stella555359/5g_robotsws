*** Settings ***
Documentation
...  This TC is performing software update twice. First update is with independent radio units update and kpi 55 (first cell down to last cell up)
...  is calculated after SBTS is up. In this case CPRI and eCPRI RUs will reset, Obsai RUs will not.
...  Then classic software update is performed and kpi 57 (first cell down to last cell up) is determined. TC checks if software operation is
...  Inter/intra release and with/without firmware update to determine kpi57 id (a/b/c/d).

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${TARGET_SW_NAME}  ${None}  # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}  /home/ute/btsauto/TARGET_SW  # Directory in which TC should look for sw package. If not given,
# '/home/ute/btsauto/TARGET_SW' shall be used
${SW_UPDATE_TIMEOUT}  5400  # Given in seconds; That is a timeout for SW download and activation (without reset)
${PING_LOSS_TIMEOUT}  240  # Timeout for ping loss during reset
${PING_REGAIN_TIMEOUT}  600  # Timeout for ping regain during reset
${RU_RESTORE_TIMEOUT}  600
${SBTS_RESTORE_TIMEOUT}  1200


*** Keywords ***
TC__KPI__Independent_RU_SW_Upgrade
    [Documentation]
    ...  [CASE LINK]: https://jiradc.int.net.nokia.com/browse/TAT-28304
    ...
    ...  ******************
    ...  28.10.2024 - https://jiradc.int.net.nokia.com/browse/TAT-28304 - Initial creation
    ...  13.01.2025 - https://jiradc.int.net.nokia.com/browse/TAT-28610 - Add variable for RU restore timeout
    ...  15.01.2025 - https://jiradc.int.net.nokia.com/browse/TAT-28618 - Improve RMOD check after RU SWR
    ...  17.01.2025 - https://jiradc.int.net.nokia.com/browse/TAT-28624 - Calculate kpi55 for each RU in reset
    ...  27.01.2025 - https://jiradc.int.net.nokia.com/browse/TAT-28668 - Fix kpi55 overriding
    ...  29.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29154 - Improve RU reset check
    ...  30.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30067 - Add kpi57e(with kpi57a) and kpi57f(with kpi57b) calculation
    ...  30.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30068 - Add kpi57g(with kpi57c) and kpi57h(with kpi57d) calculation
    ...  05.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30160 - Refactor kpi57 suite variables
    ...  11.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30592 - Add kpi58 calculation
    ...  *******************

    Set Tags  CA-KPI  OWNER-oana.badea@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-CB010780

    Step1: Find Path To SW Package
    Step2: Check SW Versions
    Step3: SW Update With Independent RU
    Step4: Wait For SBTS To Reach On Air State
    Step5: Calculate Kpi 55
    Step6: SW Update For Whole SBTS
    Step7: Wait For SBTS To Reach On Air State
    Step8: Calculate Kpi 57


Step1: Find Path To SW Package
    Log  \nStep1: Find path to SW package  console=true
    ${target_sw_path}  Get SW File For SWDL  ${TARGET_SW_DIR}  ${TARGET_SW_NAME}
    Set Test Variable  ${TARGET_SW_PATH}
    Log  Chosen software package is: ${TARGET_SW_PATH}  console=true
    Set RMODs In Reset
    Create KPI55 Results Variable


Step2: Check SW Versions
    Log  \nStep2: Check SW versions  console=true
    ${active_sw}  Infomodel Get Active SW Version  module=MSM  im_param=activeBuildDescriptorId
    ${passive_sw}  Infomodel Get Passive SW Version  module=MSM  im_param=passiveBuildDescriptorId
    Log  Active software package is: ${active_sw}  console=true
    Log  Passive software package is: ${passive_sw}  console=true
    ${active_sw_build}  Remove String Using Regexp  ${active_sw}  SBTS[0-9|A-Z]+_
    Should Not Contain  ${TARGET_SW_NAME}  ${active_sw_build}  Active software is the same as target software version.


Step3: SW Update With Independent RU
    Log  \nStep3: SW Update With Independent RU  console=true
    #Setup admin  ${OAM_BTS_IP}  name=rmod_check
    #${backgorund_tasks}  Create List
    #FOR  ${rmod_id}  IN  @{RMODS_ID_SN_IN_RESET}
    #  ${rmod_check}  Run Keyword In Background  Assert_  RMOD  ${rmod_id}  operationalState=${DISABLED}  timeout=3600  connection=rmod_check
    #  Append To List  ${backgorund_tasks}  ${rmod_check}
    #END

    coam.Update Software  ${TARGET_SW_PATH}  timeout=${SW_UPDATE_TIMEOUT}  independent_sw_update_type=RuSwOnly
    Log  RU SWR done.  console=true
# Temporary disable RMOD check.
    #FOR  ${task}  IN  @{backgorund_tasks}
    #  ${rmod_reset}  Collect Keyword Result  ${task}  timeout=3600
    #  IF  ${rmod_reset}  Log  RMOD reset successfully.[OK]  console=true  ELSE  Fail  RMODs did not reset during SWR-RuSwOnly.
    #END
    #[Teardown]  Teardown Admin  rmod_check


Step4: Wait For SBTS To Reach On Air State
    Log  \nStep4: Wait For SBTS To Reach On Air State  console=true
    Wait Until Keyword Succeeds  ${SBTS_RESTORE_TIMEOUT}  60
    ...  Admin Check All Required State
    IF  ${SCF_COUNT_NR}  Wait Until Keyword Succeeds  300  30  Check X2 And NG Links To Be Working
    ${active_ru_package}  Create list  activeRUPackageVersion
    ${rmods_params}  Get Parameter By Class  RMOD_R  ${active_ru_package}
    FOR  ${rmod_param}  IN  @{rmods_params}
        ${active_sw_build}  Remove String Using Regexp  ${rmod_param}[parameters][activeRUPackageVersion]  SBTS[0-9|A-Z]+_
        Should Contain  ${TARGET_SW_NAME}  ${active_sw_build}  Active software on ${rmod_param}[distName] is not the same as target software version.
    END


Step5: Calculate Kpi 55
    Log  \nStep5: Calculate Kpi 55  console=true
    Collect Infomodel Log From Current Session  ${BTS_FILES}/IM/InfoModel_log_ru_sw_only.ims2  leave_disconnect_logs=True
    Reset Admin
    FOR  ${rmod_id}  IN  @{RMODS_ID_SN_IN_RESET}
        ${cells_on_rmod}  Get Cell Mapping By Module Id  ${rmod_id}
        ${kpi_55a}  Calculate Kpi55a  ${BTS_FILES}/IM/InfoModel_log_ru_sw_only.ims2  cell_dist_names=${cells_on_rmod}
        ${deltas}  oam_kpi.Get All Deltas  kpi55a  skip_none=True
        ${rmod_serial_number}  Get From Dictionary  ${RMODS_ID_SN_IN_RESET}  ${rmod_id}
        Log  RMOD ${rmod_serial_number}:  console=true
        Log  kpi55a delta is: ${kpi_55a}[kpi55a][-1][delta] and converted in seconds: ${deltas}[-1].\n  console=true
        ${kpi55_values}  Copy List  ${KPI55_RESULTS}[RMOD-${rmod_serial_number}]
        Append To List  ${kpi55_values}  ${deltas}[-1]
        Set To Dictionary  ${KPI55_RESULTS}  RMOD-${rmod_serial_number}=${kpi55_values}
    END
    Save Delta Results  kpi55a  ${KPI55_RESULTS}


Step6: SW Update For Whole SBTS
    Log  \nStep6: SW Update For Whole SBTS  console=true
    Set Variables For Linux Software And Software Update Type
    coam.Update Software  ${TARGET_SW_PATH}  timeout=${SW_UPDATE_TIMEOUT}
    Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_LOSS_TIMEOUT}
    Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_REGAIN_TIMEOUT}
    Check If Target Is Stable  ${OAM_BTS_IP}  min_uptime=60  max_downtime=0  timeout=70

    Collect Infomodel Log From Current Session  ${BTS_FILES}/IM/InfoModel_log_until_swr_reset.ims2  leave_disconnect_logs=True
    Reset Admin


Step7: Wait For SBTS To Reach On Air State
    Log  \nStep7: Wait For SBTS To Reach On Air State  console=true
    Check Alarm GPS Receiver Alarm: Firmware Upgrade Ongoing
    Wait Until Keyword Succeeds  ${SBTS_RESTORE_TIMEOUT}  30  Admin Check All Required State
    IF  ${SCF_COUNT_NR}  Wait Until Keyword Succeeds  300  30  Check X2 And NG Links To Be Working
    ${active_sw}  Infomodel Get Active SW Version  module=MSM  im_param=activeBuildDescriptorId
    ${passive_sw}  Infomodel Get Passive SW Version  module=MSM  im_param=passiveBuildDescriptorId
    Log  Active software package is: ${active_sw}  console=true
    Log  Passive software package is: ${passive_sw}  console=true
    ${active_sw_build}  Remove String Using Regexp  ${active_sw}  SBTS[0-9|A-Z]+_
    Should Contain  ${TARGET_SW_NAME}  ${active_sw_build}  Active software is not the same as target software version.


Step8: Calculate Kpi 57
    Log  \nStep8: Calculate Kpi 57  console=true
    Collect Infomodel Log From Current Session  ${BTS_FILES}/IM/InfoModel_log_after_swr_reset.ims2  leave_disconnect_logs=True
    ${kpi_dictionary}  Create dictionary  57a=57e  57b=57f  57c=57g  57d=57h
    ${kpi_id}  Get KPI57 Id
    Set Suite Variable  ${SW_ACTIVATION_DOWNTIME_KPI_57}  kpi${kpi_id}
    Set Suite Variable  ${SWR_LAST_CELL_DOWN_FIRST_CELL_UP_KPI_57}  kpi${kpi_dictionary}[${kpi_id}]

    ${ims_list}  Create List  ${BTS_FILES}/IM/InfoModel_log_until_swr_reset.ims2  ${BTS_FILES}/IM/InfoModel_log_after_swr_reset.ims2
    ${kpis_to_be_calculated}  Create List  ${SW_ACTIVATION_DOWNTIME_KPI_57}  ${SWR_LAST_CELL_DOWN_FIRST_CELL_UP_KPI_57}  kpi58
    ${kpi_57_58}  Calculate Kpis  ${kpis_to_be_calculated}  ${ims_list}
    FOR  ${kpi}  IN  @{kpis_to_be_calculated}
        Log Delta In Seconds  ${kpi_57_58}[${kpi}][-1][delta]  ${kpi}
        Save Delta Results  ${kpi}
    END


Set RMODs In Reset
    ${rmods_id_sn_in_reset}  Create Dictionary
    ${rmods_params}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods_params}
        IF  'RP301_RP1' in '${rmod}[l3Protocol]'  CONTINUE
        Set To Dictionary  ${rmods_id_sn_in_reset}  ${rmod}[id]=${rmod}[serialNumber]
    END
    Set Test Variable  ${RMODS_ID_SN_IN_RESET}


Create KPI55 Results Variable
    ${kpi55_results_exists}  Run Keyword And Return Status  Variable Should Exist  ${KPI55_RESULTS}
    Return From Keyword If  ${kpi55_results_exists}
    ${KPI55_RESULTS}  Create Dictionary
    ${empty_list}  Create List
    FOR  ${rmod_id}  IN  @{RMODS_ID_SN_IN_RESET}
        Set To Dictionary  ${KPI55_RESULTS}  RMOD-${RMODS_ID_SN_IN_RESET}[${rmod_id}]=${empty_list}
    END
    Set Suite Variable  ${KPI55_RESULTS}


Get KPI57 Id
    ${linux_sw_version_after_sw_update}  Get Embedded Linux Software Version
    ${update_with_firmware}  Set Variable If  '${linux_sw_version_after_sw_update}'=='${LINUX_SW_VERSION_BEFORE_SW_UPDATE}'  no  yes

    ${kpi57_id}  Set Variable If  '${SW_UPDATE_TYPE}'=='inter' and '${update_with_firmware}'=='no'  57a
    ...  '${SW_UPDATE_TYPE}'=='inter' and '${update_with_firmware}'=='yes'  57b
    ...  '${SW_UPDATE_TYPE}'=='intra' and '${update_with_firmware}'=='no'  57c
    ...  57d

    [Return]  ${kpi57_id}


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}


TC Teardown
    Common Test Teardown
    Set Log Level  TRACE
