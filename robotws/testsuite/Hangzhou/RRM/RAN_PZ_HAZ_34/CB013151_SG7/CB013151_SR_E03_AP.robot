*** Settings ***
Documentation    Suite documentation
...    author:  keyun.ma@nokia-sbell.com
...    contact: keyun.ma@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv_tmo_65    ue_count=100
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS26R2    tl-CLOUD_5G_I_LOO_AP_LOOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${tag}    ${EMPTY}
${EMIL_FLAG}    ${False}
${AUTO_ANALYSIS_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}
${WIRESHARK_FLAG}    ${True}
${SNAPSHOT_FLAG}    pass:True,fail:True
${SOS_REPORT_FLAG}    pass:False,fail:True
${GNB_BIP_FLAG}    ${True}
${AP_BIP_FLAG}    ${False}
${RECREATE_WIRESHARK_FLAG}    ${False}
${pdu_id}    1
${gw_id}    1
${PDU_ADD_VIA_MODIFY_SUCCESS}    QoS Routing Table
${PDU_ADD_VIA_MODIFY_FAILED}    PDU Session Resource Modify Unsuccessful Transfer
${cell_id}    2
${BTS_STARTUP_RETRY}    0

#0x5901A8    rdHkfMinPCsiRepPeriod
#0x5901A7    rdHkfMinPCsiResPerSlot
#0x5901A6    rdPCsiPoolHkfPeriod_min
#0x5901A9    rdHkfPCsiPoolMaxRCUsFactor
#0x5902D3    rdSrbrLoadThreshold1SrcxNeeded
#0x5902D4    rdSrbrLoadThreshold2SrcxNotNeeded
#0x59015E    rdSrLoadThresholdDownHysteresis

@{PARAMS_IN_SWCONFIG}    0x5901A6=1    0x5902D3=50    0x5902D4=40    0x59015E=60

${HKF}    SEPARATOR=
...    (f1ap.procedureCode == 8) && (nr-rrc.pucch_ResourceId == 8) &&
...    (f1ap.radioNetwork == 7)

*** Test Cases ***
CB013151_SR_E03_Verify_Interworking_with_5GC002711_Scheduling_request_handling_wIth_2200_enable_and_cdrx_on
    [Documentation]
    ...    This user scenario is inspired by user scenario USBC013151-C #B1 and it is as well based on
    ...    5GC002271-A#1 “Adaptive SR period for non-VoNR UEs.
    ...    Therefore, the automatic adaptation of the SR period for existing and new UEs is enabled
    ...    in this test (5GC002271 is enabled).
    ...    As well feature CB014386 “increased SR capacity", that allows the support of lower SR periodicity
    ...    for a larger number of UEs, is enabled.
    ...    The intention in this US, is to verify that the SRCX expansion is triggered before the feature 5GC002271
    ...    triggers the change of the SR resource pool due to the presence of a large number of UE attached to the cell.
    ...    Still it must be noticeable that free PRBs in any PUCCH area (SRBR, HARQ, SRCX and pCSI) are then utilized by
    ...    PUSCH, as consequence of CB013151 activation, if they are in continuity with the PUSCH region.
    ...    The PRBs in the PUCCH area not allocated to any UE may change from slot to slot and this difference shall be
    ...    noticeable in the PUSCH as well slot per slot.
    ...    Separate PUCCH Format 1 resources are configured for the scheduling request (SR) and the HARQ ACK/NACK report.
    ...    1. [Configuration]:
    ...       NRCELL.actIncreasedSrCapacity=TRUE
    ...       NRBTS/NRCELL/actBeamforming=TRUE
    ...       NRCELL.actAdaptiveSr = true
    ...    2. Test Case Steps:
    ...       Step1: UEs are being connected to the cell (and not released afterwards) until cell capacity is reached
    ...              (calculated based on the 40 slots SR).
    ...       Step2: UEs disconnect until the cell is empty.Optionally, few UEs may join in between and disconnect
    ...              after some time
    ...    3. Expected Results:
    ...       Step1:
    ...    a,Number of used SR resources is below adaptiveSrLoadThresholdUp(all UEs are allocated with the SR from pool)
    ...    b,Number of used SR resources in pool#1 reached rdSrbrLoadThreshold1SrcxNeeded below
    ...      adaptiveSrLoadThresholdUp that triggers expansion of SRBR region to SRCX, thus more resources
    ...      are available to the pools after the expansion to SRCX.
    ...    c,Attach more UEs with VoNR PDU session to the cell. When adaptiveSrLoadThresholdUp is reached,new UEs with
    ...      VoNR service are configured with SR resources from pool #2 with larger SR period. In parallel the
    ...      re-allocation of resource from pool #1 to pool#2 is started and and only a small number* of UEs are kept
    ...      with the SR period from pool #1)
    ...      Note: *the amount of UEs that is kept in shorter pool is called reservation for low latency and
    ...      by default is predefined, however it can be changed with NIDD parameter NRBTS/NRCELL/lowLatencyReservation.
    ...    d,Number of used SR resources from pool #2 + Number of not available SR resources from pool #2 is below
    ...      adaptiveSrLoadThresholdUp (new UEs are now using SR resources from pool #2).
    ...      Note: not available SR resources in pool #2 are due to UEs in pool #1
    ...    e,Number of used SR resources from pool #2 + Number of not available SR resources from pool #2 reached
    ...      adaptiveSrLoadThresholdUp (reallocation of the remaining portion of UEs from pool #1 to pool #2 is started
    ...      and at the end all UEs are using SR resources from pool #2)
    ...    f,Number of used SR resources from pool #2 reached cell capacity (if there are still new UEs trying to access
    ...      the cell, they are rejected)
    ...      Step2:
    ...    a,When UE disconnects, the related SR resource is given free in the corresponding pool and is available to
    ...      other later incoming UEs.
    ...    b,Number of used SR resources from pool #2 is above adaptiveSrLoadThresholdDown (all UEs are still allocated
    ...      with the SR from pool #2).
    ...    c,Number of used SR resources from pool #2 reached adaptiveSrLoadThresholdDown (reallocation of SR resources
    ...      from pool #2 to pool #1 is not started yet, but at this point some new UEs are allocated with the SR from
    ...      pool #1)
    ...    d,Number of used SR resources from pool #2 reached adaptiveSrLoadThresholdDown calculated using the capacity
    ...      of pool #1 to avoid ping pong. The reallocation of SR resources from pool #2 to pool #1 is started and
    ...      finally all UEs are using SR period from pool #1
    ...    e,During above steps, when the number of SR resources allocated decreases below,
    ...      rdSrbrLoadThreshold2SrcxNotNeeded, which is calculated on the SRBR region capacity (2 PRBs), the
    ...      housekeeping function starts to empty the SRCX PRBs closest to the cell BW center and free them.
    ...    f,When the SRCX region is empty, after the UE relocation, the SRCX region is removed and the PRB before
    ...      reserved to SRCX can potentially be allocated either to pCSI or to PUSCH or stay empty.
    ...    g,When the SR region is made only of PRBs in SRBR and the load in SR pool #1 decreases below
    ...      NRCELL.adaptiveSrLoadThresholdDown, all new incoming UEs with VoNR Service are allocated to pool #1 and all
    ...      the UE still in pool #2 (if any) are reallocated to pool #1.
    ...    h,Finally cell is empty and all SR pools are empty.
    [Tags]    E03
    Start To Capture Wireshark Log    cell${cell_id}_phase1
    Multi SA Call Setup Successfully    cell_id=2    ue_id_start=1    ue_id_end_before=100
    stop capture wireshark log    cell${cell_id}_phase1
    ${num1}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark_cell${cell_id}_phase1.pcap    ${HKF}
    Should Be True    ${num1}>=100
    Start To Capture Wireshark Log    cell${cell_id}_phase2
    add traffic for UE99
    sleep    10s
    Release Ues    ue_id=1-48
    sleep    180s
    stop capture wireshark log    cell${cell_id}_phase2
    ${num2}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark_cell${cell_id}_phase2.pcap    ${HKF}
    Should Be True    ${num2}==3
    Start To Capture Wireshark Log    cell${cell_id}_phase3
    Release Ues    ue_id=49-89
    sleep    70s
    stop capture wireshark log    cell${cell_id}_phase3
    ${num3}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark_cell${cell_id}_phase3.pcap    ${HKF}
    Should Be True    ${num3}==10
    Traffic Should Be Correct

*** Keywords ***
Traffic Should Be Correct
    [Arguments]    ${ue_id}=99    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>=9.9
    Should Be True    ${ul_throughput}/1000>=9.9

Send Throuput
    [Arguments]    ${ue_id}=1    ${qfi_id}=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=100 trf_id=1
    ...    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=40 trf_id=1
    ...    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

UE SA Attach To Target Cell
    [Arguments]    ${cell_id}=1    ${ue_id}=81    ${nwslice}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}
    ...    QoS Routing Table

Add Qosflow With PDU Session Modify
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qosflows_to_add}=2    ${expect_result}={EMPTY}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add}
    ...    pass_regexp=${expect_result}

Set qosflow GFBR
    [Arguments]    ${qosflow_id}=2    ${gfbr_dl}=28000    ${gfbr_ul}=28000
    Execute Egate Command    qosflow_modify qos_flow=${qosflow_id} gfbr_dl=${gfbr_dl} gfbr_ul=${gfbr_ul}

Add Aditional qosflow
    [Arguments]    ${qosflow_id}=2    ${smf_id}=1
    Execute Egate Command    smf_param additional_qosflows_to_activate=${qosflow_id} id=${smf_id}

add traffic for UE99
    [Arguments]    ${ue_id}=99
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=10 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

SA Call Setup Successfully
    [Arguments]    ${ue_id}    ${cell_id}=2    ${pdu_id}=1    ${gw_id}=1    ${dlmbps}=1    ${ulmbps}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    ${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id}    QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${dlmbps} trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=${ulmbps} trf_id=1    UE ${ue_id}: UDP UL

Multi SA Call Setup Successfully
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        SA Call Setup Successfully    ${ue_id}    ${cell_id}
    END

NSA Call Setup Successfully
    [Arguments]    ${ue_id}=101    ${cell_id}=2    ${dlmbps}=1    ${ulmbps}=1
    Execute Egate Command    ue_attach id=${ue_id}
    Execute Egate Command    enb_endc_param id=1 selected_plmn=310:260
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=${ulmbps} trf_id=1
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=${dlmbps} trf_id=2

Multi NSA Call Setup Successfully
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        NSA Call Setup Successfully    ${ue_id}    ${cell_id}
    END

Set RRC Reconfig param
    [Arguments]    ${ue_id_start}=49    ${ue_id_end_before}=97
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=reestablish
    END

Clear RRC Reconfig param
    [Arguments]    ${ue_id_start}=49    ${ue_id_end_before}=97
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} reset
    END
