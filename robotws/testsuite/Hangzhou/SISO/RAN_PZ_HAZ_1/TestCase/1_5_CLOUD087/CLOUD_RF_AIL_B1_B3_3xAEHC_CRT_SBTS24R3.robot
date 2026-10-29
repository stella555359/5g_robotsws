*** Settings ***
Documentation    Suite description
...    Author:        lisa.ding@nokia-sbell.com
...    Maintainer:    Lisa Ding

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables   ./env.py

Force Tags    CLOUD_RF_AIL_B1_B3_3xAEHC_B    CA_RAN_PZ_HAZ_1    SBTS24R3    RAN_5G    RAN_5G_TDD

Test Timeout      73h

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${pk1}    "1":[110,9],"2":[110,9],"3":[110,9],
${pk2}    "4":[110,9],"5":[110,9],"6":[110,9],
${PK3}    "7":[110,9],"8":[110,9],"9":[110,9]
&{3EAHC_S333}=        HW_ID=3EAHC_S333        ONAIR_TIME=20 min        site_mode=4G
...    peak_rate_config={${pk1}${pk2}${pk3}}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${extra_peak_rate_config}    {${pk1}${pk2}${pk3}}

*** Test Cases ***

[1][1.0] Data Transfer
    [Tags]    QC_847892    QCD_MN_RAN  QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=3EAHC_S333
    test_fv.Data Transfer
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Ru Lock And Unlock
    [Tags]    QC_847891    QCD_MN_RAN  QCP_RAN_ST
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Setup]    Testcase Basic Precondition    case_name=Ru_Lock_And_Unlock    config_id=3EAHC_S333
    Ru lock And Unlock All    extra_peak_rate_config=${extra_peak_rate_config}
    [Teardown]    Testcase Basic Postcondition

