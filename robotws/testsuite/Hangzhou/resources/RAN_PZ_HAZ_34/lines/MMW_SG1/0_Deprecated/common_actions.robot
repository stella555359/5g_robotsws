*** Settings ***
Force Tags    PY27
#Variables    /home/ute/Projects/testline_configuration/7_5_UTE5G402T254/__init__.py
#Variables    /home/ute/Project/testline_configuration/7_5_UTE5G402T049/__init__.py
#Variables    /home/ute/Projects/testline_configuration/7_5_UTE5G402T255/__init__.py

Resource    ../common_resources.robot

*** Test Cases ***
Start_ue_detach_before_CIT_CRT
    [Documentation]  Author: Ding Binmei
    ...              Description: This case is used to make sure that UE is in detach status before run CIT CRT cases
    ...                 WA for CA cases to avoid attach to other TDD cells
    ${UE_TYPE}    ue.translate_power_ue_type_from_testline
    Set suite variable    ${UE_TYPE}
    power_ue.Prepare UE    ue_type=${UE_TYPE}    detach_request=${False}
    Retry commercial ue detach if failed
    [Teardown]    Run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}


Check_all_cells_on_air
    [Documentation]    Author: Wu Rong
    ...              Description: The case is used to check cell on air after upgrade gNB and eNB build
    Connect to gnb coam via ssl
    COAM Wait for gnb ready and cell setup    is_need_to_setup_gnb_connection=${false}
    ...    is_x2_check_from_gnb_needed=${false}
    [Teardown]    Run keywords    COAM Teardown gnb connections
