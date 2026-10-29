*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CIT    CLOUD_R4LAPO_CUS
...               team-SG4    release-SBTS21B    owner-chenghong.li
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{Related_Feature_Switch}

@{Related_Feature_Switch}
...    LNBTS:actImmHRPD=true
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=80ms|siMessageSibType=SIB4
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB4
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=80ms|siMessageSibType=SIB5
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB5
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=80ms|siMessageSibType=SIB6
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB6
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=80ms|siMessageSibType=SIB7
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB7
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=80ms|siMessageSibType=SIB8
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB8
...    LNBTS:actCsgS1Mobility=true
...    LNBTS:actLTES1Ho=true
...    LNBTS/LNCSG-1:csgFreqEutra=38000
...    LNCEL-1/LNCEL_TDD-0:earfcn=38000
...    LNCEL-2/LNCEL_TDD-0:earfcn=38000
...    LNCEL-3/LNCEL_TDD-0:earfcn=38000
...    LNCEL-1/SIB-0:sib3Scheduling:siMessagePeriodicity=80ms
...    LNCEL-1/UFFIM-1:tResUtra=1
...    LNBTS/LNCSG-0:cellIndOff=0dB
...    LNBTS/LNCSG-0:csgFreqEutra=1400
...    LNBTS/LNCSG-0:csgPciFirst=0
...    LNBTS/LNCSG-0:enbIdSize=20bit

@{set_siMessagePeriodicity_80ms}
...    LNCEL-1/SIB-0:sib3Scheduling:siMessagePeriodicity=80ms

@{set_siMessagePeriodicity_160ms}
...    LNCEL-1/SIB-0:sib3Scheduling:siMessagePeriodicity=160ms

*** Test Cases ***
LTE39_LTE870-C_Online configuration sib1 to sib8
    [Tags]
    Delta Commission Parameters    ${set_siMessagePeriodicity_80ms}
    Cells Should Be OnAir
    Check SIB1-SIB8
    Delta Commission Parameters    ${set_siMessagePeriodicity_160ms}
    Cells Should Be OnAir
    Check SIB1 message

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    Set ue parameters before ENDC setup
    Create Alias

Set ue parameters before ENDC setup
    execute uex command    ue_param id=1-13 dual_conn=eutra_nr pdcp_sn_extension=18bit
    execute uex command    ue_param id=1-13 nr_supported_bands=7
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    execute egate command    enb_timer T_DC_Overall=5000ms

Create Alias
    FOR    ${ue_id}    IN RANGE    1    3
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=3    id_type=cus
    Create Enb Alias    alias=Rel_ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 1, pdn: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31}
    FOR    ${ue_id}     IN RANGE    1    3
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END

Check Sib${id} Message
    ${sibType3_to_sibType8_rf8}    catenate
    ...    schedulingInfoList contains (
    ...    (si-Periodicity eq 'rf8') and sib-MappingInfo contains ('sibType3'),
    ...    (si-Periodicity eq 'rf8') and sib-MappingInfo contains ('sibType4'),
    ...    (si-Periodicity eq 'rf8') and sib-MappingInfo contains ('sibType5'),
    ...    (si-Periodicity eq 'rf8') and sib-MappingInfo contains ('sibType6'),
    ...    (si-Periodicity eq 'rf8') and sib-MappingInfo contains ('sibType7'),
    ...    (si-Periodicity eq 'rf8') and sib-MappingInfo contains ('sibType8')
    ...    )
    Expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType1 ( ${sibType3_to_sibType8_rf8} )
    ...    alias=SIB${id}    overall_timeout=90
    ${sib_status}    Execute Uex Command    get_sib_status
    Should Be True    ${sib_status[1]['SIB${id}']} 
    Flow Occurred As Expected    alias=SIB${id}

Check SIB1-SIB8
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    FOR    ${id}    IN RANGE    1    9
        Check Sib${id} Message
    END

Check SIB1 message
    [Arguments]    ${id}=1
    ${sibType3_to_sibType8_rf16}    catenate
    ...    schedulingInfoList contains (
    ...    (si-Periodicity eq 'rf16') and sib-MappingInfo contains ('sibType3'),
    ...    (si-Periodicity eq 'rf8') and sib-MappingInfo contains ('sibType4'),
    ...    (si-Periodicity eq 'rf8') and sib-MappingInfo contains ('sibType5'),
    ...    (si-Periodicity eq 'rf8') and sib-MappingInfo contains ('sibType6'),
    ...    (si-Periodicity eq 'rf8') and sib-MappingInfo contains ('sibType7'),
    ...    (si-Periodicity eq 'rf8') and sib-MappingInfo contains ('sibType8')
    ...    )
    Expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType1 ( ${sibType3_to_sibType8_rf16} )
    ...    CELL_1:RRC_SystemInformationBlockType2 ( radioResourceConfigCommon contains (n1PUCCH-AN is present) )
    ...    alias=SIB_rf16    overall_timeout=90
    ${sib_status}    Execute Uex Command    get_sib_status
    Should Be True    ${sib_status[1]['SIB${id}']} 
    Flow Occurred As Expected    alias=SIB_rf16
