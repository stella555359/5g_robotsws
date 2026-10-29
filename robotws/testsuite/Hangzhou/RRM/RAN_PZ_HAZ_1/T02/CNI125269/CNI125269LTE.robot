*** Settings ***
Documentation
...   author: Yongjie Liu
...   contact: yongjie.liu@nokia-sbell.com
...   this is a robot case about CNI-125269.

Resource          ../Resources_pet/pet_all.robot
Resource          ./Resources/CNI-125269LTE.resource

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
${SCF_XML}    ${CURDIR}/config/SCFC_1.xml
${CUS_YAML}    ${CURDIR}/config/cus.yaml
${SWCONFIG}    ${CURDIR}/config/swconfig.txt



*** Test Cases ***
CNI-125269-ST-1 RNL Normal Release is used for the SgNB Release Request message in the UE triggered EN-DC takeback scenario-LTE part
    [Tags]    QC_99347
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    21.08.2024,yongjie.liu@nokia-sbell.com,case template draft
    [Setup]    Common Case Setup For Pet
    Prepare Counter
    Start Capture Btslog
    UE6 Attach ENB1 Cell1 With Default Bearer QCI6 And Changed To SCG
    UE Trigger EN DC Tackback
    Sleep    300
    Check Related PM Counters For Case
    [Teardown]    Case Teardown For CUS

CNI-125269-ST-2 RNL Normal Release is used for the SgNB Release Request message in the UE triggered EN-DC takeback scenario-NR part
    [Tags]    QC_99348
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    21.08.2024,yongjie.liu@nokia-sbell.com,case template draft
    [Setup]    Common Case Setup For Pet
    Prepare Counter
    Start Capture Btslog
    UE6 Attach ENB1 Cell1 With Default Bearer QCI6 And Changed To SCG
    UE Trigger EN DC Tackback
    Sleep    300
    Check Related PM Counters For Case
    [Teardown]    Case Teardown For CUS

*** Keywords ***
Skip Robocop Warning
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    21.08.2024,yongjie.liu@nokia-sbell.com,case template draft
    Log To Console    ${INSTALL_BUILD}
    Log To Console    ${DEBUG_MODE}
    Log To Console    ${CLEAN_LOG_SIZE}
    Log To Console    ${USE_AIRPHONE}

