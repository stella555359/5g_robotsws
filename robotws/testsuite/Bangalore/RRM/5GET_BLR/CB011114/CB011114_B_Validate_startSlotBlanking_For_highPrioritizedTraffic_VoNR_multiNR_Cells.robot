*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    OPTION_RELATED_ARTIFACTS_5G   SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00   CONFIGURED

Resource         ./resources/CB011114_common_resources.robot

#Suite Setup         Run Keywords    Prepare TL with all config files
Suite Setup         Run Keywords      Suite setup from scratch
#...                 AND     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Asoh_fdd_multicell.json
...                 AND     Prepare TL with IPHY file change
...                 AND     Add RadParam to swconfig     "0x580627=1"     "0x5901F5=8"    "0x590204=7"    "0x590205=9"     IP=192.168.255.129
...                 AND     Gnb.Perform gNB reboot
...                 AND     Sleep       500s      reason=wait for RMOD to comeup
...                 AND     WTS_Runner_Keywords.Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Kill WTS processes Using WTS_Runner
...                 AND     Stop Log     snapshot

Documentation
...
...  AUTHOR          :  Ragunath Seenan
...  MAINTAINER      :  ragunath.seenan@nokia.com
...  INTRODUCTION    :  This test scenario describes on-line feature activation and behavior of
...                     Slot Blanking or Muting interworking with RFU connected with multiple NR cells.
...                     Verifies CSIRS and SSB slot are not muted from ttitrace
...                     Verifies TargetMutingRatio and SlotMutedforRFcooling for LASTUNUSED slots
...                     Verifies rdDeltaMutingRatio is added for Multicell and not for Singlecell
...  TEST SET NAME   :  CB011114_B_Validate_startSlotBlanking_For_highPrioritizedTraffic_VoNR_multiNR_Cells
...                     CB011114_B_Validate_SlotBlanking_with_rdDeltatgtMutingRatio_For_multiNR_Cells
...                     CB011114_B_Validate_SlotBlanking_with_rdDeltatgtMutingRatio1_For_multiNR_Cells
...                     CB011114_B_Validate_SlotBlanking_with_rdDeltatgtMutingRatio3_For_multiNR_Cells
...  TESTING SPLIT   :  CB011114-B
...  CONTACTS        :  ragunath.seenan@nokia.com
...  REFERENCES      :  CFAM
...  REQUIREMENT ID  :  5G_RAN_USR_RRM_22656

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
#${wts_cfg_file}     ${CURDIR}/config/wts/MutliCell_basic_setup.cfg
${wts_cfg_file}         ${CURDIR}/config/wts/asoh_basic_setup.cfg
#${wts_cfg_file}         /opt/iphy/latest/basic_setup.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${scell_idx}    0
${epc_log_path}     /tmp/
#${iphy_xml}         ${CURDIR}/config/wts/Cell_Addition_AVQE_iphy.xml
${highMuting}         --db 3 set_temp_rating HIGH
${normalMuting}       --db 3 set_temp_rating NORMAL
${increasedMuting}    --db 3 set_temp_rating INCREASED
${highExp}            set_temp_rating HIGH successfully proceed
${normalExp}          set_temp_rating NORMAL successfully proceed
${increasedExp}       set_temp_rating INCREASED successfully proceed
${trigger_alarm}     --db 3 trigger_rf_fault 1936 module CRI
${cancel_alarm}     --db 3 cancel_rf_fault 1936 module
${TEST_NAME}     CB011114_MultiCell
#${SCFC}     ${CURDIR}/config/SBTS24R2/MultiCell_SCF.xml
#${AP_XML}     ${CURDIR}/config/wts/MultiCell_IPHY.xml
#${SCFC}         ${CURDIR}/config/SBTS24R3/multicell_ahfib.xml
#${AP_XML}       ${CURDIR}/config/wts/iphy_ahfib_multicell.xml
${AP_XML}           ${CURDIR}/config/wts/iphy_asoh_fdd_multicell.xml
${startMutingParam}    --db 3 set_temp_rating HIGH
${noMutingParam}       --db 3 set_temp_rating INCREASED
${stopMutingParam}     --db 3 set_temp_rating NORMAL
${nwslice_ID}    1
${gw_ID}     1
${pdu_id}    1
${nw_id}     1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${ue_id}     1
${Pdu_session_ID}    1
${iphy_xml}         ${CURDIR}/config/iphy.xml
${gscn_value}   1
${st_ue_id}      51
${en_ue_id}      51

*** Test Cases ***
[1][1.0] CB011114_B_Validate_startSlotBlanking_For_highPrioritizedTraffic_VoNR_multiNR_Cells
    Perform SCF Delta Commissioning with VoNR_GBR.json
    Sleep   20s
        set test variable     ${LOG_PATH}
    log to console   UE attach trigerring now...

    start log     cprt    btslog
    MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=1    nw_id=1
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=1   qosflows_to_add=2
    Sleep   2s
    MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=140     pdu_id=1    trf_id=1       qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     ul_rate=30      pdu_id=1    trf_id=1       qfi_id=2
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}      pdu_id=1      qosflows_to_add=3
    Trigger MultiUE VoNR DL Traffic with multiple trfids    ${st_ue_id}    ${en_ue_id}    pdu_id=1     num_trf_id=3    qfi_id=3    rtp_codec=custom
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
#    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=140     pdu_id=1     qfi_id=1
#    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=30     pdu_id=1     qfi_id=1
    MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}

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
