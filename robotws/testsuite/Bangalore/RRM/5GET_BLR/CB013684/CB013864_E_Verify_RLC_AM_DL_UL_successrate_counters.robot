*** Settings ***
Force Tags        CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED    TOOLS_PROFILE_TTI_LEGACY

Documentation        :copyright: Nokia
...                  :AUTHOR: Chaithanya H S and Shekhar
...                  :MAINTAINER contacts  chaithanya.h_s@nokia.com    shekhar.vijay_barewar@nokia.com
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Resource         ../CB008278/resources/common_CA.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/avg_dl_data.py
Library          OperatingSystem
Library          taf.sw.scout    WITH NAME     scout
Resource         ../../../resources/robot/counter_benchmark_resource.robot
Library           taf.analyzer.pmcounter    WITH NAME    analyser
Library           taf.hw.rf_attenuator.attenuator  WITH NAME  at
Library           taf.sw.dcap.rd     WITH NAME   dcap
Library           Collections
Library           String      WITH NAME   str
Library           ute_ue
Library           taf.collectors.pmcounters    WITH NAME    PM
#Resource         ../CB008370/CB008370_C_IWK2_9855_TC16.robot


Suite Setup         Run keywords   Prepare TL with all config files
...                 AND    Run Keyword and Ignore Error   Suite setup from scratch
...                 AND    Update GNB R&D Parameter
...                 AND    Configure eth3 IP
...                 AND    Log to console    Loading CFG
...                 AND    Load CFG and verify cell status   ${wts_cfg_file}    1    6


Test Teardown       Link SCOUT SCF to Configuration ID for Reporting

Suite Teardown      Run Keywords    Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

*** Variable ***
${wts_cfg_file}    ${CURDIR}/config/basic_setup_CB0163864_E.cfg
&{WTS}         Ip=127.0.0.1        Username=ute        Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${nwslice_ID}   1
${gw_ID}     1
@{scell_PhyId_list}    50    51    52    53
@{scell_PhyId_list_CB016384_E}     ${scell_PhyId_list}
${CC_NUMBER}    5
${Pdu_session_ID}    1
${QFI_ID}    1
${TRF_ID}    1
${Trf_rate_SA}  mbps
${DL_RATE}   100
${UL_RATE}   100
${UE_ID_CA}    1
${start_DL_trfids}  1
${end_DL_trfids}    12
${r&d_parameter}    0x5B0621=1;0x5b0226=1;0x5b0613=1
${SCFC}=           ${CURDIR}/config/CB013684_E_scf.xml
${AP_XML}=         ${CURDIR}/config/CB013684_E_iphy.xml
${target_dir}=    /home/ute/Desktop/
${counter_json_file}=    ${CURDIR}/config/counter_data.json
${host}=   192.168.255.129
${user}=   Nemuadmin
${password}=   nemuuser
${git_path}=   https://gitlabe1.ext.net.nokia.com/BTS_TOOLS/counter_benchmarking/-/blob/main/Bangalore/VRF_BLR1/T09/CB013684_Counter_Benchmking.xlsx


*** Test Cases ***
[1][2.0] CB013684_E_1_DL_RLC_ARQ_Success_Rates_for_RLC_AM_CAUE
     [Documentation]    This user scenario is aimed at verifying the counters for calculating DL and UL Initial AM RLC success rate and
     ...  Final AM RLC success rate. This US follows Req.ID 5G_PM_2188 for DL and 5G_PM_2189 for UL
	 ...  the expectation is all RLC AM TX and RX transmitted and recieved from and to gnb should have suuccessful ack for from and to gnb
     ...  defination of counters
     ...  DL
 	 ...  DL_RLC_AM_SDU_INI_TRANS_CA
     ...  This counter measures the number of transmitted RLC SDUs in RLC AM by initial transmission.
     ...  DL_RLC_AM_SDU_INI_TRANS_SUC_CA
     ...  This counter measures the successfully transmitted AM RLC SDUs by initial transmission, which are acknowledged by RLC ACK.
     ...  DL_RLC_AM_SDU_ANY_TRANS_SUC_CA
     ...  This counter measures the successfully transmitted AM RLC SDUs by any transmission, which are acknowledged by RLC ACK.
	 ...  UL
	 ...  UL_RLC_AM_SDU_RX_INI_TRANS_CA
     ...  This counter provides the total number of UL RLC SDUs received in RLC AM by initial transmission.
     ...  UL_RLC_AM_SDU_RX_TRANS_CA
     ...  This counter provides the total number of UL RLC SDUs received in RLC AM by any transmission.
     ...  UL_RLC_AM_SDU_RTX_INI_TRANS_CA
     ...  Number of successfully transmitted DL RLC AM SDUs by any transmission for DRBs in CA
     ...  So the following relation b/w the counters in DL and UL is expected.
     ...  DL relation
     ...  DL_RLC_AM_SDU_ANY_TRANS_SUC_CA = DL_RLC_AM_SDU_INI_TRANS_CA
     ...  DL_RLC_AM_SDU_ANY_TRANS_SUC = DL_RLC_AM_SDU_INI_TRANS
	 ...  UL relation
	 ...  UL_RLC_AM_SDU_RX_TRANS = UL_RLC_AM_SDU_RX_INI_TRANS + UL_RLC_AM_SDU_RETX_INI_TRANS
     ...  UL_RLC_AM_SDU_RX_TRANS_CA = UL_RLC_AM_SDU_RX_INI_TRANS_CA + UL_RLC_AM_SDU_RTX_INI_TRANS_CA
     ...  Above expectations for counter relations are scripted below in wrapper keywords.
     Set Test Variable    ${LOG_PATH}
     Start_Fetching_Counter_Values
     Run keyword and ignore error    Start Collecting Syslog     NAME=syslog_ue_attach
     UE Regristation with Scell Blind Addition and High Traffic with CA configured DRB followed by a BLER
     Validate Counters UL DL RLC AM trf success rate for UE's CA Configured DRB
     Add DRB with QoS 5qi-4 to Same UE which will act as not CA Configured DRB and run High Traffic
     Validate Counters UL DL RLC AM trf success rate for UE's not CA Configured DRB
     Run keyword and ignore error     Stop Collecting Syslog       NAME=syslog_ue_attach
     Stop_Fetching_Counter_Values
     Run Keyword And Continue On Failure    Collect_Counter_Logs      ${host}     ${user}      ${password}
	...     ${target_dir}    ${counter_json_file}         ${git_path}

*** Keywords ***
Update GNB R&D Parameter
    Get GNB Swconfig File    ${LOG_PATH}
    Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
    Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

Intiate Bler for Ues and activate with pktloss DL
    [Arguments]    ${startue}    ${endue}    ${pkt_loss}
    ${profile}	   SET VARIABLE
    ...   bler_testmode_nr profile_id=1 dl_bler=${pkt_loss}
    ute_wtssim.execute_egate_command    ${profile}
    FOR     ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
    ${activate}	   SET VARIABLE    ue_testmode_set_nr id=${ue_idx} testmode=bler profile_id=1 action=activate
    ute_wtssim.execute_egate_command    ${activate}
    END

Intiate Bler for Ues and activate with pktloss UL
    [Arguments]    ${startue}    ${endue}    ${pkt_loss}
    ${profile}	   SET VARIABLE
    ...   bler_testmode_nr profile_id=2 ul_bler=${pkt_loss}
    ute_wtssim.execute_egate_command    ${profile}
    FOR     ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
    ${activate}	   SET VARIABLE    ue_testmode_set_nr id=${ue_idx} testmode=bler profile_id=2 action=activate
    ute_wtssim.execute_egate_command    ${activate}
    END

UE Regristation with Scell Blind Addition and High Traffic with CA configured DRB followed by a BLER
    log to console   UE attach trigerring now...
    UE Register should be Successful     ${UE_ID_CA}
    Sleep    10s
    Verify SA All Scell PCIs With UE ID  ${UE_ID_CA}  ${scell_PhyId_list}  ${CC_NUMBER}
    FOR   ${i}  IN RANGE   1  3
        Trigger UL Data Traffic for SA with Sec  ue_id=${UE_ID_CA}  Trf_rate=mbps   ul_rate=175   pdu_id=1   trf_id=${i}  sec=600    qfi=1
        sleep   2s
    END
    FOR   ${i}  IN RANGE  1  6
        Trigger DL Data Traffic for SA with Sec  ue_id=${UE_ID_CA}  Trf_rate=mbps   dl_rate=175   pdu_id=1   trf_id=${i}  sec=600    qfi=1
        sleep   2s
    END
    Intiate Bler for Ues and activate with pktloss DL     startue=1   endue=1    pkt_loss=5
    Intiate Bler for Ues and activate with pktloss UL     startue=1   endue=1    pkt_loss=5
    sleep    5s

Validate Counters UL DL RLC AM trf success rate for UE's CA Configured DRB
    Set Suite Variable    ${UL_RLC_AM_SDU_RX_INI_TRANS}   1
    Set Suite Variable    ${DL_RLC_AM_SDU_INI_TRANS}    1
    Set Suite Variable    ${UL_RLC_AM_SDU_RX_INI_TRANS_sum_all_int}   0
    Set Suite Variable    ${UL_RLC_AM_SDU_RETX_INI_TRANS_sum_all_int}   0
    Set Suite Variable    ${UL_RLC_AM_SDU_RX_TRANS_sum_all_int}   0
    Set Suite Variable    ${UL_RLC_AM_SDU_RX_INI_TRANS_CA_sum_all_int}   0
	Set Suite Variable    ${UL_RLC_AM_SDU_RX_TRANS_CA_sum_all_int}   0
	Set Suite Variable	  ${UL_RLC_AM_SDU_RTX_INI_TRANS_CA_sum_all_int}    0
    Set Suite Variable    ${Overall_ANY_RX}    0
    Set Suite Variable    ${Overall_ANY_RX_CA}     0
    Set Suite Variable    ${DL_RLC_AM_SDU_INI_TRANS_sum_all_int}   0
    Set Suite Variable    ${DL_RLC_AM_SDU_ANY_TRANS_SUC_sum_all_int}   0
    Set Suite Variable    ${DL_RLC_AM_SDU_INI_TRANS_CA_sum_all_int}   0
    Set Suite Variable    ${DL_RLC_AM_SDU_ANY_TRANS_SUC_CA_sum_all_int}   0
    FOR   ${Interval}  IN RANGE   6
        Log to console    ${Interval} iteration ongoing....
        Exit For Loop If    ${UL_RLC_AM_SDU_RX_INI_TRANS} == 0 and ${DL_RLC_AM_SDU_INI_TRANS} == 0
        Wait until the next Measurement Period starts
        ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
        ${UL_RLC_AM_SDU_RX_INI_TRANS}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00075    moc=NRCELL-6
        ${UL_RLC_AM_SDU_RX_TRANS}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00076    moc=NRCELL-6
        ${UL_RLC_AM_SDU_RETX_INI_TRANS}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00077    moc=NRCELL-6
        ${UL_RLC_AM_SDU_RX_INI_TRANS_CA}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00078    moc=NRCELL-6
        ${UL_RLC_AM_SDU_RX_TRANS_CA}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00079    moc=NRCELL-6
	    ${UL_RLC_AM_SDU_RTX_INI_TRANS_CA}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00080    moc=NRCELL-6
	    Log to console    Ul Counters collected for ${Interval} interval successfuly
		${UL_RLC_AM_SDU_RX_INI_TRANS_sum_all_int}    Evaluate    ${UL_RLC_AM_SDU_RX_INI_TRANS}+${UL_RLC_AM_SDU_RX_INI_TRANS_sum_all_int}
        ${UL_RLC_AM_SDU_RX_TRANS_sum_all_int}    Evaluate    ${UL_RLC_AM_SDU_RX_TRANS}+${UL_RLC_AM_SDU_RX_TRANS_sum_all_int}
        ${UL_RLC_AM_SDU_RETX_INI_TRANS_sum_all_int}    Evaluate    ${UL_RLC_AM_SDU_RETX_INI_TRANS}+${UL_RLC_AM_SDU_RETX_INI_TRANS_sum_all_int}
        ${UL_RLC_AM_SDU_RX_INI_TRANS_CA_sum_all_int}    Evaluate    ${UL_RLC_AM_SDU_RX_INI_TRANS_CA}+${UL_RLC_AM_SDU_RX_INI_TRANS_CA_sum_all_int}
		${UL_RLC_AM_SDU_RX_TRANS_CA_sum_all_int}    Evaluate    ${UL_RLC_AM_SDU_RX_TRANS_CA}+${UL_RLC_AM_SDU_RX_TRANS_CA_sum_all_int}
		${UL_RLC_AM_SDU_RTX_INI_TRANS_CA_sum_all_int}    Evaluate    ${UL_RLC_AM_SDU_RTX_INI_TRANS_CA}+${UL_RLC_AM_SDU_RTX_INI_TRANS_CA_sum_all_int}
        Log to console    Ul Counters evalution for ${Interval} interval done successfully
		${DL_RLC_AM_SDU_INI_TRANS}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00069    moc=NRCELL-6
        ${DL_RLC_AM_SDU_INI_TRANS_SUC}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00070    moc=NRCELL-6
        ${DL_RLC_AM_SDU_ANY_TRANS_SUC}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00071    moc=NRCELL-6
        ${DL_RLC_AM_SDU_INI_TRANS_CA}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00072    moc=NRCELL-6
        ${DL_RLC_AM_SDU_INI_TRANS_SUC_CA}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00073    moc=NRCELL-6
	    ${DL_RLC_AM_SDU_ANY_TRANS_SUC_CA}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00074    moc=NRCELL-6
	    Log to console    Dl Counters collected for ${Interval} interval successfuly
        ${DL_RLC_AM_SDU_INI_TRANS_sum_all_int}    Evaluate    ${DL_RLC_AM_SDU_INI_TRANS}+${DL_RLC_AM_SDU_INI_TRANS_sum_all_int}
        ${DL_RLC_AM_SDU_ANY_TRANS_SUC_sum_all_int}    Evaluate    ${DL_RLC_AM_SDU_ANY_TRANS_SUC}+${DL_RLC_AM_SDU_ANY_TRANS_SUC_sum_all_int}
        ${DL_RLC_AM_SDU_INI_TRANS_CA_sum_all_int}    Evaluate    ${DL_RLC_AM_SDU_INI_TRANS_CA}+${DL_RLC_AM_SDU_INI_TRANS_CA_sum_all_int}
        ${DL_RLC_AM_SDU_ANY_TRANS_SUC_CA_sum_all_int}    Evaluate    ${DL_RLC_AM_SDU_ANY_TRANS_SUC_CA}+${DL_RLC_AM_SDU_ANY_TRANS_SUC_CA_sum_all_int}
        Log to console    Dl Counters evalution for ${Interval} interval done successfully
    END
    ${Overall_ANY_RX}    Evaluate    ${UL_RLC_AM_SDU_RX_INI_TRANS_sum_all_int}+${UL_RLC_AM_SDU_RETX_INI_TRANS_sum_all_int}
    ${Overall_ANY_RX_CA}    Evaluate    ${UL_RLC_AM_SDU_RX_INI_TRANS_CA_sum_all_int}+${UL_RLC_AM_SDU_RTX_INI_TRANS_CA_sum_all_int}
    Should be Equal    ${Overall_ANY_RX}    ${UL_RLC_AM_SDU_RX_TRANS_sum_all_int}
    Should be Equal    ${Overall_ANY_RX_CA}    ${UL_RLC_AM_SDU_RX_TRANS_CA_sum_all_int}
    Should be Equal    ${DL_RLC_AM_SDU_INI_TRANS_sum_all_int}     ${DL_RLC_AM_SDU_ANY_TRANS_SUC_sum_all_int}
    Should be Equal    ${DL_RLC_AM_SDU_INI_TRANS_CA_sum_all_int}     ${DL_RLC_AM_SDU_ANY_TRANS_SUC_CA_sum_all_int}
    Log to console    Overall DL UL Evaluation done successfully for CA Configured  DRB

Add DRB with QoS 5qi-4 to Same UE which will act as not CA Configured DRB and run High Traffic
     UE PDU Modfication should be Successful    1    pdu_id=1   qosflows_to_add=2
     sleep   10s
     UE PDU Modfication should be Successful    1    pdu_id=1   qosflows_to_add=3
     sleep   10s
     UE PDU Modfication should be Successful    1    pdu_id=1   qosflows_to_add=5
     sleep   10s
     Log to console    5qi-4 QOS DRB added succesfully
     Trigger UL Data Traffic for SA with Sec  ue_id=${UE_ID_CA}  Trf_rate=mbps   ul_rate=175   pdu_id=1   trf_id=1  sec=600    qfi=4
     sleep   2s
     Trigger DL Data Traffic for SA with Sec  ue_id=${UE_ID_CA}  Trf_rate=mbps   dl_rate=175   pdu_id=1   trf_id=1  sec=600    qfi=4
     sleep   2s
     Log to console    5qi-4 QOS DRB traffic ran successfully
Validate Counters UL DL RLC AM trf success rate for UE's not CA Configured DRB
    Set Suite Variable    ${UL_RLC_AM_SDU_RX_INI_TRANS}   1
    Set Suite Variable    ${DL_RLC_AM_SDU_INI_TRANS}    1
    Set Suite Variable    ${UL_RLC_AM_SDU_RX_INI_TRANS_sum_all_int}   0
    Set Suite Variable    ${UL_RLC_AM_SDU_RETX_INI_TRANS_sum_all_int}   0
    Set Suite Variable    ${UL_RLC_AM_SDU_RX_TRANS_sum_all_int}   0
    Set Suite Variable    ${Overall_ANY_RX}    0
    Set Suite Variable    ${DL_RLC_AM_SDU_INI_TRANS_sum_all_int}   0
    Set Suite Variable    ${DL_RLC_AM_SDU_ANY_TRANS_SUC_sum_all_int}   0
    FOR   ${Interval}  IN RANGE   6
        Log to console    ${Interval} iteration ongoing...
        Exit For Loop If    ${UL_RLC_AM_SDU_RX_INI_TRANS} == 0 and ${DL_RLC_AM_SDU_INI_TRANS} == 0
        Wait until the next Measurement Period starts
        ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
        ${UL_RLC_AM_SDU_RX_INI_TRANS}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00075    moc=NRCELL-6
        ${UL_RLC_AM_SDU_RX_TRANS}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00076    moc=NRCELL-6
        ${UL_RLC_AM_SDU_RETX_INI_TRANS}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00077    moc=NRCELL-6
        ${UL_RLC_AM_SDU_RX_INI_TRANS_CA}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00078    moc=NRCELL-6
        ${UL_RLC_AM_SDU_RX_TRANS_CA}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00079    moc=NRCELL-6
	    ${UL_RLC_AM_SDU_RTX_INI_TRANS_CA}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00080    moc=NRCELL-6
	    Log to console    Ul Counters collected for ${Interval} interval successfuly
	    ${UL_RLC_AM_SDU_RX_INI_TRANS_sum_all_int}    Evaluate    ${UL_RLC_AM_SDU_RX_INI_TRANS}+${UL_RLC_AM_SDU_RX_INI_TRANS_sum_all_int}
        ${UL_RLC_AM_SDU_RX_TRANS_sum_all_int}    Evaluate    ${UL_RLC_AM_SDU_RX_TRANS}+${UL_RLC_AM_SDU_RX_TRANS_sum_all_int}
        ${UL_RLC_AM_SDU_RETX_INI_TRANS_sum_all_int}    Evaluate    ${UL_RLC_AM_SDU_RETX_INI_TRANS}+${UL_RLC_AM_SDU_RETX_INI_TRANS_sum_all_int}
	    Log to console    Ul Counters evalution for ${Interval} interval done successfully
        Should be True  ${UL_RLC_AM_SDU_RX_INI_TRANS_CA} == 0
        Should be True  ${UL_RLC_AM_SDU_RX_TRANS_CA} == 0
	    Should be True  ${UL_RLC_AM_SDU_RTX_INI_TRANS_CA} == 0
        ${DL_RLC_AM_SDU_INI_TRANS}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00069    moc=NRCELL-6
        ${DL_RLC_AM_SDU_INI_TRANS_SUC}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00070    moc=NRCELL-6
        ${DL_RLC_AM_SDU_ANY_TRANS_SUC}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00071    moc=NRCELL-6
        ${DL_RLC_AM_SDU_INI_TRANS_CA}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00072    moc=NRCELL-6
        ${DL_RLC_AM_SDU_INI_TRANS_SUC_CA}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00073    moc=NRCELL-6
	    ${DL_RLC_AM_SDU_ANY_TRANS_SUC_CA}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55349C00074    moc=NRCELL-6
	    Log to console    Dl Counters collected for ${Interval} interval successfuly
        Should be True   ${DL_RLC_AM_SDU_INI_TRANS_CA} == 0
        Should be True   ${DL_RLC_AM_SDU_INI_TRANS_SUC_CA} == 0
	    Should be True   ${DL_RLC_AM_SDU_ANY_TRANS_SUC_CA} == 0
	    ${DL_RLC_AM_SDU_INI_TRANS_sum_all_int}    Evaluate    ${DL_RLC_AM_SDU_INI_TRANS}+${DL_RLC_AM_SDU_INI_TRANS_sum_all_int}
        ${DL_RLC_AM_SDU_ANY_TRANS_SUC_sum_all_int}    Evaluate    ${DL_RLC_AM_SDU_ANY_TRANS_SUC}+${DL_RLC_AM_SDU_ANY_TRANS_SUC_sum_all_int}
	    Log to console   Dl Counters evalution for ${Interval} interval done successfully
    END
    ${Overall_ANY_RX}    Evaluate    ${UL_RLC_AM_SDU_RX_INI_TRANS_sum_all_int}+${UL_RLC_AM_SDU_RETX_INI_TRANS_sum_all_int}
    Should be Equal    ${Overall_ANY_RX}    ${UL_RLC_AM_SDU_RX_TRANS_sum_all_int}
    Should be Equal    ${DL_RLC_AM_SDU_INI_TRANS_sum_all_int}     ${DL_RLC_AM_SDU_ANY_TRANS_SUC_sum_all_int}
    Log to console    Overall DL UL Evaluation done successfully for not CA Configured DRB, Overall RLC successrate tested successfully

Verify SA All Scell PCIs With UE ID
    [Arguments]    ${ue_id}    ${scell_physicalid_list}    ${cc_num}
    [Documentation]    This keyword is to check all scell physicall id of single ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | YES |  id of ue |
    ...    | ${scell_physicalid_list} | yes | the list for scell physicall id of ue |
    ...    | ${cc_num} | yes | the num for how many cc |
    ...
    ...    Examples:
    ...    | ${ue_id} |  | 1 |
    ...    | @{scell_physicalid_list} |  | 51 | 52 |
    ...    | Verify SA All Scell PCIs With UE ID | ${ue_id} | ${scell_physicalid_list} | 3 |
    ...
    ${for_num}    Evaluate    ${cc_num}-1
    FOR    ${id}    IN RANGE    ${for_num}
        ${index}    Evaluate    ${id}+1
        Verify single SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid_list}[${id}]    ${index}
    END
Verify single SA Scell PhysicalID With UE ID
    [Arguments]    ${ue_id}    ${scell_physicalid}    ${scell_index}    ${log_path}=${LOG_PATH}
    [Documentation]    This keyword is to check scell physicallid as the same as the expected one which
    ...         got from egate log with scell index
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | yes | the id of ue |
    ...    | ${scell_physicalid} | yes | the expected physicalid |
    ...    | ${scell_index} | yes | the scell index of ue need to check |
    ...    | ${log_path} | No | the path saved egate log |
    ...
    ...    Examples:
    ...    | Verify single SA Scell PhysicalID With UE ID | 1 | 51 | 1 |
    ...
#    Save Egate Log    log_path=${log_path}
    ute_wtssim.Execute Egate Command    sim_log_set flush
    OperatingSystem.Copy Files    /opt/iphy/latest/egate_console.log*    ${log_path}
    ${t_scell_id}    Fetch PhysCellId With UE Id From Egate Log    ${ue_id}    ${scell_index}    ${log_path}/egate_console.log
    Should Be True    "${scell_physicalid}"=="${t_scell_id}"
    ...    msg=the PhysicalID of ScellId${scell_index} for UE${ue_id} is ${t_scell_id}, not as the expected one ${scell_physicalid}.
Fetch PhysCellId With UE Id From Egate Log
    [Arguments]    ${ue_id}    ${scellindex}    ${egate_Log}
    [Documentation]    This keyword is to get physCellId from egate conscole Log according to sCellIndex.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id, such as 1,2,3... |
    ...    | ${scellindex} | Yes | the index for scell, such as 1,2,3... |
    ...    | ${egate_Log} | Yes | the egate console Log path |
    ...
    ...    Example:
    ...    | ${egate_Log} | Set Variable | ${CURDIR}/egate_console2.Log |
    ...    | ${physcellid_list} | Fetch PhysCellId With UE Id From Egate Log | 88 | 1 | ${egate_Log} |
    ...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}    OperatingSystem.Get File    ${egate_Log}
    ${patt}    Catenate    SEPARATOR=    UE${ue_id}\\[NR-RRC\\]: <- (DL-DCCH-NR)?[\\s\\S]*?
    ...    sCellIndex\\s${scellindex}\[\\s\\S\]*?physCellId\\s+(?P<physCellId>\\d+)[\\s\\S]*?
    ${physcellid}    String.Get Regexp Matches    ${content}    ${patt}    physCellId
    Log To Console    Get PhysCellId is ${physcellid[-1]} for UE${ue_id}
    [Return]    ${physcellid[-1]}

