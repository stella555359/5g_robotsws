*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com
Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.sw.dcap.rd   WITH NAME   rd
Library     taf.transport.ssh   WITH NAME   csn
Library     taf.analyzer.pcap   WITH NAME   wireshark

Resource    ../../common/taf_coam.robot
Resource    ../../common/L3_Call.robot

Resource    ./Classical.robot
Resource    ./Cloud.robot
Resource    ./DCAP.robot
Resource    ./EMIL.robot
Resource    ./L3Call.robot
Resource    ./PowerUE_Cloud.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Variables   ../Library/pcmd_var.py
Variables   ../../libraries/global_vars.py


*** Variables ***

*** Keywords ***


