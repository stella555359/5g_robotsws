*** Settings ***
Documentation
...   author:
...    - Mateusz Matusik (mateusz.matusik@nokia.com)

Resource     ./resources/common.robot
Resource     ./resources/CB009485_keywords.robot

Suite Setup    Run Setup

*** Variables ***
${LUA_CFG}=             ${CURDIR}/resources/configs/egate.lua
${SCFC}=                ${CURDIR}/resources/configs/SBTS00_SCF.xml
${tce_yaml}=            ${CURDIR}/resources/configs/yaml/tce.yaml
${C_setup}=             ${CURDIR}/resources/configs/yaml/CB009485_setup.yaml
@{setup_yaml}=          ${tce_yaml}    ${C_setup}
${SKIP_COUNTERS}=       ${FALSE}

*** Test Cases ***
CB009485_C_01_Monitoring_segmentation_of_UE_radio_capability_information

    [Setup]    Test setup

    Configure that UE1 will send capabilites in parts and UE2 in single message
    Expect UE1 to sent UE Capabilities Information in segments
    UE1 attach to gNB2
    Verify that UE1 Capabilities were sent with several ULDedicatedMessageSegment messages
    Stop capturing UE1 trace in Wireshark
    Verify that UL Dedicated Message Segments were contained in active TRS of UE1 call
    Verify that reassembled UE Capability Information is present in active TRS of UE1 call

    Start tshark collecting
    Expect UE2 to sent UE Capabilities Information in single message
    UE2 attach to gNB2
    Verify that UE2 Capabilities were sent in UECapabilityInformation message
    Stop capturing UE2 trace in Wireshark
    Verify that UL UECapabilityInformation message was contained in active TRS of UE2 call

    [Teardown]    Test cleanup
