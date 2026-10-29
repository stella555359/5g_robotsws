*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Variables ***
${RU_SWDL}                ${True}
${WAIT_BETWEEN_SWDLS}     60


*** Keywords ***
OMKPI Independent DU SW Upgrade
    [Documentation]  Compare given release to SW that is active on BTS and select if the software download
    ...              should be inter or intra. First upgrade software to RUs and calculate KPIs, then upgrade software to DU.
    ...              NOTE If UPDATE_PATH or UUF_CUSTOMER or UUF_BUILD TAG has been given during reservation, RELEASE
    ...              and PROMOTION_TAG are ignored.
    ...              NOTE If RELEASE variable is empty and no UPDATE_PATH/UUF_CUSTOMER/UUF_BUILD TAG has been given during
    ...              reservation, always selects Intra SWDL.
    ...              NOTE if BASE_BUILD variable given in test/reservation downloads it as an older build.
    [Arguments]      ${SAVE_BUILD_TO_PC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    ...              ${RELEASE}  ${PROMOTION_TAG}  ${LMP_SWDL}  ${OAM_KPI_TARGETS}  ${SELECTED_KPI}
    Run Keyword And Continue On Failure   COLLECTLOGS.Give Command To Terminal  sudo rm -rf /home/ute/MN/UTE/robotlte
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
    Run Keyword If  '${OLDER_SW_BUILD}' != '${EMPTY}' and '${CURRENT_LOOP}' == '${1}'  Run Keywords    Run Keyword and Continue On Failure
    ...  Update SW LMP or S1  ${OLDER_SW_BUILD}  normal build  ${STEP}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${LMP_SWDL}   AND
    ...  Run Keyword And Continue On Failure    Wait Time And Reason   ${WAIT_BETWEEN_SWDLS}   before starting T1 SWDL
    Run Keyword If  '${OLDER_SW_BUILD}' == '${EMPTY}'  Set Suite Variable  ${OLDER_SW_BUILD}  ${ACTIVE_SW}

    Run Keyword If  '${ROLLBACKS}' == '${False}'  Run Keyword and Continue On Failure
    ...   Upgrade SW build  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${STEP}  ${UNALLOWED_SYSLOGS}  ${LMP_SWDL}  ${OAM_KPI_TARGETS}  ${SELECTED_KPI}
    Run Keyword If  '${ROLLBACKS}' == '${True}'  Run Keyword and Continue On Failure
    ...   Upgrade SW build On Older Build  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${STEP}  ${UNALLOWED_SYSLOGS}  ${LMP_SWDL}
    ...   ${OAM_KPI_TARGETS}  ${SELECTED_KPI}  ${BUILD_T1}  ${BUILD_T2}  ${BUILD_N}  ${OLDER_SW_BUILD}

    Run Keyword And Continue On Failure   Stop Background Syslog Print Search

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
