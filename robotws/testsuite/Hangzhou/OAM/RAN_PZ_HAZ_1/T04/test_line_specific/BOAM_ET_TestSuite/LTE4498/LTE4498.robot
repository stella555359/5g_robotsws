*** Settings ***
Documentation     Copyright 2022 Nokia Solution and Networks. All rights reserved
...               Author: Jet Li.Li (NSB - CN/Hangzhou)
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/BOAM_ET/TAF_Common_Resource.robot
Force Tags        TEAM-BOAM OSSEMS ET    FEATURE-LTE4498    RAN_4G    RAN_4G_FDD
...    SBTS00    SBTS23R1    OWNER-Wu Xi   CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
Suite Setup       Common BTS Suite Setup
Suite Teardown    Common BTS Suite Teardown
Test Setup        Common BTS Test Setup
Test Teardown     Common BTS Test Teardown


*** Test Cases ***
LTE4498-A-a.1.2 Triger HW upload from NetAct together with CM
    [Tags]   CRT
    [Setup]    Run Keywords	   Setup with Emssim    AND    Common BTS Test Setup
	ta_emss.Request Upload    allconfigurationplanfile
	file.File Should Contain    /home/flexi1/UPLOADS/CUPL_BTSA_flexi1.xml    MNL    #CM MO in CM file
    file.File Should Contain    /home/flexi1/UPLOADS/CUPL_BTSA_flexi1.xml    com.nokia.eqm.hw:INVUNIT    #HW MO in HW
    [Teardown]    Run Keywords    Teardown with Emssim   AND    Common BTS Test Teardown

[1.0] LTE4498-A-a.1.3 HW upload from NetAct successfully which separate with CM.
    [Tags]   CRT
    [Setup]    Run Keywords	   Setup with Emssim    AND    Common BTS Test Setup
    ta_emss.Request Upload    hwConfigurationFile
    file.File Should Contain    /home/flexi1/UPLOADS/CUPL_BTSA_flexi1.xml    com.nokia.eqm.hw:INVUNIT||HW-1/INVUNIT
    file.File Should Not Contain    /home/flexi1/UPLOADS/CUPL_BTSA_flexi1.xml    FEATCADM    #No another MO except HW MO
    ta_emss.Request Upload    configurationPlanFile
    file.File Should Not Contain    /home/flexi1/UPLOADS/CUPL_BTSA_flexi1.xml    com.nokia.eqm.hw:INVUNIT    #CM plan file should not contain HW
    file.File Should Contain    /home/flexi1/UPLOADS/CUPL_BTSA_flexi1.xml    FEATCADM
    [Teardown]    Run Keywords    Teardown with Emssim   AND    Common BTS Test Teardown
