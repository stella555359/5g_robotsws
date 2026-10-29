*** Settings ***
Documentation    Suite description
...    Author:        amy.wu@nokia-sbell.com
...    Maintainer:    Wu Amy

Library     Telnet
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ./random.robot

#Variables    ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

Force Tags    STATE_GNB_NOT_COMMISSIONED   CLOUD_5G_CLASSICAL_SA_ASIBLR_ABIOB1B4_AEHC_3xAHCA_FULLRACK

Test Timeout     72h

*** Variables ***
&{5G_CB007262_AEHC_3AHCA_MultiRat}=    HW_ID=CB007262    site_mode=MultiRat    ONAIR_TIME=15 min
...                                    peak_rate_config={"171":[200,20],"172":[200,20]}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}    5G_CB007262_AEHC_3AHCA_MultiRat

${NO_REQUIRED_CELL_ID}    182:183
${REQUIRED_CELLS}    171:172:179:180:181
${ONLINE_PARAMETERS}    [{"distName": "MRBTS-10628/LNBTS-10628/LNCEL-9", "paraName": "pMax", "paraValue": ["300", "370"]},
...    {"distName": "MRBTS-10628/LNBTS-10628/LNCEL-10", "paraName": "pMax", "paraValue": ["300", "370"]}]
@{RANDOM_ACTIONS}    Random Lock RRU
...                  Random Unlock RRU
...                  Random Reset BBMOD
...                  Random Block Cell
...                  Random Unblock Cell
...                  Random Make Tput
...                  Random Check RFSW logs In BTS Snapshot
...                  Random Reset RU
...                  Random Online Commission
...                  Random Power Off RU
...                  Random Power On RU
...                  Random RAT Reset

*** Test Cases ***
Random Test
    [Setup]    Testcase Basic Precondition    case_name=random_test
    Random Setup
    FOR    ${i}    IN RANGE    ${2}
        Random Test Keyword
        Verify All Cells OnAir
        Check Alarms
        Check Historical Alarms    additional_allowed_alarms=Cell blocked
    END
    [Teardown]    Testcase Basic Postcondition

Verify Random Test
    [Setup]    Testcase Basic Precondition    case_name=random_test
    Execute Specific Random Steps    steps_txt=/home/ute/logs/2023-03-28-02-58-39_CB007262_SBTS00/Random_Test/step.txt
    Verify All Cells OnAir
    Check Alarms
    Check Historical Alarms    additional_allowed_alarms=Cell blocked
    [Teardown]    Testcase Basic Postcondition
