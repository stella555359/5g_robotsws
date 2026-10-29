*** Settings ***
Documentation
...    Author: charlotte.wu@nokia-sbell.com
...    Maintainer: charlotte.wu@nokia-sbell.com
...    Description: 5gNB snapshot collecting
...    Team in charge: I_NSB_MN_5GSC_MMW_SC_PZ_HZ_02_GMS
...    QualityCenter: tds://5g.mn_5g.qc12-prod.int.net.nokia.com/qcbin/TestLabModule-000000003649890581?EntityType=ITestSet&EntityID=68153

Library    String
Library    BuiltIn
Library    OperatingSystem
Library    Collections
Library    XML  lxml=True
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.config.scf    WITH NAME    scf
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot

*** Variable ***
${test_btsName}    TestBTS

*** Keywords ***
Generate SCF to commission
    [Documentation]
    ...  Modify BTS name for commission test
    [Arguments]    ${source_SCF_path}
    ${XML}=    Parse XML   ${source_SCF_path}
    ${mrbtsId_element}=    Get Element    ${XML}    .//managedObject[@class="com.nokia.du.5g:MRBTS"]
    set global variable    ${mrbtsId}    ${mrbtsId_element.attrib['distName']}
    ${bts_name_parameter}=    Create List
    ${bts_name_dict}=    Create Dictionary    dist_name=${mrbtsId}    p_name=btsName	value=${test_btsName}
    Append To List     ${bts_name_parameter}    ${bts_name_dict}
    ${target_SCF_path}=    COAM Modify scf file    scf_file_path=${source_SCF_path}    scf_parameters_list=${bts_name_parameter}
    [Return]    ${target_SCF_path}

Check BTS name changed
    [Documentation]
    ...  Check BTS name the same as SCF
    [Arguments]    ${changed}=True
    ${btsName}=    selenium_coam.get_bts_name
    Run keyword if    ${changed}==True    Should be Equal    ${test_btsName}    ${btsName}
    ...    ELSE    Should not be Equal    ${test_btsName}    ${btsName}

Get BTS name
    [Documentation]
	...  Get BTS name from gnb
	${orig_btsName}=    selenium_coam.get_bts_name
    set global variable    ${orig_btsName}

Restore BTS name
    [Documentation]
    ...  Restore BTS name for gnb
    selenium_coam.set_parameter_value    dist_name=${mrbtsId}    filter_param=BTS name    new_value=${orig_btsName}
    Validate Plan
    Activate Plan

Change actCli value
    [Documentation]  Author: Charlotte Wu
    ...  Change actCli to different value
    ${actCli}=    selenium_coam.get_parameter_value    dist_name=FEATCADM-1    filter_param=Activate CLI
    ${new_actCli}=    Set Variable If    '${actCli}' == 'true'    false    true
    selenium_coam.set_parameter_value    dist_name=FEATCADM-1    filter_param=Activate CLI    new_value=${new_actCli}
    Validate Plan
    Activate Plan
    Du Check cell on air via WebUI without login
    ${actCli}=     selenium_coam.get_parameter_value    dist_name=FEATCADM-1    filter_param=Activate CLI
    Should Be True    '${actCli}' == '${new_actCli}'

Change pMax value
    [Documentation]  Author: Charlotte Wu
    ...  Change actCli to different value
    ${pMax}=    selenium_coam.get_parameter_value    dist_name=NRCELL-1    filter_param=Maximum output power
    ${RU_info}=    selenium_coam.get_ru_info
    ${RU_type}=    Set Variable    ${RU_info['Product name']}
    ${new_pMax_value}=    Set Variable If    '${RU_type}' == 'AEUB' or '${RU_type}' == 'AEWB'    ${18}    ${15}
    ${new_pMax_value2}=    Evaluate    ${new_pMax_value} - 1
    ${new_pMax_value}=    Set Variable If    '${pMax}' == '${new_pMax_value}dBm'    ${new_pMax_value2}    ${new_pMax_value}
    selenium_coam.set_parameter_value    dist_name=NRCELL-1    filter_param=Maximum output power    new_value=${new_pMax_value}
    Validate Plan
    Activate Plan and Close Activate Plan Window
    Close DU start up window    timeout=${200}
    Wait until keyword succeeds    15 x    60 s
    ...    Du Check cell on air via WebUI without login
    ${pMax}=    selenium_coam.get_parameter_value    dist_name=NRCELL-1    filter_param=Maximum output power
    ${new_pMax_value}=    Convert To String    ${new_pMax_value}
    Should Contain    ${pMax}    ${new_pMax_value}

Get Last Cell Index
    [Documentation]  Author: Charlotte Wu
    ...  Get last cell index from SCF
    [Arguments]    ${SCF_path}
    scf.load_scf    ${SCF_path}
    ${cell_group}=    scf.get_all_values_from_scf    list_name=nrCellList
    ${cell_index}=    Get From List    ${cell_group}    -1
    ${cell_index}=    Convert To Integer    ${cell_index}
    [Return]    ${cell_index}
	
	
Update NRCELL List
    [Documentation]  Author: Charlotte Wu
    ...  Update nrCellList id
    [Arguments]    ${index}    ${value}
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELLGRP-0
    ...    filter_param=List of NR cells assigned to cell group
    ...    node_index=${index}
    ...    new_value=${value}

Activate Plan and Close Activate Plan Window
    [Documentation]  Author: Charlotte Wu
    ...              Description: Activate Loaded SCF
    Activate Plan
    Close DU start up window    timeout=${200}
