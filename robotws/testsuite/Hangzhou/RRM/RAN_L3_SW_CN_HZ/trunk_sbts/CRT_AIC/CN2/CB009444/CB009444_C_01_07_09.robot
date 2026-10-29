*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2Du
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    vDUCNF00    RAN_5G    RAN_Aic    CRT    master_vDU
...    CLOUD_5GC_dRNIC_2vDU_O_AP_LO    team-Beam    owner-ying.yao
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/1cell
${BTS_STARTUP_RETRY}    1
${SA_UE_ID}    1

@{PARAMS_IN_SCF_CU}
...    NRBTS:xnNgRanCfUpNbInfoBackOffTmr=3
...    NRBTS:actAdditionalSliceSupport=true
...    @{xnlink}
...    @{SNSSAI_setting}
...    @{TRACKINGAREA}
...    @{CB009444_feature_enable}

@{PARAMS_IN_SCF_DU1}
...    NRBTS:actAdditionalSliceSupport=true
...    @{DU1_SNSSAI_setting}
...    @{DU1_TRACKINGAREA}

@{PARAMS_IN_SCF_DU2}
...    NRBTS:actAdditionalSliceSupport=true
...    @{DU2_SNSSAI_setting}
...    @{DU2_TRACKINGAREA}

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
...    NRBTS-1/SNSSAI-3:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-3:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-3:sst=1
...    NRBTS-1/SNSSAI-3:sd=13714343
...    NRBTS-1/SNSSAI-3:operationalState=disabled
...    NRBTS-1/SNSSAI-4:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-4:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-4:sst=1
...    NRBTS-1/SNSSAI-4:sd=13714344
...    NRBTS-1/SNSSAI-4:operationalState=disabled
...    NRBTS-1/SNSSAI-5:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-5:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-5:sst=1
...    NRBTS-1/SNSSAI-5:sd=13714345
...    NRBTS-1/SNSSAI-5:operationalState=disabled
...    NRBTS-1/SNSSAI-6:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-6:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-6:sst=1
...    NRBTS-1/SNSSAI-6:sd=13714346
...    NRBTS-1/SNSSAI-6:operationalState=disabled
...    NRBTS-1/SNSSAI-7:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-7:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-7:sst=1
...    NRBTS-1/SNSSAI-7:sd=13714347
...    NRBTS-1/SNSSAI-7:operationalState=disabled
...    NRBTS-1/SNSSAI-8:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-8:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-8:sst=1
...    NRBTS-1/SNSSAI-8:sd=13714348
...    NRBTS-1/SNSSAI-8:operationalState=disabled
...    NRBTS-1/SNSSAI-9:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-9:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-9:sst=1
...    NRBTS-1/SNSSAI-9:sd=13714349
...    NRBTS-1/SNSSAI-9:operationalState=disabled

@{DU1_SNSSAI_setting}
...    NRBTS-1/SNSSAI-1:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-1:sst=1
...    NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-2:sst=1
...    NRBTS-1/SNSSAI-2:sd=13714342
...    NRBTS-1/SNSSAI-3:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-3:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-3:sst=1
...    NRBTS-1/SNSSAI-3:sd=13714343
...    NRBTS-1/SNSSAI-4:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-4:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-4:sst=1
...    NRBTS-1/SNSSAI-4:sd=13714344
...    NRBTS-1/SNSSAI-5:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-5:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-5:sst=1
...    NRBTS-1/SNSSAI-5:sd=13714345
...    NRBTS-1/SNSSAI-6:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-6:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-6:sst=1
...    NRBTS-1/SNSSAI-6:sd=13714346
...    NRBTS-1/SNSSAI-7:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-7:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-7:sst=1
...    NRBTS-1/SNSSAI-7:sd=13714347
...    NRBTS-1/SNSSAI-8:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-8:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-8:sst=1
...    NRBTS-1/SNSSAI-8:sd=13714348
...    NRBTS-1/SNSSAI-9:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-9:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-9:sst=1
...    NRBTS-1/SNSSAI-9:sd=13714349

@{DU2_SNSSAI_setting}
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
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS-1/TRACKINGAREA-2:snssaiList:snssaiDN=${snssaiDNList2}
...    NRBTS-1/TRACKINGAREA-2:fiveGsTac=300
...    NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-2

@{DU1_TRACKINGAREA}
...    delete:MRBTS-1/NRBTS-1/TRACKINGAREA-0
...    delete:MRBTS-1/NRBTS-1/TRACKINGAREA-1
...    NRBTS-1/TRACKINGAREA-1:fiveGsTac=280
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=${snssaiDNList1}
...    NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-1

@{DU2_TRACKINGAREA}
...    delete:MRBTS-1/NRBTS-1/TRACKINGAREA-0
...    delete:MRBTS-1/NRBTS-1/TRACKINGAREA-1
...    NRBTS-1/TRACKINGAREA-2:fiveGsTac=300
...    NRBTS-1/TRACKINGAREA-2:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-2:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-2

${nrPlmnDNList1}    MRBTS-1/NRBTS-1/NRPLMN-1
${snssaiDNList1}    MRBTS-1/NRBTS-1/SNSSAI-1
${snssaiDNList2}    MRBTS-1/NRBTS-1/SNSSAI-2
${snssaiDNList13}    MRBTS-1/NRBTS-1/SNSSAI-1,MRBTS-1/NRBTS-1/SNSSAI-3
${snssaiDNList12}    MRBTS-1/NRBTS-1/SNSSAI-1,MRBTS-1/NRBTS-1/SNSSAI-2
${snssaiDNList123}    MRBTS-1/NRBTS-1/SNSSAI-1,MRBTS-1/NRBTS-1/SNSSAI-2,MRBTS-1/NRBTS-1/SNSSAI-3
${snssaiDNList456}    MRBTS-1/NRBTS-1/SNSSAI-4,MRBTS-1/NRBTS-1/SNSSAI-5,MRBTS-1/NRBTS-1/SNSSAI-6
${snssaiDNList789}    MRBTS-1/NRBTS-1/SNSSAI-7,MRBTS-1/NRBTS-1/SNSSAI-8,MRBTS-1/NRBTS-1/SNSSAI-9
${snssaiDNList1_9}    ${snssaiDNList123},${snssaiDNList456},${snssaiDNList789}
${snssaiDNList13}    MRBTS-1/NRBTS-1/SNSSAI-1,MRBTS-1/NRBTS-1/SNSSAI-3

@{CB009444_feature_enable}
...    NRBTS-1:actSliceConfSync=true

@{CB009444_DU1_delta_add_snssai3}
...    NRBTS-1/SNSSAI-3:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-3:nrPlmnDNList=${nrPlmnDNList1}
...    NRBTS-1/SNSSAI-3:sst=1
...    NRBTS-1/SNSSAI-3:sd=13714343
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3

@{CB009444_CU_delta_trackarea2}
...    NRBTS-1/TRACKINGAREA-2:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-2:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2

@{CB009444_CU_delta_del_snssai3}
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2

@{CB009444_CU_delta_del_snssai123}
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3

@{CB009444_CU_delta_add_trackarea1_1_9}
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-5|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-5
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-6|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-6
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-7|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-7
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-8|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-8
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-9|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-9

@{CB009444_DU1_delta_add_trackarea1_1_3}
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3

@{CB009444DU1_delta_cell1_chg_to_snssaiDNList1_9}
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-5|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-5
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-6|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-6
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-7|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-7
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-8|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-8
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-9|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-9

@{CB009444DU1_delta_cell1_chg_to_snssaiDNList13}
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3

@{CB009444DU1_delta_cell1_chg_to_snssaiDNList1}
...    NRBTS-1/TRACKINGAREA-1:snssaiList:snssaiDN=${snssaiDNList1}

@{CB009444DU2_delta_cell2_chg_to_snssai1}
...    NRBTS-1/TRACKINGAREA-2:snssaiList:snssaiDN=${snssaiDNList1}

@{CB009444DU2_delta_cell2_chg_to_snssai12}
...    NRBTS-1/TRACKINGAREA-2:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-2:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2

@{CB009444_DU1_delta_lock_snssai3}
...    NRBTS-1/SNSSAI-3:administrativeState=Locked

@{CB009444_DU1_delta_unlock_snssai3}
...    NRBTS-1/SNSSAI-3:administrativeState=Unlocked

@{CB009444_DU1_delta_mod_snssai3_paras}
...    NRBTS-1/SNSSAI-3:sst=127
...    NRBTS-1/SNSSAI-3:sd=0

@{CB009444_DU2_delta_lock_snssai2}
...    NRBTS-1/SNSSAI-2:administrativeState=Locked

@{CB009444_DU2_delta_unlock_snssai2}
...    NRBTS-1/SNSSAI-2:administrativeState=Unlocked

@{CB009444_DU2_delta_mod_snssai2_paras}
...    NRBTS-1/SNSSAI-2:sst=128
...    NRBTS-1/SNSSAI-2:sd=16777214

@{CB009444_CU_delta_lock_snssai2}
...    NRBTS-1/TRACKINGAREA-2:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-2:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS-1/SNSSAI-2:administrativeState=Locked

@{CB009444_CU_delta_unlock_snssai2}
...    NRBTS-1/TRACKINGAREA-2:snssaiList:snssaiDN=${snssaiDNList2}
...    NRBTS-1/SNSSAI-2:administrativeState=Unlocked

@{CB009444_CU_delta_mod_snssai2_paras}
...    NRBTS-1/SNSSAI-2:sst=128
...    NRBTS-1/SNSSAI-2:sd=16777214

*** Test Cases ***
CB009444_C_01_vRAN_TDD_SA_slice_modify_Succ_delete_add_slice_on_CU_and_vDUs
    [Documentation]
    ...    1. This user scenario describes successful slice modification on CU and vDU side in
    ...       cloud gNB configuration.Consistent slice list on gNB is expected as intersection
    ...       of slice list on CU and vDU whenever they change. Slice modification may be
    ...       performed by changing slice administrative state.
    ...    2. Test Case Steps:
    ...       a. on vDU1 webem add slice SNSSAI-3, vDU1: NRCELL-1 -> TRACKINGAREA-1 -> SNSSAI-1; SNSSAI-3
    ...       b. setup PDU session on slice SNSSAI-3
    ...       c. on CU webem delete slice SNSSAI-3, CU contain: NRCELL-1 -> TRACKINGAREA-1 -> SNSSAI-1; SNSSAI-2
    ...       d. setup PDU session on wts slice SNSSAI-5(for bbu the slice is SNSSAI-3), pdu session
    ...          setup failed on slice 2
    [Tags]    QC_282769
    Object Should Exist In Cu    XNLINK-3:xnLinkStatus=available
    UE Register To Cell1 Successfully And Traffic OK    index=1    ue_id=1    nwslice=1
    Release Ues    ue_id=1    ue_type=sa

    OnlineParamChange Du    DELTA_PARAMS_IN_SCF_DU=${CB009444_DU1_delta_add_snssai3}    index=2
    Parameter Check For Step2

    UE Register To Cell1 Successfully And Traffic OK    index=3    ue_id=1    nwslice=5
    Release Ues    ue_id=1    ue_type=sa

    OnlineParamChange CU    DELTA_PARAMS_IN_SCF_CU=${CB009444_CU_delta_del_snssai3}    index=4

    UE Register To Cell1 Not OK    index=5    ue_id=1    nwslice=5
    Release Ues    ue_id=1    ue_type=sa
    Recovery Parameters For TC01

    Check WireShark Log Aic    ${CURDIR}${/}a2a_C01${/}a2a_step2.ini
    Check WireShark Log Aic    ${CURDIR}${/}a2a_C01${/}a2a_step4.ini

CB009444_C_09_vRAN_TDD_SA_multiSlice_modify_Succ_add_delete_slice_on_vDUs
    [Documentation]
    ...    1. This user scenario describes successful slice modification on CU and vDU side in
    ...       cloud gNB configuration.Consistent slice list on gNB is expected as intersection
    ...       of slice list on CU and vDU whenever they change. Slice modification may be
    ...       performed by changing slice administrative state.
    ...    2. Test Case Steps:
    ...       a. on vDU1 webem add slice SNSSAI-4~9, vDU1: NRCELL-1 -> TRACKINGAREA-1 ->
    ...          SNSSAI-1; SNSSAI-2; SNSSAI-3; SNSSAI-4; SNSSAI-5; SNSSAI-6; SNSSAI-7; SNSSAI-8;
    ...          SNSSAI-9.
    ...       b. on vDU2 webem delete slice SNSSAI-2, vDU2 contain: NRCELL-2 -> T
    ...          RACKINGAREA-2 -> SNSSAI-1
    [Tags]    QC_284150
    Paramter Prepare For TC09
    Object Should Exist In Cu    XNLINK-3:xnLinkStatus=available

    UE Register To Cell1 Successfully And Traffic OK    index=1    ue_id=1    nwslice=1
    Release Ues    ue_id=1    ue_type=sa

    OnlineParamChange DU    DELTA_PARAMS_IN_SCF_DU=${CB009444DU1_delta_cell1_chg_to_snssaiDNList1_9}    index=2
    Parameter Check For TC09 Step2

    OnlineParamChange DU2    DELTA_PARAMS_IN_SCF_DU=${CB009444DU2_delta_cell2_chg_to_snssai1}    index=3
    Parameter Check For TC09 Step3
    Fm Fault Should Be Raised Cu    fault_id=7105    timeout=300

    UE Register To Cell1 Successfully And Traffic OK    index=4    ue_id=1    nwslice=7
    Release Ues    ue_id=1    ue_type=sa

    Recovery Parameters For TC09

    Check WireShark Log Aic    ${CURDIR}${/}a2a_C09${/}a2a_step2.ini
    Check WireShark Log Aic    ${CURDIR}${/}a2a_C09${/}a2a_step3.ini

CB009444_C_07_vRAN_TDD_SA_modify_slice_configure_sst_sd_plmn_on_CU_webem
    [Documentation]
    ...    1. This user scenario describes proper displaying in WebEM on CU all Slices configured under vDU NIDD
    ...    2. Test Case Steps:
    ...       a. on vDU1 webem,change administrativeState of SNSSAI-3 to lock,
    ...          modify following configurations of SNSSAI-3:sst->127, sd->0,
    ...          change administrativeState of SNSSAI-3 to unlock.
    ...       b. on vDU2 webem,change administrativeState of SNSSAI-2 to lock,
    ...           modify following configurations of SNSSAI-2: Sst->128, sd->16777214
    ...           change administrativeState of SNSSAI-2 to unlock.
    ...       c. on vCU webem,change administrativeState of SNSSAI-3 to lock,
    ...           modify following configurations of SNSSAI-2: Sst->128, sd->16777214
    ...           hange administrativeState of SNSSAI-2 to unlock.
    ...       d. setup PDU session on wts slice 2(Sst->128, sd->16777214).
    [Tags]    QC_282767
    Paramter Prepare For TC07
    Object Should Exist In Cu    XNLINK-3:xnLinkStatus=available

    OnlineParamChange DU1 Parameters For T07    index=2
    Parameter Check For Step2 For T07

    OnlineParamChange DU2 Parameters For T07    index=3
    Parameter Check For Step3 For T07

    OnlineParamChange CU Parameters For T07    index=4
    Parameter Check For Step4 For T07

    UE Register To Cell1 Successfully And Traffic OK    index=5    ue_id=2    nwslice=2
    Release Ues    ue_id=2    ue_type=sa

    Check WireShark Log Aic    ${CURDIR}${/}a2a_C07${/}a2a_step2.ini
    Check WireShark Log Aic    ${CURDIR}${/}a2a_C07${/}a2a_step3.ini

*** Keywords ***
OnlineParamChange CU
    [Arguments]    ${DELTA_PARAMS_IN_SCF_CU}    ${index}
    Start To Capture Wireshark RRC Log    ${index}
    delta commission parameters Cu    ${DELTA_PARAMS_IN_SCF_CU}
    Cells Should Be Onair Du    timeout=300
    Cells Should Be Onair Du2    timeout=300
    Stop To Capture Wireshark RRC Log    ${index}

Paramter Prepare For TC09
    Delta commission parameters Cu    ${CB009444_CU_delta_add_trackarea1_1_9}
    Cells Should Be Onair Du    timeout=300
    Cells Should Be Onair Du2    timeout=300
    Delta commission parameters Du    ${CB009444_DU1_delta_add_trackarea1_1_3}
    Cells Should Be Onair Du    timeout=300
    Cells Should Be Onair Du2    timeout=300

Recovery Parameters For TC09
    Delta commission parameters Du    ${CB009444DU1_delta_cell1_chg_to_snssaiDNList1}
    Delta commission parameters Du2    ${CB009444DU2_delta_cell2_chg_to_snssai12}
    Delta commission parameters Cu    ${CB009444_CU_delta_del_snssai123}
    Cells Should Be Onair Du    timeout=300
    Cells Should Be Onair Du2    timeout=300

Recovery Parameters For TC01
    Delta commission parameters Du    ${CB009444DU1_delta_cell1_chg_to_snssaiDNList1}
    Delta commission parameters Cu    ${CB009444_CU_delta_del_snssai123}
    Cells Should Be Onair Du    timeout=300
    Cells Should Be Onair Du2    timeout=300

Paramter Prepare For TC07
    Delta commission parameters Cu    ${CB009444_CU_delta_trackarea2}
    Delta commission parameters Du    ${CB009444DU1_delta_cell1_chg_to_snssaiDNList13}
#    Delta commission parameters Du2    ${CB009444DU2_delta_cell2_chg_to_snssai12}
    Cells Should Be Onair Du    timeout=300
    Cells Should Be Onair Du2    timeout=300

OnlineParamChange DU
    [Arguments]    ${DELTA_PARAMS_IN_SCF_DU}    ${index}
    Start To Capture Wireshark RRC Log    ${index}
    delta commission parameters Du    ${DELTA_PARAMS_IN_SCF_DU}
    Cells Should Be Onair Du    timeout=300
    Cells Should Be Onair Du2    timeout=300
    Stop To Capture Wireshark RRC Log    ${index}

OnlineParamChange DU2
    [Arguments]    ${DELTA_PARAMS_IN_SCF_DU}    ${index}
    Start To Capture Wireshark RRC Log    ${index}
    delta commission parameters Du2    ${DELTA_PARAMS_IN_SCF_DU}
    Cells Should Be Onair Du    timeout=300
    Cells Should Be Onair Du2    timeout=300
    Stop To Capture Wireshark RRC Log    ${index}

Start To Capture Wireshark RRC Log
    [Arguments]    ${index}
    Start To Capture Wireshark Log Vcu    log${index}
    Start To Capture Wireshark Log Vdu    log${index}
    Start RRC Log Aic    rrclog${index}

Stop To Capture Wireshark RRC Log
    [Arguments]    ${index}
    Stop RRC Log Aic
    Stop To Capture Wireshark Log Vcu    log${index}
    Stop To Capture Wireshark Log Vdu    log${index}
    Stop To Capture Wireshark Log Vdu2    log${index}
    Get RRC Log

UE Register To Cell1 Successfully And Traffic OK
    [Arguments]    ${index}    ${ue_id}=${SA_UE_ID}    ${nwslice}=1
    Start To Capture Wireshark RRC Log    ${index}
    SA UE Register And PDU Setup    ue_id=${ue_id}    nwslice=${nwslice}
    Send Throughput    ue_id=${ue_id}
    Verify Throughput    ue_id=${ue_id}
    Stop To Capture Wireshark RRC Log    ${index}

UE Register To Cell1 Not OK
    [Arguments]    ${index}    ${ue_id}=${SA_UE_ID}    ${nwslice}=1
    SA UE Register And PDU Setup NOK    ue_id=${ue_id}    nwslice=${nwslice}

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

SA UE Register And PDU Setup NOK
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=1
     ...    Network Slice-${nwslice} not found in allowed nssai

Modify Cfg Aic
    Update Cfg Aic    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf_region_id=1
    Update Cfg Aic    set_nwslice id=2 snssai=0x80:0xFFFFFE ue=all amf_region_id=1
    Update Cfg Aic    set_nwslice id=3 snssai=0x7F:0x0 ue=all amf_region_id=1
    Update Cfg Aic    set_nwslice id=4 snssai=0x01:0xD143A6 ue=all amf_region_id=1
    Update Cfg Aic    set_nwslice id=5 snssai=0x01:0xD143A7 ue=all amf_region_id=1

    Update Cfg Aic    set_nwslice id=6 snssai=0x01:0xD143A8 ue=all amf=1
    Update Cfg Aic    set_nwslice id=7 snssai=0x01:0xD143A9 ue=all amf=1
    Update Cfg Aic    set_nwslice id=8 snssai=0x01:0xD143AA ue=1 amf=1
    Update Cfg Aic    set_nwslice id=9 snssai=0x01:0xD143AB ue=2 amf=1
    Update Cfg Aic    set_nwslice id=10 snssai=0x01:0xD143AC ue=3 amf=1
    Update Cfg Aic    set_nwslice id=11 snssai=0x01:0xD143AD ue=4 amf=1

    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.11.11 gnb_id=0x3:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.11 nssai=0x1:0xd143a5 amf=1 plmnList=311:489
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb3}
    Update Cfg Aic    ${set_gnb3_cell1}
    Update Cfg Aic    gnb_make_plmnset plmn_set_id=1 dual_conn=off gnb=3 cell=1 tac=280 plmn_id_list=311:489
    Update Cfg Aic    gnb_set_nwslice_per_plmn gnb=3 cell=1 plmn_set_id=1 plmn=311:489 nssai=0x01:0xd143a5
    Update Cfg Aic    gnb_param id=3 xn_listening_socket=on send_xn_setup=false

Parameter Check For Step2
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-3:operationalState=enabled
    ${nrDuSnssaiDNList_nrdu1}    Get SCF Parameter Value Cu    MRBTS-1/NRBTS-1/NRDU-1:nrDuSnssaiDNList
    ${nrDuSnssaiDNList_nrdu2}    Get SCF Parameter Value Cu    MRBTS-1/NRBTS-1/NRDU-2:nrDuSnssaiDNList
    ${nrDuSnssaiDNList_nrdu1_regex}    String.Get Regexp Matches    ${nrDuSnssaiDNList_nrdu1}    (MRBTS-[0-9]*/NRBTS-[0-9]*/NRDU_SNSSAI-\\d+)    1
    ${nrDuSnssaiDNList_nrdu2_regex}    String.Get Regexp Matches    ${nrDuSnssaiDNList_nrdu2}    (MRBTS-[0-9]*/NRBTS-[0-9]*/NRDU_SNSSAI-\\d+)    1
    ${nrDuSnssaiDNList_nrdu1_len}    Get Length    ${nrDuSnssaiDNList_nrdu1_regex}
    ${nrDuSnssaiDNList_nrdu2_len}    Get Length    ${nrDuSnssaiDNList_nrdu2_regex}

    Should Be Equal    '${nrDuSnssaiDNList_nrdu1_len}'    '2'    NRDU-1 Should only contain 2 NRDU_SNSSAI!!
    Should Be Equal    '${nrDuSnssaiDNList_nrdu2_len}'    '2'    NRDU-2 Should only contain 2 NRDU_SNSSAI!!

    Check sd Values Is Correct

Check sd Values Is Correct
    ${nrdu_snssai_1_sd}    Get SCF Parameter Value Cu    MRBTS-1/NRBTS-1/NRDU_SNSSAI-1:sd
    ${nrdu_snssai_2_sd}    Get SCF Parameter Value Cu    MRBTS-1/NRBTS-1/NRDU_SNSSAI-2:sd
    ${nrdu_snssai_3_sd}    Get SCF Parameter Value Cu    MRBTS-1/NRBTS-1/NRDU_SNSSAI-3:sd
    Should Match Regexp    ${nrdu_snssai_1_sd}    1371434[1-3]    sd should be in 1371434[1-3]!!
    Should Match Regexp    ${nrdu_snssai_2_sd}    1371434[1-3]    sd should be in 1371434[1-3]!!
    Should Match Regexp    ${nrdu_snssai_3_sd}    1371434[1-3]    sd should be in 1371434[1-3]!!

Parameter Check For TC09 Step2
    ${nrDuSnssaiDNList_nrdu1}    Get SCF Parameter Value Cu    MRBTS-1/NRBTS-1/NRDU-1:nrDuSnssaiDNList
    ${nrDuSnssaiDNList_nrdu1_regex}    String.Get Regexp Matches    ${nrDuSnssaiDNList_nrdu1}
     ...    (MRBTS-[0-9]*/NRBTS-[0-9]*/NRDU_SNSSAI-\\d+)    1
    ${nrDuSnssaiDNList_nrdu1_len}    Get Length    ${nrDuSnssaiDNList_nrdu1_regex}
    Should Be Equal     '${nrDuSnssaiDNList_nrdu1_len}'    '9'    NRDU-1 Should only contain 9 NRDU_SNSSAI!!
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-4:operationalState=enabled
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-5:operationalState=enabled
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-6:operationalState=enabled
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-7:operationalState=enabled
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-8:operationalState=enabled
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-9:operationalState=enabled

Parameter Check For TC09 Step3
    ${nrDuSnssaiDNList_nrdu1}    Get SCF Parameter Value Cu    MRBTS-1/NRBTS-1/NRDU-1:nrDuSnssaiDNList
    ${nrDuSnssaiDNList_nrdu2}    Get SCF Parameter Value Cu    MRBTS-1/NRBTS-1/NRDU-2:nrDuSnssaiDNList
    ${nrDuSnssaiDNList_nrdu1_regex}    String.Get Regexp Matches    ${nrDuSnssaiDNList_nrdu1}
     ...    (MRBTS-[0-9]*/NRBTS-[0-9]*/NRDU_SNSSAI-\\d+)    1
    ${nrDuSnssaiDNList_nrdu2_regex}    String.Get Regexp Matches    ${nrDuSnssaiDNList_nrdu2}
     ...    (MRBTS-[0-9]*/NRBTS-[0-9]*/NRDU_SNSSAI-\\d+)    1
    ${nrDuSnssaiDNList_nrdu1_len}    Get Length    ${nrDuSnssaiDNList_nrdu1_regex}
    ${nrDuSnssaiDNList_nrdu2_len}    Get Length    ${nrDuSnssaiDNList_nrdu2_regex}
    Should Be Equal     '${nrDuSnssaiDNList_nrdu1_len}'    '9'    NRDU-1 Should only contain 9 NRDU_SNSSAI!!
    Should Be Equal     '${nrDuSnssaiDNList_nrdu2_len}'    '1'    NRDU-2 Should only contain 1 NRDU_SNSSAI!!
    SNSSAI 4 to 9 All enable

SNSSAI 4 to 9 All enable
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-4:operationalState=enabled
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-5:operationalState=enabled
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-6:operationalState=enabled
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-7:operationalState=enabled
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-8:operationalState=enabled
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-9:operationalState=enabled
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/NRCELL-2:barringStatus=barred

OnlineParamChange CU Parameters For T07
    [Arguments]    ${index}
    Start To Capture Wireshark RRC Log    ${index}
    delta commission parameters Cu    ${CB009444_CU_delta_lock_snssai2}
    delta commission parameters Cu    ${CB009444_CU_delta_mod_snssai2_paras}
    delta commission parameters Cu    ${CB009444_CU_delta_unlock_snssai2}
    Cells Should Be Onair Du    timeout=300
    Cells Should Be Onair Du2    timeout=300
    Stop To Capture Wireshark RRC Log    ${index}

OnlineParamChange DU1 Parameters For T07
    [Arguments]    ${index}
    Start To Capture Wireshark RRC Log    ${index}
    Delta Commission Parameters Du    ${CB009444_DU1_delta_lock_snssai3}
    Delta Commission Parameters Du    ${CB009444_DU1_delta_mod_snssai3_paras}
    Delta Commission Parameters Du    ${CB009444_DU1_delta_unlock_snssai3}
    Cells Should Be Onair Du    timeout=300
    Cells Should Be Onair Du2    timeout=300
    Sleep    300s    Sleep for message collection
    Stop To Capture Wireshark RRC Log    ${index}

OnlineParamChange DU2 Parameters For T07
    [Arguments]    ${index}
    Start To Capture Wireshark RRC Log    ${index}
    Delta Commission Parameters Du2    ${CB009444_DU2_delta_lock_snssai2}
    Delta Commission Parameters Du2    ${CB009444_DU2_delta_mod_snssai2_paras}
    Delta Commission Parameters Du2    ${CB009444_DU2_delta_unlock_snssai2}
    Cells Should Be Onair Du    timeout=300
    Cells Should Be Onair Du2    timeout=300
    Sleep    300s    Sleep for message collection
    Stop To Capture Wireshark RRC Log    ${index}

Parameter Check For Step2 For T07
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-3:operationalState=disabled
    ${nrDuSnssaiDNList_nrdu1}    Get SCF Parameter Value Cu    MRBTS-1/NRBTS-1/NRDU-1:nrDuSnssaiDNList
    ${nrDuSnssaiDNList_nrdu1_regex}    String.Get Regexp Matches    ${nrDuSnssaiDNList_nrdu1}
     ...    (MRBTS-[0-9]*/NRBTS-[0-9]*/NRDU_SNSSAI-\\d+)    1
    ${nrDuSnssaiDNList_nrdu1_len}    Get Length    ${nrDuSnssaiDNList_nrdu1_regex}
    Should Be Equal     '${nrDuSnssaiDNList_nrdu1_len}'    '2'    NRDU-1 Should only contain 1 NRDU_SNSSAI!!
    Check Sst and Sd Values For Du1    ${nrDuSnssaiDNList_nrdu1_regex}

Check Sst and Sd Values For Du1
    [Arguments]    ${nrDuSnssaiDNList_nrdu1_regex}
    ${sd1}    Get SCF Parameter Value Cu    ${nrDuSnssaiDNList_nrdu1_regex[0]}:sd
    ${sst1}    Get SCF Parameter Value Cu    ${nrDuSnssaiDNList_nrdu1_regex[0]}:sst
    ${sd2}    Get SCF Parameter Value Cu    ${nrDuSnssaiDNList_nrdu1_regex[1]}:sd
    ${sst2}    Get SCF Parameter Value Cu    ${nrDuSnssaiDNList_nrdu1_regex[1]}:sst
    ${sst_list}    Create List    ${sst1}    ${sst2}
    ${sd_list}    Create List    ${sd1}    ${sd2}
    Should Contain     ${sst_list}    127    sst id 127 does not exist!!
    Should Contain     ${sd_list}    0    st id 0 does not exist!!

Parameter Check For Step3 For T07
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-2:operationalState=disabled
    ${nrDuSnssaiDNList_nrdu2}    Get SCF Parameter Value Cu    MRBTS-1/NRBTS-1/NRDU-2:nrDuSnssaiDNList
    ${nrDuSnssaiDNList_nrdu2_regex}    String.Get Regexp Matches    ${nrDuSnssaiDNList_nrdu2}    (MRBTS-[0-9]*/NRBTS-[0-9]*/NRDU_SNSSAI-\\d+)    1
    ${nrDuSnssaiDNList_nrdu2_len}    Get Length    ${nrDuSnssaiDNList_nrdu2_regex}
    Should Be Equal     '${nrDuSnssaiDNList_nrdu2_len}'    '2'    NRDU-2 Should only contain 2 NRDU_SNSSAI!!
    Check Sst and Sd Values For Du2    ${nrDuSnssaiDNList_nrdu2_regex}

Check Sst and Sd Values For Du2
    [Arguments]    ${nrDuSnssaiDNList_nrdu2_regex}
    ${sd1}    Get SCF Parameter Value Cu    ${nrDuSnssaiDNList_nrdu2_regex[0]}:sd
    ${sst1}    Get SCF Parameter Value Cu    ${nrDuSnssaiDNList_nrdu2_regex[0]}:sst
    ${sd2}    Get SCF Parameter Value Cu    ${nrDuSnssaiDNList_nrdu2_regex[1]}:sd
    ${sst2}    Get SCF Parameter Value Cu    ${nrDuSnssaiDNList_nrdu2_regex[1]}:sst
    ${sst_list}    Create List    ${sst1}    ${sst2}
    ${sd_list}    Create List    ${sd1}    ${sd2}
    Should Contain     ${sst_list}    128    sst id 128 does not exist!!
    Should Contain     ${sd_list}    16777214    st id 16777214 does not exist!!

Parameter Check For Step4 For T07
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-2:operationalState=enabled
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-2:sd=16777214
    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SNSSAI-2:sst=128
