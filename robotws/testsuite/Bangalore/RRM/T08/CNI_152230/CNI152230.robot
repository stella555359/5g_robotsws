*** Settings ***
Documentation
...  author: Amit Kumar Sahu
...  contact: Amit.kumar_sahu@nokia.com
...  Description: Test Suite for CNI152230


Test Setup    Test Setup
Test Teardown    Test Teardown
Resource    CNI152230_keywords.robot
#Resource    expected_alarms.robot
#Resource    pva.robot


*** Variables ***
${pva_ip}  10.45.153.213
${vendor}  TOPYOUNG
${model}  TAS16T16-51-120-1N-DEJS
${VM_IP}  10.58.238.167
${VM_usn}  ute
${VM_pwd}  BT5l@bus3rl0g1n
${mplane_ip}  10.58.239.29
${MCG_IP}  10.45.150.251
${MCG_usn}  inbabtslabuser
${MCG_pwd}  BT5l@bus3rl0g1n
${MCG_domain}  NOKLAB

${DURATION}  800s

${k}  0
${name}
${vonr_dist}  MRBTS-1066/NRBTS-1066/NRCELL-0
${vonr_name}  Activate last two DL slots muting in tdLte frame structure
${vonr_abbr}  actTwoDlSlotsMutInTdLte

${ABSTRACT_LIB_CONFIG}
@{capabilities}    Legacy_1   #s1ho activate
@{throughput_dl}    4500
@{throughput_ul}    3700
${dt_name_v}    test_voice_call
@{UE_alias}=    UE1
@{direction_dl}=      dl
@{direction_ul}=      ul
@{timeout}    20
@{deviation_dl}=      300
@{deviation_ul}=      10
@{call_type}=    TCP


*** Test Cases ***
CNI152230_Functional_verification_of_feature
    [Setup]  Run Keywords    Test Setup
    CNI_Verification
    [Teardown]  Run Keywords    Test Teardown


*** Keywords ***
CNI_Verification
    Set Environment Variable    ABSTRACT_LIB_CONFIG    /home/ute/testline_configuration/Bangalore/7_2_RJIO1066/ta_ue_config.yaml
    Log to Console  \n --- PVA Port 1 Set to 20 --- \n
    CoamAdmin.lock    dist_name=MRBTS-1066/NRBTS-1066/NRCELL-48    timeout=300    connection=oam
    sleep    30s
    Start DCAP log collection
    sleep    20s
    Start Prepare UE & Attach UE
    Start Data Transfer
    Stop DCAP log collection
    sleep    150s

    Run keyword And Continue On Failure    Unzip and extract files    ${dcap_dirname}
    Download TTI build
    Validation of TTI traces    ${source_path}

    Log to Console    \n ****Online Counter validation before start modification CNI152230 Parameter*****
    ${value1}    Counter validation    M55601C00002
    Log to Console    \n ****Let's modify CNI152230 Parameter*****
    Parameter change task
    sleep    30s
    Log to Console    \n **** Data Running on UE.....
    Start DCAP log collection
    sleep    40s
    Stop DCAP log collection
    sleep    100s
    Stop Data Transfer
    sleep    10s
    Run keyword And Continue On Failure    Unzip and extract files post    ${dcap_dirname}
#    Download TTI build
    Validation of TTI traces post    ${source_path}


    Log to Console    \n **** Online Counter validation After modification parameter value
    ${value2}    Counter validation    M55601C00002

    ${difference}=    Evaluate    ${value2} - ${value1}
    ${remainder}=     Evaluate    ${difference} % 300
    ${status}=    Run Keyword And Return Status    Should Be Equal As Numbers    ${remainder}    0
    Run Keyword If    ${status}
    ...    Log To Console    PASS: CHECK POINT-1 ***CNI-152230 **** CNI-152230 online modification verified
    ...    ELSE
    ...    Log To Console    FAIL: CHECK POINT-1 ***CNI-152230 Online modiciation verified Failed  (${remainder})
    CoamAdmin.unlock    dist_name=MRBTS-1066/NRBTS-1066/NRCELL-48    timeout=300    connection=oam


Set_export_yml
    [Arguments]  ${yml_filepath}
    ssh.Connect_to  ${VM_IP}  ${VM_usn}  ${VM_pwd}  alias=vm
    ssh.Execute  command=${yml_filepath}  connection=vm  timeout=30s
    ssh.Disconnect  connection=vm
