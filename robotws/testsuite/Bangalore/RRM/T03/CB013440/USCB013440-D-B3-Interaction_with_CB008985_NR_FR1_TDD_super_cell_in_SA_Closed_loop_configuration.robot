*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             SBTS00   CONFIGURED   5G_RAN   RAN_5G   RAN_5G_TDD   5G_RAN_TDD   CRT   195302

Documentation
...
...      author:            Prapulla    prapulla.bt@nokia.com
...      maintainer:        Prapulla    prapulla.bt@nokia.com
...
...      INTRODUCTION:    Verify the interoperability of NR FR1 TDD super cell functionality (CB008985) in SA mode
...      with enhanced broadcast and control channel transmission (CB013440) using 2TX for SSB, TRS, cell specific PDCCH,
...      and cell specific PDSCH, and PMI-LI based precoding for UE specific PDCCH.
...      TEST SET NAME:  CB013440-CB013440 Enhanced Broadcast and Control Channel Transmission for non-BF cells
...      Requirement id -

Resource          ../../5GET_BLR/resources/robot/common_log_collection.robot
Resource          ../../5GET_BLR/resources/robot/wts_sim_keywords.robot
Resource          ../../5GET_BLR/5GC000937/resources/5GC000937_Keywords.robot
Library          taf.sw.scout    WITH NAME     scout
Library          ../../5GET_BLR/resources/python/BIP_Capture.py
Library          taf.analyzer.pdml    WITH NAME    taf_pdml_analyser
Library          taf.analyzer.pcap    WITH NAME    parser
Library          ta5g_pm_counters


Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1    1

Suite Teardown    Run Keywords    wts_sim_keywords.Clean edaemon and egate
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

Test Teardown      Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_D_B3.cfg
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}            1
${UE_ID1}           1
${UE_ID2}           2
${UE_ID_NSA1}            11
${UE_ID_NSA2}            12
${nwslice_ID}     1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${beam_profile_id}       1
@{syslog_regex_bwp}     DCI11   DCI01
${Beam_switch_0_1}    Old Beam: 0 New Beam: 1
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving
${SCFC}=           ${CURDIR}/config/Scf_D_B3.xml
${AP_XML}=         ${CURDIR}/config/iphy_AKQJ.xml
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_SCN1.csv
@{crnti_list}
${exp_precoding}        255
${exp_precoding_SIB}        1 #SCDD
${exp_transscheme}      1
${exp_pdcch_precoding_Msg2}    2
*** Test Cases ***
[1]USCB013440-D-B3-Interaction with CB008985 NR FR1 TDD super cell in SA Closed loop configuration
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Check Feature Activation Msg in BIP log
    Create BeamForming profile attach SANSA UE and trigger data
    Verify Counters before Beamswitch
    Beam Switch to Beam1
    Verify Counters after Beamswitch
	wts_sim_keywords.MultiUE Deregister should be Successful   ${UE_ID1}   ${UE_ID2}
	wts_sim_keywords.NSA Multi UE Detach should be Successful    ${UE_ID_NSA1}    ${UE_ID_NSA2}

*** Keywords ***
Create BeamForming profile attach SANSA UE and trigger data
    Start Log    cprt    biptaf    btslog
	Beam Profile Creation
	Activate Beam profile    ${UE_ID1}     ${UE_ID2}    1
	wts_sim_keywords.MultiUE Register should be Successful    ${UE_ID1}     ${UE_ID2}
	wts_sim_keywords.MultiUE Trigger DL Traffic for SA    ${UE_ID1}    ${UE_ID2}   mbps    175
	Sleep    2s
	wts_sim_keywords.Validate DL Traffic For MultiUE SA  ${UE_ID1}    ${UE_ID2}    dl_rate=175     qfi_id=${QFI_ID}
	Activate Beam profile    ${UE_ID_NSA1}    ${UE_ID_NSA2}    1
	Sleep    2s
	Attach All NSA Ues and fetch RNTI    ${UE_ID_NSA1}    ${UE_ID_NSA2}
    wts_sim_keywords.MultiUE Trigger DL Traffic for NSA    ${UE_ID_NSA1}    ${UE_ID_NSA2}   mbps    150
    Sleep    2s
    wts_sim_keywords.Validate DL Traffic For MultiUE NSA    ${UE_ID_NSA1}     ${UE_ID_NSA2}    dl_rate=150
    sleep    2s
    ${attachSANSA}    Stop Log    btslog    cprt    biptaf    test_scenario=attach_SANSA
    Verifying MSG2    ${attachSANSA}

Check Feature Activation Msg in BIP log
    Start Log     biptaf
    sleep  5s
    ${MIB_SIB}    Stop Log    biptaf    test_scenario=mib_sib
    Verifying MIB with CB013440 Enabled     ${MIB_SIB}
    Verifying SIB with CB013440 Enabled     ${MIB_SIB}

Beam Switch to Beam1
    Beamcontrol Beam Switch    ${UE_ID1}    ${UE_ID2}

Beam Profile Creation
    ute_wtssim.Execute Egate Command
    ...    cmd=beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ute_wtssim.Execute Egate Command
    ...    cmd=beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-50

Activate Beam profile
     [Arguments]       ${startue}    ${endue}    ${prfileid}
     FOR    ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
     ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=${ue_idx} testmode=beam_control action=activate profile_id=${prfileid} beamaction=attach scell=0
	 ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=${ue_idx} testmode=beam_control action=activate profile_id=${prfileid} beamaction=attach scell=0
     END

Beamcontrol Beam Switch
    [Arguments]    ${startue}=1    ${endue}=1    ${beam_profile_id}=2     ${scell_idx}=0     ${best_beam}=1
    Log to Console    Changing Beam   ${best_beam}
    FOR    ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
    ${ue_switch_cmd}	 catenate    SEPARATOR=${SPACE}
    ...    ue_testmode_set_nr id=${ue_idx} testmode=beam_control action=activate profile_id=${beam_profile_id}
    ...    beamaction=switch scell=${scell_idx}
     ute_wtssim.Execute Egate Command And Wait For Data  ${ue_switch_cmd}   pass_regexp=${Beam_switch_0_1}
    ...     timeout=${EGATE_COMMAND_TIMEOUT}

    wts_sim_keywords.Validate DL Traffic For SA   ue_id=${ue_idx}     dl_rate=175     qfi_id=${QFI_ID}
    END

Attach All NSA Ues and fetch RNTI
    [Arguments]    ${UE_ID_NSA1}    ${UE_ID_NSA2}
    FOR   ${UE}    IN RANGE    ${UE_ID_NSA1}    ${UE_ID_NSA2}+1
    ${rnti}    NSA LTE Attach should be Successful    ${UE}
    Append To List  ${crnti_list}    ${rnti}
    END

Validate Supercell enabled
    [Arguments]    ${log_path}
    ${status} =   run    command=sudo cat ${log_path}/gnb_syslog.log | grep "Supercell is enabled"
    Builtin.Log   ${status}
    Should Not Be Empty    ${status}
    Should Match Regexp    ${status}    Supercell is enabled

Verify Counters before Beamswitch
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55305C00001    >0     DL_SERV_BEAM_ID_BEAM_00
    ...     M55305C12001    >0     Number_of_UEs_per_beam-Beam_ID_0
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

Verify Counters after Beamswitch
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55305C00002    >0     DL_SERV_BEAM_ID_BEAM_01
    ...     M55305C12002    >0     Number_of_UEs_per_beam-Beam_ID_1
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

Verifying MIB with CB013440 Enabled
    [Arguments]    ${path_NSA}
    ${pdmlFile}=    analyzer.pcap_to_pdml    ${path_NSA}[biptaf]/BIP_L1L2.pcap
    ...      (dldata_ssblocksendreql1sw) && (3gpp.subcellid == 0)
    Log to Console    ***MIB Validation***
    ${path_cu} =   Catenate  SEPARATOR=  icom_5g/nr_l1dl_l2ps/dldata_ssblocksendreql1sw/
    ...  nr_l1dl_l2ps_dldata_ssblocksendreql1sw_t/DlData_SsBlockSendReqL1sw_t.precodingVectorIndex
    ${packet}    set variable    DlData_SsBlockSendReqL1sw_t.precodingVectorIndex
    Log to Console   ${packet}
    ${precoding_vector}   analyzer.get_unique  pdmlFile=${pdmlFile}
    ...                               packetName=${packet}
    ...                               path=${path_cu}
    ...                               endPacket=1
    Log to Console   ${precoding_vector}
    Run Keyword if   ${precoding_vector} !=${exp_precoding}   Fail   Precoding check failed
    ...         else    Pass     Precoding check passed

    ${path_cu} =   Catenate  SEPARATOR=  icom_5g/nr_l1dl_l2ps/dldata_ssblocksendreql1sw/
    ...  nr_l1dl_l2ps_dldata_ssblocksendreql1sw_t/DlData_SsBlockSendReqL1sw_t.enhTransScheme
    ${packet}    set variable    DlData_SsBlockSendReqL1sw_t.enhTransScheme
    Log to Console   ${packet}
    ${trans_scheme}   analyzer.get_unique  pdmlFile=${pdmlFile}
    ...                               packetName=${packet}
    ...                               path=${path_cu}
    ...                               endPacket=1
    Run Keyword if   ${trans_scheme} !=${exp_transscheme}   Fail   CB013440 Disabled  failed
    ...         else    Pass   CB013440 Feature Enabled check passed

Verifying SIB with CB013440 Enabled
    [Arguments]    ${path_NSA}
    ${pdmlFile}=    analyzer.pcap_to_pdml    ${path_NSA}[biptaf]/BIP_L1L2.pcap
    ...      ((dldata_pdcchsendreql1sw) && (3gpp.subcellid == 0)) && (3gpp.rnti == 65535)
    Log to Console    ***SIB Validation***
    ${path_cu} =   Catenate  SEPARATOR=  icom_5g/nr_l1dl_l2ps/dldata_pdcchsendreql1sw/
    ...     nr_l1dl_l2ps_dldata_pdcchsendreql1sw_t/_/nr_l1dl_l2ps_dldata_dciinfol1sw/DlData_DciInfoL1sw.pdcchPrecodingOption4x4
    ${packet}    set variable    DlData_DciInfoL1sw.pdcchPrecodingOption4x4
    Log to Console   ${packet}
    ${precoding_vector}   analyzer.get_unique  pdmlFile=${pdmlFile}
    ...                               packetName=${packet}
    ...                               path=${path_cu}
    ...                               endPacket=1
    Log to Console   ${precoding_vector}
    Run Keyword if   ${precoding_vector} !=${exp_precoding_SIB}   Fail   Precoding SCDD failed
    ...         else    Pass     Precoding SCDD passed

Verifying MSG2
    [Arguments]    ${path_NSA}
    ${pdmlFile}=    analyzer.pcap_to_pdml    ${path_NSA}[biptaf]/BIP_L1L2.pcap
    ...      (DlData_DciInfoL1sw.rachStatus) && (3gpp.subcellid == 0)
    Log to Console    ***MSG2 Validation***
    ${path_cu} =   Catenate  SEPARATOR=  icom_5g/nr_l1dl_l2ps/dldata_pdcchsendreql1sw/
    ...     nr_l1dl_l2ps_dldata_pdcchsendreql1sw_t/_/nr_l1dl_l2ps_dldata_dciinfol1sw/DlData_DciInfoL1sw.pdcchPrecodingOption4x4
    ${packet}    set variable    DlData_DciInfoL1sw.pdcchPrecodingOption4x4
    Log to Console   ${packet}
    ${pdcch_precoding_Msg2}   analyzer.get_unique  pdmlFile=${pdmlFile}
    ...                               packetName=${packet}
    ...                               path=${path_cu}
    ...                               endPacket=1
    Log to Console   ${pdcch_precoding_Msg2}
    Run Keyword if   ${pdcch_precoding_Msg2} !=${exp_pdcch_precoding_Msg2}   Fail   Precoding RepitionOnexPolBeam failed
    ...         else    Pass     Precoding RepititionOnexPolBeam passed
