*** Settings ***
Library  OperatingSystem
Force Tags  ${ENB_BRANCH}  SRAN  CLOUD_SRAN_LWG_2ASIA_5ABIA_2FRGY_2FXDB_1AHEB  STATE_SKIP_AGENT


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
@{GSMVlan}            ${261}  ${261}
${WCDMAVlan}          ${361}
${LTEVlan}            ${461}
${Switch_IP}          10.255.10.109
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       1
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass1234

*** Test Cases ***
Test
    [Timeout]  10s
    Create Directory  /home/ute/logs/TestDirectory
    Log Variables

Test
    [Timeout]  10s
    Create File  /home/ute/logs/TestDirectory/test.txt  0123456789
    Log Variables

Test 1
    [Timeout]  10s
    Log Variables

Test 1
    [Timeout]  10s
    Log Variables

Test 2
    [Timeout]  10s
    Log Variables

Test 2
    [Timeout]  10s
    Log Variables

Test 3
    [Timeout]  10s
    Log Variables

Test 3
    [Timeout]  10s
    Log Variables

Test 3
    [Timeout]  10s
    Log Variables

Test 4
    [Timeout]  10s
    Log Variables

Test 4
    [Timeout]  10s
    Log Variables

Test 5
    [Timeout]  10s
    Log Variables

Test 5
    [Timeout]  10s
    Log Variables

Test 6
    [Timeout]  10s
    Log Variables

Test 6
    [Timeout]  10s
    Log Variables

Test 7
    [Timeout]  10s
    Log Variables

Test 7
    [Timeout]  10s
    Log Variables

Test 8
    [Timeout]  10s
    Log Variables

Test 8
    [Timeout]  10s
    Log Variables

Test 9
    [Timeout]  10s
    Log Variables

Test 9
    [Timeout]  10s
    Log Variables

Test 10
    [Timeout]  10s
    Log Variables

Test 10
    [Timeout]  10s
    Log Variables

*** Keywords ***
