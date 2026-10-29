*** Settings ***
Force Tags      5G_SC_TDD    5G_RAN     SBTS00     SBTS25R2    CONFIGURED

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Resource         CB008963_resource.robot
Library          taf.sw.scout    WITH NAME     scout
Library          ta5g_pm_counters

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Prepare TL with all config files
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1    2

Documentation
...
...      author:            Ganesha    ganesha_u@nokia.com
...      maintainer:        Ganesha    ganesha_u@nokia.com
...
...      INTRODUCTION:    This user scenario describes the successful PDU Session Resource Modification procedure requested
...      by the AMF with establishment of a GBR QoS Flow to an existing PDU Session.
...      TEST SET NAME:  CB008963-SR-C-B2 Multiple GBR inter-RAT HO with 12-bit RLC_UM and 12-bit RLC_AM

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/lte_to_5g_ho.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${TRF_ID}    1
${Q_O_ADD1}    1
${epc_log_path}    /tmp/
@{5QI1}     2    12    false
&{flows_ue1_pdu1}    ${2}=${5QI1}
${SCFC}=                  ${CURDIR}/config/IRAT_HO.xml
${AP_XML}=                ${CURDIR}/config/IRAT_iphy.xml

*** Test Cases ***
[1][1.0] USCB008963-C_B2_4_Verify_Successful_IRAT_HO_with_indirect_dataforwarding_with_multiple_GBR_bearers_include_5QI1&2
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    Set Test Variable    ${Validation}    ${True}
    Register UE with GBR and check default bearer and PDCP length    1    false    12
    Add multiple GBR bearers without nonGBR bearers in PDU-1    1
	Verify legacy Counters
    Trigger multiple UE HO to LTE and RealGNB   1
	Verify legacy Counters after HO
	wts_sim_keywords.MultiUE Deregister should be Successful    1   1
    [Teardown]   Run Keywords        Link SCOUT SCF to Configuration ID for Reporting
    ...         AND        wts_sim_keywords.Clean edaemon and egate
    ...         AND        run keyword if test failed    Run Keyword and Ignore Error    Get Snapshot
    ...         AND        run keyword if test failed    Run Keyword and Ignore Error    Get Sos Report

*** Keywords ***
Add multiple GBR bearers without nonGBR bearers in PDU-1
    [Arguments]  ${UEID}
    FOR   ${5QI}   IN RANGE    2   3
       Start Log    btslog   cprt
       ${value}    Get From Dictionary   ${flows_ue1_pdu1}   ${5QI}
       wts_sim_keywords.UE PDU Modfication should be Successful    ue_id=${UEID}      pdu_id=1     qosflows_to_add=${value}[0]
       wts_sim_keywords.Trigger DL Traffic for SA    ue_id=${UEID}      Traffic_rate=mbps     dl_rate=1     pdu_id=1   trf_id=1    qfi_id=${5QI}
       wts_sim_keywords.Trigger UL Traffic for SA    ue_id=${UEID}      Traffic_rate=mbps     ul_rate=1     pdu_id=1   trf_id=1    qfi_id=${5QI}
       ${add_pdu1}    Stop Log    btslog   cprt    test_scenario=add_${UEID}_PDU1_${5QI}
       CheckPDCPLength   ${add_pdu1}[cprt]   ${value}[1]
       Checkdrbdefault    ${add_pdu1}[cprt]   ${value}[2]
    END

Verify legacy Counters
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55310C01001    >100     DL_RLC_VOL_TX_L_QOS_GRP_01_5QI_1
    ...     M55310C01004    >100     DL_RLC_VOL_TX_L_QOS_GRP_03_5QI_4
    ...     M55310C03001    >100     UL_RLC_VOL_RX_L_QOS_GRP_01_5QI_1
    ...     M55310C03004    >100     UL_RLC_VOL_RX_L_QOS_GRP_03_5QI_4
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

Verify legacy Counters after HO
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55310C01001    >100     DL_RLC_VOL_TX_L_QOS_GRP_01_5QI_1
    ...     M55310C01004    >100     DL_RLC_VOL_TX_L_QOS_GRP_03_5QI_4
    ...     M55310C03001    >100     UL_RLC_VOL_RX_L_QOS_GRP_01_5QI_1
    ...     M55310C03004    >100     UL_RLC_VOL_RX_L_QOS_GRP_03_5QI_4
    ...     M55144C00006    1        NREMO_IRATHO_EXE_SUC
    ...     M55142C00508    1        I_LTE_HO_EXEC_NOTIFY
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

Trigger multiple UE HO to LTE and RealGNB
    [Arguments]  ${UEID}
    Start Log    btslog   cprt
    wts_sim_keywords.Get Configured Measurements of UE${UEID}
	wts_sim_keywords.Trigger handover 5G to LTE cell     ue_id=${UEID}    A2_meas_id=1   B2_meas_id=3
	sleep    30s    reason=wait for data stable
	wts_sim_keywords.Get Configured Measurements of UE${UEID}
	wts_sim_keywords.Trigger handover to LTE to 5G     ue_id=${UEID}
    Stop Log    btslog   cprt    test_scenario=Trigger_HO_NRcell_${UEID}
