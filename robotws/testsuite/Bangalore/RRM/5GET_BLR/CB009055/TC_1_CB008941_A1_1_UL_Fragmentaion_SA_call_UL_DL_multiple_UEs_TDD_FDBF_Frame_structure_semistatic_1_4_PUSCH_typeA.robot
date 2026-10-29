*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    CDRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS23R1    SBTS23R2    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Prakhar
...              :contact: prakhar.rastogi@nokia.com


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
#Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008941_resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          OperatingSystem


Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Download MCShark To UTE
...                 AND     Add RD Parameters To GNB Swconfig File     ${RD_PARAM}
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_2CC_TDD_FS_8941_BF_typeA_1_4.json
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report
#...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_APoABIO_MultiUe_VONR_tdd.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${Large_BWP}      bwp:.*1\\sfd
${PS_BWP}      bwp:.*2\\sfd
@{syslog_regex_bwp}     DCI11   DCI01
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving
${TEST_NAME}        test_case
${IPHY_FILE}                    ${CURDIR}/config/wts/Conf_7752-B-SANSA-TDD-iphy.xml

*** Test Cases ***
[1]CB008941_A1_1_UL_Fragmentaion_SA_call_UL_DL_multiple_UEs_TDD_FDBF_Frame_structure_semistatic_1_4_PUSCH_typeA
    [Documentation]   This user scenario validates system behavior in case when UL UP dynamic fragmentation is
    ...         activated, the data transmission in eCPRI uplink contains the NR IQ of scheduled PRBs for TDD FR1
    ...         deployments, the NR carrier supports UL PRB dynamic fragmentation.If UP fragmentation can be supported
    ...         by only partial streams of a single RU, operator can try to configure more cells to verify the case
    ...         that configured streams more than the streams with UP fragmentation supported


    Read Cellsetup msg      ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    set test variable      ${LOG_PATH}
    UE Beamforming Profile And Association For 2 Beams SA    ${15}
    log to console   UE attach trigerring now...

    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
    Start L1L2 Bip Mon on classical gNB
	${crnti_list_1}=      MultiUE Register should be Successful    1  8
    sleep    1ms    reason=Wait for successful response from admin
    Stop and Collect L1L2 Bip Monitoring on classical gNB     ${Log_path}
    move file    ${Log_path}/L1L2_bipmon/l1l2_abip.pcap    ${Log_path}/L1L2_bipmon/l1l2_abip_new1_8.pcap
    Set to dictionary   ${CaptureL1L2}    path=${Log_path}/L1L2_bipmon/l1l2_abip_new1_8.pcap

    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
    Start L1L2 Bip Mon on classical gNB
	${crnti_list_1}=      MultiUE Register should be Successful    9  15
    sleep    1ms    reason=Wait for successful response from admin
    Stop and Collect L1L2 Bip Monitoring on classical gNB     ${Log_path}
    move file    ${Log_path}/L1L2_bipmon/l1l2_abip.pcap    ${Log_path}/L1L2_bipmon/l1l2_abip_new9_15.pcap
    Set to dictionary   ${CaptureL1L2}    path=${Log_path}/L1L2_bipmon/l1l2_abip_new9_15.pcap

#    Start Log    bip
#    ${crnti_list_1}=      MultiUE Register should be Successful    1  8
#    ${scen1}     Stop Log     bip     test_scenario=attach_1_8

#    Start Log    bip
#    ${crnti_list_2}=      MultiUE Register should be Successful    9  15
#    ${scen2}     Stop Log     bip    test_scenario=attach_9_15

    MultiUE Trigger DL Traffic for SA    1  15    Traffic_rate=kbps     dl_rate=15          trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    1  15    Traffic_rate=kbps     ul_rate=15          trf_id=${TRF_ID}

    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
    Start L1L2 Bip Mon on classical gNB
    sleep    1ms    reason=Wait for successful response from admin
    Stop and Collect L1L2 Bip Monitoring on classical gNB     ${Log_path}
    move file    ${Log_path}/L1L2_bipmon/l1l2_abip.pcap     ${Log_path}/L1L2_bipmon/l1l2_abip_new_data.pcap
    Set to dictionary   ${CaptureL1L2}    path=${Log_path}/L1L2_bipmon/l1l2_abip_new_data.pcap

	Start Log     ttitrace
    sleep    1s
    ${scen4}     Stop Log     ttitrace     test_scenario=data_1_15
    sleep   30s

    Validate DL Traffic For MultiUE for SA    1  15     dl_rate=0.015
    Validate UL Traffic For MultiUE for SA    1  15     ul_rate=0.015

    Stop MultiUE Data Traffic for SA     1  15
    MultiUE Deregister should be Successful   1  15

    Decode TTI Trace   data_1_15
    ${rc}   tti_utility.verify_sliv   ${scen4}[ttitrace]/output_ul_formated.csv    ulFdSchedData   SLIV
    Should Contain	${rc}	Pass


    ${rc}   Read pucch boundary      ${Log_path}/L1L2_bipmon/l1l2_abip_new1_8.pcap
    Should Contain	${rc}	pass
    ${rc}   Read pucch boundary      ${Log_path}/L1L2_bipmon/l1l2_abip_new9_15.pcap
    Should Contain	${rc}	pass
    ${rc}   Read pucch boundary      ${Log_path}/L1L2_bipmon/l1l2_abip_new_data.pcap
    Should Contain	${rc}	pass
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}



