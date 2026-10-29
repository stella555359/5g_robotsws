*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Variables ***
${WAIT_BETWEEN_SWDLS}     0

*** Keywords ***
OMKPI SW DL
    [Documentation]  OMKPI SW DL compare given release to SW that is active on BTS and select if the software download
    ...              should be inter or intra.
    ...              NOTE If UPDATE_PATH or UUF_CUSTOMER or UUF_BUILD TAG has been given during reservation, RELEASE
    ...              and PROMOTION_TAG are ignored.
    ...              NOTE If RELEASE variable is empty and no UPDATE_PATH/UUF_CUSTOMER/UUF_BUILD TAG has been given during
    ...              reservation, always selects Intra SWDL.
    ...              NOTE if BASE_BUILD variable given in test/reservation downloads it as an older build.
    [Arguments]      ${SAVE_BUILD_TO_PC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    ...              ${RELEASE}  ${PROMOTION_TAG}  ${LMP_SWDL}  ${OAM_KPI_TARGETS}  ${SELECTED_KPI}
    Run Keyword And Continue On Failure   COLLECTLOGS.Give Command To Terminal  sudo rm -rf /home/ute/MN/UTE/robotlte
    Run Keyword And Continue On Failure   COLLECTLOGS.Give Command To Terminal  sudo rm -rf /home/ute/.ute-ca/cache/*
    Run Keyword And Continue On Failure   COLLECTLOGS.Give Command To Terminal  sudo rm -rf $HOME/.local/share/Trash/*
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background     ${SYSLOG_LIST}
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase  0
    Print Step Text                       ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
#    Run Keyword And Continue On Failure   Check If Netboot Is Active And Deactivate It
    ${ACTIVE_SW}=                         Get Active SW Of Bts
    ${BRANCH_OF_ACTIVE_SW}=               Get Branch Of Active Build
    ${update_path_build}=                 Get Build Used In Update Path Tag
    ${customer}=                          Get Customer Build Used In Tag
    ${uuf_build}=                         Get Uuf Build Used In Tag
    Run Keyword                           Set Build Names And Get Packages That Will Be Used In Swdl
    ...                                   ${BRANCH_OF_ACTIVE_SW}  ${SAVE_BUILD_TO_PC}  ${update_path_build}  ${customer}  ${uuf_build}
    ${ROLLBACKS}=                         Check If SWDL Intra Or Inter And If Rollbacks In Test
    ...                                   release=${RELEASE}  promotion_tag=${PROMOTION_TAG}  save_to_pc=${SAVE_BUILD_TO_PC}
    ${OLDER_SW_BUILD}=                    Get Older Build Path
    ${CURRENT_LOOP}=                      Current Test Loop
    IF  '${OLDER_SW_BUILD}' != '${EMPTY}' and '${CURRENT_LOOP}' == '${1}'
        Run Keywords    Run Keyword and Continue On Failure
    ...  Update SW LMP or S1  ${OLDER_SW_BUILD}  normal build  ${STEP}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${LMP_SWDL}   AND
    ...  Run Keyword And Continue On Failure    Wait Time And Reason   ${WAIT_BETWEEN_SWDLS}   before starting T1 SWDL
    END
    IF  '${OLDER_SW_BUILD}' == '${EMPTY}'
        Set Suite Variable  ${OLDER_SW_BUILD}  ${ACTIVE_SW}
    END
    IF  '${ROLLBACKS}' == '${False}'
        Run Keyword and Continue On Failure  Upgrade SW build  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${STEP}
        ...     ${UNALLOWED_SYSLOGS}  ${LMP_SWDL}  ${OAM_KPI_TARGETS}  ${SELECTED_KPI}
    ELSE IF    '${ROLLBACKS}' == '${True}'
        Run Keyword and Continue On Failure  Upgrade SW build On Older Build  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${STEP}
    ...    ${UNALLOWED_SYSLOGS}  ${LMP_SWDL}  ${OAM_KPI_TARGETS}  ${SELECTED_KPI}  ${BUILD_T1}  ${BUILD_T2}  ${BUILD_N}  ${OLDER_SW_BUILD}
    END
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}


OMKPI SW DL One Package
    [Documentation]  OMKPI SW DL One Package updates given build SW to SMOD(s) and calculates KPIs.
    [Arguments]      ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}   ${LMP_SWDL}  ${OAM_KPI_TARGETS}
    ...              ${SELECTED_KPI}  ${ONE_BUILD}
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background     ${SYSLOG_LIST}
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    0
    ${BUILD}=   Get Build given As One_build Argument    ${ONE_BUILD}
    Run Keyword And Continue On Failure    Check If Build In Passive Side Is Same That Is Planned To Be Downloaded
    ...                                    ${BUILD}    switch_order=${False}
    Run Keyword And Continue On Failure    Check If Swdl Of Build Will Be Intra Or Inter  ${BUILD}
    ${RU_SWDL}=      Get Variable Value  ${RU_SWDL}  ${False}
# Check if ru swdl and run test
    Run Keyword If   '${RU_SWDL}' == '${True}'  Run Keyword And Continue On Failure
    ...  Log Folders And Radio Software Update   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}
    ...                                          ${BUILD}   OneBuild   No_KPI55
    Run Keyword and Continue On Failure    Update SW LMP or S1 And Make Checks  ${BUILD}  ${ONE_BUILD}  ${STEP}  ${WAIT_CHECKS}
    ...                                    ${WAIT_FOR_CELLS_UP}  ${LMP_SWDL}  ${OAM_KPI_TARGETS}  ${SELECTED_KPI}
    ${other_master_lmp_swdl_test}=    Get Variable Value   ${OTHER_MASTER_LMP_SWDL}   ${False}
    IF   '${other_master_lmp_swdl_test}' == '${True}'
        ${log_collection}=  Logs Should Be Collected
        IF  '${log_collection}' == '${True}'
            Run Keyword and Continue On Failure    Get Admin Logs From Other To Test Logs
        END
    END
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Run Keyword And Continue On Failure   Get E2e Startup Points From Syslog And Snapshot
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

