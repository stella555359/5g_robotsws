*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot
Library           ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/FCT_Excel.py

*** Keywords ***
CM__CB009451-E_001_Installing_New_FCT_Tool_Version_To_The_FCE_In_Online_WebEM
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   New case for TA_RAN_ST_CB009451-E_001_CM_Installing new FCT tool version to the FCE in online WebEM
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.06.2023 - New case

    Set Tags    CM    UI    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Install Mismatched FCT Package Failed
    Step 2: Install Matched FCT Package Success
    Step 3: Install Last Or Middle Higher FCT Package Success
    Step 4: Install First Higher FCT Package Without Obsolete Success
    Step 5: Install First Higher FCT Package With Obsolete Success
    Step 6: Check Installed FCT Detail Info

Step ${index}: Install Mismatched FCT Package Failed
    Log    Step ${index}: Install Mismatched FCT Package Failed    console=True
    ${Sub_Version_Fst}    Convert To Integer    ${FCT_Version_List[0]}
    ${FCT_Version_New1}    Set Variable	${Sub_Version_Fst-1}.${FCT_Version_List[1]}.${FCT_Version_List[2]}
    ${New_FileName}    FCT_Excel.make_mismatch_FCT
    ...    ${Test Results Dir}/TestFiles/FCT_Files/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    Version    ${FCT_Version_New1}
    log    ${New_FileName}
    ${error}    Install FCT On WebEM CA    ${New_FileName}
    Should Be Equal As Strings    ${error}
    ...    FCT installing process is terminated. The supported adaptation versions of the FCT do not align with the BTS version!

Step ${index}: Install Matched FCT Package Success
    Log    Step ${index}: Install Matched FCT Package Success    console=True
    ${Param_Value_Dic}    Create Dictionary    Tool Name=PUCCH_Config_Recommendations    Abbreviated Tool Name=PUCCH
    ${New_FileName}    FCT_Excel.update_parameters
    ...    ${Test Results Dir}/TestFiles/FCT_Files/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    ${Param_Value_Dic}
    log    ${New_FileName}
    Install FCT On WebEM CA    ${New_FileName}
    ${feature_list}    Get Feature List From WebEM CA
    ${feature_len}    Get Length    ${feature_list}
    Should Be Equal As Integers    ${feature_len}    4
    List Should Contain Value    ${feature_list}    ${FCT_Info["Tool Name"]}_${FCT_Version}  #PDCCH_4.2.0
    List Should Contain Value    ${feature_list}    PUCCH_Config_Recommendations_${FCT_Version}  #PUCCH_4.2.0

Step ${index}: Install Last Or Middle Higher FCT Package Success
    Log    Step ${index}: Install Last Or Middle Higher FCT Package Success    console=True
    ${Sub_Version_Mid}    Convert To Integer    ${FCT_Version_List[1]}
    ${Sub_Version_Last}    Convert To Integer    ${FCT_Version_List[2]}
    ${index}    Evaluate    random.randint(0,1)    modules=random, sys
    ${FCT_Version_New2}    Set Variable If	   ${index}==${0}    ${FCT_Version_List[0]}.${Sub_Version_Mid+1}.${FCT_Version_List[2]}
    ...    ${FCT_Version_List[0]}.${FCT_Version_List[1]}.${Sub_Version_Last+1}
    ${Param_Value_Dic}    Create Dictionary    Version=${FCT_Version_New2}
    ${New_FileName}    FCT_Excel.update_parameters
    ...    ${Test Results Dir}/TestFiles/FCT_Files/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    ${Param_Value_Dic}
    log    ${New_FileName}
    Install FCT On WebEM CA    ${New_FileName}
    ${feature_list}    Get Feature List From WebEM CA
    ${feature_len}    Get Length    ${feature_list}
    Should Be Equal As Integers    ${feature_len}    4
    List Should Contain Value    ${feature_list}    ${FCT_Info["Tool Name"]}_${FCT_Version_New2}  #PDCCH_4.2.1 or PDCCH_4.3.0
    List Should Contain Value    ${feature_list}    PUCCH_Config_Recommendations_${FCT_Version}   #PUCCH_4.2.0
    Set Test Variable    ${FCT_Version_New2}

Step ${index}: Install First Higher FCT Package Without Obsolete Success
    Log    Step ${index}: Install First Higher FCT Package Without Obsolete Success    console=True
    ${Sub_Version_Fst}    Convert To Integer    ${FCT_Version_List[0]}
    ${FCT_Version_New3}    Set Variable	${Sub_Version_Fst+1}.${FCT_Version_List[1]}.${FCT_Version_List[2]}
    ${Param_Value_Dic}    Create Dictionary    Version=${FCT_Version_New3}
    ${New_FileName}    FCT_Excel.update_parameters
    ...    ${Test Results Dir}/TestFiles/FCT_Files/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    ${Param_Value_Dic}
    log    ${New_FileName}
    Install FCT On WebEM CA    ${New_FileName}
    ${feature_list}    Get Feature List From WebEM CA
    ${feature_len}    Get Length    ${feature_list}
    Should Be Equal As Integers    ${feature_len}    5
    List Should Contain Value    ${feature_list}    ${FCT_Info["Tool Name"]}_${FCT_Version_New2}  #PDCCH_4.2.1 or PDCCH_4.3.0
    List Should Contain Value    ${feature_list}    ${FCT_Info["Tool Name"]}_${FCT_Version_New3}  #PDCCH_5.2.0
    List Should Contain Value    ${feature_list}    PUCCH_Config_Recommendations_${FCT_Version}   #PUCCH_4.2.0
    Set Test Variable    ${FCT_Version_New3}

Step ${index}: Install First Higher FCT Package With Obsolete Success
    Log    Step ${index}: Install First Higher FCT Package With Obsolete Success    console=True
    ${Sub_Version_Fst}    Convert To Integer    ${FCT_Version_List[0]}
    ${FCT_Version_New4}    Set Variable	${Sub_Version_Fst+2}.${FCT_Version_List[1]}.${FCT_Version_List[2]}
    ${Param_Value_Dic}    Create Dictionary    Version=${FCT_Version_New4}    #Obsoletes version(s) :=5.2.0
    #${New_FileName}    FCT_Excel.update_parameters
    #...    ${Test Results Dir}/TestFiles/FCT_Files/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    ${Param_Value_Dic}
    #log    ${New_FileName}
    #${New_FileName}    FCT_Excel.add_obsolete    ${New_FileName}    GENERAL-METADATA    ${FCT_Info["Abbreviated Tool Name"]}    ${Sub_Version_Fst+1}
    #log    ${New_FileName}
    #${New_FileName}    FCT_Excel.update_with_obsolete    ${TEST_LOG_DIRECTORY}/FCT_Files/FCT_PDCCH_MultiRelease.xlsx
    ${New_FileName}    FCT_Excel.update_with_obsolete    ${Test Results Dir}/TestFiles/FCT_Files/FCT_PDCCH_MultiRelease.xlsx
    ...    GENERAL-METADATA    ${Param_Value_Dic}    ${FCT_Info["Abbreviated Tool Name"]}    ${Sub_Version_Fst+1}
    log    ${New_FileName}
    Install FCT On WebEM CA    ${New_FileName}
    ${feature_list}    Get Feature List From WebEM CA
    ${feature_len}    Get Length    ${feature_list}
    Should Be Equal As Integers    ${feature_len}    5
    List Should Contain Value   ${feature_list}     ${FCT_Info["Tool Name"]}_${FCT_Version_New2}   #PDCCH_4.2.1 or PDCCH_4.3.0
    List Should Contain Value   ${feature_list}     ${FCT_Info["Tool Name"]}_${FCT_Version_New4}   #PDCCH_6.2.0
    List Should Contain Value    ${feature_list}    PUCCH_Config_Recommendations_${FCT_Version}    #PUCCH_4.2.0
    List Should Not Contain Value    ${feature_list}    ${FCT_Info["Tool Name"]}_${FCT_Version_New3}   #PDCCH_5.2.0
    Set Test Variable    ${FCT_Version_New3}

Step ${index}: Check Installed FCT Detail Info
    Log    Step ${index}: Check Installed FCT Detail Info    console=True
    Install FCE From WebEM CA    ${Test Results Dir}/TestFiles/${fce_worker_name}
    SBTS WEM Select Feature On CA    ${FCT_Info["Tool Name"]}_${FCT_Version}  #${FCT_Info["Tool Name"]}_${FCT_Version_New1}
    ${FCT_Info_WebEM_Dic}    SBTS WEM Get Feature Detail Info On CA
    ${Adapt_WebEM_List}    Split String    ${FCT_Info_WebEM_Dic["Supported adaptation version(s):"]}
    Sort List    ${Adapt_WebEM_List}
    Set To Dictionary    ${FCT_Info_WebEM_Dic}    Supported adaptation version(s):    ${Adapt_WebEM_List}
    ${ParmName_WebEM_List}    Get Dictionary Keys    ${FCT_Info_WebEM_Dic}
    FOR    ${ParamName}    IN    @{ParmName_WebEM_List}
        log    ${FCT_Info_WebEM_Dic["${ParamName}"]}
        ${ParamValue_WebEM}    Set Variable If    "${FCT_Info_WebEM_Dic["${ParamName}"]}"=="-"    ${None}    ${FCT_Info_WebEM_Dic["${ParamName}"]}
        ${ParamName_Excel}    Set Variable    ${Params_WebEM_Excel_Dic["${ParamName}"]}
        ${ParamValue_Excel}    Set Variable    ${FCT_Info["${ParamName_Excel}"]}
        Should Be Equal    ${ParamValue_WebEM}    ${ParamValue_Excel}
    END


SetUp
    Common Test Setup SBTS    scf_check=${FALSE}
    Install FCE Package
    ${Params_WebEM_Excel_Dic}    Create Dictionary    Abbreviated FCT tool name:=Abbreviated Tool Name    Version:=Version
    ...    FCT tool description:=Description    Full FCT tool name:=Tool Name    Category:=Category
    ...    Supported adaptation version(s):=Support Release(s) \\ NIDD adaptationId(s)
    ${ParmName_Excel_list}    Get Dictionary Values    ${Params_WebEM_Excel_Dic}
    ${FCT_Info}    FCT_Excel.get_FCT_info
    ...    ${Test Results Dir}/TestFiles/FCT_Files/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    ${ParmName_Excel_list}
    log    ${FCT_Info}
    ${FCT_Version}    Set Variable    ${FCT_Info["Version"]}
    log    ${FCT_Version}
    Set Test Variable    ${FCT_Info}
    Set Test Variable    ${FCT_Version}
    ${FCT_Version_List}	Split String	${FCT_Version}	.
    Set Test Variable    ${FCT_Version}
    Set Test Variable    ${FCT_Version_List}
    Set Test Variable    ${Params_WebEM_Excel_Dic}
    Set Test Variable    ${ParmName_Excel_list}


TearDown
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    Common Test Teardown SBTS
    SBTS WEM Download Chrome Console Log
    [Teardown]    Close All Browsers

Install FCE Package
    Log    Install FCE Package    console=True
    ${fce_worker_name}    ${fct_file_name}    Download FCE Modules For Current SW
    Set Test Variable    ${fce_worker_name}
    Set Test Variable    ${fct_file_name}
    OperatingSystem.Run    mkdir ${Test Results Dir}/TestFiles/FCT_Files
    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output
    ...    unzip ${Test Results Dir}/TestFiles/${fct_file_name} -d ${Test Results Dir}/TestFiles/FCT_Files
    Should Be Equal As Integers    ${rc}    ${0}
    OperatingSystem.File Should Exist    ${Test Results Dir}/TestFiles/FCT_Files/FCT_PDCCH_MultiRelease.xlsx
    ${win_index}    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}
    SBTS WEM Open Configuration Manager    CA
    Install FCE From WebEM CA    ${Test Results Dir}/TestFiles/${fce_worker_name}



