*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
#
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE] CB014613
...               Scope : Common-Keywords SR-CR
#
...               Test Case Scenario author   : vincent.boulet@nokia.com
...               Creation Date               : 2025-11-19
...               Modified Date               : 2026-02-25
#
#                 Version    Date       Author                          Notes
#                 0.1        FB2523     vincent.boulet@nokia.com        Robot creation and test cases for preparation
#                 0.2        FB2525     vincent.boulet@nokia.com        Continued preparation focused on CB014613
#                 0.3        FB2525     vincent.boulet@nokia.com        Continued preparation focused on CB014613 SR and CR
#                                                                       Correction due to unexpected named argument 'param'
#                 0.4        FB2525     vincent.boulet@nokia.com        Get And Check NRCELL Parameters
#                 0.5        FB2526     vincent.boulet@nokia.com        Check NRRIMINFO Parameters, Get NRCELL Parameters SR-CR
#                 0.6        FB2601     vincent.boulet@nokia.com        Selection of RI detection mode based on parameter riStateReport
#                                                                       Remove Restart.Wait Vcu And Vdu Available after commissioning
#                 1.0        FB2605     vincent.boulet@nokia.com        Robot version for first execution
# --------------------------------------------------------------------------------------------------------------------------------------------------

# Libraries
Library                               OperatingSystem
Library                               ../../../../../resources/SWENG/python/Archi.py
Library                               taf.wts.runner                WITH NAME    wtsemu

# Resources
Resource                              ../../../resources/common/TtiTrace/ttitrace.robot
Resource                              ../../../../../resources/SWENG/robot/Container.robot
Resource                              ../../../../../resources/SWENG/robot/GenericTest.robot
Resource                              ../../../../../resources/SWENG/robot/GnbXmlTools.robot
Resource                              ../../../../../resources/SWENG/robot/KPIs.robot
Resource                              ../../../../../resources/SWENG/robot/PacketSearch.robot
Resource                              ../../../../../resources/SWENG/robot/Restart.robot
Resource                              ../../../../../resources/SWENG/robot/RdCounters.robot
Resource                              ../../../../../resources/SWENG/robot/Scf.robot
Resource                              ../../../../../resources/SWENG/robot/Syslogs.robot
Resource                              ../../../../../resources/SWENG/robot/Tools.robot
Resource                              ../../../../../resources/SWENG/robot/Topology.robot
Resource                              ../../../../../resources/SWENG/robot/Traffic.robot
Resource                              ../../../../../resources/SWENG/robot/WtsCfgConfig.robot
Resource                              ../../../../../resources/SWENG/robot/WtsXmlConfig.robot
# Following resources are defined to access wrappers for TTI Analysis and Convert interfaces
Resource                              ../../../../../resources/SWENG/robot/TtiConvertInterface.robot
Resource                              ../../../../../resources/SWENG/robot/TtiAnalysisInterface.robot
#Resource                             ../../../../../resources/SWENG/robot/TtiMultiAnalysisInterface.robot
#
Resource                              ./CB014613-Commissioning.robot

Variables                             ../../../../../resources/SWENG/python/Colors.py

*** Variables ***
${TestSharkTool}                      MC_SHARK
${AUTO_SAVE_DEBUG_DATA}               ${True}
${CALL_ENABLED}                       ${True}
#USELESS#${SUITE_DEBUG_MODE}          ${True}
#FAILED#@{protocol_exclusion}                 ARP    UDP   ICMP
${path_to_json}                       /tmp/TTI_traces.json    # internal usage for decoding TTI pcap
# Remote Interference Noise Power configuration
${RI_0}  -97,-99,-97,-99,-97,-99,-97,-99,-97,-105,-107,-107,-107,-105,-107,-105,-107,-105,-97,-99,-97,-99,-97,-99,-97,-99,-97,-99,-97,-115,-115,-115
# Thresholds calculated around -87dBm
${RI_N_PW_1}      -75,-77,-75,-77,-75,-77,-75,-77,-75,-83,-85,-83,-85,-83,-85,-83,-85,-87,-75,-77,-75,-77,-75,-77,-75,-77,-75,-77,-75,-115,-115,-115
${RICRNPW_1}      -80,-82,-80,-82,-80,-82,-80,-82,-80,-88,-90,-88,-90,-88,-90,-88,-90,-92,-80,-82,-80,-82,-80,-82,-80,-82,-80,-82,-80,-115,-115,-115
#
${RI_N_PW_6}      -80,-82,-80,-82,-80,-82,-80,-82,-80,-88,-90,-88,-90,-88,-90,-88,-90,-92,-80,-82,-80,-82,-80,-82,-80,-82,-80,-82,-80,-115,-115,-115
${RICRNPW_6}      -85,-87,-85,-87,-85,-87,-85,-87,-85,-93,-95,-93,-95,-93,-95,-93,-95,-97,-85,-87,-85,-87,-85,-87,-85,-87,-85,-87,-85,-115,-115,-115
# Thresholds calculated around -95dBm
${RI_N_PW_10}     -84,-86,-84,-86,-84,-86,-84,-86,-84,-92,-94,-92,-94,-92,-94,-92,-94,-96,-84,-86,-84,-86,-84,-86,-84,-86,-84,-86,-84,-115,-115,-115
${RICRNPW_10}    -89,-91,-89,-91,-89,-91,-89,-91,-89,-97,-99,-97,-99,-97,-99,-97,-99,-101,-89,-91,-89,-91,-89,-91,-89,-91,-89,-91,-89,-115,-115,-115
# Thresholds calculated around ~-86dBm
${RI_N_PW_SS_1}   -75,-77,-75,-77,-75,-77,-75,-77,-75,-83,-85,-83,-85,-83,-115,-115
# Thresholds calculated around -96dBm
${RI_N_PW_SS_10}  -84,-86,-84,-86,-84,-86,-84,-86,-84,-92,-94,-92,-94,-92,-115,-115
# --------------------------------------------------------------------------------------------------------------------------------------------------
*** Keywords ***
# Suite #
Suite Setup SR-CR
    [Arguments]             ${keep_all_data_in_file}=${False}
    #
    Dated Log New Line                ----Suite Setup SR-CR----
    ${timestamp_suite_setup}=         DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Suite Variable                ${timestamp_suite_setup}
    Setup.Suite Setup From Scratch    automaticTeardown=${True}    keepAllUeDataInCfgFile=${keep_all_data_in_file}
    Backup.Backup Files
    ${scf_suite_setup_backup}=        Oam.OAM Get SCF File    file=SCF_DU_BACKUP.xml
    Set Suite Variable                ${scf_suite_setup_backup}
    Dated Log                         > DU backup file is ${scf_suite_setup_backup}
    ${scf_vcu_suite_setup_backup}=    Run Keyword If    ${isAic}    Oam.OAM Get Cu SCF File    file=SCF_CU_BACKUP.xml
    ...           ELSE                Set Variable    ${None}
    Set Suite Variable                ${scf_vcu_suite_setup_backup}
    Dated Log                         > CU backup file is ${scf_vcu_suite_setup_backup}
    Set Variables For Colors
    Dated Log New Line                ----------------------------------


Test Teardown SR-CR
    [Arguments]             ${is_snapshot}=${False}
    ...                     ${F1_wait_time}=15min
    #
    Dated Log New Line                ${cc_cyan}----Test Teardown SR-CR----${cc_normal}
    GenericTest.Display diagnosis
    Dated Log New Line                ${cc_cyan}----Produce Scout Data----${cc_normal}
    IF    not ${isAic}    #[VRF_NPS_AUTO-248]#
        Produce Scout Data
    END
    Dated Log New Line                ${cc_cyan}----Restore And Clean environment----${cc_normal}
    Save and Clear Egate Console Log    pattern=TestTeardown
    Restore Files
    # Saving snapshots for debugging if AUTO_SAVE_DEBUG_DATA mode is set
    Dated Log                         > Get snapshot just if requested and not already generated after failure...
    ${snapshot_path}=                 Set Variable    ${LOG_PATH}/SNAPSHOT_GNB*.zip
    ${status}   ${ret}                Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${snapshot_path}
    Run Keyword If                    "${status}" == "PASS"
    ...    Dated Log                  > ${snapshot_path} is already present
    ...           ELSE IF             ${AUTO_SAVE_DEBUG_DATA} and ${is_snapshot} and "${TEST_STATUS}" != "FAIL"    Setup.Get Snapshot
    #
    Run                               command=cp /opt/wts/latest/basic_*.modified.cfg ${LOG_PATH}
    # Restoring backups scf
    ${scf_suite_teardown_restore}=    Get Variable Value    ${scf_suite_setup_backup}    None
    ${scf_vcu_suite_teardown_restore}=    Run Keyword If    ${isAic}    Get Variable Value    ${scf_vcu_suite_setup_backup}    None
    ...           ELSE                Set Variable    ${None}
    Run Keyword If    ${isAic}        Oam.OAM Perform Full Commissioning    scf_file=${scf_vcu_suite_teardown_restore}  oam=${GNB_CU.oam}
    Oam.OAM Perform Full Commissioning    scf_file=${scf_suite_teardown_restore}    oam=${GNB_DU.oam}
    IF    ${isAic}
                                      Restart.Wait Vcu And Vdu Available
                                      Restart.Restart Airphone
                                      Traced Sleep    duration=120s    msg=restart of Aiphone
                                      Restart.Wait Airphone Available
                                      Restart.F1 Wait Link AIC    timeout=${F1_wait_time}
                                      Traced Sleep    duration=300s    msg=activation of radio modules
                                      Setup.Get TL Info Struct
    ELSE
                                      Oam.OAM wait available
                                      Restart.Restart Airphone
                                      Traced Sleep    duration=120s    msg=restart of Aiphone
                                      Restart.Wait Airphone Available
                                      Traced Sleep    duration=180s    msg=activation of radio modules
                                      Setup.Get TL Info Struct
    END
    # Cleaning-up debugging files
    Run                               command=rm -f ${scf_suite_setup_backup}
    Run Keyword If    ${isAic}        Run    command=rm -f ${scf_vcu_suite_setup_backup}
    Dated Log                         > Remove the SCF BACKUP files
    Run                               command=rm -f ${LOG_PATH}/L1L2/*.pdml
    Dated Log                         > Remove the generated pdml files
    Run                               command=rm -f ${LOG_PATH}/L1L2/*.__*.pcap
    Dated Log                         > Remove the intermediate pcap files
    Run                               command=rm -f ${LOG_PATH}/TTITraces/*.json
    Dated Log                         > Remove the TTI json files
    Run                               command=rm -f ${LOG_PATH}/SCF.xml
    ${timestamp_suite_teardown}=      DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Suite Variable                ${timestamp_suite_teardown}
    Dated Log New Line                ---------------------------------------------
    Dated Log                         > RUNTIME: ${timestamp_suite_setup} -> ${timestamp_suite_teardown}
    Dated Log New Line                ---------------------------------------------
    Run keyword if                    "${TEST_STATUS}" == "FAIL"    Test Teardown if Fail
    ...           ELSE                Run    command=mv ${LOG_PATH} ${OUTPUT_DIR}/Logs/Results
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Variables #
Set Variables For Colors
    #
    # colors definition based on Variables    ../../../../../resources/SWENG/python/Colors.py
    ${cc_blue}                        Evaluate    "${BLUE}"
    ${cc_cyan}                        Evaluate    "${CYAN}"
    ${cc_green}                       Evaluate    "${GREEN}"
    ${cc_normal}                      Evaluate    "${NORMAL}"
    ${cc_pink}                        Evaluate    "${PINK}"
    ${cc_red}                         Evaluate    "${RED}"
    ${cc_white}                       Evaluate    "${WHITE}"
    ${cc_yellow}                      Evaluate    "${YELLOW}"
    ${cc_bg_black}                    Evaluate    "${BG_BLACK}"
    ${cc_bg_yellow}                   Evaluate    "${BG_YELLOW}"
    #
    Set Suite Variable                ${cc_blue}
    Set Suite Variable                ${cc_cyan}
    Set Suite Variable                ${cc_green}
    Set Suite Variable                ${cc_normal}
    Set Suite Variable                ${cc_pink}
    Set Suite Variable                ${cc_red}
    Set Suite Variable                ${cc_white}
    Set Suite Variable                ${cc_yellow}
    Set Suite Variable                ${cc_bg_black}
    Set Suite Variable                ${cc_bg_yellow}
# --------------------------------------------------------------------------------------------------------------------------------------------------
Convert Dictionary to Parameter String
    [Arguments]             ${kwargs}
    #
    ${command_args}                   Set Variable   ${EMPTY}
    FOR    ${key}    IN    @{kwargs}
        ${value}=                     Collections.Get From Dictionary    ${kwargs}    ${key}
        ${cleaned_key}=               Replace String Using Regexp    string=${key}    pattern=__\\d+    replace_with=${EMPTY}
#DEBUG_LOG#
#       Dated Log          >> ${cleaned_key}= ${value}
        ${command_args}=              Set Variable    ${command_args} ${cleaned_key}=${value}
    END
#DEBUG_LOG#
#   Dated Log              >> ${command_args}
    [Return]                          ${command_args}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# RAD Parameters #
Set RAD Parameters SR
    [Arguments]             ${rad_0x5801CB_val}=${None}
    ...                     ${rad_0x58046F_val}=${None}
    ...                     ${rad_0x580689_val}=${None}
    ...                     ${rad_0x58057A_val}=${None}
    ...                     ${rad_0x58057C_val}=${None}
    ...                     ${rad_0x58057F_val}=${None}
    ...                     ${rad_0x58061C_val}=${None}
    ...                     ${rad_0x58061D_val}=${None}
    ...                     ${rad_0x1003F_val}=${None}
    ...                     ${rad_0x10040_val}=${None}
    ...                     ${rad_0x10041_val}=${None}
    ...                     ${rad_0x9D0001_val}=${None}
    ...                     ${rad_0x9D0002_val}=${None}
    ...                     ${rad_0x9D0006_val}=${None}
    ...                     ${rad_0x800059_val}=${None}
    ...                     ${rad_0x580580_val}=${None}
    ...                     ${rad_0x800045_val}=${None}
    ...                     ${rad_0x800001_val}=${None}

    @{list_rad_param}=                Create List
    #
    #0x5801CB#L2PS#rdFakeUeSchedulingEnable#disabled#
    &{rad_0x5801CB}=    Run Keyword If    ${rad_0x5801CB_val} != ${None}    Create Dictionary    field=0x5801cb    value=${rad_0x5801CB_val}
    Run Keyword If    ${rad_0x5801CB_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x5801CB}
    #
    #0x58046F#L2PS#rdStaticPdcchPowerOffset#disabled#
    &{rad_0x58046F}=    Run Keyword If    ${rad_0x58046F_val} != ${None}    Create Dictionary    field=0x58046f    value=${rad_0x58046F_val}
    Run Keyword If    ${rad_0x58046F_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x58046F}
    #
    #0x580689#L2PS#rdRimRsPeriodicity#bits 0-15 for period and 16-31 for offset
    &{rad_0x580689}=    Run Keyword If    ${rad_0x580689_val} != ${None}    Create Dictionary    field=0x580689    value=${rad_0x580689_val}
    Run Keyword If    ${rad_0x580689_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x580689}
    #
    #0x58057A#L2PS#rdFeatureFlagBitmapLevel#Enable feature flag logs via radparameter#VIP, 1 - ERROR, 2 - WARNING, 3 - INFO, 4 - DEBUG, 5 - INVALID#
    &{rad_0x58057A}=    Run Keyword If    ${rad_0x58057A_val} != ${None}    Create Dictionary    field=0x58057a    value=${rad_0x58057A_val}
    Run Keyword If    ${rad_0x58057A_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x58057A}
    #
    #0x58057C#L2PS#rdFeatureFlagBitmap1#Bitmap 1 of enabled feature flag logs. Requires relevant rdFeatureFlagBitmapLevel setup#
    &{rad_0x58057C}=    Run Keyword If    ${rad_0x58057C_val} != ${None}    Create Dictionary    field=0x58057c    value=${rad_0x58057C_val}
    Run Keyword If    ${rad_0x58057C_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x58057C}
    #
    #0x58061C#L2PS#rdRiDataTrimThreshold#Indicates the percentage of data to be trimmed from top and bottom of the collected RSSI dataset#
    &{rad_0x58061C}=    Run Keyword If    ${rad_0x58061C_val} != ${None}    Create Dictionary    field=0x58061c    value=${rad_0x58061C_val}
    Run Keyword If    ${rad_0x58061C_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x58061C}
    #
    #0x58061D#L2PS#rdAutoRiThresBaseCalcInterval#Update interval of the adjusted RI detection threshold for testing purpose#
    &{rad_0x58061D}=    Run Keyword If    ${rad_0x58061D_val} != ${None}    Create Dictionary    field=0x58061d    value=${rad_0x58061D_val}
    Run Keyword If    ${rad_0x58061D_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x58061D}
    #
    #0x58057F#L2PS#rdFeatureFlagBitmap4#Bitmap 4 of enabled feature flag logs. Requires relevant rdFeatureFlagBitmapLevel setup#bit 0- RIM.Common#
    #0x58057F#L2PS#rdFeatureFlagBitmap4#bit 1- RIM.RI#
    #0x58057F#L2PS#rdFeatureFlagBitmap4#bit 6- RIM.RS_UL#
    #0x58057F#L2PS#rdFeatureFlagBitmap4#bit 18- RIM.RS_DETECTION#
    &{rad_0x58057F}=    Run Keyword If    ${rad_0x58057F_val} != ${None}    Create Dictionary    field=0x58057f    value=${rad_0x58057F_val}
    Run Keyword If    ${rad_0x58057F_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x58057F}
    #
    #0x580580#L2PS#rdFeatureFlagBitmapX#Bitmap x of enabled feature flag logs#
    #0x580580#L2PS#rdFeatureFlagBitmapX#bit X- RIM.UL_PRB_POOLING#
    &{rad_0x580580}=    Run Keyword If    ${rad_0x580580_val} != ${None}    Create Dictionary    field=0x580580    value=${rad_0x580580_val}
    Run Keyword If    ${rad_0x580580_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x580580}
    #
    #
    #UEC flags
    #0x1003f=1#ERadCcs_AaSysLogInputLevel=debug#
    &{rad_0x1003F}=    Run Keyword If    ${rad_0x1003F_val} != ${None}    Create Dictionary    field=0x1003f    value=${rad_0x1003F_val}
    Run Keyword If    ${rad_0x1003F_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x1003F}
    #
    #0x10040=1#ERadCcs_AaSysLogOutputLevel=debug#
    &{rad_0x10040}=    Run Keyword If    ${rad_0x10040_val} != ${None}    Create Dictionary    field=0x10040    value=${rad_0x10040_val}
    Run Keyword If    ${rad_0x10040_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x10040}
    #
    #0x10041=5#ERadCcs_AaSysLogOutputMode#
    &{rad_0x10041}=    Run Keyword If    ${rad_0x10041_val} != ${None}    Create Dictionary    field=0x10041    value=${rad_0x10041_val}
    Run Keyword If    ${rad_0x10041_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x10041}
    #
    #
    #PMSTAT flags
    #0x9D0001=1#enable PMStat core flag#
    &{rad_0x9D0001}=    Run Keyword If    ${rad_0x9D0001_val} != ${None}    Create Dictionary    field=0x9d0001    value=${rad_0x9D0001_val}
    Run Keyword If    ${rad_0x9D0001_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x9D0001}
    #
    #0x9D0002=1#enable PMStat PM flag#
    &{rad_0x9D0002}=    Run Keyword If    ${rad_0x9D0002_val} != ${None}    Create Dictionary    field=0x9d0002    value=${rad_0x9D0002_val}
    Run Keyword If    ${rad_0x9D0002_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x9D0002}
    #
    #0x9D0006=55308#Debug flag for M55308#
    &{rad_0x9D0006}=    Run Keyword If    ${rad_0x9D0006_val} != ${None}    Create Dictionary    field=0x9d0006    value=${rad_0x9D0006_val}
    Run Keyword If    ${rad_0x9D0006_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x9D0006}
    #
    #
    #0x800059#L1#rdUlPhyNrRimRsDetectionThreshold#Remote interference RS detection threshold for NR#
    &{rad_0x800059}=    Run Keyword If    ${rad_0x800059_val} != ${None}    Create Dictionary    field=0x800059    value=${rad_0x800059_val}
    Run Keyword If    ${rad_0x800059_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x800059}
    #
    # L1 IQ data flags
    #0x800045=0x200#NrUlPhy+enableRespCapture+9-RespCaptureMask_RimReceiveRespPs (0b0010 0000 0000=0x200=512)#
    &{rad_0x800045}=    Run Keyword If    ${rad_0x800045_val} != ${None}    Create Dictionary    field=0x800045    value=${rad_0x800045_val}
    Run Keyword If    ${rad_0x800045_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x800045}
    #0x800001=0x80000000#NrUlPhy+phyEventEnable+31-EphyEvent_RimRsDm (0b1000 0000 0000 0000 0000 0000 0000 0000=0x80000000)#
    &{rad_0x800001}=    Run Keyword If    ${rad_0x800001_val} != ${None}    Create Dictionary    field=0x800001    value=${rad_0x800001_val}
    Run Keyword If    ${rad_0x800001_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x800001}
    #
    ${length_list_rad_param}=         Get Length    ${list_rad_param}
    Dated Log                         > RAD params list is ${list_rad_param} with length= ${length_list_rad_param}
    Run Keyword If    ${length_list_rad_param} > 0    SetConfig.Set Fields in swconfig DU    param_list=${list_rad_param}


Set CPLANE RAD Parameters SR
    [Arguments]             ${rad_0x66001B_val}=${None}
    ...                     ${rad_0x590072_val}=${None}
    ...                     ${rad_0x890001_val}=${None}
    ...                     ${rad_0x890002_val}=${None}
    ...                     ${rad_0x890003_val}=${None}
    ...                     ${rad_0x890004_val}=${None}
    ...                     ${rad_0x890005_val}=${None}
    ...                     ${rad_0x890006_val}=${None}
    ...                     ${rad_0x890007_val}=${None}
    ...                     ${rad_0x890008_val}=${None}
    ...                     ${rad_0x890009_val}=${None}
    #
    Dated Log New Line                ${cc_cyan}----Set CPLANE RAD Parameters SR----${cc_normal}
    @{list_rad_param}=                Create List
    #
    #0x66001B#L2PS#ERadCcs_AaSysLogOutputMode#0 = disable, 1 = debug, 2 = info, 3 = warning, 4 = error, 5 = vip, 6 = disable#
    ${rad_value}=                     Set Variable    2    # default= 2 = info
    IF    ${rad_0x66001B_val} != ${None}
        ${rad_value}=                 Set Variable    ${rad_0x66001B_val}
    END
    &{rad_0x66001B}=              Create Dictionary    field=0x66001b    value=${rad_value}
    Append To List                ${list_rad_param}    ${rad_0x66001B}
    #
    #0x590072#CP-RT#
    ${rad_value}=                     Set Variable    2    # default= 2 = info
    IF    ${rad_0x590072_val} != ${None}
        ${rad_value}=                 Set Variable    ${0x590072_val}
    END
    &{rad_0x590072}=              Create Dictionary    field=0x590072    value=${rad_value}
    Append To List                ${list_rad_param}    ${rad_0x590072}
    #
    #0x890001#CP-NRT#
    ${rad_value}=                     Set Variable    2    # default= 2 = info
    IF    ${rad_0x890001_val} != ${None}
        ${rad_value}=                 Set Variable    ${0x890001_val}
    END
    &{rad_0x890001}=              Create Dictionary    field=0x890001    value=${rad_value}
    Append To List                ${list_rad_param}    ${rad_0x890001}
    #
    #0x890002#CP-NB#
    ${rad_value}=                     Set Variable    2    # default= 2 = info
    IF    ${rad_0x890002_val} != ${None}
        ${rad_value}=                 Set Variable    ${0x890002_val}
    END
    &{rad_0x890002}=              Create Dictionary    field=0x890002    value=${rad_value}
    Append To List                ${list_rad_param}    ${rad_0x890002}
    #
    #0x890003#CP-SB#
    ${rad_value}=                     Set Variable    2    # default= 2 = info
    IF    ${rad_0x890003_val} != ${None}
        ${rad_value}=                 Set Variable    ${0x890003_val}
    END
    &{rad_0x890003}=              Create Dictionary    field=0x890003    value=${rad_value}
    Append To List                ${list_rad_param}    ${rad_0x890003}
    #
    #0x890004#CP-UE#
    ${rad_value}=                     Set Variable    2    # default= 2 = info
    IF    ${rad_0x890004_val} != ${None}
        ${rad_value}=                 Set Variable    ${0x890004_val}
    END
    &{rad_0x890004}=              Create Dictionary    field=0x890004    value=${rad_value}
    Append To List                ${list_rad_param}    ${rad_0x890004}
    #
    #0x890005#CP-CL#
    ${rad_value}=                     Set Variable    2    # default= 2 = info
    IF    ${rad_0x890005_val} != ${None}
        ${rad_value}=                 Set Variable    ${0x890005_val}
    END
    &{rad_0x890005}=              Create Dictionary    field=0x890005    value=${rad_value}
    Append To List                ${list_rad_param}    ${rad_0x890005}
    #
    #0x890006#CP-IF#
    ${rad_value}=                     Set Variable    2    # default= 2 = info
    IF    ${rad_0x890006_val} != ${None}
        ${rad_value}=                 Set Variable    ${0x890006_val}
    END
    &{rad_0x890006}=              Create Dictionary    field=0x890006    value=${rad_value}
    Append To List                ${list_rad_param}    ${rad_0x890006}
    #
    #0x890007#CP-SCTP#
    ${rad_value}=                     Set Variable    2    # default= 2 = info
    IF    ${rad_0x890007_val} != ${None}
        ${rad_value}=                 Set Variable    ${0x890007_val}
    END
    &{rad_0x890007}=              Create Dictionary    field=0x890007    value=${rad_value}
    Append To List                ${list_rad_param}    ${rad_0x890007}
    #
    #0x890008#CP-E2#
    ${rad_value}=                     Set Variable    2    # default= 2 = info
    IF    ${rad_0x890008_val} != ${None}
        ${rad_value}=                 Set Variable    ${0x890008_val}
    END
    &{rad_0x890008}=              Create Dictionary    field=0x890008    value=${rad_value}
    Append To List                ${list_rad_param}    ${rad_0x890008}
    #
    #0x890009#CP-VEMC#
    ${rad_value}=                     Set Variable    2    # default= 2 = info
    IF    ${rad_0x890009_val} != ${None}
        ${rad_value}=                 Set Variable    ${0x890009_val}
    END
    &{rad_0x890009}=              Create Dictionary    field=0x890009    value=${rad_value}
    Append To List                ${list_rad_param}    ${rad_0x890009}
    #
    ${length_list_rad_param}=         Get Length    ${list_rad_param}
    Dated Log                         > RAD params list is ${list_rad_param} with length= ${length_list_rad_param}
    #
    IF    ${length_list_rad_param} > 0
        ${result}=                    SetConfig.Set Fields in swconfig DU    param_list=${list_rad_param}
        Dated Log                     >> result= ${result}
    END


#[VRF_NPS_AUTO-249]# Closed
#[VRF_NPS_AUTO-250]# Not tested
Set RAD Parameters CR
    [Arguments]             ${entity_oam}=${GNB_DU.oam}
    ...                     ${domain}=L2PS
    ...                     ${rad_0x58057A_val}=${None}
    ...                     ${rad_0x58057F_val}=${None}
    #
    @{list_rad_param}=                Create List
    #
    #0x58057A#L2PS#rdFeatureFlagBitmapLevel#Enable feature flag logs via radparameter#VIP, 1 - ERROR, 2 - WARNING, 3 - INFO, 4 - DEBUG, 5 - INVALID#
    IF    ${rad_0x58057A_val} != ${None}
        &{rad_0x58057A}=              Create Dictionary    name=rdFeatureFlagBitmapLevel    value=${rad_0x58057A_val}
        Append To List                ${list_rad_param}    ${rad_0x58057A}
    END
    #
    #0x58057F#L2PS#rdFeatureFlagBitmap4#Bitmap 4 of enabled feature flag logs. Requires relevant rdFeatureFlagBitmapLevel setup#bit 0- RIM.Common#
    #0x58057F#L2PS#rdFeatureFlagBitmap4#bit 1- RIM.RI#
    #0x58057F#L2PS#rdFeatureFlagBitmap4#bit 6- RIM.RS_UL#
    #0x58057F#L2PS#rdFeatureFlagBitmap4#bit 18- RIM.RS_DETECTION#
    IF    ${rad_0x58057F_val} != ${None}
        &{rad_0x58057F}=              Create Dictionary    name=rdFeatureFlagBitmap4    value=${rad_0x58057F_val}
        Append To List                ${list_rad_param}    ${rad_0x58057F}
    END
    #
    ${length_list_rad_param}=         Get Length    ${list_rad_param}
    Dated Log                         > RAD params list is ${list_rad_param} with length= ${length_list_rad_param}
    #
    IF    ${length_list_rad_param} > 0
        ${result}=                    Oam.OAM Update RAD Debug Parameters    domain_name=${domain}  parameters=${list_rad_param}  oam=${entity_oam}
        Should Be Equal               ${result['status']}    succeeded
    END


#Set CPLANE RAD Parameters CR
#    [Arguments]             ${rad_0x66001B_val}=${None}
#    ...                     ${rad_0x590072_val}=${None}
#    ...                     ${rad_0x890001_val}=${None}
#    ...                     ${rad_0x890002_val}=${None}
#    ...                     ${rad_0x890003_val}=${None}
#    ...                     ${rad_0x890004_val}=${None}
#    ...                     ${rad_0x890005_val}=${None}
#    ...                     ${rad_0x890006_val}=${None}
#    ...                     ${rad_0x890007_val}=${None}
#    ...                     ${rad_0x890008_val}=${None}
#    ...                     ${rad_0x890009_val}=${None}
#    #
#    Dated Log New Line                ${cc_cyan}----Set CPLANE RAD Parameters CR----${cc_normal}
#    @{list_rad_param}=                Create List
#    #
#    #0x66001B#L2PS#ERadCcs_AaSysLogOutputMode#0 = disable, 1 = debug, 2 = info, 3 = warning, 4 = error, 5 = vip, 6 = disable#
#    ${rad_value}=                     Set Variable    2    # default= 2 = info
#    IF    ${rad_0x66001B_val} != ${None}
#        ${rad_value}=                 Set Variable    ${rad_0x66001B_val}
#    END
#    &{rad_0x66001B}=              Create Dictionary    name=    value=${rad_value}
#    Append To List                ${list_rad_param}    ${rad_0x66001B}
#    #
#    #0x590072#CP-RT#
#    ${rad_value}=                     Set Variable    2    # default= 2 = info
#    IF    ${rad_0x590072_val} != ${None}
#        ${rad_value}=                 Set Variable    ${0x590072_val}
#    END
#    &{rad_0x590072}=              Create Dictionary    name=    value=${rad_value}
#    Append To List                ${list_rad_param}    ${rad_0x590072}
#    #
#    #0x890001#CP-NRT#
#    ${rad_value}=                     Set Variable    2    # default= 2 = info
#    IF    ${rad_0x890001_val} != ${None}
#        ${rad_value}=                 Set Variable    ${0x890001_val}
#    END
#    &{rad_0x890001}=              Create Dictionary    name=    value=${rad_value}
#    Append To List                ${list_rad_param}    ${rad_0x890001}
#    #
#    #0x890002#CP-NB#
#    ${rad_value}=                     Set Variable    2    # default= 2 = info
#    IF    ${rad_0x890002_val} != ${None}
#        ${rad_value}=                 Set Variable    ${0x890002_val}
#    END
#    &{rad_0x890002}=              Create Dictionary    name=    value=${rad_value}
#    Append To List                ${list_rad_param}    ${rad_0x890002}
#    #
#    #0x890003#CP-SB#
#    ${rad_value}=                     Set Variable    2    # default= 2 = info
#    IF    ${rad_0x890003_val} != ${None}
#        ${rad_value}=                 Set Variable    ${0x890003_val}
#    END
#    &{rad_0x890003}=              Create Dictionary    name=    value=${rad_value}
#    Append To List                ${list_rad_param}    ${rad_0x890003}
#    #
#    #0x890004#CP-UE#
#    ${rad_value}=                     Set Variable    2    # default= 2 = info
#    IF    ${rad_0x890004_val} != ${None}
#        ${rad_value}=                 Set Variable    ${0x890004_val}
#    END
#    &{rad_0x890004}=              Create Dictionary    name=    value=${rad_value}
#    Append To List                ${list_rad_param}    ${rad_0x890004}
#    #
#    #0x890005#CP-CL#
#    ${rad_value}=                     Set Variable    2    # default= 2 = info
#    IF    ${rad_0x890005_val} != ${None}
#        ${rad_value}=                 Set Variable    ${0x890005_val}
#    END
#    &{rad_0x890005}=              Create Dictionary    name=    value=${rad_value}
#    Append To List                ${list_rad_param}    ${rad_0x890005}
#    #
#    #0x890006#CP-IF#
#    ${rad_value}=                     Set Variable    2    # default= 2 = info
#    IF    ${rad_0x890006_val} != ${None}
#        ${rad_value}=                 Set Variable    ${0x890006_val}
#    END
#    &{rad_0x890006}=              Create Dictionary    name=    value=${rad_value}
#    Append To List                ${list_rad_param}    ${rad_0x890006}
#    #
#    #0x890007#CP-SCTP#
#    ${rad_value}=                     Set Variable    2    # default= 2 = info
#    IF    ${rad_0x890007_val} != ${None}
#        ${rad_value}=                 Set Variable    ${0x890007_val}
#    END
#    &{rad_0x890007}=              Create Dictionary    name=    value=${rad_value}
#    Append To List                ${list_rad_param}    ${rad_0x890007}
#    #
#    #0x890008#CP-E2#
#    ${rad_value}=                     Set Variable    2    # default= 2 = info
#    IF    ${rad_0x890008_val} != ${None}
#        ${rad_value}=                 Set Variable    ${0x890008_val}
#    END
#    &{rad_0x890008}=              Create Dictionary    name=    value=${rad_value}
#    Append To List                ${list_rad_param}    ${rad_0x890008}
#    #
#    #0x890009#CP-VEMC#
#    ${rad_value}=                     Set Variable    2    # default= 2 = info
#    IF    ${rad_0x890009_val} != ${None}
#        ${rad_value}=                 Set Variable    ${0x890009_val}
#    END
#    &{rad_0x890009}=              Create Dictionary    name=    value=${rad_value}
#    Append To List                ${list_rad_param}    ${rad_0x890009}
#    #
#    ${length_list_rad_param}=         Get Length    ${list_rad_param}
#    Dated Log                         > RAD params list is ${list_rad_param} with length= ${length_list_rad_param}
#    #
#    IF    ${length_list_rad_param} > 0
#        ${result}=                    SetConfig.Set Fields in swconfig DU    param_list=${list_rad_param}
#        Dated Log                     >> result= ${result}
#    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
# BSR #
Software Download BSR file SR
    [Arguments]             ${param}
    ...                     ${bsr_git_path}=gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
    #
    Dated Log New Line                ${cc_cyan}----Software Download BSR file SR ${param.bsr_target}----${cc_normal}
    Download Package Using Git Update OAM    git_path=${bsr_git_path}
    ...                               git_folder=${param.bsr_folder}
    ...                               git_file_name=${param.bsr_target}
    ...                               target_dir=${LOG_PATH}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# basic_setup #
Configure Parameter In WTS basic_setup File
    [Arguments]             ${identifier}
    ...                     ${param}
    ...                     ${value}
    #
    Dated Log New Line                ${cc_cyan}----Configure Parameter In WTS basic_setup File----${cc_normal}
    WtsCfgConfig.startSession
    ${default_value}=                 WtsCfgConfig.getParam    prefix=${identifier}    param=${param}
    Dated Log                         > default value for ${identifier}: ${param}= ${default_value}
    replaceValue                      prefix=${identifier}    param=${param}    oldValue=${default_value}    newValue=${value}
    Dated Log                         > new value updated for ${identifier} for ${param} is ${value}
    WtsCfgConfig.stopSession          rename=modified


#iphy#
Configure Parameter In AP iphy File
    [Arguments]             ${identifier}
    ...                     ${param}
    ...                     ${value}
    #
    Dated Log New Line                ${cc_cyan}----Configure Parameter In AP iphy File----${cc_normal}
    WtsXmlConfig.startSession         file=iphy
    WtsXmlConfig.setTextUsingIndex    path=//${param}    val=${value}    idx=${identifier}
    Dated Log                         > new value updated for ${param} idx= ${identifier} is ${value}
    WtsXmlConfig.stopSession          file=iphy
# --------------------------------------------------------------------------------------------------------------------------------------------------
# UE
Display List UEs Settings
    [Arguments]             ${list_elem}
    #
    Dated Log New Line                ${cc_cyan}----Display List UEs Settings----${cc_normal}
    FOR    ${current_elem}    IN    @{list_elem}
        Dated Log        ue= ${current_elem}[ue], call= ${current_elem}[call_type], rnti=${current_elem}[c_rnti], cell=${current_elem}[target_cells]
    END


Get List UEs Settings
    [Arguments]             ${param}
    ...                     ${dict_settings}
    #
    Dated Log New Line                ${cc_cyan}----Get List UEs Settings----${cc_normal}
    @{list_ue}=                       Create List
    @{cell_id_streaming}=             Create List
    FOR    ${current_id}    IN RANGE    0    ${param.total_nb_ue}
        ${current_call_type}=         Set Variable    ${dict_settings[${current_id}].call_type}
        ${current_ue_id}=             Set Variable    ${dict_settings[${current_id}].ue_id}
        ${current_ue_setting}=        Run Keyword If    "${current_call_type}" == "SA"    Copy Dictionary     ${BASIC_UE_SA}
        ...       ELSE                Copy Dictionary     ${UE_SIMPLE}
        Set To Dictionary             ${current_ue_setting}    ue    ${current_ue_id}
        Set To Dictionary             ${current_ue_setting}    trf_id    1
        Run Keyword If                "${current_call_type}" == "SA"
        ...                           Set To Dictionary    ${current_ue_setting}    pdu    1
        Run Keyword If                "${current_call_type}" == "NSA"
        ...                           Set To Dictionary    ${current_ue_setting}    bearer    2
        Set To Dictionary             ${current_ue_setting}    target_gnb               ${param.target_gnb}
        # Dispatching the ue on the requested original cell for the call establishment
        Set To Dictionary             ${current_ue_setting}    target_cells             ${dict_settings[${current_id}].original_cell}
        ${nb_values}=                 Count Values In List    ${cell_id_streaming}    ${current_ue_setting.target_cells}
        Run Keyword If                ${nb_values} == 0    Append To List    ${cell_id_streaming}     ${current_ue_setting.target_cells}
        # Set the correct requested throughput per ue
        Set To Dictionary             ${current_ue_setting}    throughput               ${dict_settings[${current_id}].throughput}
        Set To Dictionary             ${current_ue_setting}    throughput_ul            ${dict_settings[${current_id}].throughput_ul}
        Set To Dictionary             ${current_ue_setting}    throughput_gbr           ${dict_settings[${current_id}].throughput_gbr}
        Set To Dictionary             ${current_ue_setting}    call_type                ${current_call_type}
        Set To Dictionary             ${current_ue_setting}    paging                   ${dict_settings[${current_id}].paging}
        ${k_csi_override_cqi}=        Is Parameter A Dictionary Key    dict=${dict_settings[${current_id}]}    parameter=csi_override_cqi
        Run Keyword If                ${k_csi_override_cqi}
        ...                       Set To Dictionary    ${current_ue_setting}    csi_override_cqi    ${dict_settings[${current_id}].csi_override_cqi}
        ${k_ue_measurement_nr}=       Is Parameter A Dictionary Key    dict=${dict_settings[${current_id}]}    parameter=ue_measurement_nr
        Run Keyword If                "${param.ue_measurement_nr}" != "${None}" and ${k_ue_measurement_nr}
        ...                     Set To Dictionary    ${current_ue_setting}    ue_measurement_nr    ${dict_settings[${current_id}].ue_measurement_nr}
        ${k_target_handover}=         Is Parameter A Dictionary Key    dict=${dict_settings[${current_id}]}    parameter=target_handover
        Run Keyword If                "${param.ue_measurement_nr}" != "${None}" and ${k_target_handover}
        ...                         Set To Dictionary    ${current_ue_setting}    target_handover    ${dict_settings[${current_id}].target_handover}
        Append To List                ${list_ue}    ${current_ue_setting}
        ${nb_values}=                 Run Keyword If    "${param.ue_measurement_nr}" != "${None}" and ${k_target_handover}    Count Values In List
        ...                                                         ${cell_id_streaming}    ${current_ue_setting.target_handover}
        ...       ELSE                Set Variable    1
        Run Keyword If                ${nb_values} == 0    Append To List    ${cell_id_streaming}     ${current_ue_setting.target_handover}
    END
#DEBUG_LOG#
#   Dated Log                         >> UE's list is ${list_ue}
#   Dated Log                         >> Cells list for TTI streaming is ${cell_id_streaming}
    [Return]                          ${list_ue}    ${cell_id_streaming}


Set CRNTI Into UEs Settings
    [Arguments]             ${list_ue}
    ...                     ${list_crnti}
    #
    Dated Log New Line                ${cc_cyan}----Set CRNTI Into UEs Settings----${cc_normal}
    ${nb_crnti}=                      Get Length    ${list_crnti}
    FOR    ${iteration_crnti}    IN RANGE    0    ${nb_crnti}
        Set To Dictionary             ${list_ue[${iteration_crnti}]}    c_rnti    ${list_crnti[${iteration_crnti}]}
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Captures #
#[VRF_NPS_AUTO-245]# Closed
Captures Init
    [Arguments]             ${isMirror}=${False}
    #
    Dated Log New Line                ${cc_cyan}----Captures Init----${cc_normal}
    ${capture_l1l2}=                  Capture L1L2 Set Upon Config    airscale=${GNB_DU}   isMirror=${isMirror}
#FAILED#    ${capture_l1l2.filter}=           Get Filter To Exclude protocols    capture=${capture_l1l2}    protocolList=${protocol_exclusion}
    ${capture_l1l2.filter}=    Run Keyword If    ${isMirror}    Set Variable    ether[24:2]=0xe24d or ether[24:2]=0xe113 or ether[24:2]=0xe251
    ${capture_core}=                  Run Keyword If    ${isAic}    Capture CORE Set Upon Config    airscale=${GNB_CU}
    ...           ELSE                Capture CORE Set Upon Config    airscale=${GNB_DU}
    ${capture_cprt}=                  Capture CPRT Set Upon Config    airscale=${GNB_DU}
    Capture Init                      ${capture_l1l2}    #withTN=True
    Capture Init                      ${capture_core}    #withTN=True
    Capture Init                      ${capture_cprt}    #withTN=True
    Set Suite Variable                ${capture_l1l2}
    Set Suite Variable                ${capture_core}
    Set Suite Variable                ${capture_cprt}


Capture L1L2 Stop
    [Arguments]             ${capture_config}
    ...                     ${output_suffix}
    ...                     ${output_prefix}=L1L2
    ...                     ${output_log_path}=L1L2
    #
    Dated Log New Line                ${cc_cyan}----Capture L1L2 Stop----${cc_normal}
    ${output_log}=                    Set Variable    ${LOG_PATH}/${output_log_path}/${output_prefix}_${output_suffix}.pcap
    Run Keyword And Ignore Error      Capture Stop    capture=${capture_config}
    Dated Log                         > input= ${capture_config.path}
    Dated Log                         > output= ${output_log}
    Run                               command=mkdir -p ${LOG_PATH}/${output_log_path}
    Run                               command=mv ${capture_config.path} ${output_log}


# L1L2 #
#CR_NOT_TESTED##CB011127#CB011127 Create Filter Message List
#CR_NOT_TESTED##CB011127#CB011127 Create Filter Message List Per CRNTI
#CR_NOT_TESTED##CB011127#CB011127 Analyze pcap and pdml
#CR_NOT_TESTED#Post Processing L1L2 Traces
# --------------------------------------------------------------------------------------------------------------------------------------------------
# TTI #
Start TTI Logs SR-CR
    [Arguments]             ${cell_id_list}
    #
    Dated Log New Line                ${cc_cyan}----Start TTI Logs----${cc_normal}
    ${TTIdir}=                        Get TTI Trace Path
    Run Keyword If                    ${isAic}    ttitrace.Start TTI Traces in Streaming mode   src_ip=10.0.1.2   nrcell_id_list_aic=${cell_id_list}
    ...           ELSE                ttitrace.Start TTI Traces in Streaming mode    src_ip=10.0.1.2    cell_distid=${cell_id_list}
    Set Suite Variable                ${TTIdir}


Stop and Get TTI Logs SR-CR
    [Arguments]             ${list_events_to_filter}
    ...                     ${trace_name}=TTI
    #
    Dated Log New Line                ${cc_cyan}----Stop TTI Logs----${cc_normal}
    ${TTIpcap}=                       ttitrace.Stop TTI Traces in Streaming mode    tti_trace_path=${TTIdir}    tti_trace_filename=${trace_name}
    Dated Log                         ----Decode TTI Logs----
    ${json_tti_output}=               Set Variable    ${LOG_PATH}/TTITraces/${trace_name}_filtered.json
    #${tti_decoder_path}=             Set Variable    /opt/tti-dec/tti-dec-bin/
    #@{list_events_to_filter}=        Create List    utcTimestampData    ulAllocatedPooledResourcesData    #dlAllocatedPooledResourcesData
    #...                              ulRimRsPooledResourcesData    reasonsOfDroppedRsDetection
    IF    ${list_events_to_filter} != ${None}
        TtiConvertInterface.Convert TTI capture    pcap_file_path=${TTIpcap}    events_list=${list_events_to_filter}
        ${status}   ${ret}            Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${json_tti_output}
        IF    "${status}" != "PASS"
            Dated Log                 > TTI decoding is failed because ${json_tti_output} is not found
        END
        Should Be True    "${status}" == "PASS"
    END
    Dated Log                         > TTI decoding is passed in ${json_tti_output}
    # ${path_to_json} is mandatory for decoding then create a symbolic link to ${json_tti_output}
    Run                               command=ln -fs ${json_tti_output} ${path_to_json}


#CR_NOT_TESTED#Create Dictionary With Common Parameters To Filter
#CR_NOT_TESTED##CB011127#Export TTI For CB011127


Get List Cells Retained For TTI Streaming SR-CR
    [Arguments]             ${cell_id_streaming}
    ...                     ${oam_type}=${GNB_DU.oam}
    #
    Dated Log New Line                ${cc_cyan}----Get List Cells Retained For TTI Streaming SR-CR----${cc_normal}
    @{list_cell_id}=                  Create List
    @{cellsNr}=                       Oam.OAM Get Cells Nr    oam=${oam_type}
#DEBUG_LOG#
#   Dated Log                         >> CellsNr=@{cellsNr}
    FOR    ${current_cell}    IN    @{cellsNr}
#DEBUG_LOG#
#       Dated Log                     >> cell NR is ${current_cell}
#       IF    not ${isAic}
#                  Dated Log          >> internal distname ${current_cell['id']['internal']}
#       ELSE
#                  Dated Log          >> internal distname ${current_cell['dist_names']['config']}
#       END
        ${cell_status_}=              Run Keyword If    not ${isAic}    Set variable  ${current_cell['status']}
        ${operationalState}=          Run Keyword If    not ${isAic}    Set Variable   ${cell_status_['operationalState']}
        ...                           ELSE    Set Variable   ${current_cell['operational_state']}
#DEBUG_LOG#
#       IF    not ${isAic}
#                  Dated Log          >> operationalState for DN [${current_cell['id']['internal']}] is ${operationalState}
#       ELSE
#                  Dated Log          >> operationalState for DN [${current_cell['dist_names']}] is ${operationalState}
#       END
        ${globalCellId}=              Run Keyword If    not ${isAic}    Set Variable   ${current_cell['globalCellId']}
        ...       ELSE                Set Variable   ${current_cell['id']}
        ${is_global_cell_id}=         Is Global Cell Id Retained For Streaming    global_cell_id=${globalCellId}    cell_list=${cell_id_streaming}
        Run Keyword If                ${is_global_cell_id} and not ${isAic}   Append to List    ${list_cell_id}    ${current_cell['id']['internal']}
        Run Keyword If                ${is_global_cell_id} and ${isAic}   Append to List   ${list_cell_id}   ${current_cell['dist_names']['config']}
    END
#DEBUG_LOG#
#   Dated Log                         >> Distname list of cells retained for TTI streaming ${list_cell_id}
    [Return]                          ${list_cell_id}


Is Global Cell Id Retained For Streaming
    [Arguments]             ${global_cell_id}
    ...                     ${cell_list}
    #
    ${result_global_cell}=            Set Variable    ${False}
    FOR    ${current_cell}    IN    @{cell_list}
#DEBUG_LOG#
#       Dated Log                     >> global cell id ${global_cell_id} vs. current cell ${current_cell}
#       Run Keyword If                ${result_global_cell} or ${global_cell_id}==${current_cell}
#       ...    Dated Log              >> True    ELSE    Dated Log    >> False
        ${result_global_cell}=        Run Keyword If    ${result_global_cell} or ${global_cell_id}==${current_cell}    Set Variable    ${True}
        ...       ELSE                Set Variable    ${False}
    END
#DEBUG_LOG#
#   Dated Log                         >> final result returned is ${result_global_cell}
    [Return]                          ${result_global_cell}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Counter And KPI #
#[VRF_NPS_AUTO-252]# Closed
Check Counter And KPI Constraints SR-CR
    [Arguments]             ${pm_path}
    ...                     ${test_name}
    ...                     ${localKpiFileName}=${None}
    #
    Dated Log New Line                ${cc_cyan}----Check Counter And KPI Constraints SR-CR----${cc_normal}
    ${localKpiFile}=                  Run Keyword If    "${localKpiFileName}" == "${None}"    Set Variable   ${None}
    ...           ELSE                Set Variable   ${CURDIR}/../../config/counter/constraint/${localKpiFileName}
    KPIs.KPI Evaluate                 pmFile=${pm_path}
    ...                               constraintsFile=${CURDIR}/../../config/counter/constraint/${test_name}.csv
    ...                               failOnError=${True}
    ...                               localKpiFile=${localKpiFile}
    Dated Log                         > Check counter and KPI constraints is ended


Collect And Check Counter And KPI Constraints SR-CR
    [Arguments]             ${param}
    ...                     ${capture_settings}
    #
    FOR    ${iteration_pm}    IN RANGE    1    ${param.pm_waiting_period} + 1
        Dated Log New Line            ${cc_cyan}----Collect And Check Counter And KPI Constraints SR-CR (${iteration_pm})----${cc_normal}
        IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
            ${syslog_monitoring}=     SYSLOG Start    host=${GNB_DU.sys[0].M}    name=monitoring_${iteration_pm}
        END
        #
        Wait PM availability          pmPeriodSec=300    #pmAvailDelay=60
        IF    ${isAic}
            ${pm_path}=               Counters.Collect PM files from BTS    ${LOG_PATH}/PM    optional_files=${True}  posProcess=${True}  node='vcu'
            Check Counter And KPI Constraints SR-CR    pm_path=${pm_path}    test_name=${param.counter_constraint}_VCU
            ${pm_path}=               Counters.Collect PM files from BTS    ${LOG_PATH}/PM    optional_files=${True}  posProcess=${True}  node='vdu'
            Check Counter And KPI Constraints SR-CR    pm_path=${pm_path}    test_name=${param.counter_constraint}_VDU
        ELSE
            ${pm_path}=               Counters.Collect PM files from BTS    ${LOG_PATH}/PM
            Check Counter And KPI Constraints SR-CR    pm_path=${pm_path}    test_name=${param.counter_constraint}
        END
        IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
                                      SYSLOG Stop    syslog=${syslog_monitoring}
        END
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Traffic #
DL+UL Traffic Not Stopped Common
    [Arguments]             ${param}
    ...                     ${current_ue_setting}
    ...                     ${current_trf_id}=1
    #
    Set To Dictionary                 ${current_ue_setting}    trf_id    ${current_trf_id}
    Run Keyword If                    ${current_ue_setting.throughput} > 0    Traffic UE DL    ueSetting=${current_ue_setting}
    ...                               throughput=${current_ue_setting.throughput}
    ...                               captureCallback=None
    ...                               capture=None
    ...                               captureDuration=0
    ...                               duration=${param.duration}
    ...                               shouldBeStop=False
    ...                               deviation=${param.deviation}
    #
    ${current_trf_id}=                Evaluate    ${current_trf_id} + 1    # 9
    Set To Dictionary                 ${current_ue_setting}    trf_id    ${current_trf_id}
    Run Keyword If                    ${current_ue_setting.throughput_ul} > 0    Traffic UE UL    ueSetting=${current_ue_setting}
    ...                               throughput=${current_ue_setting.throughput_ul}
    ...                               captureCallback=None
    ...                               capture=None
    ...                               captureDuration=0
    ...                               duration=${param.duration}
    ...                               shouldBeStop=False
    ...                               deviation=${param.deviation}


DL Traffic GBR SA Not Stopped
    [Arguments]             ${param}
    ...                     ${current_ue_setting}=${BASIC_UE_SA}
    ...                     ${current_trf_id}=20
    #
    # Step 1 on qfi=2 with protocol tcp
    Set To Dictionary                 ${current_ue_setting}    trf_id    ${current_trf_id}
    Set To Dictionary                 ${current_ue_setting}    qfi    2
    Run Keyword If                    ${current_ue_setting.throughput_gbr} > 0    Traffic UE DL    ueSetting=${current_ue_setting}
    ...                               throughput=${current_ue_setting.throughput_gbr}
    ...                               captureCallback=None
    ...                               capture=None
    ...                               captureDuration=0
    ...                               duration=${param.duration}
    ...                               shouldBeStop=False
    ...                               deviation=${param.deviation}
    ...                               protocol=tcp
    # Step 2 on qfi=3 with protocol udp
    ${current_trf_id}=                Evaluate    ${current_trf_id} + 1
    Set To Dictionary                 ${current_ue_setting}    trf_id    ${current_trf_id}
    Set To Dictionary                 ${current_ue_setting}    qfi    3
    Run Keyword If                    ${current_ue_setting.throughput_gbr} > 0    Traffic UE DL    ueSetting=${current_ue_setting}
    ...                               throughput=${current_ue_setting.throughput_gbr}
    ...                               captureCallback=None
    ...                               capture=None
    ...                               captureDuration=0
    ...                               duration=${param.duration}
    ...                               shouldBeStop=False
    ...                               deviation=${param.deviation}
    ...                               protocol=udp


UL Traffic GBR SA Not Stopped
    [Arguments]             ${param}
    ...                     ${current_ue_setting}=${BASIC_UE_SA}
    ...                     ${current_trf_id}=22
    #
    # Step 1 on qfi=2 with protocol tcp
    Set To Dictionary                 ${current_ue_setting}    trf_id    ${current_trf_id}
    Set To Dictionary                 ${current_ue_setting}    qfi    2
    Run Keyword If                    ${current_ue_setting.throughput_gbr} > 0    Traffic UE UL    ueSetting=${current_ue_setting}
    ...                               throughput=${current_ue_setting.throughput_gbr}
    ...                               captureCallback=None
    ...                               capture=None
    ...                               captureDuration=0
    ...                               duration=${param.duration}
    ...                               shouldBeStop=False
    ...                               deviation=${param.deviation}
    ...                               protocol=tcp
    # Step 2 on qfi=3 with protocol udp
    ${current_trf_id}=                Evaluate    ${current_trf_id} + 1
    Set To Dictionary                 ${current_ue_setting}    trf_id    ${current_trf_id}
    Set To Dictionary                 ${current_ue_setting}    qfi    3
    Run Keyword If                    ${current_ue_setting.throughput_gbr} > 0    Traffic UE UL    ueSetting=${current_ue_setting}
    ...                               throughput=${current_ue_setting.throughput_gbr}
    ...                               captureCallback=None
    ...                               capture=None
    ...                               captureDuration=0
    ...                               duration=${param.duration}
    ...                               shouldBeStop=False
    ...                               deviation=${param.deviation}
    ...                               protocol=udp
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Alarm #
Get Number Of Alarm
    [Arguments]             ${oam_type}=${GNB_DU.oam}
    #
    @{alarms}=                        OAM Get Active Alarms    oam=${oam_type}
    ${nb_of_alarm}=                   Get Length    ${alarms}
    [Return]                          ${nb_of_alarm}


#[VRF_NPS_AUTO-251]# Closed
Detection Alarm Id
    [Arguments]             ${alarm_id}=7101
    ...                     ${fault_id}=4383
    ...                     ${alarm_object}=${None}
    ...                     ${suppl_info}=${None}
    ...                     ${oam_type}=${GNB_DU.oam}
    ...                     ${confirm_presence}=${True}
    #
    Dated Log New Line                ${cc_cyan}----Detection Alarm----${cc_normal}
    @{alarms}=                        OAM Get Active Alarms    oam=${oam_type}
    ${nb_of_alarm}=                   Get Length    ${alarms}
    ${flag_alarm_id}=                 Set Variable    ${False}
    ${flag_fault_id}=                 Set Variable    ${False}
    ${flag_alarm_object}=             Set Variable    ${False}
    ${flag_alarm_suppl}=              Set Variable    ${False}
    ${i}=                             Set Variable    ${0}
    IF    ${nb_of_alarm} > 0
        FOR    ${alarm}    IN    @{alarms}
            ${i}=                     Evaluate    ${i}+${1}
            ${result}=                Replace String    ${alarm}    ]    [
            @{alarm_words}=           Split String    ${result}    separator=[
            Remove Values From List   ${alarm_words}    ${EMPTY}
            Remove Values From List   ${alarm_words}    ${SPACE}
            ${flag_alarm_id}=         Set Variable    ${False}
            ${flag_fault_id}=         Set Variable    ${False}
            IF    ${alarm_words[0]} == ${alarm_id}
                ${flag_alarm_id}=     Set Variable    ${True}
            END
            IF    ${alarm_words[1]} == ${fault_id} or "${fault_id}" == "${None}"
                ${flag_fault_id}=     Set Variable    ${True}
            END
#DEBUG_LOG#
#           Dated Log                 >> alarm_words_object= ${alarm_words}
            ${is_object_present}=     Run Keyword And Return Status    Should Contain    ${alarm_words[3]}    ${alarm_object}
            ${flag_alarm_object}=     Set Variable    ${False}
            IF    ${is_object_present} or "${alarm_object}" == "${None}"
                ${flag_alarm_object}=    Set Variable    ${True}
            END
            IF    ${isAic}
                ${is_suppl_present}=  Set Variable    ${False}
            ELSE
                ${is_suppl_present}=  Run Keyword And Return Status    Should Contain    ${alarm_words[4]}    ${suppl_info}
            END
            ${flag_alarm_suppl}=      Set Variable    ${False}
            IF    ${is_suppl_present} or "${suppl_info}" == "${None}"
                ${flag_alarm_suppl}=  Set Variable    ${True}
#DEBUG_LOG#
#               Dated Log             >> alarm_words_4= ${alarm_words[4]} suppl_info= ${suppl_info} <=> is_suppl_present= ${is_suppl_present}
            END
            Exit For Loop If          ${flag_alarm_id} and ${flag_fault_id} and ${flag_alarm_object} and ${flag_alarm_suppl}
        END
    END
    IF    ${flag_alarm_id} and ${flag_fault_id} and ${flag_alarm_object} and ${flag_alarm_suppl}
        ${iteration_alarm}=           Set Variable    ${alarm}
        Dated Log                     ${cc_yellow}> Alarm [${alarm_id}] with fault [${fault_id}] is detected on object=${alarm_object} ${cc_normal}
        Dated Log                     ${cc_yellow}> GNB_DU_OAM_ALARM[${i}]=${iteration_alarm} ${cc_normal}
    ELSE
        ${iteration_alarm}=           Set Variable    ${None}
        Dated Log                     ${cc_green}> Alarm [${alarm_id}] with fault [${fault_id}] is NOT detected ${cc_normal}
    END
    IF    ${flag_fault_id} and "${fault_id}" != "${None}"
        ${fault_id_word}=             Set Variable    ${alarm_words[1]}
    ELSE
        ${fault_id_word}=             Set Variable    ${None}
    END
    IF    ${flag_alarm_id} and ${flag_fault_id} and ${flag_alarm_object} and ${flag_alarm_suppl} and ${confirm_presence}
                                      Should Be True    "${fault_id}" == "${fault_id_word}"
    END
    [Return]                          ${iteration_alarm}


Is Alarm Present
    [Arguments]             ${alarm_id}
    ...                     ${fault_id}
    ...                     ${alarm_object}=${None}
    ...                     ${oam_type}=${GNB_DU.oam}
    ...                     ${iteration}=5
    ...                     ${delay_iteration}=5s
    ...                     ${confirm_presence}=${True}
    #
    FOR    ${current_it}    IN RANGE    1    ${iteration} + 1
        IF    "${alarm_object}" == "${None}"
            Dated Log                 ----Is Alarm [${alarm_id}][${fault_id}] Present (${current_it}/${iteration})----
        ELSE
            Dated Log                 ----Is Alarm [${alarm_id}][${fault_id}] Present on object=${alarm_object} (${current_it}/${iteration})----
        END
        ${alarm_information}=         Detection Alarm Id    alarm_id=${alarm_id}    fault_id=${fault_id}    alarm_object=${alarm_object}
        ...                           confirm_presence=${confirm_presence}    oam_type=${oam_type}
#DEBUG_LOG#
#       Dated Log                     >> alarm_information= ${alarm_information}
        Exit For Loop If              "${alarm_information}" != "${None}"
        Sleep                         ${delay_iteration}
    END
    # Alarm must be found after ${iteration} attempts
    IF    "${alarm_information}" != "${None}"
        ${is_present}=                Set Variable    ${True}
    ELSE
        ${is_present}=                Set Variable    ${False}
    END
    IF    ${confirm_presence}
                                      Should Be True    ${is_present} == ${True}
    END
    [Return]                          ${is_present}
# --------------------------------------------------------------------------------------------------------------------------------------------------
#[VRF_NPS_AUTO-259]# Closed
Get NRCELL Parameters SR-CR
    [Arguments]             ${dico}
    ...                     ${nrcell_key}
    ...                     ${list_nrcell}
    ...                     ${extra_dist_name}=${None}
    #
    Dated Log New Line                ${cc_cyan}----Get NRCELL Parameters SR-CR----${cc_normal}
    Dated Log                         > from ${list_nrcell}
    ${k_nrcell_list}=                 Is Parameter A Dictionary Key    dict=${dico}    parameter=${nrcell_key}
    Should Be True                    ${k_nrcell_list} == ${True}
    IF    not ${isAic}
        ${mode}=                      Set Variable    Classical
        # Create list of parameters from dico for Classical
        ${parameter_list}=            Create List
        FOR    ${key}    ${value}     IN    &{dico}
            Append To List            ${parameter_list}    ${key}
        END
    ELSE
        ${mode}=                      Set Variable    Both
        ${parameter_list}=            Evaluate    next(iter(${dico}))
    END
#DEBUG_LOG#
#   Dated Log                         >> parameter_list=${parameter_list}
    ${list_result}=                   Create List
    FOR    ${position}    IN    @{dico}[${nrcell_key}]
        ${internal_pos}=              Evaluate    ${position}-1
        ${dn_object}=                 Set Variable    ${dn_nrbts}/NRCELL-${list_nrcell[${internal_pos}].nrCellId}
        IF    "${extra_dist_name}" != "${None}"
            ${dn_object}=             Set Variable    ${dn_nrbts}/NRCELL-${list_nrcell[${internal_pos}].nrCellId}/${extra_dist_name}
        END
#DEBUG_LOG#
#       Dated Log                     >> dn_object=${dn_object}
        IF    not ${isAic}
            ${entity_oam}=            Set Variable    ${GNB_DU.oam}
        ELSE
            ${entity_oam}=            Set Variable    ${TGNB_DU[0].oam}
        END
#DEBUG_LOG#
#       Dated Log                     >> entity_oam=${entity_oam}
        ${result}=                    Oam.OAM Get Parameter By Distname    oam=${entity_oam}
        ...                           dist_name=${dn_object}
        ...                           parameter_list=${parameter_list}
        ...                           include_children=${False}
        ...                           timeout=30
        ...                           detailed_output=${False}
        Dated Log                     > OAM Get Parameter By Distname= ${result}
        IF    not ${isAic}
            IF    ${result} != ${None}
                ${len_result}=            Get Length    ${result}
                IF    ${len_result} != 0
                    Append To List        ${list_result}    ${result}
                END
            END
        ELSE
            Append To List        ${list_result}    ${result}
        END
    END
    Dated Log                         >> list_result= ${list_result}
    [Return]                          ${list_result}


Evaluate Value in Range
    [Arguments]             ${reference}
    ...                     ${value}
    ...                     ${percentage_tolerance}=10
    #
    IF    ${percentage_tolerance} > 0
        ${tolerance}=                 Evaluate    ${percentage_tolerance} / 100    #DEBUG#
    ELSE
        ${tolerance}=                 Set Variable    0
    END
    ${min_tolerance}=                 Evaluate    1 - ${tolerance}
    ${max_tolerance}=                 Evaluate    1 + ${tolerance}
    IF    ${value} < 1    # value is negative
        ${float_min_value}=           Evaluate    ${reference} * ${max_tolerance}
        ${float_max_value}=           Evaluate    ${reference} * ${min_tolerance}
    ELSE                  # value is positive
        ${float_min_value}=           Evaluate    ${reference} * ${min_tolerance}
        ${float_max_value}=           Evaluate    ${reference} * ${max_tolerance}
    END
    ${min_value}=                     Convert To Integer    ${float_min_value}
    ${max_value}=                     Convert To Integer    ${float_max_value}
    Dated Log                         > ${min_value} <= ${value} <= ${max_value} ?
    IF    ${min_value} <= ${value} <= ${max_value}
        Dated Log                     ${cc_green}> ${value} is within the range (${min_value}, ${max_value})${cc_normal}
        ${result}=                    Set Variable    ${True}
    ELSE
        Dated Log                     ${cc_red}> ${value} is not within the range (${min_value}, ${max_value})${cc_normal}
        ${result}=                    Set Variable    ${False}
    END
    Should Be True                    ${result}
    [Return]                          ${result}


Check NRRIMINFO Parameters
    [Arguments]             ${dico}
    ...                     ${list_elem}
    ...                     ${percentage_tolerance}=10
    #
    Dated Log                         ${cc_cyan}----Check NRRIMINFO Parameters----${cc_normal}
    ${k_nrRimInfoId}=                 Is Parameter A Dictionary Key    dict=${dico}    parameter=nrRimInfoId
    ${k_riState}=                     Is Parameter A Dictionary Key    dict=${dico}    parameter=riState
    ${k_riThresBasePerSubband}=       Is Parameter A Dictionary Key    dict=${dico}    parameter=riThresBasePerSubband
    #
    ${len_list_elem}=                 Get Length    ${list_elem}
    IF    ${len_list_elem} == 0
        ${check_result}=              Set Variable    ${False}
        Dated Log                     ${cc_yellow}> Check NRRIMINFO Parameters is NOT POSSIBLE because list of information is empty${cc_normal}
    ELSE
        ${check_result}=              Set Variable    ${True}
        FOR    ${current_elem}    IN      @{list_elem}
#DEBUG_LOG#
#           Dated Log                 >> current_elem= ${current_elem}
            ${first_dico}=            Set Variable    ${current_elem}[0]
            Dated Log                 > check NRRIMINFO result of ${first_dico}[distName]
            ${parameters}=            Set Variable    ${first_dico}[parameters]
#DEBUG_LOG#
#           Dated Log                 >> parameters=${parameters}
            # NRCELL.nrRimInfoId / check
            ${current_param}=         Set Variable    nrRimInfoId
            IF    ${k_nrRimInfoId}
                IF    "${dico}[${current_param}]" != "${None}"
                    Dated Log         >> comparison between ${parameters}[${current_param}] and ${dico}[${current_param}]
                    IF    "${parameters}[${current_param}]" != "${dico}[${current_param}]"
                        ${check_result}=    Set Variable    ${False}
                    ELSE
                        Dated Log     ${cc_green}> check of ${current_param} is successfully completed${cc_normal}
                    END
                END
            END
            # NRCELL.riState / check
            ${current_param}=         Set Variable    riState
            IF    ${k_riState}
                IF    "${dico}[${current_param}]" != "${None}"
                    Dated Log         >> comparison between ${parameters}[${current_param}] and ${dico}[${current_param}]
                    IF    "${parameters}[${current_param}]" != "${dico}[${current_param}]"
                        ${check_result}=    Set Variable    ${False}
                    ELSE
                        Dated Log     ${cc_green}> check of ${current_param} is successfully completed${cc_normal}
                    END
                END
            END
            # NRCELL.riThresBasePerSubband / check
            ${current_param}=         Set Variable    riThresBasePerSubband
            IF    ${k_riThresBasePerSubband}
                IF    "${dico}[${current_param}]" != "${None}"
                    ${len_riThresBasePerSubband}=    Get Length    ${dico}[${current_param}]
                    ${current_riThresBasePerSubband}=    Set Variable    ${parameters}[${current_param}]
                    ${dico_perSubband}=    Set Variable    ${current_riThresBasePerSubband}[0]
                    Dated Log          >> riThresBasePerSubband= ${dico_perSubband}
                    FOR    ${current_elem}    IN RANGE    0    ${len_riThresBasePerSubband}
#DEBUG_LOG#
#                       Dated Log     >> check ${dico_perSubband}[riThresBaseSubband${current_elem}] and ${dico}[${current_param}][${current_elem}]
                        ${check_result}=    Evaluate Value in Range    reference=${dico}[${current_param}][${current_elem}]
                        ...           value=${dico_perSubband}[riThresBaseSubband${current_elem}]    percentage_tolerance=${percentage_tolerance}
                        IF    ${check_result}
                          Dated Log   ${cc_green}> check of riThresBaseSubband${current_elem} is successfully completed${cc_normal}
                        END
                        Exit For Loop If    not ${check_result}
                    END
                END
            END
#OBSOLETE#
#           Exit For Loop If    not ${check_result}
        END
#OBSOLETE#
#       Should Be True    ${check_result}
    END
    [Return]                          ${check_result}


Check NRRIMINFO Parameter riThresBasePerSubband CR
    [Arguments]             ${dico}
    ...                     ${list_elem}
    ...                     ${percentage_tolerance}=10
    #
    Dated Log                         ${cc_blue}----Check NRRIMINFO Parameter riThresBasePerSubband CR----${cc_normal}
    ${k_riThresBasePerSubband}=       Is Parameter A Dictionary Key    dict=${dico}    parameter=riThresBasePerSubband
    #
    IF    ${k_riThresBasePerSubband}
        ${len_riThresBasePerSubband}=    Get Length    ${dico}[riThresBasePerSubband]
    END
    FOR    ${current_elem}    IN      @{list_elem}
#DEBUG_LOG#
#       Dated Log                     >> riThresBasePerSubband= ${current_elem}[0]
        FOR    ${riThresBasePerSubband_elem}    IN      @{current_elem}[0]
#DEBUG_LOG#
#           Dated Log                 >> riThresBasePerSubband_elem=${riThresBasePerSubband_elem}
#           Dated Log                 >> riThresBasePerSubband_elem.name=${riThresBasePerSubband_elem['name']}
            ${value_dict}=            Evaluate    json.loads('''${riThresBasePerSubband_elem['value']}''')    json
#DEBUG_LOG#
#           Dated Log                 >> riThresBasePerSubband_elem.value=${value_dict}
            # NRCELL.riThresBaseSubband0 / check
            IF    ${k_riThresBasePerSubband}
                IF    ${len_riThresBasePerSubband} > 0 and "${riThresBasePerSubband_elem['name']}" == "riThresBaseSubband0"
                    ${current_param}=     Set Variable    riThresBaseSubband0
                    ${current_value}=     Set Variable    ${value_dict['currentValue']}
                    Dated Log             > current_value for ${current_param}=${current_value}
                    ${check_result}=      Evaluate Value in Range    reference=${dico}[riThresBasePerSubband][0]
                    ...                   value=${current_value}    percentage_tolerance=${percentage_tolerance}
                    IF    ${check_result}
                        Dated Log         ${cc_green}> check of ${current_param} is successfully completed${cc_normal}
                    END
                END
            END
            # NRCELL.riThresBaseSubband1 / check
            IF    ${k_riThresBasePerSubband}
                IF    ${len_riThresBasePerSubband} > 1 and "${riThresBasePerSubband_elem['name']}" == "riThresBaseSubband1"
                    ${current_param}=     Set Variable    riThresBaseSubband1
                    ${current_value}=     Set Variable    ${value_dict['currentValue']}
                    Dated Log             > current_value for ${current_param}=${current_value}
                    ${check_result}=      Evaluate Value in Range    reference=${dico}[riThresBasePerSubband][1]
                    ...                   value=${current_value}    percentage_tolerance=${percentage_tolerance}
                    IF    ${check_result}
                        Dated Log         ${cc_green}> check of ${current_param} is successfully completed${cc_normal}
                    END
                END
            END
            # NRCELL.riThresBaseSubband2 / check
            IF    ${k_riThresBasePerSubband}
                IF    ${len_riThresBasePerSubband} > 2 and "${riThresBasePerSubband_elem['name']}" == "riThresBaseSubband2"
                    ${current_param}=     Set Variable    riThresBaseSubband2
                    ${current_value}=     Set Variable    ${value_dict['currentValue']}
                    Dated Log             > current_value for ${current_param}=${current_value}
                    ${check_result}=      Evaluate Value in Range    reference=${dico}[riThresBasePerSubband][2]
                    ...                   value=${current_value}    percentage_tolerance=${percentage_tolerance}
                    IF    ${check_result}
                        Dated Log         ${cc_green}> check of ${current_param} is successfully completed${cc_normal}
                    END
                END
            END
            # NRCELL.riThresBaseSubband3 / check
            IF    ${k_riThresBasePerSubband}
                IF    ${len_riThresBasePerSubband} > 3 and "${riThresBasePerSubband_elem['name']}" == "riThresBaseSubband3"
                    ${current_param}=     Set Variable    riThresBaseSubband3
                    ${current_value}=     Set Variable    ${value_dict['currentValue']}
                    Dated Log             > current_value for ${current_param}=${current_value}
                    ${check_result}=      Evaluate Value in Range    reference=${dico}[riThresBasePerSubband][3]
                    ...                   value=${current_value}    percentage_tolerance=${percentage_tolerance}
                    IF    ${check_result}
                        Dated Log         ${cc_green}> check of ${current_param} is successfully completed${cc_normal}
                    END
                END
            END
            # NRCELL.riThresBaseSubband4 / check
            IF    ${k_riThresBasePerSubband}
                IF    ${len_riThresBasePerSubband} > 4 and "${riThresBasePerSubband_elem['name']}" == "riThresBaseSubband4"
                    ${current_param}=     Set Variable    riThresBaseSubband4
                    ${current_value}=     Set Variable    ${value_dict['currentValue']}
                    Dated Log             > current_value for ${current_param}=${current_value}
                    ${check_result}=      Evaluate Value in Range    reference=${dico}[riThresBasePerSubband][4]
                    ...                   value=${current_value}    percentage_tolerance=${percentage_tolerance}
                    IF    ${check_result}
                        Dated Log         ${cc_green}> check of ${current_param} is successfully completed${cc_normal}
                    END
                END
            END
        END
        #
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Verifications # CB008375-D #
#CR_NOT_TESTED#Execute Command And Check Content
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Verifications # CB011127-A #
#CR_NOT_TESTED##CB011127#CB011127 Execute Command And Check Content
# --------------------------------------------------------------------------------------------------------------------------------------------------
Create Csi Override Nr Profile
    [Arguments]             ${profile_id}
    ...                     ${cqi_val}
    ...                     ${cqi_mode}=fixed
    ...                     ${ri_val}=${None}
    ...                     ${pmi_val}=${None}
    #
    Dated Log New Line                ${cc_cyan}----Create Csi Override Testmode Nr Profile----${cc_normal}
    IF    "${cqi_mode}" != "${None}"
                                      wtsemu.csi_override_testmode_nr    profile_id=${profile_id}    cqi=${cqi_val}    cqi_mode=fixed
                                      wtsemu.read_wtsemu_output_until_prompt    timeout=10
        Dated Log                     > csi_override_testmode_nr profile_id=${profile_id} cqi=${cqi_val} cqi_mode=fixed
    ELSE
                                      wtsemu.csi_override_testmode_nr    profile_id=${profile_id}    cqi=${cqi_val}    ri=${ri_val}   pmi=${pmi_val}
                                      wtsemu.read_wtsemu_output_until_prompt    timeout=10
        Dated Log                     > csi_override_testmode_nr profile_id=${profile_id} cqi=${cqi_val} ri=${ri_val} pmi=${pmi_val}
    END


Testmode Csi Override
    [Arguments]             ${profile_id}
    ...                     ${nrcell}
    ...                     ${ue_id}
    ...                     ${action}
    #
    Dated Log New Line                ${cc_cyan}----Testmode Csi Override----${cc_normal}
    wtsemu.ue_testmode_set_nr         id=${ue_id}    scell=${nrcell}    testmode=csi_override    profile_id=${profile_id}    action=${action}
    wtsemu.read_wtsemu_output_until_prompt    timeout=10
    Dated Log                         > ue_testmode_set_nr id=${ue_id} scell=${nrcell} testmode=csi_override prof_id=${profile_id} action=${action}


Testmode Paging Start
    [Arguments]             ${ue_id}
    ...                     ${default_drx}=128
    ...                     ${max_paging}=5
    ...                     ${cause_release}=NAS_normal_release
    #
    Dated Log New Line                ${cc_cyan}----Testmode Paging Start for UE${ue_id}----${cc_normal}
    wtsemu.amf_paging_param           id=1    default_drx=${default_drx}    max_paging_retries=${max_paging}
    wtsemu.read_wtsemu_output_until_prompt    timeout=10
    #
    wtsemu.ue_ng_ctx_release          id=${ue_id}    cause=${cause_release}
    ${status}    ${output}            Run Keyword And Ignore Error    wtsemu.read_wtsemu_output_until
    ...                               expected=UE${ue_id}: IS IDLE    timeout=10
    Run Keyword If                    "${status}" == "FAIL"    Fail    ACTIVE-IDLE state is not found
    Return From Keyword If            "${status}" == "FAIL"
    ${output_1}=                      Get Lines Matching Regexp    ${output}    UE.*in NAS-.*ACTIVE-IDLE    partial_match=${TRUE}
    Log to Console                    ${output_1}
    ${output_2}=                      Get Lines Matching Regexp    ${output}    UE.*IS IDLE    partial_match=${TRUE}
    Log to Console                    ${output_2}
    #
    ${output}=                        wtsemu.amf_paging_start    id=1    ueid=${ue_id}
    ${status}    ${output}            Run Keyword And Ignore Error    wtsemu.read_wtsemu_output_until
    ...                               expected=PagingProcedure is in progress    timeout=10
    Run Keyword If                    "${status}" == "FAIL"    Fail    PagingProcedure in progress state is not found
    Return From Keyword If            "${status}" == "FAIL"
    ${output_1}=                      Get Lines Matching Regexp    ${output}    Paging UE with.*    partial_match=${TRUE}
    Log to Console                    ${output_1}
    ${output_2}=                      Get Lines Matching Regexp    ${output}    UE.*paged on.*    partial_match=${TRUE}
    Log to Console                    ${output_2}
    ${output_3}=                      Get Lines Matching Regexp    ${output}    UE.*Paging.*is in progress    partial_match=${TRUE}
    Log to Console                    ${output_3}
    Sleep                             1s
    #
    ${output}=                        wtsemu.amf_paging_param_disp    id=1    ue=${ue_id}
    wtsemu.read_wtsemu_output_until_prompt    timeout=10


Testmode UE Measurement Send NR
    [Arguments]             ${ue_id}
    ...                     ${physical_target_cell_id}
    ...                     ${meas_id}=1
    ...                     ${event_type}=A3
    #
    Dated Log New Line                ${cc_cyan}----Testmode UE Measurement Send NR----${cc_normal}
    Dated Log                         > meas_id= ${meas_id} event= ${event_type} target= ${physical_target_cell_id} requested for ue= ${ue_id}
    # wtsemu.ue_measurement_send_nr   id=1    meas_id=1    event=A3    srsrp_nr=20    phycell_id=51    nrsrp_nr=90
    # rs_type=ssb    index=0    nrs_result=11:12:13 <= to avoid cp_rt warning when ssb-result is empty
    wtsemu.ue_measurement_send_nr     id=${ue_id}    meas_id=${meas_id}    event=${event_type}    phycell_id=${physical_target_cell_id}
    ...                               srsrp_nr=20    nrsrp_nr=90    rs_type=ssb    index=0    nrs_result=11:12:13
    Dated Log                         > waiting for measurement report message
    ${output}=                        wtsemu.Read Wtsemu Output Until    expected=measurementReport    timeout=10
    Dated Log                         > waiting for RRC reconfiguration complete message
    ${output_2}=                      wtsemu.Read Wtsemu Output Until    expected=rrcReconfigurationComplete    timeout=10
    #EGATE>  10:14:43.960  INF : UEC-1: UE1: reconfigurationWithSync with physCellId 51 is pres
    #ent in masterCellGroup. Handover will be triggered using CFRA.
    #Should Contain                   ${output_2}    reconfigurationWithSync with physCellId
    #${pattern_match_1}=            Set Variable    ^.*UE${ue_id}:\\s+reconfigurationWithSync\\s+with\\s+physCellId\\s+${physical_target_cell_id}.*$
    ${pattern_match_1}=               Set Variable    UE${ue_id}:\\s+reconfigurationWithSync\\s+with\\s+physCellId\\s+${physical_target_cell_id}
    ${result_match_1}=                Should Match Regexp    string=${output_2}    pattern=${pattern_match_1}
    Dated Log                         > match= ${result_match_1}
    #EGATE>  10:14:43.973  INF : UEC-1: UE1: CTRL_ADD_UE_HO_NR_RSP_T Received
    #${pattern_match_2}=              Set Variable    ^.*UE${ue_id}:\\s+CTRL_ADD_UE_HO_NR_RSP_T\\s+Received.*$
    ${pattern_match_2}=               Set Variable    UE${ue_id}:\\s+CTRL_ADD_UE_HO_NR_RSP_T\\s+Received
    ${result_match_2}=                Should Match Regexp    string=${output_2}    pattern=${pattern_match_2}
    Dated Log                         > match= ${result_match_2}
    #EGATE>  10:14:43.984  INF : UEC-1: UE1: CTRL_RACH_COMPLETE Received
    #${pattern_match_3}=              Set Variable    ^.*UE${ue_id}:\\s+CTRL_RACH_COMPLETE\\s+Received.*$
    ${pattern_match_3}=               Set Variable    UE${ue_id}:\\s+CTRL_RACH_COMPLETE\\s+Received
    ${result_match_3}=                Should Match Regexp    string=${output_2}    pattern=${pattern_match_3}
    Dated Log                         > match= ${result_match_3}
    #EGATE>  10:14:43.984  INF : UEC-1: UE1: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2
    #performed (crnti: 49042 = 0xBF92)
    #${pattern_match_4}=              Set Variable    ^.*UE${ue_id}:\\s+Intra-eNB\\s+handover\\s+from.*to\\s+EXT_ENB-\\d+\.\\d+.*$
    ${pattern_match_4}=               Set Variable    UE${ue_id}:\\s+Intra-eNB\\s+handover\\s+from.*to\\s+EXT_ENB-\\d+\.\\d+
    ${result_match_4}=                Should Match Regexp    string=${output_2}    pattern=${pattern_match_4}
    Dated Log                         > match= ${result_match_4}
    #${pattern_match_5}=              Set Variable    ^.*performed\\s+\\(crnti:\\s+(\\d+)\\s+=\\s+0x\\w+\\).*$
    ${pattern_match_5}=               Set Variable    performed\\s+\\(crnti:\\s+(\\d+)\\s+=\\s+0x\\w+\\)
    ${result_match_5}    ${group_1}=    Should Match Regexp    string=${output_2}    pattern=${pattern_match_5}
    Dated Log                         > match= ${result_match_5}
    Dated Log                         > ue= ${ue_id}, new c_rnti= ${group_1}
    [Return]                          ${group_1}


# Testmode by using wtsemu.script #
Create And Execute Egate Script
    [Arguments]             ${testmode}
    ...                     ${dico_tm}
    ...                     ${script_path}=/tmp/script.sce
    ...                     ${option_remove}=${True}
    ...                     ${option_sleep}=${None}
    #
    Dated Log New Line                ${cc_cyan}----Create And Execute Egate Script for testmode=${testmode}----${cc_normal}
    ${arguments_tm}=                  Convert Dictionary to Parameter String    kwargs=${dico_tm}
    Run Keyword If                    ${option_remove}    OperatingSystem.Remove File    path=${script_path}
    # append or create file containing testmode
    OperatingSystem.Append To File    path=${script_path}    content=${testmode} ${arguments_tm}\n
    Run Keyword If                    "${option_sleep}" != "${None}"
    ...                               OperatingSystem.Append To File    path=${script_path}    content=script_sleep ${option_sleep}\n
    wtsemu.script                     file=${script_path}
    Dated Log                         > rimrs_testmode_nr${arguments_tm}
    wtsemu.read_wtsemu_output_until_prompt    timeout=10


Create RI Testmode NR Profile
    [Arguments]             ${profile_id}
    ...                     ${noise_power_val}
    ...                     ${start_symbol_pos}=0
    ...                     ${num_symbols}=32
    #
    Dated Log New Line                ${cc_cyan}----Create RI Testmode NR Profile----${cc_normal}
    # remote_interference_testmode_nr profile_id=1 start_symbol_position=0 num_of_symbols=32 noise_power_values
    #-75,-77,-75,-77,-75,-77,-75,-77,-75,-83,-85,-83,-85,-83,-85,-83,-85,-83,-75,-77,-75,-77,-75,-77,-75,-77,-75,-77,-75,-115,-115,-115
    wtsemu.remote_interference_testmode_nr    profile_id=${profile_id}
    ...                               start_symbol_position=${start_symbol_pos}
    ...                               num_of_symbols=${num_symbols}
    ...                               noise_power_values=${noise_power_val}
    #
    wtsemu.read_wtsemu_output_until_prompt    timeout=10
    Sleep                             1s
    Dated Log                         > remote_interference_testmode_nr profile=${profile_id}
    Dated Log                         > start symbol=${start_symbol_pos} number symbols=${num_symbols} noise power values=${noise_power_val}


Cell Testmode Remote Interference
    [Arguments]             ${profile_id}
    ...                     ${nrcell_id}
    ...                     ${action}
    ...                     ${gnb_id}=2
    #
    Dated Log New Line                ${cc_cyan}----Cell Testmode Remote Interference----${cc_normal}
    wtsemu.cell_testmode_set_nr       gnb=${gnb_id}    cell_id=${nrcell_id}    testmode=remote_interference
    ...                                                             profile_id=${profile_id}    action=${action}
    wtsemu.read_wtsemu_output_until_prompt    timeout=10
    Sleep                             1s
    Dated Log                         > cell_testmode_set_nr cell=${nrcell_id} testmode=remote_interference profile=${profile_id} action=${action}


Cell Testmode RIM RS
    [Arguments]             ${profile_id}
    ...                     ${nrcell_id}
    ...                     ${action}
    ...                     ${gnb_id}=2
    #
    Dated Log New Line                ${cc_cyan}----Cell Testmode RIM RS----${cc_normal}
    wtsemu.cell_testmode_set_nr       gnb=${gnb_id}    cell_id=${nrcell_id}    testmode=rim_rs    profile_id=${profile_id}    action=${action}
    wtsemu.read_wtsemu_output_until_prompt    timeout=10
    Sleep                             1s
    Dated Log                         > cell_testmode_set_nr cell=${nrcell_id} testmode=rim_rs profile=${profile_id} action=${action}


Start Remote Interference on NRCELL
    [Arguments]             ${nrcell_pos_victim}
    ...                     ${list_nrcell}
    ...                     ${profile_id}=1
    #
    ${internal_pos}=                  Evaluate    ${nrcell_pos_victim}-1
    ${victim_cell}=                   Set Variable    ${list_nrcell[${internal_pos}].nrCellId}
    ${current_nrcell}=                Set Variable    ${dn_nrbts}/NRCELL-${victim_cell}
    ${dn_nrrim_profile}=              Set Variable    ${current_nrcell}/NRRIM_PROFILE-1
    Dated Log                         ${cc_cyan}----Start Remote Interference on NRCELL-${victim_cell}----${cc_normal}
    # step 1: wtsemu > remote_interference_testmode_nr
    Cell Testmode Remote Interference    profile_id=${profile_id}    nrcell_id=${victim_cell}    action=activate


Stop Remote Interference on NRCELL
    [Arguments]             ${nrcell_pos_victim}
    ...                     ${list_nrcell}
    ...                     ${profile_id}=${None}
    #
    ${internal_pos}=                  Evaluate    ${nrcell_pos_victim}-1
    ${victim_cell}=                   Set Variable    ${list_nrcell[${internal_pos}].nrCellId}
    Dated Log                         ${cc_cyan}----Stop Remote Interference on NRCELL-${victim_cell}----${cc_normal}
    ${p_id}=    Run Keyword If        "${profile_id}" == "${None}"    Set Variable    ${victim_cell}    ELSE    Set Variable    ${profile_id}
    Cell Testmode Remote Interference    profile_id=${p_id}    nrcell_id=${victim_cell}    action=deactivate


Start RIM RS on NRCELL
    [Arguments]             ${nrcell_pos_victim}
    ...                     ${list_nrcell}
    ...                     ${input}
    #
    ${internal_pos}=                  Evaluate    ${nrcell_pos_victim}-1
    ${victim_cell}=                   Set Variable    ${list_nrcell[${internal_pos}].nrCellId}
    ${current_nrcell}=                Set Variable    ${dn_nrbts}/NRCELL-${victim_cell}
    ${dn_nrrim_profile}=              Set Variable    ${current_nrcell}/NRRIM_PROFILE-1
    Dated Log                         ${cc_cyan}----Start RIM RS on NRCELL-${victim_cell}----${cc_normal}
    ${profile_id}=                    Set Variable    ${victim_cell}
    # step 2: wtsemu > rimrs_testmode_nr
    # NRCELL.actNrRim / get
    ${current_param}=                 Set Variable    actNrRim
    ${nb_match}    ${result}          Get Values From Object    dist_name=${current_nrcell}    p_name=${current_param}
    ...                               current_scf=${updated_scf}
    Should Be True                    ${nb_match} > 0
    Dated Log                         >> match for ${current_nrcell}: ${current_param}= ${result}
    ${current_framework}=             Set Variable    ${result[0]}
    Dated Log                         >> current_framework=${current_framework}
    ${flag_framework_0}=    Run Keyword If    "${current_framework}" == "framework-0"    Set Variable    ${True}    ELSE    Set Variable    ${False}
    ${flag_framework_1}=    Run Keyword If    "${current_framework}" == "framework-1"    Set Variable    ${True}    ELSE    Set Variable    ${False}
    ${rim_framework}=       Run Keyword If    ${flag_framework_0}    Set Variable    framework_0
    ...           ELSE IF             ${flag_framework_1}    Set Variable    framework_1
    ...           ELSE                Set Variable    ${None}
    Dated Log                         >> rim_framework= ${rim_framework}
    #
    ${aggressor_cell}=                Set Variable    ${victim_cell}
    # rsSetId's are fixed depending on ${victim_cell}
    ${rsSetId}=                       Set Variable    1${victim_cell}00
    ${rsSetId2}=                      Set Variable    2${victim_cell}00
    # testmode arguments supported
    ${k_factorRsSequence}=            Is Parameter A Dictionary Key    dict=${input}    parameter=factorRsSequence
    ${k_factorRsSequenceRS2}=         Is Parameter A Dictionary Key    dict=${input}    parameter=factorRsSequenceRS2
    ${k_globalF0ForRs}=               Is Parameter A Dictionary Key    dict=${input}    parameter=globalF0ForRs
    ${k_numRbForRs}=                  Is Parameter A Dictionary Key    dict=${input}    parameter=numRbForRs
    ${k_numRsType1SetId}=             Is Parameter A Dictionary Key    dict=${input}    parameter=numRsType1SetId
    ${k_numRsType2SetId}=             Is Parameter A Dictionary Key    dict=${input}    parameter=numRsType2SetId
    ${k_offsetRsSequence}=            Is Parameter A Dictionary Key    dict=${input}    parameter=offsetRsSequence
    ${k_offsetRsSequenceRS2}=         Is Parameter A Dictionary Key    dict=${input}    parameter=offsetRsSequenceRS2
    ${k_repetitionRsType1}=           Is Parameter A Dictionary Key    dict=${input}    parameter=repetitionRsType1
    ${k_repetitionRsType2}=           Is Parameter A Dictionary Key    dict=${input}    parameter=repetitionRsType2
    ${k_rsNearFarConfig}=             Is Parameter A Dictionary Key    dict=${input}    parameter=rsNearFarConfig
    ${k_rsNearFarConfig__2}=          Is Parameter A Dictionary Key    dict=${input}    parameter=rsNearFarConfig__2
    ${k_rsPattern1Period}=            Is Parameter A Dictionary Key    dict=${input}    parameter=rsPattern1Period
    ${k_rsPattern2Period}=            Is Parameter A Dictionary Key    dict=${input}    parameter=rsPattern2Period
    #${k_rsSetId}=                    Is Parameter A Dictionary Key    dict=${input}    parameter=rsSetId
    ${k_rsType1NScId}=                Is Parameter A Dictionary Key    dict=${input}    parameter=rsType1NScId
    ${k_rsType2NScId}=                Is Parameter A Dictionary Key    dict=${input}    parameter=rsType2NScId
    ${k_startRbForRs}=                Is Parameter A Dictionary Key    dict=${input}    parameter=startRbForRs
    ${k_startFreqOffsetForRs}=        Is Parameter A Dictionary Key    dict=${input}    parameter=startFreqOffsetForRs
    #
    &{dico}=                          Create Dictionary
    # create dico for testmode framework_0
    IF    ${flag_framework_0}
                                      Set To Dictionary    ${dico}     profile_id                 ${profile_id}
                                      Set To Dictionary    ${dico}     config_mode                standalone
                                      Set To Dictionary    ${dico}     victim_cell                ${victim_cell}
                                      Set To Dictionary    ${dico}     aggressor_cell             ${aggressor_cell}
                                      Set To Dictionary    ${dico}     rsSetId                    ${rsSetId}
                                      Set To Dictionary    ${dico}     numRsSetId                 1
                                      Set To Dictionary    ${dico}     rimRsType                  rsType1
    END
    Run Keyword If                    ${flag_framework_0} and ${k_rsNearFarConfig}
    ...                               Set To Dictionary    ${dico}     rsNearFarConfig            ${input}[rsNearFarConfig]
    Run Keyword If                    ${flag_framework_0}
    ...                               Set To Dictionary    ${dico}     propagation_delay          16
    Run Keyword If    ${flag_framework_0} and ${k_factorRsSequence}
    ...                               Set To Dictionary    ${dico}     factorRsSequence           ${input}[factorRsSequence]
    Run Keyword If    ${flag_framework_0} and ${k_offsetRsSequence}
    ...                               Set To Dictionary    ${dico}     offsetRsSequence           ${input}[offsetRsSequence]
    Run Keyword If    ${flag_framework_0} and ${k_rsType1NScId}
    ...                               Set To Dictionary    ${dico}     rsType1NScId               ${input}[rsType1NScId]
    Run Keyword If                    ${flag_framework_0} and ${k_numRbForRs}
    ...                               Set To Dictionary    ${dico}     numRbForRs                 ${input}[numRbForRs]
    Run Keyword If                    ${flag_framework_0} and ${k_rsPattern1Period}
    ...                               Set To Dictionary    ${dico}     rsPattern1Period           ${input}[rsPattern1Period]
    Run Keyword If                    ${flag_framework_0} and ${k_rsPattern2Period}
    ...                               Set To Dictionary    ${dico}     rsPattern2Period           ${input}[rsPattern2Period]
    Run Keyword If                    ${flag_framework_0} and ${k_repetitionRsType1}
    ...                               Set To Dictionary    ${dico}     repetitionRsType1          ${input}[repetitionRsType1]
    Run Keyword If                    ${flag_framework_0}
    ...                               Set To Dictionary    ${dico}     rim_framework              ${rim_framework}
    Run Keyword If                    ${flag_framework_0} and ${k_startRbForRs}
    ...                               Set To Dictionary    ${dico}     startRbForRs               ${input}[startRbForRs]
    Run Keyword If                    ${flag_framework_0} and ${k_numRsType1SetId}
    ...                               Set To Dictionary    ${dico}     numRsType1SetId            ${input}[numRsType1SetId]
    # create dico for testmode framework_1
    IF    ${flag_framework_1}
                                      Set To Dictionary    ${dico}     profile_id                 ${profile_id}
                                      Set To Dictionary    ${dico}     config_mode                standalone
                                      Set To Dictionary    ${dico}     victim_cell                ${victim_cell}
                                      Set To Dictionary    ${dico}     aggressor_cell             ${aggressor_cell}
                                      Set To Dictionary    ${dico}     rsSetId                    ${rsSetId}
                                      Set To Dictionary    ${dico}     numRsSetId                 1
                                      Set To Dictionary    ${dico}     rimRsType                  rsType1
    END
    Run Keyword If                    ${flag_framework_1} and ${k_rsNearFarConfig}
    ...                               Set To Dictionary    ${dico}     rsNearFarConfig            ${input}[rsNearFarConfig]
    IF    ${flag_framework_1}
                                      Set To Dictionary    ${dico}     propagation_delay          16
                                      Set To Dictionary    ${dico}     rsSetId__2                 ${rsSetId2}
                                      Set To Dictionary    ${dico}     numRsSetId__2              1
                                      Set To Dictionary    ${dico}     rimRsType__2               rsType2
                                      Set To Dictionary    ${dico}     propagation_delay__2       16
    END
    Run Keyword If                    ${flag_framework_1} and ${k_rsNearFarConfig__2}
    ...                               Set To Dictionary    ${dico}     rsNearFarConfig__2         ${input}[rsNearFarConfig__2]
    Run Keyword If                    ${flag_framework_1} and ${k_factorRsSequenceRS2}
    ...                               Set To Dictionary    ${dico}     factorRsSequenceRS2        ${input}[factorRsSequenceRS2]
    Run Keyword If                    ${flag_framework_1} and ${k_factorRsSequence}
    ...                               Set To Dictionary    ${dico}     factorRsSequence           ${input}[factorRsSequence]
    Run Keyword If                    ${flag_framework_1} and ${k_offsetRsSequence}
    ...                               Set To Dictionary    ${dico}     offsetRsSequence           ${input}[offsetRsSequence]
    Run Keyword If                    ${flag_framework_1} and ${k_offsetRsSequenceRS2}
    ...                               Set To Dictionary    ${dico}     offsetRsSequenceRS2        ${input}[offsetRsSequenceRS2]
    Run Keyword If                    ${flag_framework_1} and ${k_rsPattern1Period}
    ...                               Set To Dictionary    ${dico}     rsPattern1Period           ${input}[rsPattern1Period]
    Run Keyword If                    ${flag_framework_1} and ${k_rsPattern2Period}
    ...                               Set To Dictionary    ${dico}     rsPattern2Period           ${input}[rsPattern2Period]
    Run Keyword If                    ${flag_framework_1}
    ...                               Set To Dictionary    ${dico}     rim_framework              ${rim_framework}
    Run Keyword If                    ${flag_framework_1} and ${k_numRbForRs}
    ...                               Set To Dictionary    ${dico}     numRbForRs                 ${input}[numRbForRs]
    Run Keyword If                    ${flag_framework_1} and ${k_repetitionRsType1}
    ...                               Set To Dictionary    ${dico}     repetitionRsType1          ${input}[repetitionRsType1]
    Run Keyword If                    ${flag_framework_1} and ${k_repetitionRsType2}
    ...                               Set To Dictionary    ${dico}     repetitionRsType2          ${input}[repetitionRsType2]
    Run Keyword If                    ${flag_framework_1} and ${k_rsType1NScId}
    ...                               Set To Dictionary    ${dico}     rsType1NScId               ${input}[rsType1NScId]
    Run Keyword If                    ${flag_framework_1} and ${k_rsType2NScId}
    ...                               Set To Dictionary    ${dico}     rsType2NScId               ${input}[rsType2NScId]
    Run Keyword If                    ${flag_framework_1} and ${k_numRsType1SetId}
    ...                               Set To Dictionary    ${dico}     numRsType1SetId            ${input}[numRsType1SetId]
    Run Keyword If                    ${flag_framework_1} and ${k_numRsType2SetId}
    ...                               Set To Dictionary    ${dico}     numRsType2SetId            ${input}[numRsType2SetId]
    Run Keyword If                    ${flag_framework_1} and ${k_startFreqOffsetForRs}
    ...                               Set To Dictionary    ${dico}     startFreqOffsetForRs       ${input}[startFreqOffsetForRs]
    Run Keyword If                    ${flag_framework_1} and ${k_globalF0ForRs}
    ...                               Set To Dictionary    ${dico}     globalF0ForRs              ${input}[globalF0ForRs]
    IF    ${flag_framework_0} or ${flag_framework_1}
        Create And Execute Egate Script   testmode=rimrs_testmode_nr    dico_tm=${dico}
        ...                           script_path=${LOG_PATH}/rimrs_testmode_nr_cell-${victim_cell}.sce    option_remove=${True}    option_sleep=1
                                      Cell Testmode RIM RS    profile_id=${profile_id}    nrcell_id=${victim_cell}    action=activate
    ELSE IF    not ${flag_framework_0} and not ${flag_framework_1}
        Dated Log                     > Create RIM RS Testmode NR Profile is not started because actNrRim found is NOT supported
    END
    [Return]                          ${flag_framework_0}    ${flag_framework_1}


Stop RIM RS on NRCELL
    [Arguments]             ${nrcell_pos_victim}
    ...                     ${list_nrcell}
    #
    ${internal_pos}=                  Evaluate    ${nrcell_pos_victim}-1
    ${victim_cell}=                   Set Variable    ${list_nrcell[${internal_pos}].nrCellId}
    Dated Log                         ${cc_cyan}----Stop RIM RS on NRCELL-${victim_cell}----${cc_normal}
    ${profile_id}=                    Set Variable    ${victim_cell}
    Cell Testmode RIM RS              profile_id=${profile_id}    nrcell_id=${victim_cell}    action=deactivate
# --------------------------------------------------------------------------------------------------------------------------------------------------
UE Register And CRNTI Backup
    [Arguments]             ${ue_settings}
    #
    ${output_crnti}=                  CallSetup.UE Register    ue=${ue_settings}[ue]
    Set To Dictionary                 ${ue_settings}    c_rnti    ${output_crnti}
    Dated Log                         > The CRNTI ${ue_settings}[c_rnti] is saved for the UE Id ${ue_settings}[ue]


UE Establish NSA Call
    [Arguments]             ${ue_settings}
    #
    CallSetup.UE Attach Enb           ueSetting=${ue_settings}
    Sleep                             5s
    CallSetup.UE Attach Gnb           ueSetting=${ue_settings}
# --------------------------------------------------------------------------------------------------------------------------------------------------
Get Remote Interference State From NRRIMINFO
    [Arguments]             ${position_nrcell}
    ...                     ${ri_state}=RI detected
    ...                     ${iteration_max}=20
    ...                     ${confirm_detection}=${True}
    #
    Dated Log                         ${cc_cyan}----Get Remote Interference State From NRRIMINFO----${cc_normal}
    ${list_position_nrcell}=          Create List    ${position_nrcell}
    ${result}=                        Set Variable    ${False}
    FOR    ${iteration}    IN RANGE   1    ${iteration_max} + 1
        Dated Log                     > detection RI state [${ri_state}] (${iteration}/${iteration_max})
        # Get NRCELL Parameters SR-CR from NRRIMINFO object
        # using only one parameter like riState in this case for Cloud RAN
        &{dico_nrriminfo}=            Create Dictionary    riState=${ri_state}
        ...                           nrcell_tdd=${list_position_nrcell}
        ${nrriminfo_result}=          Get NRCELL Parameters SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
        ...                           extra_dist_name=NRRIMINFO-1
        IF    not ${isAic}
            ${result}=                Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
        ELSE
            ${len_nrriminfo_result}=  Get Length    ${nrriminfo_result}
            IF    ${len_nrriminfo_result} == 0
                Dated Log             ${cc_red}> Check riState Parameter is NOT POSSIBLE because list of information is empty${cc_normal}
            ELSE
                IF    "${nrriminfo_result}[0]" == "${ri_state}"
                    ${result}=            Set Variable    ${True}
                END
            END
        END
        IF    ${result}
            Dated Log                 ${cc_yellow}> Get NRRIMINFO Parameters SR-CR result=${nrriminfo_result}${cc_normal}
        ELSE
            Dated Log                 > Get NRRIMINFO Parameters SR-CR result=${nrriminfo_result}
            Traced Sleep              duration=30s    msg=call and before next detection attempt
        END
        Exit For Loop If              ${result}
    END
    IF    ${confirm_detection}
                                      Should Be True    ${result} == ${True}
    END


Get riStateReport Parameters From actRimCmFmReport CR
    [Arguments]             ${current_elem}
    #
    Dated Log                         ${cc_cyan}----Get riStateReport Parameters From actRimCmFmReport CR----${cc_normal}
    #
    ${current_value}=                 Set Variable    FM off, CM off
    ${first_elem}=                    Set Variable    ${current_elem}[0]
    Dated Log                         >> ${first_elem}
    FOR    ${current_report}    IN    @{first_elem}
        ${current_name}=              Set Variable    ${current_report['name']}
#DEBUG_LOG#
#       Dated Log                     >> current_report.name=${current_name}
        ${value_dict}=                Evaluate    json.loads('''${current_report['value']}''')    json
#DEBUG_LOG#
#       Dated Log                     >> current_report.value=${value_dict}
        ${current_value}=             Set Variable    ${value_dict['currentValue']}
        Exit For Loop If              "${current_name}" == "riStateReport"
    END
    [Return]                          ${current_value}


Get riStateReport Parameters From actRimCmFmReport SR
    [Arguments]             ${current_elem}
    #
    Dated Log                         ${cc_cyan}----Get riStateReport Parameters From actRimCmFmReport SR----${cc_normal}
    #
    ${first_dico}=                    Set Variable    ${current_elem}[0]
#DEBUG_LOG#
#   Dated Log                         >> ${first_dico}
    ${parameters}=                    Set Variable    ${first_dico}[parameters]
    ${actRimCmFmReport}=              Set Variable    ${parameters}[actRimCmFmReport]
    ${dico_actRimCmFmReport}=         Set Variable    ${actRimCmFmReport}[0]
    Dated Log                         > dico_actRimCmFmReport=${dico_actRimCmFmReport}
    ${current_param}=                 Set Variable    riStateReport
    [Return]                          ${dico_actRimCmFmReport}[${current_param}]


Get riThresBasePerSubband Values SR-CR
    [Arguments]             ${dico}
    ...                     ${nrcell_key}
    ...                     ${list_nrcell}
    #
    Dated Log New Line                ${cc_cyan}----Get riThresBasePerSubband Values SR-CR----${cc_normal}
    ${result}=                        Get NRCELL Parameters SR-CR    dico=${dico}    nrcell_key=${nrcell_key}    list_nrcell=${list_nrcell}
    ...                               extra_dist_name=NRRIMINFO-1
    [Return]                          ${result}


Get Active Alarm And Check Specific Detection
    [Arguments]             ${capture}
    ...                     ${alarm_id}
    ...                     ${fault_id}=${None}
    ...                     ${alarm_object}=${None}
    ...                     ${suppl_alarm_info}=${None}
    ...                     ${iteration_max}=32
    ...                     ${suffix}=detection
    ...                     ${confirm_detection}=${True}
    ...                     ${cell_id_list}=${None}
    ...                     ${oam_type}=${GNB_DU.oam}
    #
    Dated Log                         ${cc_cyan}----Get Active Alarm And Check Specific Detection----${cc_normal}
    FOR    ${iteration}    IN RANGE   1    ${iteration_max} + 1
        Dated Log New Line            > detection alarm [${alarm_id}][${fault_id}] on object=${alarm_object} (${iteration}/${iteration_max})
        Dated Log                     > and containing the supplementary information if not none: ${suppl_alarm_info}
        # Capture TTI traces start during detection alarm
        IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture}[is_capture_tti] and "${cell_id_list}" != "${None}"
                                      Start TTI Logs SR-CR    cell_id_list=${cell_id_list}
        END
        ${alarm_information}=         Detection Alarm Id    alarm_id=${alarm_id}    fault_id=${fault_id}    alarm_object=${alarm_object}
        ...                           confirm_presence=${True}    suppl_info=${suppl_alarm_info}    oam_type=${oam_type}
#DEBUG_LOG#
#       Dated Log                     >> alarm_information= ${alarm_information}
        # Capture TTI traces stop during detection alarm
        @{list_events}=               Create List    utcTimestampData    ulAllocatedPooledResourcesData    dlAllocatedPooledResourcesData
        ...                           ulFdSchedData    dlFdSchedData
        IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture}[is_capture_tti] and "${cell_id_list}" != "${None}"
            IF    "${alarm_information}" != "${None}"
                            Stop and Get TTI Logs SR-CR    trace_name=TTI_${suffix}_${fault_id}_${iteration}    list_events_to_filter=${list_events}
            ELSE
                            Stop and Get TTI Logs SR-CR    trace_name=TTI_${suffix}_${fault_id}_${iteration}    list_events_to_filter=${None}
            END
        END
        IF    "${alarm_information}" == "${None}"
                                      Traced Sleep    duration=30s    msg=alarm detection and before next iteration
        END
        Exit For Loop If              "${alarm_information}" != "${None}"
        ${pcap_file}=                 Set Variable    ${LOG_PATH}/*/*_${suffix}_${fault_id}_${iteration}*
        IF    ${iteration} < ${iteration_max}
                                      Run    command=rm -f ${pcap_file}
        END
    END
    # Alarm must be found after ${iteration} attempts
    IF    "${alarm_information}" != "${None}"
        ${result}=                    Set Variable    ${True}
    ELSE
        ${result}=                    Set Variable    ${False}
    END
    IF    ${confirm_detection}
                                      Should Be True    ${result} == ${True}
    END
    [Return]                          ${result}


#CR_NOT_TESTED#Loop Detection RIM RS 7527
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Call And Then Traffic #
CB014613 Call And Then Traffic SR-CR
    [Arguments]             ${param}
    ...                     ${ues_settings}
    ...                     ${capture_settings}
    ...                     ${list_position_nrcell}
    ...                     ${delay_before_RI}=8m    # delay of 8 minutes before checking for remote interference
    ...                     ${frameStructureType}=tdLte
    ...                     ${bypassX2Setup}=${True}
    #
    Dated Log New Line                ${cc_cyan}----CB014613 Call And Then Traffic SR-CR----${cc_normal}
    # Capture SYSLOG start during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
        ${syslog_call_setup}=         SYSLOG Start    host=${GNB_DU.sys[0].M}    name=call_setup
    END
    ${param.total_nb_ue}=             Set Variable    0
    IF    ${CALL_ENABLED}
        ${param.total_nb_ue}=         Get Length    ${ues_settings}
    END
    ${list_ue}    ${cell_id_for_streaming}    Get List UEs Settings    param=${param}    dict_settings=${ues_settings}
    Display List UEs Settings         ${list_ue}
    Dated Log                         > Cells list for TTI streaming is ${cell_id_for_streaming}
    #
    Dated Log New Line                ${cc_cyan}----CallSetup WTS Setup----${cc_normal}
    Critical Step                     CallSetup.WTS Setup           nbUe=${param.total_nb_ue}    nbSaUe=${param.nb_sa_ue}    shouldUseLua=${False}
    ...                               bypassX2Setup=${bypassX2Setup}
    #
    @{cell_id_list}=                  Get List Cells Retained For TTI Streaming SR-CR    cell_id_streaming=${cell_id_for_streaming}
    Dated Log                         > Distname list of the cells retained for TTI streaming ${cell_id_list}
    IF    ${isAic}
        @{cell_id_list}=              Copy List    ${cell_id_for_streaming}
    END
    #
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are initialzed with legacy values just after cell setup
    @{riThresBasePerSubband_val}=     Create List    -110    -110    -110    -110    -110
    &{dico_nrriminfo}=                Create Dictionary    riThresBasePerSubband=${riThresBasePerSubband_val}
    ...                                                    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    IF    not ${isAic}
        Step                          Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}   percentage_tolerance=0
    ELSE
        Step                          Check NRRIMINFO Parameter riThresBasePerSubband CR    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
        ...                           percentage_tolerance=0
    END
    #
    # Capture L1L2 traces start during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Captures Init    isMirror=${True}
                                      Capture Start    capture=${capture_l1l2}
                                      Sleep    10s
    END
    Dated Log New Line                ${cc_cyan}----Call Establishment----${cc_normal}
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                "${current_elem.call_type}" == "SA"    Run Keywords
        ...          Critical Step    UE Register And CRNTI Backup    ue_settings=${current_elem}    depends=CallSetup.WTS Setup
        ...    AND            Step    CallSetup.Launch PDU Session    ue=${current_elem.ue}    pdu=${current_elem.pdu}    gw=${current_elem.ue}
        ...                           depends=UE Register And CRNTI Backup
        ...       ELSE
        ...          Critical Step    UE Establish NSA Call    ue_settings=${current_elem}    depends=CallSetup.WTS Setup
        Run Keyword If                ${current_elem.throughput_gbr} > 0    Run Keywords
        ...    Dated Log New Line     ${cc_cyan}----Update PDU session reserved for the ue's configured with GBR traffic----${cc_normal}
        ...    AND            Step    CallSetup.UE PDU Session Modify    ue=${current_elem.ue}    pdu=${current_elem.pdu}    qfta=2    by=amf
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND                    Sleep    2s
        ...    AND            Step    CallSetup.UE PDU Session Modify    ue=${current_elem.ue}    pdu=${current_elem.pdu}    qfta=3    by=amf
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND                    Sleep    2s
    END
    # Capture L1L2 traces stop during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Capture L1L2 Stop    capture_config=${capture_l1l2}    output_suffix=call_setup
    END
    #
    Display List UEs Settings         ${list_ue}
    # Capture L1L2 traces start during traffic
#OBSOLETE#
#   IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
#                                     Captures Init
#                                     Capture Start    capture=${capture_l1l2}
#   END
    Dated Log New Line                ${cc_cyan}----Start non-GBR Traffic----${cc_normal}
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                "${param.dir}" != "${None}"
        ...                   Step    ${param.dir} Traffic Not Stopped Common    param=${param}    current_ue_setting=${current_elem}
    END
    Dated Log New Line                ${cc_cyan}----Start GBR Traffic----${cc_normal}
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                ${current_elem.throughput_gbr} > 0    Run Keywords
        ...                   Step    DL Traffic GBR SA Not Stopped    param=${param}    current_ue_setting=${current_elem}
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND            Step    UL Traffic GBR SA Not Stopped    param=${param}    current_ue_setting=${current_elem}
        ...                           depends=CallSetup.Launch PDU Session
    END
    Traced Sleep                      duration=10s    msg=traffic and before stopping capture L1L2
    # Capture L1L2 traces stop during traffic
#OBSOLETE#
#   IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
#                                     Capture L1L2 Stop    capture_config=${capture_l1l2}    output_suffix=traffic
#   END
    # Capture TTI traces start and stop during traffic
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti] and "${cell_id_list}" != "${None}"
                                      Start TTI Logs SR-CR    cell_id_list=${cell_id_list}
                                      Traced Sleep    duration=10s    msg=traffic and before stopping capture TTI
        @{list_events}=  Create List  utcTimestampData  ulAllocatedPooledResourcesData  dlAllocatedPooledResourcesData  ulFdSchedData  dlFdSchedData
                                      Stop and Get TTI Logs SR-CR    trace_name=TTI_traffic    list_events_to_filter=${list_events}
    END
    # Capture SYSLOG stop during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
                                      SYSLOG Stop    syslog=${syslog_call_setup}
    END
    # Get actRimCmFmReport configuration to identify riStateReport mode: 'FM on, CM off' <=> alarm or 'FM off, CM on' <=> riState
    IF    not ${isAic}
        ${entity_oam}=                Set Variable    ${GNB_DU.oam}
        ${parameter_list}=            Create List    actRimCmFmReport
    ELSE
        ${entity_oam}=                Set Variable    ${TGNB_DU[0].oam}
        ${parameter_list}=            Set Variable    actRimCmFmReport
    END
    ${result_report}=                 Oam.OAM Get Parameter By Distname    oam=${entity_oam}    dist_name=${dn_nrbts}
    ...                               parameter_list=${parameter_list}    include_children=${False}    timeout=30    detailed_output=${False}
    Dated Log                         > OAM Get Parameter By Distname= ${result_report}
    IF    not ${isAic}
        ${ri_state_report}=           Get riStateReport Parameters From actRimCmFmReport SR    current_elem=${result_report}
    ELSE
        ${ri_state_report}=           Get riStateReport Parameters From actRimCmFmReport CR    current_elem=${result_report}
    END
    Dated Log                         ${cc_red}> ri_state_report= ${ri_state_report}${cc_normal}
    #
    Dated Log                         ${cc_cyan}----OAM get active alarm and check remote interference is not yet detected----${cc_normal}
    ${is_alarm_present}=              Is Alarm Present    alarm_id=7115    fault_id=7525    iteration=2    confirm_presence=${False}
    Should Be True                    ${is_alarm_present} == ${False}
    #
    IF    "${ri_state_report}" == "FM off, CM on"
        FOR    ${position}    IN          @{list_position_nrcell}
            Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=no RI    iteration_max=1
            ...                       confirm_detection=${True}    #for bypassing PR868877#${False}
        END
    END
    #
    ${start_symbol_pos_val}=          Set Variable    0
    IF    "${frameStructureType}" == "tdLte"
        ${num_symbols_val}=           Set Variable    32
    ELSE
        ${num_symbols_val}=           Set Variable    16
    END
    #
    # Capture SYSLOG start during detection legacy
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
        ${syslog_legacy}=             SYSLOG Start    host=${GNB_DU.sys[0].M}    name=detection_legacy
    END
    #
    Dated Log New Line                ${cc_cyan}----Simulate Remote Interference using profile_id=10----${cc_normal}
    Step                              Create RI Testmode NR Profile     profile_id=10    noise_power_val=${param.RI_N_PW_10}
    ...                               start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
    FOR    ${position}    IN          @{list_position_nrcell}
        Step                          Start Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}
        ...                           profile_id=10
    END
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are initialzed with legacy values
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    Traced Sleep                      duration=${delay_before_RI}  msg=${cc_cyan}remote interference and before starting alarm detection${cc_normal}
    # Check for remote interference alarm
    &{capture_detection}=           Create Dictionary    is_capture_l1l2=${False}    is_capture_tti=${False}    is_capture_syslog=${False}
    FOR    ${position}    IN          @{list_position_nrcell}
        IF    "${ri_state_report}" == "FM on, CM off"
            # check RI detection using active alarm 7115 fault_id=7525
            ${internal_pos}=          Evaluate    ${position}-1
            ${victim_cell}=           Set Variable    ${TDD_Cell_list[${internal_pos}].nrCellId}
            ${current_nrcell}=        Set Variable    NRCELL-${victim_cell}
            # [7115][7525](Minor) b'BASE STATION INFORMATION'           :b'Remote interference detected'
            Critical Step             Get Active Alarm And Check Specific Detection    capture=${capture_detection}
            ...                       alarm_id=7115    fault_id=7525    alarm_object=${current_nrcell}    iteration_max=50
            ...                       suffix=detection_${current_nrcell}    cell_id_list=${cell_id_list}    oam_type=${entity_oam}
        ELSE IF    "${ri_state_report}" == "FM off, CM on"
            # check RI detection using NRCELL/NRRIMINFO/riState = RI detected
            Critical Step             Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=RI detected
            ...                       confirm_detection=${True}
        ELSE
            # no detection required
            Dated Log                 ${cc_red}> Remote Interference detection is NOT required${cc_normal}
        END
    END
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are changed
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    IF    not ${isAic}
        Step                          Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}   percentage_tolerance=0
    ELSE
        Step                          Check NRRIMINFO Parameter riThresBasePerSubband CR    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
        ...                           percentage_tolerance=0
    END
    FOR    ${position}    IN          @{list_position_nrcell}
        Stop Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}    profile_id=10
    END
    IF    "${ri_state_report}" == "FM off, CM on"
        FOR    ${position}    IN          @{list_position_nrcell}
            Critical Step             Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=no RI
            ...                       confirm_detection=${True}
        END
    END
    # Capture SYSLOG stop during detection legacy
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
                                      SYSLOG Stop    syslog=${syslog_legacy}
        ${status}   ${ret}   Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${param.syslog_grep_target}
        IF   "${status}" == "PASS"
                                      Run    command=chmod 777 ${param.syslog_grep_target}
                                      Run    command=${param.syslog_grep_target} ${LOG_PATH}/SYSLOG > ${LOG_PATH}/SYSLOG/grep_result_legacy.txt
        ELSE
            Dated Log                 > ${param.syslog_grep_target} is NOT present
        END
    END
    #
    # rdAutoRiThresBaseCalcInterval is set to 20 minutes for this test.
    # Robot WA is to delayed the 2nd remote interference starting / end of calculation interval for thresholds.
    Traced Sleep                      duration=300s  msg=${cc_cyan}end of calculation interval for the remote interference thresholds${cc_normal}
    #
    # Capture SYSLOG start during dynamic detection
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
        ${syslog_dynamic}=            SYSLOG Start    host=${GNB_DU.sys[0].M}    name=detection_dynamic
    END
    #
    Dated Log New Line                ${cc_cyan}----Simulate Remote Interference using profile_id=1----${cc_normal}
    Step                              Create RI Testmode NR Profile     profile_id=1    noise_power_val=${param.RI_N_PW_1}
    ...                               start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
    FOR    ${position}    IN          @{list_position_nrcell}
        Step                          Start Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}
        ...                           profile_id=1
    END
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are changed before dynamic detection
    @{riThresBasePerSubband_val}=     Run Keyword If    not ${isAic}    Create List    -95    -95    -95    -95    -95
    ...                               ELSE    Create List    -85    -85    -85    -85    -85
    &{dico_nrriminfo}=                Create Dictionary    riThresBasePerSubband=${riThresBasePerSubband_val}
    ...                                                    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    IF    not ${isAic}
        Step                          Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
    ELSE
        Step                          Check NRRIMINFO Parameter riThresBasePerSubband CR    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
    END
    #
    Traced Sleep                      duration=${delay_before_RI}  msg=${cc_cyan}remote interference and before starting alarm detection${cc_normal}
    # Check for remote interference alarm
    FOR    ${position}    IN          @{list_position_nrcell}
        IF    "${ri_state_report}" == "FM on, CM off"
            # check RI detection using active alarm 7115 fault_id=7525
            ${internal_pos}=          Evaluate    ${position}-1
            ${victim_cell}=           Set Variable    ${TDD_Cell_list[${internal_pos}].nrCellId}
            ${current_nrcell}=        Set Variable    NRCELL-${victim_cell}
            # [7115][7525](Minor) b'BASE STATION INFORMATION'           :b'Remote interference detected'
            Critical Step             Get Active Alarm And Check Specific Detection    capture=${capture_detection}
            ...                       alarm_id=7115    fault_id=7525    alarm_object=${current_nrcell}    iteration_max=50
            ...                       suffix=detection_${current_nrcell}    cell_id_list=${cell_id_list}    oam_type=${entity_oam}
        ELSE IF    "${ri_state_report}" == "FM off, CM on"
            # check RI detection using NRCELL/NRRIMINFO/riState = RI detected
            Critical Step             Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=RI detected
            ...                       confirm_detection=${True}
        ELSE
            # no detection required
            Dated Log                 ${cc_red}> Remote Interference detection is NOT required${cc_normal}
        END
    END
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are changed
    &{dico_nrriminfo}=                Create Dictionary    riThresBasePerSubband=${riThresBasePerSubband_val}
    ...                                                    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    IF    not ${isAic}
        Step                          Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
    ELSE
        Step                          Check NRRIMINFO Parameter riThresBasePerSubband CR    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
    END
    #
    Step                              Collect And Check Counter And KPI Constraints SR-CR    param=${param}    capture_settings=${capture_detection}
    #
    FOR    ${position}    IN          @{list_position_nrcell}
        Stop Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}    profile_id=1
    END
    IF    "${ri_state_report}" == "FM off, CM on"
        FOR    ${position}    IN          @{list_position_nrcell}
            Critical Step             Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=no RI
            ...                       confirm_detection=${True}
        END
    END
    FOR    ${iteration_alarm}         IN RANGE    1    100+1
        Traced Sleep                  duration=10s    msg=checking for remote interference deactivation (${iteration_alarm}/100)
        ${is_alarm_present}=          Is Alarm Present    alarm_id=7115    fault_id=7525    iteration=1    confirm_presence=${False}
        Exit For Loop If              not ${is_alarm_present}
    END
    Should Be True                    ${is_alarm_present} == ${False}
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are changed
    @{riThresBasePerSubband_val}=     Create List    -85    -85    -85    -85    -85
    &{dico_nrriminfo}=                Create Dictionary    riThresBasePerSubband=${riThresBasePerSubband_val}
    ...                                                    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    IF    not ${isAic}
        Step                          Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
    ELSE
        Step                          Check NRRIMINFO Parameter riThresBasePerSubband CR    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
    END
    # Capture SYSLOG stop during dynamic detection
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
                                      SYSLOG Stop    syslog=${syslog_dynamic}
        ${status}   ${ret}   Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${param.syslog_grep_target}
        IF   "${status}" == "PASS"
                                      Run    command=chmod 777 ${param.syslog_grep_target}
                                      Run    command=${param.syslog_grep_target} ${LOG_PATH}/SYSLOG > ${LOG_PATH}/SYSLOG/grep_result.txt
        ELSE
            Dated Log                 > ${param.syslog_grep_target} is NOT present
        END
    END
    # Deregister all the ue's
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                "${current_elem.call_type}" == "SA"
        ...               Step        CallSetup.UE Deregister    id=${current_elem.ue}    ue_deregister_type=switch_off    by=ue
        ...                           depends=Ue Register And CRNTI Backup
        ...       ELSE
        ...               Step        CallSetup.UE Detach Enb    ueSetting=${current_elem}    depends=UE Establish NSA Call
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Call And Then Traffic #
CB014613 Call And Then Traffic SR A_9
    [Arguments]             ${param}
    ...                     ${ues_settings}
    ...                     ${capture_settings}
    ...                     ${list_position_nrcell}
    ...                     ${delay_before_RI}=8m    # delay of 8 minutes before checking for remote interference
    ...                     ${frameStructureType}=tdLte
    ...                     ${bypassX2Setup}=${False}
    #
    Dated Log New Line                ${cc_cyan}----CB014613 Call And Then Traffic SR-CR----${cc_normal}
    # Capture SYSLOG start during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
        ${syslog_call_setup}=         SYSLOG Start    host=${GNB_DU.sys[0].M}    name=call_setup
    END
    ${param.total_nb_ue}=             Set Variable    0
    IF    ${CALL_ENABLED}
        ${param.total_nb_ue}=         Get Length    ${ues_settings}
    END
    ${list_ue}    ${cell_id_for_streaming}    Get List UEs Settings    param=${param}    dict_settings=${ues_settings}
    Display List UEs Settings         ${list_ue}
    Dated Log                         > Cells list for TTI streaming is ${cell_id_for_streaming}
    #
    Dated Log New Line                ${cc_cyan}----CallSetup WTS Setup----${cc_normal}
    Critical Step                     CallSetup.WTS Setup           nbUe=${param.total_nb_ue}    nbSaUe=${param.nb_sa_ue}    shouldUseLua=${False}
    ...                               bypassX2Setup=${bypassX2Setup}
    #
    @{cell_id_list}=                  Get List Cells Retained For TTI Streaming SR-CR    cell_id_streaming=${cell_id_for_streaming}
    Dated Log                         > Distname list of the cells retained for TTI streaming ${cell_id_list}
    IF    ${isAic}
        @{cell_id_list}=              Copy List    ${cell_id_for_streaming}
    END
    #
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are initialzed with legacy values just after cell setup
    @{riThresBasePerSubband_val}=     Create List    -110    -110    -110
    &{dico_nrriminfo}=                Create Dictionary    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    riThresBasePerSubband=${riThresBasePerSubband_val}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    Step                              Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}   percentage_tolerance=0
    #
    # Capture L1L2 traces start during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Captures Init    isMirror=${True}
                                      Capture Start    capture=${capture_l1l2}
                                      Sleep    10s
    END
    Dated Log New Line                ${cc_cyan}----Call Establishment----${cc_normal}
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                "${current_elem.call_type}" == "SA"    Run Keywords
        ...          Critical Step    UE Register And CRNTI Backup    ue_settings=${current_elem}    depends=CallSetup.WTS Setup
        ...    AND            Step    CallSetup.Launch PDU Session    ue=${current_elem.ue}    pdu=${current_elem.pdu}    gw=${current_elem.ue}
        ...                           depends=UE Register And CRNTI Backup
        ...       ELSE
        ...          Critical Step    UE Establish NSA Call    ue_settings=${current_elem}    depends=CallSetup.WTS Setup
        Run Keyword If                ${current_elem.throughput_gbr} > 0    Run Keywords
        ...    Dated Log New Line     ${cc_cyan}----Update PDU session reserved for the ue's configured with GBR traffic----${cc_normal}
        ...    AND            Step    CallSetup.UE PDU Session Modify    ue=${current_elem.ue}    pdu=${current_elem.pdu}    qfta=2    by=amf
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND                    Sleep    2s
        ...    AND            Step    CallSetup.UE PDU Session Modify    ue=${current_elem.ue}    pdu=${current_elem.pdu}    qfta=3    by=amf
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND                    Sleep    2s
    END
    # Capture L1L2 traces stop during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Capture L1L2 Stop    capture_config=${capture_l1l2}    output_suffix=call_setup
    END
    #
    Display List UEs Settings         ${list_ue}
    # Capture L1L2 traces start during traffic
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Captures Init
                                      Capture Start    capture=${capture_l1l2}
    END
    Dated Log New Line                ${cc_cyan}----Start non-GBR Traffic----${cc_normal}
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                "${param.dir}" != "${None}"
        ...                   Step    ${param.dir} Traffic Not Stopped Common    param=${param}    current_ue_setting=${current_elem}
    END
    Dated Log New Line                ${cc_cyan}----Start GBR Traffic----${cc_normal}
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                ${current_elem.throughput_gbr} > 0    Run Keywords
        ...                   Step    DL Traffic GBR SA Not Stopped    param=${param}    current_ue_setting=${current_elem}
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND            Step    UL Traffic GBR SA Not Stopped    param=${param}    current_ue_setting=${current_elem}
        ...                           depends=CallSetup.Launch PDU Session
    END
    Traced Sleep                      duration=10s    msg=traffic and before stopping capture L1L2
    # Capture L1L2 traces stop during traffic
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Capture L1L2 Stop    capture_config=${capture_l1l2}    output_suffix=traffic
    END
    # Capture TTI traces start and stop during traffic
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti] and "${cell_id_list}" != "${None}"
                                      Start TTI Logs SR-CR    cell_id_list=${cell_id_list}
                                      Traced Sleep    duration=10s    msg=traffic and before stopping capture TTI
        @{list_events}=  Create List  utcTimestampData  ulAllocatedPooledResourcesData  dlAllocatedPooledResourcesData  ulFdSchedData  dlFdSchedData
                                      Stop and Get TTI Logs SR-CR    trace_name=TTI_traffic    list_events_to_filter=${list_events}
    END
    # Capture SYSLOG stop during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
                                      SYSLOG Stop    syslog=${syslog_call_setup}
    END
    # Get actRimCmFmReport configuration to identify riStateReport mode: 'FM on, CM off' <=> alarm or 'FM off, CM on' <=> riState
    IF    not ${isAic}
        ${entity_oam}=                Set Variable    ${GNB_DU.oam}
        ${parameter_list}=            Create List    actRimCmFmReport
    ELSE
        ${entity_oam}=                Set Variable    ${TGNB_DU[0].oam}
        ${parameter_list}=            Set Variable    actRimCmFmReport
    END
    ${result_report}=                 Oam.OAM Get Parameter By Distname    oam=${entity_oam}    dist_name=${dn_nrbts}
    ...                               parameter_list=${parameter_list}    include_children=${False}    timeout=30    detailed_output=${False}
    Dated Log                         > OAM Get Parameter By Distname= ${result_report}
    IF    not ${isAic}
        ${ri_state_report}=           Get riStateReport Parameters From actRimCmFmReport SR    current_elem=${result_report}
    ELSE
        ${ri_state_report}=           Get riStateReport Parameters From actRimCmFmReport CR    current_elem=${result_report}
    END
    Dated Log                         ${cc_red}> ri_state_report= ${ri_state_report}${cc_normal}
    #
    Dated Log                         ${cc_cyan}----OAM get active alarm and check remote interference is not yet detected----${cc_normal}
    ${is_alarm_present}=              Is Alarm Present    alarm_id=7115    fault_id=7525    iteration=2    confirm_presence=${False}
    Should Be True                    ${is_alarm_present} == ${False}
    #
    IF    "${ri_state_report}" == "FM off, CM on"
        FOR    ${position}    IN          @{list_position_nrcell}
            Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=no RI    iteration_max=1
            ...                       confirm_detection=${True}    #for bypassing PR868877#${False}
        END
    END
    #
    ${start_symbol_pos_val}=          Set Variable    0
    IF    "${frameStructureType}" == "tdLte"
        ${num_symbols_val}=           Set Variable    32
    ELSE
        ${num_symbols_val}=           Set Variable    16
    END
    #
    # Capture SYSLOG start during detection legacy
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
        ${syslog_legacy}=             SYSLOG Start    host=${GNB_DU.sys[0].M}    name=detection_legacy
    END
    #
    Dated Log New Line                ${cc_cyan}----Simulate Remote Interference using profile_id=10----${cc_normal}
    Step                              Create RI Testmode NR Profile     profile_id=10    noise_power_val=${param.RI_N_PW_10}
    ...                               start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
    FOR    ${position}    IN          @{list_position_nrcell}
        Step                          Start Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}
        ...                           profile_id=10
    END
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are initialzed with legacy values
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    Traced Sleep                      duration=${delay_before_RI}  msg=${cc_cyan}remote interference and before starting alarm detection${cc_normal}
    # Check for remote interference alarm
    &{capture_detection}=           Create Dictionary    is_capture_l1l2=${False}    is_capture_tti=${False}    is_capture_syslog=${False}
    FOR    ${position}    IN          @{list_position_nrcell}
        IF    "${ri_state_report}" == "FM on, CM off"
            # check RI detection using active alarm 7115 fault_id=7525
            ${internal_pos}=          Evaluate    ${position}-1
            ${victim_cell}=           Set Variable    ${TDD_Cell_list[${internal_pos}].nrCellId}
            ${current_nrcell}=        Set Variable    NRCELL-${victim_cell}
            # [7115][7525](Minor) b'BASE STATION INFORMATION'           :b'Remote interference detected'
            Critical Step             Get Active Alarm And Check Specific Detection    capture=${capture_detection}
            ...                       alarm_id=7115    fault_id=7525    alarm_object=${current_nrcell}    iteration_max=50
            ...                       suffix=detection_${current_nrcell}    cell_id_list=${cell_id_list}    oam_type=${entity_oam}
        ELSE IF    "${ri_state_report}" == "FM off, CM on"
            # check RI detection using NRCELL/NRRIMINFO/riState = RI detected
            Critical Step             Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=RI detected
            ...                       confirm_detection=${True}
        ELSE
            # no detection required
            Dated Log                 ${cc_red}> Remote Interference detection is NOT required${cc_normal}
        END
    END
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are changed
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    Step                              Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}   percentage_tolerance=0
    FOR    ${position}    IN          @{list_position_nrcell}
        Stop Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}    profile_id=10
    END
    # Capture SYSLOG stop during detection legacy
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
                                      SYSLOG Stop    syslog=${syslog_legacy}
        ${status}   ${ret}   Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${param.syslog_grep_target}
        IF   "${status}" == "PASS"
                                      Run    command=chmod 777 ${param.syslog_grep_target}
                                      Run    command=${param.syslog_grep_target} ${LOG_PATH}/SYSLOG > ${LOG_PATH}/SYSLOG/grep_result_legacy.txt
        ELSE
            Dated Log                 > ${param.syslog_grep_target} is NOT present
        END
    END
    #
    # rdAutoRiThresBaseCalcInterval is set to 25 minutes for this test.
    # Robot WA is to delayed the 2nd remote interference starting / end of calculation interval for thresholds.
    Traced Sleep                      duration=660s  msg=${cc_cyan}end of calculation interval for the remote interference thresholds${cc_normal}
    #
    # Capture SYSLOG start during dynamic detection
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
        ${syslog_dynamic}=            SYSLOG Start    host=${GNB_DU.sys[0].M}    name=detection_dynamic
    END
    #
    Dated Log New Line                ${cc_cyan}----Simulate Remote Interference using profile_id=1----${cc_normal}
    Step                              Create RI Testmode NR Profile     profile_id=1    noise_power_val=${param.RI_N_PW_1}
    ...                               start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
    FOR    ${position}    IN          @{list_position_nrcell}
        Step                          Start Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}
        ...                           profile_id=1
    END
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are changed before dynamic detection
    @{riThresBasePerSubband_val}=     Create List    -95    -95    -95
    &{dico_nrriminfo}=                Create Dictionary    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    riThresBasePerSubband=${riThresBasePerSubband_val}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    Step                              Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}  percentage_tolerance=10
    #
    Traced Sleep                      duration=${delay_before_RI}  msg=${cc_cyan}remote interference and before starting alarm detection${cc_normal}
    # Check for remote interference alarm
    FOR    ${position}    IN          @{list_position_nrcell}
        IF    "${ri_state_report}" == "FM on, CM off"
            # check RI detection using active alarm 7115 fault_id=7525
            ${internal_pos}=          Evaluate    ${position}-1
            ${victim_cell}=           Set Variable    ${TDD_Cell_list[${internal_pos}].nrCellId}
            ${current_nrcell}=        Set Variable    NRCELL-${victim_cell}
            # [7115][7525](Minor) b'BASE STATION INFORMATION'           :b'Remote interference detected'
            Critical Step             Get Active Alarm And Check Specific Detection    capture=${capture_detection}
            ...                       alarm_id=7115    fault_id=7525    alarm_object=${current_nrcell}    iteration_max=50
            ...                       suffix=detection_${current_nrcell}    cell_id_list=${cell_id_list}    oam_type=${entity_oam}
        ELSE IF    "${ri_state_report}" == "FM off, CM on"
            # check RI detection using NRCELL/NRRIMINFO/riState = RI detected
            Critical Step             Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=RI detected
            ...                       confirm_detection=${True}
        ELSE
            # no detection required
            Dated Log                 ${cc_red}> Remote Interference detection is NOT required${cc_normal}
        END
    END
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are changed
    &{dico_nrriminfo}=                Create Dictionary    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    riThresBasePerSubband=${riThresBasePerSubband_val}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    Step                              Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}  percentage_tolerance=10
    #
    # Online NIDD modification for setting actDynamicRiThresBaseCalc=false
    &{dico_nrrim_online_modif}=       Create Dictionary    actDynamicRiThresBaseCalc=false    nrcell_tdd=${list_position_nrcell}
    Step    Online Modification NRRIM PROFILE Parameters SR-CR    ${dico_nrrim_online_modif}    nrcell_key=nrcell_tdd   list_nrcell=${TDD_Cell_list}
    #
    # Check NRRIMINFO Parameters to verify that riThresBasePerSubband is no more present
    &{dico_nrriminfo}=                Create Dictionary    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    riThresBasePerSubband=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    Step                              Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
    #
    #
    # + Check that riThresBasePerSubband is no more present into ${nrriminfo_result}
    #
    #
    # Capture SYSLOG stop during dynamic detection
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
                                      SYSLOG Stop    syslog=${syslog_dynamic}
        ${status}   ${ret}   Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${param.syslog_grep_target}
        IF   "${status}" == "PASS"
                                      Run    command=chmod 777 ${param.syslog_grep_target}
                                      Run    command=${param.syslog_grep_target} ${LOG_PATH}/SYSLOG > ${LOG_PATH}/SYSLOG/grep_result.txt
        ELSE
            Dated Log                 > ${param.syslog_grep_target} is NOT present
        END
    END
    #
    # Testmode is always activated and actDynamicRiThresBaseCalc=false so, check that remote interference is maintained:
    # If rdAutoRiThresBaseCalcInterval=25 then continue checking during at least 25 minutes
    IF    "${ri_state_report}" == "FM off, CM on"
        FOR    ${iteration_alarm}     IN RANGE    1    25+1
            Traced Sleep              duration=45s    msg=checking for remote interference detected (${iteration_alarm}/25)
            # check RI detection using NRCELL/NRRIMINFO/riState = RI detected
            FOR    ${position}    IN  @{list_position_nrcell}
                Critical Step         Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=RI detected
                ...                   confirm_detection=${True}
            END
        END
    END
    #
    FOR    ${position}    IN          @{list_position_nrcell}
        Stop Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}    profile_id=1
    END
    IF    "${ri_state_report}" == "FM off, CM on"
        FOR    ${position}    IN          @{list_position_nrcell}
            Critical Step             Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=no RI
            ...                       confirm_detection=${True}
        END
    END
    FOR    ${iteration_alarm}         IN RANGE    1    100+1
        Traced Sleep                  duration=10s    msg=checking for remote interference deactivation (${iteration_alarm}/100)
        ${is_alarm_present}=          Is Alarm Present    alarm_id=7115    fault_id=7525    iteration=1    confirm_presence=${False}
        Exit For Loop If              not ${is_alarm_present}
    END
    Should Be True                    ${is_alarm_present} == ${False}
    # Deregister all the ue's
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                "${current_elem.call_type}" == "SA"
        ...               Step        CallSetup.UE Deregister    id=${current_elem.ue}    ue_deregister_type=switch_off    by=ue
        ...                           depends=Ue Register And CRNTI Backup
        ...       ELSE
        ...               Step        CallSetup.UE Detach Enb    ueSetting=${current_elem}    depends=UE Establish NSA Call
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
CB014613 Call And Then Traffic SR A_12
    [Arguments]             ${param}
    ...                     ${ues_settings}
    ...                     ${capture_settings}
    ...                     ${list_position_nrcell}
    ...                     ${delay_before_RI}=8m    # delay of 8 minutes before checking for remote interference
    ...                     ${frameStructureType}=tdLte
    ...                     ${bypassX2Setup}=${False}
    #
    Dated Log New Line                ${cc_cyan}----CB014613 Call And Then Traffic SR-CR----${cc_normal}
    # Capture SYSLOG start during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
        ${syslog_full_scenario}=      SYSLOG Start    host=${GNB_DU.sys[0].M}    name=full_scenario
    END
    ${param.total_nb_ue}=             Set Variable    0
    IF    ${CALL_ENABLED}
        ${param.total_nb_ue}=         Get Length    ${ues_settings}
    END
    ${list_ue}    ${cell_id_for_streaming}    Get List UEs Settings    param=${param}    dict_settings=${ues_settings}
    Display List UEs Settings         ${list_ue}
    Dated Log                         > Cells list for TTI streaming is ${cell_id_for_streaming}
    #
    Dated Log New Line                ${cc_cyan}----CallSetup WTS Setup----${cc_normal}
    Critical Step                     CallSetup.WTS Setup           nbUe=${param.total_nb_ue}    nbSaUe=${param.nb_sa_ue}    shouldUseLua=${False}
    ...                               bypassX2Setup=${bypassX2Setup}
    #
    @{cell_id_list}=                  Get List Cells Retained For TTI Streaming SR-CR    cell_id_streaming=${cell_id_for_streaming}
    Dated Log                         > Distname list of the cells retained for TTI streaming ${cell_id_list}
    IF    ${isAic}
        @{cell_id_list}=              Copy List    ${cell_id_for_streaming}
    END
    #
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are initialzed with legacy values just after cell setup
    @{riThresBasePerSubband_val}=     Create List    -110    -110    -110    -110    -110
    &{dico_nrriminfo}=                Create Dictionary    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    riThresBasePerSubband=${riThresBasePerSubband_val}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    Step                              Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}   percentage_tolerance=0
    #
    # Capture L1L2 traces start during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Captures Init    isMirror=${True}
                                      Capture Start    capture=${capture_l1l2}
                                      Sleep    10s
    END
    Dated Log New Line                ${cc_cyan}----Call Establishment----${cc_normal}
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                "${current_elem.call_type}" == "SA"    Run Keywords
        ...          Critical Step    UE Register And CRNTI Backup    ue_settings=${current_elem}    depends=CallSetup.WTS Setup
        ...    AND            Step    CallSetup.Launch PDU Session    ue=${current_elem.ue}    pdu=${current_elem.pdu}    gw=${current_elem.ue}
        ...                           depends=UE Register And CRNTI Backup
        ...       ELSE
        ...          Critical Step    UE Establish NSA Call    ue_settings=${current_elem}    depends=CallSetup.WTS Setup
        Run Keyword If                ${current_elem.throughput_gbr} > 0    Run Keywords
        ...    Dated Log New Line     ${cc_cyan}----Update PDU session reserved for the ue's configured with GBR traffic----${cc_normal}
        ...    AND            Step    CallSetup.UE PDU Session Modify    ue=${current_elem.ue}    pdu=${current_elem.pdu}    qfta=2    by=amf
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND                    Sleep    2s
        ...    AND            Step    CallSetup.UE PDU Session Modify    ue=${current_elem.ue}    pdu=${current_elem.pdu}    qfta=3    by=amf
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND                    Sleep    2s
    END
    # Capture L1L2 traces stop during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Capture L1L2 Stop    capture_config=${capture_l1l2}    output_suffix=call_setup
    END
    #
    Display List UEs Settings         ${list_ue}
    # Capture L1L2 traces start during traffic
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Captures Init
                                      Capture Start    capture=${capture_l1l2}
    END
    Dated Log New Line                ${cc_cyan}----Start non-GBR Traffic----${cc_normal}
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                "${param.dir}" != "${None}"
        ...                   Step    ${param.dir} Traffic Not Stopped Common    param=${param}    current_ue_setting=${current_elem}
    END
    Dated Log New Line                ${cc_cyan}----Start GBR Traffic----${cc_normal}
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                ${current_elem.throughput_gbr} > 0    Run Keywords
        ...                   Step    DL Traffic GBR SA Not Stopped    param=${param}    current_ue_setting=${current_elem}
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND            Step    UL Traffic GBR SA Not Stopped    param=${param}    current_ue_setting=${current_elem}
        ...                           depends=CallSetup.Launch PDU Session
    END
    Traced Sleep                      duration=10s    msg=traffic and before stopping capture L1L2
    # Capture L1L2 traces stop during traffic
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Capture L1L2 Stop    capture_config=${capture_l1l2}    output_suffix=traffic
    END
    # Capture TTI traces start and stop during traffic
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti] and "${cell_id_list}" != "${None}"
                                      Start TTI Logs SR-CR    cell_id_list=${cell_id_list}
                                      Traced Sleep    duration=10s    msg=traffic and before stopping capture TTI
        @{list_events}=  Create List  utcTimestampData  ulAllocatedPooledResourcesData  dlAllocatedPooledResourcesData  ulFdSchedData  dlFdSchedData
                                      Stop and Get TTI Logs SR-CR    trace_name=TTI_traffic    list_events_to_filter=${list_events}
    END
    # Get actRimCmFmReport configuration to identify riStateReport mode: 'FM on, CM off' <=> alarm or 'FM off, CM on' <=> riState
    IF    not ${isAic}
        ${entity_oam}=                Set Variable    ${GNB_DU.oam}
        ${parameter_list}=            Create List    actRimCmFmReport
    ELSE
        ${entity_oam}=                Set Variable    ${TGNB_DU[0].oam}
        ${parameter_list}=            Set Variable    actRimCmFmReport
    END
    ${result_report}=                 Oam.OAM Get Parameter By Distname    oam=${entity_oam}    dist_name=${dn_nrbts}
    ...                               parameter_list=${parameter_list}    include_children=${False}    timeout=30    detailed_output=${False}
    Dated Log                         > OAM Get Parameter By Distname= ${result_report}
    IF    not ${isAic}
        ${ri_state_report}=           Get riStateReport Parameters From actRimCmFmReport SR    current_elem=${result_report}
    ELSE
        ${ri_state_report}=           Get riStateReport Parameters From actRimCmFmReport CR    current_elem=${result_report}
    END
    Dated Log                         ${cc_red}> ri_state_report= ${ri_state_report}${cc_normal}
    #
    Dated Log                         ${cc_cyan}----OAM get active alarm and check remote interference is not yet detected----${cc_normal}
    ${is_alarm_present}=              Is Alarm Present    alarm_id=7115    fault_id=7525    iteration=2    confirm_presence=${False}
    Should Be True                    ${is_alarm_present} == ${False}
    #
    IF    "${ri_state_report}" == "FM off, CM on"
        FOR    ${position}    IN          @{list_position_nrcell}
            Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=no RI    iteration_max=1
            ...                       confirm_detection=${True}    #for bypassing PR868877#${False}
        END
    END
    #
    ${start_symbol_pos_val}=          Set Variable    0
    IF    "${frameStructureType}" == "tdLte"
        ${num_symbols_val}=           Set Variable    32
    ELSE
        ${num_symbols_val}=           Set Variable    16
    END
    #
    Dated Log New Line                ${cc_cyan}----Simulate Remote Interference using profile_id=10----${cc_normal}
    Step                              Create RI Testmode NR Profile     profile_id=10    noise_power_val=${param.RI_N_PW_10}
    ...                               start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
    FOR    ${position}    IN          @{list_position_nrcell}
        Step                          Start Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}
        ...                           profile_id=10
    END
    Traced Sleep                      duration=${delay_before_RI}  msg=${cc_cyan}remote interference and before starting alarm detection${cc_normal}
    # Check for remote interference alarm
    &{capture_detection}=           Create Dictionary    is_capture_l1l2=${False}    is_capture_tti=${False}    is_capture_syslog=${False}
    FOR    ${position}    IN          @{list_position_nrcell}
        IF    "${ri_state_report}" == "FM on, CM off"
            # check RI detection using active alarm 7115 fault_id=7525
            ${internal_pos}=          Evaluate    ${position}-1
            ${victim_cell}=           Set Variable    ${TDD_Cell_list[${internal_pos}].nrCellId}
            ${current_nrcell}=        Set Variable    NRCELL-${victim_cell}
            # [7115][7525](Minor) b'BASE STATION INFORMATION'           :b'Remote interference detected'
            Critical Step             Get Active Alarm And Check Specific Detection    capture=${capture_detection}
            ...                       alarm_id=7115    fault_id=7525    alarm_object=${current_nrcell}    iteration_max=50
            ...                       suffix=detection_${current_nrcell}    cell_id_list=${cell_id_list}    oam_type=${entity_oam}
        ELSE IF    "${ri_state_report}" == "FM off, CM on"
            # check RI detection using NRCELL/NRRIMINFO/riState = RI detected
            Critical Step             Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=RI detected
            ...                       confirm_detection=${True}
        ELSE
            # no detection required
            Dated Log                 ${cc_red}> Remote Interference detection is NOT required${cc_normal}
        END
    END
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are changed
    @{riThresBasePerSubband_val}=     Create List    -110    -110    -110    -110    -110
    &{dico_nrriminfo}=                Create Dictionary    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    riThresBasePerSubband=${riThresBasePerSubband_val}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    Step                              Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}  percentage_tolerance=10
    FOR    ${position}    IN          @{list_position_nrcell}
        Stop Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}    profile_id=10
    END
    #
    # rdAutoRiThresBaseCalcInterval set to 12 minutes (default=0)
    Set Rad Parameter Using Aashell    rad_param_value=12    rad_param=0x58061d
    # rdAutoRiThresBaseCalcInterval is set to 12 minutes for this test.
    # Robot WA is to delayed the 2nd remote interference starting / end of calculation interval for thresholds and return to state=no RI
    Traced Sleep                      duration=300s  msg=${cc_cyan}end of calculation interval for the remote interference thresholds${cc_normal}
    &{dico_nrriminfo}=                Create Dictionary    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    riThresBasePerSubband=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    #
    Dated Log New Line                ${cc_cyan}----Simulate Remote Interference using profile_id=1----${cc_normal}
    Step                              Create RI Testmode NR Profile     profile_id=1    noise_power_val=${param.RI_N_PW_1}
    ...                               start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
    FOR    ${position}    IN          @{list_position_nrcell}
        Step                          Start Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}
        ...                           profile_id=1
    END
    Traced Sleep                      duration=180s    msg=${cc_cyan}remote interference and before starting alarm detection${cc_normal}
    # Check for remote interference alarm
    FOR    ${position}    IN          @{list_position_nrcell}
        IF    "${ri_state_report}" == "FM on, CM off"
            # check RI detection using active alarm 7115 fault_id=7525
            ${internal_pos}=          Evaluate    ${position}-1
            ${victim_cell}=           Set Variable    ${TDD_Cell_list[${internal_pos}].nrCellId}
            ${current_nrcell}=        Set Variable    NRCELL-${victim_cell}
            # [7115][7525](Minor) b'BASE STATION INFORMATION'           :b'Remote interference detected'
            Critical Step             Get Active Alarm And Check Specific Detection    capture=${capture_detection}
            ...                       alarm_id=7115    fault_id=7525    alarm_object=${current_nrcell}    iteration_max=50
            ...                       suffix=detection_${current_nrcell}    cell_id_list=${cell_id_list}    oam_type=${entity_oam}
        ELSE IF    "${ri_state_report}" == "FM off, CM on"
            # check RI detection using NRCELL/NRRIMINFO/riState = RI detected
            Critical Step             Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=RI detected
            ...                       confirm_detection=${True}
        ELSE
            # no detection required
            Dated Log                 ${cc_red}> Remote Interference detection is NOT required${cc_normal}
        END
    END
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are changed
    @{riThresBasePerSubband_val}=     Create List    -82    -82    -82    -82    -82
    &{dico_nrriminfo}=                Create Dictionary    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    riThresBasePerSubband=${riThresBasePerSubband_val}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    Step                              Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}  percentage_tolerance=10
    FOR    ${position}    IN          @{list_position_nrcell}
        Stop Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}    profile_id=1
    END
    #
    #
    # Step to reassemble the previously calculated thresholds
    Dated Log New Line                ${cc_cyan}----Simulate Remote Interference using profile_id=100----${cc_normal}
    Step                              Create RI Testmode NR Profile     profile_id=100    noise_power_val=${RI_0}
    ...                               start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
    FOR    ${position}    IN          @{list_position_nrcell}
        Step                          Start Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}
        ...                           profile_id=100
    END
    Step                              Collect And Check Counter And KPI Constraints SR-CR    param=${param}    capture_settings=${capture_detection}
    Traced Sleep                      duration=600s  msg=${cc_cyan}remote interference to reassemble the calculated thresholds${cc_normal}
    ${riThresBasePerSubband_val}=     Create List    -90    -90    -90    -90    -90
    &{dico_nrriminfo}=                Create Dictionary    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    riThresBasePerSubband=${riThresBasePerSubband_val}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    Step                              Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}  percentage_tolerance=20
    #
    # Online NIDD modification for setting nrRiMonitorWindow=3
    &{dico_nrrim_online_modif}=       Create Dictionary    nrRiMonitorWindow=3    nrcell_tdd=${list_position_nrcell}
    Step    Online Modification NRRIM PROFILE Parameters SR-CR    ${dico_nrrim_online_modif}    nrcell_key=nrcell_tdd   list_nrcell=${TDD_Cell_list}
    # Check the result of the online modification in case of a PDL rule exists
    ${scf_online_modification}=       Oam.OAM Get SCF File    file=SCF_DU_ONLINE.xml
    ${result_scf_val}  ${result_pdl}  SCF Validate NIDD And PDL Rules    scf_file=${scf_online_modification}
    Should Be True                    ${result_scf_val}
    #
    # Check that riThresBasePerSubband thresholds are not cleared after online modification
    FOR    ${iteration}     IN RANGE    0    15
        ${nrriminfo_result}=          Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
        ...                           list_nrcell=${TDD_Cell_list}
        Dated Log New Line            ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
        Traced Sleep                  duration=60s    msg=checking for riThresBasePerSubband thresholds not cleared (${iteration})
    END
    FOR    ${position}    IN          @{list_position_nrcell}
        Stop Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}    profile_id=100
    END
    Traced Sleep                      duration=300s  msg=${cc_cyan}end of calculation interval for the remote interference thresholds${cc_normal}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    Step                              Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}  percentage_tolerance=20
    #
    Dated Log New Line                ${cc_cyan}----Simulate Remote Interference using profile_id=6----${cc_normal}
    Step                              Create RI Testmode NR Profile     profile_id=6    noise_power_val=${RI_N_PW_6}
    ...                               start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
    FOR    ${position}    IN          @{list_position_nrcell}
        Step                          Start Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}
        ...                           profile_id=6
    END
    Traced Sleep                      duration=300s  msg=${cc_cyan}remote interference and before starting alarm detection${cc_normal}
    # Check for remote interference alarm
    FOR    ${position}    IN          @{list_position_nrcell}
        IF    "${ri_state_report}" == "FM on, CM off"
            # check RI detection using active alarm 7115 fault_id=7525
            ${internal_pos}=          Evaluate    ${position}-1
            ${victim_cell}=           Set Variable    ${TDD_Cell_list[${internal_pos}].nrCellId}
            ${current_nrcell}=        Set Variable    NRCELL-${victim_cell}
            # [7115][7525](Minor) b'BASE STATION INFORMATION'           :b'Remote interference detected'
            Critical Step             Get Active Alarm And Check Specific Detection    capture=${capture_detection}
            ...                       alarm_id=7115    fault_id=7525    alarm_object=${current_nrcell}    iteration_max=50
            ...                       suffix=detection_${current_nrcell}    cell_id_list=${cell_id_list}    oam_type=${entity_oam}
        ELSE IF    "${ri_state_report}" == "FM off, CM on"
            # check RI detection using NRCELL/NRRIMINFO/riState = RI detected
            Critical Step             Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=RI detected
            ...                       confirm_detection=${True}
        ELSE
            # no detection required
            Dated Log                 ${cc_red}> Remote Interference detection is NOT required${cc_normal}
        END
    END
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are changed
    &{dico_nrriminfo}=                Create Dictionary    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    riThresBasePerSubband=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    # Capture SYSLOG stop during dynamic detection
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
                                      SYSLOG Stop    syslog=${syslog_full_scenario}
        ${status}   ${ret}   Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${param.syslog_grep_target}
        IF   "${status}" == "PASS"
                                      Run    command=chmod 777 ${param.syslog_grep_target}
                                      Run    command=${param.syslog_grep_target} ${LOG_PATH}/SYSLOG > ${LOG_PATH}/SYSLOG/grep_result.txt
        ELSE
            Dated Log                 > ${param.syslog_grep_target} is NOT present
        END
    END
    FOR    ${position}    IN          @{list_position_nrcell}
        Stop Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}    profile_id=6
    END
    IF    "${ri_state_report}" == "FM off, CM on"
        FOR    ${position}    IN          @{list_position_nrcell}
            Critical Step             Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=no RI
            ...                       confirm_detection=${True}
        END
    END
    FOR    ${iteration_alarm}         IN RANGE    1    100+1
        Traced Sleep                  duration=10s    msg=checking for remote interference deactivation (${iteration_alarm}/100)
        ${is_alarm_present}=          Is Alarm Present    alarm_id=7115    fault_id=7525    iteration=1    confirm_presence=${False}
        Exit For Loop If              not ${is_alarm_present}
    END
    Should Be True                    ${is_alarm_present} == ${False}
    # Deregister all the ue's
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                "${current_elem.call_type}" == "SA"
        ...               Step        CallSetup.UE Deregister    id=${current_elem.ue}    ue_deregister_type=switch_off    by=ue
        ...                           depends=Ue Register And CRNTI Backup
        ...       ELSE
        ...               Step        CallSetup.UE Detach Enb    ueSetting=${current_elem}    depends=UE Establish NSA Call
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
#Simulate Remote Interference CB014613 SR-CR A_14
#   [Arguments]             ${list_position_nrcell}
#   ...                     ${rdRiDataTrimThreshold}
#   ...                     ${start_symbol_pos_val}
#   ...                     ${num_symbols_val}
#   ...                     ${capture_detection}
#   ...                     ${cell_id_list}
#   ...                     ${entity_oam}
#   ...                     ${ri_state_report}
#   #
#   Dated Log New Line                ${cc_cyan}----Simulate Remote Interference CB014613 SR-CR A_14----${cc_normal}
#   #
#   # Deactivate/activate feature to restore static thresholds
#   # Online NIDD modification for setting actDynamicRiThresBaseCalc=false
#   &{dico_nrrim_online_modif}=       Create Dictionary    actDynamicRiThresBaseCalc=false    nrcell_tdd=${list_position_nrcell}
#   Step    Online Modification NRRIM PROFILE Parameters SR-CR    ${dico_nrrim_online_modif}    nrcell_key=nrcell_tdd   list_nrcell=${TDD_Cell_list}
#   Traced Sleep                      duration=10s    msg=${cc_cyan}online modification of actDynamicRiThresBaseCalc=false${cc_normal}
#   #
#   # Online NIDD modification for setting actDynamicRiThresBaseCalc=true
#   &{dico_nrrim_online_modif}=       Create Dictionary    actDynamicRiThresBaseCalc=true    nrcell_tdd=${list_position_nrcell}
#   Step    Online Modification NRRIM PROFILE Parameters SR-CR    ${dico_nrrim_online_modif}    nrcell_key=nrcell_tdd   list_nrcell=${TDD_Cell_list}
#   Traced Sleep                      duration=10s    msg=${cc_cyan}online modification of actDynamicRiThresBaseCalc=true${cc_normal}
#   #
#   Dated Log                         ${cc_cyan}> Online Modification RAD parameters rdRiDataTrimThreshold=${rdRiDataTrimThreshold}${cc_normal}
#   Dated Log                         ${cc_yellow}> Set Rad Parameter rdRiDataTrimThreshold=${rdRiDataTrimThreshold} Using Aashell${cc_normal}
#   IF    not ${isAic}
#       Set Rad Parameter Using Aashell   rad_param_value=${rdRiDataTrimThreshold}    rad_param=0x58061c
#   ELSE
#       Set Rad Parameter Using Aashell   rad_param_value=${rdRiDataTrimThreshold}    rad_param=0x58061c    domain_nom=ute-l2rt-a-0
#       ...                           domain_elem=ctr-l2rt
#   END
#   Traced Sleep                      duration=120s    msg=${cc_cyan}online modification of RAD parameter${cc_normal}
#   # Get riThresBasePerSubband Values SR-CR
#   ${riThresBasePerSubband_val}=    Create List    -110    -110    -110    -110    -110
#   &{dico_nrriminfo}=                Create Dictionary    riThresBasePerSubband=${riThresBasePerSubband_val}
#   ...                                                    nrcell_tdd=${list_position_nrcell}
#   ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
#   ...                               list_nrcell=${TDD_Cell_list}
#   Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
#    IF    not ${isAic}
#        Step                          Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}  percentage_tolerance=0
#    ELSE
#        Step                          Check NRRIMINFO Parameter riThresBasePerSubband CR    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
#        ...                           percentage_tolerance=0
#    END
#   #
#   Dated Log New Line                ${cc_cyan}----Simulate Remote Interference using profile_id=10----${cc_normal}
#   IF    not ${isAic}
#       Step                          Create RI Testmode NR Profile     profile_id=10    noise_power_val=${RI_N_PW_10}
#       ...                           start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
#   ELSE
#       Step                          Create RI Testmode NR Profile     profile_id=10    noise_power_val=${RICRNPW_10}
#       ...                           start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
#   END
#   FOR    ${position}    IN          @{list_position_nrcell}
#       Step                          Start Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}
#       ...                           profile_id=10
#   END
#   Traced Sleep                      duration=600s    msg=${cc_cyan}remote interference and before reading current thresholds${cc_normal}
#   # Get riThresBasePerSubband Values SR-CR
#   IF    not ${isAic}
#       ${riThresBasePerSubband_val}=    Create List    -95    -95    -95    -95    -95
#   ELSE
#       ${riThresBasePerSubband_val}=    Create List    -89    -89    -89    -89    -89
#   END
#   &{dico_nrriminfo}=                Create Dictionary    riThresBasePerSubband=${riThresBasePerSubband_val}
#   ...                                                    nrcell_tdd=${list_position_nrcell}
#   FOR    ${iteration}     IN RANGE    1    5+1
#       ${nrriminfo_result}=          Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
#       ...                           list_nrcell=${TDD_Cell_list}
#       Dated Log New Line            ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
#       Traced Sleep                  duration=60s    msg=${cc_cyan}riThresBasePerSubband thresholds reading (${iteration})${cc_normal}
#   END
#   IF    not ${isAic}
#       Step                          Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}  percentage_tolerance=10
#   ELSE
#       Step                          Check NRRIMINFO Parameter riThresBasePerSubband CR    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
#       ...                           percentage_tolerance=10
#   END
#   FOR    ${position}    IN          @{list_position_nrcell}
#       Stop Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}    profile_id=10
#   END
#   Traced Sleep                      duration=180s    msg=${cc_cyan}the stop of remote interference${cc_normal}
#   #
#   #
#   Dated Log                         ${cc_cyan}> Simulate Remote Interference using profile_id=6----${cc_normal}
#   IF    not ${isAic}
#       Step                          Create RI Testmode NR Profile     profile_id=10    noise_power_val=${RI_N_PW_6}
#       ...                           start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
#   ELSE
#       Step                          Create RI Testmode NR Profile     profile_id=10    noise_power_val=${RICRNPW_6}
#       ...                           start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
#   END
#   FOR    ${position}    IN          @{list_position_nrcell}
#       Step                          Start Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}
#       ...                           profile_id=6
#   END
#   Traced Sleep                      duration=600s    msg=${cc_cyan}remote interference and before reading current thresholds${cc_normal}
#   # Get riThresBasePerSubband Values SR-CR
#   IF    not ${isAic}
#       ${riThresBasePerSubband_val}=    Create List    -92    -92    -92    -92    -92
#   ELSE
#       ${riThresBasePerSubband_val}=    Create List    -86    -86    -86    -86    -86
#   END
#   &{dico_nrriminfo}=                Create Dictionary    riThresBasePerSubband=${riThresBasePerSubband_val}
#   ...                                                    nrcell_tdd=${list_position_nrcell}
#   FOR    ${iteration}     IN RANGE    1    5+1
#       ${nrriminfo_result}=          Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
#       ...                           list_nrcell=${TDD_Cell_list}
#       Dated Log New Line            ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
#       Traced Sleep                  duration=60s    msg=${cc_cyan}riThresBasePerSubband thresholds reading (${iteration})${cc_normal}
#   END
#   IF    not ${isAic}
#       Step                          Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}  percentage_tolerance=10
#   ELSE
#       Step                          Check NRRIMINFO Parameter riThresBasePerSubband CR    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
#       ...                           percentage_tolerance=10
#   END
#   FOR    ${position}    IN          @{list_position_nrcell}
#       Stop Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}    profile_id=6
#   END
#   Traced Sleep                      duration=180s    msg=${cc_cyan}the stop of remote interference${cc_normal}
#   #
#   #
#   Dated Log New Line                ${cc_cyan}----Simulate Remote Interference using profile_id=1----${cc_normal}
#   IF    not ${isAic}
#       Step                          Create RI Testmode NR Profile     profile_id=10    noise_power_val=${RI_N_PW_1}
#       ...                           start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
#   ELSE
#       Step                          Create RI Testmode NR Profile     profile_id=10    noise_power_val=${RICRNPW_1}
#       ...                           start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
#   END
#   FOR    ${position}    IN          @{list_position_nrcell}
#       Step                          Start Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}
#       ...                           profile_id=1
#   END
#   Traced Sleep                      duration=600s    msg=${cc_cyan}remote interference and before reading current thresholds${cc_normal}
#   # Get riThresBasePerSubband Values SR-CR
#   IF    not ${isAic}
#       ${riThresBasePerSubband_val}=    Create List    -90    -90    -90    -90    -90
#   ELSE
#       ${riThresBasePerSubband_val}=    Create List    -84    -84    -84    -84    -84
#   END
#   &{dico_nrriminfo}=                Create Dictionary    riThresBasePerSubband=${riThresBasePerSubband_val}
#   ...                                                    nrcell_tdd=${list_position_nrcell}
#   FOR    ${iteration}     IN RANGE    1    5+1
#       ${nrriminfo_result}=          Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
#       ...                           list_nrcell=${TDD_Cell_list}
#       Dated Log New Line            ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
#       Traced Sleep                  duration=60s    msg=${cc_cyan}riThresBasePerSubband thresholds reading (${iteration})${cc_normal}
#   END
#   IF    not ${isAic}
#       Step                          Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}  percentage_tolerance=10
#   ELSE
#       Step                          Check NRRIMINFO Parameter riThresBasePerSubband CR    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
#       ...                           percentage_tolerance=10
#   END
#   FOR    ${position}    IN          @{list_position_nrcell}
#       Stop Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}    profile_id=1
#   END
#   Traced Sleep                      duration=180s    msg=${cc_cyan}the stop of remote interference${cc_normal}


Simulate Remote Interference CB014613 SR-CR A_14
    [Arguments]             ${list_position_nrcell}
    ...                     ${rdRiDataTrimThreshold}
    ...                     ${start_symbol_pos_val}
    ...                     ${num_symbols_val}
    #
    Dated Log New Line                ${cc_cyan}----Simulate Remote Interference CB014613 SR-CR A_14----${cc_normal}
    #
    # Deactivate/activate feature to restore static thresholds
    # Online NIDD modification for setting actDynamicRiThresBaseCalc=false
    &{dico_nrrim_online_modif}=       Create Dictionary    actDynamicRiThresBaseCalc=false    nrcell_tdd=${list_position_nrcell}
    Step    Online Modification NRRIM PROFILE Parameters SR-CR    ${dico_nrrim_online_modif}    nrcell_key=nrcell_tdd   list_nrcell=${TDD_Cell_list}
    Traced Sleep                      duration=10s    msg=${cc_cyan}online modification of actDynamicRiThresBaseCalc=false${cc_normal}
    #
    # Online NIDD modification for setting actDynamicRiThresBaseCalc=true
    &{dico_nrrim_online_modif}=       Create Dictionary    actDynamicRiThresBaseCalc=true    nrcell_tdd=${list_position_nrcell}
    Step    Online Modification NRRIM PROFILE Parameters SR-CR    ${dico_nrrim_online_modif}    nrcell_key=nrcell_tdd   list_nrcell=${TDD_Cell_list}
    Traced Sleep                      duration=10s    msg=${cc_cyan}online modification of actDynamicRiThresBaseCalc=true${cc_normal}
    #
    Dated Log                         ${cc_cyan}> Online Modification RAD parameters rdRiDataTrimThreshold=${rdRiDataTrimThreshold}${cc_normal}
    Dated Log                         ${cc_yellow}> Set Rad Parameter rdRiDataTrimThreshold=${rdRiDataTrimThreshold} Using Aashell${cc_normal}
    IF    not ${isAic}
        Set Rad Parameter Using Aashell   rad_param_value=${rdRiDataTrimThreshold}    rad_param=0x58061c
    ELSE
        Set Rad Parameter Using Aashell   rad_param_value=${rdRiDataTrimThreshold}    rad_param=0x58061c    domain_nom=ute-l2rt-a-0
        ...                           domain_elem=ctr-l2rt
    END
    Traced Sleep                      duration=10s    msg=${cc_cyan}online modification of RAD parameter${cc_normal}
    #
    Dated Log New Line                ${cc_cyan}----Simulate Remote Interference using profile_id=10----${cc_normal}
    IF    not ${isAic}
        Step                          Create RI Testmode NR Profile     profile_id=10    noise_power_val=${RI_N_PW_10}
        ...                           start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
    ELSE
        Step                          Create RI Testmode NR Profile     profile_id=10    noise_power_val=${RICRNPW_10}
        ...                           start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
    END
    FOR    ${position}    IN          @{list_position_nrcell}
        Step                          Start Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}
        ...                           profile_id=10
    END
    Traced Sleep                      duration=300s    msg=${cc_cyan}remote interference and before reading current thresholds${cc_normal}
    &{dico_nrriminfo}=                Create Dictionary    riThresBasePerSubband=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    FOR    ${iteration}     IN RANGE    1    3+1
        ${nrriminfo_result}=          Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
        ...                           list_nrcell=${TDD_Cell_list}
        Dated Log New Line            ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
        Traced Sleep                  duration=60s    msg=${cc_cyan}riThresBasePerSubband thresholds reading (${iteration})${cc_normal}
    END
    # Get riThresBasePerSubband Values SR-CR
    IF    not ${isAic}
        ${riThresBasePerSubband_val}=    Create List    -95    -95    -95    -95    -95
    ELSE
        ${riThresBasePerSubband_val}=    Create List    -89    -89    -89    -89    -89
    END
    &{dico_nrriminfo}=                Create Dictionary    riThresBasePerSubband=${riThresBasePerSubband_val}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    FOR    ${iteration}     IN RANGE    1    5+1
        ${nrriminfo_result}=          Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
        ...                           list_nrcell=${TDD_Cell_list}
        Dated Log New Line            ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
        Traced Sleep                  duration=60s    msg=${cc_cyan}riThresBasePerSubband thresholds reading (${iteration})${cc_normal}
    END
    IF    not ${isAic}
        Step                          Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}  percentage_tolerance=10
    ELSE
        Step                          Check NRRIMINFO Parameter riThresBasePerSubband CR    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
        ...                           percentage_tolerance=10
    END
    FOR    ${position}    IN          @{list_position_nrcell}
        Stop Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}    profile_id=10
    END
    Traced Sleep                      duration=180s    msg=${cc_cyan}the stop of remote interference${cc_normal}
    #
    #
#   Dated Log                         ${cc_cyan}> Simulate Remote Interference using profile_id=6----${cc_normal}
#   IF    not ${isAic}
#       Step                          Create RI Testmode NR Profile     profile_id=6    noise_power_val=${RI_N_PW_6}
#       ...                           start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
#   ELSE
#       Step                          Create RI Testmode NR Profile     profile_id=6    noise_power_val=${RICRNPW_6}
#       ...                           start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
#   END
#   FOR    ${position}    IN          @{list_position_nrcell}
#       Step                          Start Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}
#       ...                           profile_id=6
#   END
#   Traced Sleep                      duration=600s    msg=${cc_cyan}remote interference and before reading current thresholds${cc_normal}
#   # Get riThresBasePerSubband Values SR-CR
#   IF    not ${isAic}
#       ${riThresBasePerSubband_val}=    Create List    -92    -92    -92    -92    -92
#   ELSE
#       ${riThresBasePerSubband_val}=    Create List    -86    -86    -86    -86    -86
#   END
#   &{dico_nrriminfo}=                Create Dictionary    riThresBasePerSubband=${riThresBasePerSubband_val}
#   ...                                                    nrcell_tdd=${list_position_nrcell}
#   FOR    ${iteration}     IN RANGE    1    5+1
#       ${nrriminfo_result}=          Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
#       ...                           list_nrcell=${TDD_Cell_list}
#       Dated Log New Line            ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
#       Traced Sleep                  duration=60s    msg=${cc_cyan}riThresBasePerSubband thresholds reading (${iteration})${cc_normal}
#   END
#   IF    not ${isAic}
#       Step                          Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}  percentage_tolerance=10
#   ELSE
#       Step                          Check NRRIMINFO Parameter riThresBasePerSubband CR    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
#       ...                           percentage_tolerance=10
#   END
#   FOR    ${position}    IN          @{list_position_nrcell}
#       Stop Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}    profile_id=6
#   END
#   Traced Sleep                      duration=180s    msg=${cc_cyan}the stop of remote interference${cc_normal}
    #
    #
    Dated Log New Line                ${cc_cyan}----Simulate Remote Interference using profile_id=1----${cc_normal}
    IF    not ${isAic}
        Step                          Create RI Testmode NR Profile     profile_id=1    noise_power_val=${RI_N_PW_1}
        ...                           start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
    ELSE
        Step                          Create RI Testmode NR Profile     profile_id=1    noise_power_val=${RICRNPW_1}
        ...                           start_symbol_pos=${start_symbol_pos_val}    num_symbols=${num_symbols_val}
    END
    FOR    ${position}    IN          @{list_position_nrcell}
        Step                          Start Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}
        ...                           profile_id=1
    END
    Traced Sleep                      duration=300s    msg=${cc_cyan}remote interference and before reading current thresholds${cc_normal}
    # Get riThresBasePerSubband Values SR-CR
    IF    not ${isAic}
        ${riThresBasePerSubband_val}=    Create List    -90    -90    -90    -90    -90
    ELSE
        ${riThresBasePerSubband_val}=    Create List    -84    -84    -84    -84    -84
    END
    &{dico_nrriminfo}=                Create Dictionary    riThresBasePerSubband=${riThresBasePerSubband_val}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    FOR    ${iteration}     IN RANGE    1    8+1
        ${nrriminfo_result}=          Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
        ...                           list_nrcell=${TDD_Cell_list}
        Dated Log New Line            ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
        Traced Sleep                  duration=60s    msg=${cc_cyan}riThresBasePerSubband thresholds reading (${iteration})${cc_normal}
    END
    IF    not ${isAic}
        Step                          Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}  percentage_tolerance=10
    ELSE
        Step                          Check NRRIMINFO Parameter riThresBasePerSubband CR    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
        ...                           percentage_tolerance=10
    END
    FOR    ${position}    IN          @{list_position_nrcell}
        Stop Remote Interference on NRCELL    nrcell_pos_victim=${position}    list_nrcell=${TDD_Cell_list}    profile_id=1
    END
    Traced Sleep                      duration=180s    msg=${cc_cyan}the stop of remote interference${cc_normal}
    &{dico_nrriminfo}=                Create Dictionary    riThresBasePerSubband=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    Traced Sleep                      duration=60s    msg=${cc_cyan}riThresBasePerSubband thresholds reading${cc_normal}


CB014613 Call And Then Traffic SR-CR A_14
    [Arguments]             ${param}
    ...                     ${ues_settings}
    ...                     ${capture_settings}
    ...                     ${list_position_nrcell}
    ...                     ${frameStructureType}=tdLte
    ...                     ${bypassX2Setup}=${False}
    #
    Dated Log New Line                ${cc_cyan}----CB014613 Call And Then Traffic SR-CR A_14----${cc_normal}
    # Capture SYSLOG start for full scenario
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
        ${syslog_full_scenario}=      SYSLOG Start    host=${GNB_DU.sys[0].M}    name=full_scenario
    END
    ${param.total_nb_ue}=             Set Variable    0
    IF    ${CALL_ENABLED}
        ${param.total_nb_ue}=         Get Length    ${ues_settings}
    END
    ${list_ue}    ${cell_id_for_streaming}    Get List UEs Settings    param=${param}    dict_settings=${ues_settings}
    Display List UEs Settings         ${list_ue}
    Dated Log                         > Cells list for TTI streaming is ${cell_id_for_streaming}
    #
    Dated Log New Line                ${cc_cyan}----CallSetup WTS Setup----${cc_normal}
    Critical Step                     CallSetup.WTS Setup           nbUe=${param.total_nb_ue}    nbSaUe=${param.nb_sa_ue}    shouldUseLua=${False}
    ...                               bypassX2Setup=${bypassX2Setup}
    #
    @{cell_id_list}=                  Get List Cells Retained For TTI Streaming SR-CR    cell_id_streaming=${cell_id_for_streaming}
    Dated Log                         > Distname list of the cells retained for TTI streaming ${cell_id_list}
    IF    ${isAic}
        @{cell_id_list}=              Copy List    ${cell_id_for_streaming}
    END
    #
    # Get riThresBasePerSubband Values SR-CR to check if riThresBasePerSubband's values are initialzed with legacy values just after cell setup
    @{riThresBasePerSubband_val}=     Create List    -110    -110    -110    -110    -110
    &{dico_nrriminfo}=                Create Dictionary    riThresBasePerSubband=${riThresBasePerSubband_val}
    ...                                                    nrRimInfoId=1
    ...                                                    riState=${None}
    ...                                                    nrcell_tdd=${list_position_nrcell}
    ${nrriminfo_result}=              Get riThresBasePerSubband Values SR-CR    dico=${dico_nrriminfo}    nrcell_key=nrcell_tdd
    ...                               list_nrcell=${TDD_Cell_list}
    Dated Log New Line                ${cc_yellow}> NRRIMINFO result= ${nrriminfo_result}${cc_normal}
    IF    not ${isAic}
        Step                          Check NRRIMINFO Parameters    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}  percentage_tolerance=0
    ELSE
        Step                          Check NRRIMINFO Parameter riThresBasePerSubband CR    dico=${dico_nrriminfo}    list_elem=${nrriminfo_result}
        ...                           percentage_tolerance=0
    END
    #
    # Capture L1L2 traces start during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Captures Init    isMirror=${True}
                                      Capture Start    capture=${capture_l1l2}
                                      Sleep    10s
    END
    Dated Log New Line                ${cc_cyan}----Call Establishment----${cc_normal}
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                "${current_elem.call_type}" == "SA"    Run Keywords
        ...          Critical Step    UE Register And CRNTI Backup    ue_settings=${current_elem}    depends=CallSetup.WTS Setup
        ...    AND            Step    CallSetup.Launch PDU Session    ue=${current_elem.ue}    pdu=${current_elem.pdu}    gw=${current_elem.ue}
        ...                           depends=UE Register And CRNTI Backup
        ...       ELSE
        ...          Critical Step    UE Establish NSA Call    ue_settings=${current_elem}    depends=CallSetup.WTS Setup
        Run Keyword If                ${current_elem.throughput_gbr} > 0    Run Keywords
        ...    Dated Log New Line     ${cc_cyan}----Update PDU session reserved for the ue's configured with GBR traffic----${cc_normal}
        ...    AND            Step    CallSetup.UE PDU Session Modify    ue=${current_elem.ue}    pdu=${current_elem.pdu}    qfta=2    by=amf
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND                    Sleep    2s
        ...    AND            Step    CallSetup.UE PDU Session Modify    ue=${current_elem.ue}    pdu=${current_elem.pdu}    qfta=3    by=amf
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND                    Sleep    2s
    END
    # Capture L1L2 traces stop during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Capture L1L2 Stop    capture_config=${capture_l1l2}    output_suffix=call_setup
    END
    #
    Display List UEs Settings         ${list_ue}
    # Capture L1L2 traces start during traffic
    Dated Log New Line                ${cc_cyan}----Start non-GBR Traffic----${cc_normal}
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                "${param.dir}" != "${None}"
        ...                   Step    ${param.dir} Traffic Not Stopped Common    param=${param}    current_ue_setting=${current_elem}
    END
    Dated Log New Line                ${cc_cyan}----Start GBR Traffic----${cc_normal}
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                ${current_elem.throughput_gbr} > 0    Run Keywords
        ...                   Step    DL Traffic GBR SA Not Stopped    param=${param}    current_ue_setting=${current_elem}
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND            Step    UL Traffic GBR SA Not Stopped    param=${param}    current_ue_setting=${current_elem}
        ...                           depends=CallSetup.Launch PDU Session
    END
    Traced Sleep                      duration=10s    msg=traffic and before stopping capture L1L2
    # Capture L1L2 traces stop during traffic
    # Capture TTI traces start and stop during traffic
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti] and "${cell_id_list}" != "${None}"
                                      Start TTI Logs SR-CR    cell_id_list=${cell_id_list}
                                      Traced Sleep    duration=10s    msg=traffic and before stopping capture TTI
        @{list_events}=  Create List  utcTimestampData  ulAllocatedPooledResourcesData  dlAllocatedPooledResourcesData  ulFdSchedData  dlFdSchedData
                                      Stop and Get TTI Logs SR-CR    trace_name=TTI_traffic    list_events_to_filter=${list_events}
    END
    # Get actRimCmFmReport configuration to identify riStateReport mode: 'FM on, CM off' <=> alarm or 'FM off, CM on' <=> riState
    IF    not ${isAic}
        ${entity_oam}=                Set Variable    ${GNB_DU.oam}
        ${parameter_list}=            Create List    actRimCmFmReport
    ELSE
        ${entity_oam}=                Set Variable    ${TGNB_DU[0].oam}
        ${parameter_list}=            Set Variable    actRimCmFmReport
    END
    ${result_report}=                 Oam.OAM Get Parameter By Distname    oam=${entity_oam}    dist_name=${dn_nrbts}
    ...                               parameter_list=${parameter_list}    include_children=${False}    timeout=30    detailed_output=${False}
    Dated Log                         > OAM Get Parameter By Distname= ${result_report}
    IF    not ${isAic}
        ${ri_state_report}=           Get riStateReport Parameters From actRimCmFmReport SR    current_elem=${result_report}
    ELSE
        ${ri_state_report}=           Get riStateReport Parameters From actRimCmFmReport CR    current_elem=${result_report}
    END
    Dated Log                         ${cc_red}> ri_state_report= ${ri_state_report}${cc_normal}
    #
    Dated Log                         ${cc_cyan}----OAM get active alarm and check remote interference is not yet detected----${cc_normal}
    ${is_alarm_present}=              Is Alarm Present    alarm_id=7115    fault_id=7525    iteration=2    confirm_presence=${False}
    Should Be True                    ${is_alarm_present} == ${False}
    #
    IF    "${ri_state_report}" == "FM off, CM on"
        FOR    ${position}    IN          @{list_position_nrcell}
            Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=no RI    iteration_max=1
            ...                       confirm_detection=${True}    #for bypassing PR868877#${False}
        END
    END
    #
    ${start_symbol_pos_val}=          Set Variable    0
    IF    "${frameStructureType}" == "tdLte"
        ${num_symbols_val}=           Set Variable    32
    ELSE
        ${num_symbols_val}=           Set Variable    16
    END
    &{capture_detection}=             Create Dictionary    is_capture_l1l2=${False}    is_capture_tti=${False}    is_capture_syslog=${False}
    #
    #
    Simulate Remote Interference CB014613 SR-CR A_14    list_position_nrcell=${list_position_nrcell}    rdRiDataTrimThreshold=1
    ...                               start_symbol_pos_val=${start_symbol_pos_val}    num_symbols_val=${num_symbols_val}
    #
    Simulate Remote Interference CB014613 SR-CR A_14    list_position_nrcell=${list_position_nrcell}    rdRiDataTrimThreshold=15
    ...                               start_symbol_pos_val=${start_symbol_pos_val}    num_symbols_val=${num_symbols_val}
    #
    Simulate Remote Interference CB014613 SR-CR A_14    list_position_nrcell=${list_position_nrcell}    rdRiDataTrimThreshold=35
    ...                               start_symbol_pos_val=${start_symbol_pos_val}    num_symbols_val=${num_symbols_val}
    #
    #
    # Capture SYSLOG stop for full scenario
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
                                      SYSLOG Stop    syslog=${syslog_full_scenario}
        ${status}   ${ret}   Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${param.syslog_grep_target}
        IF   "${status}" == "PASS"
                                      Run    command=chmod 777 ${param.syslog_grep_target}
                                      Run    command=${param.syslog_grep_target} ${LOG_PATH}/SYSLOG > ${LOG_PATH}/SYSLOG/grep_result.txt
        ELSE
            Dated Log                 > ${param.syslog_grep_target} is NOT present
        END
    END
    IF    "${ri_state_report}" == "FM off, CM on"
        FOR    ${position}    IN          @{list_position_nrcell}
            Critical Step             Get Remote Interference State From NRRIMINFO    position_nrcell=${position}    ri_state=no RI
            ...                       confirm_detection=${True}
        END
    END
    FOR    ${iteration_alarm}         IN RANGE    1    100+1
        Traced Sleep                  duration=10s    msg=checking for remote interference deactivation (${iteration_alarm}/100)
        ${is_alarm_present}=          Is Alarm Present    alarm_id=7115    fault_id=7525    iteration=1    confirm_presence=${False}
        Exit For Loop If              not ${is_alarm_present}
    END
    Should Be True                    ${is_alarm_present} == ${False}
    # Deregister all the ue's
    FOR    ${current_elem}    IN      @{list_ue}
        Run Keyword If                "${current_elem.call_type}" == "SA"
        ...               Step        CallSetup.UE Deregister    id=${current_elem.ue}    ue_deregister_type=switch_off    by=ue
        ...                           depends=Ue Register And CRNTI Backup
        ...       ELSE
        ...               Step        CallSetup.UE Detach Enb    ueSetting=${current_elem}    depends=UE Establish NSA Call
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
Call And Then Traffic SR-CR
    [Arguments]             ${param}
    ...                     ${ues_settings}
    ...                     ${capture_settings}
    #
    Dated Log New Line                ${cc_cyan}----Call And Then Traffic SR-CR----${cc_normal}
    # Capture SYSLOG start during call setup
    ${syslog_call_setup}=             Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
    ...                               SYSLOG Start    host=${GNB_DU.sys[0].M}    name=call_setup
    ${param.total_nb_ue}=             Run Keyword If    ${CALL_ENABLED}    Get Length    ${ues_settings}
    ...           ELSE                Set Variable    0
    ${list_ue}    ${cell_id_for_streaming}    Get List UEs Settings    param=${param}    dict_settings=${ues_settings}
    Display List UEs Settings         ${list_ue}
    Dated Log                         > Cells list for TTI streaming is ${cell_id_for_streaming}
    #
    Dated Log New Line                ----CallSetup WTS Setup----
    Critical Step                     CallSetup.WTS Setup           nbUe=${param.total_nb_ue}    nbSaUe=${param.nb_sa_ue}    shouldUseLua=${False}
    #
    @{cell_id_list}=                  Get List Cells Retained For TTI Streaming SR-CR    cell_id_streaming=${cell_id_for_streaming}
    Dated Log                         > Distname list of the cells retained for TTI streaming ${cell_id_list}
    @{cell_id_list}=                  Run Keyword If    ${isAic}    Copy List    ${cell_id_for_streaming}
    #
    # Capture L1L2 traces start during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Captures Init
                                      Capture Start    capture=${capture_l1l2}
                                      Sleep    10s
    END
    Dated Log New Line                ----Call Establishment----
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If                "${current_elem.call_type}" == "SA"    Run Keywords
        ...          Critical Step    UE Register And CRNTI Backup    ue_settings=${current_elem}    depends=CallSetup.WTS Setup
        ...    AND            Step    CallSetup.Launch PDU Session    ue=${current_elem.ue}    pdu=${current_elem.pdu}    gw=${current_elem.ue}
        ...                           depends=UE Register And CRNTI Backup
        ...       ELSE
        ...          Critical Step    UE Establish NSA Call    ue_settings=${current_elem}    depends=CallSetup.WTS Setup
        Run Keyword If                ${current_elem.throughput_gbr} > 0    Run Keywords
        ...    Dated Log New Line     ----Update PDU session reserved for the ue's configured with GBR traffic----
        ...    AND            Step    CallSetup.UE PDU Session Modify    ue=${current_elem.ue}    pdu=${current_elem.pdu}    qfta=2    by=amf
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND                    Sleep    2s
        ...    AND            Step    CallSetup.UE PDU Session Modify    ue=${current_elem.ue}    pdu=${current_elem.pdu}    qfta=3    by=amf
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND                    Sleep    2s
    END
    # Capture L1L2 traces stop during call setup
    Run Keyword If                    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
    ...                               Capture L1L2 Stop    capture_config=${capture_l1l2}    output_suffix=call_setup
    #
    Display List UEs Settings         ${list_ue}
    # Capture L1L2 traces start during traffic
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Captures Init
                                      Capture Start    capture=${capture_l1l2}
    END
    Dated Log New Line                ----Start non-GBR Traffic----
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If                "${param.dir}" != "${None}"
        ...                   Step    ${param.dir} Traffic Not Stopped Common    param=${param}    current_ue_setting=${current_elem}
    END
    Dated Log New Line                ----Start GBR Traffic----
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If                ${current_elem.throughput_gbr} > 0    Run Keywords
        ...                   Step    DL Traffic GBR SA Not Stopped    param=${param}    current_ue_setting=${current_elem}
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND            Step    UL Traffic GBR SA Not Stopped    param=${param}    current_ue_setting=${current_elem}
        ...                           depends=CallSetup.Launch PDU Session
    END
    Traced Sleep                      duration=10s    msg=traffic and before stopping capture L1L2
    # Capture L1L2 traces stop during traffic
    Run Keyword If                    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
    ...                               Capture L1L2 Stop    capture_config=${capture_l1l2}    output_suffix=traffic
    # Capture TTI traces start during traffic
    Run Keyword If                    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti] and "${cell_id_list}" != "${None}"
    ...                               Start TTI Logs SR-CR    cell_id_list=${cell_id_list}
    Traced Sleep                      duration=10s    msg=traffic and before stopping capture TTI
    # Capture TTI traces stop during traffic
    @{list_events}=                   Create List    utcTimestampData    ulAllocatedPooledResourcesData    dlAllocatedPooledResourcesData
    ...                               ulFdSchedData    dlFdSchedData
    Run Keyword If                    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti] and "${cell_id_list}" != "${None}"
    ...                               Stop and Get TTI Logs SR-CR    trace_name=TTI_traffic    list_events_to_filter=${list_events}
    # Capture SYSLOG stop during call setup
    Run Keyword If                    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog] and not ${isAic}
    ...                               SYSLOG Stop    syslog=${syslog_call_setup}
    #
    FOR    ${iteration_pm}    IN RANGE    1    ${param.pm_waiting_period} + 1
        Dated Log New Line                ----Check Counter And KPI Constraints (${iteration_pm})----
        Wait PM availability          pmPeriodSec=300    #pmAvailDelay=60
        IF    ${isAic}
            ${pm_path}=               Counters.Collect PM files from BTS    ${LOG_PATH}/PM    optional_files=${True}  posProcess=${True}  node='vcu'
            Step                      Check Counter And KPI Constraints SR-CR    pm_path=${pm_path}    test_name=${param.counter_constraint}_VCU
            ${pm_path}=               Counters.Collect PM files from BTS    ${LOG_PATH}/PM    optional_files=${True}  posProcess=${True}  node='vdu'
            Step                      Check Counter And KPI Constraints SR-CR    pm_path=${pm_path}    test_name=${param.counter_constraint}_VDU
        ELSE
            ${pm_path}=               Counters.Collect PM files from BTS    ${LOG_PATH}/PM
            Step                      Check Counter And KPI Constraints SR-CR    pm_path=${pm_path}    test_name=${param.counter_constraint}
        END
    END
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If                "${current_elem.call_type}" == "SA"
        ...               Step        CallSetup.UE Deregister    id=${current_elem.ue}    ue_deregister_type=switch_off    by=ue
        ...                           depends=Ue Register And CRNTI Backup
        ...       ELSE
        ...               Step        CallSetup.UE Detach Enb    ueSetting=${current_elem}    depends=UE Establish NSA Call
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
Call And Then Traffic For Captures Testing
    [Arguments]             ${param}
    ...                     ${ues_settings}
    ...                     ${capture_settings}
    #
    Dated Log New Line                ${cc_cyan}----Call And Then Traffic For Captures Testing----${cc_normal}
    ${param.total_nb_ue}=             Run Keyword If    ${CALL_ENABLED}    Get Length    ${ues_settings}
    ...           ELSE                Set Variable    0
    ${list_ue}    ${cell_id_for_streaming}    Get List UEs Settings    param=${param}    dict_settings=${ues_settings}
    Display List UEs Settings         ${list_ue}
    Dated Log                         > Cells list for TTI streaming is ${cell_id_for_streaming}
    #
    Dated Log New Line                ----CallSetup WTS Setup----
    Critical Step                     CallSetup.WTS Setup           nbUe=${param.total_nb_ue}    nbSaUe=${param.nb_sa_ue}    shouldUseLua=${False}
    #
    @{cell_id_list}=                  Get List Cells Retained For TTI Streaming SR-CR    cell_id_streaming=${cell_id_for_streaming}
    Dated Log                         > Distname list of the cells retained for TTI streaming ${cell_id_list}
    @{cell_id_list}=                  Run Keyword If    ${isAic}    Copy List    ${cell_id_for_streaming}
    #
    # Capture L1L2 traces start during call setup
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Captures Init    isMirror=${True}
                                      Capture Start    capture=${capture_l1l2}
                                      Sleep    10s
    END
    Dated Log New Line                ----Call Establishment----
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If                "${current_elem.call_type}" == "SA"    Run Keywords
        ...          Critical Step    UE Register And CRNTI Backup    ue_settings=${current_elem}    depends=CallSetup.WTS Setup
        ...    AND            Step    CallSetup.Launch PDU Session    ue=${current_elem.ue}    pdu=${current_elem.pdu}    gw=${current_elem.ue}
        ...                           depends=UE Register And CRNTI Backup
        ...       ELSE
        ...          Critical Step    UE Establish NSA Call    ue_settings=${current_elem}    depends=CallSetup.WTS Setup
        Run Keyword If                ${current_elem.throughput_gbr} > 0    Run Keywords
        ...    Dated Log New Line     ----Update PDU session reserved for the ue's configured with GBR traffic----
        ...    AND            Step    CallSetup.UE PDU Session Modify    ue=${current_elem.ue}    pdu=${current_elem.pdu}    qfta=2    by=amf
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND                    Sleep    2s
        ...    AND            Step    CallSetup.UE PDU Session Modify    ue=${current_elem.ue}    pdu=${current_elem.pdu}    qfta=3    by=amf
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND                    Sleep    2s
    END
    # Capture L1L2 traces stop during call setup
    Run Keyword If                    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
    ...                               Capture L1L2 Stop    capture_config=${capture_l1l2}    output_suffix=call_setup
    #
    Display List UEs Settings         ${list_ue}
    # Capture L1L2 traces start during traffic
    IF    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
                                      Captures Init
                                      Capture Start    capture=${capture_l1l2}
    END
    Dated Log New Line                ----Start non-GBR Traffic----
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If                "${param.dir}" != "${None}"
        ...                   Step    ${param.dir} Traffic Not Stopped Common    param=${param}    current_ue_setting=${current_elem}
    END
    Dated Log New Line                ----Start GBR Traffic----
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If                ${current_elem.throughput_gbr} > 0    Run Keywords
        ...                   Step    DL Traffic GBR SA Not Stopped    param=${param}    current_ue_setting=${current_elem}
        ...                           depends=CallSetup.Launch PDU Session
        ...    AND            Step    UL Traffic GBR SA Not Stopped    param=${param}    current_ue_setting=${current_elem}
        ...                           depends=CallSetup.Launch PDU Session
    END
    Traced Sleep                      duration=10s    msg=traffic and before stopping capture L1L2
    # Capture L1L2 traces stop during traffic
    Run Keyword If                    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]
    ...                               Capture L1L2 Stop    capture_config=${capture_l1l2}    output_suffix=traffic
    #
    # Capture TTI traces start during traffic
    Run Keyword If                    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti] and "${cell_id_list}" != "${None}"
    ...                               Start TTI Logs SR-CR    cell_id_list=${cell_id_list}
    Traced Sleep                      duration=10s    msg=traffic and before stopping capture TTI
    # Capture TTI traces stop during traffic
    @{list_events}=                   Create List    utcTimestampData    ulAllocatedPooledResourcesData    dlAllocatedPooledResourcesData
    ...                               ulFdSchedData    dlFdSchedData
    Run Keyword If                    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti] and "${cell_id_list}" != "${None}"
    ...                               Stop and Get TTI Logs SR-CR    trace_name=TTI_traffic    list_events_to_filter=${list_events}
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If                "${current_elem.call_type}" == "SA"
        ...               Step        CallSetup.UE Deregister    id=${current_elem.ue}    ue_deregister_type=switch_off    by=ue
        ...                           depends=Ue Register And CRNTI Backup
        ...       ELSE
        ...               Step        CallSetup.UE Detach Enb    ueSetting=${current_elem}    depends=UE Establish NSA Call
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Handover #
#CR_NOT_TESTED#Perform Handover By Using meas_id 1 and event A3
#    [Arguments]             ${current_elem}
#    ...                     ${csi_override_cqi}=3
#    #
#    Dated Log New Line                ${cc_cyan}----Perform Handover By Using meas_id 1 and event A3----${cc_normal}
#    ${backup_serving_cell_id}=        Set Variable    ${current_elem.target_cells}
#    ${current_param}=                 Set Variable    physCellId
#    ${dn_target_nrcell_for_ho}=       Set Variable    ${dn_nrbts}/NRCELL-${current_elem.target_handover}
#    # NRCELL.physCellId / get / target
#    ${nb_match}    ${result}          Get Values From Object    dist_name=${dn_target_nrcell_for_ho}    p_name=${current_param}
#    ...                                                             current_scf=${updated_scf}
#    Should Be True                    ${nb_match} > 0
#    ${physical_target_cell_id_for_ho}=    Set Variable    ${result[0]}
#    Dated Log                         >> match for ${dn_target_nrcell_for_ho}: ${current_param}= ${physical_target_cell_id_for_ho}
#    ${output_crnti}=                  Testmode UE Measurement Send NR    ue_id=${current_elem.ue}
#    ...                                                             physical_target_cell_id=${physical_target_cell_id_for_ho}
#    IF    "${csi_override_cqi}" != "${None}"
#        Testmode Csi Override    profile_id=${current_elem.ue}  nrcell=${current_elem.target_cells}  ue_id=${current_elem.ue}  action=deactivate
#        Testmode Csi Override    profile_id=${current_elem.ue}  nrcell=${current_elem.target_handover}  ue_id=${current_elem.ue}  action=activate
#    END
#    Set To Dictionary    ${current_elem}    target_cells    ${current_elem.target_handover}
#    Set To Dictionary    ${current_elem}    target_handover    ${backup_serving_cell_id}
#    Set To Dictionary    ${current_elem}    c_rnti    ${output_crnti}


#CR_NOT_TESTED#Perform Handovers By Using meas_id 1 and event A3
#    [Arguments]             ${list_ue}
#    ...                     ${param}
#    #
#    FOR    ${current_elem}    IN    @{list_ue}
#        Run Keyword If                "${param.ue_measurement_nr}" == "${True}" and ${current_elem.ue_measurement_nr} == ${True}
#        ...                           Perform Handover By Using meas_id 1 and event A3    ${current_elem}
#    END


#CR_NOT_TESTED#Perform N Handovers By Using meas_id 1 and event A3
#    [Arguments]             ${list_elem}
#    ...                     ${param}
#    ...                     ${n_handover}=50
#    #
#    Dated Log New Line                ${cc_cyan}----Perform ${n_handover} Handovers By Using meas_id 1 and event A3----${cc_normal}
#    FOR    ${iteration}    IN RANGE    1    ${n_handover} + 1
#        Dated Log                     > Loop ${iteration} / ${n_handover}
#        Perform Handovers By Using meas_id 1 and event A3    list_ue=${list_elem}    param=${param}
#        Sleep                         1s
#    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
