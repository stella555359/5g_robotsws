*** Settings ***
Documentation
...    Author: Du Ning
...    Contact: ning.du@nokia-sbell.com
...    This is a testing case to verify the functions of modules.

Resource                ../Module.robot
Resource                ../../../../RRM/RAN_PZ_HAZ_1/Resources/Classical/RRM_MultiBTS_Common_Resource.robot

Suite Setup             Common MultiBTS Suite Setup For RRM
Test Setup              Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
Test Teardown           Common MultiBTS Test Teardown For RRM
Suite Teardown          Common MutliBTS Suite Teardown For RRM


Force Tags              RAN_5G
Test Timeout            120 minutes

*** Variables ***
${SCF_Foler}            /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test/Parameter_Operation_SCF/

*** Test Cases ***
T01_Parameter_Operation_Test_Operation_Typing_Error
    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=asdf   product_type=gnb
    Log To Console    \nOutput is: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

T02_Parameter_Operation_Test_Delta_Plan_Delta_File_Path_Missing
    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=delta_plan_update   product_type=gnb
    Log To Console    \nGNB delta plan update result: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

T03_Parameter_Operation_Test_Delta_Plan_Delta_File_Path_Wrong
    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                                                                delta_file_path=${SCF_Foler}gxx_delta_plan_true.xml
    Log To Console    \nGNB delta plan update result: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

T04_Parameter_Operation_Test_Scf_File_Path_Missing
    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=full_commission   product_type=gnb
    Log To Console    \nGNB delta plan update result: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

T05_Parameter_Operation_Test_Scf_File_Path_Wrong
    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=full_commission   product_type=gnb
    ...                                                                                delta_file_path=${SCF_Foler}gxx_scf_true.xml
    Log To Console    \nGNB delta plan update result: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

T06_Parameter_Operation_Delta_Plan_Update
    @{para_list}    Create List    actCDrx    actCDrxVoNR    actEnhancedVoNR    actVoNR
    @{mo_list_gnb}    Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ...                              MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1

    ${out}    Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list_gnb}
    Log To Console    \nGNB Parameter Check Result: ${out}
    ${out}    Parameter Operation    operation=delta_plan_update   product_type=gnb    delta_file_path=${SCF_Foler}gnb_delta_plan_true.json
    Log To Console    \nGNB delta plan update result: ${out}
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list_gnb}
    Log To Console    \nGNB Parameter Check Result: ${out}

    Sleep    20s

    ${out}    Parameter Operation    operation=delta_plan_update   product_type=gnb    delta_file_path=${SCF_Foler}gnb_delta_plan_false.json
    Log To Console    \nGNB delta plan update result: ${out}
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list_gnb}
    Log To Console    \nGNB Parameter Check Result: ${out}

T07_Parameter_Operation_Parameter_Update
    @{para_list}    Create List    actCDrx    actCDrxVoNR    actEnhancedVoNR    actVoNR
    @{mo_list_gnb}    Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ...                              MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    @{value_list_true}    Create List    true    true    true    true
    @{value_list_false}    Create List    false    false    false    false

    ${out}    Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list_gnb}
    Log To Console    \nGNB Parameter Check Result: ${out}

    ${out}    Parameter Operation    operation=parameter_update   product_type=gnb
    ...                              para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_gnb}

    ${out}    Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list_gnb}
    Log To Console    \nGNB Parameter Check Result: ${out}

    ${out}    Parameter Operation    operation=parameter_update   product_type=gnb
    ...                              para_list=@{para_list}    value_list=@{value_list_false}    mo_list=@{mo_list_gnb}

    ${out}    Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list_gnb}
    Log To Console    \nGNB Parameter Check Result: ${out}

# T08_Parameter_Operation_Modify_List (NOT SUPPORT List NIDD MODIFICATION)
#     # List参数和简单参数混合修改（第二项为List参数）
#     @{para_list}          Create List    btsName    refNrCellGroup/1
#     @{value_list}         Create List    test_10868_bstname    1
#     @{mo_list}            Create List    MRBTS-1    MRBTS-1/NRBTS-1/NRDU-1

#     ${out}                Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list}
#     Log To Console        \nGNB Parameter Check Result: ${out}

#     ${res}                Parameter Operation    operation=parameter_update    product_type=gnb
#     ...                                          para_list=${para_list}    value_list=${value_list}    mo_list=${mo_list}
#     Log To Console        GNB paramter update result: ${res}

#     ${out}                Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list}
#     Log To Console        \nGNB Parameter Check Result: ${out}

T09_Parameter_Operation_Modify_Staged
    # Staged参数修改
    @{para_list}          Create List    prachConfigurationIndex
    @{value_list}         Create List    89
    @{mo_list}            Create List    MRBTS-1/NRBTS-1/NRCELL-1

    ${out}                Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console        \nGNB Parameter Check Result: ${out}

    ${res}                Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                          para_list=${para_list}    value_list=${value_list}    mo_list=${mo_list}
    Log To Console        GNB paramter update result: ${res}

    ${out}                Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console        \nGNB Parameter Check Result: ${out}

T10_Parameter_Operation_Modify_Random
    # 简单参数修改，目标值为给出的多个值中随机选择
    @{para_list}          Create List    btsName
    @{value_list}         Create List    CU_10868_077+CU_10868_033+CU_10868_022
    @{mo_list}            Create List    MRBTS-1

    ${out}                Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console        \nGNB Parameter Check Result: ${out}

    ${res}                Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                          para_list=${para_list}    value_list=${value_list}    mo_list=${mo_list}
    Log To Console        GNB paramter update result: ${res}

    ${out}                Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console        \nGNB Parameter Check Result: ${out}

T11_Parameter_Operation_Full_Commission
    @{para_list}    Create List    actCDrx    actCDrxVoNR    actEnhancedVoNR    actVoNR
    @{mo_list_gnb}    Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ...                              MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1

    ${out}    Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list_gnb}
    Log To Console    \nGNB Parameter Check Result: ${out}

    ${out}    Parameter Operation    operation=full_commission   product_type=gnb    scf_path=${SCF_Foler}gnb_scf_true.xml
    Log To Console    \nGNB scf commission result: ${out}

    ${out}    Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list_gnb}
    Log To Console    \nGNB Parameter Check Result: ${out}

    ${out}    Parameter Operation    operation=full_commission   product_type=gnb    scf_path=${SCF_Foler}gnb_scf.xml
    Log To Console    \nGNB scf commission result: ${out}

    ${out}    Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list_gnb}
    Log To Console    \nGNB Parameter Check Result: ${out}


