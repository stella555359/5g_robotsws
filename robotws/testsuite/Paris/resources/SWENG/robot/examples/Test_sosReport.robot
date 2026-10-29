*** Settings ***
Documentation        A test suite with a single test for testing the SOS report

Resource                            ../Tools.robot
Resource                            ../Setup.robot
Resource                            ../Topology.robot
Library                             ../../python/StringTool.py
Library                             ../../python/OsTool.py
Library                             ../../python/Setup.py

Suite Setup                         Suite Setup
#Suite Teardown                      Suite Teardown

Test Teardown                       Test Teardown

*** Test Cases ***

Test OK
    Dated log                       Start

Test KO
    Dated Log                       Test KO
    should be true                  ${False}
