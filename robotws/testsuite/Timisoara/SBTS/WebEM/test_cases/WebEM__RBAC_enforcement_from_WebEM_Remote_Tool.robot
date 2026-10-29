*** Settings ***
Documentation  This suite contains WebEM__RBAC_enforcement_from_WebEM_Remote_Tool TC

Resource  ../test_resources/WebEM__RBAC_enforcement_from_WebEM_Remote_Tool.robot


*** Test Cases ***
WebEM__RBAC_enforcement_from_WebEM_Remote_Tool
    [Setup]  TC Setup
    TC__WebEM__RBAC_enforcement_from_WebEM_Remote_Tool
    [Teardown]  TC Teardown
