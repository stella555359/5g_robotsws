*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    OPTION_RELATED_ARTIFACTS_5G   SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00   CONFIGURED

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner

Resource         ./CB010414_CB010796_common_resources.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          OperatingSystem
Library          taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library          taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Resource         ../resources/robot/AIC_Common_Keywords.robot
Resource         ../resources/robot/Common_Keywords.robot


Suite Setup             Run keywords     Test Suite Setup
...                     AND              AIC Software Build Info
...                     AND              Fetch Taf Library used in TL
...                     AND   			 Update vDU TargetBDxml contents in AP_iphyxml      AVQL    ${iphy_xml}
...                     AND              AP Reboot Wait For Connection    ${720}
...                     AND              Fast Delta Commission vCU Using Delta XML File     ${delta_cu}
...                     AND              sleep    300s
...                     AND              Log to console    vDU delta commissioning
...                     AND              Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
...                     AND              sleep    600s
...                     AND              Run keyword and Ignore error   Verify RMODs Online Status   ${800}
...                     AND              log to console   loading cfg file
...                     AND              Configure UTE ETH3 IPs
...                     AND              Start WTS Using WTS_Runner      ${wts_cfg_file}



Suite Teardown         Run keywords        Kill WTS processes Using WTS_Runner

Documentation
...
...  AUTHOR          :  Prakhar Rastogi
...  MAINTAINER      :  prakhar.rastogi@nokia.com
...  INTRODUCTION    :  This test scenario describes feature activation and
...                     Verifies cellSetupReq, SlotBlankingReq and SlotBlankingResp and
...                     level1, level2, level3 slot mutting
...  TEST SET NAME   :  CB010796_A_Validate_rfCoolingMode_Activation_Deactivation_For_AVQL
...  TESTING SPLIT   :  CB010796_A

...  CONTACTS        :  prakhar.rastogi@nokia.com
...  REFERENCES      :  CFAM
...  REQUIREMENT ID  :  5G_RAN_USR_RRM_21656

*** Variables ***
${delta_vdu}        ${CURDIR}/config/SBTS24R3/vDU_Delta_configuration_scf_one_cell_AVQL.xml
${delta_cu}         ${CURDIR}/config/SBTS24R3/vCU_Delta_configuration_scf_one_cell_AVQL.xml
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_AVQL.cfg
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
${iphy_xml}         ${CURDIR}/config/wts/new_iphy_AVQL.xml
${gscn_value}   1
${highMuting}         --db 1 set_temp_rating HIGH
${normalMuting}       --db 1 set_temp_rating NORMAL
${increasedMuting}    --db 1 set_temp_rating INCREASED
${highExp}            set_temp_rating HIGH successfully proceed
${normalExp}          set_temp_rating NORMAL successfully proceed
${increasedExp}       set_temp_rating INCREASED successfully proceed
${trigger_alarm}     --db 1 trigger_rf_fault 1936 module CRI
${cancel_alarm}     --db 1 cancel_rf_fault 1936 module
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
${gscn_value}   1
${st_ue_id}      1
${en_ue_id}      2

*** Test Cases ***
[1][1.0] CB010796_A_Validate_Level0_SlotBlanking
    set test variable     ${LOG_PATH}
    log to console   UE attach trigerring now...
#    Start CPRT F1 Monitoring
    MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=1    nw_id=1
    MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=120     pdu_id=1    trf_id=1       qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     ul_rate=50      pdu_id=1    trf_id=1       qfi_id=1
    sleep       3s

#    Start CPRT F1 Monitoring

    Slot Muting    ${highMuting}    ${highExp}
    Run Keyword and continue on failure     Start L2Ps TTI logs from vDU    ${NR_cell1}
    sleep   10s
#    ${scene3}    Stop and Collect CPRT F1 Monitoring    test_scenario=Level1_HIGH_Slot_muting
    ${tti_1}     Stop L2Ps TTI logs from vDU    test_scenario=Level1_HIGH_Slot_muting
    sleep       120s

#    Start CPRT F1 Monitoring
    Slot Muting    ${highMuting}    ${highExp}
    Run Keyword and continue on failure     Start L2Ps TTI logs from vDU    ${NR_cell1}
    sleep   10s
#    ${scene4}    Stop and Collect CPRT F1 Monitoring    test_scenario=Level2_HIGH_Slot_muting
    ${tti_2}     Stop L2Ps TTI logs from vDU    test_scenario=Level2_HIGH_Slot_muting
    sleep       120s

#    Start CPRT F1 Monitoring
    Slot Muting    ${highMuting}    ${highExp}
    Run Keyword and continue on failure     Start L2Ps TTI logs from vDU    ${NR_cell1}
    sleep   10s
#    ${scene5}    Stop and Collect CPRT F1 Monitoring   test_scenario=Level3_HIGH_Slot_muting
    ${tti_3}     Stop L2Ps TTI logs from vDU    test_scenario=Level3_HIGH_Slot_muting
    sleep       120s

    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${normalMuting}    ${normalExp}

#    Start CPRT F1 Monitoring
    Run Keyword and continue on failure     Start L2Ps TTI logs from vDU    ${NR_cell1}
    sleep   10s
#    ${scene6}    Stop and Collect CPRT F1 Monitoring    test_scenario=Level0_HIGH_Slot_muting
    ${tti_4}     Stop L2Ps TTI logs from vDU    test_scenario=Level0_Normal_Slot_muting
    sleep   120s

#    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=140     pdu_id=1     qfi_id=1
#    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=30     pdu_id=1     qfi_id=1
    MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}

    Decode TTI Trace    Level1_HIGH_Slot_muting
    Decode TTI Trace    Level2_HIGH_Slot_muting
    Decode TTI Trace    Level3_HIGH_Slot_muting
    Decode TTI Trace    Level0_Normal_Slot_muting

    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${tti_1}[ttitrace]/output_dl_formated.csv
    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${tti_2}[ttitrace]/output_dl_formated.csv
    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${tti_3}[ttitrace]/output_dl_formated.csv
    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${tti_4}[ttitrace]/output_dl_formated.csv
    Verify targetMutingRatio for blankedSlots in ttitrace     ${tti_2}[ttitrace]/output_dl_formated.csv     35
    Verify targetMutingRatio for blankedSlots in ttitrace     ${tti_3}[ttitrace]/output_dl_formated.csv     50


*** Keywords ***
Collect TTI trace
    ${cells}  create list   NRCELL-1
    Log To Console    \nStartingTTICapture
    Start L2Ps TTI logs from vDU    ${cells}
    sleep  3s
#    ${tti}    Stop L2Ps TTI logs from vDU    test_scenario=Ue_DLUL_data
#    Decode TTI Trace    Ue_DLUL_data


Start CPRT F1 Monitoring
    [Arguments]
    Log to Console     \n-----> Start CPRT F1 Mon <-----
    AIC Start CPRT F1 Mon    ${vDU_NODE_HOST}    ${vDU_NODE_USER}    ${vDU_NODE_PASSWORD}    ${vDU_NAMESPACE}


Stop and Collect CPRT F1 Monitoring
    [Arguments]
    Log to Console     \n-----> Stop and Collect CPRT F1 Monitoring <-----
    ${fullTestName}=       replace string  ${TESTNAME}      ${SPACE}        _
    ${fullTestName1}=       replace string  ${fullTestName}      [           _
    ${fullTestName}=       replace string  ${fullTestName1}      ]           _
    set test variable    ${TESTCASE_LOG_PATH}    ${Suite_LOG_PATH}/${fullTestName}
    Create Folder        ${TESTCASE_LOG_PATH}/CPRT/
    AIC Stop Collect CPRT F1 Mon   ${TESTCASE_LOG_PATH}/CPRT/    ${vDU_NODE_HOST}    ${vDU_NODE_USER}
    ...   ${vDU_NODE_PASSWORD}    ${vDU_NAMESPACE}
    Move File    ${TESTCASE_LOG_PATH}/CPRT/CPRT.pcap    ${TESTCASE_LOG_PATH}/CPRT/NODECPRT_GNB_UE_${ue_idx}.pcap
