*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for TA_RAN_ST_CB009451-E_001_CM_Installing new FCT tool version to the FCE in online WebEM
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot
Library           ../Resources/python/FCT_Excel.py



*** Keywords ***
TC__VRAN_CM_Installing_New_FCT_Tool_Version_To_The_FCE_In_Online_WebEM_CB009451-E_001
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    20.06.2023, yuyan.xu@nokia-sbell.com, draft
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
    ...    ${TEST_LOG_DIRECTORY}/FCT_Files/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    Version    ${FCT_Version_New1}
    log    ${New_FileName}
    ${error}    Install FCT    ${New_FileName}
    Should Be Equal As Strings    ${error}
    ...    FCT installing process is terminated. The FCT version is lower than the existing one, operation failed!

Step ${index}: Install Matched FCT Package Success
    Log    Step ${index}: Install Matched FCT Package Success    console=True
    ${Param_Value_Dic}    Create Dictionary    Tool Name=PUCCH_Config_Recommendations    Abbreviated Tool Name=PUCCH
    ${New_FileName}    FCT_Excel.update_parameters
    ...    ${TEST_LOG_DIRECTORY}/FCT_Files/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    ${Param_Value_Dic}
    log    ${New_FileName}
    Install FCT    ${New_FileName}
    ${feature_list}    Get FCE Feature List
    ${feature_len}    Get Length    ${feature_list}
    Should Be Equal As Integers    ${feature_len}    4
    List Should Contain Value    ${feature_list}    ${FCT_Info["Tool Name"]}_${FCT_Version}  #PDCCH_4.2.0
    List Should Contain Value    ${feature_list}    PUCCH_Config_Recommendations_${FCT_Version}   #PUCCH_4.2.0

Step ${index}: Install Last Or Middle Higher FCT Package Success
    Log    Step ${index}: Install Last Or Middle Higher FCT Package Success    console=True
    ${Sub_Version_Mid}    Convert To Integer    ${FCT_Version_List[1]}
    ${Sub_Version_Last}    Convert To Integer    ${FCT_Version_List[2]}
    ${index}    Evaluate    random.randint(0,1)    modules=random, sys
    ${FCT_Version_New2}    Set Variable If	   ${index}==${0}    ${FCT_Version_List[0]}.${Sub_Version_Mid+1}.${FCT_Version_List[2]}
    ...    ${FCT_Version_List[0]}.${FCT_Version_List[1]}.${Sub_Version_Last+1}
    ${Param_Value_Dic}    Create Dictionary    Version=${FCT_Version_New2}
    ${New_FileName}    FCT_Excel.update_parameters
    ...    ${TEST_LOG_DIRECTORY}/FCT_Files/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    ${Param_Value_Dic}
    log    ${New_FileName}
    Install FCT    ${New_FileName}
    ${feature_list}    Get FCE Feature List
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
    ...    ${TEST_LOG_DIRECTORY}/FCT_Files/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    ${Param_Value_Dic}
    log    ${New_FileName}
    Install FCT    ${New_FileName}
    ${feature_list}    Get FCE Feature List
    ${feature_len}    Get Length    ${feature_list}
    Should Be Equal As Integers    ${feature_len}    5
    List Should Contain Value    ${feature_list}    ${FCT_Info["Tool Name"]}_${FCT_Version_New2}   #PDCCH_4.2.1 or PDCCH_4.3.0
    List Should Contain Value    ${feature_list}    ${FCT_Info["Tool Name"]}_${FCT_Version_New3}   #PDCCH_5.2.0
    List Should Contain Value    ${feature_list}    PUCCH_Config_Recommendations_${FCT_Version}   #PUCCH_4.2.0
    Set Test Variable    ${FCT_Version_New3}

Step ${index}: Install First Higher FCT Package With Obsolete Success
    Log    Step ${index}: Install First Higher FCT Package With Obsolete Success    console=True
    ${Sub_Version_Fst}    Convert To Integer    ${FCT_Version_List[0]}
    ${FCT_Version_New4}    Set Variable	${Sub_Version_Fst+2}.${FCT_Version_List[1]}.${FCT_Version_List[2]}
    ${Param_Value_Dic}    Create Dictionary    Version=${FCT_Version_New4}    #Obsoletes version(s) :=5.2.0
    ${New_FileName}    FCT_Excel.update_with_obsolete    ${TEST_LOG_DIRECTORY}/FCT_Files/FCT_PDCCH_MultiRelease.xlsx
    ...    GENERAL-METADATA    ${Param_Value_Dic}    ${FCT_Info["Abbreviated Tool Name"]}    ${Sub_Version_Fst+1}
    log    ${New_FileName}
    Install FCT    ${New_FileName}
    ${feature_list}    Get FCE Feature List
    ${feature_len}    Get Length    ${feature_list}
    Should Be Equal As Integers    ${feature_len}    5
    List Should Contain Value   ${feature_list}     ${FCT_Info["Tool Name"]}_${FCT_Version_New2}  #PDCCH_4.2.1 or PDCCH_4.3.0
    List Should Contain Value   ${feature_list}     ${FCT_Info["Tool Name"]}_${FCT_Version_New4}  #PDCCH_6.2.0
    List Should Contain Value    ${feature_list}    PUCCH_Config_Recommendations_${FCT_Version}   #PUCCH_4.2.0
    List Should Not Contain Value    ${feature_list}    ${FCT_Info["Tool Name"]}_${FCT_Version_New3}  #PDCCH_5.2.0
    Set Test Variable    ${FCT_Version_New4}

Step ${index}: Check Installed FCT Detail Info
    Log    Step ${index}: Check Installed FCT Detail Info    console=True
    Install FCE    ${TEST_LOG_DIRECTORY}/${fce_worker_name}
    Select Feature In Configuration Automation    ${FCT_Info["Tool Name"]}_${FCT_Version}
    ${FCT_Info_WebEM_Dic}    Get Feature Detail Info On CA
    ${Adapt_WebEM_List}    Split String    ${FCT_Info_WebEM_Dic["Supported adaptation version(s):"]}
    Sort List    ${Adapt_WebEM_List}
    Set To Dictionary    ${FCT_Info_WebEM_Dic}    Supported adaptation version(s):    ${Adapt_WebEM_List}
    ${ParmName_WebEM_List}    Get Dictionary Keys    ${FCT_Info_WebEM_Dic}
    FOR    ${ParamName}    IN    @{ParmName_WebEM_List}
        ${ParamValue_WebEM}    Set Variable If    "${FCT_Info_WebEM_Dic["${ParamName}"]}"=="-"    ${None}    ${FCT_Info_WebEM_Dic["${ParamName}"]}
        ${ParamName_Excel}    Set Variable    ${Params_WebEM_Excel_Dic["${ParamName}"]}
        ${ParamValue_Excel}    Set Variable    ${FCT_Info["${ParamName_Excel}"]}
        Should Be Equal    ${ParamValue_WebEM}    ${ParamValue_Excel}
    END

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    ${ReIntegrate_vCU}
    Log To Console    ${ReIntegrate_vDU}
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Install FCE Package
    ${Params_WebEM_Excel_Dic}    Create Dictionary    Abbreviated FCT tool name:=Abbreviated Tool Name    Version:=Version
    ...    FCT tool description:=Description    Full FCT tool name:=Tool Name    Category:=Category
    ...    Supported adaptation version(s):=Support Release(s) \\ NIDD adaptationId(s)
    ${ParmName_Excel_list}    Get Dictionary Values    ${Params_WebEM_Excel_Dic}
    ${FCT_Info}    FCT_Excel.get_FCT_info
    ...    ${TEST_LOG_DIRECTORY}/FCT_Files/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    ${ParmName_Excel_list}
    log    ${FCT_Info}
    ${FCT_Version}    Set Variable    ${FCT_Info["Version"]}
    log    ${FCT_Version}
    Set Test Variable    ${FCT_Info}
    ${FCT_Version_List}	Split String	${FCT_Version}	.
    Set Test Variable    ${FCT_Version}
    Set Test Variable    ${FCT_Version_List}
    Set Test Variable    ${Params_WebEM_Excel_Dic}
    Set Test Variable    ${ParmName_Excel_list}

Case Postcondition
    Log To Console    Case Postcondition
    Common Test Teardown For AIC
    Logout And Close WEBEM

Install FCE Package
    Log    Install FCE Package    console=True
    ${fce_worker_name}    ${fct_file_name}    Download FCE Modules For Current SW    ${Trunk_Prefix}
    Set Test Variable    ${fce_worker_name}
    Set Test Variable    ${fct_file_name}
    OperatingSystem.Run    mkdir ${TEST_LOG_DIRECTORY}/FCT_Files
    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output
    ...    unzip ${TEST_LOG_DIRECTORY}/${fct_file_name} -d ${TEST_LOG_DIRECTORY}/FCT_Files
    Should Be Equal As Integers    ${rc}    ${0}
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/FCT_Files/FCT_PDCCH_MultiRelease.xlsx
    Open WEBEM and Login    https://${du_ip}    Nemuadmin    Nokia@123
    ${msg}    Install FCE    ${TEST_LOG_DIRECTORY}/${fce_worker_name}
    Should Be Empty    ${msg}



