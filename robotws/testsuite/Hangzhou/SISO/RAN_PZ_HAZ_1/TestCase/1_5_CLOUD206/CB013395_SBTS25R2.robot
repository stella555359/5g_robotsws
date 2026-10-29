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
${pk1}    "41":[60,30],"42":[60,30],"43":[60,30],"44":[140,80],"45":[140,80],"46":[140,80],"47":[95,56],"48":[95,56],"49":[95,56]
${pk2}    "144":[55,69],"145":[17,8],"146":[55,69]
${pk3}    "147":[17,8],"148":[140,80],"148":[17,8],"150":[17,7],"151":[17,7],"152":[17,7]

#${pk1}    "41":[60,35],"42":[60,35],"43":[60,35],"44":[140,80],"45":[140,80],"46":[140,80],"47":[95,60],"48":[95,60],"49":[95,60]
#${pk2}    "141":[5,2.5],"142":[5,2.5],"143":[5,2.5],"144":[140,80],"145":[17,8],"146":[140,80]
#${pk3}    "147":[17,8],"148":[140,80],"148":[17,8],"150":[17,8],"151":[17,8],"152":[17,8]
&{CB013395_D1_tput_pure_3M}=    peak_rate_config={${pk1},${pk2},${pk3}}
...   HW_ID=CB013395
...   site_mode=4T4R
...   ONAIR_TIME=15 min

&{CB013395_D2_TPUT_OK}=    peak_rate_config={${pk1},${pk2},${pk3}}
...   HW_ID=CB013395
...   site_mode=4T4R
...   ONAIR_TIME=15 min

&{CB013395_D1_tput_3_14M_MIX}=    peak_rate_config={${pk1},${pk2},${pk3}}
...   HW_ID=CB013395
...   site_mode=4T4R
...   ONAIR_TIME=15 min
${online_commissioning}    [['MRBTS-37646/NRBTS-37646/NRCELL-5/NRCELL_FDD-1',['chBwDl','10MHz']],
...                         ['MRBTS-37646/NRBTS-37646/NRCELL-5/NRCELL_FDD-1',['chBwUl','10MHz']],
...                         ['MRBTS-37646/NRBTS-37646/NRCELL-5',['actDownSampling','false']]]
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}     CB013395_D1_tput_3_14M_MIX
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitPartialReset    NgGnbInitFullReset     IP Traffic Capacity Limit

#${if_reporting_rep}    True
#${REP_COMMENT}    NFTA
${REQUIRED_BTS_ID}    37646
${RB_TO_TARGET}    YES
${YAFT}    YES
*** Test Cases ***
[1.0] General_SiSo_RAT_Reset
    [Tags]    QC_146144    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=LTE_RAT_reset_from_WebEm       config_id=CB013395_D1_tput_3_14M_MIX
    RAT reset from WebEm For LTE testline
    ...       required_cells=41:42:43:45:46:47:48:49:144:145:146:147:148:149:150:151:152
	RAT reset from WebEm For NR testline
    ...       required_cells=41:42:43:45:46:47:48:49:144:145:146:147:148:149:150:151:152
    [Teardown]    Testcase Basic Postcondition

[1] General_SiSo_RAT_hard_Reset
    [Tags]    QC_146143   QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RAT_hard_reset_from_WebEm
    BTS Operation    operation=rat_reset       product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=yes
    ...    reset_type=Hard
    sleep    10s
    BTS Operation    operation=rat_reset       product_type=gnb    bts_index=0    distname_id=LNCEL-ALL    need_verify=yes
    ...    reset_type=Hard
    sleep    10s
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR
    Wait For All Cells OnAir
    Check Alarms
    Check Historical Alarms
    Make L3call
    ...       required_cells=41:42:43:45:46:47:48:49:144:145:146:147:148:149:150:151:152
    [Teardown]    Testcase Basic Postcondition


[1][1] Common_SiSo_State Management_RF Lock & Unlock_with_RF Reset
    [Tags]    QC_146137  QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RFlock_with_RfReset
    Common_SiSo_State Management_RF Lock & Unlock_with_RF Reset
    ...       required_cells=41:42:43:45:46:47:48:49:144:145:146:147:148:149:150:151:152
    [Teardown]    Testcase Basic Postcondition

[1][1]Common_SiSo_State Management_Block & Unblock cell_Then_ RF lock & unlock
    [Tags]    QC_188658  QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF lock And Unlock with cell block
    Common_SiSo_State Management_Block & Unblock cell_Then_ RF lock & unlock
    ...       required_cells=41:42:43:45:46:47:48:49:144:145:146:147:148:149:150:151:152
    [Teardown]    Testcase Basic Postcondition


[1][1.0] Common_SiSo_State Management_Cell block_Then_RF reset_Then_Cell unblock
    [Tags]    QC_146139    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Cell block_Then_RF reset_Then_Cell unblock
    Cell Block And Unblock All with rfreset
    ...       required_cells=41:42:43:45:46:47:48:49:144:145:146:147:148:149:150:151:152
    [Teardown]    Testcase Basic Postcondition


[1][1]RF lock And Unlock with BTS Reset
    [Tags]    QC_188659    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF lock And Unlock with BTS Reset
    RF lock And Unlock with BTS Reset
    ...       required_cells=41:42:43:45:46:47:48:49:144:145:146:147:148:149:150:151:152
    [Teardown]    Testcase Basic Postcondition


[1][1] Automated SiSo OnLine Parameters delta Commissioning
    [Tags]    QC_188657    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=delta Commissioning
    Automated SiSo OnLine Parameters Commissioning
    ...       required_cells=41:42:43:45:47:48:49:144:145:146:147:148:149:150:151:152
    [Teardown]    Testcase Basic Postcondition
