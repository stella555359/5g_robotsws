*** Settings ***
Documentation
...   author: Fengcai Liu;Yongjie Liu
...   contact: amy.c.liu@nokia-sbell.com;yongjie.liu@nokia-sbell.com
...   this is kwyword for CB007942.
Library    Collections
Library    ta_uexgate
Library    ta_messaging
Library    ute_wtssim



*** Keywords ***
Suite Setup For CUS
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    [Arguments]    ${scf_file}    ${swconfig}    ${cus}
    Common Suite Setup For Pet
    Setup For Ap  swconfig=${swconfig}  scf_file=${scf_file}  cus_yaml=${cus}
    Create Alias

Suite Teardown For CUS
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Common Suite Teardown For Pet
    Run Keyword And Ignore Error  Teardown All Aliases For Admin
    Run Keyword And Ignore Error  fsmaccess.Teardown All Aliases For Enb Fsmaccess
    Run Keyword And Ignore Error  fsmaccess.Teardown All Aliases For Wts Fsmaccess

Create BTS Alias
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_2    enb_id=2    id_type=wts
    Create Enb Alias    GNB_3    enb_id=3    id_type=wts
    Create Enb Alias    ENB_4    enb_id=4    id_type=wts

Create UES Alias
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    Create UES Alias
    FOR    ${ue_id}    IN RANGE    1    7
       Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END

Create Alias
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Create UES Alias
    Create BTS Alias
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Prepare Counter
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Pet FCT Exec Command    ${FCT_MASTER}    rm -rf /tmp/PM*
    Pet FCT Exec Command    ${FCT_MASTER}    rm -rf /tmp/RD*

Judge Counters For Case
    [Arguments]    ${pmdict}
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Should Be True   ${pmdict}[M8080C136]==1
    Should Be True   ${pmdict}[M8080C136]==1


Check Related PM Counters For Case
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Pet Wait Until All PM File Done    ${FCT_MASTER}
    Create Directory    ${CASE_DIRE}/PMCounter
    Pet FCT Get File    ${FCT_MASTER}    /tmp/PM*.xml.gz    ${CASE_DIRE}/PMCounter/
    @{pmlist}=    Create List    M8080C136  M8080C137
    &{dt1}=    Create Dictionary
    ${distname}=    Set Variable    PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-1
    FOR    ${pmname}    IN    @{pmlist}
        ${pmvalue}=    Pet Sum Counter In Files    ${CASE_DIRE}/PMCounter/    ${pmname}    ${distname}
        Set To Dictionary    ${dt1}    ${pmname}=${pmvalue}
    END
    Judge Counters For Case    ${dt1}

Capture Bts Snapshot
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     Capture Bts Snapshot
    coam.Collect Snapshot    target_file_name=${CASE_DIRE}/snapshot.zip    connection=master    timeout=1800

Case Teardown For CUS
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Capture Bts Snapshot
    Run Keyword And Ignore Error    Stop Capture 5G Btslog
    Common Case Teardown For Pet

Start Capture Btslog
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Set Suite Variable    ${BTSLOG_FILENAME}   ${CASE_DIRE}/btslog/btslog.log
    ${collector}=    Pet Create Btslog Collector    host=127.0.0.1    port=51000    password=uteUTE!
    ...              filename=${BTSLOG_FILENAME}
    Set Suite Variable          ${COLLECTOR_5G}    ${collector}
    Pet Start Capture Btslog    ${COLLECTOR_5G}

Stop Capture 5G Btslog
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     Stop Capture 5G Btslog
    Pet Stop Capture Btslog    ${COLLECTOR_5G}

UE6 Attach ENB1 Cell1 With Default Bearer QCI6 And Changed To SCG
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     UE6 Attach ENB1 Cell1 With Default Bearer QCI6 And Changed To SCG
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest ( E-RABToBeSetupListCtxtSUReq contains ( e-RAB-ID eq 5 and qCI eq 6 ))
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    ENB_1:X2AP_SgNBAdditionRequest (E-RABs-ToBeAdded-SgNBAddReqList contains (qCI eq 6))
    ...    GNB_2:X2AP_SgNBAdditionRequestAcknowledge (E-RABs-Admitted-ToBeAdded-SgNBAddReqAckList contains (e-RAB-ID eq 5))
    ...    UE_6:RRC_RRCConnectionReconfiguration
    ...    UE_6:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_6_attach    overall_timeout=30
    Run Uex Command    ue_attach id=6 enb=1 cell=1
    Run Uex Command    trf_data_start ue=6 dir=dl_and_ul protocol=udp qci=6 Mbps=160 duration=1200
    Flow Occurred As Expected    alias=UE_6_attach


UE Trigger EN DC Tackback
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     UE Trigger EN DC Tackback
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBReleaseRequest ( Cause contains (radioNetwork eq 'unspecified'))
    ...    ENB_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    GNB_2:X2AP_SgNBReleaseRequestAcknowledge ( E-RABs-Admitted-ToBeReleased-SgNBRelReqAckList contains (e-RAB-ID eq 5))
    ...    UE_6:RRC_RRCConnectionReconfiguration
    ...    UE_6:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_trigger_EN-DC_tackback    overall_timeout=30
    Log To Console     ue_dc_rlf id=6 scg_failure_info=90080000000000
    Run Uex Command    ue_dc_rlf id=6 scg_failure_info=90080000000000
    Flow Occurred As Expected    UE_trigger_EN-DC_tackback