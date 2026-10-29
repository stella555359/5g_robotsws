*** Settings ***
Force Tags      5G_SC_TDD    5G_RAN     SBTS00     SBTS25R2    CONFIGURED   120290

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         config/MultiUe_MultiDRB_Wrapper_Keyword.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource         ../../../resources/robot/counter_benchmark_resource.robot


Resource         CB008963_resource.robot
Library          taf.sw.scout    WITH NAME     scout
Library          ta5g_pm_counters
Library          ute_wtssim
Library          cb008963_discard_pm.py

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with InterGNB_HO.json
...                 AND     Perform SCF Delta Commissioning with RRC_Inactive.json
...                 AND     sleep    100s
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1    4


Documentation
...
...      author:            Ganesha    ganesha_u@nokia.com
...      maintainer:        Ganesha    ganesha_u@nokia.com
...
...      INTRODUCTION:    This user scenario describes the successful PDU Session Resource Modification procedure requested
...      by the AMF with establishment of a GBR QoS Flow to an existing PDU Session.
...      TEST SET NAME:  CB008963-SR-A-B7 Inter-gNB/inter-RAT handovers with multiple GBR bearers

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/InterGNB_HO.cfg
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

&{Vonr_qos}       1=5    2=1
&{qfi_ids_vonr}        5=2    1=3
${target_dir}=    /home/ute/Desktop/
${counter_json_file}=    ${CURDIR}/config/counter_8963.json
${host}=   192.168.255.129
${user}=   Nemuadmin
${password}=   nemuuser
${git_path}=   https://gitlabe1.ext.net.nokia.com/BTS_TOOLS/counter_benchmarking/-/blob/main/Bangalore/VRF_BLR1/T09/CB08963_Counter_Benchmking_D.xlsx


*** Test Cases ***
[1][1.0] USCB008963-A_B7_12_Verify_Successful_Intra-frequency_Inter-gNB_HO_with_multiple_GBRbearers
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    Set Test Variable    ${Validation}    ${True}
    Start_Fetching_Counter_Values
    MultiUe MultiDBR registration Should Be Successful
    Check PDCP Discard and Delay Counters
    Stop_Fetching_Counter_Values
    Run Keyword And Continue On Failure    Collect_Counter_Logs      ${host}     ${user}      ${password}
	...     ${target_dir}    ${counter_json_file}         ${git_path}
    FOR  ${UE}  IN RANGE    1   4
		Register UE with GBR and check default bearer and PDCP length    ${UE}    true    12
		Add multiple GBR bearers without nonGBR bearers in PDU-1  ${UE}
    END
    Send High Data for Ues
    Run Keyword and continue on Failure  Verify The Counter DL UL    100    10
	Verify legacy Counters
    FOR  ${UE}  IN RANGE    1   4
		Trigger multiple UE HO to Simulated and RealGNB   ${UE}
    END
	Verify legacy Counters after HO
	wts_sim_keywords.MultiUE Deregister should be Successful    1   3
    Register UE with GBR and check default bearer and PDCP length   51    true    12
    Check PDCP Priorty GBR OverNonGBR    51
    Stop All Data Traffic for SA    51
    Check PDCP Priorty NonGBR OverGBR    51
    [Teardown]   Run Keywords        Link SCOUT SCF to Configuration ID for Reporting
    ...         AND        wts_sim_keywords.Clean edaemon and egate
    ...         AND        Check resource hanging
    ...         AND        run keyword if test failed    Run Keyword and Ignore Error    Get Snapshot
    ...         AND        run keyword if test failed    Run Keyword and Ignore Error    Get Sos Report

*** Keywords ***
MultiUe MultiDBR registration Should Be Successful
    ute_wtssim.Execute Egate Command   cmd=qosflow_modify qos_flow=3 gfbr_dl=30720 gfbr_ul=30720 mfbr_dl=30720 mfbr_ul=30720
    Ue RRC Inactive state should be successful    221    225    311    489
    Register ALL Ues and Send Low data    Start_ue=5    End_ue=10
    Register ALL Ues and Send Low data    Start_ue=200    End_ue=214
    Log to console    Adding Vonr Ues
    QosFlow addition should be Successful     200   204      ${Vonr_qos}     ${qfi_ids_vonr}
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    210    212    Traffic_rate=mbps   dl_rate=1   pdu_id=1
    ...    trf_id=1   qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    210    212    Traffic_rate=mbps   ul_rate=1   pdu_id=1
    ...    trf_id=1   qfi_id=1

Send High Data for Ues
    Start Multi UE DL traffic with multiple trafficID     start_ue=213   end_ue=214    Traffic_rate=mbps    dl_trf_id=1    qfi_id=1    dl_rate_DL=10
    Start Multi UE UL traffic with multiple trafficID     start_ue=213   end_ue=214    Traffic_rate=mbps    ul_trf_id=1    qfi_id=1    ul_rate_UL=15

Verify The Counter DL UL
    [Arguments]    ${DL_rate}    ${UL_rate}
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${PM_dir1}=      Get Latest Unpacked Full Pm Counters File
    ${DLG_06}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C01005    local_moid=NRCELL-1
    ${DLG_01}    Get Latest Pm Counter Value   filepath=${PM_dir1}    counter_id=M55310C01001    local_moid=NRCELL-1
    ${DLG_04}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C01004    local_moid=NRCELL-1
    ${DLG_06}=   convert to integer    ${DLG_06}
    ${DLG_01}=   convert to integer    ${DLG_01}
    ${DLG_04}=   convert to integer    ${DLG_04}
    ${DL_Primary}    Evaluate    ${DLG_04}+${DLG_06}+${DLG_01}
    ${DL_Primary}    Evaluate    ${DL_Primary}*5/300000000
    ${ULG_06}    Get Latest Pm Counter Value   filepath=${PM_dir1}    counter_id=M55310C03005    local_moid=NRCELL-1
    ${ULG_01}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C03001    local_moid=NRCELL-1
    ${ULG_04}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C03004    local_moid=NRCELL-1
    ${ULG_06}=   convert to integer    ${ULG_06}
    ${ULG_01}=   convert to integer    ${ULG_01}
    ${ULG_04}=   convert to integer    ${ULG_04}
    ${UL_Primary}    Evaluate    ${ULG_04}+${ULG_06}+${ULG_01}
    ${UL_Primary}    Evaluate    ${UL_Primary}*5/300000000
    Should be True    ${DL_Primary} > ${DL_rate}
    Should be True    ${UL_Primary} > ${UL_rate}



Check PDCP Priorty GBR OverNonGBR
    [Arguments]    ${UEID}
    Start Log    btslog   cprt
    wts_sim_keywords.Trigger DL Traffic for SA    ue_id=${UEID}      Traffic_rate=mbps     dl_rate=40     pdu_id=1   trf_id=1    qfi_id=1
    sleep  60s  reason=stable data
    wts_sim_keywords.Validate DL Traffic For SA    ${UEID}      dl_rate=40     pdu_id=1      qfi_id=1
    wts_sim_keywords.UE PDU Modfication should be Successful    ue_id=${UEID}     pdu_id=1     qosflows_to_add=4
    wts_sim_keywords.Trigger DL Traffic for SA    ue_id=${UEID}      Traffic_rate=mbps     dl_rate=150     pdu_id=1   trf_id=1    qfi_id=2
    wts_sim_keywords.Trigger DL Traffic for SA    ue_id=${UEID}      Traffic_rate=mbps     dl_rate=100     pdu_id=1   trf_id=2    qfi_id=2
    sleep  60s  reason=stable data
    wts_sim_keywords.Validate DL Traffic For SA    ${UEID}      dl_rate=175     pdu_id=1      qfi_id=2
    wts_sim_keywords.Validate DL Traffic For SA    ${UEID}      dl_rate=40     pdu_id=1      qfi_id=1
    ${Pdcp_data}    Stop Log    btslog   cprt    test_scenario=pdcp_${UEID}

Stop All Data Traffic for SA
    [Arguments]    ${UEID}
     wts_sim_keywords.Stop data    ue_id=${UEID}  pdu_id=1     dir=dl   trf_id=1    qfi=1
     wts_sim_keywords.Stop data    ue_id=${UEID}  pdu_id=1     dir=dl   trf_id=1    qfi=2
     wts_sim_keywords.Stop data    ue_id=${UEID}  pdu_id=1     dir=dl   trf_id=2    qfi=2
     sleep    10s    reason=wait for data stable

Check PDCP Priorty NonGBR OverGBR
    [Arguments]    ${UEID}
    Start Log    btslog   cprt
    wts_sim_keywords.Trigger DL Traffic for SA    ue_id=${UEID}      Traffic_rate=mbps     dl_rate=150     pdu_id=1   trf_id=1    qfi_id=2
    wts_sim_keywords.Trigger DL Traffic for SA    ue_id=${UEID}      Traffic_rate=mbps     dl_rate=100     pdu_id=1   trf_id=2    qfi_id=2
    sleep  60s  reason=stable data
    wts_sim_keywords.Validate DL Traffic For SA    ${UEID}      dl_rate=215     pdu_id=1      qfi_id=2
    wts_sim_keywords.Trigger DL Traffic for SA    ue_id=${UEID}      Traffic_rate=mbps     dl_rate=40     pdu_id=1   trf_id=1    qfi_id=1
    sleep  60s  reason=stable data
    wts_sim_keywords.Validate DL Traffic For SA    ${UEID}      dl_rate=175     pdu_id=1      qfi_id=2
    wts_sim_keywords.Validate DL Traffic For SA    ${UEID}      dl_rate=40     pdu_id=1      qfi_id=1
    ${Pdcp_data}    Stop Log    btslog   cprt    test_scenario=pdcp_${UEID}

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
#    ...     M55310C01001    >100     DL_RLC_VOL_TX_L_QOS_GRP_01_5QI_1
#    ...     M55310C01004    >100     DL_RLC_VOL_TX_L_QOS_GRP_03_5QI_4
#    ...     M55310C03001    >100     UL_RLC_VOL_RX_L_QOS_GRP_01_5QI_1
#    ...     M55310C03004    >100     UL_RLC_VOL_RX_L_QOS_GRP_03_5QI_4
    ...     M55143C00001      3      XN_HO_REQ_ACK_RECEIVED
    ...     M55143C00006      3      XN_HO_REQ_ACK_SENT
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

Trigger multiple UE HO to Simulated and RealGNB
    [Arguments]  ${UEID}
    Start Log    btslog   cprt
    wts_sim_keywords.Get Configured Measurements of UE${UEID}
	wts_sim_keywords.Trigger A3 RsrpAndRsrq Measurement for intragnb HO    ${UEID}   1    54
	sleep    30s    reason=wait for data stable
	wts_sim_keywords.Get Configured Measurements of UE${UEID}
	wts_sim_keywords.Trigger A3 RsrpAndRsrq Measurement for intragnb HO    ${UEID}   1    50
    Stop Log    btslog   cprt    test_scenario=Trigger_HO_NRcell_${UEID}

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/MN/UTE/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI

Check PDCP Discard and Delay Counters
    Register ALL Ues and Send Low data    Start_ue=1    End_ue=2
    Start Multi UE DL traffic with multiple trafficID     start_ue=1   end_ue=2    Traffic_rate=mbps    dl_trf_id=1    qfi_id=1    dl_rate_DL=150
    check_pm_counters_for_timer_discarding_and_pdcp_packet_delay
    wts_sim_keywords.Stop MultiUE Data Traffic for SA     1     2
    wts_sim_keywords.MultiUE Deregister should be Successful    1   2
