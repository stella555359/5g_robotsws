*** Settings ***
Library    ../libraries/OcpUtils.py

Suite Setup  Suite Setup


*** Test Cases ***
Test Get Current Context
    ${current}=  Get Current Context


*** Keywords ***
Suite Setup
    Run Keywords
        Set Log Level  TRACE
        Get Testline Configuration
        Log in to all OCP servers
