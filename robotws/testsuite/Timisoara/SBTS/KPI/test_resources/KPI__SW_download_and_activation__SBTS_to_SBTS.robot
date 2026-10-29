*** Settings ***
Documentation
    ...  TC for SW download and activation. There are optional parameters:
    ...  1. Target SW name - SW package name. If not given, TC will choose newest package in a directory
    ...  2. Target SW dir - Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
    ...  3. SW Update Timeout - Given in seconds; That is a timeout for SW download and Activation (probably without reset - will be clarified)
    ...  4. onAir Check Number - Number of checks for proceduralStatus: onAir (probably since the reset beginning); check interval = 10s

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${TARGET_SW_NAME}  ${None}  # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}  /home/ute/btsauto/TARGET_SW  # Directory in which TC should look for sw package. If not given,
# '/home/ute/btsauto/TARGET_SW' shall be used
${SW_UPDATE_TIMEOUT}  5400  # Given in seconds; That is a timeout for SW download and activation
# (without reset)
${PING_LOSS_TIMEOUT}  240  # Timeout for ping loss during reset
${PING_REGAIN_TIMEOUT}  600  # Timeout for ping regain during reset
${ON_AIR_CHECK_NUMBER}  60  # Number of checks for proceduralStatus:
# onAir (probably since the reset beginning); check interval = 10s
${FIRST_CELL_ON_AIR_TIMEOUT}  15  # Time to wait for first cell on Air (in minutes)
${TEST_TIMEOUT}  90  # Test timeout (in minutes)
${MAKE_ADDITIONAL_CHECKS}  ${FALSE}  # Set TRUE if additional check of BTS (cells, modules, alarms)
# should be taken at the end of TC
# Check is performed to ensure that BTS is onAir for some period of time
${ADDITIONAL_CHECKS_NUMBER}  5  # Number of checks which have to be perform to ensure that bts is onAir
${SLEEP_INTERVAL}  1 min  # Time interval between additional checks, if given in minutes,
# time unit must be added
${PASS_IF_SW_EXISTS}  ${False}  # Set True if the test must finish as PASSED when the requested SW is installed yet
${LOG_KP_IS}  ${TRUE}  # Parameter created to turn off KPIs logging on demand
${EXPECTED_BTS_STATUS}  OnAir  # Expected BTS state before TC starts
${EXPECTED_BTS_STATUS_AFTER_SWDL}  OnAir  # Expected BTS state after SW download and activation,
# can be list of values separeted by commas (no spaces) e.g. OnAir,Degraded
${HARDWARE_CHECK_AFTER_UPDATE}  10  # [min] Time to wait for hardware to have expected states
${INFOMODEL_TIMEOUT}  20  # Time to connect to infomodel
${CALCULATE_KPI}  ${True}
${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}  ${False}


*** Keywords ***
TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Documentation]
    ...
    ...  *********************
    ...  3. History of changes
    ...  *********************
    ...
    ...  10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24073 - Log delta to console
    ...  11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24107 - Save delta in json file after every TC
    ...  18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24126 - Remove hran_wft and hran_logging libraries
    ...  16.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24317 - Refactor KPI TCs and resources to use KWs from ca_SBTS_general
    ...  14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  24.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25034 - Inrease timeout for Check if target is stable
    ...  13.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25539 - Add option for activating graceful cell shutdown before reset
    ...  06.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25685 - Reset admin connection after SWR
    ...  07.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25718 - Reset infomodel connection after SWR
    ...  09.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25927 - Update TC to work with kpi2a and kpi2c
    ...  15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26612 - Add kpi2b and kpi2d for reporting
    ...  11.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27096 - Change modules and cells check
    ...  03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27599 - Check alarm GPS receiver alarm: firmware upgrade ongoing
    ...  27.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28145 - Check if C-Plane checkpoints are visible in snapshot
    ...  24.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28291 - Check CP checkpoints starting from 25R1
    ...  12.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28375 - Add gNb type verification for checkpoints
    ...  04.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28492 - Add admin_api_log_dir for second admin connection
    ...  19.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28565 - Use only one admin connection
    ...  08.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29534 - Add kpi2i and kpi2j
    ...  03.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30065 - Add kpi2o and kpi2p
    ...  05.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30160 - Refactor kpi2 suite variables
    ...
    ...  **********************
    ...  4. Test case flowchart
    ...  **********************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4072.png#
    [Timeout]  ${TEST_TIMEOUT} minutes

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-sebastian.burniak@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS17  SW-SBTS18  SW-SBTS19  SW-SBTS22  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923
    ...  FEATURE-RP001486_RP000923  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923  FEATURE-CB012999

    Step1: Find Path To SW Package
    Step2: Check SW Versions
    Step3: SW Update
    Step4: Check BTS State
    Step5: Check SW Versions
    Step6: Check If All Cells OnAir
    Step7: Check Active Alarms


Step${number_step}: Check SW Versions
    Log  Step${number_step}: Check SW versions  console=true
    IF  '${number_step}'!='2'
        Wait Until Keyword Succeeds  ${INFOMODEL_TIMEOUT} min  30 sec  Fail If Connection To Infomodel Is Not Available
    END
    Check SW Version  ${number_step}  ${PASS_IF_SW_EXISTS}
    IF  '${number_step}'=='2'
        Run Keyword And Ignore Error  Change And Collect SCF
    END


Step1: Find Path To SW Package
    Log  Step1: Find path to SW package  console=true
    Find Path To SW Package
    IF  '${TARGET_SW_PATH}'== ${None}  Fail


Step3: SW Update
    Log  Step3: SW update  console=true

    Set Variables For Linux Software And Software Update Type

    IF  ${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}
        Activate Or Deactivate Graceful Cell Shutdown  enableGrflShdn_new_value=Enabled  actGrflShdn_new_value=true
    ELSE
        Activate Or Deactivate Graceful Cell Shutdown  enableGrflShdn_new_value=Disabled  actGrflShdn_new_value=false
    END
    Log  Will now perform software update  console=true
    ${software_update_start}  Get Current Date
    ${sw_update_result}  ${sw_update_msg}  Run Keyword And Ignore Error
    ...  coam.Update Software  ${TARGET_SW_PATH}  True  ${SW_UPDATE_TIMEOUT}
    ${software_update_end}  Get Current Date
    IF  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${sw_update_msg}
    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_LOSS_TIMEOUT}
    IF  ${ping_loss_status}==${FALSE}
        Log  BTS RESET after successful sw update DID NOT OCCUR  console=true
    ELSE
        Log  BTS is resetting after successful sw update  console=true
    END
    ${ping_loss}  Get Current Date
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_REGAIN_TIMEOUT}
    IF  ${ping_regain_status}==${False}  Set Test Failed  Ping has not been regained within timeout
    ${ping_regain}  Get Current Date
    ${ping_stable_status}  Run Keyword And Return Status
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=60  max_downtime=0  timeout=70
    IF  ${ping_stable_status}==${False}  Set Test Failed  Ping has not been available for 60 seconds

    Collect Infomodel Log From Current Session  ${BTS_FILES}/IM/InfoModel_log_from_current_session_until_reset.ims2
    Reset Admin
    Set Test Variable  ${SOFTWARE_UPDATE_START}
    Set Test Variable  ${SOFTWARE_UPDATE_END}
    Set Test Variable  ${PING_LOSS}
    Set Test Variable  ${PING_REGAIN}
    Wait Until Keyword Succeeds  5 min  30 sec  Fail If Connection With Admin Is Not Available


Step4: Check BTS State
    Log  Step4: Check BTS state  console=true
    Check Alarm GPS Receiver Alarm: Firmware Upgrade Ongoing
    Log  Will now wait for first cell onAir  console=true
    Wait Until Keyword Succeeds  ${FIRST_CELL_ON_AIR_TIMEOUT} min  30 sec  Check If Any Cell Is OnAir
    ${first_cell_onair}  Get Current Date
    Set Test Variable  ${FIRST_CELL_ONAIR}
    Log  Will now check if SMODs and RMODs are in expected states:${\n}SMODs:${SMOD_EXPECTED_STATES}${\n}RMODs:${RMOD_EXPECTED_STATES}
    ...  console=true
    Wait Until Keyword Succeeds  ${HARDWARE_CHECK_AFTER_UPDATE} min  30 sec  Check System Modules And Radio Modules
    ${expected_bts_status_after_swdl}  Split String  ${EXPECTED_BTS_STATUS_AFTER_SWDL}  separator=,  max_split=-1
    ${log_message}  Catenate  Will now check if BTS state is in list of EXPECTED STATES:${expected_bts_status_after_swdl}
    ...  up to ${ON_AIR_CHECK_NUMBER} times with 10s interval.
    Log  ${log_message}  console=true
    FOR  ${run}  IN RANGE  1  ${ON_AIR_CHECK_NUMBER}
        ${bts_check_status}  ${bts_status_after_swdl}  Run Keyword And Ignore Error  coam.Get Mrbts State
        IF  '${bts_status_after_swdl}' in ${expected_bts_status_after_swdl}
            Log  BTS state is ${bts_status_after_swdl}! Check attempt: ${run}  console=true
            Log  BTS state:${bts_status_after_swdl} in LIST of EXPECTED STATES:${expected_bts_status_after_swdl} - YES  console=true
            RETURN
        END
        Sleep  10
    END
    ${failed_message}  Catenate  BTS state:${bts_status_after_swdl} NOT in LIST of EXPECTED STATES:${expected_bts_status_after_swdl}
    ...  within timeout or the status could not have been obtained
    Set Test Failed  ${failed_message}


Step6: Check If All Cells OnAir
    Log  Step6: Check if all cells onAir  console=true
    Log  Will now wait for all cells to be online. Will check every 30 seconds.  level=INFO  console=true
    IF  ${SCF_COUNT_NR}  Wait Until Keyword Succeeds  300  30  Check NR Status To Be Working
    FOR  ${run}  IN RANGE  1  420
        ${all_cell_status}  Infomodel Check If All Objects From Path Are Online  ${DIST_CELLS}
        IF  ${all_cell_status} == ${True}
            Log  All cells online! Check attempt: ${run}  console=true
            BREAK
        END
        Sleep  10
    END
    ${all_cells_onair}  Get Current Date
    IF  ${MAKE_ADDITIONAL_CHECKS}  Ensure That BTS Remains OnAir
    Set Test Variable  ${ALL_CELLS_ONAIR}
    ${mplane_ip}  Admin Get MPLANE IP
    ${status}  Run Keyword And Return Status  Admin Check Mplane Connection  ${mplane_ip}
    IF  ${status}==${FALSE}  Set Test Restriction  Check mplane connection to admin failed!


Step7: Check Active Alarms
    Log  Step7: Check active alarms  console=true
    ${critical_alarms1}  Create Dictionary  severity=Major
    ${critical_alarms2}  Create Dictionary  severity=Critical
    ${critical_patterns}  Create List  ${critical_alarms1}  ${critical_alarms2}
    ${alarms_status}  ${alarms_return}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  critical_patterns=${critical_patterns}
    IF  '${alarms_status}'=='FAIL'  Fail  Major/Critical alarm found.
    IF  ${alarms_return}  Set Test Restriction  Minor alarm found.


Check If Any Cell Is OnAir
    ${gsm_cells_status}  Run Keyword And Return Status
    ...  Assert Any  GNCEL  operationalState=${ENABLED}  timeout=1s
    IF  ${gsm_cells_status}  RETURN
    ${wcdma_cells_status}  Run Keyword And Return Status
    ...  Assert Any  WNCEL  operationalState=${ENABLED}  timeout=1s
    IF  ${wcdma_cells_status}  RETURN
    ${lte_cells_status}  Run Keyword And Return Status
    ...  Assert Any  LNCEL  operationalState=${ENABLED}  timeout=1s
    IF  ${lte_cells_status}  RETURN
    ${nr_cells_status}  Run Keyword And Return Status
    ...  Assert Any  NRCEL  operationalState=${ENABLED}  timeout=1s
    IF  ${nr_cells_status}  RETURN
    Fail  There is no cell onAir!


Change And Collect SCF
    Log  Collect and validate SCF before download and activation  console=true
    ${active_package_name}  Get TargetBD Attribute Value From Active Partition  swReleaseVersionPackageName
    ${target_package_name}  hran_file_operations.Get TargetBD Node Attribute Value  swReleaseVersionPackageName  ${TARGET_SW_PATH}
    Log  active swReleaseVersionPackageName: ${active_package_name}\ntarget swReleaseVersionPackageName: ${target_package_name}  console=true
    ${active_sw}  Should Match Regexp  ${active_package_name}  SBTS.+_ENB_[0-9]{4}_[0-9]{6}_[0-9]{6}
    ${target_sw}  Should Match Regexp  ${target_package_name}  SBTS.+_ENB_[0-9]{4}_[0-9]{6}_[0-9]{6}
    Collect SCF  ${BTS_FILES}/SCF_${active_sw}_before_SW_Download.xml
    ${scf_valid}  ${msg}  Run Keyword And Ignore Error
    ...  Validate Scf  scf_file=${BTS_FILES}/SCF_${active_sw}_before_SW_Download.xml  timeout=240
    IF  '${scf_valid}'=='FAIL'  Set Test Restriction  SCF Validation on BASE SW:${active_sw} failed:\n${msg}
    Log  SCF has been saved under ${BTS_FILES}/SCF_${active_sw}_before_SW_Download.xml  console=true


Fail If Connection With Admin Is Not Available
    ${status}  Run Keyword And Return Status  Get Mrbts State
    IF  ${status}  Return From Keyword
    ${admin_reset_status}  Run Keyword And Return Status  coam.Reset Admin
    ${status}  Run Keyword And Return Status  Get Mrbts State
    IF  ${status}  RETURN
    Fail  ${admin_reset_status}


Fail If Connection To Infomodel Is Not Available
    ${mrbts_r_object}  coam.Get Managed Objects  MRBTS_R
    ${status}  Evaluate  len(${mrbts_r_object}) > 0
    IF  ${status}  RETURN
    ${infomodel_reset_status}  Run Keyword And Return Status
    ...  ute_admin_infomodel.Reset Infomodel  filename=${BTS_FILES}/IM/InfoModel_untilReset.ims2
    ${mrbts_r_object}  coam.Get Managed Objects  MRBTS_R
    ${status}  Evaluate  len(${mrbts_r_object}) > 0
    IF  ${status}  RETURN
    Fail  ${infomodel_reset_status}


Ensure That BTS Remains OnAir
    Log  BTS will be checked ${ADDITIONAL_CHECKS_NUMBER} times with interval ${SLEEP_INTERVAL} if it remains onAir  console=true
    FOR  ${i}  IN RANGE  ${ADDITIONAL_CHECKS_NUMBER}
        Admin Check All Required State
        Admin Check Active Alarms TAF
        Log  BTS is onAir  console=true
        Sleep  ${SLEEP_INTERVAL}
    END


Check System Modules And Radio Modules
    Log  ${\n}${\n}SMODs/RMODs states check  console=true
    Assert Every  SMOD  operationalState=${ENABLED}
    Assert Every  RMOD  operationalState=${ENABLED}


Calculate Kpi For SWR
    ${kpi_dictionary}  Create dictionary  2a=2i  2b=2j  2c=2o  2d=2p
    ${kpi_id}  Get KPI2 Id
    Set Suite Variable  ${SW_ACTIVATION_DOWNTIME_KPI_ID}  kpi${kpi_id}
    Set Suite Variable  ${SWR_LAST_CELL_DOWN_FIRST_CELL_UP_KPI_2}  kpi${kpi_dictionary}[${kpi_id}]

    ${ims_list}  Create List  ${BTS_FILES}/IM/InfoModel_log_from_current_session_until_reset.ims2  ${BTS_FILES}/IM/InfoModel_log.ims2
    ${kpis_to_be_calculated}  Create List  ${SW_ACTIVATION_DOWNTIME_KPI_ID}  ${SWR_LAST_CELL_DOWN_FIRST_CELL_UP_KPI_2}  kpi4
    ${kpi_swr}  Calculate Kpis  ${kpis_to_be_calculated}  ${ims_list}
    FOR  ${kpi}  IN  @{kpis_to_be_calculated}
        Log Delta In Seconds  ${kpi_swr}[${kpi}][-1][delta]  ${kpi}
        Save Delta Results  ${kpi}
    END


Get KPI2 Id
    ${linux_sw_version_after_sw_update}  Get Embedded Linux Software Version
    ${update_with_firmware}  Set Variable If  '${linux_sw_version_after_sw_update}'=='${LINUX_SW_VERSION_BEFORE_SW_UPDATE}'  no  yes

    ${kpi2_id}  Set Variable If  '${SW_UPDATE_TYPE}'=='inter' and '${update_with_firmware}'=='no'  2a
    ...  '${SW_UPDATE_TYPE}'=='inter' and '${update_with_firmware}'=='yes'  2b
    ...  '${SW_UPDATE_TYPE}'=='intra' and '${update_with_firmware}'=='no'  2c
    ...  2d

    RETURN  ${kpi2_id}


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  expected_bts_status=${EXPECTED_BTS_STATUS}  infomodel_launch=${FALSE}


TC Teardown
    IF  ${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}
        Activate Or Deactivate Graceful Cell Shutdown  enableGrflShdn_new_value=Disabled  actGrflShdn_new_value=false
    END
    ${active_release}  Get Sw Release Name
    IF  ${SCF_COUNT_NR}
        ${nrbts_type}  _Get NR Type
    END
    Common Test Teardown
    IF  ${CALCULATE_KPI}  Calculate Kpi For SWR
    IF  '${active_release}'>='SBTS25R1' and ${SCF_COUNT_NR}  Check Snapshot To Contain Checkpoints For CP Components  ${nrbts_type}
    Set Log Level  TRACE
