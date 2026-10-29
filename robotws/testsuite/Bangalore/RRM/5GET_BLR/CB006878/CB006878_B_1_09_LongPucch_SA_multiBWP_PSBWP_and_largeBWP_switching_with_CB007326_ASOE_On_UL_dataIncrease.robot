*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...   PY27
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Lavanya.T.V
...              :contact: lavanya.t_v@nokia.com
...         This user scenario describes the common gNB behavior at activation of the CB006878 feature when CB007326 is active and it verifies the
...         behavior of a single UE with multiple PDUs Switch to power saving BWP on low DL/UL traffic rate and switch to large BWP on UL traffic
...         increase
...         In particular, it shall be verified that HARQ, SR and pCSI resource areas are arranged differently than when CB006878 is disable.

...         A typical example is for carrier bandwidth size 100Mhz, the large BWP covers the full carrier Bw and the power saving BWP bandwidth
...         size is 20Mhz.
...         The dynamic decision for which BWP to use is based on some configurable criteria including UL/DL data rate and UL/DL buffer length.
...         Some mechanism prevents ping-pong effect.
...         A NIDD parameter limits the number of UEs simultaneously in the power
...              *REQUIREMENTS COVERAGE:
...              *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_16315

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/common_log_collection.robot

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Suite setup from scratch
#...                 AND     Update GSCN in AP Iphy Xml     gscn=7867
#...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Perform SCF Delta Commissioning with CB006878_Enable.json
#...                 AND     sleep    180
#...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown       Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Run Keyword And Ignore Error     Stop Default Processes And Gather Logs And Compress Logs

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    MultiUE Deregister should be Successful   1   4

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_multiue_tdd_2cell_ASOE.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${Q_O_ADD}      1
${RTP_COD}      1
${epc_log_path}    /tmp/
${Large_BWP}      bwp:.*1\\sfd
${PS_BWP}      bwp:.*2\\sfd
@{syslog_regex_bwp}     DCI11   DCI01
${scf_file}      /home/ute/Downloads/.*xml*
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${tput_ue}     25
${tput_ue_3}     100
${SCFC}=                   ${CURDIR}/config/SCF_BWP.xml
${AP_XML}=                 ${CURDIR}/config/iphy_BWP.xml

*** Test Cases ***
CB006878_B#1_09_LongPucch_SA_multiBWP_PSBWP_and_largeBWP_switching_with_CB007326_ASOE_On_UL_dataIncrease
    [Documentation]   verifies the behavior of a single UE with multiple PDUs Switch to power saving BWP on low DL/UL
     ...    traffic rate and switch to large BWP on UL traffic increase.

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    CPRT Monitoring Start ASOE
    Bip Mon Start AP ASIK ABIL
    Start Collecting Syslog     NAME=ueattach_TC10
    ${crnti_list}=      MultiUE Register should be Successful    1  3
    sleep   30s
    Bip Mon Stop AP ASIK ABIL   ${LOG_PATH}
    Stop Collecting Syslog       NAME=ueattach_TC10
	${bwpid}    Create List     1     1    1
    Run Keyword And Ignore Error   Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    initial    ${crnti_list}     ${bwpid}
    ...     ${Branch_22R1}
    Start Collecting Syslog     NAME=ue_lowdata_TC10
    MultiUE Trigger DL Traffic for SA    1  2    Traffic_rate=kbps     dl_rate=25          trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    1  2    Traffic_rate=kbps     ul_rate=25          trf_id=${TRF_ID}
    MultiUE Trigger DL Traffic for SA    3  3    Traffic_rate=kbps     dl_rate=900         trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    3  3    Traffic_rate=kbps     ul_rate=900         trf_id=${TRF_ID}
    sleep   10s    reason=Wait for successful BWP switch
    CPRT Monitoring Stop Collect ASOE      ${LOG_PATH}
    Move File    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_NODECPRT_GNB_UE_Attach_TC10.pcap
    Move File    ${LOG_PATH}/External_NODECPRT_GNB.pcap    ${LOG_PATH}/External_NODECPRT_GNB_UE_Attach_TC10.pcap
    Stop Collecting Syslog       NAME=ue_lowdata_TC10
    ${bwpid}    Create List     2     2    1
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    Validate DL Traffic For MultiUE for SA    1  2     dl_rate=0.025
    Validate UL Traffic For MultiUE for SA    1  2     ul_rate=0.025
	Validate DL Traffic For MultiUE for SA    3  3     dl_rate=0.900
    Validate UL Traffic For MultiUE for SA    3  3     ul_rate=0.900
    Start Collecting Syslog     NAME=ue_highdata_TC10
    MultiUE Trigger DL Traffic for SA    1  2    Traffic_rate=mbps     dl_rate=4          trf_id=${TRF_ID2}
    Run Keyword And Ignore Error    wtsrunner.bearer_stats_clear     ue=${ue_id}    pdu=${Pdu_session_ID}
    sleep   10s      reason=Wait for successful BWP switch
    Stop Collecting Syslog       NAME=ue_highdata_TC10
    ${bwpid}    Create List     1     1    1
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    highdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    Validate DL Traffic For MultiUE for SA    1  2     dl_rate=4
    Validate UL Traffic For MultiUE for SA    1  2     ul_rate=0.025
    Validate DL Traffic For MultiUE for SA    3  3     dl_rate=0.900
    Validate UL Traffic For MultiUE for SA    3  3     ul_rate=0.900
    Stop MultiUE Data Traffic for SA     1  3
    MultiUE Deregister should be Successful   1  3

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string       ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
