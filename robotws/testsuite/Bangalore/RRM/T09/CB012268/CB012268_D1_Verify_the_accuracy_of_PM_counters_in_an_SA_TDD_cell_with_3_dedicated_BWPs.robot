*** Settings ***
Force Tags        CLOUD_5G_I_LOO_AP_LOOO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED


Documentation
...
...  AUTHOR          :   Prapulla.bt  Prapulla.bt@nokia.com
...  MAINTAINER      :   Prapulla.bt  Prapulla.bt@nokia.com
...  INTRODUCTION    :   CB012268 CB012268_D1_Verify_the_accuracy_of_PM_counters_in_an_SA_TDD_cell_with_3_dedicated_BWPs
...  TEST SET NAME   :   CB012268_D1_Verify_the_accuracy_of_PM_counters_in_an_SA_TDD_cell_with_3_dedicated_BWPs
...  TESTING SPLIT   :   Split-D
...  REFERENCES      :   CB012268-CFAM
...  REQUIREMENT ID  :   12457910


Library          ta5g_enb
Library          ta5g_pm_counters
Resource         ../CNI-109585/CNI109585_resource.robot
Resource         ../5GC000937/resources/MultiUe_MultiDRB_Wrapper_Keyword.robot
Resource         ../../../resources/robot/counter_benchmark_resource.robot


Suite Setup         Run keywords    Suite setup from scratch
...                 AND    CNI109585_resource.Perform SCF Delta Commissioning with MULTILBWP_CHANGES_TMO_12268.json
...                 AND    sleep    180s
...                 AND    Prepare TL with IPHY file change
...                 AND    Update GNB R&D Parameter
...                 AND    Reboot gNB System Module from Console and check Airscale is ready
...                 AND    Configure eth3 IP
...                 AND    Load CFG and verify cell status   ${wts_cfg_file}     1      1
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}


Suite Teardown      Run Keyword And Ignore Error    Get Sos Report

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts/default_TMO_basic.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${st_ue_1}    1
${en_ue_6}      6
${st_ue_9}    9
${en_ue_17}      17
${st_ue_ps_7}    7
${en_ue_ps_8}    8
${UE_ID}    1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${QFI_ID1}     1
${TRF_ID}     1
${Q_O_ADD1}    1
${Target_Cells}    1
${epc_log_path}    /tmp/
${AP_XML}            ${CURDIR}/config/SCF/New_Iphy_file.xml
${r&d_parameter}       0x600036=0

*** Test Cases ***

[1][1.0] CB012268_D1_Verify_the_accuracy_of_PM_counters_in_an_SA_TDD_cell_with_3_dedicated_BWPs
    [Documentation]   Test Case Configured for NRCELL-1
    Set test variable      ${LOG_PATH}
    ${TEST_LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${TEST_LOG_PATH}
    log to console   Suite setup successful ...
	Start Log   btslog
    Start_Fetching_Counter_Values
    MultiUe All-BWP registration Should Be Successful
    Validate BWP Counter after UE attach
    MultiUE Deregister should be Successful    1    8
    MultiUe registration Should Be Successful
    Validate Bin Counters after UE attach
    Stop log   btslog
    Stop log    snapshot  test_scenario=snap
    [Teardown]    Run keywords       Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
MultiUe All-BWP registration Should Be Successful
    log to console   UE attach trigerring now...
    WTS_Runner_Keywords.MultiUE Register should be Successful    ${st_ue_1}  ${en_ue_6}
    sleep   20s

    WTS_Runner_Keywords.MultiUE Trigger DL Traffic for SA    ${st_ue_1}    ${en_ue_6}    Traffic_rate=mbps     dl_rate=10
    ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    sleep   2s
    WTS_Runner_Keywords.MultiUE Trigger UL Traffic for SA    ${st_ue_1}    ${en_ue_6}    Traffic_rate=mbps     ul_rate=10
    ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    sleep   2s

    ${crnti_list}=      WTS_Runner_Keywords.MultiUE Register should be Successful    ${st_ue_ps_7}  ${en_ue_ps_8}
    sleep   5s
    WTS_Runner_Keywords.MultiUE Trigger DL Traffic for SA    ${st_ue_ps_7}    ${en_ue_ps_8}    Traffic_rate=kbps     dl_rate=10
    ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    sleep   2s
    WTS_Runner_Keywords.MultiUE Trigger UL Traffic for SA    ${st_ue_ps_7}    ${en_ue_ps_8}    Traffic_rate=kbps     ul_rate=10
    ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    sleep   2s

MultiUe registration Should Be Successful
    log to console   UE attach trigerring now...
    WTS_Runner_Keywords.MultiUE Register should be Successful    ${st_ue_9}  ${en_ue_17}
    sleep   20s

    Multi UEs Trigger DL Traffic for SA call    ${st_ue_9}    ${en_ue_17}    Traffic_rate=mbps  size=42   dl_rate=10
    ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    sleep   2s
	Multi UEs Trigger DL Traffic for SA call    ${st_ue_9}    ${en_ue_17}    Traffic_rate=mbps  size=75   dl_rate=10
    ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
	    sleep   2s
	Multi UEs Trigger DL Traffic for SA call    ${st_ue_9}    ${en_ue_17}    Traffic_rate=mbps  size=150   dl_rate=10
    ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    sleep   2s
	Multi UEs Trigger DL Traffic for SA call    ${st_ue_9}    ${en_ue_17}    Traffic_rate=mbps  size=350   dl_rate=10
    ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    sleep   2s
	Multi UEs Trigger DL Traffic for SA call    ${st_ue_9}    ${en_ue_17}    Traffic_rate=mbps  size=690   dl_rate=10
    ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    sleep   2s
	Multi UEs Trigger DL Traffic for SA call    ${st_ue_9}    ${en_ue_17}    Traffic_rate=mbps  size=1150   dl_rate=10
    ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    sleep   2s
	Multi UEs Trigger DL Traffic for SA call    ${st_ue_9}    ${en_ue_17}    Traffic_rate=mbps  size=1300   dl_rate=10
    ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    sleep   2s
	Multi UEs Trigger DL Traffic for SA call    ${st_ue_9}    ${en_ue_17}    Traffic_rate=mbps  size=1450   dl_rate=10
    ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    sleep   2s
	Multi UEs Trigger DL Traffic for SA call    ${st_ue_9}    ${en_ue_17}    Traffic_rate=mbps  size=1550   dl_rate=10
    ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}

Validate BWP Counter after UE attach
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55351C00003    >0      PDSCH_INIRE_VOL_BWP1
    ...     M55351C00004    >0      PDSCH_INIRE_VOL_BWP2
    ...     M55351C00005    >0      PDSCH_INIRE_VOL_BWP3

    ...     M55351C00007    >0      PUSCH_INIRE_VOL_BWP1
	...     M55351C00008    >0     PUSCH_INIRE_VOL_BWP2
	...     M55351C00009    >0     PUSCH_INIRE_VOL_BWP3

	...     M55351C00006    >0     PUSCH_INIRE_VOL_BWP_PS
	...     M55351C00010    >0     PUDCH_INIRE_VOL_BWP_PS

	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
	...     file_path=${pm_counter_file}

Validate Bin Counters after UE attach
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55350C00071    >0      DL_PDCP_SDU_SIZE_BIN1
    ...     M55350C00072    >0      DL_PDCP_SDU_SIZE_BIN2
    ...     M55350C00073    >0      DL_PDCP_SDU_SIZE_BIN3

    ...     M55350C00074    >0      DL_PDCP_SDU_SIZE_BIN4
	...     M55350C00075    >0     DL_PDCP_SDU_SIZE_BIN5
	...     M55350C00076    >0     DL_PDCP_SDU_SIZE_BIN6

	...     M55350C00077    >0     DL_PDCP_SDU_SIZE_BIN7
	...     M55350C00078    >0     DL_PDCP_SDU_SIZE_BIN8
	...     M55350C00079    >0     DL_PDCP_SDU_SIZE_BIN9

	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
	...     file_path=${pm_counter_file}


Update GNB R&D Parameter
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

MultiUE Deregister should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
	${deregister_cmd}    SET VARIABLE    ue_deregister id=${ue_idx} ue_deregister_type=switch_off by=ue
	ute_wtssim.Execute Egate Command And Wait For Data   ${deregister_cmd}    pass_regexp=${UE_deregister_pattern}
    ... 	timeout=${EGATE_COMMAND_TIMEOUT}
    END
    BuiltIn.Log                multi_ue_deregister_is_ok

Multi UEs Trigger DL Traffic for SA call
    [Arguments]     ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${size}   ${dl_rate}   ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    ${data_cmd}	SET VARIABLE	trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=${qfi_id} dir=dl size=${size} ${Traffic_rate}=${dl_rate} trf_id=${trf_id}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${data_cmd}    pass_regexp=Started Downlink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
	END
    BuiltIn.Log    DL_traffic_data_is_started_successfully
