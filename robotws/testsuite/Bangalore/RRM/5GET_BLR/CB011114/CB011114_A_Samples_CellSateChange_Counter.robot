*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    OPTION_RELATED_ARTIFACTS_5G   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G    5G_RAN     SBTS00   SBTS24R2    CONFIGURED

Resource         ./resources/CB011114_common_resources.robot


#Suite Setup         Run Keywords    Prepare TL with all config files
Suite Setup         Run Keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with CB011114_Enable_PmInterval.json
...                 AND     Perform SCF Delta Commissioning with Create_PMMNL.json
#...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Gnb.Perform gNB reboot
...                 AND     Sleep       500s      reason=wait for RMOD to comeup
...                 AND     WTS_Runner_Keywords.Start WTS Using WTS_Runner      ${wts_cfg_file}


Suite Teardown      Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot

Documentation
...
...  AUTHOR          :  Ragunath Seenan
...  MAINTAINER      :  ragunath.seenan@nokia.com
...  INTRODUCTION    :  This test scenario describes on-line feature activation and deactivation by following NIDD
...                     actMicroDtx= True
...                     disableSchedAssistRfCooling= True/False
...                     allowGBRMutingForRfCooling= On/Off
...                     Verifies below counters
...                     M55601C00016    No of samples when the NR cell is in RF cooling mode0
...                     M55601C00017    No of NR cell state changes to RF cooling mode0
...                     M55601C00018    No of samples when the NR cell is in RF cooling mode2
...                     M55601C00019    No of NR cell state changes to RF cooling mode2
...                     M55601C00020    No of samples when the NR cell is in RF cooling mode1
...                     M55601C00021    No of NR cell state changes to RF cooling mode1
...                     M55601C00022    No of samples when the NR cell is in RF cooling mode3
...                     M55601C00023    No of NR cell state changes to RF cooling mode3
...                     M40008C2        Time of radio unit in NORMAL temperature state
...                     M40008C3        Time of radio unit in INCREASED temperature state
...                     M40008C4        Time of radio unit in HIGH temperature state
...  TEST SET NAME   :  CB011114_A_Validate_NrCell_Samples_cellStateChange_Counters_At_Level1and3
...                     CB011114_A_Validate_NrRmod_rfTemperatureState_Samples_Counters
...  TESTING SPLIT   :  CB011114-A
...  CONTACTS        :  ragunath.seenan@nokia.com
...  REFERENCES      :  CFAM
...  REQUIREMENT ID  :

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
#${wts_cfg_file}     ${CURDIR}/config/wts/AHPCA_1CELL_WTS.cfg
${wts_cfg_file}         ${CURDIR}/config/wts/asoh_basic_setup.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${scell_idx}    0
#${iphy_xml}         ${CURDIR}/config/wts/Cell_Addition_AVQE_iphy.xml
${nwslice_ID}    1
${gw_ID}     1
${pdu_id}    1
${nw_id}     1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${ue_id}     1
${Pdu_session_ID}    1
${epc_log_path}     /tmp/
${iphy_xml}         ${CURDIR}/config/iphy.xml
${gscn_value}   1
${st_ue_id}      1
${en_ue_id}      1
${st_ue_id_2}      51
${en_ue_id_2}      51
${highMuting}         --db 3 set_temp_rating HIGH
${normalMuting}       --db 3 set_temp_rating NORMAL
${increasedMuting}    --db 3 set_temp_rating INCREASED
${highExp}            set_temp_rating HIGH successfully proceed
${normalExp}          set_temp_rating NORMAL successfully proceed
${increasedExp}       set_temp_rating INCREASED successfully proceed
${trigger_alarm}     --db 3 trigger_rf_fault 1936 module CRI
${cancel_alarm}     --db 3 cancel_rf_fault 1936 module
${TEST_NAME}     CB011114_Counters
#${SCFC}     ${CURDIR}/config/SBTS24R2/AHPCA_1CELL_SCF.xml
#${AP_XML}     ${CURDIR}/config/SBTS24R2/AHPCA_1CELL_IPHY.xml
${SCFC}         ${CURDIR}/config/SBTS24R3/multicell_ahfib.xml
${AP_XML}       ${CURDIR}/config/wts/iphy_ahfib_multicell.xml

${TEST_NAME_2}     CB011114_MultiCell
${startMutingParam}    --db 3 set_temp_rating HIGH
${noMutingParam}       --db 3 set_temp_rating INCREASED
${stopMutingParam}     --db 3 set_temp_rating NORMAL



*** Test Cases ***
[1][1.0] CB011114_A_Validate_NrCell_Samples_cellStateChange_Counters_At_Level1and3
    Set test variable     ${LOG_PATH}
#    Perform SCF Delta Commissioning with CB011114_Activation.json
#    Configure ETH And Load CFG      ${wts_cfg_file}
    Sleep    30s
    Wait until the next Measurement Period starts
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${increasedMuting}    ${increasedExp}
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${increasedMuting}    ${increasedExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Wait until the current Measurement Period stops
    ${pm_files1}     Collect RD Counters

    Validate NR CELL RF COOL MODE0 SAMPLES     ${pm_files1}
    Validate NR CELL RF COOL MODE0 STATE CHANGE     ${pm_files1}
    Validate NR CELL RF COOL MODE1 SAMPLES     ${pm_files1}
    Validate NR CELL RF COOL MODE1 STATE CHANGE     ${pm_files1}
    Validate NR CELL RF COOL MODE2 SAMPLES     ${pm_files1}
    Validate NR CELL RF COOL MODE2 STATE CHANGE     ${pm_files1}
    Validate NR CELL RF COOL MODE3 SAMPLES     ${pm_files1}
    Validate NR CELL RF COOL MODE3 STATE CHANGE     ${pm_files1}

    Validate NR RMOD RF TEMP NORMAL SAMPLES     ${pm_files1}
    Validate NR RMOD RF TEMP INCREASED SAMPLES     ${pm_files1}
    Validate NR RMOD RF TEMP HIGH SAMPLES     ${pm_files1}
    [Teardown]    Run keyword and Ignore Error      Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] CB011114_B_Validate_startSlotBlanking_For_highPrioritizedTraffic_VoNR_multiNR_Cells
    [Setup]   		Run keywords    Suite setup from scratch
	#...                 AND     Suite setup from scratch
	...					 AND		Perform SCF Delta Commissioning with VoNR_GBR.json
    ...					AND     Sleep   20s
	...                 AND     Add RadParam to swconfig     "0x580627=1"     "0x5901F5=8"    "0x590204=7"
	...                 "0x590205=9"     IP=192.168.255.129
	...                 AND     Gnb.Perform gNB reboot
	...                 AND     Sleep       500s      reason=wait for RMOD to comeup
	...                 AND     WTS_Runner_Keywords.Start WTS Using WTS_Runner      ${wts_cfg_file}

#	Perform SCF Delta Commissioning with VoNR_GBR.json
 #   Sleep   20s
    set test variable     ${LOG_PATH}
    log to console   UE attach trigerring now...

    start log     cprt    btslog
    MultiUE Register should be Successful     ${st_ue_id_2}    ${en_ue_id_2}    pdu_id=1    nw_id=1
    MultiUE PDU Modfication should be Successful     ${st_ue_id_2}    ${en_ue_id_2}    pdu_id=1   qosflows_to_add=2
    Sleep   2s
    MultiUE Trigger DL Traffic for SA    ${st_ue_id_2}    ${en_ue_id_2}    Traffic_rate=mbps     dl_rate=140
    ...                                  pdu_id=1    trf_id=1       qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${st_ue_id_2}    ${en_ue_id_2}    Traffic_rate=mbps     ul_rate=30
    ...                                  pdu_id=1    trf_id=1       qfi_id=2
    MultiUE PDU Modfication should be Successful     ${st_ue_id_2}    ${en_ue_id_2}      pdu_id=1      qosflows_to_add=3
    Trigger MultiUE VoNR DL Traffic with multiple trfids    ${st_ue_id_2}    ${en_ue_id_2}    pdu_id=1     num_trf_id=3
    ...                                   qfi_id=3    rtp_codec=custom
    ${scene1}    Stop log      cprt     btslog      test_scenario=UE_Attach
    sleep       3s

#    start log     btslog     cprt
#    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-3       update      disableSchedAssistRfCooling        false
#    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-3       update      allowGBRMutingForRfCooling     On
#    ${scene2}    Stop log      cprt     btslog     test_scenario=Feature_Activation
#    sleep       3s

    start log     cprt      btslog     ttitrace
    Start Slot Muting    ${startMutingParam}
    sleep   5s
    ${scene3}    Stop log     ttitrace    cprt    btslog     test_scenario=Level1_HIGH_Slot_muting
    sleep       3s

    start log     cprt     btslog     ttitrace
    Start Slot Muting    ${startMutingParam}
    sleep   5s
    ${scene4}    Stop log     ttitrace    cprt    btslog     test_scenario=Level2_HIGH_Slot_muting


    sleep       3s

    start log     cprt     btslog     ttitrace
    Start Slot Muting    ${startMutingParam}
    sleep   5s
    ${scene5}    Stop log     ttitrace    cprt    btslog    test_scenario=Level3_HIGH_Slot_muting
    sleep       3s

    Stop Slot Muting    ${stopMutingParam}
    Stop Slot Muting    ${stopMutingParam}
    Stop Slot Muting    ${stopMutingParam}
    start log     cprt     btslog     ttitrace
    sleep   5s
    ${scene6}   Stop log    ttitrace    cprt    btslog    test_scenario=Level0_Normal_Slot_muting
    sleep   3s
#
#    Validate DL Traffic For MultiUE for SA    ${st_ue_id_2}    ${en_ue_id_2}     dl_rate=140     pdu_id=1     qfi_id=1
#    Validate UL Traffic For MultiUE for SA    ${st_ue_id_2}    ${en_ue_id_2}     ul_rate=30     pdu_id=1     qfi_id=1
    MultiUE Deregister should be Successful      ${st_ue_id_2}    ${en_ue_id_2}

    Decode TTI Trace    Level1_HIGH_Slot_muting
    Decode TTI Trace    Level2_HIGH_Slot_muting
    Decode TTI Trace    Level3_HIGH_Slot_muting
    Decode TTI Trace    Level0_Normal_Slot_muting

    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${scene3}[ttitrace]/output_dl_formated.csv
    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${scene4}[ttitrace]/output_dl_formated.csv
    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${scene5}[ttitrace]/output_dl_formated.csv
    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${scene6}[ttitrace]/output_dl_formated.csv
    Verify targetMutingRatio for blankedSlots in ttitrace     ${scene3}[ttitrace]/output_dl_formated.csv     24
    Verify targetMutingRatio for blankedSlots in ttitrace     ${scene4}[ttitrace]/output_dl_formated.csv     43
    Verify targetMutingRatio for blankedSlots in ttitrace     ${scene5}[ttitrace]/output_dl_formated.csv     59
    [Teardown]    Run keyword and Ignore Error      Link SCOUT SCF to Configuration ID for Reporting






















