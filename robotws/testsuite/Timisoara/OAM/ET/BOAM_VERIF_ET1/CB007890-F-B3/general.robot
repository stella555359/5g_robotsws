*** Settings ***
Documentation
...    Author: Razvan Purlea (razvan.purlea@nokia.com)
...    Maintainer: Razvan Purlea (razvan.purlea@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_SPIRIT_ET_GMS
...    Feature Description: CB007890-F-B3
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007890-F-B3/general.robot

Resource    ./resources/CB007890-F-B3.robot

Suite Teardown  Run Keyword  Close Connection

Library  SeleniumLibrary
Library  SSHLibrary
Library  String
Library  DateTime

Library       taf.config.scf    WITH NAME    scf


*** Variables ***

*** Test Cases ***

4_LTE_OPR_REQ_31898_vCU_UPUE_Check_Fault_4695
    [Tags]         CRT
      Generate Fault 4695 for UPUE
    [Teardown]  Run Keyword  Close Connection

3_LTE_OPR_REQ_31898_vCU_CPUE_Check_Fault_4695
   [Tags]         CRT
   Generate Fault 4695 for CPUE

