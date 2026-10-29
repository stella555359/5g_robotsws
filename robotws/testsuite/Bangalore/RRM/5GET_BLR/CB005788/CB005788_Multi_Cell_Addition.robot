*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CONFIGS_Bangalore/RRM/ET/CB005788/CB005788_AVQE.yml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00   SBTS23R4    CONFIGURED

Resource         ./resources/CB005788_common_resources.robot


Suite Setup         Run Keywords     Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${iphy_xml}    AVQE
...                 AND     Perform SCF Delta Commissioning with TC09_One_RU_one_cell.json
...                 AND     Add RadParam to swconfig     "0x580627=1"     "0x5901F5=7"     IP=192.168.255.129
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Configure ETH And Load CFG      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
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
...  TEST SET NAME   :  CB005788_A_Validate_Addition_of_Cell_to_hotRFU
...                     CB005788_B_Validate_startSlotBlanking_For_highPrioritizedTraffic_VoNR_multiNR_Cells
...                     CB005788_B_Validate_startSlotBlanking_rdDeltatgtMutingRatio_For_nonVoNR_multiNR_Cells
...  TESTING SPLIT   :  CB005788-A
...  CONTACTS        :  ragunath.seenan@nokia.com
...  REFERENCES      :  CFAM
...  REQUIREMENT ID  :  5G_RAN_USR_RRM_19915,5G_RAN_USR_RRM_19821,5G_RAN_USR_RRM_19717,5G_RAN_USR_RRM_19718

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_file}     ${CURDIR}/config/wts/Cell_Additon.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${epc_log_path}    /tmp/
${scell_idx}    0
${ul_ue_ip}    72.23.0.1
${dl_ue_ip}    1.2.4.2
${dl_port}    7073
${ul_port}    7074
${duration}    -t 3600
${bytes}    -n 8000000
${ping_unit}    Kbps
${iperf_unit}    Mbps
${exp_dl_avg_ping}    1.4
${exp_ul_avg_ping}    2.8
${exp_dl_avg_iperf}    450
${exp_ul_avg_iperf}    220
${startMutingParam}    --db 1 set_temp_rating HIGH
${stopMutingParam}    --db 1 set_temp_rating NORMAL
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
#${st_ue_id}      1
#${en_ue_id}      2


*** Test Cases ***
[1]CB005788_B_Validate_startSlotBlanking_For_highPrioritizedTraffic_VoNR_multiNR_Cells
    set test variable     ${LOG_PATH}

    Log to console   UE attach trigerring now...
#   Single Cell Setup
    Start Log     cprt
    MultiUE Register should be Successful      1    1    pdu_id=1    nw_id=1
    MultiUE Trigger DL Traffic for SA      1     1    mbps   130   pdu_id=1    trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA      1     1    mbps   20   pdu_id=1    trf_id=1    qfi_id=1
    Sleep     3s
    ${path1}    Stop Log      cprt      test_scenario=cellsetup_data

#   Feature Activation
    Start Log     cprt
    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-1       update      disableSchedAssistRfCooling      false
    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-1       update      allowGBRMutingForRfCooling     On
    ${path2}    Stop Log      cprt    test_scenario=activation

#   Single Cell Muting
    Start Log     cprt    sherpa    ttitrace
    Start Slot Muting    ${startMutingParam}
    Sleep     3s
    ${path3}    Stop Log     ttitrace     sherpa     cprt    test_scenario=1cell_slotmuting

#   Add Cell when RU Hot and run traffic
    Perform SCF Delta Commissioning with One_cell_Addition.json
    Sleep     180s
    MultiUE Register should be Successful      2    2    pdu_id=1    nw_id=1
    MultiUE Trigger DL Traffic for SA      2     2    mbps   130   pdu_id=1    trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA      2     2    mbps   20   pdu_id=1    trf_id=1    qfi_id=1
    Sleep     3s
    Stop Slot Muting    ${stopMutingParam}

#   Muting For Multi cell with rdDeltaMutingRatio
    Start Log     cprt     sherpa     ttitrace
    Start Slot Muting    ${startMutingParam}
    Sleep     3s
    ${path4}    Stop Log     ttitrace     sherpa    cprt    test_scenario=multicell_rdDelta
    Stop Slot Muting    ${stopMutingParam}

    MultiUE Deregister should be Successful      1    2

    Decode TTI Trace    1cell_slotmuting
    Decode TTI Trace    multicell_rdDelta

    Decode Sherpa pcap     1cell_slotmuting
    Decode Sherpa pcap     multicell_rdDelta

    Verify rfCooling rfUnitShare tgtMutingRatio in SlotBlankingReq     ${path3}[cprt]/NODECPRT_GNB.pcap    sctp    1     0     35
    Verify rfCooling rfUnitShare tgtMutingRatio in SlotBlankingReq     ${path4}[cprt]/NODECPRT_GNB.pcap    sctp    1     1     42
    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${path3}[ttitrace]/output_dl_formated.csv
    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${path4}[ttitrace]/output_dl_formated.csv
    Verify targetMutingRatio for blankedSlots in ttitrace     ${path3}[ttitrace]/output_dl_formated.csv     35
    Verify targetMutingRatio for blankedSlots in ttitrace     ${path4}[ttitrace]/output_dl_formated.csv     42

