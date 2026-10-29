*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS24R1    CONFIGURED

Documentation
...             author:                 vaibhav.3.tyagi@nokia.com
...             maintainer:             vaibhav.3.tyagi@nokia.com
...
...             INTRODUCTION:      This user scenario describes the gNB behaviour for the successful interaction
...                                of Configured Grants Type2 configuration with link adaptation for high reliability
...                                in UL where UL-64QAMLowSE table is not capable and CG type2 DRB release

...             TEST SET NAME:     CB008246_J5_1_UE_capable_of_64QAMLowSE-table_in_UL_CG_DRB_HR_configured
...             TESTING SPLIT:     See CB008246-J testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-J CFAM
...

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008246_resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/ssh_command.py     WITH NAME       ssh_cmd

Suite Setup         Run keywords    Run Keyword and Ignore Error    Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_Config_scf_J4_1_UE-64QAMLowSE_UL_CGRel.json
...                 AND     Add RD Parameters To GNB Swconfig File      0x58057A=0x4
...                 AND     Add RD Parameters To GNB Swconfig File      0x58057E=0x200
...                 AND     Add RD Parameters To GNB Swconfig File      0x58057F=0x680
...                 AND     sleep    1s
...                 AND     gnb.Perform gNB reboot
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Start Log    btslog
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Stop Log    btslog
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport


*** Variables ***
${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_J4_1_UE-64QAMLowSE_UL_CGRel.cfg
${IPHY_FILE}         ${CURDIR}/config/wts/iphy.xml
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
${st_ue_id}      1
${en_ue_id}      1


*** Test Cases ***
[1]CB008246_J5_1_UE_capable_of_64QAMLowSE-table_in_UL_CG_DRB_HR_configured
    log to console   UE attach trigerring now...
    ${crnti_list_SA_HR}=      MultiUE Register should be Successful fixed    1      1      enhancedSkipUplinkTxConfigured*
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}     ${en_ue_id}     Traffic_rate=mbps   ul_rate=1
    ...   trf_id=${TRF_ID}
    sleep    2s
    Start Log      cprt
    Start Log      ttitrace
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
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
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


