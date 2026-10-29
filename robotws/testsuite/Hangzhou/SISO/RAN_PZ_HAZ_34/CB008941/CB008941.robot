# *** Settings ***
# Suite Setup    run keywords    SISO Coam Suite Setup    AND    Modify Swconfig File    swconfig_path=${CURDIR}/Resources/swconfig_new.txt
# Suite Teardown    run keywords    Modify Swconfig File    swconfig_path=${CURDIR}/Resources/swconfig_old.txt    AND    SISO Coam Suite Teardown
# Test Setup    SISO Coam Test Setup
# Test Teardown    SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource     Resources/CB008941_common_keyword.robot
# 
# Documentation
# ...    Author: jiangjing.lin
# ...    Contact: jiangjing.lin@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB008941
# 
# Force Tags            RAN_5G_TDD    5G_RAN_TDD    SBTS00    RAN_5G    5G_RAN    CRT_UTE	   STATE_SW_UPLOADED
# ...   PY36
# ...    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQN_5GC002374
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB008941-SR-AA-1_Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF
#     Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF-AA-1
# 
# [1]CB008941-SR-AA-8_L3call_Loki_based_DU_with_short_PUCCH_FDBF
#     L3call_Loki_based_DU_with_short_PUCCH_FDBF-AA-8
# 
# [1]CB008941-SR-AB-1_Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF
#     Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF-AB-1
# 
# [1]CB008941-SR-AB-8_L3call_Loki_based_DU_with_short_PUCCH_FDBF
#     L3call_Loki_based_DU_with_short_PUCCH_FDBF-AB-8
