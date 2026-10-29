*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/EnergySaving_common_keywords.robot
Resource    Resources/Energysaving_Call_keywords.robot


Documentation
...    Author:zhenzhen ren
...    contact:zhenzhen.ren@nokia-sbell.com
...    squad group:SG_08
...    Feature CB012196-B in 25R1

Force Tags            RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00
...    PY36


*** Variables ***
@{modify_list_1}    'ssbFrequency'  'actBadUplinkRadioRedirect'
@{modify_list_2}    'ngSetupRespTmr'  'actDl256Qam'
@{modify_list_3}    'dllaTargetBlerVoNR'  'qRxLevMin'  'Pmax'  'actDlDynSwitchAlloc'



*** Test Cases ***
ES IWK with Parameter Change IWK with NG link interrupted
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air
    Enable or disbale 04131588 feature flag
    AlarmWatchdog.add_allow_alarms    fault_id=7101
    ES IWK with Parameter Change IWK with NG link interrupted    modify_list=${modify_list_1}    Max_loop=${3}
    Make L3 call in cell3

ES IWK with Parameter Change IWK with cell lock
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air
    Enable or disbale 04131588 feature flag
    ES IWK with Parameter Change IWK with cell lock    modify_list=${modify_list_2}    Max_loop=${3}
    Make L3 call in cell2

ES Switching on IWK With Parameter change
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air
    Enable or disbale 04131588 feature flag
    ES Switching on IWK With Parameter change    modify_list=${modify_list_3}    Max_loop=${3}
    Make L3 call in cell1

EDSM after multiple RU reset
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air
    Enable or disbale 04131588 feature flag
    EDSM after multiple RU reset    Max_loop=${5}


EDSM after multiple snapshot
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air
    Enable or disbale 04131588 feature flag
    EDSM after multiple snapshot    Max_loop=${5}