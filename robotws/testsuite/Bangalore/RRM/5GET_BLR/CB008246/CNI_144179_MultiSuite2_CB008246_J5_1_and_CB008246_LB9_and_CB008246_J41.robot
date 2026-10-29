*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    VARIANT_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...               RAN_5G_FDD    RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation    :copyright: Nokia
...             author:                 vaibhav.3.tyagi@nokia.com
...             maintainer:             vaibhav.3.tyagi@nokia.com
...             INTRODUCTION:      This user scenario describes the gNB behaviour for the successful interaction
...                                of Configured Grants Type2 configuration with link adaptation for high reliability
...                                in UL where UL-64QAMLowSE table is not capable and CG type2 DRB release
...             TEST SET NAME:     CB008246_J5_1_UE_capable_of_64QAMLowSE-table_in_UL_CG_DRB_HR_configured
...             TESTING SPLIT:     See CB008246-J testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-J CFAM
...
...             author:                 vaibhav.3.tyagi@nokia.com
...             maintainer:             vaibhav.3.tyagi@nokia.com
...             INTRODUCTION:      This user scenario is aimed at verifying the TDD IWK between 5GC002271-B#1
...                                (that DTX received for the initial transmission which UE skipped against proactive
...                                uplink grant are not counted in initial transmission counters) & CB008246-I#2
...                                ( Scheduling of 5G UE with multiple non-GBR High Reliability DRBs in UL where
...                                UE does not support ?Ul-64QAM-MCS-TableAlt?.)
...             TEST SET NAME:     CB008246-L High reliability support in PDCCH and Counter Validation
...             TESTING SPLIT:     See CB008246-L testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-L CFAM
...
...             author:                 ishan.sharma@nokia.com
...             maintainer:             ishan.sharma@nokia.com
...             INTRODUCTION:      This user scenario describes the gNB behaviour for the successful interaction
...                                of Configured Grants Type2 configuration with link adaptation for high reliability
...                                in UL where UL-64QAMLowSE table is not capable and CG type2 DRB release
...             TEST SET NAME:     CB008246_J_B4_1_UE_capable_of_64QAMLowSE_table_in_UL_CG_DRB_release
...             TESTING SPLIT:     See CB008246-J testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-J CFAM


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          taf.rfrl.utilities.utf_lab.ute_utf_lab.UteUtfLab  WITH NAME  ute_utf_lab
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008246_resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/ssh_command.py     WITH NAME       ssh_cmd

Suite Teardown   Run Keyword and Ignore Error    Get Sos Report

*** Variables ***
#CommonVariables
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
@{Component1}   L2PS

#Suite_1
${wts_cfg_file_J5_1}    ${CURDIR}/config/wts/basic_setup_J4_1_UE-64QAMLowSE_UL_CGRel.cfg
${IPHY_FILE_J5_1}         ${CURDIR}/config/wts/iphy.xml

#Suite_2
${wts_cfg_file_LB9}    ${CURDIR}/config/wts/CG_jb31.cfg
${wts_cfg_file_LB9_RJIO}    ${CURDIR}/config/wts/CG_jb31_RJIO.cfg
${IPHY_FILE_LB9}         ${CURDIR}/config/wts/iphy.xml

${nsa_st_ue_id}    11
${nsa_en_ue_id}    12

#Suite_3
#${wts_cfg_file_J41}    ${CURDIR}/config/wts/basic_setup_J4_1_UE-64QAMLowSE_UL_CGRel.cfg
${wts_cfg_file_J41_RJIO}    ${CURDIR}/config/wts/basic_setup_J4_1_UE-64QAMLowSE_UL_CGRel_RJIO.cfg
${IPHY_FILE_J41}         ${CURDIR}/config/wts/iphy.xml
${qos_flow_del}    Deleting QosFlow with QFI:2 5QI:9
${Pdu_session_del_patten}      Deleting QosFlow with QFI:2 5QI:9



*** Test Cases ***
[1]CB008246_J5_1_UE_capable_of_64QAMLowSE-table_in_UL_CG_DRB_HR_configured
    [Tags]  TC01
    [Setup]    Run keywords   BuiltIn.Set Suite Variable    ${SCFC}
    ...            testsuite/Bangalore/RRM/5GET_BLR/CB008246/config/SCF/default_Setup_SCF.xml
    ...     AND    BuiltIn.Set Suite Variable     ${AP_XML}
    ...            testsuite/Bangalore/RRM/5GET_BLR/CB008246/config/wts/default_Setup_iphy.xml
    ...                 AND    Prepare TL with all config files
    ...                 AND     sleep    180s
    ...                 AND     Run Keyword and Ignore Error    Suite setup from scratch
    ...                 AND     Perform SCF Delta Commissioning with Delta_Config_scf_J4_1_UE-64QAMLowSE_UL_CGRel.json
    ...                 AND     Add RD Parameters To GNB Swconfig File      0x58057A=0x4
    ...                 AND     Add RD Parameters To GNB Swconfig File      0x58057E=0x200
    ...                 AND     Add RD Parameters To GNB Swconfig File      0x58057F=0x680
    ...                 AND     sleep    1s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file_J5_1}
    ...                 AND     Start Log    btslog
    ...                 AND     Check gNB Bulid

    log to console   UE attach trigerring now...
    ${crnti_list_SA_HR}=      MultiUE Register should be Successful fixed    1      1      enhancedSkipUplinkTxConfigured*
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}     ${en_ue_id}     Traffic_rate=mbps   ul_rate=1
    ...   trf_id=${TRF_ID}
    sleep    2s
    Start Log      cprt
#    Start Log      ttitrace
    MultiUE PDU Modfication should be Successful     1    1      pdu_id=1      qosflows_to_add=8
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}     ${en_ue_id}     Traffic_rate=mbps   ul_rate=1
    ...   trf_id=${TRF_ID}   qfi_id=2
    sleep    2s
    ${path_cprt_cqi131}    Stop Log      cprt     test_scenario=cprt_cqi131
    Start Log      cprt
    ${csrnti_list_SA_HR}=      MultiUE PDU Modfication should be Successful for CG DRB     1    1      pdu_id=1
    ...      qosflows_to_add=7
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}     ${en_ue_id}     Traffic_rate=mbps   ul_rate=1
    ...   trf_id=${TRF_ID}   qfi_id=3
    sleep    15s
    Start Log      ttitrace
    sleep    2s
    ${path_ttitrace_cqi13}    Stop log      ttitrace    test_scenario=ttitrace_cqi13
    ${path_cprt_cqi132}    Stop Log      cprt     test_scenario=cprt_cqi132
    MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
    log to console    ${path_ttitrace_cqi13}
    Verify CB008246 Parameters     ${path_cprt_cqi131}[cprt]     itf_l2_ps_cellconfigmodifyparam_t
    ...     itf_l2_ps_pusch_PuschConfig.mcsTable
    Verify CB008246 Parameters     ${path_cprt_cqi132}[cprt]     nr-rrc.configuredGrantConfig     nr-rrc.mcs_Table
    Decode TTI Trace    ttitrace_cqi13
    ${cg_val}     Create list    physCellId    sfn    slot    rnti    csRnti
    verification for CG    ${path_ttitrace_cqi13}[ttitrace]/output_ul_formated.csv
    ...     ulConfiguredGrantType2Data    50    ${cg_val}


    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...         AND        Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND        Stop Log    btslog      snapshot     sosreport
    ...                 AND        Link SCOUT SCF to Configuration ID for Reporting

[1]CB008246_L_B91_HR_LA_interworking_for_PM_counter_aligned_5GC002271_1
    [Tags]     TC02
    [Setup]    Run keywords   BuiltIn.Set Suite Variable    ${SCFC}
    ...            testsuite/Bangalore/RRM/5GET_BLR/CB008246/config/SCF/default_Setup_SCF.xml
    ...     AND    BuiltIn.Set Suite Variable     ${AP_XML}
    ...            testsuite/Bangalore/RRM/5GET_BLR/CB008246/config/wts/default_Setup_iphy.xml
#    ...                 AND    Prepare TL with all config files
#    ...                 AND     sleep    180s
    ...                 AND     Run Keyword and Ignore Error    Suite setup from scratch
    ...                 AND     Perform SCF Delta Commissioning with Delta_CB008246_LB91_RJIO.json
#    ...                 AND     Find Scfc And Fix And Send Full Commissioning
#    ...                         scfc_filename=LB_4_2271.xml
    ...                 AND     Add RD Parameters To GNB Swconfig File      0x58057A=0x4
    ...                 AND     Add RD Parameters To GNB Swconfig File      0x58057E=0x200
    ...                 AND     Add RD Parameters To GNB Swconfig File      0x58057F=0x680
    ...                 AND     sleep    1s
    ...                 AND     Update bsr package
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file_LB9_RJIO}
    ...                 AND     Start Log    btslog

    log to console   UE attach trigerring now...

    ${crnti_list_SA_HR}=      MultiUE Register should be Successful fixed    1      1     enhancedSkipUplinkTxConfigured*
    MultiUE Trigger DL Traffic for SA   ${st_ue_id}     ${en_ue_id}     Traffic_rate=mbps   dl_rate=10
    ...   trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}     ${en_ue_id}     Traffic_rate=mbps   ul_rate=10
    ...   trf_id=${TRF_ID}
    Start Log      ttitrace
    sleep    2s
    ${path_ttitrace_cqi13}    Stop log      ttitrace    test_scenario=ttitrace_cqi13
    log to console    ${path_ttitrace_cqi13}

    MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
    Decode TTI Trace    ttitrace_cqi13

    Verify lamode and mcstable after CG DRB is released    ${path_ttitrace_cqi13}[ttitrace]
    ...                                                  ${crnti_list_SA_HR}     ${crnti_list_SA_HR}

    ${skg_val}     Create list    physCellId    sfn    slot    rnti    ulProGrantType
    verification for 2271      ${path_ttitrace_cqi13}[ttitrace]/output_ul_formated.csv
    ...     ulFdSchedData    50    ${skg_val}

    [Teardown]     Run Keywords
    ...                 Log To console  Suitetardown
    ...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND     Stop Log    btslog
    ...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport
    ...                 AND     Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] [1]CB008246_J4_1_LA_for_HR_feature_interworking_with_CG2_in_UL_while_UE_is_in_CG_Type2
    [Tags]    TC03
    [Setup]    Run keywords     Run Keyword and Ignore Error    Suite setup from scratch
    ...                 AND     Perform SCF Delta Commissioning with Delta_Config_scf_J4_1_UE-64QAMLowSE_UL_CGRel_RJIO.json
    ...                 AND     sleep    1s
    ...                 AND     Update bsr package
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file_J41_RJIO}
    ...                 AND     Start Log    btslog

    log to console   UE attach trigerring now...

    ${crnti_list_SA_HR}=      MultiUE Register should be Successful fixed    1      1      enhancedSkipUplinkTxConfigured*
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}     ${en_ue_id}     Traffic_rate=mbps   ul_rate=1
    ...   trf_id=${TRF_ID}


    ${csrnti_list_SA_HR}=      MultiUE PDU Modfication should be Successful for CG DRB     1    1      pdu_id=1      qosflows_to_add=7
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}     ${en_ue_id}     Traffic_rate=mbps   ul_rate=1
    ...   trf_id=${TRF_ID}   qfi_id=2

    Start Log      ttitrace
    MultiUE PDU Modfication should be Successful     1    1      pdu_id=1      qosflows_to_add=8
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}     ${en_ue_id}     Traffic_rate=mbps   ul_rate=1
    ...   trf_id=${TRF_ID}   qfi_id=3
    sleep    1s
    ${path_ttitrace_CGHRDRB}    Stop log      ttitrace    test_scenario=ttitrace_CGHRDRB
    log to console    ${path_ttitrace_CGHRDRB}

    Start Log      cprt

    MultiUE PDU Deletion should be Successful     1    1      pdu_id=1      qosflows_to_del=7
    Start Log      ttitrace
    sleep       2s
    ${path_ttitrace_CGRel}    Stop log      ttitrace    test_scenario=ttitrace_CGRel
    ${path_cprt_cqi13}    Stop Log      cprt     test_scenario=cprt_cqi13
    log to console    ${path_ttitrace_CGRel}

    Decode TTI Trace    ttitrace_CGHRDRB
    sleep       20s
    Decode TTI Trace    ttitrace_CGRel

    Verify lamode and mcstable HR DRB added after CG DRB    ${path_ttitrace_CGHRDRB}[ttitrace]
    ...                                                  ${crnti_list_SA_HR}    ${csrnti_list_SA_HR}
    Verify lamode and mcstable after CG DRB is released    ${path_ttitrace_CGRel}[ttitrace]
    ...                                                  ${crnti_list_SA_HR}    ${csrnti_list_SA_HR}

    [Teardown]     Run Keywords     Log To console  Suitetardown
    ...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND     Stop Log    btslog
    ...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport


*** Keywords ***
#keywords_of_CB008246_J5_1
MultiUE PDU Modfication should be Successful for CG DRB
    [Arguments]     ${start_ue_id}    ${end_ue_id}     ${pdu_id}=${Pdu_session_ID}      ${qosflows_to_add}=${Q_O_ADD}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_pdu_session_modify      ue=${ue_idx}       pdu=${pdu_id}    qosflows_to_add=${qosflows_to_add}    by=amf
    ${output}    Read WTS Output Until Pattern Matches    ${Pdu_session_qos_patten}     ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Pdu_session_mod_patten}
    Create File	    ${OUTPUT_DIR}/csrnti.txt	    ${output}
    sleep    1s
    ${csrnti_string}=    Run     cat ${OUTPUT_DIR}/csrnti.txt |grep -i "cs-RNTI setup" |awk '{print $4}'|cut -d ',' -f 1
    BuiltIn.Log               ue=${ue_idx} qosflow=${qosflows_to_add} added
	Log to Console            ue=${ue_idx} qosflow=${qosflows_to_add} added
    END
    BuiltIn.Log       All_ue_added_an_extra_qosflow_successfully
	Log to Console    All_ue_added_an_extra_qosflow_successfully
	[Return]      ${csrnti_string}

#keywords_of_CB008246_J41
MultiUE PDU Deletion should be Successful
    [Arguments]     ${start_ue_id}    ${end_ue_id}     ${pdu_id}=${Pdu_session_ID}      ${qosflows_to_del}=${Q_O_DEL}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_pdu_session_modify      ue=${ue_idx}       pdu=${pdu_id}    qosflows_to_del=${qosflows_to_del}    by=amf
    ${output}    Read WTS Output Until Pattern Matches    ${qos_flow_del}     ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Pdu_session_del_patten}
    BuiltIn.Log               ue=${ue_idx} qosflow=${qosflows_to_del} deleted
    Log to Console            ue=${ue_idx} qosflow=${qosflows_to_del} deleted
    END
    BuiltIn.Log       All_ue_deleted_an_extra_qosflow_successfully
    Log to Console    All_ue_deleted_an_extra_qosflow_successfully

Verify lamode and mcstable HR DRB added after CG DRB
    [Arguments]   ${FolderName}    ${UE_crnti_list}    ${UE_csrnti_list}
    ${rc}    CGJ4verify     ulFdSchedData    ${UE_crnti_list}     ${UE_csrnti_list}     ${FolderName}/output_ul_formated.csv
    Should Contain	${rc}	PASS

Verify lamode and mcstable after CG DRB is released
    [Arguments]   ${FolderName}    ${UE_crnti_list}    ${UE_csrnti_list}
    ${rc}    CG_release_J4verify_HR_UE     ulFdSchedData    ${UE_crnti_list}     ${UE_csrnti_list}     ${FolderName}/output_ul_formated.csv
    Should Contain	${rc}	PASS

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin
