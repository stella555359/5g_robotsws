*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO       VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...             CIT    CDRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS22R4    SBTS23R1    #CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Madhu,Sowrabha
...              :contact: madhusudhan.y@nokia.com,sowrabha.s_m@nokia.com
...         The aim of the 5GC000937 feature is to allow power savings for UE with small throughput traffic.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         The strategy for UE power savings is based on the possibility of dynamic switch between a BWP with large bandwidth size
...         (often configured with full carrier
...         bandwidth size) and a "power saving BWP" with a narrow bandwidth size.
...         The feature is considered as being efficient when the power saving BWP bandwidth size is a small
...         fraction of the large BWP bandwidth size.
...         A typical example is for carrier bandwidth size 100Mhz, the large BWP covers the full carrier Bw and the
...         power saving BWP bandwidth size is 20Mhz.
...         The dynamic decision for which BWP to use is based on some configurable criteria including UL/DL data rate and
...         UL/DL buffer length.
...         Some mechanism prevents ping-pong effect.
...         A NIDD parameter limits the number of UEs simultaneously in the power saving BWP.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/common_log_collection.robot

Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with TMO_937_545.json
...                 AND     sleep   200s   reason=RAT reset
...                 AND     Prepare TL with IPHY file change
...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid


Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/TMO_5GC000937_with_5GC000545.cfg
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
@{pysical_cell_ids}      52

${AP_XML}=                 ${CURDIR}/config/SCF/TMO_937_iphy.xml

*** Test Cases ***

[1][1.0] 5GC000937_TC_09_Verify_multi-UE_Switch_to_power_saving_BWP_on_low_DL_UL_traffic_rate_and_switch_to_large_BWP_on_UL_traffic_increase
    [Documentation]   in this testcase verify that 5G NR powerSaving BWP cabable  UE configured with large BWP and
    ...         Power Saving BWP during UE context setup. in the beginning when successful DL/UL data transfer initiated
    ...         verify that data transfer happens in the large BWP,
    ...        DCI switch to PS BWP happens using DCI format 1_1, when data rates are less than thresholds.
    ...        DCI switch to large BWP happens, when DL data rate is more than the thresholds.
    [Tags]    QC_363194      QCD_MN_RAN    QCP_RAN_ET
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Attach Multiple UEs
    Start low traffic on UE1 and UE2 and high traffic on UE3 and validate PSBWP on UE1 and UE2
    Validate the mutiple UE traffic
    Start high traffic on UE1 and UE2 and validate the UEs moving to LargeBWP
    [Teardown]    Run keywords    Stop MultiUE Data Traffic for SA     41  43
	...           AND             MultiUE Deregister should be Successful   41  43
    ...           AND             Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
    ...           AND             Get Sos Report
    ...           AND             Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Attach Multiple UEs
    log to console   UE attach trigerring now...
    Start Log   bip   cprt   btslog
    ${crnti_list}=      MultiUE Register should be Successful    41  43
    Set suite variable     ${crnti_list}

Start low traffic on UE1 and UE2 and high traffic on UE3 and validate PSBWP on UE1 and UE2
    MultiUE Trigger DL Traffic for SA    41  42    Traffic_rate=kbps     dl_rate=25          trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    41  42    Traffic_rate=kbps     ul_rate=25          trf_id=${TRF_ID}
    MultiUE Trigger DL Traffic for SA    43  43    Traffic_rate=mbps     dl_rate=1         trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    43  43    Traffic_rate=mbps     ul_rate=1         trf_id=${TRF_ID}
    sleep   5s    reason=Wait for successful BWP switch
    Stop Log      bip   cprt   btslog     test_scenario=lowdata_UE1_UE2
	${bwpid}    Create List     2     2    1
	${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    Capture TTI Traces and Validate UE bwpid Per Cell     ${LOG_PATH}    lowdata     ${crnti_list}
    ...     ${bwpid}     ${Branch_22R1}     ${pysical_cell_ids}

Validate the mutiple UE traffic
    Validate DL Traffic For MultiUE for SA    41  42     dl_rate=0.025
    Validate UL Traffic For MultiUE for SA    41  22     ul_rate=0.025
    Validate DL Traffic For MultiUE for SA    43  43     dl_rate=1
    Validate UL Traffic For MultiUE for SA    43  43     ul_rate=1

Start high traffic on UE1 and UE2 and validate the UEs moving to LargeBWP
    Start Log   bip   cprt   btslog
    MultiUE Trigger UL Traffic for SA    41  42    Traffic_rate=mbps     ul_rate=2          trf_id=${TRF_ID2}
    sleep   10s      reason=Wait for successful BWP switch
    Stop Log      bip   cprt   btslog     test_scenario=highdata_UE1_UE2
    ${bwpid}    Create List     1     1    1
    Capture TTI Traces and Validate UE bwpid Per Cell     ${LOG_PATH}    lowdata     ${crnti_list}
    ...     ${bwpid}     ${Branch_22R1}     ${pysical_cell_ids}
    Validate UL Traffic For MultiUE for SA    41  42     ul_rate=2
    Validate DL Traffic For MultiUE for SA    41  42     dl_rate=0.025
    Validate DL Traffic For MultiUE for SA    43  43     dl_rate=1
    Validate UL Traffic For MultiUE for SA    43  43     ul_rate=1
