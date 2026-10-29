*** Settings ***
Documentation    Suite description
...    Author: ling.qin@nokia.com
...    Maintainer: Author

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Variables    ./env.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot

Force Tags    CLOUD_5G_CLASSICAL_NSA_ASILL_ABIPB1_4XAHFIB    CA_RAN_PZ_HAZ_1    SBTS25R2    RAN_5G
...    RAN_5G_FDD    PY36

*** Variables ***

${pk1}    "102":[150,50],"103":[150,50],"104":[150,50],"105":[150,50],"106":[150,50],"107":[150,50]
${pk2}    "108":[150,50],"109":[150,50],"110":[150,50],"111":[150,50],"112":[150,50],"113":[150,50]
${pk3}    "114":[150,50],"115":[150,50],"116":[150,50],"117":[150,50],"118":[150,50],"119":[150,50]
${pk4}    "120":[150,50],"121":[150,50],"122":[150,50],"123":[150,50],"124":[150,50],"125":[150,50]
${pk5}    "126":[150,50],"127":[150,50],"128":[150,50],"129":[150,50],"130":[150,50],"131":[150,50]
${pk7}    "132":[150,50],"133":[150,50],"134":[150,50],"135":[150,50],"136":[150,50],"137":[150,50]
${pk6}    "0":[150,50],"1":[150,50],"2":[150,50],"3":[150,50],"4":[150,50],"5":[150,50]
&{CB010448_36cell}=    peak_rate_config={${pk1},${pk2},${pk3},${pk4},${pk5},${pk7}}
...    site_mode=4G    HW_ID=T33333333    ONAIR_TIME=15 min
${KEY_PERFORM_HW_SETUP}=            True
${GLO_TL_DESCRIPTOR_FILE_PATH}=    ${CURDIR}/TLdescriptor_All.xml
${INIT_CONFIG_ID}=    CB010448_36cell

*** Test Cases ***
[3][1][1.0] Common_SiSo_Recovery_BTS SiteReset
    [Tags]    QC_216204    QCD_MN_RAN    QCP_RAN_VRF
	[Setup]    Testcase Basic Precondition    case_name=reset    config_id=CB010448_36cell
    [Timeout]    72h
    Reset With Remove HWBIN KPI1
    [Teardown]    Testcase KPI postcondition    CaseType=RESET

[3]SISO_Configuration1_Throughput
    [Tags]    QC_216205    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Throughput    config_id=CB010448_36cell
    test_fv.Data Transfer
    [Teardown]    Testcase Basic Postcondition