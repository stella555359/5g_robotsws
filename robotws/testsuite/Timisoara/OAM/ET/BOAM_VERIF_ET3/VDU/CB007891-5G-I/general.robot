*** Settings ***
Documentation
...    Author: Fiterau Andreea (andreea.fiterau@nokia.com), Gordan Adelina (adelina.gordan@nokia.com
...    Maintainer: Fiterau Andreea (andreea.fiterau@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_TIM_3_ET_GMS
...    Feature Description: CB007891-B
...    Sample execution: robot -L TRACE -b debug.log -d /home/ute/Desktop/CRT/Results_VDU/CB007891-I 
...       /home/ute/Desktop/CRT/Test_Suite_EIT_VDU/CB007891-I/general.robot

Resource    ./resources/xpath_CB007891-I.robot
Resource    ./resources/CB007891-I.robot

Library  SeleniumLibrary
Library  SSHLibrary
Library  String
Library  OperatingSystem
Library  DateTime

*** Test Cases ***

[1].1 Check fault 4350 and the alarm 7101 to be triggered as a recovery action

    Login To WebEM
    Check if OnAir

    Login To Worker1-242
    Turn Off Worker-1

    Login To Worker2-243
    Turn Off Worker-2

    Sleep      90

    Login To WebEM
    Check if up pods are NOT available
    Sleep       30
    Check alarms
    Sleep       20

    Log in SSH
    Verify PODS are TERMINATING
    Sleep       300

    Log in SSH
    Verify NODES are NOT ready

    Login To Worker1-242
    Turn On Worker-1

    Login To Worker2-243
    Turn On Worker-2

    Sleep       600

    Log in SSH
    Verify all NODES are ready

    Sleep       600

    Log in SSH
    Verify all PODS are running

[1].4 Check fault 4350 with alarm 7115 is raised with no recovery action and no cell mapped on the failed pod
    Login To WebEM
    Check alarm 7115

[1]5.Check fault 4350 with alarm 7116 is raised when there are cell(s) mapped on the failed pod
    Login To WebEM
    Check alarm 7116
