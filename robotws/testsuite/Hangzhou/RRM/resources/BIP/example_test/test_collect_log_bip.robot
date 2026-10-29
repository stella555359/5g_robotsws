*** Settings ***
Force Tags    PY27
Resource    ./../common_resource_catch_bip.robot

*** Variables ***

*** Test Cases ***
Example Test For Catch BIP Log
    Start Gnb BIP Log
    Sleep    10s
    Stop Gnb BIP Log


*** Keywords ***

