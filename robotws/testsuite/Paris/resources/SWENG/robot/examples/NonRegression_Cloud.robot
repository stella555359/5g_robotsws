*** Settings ***
#
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE] Test Suite for non regression on cloud TLs
# --------------------------------------------------------------------------------------------------------------------------------------------------

# Libraries
Library                               OperatingSystem
Library                               ../../python/Archi.py
Library                               taf.wts.runner                WITH NAME    wtsemu

# Resources
Resource                             ../../../../RRM/ET/resources/common/TtiTrace/ttitrace.robot
Resource                             ../Container.robot
Resource                             ../GenericTest.robot
Resource                             ../GnbXmlTools.robot
Resource                             ../KPIs.robot
Resource                             ../PacketSearch.robot
Resource                             ../Restart.robot
Resource                             ../RdCounters.robot
Resource                             ../Scf.robot
Resource                             ../Syslogs.robot
Resource                             ../Tools.robot
Resource                             ../Topology.robot
Resource                             ../Traffic.robot
Resource                             ../WtsCfgConfig.robot
Resource                             ../WtsXmlConfig.robot
# Following resources are defined to access wrappers for TTI Analysis and Convert interfaces
Resource                             ../TtiConvertInterface.robot
Resource                             ../TtiAnalysisInterface.robot

Variables                             ../../python/Colors.py
# Suites setup and teardown
Suite Setup                           Suite Setup SR-CR    keep_all_data_in_file=${True}
#NOT_REQUESTED#Suite Teardown         Suite Teardown
Test Teardown                         Test Teardown SR-CR   is_snapshot=${is_capture}[is_capture_snapshot]

*** Variables ***
# tests settings
&{TEST_SETTINGS_CR_1}
...                                   set_suite_dist_name_variables=Set Suite Dist Name Variables For CR
...                                   capture_duration=0            # capture duration during traffic starting phase
...                                   deviation=20                  # default deviation for throughput and double for uplink
...                                   dir=DL+UL                     # direction for supported traffic
...                                   duration=3                    # traffic duration during declaration phase
...                                   pm_waiting_period=1           # number of waiting periods added for observation
...                                   target_gnb=2                  # gnb target id
...                                   test_name=TC_TEST_SETTINGS_CR_1
...                                   total_nb_cell=6               # total number of cell used for ue's dispatching
...                                   total_nb_ue=0                 # total number of ue's to configure
...                                   nb_sa_ue=0                    # number of SA ue's to configure
...                                   csi_override_cqi=${None}      # cqi value to fix via csi_override testmode
...                                   ue_measurement_nr=${None}     # ue measurement nr support

# ue's settings # configuration SA
# TDD nrcells 1, 2
&{dict_SA_ue_1}  ue_id=1     call_type=SA   original_cell=1  throughput=0  throughput_ul=0   throughput_gbr=0   paging=${False}   csi_override_cqi=0
&{dict_SA_ue_2}  ue_id=21    call_type=SA   original_cell=2  throughput=0  throughput_ul=0   throughput_gbr=0   paging=${False}   csi_override_cqi=0
# FDD nrcells 3, 4, 5, 6
&{dict_SA_ue_3}  ue_id=31    call_type=SA   original_cell=3  throughput=0  throughput_ul=0   throughput_gbr=0   paging=${False}   csi_override_cqi=0
&{dict_SA_ue_4}  ue_id=41    call_type=SA   original_cell=4  throughput=0  throughput_ul=0   throughput_gbr=0   paging=${False}   csi_override_cqi=0
&{dict_SA_ue_5}  ue_id=51    call_type=SA   original_cell=5  throughput=0  throughput_ul=0   throughput_gbr=0   paging=${False}   csi_override_cqi=0
&{dict_SA_ue_6}  ue_id=61    call_type=SA   original_cell=6  throughput=0  throughput_ul=0   throughput_gbr=0   paging=${False}   csi_override_cqi=0
# ue's settings # configuration NSA
# TDD nrcells 1, 2
&{dict_NSA_ue_1}  ue_id=101  call_type=NSA  original_cell=1  throughput=0  throughput_ul=0   throughput_gbr=0   paging=${False}   csi_override_cqi=0
&{dict_NSA_ue_2}  ue_id=121  call_type=NSA  original_cell=2  throughput=0  throughput_ul=0   throughput_gbr=0   paging=${False}   csi_override_cqi=0
# FDD nrcells 3, 4, 5, 6
&{dict_NSA_ue_3}  ue_id=231  call_type=NSA  original_cell=3  throughput=0  throughput_ul=0   throughput_gbr=0   paging=${False}   csi_override_cqi=0
&{dict_NSA_ue_4}  ue_id=241  call_type=NSA  original_cell=4  throughput=0  throughput_ul=0   throughput_gbr=0   paging=${False}   csi_override_cqi=0
&{dict_NSA_ue_5}  ue_id=251  call_type=NSA  original_cell=5  throughput=0  throughput_ul=0   throughput_gbr=0   paging=${False}   csi_override_cqi=0
&{dict_NSA_ue_6}  ue_id=261  call_type=NSA  original_cell=6  throughput=0  throughput_ul=0   throughput_gbr=0   paging=${False}   csi_override_cqi=0

${TestSharkTool}                      MC_SHARK
${AUTO_SAVE_DEBUG_DATA}               ${True}
${CALL_ENABLED}                       ${True}
#USELESS#${SUITE_DEBUG_MODE}          ${True}
@{protocol_exclusion}                 ARP    UDP   ICMP
${path_to_json}                       /tmp/TTI_traces.json    # internal usage for decoding TTI pcap
# Remote Interference Noise Power configuration
${RI_N_PW_1}      -75,-77,-75,-77,-75,-77,-75,-77,-75,-83,-85,-83,-85,-83,-85,-83,-85,-83,-75,-77,-75,-77,-75,-77,-75,-77,-75,-77,-75,-115,-115,-115
${RI_N_PW_2}                          -55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115

# --------------------------------------------------------------------------------------------------------------------------------------------------
*** Test Cases ***
[1] CR_001_SA_call_w_traffic_ul_dl_ngbr
    #
    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${TEST_SETTINGS_CR_1}
    ${param.test_name}=               Set Variable    TC_CR_001_SA
    Set To Dictionary                 ${param}    counter_constraint    CR_001_SA
    Step                              ${param.set_suite_dist_name_variables}
    &{is_capture}=                    Create Dictionary    is_capture_core=${False}
    ...                                                    is_capture_cprt=${False}
    ...                                                    is_capture_l1l2=${True}
    ...                                                    is_capture_tti=${True}
    ...                                                    is_capture_syslog=${False}
    ...                                                    is_capture_snapshot=${True}
    Set To Dictionary                 ${dict_SA_ue_1}    throughput       30
    Set To Dictionary                 ${dict_SA_ue_1}    throughput_ul    15
    #DEBUG#Set To Dictionary          ${dict_SA_ue_1}    throughput_gbr   1
    Set To Dictionary                 ${dict_SA_ue_2}    throughput       30
    Set To Dictionary                 ${dict_SA_ue_2}    throughput_ul    15
    #DEBUG#Set To Dictionary          ${dict_SA_ue_2}    throughput_gbr   1
    Set To Dictionary                 ${dict_SA_ue_3}    throughput       10
    Set To Dictionary                 ${dict_SA_ue_3}    throughput_ul    3
    #DEBUG#Set To Dictionary          ${dict_SA_ue_3}    throughput_gbr   1
    Set To Dictionary                 ${dict_SA_ue_4}    throughput       10
    Set To Dictionary                 ${dict_SA_ue_4}    throughput_ul    3
    #DEBUG#Set To Dictionary          ${dict_SA_ue_4}    throughput_gbr   1
    Set To Dictionary                 ${dict_SA_ue_5}    throughput       10
    Set To Dictionary                 ${dict_SA_ue_5}    throughput_ul    3
    #DEBUG#Set To Dictionary          ${dict_SA_ue_5}    throughput_gbr   1
    Set To Dictionary                 ${dict_SA_ue_6}    throughput       10
    Set To Dictionary                 ${dict_SA_ue_6}    throughput_ul    3
    #DEBUG#Set To Dictionary          ${dict_SA_ue_6}    throughput_gbr   1
    ${current_ues_settings}=          Create List
    ...                               ${dict_SA_ue_1}    ${dict_SA_ue_2}    ${dict_SA_ue_3}    ${dict_SA_ue_4}    ${dict_SA_ue_5}    ${dict_SA_ue_6}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
    Dated Log New Line                > Test name is ${param.test_name}
    #
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    @{list_position_nrcell_tdd}=      Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    @{list_position_nrcell_fdd}=      Create List    1    2    3    4    # 1= first nrcell, 2nd, 3rd, etc.
    # ${scf_file}    ${scf_vcu_file}    Start Session Full Commissioning SR-CR    test_name=${param.test_name}
    # #
    # &{dico_nrbts}=                    Create Dictionary    actNrRimRsResourcePooling=false
    # Step                              SCF Configure NRBTS    ${dico_nrbts}
    # #
    # &{dico_nrcell_tdd}=               Create Dictionary    cellDepType=SA+NSA
    # ...                                                    actNrRim=disabled
    # ...                                                    actVoNR=true
    # ...                                                    nrcell_tdd=${list_position_nrcell_tdd}
    # Step                              SCF Configure NRCELL    ${dico_nrcell_tdd}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    # #
    # &{dico_nrcell_fdd}=               Create Dictionary    cellDepType=SA+NSA
    # ...                                                    actNrRim=disabled
    # ...                                                    actVoNR=true
    # ...                                                    nrcell_fdd=${list_position_nrcell_fdd}
    # Step                              SCF Configure NRCELL    ${dico_nrcell_fdd}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
    # #
    # # Update NRPMRNL configuration
    # &{dico_NRPMRNL}=                  Create Dictionary    miNrCellUtilization=5min    miNrRim=5min
    # Step                              SCF Configure NRPMRNL    ${dico_NRPMRNL}
    # #
    # ${result}    ${pdlValidation}     Stop Session Full Commissioning SR-CR    updated_scf=${scf_file}
    # ...                               updated_scf_vcu=${scf_vcu_file}    skip_errors=${False}
    # Dated Log New Line                ------------------------------------------------------------------------------
    # Call And Then Traffic SR-CR       ${param}    ${current_ues_settings}    ${is_capture}
    #
    #[Teardown]    # Reserved to internal testing usage
# -----------------------------------------------------------------------------------------------------------------------------------

*** Keywords ***
# Suite #
Suite Setup SR-CR
    [Arguments]             ${keep_all_data_in_file}=${False}
    #
    Dated Log New Line                ----Suite Setup Common Private----
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
    #
    Dated Log New Line                ----Test Teardown Common Private----
    GenericTest.Display diagnosis
    #FAILED#Dated Log New Line        ----Produce Scout Data----
    #FAILED#Produce Scout Data
    Dated Log New Line                ----Restore And Clean environment----
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
    Run Keyword If    ${isAic}        Oam.OAM Perform Full Commissioning    scf_file=${scf_vcu_suite_teardown_restore}    oam=${GNB_CU.oam}
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
    END
    # Cleaning-up debugging files
    Run                               command=rm -f ${scf_suite_setup_backup}
    Run Keyword If    ${isAic}        Run    command=rm -f ${scf_vcu_suite_setup_backup}
    Dated Log                         > Remove the SCF BACKUP files
    Run                               command=rm -f ${LOG_PATH}/L1L2/*.pdml
    Dated Log                         > Remove the generated pdml files
    Run                               command=rm -f ${LOG_PATH}/L1L2/*.__*.pcap
    Dated Log                         > Remove the intermediate pcap files
    #TEST#Run                         command=rm -f ${LOG_PATH}/TTITraces/*.json
    #TEST#Dated Log                   > Remove the TTI json files
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
    ${cc_green}                       Evaluate    "${GREEN}"
    ${cc_white}                       Evaluate    "${WHITE}"
    ${cc_yellow}                      Evaluate    "${YELLOW}"
    ${cc_bg_black}                    Evaluate    "${BG_BLACK}"
    ${cc_bg_yellow}                   Evaluate    "${BG_YELLOW}"
    ${cc_normal}                      Evaluate    "${NORMAL}"
    #
    Set Suite Variable                ${cc_green}
    Set Suite Variable                ${cc_white}
    Set Suite Variable                ${cc_yellow}
    Set Suite Variable                ${cc_bg_black}
    Set Suite Variable                ${cc_bg_black}
    Set Suite Variable                ${cc_normal}
# --------------------------------------------------------------------------------------------------------------------------------------------------
Convert Dictionary to Parameter String
    [Arguments]             ${kwargs}
    #
    ${command_args}                   Set Variable   ${EMPTY}
    FOR    ${key}    IN    @{kwargs}
        ${value}=                     Collections.Get From Dictionary    ${kwargs}    ${key}
        ${cleaned_key}=               Replace String Using Regexp    string=${key}    pattern=__\\d+    replace_with=${EMPTY}
        #DEBUG_LOG#Dated Log          >> ${cleaned_key}= ${value}
        ${command_args}=              Set Variable    ${command_args} ${cleaned_key}=${value}
    END
    #DEBUG_LOG#Dated Log              >> ${command_args}
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
    ...                     ${rad_0x1003F_val}=${None}
    ...                     ${rad_0x10040_val}=${None}
    ...                     ${rad_0x10041_val}=${None}
    ...                     ${rad_0x9D0001_val}=${None}
    ...                     ${rad_0x9D0002_val}=${None}
    ...                     ${rad_0x9D0006_val}=${None}
    ...                     ${rad_0x800059_val}=${None}
    ...                     ${rad_0x580580_val}=${None}
    #
    @{list_rad_param}=                Create List
    #
    #0x5801CB#L2PS#rdFakeUeSchedulingEnable#disabled#
    &{rad_0x5801CB}=            Run Keyword If    ${rad_0x5801CB_val} != ${None}    Create Dictionary    field=0x5801cb    value=${rad_0x5801CB_val}
    Run Keyword If                    ${rad_0x5801CB_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x5801CB}
    #
    #0x58046F#L2PS#rdStaticPdcchPowerOffset#disabled#
    &{rad_0x58046F}=            Run Keyword If    ${rad_0x58046F_val} != ${None}    Create Dictionary    field=0x58046f    value=${rad_0x58046F_val}
    Run Keyword If                    ${rad_0x58046F_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x58046F}
    #
    #0x580689#L2PS#rdRimRsPeriodicity#bits 0-15 for period and 16-31 for offset
    &{rad_0x580689}=            Run Keyword If    ${rad_0x580689_val} != ${None}    Create Dictionary    field=0x580689    value=${rad_0x580689_val}
    Run Keyword If                    ${rad_0x580689_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x580689}
    #
    #0x58057A#L2PS#rdFeatureFlagBitmapLevel#Enable feature flag logs via radparameter#VIP, 1 - ERROR, 2 - WARNING, 3 - INFO, 4 - DEBUG, 5 - INVALID#
    &{rad_0x58057A}=            Run Keyword If    ${rad_0x58057A_val} != ${None}    Create Dictionary    field=0x58057a    value=${rad_0x58057A_val}
    Run Keyword If                    ${rad_0x58057A_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x58057A}
    #
    #0x58057C#L2PS#rdFeatureFlagBitmap1#Bitmap 1 of enabled feature flag logs. Requires relevant rdFeatureFlagBitmapLevel setup#
    &{rad_0x58057C}=            Run Keyword If    ${rad_0x58057C_val} != ${None}    Create Dictionary    field=0x58057c    value=${rad_0x58057C_val}
    Run Keyword If                    ${rad_0x58057C_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x58057C}
    #
    #0x58057F#L2PS#rdFeatureFlagBitmap4#Bitmap 4 of enabled feature flag logs. Requires relevant rdFeatureFlagBitmapLevel setup#bit 0- RIM.Common#
    #0x58057F#L2PS#rdFeatureFlagBitmap4#bit 1- RIM.RI#
    #0x58057F#L2PS#rdFeatureFlagBitmap4#bit 6- RIM.RS_UL#
    #0x58057F#L2PS#rdFeatureFlagBitmap4#bit 18- RIM.RS_DETECTION#
    &{rad_0x58057F}=            Run Keyword If    ${rad_0x58057F_val} != ${None}    Create Dictionary    field=0x58057f    value=${rad_0x58057F_val}
    Run Keyword If                    ${rad_0x58057F_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x58057F}
    #
    #0x580580#L2PS#rdFeatureFlagBitmapX#Bitmap x of enabled feature flag logs#
    #0x580580#L2PS#rdFeatureFlagBitmapX#bit X- RIM.UL_PRB_POOLING#
    &{rad_0x580580}=            Run Keyword If    ${rad_0x580580_val} != ${None}    Create Dictionary    field=0x580580    value=${rad_0x580580_val}
    Run Keyword If                    ${rad_0x580580_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x580580}
    #
    #
    #UEC flags
    #0x1003f=1#ERadCcs_AaSysLogInputLevel=debug#
    &{rad_0x1003F}=                Run Keyword If    ${rad_0x1003F_val} != ${None}    Create Dictionary    field=0x1003f    value=${rad_0x1003F_val}
    Run Keyword If                    ${rad_0x1003F_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x1003F}
    #
    #0x10040=1#ERadCcs_AaSysLogOutputLevel=debug#
    &{rad_0x10040}=                Run Keyword If    ${rad_0x10040_val} != ${None}    Create Dictionary    field=0x10040    value=${rad_0x10040_val}
    Run Keyword If                    ${rad_0x10040_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x10040}
    #
    #0x10041=5#ERadCcs_AaSysLogOutputMode#
    &{rad_0x10041}=                Run Keyword If    ${rad_0x10041_val} != ${None}    Create Dictionary    field=0x10041    value=${rad_0x10041_val}
    Run Keyword If                    ${rad_0x10041_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x10041}
    #
    #
    #PMSTAT flags
    #0x9D0001=1#enable PMStat core flag#
    &{rad_0x9D0001}=            Run Keyword If    ${rad_0x9D0001_val} != ${None}    Create Dictionary    field=0x9d0001    value=${rad_0x9D0001_val}
    Run Keyword If                    ${rad_0x9D0001_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x9D0001}
    #
    #0x9D0002=1#enable PMStat PM flag#
    &{rad_0x9D0002}=            Run Keyword If    ${rad_0x9D0002_val} != ${None}    Create Dictionary    field=0x9d0002    value=${rad_0x9D0002_val}
    Run Keyword If                    ${rad_0x9D0002_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x9D0002}
    #
    #0x9D0006=55308#Debug flag for M55308#
    &{rad_0x9D0006}=            Run Keyword If    ${rad_0x9D0006_val} != ${None}    Create Dictionary    field=0x9d0006    value=${rad_0x9D0006_val}
    Run Keyword If                    ${rad_0x9D0006_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x9D0006}
    #
    #
    #0x800059#L1#rdUlPhyNrRimRsDetectionThreshold#Remote interference RS detection threshold for NR#
    &{rad_0x800059}=            Run Keyword If    ${rad_0x800059_val} != ${None}    Create Dictionary    field=0x800059    value=${rad_0x800059_val}
    Run Keyword If                    ${rad_0x800059_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x800059}

    ${length_list_rad_param}=         Get Length    ${list_rad_param}
    Dated Log                         > RAD params list is ${list_rad_param} with length= ${length_list_rad_param}
    Run Keyword If                    ${length_list_rad_param} > 0    SetConfig.Set Fields in swconfig DU    param_list=${list_rad_param}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# BSR #
#CR NOT TESTED#
CB011127 Download BSR file
    [Arguments]             ${param}
    ...                     ${bsr_git_path}=gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
    #
    Dated Log New Line                ----CB011127 Download BSR file ${param.bsr_target}----
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
    Dated Log New Line                ----Configure Parameter In WTS basic_setup File----
    WtsCfgConfig.startSession
    ${default_value}=                 getParam    prefix=${identifier}    param=${param}
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
    Dated Log New Line                ----Configure Parameter In AP iphy File----
    WtsXmlConfig.startSession         file=iphy
    WtsXmlConfig.setTextUsingIndex    path=//${param}    val=${value}    idx=${identifier}
    Dated Log                         > new value updated for ${param} idx= ${identifier} is ${value}
    WtsXmlConfig.stopSession          file=iphy
# --------------------------------------------------------------------------------------------------------------------------------------------------
# UE
Display List UEs Settings
    [Arguments]             ${list_elem}
    #
    Dated Log New Line                ----Display List UEs Settings----
    FOR    ${current_elem}    IN    @{list_elem}
        Dated Log        ue= ${current_elem}[ue], call= ${current_elem}[call_type], rnti=${current_elem}[c_rnti], cell=${current_elem}[target_cells]
    END


Get List UEs Settings
    [Arguments]             ${param}
    ...                     ${dict_settings}
    #
    Dated Log New Line                ----Get List UEs Settings----
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
    #DEBUG_LOG#Dated Log              >> UE's list is ${list_ue}
    #DEBUG_LOG#Dated Log              >> Cells list for TTI streaming is ${cell_id_streaming}
    [Return]                          ${list_ue}    ${cell_id_streaming}


Set CRNTI Into UEs Settings
    [Arguments]             ${list_ue}
    ...                     ${list_crnti}
    #
    Dated Log New Line                ----Set CRNTI Into UEs Settings----
    ${nb_crnti}=                      Get Length    ${list_crnti}
    FOR    ${iteration_crnti}    IN RANGE    0    ${nb_crnti}
        Set To Dictionary             ${list_ue[${iteration_crnti}]}    c_rnti    ${list_crnti[${iteration_crnti}]}
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Captures #
Captures Init
    #
    Dated Log New Line                ----Captures Init----
    ${capture_l1l2}=                  Capture L1L2 Set Upon Config    airscale=${GNB_DU}
    ${capture_l1l2.filter}=           Get Filter To Exclude protocols    capture=${capture_l1l2}    protocolList=${protocol_exclusion}
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
    ${output_log}=                    Set Variable    ${LOG_PATH}/${output_log_path}/${output_prefix}_${output_suffix}.pcap
    Run Keyword And Ignore Error      Capture Stop    capture=${capture_config}
    Dated Log                         > input= ${capture_config.path}
    Dated Log                         > output= ${output_log}
    Run                               command=mkdir -p ${LOG_PATH}/${output_log_path}
    Run                               command=mv ${capture_config.path} ${output_log}


# L1L2 #
#CR NOT TESTED#
# L1L2 pcap and pdml data analysis functions #
CB011127 Create Filter Message List
    #
    Dated Log New Line                ----CB011127 Create Filter Message List----
    #&{dict_filter_1}=          Create Dictionary    filter_name=__dldata_csirssendreq    request_pdml=${False}   message_filter=dldata_csirssendreq
    &{dict_filter_2}=       Create Dictionary    filter_name=__dldata_pdcchsendreq    request_pdml=${True}    message_filter=dldata_pdcchsendreql1sw
    #&{dict_filter_3}=          Create Dictionary    filter_name=__dldata_pdschsendreq    request_pdml=${False}   message_filter=dldata_pdschsendreq
    #&{dict_filter_4}=       Create Dictionary    filter_name=__uldata_prachrecvreq    request_pdml=${False}   message_filter=uldata_prachreceivereq
    #&{dict_filter_5}=       Create Dictionary    filter_name=__uldata_pucchrecvreq    request_pdml=${False}   message_filter=uldata_pucchreceivereq
    #&{dict_filter_6}=       Create Dictionary    filter_name=__uldata_puschrecvreq    request_pdml=${False}   message_filter=uldata_puschreceivereq
    #&{dict_filter_7}=         Create Dictionary    filter_name=__uldata_srsrecvreq      request_pdml=${False}   message_filter=uldata_srsreceivereq
    #&{dict_filter_8}=                Create Dictionary    filter_name=__uldata_puXchrecvreq    request_pdml=${False}
    #...                              message_filter=uldata_pucchreceivereq or uldata_puschreceivereq
    #&{dict_filter_9}=                Create Dictionary    filter_name=__ul_dl_rach_msg         request_pdml=${False}
    #...               message_filter=DlData_PdschGrant.rachStatus>=1 or DlData_DciInfo.rachStatus>=1 or UlData_puschReceiveReqGrant_t.rachStatus>=1
    #&{dict_no_filter}=               Create Dictionary    filter_name=_no_filter               request_pdml=${False}   message_filter=${EMPTY}
    # list of messages for filtering
    @{list_filters_messages}=         Create List    ${dict_filter_2}
    [Return]                          ${list_filters_messages}


#CR NOT TESTED#
CB011127 Create Filter Message List Per CRNTI
    [Arguments]             ${list_elem}    # List of dictionaries
    #
    Dated Log New Line                ----CB011127 Create Filter Message List Per CRNTI----
    @{list_filters_messages}=         Create List
    FOR    ${current_elem}    IN    @{list_elem}
        &{dict_filter}=               Create Dictionary    c_rnti=${current_elem.c_rnti}
        ...                           message_filter=3gpp.rnti==${current_elem.c_rnti}
        ...                           filter_name=_ue_${current_elem.ue}_crnti_${current_elem.c_rnti}    request_pdml=${False}
        Append To List                ${list_filters_messages}    ${dict_filter}
    END
    [Return]                          ${list_filters_messages}


#CR NOT TESTED#
CB011127 Analyze pcap and pdml
    [Arguments]             ${pcap_file}
    ...                     ${list_message}    # List of dictionaries
    #
    #DEBUG_LOG#Dated Log              ----CB011127 Analyze pcap and pdml of ${pcap_file}----
    FOR    ${current_elem}    IN    @{list_message}
        ${pcap_file_filtered}=        Run Keyword If    "${pcap_file}" != "${None}"
        ...                           analyzer.filter_pcap    pcapInFile=${pcap_file}
        ...                           filterName=${current_elem}[filter_name]    filterExp=${current_elem}[message_filter]
        ...       ELSE                Set Variable    ${None}
        Set To Dictionary             ${current_elem}    pcap_file_filtered    ${pcap_file_filtered}
        ${pdml_file_result}=          Run Keyword If    "${pcap_file_filtered}" != "${None}" and ${current_elem}[request_pdml] == ${True}
        ...                           analyzer.pcap_to_pdml    ${pcap_file_filtered}
        ...       ELSE                Set Variable    ${None}
        Set To Dictionary             ${current_elem}    pdml_file_result    ${pdml_file_result}
    END
    Run Keyword If                    "${pcap_file}" != "${None}"
    ...    Dated Log                  > list of messages AFTER filtering: ${list_message}


#CR NOT TESTED#
Post Processing L1L2 Traces
    [Arguments]             ${output_suffix}
    ...                     ${list_crnti_filters}
    ...                     ${list_messages_filters}
    ...                     ${output_prefix}=L1L2
    ...                     ${output_log_path}=L1L2
    #
    Dated Log New Line                ----Post Processing L1L2 Traces----
    ${pcap_file}=                     Set Variable    ${LOG_PATH}/${output_log_path}/${output_prefix}_${output_suffix}.pcap
    Dated Log                         >> list_crnti_filters= ${list_crnti_filters}
    FOR    ${current_elem}    IN    @{list_crnti_filters}
        ${pcap_file_filtered}=        Run Keyword If    "${current_elem}[c_rnti]" != "${None}"
        ...                           analyzer.filter_pcap    pcapInFile=${pcap_file}
        ...                           filterName=${current_elem}[filter_name]    filterExp=${current_elem}[message_filter]
        ...       ELSE                Set Variable    ${None}
        Set To Dictionary             ${current_elem}    pcap_crnti_filtered    ${pcap_file_filtered}
        Run Keyword If                "${current_elem}[pcap_crnti_filtered]" != "${None}"    Run Keywords
        ...    Dated Log              > filtering with ${current_elem}[message_filter]
        ...    AND                    CB011127 Analyze pcap and pdml    pcap_file=${current_elem}[pcap_crnti_filtered]
        ...                           list_message=${list_messages_filters}
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
# TTI #
Start TTI Logs SR-CR
    [Arguments]             ${cell_id_list}
    #
    Dated Log New Line                ----Start TTI Logs----
    ${TTIdir}=                        Get TTI Trace Path
    # or Start To Collect TTI Trace On AIC ?
    Run Keyword If                    ${isAic}    ttitrace.Start TTI Traces in Streaming mode   src_ip=10.0.1.2   nrcell_id_list_aic=${cell_id_list}
    ...           ELSE                ttitrace.Start TTI Traces in Streaming mode    src_ip=10.0.1.2    cell_distid=${cell_id_list}
    Set Suite Variable                ${TTIdir}


Stop and Get TTI Logs SR-CR
    [Arguments]             ${list_events_to_filter}
    ...                     ${trace_name}=TTI
    #
    Dated Log New Line                ----Stop TTI Logs----
    ${TTIpcap}=                       ttitrace.Stop TTI Traces in Streaming mode    tti_trace_path=${TTIdir}    tti_trace_filename=${trace_name}
    Dated Log                         ----Decode TTI Logs----
    ${json_tti_output}=               Set Variable    ${LOG_PATH}/TTITraces/${trace_name}_filtered.json
    #${tti_decoder_path}=             Set Variable    /opt/tti-dec/tti-dec-bin/
    #@{list_events_to_filter}=        Create List    utcTimestampData    ulAllocatedPooledResourcesData    #dlAllocatedPooledResourcesData
    #...                              ulRimRsPooledResourcesData    reasonsOfDroppedRsDetection
    TtiConvertInterface.Convert TTI capture    pcap_file_path=${TTIpcap}    events_list=${list_events_to_filter}
    ${status}   ${ret}                Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${json_tti_output}
    Run Keyword If                    "${status}" != "PASS"    Run Keywords
    ...           Dated Log           > TTI decoding is failed because ${json_tti_output} is not found
    ...    AND                        Should Be True    "${status}" == "PASS"
    Dated Log                         > TTI decoding is passed in ${json_tti_output}
    # ${path_to_json} is mandatory for decoding then create a symbolic link to ${json_tti_output}
    Run                               command=ln -fs ${json_tti_output} ${path_to_json}


#CR NOT TESTED#
Create Dictionary With Common Parameters To Filter
    [Arguments]             ${list_nrcell}
    ...                     ${pos_nrcell}
    ...                     ${list_dico_rnti}
    #
    Dated Log New Line                ----Create Dictionary With Common Parameters To Filter----
    @{list_lcr_id}=                   Create List
    @{list_phys_cell_id}=             Create List
    @{list_rnti}=                     Create List
    FOR    ${position}    IN    @{pos_nrcell}
        ${internal_pos}=              Evaluate    ${position}-1
        ${current_nrcell_id}=         Set Variable    ${list_nrcell[${internal_pos}].nrCellId}
        ${current_dn_nrcell}=         Set Variable    ${dn_nrbts}/NRCELL-${current_nrcell_id}
        # NRCELL.lcriId / get
        ${current_param}=             Set Variable    lcrId
        ${nb_match}    ${current_lcr_id}    Get Values From Object    dist_name=${current_dn_nrcell}    p_name=${current_param}
        ...                           current_scf=${updated_scf}
        Should Be True                ${nb_match} > 0
        #DEBUG_LOG#Dated Log          >> match for ${current_dn_nrcell}: ${current_param}= ${current_lcr_id}
        ${convert_lcr_id}=            Convert To Integer    ${current_lcr_id}[0]
        Append To List                ${list_lcr_id}    ${convert_lcr_id}
        ${convert_phys_cell_id}=      Convert To Integer    ${list_nrcell[${internal_pos}].physCellId}
        Append To List                ${list_phys_cell_id}    ${convert_phys_cell_id}
    END
    FOR    ${current_elem}    IN    @{list_dico_rnti}
        ${convert_rnti}=              Convert To Integer    ${current_elem}[c_rnti]
        Append To List                ${list_rnti}    ${convert_rnti}
    END
    #DEBUG_LOG#Dated Log              >> lcrId= ${list_lcr_id}
    #DEBUG_LOG#Dated Log              >> physCellId= ${list_phys_cell_id}
    #DEBUG_LOG#Dated Log              >> rnti= ${list_rnti}
    &{dico_param}=                    Create Dictionary
    Set To Dictionary                 ${dico_param}    lcrId         ${list_lcr_id}
    Set To Dictionary                 ${dico_param}    physCellId    ${list_phys_cell_id}
    Set To Dictionary                 ${dico_param}    rnti          ${list_rnti}
    #DEBUG_LOG#Dated Log              >> ${dico_param}
    [Return]                          ${dico_param}


#CR NOT TESTED#
Export TTI For CB011127
    [Arguments]             ${trace_name}=TTI
    #
    ${csv_tti_output}=                Set Variable    ${LOG_PATH}/TTITraces/${trace_name}.csv
    Dated Log                         ----Export TTI For CB011127----
    # export a list of parameters in csv by using filters
    @{list_param_to_export}=          Create List    timeStamp    sfn    slot    rnti    lcrId    physCellId
    # ulAllocatedPooledResourcesData
    ...                               ulAllocatedPooledResourcesData.allocStreamPrbCgUl
    ...                               ulAllocatedPooledResourcesData.allocStreamPrbGbrUl
    ...                               ulAllocatedPooledResourcesData.allocStreamPrbNonGbrUl
    ...                               ulAllocatedPooledResourcesData.numAllocCellPrbUl
    # ulRimRsPooledResourcesData
    ...                               ulRimRsPooledResourcesData.nrCellIdentity
    ...                               ulRimRsPooledResourcesData.requestedMinRimRsResources
    ...                               ulRimRsPooledResourcesData.requestedMaxRimRsResources
    ...                               ulRimRsPooledResourcesData.allocatedRimRsResources
    ...                               ulRimRsPooledResourcesData.newRimRsPeriod
    # reasonsOfDroppedRsDetection
    ...                               reasonsOfDroppedRsDetection.newDetectionDroppedByLackOfPRB
    ...                               reasonsOfDroppedRsDetection.newDetectionDroppedByLackOfL1Resources
    ...                               reasonsOfDroppedRsDetection.newDetectionDroppedByOverlapWithPucchOrPrach
    ...                               reasonsOfDroppedRsDetection.revalidationDroppedByLackOfPRB
    ...                               reasonsOfDroppedRsDetection.revalidationDroppedByLackOfL1Resources
    # dictionary of common parameters to filter, optional and can be set to none
    @{list_phys_cell_id}=             Create List
    FOR    ${current_id}    IN RANGE    50    56
        Append To List                ${list_phys_cell_id}    ${current_id}
    END
    &{dico_common_param_to_filter}=   Create Dictionary    physCellId=${list_phys_cell_id}
    # dictionary of specific parameters to filter, optional and can be set to none
    #&{dico_specif_param_to_filter}=   Create Dictionary    ulRimRsPooledResourcesData.requestedMinRimRsResources=0
    Dated Log                         > TTI export in csv is started
    Dated Log                         > from json input ${path_to_json}
    Dated Log New Line                > for only parameters ${list_param_to_export}
    Dated Log New Line                > after applying filters ${dico_common_param_to_filter}
    TtiAnalysisInterface.Export Specific Parameters To CSV and Dataframe    path_to_csv=${csv_tti_output}
    ...                               parameters=${list_param_to_export}
    ...                               common_parameters_filter=${dico_common_param_to_filter}
    ...                               specific_parameters_filter=${None}
    ...                               path_to_json=${path_to_json}    #${dico_specif_param_to_filter}
    ${status}   ${ret}                Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${csv_tti_output}
    Run Keyword If                    "${status}" != "PASS"    Run Keywords
    ...           Dated Log           > TTI export in csv is failed because ${csv_tti_output} is not found
    ...    AND                        Should Be True    "${status}" == "PASS"
    Dated Log                         > TTI export is passed in ${csv_tti_output}


Get List Cells Retained For TTI Streaming SR-CR
    [Arguments]             ${cell_id_streaming}
    ...                     ${oam_type}=${GNB_DU.oam}
    #
    Dated Log New Line                ----Get List Cells Retained For TTI Streaming----
    @{list_cell_id}=                  Create List
    @{cellsNr}=                       Oam.OAM Get Cells Nr    oam=${oam_type}
    #DEBUG_LOG#Dated Log              >> CellsNr=@{cellsNr}
    FOR    ${current_cell}    IN    @{cellsNr}
        #DEBUG_LOG#Dated Log          >> cell NR is ${current_cell}
        #DEBUG_LOG#IF    not ${isAic}
        #DEBUG_LOG#...        Dated Log          >> internal distname ${current_cell['id']['internal']}
        #DEBUG_LOG#ELSE
        #DEBUG_LOG#...        Dated Log          >> internal distname ${current_cell['dist_names']['config']}
        #DEBUG_LOG#END
        ${cell_status_}=              Run Keyword If    not ${isAic}    Set variable  ${current_cell['status']}
        ${operationalState}=          Run Keyword If    not ${isAic}    Set Variable   ${cell_status_['operationalState']}
        ...                           ELSE    Set Variable   ${current_cell['operational_state']}
        #DEBUG_LOG#IF    not ${isAic}
        #DEBUG_LOG#...        Dated Log          >> operationalState for DN [${current_cell['id']['internal']}] is ${operationalState}
        #DEBUG_LOG#ELSE
        #DEBUG_LOG#...        Dated Log          >> operationalState for DN [${current_cell['dist_names']}] is ${operationalState}
        #DEBUG_LOG#END
        ${globalCellId}=              Run Keyword If    not ${isAic}    Set Variable   ${current_cell['globalCellId']}
        ...                           ELSE    Set Variable   ${current_cell['id']}
        ${is_global_cell_id}=         Is Global Cell Id Retained For Streaming    global_cell_id=${globalCellId}    cell_list=${cell_id_streaming}
        Run Keyword If             ${is_global_cell_id} and not ${isAic}    Append to List    ${list_cell_id}    ${current_cell['id']['internal']}
        Run Keyword If             ${is_global_cell_id} and ${isAic}    Append to List    ${list_cell_id}    ${current_cell['dist_names']['config']}
    END
    #DEBUG_LOG#Dated Log              >> Distname list of cells retained for TTI streaming ${list_cell_id}
    [Return]                          ${list_cell_id}

Is Global Cell Id Retained For Streaming
    [Arguments]             ${global_cell_id}
    ...                     ${cell_list}
    #
    ${result_global_cell}=            Set Variable    ${False}
    FOR    ${current_cell}    IN    @{cell_list}
        #DEBUG_LOG#Dated Log          >> global cell id ${global_cell_id} vs. current cell ${current_cell}
        #DEBUG_LOG#Run Keyword If     ${result_global_cell} or ${global_cell_id}==${current_cell}
        #DEBUG_LOG#...    Dated Log   >> True    ELSE    Dated Log    >> False
        ${result_global_cell}=        Run Keyword If    ${result_global_cell} or ${global_cell_id}==${current_cell}    Set Variable    ${True}
        ...       ELSE                Set Variable    ${False}
    END
    #DEBUG_LOG#Dated Log              >> final result returned is ${result_global_cell}
    [Return]                          ${result_global_cell}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Counter And KPI #
Check Counter And KPI Constraints SR-CR
    [Arguments]             ${pm_path}
    ...                     ${test_name}
    ...                     ${localKpiFileName}=${None}
    #
    Dated Log New Line                ----Check Counter And KPI Constraints SR-CR----
    ${localKpiFile}=                  Run Keyword If    "${localKpiFileName}" == "${None}"    Set Variable   ${None}
    ...           ELSE                Set Variable   ${CURDIR}/../../config/counter/constraint/${localKpiFileName}
    KPIs.KPI Evaluate                 pmFile=${pm_path}
    ...                               constraintsFile=${CURDIR}/../../config/counter/constraint/${test_name}.csv
    ...                               failOnError=${True}
    ...                               localKpiFile=${localKpiFile}
    Dated Log                         > Check counter and KPI constraints is ended
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
#CR NOT TESTED#
Get Number Of Alarm
    [Arguments]             ${oam_type}=${GNB_DU.oam}
    #
    @{alarms}=                        OAM Get Active Alarms    oam=${oam_type}
    ${nb_of_alarm}=                   Get Length    ${alarms}
    [Return]                          ${nb_of_alarm}


#CR NOT TESTED#
Detection Alarm Id
    [Arguments]             ${alarm_id}=7101
    ...                     ${fault_id}=4383
    ...                     ${alarm_object}=${None}
    ...                     ${suppl_info}=${None}
    ...                     ${oam_type}=${GNB_DU.oam}
    ...                     ${confirm_presence}=${True}
    #
    #DEBUG_LOG#Dated Log New Line     ----Detection Alarm----
    @{alarms}=                        OAM Get Active Alarms    oam=${oam_type}
    ${flag_alarm_id}=                 Set Variable    ${False}
    ${i}=                             Set Variable    ${0}
    FOR    ${alarm}    IN    @{alarms}
        ${i}=                         Evaluate    ${i}+${1}
        ${result}=                    Replace String    ${alarm}    ]    [
        @{alarm_words}=               Split String    ${result}    separator=[
        Remove Values From List       ${alarm_words}    ${EMPTY}
        Remove Values From List       ${alarm_words}    ${SPACE}
        ${flag_alarm_id}=        Run Keyword If    ${alarm_words[0]} == ${alarm_id}     Set Variable    ${True}     ELSE    Set Variable    ${False}
        ${flag_fault_id}=             Run Keyword If    ${alarm_words[1]} == ${fault_id} or "${fault_id}" == "${None}"    Set Variable    ${True}
        ...       ELSE                Set Variable    ${False}
        #DEBUG_LOG#Dated Log          >> alarm_words_object= ${alarm_words}
        ${is_object_present}=         Run Keyword And Return Status    Should Contain    ${alarm_words[3]}    ${alarm_object}
        ${flag_alarm_object}=         Run Keyword If    ${is_object_present} or "${alarm_object}" == "${None}"    Set Variable    ${True}
        ...       ELSE                Set Variable    ${False}
        ${is_suppl_present}=          Run Keyword And Return Status    Should Contain    ${alarm_words[4]}    ${suppl_info}
        ${flag_alarm_suppl}=          Run Keyword If    ${is_suppl_present} or "${suppl_info}" == "${None}"    Set Variable    ${True}
        ...       ELSE                Set Variable    ${False}
        #DEBUG_LOG#Dated Log          >> alarm_words_4= ${alarm_words[4]} suppl_info= ${suppl_info} <=> is_suppl_present= ${is_suppl_present}
        Exit For Loop If              ${flag_alarm_id} and ${flag_fault_id} and ${flag_alarm_object} and ${flag_alarm_suppl}
    END
    ${iteration_alarm}=               Run Keyword If    ${flag_alarm_id} and ${flag_fault_id} and ${flag_alarm_object} and ${flag_alarm_suppl}
    ...                               Set Variable    ${alarm}
    ...           ELSE                Set Variable    ${None}
    ${fault_id_word}=                 Run Keyword If    ${flag_fault_id} and "${fault_id}" != "${None}"    Set Variable    ${alarm_words[1]}
    ...           ELSE                Set Variable    ${None}
    Run Keyword If                    ${flag_alarm_id} and ${flag_fault_id} and ${flag_alarm_object} and ${flag_alarm_suppl}    Run Keywords
    ...           Dated Log           ${cc_yellow}> Alarm [${alarm_id}] with fault [${fault_id}] is detected on object=${alarm_object} ${cc_normal}
    ...    AND    Dated Log           ${cc_yellow}> GNB_DU_OAM_ALARM[${i}]=${iteration_alarm} ${cc_normal}
    ...           ELSE    Dated Log   ${cc_green}> Alarm [${alarm_id}] with fault [${fault_id}] is NOT detected ${cc_normal}
    Run Keyword If    ${flag_alarm_id} and ${flag_fault_id} and ${flag_alarm_object} and ${flag_alarm_suppl} and ${confirm_presence}
    ...                               Should Be True    "${fault_id}" == "${fault_id_word}"
    [Return]                          ${iteration_alarm}


#CR NOT TESTED#
Is Alarm Present
    [Arguments]             ${alarm_id}
    ...                     ${fault_id}
    ...                     ${alarm_object}=${None}
    ...                     ${iteration}=5
    ...                     ${delay_iteration}=5s
    ...                     ${confirm_presence}=${True}
    #
    FOR    ${current_it}    IN RANGE    1    ${iteration} + 1
        Run Keyword If    "${alarm_object}" == "${None}"
        ...    Dated Log              ----Is Alarm [${alarm_id}][${fault_id}] Present (${current_it}/${iteration})----
        ...       ELSE
        ...    Dated Log              ----Is Alarm [${alarm_id}][${fault_id}] Present on object=${alarm_object} (${current_it}/${iteration})----
        ${alarm_information}=         Detection Alarm Id    alarm_id=${alarm_id}    fault_id=${fault_id}    alarm_object=${alarm_object}
        ...                           confirm_presence=${confirm_presence}
        #DEBUG_LOG#Dated Log          >> alarm_information= ${alarm_information}
        Exit For Loop If              "${alarm_information}" != "${None}"
        Sleep                         ${delay_iteration}
    END
    # Alarm must be found after ${iteration} attempts
    ${is_present}=                    Run Keyword If    "${alarm_information}" != "${None}"    Set Variable    ${True}
    ...           ELSE                Set Variable    ${False}
    Run Keyword If                    ${confirm_presence}    Should Be True    ${is_present} == ${True}
    [Return]                          ${is_present}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Verifications # CB008375-D #
#CR NOT TESTED#
Execute Command And Check Content
    [Arguments]             ${command}
    #
    #DEBUG_LOG#Dated Log              >> ${command}
    ${result}=                        OperatingSystem.Run    ${command}
    #DEBUG_LOG#Dated Log              >> ${result}
    @{result_splitted}=               Split String    ${result}    separator=${SPACE}
    Remove Values From List           ${result_splitted}    ${EMPTY}
    #DEBUG_LOG#Dated Log              >> result found is ${result_splitted}
    ${list_length}=                   Get Length    ${result_splitted}
    ${log_size}=    Run Keyword If    ${list_length} != 0    Convert To Integer    ${result_splitted[0]}    ELSE    Set Variable    0
    Should Be True                    ${log_size} > 0
    #DEBUG_LOG#Dated Log              >> check is successful because log size= ${log_size} is well > 0
    [Return]                          ${result_splitted}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Verifications # CB011127-A #
#CR NOT TESTED#
CB011127 Execute Command And Check Content
    [Arguments]             ${cmd}
    ...                     ${msg}
    ...                     ${expected_res}=${False}
    #
    Dated Log                         > ${msg}
    Dated Log                         >> ${cmd}
    ${res}=                           OperatingSystem.Run    ${cmd}
    ${len_res}=                       Get Length    ${res}
    Run Keyword If                    ${expected_res}
    ...                               Should Be True    ${len_res} > 0
    ...           ELSE                Should Be True    ${len_res} == 0
    Dated Log                         > check is passed and length result is ${len_res}
# --------------------------------------------------------------------------------------------------------------------------------------------------
#CR NOT TESTED#
# Testmode by using wtsemu.<function> #
Create Csi Override Nr Profile
    [Arguments]             ${profile_id}
    ...                     ${cqi_val}
    ...                     ${cqi_mode}=fixed
    ...                     ${ri_val}=${None}
    ...                     ${pmi_val}=${None}
    #
    Dated Log New Line                ----Create Csi Override Testmode Nr Profile----
    Run Keyword If                    "${cqi_mode}" != "${None}"    Run Keywords
    ...                               wtsemu.csi_override_testmode_nr    profile_id=${profile_id}    cqi=${cqi_val}    cqi_mode=fixed
    ...    AND                        wtsemu.read_wtsemu_output_until_prompt    timeout=10
    ...    AND    Dated Log           > csi_override_testmode_nr profile_id=${profile_id} cqi=${cqi_val} cqi_mode=fixed
    ...           ELSE                Run Keywords    wtsemu.csi_override_testmode_nr    profile_id=${profile_id}    cqi=${cqi_val}    ri=${ri_val}
    ...                               pmi=${pmi_val}
    ...    AND                        wtsemu.read_wtsemu_output_until_prompt    timeout=10
    ...    AND    Dated Log           > csi_override_testmode_nr profile_id=${profile_id} cqi=${cqi_val} ri=${ri_val} pmi=${pmi_val}


Testmode Csi Override
    [Arguments]             ${profile_id}
    ...                     ${nrcell}
    ...                     ${ue_id}
    ...                     ${action}
    #
    Dated Log New Line                ----Testmode Csi Override----
    wtsemu.ue_testmode_set_nr         id=${ue_id}    scell=${nrcell}    testmode=csi_override    profile_id=${profile_id}    action=${action}
    wtsemu.read_wtsemu_output_until_prompt    timeout=10
    Dated Log                         > ue_testmode_set_nr id=${ue_id} scell=${nrcell} testmode=csi_override prof_id=${profile_id} action=${action}


Testmode Paging Start
    [Arguments]             ${ue_id}
    ...                     ${default_drx}=128
    ...                     ${max_paging}=5
    ...                     ${cause_release}=NAS_normal_release
    #
    Dated Log New Line                ----Testmode Paging Start for UE${ue_id}----
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
    Dated Log New Line                ----Testmode UE Measurement Send NR----
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
    Dated Log New Line                ----Create And Execute Egate Script for testmode=${testmode}----
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
    Dated Log New Line                ----Create RI Testmode NR Profile----
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
    Dated Log New Line                ----Cell Testmode Remote Interference----
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
    Dated Log New Line                ----Cell Testmode RIM RS----
    wtsemu.cell_testmode_set_nr       gnb=${gnb_id}    cell_id=${nrcell_id}    testmode=rim_rs    profile_id=${profile_id}    action=${action}
    wtsemu.read_wtsemu_output_until_prompt    timeout=10
    Sleep                             1s
    Dated Log                         > cell_testmode_set_nr cell=${nrcell_id} testmode=rim_rs profile=${profile_id} action=${action}


Start Remote Interference on NRCELL
    [Arguments]             ${nrcell_pos_victim}
    ...                     ${list_nrcell}
    ...                     ${noise_power_val}=${RI_N_PW_1}
    ...                     ${start_symbol_pos}=0
    ...                     ${num_symbols}=32
    #
    ${internal_pos}=                  Evaluate    ${nrcell_pos_victim}-1
    ${victim_cell}=                   Set Variable    ${list_nrcell[${internal_pos}].nrCellId}
    ${current_nrcell}=                Set Variable    ${dn_nrbts}/NRCELL-${victim_cell}
    ${dn_nrrim_profile}=              Set Variable    ${current_nrcell}/NRRIM_PROFILE-1
    Dated Log                         ----Start Remote Interference on NRCELL-${victim_cell}----
    ${profile_id}=                    Set Variable    ${victim_cell}
    # step 1: wtsemu > remote_interference_testmode_nr
    Create RI Testmode NR Profile     profile_id=${profile_id}    noise_power_val=${noise_power_val}    start_symbol_pos=${start_symbol_pos}
    ...                               num_symbols=${num_symbols}
    Cell Testmode Remote Interference    profile_id=${profile_id}    nrcell_id=${victim_cell}    action=activate


Start RIM RS on NRCELL
    [Arguments]             ${nrcell_pos_victim}
    ...                     ${list_nrcell}
    ...                     ${input}
    #
    ${internal_pos}=                  Evaluate    ${nrcell_pos_victim}-1
    ${victim_cell}=                   Set Variable    ${list_nrcell[${internal_pos}].nrCellId}
    ${current_nrcell}=                Set Variable    ${dn_nrbts}/NRCELL-${victim_cell}
    ${dn_nrrim_profile}=              Set Variable    ${current_nrcell}/NRRIM_PROFILE-1
    Dated Log                         ----Start RIM RS on NRCELL-${victim_cell}----
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
    ${rim_framework}=                 Run Keyword If    ${flag_framework_0}    Set Variable    framework_0
    ...           ELSE IF             ${flag_framework_1}    Set Variable    framework_1
    ...           ELSE                Set Variable    ${None}
    Dated Log                         >> rim_framework= ${rim_framework}
    #
    ${aggressor_cell}=                Set Variable    ${victim_cell}
    # rsSetId's are fixed depending on ${victim_cell}
    ${rsSetId}=                       Set Variable    1${victim_cell}000
    ${rsSetId2}=                      Set Variable    2${victim_cell}000
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
    Run Keyword If    ${flag_framework_0}    Run Keywords
    ...                               Set To Dictionary    ${dico}     profile_id                 ${profile_id}
    ...    AND                        Set To Dictionary    ${dico}     config_mode                standalone
    ...    AND                        Set To Dictionary    ${dico}     victim_cell                ${victim_cell}
    ...    AND                        Set To Dictionary    ${dico}     aggressor_cell             ${aggressor_cell}
    ...    AND                        Set To Dictionary    ${dico}     rsSetId                    ${rsSetId}
    ...    AND                        Set To Dictionary    ${dico}     numRsSetId                 1
    ...    AND                        Set To Dictionary    ${dico}     rimRsType                  rsType1
    Run Keyword If                    ${flag_framework_0} and ${k_rsNearFarConfig}
    ...                               Set To Dictionary    ${dico}     rsNearFarConfig            ${input}[rsNearFarConfig]
    Run Keyword If                    ${flag_framework_0}
    ...                               Set To Dictionary    ${dico}     propagation_delay          16
    Run Keyword If                    ${flag_framework_0} and ${k_rsType1NScId}
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
    Run Keyword If                    ${flag_framework_1}    Run Keywords
    ...                               Set To Dictionary    ${dico}     profile_id                 ${profile_id}
    ...    AND                        Set To Dictionary    ${dico}     config_mode                standalone
    ...    AND                        Set To Dictionary    ${dico}     victim_cell                ${victim_cell}
    ...    AND                        Set To Dictionary    ${dico}     aggressor_cell             ${aggressor_cell}
    ...    AND                        Set To Dictionary    ${dico}     rsSetId                    ${rsSetId}
    ...    AND                        Set To Dictionary    ${dico}     numRsSetId                 1
    ...    AND                        Set To Dictionary    ${dico}     rimRsType                  rsType1
    Run Keyword If                    ${flag_framework_1} and ${k_rsNearFarConfig}
    ...                               Set To Dictionary    ${dico}     rsNearFarConfig            ${input}[rsNearFarConfig]
    Run Keyword If                    ${flag_framework_1}    Run Keywords
    ...                               Set To Dictionary    ${dico}     propagation_delay          16
    ...    AND                        Set To Dictionary    ${dico}     rsSetId__2                 ${rsSetId2}
    ...    AND                        Set To Dictionary    ${dico}     numRsSetId__2              1
    ...    AND                        Set To Dictionary    ${dico}     rimRsType__2               rsType2
    ...    AND                        Set To Dictionary    ${dico}     propagation_delay__2       16
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
    Run Keyword If                    ${flag_framework_0} or ${flag_framework_1}    Run Keywords
    ...                               Create And Execute Egate Script   testmode=rimrs_testmode_nr    dico_tm=${dico}
    ...                               script_path=${LOG_PATH}/rimrs_testmode_nr_cell-${victim_cell}.sce    option_remove=${True}    option_sleep=1
    ...    AND                        Cell Testmode RIM RS    profile_id=${profile_id}    nrcell_id=${victim_cell}    action=activate
    ...           ELSE IF             not ${flag_framework_0} and not ${flag_framework_1}
    ...    Dated Log                  > Create RIM RS Testmode NR Profile is not started because actNrRim found is NOT supported
    [Return]                          ${flag_framework_0}    ${flag_framework_1}

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
#CR NOT TESTED#
Get Active Alarm And Check Specific Detection
    [Arguments]             ${param}
    ...                     ${capture}
    ...                     ${alarm_id}
    ...                     ${fault_id}=${None}
    ...                     ${alarm_object}=${None}
    ...                     ${suppl_alarm_info}=${None}
    ...                     ${iteration_max}=32
    ...                     ${suffix}=detection
    #OBSOLETE#...           ${output_prefix}=L1L2
    #OBSOLETE#...           ${output_log_path}=L1L2
    ...                     ${confirm_detection}=${True}
    ...                     ${cell_id_list}=${None}
    #
    Dated Log                         ----Get Active Alarm And Check Specific Detection----
    FOR    ${iteration}    IN RANGE    1    ${iteration_max} + 1
        Dated Log New Line            > detection alarm [${alarm_id}][${fault_id}] on object=${alarm_object} (${iteration}/${iteration_max})
        Dated Log                     > and containing the supplementary information if not none: ${suppl_alarm_info}
        # Capture TTI traces start during detection alarm
        Run Keyword If                ${AUTO_SAVE_DEBUG_DATA} and ${capture}[is_capture_tti] and "${cell_id_list}" != "${None}"
        ...                           Start TTI Logs SR-CR    cell_id_list=${cell_id_list}
        # Capture L1L2 traces start during detection alarm
        Run Keyword If                ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture}[is_capture_l1l2]    Run Keywords
        ...                           Captures Init
        ...    AND                    Capture Start    capture=${capture_l1l2}
        ...    AND                    Traced Sleep    duration=20s    msg=alarm detection and before stopping capture L1L2
        ${alarm_information}=         Detection Alarm Id    alarm_id=${alarm_id}    fault_id=${fault_id}    alarm_object=${alarm_object}
        ...                           confirm_presence=${True}    suppl_info=${suppl_alarm_info}
        #DEBUG_LOG#Dated Log          >> alarm_information= ${alarm_information}
        # Capture TTI traces stop during detection alarm
        Run Keyword If                ${AUTO_SAVE_DEBUG_DATA} and ${capture}[is_capture_tti] and "${cell_id_list}" != "${None}"
        ...                           Stop and Get TTI Logs SR-CR    trace_name=TTI_${suffix}_${fault_id}_${iteration}
        # Capture L1L2 traces stop during detection alarm
        Run Keyword If                ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture}[is_capture_l1l2]
        ...                           Capture L1L2 Stop    capture_config=${capture_l1l2}    output_suffix=${suffix}_${fault_id}_${iteration}
        Exit For Loop If              "${alarm_information}" != "${None}"
        ${pcap_file}=                 Set Variable    ${LOG_PATH}/*/*_${suffix}_${fault_id}_${iteration}*
        Run Keyword If                ${iteration} < ${iteration_max}    Run    command=rm -f ${pcap_file}
    END
    # Alarm must be found after ${iteration} attempts
    ${result}=                        Run Keyword If    "${alarm_information}" != "${None}"    Set Variable    ${True}
    ...           ELSE                Set Variable    ${False}
    Run Keyword If                    ${confirm_detection}    Should Be True    ${result} == ${True}
    [Return]                          ${result}


#CR NOT TESTED#
Loop Detection RIM RS 7527
    [Arguments]             ${param}
    ...                     ${capture}
    ...                     ${nrcell}
    ...                     ${info}
    ...                     ${cell_id_list}
    ...                     ${iteration_max}=10
    #
    FOR    ${iteration}    IN RANGE    1    ${iteration_max} + 1
        # Capture SYSLOG during detection_7527 as Log4
        ${syslog_7527}=               Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture}[is_capture_syslog]
        ...                           SYSLOG Start    host=${GNB_DU.sys[0].M}    name=detection_${nrcell}_7527_${iteration}
        Dated Log                     ----Loop Detection RIM RS 7527 for ${nrcell} (${iteration}/${iteration_max})----
        # [7115][7527](Minor) b'BASE STATION INFORMATION'             :b'RIM-RS detected'
        ${detection}=                 Get Active Alarm And Check Specific Detection    param=${param}    capture=${capture}
        ...                           alarm_id=7115    fault_id=7527    alarm_object=${nrcell}    iteration_max=10
        ...                           suffix=detection_${nrcell}    suppl_alarm_info=${info}    confirm_detection=${False}
        ...                           cell_id_list=${cell_id_list}
        Run Keyword If                ${AUTO_SAVE_DEBUG_DATA} and ${capture}[is_capture_syslog]
        ...                           SYSLOG Stop    syslog=${syslog_7527}
        Exit For Loop If              ${detection}
        ${syslog_file}=               Set Variable    ${LOG_PATH}/SYSLOG/*detection_${nrcell}_7527_${iteration}.log
        Run Keyword If                ${iteration} <= ${iteration_max}    Run    command=rm -f ${syslog_file}
    END
    Should Be True                    ${detection} == ${True}


# --------------------------------------------------------------------------------------------------------------------------------------------------
# Call And Then Traffic #
Call And Then Traffic SR-CR
    [Arguments]             ${param}
    ...                     ${ues_settings}
    ...                     ${capture_settings}
    #
    Dated Log New Line                ----Call And Then Traffic SR-CR----
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
    Critical Step                     CallSetup.WTS Setup           nbUe=${param.total_nb_ue}
    ...                               nbSaUe=${param.nb_sa_ue}    shouldUseLua=${False}    nbCell=${param.total_nb_cell}
    #
    @{cell_id_list}=                  Get List Cells Retained For TTI Streaming SR-CR    cell_id_streaming=${cell_id_for_streaming}
    Dated Log                         > Distname list of the cells retained for TTI streaming ${cell_id_list}
    @{cell_id_list}=                  Run Keyword If    ${isAic}    Copy List    ${cell_id_for_streaming}
    #
    # Capture TTI traces start during call setup
    #NOT_REQUESTED#Run Keyword If     ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti] and "${cell_id_list}" != "${None}"
    #NOT_REQUESTED#...                Start TTI Logs SR-CR    cell_id_list=${cell_id_list}
    # Capture L1L2 traces start during call setup
    Run Keyword If                    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]    Run Keywords
    ...                               Captures Init
    ...    AND                        Capture Start    capture=${capture_l1l2}
    ...    AND                        Sleep    10s
    Dated Log New Line                ----Call Establishment----
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If                "${current_elem.call_type}" == "SA"    Run Keywords
        ...          Critical Step    UE Register And CRNTI Backup    ue_settings=${current_elem}
        ...                           depends=CallSetup.WTS Setup
        ...    AND            Step    CallSetup.Launch PDU Session    ue=${current_elem.ue}    pdu=${current_elem.pdu}    gw=${current_elem.ue}
        ...                           depends=UE Register And CRNTI Backup
        ...       ELSE
        ...          Critical Step    UE Establish NSA Call    ue_settings=${current_elem}
        ...                           depends=CallSetup.WTS Setup
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
    # Capture TTI traces stop during call setup
    #NOT_REQUESTED#@{list_events}=    Create List    utcTimestampData    ulAllocatedPooledResourcesData    dlAllocatedPooledResourcesData
    #NOT_REQUESTED#...                ulFdSchedData    dlFdSchedData
    #NOT_REQUESTED#Run Keyword If     ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti] and "${cell_id_list}" != "${None}"
    #NOT_REQUESTED#...                Stop and Get TTI Logs SR-CR    trace_name=TTI_call_setup    list_events_to_filter=${list_events}
    #
    Display List UEs Settings         ${list_ue}
    # Capture L1L2 traces start during traffic
    Run Keyword If                    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]    Run Keywords
    ...                               Captures Init
    ...    AND                        Capture Start    capture=${capture_l1l2}
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
    Dated Log New Line                ----Check Counter And KPI Constraints----
    Run Keyword If                    ${param.pm_waiting_period} > 0
    ...                               Wait PM availability    pmPeriodSec=300    #pmAvailDelay=60
    FOR    ${iteration_pm}    IN RANGE    1    ${param.pm_waiting_period} + 1
        Wait PM availability          pmPeriodSec=300    #pmAvailDelay=60
        ${pm_path}=    Run Keyword If    ${isAic}    Counters.Collect PM files from BTS    ${LOG_PATH}/PM
        ...                           optional_files=${True}    posProcess=${True}    node='vcu'
        Run Keyword If    ${isAic}    Check Counter And KPI Constraints SR-CR    pm_path=${pm_path}
        ...                           test_name=${param.counter_constraint}_VCU    #localKpiFileName=internal_KPI_Definitions.csv
        ${pm_path}=    Run Keyword If    ${isAic}    Counters.Collect PM files from BTS    ${LOG_PATH}/PM
        ...                           optional_files=${True}    posProcess=${True}    node='vdu'
        ...       ELSE                Counters.Collect PM files from BTS    ${LOG_PATH}/PM
        Run Keyword If    ${isAic}    Check Counter And KPI Constraints SR-CR    pm_path=${pm_path}
        ...                           test_name=${param.counter_constraint}_VDU    #localKpiFileName=internal_KPI_Definitions.csv
        ...       ELSE                Check Counter And KPI Constraints SR-CR    pm_path=${pm_path}
        ...                           test_name=${param.counter_constraint}
    END
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If                "${current_elem.call_type}" == "SA"
        ...               Step        CallSetup.UE Deregister    id=${current_elem.ue}    ue_deregister_type=switch_off    by=ue
        ...                           depends=Ue Register And CRNTI Backup
        ...       ELSE
        ...               Step        CallSetup.UE Detach Enb    ueSetting=${current_elem}
        ...                           depends=UE Establish NSA Call
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Handover #
#CR NOT TESTED#
Perform Handover By Using meas_id 1 and event A3
    [Arguments]             ${current_elem}
    ...                     ${csi_override_cqi}=3
    #
    Dated Log New Line                ----Perform Handover By Using meas_id 1 and event A3----
    ${backup_serving_cell_id}=        Set Variable    ${current_elem.target_cells}
    ${current_param}=                 Set Variable    physCellId
    ${dn_target_nrcell_for_ho}=       Set Variable    ${dn_nrbts}/NRCELL-${current_elem.target_handover}
    # NRCELL.physCellId / get / target
    ${nb_match}    ${result}          Get Values From Object    dist_name=${dn_target_nrcell_for_ho}    p_name=${current_param}
    ...                                                             current_scf=${updated_scf}
    Should Be True                    ${nb_match} > 0
    ${physical_target_cell_id_for_ho}=    Set Variable    ${result[0]}
    Dated Log                         >> match for ${dn_target_nrcell_for_ho}: ${current_param}= ${physical_target_cell_id_for_ho}
    ${output_crnti}=                  Testmode UE Measurement Send NR    ue_id=${current_elem.ue}
    ...                                                             physical_target_cell_id=${physical_target_cell_id_for_ho}
    Run Keyword If                    "${csi_override_cqi}" != "${None}"    Run Keywords
    ...                               Testmode Csi Override    profile_id=${current_elem.ue}
    ...                               nrcell=${current_elem.target_cells}
    ...                               ue_id=${current_elem.ue}
    ...                               action=deactivate
    ...    AND                        Testmode Csi Override    profile_id=${current_elem.ue}
    ...                               nrcell=${current_elem.target_handover}
    ...                               ue_id=${current_elem.ue}
    ...                               action=activate
    Set To Dictionary    ${current_elem}    target_cells    ${current_elem.target_handover}
    Set To Dictionary    ${current_elem}    target_handover    ${backup_serving_cell_id}
    Set To Dictionary    ${current_elem}    c_rnti    ${output_crnti}


#CR NOT TESTED#
Perform Handovers By Using meas_id 1 and event A3
    [Arguments]             ${list_ue}
    ...                     ${param}
    #
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If                "${param.ue_measurement_nr}" == "${True}" and ${current_elem.ue_measurement_nr} == ${True}
        ...                           Perform Handover By Using meas_id 1 and event A3    ${current_elem}
    END


#CR NOT TESTED#
Perform N Handovers By Using meas_id 1 and event A3
    [Arguments]             ${list_elem}
    ...                     ${param}
    ...                     ${n_handover}=50
    #
    Dated Log New Line                ----Perform ${n_handover} Handovers By Using meas_id 1 and event A3----
    FOR    ${iteration}    IN RANGE    1    ${n_handover} + 1
        Dated Log                     > Loop ${iteration} / ${n_handover}
        Perform Handovers By Using meas_id 1 and event A3    list_ue=${list_elem}    param=${param}
        Sleep                         1s
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
