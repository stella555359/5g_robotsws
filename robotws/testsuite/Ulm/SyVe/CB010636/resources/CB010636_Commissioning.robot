*** Settings ***
Documentation   covers the commissioning for the CB010636 TCs


#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.scf             WITH NAME    scf
Library    taf.sbts.oam.coam.admin.interface    WITH NAME    admin

Resource    ../../../resources/Common/commissioning.robot
Resource    ../../resources/scf_info.robot
Resource    ../../resources/syve_commissioning.robot


*** Keywords ***
Commission delta gnb_scf
    [Documentation]     Settings for file commissioning and executiong of Delta commissioning
    ...                 Set all gnb variables
    [Arguments]         ${gnb_id}=${0}

    ${configSuiteDir}=    testline.Get test suite config directory
    Set Suite Variable  ${basic_scf_name_gnb_${gnb_id}}
    ...  /mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs/${GNB_SW_BRANCH}/${TL_NAME}/GNB-${gnb_id}/scf.xml
    Set Suite Variable   ${target_scf_name_gnb_${gnb_id}}  ${configSuiteDir}/scf_updated_gnb_${gnb_id}.xml
    Set Suite Variable  ${delta_scf_recommissioning_name_${gnb_id}}
    ...                 ${configSuiteDir}/delta_scf__${gnb_id}.json
    Set Suite Variable  ${revert_delta_scf_recommissioning_name_${gnb_id}}
    ...                 ${configSuiteDir}/revert_delta_scf__${gnb_id}.json

    Log To Console    \Loading delta gnb scf parameters

    IF  'CB010636-A_TC04' in ${TEST TAGS}
        Commissioning gNB for TC04  gnb_id=${0}
        ...        target_scf_name_gnb=${target_scf_name_gnb_${gnb_id}}
        ...        delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${gnb_id}}
    ELSE IF    'CB010636-B_TC12' in ${TEST TAGS}
        Commissioning gNB for TC04  gnb_id=${0}
        ...        target_scf_name_gnb=${target_scf_name_gnb_${gnb_id}}
        ...        delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${gnb_id}}
    ELSE IF    'CB010636-D_TC23' in ${TEST TAGS}
        Commissioning gNB for TC23  gnb_id=${gnb_id}
        ...        target_scf_name_gnb=${target_scf_name_gnb_${gnb_id}}
        ...        delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${gnb_id}}
    ELSE IF    'CB010636-D_TC24' in ${TEST TAGS}
        Commissioning gNB for TC23  gnb_id=${gnb_id}
        ...        target_scf_name_gnb=${target_scf_name_gnb_${gnb_id}}
        ...        delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${gnb_id}}
    END
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}  timeout=900s

Revert gNB Delta Commission
    [Documentation]    Commissioning of gnb for CB010636, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.
    [Arguments]    ${gnb_id}  ${target_scf_name_gnb}  ${revert_delta_scf_recommissioning_name}

    Log to Console  Start commissioning for gnb

    scf.calculate delta scf
    ...    target_scf_path=${basic_scf_name_gnb_${gnb_id}}
    ...    actual_scf_path=${target_scf_name_gnb}
    ...    delta_scf_path=${revert_delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name}

Revert Commission delta gnb_scf
    [Documentation]     Reverting delta file commissioning and executiong Revert commissioning
    [Arguments]    ${gnb_id}=${0}
    Log To Console    \Revert delta commissioning
    IF    'CB010636-A_TC04' in ${TEST TAGS}
         Revert gNB Delta Commission   gnb_id=${0}
         ...   target_scf_name_gnb=${target_scf_name_gnb_${gnb_id}}
         ...   revert_delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name_${gnb_id}}
    ELSE IF    'CB010636-B_TC12' in ${TEST TAGS}
         Revert gNB Delta Commission  gnb_id=${0}
         ...   target_scf_name_gnb=${target_scf_name_gnb_${gnb_id}}
         ...   revert_delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name_${gnb_id}}
    ELSE IF    'CB010636-D_TC23' in ${TEST TAGS}
         Revert gNB Delta Commission   gnb_id=${0}
         ...   target_scf_name_gnb=${target_scf_name_gnb_${gnb_id}}
         ...   revert_delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name_${gnb_id}}
    ELSE IF    'CB010636-D_TC24' in ${TEST TAGS}
         Revert gNB Delta Commission   gnb_id=${0}
         ...        target_scf_name_gnb=${target_scf_name_gnb_${gnb_id}}
         ...        revert_delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name_${gnb_id}}
    END

    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}  timeout=900s

Commissioning gNB for TC04
   [Documentation]
    ...    |    Commissioning of gNB    |
    [Arguments]        ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}

    ${configSuiteDir}=    testline.Get test suite config directory
    scf_info.Set MNL version string for branch    basic_scf_name=${basic_scf_name_gnb_${gnb_id}}

    Log to Console  Start commissioning for gnb
    scf.load_scf  file_path=${basic_scf_name_gnb_${gnb_id}}

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${NRBTS_ID_${gnb_id}}/NRBTS-${NRBTS_ID_${gnb_id}}

    @{GNB_PARAMS_IN_SCF}   create list
    ...  modify:${nrbts_nidd}\$:sCellActivationMethod=bufferBased
    ...  modify:${nrbts_nidd}\$:actBufferBasedSCellAddition=oneShot_Dl_Fr1

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${target_scf_name_gnb}

    # create delta to check if modify_scf_element or perform_scf_modification worked correct by glance at generated delta
    # Node: for deleting sCellAdditionMethod "calculate delta scf" creates an 'update' with empty value. 'update' with
    # empty value does also remove the parameter. But correction alredy done in taf. Next taf version
    # creates the expected 'delete'
    scf.calculate delta scf
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${gnb_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    # if you want to do a delta_recommissioning instead of full commissioning following may work for you:
    # when built up the scf.xml file for the testcase, get current scf file, calculate delta scf and do a delta commissioning.
    # if no reboot is needed, delta_recommissioning is faster.

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}


Configure cfg5qiRange     #ToDo: Remove in the next MR to check robocop!
    [Documentation]
    ...    | change cfg5qiRange to the needed value |
    ...    | MRBTS-403891/NRBTS-403891/NRPMRNL-1/NRPMQAP-1 |
    [Arguments]    ${gnb_id}=${0}    ${cfg5qiRange}=${6}    ${timeout}=180    ${msg}=in Progress...
    Log To Console    ${\n}OnLine change of cfg5qiRange.
    Log To Console    ${\n}Perform gNB Delta Comissioning: ${msg}
    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+    gnb_id=${gnb_id}
    ${bts_distName}=    Get From List    ${bts_distNames}    ${0}

    ${configSuiteDir}=    testline.Get test suite config directory
    ${resultTestDir}=    testline.Get testcase log directory

    ${parameter1}=  create dictionary  value=${cfg5qiRange}  dist_name=${bts_distName}/NRPMRNL-1/NRPMQAP-1  p_name=cfg5qiRange
    ${param_list}=  Create List  ${parameter1}

    ${delta_scf_path}=  commissioning.Generate Delta Commissioning File
    ...    scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml
    ...    parameters_list=${param_list}
    ...    target_local_path=${resultTestDir}/gNB${gnb_id}_delta_scf_file_cfg5qiRange_${cfg5qiRange}.xml

    ${result}=   commissioning.Execute delta commissioning
    ...    delta_scf_template=${delta_scf_path}
    ...    resultDir=${resultTestDir}
    ...    gnb_id=${gnb_id}
    ...    timeout=${timeout}

    RETURN    ${result}


Commissioning gNB for TC23
    [Documentation]
    ...    |    Commissioning of gNB    |
    [Arguments]        ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}

    ${configSuiteDir}=    testline.Get test suite config directory

    scf_info.Set MNL version string for branch    basic_scf_name=${basic_scf_name_gnb_${gnb_id}}

    Log to Console  Start commissioning for gnb
    scf.load_scf  file_path=${basic_scf_name_gnb_${gnb_id}}

    #to overcome the 150 sign limitiation
    ${nrbts_nidd}=   Set Variable    MRBTS-${NRBTS_ID_${gnb_id}}/NRBTS-${NRBTS_ID_${gnb_id}}

    @{GNB_PARAMS_IN_SCF}   create list

    ...  modify:${nrbts_nidd}\$:actMultipleDedicatedBWPs=true
    ...  add:${nrbts_nidd}/NRCELL-4:pdcchAutoConfig:bwpChBwDedicated2=20MHz

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}

    ${bwplist_dict_1}    Create dictionary
    ...    actPdcchCceFragmentControl     false
    ...    actUpperThrAckNackFiltering    false
    ...    actUpperThrAckNackHrFiltering  false
    ...    bwpDN                          ${nrbts_nidd}/BWP_PROFILE-10033
    ...    cellBwpId                      2
    ...    pdcchBlockingThresholdDL       30
    ...    pdcchBlockingThresholdUL       30
    ...    pdcchFreeThresholdDL           50
    ...    pdcchFreeThresholdUL           50
    ...    pdcchResourcePreference        peakRate

    scf.add_item_to_list
    ...    dist_name=${nrbts_nidd}/NRCELL-4
    ...    list_name=cellBwpList
    ...    elements=${bwplist_dict_1}
    scf.save_scf  ${target_scf_name_gnb}

    # create delta to check if modify_scf_element or perform_scf_modification worked correct by glance at generated delta
    # Node: for deleting sCellAdditionMethod "calculate delta scf" creates an 'update' with empty value. 'update' with
    # empty value does also remove the parameter. But correction alredy done in taf. Next taf version
    # creates the expected 'delete'
    scf.calculate delta scf
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${gnb_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    # if you want to do a delta_recommissioning instead of full commissioning following may work for you:
    # when built up the scf.xml file for the testcase, get current scf file, calculate delta scf and do a delta commissioning.
    # if no reboot is needed, delta_recommissioning is faster.

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}

Create cfg5qiRange with Delta Recommissioning
    [Documentation]
    ...    | create cfg5qiRange to the needed value |
    ...    | MRBTS-403891/NRBTS-403891/NRPMRNL-1/NRPMQAP-1 |
    [Arguments]    ${gnb_id}=${0}    ${cfg5qiRange}=${6}
    Log To Console    ${\n}Online Creation of cfg5qiRange

    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+    gnb_id=${gnb_id}
    ${bts_distName}=    Get From List    ${bts_distNames}    ${0}

    ${resultTestDir}=    testline.Get testcase log directory

    admin.Create delta    cfg5qiRange_Creation    #the keyword is a must to initiate the commissioning object
    admin.Append managed object to delta    ${bts_distName}/NRPMRNL-1/NRPMQAP-1    operation=update    delta_id=cfg5qiRange_Creation
    admin.Append parameter update to delta
    ...    dist_name=${bts_distName}/NRPMRNL-1/NRPMQAP-1
    ...    parameter=cfg5qiRange
    ...    value=${cfg5qiRange}
    ...    delta_id=cfg5qiRange_Creation

    admin.Get delta    cfg5qiRange_Creation
    admin.Save delta    ${resultTestDir}/gNB${gnb_id}_delta_scf_file_cfg5qiRange_Creation.json    cfg5qiRange_Creation

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    admin.Perform delta recommissioning
    ...    delta_file=${resultTestDir}/gNB${gnb_id}_delta_scf_file_cfg5qiRange_Creation.json
    ...    connection=${oam_alias}

Delete cfg5qiRange with Delta Recommissioning
    [Documentation]
    ...    | delete cfg5qiRange |
    ...    | MRBTS-403891/NRBTS-403891/NRPMRNL-1/NRPMQAP-1 |
    [Arguments]    ${gnb_id}=${0}
    Log To Console    ${\n}Online Deletion of cfg5qiRange

    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+    gnb_id=${gnb_id}
    ${bts_distName}=    Get From List    ${bts_distNames}    ${0}

    ${resultTestDir}=    testline.Get testcase log directory

    admin.Create delta    cfg5qiRange_Deletion    #the keyword is a must to initiate the commissioning object
    admin.Append managed object to delta    ${bts_distName}/NRPMRNL-1/NRPMQAP-1    operation=update    delta_id=cfg5qiRange_Deletion
    admin.Append parameter delete to delta
    ...    dist_name=${bts_distName}/NRPMRNL-1/NRPMQAP-1
    ...    parameter=cfg5qiRange
    ...    delta_id=cfg5qiRange_Deletion

    admin.Get delta    cfg5qiRange_Deletion
    admin.Save delta    ${resultTestDir}/gNB${gnb_id}_delta_scf_file_cfg5qiRange_Deletion.json    cfg5qiRange_Deletion

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    admin.Perform delta recommissioning
    ...    delta_file=${resultTestDir}/gNB${gnb_id}_delta_scf_file_cfg5qiRange_Deletion.json
    ...    connection=${oam_alias}
