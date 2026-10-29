*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    OPTION_RELATED_ARTIFACTS_5G   VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00   SBTS23R4    CONFIGURED

Resource         ./resources/CB010796_common_resources.robot

Suite Setup         Run Keywords    Prepare TL with all config files
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${iphy_xml}    AVQE
...                 AND     Perform SCF Delta Commissioning with OneCell_OneRU.json
...                 AND     Add RadParam to swconfig     "0x580627=1"     "0x5901F5=8"    "0x590204=7"    "0x590205=9"     IP=192.168.255.129
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Configure ETH And Load CFG      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
#...                 AND     Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot     sosreport

Documentation
...
...  AUTHOR          :  Ragunath Seenan
...  MAINTAINER      :  ragunath.seenan@nokia.com
...  INTRODUCTION    :  This test scenario describes on-line feature activation and behavior of
...                     Slot Blanking or Muting interworking with RFU connected with multiple NR cells.
...                     Verifies CSIRS and SSB slot are not muted from ttitrace
...                     Verifies TargetMutingRatio and SlotMutedforRFcooling for LASTUNUSED slots
...                     Verifies rdDeltaMutingRatio is added for Multicell and not for Singlecell
...  TEST SET NAME   :  CB010796_B_Validate_startSlotBlanking_For_highPrioritizedTraffic_VoNR_multiNR_Cells
...                     CB010796_B_Validate_SlotBlanking_with_rdDeltatgtMutingRatio_For_multiNR_Cells
...                     CB010796_B_Validate_SlotBlanking_with_rdDeltatgtMutingRatio1_For_multiNR_Cells
...                     CB010796_B_Validate_SlotBlanking_with_rdDeltatgtMutingRatio3_For_multiNR_Cells
...                     CB010796_A_Validate_Addition_of_Cell_to_Level3_HotRU
...  TESTING SPLIT   :  CB005788-B
...  CONTACTS        :  ragunath.seenan@nokia.com
...  REFERENCES      :  CFAM
...  REQUIREMENT ID  :  5G_RAN_USR_RRM_19915,5G_RAN_USR_RRM_19821,5G_RAN_USR_RRM_19717,5G_RAN_USR_RRM_19718

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_file}     ${CURDIR}/config/wts/basic_config_TDD_40MHz_VoNR_GBR.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${epc_log_path}    /tmp/
${scell_idx}    0
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
${iphy_xml}         ${CURDIR}/config/wts/Cell_Addition_AVQE_iphy.xml
${gscn_value}   1
${highMuting}         --db 1 set_temp_rating HIGH
${normalMuting}       --db 1 set_temp_rating NORMAL
${increasedMuting}    --db 1 set_temp_rating INCREASED
${highExp}            set_temp_rating HIGH successfully proceed
${normalExp}          set_temp_rating NORMAL successfully proceed
${increasedExp}       set_temp_rating INCREASED successfully proceed
${trigger_alarm}     --db 1 trigger_rf_fault 1936 module CRI
${cancel_alarm}     --db 1 cancel_rf_fault 1936 module
${TEST_NAME}     CB010796_MultiCell
${SCFC}     ${CURDIR}/config/SBTS24R1/AVQE_SCF.xml
${AP_XML}     ${CURDIR}/config/wts/AVQE_iphy.xml



*** Test Cases ***
[1][1.0] CB010796_B_Validate_startSlotBlanking_For_highPrioritizedTraffic_VoNR_multiNR_Cells
    Perform SCF Delta Commissioning with VoNR_GBR.json
    Sleep     10s
    set test variable     ${LOG_PATH}

    Log to console   UE attach trigerring now...
#   Single Cell Setup
    Start Log     cprt
    MultiUE Register should be Successful    1    1    pdu_id=1    nw_id=1
    Sleep    2s
    MultiUE PDU Modfication should be Successful    1    1    pdu_id=1    qosflows_to_add=2
    Sleep    2s
    MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=130     pdu_id=1    trf_id=1       qfi_id=2
    MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=20      pdu_id=1    trf_id=1       qfi_id=2
    MultiUE PDU Modfication should be Successful    1    1    pdu_id=1    qosflows_to_add=3
    Sleep    2s
    wtsrunner.trf_data_start     ue=1     pdu=1     qfi=3     dir=dl      trf_id=1      rtp_codec=custom
    wtsrunner.trf_data_start     ue=1     pdu=1     qfi=3     dir=ul      trf_id=1      rtp_codec=custom

    Sleep    3s
    ${path1}    Stop Log      cprt      test_scenario=cellsetup_data

#   Feature Activation
#    Start Log     cprt
#    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-1       update      disableSchedAssistRfCooling      false
#    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-1       update      allowGBRMutingForRfCooling     On
#    ${path2}    Stop Log      cprt    test_scenario=activation

#   Level1 Muting
    Start Log     cprt
    Slot Muting    ${highMuting}    ${highExp}
    Start Log     ttitrace
    Sleep     3s
    ${path3}    Stop Log     ttitrace      cprt    test_scenario=level1_slotmuting

#   Level2 Muting
    Start Log     cprt
    Slot Muting    ${highMuting}    ${highExp}
    Start Log     ttitrace
    Sleep     3s
    ${path4}    Stop Log     ttitrace     cprt    test_scenario=level2_slotmuting

#   Level3 Muting
    Start Log     cprt
    Slot Muting    ${highMuting}    ${highExp}
    Start Log     ttitrace
    Sleep     3s
    ${path5}    Stop Log     ttitrace     cprt    test_scenario=level3_slotmuting

#   Add Cell when RU Hot at Level3 and run traffic
    Perform SCF Delta Commissioning with OneCell_Addition.json
    Sleep     180s
    MultiUE Register should be Successful    2    2    pdu_id=1    nw_id=1
    Sleep    2s
    MultiUE PDU Modfication should be Successful    2    2    pdu_id=1    qosflows_to_add=2
    Sleep    2s
    MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=130     pdu_id=1    trf_id=2       qfi_id=2
    MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=20      pdu_id=1    trf_id=2       qfi_id=2
    MultiUE PDU Modfication should be Successful    2    2    pdu_id=1    qosflows_to_add=3
    Sleep    2s
    wtsrunner.trf_data_start     ue=2     pdu=1     qfi=3     dir=dl      trf_id=1      rtp_codec=custom
    wtsrunner.trf_data_start     ue=2     pdu=1     qfi=3     dir=ul      trf_id=1      rtp_codec=custom


#   Maxumum level Muting For Multi cell with 1936 Alarm
    Start Log     cprt     ttitrace
    Sleep     3s
    ${path6}    Stop Log     ttitrace     cprt    test_scenario=multicell_rdDelta
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${normalMuting}    ${normalExp}

#    MultiUE Deregister should be Successful      1    2

    Decode TTI Trace    level3_slotmuting
    Decode TTI Trace    multicell_rdDelta

#    Decode Sherpa pcap     level1_slotmuting

    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${path5}[ttitrace]/output_dl_formated.csv
    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${path6}[ttitrace]/output_dl_formated.csv
    Verify targetMutingRatio for blankedSlots in ttitrace     ${path5}[ttitrace]/output_dl_formated.csv     50
    Verify targetMutingRatio for blankedSlots in ttitrace     ${path6}[ttitrace]/output_dl_formated.csv     59
#    Verify SlotBlankingReq Event in sherpa     ${path3}[sherpa]/micro__l1l2Trace.csv
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
