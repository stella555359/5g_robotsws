*** Settings ***
Documentation     \\eseefsn50.emea.nsn-net.net\rotta4internal\ATF\juvirtan
Resource          ./../CUDU_L2/common_setup_teardown.robot
Library           ../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb
Suite Teardown    Common Suite Teardown    debug
#Test Teardown    Common Test Teardown    debug
Test Teardown     Common Test Teardown 2
Force Tags        CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${LOCAL_WTS_DIR}     ${CURDIR}/config/WTS_CFG
${SCF_PATH}          ${CURDIR}/config/SCF
${SCF_8311_BB102}    ${SCF_PATH}/SCF_BB102.xml
${SCF_8311_CB306}    ${SCF_PATH}/SCF_6cell_4CC_blind_add.xml
${SCF_8311_CB307}    ${SCF_PATH}/SCF_6cell_4CC.xml
${SCF_8311_CB301}    ${SCF_PATH}/SCF_CB301.xml
${SCF_8311_CB601}    ${SCF_PATH}/SCF_CB601.xml
${IPHY_6CELL}        ${CURDIR}/config/IPHY/iphy_6cell_FFTFFT.xml
${WTS_CFG}           basic_setup_TF_TTF_TTFF_n78n78n66n66.cfg
@{LOG_NAME_LIST}     btslog    egatelog
${force_reboot}      ${True}
${rd_flag}           0x58057a = 4;0x58057d = 2147483648

*** Test Cases ***
CB008311_ET_B_B102_2CC_TF_SA_Verify_Buffer_monitoring_deactivation_with_covBasedA1_when_UE_leaves_A1_threshold_coverage
    [Documentation]
    ...   Precondition:
    ...                 scellActivationMethod = bufferBased
    ...                 scellAdditionMethod = covBasedA1
    ...                 actSCellReleaseForInactiveSCell = timer_based_Fr1
    ...                 scellInactivityReleaseTimer = 10 seconds
    ...                 scellDeactivationTimerGNB = ms1280
    ...                 actBufferBasedSCellAddition = oneShot_Dl_Fr1
    ...                 a1ThresholdSCellAddSsbRsrpFDD = 80
    ...                 a1ThresholdSCellAddSsbRsrpTDD = 80
    ...         Feature 5GC002200 and Beamforming open
    ...   Test Steps:
    ...                 Step1: UE attach
    ...                 Step2: Send A1 report RSRP higher than 80 to make UE is in A1 threshold coverage
    ...                 Step3: Send A1 report RSRP lower than 80 to make UE is out of A1 threshold coverage
    ...                 Step4: Send A1 report RSRP higher than 80 to make UE is in A1 threshold coverage
    ...                 Step5: Start DL traffic to make scell activated.
    ...   Check point:
    ...                 1. Check syslog for Step 2 and Step 3.
    ...                 2. Check egate console log for Step 5.
    [Tags]    caseBB102    TA_Mayue    Manual_Fangping
    [Setup]    Run Keywords
    ...    Suite Setup Update GNB    force_reboot=${force_reboot}    log=${False}    scf_file=${SCF_8311_BB102}    iphy_file=${IPHY_6CELL}
    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...    AND    Suite Setup Start WTS And Check OnAir    log=${False}
    ...    AND    Common Test Setup 2
    Attach UE And Start Traffic For B_B102    3    100    10    800

#CB008311_ET_C_B306_4CC_TTFF_SA_Verify_partial_Scell_release_due_to_prolonged_data_inactivity_with_blind_ScellAddition_bufferBased_ScellActive
#    [Documentation]
#    ...   Precondition:
#    ...                 scellActivationMethod = bufferBased
#    ...                 scellAdditionMethod = blind
#    ...                 actSCellReleaseForInactiveSCell = timer_based_Fr1
#    ...                 scellInactivityReleaseTimer = 10 seconds
#    ...                 scellDeactivationTimerGNB = ms1280
#    ...                 actBufferBasedSCellAddition = oneShot_Dl_Fr1
#    ...                 a1ThresholdSCellAddSsbRsrpFDD = 80
#    ...                 a1ThresholdSCellAddSsbRsrpTDD = 80
#    ...                 maxNumScellsDlFr1 = 3
#    ...         Feature 5GC002200 and Beamforming open
#    ...   Test Steps:
#    ...                 Step1: UE attach
#    ...                 Step2: Start engough DL traffic to make scell activated.
#    ...                 Step3: Low DL traffic to make scell deactivated.
#    ...                 Step4: Wait for scell released.
#    ...   Check point:
#    ...                 1. Check egate console log for Step 5.
#    [Tags]    caseCB306    TA_Mayue    Manual_Fangping    CIT
#    [Setup]    Run Keywords
#    ...    Suite Setup Update GNB    force_reboot=${force_reboot}    log=${False}    scf_file=${SCF_8311_CB306}    iphy_file=${IPHY_6CELL}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...    AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...    AND    Common Test Setup 2
#    Attach UE And Start Traffic For C_B306    1    100    10    800

#CB008311_ET_C_B307_2CC_TF_SA_Verify_Scell_release_due_to_prolonged_data_inactivity_with_covBasedA1_ScellAddition_bufferBased_ScellActive
#    [Documentation]
#    ...   Precondition:
#    ...                 scellActivationMethod = bufferBased
#    ...                 scellAdditionMethod = covBasedA1
#    ...                 actSCellReleaseForInactiveSCell = timer_based_Fr1
#    ...                 scellInactivityReleaseTimer = 10 seconds
#    ...                 scellDeactivationTimerGNB = ms1280
#    ...                 actBufferBasedSCellAddition = oneShot_Dl_Fr1
#    ...                 a1ThresholdSCellAddSsbRsrpFDD = 80
#    ...                 a1ThresholdSCellAddSsbRsrpTDD = 80
#    ...         Feature 5GC002200 and Beamforming open
#    ...   Test Steps:
#    ...                 Step1: UE attach
#    ...                 Step2: Send A1 report
#    ...                 Step3: Start engough DL traffic to make scell activated.
#    ...                 Step4: Low DL traffic to make scell deactivated.
#    ...                 Step5: Wait for scell released.
#    ...   Check point:
#    ...                 1. Check egate console log for Step 5.
#    [Tags]    caseCB307    TA_Mayue    Manual_Fangping
#    [Setup]    Run Keywords
#    ...    Suite Setup Update GNB    force_reboot=${force_reboot}    log=${False}    scf_file=${SCF_8311_CB307}    iphy_file=${IPHY_6CELL}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...    AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...    AND    Common Test Setup 2
#    Attach UE And Start Traffic For C_B307    3    100    10    800

CB008311_ET_C_B301_2CC_TF_SA_Verify_Scell_release_due_to_prolonged_data_inactivity_with_blind_ScellAddition_bufferBased_ScellActive
    [Documentation]
    ...   Precondition:
    ...                 scellActivationMethod = bufferBased
    ...                 scellAdditionMethod = 0 (blind)
    ...                 actSCellReleaseForInactiveSCell = timer_based_Fr1
    ...                 scellInactivityReleaseTimer = 10 seconds
    ...                 scellDeactivationTimerGNB = ms1280
    ...                 actBufferBasedSCellAddition = oneShot_Dl_Fr1
    ...         Feature 5GC002200 and Beamforming open
    ...   Test Steps:
    ...                 Step1: UE attach
    ...                 Step2: Start enough DL traffic to activate Scell
    ...                 Step3: Decrease DL non-GBR data rate to low rate and scell deactivate
    ...                 Step4: Increase DL non-GBR data rate to activate Scell again before the scellInactivityReleaseTimer expires
    ...                 Step5: Decrease DL non-GBR data rate to low rate again, wait the scellInactivityReleaseTimer expires
    ...   Check point:
    ...                 1.Scell activate, DL Non-GBR data transfer on Both PCell and SCell with enough DL traffic
    ...                 2.Decrease DL non-GBR data rate , scell deactivate, DL Non-GBR data transfer on PCell
    ...                   Scell not release	before the scellInactivityReleaseTimer expires
    ...                 3.Increase DL non-GBR data rate , scell activate again, DL Non-GBR data transfer on Both PCell and SCell again
    ...                 4.Decrease DL non-GBR data rate , scell deactivate  again, DL Non-GBR data transfer on PCell
    ...                   Scell release	after the scellInactivityReleaseTimer expires, inactiveReason = inactivity_timer
    ...                   ScellInactivityReleaseTimer = 10 seconds
    ...                 5.L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER start and stop
    ...   rd parameter: 0x58057a = 4   #   rdFeatureFlagBitmapLevel=DEBUG
    ...                 0x58057d = 2147483648   #   rdFeatureFlagBitmap2=31CA.ACT_DEACT(8311)
    [Tags]    caseCB301    Manual_Fangping    TA_Krihu
    [Setup]    Run Keywords
    ...    Suite Setup Update GNB    force_reboot=${force_reboot}    log=${False}    scf_file=${SCF_8311_CB301}    iphy_file=${IPHY_6CELL}
    ...    swconfig_param=${rd_flag}
    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...    AND    Suite Setup Start WTS And Check OnAir    log=${False}
    ...    AND    Common Test Setup 2
    Attach UE    3
    Do and Check Traffic For C_B301    3
    Syslog Check for C_B301

CB008311_ET_C_B402_2CC_TF_SA_Verify_Scell_release_due_to_UE_Overheating_with_covBasedA1_ScellAddition_bufferBased_ScellActive
    [Documentation]
    ...   Precondition:
    ...                 scellActivationMethod = bufferBased
    ...                 scellAdditionMethod = 1 (covBasedA1)
    ...                 actSCellReleaseForInactiveSCell = timer_based_Fr1
    ...                 scellInactivityReleaseTimer = 40 seconds
    ...                 scellDeactivationTimerGNB = ms1280
    ...                 actBufferBasedSCellAddition = oneShot_Dl_Fr1
    ...                 caBackoffTimerUeOh = 60
    ...         Feature CB008697 open, NIDD Parameter settings for 8697:
    ...                 actOverheatingAssistance = true
    ...                 timerPostOverheating = 60
    ...                 timerOverheatIndProhibit = 10s
    ...         Feature 5GC002200 and Beamforming open
    ...   Test Steps:
    ...                 Step 1: UE1 attaches to the TDD cell (Cell1) with high DL non-GBR data rate
    ...                 Step 2: Trigger A1 report with entry condition met
    ...                 Step 3: Trigger UE1 overheated state, wait the scellInactivityReleaseTimer expires
    ...                 Step 4: The gNB receives an A1 measurement report for SCell Addition with entry condition before caBackoffTimerUeOh expired
    ...                 Step 5: After at least caBackoffTimerUeOh seconds, The gNB activates re-activates DL buffer monitoring for SCell Addition
    ...   Check point:
    ...                 1.Scell activate, DL Non-GBR data transfer on Both PCell
    ...                 2.Check UeAssistanceInformation, it should contain reducedMaxCCs/reducedCCsDL value = 0
    ...                 3.Scell deactivate due to UE overheating, DL Data transfer is on the PCell only
    ...                   ScellInactivityReleaseTimer start, caBackoffTimerUeOh start
    ...                 4.Scell release	after the scellInactivityReleaseTimer expires, inactiveReason = ue_overheating
    ...                   ScellInactivityReleaseTimer = 40 seconds
    ...                 5.After at least caBackoffTimerUeOh seconds, The gNB activates re-activates DL buffer monitoring for SCell Addition
    ...                   DL data transfer on Both PCell
    ...         Check below PM counter for related steps:
    ...                 M55118C10503 = 1	DL_RRC_1SCELL_REL_ATT_SA
    ...                 M55118C10504 = 1	DL_RRC_1SCELL_REL_SUC_SA
    ...                 M55118C10513 = 1	INA_OVHT_REL_SCELL_ATT_SA
    ...                 M55118C10514 = 1	INA_OVHT_REL_SCELL_SUC_SA
    ...                 M55316C09000 = 1	SCELL_ACTIVATIONS
    ...                 M55316C09001 = 0	SCELL_DEACT_BUFFER_STATUS
    ...                 M55316C09002 = 0	SCELL_DEACT_CHANNEL_STATE
    ...   rd parameter: 0x58057a = 4   #   rdFeatureFlagBitmapLevel=DEBUG
    ...                 0x58057d = 2147483648   #   rdFeatureFlagBitmap2=31CA.ACT_DEACT
    [Tags]    caseCB402    Manual_Krihu    TA_Krihu
    [Setup]    Run Keywords
    ...    Suite Setup Update GNB    force_reboot=${force_reboot}    log=${False}    scf_file=${SCF_8311_CB301}    iphy_file=${IPHY_6CELL}
    ...    swconfig_param=${rd_flag}
    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...    AND    Common Test Setup 2
    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_C_B402.xml
    Delta Commission With SCF File    ${json_file}
    Suite Setup Start WTS And Check OnAir    log=${False}
    Wait until this counter refresh period end
    Attach UE    3
    Send A1 report And Do Traffic For C_B402    3
    Trigger OverHeating    3
    Send A1 report again And wait caBackoffTimerUeOh expired    3
    Syslog Check for C_B402
    Get and Check PM Counter for C_B402

#CB008311_ET_C_B601_2CC_FT_SA_Verify_Scell_release_due_to_Bad_RLQ_with_covBasedA1_ScellAddition_bufferBased_ScellActive
#    [Tags]    caseCB601    Manual_MaYue    Manual_MaYue
#    [Setup]    Run Keywords
#    ...    Suite Setup Update GNB    force_reboot=${force_reboot}    log=${False}    scf_file=${SCF_8311_CB601}    iphy_file=${IPHY_6CELL}
#   ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...    AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...    AND    Common Test Setup 2
#    Attach UE And Start Traffic For C_B601    4    100    10    800

*** Keywords ***
Attach UE
    [Arguments]    ${UE_ID}
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}

Check Traffic On Pcell and Scell
    [Arguments]    ${UE_ID}    ${Scell_num}    ${dl_tp_threshold}=10
    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    Run Keyword And Continue On Failure    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
    FOR    ${index}    IN RANGE    1    ${Scell_num}+1
        ${scell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=${index}
        Run Keyword And Continue On Failure    Should Be True    ${scell_dl_tp}>${dl_tp_threshold}
    END

Check Traffic On Pcell
    [Arguments]    ${UE_ID}    ${Scell_num}    ${dl_tp_threshold}=10
    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    Run Keyword And Continue On Failure    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
    FOR    ${index}    IN RANGE    1    ${Scell_num}+1
        ${scell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=${index}
        Run Keyword And Continue On Failure    Should Be True    "${scell_dl_tp}"=="0"
    END

Send Measurement Report To Trigger Scell Active
    [Arguments]    ${UE_ID}    ${meas_id}=1
    ute_wtssim.Execute Egate Command    cmd=ue_measurement_send_nr id\=${UE_ID} meas_id\=${meas_id} event=A1 srsrp_nr=95
    Sleep    2s

Send Measurement Report To Trigger Scell Deacitve
    [Arguments]    ${UE_ID}
    ute_wtssim.Execute Egate Command    cmd=ue_measurement_send_nr id\=${UE_ID} meas_id=1 event=A1 srsrp_nr=75
    Sleep    2s

Send Measurement Report To Trigger Scell Reactive
    [Arguments]    ${UE_ID}    ${meas_id}=2
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${UE_ID} meas_id\=${meas_id} event=A1 srsrp_nr=95
    ...    pass_regexp=SCellIndex 1 activated successfully at airphone    timeout=3minutes
    Sleep    2s

Start DL Traffic To Activate Scell
    [Arguments]    ${UE_ID}    ${activate_times}    ${trf_id_num}    ${Scell_num}
    FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id\=${index} mbps=175 dir=dl
    END
    Sleep   5s    reason=Wait scell activate successfully ...
    #save debug log
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellAct.log
    ${egate_console_file}=    Set Variable    /opt/iphy/latest/egate_console.log
    Check Egate Log With Message     ${egate_console_file}    SCellIndex 1 activated successfully at airphone    ${activate_times}
    Run keyword if    "${Scell_num}">"1"     Check Egate Log With Message     ${egate_console_file}
    ...    SCellIndex 2 activated successfully at airphone    ${activate_times}
    Run keyword if    "${Scell_num}">"2"     Check Egate Log With Message     ${egate_console_file}
    ...    SCellIndex 3 activated successfully at airphone    ${activate_times}

Decrease DL Traffic To Deactivate Scell
    [Arguments]    ${UE_ID}    ${deactivate_times}    ${Scell_num}
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu=1 qfi=1 dir=dl
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=1 mbps=20 dir=dl
    Sleep   5s    reason=Wait scell deactivate successfully ...
    #save debug log
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
    ${egate_console_file}=    Set Variable    /opt/iphy/latest/egate_console.log
    Check Egate Log With Message     ${egate_console_file}    SCellIndex 1 deactivated successfully at airphone    ${deactivate_times}
    Run keyword if    "${Scell_num}">"1"     Check Egate Log With Message     ${egate_console_file}
    ...    SCellIndex 2 deactivated successfully at airphone    ${deactivate_times}
    Run keyword if    "${Scell_num}">"2"     Check Egate Log With Message     ${egate_console_file}
    ...    SCellIndex 3 deactivated successfully at airphone    ${deactivate_times}

Check egate_console log Message
    [Arguments]    ${A2A_ini}
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    A2A_Check_RRC_Log    ${CURDIR}/A2A/rrcReconfiguration/${A2A_ini}    ${TEST_LOG_DIRECTORY}/egate_console.log    log_path=${TEST_LOG_DIRECTORY}


Attach UE And Start Traffic For B_B102
    [Arguments]    ${UE_ID}    ${activate_mbps}    ${deactivate_mbps}    ${max_dl_tp}
    [Documentation]
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=95
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=75
    ...    syslog:add Ue,delete Ue
    Log To Console   ${activate_mbps} ${deactivate_mbps} ${max_dl_tp}
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
    Send Measurement Report To Trigger Scell Active    3
    Send Measurement Report To Trigger Scell Deacitve    3
    Sleep    5s
    ute_syslog.Collect From Savepoint    savepoint=${savepoint}
    ...    destination_file=${TEST_LOG_DIRECTORY}/target_syslog.txt    alias=${GNB_SYSLOG.alias}
    ${content}=    Get File    ${TEST_LOG_DIRECTORY}/target_syslog.txt
#    Run Keyword And Continue On Failure    Should Contain    ${content}    add Ue
#    Run Keyword And Continue On Failure    Should Contain    ${content}    delete Ue
    Send Measurement Report To Trigger Scell Active    3
    Run Keyword And Continue On Failure    Start DL Traffic To Activate Scell    3    1    3    1
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_add.ini

Attach UE And Start Traffic For C_B306
    [Arguments]    ${UE_ID}    ${activate_mbps}    ${deactivate_mbps}    ${max_dl_tp}
    [Documentation]
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=95
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=75
    ...    syslog:add Ue,delete Ue
    Log To Console   ${activate_mbps} ${deactivate_mbps} ${max_dl_tp}
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    Run Keyword And Continue On Failure    Start DL Traffic To Activate Scell    1    1    3    3
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_add_4CC.ini
    Run Keyword And Continue On Failure    Decrease DL Traffic To Deactivate Scell    1    1    3
    Sleep    10s    Wait scellInactivityReleaseTimer expires, Scell Release...
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_delete_4CC.ini

Attach UE And Start Traffic For C_B307
    [Arguments]    ${UE_ID}    ${activate_mbps}    ${deactivate_mbps}    ${max_dl_tp}
    Log To Console   ${activate_mbps} ${deactivate_mbps} ${max_dl_tp}
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
    Send Measurement Report To Trigger Scell Active    3
    ute_syslog.Collect From Savepoint    savepoint=${savepoint}
    ...    destination_file=${TEST_LOG_DIRECTORY}/target_syslog.txt    alias=${GNB_SYSLOG.alias}
    ${content}=    Get File    ${TEST_LOG_DIRECTORY}/target_syslog.txt
    Run Keyword And Continue On Failure    Should Contain    ${content}    add Ue
    Run Keyword And Continue On Failure    Start DL Traffic To Activate Scell    3    1    3    1
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_add.ini
    Run Keyword And Continue On Failure    Decrease DL Traffic To Deactivate Scell    3    1    1
    Sleep    10s    Wait scellInactivityReleaseTimer expires, Scell Release...
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_delete_2CC.ini

Do and Check Traffic For C_B301
    [Arguments]    ${UE_ID}
    Log To Console   ${UE_ID}
    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
    Run Keyword And Continue On Failure    Start DL Traffic To Activate Scell    3    1    5    1
    Sleep    10s    reason=Wait ttraffic stab1e...
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_add.ini
    Run Keyword And Continue On Failure    Check Traffic On Pcell and Scell    3    1
    Run Keyword And Continue On Failure    Decrease DL Traffic To Deactivate Scell    3    1    1
    ute_syslog.Collect From Savepoint    savepoint=${savepoint}
    ...    destination_file=${TEST_LOG_DIRECTORY}/syslog_C_B301_1.txt    alias=${GNB_SYSLOG.alias}
    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
    Sleep    2s
    Run Keyword And Continue On Failure    Start DL Traffic To Activate Scell    3    2    5    1
    Sleep    10s    reason=Wait ttraffic stab1e...
    Run Keyword And Continue On Failure    Decrease DL Traffic To Deactivate Scell    3    2    1
    Sleep    10s    Wait scellInactivityReleaseTimer expires, Scell Release...
    ute_syslog.Collect From Savepoint    savepoint=${savepoint}
    ...    destination_file=${TEST_LOG_DIRECTORY}/syslog_C_B301_2.txt    alias=${GNB_SYSLOG.alias}
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_delete_2CC.ini
    Run Keyword And Continue On Failure    Check Traffic On Pcell    3    1

Syslog Check for C_B301
    ${content1}=    Get File    ${TEST_LOG_DIRECTORY}/syslog_C_B301_1.txt
    Run Keyword And Continue On Failure    Should Contain    ${content1}    delete Ue
    Run Keyword And Continue On Failure    Should Contain    ${content1}    sCellInactivityReleaseTimer(10)
    Run Keyword And Continue On Failure    Should Contain    ${content1}    Start timer L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER
    Run Keyword And Continue On Failure    Should Contain    ${content1}    Stop timer L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER
    Run Keyword And Continue On Failure    Should not Contain    ${content1}    Received TaskDone for ueSCellReleaseCompleteTask - OK
    ${content2}=    Get File    ${TEST_LOG_DIRECTORY}/syslog_C_B301_2.txt
    Run Keyword And Continue On Failure    Should Contain    ${content2}    add Ue
    Run Keyword And Continue On Failure    Should Contain    ${content2}    Stop timer L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER
    Run Keyword And Continue On Failure    Should Contain    ${content2}    Start timer L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER
    Run Keyword And Continue On Failure    Should Contain    ${content2}    Dl timer expiry
    Run Keyword And Continue On Failure    Should Contain    ${content2}    sCellNrCellIdentity:16386,inactiveReason:inactivity_timer

Send A1 report And Do Traffic For C_B402
    [Arguments]    ${UE_ID}
    Log To Console   ${UE_ID}
    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
    Send Measurement Report To Trigger Scell Active    3
    Run Keyword And Continue On Failure    Start DL Traffic To Activate Scell    3    1    5    1
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_add.ini
    sleep    10s    reason=Wait ttraffic stab1e...
    Run Keyword And Continue On Failure    Check Traffic On Pcell and Scell    3    1
    #ute_syslog.Wait For Message In Syslog File    regexp=Stop timer L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER
    #...    timeout=2minutes    alias=${GNB_SYSLOG.alias}
    ute_syslog.Collect From Savepoint    savepoint=${savepoint}
    ...    destination_file=${TEST_LOG_DIRECTORY}/syslog_C_B402_1.txt    alias=${GNB_SYSLOG.alias}

Trigger OverHeating
    [Arguments]    ${UE_ID}
    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
    Sleep    2s
    Run Keyword And Continue On Failure    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_assistance_send_nr ue_id\=${UE_ID} forOverheating=yes reducedCCsDL=0
    ...    pass_regexp=SCellIndex 1 deactivated successfully    timeout=60s
    Sleep    40s
    Run Keyword And Continue On Failure    Check Traffic On Pcell    3    1
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_delete_2CC.ini
    Run Keyword And Continue On Failure    Check egate_console log Message    C_B402.ini
    ute_syslog.Wait For Message In Syslog File    regexp=Dl timer expiry    timeout=2minutes    alias=${GNB_SYSLOG.alias}
    ute_syslog.Collect From Savepoint
    ...    savepoint=${savepoint}    destination_file=${TEST_LOG_DIRECTORY}/syslog_C_B402_2.txt    alias=${GNB_SYSLOG.alias}

Send A1 report again And wait caBackoffTimerUeOh expired
    [Arguments]    ${UE_ID}
    Run Keyword And Continue On Failure    ute_wtssim.Execute Egate Command    cmd=ue_measurement_send_nr id\=${UE_ID} meas_id=3 event=A1 srsrp_nr=95
    ...    pass_regexp=SCellIndex 1 activated successfully at airphone     timeout=60s
    Sleep    10s    reason=Wait ttraffic stab1e...
    Run Keyword And Continue On Failure    Check Traffic On Pcell and Scell    3    1

Syslog Check for C_B402
    ${content1}=    Get File    ${TEST_LOG_DIRECTORY}/syslog_C_B402_1.txt
    #Run Keyword And Continue On Failure    Should Contain    ${content1}    add Ue
    #Run Keyword And Continue On Failure    Should Contain    ${content1}    delete Ue
    Run Keyword And Continue On Failure    Should Contain    ${content1}    A1ScellAdd
    Run Keyword And Continue On Failure    Should Contain    ${content1}    Recv BufferMonitoringNotification
    Run Keyword And Continue On Failure    Should Contain    ${content1}    sCellInactivityReleaseTimer(40)
    Run Keyword And Continue On Failure    Should Contain    ${content1}    Start timer L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER
    Run Keyword And Continue On Failure    Should Contain    ${content1}    Stop timer L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER
    ${content2}=    Get File    ${TEST_LOG_DIRECTORY}/syslog_C_B402_2.txt
    Run Keyword And Continue On Failure    Should Contain    ${content2}    Start timer L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER
    Run Keyword And Continue On Failure    Should Contain    ${content2}    Dl timer expiry
    #Run Keyword And Continue On Failure    Should Contain    ${content2}    sCellNrCellIdentity:16386,inactiveReason:ue_overheating
    Run Keyword And Continue On Failure    Should Contain    ${content2}    sCellNrCellIdentity:16386, inactiveReason:ue_overheating
    Run Keyword And Continue On Failure    Should Contain    ${content2}    CaBackoffTimerUeOh

Wait until this counter refresh period end
    #<p name="reportingIntervalPm">5min</p>
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for the period end.
    Sleep    5s    wait for a while.

Get and Check PM Counter for C_B402
    #<p name="reportingIntervalPm">5min</p>
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    20s    wait pm counter file generated stable.
    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
    ${DL_SCELL_REL_ATT}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C10503    cell_id=3
    Run Keyword And Continue On Failure    should Be True    "${DL_SCELL_REL_ATT}"=="1"
    ${DL_SCELL_REL_SUC}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C10504    cell_id=3
    Run Keyword And Continue On Failure    should Be True    "${DL_SCELL_REL_SUC}"=="1"
    ${INA_OVHT_REL_SCELL_ATT}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C10513    cell_id=3
    Run Keyword And Continue On Failure    should Be True    "${INA_OVHT_REL_SCELL_ATT}"=="1"
    ${INA_OVHT_REL_SCELL_SUC}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C10514    cell_id=3
    Run Keyword And Continue On Failure    should Be True    "${INA_OVHT_REL_SCELL_SUC}"=="1"
    ${scell_activations}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09000    cell_id=2
    Run Keyword And Continue On Failure    should Be True    ${scell_activations}>0
    ${scell_deact_buffer}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09001    cell_id=2
    Run Keyword And Continue On Failure    should Be True    "${scell_deact_buffer}"=="0"
    ${scell_deact_channel}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09002    cell_id=2
    Run Keyword And Continue On Failure    should Be True    "${scell_deact_channel}"=="0"

Attach UE And Start Traffic For C_B601
    [Arguments]    ${UE_ID}    ${activate_mbps}    ${deactivate_mbps}    ${max_dl_tp}
    [Documentation]
    ...    bler_testmode_nr profile_id=2 target_mcs=0 num_dl_pkts=10000
    ...    ue_testmode_set_nr id=1 scell=1 testmode=bler action=activate profile_id=2
    ...    ue_testmode_set_nr id=1 scell=1 testmode=bler action=deactivate profile_id=2
    ...    bler_testmode_nr delete=true profile_id=2
    Log To Console   ${activate_mbps} ${deactivate_mbps} ${max_dl_tp}
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    Send Measurement Report To Trigger Scell Active    ${UE_ID}
    Start DL Traffic To Activate Scell    ${UE_ID}    1    1    1
    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    2
    Run Keyword And Continue On Failure    Add Bad RLQ to Release Scell    ${UE_ID}
    Run Keyword And Continue On Failure    Remove Bad RLQ    ${UE_ID}
    Sleep    5s
    Send Measurement Report To Trigger Scell Active    ${UE_ID}    2
    #Check Scell in Blacklist
    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    1
    Sleep    30s
    Run Keyword And Continue On Failure    Send Measurement Report To Trigger Scell Reactive    ${UE_ID}    2
    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    2

Check Whether UE In CA Mode
    [Arguments]    ${UE_ID}=1    ${ca_num}=1
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data     cmd=ue_stats_nr id\=${UE_ID} type=pdsch scell=0-31    pass_regexp=EGATE
    Log    ${output}
    Should Contain X Times    ${output}    CellIndex-    ${ca_num}   msg=UE is not in ${ca_num} CC mode

Add Bad RLQ to Release Scell
    [Arguments]    ${UE_ID}=1
    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id=2 target_mcs=0 num_dl_pkts=10000
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_testmode_set_nr id\=${UE_ID} scell=1 testmode=bler action=activate profile_id=2
    ...    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
    Should Contain    ${output}    SCellIndex 1 deactivated successfully at airphone
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_delete_2CC.ini

Remove Bad RLQ
    [Arguments]    ${UE_ID}=1
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${UE_ID} scell=1 testmode=bler action=deactivate profile_id=2
    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr delete=true profile_id=2
