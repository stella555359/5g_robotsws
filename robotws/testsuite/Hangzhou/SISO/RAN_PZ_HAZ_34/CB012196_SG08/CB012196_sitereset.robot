*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/CB012196_common_keywords.robot


Documentation
...    Author:zhenzhen ren
...    contact:zhenzhen.ren@nokia-sbell.com
...    squad group:SG_08
...    Feature CB012196-B in 25R1

Force Tags            RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00
...    PY36


*** Test Cases ***
Config5_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air    scf_name=config5
    Config5_OAM_KPI_61a_SiSo_Auto_BTS_site_reset    Max_loop=${50}
