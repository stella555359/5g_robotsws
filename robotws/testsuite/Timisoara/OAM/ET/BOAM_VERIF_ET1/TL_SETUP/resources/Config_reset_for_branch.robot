*** Settings ***

Library        String
Library        OperatingSystem
Library        Process
Library        taf.gnb.oam.coam.admin.interface.admin   WITH NAME   taf_admin
Library        DateTime

Resource    ./keyword.robot
Resource    ../../resources/pretest_posttest.robot

*** Variables ***
${Scf_Initial_Configuration}=  Initial_Configuration_scf_MRBTS_AAFB_AAIB_n25_n66_BW5_-30.xml
${Scf_Default}=   /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/5GC000766-A/resources/${Scf_Initial_Configuration}

*** Keywords ***
Config reset for branch
    Log To Console   ConfigReset scf SWR
    Configuration Reset


