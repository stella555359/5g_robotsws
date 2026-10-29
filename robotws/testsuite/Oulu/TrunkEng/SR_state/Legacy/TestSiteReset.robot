*** Settings ***
Documentation
...   author: Pekka Lonnakko
...   contact: pekka.lonnakko@nokia.com
...   The purpose of this test is to verify that dynamic testlines work on 5G

Resource            ../../Resources/robot/Flame_Resource.robot
Force Tags          CLOUD_FR4K_R_L_[1]_[AHLOA]   SkipRun

*** Test Cases ***
test_SiteReset
    [Tags]
    Sleep  1s
    Run Flame Script  https://svne1.access.nsn.com/isource/svnroot/robotfiles/RDeOu1/TestCases/SR_state/sitereset_test.fws
