*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com


*** Keywords ***
OMKPI SW Rollback
    [Documentation]    In this test T1 testpackage is downloaded to BTS or if UUF_CUSTOMER or UPDATE_PATH or UUF_BUILD
    ...  has been given then the software used for triggering is downloaded to BTS and then SW rollback is done to the.
    ...   previous SW. After that checks are made and KPIs are collected and checked.
    ...  NOTE If multiple loops are run downloading of T1/triggering build is not done again after first loop, because
    ...  it is already in passive side.
    [Arguments]    ${SAVE_BUILD_TO_PC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    ...            ${WAIT_DISABLED_CELLS}
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${A_SW}=                              Get Active Sw Of Bts
    Set Suite Variable                    ${ACTIVE_SW}   ${A_SW}
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    Print Step Text                       ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
#    Run Keyword And Continue On Failure   Check If Netboot Is Active And Deactivate It
    ${BUILD}=                             Check And Get If Customer Or Update Path Or T1 In Passive
    ${NOT_FIRST_LOOP}=                    More Than One Test Loop Current Loop Is Not First
    ${use_builds_already_on_bts}=         Get Variable Value    ${USE_BUILDS_ALREADY_ON_BTS}  ${False}
    Run Keyword If    '${use_builds_already_on_bts}' == '${True}' or '${NOT_FIRST_LOOP}' == '${True}'  Run Keywords
    ...               Print Text To Eventlog   Do rollbacks between builds that already are on active and passive banks   AND
    ...               Run Keyword And Continue On Failure    Set Variable To Point Software On Passive Side
    Run Keyword If    '${NOT_FIRST_LOOP}' == '${False}' and '${use_builds_already_on_bts}' == '${False}'
    ...               Run Keyword And Continue On Failure    Get Build And Do SWDL
    ...               ${SAVE_BUILD_TO_PC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${STEP}   ${BUILD}
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                       ${STEP}  Rollback from ${ACTIVE_SW_T1} SW to ${ACTIVE_SW} SW
    Print Text To Eventlog                Request rollback to ${ACTIVE_SW}
    Run Keyword And Continue On Failure   Rollback To Passive Sw  timeout=${1200}  admin_connection=log_admin
    Print Text To Eventlog                Request to rollback done
# Because of 4420 fault occasionally BTS is busy and it is not possible to get information from it before 4420 is cleared
#    Run Keyword And Continue On Failure   Check If Fault Active And Wait For It To Clear  4420
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                       ${STEP}  Wait for all cells faulty
    Run Keyword And Continue On Failure   Wait For Cells Faulty  ${WAIT_DISABLED_CELLS}
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                       ${STEP}  Wait for all cells up
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                       ${STEP}  Check that active SW is ${ACTIVE_SW}
    Run Keyword And Continue On Failure   Check That SW Has Been Updated  ${ACTIVE_SW}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                       ${STEP}  Check Postconditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Run Keyword And Continue On Failure   Common Postconditions
# Commented out because of FCA_TATSCRIPTS-182446 Robotization for SWDL cases: Remove states checking
#    Print Step Text                   12  Check from history that SMOD, RMODs, BBMODs and cells were reset
#    Run Keyword And Continue On Failure   Check SMOD RMOD And BBMOD States
# No need to check if cells were reset because we check if all cells faulty and then all cells up
# FCA_TATSCRIPTS-182904 Remove cell history check
#    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
#    Print Step Text                       ${STEP}  Check from history that cells did reset
#    Run Keyword And Continue On Failure   Check If Selected Cells Were Disabled And Enabled    all_cells=${True}
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                       ${STEP}  Collect KPIs
    Run Keyword and Continue On Failure   Collect KPIs  Sw rollback
    Run Keyword And Continue On Failure   Check Loop KPI  Sw rollback  ${OAM_KPI_TARGETS}
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                       ${STEP}  Print extra KPIs
    Run Keyword And Continue On Failure   Print Extra KPIs  Sw rollback

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Get Build And Do SWDL
    [Documentation]    Get build that is currently active on BTS and get T1 test package for it or triggering build.
    ...                Then update T1/triggering SW and make checks.
    [Arguments]    ${SAVE_BUILD_TO_PC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${STEP}   ${BUILD_TO_DOWNLOAD}
    ${EXPL}=                              Get Variable Value   ${EXPLANATION}    T1 testpackage
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    IF  '${EXPL}' == 'T1 testpackage'
        ${BUILD_TO_DOWNLOAD}=             Get Build That Is Currently Active On BTS  save_to_pc=${SAVE_BUILD_TO_PC}  testpackage=T1
    ELSE
        Print Text To Eventlog            Get Build ${BUILD_TO_DOWNLOAD} to PC
        ${BUILD_TO_DOWNLOAD}=             Get Build From Artifactory   ${BUILD_TO_DOWNLOAD}   package_type=A54
        ...                               save_to_pc=${SAVE_BUILD_TO_PC}
    END
    ${BUILD_IN_PASSIVE}=  Check If Build In Passive Side Is Same That Is Planned To Be Downloaded  ${BUILD_TO_DOWNLOAD}
    ...                   switch_order=${False}  return_boolean=${True}
    IF  '${BUILD_IN_PASSIVE}' == '${False}' and '${EXPL}' == 'T1 testpackage'
        Run Keyword And Continue On Failure   Update SW And Make Checks  ${BUILD_TO_DOWNLOAD}  ${EXPL}  ${STEP}
        ...                                   ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
    ELSE IF    '${BUILD_IN_PASSIVE}' == '${False}' and '${EXPL}' != 'T1 testpackage'
        Run Keyword And Continue On Failure   Update SW And Make Checks  ${BUILD_TO_DOWNLOAD}  Triggering build  ${STEP}
        ...                                   ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
    ELSE
        Print Text To Eventlog  Build ${BUILD_TO_DOWNLOAD} is already in the passive partition, no need to do SWDL
        Set Variable To Point Software On Passive Side
        Set Suite Variable    ${USE_BUILDS_ALREADY_ON_BTS}   ${True}

    END
    ${A_SW_T1}=                           Get Active SW Of BTS
    Set Suite Variable                    ${ACTIVE_SW_T1}   ${A_SW_T1}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Set Variable To Point Software On Passive Side
    [Documentation]    Because T1 or triggering build is on passive side after first loop and no swdl is made. Set ACTIVE_SW_T1
    ...   to point current active build and ACTIVE_SW to point software on passive side.
    ${P_SW}=  Get Passive Sw Of Bts
    Set Suite Variable                    ${ACTIVE_SW_T1}   ${ACTIVE_SW}
    Set Suite Variable                    ${ACTIVE_SW}   ${P_SW}
# Rollback from ${ACTIVE_SW_T1} SW to ${ACTIVE_SW} SW
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
