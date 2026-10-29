*** Settings ***
Documentation
...    Author: Roxana Craciun (roxana.craciun@nokia.com)
...    Maintainer: Roxana Craciun (roxana.craciun@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:CB005958-5G
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB005958-5G/general.robot

Resource    ./resources/CB005958-5G.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN     SBTS00  SBTS22R4  SBTS23R1    CRT
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD      # CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
...    CA_RAN_BOAM_VERIF  CA_BTS_OAM_FMRECOV     #QCP_BTS_OAM    QCD_MN_BTS_OAM   CLOUD_5G_I_KL_AP_KL_NSA_FS_CPRI_CMWV_TDD
#...   # master_classicalbts_all   #SBTS21B #21A_classicalbts  SBTS22R1   SBTS22R2  SBTS22R3 

Suite Setup       Run Keywords    Reach OnAir Setup for LO_AP_LO
...               AND             Suite Preconditions
Suite Teardown    Run Keywords    Reach OnAir Teardown
...               AND             Suite Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***

M55601C01001 - NR_CELL_PLAN_UNAVAIL_SAMPLES_WebEM
    [Tags]   CRT  
    [Documentation]
    ...
    M55601C01001 - NR_CELL_PLAN_UNAVAIL_SAMPLES_WebEM


# M55601C01002- NR_CELL_PLAN_UNAVAIL_CHNG_TO_WebEM           
#    [Tags]   CRT                   # regression optimisation
#    [Documentation]
#    ...
#    M55601C01002- NR_CELL_PLAN_UNAVAIL_CHNG_TO_WebEM

# Robustness_testing Check if value of NR_CELL_PLAN_UNAVAIL_CHNG_TO is incremented
#    [Tags]   CRT                    # regression optimisation
#    [Documentation]
#    ...
#    Robustness_testing Check if value of NR_CELL_PLAN_UNAVAIL_CHNG_TO is incremented

