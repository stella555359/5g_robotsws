*** Settings ***
Documentation
    ...    Author: lei.24.wang@nokia-sbell.com
    ...    to define SG07 COMMON SISO Cased

Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/oam_common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/resource.py

Suite Setup   Siso Common Suite Setup for UTE
Suite Teardown   Siso Common Suite Teardown
Test Setup   robot_common_operations.Common Case Setup
Test Teardown   robot_common_operations.Common Case Teardown

*** Variables ***
@{ALL_TEST_STATUS}
${PREV_TEST_STATUS}

*** Test Cases ***
[1]CB012842_AWHHK_siso_common
   [Tags]   24R3
   AlarmWatchdog.add_allow_alarms    fault_id=49
   run keyword and continue on failure   siso_common_RU_reset
   run keyword and continue on failure   siso_common_RU_Lock_Unlock


*** Keywords ***
siso_common_RU_reset
   [Timeout]  2h
   Case Setup:siso_common_RU_reset
   Wait Until Keyword Succeeds    3x  20s   COAM Login
   FOR   ${index}    IN RANGE    ${5}
       log to console     //this is index：${index} time do ALL RUs reset...
       ALL RUs reset
   END
   [Teardown]   Run keywords   Case Teardown:siso_common_RU_reset
   ...   AND   run keyword and ignore error    COAM Logout

siso_common_RU_Lock_Unlock
   [Timeout]  2h
   Case Setup:siso_common_RU_Lock_Unlock
   Wait Until Keyword Succeeds    3x  20s   COAM Login
   FOR   ${index}    IN RANGE    ${5}
       log to console     //this is index：${index} time do ALL RUs Lock Unlock...
       ALL RUs Lock Unlock
   END
   [Teardown]   Run keywords   Case Teardown:siso_common_RU_Lock_Unlock
   ...   AND   run keyword and ignore error    COAM Logout


Case Setup:siso_common_cell_reset
     Set test Variable    ${Siso_Common_LOG_PATH}   ${OUTPUT_DIR}/siso_common_cell_reset
     Wait Until Keyword Succeeds    3x  20s   COAM Login
     ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List
     set test variable    ${nr_cell_list}
     set test variable    ${lte_cell_list}
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
     [Teardown]    run keyword and ignore error    COAM Logout


Case Teardown:siso_common_cell_reset
    LOG     //Case Teardown:siso_common_cell_reset
    Siso Common Save Logs


Case Setup:siso_common_cell_lock_unlock
     Set test Variable    ${Siso_Common_LOG_PATH}   ${OUTPUT_DIR}/siso_common_cell_lock_unlock
     Wait Until Keyword Succeeds    3x  20s   COAM Login
     ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List
     set test variable    ${nr_cell_list}
     set test variable    ${lte_cell_list}
     FOR    ${nrcell}    IN     ${nr_cell_list}
         run keyword and ignore error
         ...     COAM Lock unclock Cell via Change Parameter    celltype=nr    cellid=${cell['globalCellId']}    operation=Unlocked
         run keyword and ignore error
         ...     ADMIN UnBlock NR cell and check status      cell_index=${cell['globalCellId']}
     END
     FOR    ${ltecell}    IN     ${lte_cell_list}
         run keyword and ignore error
         ...     COAM Lock unclock Cell via Change Parameter    celltype=lte    cellid=${cell['globalCellId']}    operation=Unlocked
         run keyword and ignore error
         ...     ADMIN UnBlock LTE cell and check status     cell_index=${cell['globalCellId']}
     END
      Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
      [Teardown]    run keyword and ignore error    COAM Logout


Case Teardown:siso_common_cell_lock_unlock
     Siso Common Save Logs
     Wait Until Keyword Succeeds    3x  20s   COAM Login
     FOR    ${nrcell}    IN     ${nr_cell_list}
         run keyword and ignore error
         ...     COAM Lock unclock Cell via Change Parameter    celltype=nr    cellid=${nrcell['globalCellId']}    operation=Unlocked
         run keyword and ignore error
         ...     ADMIN UnBlock NR cell and check status      cell_index=${nrcell['globalCellId']}
     END
     FOR    ${ltecell}    IN     ${lte_cell_list}
         run keyword and ignore error
         ...     COAM Lock unclock Cell via Change Parameter    celltype=lte    cellid=${ltecell['globalCellId']}    operation=Unlocked
         run keyword and ignore error
         ...     ADMIN UnBlock LTE cell and check status     cell_index=${ltecell['globalCellId']}
     END
     Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    run keyword and ignore error    COAM Logout


Case Setup:siso_common_RU_reset
     Set test Variable    ${Siso_Common_LOG_PATH}   ${OUTPUT_DIR}/siso_common_RU_reset
    LOG     //Case Setup:siso_common_RU_reset
    Wait Until Keyword Succeeds    3x  20s  COAM Login
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
    [Teardown]    run keyword and ignore error    COAM Logout

Case Teardown:siso_common_RU_reset
    Siso Common Save Logs
    Wait Until Keyword Succeeds    3x  20s  COAM Login
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
    [Teardown]    run keyword and ignore error    COAM Logout

Case Setup:siso_common_RU_Lock_Unlock
     Set test Variable    ${Siso_Common_LOG_PATH}   ${OUTPUT_DIR}/siso_common_RU_Lock_Unlock
    Wait Until Keyword Succeeds    3x  20s  COAM Login
    FOR     ${RU}     IN     @{rmod_serial_mapping}
        run keyword and ignore error     COAM Unlock RU    dist_name=${rmod_serial_mapping['${RU}']['configDN']}
    END
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
    [Teardown]    run keyword and ignore error    COAM Logout

Case Teardown:siso_common_RU_Lock_Unlock
    Siso Common Save Logs
    Wait Until Keyword Succeeds    3x  20s  COAM Login
    FOR     ${RU}     IN     @{rmod_serial_mapping}
        run keyword and ignore error     COAM Unlock RU    dist_name=${rmod_serial_mapping['${RU}']['configDN']}
    END
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
    [Teardown]    run keyword and ignore error    COAM Logout



Case Setup:siso_common_bbmod_reset
     Set test Variable    ${Siso_Common_LOG_PATH}   ${OUTPUT_DIR}/siso_common_bbmod_reset
#    COAM WEBUI Login
    Wait Until Keyword Succeeds    3x  20s   COAM Login
    ${bbmod_mapping}     Siso Common Get BBMOD Mapping RMOD    source=${siso_scf_xml}
    ${bbmod_cell_mapping}    Siso Common Get BBMOD Mapping Cell     source=${siso_scf_xml}
    ${bbmods_info}     Get BBMODs info
    set test variable     ${bbmod_mapping}
    set test variable     ${bbmods_info}
    set test variable     ${bbmod_cell_mapping}
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
    [Teardown]    run keyword and ignore error    COAM Logout


Case Teardown:siso_common_bbmod_reset
    Wait Until Keyword Succeeds    3x  20s  COAM Login
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
#    COAM WEBUI Logout
    [Teardown]    run keyword and ignore error    COAM Logout


Case Setup:siso_common_bbmod_Lock_Unlock
     Set test Variable    ${Siso_Common_LOG_PATH}   ${OUTPUT_DIR}/siso_common_bbmod_Lock_Unlock
    Wait Until Keyword Succeeds    3x  20s   COAM Login
    ${bbmod_mapping}     Siso Common Get BBMOD Mapping RMOD    source=${siso_scf_xml}
    ${bbmod_cell_mapping}    Siso Common Get BBMOD Mapping Cell     source=${siso_scf_xml}
    ${bbmods_info}     Get BBMODs info
    set test variable     ${bbmod_mapping}
    set test variable     ${bbmods_info}
    set test variable     ${bbmod_cell_mapping}
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
    [Teardown]    run keyword and ignore error    COAM Logout


Case Teardown:siso_common_bbmod_Lock_Unlock
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    Siso Common Save Logs
    Wait Until Keyword Succeeds    3x  20s   COAM Login
    FOR     ${bbmod}     IN     @{bbmods_info}
        run keyword and ignore error    COAM Unlock BBMOD      dist_name=${bbmod['internal']}
    END
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
    [Teardown]    run keyword and ignore error    COAM Logout



Case Setup:siso_common_rat_reset
     Set test Variable    ${Siso_Common_LOG_PATH}   ${OUTPUT_DIR}/siso_common_rat_reset
    Wait Until Keyword Succeeds    3x  20s   COAM Login
    ${btsinfo}     COAM Get BTS Info
#    ${cells_info}     Get Dictionary Values    ${btsinfo['cells']}
    ${rat_list}     Create List
    FOR    ${rat}    IN    @{btsinfo['cells']}
        ${isempty}     run keyword and return status     should be empty    ${btsinfo['cells']['${rat}']}
        continue for loop if     ${isempty}
        Append to list     ${rat_list}     ${rat}
     END
     ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List
     Set test variable     ${rat_list}
     Set test variable     ${nr_cell_list}
     Set test variable     ${lte_cell_list}
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
     [Teardown]    run keyword and ignore error    COAM Logout


Case Teardown:siso_common_rat_reset
    Siso Common Save Logs
    Wait Until Keyword Succeeds    3x  20s   COAM Login
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
    [Teardown]    run keyword and ignore error    COAM Logout


Case Setup:siso_common_rat_Block_Unblock
     Set test Variable    ${Siso_Common_LOG_PATH}   ${OUTPUT_DIR}/siso_common_rat_Block_Unblock
    Wait Until Keyword Succeeds    3x  20s   COAM Login
    ${btsinfo}     COAM Get BTS Info
#    ${cells_info}     Get Dictionary Values    ${btsinfo['cells']}
    ${rat_list}     Create List
    FOR    ${rat}    IN    @{btsinfo['cells']}
        ${isempty}     run keyword and return status     should be empty    ${btsinfo['cells']['${rat}']}
        continue for loop if     ${isempty}
        Append to list     ${rat_list}     ${rat}
     END
     ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List
     Set test variable     ${rat_list}
     Set test variable     ${nr_cell_list}
     Set test variable     ${lte_cell_list}
     FOR     ${rat}     IN     @{rat_list}
        run keyword and ignore error    COAM Unlock Rat      rat_type=${rat}
     END
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
     [Teardown]    run keyword and ignore error    COAM Logout


Case Teardown:siso_common_rat_Block_Unblock
    Siso Common Save Logs
    Wait Until Keyword Succeeds    3x  20s   COAM Login
    FOR     ${rat}     IN     @{rat_list}
        run keyword and ignore error    COAM Unlock Rat      rat_type=${rat}
     END
     Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    run keyword and ignore error    COAM Logout


Case Setup:siso_common_DU_Lock_Unlock
     Set test Variable    ${Siso_Common_LOG_PATH}   ${OUTPUT_DIR}/siso_common_DU_Lock_Unlock
     Wait Until Keyword Succeeds    3x  20s   COAM Login
     ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List
     ${btsinfo}     COAM Get BTS Info
     ${rat_list}     Create List
     FOR    ${rat}    IN    @{btsinfo['cells']}
        ${isempty}     run keyword and return status     should be empty    ${btsinfo['cells']['${rat}']}
        continue for loop if     ${isempty}
        Append to list     ${rat_list}     ${rat}
     END
     Set test variable     ${rat_list}
     Set test variable     ${nr_cell_list}
     Set test variable     ${lte_cell_list}
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
     [Teardown]    run keyword and ignore error    COAM Logout

Case Teardown:siso_common_DU_Lock_Unlock
      Siso Common Save Logs
      ${nrdu_objlist}   XML.Get Elements   ${siso_scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRDU"]
      FOR    ${nrdu}    IN    @{nrdu_objlist}
         ${nrdu_dn}   XML.Get Element Attribute   ${nrdu}   distName
         COAM Unlock NRDU     distname=${nrdu_dn}
      END
      Wait Until Keyword Succeeds   20m   10s   Rat Cell should Enabled and Mplane Check     rat=nr

Case Setup:siso_common_Commission
     Set test Variable    ${Siso_Common_LOG_PATH}   ${OUTPUT_DIR}/siso_common_Commission
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair

Case Teardown:siso_common_Commission
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair

Case Setup:siso_common_Power_Reset
     Set test Variable    ${Siso_Common_LOG_PATH}   ${OUTPUT_DIR}/siso_common_Power_Reset
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair

Case Teardown:siso_common_Power_Reset
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair