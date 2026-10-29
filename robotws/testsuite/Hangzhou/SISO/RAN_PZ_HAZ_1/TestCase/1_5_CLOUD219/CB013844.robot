*** Settings ***
Documentation    Suite description
...     Author:     xxx.yyy@nokia-sbell.com
...     Maintainer:   Author

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/reportportal.robot
#Resource    ../../resources/common_setup.robot
#Resource    ../../resources/test_fv.robot
Variables   ./env.py
Library    taf.sbts.oam.coam.admin    WITH NAME    coam

Force Tags         CA_RAN_PZ_HAZ_1    SBTS00

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition


*** Variables ***
#&{SCFC_CB013844}         HW_ID=AKHM     site_mode=4G5G    ONAIR_TIME=18 min
&{SCFC_CB013844_SBTS00}         HW_ID=AKHM     site_mode=4G5G    ONAIR_TIME=18 min
#&{SCFC_CB013844_2RET}      HW_ID=AKHM    site_mode=4G5G     ONAIR_TIME=16 min
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
#${INIT_CONFIG_ID}                SCFC_CB013844
${INIT_CONFIG_ID}                SCFC_CB013844_SBTS00
#${INIT_CONFIG_ID}              SCFC_CB013844_2RET
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}=  Unit power reset
...                         NgGnbInitFullReset
...                         System information broadcast parameters overflow
#...                         No module fan detected
...                         NgGnbInitPartialReset
...                         Xn SCTP setup fail
...                         No Xn link available
#...                         Cooling fan broken
#${extra_peak_rate_config}    {${pk1}${pk2}${pk3}}
##UUF4All
#${INIT_SW_VERSION}    {'37614': 'SBTS23R3_ENB_0000_000117_000000'}
#${TARGET_SW_VERSION}    {'37614': 'SBTS00_ENB_9999_230604_000016'}
#${middle_build}    {'37614': 'SBTS23R3_ENB_0000_000118_000000'}
#${RB_TO_TARGET}    YES # YES|NO
#${YAFT}    NO

${deltaDict1}     {'37614': '/home/ute/MN/UTE/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/TestCase/1_5_CLOUD219/AKHM_ADD_RET_Product.json'}
${deltaDict2}     {'37614': '/home/ute/MN/UTE/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/TestCase/1_5_CLOUD219/AKHM_RM_RET.json'}
${deltaDict3}     {'37614': '/home/ute/MN/UTE/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/TestCase/1_5_CLOUD219/AKHM_ADD_RET_NoProduct.json'}

*** Test Cases ***
#[1]CB013844_ALD_Configuration_Management_ALD_site_commissioning_and_HW_detection
#    [Tags]    QCD_MN_RAN      QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition       case_name=SiSo_DeltaFile_Recommissioning
#    SiSo DeltaFile Recommissioning1        deltaDict=${deltaDict1}
#    sleep     15s
#    SiSo DeltaFile Recommissioning1        deltaDict=${deltaDict2}
#    sleep     5s
#    [Teardown]    Testcase Basic Postcondition
#
#[2]SISO_Recovery RF module reset
#    [Tags]    QCD_MN_RAN      QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=rf_reset
#    SISO_Recovery RF module reset            required_power_rfs=1M243101201
#    [Teardown]    Testcase Basic Postcondition
#
[3]CB013844_ALD_Configuration_Management_ALD_site_commissioning_and_HW_detection
    [Tags]    QC_191138     QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition       case_name=SiSo_DeltaFile_Recommissioning
    SiSo DeltaFile Recommissioning1        deltaDict=${deltaDict3}
    sleep     5s
    [Teardown]    Testcase Basic Postcondition

*** Keywords ***
SiSo DeltaFile Recommissioning1
    [Arguments]    ${deltaDict}    #${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${ping}=${True}
    [Documentation]    Author:     lisa.ding@nokia-sbell.com
    ${deltaDict}      Evaluate    ${deltaDict}
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${deltafile}    Get From Dictionary    ${deltaDict}    ${bts_id}
        coam.Perform delta recommissioning    ${deltafile}    skip_parameter_relation_errors=True
        ...    connection=${CASE_NAME}_${bts_id}      timeout=600
        Create Node Parameters From Current SCF
    END
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Check Alarms
    Check Historical Alarms
#    Make L3call    ping=${ping}    required_cells=${required_cells}    extra_peak_rate_config=${extra_peak_rate_config}

#SISO_Recovery RF module reset
#    [Arguments]    ${required_power_rfs}=${EMPTY}    #${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
#    [Documentation]    Author:        amy.wu@nokia-sbell.com
#    ...                Maintainer:    amy.wu@nokia-sbell.com
#    ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
#    ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_power_rfs_list}
#    ${cell_cross_rru}    Check Is Cell Cross RRU
#    FOR    ${fr_serial_number}    IN    @{rf_list}
#        Radio Reset    ${fr_serial_number}
#    END
#    Check Multinode Without Unexpect Alarm
#    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
#    Run Keyword If    ${cell_cross_rru}
#    ...    Check Historical Alarms    additional_allowed_alarms=Transmission path failure:Tx Failure Turn Mimo Off
#    ...    ELSE    Check Historical Alarms
#    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
