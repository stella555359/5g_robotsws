*** Settings ***
Documentation
...   author: Fengcai Liu;Yongjie Liu
...   contact: amy.c.liu@nokia-sbell.com;yongjie.liu@nokia-sbell.com
...   this is kwyword for CB007942.
Library    ta_uexgate
Library    ta_messaging
Library    ute_wtssim


*** Variables ***
${MOD200}        bearer_mod ue=5 id=2 qci=200
${MOD210}        bearer_mod ue=5 id=2 qci=210
${MOD140}        bearer_mod ue=5 id=2 qci=140
${MOD199}        bearer_mod ue=6 id=2 qci=199
${MOD100}        bearer_mod ue=6 id=2 qci=100
${MOD98}        bearer_mod ue=6 id=2 qci=98
# ${ATTACH_CMD1}    ue_attach id=1 enb=1 cell=3


*** Keywords ***
UE1 Attach ENB1 Cell3 With QCI9 QCI150 And QCI200
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    UE1 Attach ENB1 Cell3 With QCI9 QCI150 And QCI200
    ${QCI9_QCI150_QCI200}=    Catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    e-RAB-ID eq 5 and qCI eq 9,
    ...    e-RAB-ID eq 6 and qCI eq 150,
    ...    e-RAB-ID eq 7 and qCI eq 200)
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest ( ${QCI9_QCI150_QCI200} )
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_1:RRC_RRCConnectionReconfiguration
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_1_attach    overall_timeout=30
    Run Uex Command    ue_attach id=1 enb=1 cell=3
    Run Uex Command    trf_data_start ue=1 dir=dl_and_ul protocol=udp qci=150 Mbps=60 duration=1200
    Flow Occurred As Expected    alias=UE_1_attach

UE2 Attach ENB4 Cell41 With QCI9 QCI150 And QCI200
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    UE2 Attach ENB4 Cell41 With QCI9 QCI150 And QCI200
    ${QCI9_QCI150_QCI200}=    Catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    e-RAB-ID eq 5 and qCI eq 9,
    ...    e-RAB-ID eq 6 and qCI eq 150,
    ...    e-RAB-ID eq 7 and qCI eq 200)
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest ( ${QCI9_QCI150_QCI200} )
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_2:RRC_RRCConnectionReconfiguration
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_2_attach    overall_timeout=60
    Run Uex Command    ue_attach id=2 enb=4 cell=41
    Flow Occurred As Expected    alias=UE_2_attach

UE2 HO To ENB1 Cell3
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    UE2 HO To ENB1 Cell3
    ${eNB4messages}=    Catenate
    ...    E-RABs-ToBeSetup-Item contains (
    ...    e-RAB-ID eq 5 and qCI eq 9,
    ...    e-RAB-ID eq 6 and qCI eq 150,
    ...    e-RAB-ID eq 7 and qCI eq 200)
    ${UE2messages}=    Catenate
    ...    mobilityControlInfo  contains (
    ...    targetPhysCellId eq 3)
    ${eNB1messages}=    Catenate
    ...    E-RABs-Admitted-List  contains (
    ...    e-RAB-ID eq 5,
    ...    e-RAB-ID eq 6,
    ...    e-RAB-ID eq 7)
    Expect Message Flow
    ...    ENB_4:X2AP_HandoverRequest ( ${eNB4messages} )
    ...    ENB_1:X2AP_HandoverRequestAcknowledge ( ${eNB1messages} )
    ...    UE_2:RRC_RRCConnectionReconfiguration ( ${UE2messages} )
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_2_ho    overall_timeout=60
    Run Uex Command    ue_ho id=2 enb=1 cell=3
    Run Uex Command  trf_data_start ue=2 dir=dl_and_ul protocol=udp qci=200 Mbps=60 duration=1200
    Flow Occurred As Expected    alias=UE_2_ho

UE3 Attach ENB1 Cell4 With Default Bearer QCI7
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    UE3 Attach ENB1 Cell4 With Default Bearer QCI7
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest ( E-RABToBeSetupListCtxtSUReq contains ( e-RAB-ID eq 5 and qCI eq 7 ))
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_3:RRC_RRCConnectionReconfiguration
    ...    UE_3:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_3_attach    overall_timeout=30
    Run Uex Command    ue_attach id=3 enb=1 cell=4
    Run Uex Command  trf_data_start ue=3 dir=dl_and_ul protocol=udp Mbps=60 duration=1200
    Flow Occurred As Expected    alias=UE_3_attach

Dedicated Bearer QCI128 Added For UE3
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    Dedicated Bearer QCI128 Added For UE3
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest ( E-RABToBeSetupListBearerSUReq contains ( e-RAB-ID eq 6 and qCI eq 128 ))
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupResponse contains ( e-RAB-ID eq 6 and radioNetwork eq 'not-supported-QCI-value' ))
    ...    alias=UE_3_QCI128    overall_timeout=30
    Run Keyword And Ignore Error   Run Uex Command    bearer_add ue=3 qci=128
    Flow Occurred As Expected    alias=UE_3_QCI128

Dedicated Bearer QCI250 Added For UE3
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    Dedicated Bearer QCI250 Added For UE3
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest ( E-RABToBeSetupListBearerSUReq contains ( e-RAB-ID eq 6 and qCI eq 250 ))
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupResponse contains ( e-RAB-ID eq 6 and radioNetwork eq 'not-supported-QCI-value'))
    ...    alias=UE_3_QCI250    overall_timeout=30
    Run Keyword And Ignore Error   Run Uex Command    bearer_add ue=3 qci=250
    Flow Occurred As Expected    alias=UE_3_QCI250

UE4 Attach ENB1 Cell4 With Default Bearer QCI8
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    UE4 Attach ENB1 Cell4 With Default Bearer QCI8
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest ( E-RABToBeSetupListCtxtSUReq contains ( e-RAB-ID eq 5 and qCI eq 8 ))
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_4:RRC_RRCConnectionReconfiguration
    ...    UE_4:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_4_attach    overall_timeout=30
    Run Uex Command    ue_attach id=4 enb=1 cell=4
    Flow Occurred As Expected    alias=UE_4_attach

Dedicated Bearer QCI98 Added For UE4
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    Dedicated Bearer QCI98 Added For UE4
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest ( E-RABToBeSetupListBearerSUReq contains ( e-RAB-ID eq 6 and qCI eq 98 ))
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 6))
    ...    UE_4:RRC_RRCConnectionReconfiguration
    ...    UE_4:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_4_QCI98    overall_timeout=30
    Run Uex Command    bearer_add ue=4 qci=98
    Run Uex Command  trf_data_start ue=4 dir=dl_and_ul protocol=udp qci=98 Mbps=60 duration=1200
    Flow Occurred As Expected    alias=UE_4_QCI98

Dedicated Bearer QCI254 Added For UE4
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    Dedicated Bearer QCI254 Added For UE4
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest ( E-RABToBeSetupListBearerSUReq contains ( e-RAB-ID eq 7 and qCI eq 254 ))
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 7))
    ...    UE_4:RRC_RRCConnectionReconfiguration
    ...    UE_4:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_4_QCI254    overall_timeout=30
    Run Uex Command    bearer_add ue=4 qci=254
    Flow Occurred As Expected    alias=UE_4_QCI254

UE5 Attach ENB1 Cell5 With Default Bearer QCI9 And QCI140
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    UE5 Attach ENB1 Cell5 With Default Bearer QCI9 And QCI140
    ${QCI9_QCI140}=    Catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    e-RAB-ID eq 5 and qCI eq 9,
    ...    e-RAB-ID eq 6 and qCI eq 140)
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest ( ${QCI9_QCI140} )
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_5:RRC_RRCConnectionReconfiguration
    ...    UE_5:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_5_attach    overall_timeout=30
    Run Uex Command    ue_attach id=5 enb=1 cell=5
    Flow Occurred As Expected    alias=UE_5_attach

Trigger ERAB Modify From Qci140 To Qci200
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    Trigger ERAB Modify From Qci140 To Qci200
    Expect Message Flow
    ...    MME_1:S1AP_E-RABModifyRequest ( E-RABToBeModifiedItemBearerModReq contains ( e-RAB-ID eq 6 and qCI eq 200))
    ...    MME_1:S1AP_E-RABModifyResponse (E-RABModifyListBearerModRes contains (e-RAB-ID eq 6))
    ...    UE_5:RRC_RRCConnectionReconfiguration (drb-ToAddModList contains (drb-Identity eq 5))
    ...    UE_5:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_5_MOD200    overall_timeout=30
    Log To Console     Execute Egate Command MOD200
    wts.Execute Egate Command    cmd=${MOD200}
    Flow Occurred As Expected    UE_5_MOD200

Trigger ERAB Modify From Qci200 To Qci210
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    Trigger ERAB Modify From Qci200 To Qci210
    Expect Message Flow
    ...    MME_1:S1AP_E-RABModifyRequest ( E-RABToBeModifiedItemBearerModReq contains ( e-RAB-ID eq 6 and qCI eq 210))
    ...    MME_1:S1AP_E-RABModifyResponse (E-RABModifyListBearerModRes contains (e-RAB-ID eq 6))
    ...    UE_5:RRC_RRCConnectionReconfiguration (drb-ToAddModList contains (drb-Identity eq 5))
    ...    UE_5:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_5_MOD210    overall_timeout=30
    Log To Console     Execute Egate Command MOD210
    wts.Execute Egate Command    cmd=${MOD210}
    Flow Occurred As Expected    UE_5_MOD210

Trigger ERAB Modify From Qci210 To Qci140
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    Trigger ERAB Modify From Qci210 To Qci140
    Expect Message Flow
    ...    MME_1:S1AP_E-RABModifyRequest ( E-RABToBeModifiedItemBearerModReq contains ( e-RAB-ID eq 6 and qCI eq 140))
    ...    MME_1:S1AP_E-RABModifyResponse (E-RABModifyListBearerModRes contains (e-RAB-ID eq 6))
    ...    UE_5:RRC_RRCConnectionReconfiguration (drb-ToAddModList contains (drb-Identity eq 5))
    ...    UE_5:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_5_MOD140    overall_timeout=30
    Log To Console     Execute Egate Command MOD140
    wts.Execute Egate Command    cmd=${MOD140}
    Flow Occurred As Expected    UE_5_MOD140

UE6 Attach ENB1 Cell1 With Default Bearer QCI6
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     UE6 Attach ENB1 Cell1 With Default Bearer QCI6
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest ( E-RABToBeSetupListCtxtSUReq contains ( e-RAB-ID eq 5 and qCI eq 6 ))
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_6:RRC_RRCConnectionReconfiguration
    ...    UE_6:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_6_attach    overall_timeout=30
    Run Uex Command    ue_attach id=6 enb=1 cell=1
    Flow Occurred As Expected    alias=UE_6_attach

Dedicated Bearer QCI140 Added For UE6
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     Dedicated Bearer QCI140 Added For UE6
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest ( E-RABToBeSetupListBearerSUReq contains ( e-RAB-ID eq 6 and qCI eq 140 ))
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 6))
    ...    UE_6:RRC_RRCConnectionReconfiguration
    ...    UE_6:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_6_QCI140    overall_timeout=30
    Run Uex Command    bearer_add ue=6 qci=140
    Flow Occurred As Expected    alias=UE_6_QCI140

Dedicated Bearer QCI99 Added For UE6 And Changed To SCG
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     Dedicated Bearer QCI99 Added For UE6 And Changed To SCG
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest ( E-RABToBeSetupListBearerSUReq contains ( e-RAB-ID eq 7 and qCI eq 99 ))
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 7))
    ...    ENB_1:X2AP_SgNBAdditionRequest (E-RABs-ToBeAdded-SgNBAddReqList contains (qCI eq 99))
    ...    GNB_2:X2AP_SgNBAdditionRequestAcknowledge (E-RABs-Admitted-ToBeAdded-SgNBAddReqAckList contains (e-RAB-ID eq 7))
    ...    UE_6:RRC_RRCConnectionReconfiguration
    ...    UE_6:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_6_QCI99    overall_timeout=30
    Run Uex Command    bearer_add ue=6 qci=99
    Flow Occurred As Expected    alias=UE_6_QCI99

Trigger ERAB Modify From Qci99 To Qci199
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     Trigger ERAB Modify From Qci99 To Qci199
    Expect Message Flow
    ...    MME_1:S1AP_E-RABModifyRequest ( E-RABToBeModifiedItemBearerModReq contains ( e-RAB-ID eq 7 and qCI eq 199))
    ...    MME_1:S1AP_E-RABModifyResponse (E-RABModifyListBearerModRes contains (e-RAB-ID eq 7))
    ...    UE_6:RRC_RRCConnectionReconfiguration (drb-ToAddModList contains (drb-Identity eq 6))
    ...    UE_6:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_6_MOD199    overall_timeout=30
    Log To Console     Execute Egate Command MOD199
    wts.Execute Egate Command    cmd=${MOD199}
    Flow Occurred As Expected    UE_6_MOD199

Trigger ERAB Modify From Qci199 To Qci100
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     Trigger ERAB Modify From Qci199 To Qci100
    Expect Message Flow
    ...    MME_1:S1AP_E-RABModifyRequest ( E-RABToBeModifiedItemBearerModReq contains ( e-RAB-ID eq 7 and qCI eq 100))
    ...    MME_1:S1AP_E-RABModifyResponse ( E-RABModifyResponse contains ( e-RAB-ID eq 7 and radioNetwork eq 'not-supported-QCI-value'))
    ...    alias=UE_6_MOD100    overall_timeout=30
    Log To Console     Execute Egate Command MOD100
    Run Keyword And Ignore Error    wts.Execute Egate Command    cmd=${MOD100}
    Flow Occurred As Expected    UE_6_MOD100

Trigger ERAB Modify From Qci199 To Qci98
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     Trigger ERAB Modify From Qci199 To Qci98
    Expect Message Flow
    ...    MME_1:S1AP_E-RABModifyRequest ( E-RABToBeModifiedItemBearerModReq contains ( e-RAB-ID eq 7 and qCI eq 98))
    ...    MME_1:S1AP_E-RABModifyResponse (E-RABModifyListBearerModRes contains (e-RAB-ID eq 7))
    ...    UE_6:RRC_RRCConnectionReconfiguration (drb-ToAddModList contains (drb-Identity eq 6))
    ...    UE_6:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_6_MOD98    overall_timeout=30
    Log To Console     Execute Egate Command MOD98
    wts.Execute Egate Command    cmd=${MOD98}
    Flow Occurred As Expected    UE_6_MOD98

Dedicated Bearer QCI99 Deled For UE6 And Changed To MCG
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     Dedicated Bearer QCI99 Deled For UE6 And Changed To MCG
    Expect Message Flow
    ...    MME_1:S1AP_E-RABReleaseCommand
    ...    MME_1:S1AP_E-RABReleaseResponse
    ...    ENB_1:X2AP_SgNBReleaseRequest
    ...    GNB_2:X2AP_SgNBReleaseRequestAcknowledge ( E-RABs-Admitted-ToBeReleased-SgNBRelReqAckList contains (e-RAB-ID eq 7))
    ...    UE_6:RRC_RRCConnectionReconfiguration
    ...    UE_6:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_6_Del99    overall_timeout=30
    Log To Console     Execute Uex Command Del99
    Run Uex Command    bearer_del ue=6 qci=99
    Flow Occurred As Expected    UE_6_Del99

Dedicated Bearer QCI99 Added For UE6 And No SCG
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     Dedicated Bearer QCI99 Added For UE6 And No SCG
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest ( E-RABToBeSetupListBearerSUReq contains ( e-RAB-ID eq 7 and qCI eq 210 ))
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 7))
    ...    UE_6:RRC_RRCConnectionReconfiguration
    ...    UE_6:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_6_QCI99Default150    overall_timeout=30
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    alias=no_SCG_flow    overall_timeout=30
    Run Uex Command    bearer_add ue=6 qci=210
    Flow Occurred As Expected    alias=UE_6_QCI99Default150
    Flow Not Occurred For Message    alias=no_SCG_flow

Trigger UE6 Reestablishment
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Expect Message Flow
    ...    UE_6:RRC_RRCConnectionReestablishmentRequest
    ...    UE_6:RRC_RRCConnectionReestablishment
    ...    UE_6:RRC_RRCConnectionReconfiguration
    ...    UE_6:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_6_RRCReestablish    overall_timeout=30
    Run Uex Command    ue_rrc_reestablish id=6 enb=1 cell=1 cause=otherFailure
    Flow Occurred As Expected    UE_6_RRCReestablish
