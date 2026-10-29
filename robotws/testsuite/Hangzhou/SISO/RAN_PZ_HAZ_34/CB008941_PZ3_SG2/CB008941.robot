*** Settings ***
Documentation     author: Wu Charlotte
...               contact: charlotte.wu@nokia-sbell.com
...               squad group: MMW_02
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

Resource          Resources/CB008941_keywords.robot
Force Tags    5G_RAN    5G_RAN_TDD    RAN_5G    RAN_5G_TDD    SBTS00    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AQQN    STATE_SW_UPLOADED    PY39
*** Variables ***
@{GNB_PS_CELL_INDEX_LIST}    1
# ${if_commissioning}   False
${scf_1sector}    SCF_SBTS00.xml
${base_path}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G

*** Test Cases ***
[1]CB008941-SR-AA-B1_1_Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF
    [Tags]    CRT_UTE
    [Setup]    Run Keywords    SISO Coam Test Setup
    Run Keyword If    ${tl.gnbs[0].instance_id} == 169    Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF_dingliUE
    ...    ELSE    Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF
    [Teardown]    Run Keywords    SISO Coam Test Teardown    AND    Check ulUPlaneFragmentation in BTSlog    AND    ERR check in BTSlog

[1]CB008941-SR-AA-B1_9_L3call_Loki_based_DU_with_UL_PRB_muting_active_PUSCH_mapping_typeB_with_SRS_FDBF
    [Tags]    CRT_UTE
    [Setup]    SISO Coam Test Setup
    L3call_Loki_based_DU_with_UL_PRB_muting_active_PUSCH_mapping_typeB_with_SRS_FDBF
    [Teardown]    Run Keywords    SISO Coam Test Teardown    AND    ERR check in BTSlog

[1]CB008941-SR-AA-B1_15_L3call_Loki_based_DU_with_short_PUCCH_FDBF
    [Tags]    CRT_UTE
    [Setup]    SISO Coam Test Setup
    L3call_Loki_based_DU_with_short_PUCCH_FDBF
    [Teardown]    Run Keywords    SISO Coam Test Teardown    AND    ERR check in BTSlog

[1]CB008941-SR-AA-B1_6_L3call_Loki_based_DU_with_UL_PRB_muting_inactive_FDBF
    [Tags]    CRT_UTE
    [Setup]    SISO Coam Test Setup
    L3call_Loki_based_DU_with_UL_PRB_muting_inactive_FDBF
    [Teardown]    Run Keywords    SISO Coam Test Teardown    AND    ERR check in BTSlog
