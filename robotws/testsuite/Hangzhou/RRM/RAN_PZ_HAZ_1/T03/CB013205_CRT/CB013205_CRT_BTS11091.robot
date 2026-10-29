*** Settings ***
Documentation
...   Author: zhuo.1.gao@nokia-sbell.com
...   Contact: zhuo.1.gao@nokia-sbell.com
...   Description: This user scenario describes

Resource          ../Resources/common_resource.robot
# Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Common MultiBTS Test Setup For RRM
Test Teardown     Common MultiBTS Test Teardown For RRM


#Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
#Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM

Force Tags
...      CRT             #Tag Item
...      RAN_VRF_HAZ_1             #Competence Area
...      RAN_VRF_HAZ_T06  #Organization
...      TA_LEVEL_23              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

*** Variables ***
# ${PA_MaxValue}           ${60}
# ${PA_NormalValue}        ${30}
${DEBUG_MODE}        ${TRUE}

*** Test Cases ***
CB013205_Case01_ Close the X2 link after S1 link down with single S1 link configured in eNB
    #[Tags]    QC_172870    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    FOR    ${index}    IN RANGE    1
        block_unblock_all_cells
        Sleep    5s
    END



*** Keywords ***
block_unblock_all_cells
    BTS Operation    operation=cell_block           product_type=gnb    bts_index=0    distname_id=NRCELL-ALL     need_verify=True
    BTS Operation    operation=cell_unblock         product_type=gnb    bts_index=0    distname_id=NRCELL-ALL     need_verify=True