*** Settings ***
Documentation
...    Author:yin zhang
...    contact:yin.zhang@nokia-sbell.com
...    squad group:VRF3_7
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown
Resource          ../resources/DevHZ5_resource_ST.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS:actCMAS=true
...    NRCELL:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=1
...    NRCELL-311:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=81
...    NRBTS/NRADJGNB-1:gNodeBId=2
@{PARAMS_IN_SCF_BTS2}
...    LNBTS:actCMAS=true
...    LNCEL:a3Offset=6
...    LNCEL-1:a1TimeToTriggerDeactInterMeas=40ms

*** Test Cases ***
Setup GNB
    log to console    Hello ST World!!!

*** Keywords ***
Start BTS With Specified Config Files
    Common suite setup and Setup 2BTS env    scf1=SCFC_1.xml    scf2=SCFC_2_enb.xml
