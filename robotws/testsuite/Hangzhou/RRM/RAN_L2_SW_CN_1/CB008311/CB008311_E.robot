*** Settings ***
Documentation     \\eseefsn50.emea.nsn-net.net\rotta4internal\ATF\juvirtan
Resource          ./../CUDU_L2/common_setup_teardown.robot
Suite Teardown    Common Suite Teardown    debug
Test Teardown     Common Test Teardown 2
Force Tags        CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${LOCAL_WTS_DIR}     ${CURDIR}/config/WTS_CFG
${SCF_PATH}          ${CURDIR}/config/SCF
${SCF_8311_CB301}    ${SCF_PATH}/SCF_CB301.xml
${IPHY_6CELL}        ${CURDIR}/config/IPHY/iphy_6cell_FFTFFT.xml
${WTS_CFG}           basic_setup_TF_TTF_TTFF_n78n78n66n66.cfg
@{LOG_NAME_LIST}     btslog    egatelog
${force_reboot}      ${True}
${rd_flag}           0x58057a = 4;0x58057d = 2151677952

*** Test Cases ***
CB008311_ET_E_IWK1001_2CC_FT_UL_SA_Verify_Buffer_based_one_shot_Scell_addition_and_Scell_release_due_to_prolonged_data_inactivity
    [Documentation]
    ...   Precondition:
    ...                 scellActivationMethod = blind
    ...                 scellAdditionMethod = 1 (covBasedA1)
    ...                 actSCellReleaseForInactiveSCell = timer_based_Fr1
    ...                 scellInactivityReleaseTimer = 40 seconds
    ...                 scellDeactivationTimerGNB = infinity
    ...                 actBufferBasedSCellAddition = oneShot_Dl_Fr1
    ...         Feature CB006137 open, NIDD Parameter settings for 6137:
    ...                 dlToUlContributionRatio = 50
    ...                 flexibleCAMode = 2 (ConfigurationIndependent).
    ...                 carrierAggregationSupportList = 200 (ca_Fdd_Fr1Tdd_Sa)   //5GC001390 FDD Pcell basic feature
    ...                                                 210 (ca_Fdd_Fr1Tdd_Sa)   //CB006137 FDD+TDD UL CA enable
    ...         Feature 5GC002200 and Beamforming open
    ...   Test Steps:
    ...                 Step1: UE attach
    ...                 Step2: Send A1 report for Scell addition
    ...                 Step3: Start enough DL traffic to activate Scell
    ...                 Step4: Decrease DL non-GBR data rate to low rate, wait the scellInactivityReleaseTimer expires and scell release
    ...   Check point:
    ...                 1.Scell activate, DL Non-GBR data transfer on Both PCell and SCell with enough DL traffic
    ...                 2.Decrease DL non-GBR data rate , Scell release after the scellInactivityReleaseTimer expires, DL data transfer on PCell
    ...                   ScellInactivityReleaseTimer = 40 seconds
    ...                 3.L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER start and stop when scell deactivate and activate
    ...   rd parameter: 0x58057a = 4   #   rdFeatureFlagBitmapLevel=DEBUG
    ...                 0x58057d = 2151677952   #   rdFeatureFlagBitmap2=22INTERBAND_CA.ACT_DEACT(6137)
    ...                                                                  31CA.ACT_DEACT(8311)
    [Tags]    caseE_IWK1001    Manual_Krihu    TA_Krihu
    [Setup]    Run Keywords
    ...    Suite Setup Update GNB    force_reboot=${force_reboot}    log=${False}    scf_file=${SCF_8311_CB301}    iphy_file=${IPHY_6CELL}
    ...    swconfig_param=${rd_flag}
    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...    AND    Common Test Setup 2
    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_E_IWK1001.xml
    Delta Commission With SCF File    ${json_file}
    Reboot TL And Check Configured
    Suite Setup Start WTS And Check OnAir    log=${False}
    Attach UE    4
    Send A1 report And Do Traffic For E_IWK1001    4
    Syslog Check for E_IWK1001

CB008311_ET_E_IWK1201_4CC_FFTT_IntraFreqScellSwap_Online_modification_Scell_Release_parameters
    [Documentation]
    ...   Precondition:
    ...                 scellActivationMethod = bufferBased
    ...                 scellAdditionMethod = 1 (covBasedA1)
    ...                 actSCellReleaseForInactiveSCell = disabled
    ...                 scellInactivityReleaseTimer = 20 For the Pcell, 10 For the Scell
    ...                 scellDeactivationTimerGNB = ms1280
    ...                 actBufferBasedSCellAddition = oneShot_Dl_Fr1
    ...                 actConnectedModeMobilityCA = true   //mixed CA CB008015 activated
    ...                 maxNumSCellsDlFr1 = 3   //CB008533 4CC CA
    ...                 carrierAggregationSupportList = 600 (ca_Fdd_Any_Sa)
    ...         Feature 5GC002200 and Beamforming open
    ...         A6 For SCellSwap
    ...   Test Steps:
    ...                 Step1: UE attach
    ...                 Step2: Send A1 report for Scell addition
    ...                 Step3: Start enough DL traffic to activate Scell
    ...                 Step4: Online change the NRBTS.actSCellReleaseForInactiveSCell to "timer_based_Fr1"
    ...                 Step5: SCell Swap occurs for one SCell(cell1-cell2)
    ...                 Step6: Decrease DL non-GBR data rate to low rate, wait the scellInactivityReleaseTimer expires and scell release
    ...   Check point:
    ...                 1.Scell activate, DL Non-GBR data transfer on Both PCell and SCell with enough DL traffic
    ...                 2.Scell swap completed, 4CC CA with 1 new Scell and 2 "old" Scells
    ...                 3.Decrease DL non-GBR data rate , new Scell released, old Scells remain deactivated
    ...   rd parameter: 0x58057a = 4   #   rdFeatureFlagBitmapLevel=DEBUG
    ...                 0x58057d = 2151677952   #   rdFeatureFlagBitmap2=22INTERBAND_CA.ACT_DEACT(6137)
    ...                                                                  31CA.ACT_DEACT(8311)
    [Tags]    caseE_IWK1201    Manual_Fangping    TA_Krihu
    [Setup]    Run Keywords
    ...    Suite Setup Update GNB    force_reboot=${force_reboot}    log=${False}    scf_file=${SCF_8311_CB301}    iphy_file=${IPHY_6CELL}
    ...    swconfig_param=${rd_flag}
    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...    AND    Common Test Setup 2
    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_E_IWK1201.xml
    Delta Commission With SCF File    ${json_file}
    Reboot TL And Check Configured
    Suite Setup Start WTS And Check OnAir    log=${False}
    Attach UE    5
    Send A1 report And Do Traffic For E_IWK1201    5
    Online Change actSCellReleaseForInactiveSCell to timer_based_Fr1
    Send A6 report For SCell Swap    5
    Decrease DL Traffic To Deactivate Scell For E_IWK1201    5    1
    Syslog Check for E_IWK1201

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
    [Arguments]    ${UE_ID}
    ute_wtssim.Execute Egate Command    cmd=ue_measurement_send_nr id\=${UE_ID} meas_id=1 event=A1 srsrp_nr=95
    Sleep    2s

Send Measurement Report To Trigger Scell Deacitve
    [Arguments]    ${UE_ID}
    ute_wtssim.Execute Egate Command    cmd=ue_measurement_send_nr id\=${UE_ID} meas_id=1 event=A1 srsrp_nr=75
    Sleep    2s

Start DL Traffic To Activate Scell
    [Arguments]    ${UE_ID}    ${activate_times}    ${trf_id_num}    ${Scell_num}
    FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id\=${index} mbps=175 dir=dl
    END
    Sleep   10s    reason=Wait scell activate successfully ...
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
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
    Check Egate Log With Message     ${egate_console_file}    SCellIndex 1 deactivated successfully at airphone    ${deactivate_times}
    Run keyword if    "${Scell_num}">"1"     Check Egate Log With Message     ${egate_console_file}
    ...    SCellIndex 2 deactivated successfully at airphone    ${deactivate_times}
    Run keyword if    "${Scell_num}">"2"     Check Egate Log With Message     ${egate_console_file}
    ...    SCellIndex 3 deactivated successfully at airphone    ${deactivate_times}

Check egate_console log Message
    [Arguments]    ${A2A_ini}
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    A2A_Check_RRC_Log    ${CURDIR}/A2A/rrcReconfiguration/${A2A_ini}    ${TEST_LOG_DIRECTORY}/egate_console.log    log_path=${TEST_LOG_DIRECTORY}

Send A1 report And Do Traffic For E_IWK1001
    [Arguments]    ${UE_ID}
    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
    Send Measurement Report To Trigger Scell Active    ${UE_ID}
    Run Keyword And Continue On Failure    Start DL Traffic To Activate Scell    4    1    1    1
    Sleep    10s    reason=Wait ttraffic stab1e...
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_add.ini
    Run Keyword And Continue On Failure    Check Traffic On Pcell and Scell    4    1
    Run Keyword And Continue On Failure    Decrease DL Traffic To Deactivate Scell    4    0    1
    Sleep    40s    Wait for Scell Release...
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_delete_2CC.ini
    ute_syslog.Wait For Message In Syslog File    regexp=Dl timer expiry    timeout=120    alias=${GNB_SYSLOG.alias}
    ute_syslog.Collect From Savepoint    savepoint=${savepoint}
    ...    destination_file=${TEST_LOG_DIRECTORY}/syslog_E_IWK1001.txt    alias=${GNB_SYSLOG.alias}
    Run Keyword And Continue On Failure    Check Traffic On Pcell    4    1

Syslog Check for E_IWK1001
    ${content}=    Get File    ${TEST_LOG_DIRECTORY}/syslog_E_IWK1001.txt
    Run Keyword And Continue On Failure    Should Contain    ${content}    add Ue
    Run Keyword And Continue On Failure    Should Contain    ${content}    delete Ue
    Run Keyword And Continue On Failure    Should Contain    ${content}    A1ScellAdd
    Run Keyword And Continue On Failure    Should Contain    ${content}    nonUlCaToUlCa
    Run Keyword And Continue On Failure    Should Contain    ${content}    Received BufferMonitoringNotification
    Run Keyword And Continue On Failure    Should Contain    ${content}    sCellInactivityReleaseTimer(40)
    Run Keyword And Continue On Failure    Should Contain    ${content}    Start timer L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER
    Run Keyword And Continue On Failure    Should Contain    ${content}    Stop timer L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER
    Run Keyword And Continue On Failure    Should Contain    ${content}    Dl timer expiry
    Run Keyword And Continue On Failure    Should Contain    ${content}    sCellNrCellIdentity:16387,inactiveReason:inactivity_timer

Send A1 report And Do Traffic For E_IWK1201
    [Arguments]    ${UE_ID}
    Send Measurement Report To Trigger Scell Active    ${UE_ID}
    Run Keyword And Continue On Failure    Start DL Traffic To Activate Scell    5    1    6    3
    Sleep    10s    reason=Wait ttraffic stab1e...
    Run Keyword And Continue On Failure    Check egate_console log Message   rrc_scell_add_4CC.ini
    Run Keyword And Continue On Failure    Check Traffic On Pcell and Scell    5    3

Online Change actSCellReleaseForInactiveSCell to timer_based_Fr1
    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_E_IWK1201_online.xml
    Delta Commission With SCF File    ${json_file}
    Sleep    30s

Send A6 report For SCell Swap
    [Arguments]    ${UE_ID}
    Run Keyword And Continue On Failure    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=${UE_ID} meas_id=4 event=A6 scell=1 scell_rsrp=73 phycell_id=51 nrsrp_nr=80
    ...    pass_regexp=SCellIndex 4 activated successfully at airphone     timeout=60s

Decrease DL Traffic To Deactivate Scell For E_IWK1201
    [Arguments]    ${UE_ID}    ${deactivate_times}
    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
    Sleep    2s
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu=1 qfi=1 dir=dl
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=1 mbps=20 dir=dl
    Sleep   5s    reason=Wait scell deactivate successfully ...
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
    Check Egate Log With Message     ${egate_console_file}    SCellIndex 2 deactivated successfully at airphone    ${deactivate_times}
    Check Egate Log With Message     ${egate_console_file}    SCellIndex 3 deactivated successfully at airphone    ${deactivate_times}
    Check Egate Log With Message     ${egate_console_file}    SCellIndex 4 deactivated successfully at airphone    ${deactivate_times}
    Sleep    20s    Wait scellInactivityReleaseTimer expires, Scell Release...
    ute_syslog.Collect From Savepoint    savepoint=${savepoint}
    ...    destination_file=${TEST_LOG_DIRECTORY}/syslog_E_IWK1201.txt    alias=${GNB_SYSLOG.alias}
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_delete_E_IWK1201.ini

Syslog Check for E_IWK1201
    ${content}=    Get File    ${TEST_LOG_DIRECTORY}/syslog_E_IWK1201.txt
    Run Keyword And Continue On Failure    Should Contain    ${content}    Start timer L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER
    Run Keyword And Continue On Failure    Should Contain    ${content}    Dl timer expiry
    Run Keyword And Continue On Failure    Should Contain    ${content}    sCellNrCellIdentity:16386,inactiveReason:inactivity_timer
    Run Keyword And Continue On Failure    Should not Contain    ${content}    sCellNrCellIdentity:16387,inactiveReason:inactivity_timer
    Run Keyword And Continue On Failure    Should not Contain    ${content}    sCellNrCellIdentity:16390,inactiveReason:inactivity_timer
