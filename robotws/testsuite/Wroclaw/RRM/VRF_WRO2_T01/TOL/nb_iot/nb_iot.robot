*** Settings ***
Documentation    TOL TMO tests to cover IoT cell call.
...              From TOL TMO excel file we need to cover
...              - NB_IoT_GuardBand_Attach_Tput
...              Target TL -> TMO TOL To be filled when cloud resources are available

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/multi_ue.robot

Test Setup    get ues    ${ues}    ue_capabilities=IOT

*** Variables ***
@{ues}    ue1

*** Test Cases ***
NB_IoT_GuardBand_Attach_Tput
    detach ues from cell    ${ues}
    attach ues to cell    ${ues}
    Start ULDL for UEs    ${ues}    duration=10s
    Await datatransfers finish
