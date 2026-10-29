*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS    team-SG1
...               owner-feng.chen,ying.shang    release-SBTS22R3
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{LTE518}    @{LTE1231}    @{qciOperatortable1}    @{CB007897}    @{LNREL}
@{LTE518}    LNBTS:actOperatorQCI=true
@{LTE1231}    LNBTS:actOperatorQCIGBR=true
@{CB007897}    LNBTS:actIncNumOperatorQci=true
@{CB007897_disable}    LNBTS:actIncNumOperatorQci=false
@{LNREL}
...    LNCEL-1/LNREL-2:amleAllowed=false
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=2
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
@{qciOperatortable1}
...    LNBTS:qciTabOperator:resType=nonGBR|qci=200
...    LNBTS:qciTabOperator:resType=nonGBR|qci=98
...    LNBTS:qciTabOperator:resType=nonGBR|qci=100
...    LNBTS:qciTabOperator:resType=nonGBR|qci=128
...    LNBTS:qciTabOperator:resType=nonGBR|qci=129
...    LNBTS:qciTabOperator:resType=nonGBR|qci=130
...    LNBTS:qciTabOperator:resType=nonGBR|qci=131
...    LNBTS:qciTabOperator:resType=nonGBR|qci=132
...    LNBTS:qciTabOperator:resType=nonGBR|qci=133
...    LNBTS:qciTabOperator:resType=nonGBR|qci=134    #10 nonGBR(98,100,128-134,200), 11 GBR(201-210,254)
...    LNBTS:qciTabOperator:resType=GBR|qci=201
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=201
...    LNBTS:qciTabOperator:lcgid=2|qci=201
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=201
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=201
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=201
...    LNBTS:qciTabOperator:resType=GBR|qci=202
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=202
...    LNBTS:qciTabOperator:lcgid=2|qci=202
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=202
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=202
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=202
...    LNBTS:qciTabOperator:resType=GBR|qci=203
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=203
...    LNBTS:qciTabOperator:lcgid=2|qci=203
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=203
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=203
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=203
...    LNBTS:qciTabOperator:resType=GBR|qci=204
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=204
...    LNBTS:qciTabOperator:lcgid=2|qci=204
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=204
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=204
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=204
...    LNBTS:qciTabOperator:resType=GBR|qci=205
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=205
...    LNBTS:qciTabOperator:lcgid=2|qci=205
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=205
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=205
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=205
...    LNBTS:qciTabOperator:resType=GBR|qci=206
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=206
...    LNBTS:qciTabOperator:lcgid=2|qci=206
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=206
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=206
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=206
...    LNBTS:qciTabOperator:resType=GBR|qci=207
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=207
...    LNBTS:qciTabOperator:lcgid=2|qci=207
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=207
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=207
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=207
...    LNBTS:qciTabOperator:resType=GBR|qci=208
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=208
...    LNBTS:qciTabOperator:lcgid=2|qci=208
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=208
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=208
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=208
...    LNBTS:qciTabOperator:resType=GBR|qci=209
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=209
...    LNBTS:qciTabOperator:lcgid=2|qci=209
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=209
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=209
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=209
...    LNBTS:qciTabOperator:resType=GBR|qci=210
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=210
...    LNBTS:qciTabOperator:lcgid=2|qci=210
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=210
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=210
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=210
...    LNBTS:qciTabOperator:resType=GBR|qci=254
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=254
...    LNBTS:qciTabOperator:lcgid=2|qci=254
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=254
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=254
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=254
@{qciOperatortable2}
...    LNBTS:qciTabOperator:resType=nonGBR|qci=143
...    LNBTS:qciTabOperator:resType=nonGBR|qci=99
...    LNBTS:qciTabOperator:resType=nonGBR|qci=135
...    LNBTS:qciTabOperator:resType=nonGBR|qci=136
...    LNBTS:qciTabOperator:resType=nonGBR|qci=137
...    LNBTS:qciTabOperator:resType=nonGBR|qci=138
...    LNBTS:qciTabOperator:resType=nonGBR|qci=139
...    LNBTS:qciTabOperator:resType=nonGBR|qci=140
...    LNBTS:qciTabOperator:resType=nonGBR|qci=141
...    LNBTS:qciTabOperator:resType=nonGBR|qci=142
...    LNBTS:qciTabOperator:resType=nonGBR|qci=144
...    LNBTS:qciTabOperator:resType=nonGBR|qci=145    #12 nonGBR (99,135-145), 9 GBR(211-219)
...    LNBTS:qciTabOperator:resType=GBR|qci=211
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=211
...    LNBTS:qciTabOperator:lcgid=2|qci=211
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=211
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=211
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=211
...    LNBTS:qciTabOperator:resType=GBR|qci=212
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=212
...    LNBTS:qciTabOperator:lcgid=2|qci=212
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=212
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=212
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=212
...    LNBTS:qciTabOperator:resType=GBR|qci=213
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=213
...    LNBTS:qciTabOperator:lcgid=2|qci=213
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=213
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=213
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=213
...    LNBTS:qciTabOperator:resType=GBR|qci=214
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=214
...    LNBTS:qciTabOperator:lcgid=2|qci=214
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=214
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=214
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=214
...    LNBTS:qciTabOperator:resType=GBR|qci=215
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=215
...    LNBTS:qciTabOperator:lcgid=2|qci=215
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=215
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=215
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=215
...    LNBTS:qciTabOperator:resType=GBR|qci=216
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=216
...    LNBTS:qciTabOperator:lcgid=2|qci=216
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=216
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=216
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=216
...    LNBTS:qciTabOperator:resType=GBR|qci=217
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=217
...    LNBTS:qciTabOperator:lcgid=2|qci=217
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=217
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=217
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=217
...    LNBTS:qciTabOperator:resType=GBR|qci=218
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=218
...    LNBTS:qciTabOperator:lcgid=2|qci=218
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=218
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=218
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=218
...    LNBTS:qciTabOperator:resType=GBR|qci=219
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=219
...    LNBTS:qciTabOperator:lcgid=2|qci=219
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=219
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=219
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=219
@{qciOperatortable}   @{qciOperatortable1}    @{qciOperatortable2}
${ue_eutra_capabilities}    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C10820803
...    04218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B08200828410518208384100414208206
...    1040105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0
...    B82E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71
...    E00020406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E780C000048080C2609A143C037FC00000A000000610
...    00880004
@{qciOperatortable_delete}
...    delete:LNBTS:qciTabOperator:qci=98
...    delete:LNBTS:qciTabOperator:qci=99
...    delete:LNBTS:qciTabOperator:qci=101
...    delete:LNBTS:qciTabOperator:qci=128
...    delete:LNBTS:qciTabOperator:qci=129
...    delete:LNBTS:qciTabOperator:qci=130
...    delete:LNBTS:qciTabOperator:qci=131
...    delete:LNBTS:qciTabOperator:qci=132
...    delete:LNBTS:qciTabOperator:qci=133
...    delete:LNBTS:qciTabOperator:qci=134
...    delete:LNBTS:qciTabOperator:qci=135
...    delete:LNBTS:qciTabOperator:qci=136
...    delete:LNBTS:qciTabOperator:qci=137
...    delete:LNBTS:qciTabOperator:qci=201
...    delete:LNBTS:qciTabOperator:qci=202
...    delete:LNBTS:qciTabOperator:qci=203
...    delete:LNBTS:qciTabOperator:qci=204
...    delete:LNBTS:qciTabOperator:qci=205
...    delete:LNBTS:qciTabOperator:qci=206
...    delete:LNBTS:qciTabOperator:qci=207
...    delete:LNBTS:qciTabOperator:qci=208
...    delete:LNBTS:qciTabOperator:qci=209
...    delete:LNBTS:qciTabOperator:qci=210
...    delete:LNBTS:qciTabOperator:qci=211
...    delete:LNBTS:qciTabOperator:qci=212


*** Test Cases ***
CB007897-SR-A-B1_01_01_42 qciTabOperator can be cerated and bearers with these qcis can be used normally
    [Tags]
    Create 42 qciTabOperator
    UE attach to cell1    ue_id=1-13
    Add bearers with different 42 qciOperator should be successful

CB007897-SR-A-B1_02_01_actIncNumOperatorQci can not set to false when operator specific QCIs exceed 21
    [Tags]
    Create 42 qciTabOperator
    Delete some qciTabOperator to be less than 21
    Disable 7897 feature flag should be successful
    Attach UE and add bearers with different existed qciOperator should be successful

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=16    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    eNB_1    enb_id=1    id_type=wts

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 130, gbr: no, priority: 15, delay: 100, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 201, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 202, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 203, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 204, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 205, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 206, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 207, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 208, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 209, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 210, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 98, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 100, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 128, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 129, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 254, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    FOR    ${ue_set_id}     IN RANGE    1    6
        Update Yaml    UEs/UE_sets/${ue_set_id}    bearer: 'bearer_set_2'    release: '15'    nea: 'null'    nia: 'null'
    END
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 131, gbr: no, priority: 15, delay: 100, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 132, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 133, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 134, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 200, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 135, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 99, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 136, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 137, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 138, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 211, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 212, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 213, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 214, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 215, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 216, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    FOR    ${ue_set_id}     IN RANGE    6    11
        Update Yaml    UEs/UE_sets/${ue_set_id}    bearer: 'bearer_set_3'    release: '15'    nea: 'null'    nia: 'null'
    END
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_4:
    ...     - {qci: 139, gbr: no, priority: 15, delay: 100, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 140, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 141, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 142, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 143, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 144, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 145, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 217, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 218, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 219, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    FOR    ${ue_set_id}     IN RANGE    11    16
        Update Yaml    UEs/UE_sets/${ue_set_id}    bearer: 'bearer_set_4'    release: '15'    nea: 'null'    nia: 'null'
    END
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_5:
    ...     - {qci: 130, gbr: no, priority: 15, delay: 100, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 201, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, preprovisioned: on,
    ...    default: off, filter: 2, precedence: 2,
    ...    preemption: off, vulnerability: off}
    ...     - {qci: 202, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, preprovisioned: on,
    ...    default: off, filter: 3, precedence: 3,
    ...    preemption: off, vulnerability: off}
    ...     - {qci: 203, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, preprovisioned: on,
    ...    default: off, filter: 4, precedence: 4,
    ...    preemption: off, vulnerability: off}
    ...     - {qci: 204, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 205, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 206, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 207, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 208, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 209, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 210, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 98, gbr: no, priority: 15, delay: 100, pdn: 1, preprovisioned: on, default: off, filter: 12, precedence: 12, preemption: off,
    ...    vulnerability: off}
    ...     - {qci: 100, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 128, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 129, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 254, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    Update Yaml    UEs/UE_sets/2    bearer: 'bearer_set_5'    release: '15'    nea: 'null'    nia: 'null'
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_6:
    ...     - {qci: 139, gbr: no, priority: 15, delay: 100, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 132, gbr: no, priority: 15, delay: 100, pdn: 1, preprovisioned: on, default: off, filter: 1, precedence: 1, preemption: off,
    ...    vulnerability: off}
    ...     - {qci: 141, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 142, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 200, gbr: no, priority: 15, delay: 100, pdn: 1, preprovisioned: on, default: off, filter: 4, precedence: 4, preemption: off,
    ...    vulnerability: off}
    ...     - {qci: 144, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 145, gbr: no, priority: 15, delay: 100, pdn: 1}
    ...     - {qci: 217, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 218, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 219, gbr: yes, priority: 15, delay: 100, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    Update Yaml    UEs/UE_sets/12    bearer: 'bearer_set_6'    release: '15'    nea: 'null'    nia: 'null'

UE attach to cell1
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_attach id=${ue_id} cell=1 ue_eutra_capabilities=${ue_eutra_capabilities}

Add one Bearer for UE
    [Arguments]    ${ue_id}=11    ${bearer_id}=11    ${pass_regx}=created
    ${filter_id}    evaluate    ${bearer_id}-1
    Execute Egate Command    bearer_add ue=${ue_id} id=${bearer_id} filter=${filter_id} precedence=${filter_id}
    ...    ${pass_regx}    timeout=20s

create 42 qciTabOperator
    Delta Commission Parameters     ${qciOperatortable}

Delete some qciTabOperator to be less than 21
    Delta Commission Parameters    ${qciOperatortable_delete}

Disable 7897 feature flag should be successful
    Delta Commission Parameters    ${CB007897_disable}

Add bearers with different 42 qciOperator should be successful
    Add one Bearer for UE    ue_id=1    bearer_id=2
    Add one Bearer for UE    ue_id=1    bearer_id=3
    Add one Bearer for UE    ue_id=1    bearer_id=4
    Add one Bearer for UE    ue_id=1    bearer_id=12
    Add one Bearer for UE    ue_id=1    bearer_id=13
    Add one Bearer for UE    ue_id=2    bearer_id=14
    Add one Bearer for UE    ue_id=3    bearer_id=15
    Add one Bearer for UE    ue_id=3    bearer_id=16
    Add one Bearer for UE    ue_id=3    bearer_id=5
    Add one Bearer for UE    ue_id=3    bearer_id=6
    Add one Bearer for UE    ue_id=4    bearer_id=7
    Add one Bearer for UE    ue_id=4    bearer_id=8
    Add one Bearer for UE    ue_id=4    bearer_id=9
    Add one Bearer for UE    ue_id=5    bearer_id=10
    Add one Bearer for UE    ue_id=5    bearer_id=11
    Add one Bearer for UE    ue_id=6    bearer_id=3
    Add one Bearer for UE    ue_id=6    bearer_id=4
    Add one Bearer for UE    ue_id=6    bearer_id=11
    Add one Bearer for UE    ue_id=7    bearer_id=12
    Add one Bearer for UE    ue_id=7    bearer_id=6
    Add one Bearer for UE    ue_id=7    bearer_id=7
    Add one Bearer for UE    ue_id=7    bearer_id=8
    Add one Bearer for UE    ue_id=7    bearer_id=9
    Add one Bearer for UE    ue_id=8    bearer_id=10
    Add one Bearer for UE    ue_id=8    bearer_id=13
    Add one Bearer for UE    ue_id=8    bearer_id=14
    Add one Bearer for UE    ue_id=8    bearer_id=15
    Add one Bearer for UE    ue_id=9    bearer_id=16
    Add one Bearer for UE    ue_id=11    bearer_id=2
    Add one Bearer for UE    ue_id=11    bearer_id=3
    Add one Bearer for UE    ue_id=11    bearer_id=4
    Add one Bearer for UE    ue_id=11    bearer_id=5
    Add one Bearer for UE    ue_id=11    bearer_id=9
    Add one Bearer for UE    ue_id=12    bearer_id=6
    Add one Bearer for UE    ue_id=12    bearer_id=7
    Add one Bearer for UE    ue_id=12    bearer_id=8
    Add one Bearer for UE    ue_id=13    bearer_id=10

Attach UE and add bearers with different existed qciOperator should be successful
    UE attach to cell1    ue_id=11-13
    Add one Bearer for UE    ue_id=11    bearer_id=2
    Add one Bearer for UE    ue_id=11    bearer_id=3
    Add one Bearer for UE    ue_id=11    bearer_id=4
    Add one Bearer for UE    ue_id=11    bearer_id=5
    Add one Bearer for UE    ue_id=11    bearer_id=9
    Add one Bearer for UE    ue_id=12    bearer_id=6
    Add one Bearer for UE    ue_id=12    bearer_id=7
    Add one Bearer for UE    ue_id=12    bearer_id=8
    Add one Bearer for UE    ue_id=13    bearer_id=10