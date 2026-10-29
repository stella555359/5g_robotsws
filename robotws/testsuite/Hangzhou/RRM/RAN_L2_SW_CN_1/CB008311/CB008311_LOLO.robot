*** Settings ***
Resource    ./../CUDU_L2/common_setup_teardown.robot
Force Tags    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
Documentation
    ...    testline config1(LOLO/FF_TTFF):
    ...    lcrId/cellTechnology/Band/physCellId/NR cell ID/chBw/GNB
    ...    cell1    TDD    n77     50    32769    100MHz    GNB2
    ...    cell2    TDD    n77     51    32770    100MHz    GNB2
    ...    cell11   FDD    n3      60    16395    15MHz     GNB1
    ...    cell12   FDD    n3      61    16396    15MHz     GNB1
    ...    cell13   FDD    n3      62    32781    10MHz     GNB2
    ...    cell14   FDD    n28     63    32782    15MHz     GNB2
    ...    ue1_TF:cell_1(cell_11), ue2_FTTF:cell_11(cell_1,cell_2,cell_14), ue3_FTT:cell_12(cell_1,cell_2)
    ...    testline config2(LOLO/FF_TTFF_40M):
    ...    lcrId/cellTechnology/Band/physCellId/NR cell ID/chBw/GNB
    ...    cell1    TDD    n77     50    32769    40MHz    GNB2
    ...    cell2    TDD    n77     51    32770    40MHz    GNB2
    ...    cell11   FDD    n3      60    16395    15MHz     GNB1
    ...    cell12   FDD    n3      61    16396    15MHz     GNB1
    ...    cell13   FDD    n3      62    32781    10MHz     GNB2
    ...    cell14   FDD    n28     63    32782    15MHz     GNB2
    ...    ue1_TF:cell_1(cell_11), ue2_FTTF:cell_11(cell_1,cell_2,cell_14), ue3_FTT:cell_12(cell_1,cell_2)

*** Variables ***
${LOCAL_WTS_DIR}     ${CURDIR}/config/LOLO/FF_TTFF_40M
${SCF_PATH}          ${CURDIR}/config/LOLO/FF_TTFF_40M
${SCF_8311_IWK101_1}    ${SCF_PATH}/SCF_1.xml
${SCF_8311_IWK101_2}    ${SCF_PATH}/SCF_2.xml
${IPHY_2CELL}        ${SCF_PATH}/iphy.xml
${WTS_CFG_1}           wts.cfg
@{LOG_NAME_LIST}     btslog    egatelog
${force_reboot}      ${True}
${rd_flag}           0x58057a = 4;0x58057d = 2151677952

*** Test Cases ***

CB008311_ET_E_IWK101_2CC_TF_SA_InterGnbCA_Verify_Buffer_based_one_shot_Scell_addition_with_blind
    [Documentation]
    ...    CB8311 para:
    ...                 scellActivationMethod = bufferBased
    ...                 scellAdditionMethod = blind
    ...                 actSCellReleaseForInactiveSCell = timer_based_Fr1
    ...                 scellInactivityReleaseTimer = 10 seconds
    ...                 scellDeactivationTimerGNB = ms1280
    ...                 actBufferBasedSCellAddition = oneShot_Dl_Fr1
    ...    CB008140 para:
    ...                 actInterNumerologyCa = true
    ...                 actInterGnbCa = true
    ...                 actK1OptForDPA =true
    ...                 add mo: MNL/MNLENT/XPAP,MNL/MNLENT/XPAP/XPIF,MNL/MNLENT/XPAP/XPIF/XPIFREMOTE
    ...   Test Steps:
    ...                 Step1: UE attach
    ...                 Step2: Start engough DL traffic to make scell activated.
    [Tags]    case101    TA_Mayue    Mannual_Mayue
    Import Testline Variables For 2 GNBs
    Create Suite Directory
    Backup And Update Iphy Swconfig File    ${IPHY_2CELL}
    log to console    Send scf to gnb2...
    Full Commission SCF File Through Mplane With Admin    ${SCF_8311_IWK101_2}    1    10.0.1.3
    log to console    Send scf to gnb1...
    Full Commission SCF File Through Mplane With Admin    ${SCF_8311_IWK101_1}    1    10.0.1.2
    Reboot TL And Check Configured For 2 GNBs
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG_1}
    Create Test Directory
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
    Suite Setup Start WTS And Check OnAir    log=${False}    gnb_num=2
    Sleep    60s    Wait for interGNB communication interface established stable
    Attach UE And Start Traffic For IWK101    1
    [Teardown]    Common Test Teardown 2

CB008311_ET_E_IWK202_4CC_FFTT_SA_InterGnbCA_Verify_Scell_release_due_to_UE_overheating
    [Documentation]
    ...    CB8311 para:
    ...                 scellActivationMethod = bufferBased
    ...                 scellAdditionMethod = blind
    ...                 actSCellReleaseForInactiveSCell = timer_based_Fr1
    ...                 scellInactivityReleaseTimer = 10 seconds
    ...                 scellDeactivationTimerGNB = ms1280
    ...                 actBufferBasedSCellAddition = oneShot_Dl_Fr1
    ...    CB008140 para:
    ...                 actInterNumerologyCa = true
    ...                 actInterGnbCa = true
    ...                 actK1OptForDPA =true
    ...                 add mo: MNL/MNLENT/XPAP,MNL/MNLENT/XPAP/XPIF,MNL/MNLENT/XPAP/XPIF/XPIFREMOTE
    ...   Test Steps:
    ...                 Step1: UE attach
    ...                 Step2: Start engough DL traffic to make scell activated.
    ...                 Step3: Send Overheating command to wait scell released.
    [Tags]    case202    TA_Mayue    Mannual_Anne
    Import Testline Variables For 2 GNBs
    Create Suite Directory
    Backup And Update Iphy Swconfig File    ${IPHY_2CELL}
    log to console    Send scf to gnb2...
    Full Commission SCF File Through Mplane With Admin    ${SCF_8311_IWK101_2}    1    10.0.1.3
    log to console    Send scf to gnb1...
    Full Commission SCF File Through Mplane With Admin    ${SCF_8311_IWK101_1}    1    10.0.1.2
    Reboot TL And Check Configured For 2 GNBs
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG_1}
    Create Test Directory
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
    Suite Setup Start WTS And Check OnAir    log=${False}    gnb_num=2
    Sleep    60s    Wait for interGNB communication interface established stable
    Run Keyword And Continue On Failure    Attach UE And Start Traffic For IWK202    2
    Sleep    60s    Wait for ue released, time for ue released is longer than intra GNB.
    Attach UE And Start Traffic For CB009854    2
    [Teardown]    Common Test Teardown 2

CB008311_ET_E_IWK401_3CC_FTT_SA_InterGnbCA_Verify_Scell_release_due_to_Bad_RLQ
    [Documentation]
    ...    CB8311 para:
    ...                 scellActivationMethod = bufferBased
    ...                 scellAdditionMethod = blind
    ...                 actSCellReleaseForInactiveSCell = timer_based_Fr1
    ...                 scellInactivityReleaseTimer = 10 seconds
    ...                 scellDeactivationTimerGNB = ms1280
    ...                 actBufferBasedSCellAddition = oneShot_Dl_Fr1
    ...    CB008140 para:
    ...                 actInterNumerologyCa = true
    ...                 actInterGnbCa = true
    ...                 actK1OptForDPA =true
    ...                 add mo: MNL/MNLENT/XPAP,MNL/MNLENT/XPAP/XPIF,MNL/MNLENT/XPAP/XPIF/XPIFREMOTE
    ...   Test Steps:
    ...                 Step1: UE attach
    ...                 Step2: Start engough DL traffic to make scell activated.
    ...                 Step3: Send Bad RLQ command to wait scell released.
    ...                 Step4: During blacklist time, scell can't be added.
    ...                 Step5: After blacklist time, scell can be added.
    [Tags]    case401    TA_Mayue    Mannual_Anne
    Import Testline Variables For 2 GNBs
    Create Suite Directory
    Backup And Update Iphy Swconfig File    ${IPHY_2CELL}
    log to console    Send scf to gnb2...
    Full Commission SCF File Through Mplane With Admin    ${SCF_8311_IWK101_2}    1    10.0.1.3
    log to console    Send scf to gnb1...
    Full Commission SCF File Through Mplane With Admin    ${SCF_8311_IWK101_1}    1    10.0.1.2
    Reboot TL And Check Configured For 2 GNBs
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG_1}
    Create Test Directory
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
    Suite Setup Start WTS And Check OnAir    log=${False}    gnb_num=2
    Sleep    60s    Wait for interGNB communication interface established stable
    Attach UE And Start Traffic For IWK401    3
    [Teardown]    Common Test Teardown 2

*** Keywords ***
Send A1 report And Do Traffic For E_IWK1001
    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
    Send Measurement Report To Trigger Scell Active    4
    Run Keyword And Continue On Failure    Start DL Traffic To Activate Scell    4    1    1    1
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_add.ini
    Run Keyword And Continue On Failure    Decrease DL Traffic To Deactivate Scell    4    0    1
    Sleep    40s    Wait for Scell Release...
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_delete_2CC.ini
    ute_syslog.Collect From Savepoint    savepoint=${savepoint}
    ...    destination_file=${TEST_LOG_DIRECTORY}/syslog_IWK1001.txt    alias=${GNB_SYSLOG.alias}

Syslog Check for E_IWK1001
    ${content}=    Get File    ${TEST_LOG_DIRECTORY}/syslog_IWK1001.txt
    Run Keyword And Continue On Failure    Should Contain    ${content}    A1ScellAdd
    Run Keyword And Continue On Failure    Should Contain    ${content}    Received BufferMonitoringNotification
    Run Keyword And Continue On Failure    Should Contain    ${content}    sCellInactivityReleaseTimer(40)
    Run Keyword And Continue On Failure    Should Contain    ${content}    Start timer L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER
    Run Keyword And Continue On Failure    Should Contain    ${content}    Stop timer L2PS_CA_SCELL_INACTIVITY_RELEASE_TIMER
    Run Keyword And Continue On Failure    Should Contain    ${content}    Dl timer expiry
    Run Keyword And Continue On Failure    Should Contain    ${content}    sCellNrCellIdentity:16387,inactiveReason:inactivity_timer

Attach UE
    [Arguments]    ${UE_ID}
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}

Send Measurement Report To Trigger Scell Active
    [Arguments]    ${UE_ID}
    ute_wtssim.Execute Egate Command    cmd=ue_measurement_send_nr id\=${UE_ID} meas_id=1 event=A1 srsrp_nr=95    sleep_time=2
    #Sleep    2s

Send Measurement Report To Trigger Scell Deacitve
    [Arguments]    ${UE_ID}
    ute_wtssim.Execute Egate Command    cmd=ue_measurement_send_nr id\=${UE_ID} meas_id=1 event=A1 srsrp_nr=75
    Sleep    2s

Decrease DL Traffic To Deactivate Scell
    [Arguments]    ${UE_ID}    ${deactivate_times}    ${trf_id_num}
    FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu=1 qfi=1 dir=dl trf_id\=${index}
    END
    Sleep   5s    reason=Wait scell deactivate successfully ...
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
    Check Egate Log With Message     ${egate_console_file}    SCellIndex 1 deactivated successfully at airphone    ${deactivate_times}

Check egate_console log Message
    [Arguments]    ${A2A_ini}
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    A2A_Check_RRC_Log    ${CURDIR}/A2A/rrcReconfiguration/${A2A_ini}    ${TEST_LOG_DIRECTORY}/egate_console.log    log_path=${TEST_LOG_DIRECTORY}

Attach UE And Start Traffic For IWK101
    [Arguments]    ${UE_ID}
    [Documentation]
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=95
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=75
    ...    syslog:add Ue,delete Ue
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    Run Keyword And Continue On Failure    Start DL Traffic To Activate Scell    ${UE_ID}    1    4    1
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_add.ini
    [Teardown]    SA 5G Detach    ${UE_ID}

Attach UE And Start Traffic For IWK202
    [Arguments]    ${UE_ID}
    [Documentation]
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=95
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=75
    ...    syslog:add Ue,delete Ue
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    Run Keyword And Continue On Failure    Start DL Traffic To Activate Scell    ${UE_ID}    1    2    3
    Trigger OverHeating    ${UE_ID}
    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    1
    [Teardown]    SA 5G Detach    ${UE_ID}

Attach UE And Start Traffic For IWK401
    [Arguments]    ${UE_ID}
    [Documentation]
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=95
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=75
    ...    syslog:add Ue,delete Ue
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    Start DL Traffic To Activate Scell    ${UE_ID}    1    2    2
    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    3

    Run Keyword And Continue On Failure    Add Bad RLQ to Release Scell    ${UE_ID}
    Run Keyword And Continue On Failure    Remove Bad RLQ    ${UE_ID}
    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    2
    Decrease DL Traffic To Deactivate Scell    ${UE_ID}    1    2
    Sleep    30s    Wait for Scell release...
    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    1
    Sleep    40s    Wait for scell blacklist timeout...
    Start DL Traffic To Activate Scell    ${UE_ID}    1    2    2
    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    3
    [Teardown]    SA 5G Detach    ${UE_ID}

Attach UE And Start Traffic For CB009854
    [Arguments]    ${UE_ID}
    [Documentation]
    ...    cover for CB009854-ET-C003_Inter_gNB_CA_SCell_addition_for_one_SA_connection_with_4_candidate_Scells
    ...    Precondition:
    ...    Test Steps:
    ...    1. UE attach to FDD cell as Pcell.
    ...    2. UE report A1 to trigger scell additon
    ...    4. start big data on DL and UL
    ...    5. stop ul and DL  data
    ...    6. start DL and UL data again.
    ...    7. Call release
    ...    Check Points:
    ...    1. Verify Scell addditon successfully.
    ...    2. Scell addition successfully.
    ...    3.Data transfer on pcell and scell correctly for each.
    ...    4.Verfiy UCI bit (7bit for CQI and 15 bit for beam) correct on FDD pcell
    ...    5.After step5 , CSI Report on PUCCH
    ...    6. After step6, Data transfer successfully again. Verify no NACK and DTX found.
    ...    7.Call release.
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    Start DL Traffic To Activate Scell    ${UE_ID}    1    2    3
    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    4
    Capture BIP Log By Admin Method    1s    bip
    Check UCI Bit On FDD Pcell
    [Teardown]    SA 5G Detach    ${UE_ID}

Check UCI Bit On FDD Pcell
    Log    pass

Start DL Traffic To Activate Scell
    [Arguments]    ${UE_ID}    ${activate_times}    ${trf_id_num}    ${Scell_num}
    FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id\=${index} mbps=175 dir=dl
    END
    Sleep   5s    reason=Wait scell activate successfully ...
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellAct.log
    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-scellAct.log
    Check Egate Log With Message     ${egate_console_file}    SCellIndex 1 activated successfully at airphone    ${activate_times}
    Run keyword if    "${Scell_num}">"1"     Check Egate Log With Message     ${egate_console_file}
    ...    SCellIndex 2 activated successfully at airphone    ${activate_times}
    Run keyword if    "${Scell_num}">"2"     Check Egate Log With Message     ${egate_console_file}
    ...    SCellIndex 3 activated successfully at airphone    ${activate_times}
    ${pscell_scell_sum}=    Evaluate    ${Scell_num}+1
    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    ${pscell_scell_sum}

Trigger OverHeating
    [Arguments]    ${UE_ID}
    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
    Sleep    2s
    Run Keyword And Continue On Failure    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_assistance_send_nr ue_id\=${UE_ID} forOverheating=yes reducedCCsDL=0
    ...    pass_regexp=SCellIndex 1 deactivated successfully    timeout=60s
    Sleep    40s
    Run Keyword And Continue On Failure    Check Traffic On Pcell    ${UE_ID}    1
    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_delete_2CC.ini
    Run Keyword And Continue On Failure    Check egate_console log Message    C_B402.ini
    ute_syslog.Collect From Savepoint    savepoint=${savepoint}
    ...    destination_file=${TEST_LOG_DIRECTORY}/syslog_C_B402_2.txt    alias=${GNB_SYSLOG.alias}

Check Traffic On Pcell
    [Arguments]    ${UE_ID}    ${Scell_num}    ${dl_tp_threshold}=10
    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    Run Keyword And Continue On Failure    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
    FOR    ${index}    IN RANGE    1    ${Scell_num}+1
        ${scell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=1
        Run Keyword And Continue On Failure    Should Be True    "${scell_dl_tp}"=="0"
    END

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

#Common Test Teardown 2
#    [Arguments]    ${snapshot}=${False}    ${egate}=${True}
#    Stop And Collect Syslog    ${TEST_LOG_DIRECTORY}
#    Run Keyword And Ignore Error    Save Egate Log    log_path=${TEST_LOG_DIRECTORY}
#    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ram/node_CPRT00/tmp/startup_cp_rt.log* ${TEST_LOG_DIRECTORY}
#    OperatingSystem.Run    cp -r ${OUTPUT_DIR}/bip_attach/ ${TEST_LOG_DIRECTORY}
#    Get Current Testline Config Files    log_path=${TEST_LOG_DIRECTORY}/myconfigs/
#    Run Keyword If Test Failed    Collect GNB SnapShot Via AaShell    log_dir=${TEST_LOG_DIRECTORY}
#    Run Keyword If Test Failed    Collect UTE SosReport    log_dir=${TEST_LOG_DIRECTORY}
#    Run Keyword If    "${egate}"=="${True}"    Clean Edaemon And Egate
#    Run Keyword And Ignore Error    Filter ERR WRN Message From Syslog By Log Path    ${TEST_LOG_DIRECTORY}
#    ...    ${CURDIR}/filter_msg.txt    ${TEST_LOG_DIRECTORY}/case_fatal_log.txt
#    Auto_Analyze_Error    ${TEST_LOG_DIRECTORY}/case_fatal_log.txt
