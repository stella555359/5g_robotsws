*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      CB008246_HB4_TC1_UL_Fallback_Recovery_with_64QAMLowSETable
...             TEST SET NAME:     CB008246_HB4_TC1_UL_Fallback_Recovery_with_64QAMLowSETable
...             TESTING SPLIT:     See CB008246-HB4 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-H CFAM

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          taf.rfrl.utilities.utf_lab.ute_utf_lab.UteUtfLab  WITH NAME  ute_utf_lab
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008246_resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py

Suite Setup         Run keywords
...                 Log To console  SuiteSetup
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Perform SCF Delta Commissioning with 8246_hb4_gmc.json
...                 AND     sleep    180
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
#...                 AND    ute_utf_lab.Update Utf Lab
...                 AND    operatingSystem.Run        export {http,https}_proxy=http://10.158.100.6:8080
#...		            AND	    Initiate Dcap
...                 AND     gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD to comeup
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    sleep  60s   reason=wait for mib sib
#...					AND		DCAP Connect To gNB

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     DCAP Disconnect To gNB

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/CB008246_HB4_TC1_ASOH_SCF.xml
${IPHY_FILE}          ${CURDIR}/config/SCF/8246_HB4_TC1_Gmc_IPHY.xml

${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_HB4_TC1_ASOH_SAUE1HRcapable.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${TEST_NAME}        test_case
${pathloss_start_dB}        75
${pathloss_end_dB}      130
${st_ue_id}      1
${en_ue_id}      1
@{Component1}   L2PS

*** Test Cases ***
[1][1.0] [1]CB008246_HB4_TC1_UL_Fallback_Recovery_with_64QAMLowSETable
    [Documentation]
       ...    1. This user scenario validates HR to BR Switch in UL is done.
       ...    2. Configuration
       ...    a.NSA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
       ...    b.NRF1 cell has NRCELL-cellDepType set to NSA or both
       ...    3. Test Case Steps:
       ...    a.UE attach and CQi changes are done.
       ...	  b.HR to BR Switch is done and verified.
       ...    c.UE detach.

    set test variable   ${LOG_PATH}
    log to console   UE attach trigerring now...

    Introduce csi_override_cqi      4
    Activate csi_override_for_UE        1       1
    Introduce pathloss      1       1
    Activate pathloss_for_UE        1       1
    sleep       1s

    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRPUSCHHRLA-1       update      ulHRBlerRecoverPeriod     20
    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRPUSCHHRLA-1       update      ulHRBlerOutagePeriod     20
    sleep   5s
    Log To Console          check bts state
    sleep           30s

#    Start Log Via DCAP  ttitrace  component=${Component1}

    ${crnti_list1}=      MultiUE Register should be Successful    1      1
    MultiUE PDU Modfication should be Successful     1    1      pdu_id=1      qosflows_to_add=4

    MultiUE Trigger DL Traffic for SA   1       1    Traffic_rate=mbps   dl_rate=1   trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA   1       1    Traffic_rate=mbps   ul_rate=1   trf_id=${TRF_ID}
    MultiUE Trigger DL Traffic for SA   1       1    Traffic_rate=mbps   dl_rate=1   trf_id=${TRF_ID}       qfi_id=2
    MultiUE Trigger UL Traffic for SA   1       1    Traffic_rate=mbps   ul_rate=1   trf_id=${TRF_ID}       qfi_id=2

    sleep       3s
    Start Log      ttitrace
    Introduce csi_override_cqi      1
    Activate csi_override_for_UE         1      1

    Vary pathloss       pathloss_start_dB=${pathloss_start_dB}+${1}     pathloss_end_dB=${pathloss_end_dB}     pathloss_step_dB=1
    #Vary pathloss       pathloss_start_dB=${pathloss_end_dB}    pathloss_end_dB=${pathloss_start_dB}    pathloss_step_dB=-1
#    Start Log Via DCAP  ttitrace  component=${Component1}
    sleep       2s
    ${path_ttitrace_UE1_cqi4_1}    Stop log      ttitrace    test_scenario=ttitrace_UE1_cqi4_1
#    ${path_ttitrace_UE1_cqi4_1}    Stop Log Via DCAP  ttitrace  test_scenario=ttitrace_UE1_cqi4_1

    Start Log      ttitrace
#    Start Log Via DCAP  ttitrace  component=${Component1}
    Introduce csi_override_cqi      13
    Activate csi_override_for_UE        1       1
    #Vary pathloss       pathloss_start_dB=${pathloss_start_dB}+${1}     pathloss_end_dB=${pathloss_end_dB}     pathloss_step_dB=1
    Vary pathloss       pathloss_start_dB=${80}   pathloss_end_dB=${pathloss_start_dB}    pathloss_step_dB=-1
    sleep       3s
    ${path_ttitrace_UE1_cqi13}    Stop log      ttitrace    test_scenario=ttitrace_UE1_cqi13
#    ${path_ttitrace_UE1_cqi13}    Stop Log Via DCAP  ttitrace  test_scenario=ttitrace_UE1_cqi13

    sleep       3s
    Decode TTI Trace    ttitrace_UE1_cqi13
    Decode TTI Trace    ttitrace_UE1_cqi4_1

# HR to BR switch
    ${chk_attrs}   Create List  laMode  event  pdcchMetric.nbSamples  pdcchMetric.nbSamplesThreshold  pdcchMetric.ratio
    ...     puschMetric.nbSamples  puschMetric.nbSamplesThreshold  sfn  slot  cqiAlSelection   aggregationLevel   puschMetric.ratio
    ${rc}   verify_pdcch_outage_ul   ${path_ttitrace_UE1_cqi4_1}[ttitrace]/output_ul_formated.csv   ulLaSwitchBetweenHrAndBr
    ...          ulFdSchedData   ${20}    ${20}      @{chk_attrs}
    Should Contain	${rc}	pass

#BR to HR switch
    ${rc}   verify_pdcch_recovery_ul   ${path_ttitrace_UE1_cqi13}[ttitrace]/output_ul_formated.csv   ulLaSwitchBetweenHrAndBr
    ...          ${30}    ${60}      @{chk_attrs}
#    Should Contain	${rc}	pass

    MultiUE Deregister should be Successful   ${st_ue_id}   ${en_ue_id}

    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
