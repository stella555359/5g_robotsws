*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO

...             VARIANT_SANSA_FS_CPRI_CMWV_FDD    RAN_5G    5G_RAN_FDD    5G_RAN    SBTS00    SBTS24R1    CONFIGURED

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008246_resource.robot
###Resource         /home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/5GET_BLR/CB008927/CB008927_resource.robot
Library          ./python/CB008927_Verification.py
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ./python/CB008246_validation.py


Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     CB008246_resource.Perform SCF Delta Commissioning with CB008246_TC1_K5_HR_interworking_vonr_FDD.json
...                AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     CB008246_resource.Load CFG Config And Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Run Keyword and Ignore Error    Start Log    btslog
...                 AND     Check gNB Bulid


Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Stop Log    btslog
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

Documentation
...
...             author:
...             maintainer:
...
...             INTRODUCTION:     This user scenario validates the Link adaptation for High reliability DRB interworking with VoNR
...				(5GC000786 Voice over NR introduction, CB006112 Voice over NR enhancement). HR DRB(s) shall be treated as BR DRB(s)
...				 while VoNR bearer (5QI-1) is allocated to the UE. Also, mcs-Table shall be reverted to non-HR value (64QAM or 256QAM)
...				when 5QI-1 bearer is established. When 5QI 1 bearer is released and DRB associated with HR LA profile remains, then UE is
...			   reconfigured with qam64LowSE or qam64 depending on UE capability and HR LA is applied.
...				If CB009425 VoNR Increased Transmission Reliability is activated, it is applied for all DRBs while 5QI-1 bearer is
...             TEST SET NAME:    [1]CB008246_K5_3_UE does not support Dl-64QAM-MCS-TableAlt and Ul-64QAM-MCS-TableAlt? with 256QAM
...						enabled
...             TESTING SPLIT:     See CB008246 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246 CFAM
...             Requirement ID:      5G_PM_462

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/K-split-256_enabled.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${qfi_id}    1
${Q_O_ADD}      1
${RTP_COD}      1
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${1}
${TLConfig.isUTE}       True
${TEST_NAME}        test_case
${Timeout_SA}       60


*** Test Cases ***
[1]TC1_N_High_reliability_feature_interworking_with_VoNR_FDD
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...

     Start Log    cprt
#    Start Log       ttitrace

#Step 1. Attach VONR UEs with PDU session 5QI-6 nonGBR qosflow which is default
    ${crnti}    MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=1    nw_id=1
    MultiUE PDU Modfication should be Successful     1    1      pdu_id=1      qosflows_to_add=1


#Step 2.Add pdu and start data
#    MultiUE PDU Addition should be Successful        ${st_ue_id}    ${en_ue_id}    nw_id=1    pdu_id=2
    MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     dl_rate=32     trf_id=1
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     ul_rate=32     trf_id=1

    Start Log       ttitrace

#Step 3.modify pdu with qos flow : 4 and trigger data
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=1   qosflows_to_add=7
    Sleep       2s
    MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     dl_rate=32     pdu_id=1    trf_id=1       qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     ul_rate=32     pdu_id=1    trf_id=1       qfi_id=2
#Step 4. Establish pdu_id=2 for 5QI-5 SIP Signalling
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=1   qosflows_to_add=2
    Sleep   2s
    MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     dl_rate=32     pdu_id=1    trf_id=1       qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     ul_rate=32     pdu_id=1    trf_id=1       qfi_id=2
#Step 5. Establish pdu_id=2 for 5QI-1 VoNR Call
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}      pdu_id=1      qosflows_to_add=3
    Trigger MultiUE VoNR DL Traffic with multiple trfids    ${st_ue_id}    ${en_ue_id}    pdu_id=1     num_trf_id=20    qfi_id=3    rtp_codec=custom
    Trigger MultiUE VoNR UL Traffic with multiple trfids    ${st_ue_id}    ${en_ue_id}    pdu_id=1     num_trf_id=20    qfi_id=3    rtp_codec=custom
	${path_ttitrace_1}    Stop log    ttitrace    test_scenario=ttitrace_add_FDD
    Log to Console    ${path_ttitrace_1}[ttitrace]
     ${path_cprt}    Stop log    cprt       test_scenario=cprt

#    Decode TTI Trace    ttitrace_add_FDD
     Common TTI PCAP to CSV Converter    ttitrace_add_FDD    dir=dl
     Common TTI PCAP to CSV Converter    ttitrace_add_FDD    dir=ul


#    Start Log    cprt

    wtsrunner.ue_pdu_session_modify     ue=1    pdu=1   qosflows_to_del=3   by=amf
    Start Log       ttitrace
    Sleep   2s

    Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

	${path_ttitrace_2}    Stop log    ttitrace    test_scenario=ttitrace_del_FDD
    Log to Console    ${path_ttitrace_2}[ttitrace]
#   ${path_cprt}    Stop log    cprt       test_scenario=cprt

#    Decode TTI Trace    ttitrace_del_FDD
    Common TTI PCAP to CSV Converter    ttitrace_del_FDD    dir=dl
    Common TTI PCAP to CSV Converter    ttitrace_del_FDD    dir=ul

    Verify lamode and mcstable HR DRB added after CG DRB_1    ${path_ttitrace_1}[ttitrace]
    ...      ${crnti}
    Verify lamode and mcstable HR DRB added after CG DRB_2     ${path_ttitrace_2}[ttitrace]
    ...      ${crnti}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Trigger MultiUE VoNR DL Traffic with multiple trfids
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${pdu_id}=1     ${num_trf_id}=1
	...     ${qfi_id}=1   ${rtp_codec}=custom
    [Documentation]    This keyword starts the VoNR DL Traffic for the SA variant having some rtp codec
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning VoNR DL Traffic for ue=${ue_idx} with ${rtp_codec}...
    Start dl traffic with multiple trfids    ${ue_idx}    ${pdu_id}   ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic Receiver*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ue=${ue_idx} ${output} VoNR_DL_traffic_data_is_started_successfully
    BuiltIn.Log       ue=${ue_idx} VoNR_DL_traffic_data_is_started_successfully
	END
	sleep       10s
	BuiltIn.Log       All_ue_started_DL_VoNR_traff_succesfully
	Log to Console    All_ue_started_DL_VoNR_traff_succesfully

Start dl traffic with multiple trfids
    [Arguments]    ${ue_idx}    ${pdu_id}    ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    FOR     ${traffic_id}   IN RANGE    ${1}    ${num_trf_id}+1
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    trf_id=${traffic_id}    rtp_codec=${rtp_codec}
    ...     rtp_ps=900 period_ms=10 rtp_voice_silence=200:1 rtp_send_silence_period=10 rtp_silence_ps=900
    END

Start ul traffic with multiple trfids
    [Arguments]    ${ue_idx}    ${pdu_id}    ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    FOR     ${traffic_id}   IN RANGE    ${1}    ${num_trf_id}+1
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    trf_id=${traffic_id}    rtp_codec=${rtp_codec}
    ...     rtp_ps=900 period_ms=10 rtp_voice_silence=200:1 rtp_send_silence_period=10 rtp_silence_ps=900
    END

Trigger MultiUE VoNR UL Traffic with multiple trfids
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${pdu_id}=1     ${num_trf_id}=1
	...     ${qfi_id}=1   ${rtp_codec}=custom
    [Documentation]    This keyword starts the VoNR UL Traffic for the SA variant having some rtp codec
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning VoNR UL Traffic for ue=${ue_idx} with ${rtp_codec}...
    Start ul traffic with multiple trfids    ${ue_idx}    ${pdu_id}   ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*      timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ue=${ue_idx} ${output} VoNR_UL_traffic_data_is_started_successfully
    BuiltIn.Log       ue=${ue_idx} VoNR_UL_traffic_data_is_started_successfully
	END
	sleep       10s
	BuiltIn.Log       All_ue_started_UL_VoNR_traff_succesfully
	Log to Console    All_ue_started_UL_VoNR_traff_succesfully

Verify lamode and mcstable HR DRB added after CG DRB_1
    [Arguments]   ${FolderName}    ${UE_crnti_list}
    ${rc}    SplitK9425verify     dlFdSchedData    ${UE_crnti_list}[0]     ${FolderName}/output_ul_formated.csv
    Should Contain	${rc}	PASS

Verify lamode and mcstable HR DRB added after CG DRB_2
    [Arguments]   ${FolderName}    ${UE_crnti_list}
    ${rc}    SplitK9425verify_vonr_rel     dlFdSchedData    ${UE_crnti_list}[0]     ${FolderName}/output_ul_formated.csv
    Should Contain	${rc}	PASS

MultiUE Register should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}
