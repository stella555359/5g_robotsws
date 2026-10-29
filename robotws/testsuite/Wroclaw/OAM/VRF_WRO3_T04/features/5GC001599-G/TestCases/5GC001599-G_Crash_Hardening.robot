*** Settings ***
Documentation
...  author:  Patryk Tatarek
...  contact: patryk.tatarek@nokia.com

Resource    ../Resources/Crash_Hardening.robot

*** Keywords ***
[1]5GC001599-G_VPP_Crash_Hardening_ASIK
    Kill The VPP Process
    Pause The VPP Process
