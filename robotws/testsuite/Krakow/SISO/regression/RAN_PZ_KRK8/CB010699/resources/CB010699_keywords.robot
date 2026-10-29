*** Settings ***
Documentation
...     Keywords for testing CB010699 feature
...     Author: Natalia Czech
...     Contact: natalia.czech@nokia.com



Variables            testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB010699/resources/files_to_check.py
Variables            taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables            testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB010699/resources/python_keywords.py
Library              taf.sbts.oam.coam.admin  WITH NAME  coam_admin
Library              taf/rfrl/procedures/resources/python/connections.py
Library              testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB010699/resources/python_keywords.py
Library              taf.rfrl.bts.commissioning
Resource             taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource             taf/rfrl/bts/robot/common/gnb_log.robot
Resource             taf/rfrl/procedures/SISO/General_SiSo_Commissioning_BTS_Template_Commissioning.robot


*** Variables ***
${zip_directory}                /home/ute/srcel/SRCEL
@{CUSTOM_ALLOWED_ALARMS}        No X2 link available
...                             BTS Reset Cause
...                             Sanity Check Error
${sw_config_path}               testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/UUF4ALL/resources/swconfig.txt
${prefix_tag}                   main

*** Keywords ***
Custom Suite Setup
    Perform Full Commissioning On Classical gnb     prefix_tag=${prefix_tag}    update_timeout=1200
    Perform Full Commissioning on gNB ASIR hub
    Wait Until Keyword Succeeds     1200 sec     1 sec    gnbcell.verify all cells are onair
    Common Suite Setup
