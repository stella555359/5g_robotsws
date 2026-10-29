*** Settings ***
#Suite Setup          Run Keywords    RJIO Suite Setup    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
Suite Setup          RJIO Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        RJIO Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ./Resources/Rjio_keywords.robot


Documentation
...    Author: Melinda
...    Contact: meinda.gao@nokia-sbell.com
...    squad group:SG_08
...    E2E Rjio

Force Tags    PY36


*** Variables ***
@{cell_id63}    ${63}
*** Test Cases ***
Rjio_E2E_57_Parallel_Operation_RU_Lock_And_Site_Reset
    FOR   ${index}   IN RANGE   0    5
        Rjio_E2E_57_Parallel_Operation_RU_Lock_And_Site_Reset
    END

Rjio_E2E_58_Parallel_Operation_RU_Lock_And_Parameter_Change
    FOR   ${index}   IN RANGE   0    5
        Rjio_E2E_58_Parallel_Operation_RU_Lock_And_Parameter_Change
    END

Rjio_E2E_59_Parallel_Operation_RU_Lock_And_SW_Upgrade
    FOR   ${index}   IN RANGE   0    5
        Rjio_E2E_59_Parallel_Operation_RU_Lock_And_SW_Upgrade
    END

Rjio_E2E_60_Parallel_Operation_RU_Lock_And_RU_reset
    FOR   ${index}   IN RANGE   0    5
        Rjio_E2E_60_Parallel_Operation_RU_Lock_And_RU_reset
    END

Rjio_E2E_61_Parallel_Operation_RU_Lock_And_Snapshot
    FOR   ${index}   IN RANGE   0    5
        Rjio_E2E_61_Parallel_Operation_RU_Lock_And_Snapshot
    END

Rjio_E2E_62_Parallel_Operation_Cell_Block_And_RU_Lock_Unlock
    FOR   ${index}   IN RANGE   0    5
        Rjio_E2E_62_Parallel_Operation_Cell_Block_And_RU_Lock_Unlock
    END

*** Keywords ***
