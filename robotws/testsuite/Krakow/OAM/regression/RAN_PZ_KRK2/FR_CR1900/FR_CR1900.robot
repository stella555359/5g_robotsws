*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com

Resource    ./resources/CR1900_keywords.robot

Test Setup    Run Keywords
...           Set Allowed Alarms    AND
...           Common Preconditions
Test Teardown    Common Postconditions

*** Test Cases ***
[1]FGCR_1900_C_6_Single UE UL and DL UDP peak throughput (5G 100MHz cell)
    Prepare CR1900 Ue
    Run One Way UDP DL Data Transfer
    Run One Way UDP UL Data Transfer
