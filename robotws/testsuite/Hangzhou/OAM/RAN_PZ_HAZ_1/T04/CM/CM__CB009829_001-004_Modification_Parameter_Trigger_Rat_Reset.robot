*** Settings ***
Documentation       Test suite for NFTA
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Variables         ../test_line_specific/SBTS_SYVE_37376/My_Variables.py
Resource          ../test_resources/CM/CM__CB009829_001-004_Modification_Parameter_Trigger_Rat_Reset.robot

*** Test Cases ***
CM__CB009829_001-004_Modification_Parameter_Trigger_Rat_Reset
    [Setup]    SetUp
    CM__CB009829_001-004_Modification_Parameter_Trigger_Rat_Reset
    [Teardown]    TearDown