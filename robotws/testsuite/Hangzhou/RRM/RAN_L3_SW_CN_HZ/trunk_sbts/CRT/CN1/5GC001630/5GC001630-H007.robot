*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G20A    5GC001630
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}    @{RanSharing_HO}    @{MultiPLMN}    @{NRPLMNSET_SA_NSA}    @{SNSSAI}    @{TRACKINGAREA}    @{NRREL}    @{NRADJGNB_5}
...    @{NRADJNRCELL}    @{XNLINK}    @{A3_event}

@{RanSharing_HO}
...    NRBTS-1:actRanSharing=true
...    NRBTS-1:actRanSharingEnh=max_10_PLMNs
...    NRBTS-1:actNgcFlexSaMode=true
...    NRBTS-1:actIncXn=true
...    NRBTS-1:actConflictConfiguration=false
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac

@{MultiPLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3

@{NRPLMNSET_SA_NSA}
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}

...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{SNSSAI}
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

@{NRREL}
...    NRCELL-1/NRREL-1:gNbId=36
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=402
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed

@{NRADJGNB_5}
...    NRADJGNB-5:administrativeState=Unlocked
...    NRADJGNB-5:gNodeBId=36
...    NRADJGNB-5:gNbIdLength=22
...    NRADJGNB-5:xnLinkRef=5
...    NRADJGNB-5:gnbPlmn:mcc=311
...    NRADJGNB-5:gnbPlmn:mnc=402
...    NRADJGNB-5:gnbPlmn:mncLength=3

@{NRADJNRCELL}
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=402
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:fiveGsTac=0
...    NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{XNLINK}
...    XNLINK-5:cPlaneIpAddr=10.0.1.124

@{A3_event}
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:sMeasConfigSsbRsrp=0

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2

*** Test Cases ***
5GC001630-ET-H007_verify_lack_of_inter-gnB_HO_for_SA_user_in_shared_gNB_due_to_PLMN_unavailability
    [Documentation]
    ...    1. This user scenario describes gNB behavior when intra-gNB or inter-gNB handover procedure is not initiated for SA user in shared gNB
    ...       due to lack of available PLMN(s).
    ...       All cell candidates for HO are assigned to PLMN(s) which are not supported by the AMF handling the UE.
    ...    2. Test Case Steps:
    ...       a. set all NG link setup
    ...       b. SA UE1 register
    ...       c. do traffic
    ...       d. UE1 HO from real gNB to sim gNB5
    ...    3. Expected Results:
    ...       a. All NG link is up
    ...       b. UE1 register successful
    ...       c. traffic should be ok
    ...       d. HO not initiated due to AMF1 not supported PLMN2
    [Tags]    QC_47196
    Check All XN links is up
    sa ue register and pdu setup    ue_id=1
    Traffic Should Be OK    ue_id=1    type=sa
    UE1 HO failed from real gNB to sim gNB5
    Check PLMN is not supported by AMF
    Release Ues    ue_type=all
    check wireshark log    ${CURDIR}/a2a_H007/a2a.ini    wait_string=UEContextReleaseComplete

*** Keywords ***
Modify Cfg
    #sim gnb5
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:402 ng=10.0.1.125 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a5 amf=2
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=16:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb5}
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=on send_xn_setup=false
    #other
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,200 plmn=311:402
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=1 pointer=1
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1-2 default=on ue=all

Check All XN links is up
    object should exist    XNLINK-5:xnLinkStatus=available

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=${ue_id}    QoS Routing Table

UE1 HO failed from real gNB to sim gNB5
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=25 phycell_id=48 nrsrp_nr=85    fail_regexp=Inter-eNB handover

Check PLMN is not supported by AMF
    file should contain strings    ${SAVE LOG DIRECTORY}/btslog.LOG    Measurement Type: IntraFreqA3
    file should contain strings    ${SAVE LOG DIRECTORY}/btslog.LOG    Plmn PlmnIdentity(MCC: 311, MNC: 402) is not supported by AMF, delete
