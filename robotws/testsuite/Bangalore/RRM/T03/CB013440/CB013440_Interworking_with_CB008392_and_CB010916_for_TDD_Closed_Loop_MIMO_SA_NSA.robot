*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             SBTS00   CONFIGURED   5G_RAN   RAN_5G   RAN_5G_TDD   5G_RAN_TDD   CRT   195303

Documentation
...
...      author:            Geetha    geetha.k_r@nokia.com
...      maintainer:        Geetha    geetha.k_r@nokia.com
...
...      INTRODUCTION:    verify Load Based MIMO Muting CB008392 functionality works correctly with CB013440 when Antenna port
...      remapping 5G CB010916 is not activated in both SA and NSA with enhanced broadcast and control channel transmission (CB013440)
...      using 2TX for SSB, TRS, cell specific PDCCH,and cell specific PDSCH, and PMI-LI based precoding for UE specific PDCCH.
...      TEST SET NAME:  ET - CB013440 Enhanced Broadcast and Control Channel Transmission for non-BF cells


...             Requirement id -

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library          ta_emss
Library          ta5g_pm_counters
Resource         ../../5GET_BLR/CB008541/resources/CB008541_Keywords.robot
Resource	     ../../5GET_BLR/CB008278/resources/common_CA.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Library          taf.sw.scout    WITH NAME     scout
Library          resources/check.py
Library          ../../5GET_BLR/resources/python/BIP_Capture.py

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with CB008392_enable.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1    1
...                 AND     Check gNB Bulid


Suite Teardown      Run keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

Test Teardown      Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_C.cfg
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}            1
${nwslice_ID}     1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${epc_log_path}    /tmp/
${AP_XML}=         ${CURDIR}/config/iphy_AZQU.xml
${crnti_UE1}      ue_crnti
${UE_ID_NSA}      101
${Target_Cells}      1
${exp_precoding}        255
${exp_precoding_SIB}        1 #SCDD
${exp_transscheme}      1
${exp_pdcch_precoding_Msg2}    2


*** Test Cases ***
[1]USCB013440-C_B1_3_Verification_of_CB013440_Interworking_with_CB008392(Enabled)_and_CB010916(Disabled)_for_TDD_Closed_Loop_MIMO_SA+NSA
    [Documentation]    This test case verifies that Load Based MIMO Muting CB008392 functionality works correctly with CB013440 when
    ...                Antenna port remapping 5G CB010916 is not activated.
    ...                Specifically, it checks that the gNB mutes the correct antenna ports.
    set test variable      ${LOG_PATH}
    Register SA ue and move to reducedEnergySaving state
    Register NSA ue and move to reducedEnergySaving state

*** Keywords ***
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
    ...      (((dldata_pdcchsendreql1sw)) && (DlData_DciInfoL1sw.pdcchPrecodingOption4x4 == 1)) && (3gpp.subcellid == 0)
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
    ...      ((dldata_pdcchsendreql1sw) && (DlData_DciInfoL1sw.pdcchPrecodingOption4x4 == 2)) && (DlData_DciInfoL1sw.rachStatus)
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

Verify current highest Rank Indicator for UE
    [Arguments]  ${max_expected_rank}    ${rnti}      ${file_name}
    Start Log      ttitrace
    BuiltIn.Sleep    2s
    ${TTI_Logs}    Stop Log       ttitrace   test_scenario=${file_name}
    Decode TTI Trace    ${file_name}
    Verify highest rank
    ...     max_expected_rank=${max_expected_rank}
    ...     rnti=${rnti}
    ...     file_name=${TTI_Logs}[ttitrace]/output_dl_formated.csv

Verify if cell entered in ${state} state
    BuiltIn.Sleep  120s
    run keyword and ignore error    Object Attributes Should Be  NRCELL-1  energySavingState=${state}


NSA Multi UE Attach should be Successful
    [Arguments]    ${Start_NSA_UE}    ${END_NSA_UE}     ${Target_Cells}
    FOR  ${UE}  IN RANGE    ${Start_NSA_UE}    ${END_NSA_UE}+1
       ${crnti_value}    NSA LTE Attach should be Successful    ${UE}
       NSA UE Attach should be Successful    ${UE}    ${Target_Cells}
    END
    [Return]    ${crnti_value}

NSA LTE Attach should be Successful
    [Arguments]    ${NSA_UE_ID}
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ${ue_attach_cmd}	SET VARIABLE	ue_attach id=${NSA_UE_ID}
    ${crnti_list}     Create List
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data   ${ue_attach_cmd}	pass_regexp=${LTE_attach_pattern}    timeout=${Timeout_NSA}
    BuiltIn.Log    lte_attach_is_ok
    Create File     ${OUTPUT_DIR}/regst_nsa.txt     ${output}
    ${x}    Set Variable    grep 'UEC-1: UE${NSA_UE_ID}: UE performed EPS_ATTACH'
    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst_nsa.txt|${x}|awk -F 'crnti: ' '{print $2}'|awk -F ' = ' '{print$1}'
    BuiltIn.Log     ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}
	[Return]    ${crnti_value}


Register SA ue and move to reducedEnergySaving state
    Start Log    biptaf
    ${crnti_UE1}   	wts_sim_keywords.UE Register should be Successful And Fetch RNTI     1       1       1       1
    set test variable      ${crnti_UE1}
	wts_sim_keywords.Trigger DL Traffic for SA      1      mbps     5     1      1      1
	${attachSANSA}    Stop Log     biptaf    test_scenario=attach_SANSA
	BuiltIn.Sleep      50s
	Verify if cell entered in reducedEnergySaving state
	run keyword and ignore error      Verify current highest Rank Indicator for UE
    ...  max_expected_rank=RANK2
    ...  rnti=${crnti_UE1}
    ...  file_name=SA_reducedenergysaving
    Verifying MIB with CB013440 Enabled      ${attachSANSA}
    Verifying SIB with CB013440 Enabled     ${attachSANSA}
    Verifying MSG2    ${attachSANSA}

Register NSA ue and move to reducedEnergySaving state
    Start Log    biptaf
    NSA X2AP Link Should be UP      1     2
    ${crnti_UE1}     NSA Multi UE Attach should be Successful      101      101      1
    set test variable      ${crnti_UE1}
    wts_sim_keywords.Trigger DL Traffic for NSA      101      mbps      5      1      1
    ${attachSANSA}    Stop Log     biptaf    test_scenario=attach_SANSA
    BuiltIn.Sleep      120s
	Verify if cell entered in reducedEnergySaving state
    Verifying MIB with CB013440 Enabled      ${attachSANSA}
    Verifying MSG2    ${attachSANSA}