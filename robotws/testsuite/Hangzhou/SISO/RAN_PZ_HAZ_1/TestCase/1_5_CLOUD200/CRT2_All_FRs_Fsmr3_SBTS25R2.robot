*** Settings ***
Documentation    Suite description
...    Author: amy.wu@nokia-sbell.com
...    Maintainer: Author

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Variables    ./env.py
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot

Force Tags    CLOUD_RF_FAA_CRT2_1032    CA_RAN_PZ_HAZ_1  CA_4G_SISOPZ  SBTS00  RAN_4G  RAN_4G_TDD  #CRT

Test Timeout    73h

*** Variables ***
${parameters}    [{"dist_name":"MRBTS-2282/LNBTS-2282/LNCEL-1","para_name":"Maximum output power","para_value":"40 (dBm)",
...    "require_reset":"online"},{"dist_name":"MRBTS-2282/LNBTS-2282/LNCEL-2","para_name":"Maximum output power","para_value":"40 (dBm)",
...    "require_reset":"online"}]

${online_commissioning}    [['MRBTS-2282/LNBTS-2282/LNCEL-1',['pMax','400']],
...    ['MRBTS-2282/LNBTS-2282/LNCEL-2',['pMax','400']]]

&{1_5_407}=    SM=L6133428848    RF=10YSV10E9004088|11BYU6TF8400455|11BYU6TF8400592    site_mode=4G
...    HW_ID=T222-L-407-8TX-8RX_20+10_27    ONAIR_TIME=15 min
&{1_5_407_iqc}=    SM=L6133428848    RF=10YSV10E9004088    site_mode=4G
...    HW_ID=T222-L-407-8TX-8RX_20+10_27    ONAIR_TIME=15 min

${KEY_PERFORM_HW_SETUP}=            True

${GLO_TL_DESCRIPTOR_FILE_PATH}=    ${CURDIR}/TLdescriptor.xml

${INIT_CONFIG_ID}=    1_5_407



*** Test Cases ***
Update To CMCC
    [Setup]    Testcase Basic Precondition    case_name=Update_To_CMCC    config_id=1_5_407
    Update To CMCC Package    cmcc_sw=SBTS00_FSM3_9999_240423_000002
    [Teardown]    Testcase Basic Postcondition

1UE ULDL Peak rate
    [Tags]    QC_138757    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Throughput    config_id=1_5_407
    [Timeout]    72h
    test_fv.Data Transfer
    [Teardown]    Testcase Basic Postcondition

SiSo_CM_Recommissioning_template
    [Tags]    QC_138758    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Recommissioning
    ${parameters}    Evaluate    ${parameters}
    Automated SiSo OnLine Parameters Commissioning    online_commissioning_tmp=${online_commissioning}
    [Teardown]    Testcase Basic Postcondition

SISO_Configuration_Throughput
    [Tags]    QC_138756    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Throughput    config_id=1_5_407_iqc
    [Timeout]    72h
    test_fv.Data Transfer
    [Teardown]    Testcase Basic Postcondition
