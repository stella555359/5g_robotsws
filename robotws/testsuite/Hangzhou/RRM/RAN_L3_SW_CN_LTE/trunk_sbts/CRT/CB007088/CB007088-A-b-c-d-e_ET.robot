*** Settings ***
Suite Setup    Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...    owner-qi.zheng    owner-yin.zhang    release-SBTS20B    team-DEVHZ5_SG7
Resource    ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS:actUavSupport=basic support
...    LNBTS/UAVPR-0:uavIdentifierList:spid=1|spidLast=2
...    LNBTS/UAVPR-0:uavIdentifierList:spid=4|spidLast=5
...    LNBTS/UAVPR-0:uavUlpcConfig:uavUlpcMethod=PuschOLPucchOL
...    LNBTS/UAVPR-0:uavUlpcConfig:uavUlpcP0UeOffsetSch=-8
...    LNBTS/UAVPR-0:uavUlpcConfig:uavUlpcP0UeOffsetCch=7
...    LNCEL-1:uavProfileId=0
...    LNBTS:actSelMobPrf=true
...    LNCEL-1:actUlLnkAdp=eUlLa
...    LNCEL-1:filterCoeff=fc4
...    LNCEL-1/LNCEL_FDD-0:srsPwrOffset=7
...    LNCEL-1:deltaTfEnabled=false
...    LNCEL-1:actUlpcMethod=PuschCLPucchCL
${ue_eutra_capabilities_01}
...    SEPARATOR=
...    DD980030830008081705C177E0DD89A0028372F97E0DD89A5E190117BF06EC4D5918210C2084308210C1086084104018210C00C00C10060803
...    0421801801108200168FAA8C280C1C208020A30410B08200828C1051820858410041C208020A30410B0820082841051820B205C1705C1705C1
...    705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705D
...    F8A0000336421E1E1E2E11FC5C878787878787878787878710F0F0F0E00008BF060000102020880CD0007CE3C0004080C10181C2C4C6C70750
...    7EFF896B4C03217F9BD4000C01B648000100000825C701800008040184C134287806FF8000014000000C2000
@{PARAMS_IN_EMIL}
...    0x269D
...    0x269B
@{pm_counters_16}
...    last LNCEL-1/MCC-262/MNC-03:${ACTIVE_UAV_MAX}=16
...    last LNCEL-1/MCC-262/MNC-03:${ACTIVE_UAV_AVG}>0
...    last LNCEL-1/MCC-262/MNC-03:${ACTIVE_UAV_AVG}<1700
${ACTIVE_UAV_MAX}    M8051C219
${ACTIVE_UAV_AVG}    M8051C218

@{uavIdentifierList_MAX_16_ITEMS}
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=${EMPTY}|spid=1
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=5|spid=4
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=10|spid=8
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=25|spid=20
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=40|spid=30
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=${EMPTY}|spid=45
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=53|spid=49
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=65|spid=55
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=75|spid=70
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=100|spid=80
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=120|spid=110
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=135|spid=130
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=150|spid=140
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=210|spid=200
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=230|spid=205
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=256|spid=250
...    LNBTS/UAVPR-0:uavUlpcConfig:uavUlpcP0UeOffsetSch=-8
...    LNBTS/UAVPR-0:uavUlpcConfig:uavUlpcP0UeOffsetCch=7
@{params_case6_1}
...    LNBTS/UAVPR-0:uavIdentifierList:spidLast=2|spid=1
...    LNBTS/UAVPR-0:uavUlpcConfig:uavUlpcP0UeOffsetSch=7
...    LNBTS/UAVPR-0:uavUlpcConfig:uavUlpcP0UeOffsetCch=-8
...    LNBTS/UAVPR-0:uavUlpcConfig:uavUlpcMethod=sameAsTerrestrial
@{params_case6_2}
...    LNBTS/UAVPR-0:uavIdentifierList:spid=1|spidLast=256
...    LNBTS/UAVPR-0:uavUlpcConfig:uavUlpcP0UeOffsetSch=-1
...    LNBTS/UAVPR-0:uavUlpcConfig:uavUlpcP0UeOffsetCch=-1
...    LNBTS/UAVPR-0:uavUlpcConfig:uavUlpcMethod=PuschOLPucchOL

*** Test Cases ***
CB007088-A-b-e_ET_06_02_interworking with intra-cell HO and reestablishment to serving cell contain onlinechange UAVPR parameters
    [Tags]
    Start Rtpm Counter
    Attach 17 UEs With 16 UAV UEs And Normal UE2
    Delta Commission Parameters    ${params_case6_1}
    Trigger UE1 Intra-Cell handover And P0 Updated With Latest UAV Offset
    Trigger UE2 Intra-Cell handover And No P0 Offset Updated
    Delta Commission Parameters    ${params_case6_2}
    Trigger UE1 reestablishment Twice And UAV P0 Offset Configured
    Trigger UE2 reestablishment Twice And P0 Offset 0 Configured
    Check Rtpm Counters    ${pm_counters_16}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=17    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Create 17 UEs List Except UE2
    @{ue_list}    Create List
    FOR    ${ue}    IN RANGE    1    18
        append to list    ${ue_list}    ${ue}
    END
    remove values from list    ${ue_list}    ${2}
    [return]    @{ue_list}

Attach 17 UEs With 16 UAV UEs And Normal UE2
    Delta Commission Parameters    ${uavIdentifierList_MAX_16_ITEMS}
    Set 17 UEs SPID
    @{uav_ues}    Create 17 UEs List Except UE2
    FOR    ${ue}    IN    @{uav_ues}
        Expect Message Flow
        ...    UE_GROUP_${ue}:RRC_RRCConnectionSetup (uplinkPowerControlDedicated contains (p0-UE-PUCCH eq 0 and p0-UE-PUSCH eq 0))
        ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (uplinkPowerControlDedicated contains (p0-UE-PUCCH eq 7 and p0-UE-PUSCH eq -8))
        ...    MME_1:S1AP_InitialContextSetupResponse
        ...    alias=attach_${ue}    overall_timeout=20
    END
    Expect Message Flow
    ...    UE_GROUP_2:RRC_RRCConnectionSetup (uplinkPowerControlDedicated contains (p0-UE-PUCCH eq 0 and p0-UE-PUSCH eq 0))
    ...    UE_GROUP_2:RRC_RRCConnectionReconfiguration (uplinkPowerControlDedicated is not present)
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    alias=attach_2    overall_timeout=20
    Execute Uex Command    ue_attach id=1-17 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities_01}
    FOR    ${ue}    IN RANGE    1    18
        Flow Occurred As Expected    alias=attach_${ue}
    END

Trigger UE1 Intra-Cell handover And P0 Updated With Latest UAV Offset
    Expect Message Flow
    ...    MME_1:S1AP_UEContextModificationRequest
    ...    UE_GROUP_1:RRC_RRCConnectionReconfiguration (uplinkPowerControlDedicated contains (p0-UE-PUCCH eq -8 and p0-UE-PUSCH eq 7))
    ...    alias=ho    overall_timeout=20
    Execute Egate Command    ue_reauth id=1
    Flow Occurred As Expected    alias=ho

Trigger UE2 Intra-Cell handover And No P0 Offset Updated
    Expect Message Flow
    ...    MME_1:S1AP_UEContextModificationRequest
    ...    UE_GROUP_2:RRC_RRCConnectionReconfiguration (uplinkPowerControlDedicated is not present)
    ...    alias=ho    overall_timeout=20
    Execute Egate Command    ue_reauth id=2
    Flow Occurred As Expected    alias=ho

Trigger UE reestablishment And Check P0 Offset
    [Arguments]    ${ue}    ${p0_offset}
    Expect Message Flow
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReestablishment (${p0_offset})
    ...    alias=reestablish    overall_timeout=20
    Execute UEx Command    ue_rrc_reestablish id=${ue} cell=1 enb=1 cause=otherFailure
    Flow Occurred As Expected    alias=reestablish

Trigger UE1 reestablishment Twice And UAV P0 Offset Configured
    ${uav_p0_offset}    Catenate    uplinkPowerControlDedicated contains (p0-UE-PUCCH eq -1 and p0-UE-PUSCH eq -1)
    Trigger UE reestablishment And Check P0 Offset    ue=1    p0_offset=${uav_p0_offset}
    Trigger UE reestablishment And Check P0 Offset    ue=1    p0_offset=${uav_p0_offset}

Trigger UE2 reestablishment Twice And P0 Offset 0 Configured
    ${normal_ue_p0_offset}    Catenate    uplinkPowerControlDedicated contains (p0-UE-PUCCH eq 0 and p0-UE-PUSCH eq 0)
    Trigger UE reestablishment And Check P0 Offset    ue=2    p0_offset=${normal_ue_p0_offset}
    Trigger UE reestablishment And Check P0 Offset    ue=2    p0_offset=${normal_ue_p0_offset}

Set 17 UEs SPID
    Execute Egate Command    ue_mme_param id=1 spid=1
    Execute Egate Command    ue_mme_param id=2 spid=2
    Execute Egate Command    ue_mme_param id=3 spid=5
    Execute Egate Command    ue_mme_param id=4 spid=10
    Execute Egate Command    ue_mme_param id=5 spid=20
    Execute Egate Command    ue_mme_param id=6 spid=31
    Execute Egate Command    ue_mme_param id=7 spid=45
    Execute Egate Command    ue_mme_param id=8 spid=53
    Execute Egate Command    ue_mme_param id=9 spid=65
    Execute Egate Command    ue_mme_param id=10 spid=75
    Execute Egate Command    ue_mme_param id=11 spid=90
    Execute Egate Command    ue_mme_param id=12 spid=110
    Execute Egate Command    ue_mme_param id=13 spid=135
    Execute Egate Command    ue_mme_param id=14 spid=145
    Execute Egate Command    ue_mme_param id=15 spid=210
    Execute Egate Command    ue_mme_param id=16 spid=225
    Execute Egate Command    ue_mme_param id=17 spid=256
