*** Settings ***
Documentation     author: Chen Kaijia
...               contact: kaijia.chen@nokia-sbell.com
...               squad group: MMW_SG_04

Resource          ./Resources/CB007308_common_keywords.robot
Library           ./Resources/check_tem.py
Variables         ./Resources/CB007308_modify_para.py
#Library           taf.sbts.oam.coam.admin    WITH NAME    admin
Library           taf.hw.optical_switch    WITH NAME    fiberswitch
Library           taf.selenium.sbts    WITH NAME    selenium_coam
Library           XML     use_lxml=True
Library           Collections
Library           String
Library           OperatingSystem
Library           taf.transport.ssh         WITH NAME    ssh
Library           taf.config.scf.interface.scf     WITH NAME   scf
#Resource          taf/rfrl/common_resources/robot/coam.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Force Tags        SBTS00    5G_RAN    5G_RAN_TDD    CRT_UTE    	CLOUD_5G_CLASSICAL_ANDROID_SA_ASOE_AEQE    STATE_SW_UPLOADED
...    PY36
Suite Setup       Case Suite Setup
Suite Teardown    Case Suite Teardown

*** Variables ***
${scf_path}          ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/

*** Test Cases ***
[1]CB007308-5G-AB_CB006942_3_BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_for_FH_interface
    [Tags]    CB007308    CRT_22R1    CRT_TRUNK
    [Setup]    Case Setup
    Check BTS is in On Air
    Check BTS startup
    BTS detects cooled SFP+/SFP28
    [Teardown]     Case_Teardown_common

[1]CB007308-5G-AB_CB006942_7_BTS_startup_SFP+_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface
    [Tags]    CB007308    CRT_22R1    CRT_TRUNK
    [Setup]    Case Setup
    Set SFPWhiteList File Name
    Create dir
    Download whitelist file
    Delete parameter in sfpwhitelist    sfp_model=AOSD
    Delete parameter in sfpwhitelist    sfp_model=AOZEB
    Delete parameter in sfpwhitelist    sfp_model=AOZEA
    Delete parameter in sfpwhitelist    sfp_model=FOTB
    Upload whitelist file    upload_whitelist_path=${SFPwhitelist_PATH}${SFPwhitelist_NAME}
    Reset DU
    sleep    10s
    run keyword and continue on failure    check fault 4657
    ${i}    Get EIF1 distname
    ${ii}    Get RF1 distname
    ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}    Get Availability status for SFP    i=${i}    ii=${ii}
    Check SFP availability status
    ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
    ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Degraded
    change sfpOperatorMode to true
    sleep    2s
    run keyword and continue on failure    check none fault 4657
    ${i}    Get EIF1 distname
    ${ii}    Get RF1 distname
    ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}    Get Availability status for SFP    i=${i}    ii=${ii}
    Check SFP availability status
    ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
    ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Online
    sleep    60s
    ${i}    Get EIF1 distname
    ${ii}    Get RF1 distname
    ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}    Get Availability status for SFP    i=${i}    ii=${ii}
    Check SFP availability status
    ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
    ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Online
    Reset DU
    run keyword and continue on failure    check none fault 4657
    sleep    10s
    ${i}    Get EIF1 distname
    ${ii}    Get RF1 distname
    ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}    Get Availability status for SFP    i=${i}    ii=${ii}
    Check SFP availability status
    ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
    ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Online
    sleep    5s
    change sfpOperatorMode to false
    sleep    20s
    run keyword and continue on failure    check fault 4657
    sleep    2s
    ${i}    Get EIF1 distname
    ${ii}    Get RF1 distname
    ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}    Get Availability status for SFP    i=${i}    ii=${ii}
    Check SFP availability status
    ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
    ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Degraded
    sleep    60s
    ${i}    Get EIF1 distname
    ${ii}    Get RF1 distname
    ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}    Get Availability status for SFP    i=${i}    ii=${ii}
    Check SFP availability status
    ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
    ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Degraded
    [Teardown]    Case Teardown

[1]CB007308-5G-AB_CB006942_9_The_BTS_shall_support_NIDD_parameter_SFPOperatorMode_to_enable_and_disable_SFP+_or_SFP28_compliance_validation
    [Tags]    CB007308    CRT_22R1    CRT_TRUNK
    [Setup]    Case Setup
    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    Case Teardown

[1]CB007308-5G-AC-5GC002269_08_NRCELL, NRCELLGRP addition.
    [Tags]    CB007308    CRT_22R1    CRT_TRUNK    CRT_23R2
    [Setup]    Case Setup
    Check BTS is in On Air
    WEBUI Login
    Log To Console  Add a NRCELL object under ${MRBTS_ID}/${NRBTS_ID}, copy from ${MRBTS_ID}/${NRBTS_ID}/NRCELL-411
    selenium_coam.add_object  object_name=${MRBTS_ID}/${NRBTS_ID}  object_class_name=NRCELL
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1  copy_from=${MRBTS_ID}/${NRBTS_ID}/NRCELL-411
    ...    include_subobject=${TRUE}  id_value=2
    #Set parameter physCellId
    Log To Console  Set parameter physCellId 481
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-2
    ...    filter_param=Physical cell identifier   new_value=481    abbr=physCellId
    #Set parameter lcrId
    Log To Console  Set parameter lcrId 2
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-2
    ...    filter_param=Local cell resource ID    new_value=3   abbr=lcrId
    #Set parameter nrarfcn
    Log To Console  Set parameter nrarfcn 645000
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-2
    ...    filter_param=NR Absolute radio frequency channel number   new_value=645000   abbr=nrarfcn

    #2. Add a NRCELLGRP object under MRBTS-x/NRBTS-x, copy from existing object:
    Log To Console  Add a NRCELLGRP object under ${MRBTS_ID}/${NRBTS_ID}, copy from ${MRBTS_ID}/${NRBTS_ID}/NRCELLGRP-411
    selenium_coam.add_object    object_name=${MRBTS_ID}/${NRBTS_ID}    object_class_name=NRCELLGRP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1  copy_from=${MRBTS_ID}/${NRBTS_ID}/NRCELLGRP-411
    ...    include_subobject=${TRUE}  id_value=2
    #Modify value of nrCelllList #1 to lcrId of new cell:
    Log To Console  Set parameter nrCellList 1
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELLGRP-2
    ...    filter_param=List of NR cells assigned to cell group  node_index=${0}  new_value=2    abbr=nrCellList

    #3. Add a LCELNR object under MRBTS-x/MNL-1/MNLENT-1/CELLMAPPING-1/, copy from existing object
    Log To Console  Add a LCELNR object under CELLMAPPING-1, copy from ${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-411

    selenium_coam.add_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-411
    ...    include_subobject=${TRUE}    id_value=3

    #4. Add value of new cellgroup id in refNrCellGroup under ${MRBTS_ID}/${NRBTS_ID}/NRDU-1
    Log To Console  Add value of new cellgroup id in refNrCellGroup under ${MRBTS_ID}/${NRBTS_ID}/NRDU-1
    selenium_coam.add_element    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    abbr=refNrCellGroup
    Log To Console  Set parameter refNrCellGroup 1
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group  new_value=2
    ...    node_index=${2}    abbr=refNrCellGroup

    Log To Console  Validate And Activate parameters
    WebEM ValidateAndActiveParameters
    Log To Console  Activated plan
    Check 2 cell both onair
    Log To Console  New cell onair without BTS reset

#   NRCELL reduction
    Check BTS is in On Air
    selenium_coam.remove_object    object_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-2
    selenium_coam.remove_object    object_name=${MRBTS_ID}/${NRBTS_ID}/NRCELLGRP-2
    selenium_coam.remove_element   dist_name=${MRBTS_ID}/${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${2}    abbr=refNrCellGroup
    selenium_coam.remove_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3

    Log To Console  Validate And Activate parameters
    WebEM ValidateAndActiveParameters
    Log To Console  Activated plan
    Check BTS is in On Air
    Log To Console  Cell deleted without BTS reset
    [Teardown]    Run keywords    WEBUI_Logout    AND    Case_Teardown_common


[1]CB007308-5G-AC-5GC002269_09_NRCELL, NRCELLGRP reduction
    [Tags]    CB007308    CRT_22R1    CRT_TRUNK
    [Setup]    Case Setup
    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    Case_Teardown_common


