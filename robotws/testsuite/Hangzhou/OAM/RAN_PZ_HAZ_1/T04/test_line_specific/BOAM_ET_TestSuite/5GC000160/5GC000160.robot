*** Settings ***
Documentation     Copyright 2022 Nokia Solution and Networks. All rights reserved
...               Author: Jet Li.Li (NSB - CN/Hangzhou)
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/BOAM_ET/TAF_Common_Resource.robot
Force Tags        TEAM-BOAM OSSEMS ET    FEATURE-5GC000160    CRT   RAN_5G_TDD    RAN_5G
...    SBTS00    SBTS23R1    OWNER-Jin Jiajun   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Suite Setup       Common BTS Suite Setup
Suite Teardown    Common BTS Suite Teardown

*** Variables ***
${S_Upload_File}     /home/flexi1/UPLOADS/CUPL_BTSA_flexi1.xml

*** Test Cases ***
5GC000160 Triger HW upload from NetAct together with CM
    [Setup]    Private_Test_Setup
    ta_emss.Request Upload    hwConfigurationFile
    file.File Should Contain    ${S_Upload_File}    com.nokia.eqm.hw:INVUNIT||HW-1/INVUNIT
    file.File Should Not Contain    ${S_Upload_File}    FEATCADM    #No another MO except HW MO.
    ta_emss.Request Upload    configurationPlanFile
    file.File Should Not Contain    ${S_Upload_File}    com.nokia.eqm.hw:INVUNIT    #CM plan file should not contain HW
    [Teardown]    Private_Test_Teardown

*** Keywords ***
Private_Test_Setup
    Common BTS Test Setup
	Setup with Emssim

Private_Test_Teardown
	Teardown with Emssim
    Common BTS Test Teardown