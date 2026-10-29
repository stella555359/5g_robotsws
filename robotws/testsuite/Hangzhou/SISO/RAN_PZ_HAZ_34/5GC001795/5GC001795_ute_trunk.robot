# *** Settings ***
# Documentation    Author: xiaoxia.hao@nokia-sbell.com
# Suite Setup    702 Suite Setup For UTE
# Suite Teardown    702 Suite TearDown For UTE
# Force Tags            5G_RAN_TDD    STATE_SW_UPLOADED    master_classicalbts_all    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_2xAZQH
# ...    PY36
# ...           CRT_UTE    SBTS00    RAN_5G    RAN_5G_TDD
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
# *** Variables ***
# 
# *** Test Cases ***
# #[1][1.0] General_SiSo_RF_module_power_reset
# #    [Timeout]    420m
# #    [Setup]  702 Case SetUp For UTE
# #    General_SiSo_RF_module_power_reset.General_SiSo_RF_module_power_reset
# #    [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
# #[1][1.0] General_SiSo_RU_module_reset_from_GUI
# #    [Timeout]    45m
# #    [Setup]  702 Case SetUp For UTE
# #    General SiSo RU Module Reset From GUI
# #    [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
# #[1][1.0] General_SiSo_BTS_startup_with_RF_delayed_startup
# #    [Timeout]    45m
# #    [Setup]  702 Case SetUp For UTE
# #    RRH_common_keyword.General SiSo BTS Startup With RF Delayed Startup
# #    [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
# #[1]OAM_KPI_61a_SiSo_Auto_BTS_site_reset
# #    [Timeout]    400m
# #    [Setup]  702 Case SetUp For UTE
# #    OAM_KPI_Auto_BTS_site_reset
# #    [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
# #[1][1.0] General_SiSo_CPRI_link_configuration
# #    [Timeout]    45m
# #    [Setup]  702 Case SetUp For UTE
# #    General SiSo CPRI Link Configuration
# #    [Teardown]     702 Case TearDown For UTE
