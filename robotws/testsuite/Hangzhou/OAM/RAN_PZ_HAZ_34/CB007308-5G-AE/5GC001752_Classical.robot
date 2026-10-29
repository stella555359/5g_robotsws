# *** Settings ***
# Documentation      author: Lixia Wang
# ...                 contact: lixia.wang@nokia-sbell.com
# ...                 These cases are testing 5G20B feature 5GC001752 Zero Touch Commissioning UI for 5G NB for classical Part
# ...                 There are four parts in BTS startup view, Transport, Configuration, Hardware and Cells.
# ...                 These cases are to check the content of startup view is aligned with current gnb state/configuration.
# ...                 Test case does not require special test configuration.
# Suite Setup       Setup Suite
# Suite Teardown    Teardown Suite
# Force Tags                SG_01
# ...    PY36
# Resource          ../5GC001752/Resource/5GC001752_Classical.robot
# *** Test Cases ***
# [1][1.0] 5GC001752_001_BTS_EM_displays_BTS_Startup_View_with_Classical_and_SA_Mode
#     [Documentation]  This is common case to verify startup view contents are aligned with current gnb state/configuration.
#     ...             For SA mode(gNbCuType=SA or both), the state of Connection to the CU is NA.
#     ...    The state of Connection to 5G Core is algined with NG LINK state
#     [Tags]     CRT_TRUNK    CRT_20B   CRT_21A   CRT_21B  CRT_22R1
#     [Setup]    Setup Case
#     [Teardown]  Teardown Case
#      TC.5GC001752_001_BTS_EM_displays_BTS_Startup_View_with_Classical_and_SA_Mode
# 
# [1][1.0] 5GC001752_007_Startup_View_is_Auto-opening_by_the_BTS_EM_Application
#     [Documentation]  This case is to check startup view is prompted out after resetting site.
#     [Tags]    CRT_TRUNK    CRT_20B   CRT_21A   CRT_21B   CRT_22R1
#     [Setup]  Setup Case
#     [Teardown]  Teardown Case
#     TC.5GC001752_007_Startup_View_is_Auto-opening_by_the_BTS_EM_Application
# 
# [1][1.0] 5GC001752_002_BTS_EM_displays_BTS_Startup_View_with_Classical_and_NSA_Mode
#     [Documentation]  This case is to check startup view is transport view when gnb in NSA mode
#     [Tags]
#     [Setup]  Setup Case
#     [Teardown]  Teardown Case
#     TC.5GC001752_002_BTS_EM_displays_BTS_Startup_View_with_Classical_and_NSA_Mode
# 
# [1][1.0] 5GC001752_003_Show_Transport_Status_in_BTS_Startup_View
#     [Documentation]  This case is to check transport part in startup view either gnb in NSA or SA mode
#     [Tags]
#     [Setup]  Setup Case
#     [Teardown]  Teardown Case
#     TC.5GC001752_003_Show_Transport_Status_in_BTS_Startup_View
# 
# [1][1.0] 5GC001752_004_Show_Configuration_Status_in_BTS_Startup_View
#     [Documentation]  This case is to check Configuration status in startup view either gnb in NSA or SA mode
#     [Tags]
#     [Setup]  Setup Case
#     [Teardown]  Teardown Case
#     TC.5GC001752_004_Show_Configuration_Status_in_BTS_Startup_View
# 
# [1][1.0] 5GC001752_005_Show_HW_Status_in_BTS_Startup_View
#     [Documentation]  This case is to check hardware inforamtion in startup view either gnb in NSA or SA mode
#     [Tags]
#     [Setup]  Setup Case
#     [Teardown]  Teardown Case
#     TC.5GC001752_005_Show_HW_Status_in_BTS_Startup_View
# 
# [1][1.0] 5GC001752_006_Show_Cell_Status_in_BTS_Startup_View
#     [Documentation]  This case is to check cells inforamtion in startup view either gnb in NSA or SA mode
#     [Tags]
#     [Setup]  Setup Case
#     [Teardown]  Teardown Case
#     TC.5GC001752_006_Show_Cell_Status_in_BTS_Startup_View
# 
# *** Keywords ***
# Setup Suite
#     TestSuite.Start
# Teardown Suite
#     TestSuite.Stop