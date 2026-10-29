*** Settings ***
Force Tags      CLOUD_5G_I_LOO_AP_LOOO     VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     CONFIGURED

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
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Library          ../../../resources/python/BIP_Capture.py
Library          ../../../resources/python/CPRT_Capture.py
Resource         ../../../resources/robot/common_log_collection.robot

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
${Branch_22R1}=     False

*** Test Cases ***

[1][1.0] 5GC000937_with_5GC000545_APoABIO_CRT
    [Documentation]   in this testcase verify that 5G NR powerSaving BWP cabable  UE configured with large BWP and
    ...         Power Saving BWP during UE context setup. in the beginning when successful DL/UL data transfer initiated
    ...         verify that data transfer happens in the large BWP,
    ...        DCI switch to PS BWP happens using DCI format 1_1, when data rates are less than thresholds.
    ...        DCI switch to large BWP happens, when DL data rate is more than the thresholds.
    [Tags]    QC_363194      QCD_MN_RAN    QCP_RAN_ET
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}

    Attach Multiple UEs And Validate bwp switch 4 Times
    Trigger Traffic Sequence Five Times Attach multiple GBR non-GBR and Vonr call will cell lock and unlock

    [Teardown]    Run keywords      Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
    ...           AND             Get Sos Report
    ...           AND             Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Attach Multiple UEs And Validate bwp switch 4 Times
    FOR    ${i}    IN RANGE    1    4
        Log To Console    \n=== Iteration ${i} ===
        Attach Multiple UEs
        Start low traffic on UE1 and UE2 and high traffic on UE3 and validate PSBWP on UE1 and UE2
        Validate the mutiple UE traffic
        Start high traffic on UE1 and UE2 and validate the UEs moving to LargeBWP
        WTS_Runner_Keywords.Stop MultiUE Data Traffic For SA    31    50
        WTS_Runner_Keywords.MultiUE Deregister Should Be Successful    31    50
    END

Trigger Traffic Sequence Five Times Attach multiple GBR non-GBR and Vonr call will cell lock and unlock
    FOR    ${i}    IN RANGE    1    4
        Log To Console    \n===== Iteration ${i} Started =====
        Log To Console    Starting delta_comm_locking_${i}
        5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_lock.json
        Log To Console    Starting delta_comm Done_cell_locked
        Sleep    5s
        5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_unlock.json
        Log To Console    Starting delta_comm Done_cell_unlocked
        Sleep    5s
        Register and trigger Multiple NonGBR biDir UE Traffic    Start_UE=51    End_UE=55    DL_Rate=50
        ...    UL_Rate=30
        Register and trigger Multiple GBR biDir UE Traffic    Start_UE=56    End_UE=60    DL_Rate=17
        ...    UL_Rate=10
        Sleep    20s
        Run Keyword And Continue On Failure     Validate UL Traffic for GBR Ues     Start_UE=56     End_UE=60      UL_Rate=10
        ...    Traffic_rate=mbps     qfi_id=2
        Run Keyword And Continue On Failure     Validate GBR DL Traffic in the UE      Start_UE=56     End_UE=60      DL_Rate=17
        ...   Traffic_rate=mbps     qfi_id=2
        Run Keyword And Continue On Failure     Validate biDir NonGBR Traffic for MultiUE  Start_UE=51
        ...    End_UE=55  DL_Rate=50   UL_Rate=30
        Sleep    10s
        NSA call and trigger data    start_ue_id=101    end_ue_id=105    DL_Rate=20    UL_Rate=10
        Sleep    20s
        Run Keyword And Continue On Failure    Register and Validate NSA Traffic    start_ue_id=101    end_ue_id=105    DL_Rate=20    UL_Rate=10
        WTS_Runner_Keywords.Stop MultiUE Data Traffic For SA     51    60
        WTS_Runner_Keywords.MultiUE Deregister Should Be Successful   51   60
        Multi UE Detach should be Successful    101    102    103    104    105
        Sleep    3s
        Log To Console    ===== Iteration ${i} Completed =====
    END

Start maximum data and validate the throughput
    Start Multi UE DL traffic with multiple trafficID  start_ue=${start_ueid}  end_ue=${end_ueid}  dl_trf_id=9  qfi_id=1
    sleep    10s
    Start Multi UE UL traffic with multiple trafficID  start_ue=${start_ueid}  end_ue=${end_ueid}  ul_trf_id=2  qfi_id=1
    sleep    60s
    Get UL Throughput for Pcell  UE_ID=1  scell=0
    Log To Console    Cell lock and unlock success_Waiting for DL check to succeed
    Wait Until Keyword Succeeds  5x  10sec  Get DL Throughput for Pcell  UE_ID=1  scell=0  expected_thp=1250

Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Attach Multiple UEs
    log to console   UE attach trigerring now...
    Start Log   bip   cprt   btslog
    ${crnti_list}=      MultiUE Register should be Successful    31  50
    Set suite variable     ${crnti_list}

Start low traffic on UE1 and UE2 and high traffic on UE3 and validate PSBWP on UE1 and UE2
    MultiUE Trigger UL Traffic for SA    31  32    Traffic_rate=kbps     ul_rate=25          trf_id=${TRF_ID}
    MultiUE Trigger DL Traffic for SA    31  32    Traffic_rate=kbps     dl_rate=25          trf_id=${TRF_ID}
    MultiUE Trigger DL Traffic for SA    33  40    Traffic_rate=mbps     dl_rate=1          trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    33  40    Traffic_rate=mbps     ul_rate=1          trf_id=${TRF_ID}
    MultiUE Trigger DL Traffic for SA    41  42    Traffic_rate=kbps     dl_rate=25          trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    41  42    Traffic_rate=kbps     ul_rate=25         trf_id=${TRF_ID}
    MultiUE Trigger DL Traffic for SA    43  50    Traffic_rate=mbps     dl_rate=1          trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    43  50    Traffic_rate=mbps     ul_rate=1          trf_id=${TRF_ID}
    sleep   5s    reason=Wait for successful BWP switch

    Stop Log      bip   cprt   btslog     test_scenario=lowdata_UE1_UE2
	${bwpid}    Create List     2    2    1     1     1     1     1     1     1     1     2     2     1     1
	...     1     1      1     1      1     1
	${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    Capture TTI Traces and Validate UE bwpid Per Cell     ${LOG_PATH}    lowdata     ${crnti_list}
    ...     ${bwpid}     ${Branch_22R1}     ${pysical_cell_ids}


Validate the mutiple UE traffic
    Validate DL Traffic For MultiUE for SA    31  32     dl_rate=0.025
    Validate UL Traffic For MultiUE for SA    31  32     ul_rate=0.025
    Validate DL Traffic For MultiUE for SA    41  42     dl_rate=0.025
    Validate UL Traffic For MultiUE for SA    41  42     ul_rate=0.025
    Validate DL Traffic For MultiUE for SA    33  40    dl_rate=1
    Validate UL Traffic For MultiUE for SA    33  40    ul_rate=1
    Validate DL Traffic For MultiUE for SA    43  50    dl_rate=1
    Validate UL Traffic For MultiUE for SA    43  50    ul_rate=1

Start high traffic on UE1 and UE2 and validate the UEs moving to LargeBWP
    Start Log   bip   cprt   btslog
    MultiUE Trigger UL Traffic for SA    31  32    Traffic_rate=mbps     ul_rate=2          trf_id=${TRF_ID2}
    MultiUE Trigger UL Traffic for SA    41  42    Traffic_rate=mbps     ul_rate=2          trf_id=${TRF_ID2}
    sleep   10s      reason=Wait for successful BWP switch
    Stop Log      bip   cprt   btslog     test_scenario=highdata_UE1_UE2
    ${bwpid}    Create List     1     1    1    1     1    1     1    1    1     1    1    1    1    1
    ...   1     1    1    1    1     1
#    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    highdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    Capture TTI Traces and Validate UE bwpid Per Cell     ${LOG_PATH}    highdata      ${crnti_list}
    ...     ${bwpid}     ${Branch_22R1}     ${pysical_cell_ids}



    Validate DL Traffic For MultiUE for SA    31  32     dl_rate=0.025
    Validate UL Traffic For MultiUE for SA    31  32     ul_rate=2
    Validate DL Traffic For MultiUE for SA    41  42     dl_rate=0.025
    Validate UL Traffic For MultiUE for SA    41  42     ul_rate=2
    Validate DL Traffic For MultiUE for SA    33  40    dl_rate=1
    Validate UL Traffic For MultiUE for SA    33  40    ul_rate=1
    Validate DL Traffic For MultiUE for SA    43  50    dl_rate=1
    Validate UL Traffic For MultiUE for SA    43  50    ul_rate=1

UE Detach should be Successful
    [Arguments]    ${UE_ID}
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    wtsrunner.ue_detach    id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_detach_pattern}    ${Timeout_NSA}
    Print Matching Lines from Output File    ${output}    ${UE_detach_pattern}
    BuiltIn.Log    Detach of UE ${UE_ID} is successful


Multi UE Detach should be Successful
    [Arguments]    @{UE_IDs}
    [Documentation]    This keyword detaches multiple UEs with gNB and checks completion messages.
    FOR    ${UE_ID}    IN    @{UE_IDs}
        UE Detach should be Successful    ${UE_ID}
    END

