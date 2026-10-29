*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource          ../test_resources/CM/CM__CB009451-C_001_Configure_Feature_As_Part_Of_New_BTS_Site_Creation_Using_Online_WebEM.robot

*** Test Cases ***
CM__CB009451-C_001_Configure_Feature_As_Part_Of_New_BTS_Site_Creation_Using_Online_WebEM
    [Setup]    SetUp
    CM__CB009451-C_001_Configure_Feature_As_Part_Of_New_BTS_Site_Creation_Using_Online_WebEM
    [Teardown]    TearDown