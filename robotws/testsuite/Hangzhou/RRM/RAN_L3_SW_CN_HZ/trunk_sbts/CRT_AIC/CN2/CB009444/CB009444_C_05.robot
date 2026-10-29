*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    vDUCNF00    RAN_5G    RAN_Aic    CRT    master_vDU
...    CLOUD_5GC_dRNIC_1vDU_O_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-Beam    owner-ying.yao
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/1du/2cell
${SA_UE_ID}    1
${BTS_STARTUP_RETRY}    3

@{PARAMS_IN_SCF_CU}
...    NRBTS:xnNgRanCfUpNbInfoBackOffTmr=3
...    @{CB009444_feature_enable}
...    @{xnlink}
...    @{TRACKINGAREA}
...    @{SNSSAI_setting}

@{PARAMS_IN_SCF_DU1}
...    @{DU1_SNSSAI_setting}
...    @{DU1_TRACKINGAREA}

@{xnlink}
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    XNLINK-3:cPlaneIpAddr=10.0.12.11
...    NRADJGNB-3:administrativeState=Unlocked
...    NRADJGNB-3:gNodeBId=3
...    NRADJGNB-3:gNbIdLength=22
...    NRADJGNB-3:xnLinkRef=3
...    NRADJGNB-3:gnbPlmn:mcc=311
...    NRADJGNB-3:gnbPlmn:mnc=489
...    NRADJGNB-3:gnbPlmn:mncLength=3

@{SNSSAI_setting}
...    NRBTS-1/SNSSAI-1:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-1:sst=1
...    NRBTS-1/SNSSAI-1:operationalState=enabled
...    NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-2:sst=1
...    NRBTS-1/SNSSAI-2:sd=13714342
...    NRBTS-1/SNSSAI-2:operationalState=enabled

@{DU1_SNSSAI_setting}
...    NRBTS-1/SNSSAI-1:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-1:sst=1
...    NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-2:sst=1
...    NRBTS-1/SNSSAI-2:sd=13714342

@{TRACKINGAREA}
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2

@{DU1_TRACKINGAREA}
...    delete:MRBTS-1/NRBTS-1/TRACKINGAREA-0
...    delete:MRBTS-1/NRBTS-1/TRACKINGAREA-1
...    NRBTS-1/TRACKINGAREA-1:fiveGsTac=280
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-1
...    NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-1

${nrPlmnDNList1}    MRBTS-1/NRBTS-1/NRPLMN-1
${snssaiDNList12}    MRBTS-1/NRBTS-1/SNSSAI-1,MRBTS-1/NRBTS-1/SNSSAI-2

@{CB009444_feature_disable}
...    NRBTS-1:actSliceConfSync=false
@{CB009444_feature_enable}
...    NRBTS-1:actSliceConfSync=true
@{CB009444DU_delta_lock_snssai2}
...    NRBTS-1/SNSSAI-2:administrativeState=Locked
@{CB009444DU_delta_unlock_snssai2}
...    NRBTS-1/SNSSAI-2:administrativeState=Unlocked

*** Test Cases ***
CB009444_C_05_vRAN_TDD_SA_slice_confiure_sync_featureFlag_off_featureFlag_on_lock_unlock_administrativeState_on_vDU
    [Documentation]
    ...    1. This user scenario describes gNB behaviour when feature activation flag is modified.
    ...       Consistent slice list on gNB is expected as intersection of slice list on CU and vDU
    ...       when feature activation flag is enabled.
    ...    2. Test Case Steps:
    ...        a. feature CB009444 is enabled by setting activation flag to true(actSliceConfSync=true)
    ...        b. on CU webem, change actSliceConfSync=FALSE
    ...        c. on vDU webem, remove SNSSAI-2 by changing SNSSAI-2. administrativeState = locked
    ...        d. on CU webem, change actSliceConfSync=TRUE
    ...        e. on vDU webem, add SNSSAI-2 by changing SNSSAI-2. administrativeState = unlocked
    [Tags]    QC_282768
    Object Should Exist In Cu    XNLINK-3:xnLinkStatus=available
    OnlineParamChange Cu    DELTA_PARAMS_IN_SCF_CU=${CB009444_feature_disable}
    Parameter Check For Step2

    OnlineParamChange DU Without Cell Check    DELTA_PARAMS_IN_SCF_DU=${CB009444DU_delta_lock_snssai2}    index=1
    Check WireShark Log Aic    ${CURDIR}${/}a2a_C05${/}a2a_step3.ini
     ...    ait_string=NGRANNodeConfigurationUpdateAcknowledge::1

    OnlineParamChange CU    ${CB009444_feature_enable}
    Parameter Check For Step4

    OnlineParamChange DU    DELTA_PARAMS_IN_SCF_DU=${CB009444DU_delta_unlock_snssai2}    index=2
    Parameter Check For Step5
    Check WireShark Log Aic    ${CURDIR}${/}a2a_C05${/}a2a_step5.ini
     ...    wait_string=NGRANNodeConfigurationUpdateAcknowledge::1
    UE Register To Cell1 Successfully And Traffic OK    index=7    ue_id=3    nwslice=2
    Release Ues    ue_id=3    ue_type=sa

*** Keywords ***
OnlineParamChange CU
    [Arguments]    ${DELTA_PARAMS_IN_SCF_CU}
    Delta Commission Parameters Cu    ${DELTA_PARAMS_IN_SCF_CU}
    Cells Should Be Onair Du    timeout=30

Parameter Check For Step2
    Object Should Not Exist In Cu    MRBTS-1/NRBTS-1/NRDU-1:nrDuSnssaiDNList==${EMPTY}
    Get Cu Scf    scf_tar_path=${OUTPUT_DIR}/scf_cu.xml
    ${result_nudu_snssai}    Execute Cmd On Pc    grep -i 'MRBTS-[0-9]*/NRBTS-[0-9]*/NRDU_SNSSAI-' ${OUTPUT_DIR}/scf_cu.xml
    Should Not Contain     ${result_nudu_snssai}    NRDU_SNSSAI

Parameter Check For Step4
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-2:operationalState=disabled
    Get Cu Scf    scf_tar_path=${OUTPUT_DIR}/scf_cu.xml
    ${result_nudu_snssai}    Execute Cmd On Pc    grep -i '\<p\>MRBTS-[0-9]*/NRBTS-[0-9]*/NRDU_SNSSAI-' ${OUTPUT_DIR}/scf_cu.xml
    ${nrdu_snssai}    String.Get Regexp Matches    ${result_nudu_snssai}    (MRBTS-[0-9]*/NRBTS-[0-9]*/NRDU_SNSSAI-\\d+)    1
    ${nrdu_snssai_len}    Get Length    ${nrdu_snssai}
    Should Be Equal     '${nrdu_snssai_len}'    '1'    Should only contain 1 NRDU_SNSSAI!!
    Should Contain     ${result_nudu_snssai}    NRDU_SNSSAI    NRDU_SNSSAI does not exist!!
    Object Should Exist In Cu    ${nrdu_snssaI[0]}:sd=13714341

Parameter Check For Step5
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-2:operationalState=enabled
    Get Cu Scf    scf_tar_path=${OUTPUT_DIR}/scf_cu.xml
    ${result_nudu_snssai}    Execute Cmd On Pc    grep -i '\<p\>MRBTS-[0-9]*/NRBTS-[0-9]*/NRDU_SNSSAI-' ${OUTPUT_DIR}/scf_cu.xml
    ${nrdu_snssai}    String.Get Regexp Matches    ${result_nudu_snssai}    (MRBTS-[0-9]*/NRBTS-[0-9]*/NRDU_SNSSAI-\\d+)    1
    ${nrdu_snssai_len}    Get Length    ${nrdu_snssai}
    Should Be Equal     '${nrdu_snssai_len}'    '2'    Should only contain 2 NRDU_SNSSAI!!
    Should Contain     ${result_nudu_snssai}    NRDU_SNSSAI-1    NRDU_SNSSAI_1 does not exist!!
    Should Contain     ${result_nudu_snssai}    NRDU_SNSSAI-2    NRDU_SNSSAI_2 does not exist!!
    Sd Value Should Be Correct    ${nrdu_snssai}

Sd Value Should Be Correct
    [Arguments]    ${nrdu_snssai}
    ${nrdu_snssai_1_sd}    Get SCF Parameter Value Cu    ${nrdu_snssai[0]}:sd
    ${nrdu_snssai_2_sd}    Get SCF Parameter Value Cu    ${nrdu_snssai[1]}:sd
    Should Match Regexp    ${nrdu_snssai_1_sd}    13714341|2
    Should Match Regexp    ${nrdu_snssai_2_sd}    13714341|2

OnlineParamChange DU Without Cell Check
    [Arguments]    ${DELTA_PARAMS_IN_SCF_DU}    ${index}
    Start To Capture Wireshark Log Vcu    log${index}
    Start To Capture Wireshark Log Vdu    log${index}
    Start RRC Log Aic    rrclog${index}
    delta commission parameters Du    ${DELTA_PARAMS_IN_SCF_DU}
    Stop RRC Log Aic
    Stop To Capture Wireshark Log Vcu    log${index}
    Stop To Capture Wireshark Log Vdu    log${index}
    Get RRC Log

OnlineParamChange DU
    [Arguments]    ${DELTA_PARAMS_IN_SCF_DU}    ${index}
    Start To Capture Wireshark Log Vcu    log${index}
    Start To Capture Wireshark Log Vdu    log${index}
    Start RRC Log Aic    rrclog${index}
    delta commission parameters Du    ${DELTA_PARAMS_IN_SCF_DU}
    Cells Should Be Onair Du    timeout=300
    Stop RRC Log Aic
    Stop To Capture Wireshark Log Vcu    log${index}
    Stop To Capture Wireshark Log Vdu    log${index}
    Get RRC Log

UE Register To Cell1 Successfully And Traffic OK
    [Arguments]    ${index}    ${ue_id}=${SA_UE_ID}    ${nwslice}=1
    Start To Capture Wireshark Log Vcu    log${index}
    Start To Capture Wireshark Log Vdu    log${index}
    Start RRC Log Aic    rrclog${index}
    SA UE Register And PDU Setup    ue_id=${ue_id}    nwslice=${nwslice}
    Send Throughput    ue_id=${ue_id}
    Verify Throughput    ue_id=${ue_id}
    Stop RRC Log Aic
    Stop To Capture Wireshark Log Vcu    log${index}
    Stop To Capture Wireshark Log Vdu    log${index}
    Get RRC Log

Send Throughput
    [Arguments]    ${ue_id}=${SA_UE_ID}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 protocol=udp mbps=10    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=2 protocol=udp mbps=3    UE ${ue_id}: UDP UL

Verify Throughput
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Throughput stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>9
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>2.7
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps

SA UE Register And PDU Setup
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=1    QoS Routing Table

Modify Cfg Aic
    Update Cfg Aic    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1
    Update Cfg Aic    set_nwslice id=3 snssai=0x01:0xD143A7 ue=all amf=1

    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.11.11 gnb_id=0x3:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.11 nssai=0x1:0xd143a5 amf=1 plmnList=311:489
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb3}
    Update Cfg Aic    ${set_gnb3_cell1}
    Update Cfg Aic    gnb_make_plmnset plmn_set_id=1 dual_conn=off gnb=3 cell=1 tac=280 plmn_id_list=311:489
    Update Cfg Aic    gnb_set_nwslice_per_plmn gnb=3 cell=1 plmn_set_id=1 plmn=311:489 nssai=0x01:0xd143a5
    Update Cfg Aic    gnb_param id=3 xn_listening_socket=on send_xn_setup=false
