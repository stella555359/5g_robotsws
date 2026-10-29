*** Settings ***
Documentation  CB010986 automated test cases implementation.

Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010986/resources/keywords.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/multi_ue.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/logs_collection.robot

*** Variables ***
@{ues}  ue1


*** Keywords ***
[1]TC06_CB010986-B_AoA_and_location_activation_in_WebEM
    Prepare TL for CB010986 test
    Detach ues from cell  ${ues}
    attach ues to cell  ${ues}

    Start cplane logs
    Do manual location trigger
    Stop cplane logs

    Check cplane messages exists
    Verify location counter
