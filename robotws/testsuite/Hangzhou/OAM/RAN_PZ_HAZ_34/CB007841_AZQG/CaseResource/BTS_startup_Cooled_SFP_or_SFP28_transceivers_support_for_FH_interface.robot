*** Settings ***
Documentation     author: Chen Liang
...               contact: liang.6.chen@nokia-sbell.com


Resource          ../Resource/CB007841_FID4657_keywords.robot
Resource          ../Resource/CB007841_common_keywords.robot
Variables          ../Resource/CB007841_modify_para.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***

*** Keyword ***
BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_for_FH_interface
    Check BTS is in On Air
    Check BTS startup
    BTS detects cooled SFP+/SFP28

Case Setup: cooled_SFP

Case Teardown: cooled_SFP
