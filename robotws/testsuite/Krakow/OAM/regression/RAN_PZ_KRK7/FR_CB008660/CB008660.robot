*** Settings ***
Documentation
...    Author: Bartłomiej Bieńko
...    Maintainer: bartlomiej.bienko@nokia.com
...    Description: CB008660-A
...                 Purpose of this feature is introduce functionality to use shortened NIDD paths for ASIR WebEM
...                 e.g. antAntlPrDN from CHANNEL-1 from ASI-1/ANTMODPR-1/ANTRFSMPR-1/ANTANTLPR-1 to ANTRFSMPR-1/ANTANTLPR-1
...    Usage: pass `--variable SW_DOWNLOAD_BUILD:<desired-package>` in robot command to download desired SW package locally and then upgrade it
...    Team-in-Charge: MN RAN PZ KRK 7
...    Contact:
...       - Anna Gryglak (anna.gryglak@nokia.com)
...       - Bartłomiej Bieńko (bartlomiej.bienko@nokia.com)
...       - Mateusz Szczurek (SGL) (mateusz.m.szczurek@nokia.com)

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Library    ./resources/keywords.py    WITH NAME    8660_keywords
Library    testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py

Variables    ./resources/variables.py

Suite Setup      Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                                   should_5G_neighbour_be_changed=${False}
...                                                                   increase_time_for_checking_bbmod=600
...                                                                   increase_timeout_for_update_sw=1800
...                                                                   increase_time_for_checking_radios=2100
...                                                                   increase_time_for_checking_cells=700

Suite Teardown    Common Suite Teardown

Test Setup    Run Keywords    Perform ASIR commissioning to default configuration    AND
...                           Wait Until Keyword Succeeds    10min    20s    Verify gNB is onAir    AND
...                           common_setups_and_teardowns.Common Preconditions With Watching Alarms

Test Teardown    Run Keywords    Perform ASIR commissioning to default configuration    AND
...                              Wait Until Keyword Succeeds    10min    20s    Verify gNB is onAir    AND
...                              common_setups_and_teardowns.Common Postconditions With Watching Alarms

*** Test Cases ***
[1]CB008660-A_06_Robustness_configuration_persistent_over_sw_upgrade
    [Tags]    A06
    Set Test Variable    ${OUTPUT TEST DIR}    ${OUTPUT DIR}/TEST_A06
    Create Directory     ${OUTPUT TEST DIR}

    # Checking for parameter recommissioning
    ${ASIR_SCF_file_path}=    Get Active ASIR SCF    path=${OUTPUT TEST DIR}    file_name=initial_ASIR_SCF.xml
    Update parameter of ASIR configuration    asir_dist_name=${CHANNEL_1_DIST_NAME}
    ...                                       parameter=${ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_PARAMETER}
    ...                                       value=${ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_VALUE}
    ...                                       index=${0}
    ${ASIR_SCF_file_path}=    Get Active ASIR SCF    path=${OUTPUT TEST DIR}    file_name=ASIR_SCF_after_shortened_name_commissioning.xml
    Has antAntlPrDN Has Shortened Name    scf_path=${ASIR_SCF_file_path}

    # Prepare TL for being able to download and upgrade desired SW package.
    Wait Until Keyword Succeeds    20min    20s    Verify gNB is onAir
    ${PATH_TO_SW}=    Keywords.Download SW Build    sw_build=${SW_DOWNLOAD_BUILD}    target_dir=${OUTPUT TEST DIR}
    Keywords.Wait SW Update Possible
    Keywords.Update SW    sw_package_dir=${PATH_TO_SW}

    # Check if new SW has desired value of previously recommissioned parameter
    Wait Until Keyword Succeeds    20min    20s    Verify gNB is onAir
    ${ASIR_SCF_file_path}=    Get Active ASIR SCF    path=${OUTPUT TEST DIR}    file_name=ASIR_SCF_after_sw_upgrade.xml
    Has antAntlPrDN Has Shortened Name    scf_path=${ASIR_SCF_file_path}

[1]CB008660-A_03_Adding_an_object_not_breaking_existing_distname_unambiguity_to_the_live_NE
    [Tags]    A03
    Set Test Variable    ${OUTPUT TEST DIR}    ${OUTPUT DIR}/TEST_A03
    Create Directory     ${OUTPUT TEST DIR}

    ${ASIR_SCF_file_path}=    Get Active ASIR SCF    path=${OUTPUT TEST DIR}    file_name=initial_ASIR_SCF.xml

    Update parameter of ASIR configuration    asir_dist_name=${CHANNEL_1_DIST_NAME}
    ...                                       parameter=${ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_PARAMETER}
    ...                                       value=${ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_VALUE}
    ...                                       index=${0}

    ${ASIR_SCF_file_path}=    Get Active ASIR SCF    path=${OUTPUT TEST DIR}    file_name=ASIR_SCF_after_shortened_name_commissioning.xml
    Has antAntlPrDN Has Shortened Name    scf_path=${ASIR_SCF_file_path}

[1]CB008660-A_04_Robustness_add_new_ambiguous_distname_parameter
    [Tags]    A04
    Set Test Variable    ${OUTPUT TEST DIR}    ${OUTPUT DIR}/TEST_A04
    Create Directory     ${OUTPUT TEST DIR}

    Perform ASIR commissioning with validation error check

[1]CB008660-A_05_Robustness_configuration_persistent_over_site_reset
    [Tags]    A05
    Set Test Variable    ${OUTPUT TEST DIR}    ${OUTPUT DIR}/TEST_A05
    Create Directory     ${OUTPUT TEST DIR}

    ${ASIR_SCF_file_path}=    Get Active ASIR SCF    path=${OUTPUT TEST DIR}    file_name=initial_ASIR_SCF.xml

    Update parameter of ASIR configuration    asir_dist_name=${CHANNEL_1_DIST_NAME}
    ...                                       parameter=${ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_PARAMETER}
    ...                                       value=${ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_VALUE}
    ...                                       index=${0}

    ${ASIR_SCF_file_path}=    Get Active ASIR SCF    path=${OUTPUT TEST DIR}    file_name=ASIR_SCF_after_shortened_name_commissioning.xml
    Has antAntlPrDN Has Shortened Name    scf_path=${ASIR_SCF_file_path}

    Reset gNB
    Wait Until Keyword Succeeds    5min    20s    Verify gNB is onAir

    ${ASIR_SCF_file_path}=    Get Active ASIR SCF    path=${OUTPUT TEST DIR}    file_name=ASIR_SCF_after_site_reset.xml
    Has antAntlPrDN Has Shortened Name    scf_path=${ASIR_SCF_file_path}

[1]CB008660-B_01_Remove_ASiR_spare_parameters-verification
    [Tags]    B01
    Set Test Variable    ${OUTPUT TEST DIR}    ${OUTPUT DIR}/TEST_B01
    Create Directory     ${OUTPUT TEST DIR}

    ${ASIR_SCF_file_path}=    Get Active ASIR SCF    path=${OUTPUT TEST DIR}    file_name=ASIR_SCF.xml
    Check if all managed objects of provided NIDD class has not configured desired parameter    scf_path=${ASIR_SCF_file_path}
    ...                                                                                         nidd_class=ASI
    ...                                                                                         parameter=frozenOMVersion
    ...                                                                                         mode=ASIR

    ${WebEM_SCF_file_path}=    Get Active SCF    path=${OUTPUT TEST DIR}    file_name=WebEM_SCF.xml
    Check if all managed objects of provided NIDD class has not configured desired parameter    scf_path=${WebEM_SCF_file_path}
    ...                                                                                         nidd_class=MRBTS
    ...                                                                                         parameter=frozenOMVersionVerizon
    ...                                                                                         mode=WebEM
    Check if all managed objects of provided NIDD class has not configured desired parameter    scf_path=${WebEM_SCF_file_path}
    ...                                                                                         nidd_class=MRBTS
    ...                                                                                         parameter=frozenOMVersionAtt
    ...                                                                                         mode=WebEM
    Check if all managed objects of provided NIDD class has not configured desired parameter    scf_path=${WebEM_SCF_file_path}
    ...                                                                                         nidd_class=MNL
    ...                                                                                         parameter=frozenOMVersionVerizon
    ...                                                                                         mode=WebEM
    Check if all managed objects of provided NIDD class has not configured desired parameter    scf_path=${WebEM_SCF_file_path}
    ...                                                                                         nidd_class=LNBTS
    ...                                                                                         parameter=frozenOMVersionVerizon
    ...                                                                                         mode=WebEM
    Check if all managed objects of provided NIDD class has not configured desired parameter    scf_path=${WebEM_SCF_file_path}
    ...                                                                                         nidd_class=LNBTS
    ...                                                                                         parameter=frozenOMVersionATT
    ...                                                                                         mode=WebEM
    Check if all managed objects of provided NIDD class has not configured desired parameter    scf_path=${WebEM_SCF_file_path}
    ...                                                                                         nidd_class=EQM
    ...                                                                                         parameter=frozenOMVersionVerizon
    ...                                                                                         mode=WebEM
    Check if all managed objects of provided NIDD class has not configured desired parameter    scf_path=${WebEM_SCF_file_path}
    ...                                                                                         nidd_class=EQM
    ...                                                                                         parameter=frozenOMVersionATT
    ...                                                                                         mode=WebEM
    Check if all managed objects of provided NIDD class has not configured desired parameter    scf_path=${WebEM_SCF_file_path}
    ...                                                                                         nidd_class=EQM_R
    ...                                                                                         parameter=frozenOMVersionVerizon
    ...                                                                                         mode=WebEM
    Check if all managed objects of provided NIDD class has not configured desired parameter    scf_path=${WebEM_SCF_file_path}
    ...                                                                                         nidd_class=EQM_R
    ...                                                                                         parameter=frozenOMVersionATT
    ...                                                                                         mode=WebEM
    Check if all managed objects of provided NIDD class has not configured desired parameter    scf_path=${WebEM_SCF_file_path}
    ...                                                                                         nidd_class=NRCELL
    ...                                                                                         parameter=rmodDnList
    ...                                                                                         mode=WebEM

*** Keywords ***
Perform ASIR commissioning to default configuration
    [Documentation]    Loads and activates default ASIR SCF.
    ${active_sw_release}=    keywords.Get SW Release Name
    ${mrbts_id}=    keywords.Get MRBTS Id
    Set Test Variable    ${ASIR_SCF_PATH}    ${CURDIR}/resources/SCF/${mrbts_id}/${active_sw_release}_ASIR.xml
    Perform Full Commissioning On Gnb Asir Hub    scf_path=${ASIR_SCF_PATH}
    Sleep    180s
    Wait Until Keyword Succeeds    20min    20s    Verify gNB is onAir