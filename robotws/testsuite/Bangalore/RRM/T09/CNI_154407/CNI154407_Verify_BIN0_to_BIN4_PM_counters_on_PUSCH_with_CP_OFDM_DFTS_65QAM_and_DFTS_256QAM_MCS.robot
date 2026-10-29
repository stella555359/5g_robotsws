*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_TDD
...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation
...  AUTHOR          :   Meghana s  meghana.s@nokia.com
...  MAINTAINER      :   Meghana s  meghana.s@nokia.com
...  TEST SET NAME   :   CNI154407_Verify_BIN0_to_BIN4_PM_counters_on_PUSCH_with_CP_OFDM_DFTS_65QAM_and_DFTS_256QAM_MCS
...  CONTACTS        :   meghana.s@nokia.com


Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Library          ../../../resources/python/avg_dl_data.py
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../5GC000937/resources/MultiUe_MultiDRB_Wrapper_Keyword.robot
Resource         ../../../resources/robot/counter_benchmark_resource.robot
#Resource         CB010866_resource.robot
Library          ta5g_pm_counters
#Library          python/common_gnb.py
Library          ta5g_enb
Library          taf.sw.scout    WITH NAME     scout

Suite Setup         Run Keywords
...                 Suite setup from scratch
...                 AND    Perform SCF Delta Commissioning with 64QAM.json
#...                 AND    Perform SCF Delta Commissioning with Vonr_GBR.json
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=Wait for RMOD to come up
...                 AND    Configure eth3 IP
...                 AND    Load Cfg File

Test Teardown    Run keywords       Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic.cfg

# set_qosflow ID ? 5QI Mapping (Defined in CFG)
&{QOS_6}     1=6
&{QOS_7}     2=7
&{QOS_8}     3=8
&{QOS_9}     4=9

# UE Pathloss Mapping (Keys must be STRING)
&{UE_PATHLOSS}
...    1=120
...    2=100
...    3=140
...    4=130
...    5=120
...    6=90
...    7=120
...    8=90
...    9=80
...    10=130


*** Test Cases ***
CNI154407_Verify_BIN0_to_BIN4_PM_counters_on_PUSCH_with_CP_OFDM_DFTS_65QAM_and_DFTS_256QAM_MCS
    [Tags]    QC_294757      QCD_MN_RAN    QCP_RAN_ET   TC01
    MultiUe MultiDBR Registration Should Be Successful
    Validate Bin Counters for 64QAM
    Validate Bin Counters for 256QAM
    Run Keyword And Continue On Failure    Collect TTI to check MCS values
    Stop Log    snapshot    test_scenario=snap


*** Keywords ***

Collect TTI to check MCS values
	Start Log      ttitrace
	Sleep    2s
    ${tti_lowload}    Stop Log       ttitrace   test_scenario=MCS_values

Load Cfg File
    Start Collecting gNB Syslog
    Start CPRT Capture
    Load CFG and Verify Cell Status    ${wts_cfg_file}    1    4
    Stop CPRT Capture Common    log_dir=${LOG_PATH}
    Stop Syslog    log_dir=${LOG_PATH}


MultiUe MultiDBR Registration Should Be Successful

    Register ALL Ues and Send data    Start_ue=1    End_ue=10
    Log To Console    Adding GBR UEs with individual 5QI mapping

#    QoS Flow Addition Should Be Successful     1    1     ${QOS_6}
    QoS Flow Addition Should Be Successful     2    2     ${QOS_7}
    QoS Flow Addition Should Be Successful     3    3     ${QOS_8}
    QoS Flow Addition Should Be Successful     4    4     ${QOS_9}
#    QoS Flow Addition Should Be Successful     5    5     ${QOS_6}
#    QoS Flow Addition Should Be Successful     6    6     ${QOS_6}
    QoS Flow Addition Should Be Successful     7    7     ${QOS_7}
    QoS Flow Addition Should Be Successful     8    8     ${QOS_8}
    QoS Flow Addition Should Be Successful     9    9     ${QOS_9}
#    QoS Flow Addition Should Be Successful     10   10    ${QOS_6}


QoS Flow Addition Should Be Successful
    [Arguments]    ${start_ueid}    ${end_ueid}    ${qosflows_to_add}    ${pdu_id}=1

    ${start}=    Convert To Integer    ${start_ueid}
    ${end}=      Convert To Integer    ${end_ueid}

    FOR    ${ue_id}    IN RANGE    ${start}    ${end + 1}
        Add Multiple QoS Flows to UEs and Send Data
        ...    ${ue_id}
        ...    ${qosflows_to_add}
        ...    ${pdu_id}
    END


Add Multiple QoS Flows to UEs and Send Data
    [Arguments]    ${ue_id}    ${qosflows_to_add}    ${pdu_id}=1

    FOR    ${qosflow_id}    ${fiveqi}    IN    &{qosflows_to_add}

        Log To Console    ======================================
        Log To Console    UE=${ue_id} - Applying set_qosflow ID=${qosflow_id} (5QI=${fiveqi})
        Log To Console    ======================================

        # Add QoS Flow using set_qosflow ID from CFG
        wts_sim_keywords.UE PDU Modfication Should Be Successful
        ...    ${ue_id}
        ...    pdu_id=${pdu_id}
        ...    qosflows_to_add=${qosflow_id}

        Sleep    5s

        # Get pathloss (dictionary keys must be strings)
        ${ue_id_str}=    Convert To String    ${ue_id}
        ${pathloss}=     Get From Dictionary    ${UE_PATHLOSS}    ${ue_id_str}

        Sleep    5s

##         Trigger DL Traffic (QFI assigned after 5QI attach; fixed as 2)
#        wts_sim_keywords.Trigger UL Traffic for SA
#        ...    ue_id=${ue_id}
#        ...    Traffic_rate=mbps
#        ...    ul_rate=50
#        ...    pdu_id=${pdu_id}
#        ...    trf_id=1
#        ...    qfi_id=2

#         Trigger UL Traffic (QFI assigned after 5QI attach; fixed as 2)
        wts_sim_keywords.Trigger UL Traffic for SA
        ...    ue_id=${ue_id}
        ...    Traffic_rate=mbps
        ...    ul_rate=50
        ...    pdu_id=${pdu_id}
        ...    trf_id=1
        ...    qfi_id=2

        Sleep    3s


        # Apply RF condition
        Execute Egate Command
        ...    cmd=ul_sinr_testmode_nr profile_id=${ue_id} pathloss=${pathloss} pcmax=30
        ...    timeout=60s

        Execute Egate Command
        ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_sinr profile_id=${ue_id} action=activate
        ...    timeout=60s

        Sleep    2s

    END

Validate Bin Counters for 64QAM
    Wait For Next Full Pm Interval
    ${pm_counter_file_64QAM}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55386C00039   >0      PUSCH_CP_INRE_BIN1_64TBL_PMQ     ##pathloss=120 5QI6
    ...     M55386C00042   >0      PUSCH_CP_INRE_BIN4_64TBL_PMQ     ##pathloss=100 5QI7
    ...     M55386C00038   >0      PUSCH_CP_INRE_BIN0_64TBL_PMQ     ##pathloss=140 5QI8
    ...     M55386C00039   >0      PUSCH_CP_INRE_BIN1_64TBL_PMQ     ##pathloss=140 5QI8
    ...     M55386C00038   >0      PUSCH_CP_INRE_BIN0_64TBL_PMQ     ##pathloss=120 5QI6
    ...     M55386C00040   >0      PUSCH_CP_INRE_BIN2_64TBL_PMQ     ##pathloss=120 5QI6
    ...     M55386C00041   >0      PUSCH_CP_INRE_BIN3_64TBL_PMQ     ##pathloss=120 5QI6
    ...     M55386C00042   >0      PUSCH_CP_INRE_BIN4_64TBL_PMQ     ##pathloss=120 5QI6
    ...     M55386C00039   >0      PUSCH_CP_INRE_BIN1_64TBL_PMQ     ##pathloss=130 5QI9
    ...     M55386C00038   >0      PUSCH_CP_INRE_BIN0_64TBL_PMQ     ##pathloss=130 5QI9

	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
	...     file_path=${pm_counter_file_64QAM}



Validate Bin Counters for 256QAM
    Wait For Next Full Pm Interval
    ${pm_counter_file_256QAM}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55386C00045  >0      PUSCH_CP_INRE_BIN2_256TBL_PMQ   ##pathloss=90 5QI6
    ...     M55386C00046  >0      PUSCH_CP_INRE_BIN3_256TBL_PMQ   ##pathloss=90 5QI6
    ...     M55386C00043  >0      PUSCH_CP_INRE_BIN0_256TBL_PMQ   ##pathloss=120 5QI7
    ...     M55386C00044  >0      PUSCH_CP_INRE_BIN1_256TBL_PMQ   ##pathloss=120 5QI7
    ...     M55386C00043  >0      PUSCH_CP_INRE_BIN0_256TBL_PMQ   ##pathloss=140 5QI7
    ...     M55386C00046  >0      PUSCH_CP_INRE_BIN3_256TBL_PMQ   ##pathloss=90  5QI8
    ...     M55386C00045  >0      PUSCH_CP_INRE_BIN2_256TBL_PMQ   ##pathloss=90  5QI8
    ...     M55386C00046  >0      PUSCH_CP_INRE_BIN3_256TBL_PMQ   ##pathloss=80  5QI9
    ...     M55386C00046  >0      PUSCH_CP_INRE_BIN3_256TBL_PMQ   ##pathloss=70  5QI9

	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
	...     file_path=${pm_counter_file_256QAM}


Register ALL Ues and Send data
    [Arguments]     ${Start_ue}    ${End_ue}
    ${crnti_list}     Create List
    FOR    ${ue_id}    IN RANGE    ${Start_ue}   ${End_ue}+1
    ${rnti}    wts_sim_keywords.UE Register should be Successful And Fetch RNTI    ${ue_id}
    Append to list   ${crnti_list}    ${rnti}
    wts_sim_keywords.Trigger UL Data Traffic for SA   ue_id=${ue_id}    Traffic_rate=Mbps    ul_rate=50    pdu_id=1    trf_id=1
#    Activate BIN for 5QI6 64QAM
#    Activate BIN for 5QI6 256QAM
    END
    Activate BIN for 5QI6 64QAM
    Activate BIN for 5QI6 256QAM

Activate BIN for 5QI6 64QAM
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=20 pathloss=120 pcmax=30
    ...    cmd=ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=20 action=activate


Activate BIN for 5QI6 256QAM
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=22 pathloss=90 pcmax=30
    ...    cmd=ue_testmode_set_nr id=6 testmode=ul_sinr profile_id=22 action=activate
