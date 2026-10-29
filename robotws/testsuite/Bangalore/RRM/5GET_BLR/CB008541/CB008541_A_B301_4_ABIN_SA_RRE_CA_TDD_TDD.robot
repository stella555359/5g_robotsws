*** Settings ***
Force Tags      CLOUD_5G_I_LOO_AP_LOOO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    TOOLS_PROFILE_TTI_LEGACY


Documentation    :copyright: Nokia
...              :authors: Sunil
...              :contact: sunil.t_kurian@nokia.com
...     This feature (CB008541) enhances NR CA by enabling UEs that don't fully support an SCell's bandwidth to still
...    aggregate it, improving peak downlink throughput in both SA and NSA deployments.  The system dynamically selects
...    SCells and BWPs, optimizing for throughput while considering UE capabilities (contiguous and non-contiguous bands)
...    and efficient PDCCH allocation within the UE's supported BWP.
...    This maximizes data rates for a wider range of devices and improves network efficiency.
...    The feature supports setting an SCell even if the UE only supports a smaller BWP.
...    It allows simultaneous management of UE bandwidth capabilities and dynamic BWP adaptation (5GC000937/CB007552)
...    for power saving on the same cell.  Applicable for FR1, TDD/FDD, SA/NSA, with/without beamforming,
...    and various SCell addition/change procedures and handovers.  Configuration is enabled via
...    NRBTS.actMultipleDedicatedBWPs and NRCELL.actEnhMultipleDedicatedBWPs, allowing up to four BWP profiles
...    (initial, two dedicated, and one power saving).

Resource         resources/CB008541_Keywords.robot
Library          ta5g_pm_counters

Suite Setup         Run keywords    Run Keyword and Ignore Error     Suite setup from scratch
...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_CB008541_A_301_RRE_TMO.json
#...                 AND    log to console    triggering gnb reboot
#...                 AND    Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_CA_SA_RRE.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        5
${Cell_Id}      3
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${epc_log_path}    /tmp/

*** Test Cases ***
[1]CB008541_A_B301_4_SA_UEsupporting_Pcell_LBWP_SCell_SBWP_UEReestablish_for_TDD_TDD_2CC_CA
    [Documentation]  CB008541_A_B201_4_SA_UEsupporting_Pcell_LBWP_SCell_SBWP_UEReestablish_for_TDD_FDD_2CC_CA
    [Tags]   QC_27260  QCD_MN_RAN   QCP_RAN_VRF
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    Regiter UE And Verify Scell Addition On High Data Traffic
    Verify RRC Reestablishment is Successfull
    Run keyword and continue on failure     Verify Counters incrementing RRE
    Verify Scell Deactivation On Low Data Traffic
    Run keyword and continue on failure     Verify Counters decrementing RRE
*** Keywords ***
Regiter UE And Verify Scell Addition On High Data Traffic
    UE Register should be Successful     ue_id=${UE_ID}
    Start 1Gbps Big DL Data Transfer And Check SCell Activation for 2CC
    Get Configured Measurements of UE${UE_ID}
    Trigger A1 Measurement and verify Scell added successfully    5    5    16499
    Trigger UL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=110       trf_id=1
    sleep   5s
	Run Keyword And Continue on Failure    Verify DL Tput For 2CC T_F

Verify DL Tput For 2CC T_F
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=1    unit=Mbps
    Should Be True    ${pcell_tput} > ${400}
    Should Be True    ${scell_tput} > ${200}

Verify RRC Reestablishment is Successfull
    Wait For Next Full Pm Interval
    Trigger RRC Reestablishment   ue_id=${UE_ID}    cell_id=${Cell_Id}
    Get Configured Measurements of UE${UE_ID}
    Trigger A1 Measurement and verify Scell added successfully    5    7    16499

Verify Scell Deactivation On Low Data Traffic
    Start Low Data Traffic And Check Scell Deactivation
    Run Keyword And Continue on Failure    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    sleep     60s
	Run Keyword And Continue on Failure     Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=0.010     qfi_id=${QFI_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}

Start 1Gbps Big DL Data Transfer And Check SCell Activation for 2CC
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=172       trf_id=1
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=172       trf_id=2
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=172       trf_id=3
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=172       trf_id=4
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=172       trf_id=5
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=172       trf_id=6
    sleep   5s    reason=Wait for successful traffic start


Start Low Data Traffic And Check Scell Deactivation
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=9      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=9      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful traffic start
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=1    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=2    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=3    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=4    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=5    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=6    dir=dl     pdu_id=${Pdu_session_ID}

Verify Counters incrementing RRE
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55167C00001    300    SAMPLES_BWP_UE_AMOUNTS
    ...     M55167C00002   >200    SUM_UE_SCELL_CONF_S_BWP
	...     M55139C04001    1      GNB_DU_SCELL_ADM_S_BWP_SUCC
	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55308C28001   >25000     ACC_UE_DL_SCH_SLOT_BWP1
	...     M55308C28002   1   ACC_UE_DL_SCH_SLOT_BWP_PS
 	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-4
    ...     file_path=${pm_counter_file}

Verify Counters decrementing RRE
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55167C00001    300    SAMPLES_BWP_UE_AMOUNTS
    ...     M55167C00002     0     SUM_UE_SCELL_CONF_S_BWP
	...     M55139C04001     0     GNB_DU_SCELL_ADM_S_BWP_SUCC
	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55308C28001   0     ACC_UE_DL_SCH_SLOT_BWP1
	...     M55308C28002   0   ACC_UE_DL_SCH_SLOT_BWP_PS
 	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-4
    ...     file_path=${pm_counter_file}

