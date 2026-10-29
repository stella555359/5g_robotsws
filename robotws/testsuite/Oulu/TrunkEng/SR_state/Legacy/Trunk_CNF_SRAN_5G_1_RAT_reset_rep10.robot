*** Settings ***
Documentation
...   author: Heikki Autio
...   contact: heikki.autio@nokia.com
...   The purpose of this test is to verify that dynamic testlines work on 5G

Resource            ../../Resources/robot/Flame_Resource.robot
Force Tags          CLOUD_5G_CLASSICAL_SA_ASIB_3xABIO_3xAHLOA
...                 CONFIGS_2_11_UTESRAN094/custom_config.yaml
...					RAN_5G
...                 STATE_ON_AIR


*** Test Cases ***
OMKPI_RAT_Reset_Rep10
    [Tags]
    Sleep  1s
    Run Flame Script  https://svne1.access.nsn.com/isource/svnroot/robotfiles/RDeOu1/TestCases/SR_state/Trunk_CNF_SRAN_5G_1_ratreset_rep10.fws
