*** Settings ***

Documentation     [Procedure] "[1]TRS_CB008936_Delta validation and provisioning with validation scope as DELTACHECK in NetAct during maintence"
...               [Date] "02-05-2023"
...               [Author] "Vaishnavi"
...               [Feature_ID]  "CB008936"
...               [Maintenance] "TRS I & V Tools Bangalore Team"
...               [Function_Hash_Tags]  "Validation scope,Full check,Delta check"
...               [DELTA_FILE_DEPENDENCY]   "Delta-check"
...               [Validated_TestLine]  "IAV-BLR-TL008-ETERNALS"
...               [Precondition]    "ENodeB should be integrated to Netact"

Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/resources/CB008936_keywords.robot


Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops

Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops

*** Test Cases ***
[1][1.0] TRS_CB008936_Delta plan pre-validation , validation and provisioning with validation scope as DELTACHECK in NetAct during maintence window
    Preconditions
    Export the plan-1
    sleep   150
    Import the plan-1
    Making ProvisionPlan
    Online validation


