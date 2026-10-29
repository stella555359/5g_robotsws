*** Settings ***
Documentation
...  author : liang.6.chen@nokia-sbell.com
...  contact: liang.6.chen@nokia-sbell.com

Resource          ../Resource/Common.robot
Resource          ../Resource/CB007841_common_keywords.robot
Library           ../Resource/check_tem.py
Variables         ../Resource/CB007841_modify_para.py

*** Variables ***

*** Keyword ***
BTS_startup_SFP+_or_SFP28_transceivers_start_up_support_for_backhaul_interface
    Check BTS is in On Air
    Check BTS startup
    BTS detects cold SFP+/SFP28 startup and compare the temperature

Case Setup: SFP28_startup

Case Teardown: SFP28_startup
