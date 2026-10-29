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
22R1_OMKPI_Site_Reset_Rep25
    [Tags]
    Sleep  1s
    Run Flame Script  https://svne1.access.nsn.com/isource/svnroot/robotfiles/RDeOu1/TestCases/SR_state/22R1_CNF_SRAN_5G_1_sitereset_rep25.fws
