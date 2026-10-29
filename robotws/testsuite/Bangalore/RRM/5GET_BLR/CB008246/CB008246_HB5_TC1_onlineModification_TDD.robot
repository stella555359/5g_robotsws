*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      This user scenario validates the gNB behaviour for dynamic PDCCH AL selection enabled
...                                for high reliability non-GBR DRB. This user scenario also validates the high reliability
...                                PDCCH related NIDD parameter online modification. In this scenario, at most only 1 high
...                                reliability DRB shall be configured to the test UE
...             TEST SET NAME:     CB008246-H_High_reliability_support_in_PDCCH_with_DLBler
...             TESTING SPLIT:     See CB008246-HB5 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-H CFAM
...             Requirement ID:   5G_RAN_USR_RRM_17589

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
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
...                 AND     Prepare TL with all config files
...                 AND     Suite setup from scratch
#...				    AND	 Initiate Dcap
#...                 AND     Update GSCN in AP Iphy Xml     gscn=7867
...                 AND     Add RD Parameters To GNB Swconfig File      ${radparam}
#...                 AND     Perform SCF Delta Commissioning with CB008246_Combined_Hsplit_PWSBWP.json
#...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid
#...					AND		DCAP Connect To gNB

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/CB008246_HB6_TC3_SCF.xml
${AP_XML}=      ${CURDIR}/config/SCF/CB008246_HB6_TC3_IPHY.xml

${wts_cfg_file}    ${CURDIR}/config/wts/basic_cfg_tdd_h6tc3.cfg
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
${radparam}                SEPARATOR=${EMPTY}   0x5806F2=1;0x580021=0
@{Component1}   L2PS

*** Test Cases ***
[1]CB008246-H_High_reliability_support_in_PDCCH_with_DLBler
    set test variable   ${LOG_PATH}
    start log   btslog
    start log   snapshot
    Start Log      bip
    Modify_online NIDD param under NRPDCCHHRLA-1 NRPDSCHHRLA-1 NRPUCCHHRLA-1
    sleep       3s
    ${path_biptrace_modify1}    Stop log      bip     test_scenario=biptrace_modify1
	Start Log	ttitrace
#   Start Log Via DCAP  ttitrace  component=${Component1}
    Simulate cqi        9       1       1
    sleep       1s
    log to console   UE attach trigerring now...
    ${crnti_list1}=      MultiUE Register should be Successful    1      1
    MultiUE PDU Modfication should be Successful     1    1      pdu_id=1      qosflows_to_add=4

    MultiUE Trigger DL Traffic for SA   1       1    Traffic_rate=mbps   dl_rate=1   trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA   1       1    Traffic_rate=mbps   ul_rate=1   trf_id=${TRF_ID}
    MultiUE Trigger DL Traffic for SA   1       1    Traffic_rate=mbps   dl_rate=1   trf_id=${TRF_ID}       qfi_id=2
    MultiUE Trigger UL Traffic for SA   1       1    Traffic_rate=mbps   ul_rate=1   trf_id=${TRF_ID}       qfi_id=2
    sleep       2s

    Simulate cqi        1       1       1
    Simulate bler_testmode      1       1

    sleep       3s
#    ${tti_cqi1_4}    Stop Log Via DCAP  ttitrace  test_scenario=ttitrace_cqi1_4
	${tti_cqi1_4}	Stop log    ttitrace    test_scenario=ttitrace_cqi1_4


	Start Log	ttitrace
#    Start Log Via DCAP  ttitrace  component=${Component1}
    Simulate cqi        13       1       1
    sleep       3s
    Deactivate bler_testmode_for_UE     1       1

    sleep       3s
#   ${tti_cqi13_deact}    Stop Log Via DCAP  ttitrace  test_scenario=ttitrace_cqi13_bler_deact
	${tti_cqi13_deact}		Stop log    ttitrace    test_scenario=ttitrace_cqi13_bler_deact
    stop log   btslog
    stop log   snapshot
# BR to HR switch
    Decode TTI Trace    ttitrace_cqi13_bler_deact
    sleep       30s
# HR to BR switch
    Decode TTI Trace    ttitrace_cqi1_4

    Run     cp ${tti_cqi13_deact}[ttitrace]/tcpdump_ttitrace.pcap ${tti_cqi13_deact}[ttitrace]/tcpdump_ttitrace_backup.pcap
    Run     cp ${tti_cqi1_4}[ttitrace]/tcpdump_ttitrace.pcap ${tti_cqi1_4}[ttitrace]/tcpdump_ttitrace_backup.pcap

	Run		/sbin/tcpdump -r ${tti_cqi13_deact}[ttitrace]/tcpdump_ttitrace.pcap -w ${tti_cqi13_deact}[ttitrace]/tcpdump_ttitrace.pcap -C 6.5MB
	Run		/sbin/tcpdump -r ${tti_cqi1_4}[ttitrace]/tcpdump_ttitrace.pcap -w ${tti_cqi1_4}[ttitrace]/tcpdump_ttitrace.pcap -C 6.5MB

# HR to BR switch
    ${chk_attrs}   Create List  laMode  event  pdcchMetric.nbSamples  pdcchMetric.nbSamplesThreshold  pdcchMetric.ratio
    ...     pdschMetric.nbSamples  pdschMetric.nbSamplesThreshold  sfn  slot  cqiAlSelection   aggregationLevel   pdschMetric.ratio
    ${rc}   verify_pdcch_outage   ${tti_cqi1_4}[ttitrace]/output_dl_formated.csv   dlLaSwitchBetweenHrAndBr
    ...          dlFdSchedData   ${20}    ${90}      @{chk_attrs}
    Should Contain	${rc}	pass

#BR to HR switch
    ${rc}   verify_pdcch_recovery   ${tti_cqi13_deact}[ttitrace]/output_dl_formated.csv   dlLaSwitchBetweenHrAndBr
    ...          ${20}    ${90}      @{chk_attrs}
    Should Contain	${rc}	pass

    Stop MultiUE Data Traffic for SA     ${st_ue_id}   ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}   ${en_ue_id}
    [Teardown]       Link SCOUT SCF to Configuration ID for Reporting
