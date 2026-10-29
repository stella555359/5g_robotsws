*** Settings ***
Documentation    Keywords for the CB009854

Library     ute_wtssim
Library     ta5g_ue_mobility
Resource    testsuite/Wroclaw/RRM/WRO_2/keywords/tshark_verifying.robot

*** Keywords ***
Verify Message
    [Arguments]    ${expectation}
    Verify Tcpdump Log    ${expectation}
