*** Settings ***
Documentation     [PURPOSE]
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Force Tags        QCD_MN_RAN    QCP_RAN_VRF
Library       ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource    ../SWM/CB008313/CB008313_LTE655.robot
Resource    ../SWM/CB008313/CB008313_LTE655_05_09_Automatic_SW_Fallback.robot
Resource    ../SWM/CB007402/CB007402_ST_05_03_execute_upgradeCfgDataValidCheck_successful_from_Webem.robot
Resource    ../SWM/CB007402/CB007402_ST_02_03_upgradeCfgDataValidCheck_failed_on_Webem_remot_toll_when_PDL_err_exists.robot
Resource    ../SWM/CB007402/CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact.robot
Resource    ../SWM/CB007402/CB007402_ST_02_01_upgradeCfgDataValidCheck_failed_on_Netact_when_PDL_err_exists.robot
Resource    ../SWM/CB007402/CB007402_ST_05_07_execute_SW_fullcheck_on_Netact_before_and_after_SW_download_on_Dual_core.robot
Resource    ../SWM/CB007500/CB007500.robot


*** Variables ***
${target_release}    SBTS00
${TEMP_LOGS_DIR}    /tmp/logs/
${UE1}			SONY_XZ2
${UE2}			Nokia_8.3_5G
${LTE955_PASSED}    ${FALSE}
${bts_ip}=    10.97.97.135
${USERNAME}     Nemuadmin
${PASSWORD}=    nemuuser
${vdu_username}     Nemuadmin
${vdu_password}     N0kia@dmin56


*** Test Cases ***
CB008313_LTE4934-C_ST_05_16_ Flat SOAM_Software Management_SWM_rollback Software for multi-MRBTS
#The function case include three kpi check,1th is upload,2th is provision, 3th is rollback, the final step is rollback
#so choose rollback as the case name
    [Tags]    QC_33334   10_5_UTESRAN261    SWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    ...    AND    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006053
    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown

CB008313_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
# just kpi result fetch, to update QC
    [Tags]    QC_33335   10_5_UTESRAN261    SWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    ...    AND    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006053
    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown

CB008313_LTE655_05_09_Automatic_SW_Fallback
    [Tags]    QC_33336   10_5_UTESRAN261    SWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB008313_LTE655_05_09_Automatic_SW_Fallback
    ...    AND    TC Setup
    CB008313_LTE655_05_09_Automatic_SW_Fallback
    [Teardown]    TC Teardown

CB007402_ST_05_03_execute_upgradeCfgDataValidCheck_successful_from_Webem
    [Tags]    QC_33408    7402    10_5_UTESRAN261/264
    [Setup]    run keywords
    ...  Set Library Search Order
    ...  CB007402_ST_05_03_execute_upgradeCfgDataValidCheck_successful_from_Webem
    ...  AND    TC Setup
    TC_CB007402_ST_05_03_execute_upgradeCfgDataValidCheck_successful_from_Webem
    [Teardown]    TC Teardown

CB007402_ST_02_03_upgradeCfgDataValidCheck_failed_on_Webem_remot_toll_when_PDL_err_exists
    [Tags]    QC_33407    7402    10_5_UTESRAN261/264
    [Setup]    run keywords
    ...  Set Library Search Order
    ...  CB007402_ST_02_03_upgradeCfgDataValidCheck_failed_on_Webem_remot_toll_when_PDL_err_exists
    ...  AND    TC Setup
               TC_CB007402_ST_02_03_upgradeCfgDataValidCheck_failed_on_Webem_remot_toll_when_PDL_err_or_wrn_exists
    [Teardown]    TC Teardown

CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact
    [Tags]    QC_33406    7402    10_5_UTESRAN261/264
    [Setup]    run keywords
    ...  Set Library Search Order
    ...  CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact
    ...  AND    TC Setup
    TC_CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact
    [Teardown]    TC Teardown

CB007402_ST_02_01_upgradeCfgDataValidCheck_failed_on_Netact_when_PDL_err_exists
    [Tags]    QC_33405    7402    10_5_UTESRAN261/264
    [Setup]    run keywords
    ...  Set Library Search Order
    ...  CB007402_ST_02_01_upgradeCfgDataValidCheck_failed_on_Netact_when_PDL_err_exists
    ...  AND    TC Setup
    TC_CB007402_ST_02_01_upgradeCfgDataValidCheck_failed_on_Netact_when_PDL_err_exists
    [Teardown]    TC Teardown

CB007402_ST_05_07_execute_SW_fullcheck_on_Netact_before_and_after_SW_download_on_Dual_core
    [Tags]    QC_33404    7402    10_5_UTESRAN261/264
    [Setup]    run keywords
    ...  Set Library Search Order
    ...  CB007402_ST_05_07_execute_SW_fullcheck_on_Netact_before_and_after_SW_download_on_Dual_core
    ...  AND    TC Setup
    TC_CB007402_ST_05_07_execute_SW_fullcheck_on_Netact_before_and_after_SW_download_on_Dual_core
    [Teardown]    TC Teardown

CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    [Tags]    QC_33423    ASOE    10_5_UTESRAN615
    [Setup]    run keywords    set library search order    CB007500    AND    Common Test Setup
    [Timeout]    3600s
    CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    #CB007500_ST_05_01_PNP start with reset to D&RSW by GPS
    [Teardown]  ASIK TC teardown

CB007500_ST_05_02_PNP start with configuration reset to D&RSW by DHCP with siteID
    [Tags]    QC_33417      original:3_5_UTE4G502    1st:3_5_UTE4G243       prio-1
    [Setup]    run keywords    set library search order    CB007500    taf.sbts.oam.coam.admin     AND    TC Setup
    [Timeout]    3600s
    CB007500_ST_05_02_PNP start with configuration reset to D&RSW by DHCP with siteID
    [Teardown]  ASIK TC teardown
