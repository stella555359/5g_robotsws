*** Settings ***
Documentation
...   author: Rafal Kawa
...   contact: rafal.kawa@nokia.com
...   desctiption: Test suite performs gNB commssioning

Resource    taf/rfrl/bts/robot/gnb.robot

*** Test Cases ***
Perform_gNB_commissioning
    Perform commissioning on gNB to onAir state