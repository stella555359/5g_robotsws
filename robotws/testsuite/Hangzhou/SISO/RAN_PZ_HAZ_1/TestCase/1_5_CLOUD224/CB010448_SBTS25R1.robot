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

Force Tags    CLOUD_5G_CLASSICAL_NSA_ASILL_ABIPB1_4XAHFIB    CA_RAN_PZ_HAZ_1    SBTS25R1    RAN_5G
...    RAN_5G_FDD    PY36

*** Variables ***

${pk1}    "102":[150,50],"103":[150,50],"104":[150,50],"105":[150,50],"106":[150,50],"107":[150,50]
${pk2}    "108":[150,50],"109":[150,50],"110":[150,50],"111":[150,50],"112":[150,50],"113":[150,50]
${pk3}    "114":[150,50],"115":[150,50],"116":[150,50],"117":[150,50],"118":[150,50],"119":[150,50]
${pk4}    "120":[150,50],"121":[150,50],"122":[150,50],"123":[150,50],"124":[150,50],"125":[150,50]
${pk5}    "126":[150,50],"127":[150,50],"128":[150,50],"129":[150,50],"130":[150,50],"131":[150,50]
${pk7}    "132":[150,50],"133":[150,50],"134":[150,50],"135":[150,50],"136":[150,50],"137":[150,50]
${pk6}    "0":[150,50],"1":[150,50],"2":[150,50],"3":[150,50],"4":[150,50],"5":[150,50]

${CELL_DIST_NAME}    MRBTS-11/LNBTS-11/LNCEL-0/LNCEL_FDD-0

${parameters}    [{"dist_name":"${CELL_DIST_NAME}","para_name":"Downlink channel bandwidth","para_value":"10MHz"},
...    [{"dist_name":"${CELL_DIST_NAME}","para_name":"Uplink channel bandwidth","para_value":"10MHz"},
...    [{"dist_name":"MRBTS-11/LNBTS-11/LNCEL-0","para_name":"Activate down sampling","para_value":"false"}]

&{CB010448_36cell}=    peak_rate_config={${pk1},${pk2},${pk3},${pk4},${pk5},${pk7}}
...    site_mode=4G    HW_ID=T33333333    ONAIR_TIME=15 min

&{CB010448_supercell}=    peak_rate_config={${pk6}}
...    site_mode=4G    HW_ID=T33333333    ONAIR_TIME=15 min

${KEY_PERFORM_HW_SETUP}=            True

${GLO_TL_DESCRIPTOR_FILE_PATH}=    ${CURDIR}/TLdescriptor_All.xml
#${INIT_CONFIG_ID}=    2_522CONF_CB008325_24cell
${INIT_CONFIG_ID}=    CB010448_36cell

${online_commissioning}    [['MRBTS-11/LNBTS-11/LNCEL-0/LNCEL_FDD-0',['dlChBw','10 MHz']],
...    ['MRBTS-11/LNBTS-11/LNCEL-0/LNCEL_FDD-0',['ulChBw','10 MHz']],
...    ['MRBTS-11/LNBTS-11/LNCEL-1/LNCEL_FDD-0',['dlChBw','15 MHz']],
...    ['MRBTS-11/LNBTS-11/LNCEL-1/LNCEL_FDD-0',['ulChBw','15 MHz']],
...    ['MRBTS-11/LNBTS-11/LNCEL-0',['actDownSampling','false']],
...    ['MRBTS-11/LNBTS-11/LNCEL-1',['actDownSampling','false']]]

*** Test Cases ***
#config3
[3][1]CB011005_Common_SiSo_L3 cache QoS support on Marlin
    [Tags]    QC_83857    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=CB010448_36cell
    Site Reset With L3 Cache QoS
    [Teardown]    Testcase Basic Postcondition

[3][1][1.0] Common_SiSo_State Management_Cell block & unblock
    [Tags]    QC_83856    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block_And_Unblock_with_loop    config_id=CB010448_36cell
    Cell Block And Unblock All loop 4 times
    [Teardown]    Testcase Basic Postcondition

[3][1][1.0] Common_SiSo_Recovery_BTS SiteReset
    [Tags]    QC_83853    QCD_MN_RAN    QCP_RAN_VRF
	[Setup]    Testcase Basic Precondition    case_name=reset    config_id=CB010448_36cell
    [Timeout]    72h
    Reset With Remove HWBIN KPI1
    [Teardown]    Testcase KPI postcondition    CaseType=RESET

[3] [1][1.0] General_SiSo_SBTS_reset_without_HWF_in_loop
    [Tags]    QC_83854    QCD_MN_RAN    QCP_RAN_VRF
	[Setup]    Testcase Basic Precondition    case_name=hwf    config_id=CB010448_36cell
    [Timeout]    72h
    FOR    ${num}    IN RANGE    ${5}
        Site Reset with Remove Hwbin
    END
    [Teardown]    Testcase Basic Postcondition

[3]SISO_Configuration1_Throughput
    [Tags]    QC_83858    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Throughput    config_id=CB010448_36cell
    test_fv.Data Transfer
    [Teardown]    Testcase Basic Postcondition

[3]Common_SiSo_Testability_Downlink Test Model
    [Tags]    QC_83855    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=test_model    config_id=CB010448_36cell
    Test_Dedicated_downlink
    [Teardown]    Testcase Basic Postcondition