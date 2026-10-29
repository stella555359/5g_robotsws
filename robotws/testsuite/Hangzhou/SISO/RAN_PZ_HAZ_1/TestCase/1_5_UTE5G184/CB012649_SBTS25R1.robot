*** Settings ***
#Force Tags
Documentation    Suite description
...    Author:        qing.2.he@nokia-sbell.com
...    Maintainer:    heqing

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/reportportal.robot
Variables   ./env.py
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Library     ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/kpiReporter.py
Library     ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/tools/common_tools.py
Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{CB012649_T2_8T8R_10M_90M}=    peak_rate_config={"401":[50,7.8],"402":[747,97]}
...   HW_ID=CB012649
...   site_mode=8T8R
...   ONAIR_TIME=15 min
&{CB012649_T22_4T4R_10M_20M}=    peak_rate_config={"401":[50,7.8],"402":[100,18],"403":[50,7.8],"404":[100,18]}
...   HW_ID=CB012649
...   site_mode=4T4R
...   ONAIR_TIME=15 min


${pk1}    "401":[64,7.8],"402":[373,48],"403":[64,7.8],"404":[373,48]
${pk2}    "405":[64,7.8],"406":[373,48],"407":[64,7.8],"408":[373,48]
&{CB012649_T2222_2T2R_10M_50M}=    peak_rate_config={${pk1},${pk2}}
...   HW_ID=CB012649
...   site_mode=2T2R
...   ONAIR_TIME=15 min

${pk3}    "401":[64,7.8],"402":[64,7.8],"403":[64,7.8],"404":[64,7.8]
${pk4}    "405":[64,7.8],"406":[64,7.8]
&{CB012649_T222_2T2Rmix4T4R_10M_10M}=    peak_rate_config={${pk3},${pk4}}
...   HW_ID=CB012649
...   site_mode=2T2R_4T4R
...   ONAIR_TIME=15 min

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}     CB012649_T2_8T8R_10M_90M
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitPartialReset    NgGnbInitFullReset
#${online_commissioning}    [['MRBTS-37039/LNBTS-37039/LNCEL-1/LNCEL_FDD-0',['dlChBw','10 MHz']],
#...                         ['MRBTS-37039/LNBTS-37039/LNCEL-1/LNCEL_FDD-0',['ulChBw','10 MHz']],
#...                         ['MRBTS-37039/LNBTS-37039/LNCEL-1',['actDownSampling','false']]]
#
#${prach_parameters}    [['MRBTS-37039/NRBTS-37039',['actAutoPrachConfigIndexFdd','true']],
#...                     ['MRBTS-37039/NRBTS-37039',['actAutoPrachConfigIndexFddEnh','true']]]


#${if_reporting_rep}    True
#${REP_COMMENT}    NFTA
#${GLO_PERFORM_SAVE_LOG}    ALWAYS
${REQUIRED_BTS_ID}    37512
${RB_TO_TARGET}    YES
${YAFT}    YES
*** Test Cases ***
[1][1] Common_SiSo_State Management_RF Lock & Unlock_with_RF Reset
    [Tags]    QC_83339  QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RFlock_with_RfReset        config_id=CB012649_T222_2T2Rmix4T4R_10M_10M
    Common_SiSo_State Management_RF Lock & Unlock_with_RF Reset
    [Teardown]    Testcase Basic Postcondition

[1] Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Tags]    QC_83341    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Teardown]    Testcase Basic Postcondition


[1][1.0] Common_SiSo_State Management_Cell block_Then_RF reset_Then_Cell unblock
    [Tags]    QC_83340    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call
    Cell Block And Unblock All with rfreset
    [Teardown]    Testcase Basic Postcondition

[1][1] Common_SiSo_Recovery_RF module reset_Then_BBMOD_reset
    [Tags]    QC_83343  QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RFReset_with_BBmodReset
    Common_SiSo_Recovery_RF module reset_Then_BBMOD_reset
    [Teardown]    Testcase Basic Postcondition

[1][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]    QC_83342    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=hwf
    [Timeout]    72h
    FOR    ${num}    IN RANGE    ${5}
        Site Reset with Remove Hwbin
    END
    [Teardown]    Testcase Basic Postcondition




