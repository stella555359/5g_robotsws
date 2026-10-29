*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS24R1    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Shankar Karalatti
...              :contact: Shankar.karalatti@nokia.com
...         The aim of the 5GC000937 feature is to allow power savings for UE with small throughput traffic.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         The strategy for UE power savings is based on the possibility of dynamic switch between a BWP with large bandwidth size
...         (often configured with full carrier bandwidth size)
...         and a "power saving BWP" with a narrow bandwidth size.
...         The feature is considered as being efficient when the powersavingBWP bandwidth size is a small fraction of the largeBWP bandwidth size.
...         A typical example is for carrier bandwidth size 100Mhz, the large BWP covers the full carrier Bw and the
...         power saving BWP bandwidth size is 20Mhz.
...         The dynamic decision for which BWP to use is based on some configurable criteria including UL/DL data rate and UL/DL buffer length.
...         Some mechanism prevents ping-pong effect.
...         A NIDD parameter limits the number of UEs simultaneously in the power saving BWP.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         CB010544_Resource.robot

Suite Setup         Run keywords     Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown      Run keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Log to console   "FINISH"
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs

Test Teardown      Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_robustness_100UE.cfg
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
${largebwp_id}     1
${smallbwp_id}     2
${psbwp_id}        3
#${Large_BWP}      bwp:.*1\\sfd
#${PS_BWP}      bwp:.*2\\sfd
@{syslog_regex_bwp}     DCI11   DCI01
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving
${SCFC}=           custom-config/Bangalore/RRM/ET/CB010544/scf_Robustness.xml
${AP_XML}=         custom-config/Bangalore/RRM/ET/CB010544/iphy_Robsutness.xml

*** Test Cases ***
[1]CB010544_Robust_02_100UE_Multiple_time_BWP_changes_LBWP_SBWP_to_PSBWP
    [Documentation]    Robustnes_Test_For_100UEs
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
	Start Collecting Syslog     NAME=ue_attach
	Create BeamForming profile attach MUE and trigger low data
    Trigger Beam recovery to beam_profile_id=2 and verify PSBWP through TTI trace
	Trigger Beam recovery to beam_profile_id=1 and verify PSBWP through TTI trace
	Trigger Beam recovery to beam_profile_id=2 and verify PSBWP through TTI trace
	Trigger Beam recovery to beam_profile_id=1 and verify PSBWP through TTI trace
	Trigger Beam recovery to beam_profile_id=2 and verify PSBWP through TTI trace
    Stop Data Traffic for SA     ue_id=${UE_ID}
    MultiUE Deregister should be Successful   1   100



*** Keywords ***
Create BeamForming profile attach MUE and trigger low data
    log to console   Create BeamForming Profile...
    Create Beamforming Profile for association of 4 Beams and activate MUE    1      100
    log to console   UE attach trigerring now...
	${crnti_list}       Create List
    FOR      ${ue_idx}   IN RANGE    ${1} 	  ${100}+1
    ${rnti}     UE Registered Successfully & Rach validation      ue_id=${ue_idx}
    Trigger DL Data Traffic for SA    ue_id=${ue_idx}    Traffic_rate=kbps     dl_rate=10       trf_id=1
    Append To List    ${crnti_list}   ${rnti}
    END
    set suite variable    ${crnti_list}
    Sleep    5s
    sleep   5s    reason=Wait for successful BWP switch
    ${bwpid}    Create List     3    3    3    3    3    3    3    3     3    3    3    3     3    3    3    3   3    3    3    3    3    3    3
	...	    3     3    3    3    3      3    3    3    3      3    3    3    3     3    3    3    3    3    3    3    3     3    3    3    3     3    3
	...   3    3    3    3    3    3     3    3    3    3     3    3    3    3   3    3    3    3   3    3    3    3     3    3    3    3
	...    3    3    3    3      3    3    3    3     3    3    3    3    3    3    3    3     3    3    3    3     3    3    3    3
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}
    Validate UE beamid from TTI traces     ${LOG_PATH}/ttitrace_streaming/lowdata     ${crnti_list}     ${0}

Trigger Beam recovery to beam_profile_id=2 and verify PSBWP through TTI trace
    log to console    Trigger beam recovery...
    FOR	    ${ue_idx}   IN RANGE    ${1} 	  ${100}+1
       Beamcontrol Beam Recovery      ue_id=${ue_idx}    beam_profile_id=2    best_beam=2
    END
    Sleep    15s
    ${bwpid}    Create List     3    3    3    3    3    3    3    3     3    3    3    3     3    3    3    3   3    3    3    3    3    3    3
	...	    3     3    3    3    3      3    3    3    3      3    3    3    3     3    3    3    3    3    3    3    3     3    3    3    3     3    3
	...     3    3    3    3    3    3     3    3    3    3     3    3    3    3   3    3    3    3   3    3    3    3     3    3    3    3
	...     3    3    3    3      3    3    3    3     3    3    3    3    3    3    3    3     3    3    3    3     3    3    3    3
    Run keyword and continue on failure     Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    beamrecovery    ${crnti_list}
	...     ${bwpid}    ${Branch_22R1}
	Validate UE beamid from TTI traces     ${LOG_PATH}/ttitrace_streaming/beamrecovery     ${crnti_list}     ${2}
    Run keyword and ignore error    Validate DL Traffic For MultiUE for SA    1   100     dl_rate=0.010


Trigger Beam recovery to beam_profile_id=1 and verify PSBWP through TTI trace
    log to console    Trigger beam recovery...
    FOR	    ${ue_idx}   IN RANGE    ${1} 	  ${100}+1
        Beamcontrol Beam Recovery      ue_id=${ue_idx}    beam_profile_id=1     best_beam=0
    END
    Sleep    15s
    ${bwpid}    Create List     3    3    3    3    3    3    3    3     3    3    3    3     3    3    3    3   3    3    3    3    3    3    3
	...	    3     3    3    3    3      3    3    3    3      3    3    3    3     3    3    3    3    3    3    3    3     3    3    3    3     3    3
	...   3    3    3    3    3    3     3    3    3    3     3    3    3    3   3    3    3    3   3    3    3    3     3    3    3    3
	...    3    3    3    3      3    3    3    3     3    3    3    3    3    3    3    3     3    3    3    3     3    3    3    3
    Run keyword and continue on failure     Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    beamrecovery    ${crnti_list}
	...     ${bwpid}    ${Branch_22R1}
	Validate UE beamid from TTI traces     ${LOG_PATH}/ttitrace_streaming/beamrecovery     ${crnti_list}     ${0}
    Run keyword and ignore error    Validate DL Traffic For MultiUE for SA    1   100     dl_rate=0.010
