*** Settings ***
Documentation
...    Author: Catlan Radu
...    Maintainer: Catlan Radu (radu-vasile.catlan@nokia.com)
...    Group in charge: MN RAN BOAM VERIF Team3
...    References: doors
...    Feature Description: 5GC001719-D


Resource   ./resources/5GC001719-D.robot
Resource   ./resources/xPATH_5GC001719-D.robot

Suite Teardown  Run Keyword And Ignore Error  Logout vCU

*** Test Cases ***
[1]1. Check if standby gNB_CU CNF can merge own SCF with the received SCF from active one and activate it after
    [Tags]   CRT_GEO   QC_
    Sleep  300s
    Check Primary&Active vCU status
    Check Secondary&Standby vCU status
    Login vCU1
    Create Delta Plan on active vCU to change a parameter
    Validate & Activate Delta Plan on active vCU
    Sleep  60s
    Wait Until Keyword Succeeds  15 min   1 min   Verify All Pods Are Running
#asteptam sa-si dea reset vCU2 si sa se activeze SCF-ul
    Sleep  120s
    Check Primary&Active vCU status
    Check Secondary&Standby vCU status
    Login vCU2
    Check Delta Plan from active vCU is present on standby vCU




