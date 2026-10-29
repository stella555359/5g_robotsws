*** Settings ***
Documentation    Suite description
...    Author:        weilong@nokia-sbell@nokia-sbell.com
...    Maintainer:    Zhou Weilong

Library    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/kpiReporter.py
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/reportportal.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables    ./env.py

Variables    ./env.py

Force Tags  CA_RAN_PZ_HAZ_1  SBTS00  RAN_5G


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${peak_rate}    "112":[140,60],"111":[140,60],
...             "211":[140,60],"212":[70,34]
${peak_rate1}    "211":[140,60],"212":[140,60],
...              "213":[70,30],"214":[70,30],"215":[70,30]
&{AHEK_5cc}=    HW_ID=CTC    site_mode=5G_4G     ONAIR_TIME=15 min
...									peak_rate_config={${peak_rate}}
&{AHEK_5cc_LTE_only}=    HW_ID=CTC    site_mode=5G_4G     ONAIR_TIME=15 min
...									peak_rate_config={${peak_rate1}}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${GLO_PERFORM_SAVE_LOG}    FAIL
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}
${INIT_CONFIG_ID}    AHEK_5cc
${if_reporting_rep}      True
${REP_COMMENT}      NFTA
${CALL_STRATEGY}  New Feature
*** Test Cases ***
#Test
#    ute_ue.require ue    ue_alias=UE_0    capabilities=AT_CMD_UE
#

[1] Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Tags]    QC_175157    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    ...    config_id=AHEK_5cc
    Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
#    Make L3Call     required_cells=112:111:211:212
    [Teardown]    Testcase Basic Postcondition
#
[2] Common_SiSo_State Management_Cell block_Then_RF reset_Then_Cell unblock
    [Tags]    QC_175158  	QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=cell_block_RF_reset_Cell_unblock
    Cell Block And Unblock All with rfreset
    [Teardown]    Testcase Basic Postcondition

[3] Common_SiSo_State Management_RF Lock & Unlock_with_BTS Reset
    [Tags]    QC_175159    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF lock And Unlock with BTS Reset
    RF lock And Unlock with BTS Reset
    [Teardown]    Testcase Basic Postcondition

[4] Data Transfer
    [Tags]    QC_175160     QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call
    #Make L3Call     required_cells=181:182:184:186
    test_fv.Data Transfer
#    Set Test Variable    ${GLO_TL_DESCRIPTOR_FILE_PATH}    ${GLO_4G_TL_DESCRIPTOR_FILE_PATH}
#    test_fv.Data Transfer    required_cells=182:184:186
#    #Online Unbar All Cells
    #Make L3Call     required_cells=131:132:133
    [Teardown]    Testcase Basic Postcondition


[5]Data Transfer
    [Tags]    QC_226590     QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call      config_id=AHEK_5cc_LTE_only
    test_fv.Data Transfer
    [Teardown]    Testcase Basic Postcondition



#[5]l3 call with lte GB
#    [Tags]    QC_175155     QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=L3call      #config_id=AHEK_5cc_LTE_GB
##    Make L3Call
#    [Teardown]    Testcase Basic Postcondition


[6][1.0] Explore case
    [Tags]    QC_175161    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Tput      config_id=config_id=AHEK_5cc
    Explore case1
    [Teardown]    Testcase Basic Postcondition


*** Keywords ***
Explore case1
       BTS Operation    operation=rat_reset      product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=False
       ...    reset_type=Hard
        sleep    5min
        BTS Operation    operation=cell_lock              product_type=gnb    bts_index=0    distname_id=NRCELL-ALL           need_verify=False
        sleep    5min
        BTS Operation    operation=cell_unlock              product_type=gnb    bts_index=0    distname_id=NRCELL-ALL         need_verify=False
        sleep    5min
        BTS Operation    operation=cell_lock              product_type=gnb    bts_index=0    distname_id=LNCELL-ALL           need_verify=False
        sleep    5min
        BTS Operation    operation=cell_unlock              product_type=gnb    bts_index=0    distname_id=LNCELL-ALL          need_verify=False
        Wait For All Cells OnAir
        Verify HW State
        Check Alarms
        Make L3Call     required_cells=211:212
