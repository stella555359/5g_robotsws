*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS22R4    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Noble
...              :contact: noble.iyeswariyam_edison@nokia.com
...         The feature removes restrictions concerning the feature 5GC000937 allowing
...         PRACH frequency position outside the Power Saving Bandwidth Part (PS-BWP)
...         CB008541 feature is enabled along with 5GC00937 power saving and CB007552 enabled.
...         MUE registered with different UE capabilities and BFR is activated and triggered on all UEs.

Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         CB010544_Resource.robot
Library          taf.sw.scout    WITH NAME     scout

Suite Setup         Run keywords    Run Keyword and Ignore Error    Suite setup from scratch
...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with CB010544_B_01_1CC.json
#...                 AND     Check and active the BTS l2ps DBG log     feature_flag=10544
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
#...                 AND     Run Keyword and Ignore Error   Stop Default Processes And Gather Logs And Compress Logs
#Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run keywords    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_1CC.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${start_ue_id}    1
${end_ue_id}      4
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${largebwp_id}     1
${smallbwp_id}     2
${psbwp_id}        3
@{syslog_regex_bwp}     DCI11   DCI01
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving

*** Test Cases ***
[1]CB010544_B_01_1CC_4UEs_supporting_SBWP_scell_Trigger_BFR_in_PSBWP_LBWP_SBWP_with937_8541-A_enabled
    [Documentation]   This test case verifies the Beam failure recovery for multi UEs configured with
    ...               both large and power saving BWP when the Flexibility setting is necessary,
    ...               and RACH is not in the Power saving BWP.

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Collecting Syslog     NAME=ue_attach
    Create BeamForming profile attach MUE and trigger low data
    Stop Collecting Syslog       ${LOG_PATH}/ue_attach
    Start Collecting Syslog     NAME=beam_recovery
    Trigger Beam recovery and verify PSBWP through TTI trace
    Stop Collecting Syslog       ${LOG_PATH}/beam_recovery
    Verify Beam Recovery in AP Syslog      NAME=beam_recovery
    Trigger Beam recovery on same beam and verify PSBWP through TTI trace
    Stop Data Traffic for SA     ue_id=${UE_ID}
    MultiUE Deregister should be Successful   1   4

*** Keywords ***
Create BeamForming profile attach MUE and trigger low data
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    log to console   Create BeamForming Profile...
    Create Beamforming Profile for association of 4 Beams and activate MUE    1      4
    log to console   UE attach trigerring now...
    #Multi UE registration and no rach validation
    ${crnti_list}       Create List
    FOR      ${ue_idx}   IN RANGE    ${1} 	  ${3}+1
    ${rnti}     UE Registered Successfully & Rach validation      ue_id=${ue_idx}
    Append To List    ${crnti_list}   ${rnti}
    END
    #RACH VALIDATION NOT ALLOWED FOR UE4 DUE TO 937 INCAPABLE
    ${crnti}     UE Register should be Successful And Fetch RNTI    ue_id=4
    Append To List    ${crnti_list}   ${crnti}
    set suite variable    ${crnti_list}
    Sleep    5s
    #UE1 AND UE2 MOVING FROM LARGE  BWP PROFILE TO POWER SAVING BWP PROFILE DUE TO LOW DATA
    MultiUE Trigger DL Traffic for SA    1   2    Traffic_rate=kbps     dl_rate=10          trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    MultiUE Trigger UL Traffic for SA    1   2    Traffic_rate=kbps     ul_rate=10          trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    #UE3 MOVING TO SBWP DUE TO HIGH DATA
    Trigger UL Traffic for SA    ue_id=3    Traffic_rate=mbps     ul_rate=2       pdu_id=1      trf_id=1      qfi_id=${QFI_ID}
    #UE4 MOVING TO LBWP THOUGH LOW DATA DUE TO 937 INCAPABLE UE
    MultiUE Trigger DL Traffic for SA    4   4    Traffic_rate=kbps     dl_rate=10          trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    MultiUE Trigger UL Traffic for SA    4   4    Traffic_rate=kbps     ul_rate=10          trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful BWP switch
    ${bwpid}    Create List     3    3    2    1
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}

Trigger Beam recovery and verify PSBWP through TTI trace
    log to console    Trigger beam recovery...
    Start L2 BIP Trace Capturing
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id} 	  ${end_ue_id}+1
    Beamcontrol Beam Recovery      ue_id=${ue_idx}    beam_profile_id=2    best_beam=2
    sleep      5s
    #UE1 and UE2 IN PSBWP WILL MOVE TO INITIAL BWP FOR RRC RECONFIGURATION DUE TO BFR
    Run keyword if    ${ue_idx}<${3}     Check Rach msg
    END
    Stop L1L2 capture  ${CaptureL1L2}
    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_beamrecovery.pcap
    ${bwpid}    Create List     3    3    2    1
    Run keyword and continue on failure     Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    beamrecovery    ${crnti_list}
	...     ${bwpid}    ${Branch_22R1}
	Validate UE beamid from TTI traces    ${LOG_PATH}/ttitrace_streaming/beamrecovery     ${crnti_list}    ${2}
    Validate DL Traffic For MultiUE for SA    1   2     dl_rate=0.010
    Validate UL Traffic For MultiUE for SA    1   2     ul_rate=0.010
    Validate DL Traffic For MultiUE for SA    4   4     dl_rate=0.010
    Validate UL Traffic For MultiUE for SA    4   4     ul_rate=0.010
    Validate UL Traffic For SA   ue_id=3     pdu_id=1    ul_rate=2        qfi_id=${QFI_ID}

Trigger Beam recovery on same beam and verify PSBWP through TTI trace
    log to console    Trigger beam recovery...
    Start L2 BIP Trace Capturing
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id} 	  ${end_ue_id}+1
    Beamcontrol Beam Recovery      ue_id=${ue_idx}    beam_profile_id=2    best_beam=2
    sleep      5s
    #UE1 and UE2 IN PSBWP WILL MOVE TO INITIAL BWP FOR RRC RECONFIGURATION DUE TO BFR
    Run keyword if    ${ue_idx}<${3}     Check Rach msg
    END
    Stop L1L2 capture  ${CaptureL1L2}
    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_beamrecovery.pcap
    ${bwpid}    Create List     3    3    2    1
    Run keyword and continue on failure     Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    beamrecovery    ${crnti_list}
	...     ${bwpid}    ${Branch_22R1}
	Validate UE beamid from TTI traces    ${LOG_PATH}/ttitrace_streaming/beamrecovery     ${crnti_list}    ${2}
    Validate DL Traffic For MultiUE for SA    1   2     dl_rate=0.010
    Validate UL Traffic For MultiUE for SA    1   2     ul_rate=0.010
    Validate DL Traffic For MultiUE for SA    4   4     dl_rate=0.010
    Validate UL Traffic For MultiUE for SA    4   4     ul_rate=0.010
    Validate UL Traffic For SA   ue_id=3     pdu_id=1    ul_rate=2        qfi_id=${QFI_ID}
