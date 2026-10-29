*** Settings ***
Documentation
...   author: Fengcai Liu;Yongjie Liu
...   contact: amy.c.liu@nokia-sbell.com;yongjie.liu@nokia-sbell.com
...   this is a robot case about CB007942.

Resource          ../Resources_pet/pet_all.robot
Resource          ./resources/CB007942_cus_counter_kw.resource
Resource          ./resources/CB007942_msg_kw.resource

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    STATE_SKIP_AGENT
...               CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG05_ST_RRM    TA_LEVEL_22
Suite Setup            Suite Setup For CUS    ${SCF_XML}    ${SWCONFIG}    ${CUS_YAML}
Suite Teardown         Suite Teardown For CUS
Test Setup             Common Case Setup For Pet
Test Teardown          Common Case Teardown For Pet


*** Variables ***
${INSTALL_BUILD}         NO
${DEBUG_MODE}            NO
${USE_AIRPHONE}          Y
${CLEAN_LOG_SIZE}        500
#  case1 part data:
${SCF_XML}    ${CURDIR}/config/SCFC_1_R4BANO.xml
${CUS_YAML}    ${CURDIR}/config/cus.yaml
${SWCONFIG}    ${CURDIR}/config/swconfig.txt
${PM_FILE}     ${CURDIR}/config/para.json


*** Test Cases ***
CB007942-ET-A-1 Support of undefined operator specific QCI during Initial Context Setup and incoming handover

    [Tags]    QC_32686
    [Documentation]
    ...    author: amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,amy.c.liu@nokia-sbell.com,case template draft
    [Setup]    Common Case Setup For Pet
    Prepare Counter
    Start Capture Btslog
    UE1 Attach ENB1 Cell3 With QCI9 QCI150 And QCI200
    UE2 Attach ENB4 Cell41 With QCI9 QCI150 And QCI200
    UE2 HO To ENB1 Cell3
    Log To Console     Waiting for the PM
    Sleep    300
    Check Related PM Counters For Case1
    [Teardown]    Case Teardown For CUS

CB007942-ET-A-2 Support of undefined operator specific QCI during E-RAB Setup

     [Tags]    QC_32687
     [Documentation]
     ...    author: amy.c.liu@nokia-sbell.com
     ...    history change: <date>,<who>,<what and how>
     ...    05.01.2024,amy.c.liu@nokia-sbell.com,case template draft
    [Setup]    Common Case Setup For Pet
     Prepare Counter
     UE4 Attach ENB1 Cell4 With Default Bearer QCI8
     Dedicated Bearer QCI98 Added For UE4
     Dedicated Bearer QCI254 Added For UE4
     UE3 Attach ENB1 Cell4 With Default Bearer QCI7
     Dedicated Bearer QCI128 Added For UE3
     Dedicated Bearer QCI250 Added For UE3
     Log To Console     Waiting for the PM
     Sleep    300
     Check Related PM Counters For Case2
    [Teardown]    Case Teardown For CUS

CB007942-ET-A-3 Support of undefined operator specific QCI during E-RAB Modify

      [Tags]    QC_32688
      [Documentation]
      ...    author: amy.c.liu@nokia-sbell.com
      ...    history change: <date>,<who>,<what and how>
      ...    05.01.2024,amy.c.liu@nokia-sbell.com,case template draft
    [Setup]    Common Case Setup For Pet
      Prepare Counter
      UE5 Attach ENB1 Cell5 With Default Bearer QCI9 And QCI140
      Trigger ERAB Modify From Qci140 To Qci200
      Trigger ERAB Modify From Qci200 To Qci210
      Trigger ERAB Modify From Qci210 To Qci140
    [Teardown]    Case Teardown For CUS

CB007942-ET-A-4 Interaction with Robustness Test

    [Tags]    QC_32689
    [Documentation]
    ...    author: amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,amy.c.liu@nokia-sbell.com,case template draft
    [Setup]    Common Case Setup For Pet
    Prepare Counter
    UE6 Attach ENB1 Cell1 With Default Bearer QCI6
    Dedicated Bearer QCI140 Added For UE6
    Dedicated Bearer QCI99 Added For UE6 And Changed To SCG
    Trigger ERAB Modify From Qci99 To Qci199
    Online Parameters Delete QciTabOperatorDefault
    Trigger ERAB Modify From Qci199 To Qci100
    Dedicated Bearer QCI99 Deled For UE6 And Changed To MCG
    Online Modify Parameter And Dedicated Bearer For Case4
    Trigger UE6 Reestablishment
    [Teardown]    Case Teardown For CUS


*** Keywords ***
Skip Robocop Warning
    [Documentation]
    ...    author: amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    ${INSTALL_BUILD}
    Log To Console    ${DEBUG_MODE}
    Log To Console    ${CLEAN_LOG_SIZE}
    Log To Console    ${USE_AIRPHONE}

Online Modify Parameter And Dedicated Bearer For Case4
    [Documentation]
    ...    author: amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,amy.c.liu@nokia-sbell.com,case template draft
    Online Parameters Modify QciTabOperatorDefault To 140
    Online Parameters Modify QciTabOperator Delete Qci 99    ${PM_FILE}
    Dedicated Bearer QCI99 Added For UE6 And No SCG
