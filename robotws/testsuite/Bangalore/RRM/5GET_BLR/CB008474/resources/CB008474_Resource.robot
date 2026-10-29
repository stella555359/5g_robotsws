*** Settings ***

Documentation
...  AUTHOR          :   Madhusudhan.y@nokia.com
...  MAINTAINER      :   Madhusudhan.y@nokia.com
...  INTRODUCTION    :   CB008474_Short_PRACH_format_C2_15_kHz_PRACH_SCS__for_FR1_TDD171
...  TEST SET NAME   :   CB008474_A1_3_Multiple_UE_with_PRACH_format_C2_15kHz_SCS_with_4Rx
...  TESTING SPLIT   :   CB008474-A
...  CONTACTS        :   Madhusudhan.y@nokia.com
...  REFERENCES      :   CB008474-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_25058

Resource         ../../resources/robot/Airphone.robot
#Resource         ../../resources/robot

Resource         ../../resources/robot/PM_Counters.robot
Resource         ../../resources/robot/wts_sim_keywords.robot
Resource         ../../CB008278/resources/common_CA.robot
Resource         ../../resources/robot/common_log_collection.robot
Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../resources/robot/Setup_Env.robot
Library          ../../resources/python/BIP_Capture.py
Library          ../../resources/python/CPRT_Capture.py
Library          ../../resources/python/avg_dl_data.py
Library          OperatingSystem


#*** Variables ***


*** Keywords ***
Set And Activate UE_TA_NR_Profile For Multiple UEs
    [Arguments]   ${start_ue}   ${end_ue}    ${profile_id}    ${delay}
    ute_wtssim.Execute Egate Command     cmd=ue_ta_nr profile_id=${profile_id} ue_p_delay_initial=${delay}
    ute_wtssim.Execute Egate Command     cmd=ue_testmode_set_nr id=${start_ue},${end_ue} testmode=ta action=activate profile_id=${profile_id}

Register Multiple UEs
    [Arguments]   ${start_ue}   ${end_ue}
    FOR  ${UE}  IN RANGE   ${start_ue}   ${end_ue}+${1}
          UE Register should be Successful And Fetch RNTI with RAT1    ${UE}
    END

Attach Multiple NSA UEs
    [Arguments]   ${start_ue}   ${end_ue}    ${target_cell}
    wts_sim_keywords.NSA Multi UE Attach should be Successful    ${start_ue}   ${end_ue}     ${target_cell}

Register and Send less data
    [Arguments]   ${start_ue}   ${end_ue}
    FOR  ${UE}  IN RANGE   ${start_ue}   ${end_ue}+${1}
          UE Register should be Successful And Fetch RNTI with RAT1    ${UE}
          wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${UE}    Traffic_rate=kbps     dl_rate=100     pdu_id=1
          ...                                                trf_id=1
    END
Trigger DL Data for SA Multiple UEs
    [Arguments]   ${start_ue}   ${end_ue}    ${Traffic_rate}    ${data_rate}
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA  ${start_ue}   ${end_ue}  Traffic_rate=${Traffic_rate}
    ...                             dl_rate=${data_rate}  pdu_id=1  trf_id=1

Trigger UL Data for SA Multiple UEs
    [Arguments]   ${start_ue}   ${end_ue}    ${Traffic_rate}    ${data_rate}
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA  ${start_ue}   ${end_ue}  Traffic_rate=${Traffic_rate}
    ...               ul_rate=${data_rate}  pdu_id=1  trf_id=1

Trigger DL Data for NSA Multiple UEs
    [Arguments]   ${start_ue}   ${end_ue}    ${Traffic_rate}    ${data_rate}
    wts_sim_keywords.MultiUE Trigger DL Traffic for NSA  ${start_ue}  ${end_ue}  Traffic_rate=${Traffic_rate}
    ...                      dl_rate=${data_rate}  id=2  trf_id=1

Trigger UL Data for NSA Multiple UEs
    [Arguments]   ${start_ue}   ${end_ue}    ${Traffic_rate}    ${data_rate}
    wts_sim_keywords.MultiUE Trigger UL Traffic for NSA  ${start_ue}  ${end_ue}  Traffic_rate=${Traffic_rate}
    ...                                ul_rate=${data_rate}  id=2  trf_id=1

Trigger DL Data Stop for SA Multiple UEs
    [Arguments]   ${start_ue}   ${end_ue}
    wts_sim_keywords.Multiue DL TRF Data Stop for SA    ${start_ue}   ${end_ue}

Trigger UL Data Stop for SA Multiple UEs
    [Arguments]   ${start_ue}   ${end_ue}
    wts_sim_keywords.Multiue UL TRF Data Stop for SA    ${start_ue}   ${end_ue}

Trigger DL Data Stop for NSA Multiple UEs
    [Arguments]   ${start_ue}   ${end_ue}
    wts_sim_keywords.Multiue DL TRF Data Stop for SA    ${start_ue}   ${end_ue}

Trigger UL Data Stop for NSA Multiple UEs
    [Arguments]   ${start_ue}   ${end_ue}
    wts_sim_keywords.Multiue DL TRF Data Stop for SA    ${start_ue}   ${end_ue}

Trigger UE De-Registartion for Multiple UEs
    [Arguments]   ${start_ue}   ${end_ue}
    wts_sim_keywords.MultiUE Deregister should be Successful    ${start_ue}   ${end_ue}

Trigger UE-Detach for Multiple UEs
    [Arguments]   ${start_ue}   ${end_ue}
    wts_sim_keywords.NSA Multi UE Detach should be Successful     ${start_ue}   ${end_ue}

Validate PRACH Counters
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${RA_ATT_CONT_A_PRMBL_SSB_00}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55306C00001    moc=NRCELL-1
    ${RA_COMP_CONT_A_PRMBL}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55306C03001    moc=NRCELL-1
    ${RA_MSG3_RECEP}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55306C06001    moc=NRCELL-1
    Should be True    ${RA_ATT_CONT_A_PRMBL_SSB_00} > ${2}
    Should be True    ${RA_ATT_CONT_A_PRMBL_SSB_00} == ${4}
    Should be True    ${RA_COMP_CONT_A_PRMBL} == ${4}
    Should be True    ${RA_MSG3_RECEP} == ${4}

Perform Delta-Commissioning to Update Diffrent prachConfigurationIndex To PRACH_format_C2_15_kHz Cell
        Log To Console    Starting delta_comm_locking
        5GC000937_Keywords.Perform SCF Delta Commissioning with A1_celllock_enable_feature.json
        Log To Console    Starting delta_comm Done_cell_locked
        sleep  60s
        5GC000937_Keywords.Perform SCF Delta Commissioning with A1_unlock_cell1.json
        Log To Console    Starting delta_comm Done_cell_unlocked
        sleep    300s
        wts_sim_keywords.Verify_sib_mib_for_Cell    start_cell=1    end_cell=2

Check MIB_SIB status of Active cell
   [Arguments]   ${Cell_Id}
   wtsrunner.enb_cell_ib_disp   enb=2   cell=${Cell_Id}
   ${output}   wtsrunner.read_wtsemu_output_until_re    expected=SIB5.\*80  timeout=120
   ${MIB}     Get Lines Matching Regexp    ${output}    MIB    partial_match=${TRUE}
   ${SIB1}     Get Lines Matching Regexp    ${output}    SIB1    partial_match=${TRUE}
   Should contain    ${MIB}     yes
   Should contain    ${SIB1}     yes

Trigger TA_NRTADV Report
    [Arguments]   ${ue_id}    ${trx_id}
    ute_wtssim.Execute Egate Command     cmd=lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${trx_id}
    ...      lmf_ue_measurement_id=1 report_characteristics=OnDemand meas_qty=SS-RSRP,SS-RSRQ,NR_Timing_Advance
    ute_wtssim.Execute Egate Command     cmd=lmf_send_ecid_meas_req id=1 ue=2 nrppa_transaction_id=2 lmf_ue_measurement_id=1
    ...                                  report_characteristics=OnDemand meas_qty=SS-RSRP,SS-RSRQ,NR_Timing_Advance
    sleep    5s

Deregister ALL Ues
    [Arguments]   ${start_ue}   ${end_ue}
    FOR   ${Ues}  IN RANGE   ${start_ue}    ${end_ue}
        wts_sim_keywords.MultiUE Deregister should be Successful     ${Ues}   ${end_ue}
    END

Collecte TTi-Traces And Decode
    [Arguments]   ${duration}
    Start log   ttitrace
    sleep    ${duration}
    ${SC4}    Stop log    ttitrace  test_scenario=Tti
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/Tti/
    Dated Log        converting ttitrace pcap to csv..........at ${tti_path}
    Run Keyword And Continue On Failure    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}
