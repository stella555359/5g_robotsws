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
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${pdu_id}    1
${gw_id}    1
${PDU_ADD_VIA_MODIFY_SUCCESS}    QoS Routing Table
${PDU_ADD_VIA_MODIFY_FAILED}    PDU Session Resource Modify Unsuccessful Transfer
${cell_id}    2
${BTS_STARTUP_RETRY}    0
@{PARAMS_IN_SWCONFIG}    0x5901A6=1
@{PARAMS_IN_VENDOR}
...    maxNumPucchF1SRPerSlotL1Pool=24
${HKF}    SEPARATOR=
...    (f1ap.procedureCode == 8) && (nr-rrc.pucch_ResourceId == 8) &&
...    (f1ap.radioNetwork == 7)

*** Test Cases ***
CB013151_SR_D06_Verify_HKF_failed_because_SR_reconfig_RAC_failed
    [Documentation]
    ...    This user scenario verifies the housekeeping functions of pCSI region and those of the SR region.
    ...    This user scenario triggers the usage of SRCX region to increase the SR capacity of the cell due to an
    ...    increase of the UE camped in the cell and then it verifies that PRBs in the SRCX region and pCSI are released
    ...    when the required SR capacity of the cell diminishes due to the decreasing number of UEs camped in the cell.
    ...    It checks the correct relocation of SR and pCSI resources, for those UEs that get PUCCH resources too near to
    ...    the BW center, while empty PUCCH resources more at the BW edge are free and available.
    ...    The automatic adaptation of the SR period for existing and new UEs is excluded
    ...    (NRBTS/NRCELL/actAdaptiveSr=FALSE) in this test, 5GC002271 is OFF.
    ...    Feature CB014386 “increased SR capacity", supporting lower SR periodicity for more UEs, is switched off;
    ...    activation is covered in USCB013151-#B2-ALT1.
    ...    When the number of UEs in the cell decreases, pCSI and SR resources in the SRCX and SRBX are freed.
    ...    The remaining resources may be still allocated such, that the usage of PUCCH PRBs for PUSCH is limited.
    ...    To resolve this, the re-location of pCSI and SR resources is initiated to free SRCX area and to move the
    ...    allocated pCSI resources to PRBs at the BW edges.
    ...    The re-location is only initiated when the number of remaining UEs is low, to avoid the need of relocating
    ...    too many UEs and thus avoid a too large number of UEs reconfigured.
    ...    1. [Configuration]:
    ...    pucchF1ResOccConf=1-1-0_OCCs
    ...    actBbPoolTddFr1=true
    ...    2. Test Case Steps:
    ...       Step1: Multiple Ues attach to cell,make it reaching the configured SR load threshold
    ...              (rdSrbrLoadThreshold1SrcxNeeded) in SRBR poolt
    ...       Step2: Disconnect UEs (few at time and starting from those earlier camped in the cell until the cell is
    ...              empty).From time to time few UEs may newly join in between and disconnect after some time
    ...    3. Expected Results:
    ...       Step1:
    ...       a, The UE can access and camp in the cell.
    ...       b, SRCX region is created
    ...       c, after SRBR no free resource, SR in SRCX region was allocated
    ...       Step2:
    ...       a, When UE disconnects, the related SR and pCSI resources become free in the pool and are available to
    ...          other later incoming UEs
    ...       b, When the load decreases below rdSrbrLoadThreshold2SrcxNotNeeded,the SR housekeeping function shall
    ...          relocate the UEs, but due to SR RAC failed,no actual reconfig shall happen
    ...       c, the exist ue and new coming ue shall no impact and working as expect
    [Tags]    D06
    Start To Capture Wireshark Log    cell${cell_id}_D06
    Multi SA Call Setup Successfully    cell_id=2    ue_id_start=1    ue_id_end_before=49    nwslice_id=2
    sleep    5s
    Multi SA Call Setup Successfully    cell_id=2    ue_id_start=49    ue_id_end_before=68
    Release Ues    ue_id=1-20
    sleep    180s
    stop capture wireshark log    cell${cell_id}_D06
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark_cell${cell_id}_D06.pcap    ${HKF}
    Should Be True    ${number}==0
    Release Ues    ue_type=all

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,200,280,300 plmn=310:260,311:490
    Update Cfg    set_nwslice id=1 snssai=0x01:13714341 default=on ue=all amf_region_id=1 plmn_list=310:260,311:490
    Update Cfg    set_nwslice id=2 snssai=0x01:13714342 ue=all amf_region_id=1 plmn_list=310:260,311:490
    ${gnb2_set}    catenate
    ...    set_gnb id=2 type=external plmn=310:260 s1u=$GNB_S1U_ADDR x2=$GNB_X2_ADDR:36422 ng=$GNB_NG_ADDR gnb_id=0x01:24
    ...    daemon=$SERVER_IP:$DAEMON_PORT x2_peers=none amf=1 plmnList=310:260 nssai=0x1:0xd143a5,0x1:0xd143a6 xn=10.0.1.2
    Update Cfg    ${gnb2_set}

SA Call Setup Successfully
  [Arguments]    ${ue_id}    ${cell_id}=2    ${pdu_id}=1    ${gw_id}=1    ${dlmbps}=1    ${ulmbps}=1    ${nwslice_id}=1
  Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    ${cell_id}
  Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
  Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
  Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice_id}    QoS Routing Table
  Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${dlmbps} trf_id=1    UE ${ue_id}: UDP DL
  Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=${ulmbps} trf_id=1    UE ${ue_id}: UDP UL

Multi SA Call Setup Successfully
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}    ${nwslice_id}=1
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        SA Call Setup Successfully    ${ue_id}    ${cell_id}    nwslice_id=${nwslice_id}
    END
