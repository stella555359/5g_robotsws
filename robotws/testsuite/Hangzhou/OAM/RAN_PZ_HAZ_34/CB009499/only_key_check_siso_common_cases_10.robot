*** Settings ***
Documentation
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    to define SG07 COMMON SISO Cased

Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/oam_common.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/resource.py

Suite Setup   Siso Common Suite Setup
Suite Teardown   Siso Common Suite Teardown


*** Variables ***
${retry_times}    10


*** Test Cases ***
siso_common_cell_reset
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_cell_reset
   FOR   ${index}    IN RANGE    ${retry_times}
       log to console     //this is index：${index} time do ALL Cells Reset...
       All Cells Reset     keycheck=${True}
    END
    [Teardown]   Case Teardown:siso_common_cell_reset


siso_common_cell_lock_unlock_via_CM
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_cell_lock_unlock
   FOR   ${index}    IN RANGE    ${retry_times}
       log to console     //this is index：${index} time do ALL Cells lock unlock...
       All Cells lock unlock cells     keycheck=${True}
    END
    [Teardown]   Case Teardown:siso_common_cell_lock_unlock

siso_common_cell_Block_unBlock_via_Button
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_cell_lock_unlock
    FOR   ${index}    IN RANGE    ${retry_times}
       log to console     //this is index：${index} time do ALL Cells Block unBlock...
       All Cells block unblock cells     keycheck=${True}
    END
    [Teardown]   Case Teardown:siso_common_cell_lock_unlock


siso_common_RU_reset
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_RU_reset
   FOR   ${index}    IN RANGE    ${retry_times}
       log to console     //this is index：${index} time do ALL RUs reset...
       ALL RUs reset     keycheck=${True}
    END
    [Teardown]   Case Teardown:siso_common_RU_reset


siso_common_RU_Lock_Unlock
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_RU_Lock_Unlock
   FOR   ${index}    IN RANGE    ${retry_times}
       log to console     //this is index：${index} time do ALL RUs Lock Unlock...
       ALL RUs Lock Unlock     keycheck=${True}
    END
    [Teardown]   Case Teardown:siso_common_RU_Lock_Unlock


siso_common_bbmod_reset
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_bbmod_reset
   FOR   ${index}    IN RANGE    ${retry_times}
       log to console     //this is index：${index} time do All BBMODs Reset...
       All BBMODs Reset     keycheck=${True}
    END
    [Teardown]   Case Teardown:siso_common_bbmod_reset


siso_common_bbmod_Lock_Unlock
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_bbmod_Lock_Unlock
   FOR   ${index}    IN RANGE    ${retry_times}
       log to console     //this is index：${index} time do All BBMODs Lock UnLock...
       All BBMODs Lock UnLock     keycheck=${True}
    END
    [Teardown]   Case Teardown:siso_common_bbmod_Lock_Unlock


siso_common_rat_reset
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_rat_reset
   FOR   ${index}    IN RANGE    ${retry_times}
       log to console     //this is index：${index} time do All RAT Reset...
       All RAT Reset     keycheck=${True}
    END
    [Teardown]   Case Teardown:siso_common_rat_reset


siso_common_rat_Block_Unblock
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_rat_reset
   FOR   ${index}    IN RANGE    ${retry_times}
       log to console     //this is index：${index} time do ALL RAT BLOCK UNBLOCK...
       All RAT Block Unblock     keycheck=${True}
    END
    [Teardown]   Case Teardown:siso_common_rat_reset


siso_common_DU_Lock_Unlock
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_DU_Lock_Unlock
   FOR   ${index}    IN RANGE    ${retry_times}
       log to console     //this is index：${index} time do NRDU LOCK UNLOCK...
       All NRDU Lock Unlock     keycheck=${True}
    END
    [Teardown]   Case Teardown:siso_common_DU_Lock_Unlock

siso_common_Commission
   [Timeout]  8h
   [Setup]   Case Setup:siso_common_Commission
   FOR   ${index}    IN RANGE    ${retry_times}
       log to console     //this is index：${index} time do common Commission...
       All Site Commissioning     keycheck=${True}
    END
    [Teardown]    Case Teardown:siso_common_Commission


siso_common_Power_Reset
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_Power_Reset
   FOR   ${index}    IN RANGE    ${retry_times}
       log to console     //this is index：${index} time do power reset...
       All Site Power Reset     keycheck=${True}
    END
    [Teardown]    Case Teardown:siso_common_Power_Reset


siso_common_check_PDL_Rule
   [Timeout]  1h
   [Setup]    Wait Until Keyword Succeeds    2m   30s   COAM Login
   COAM Check Validation Error
   [Teardown]   run keywords    Siso Common Save Logs   AND    COAM Logout


*** Keywords ***
Case Setup:siso_common_cell_reset
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List
     set test variable    ${nr_cell_list}
     set test variable    ${lte_cell_list}
     Recovery At Case Setup if Fault Occurs
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair

Case Teardown:siso_common_cell_reset
    LOG     //Case Teardown:siso_common_cell_reset
    Siso Common Save Logs
     [Teardown]    Run Keyword And Ignore Error    COAM Logout

Case Setup:siso_common_cell_lock_unlock
    Wait Until Keyword Succeeds    2m   30s   COAM Login
     ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List
     set test variable    ${nr_cell_list}
     set test variable    ${lte_cell_list}
     Recovery At Case Setup if Fault Occurs
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

Case Teardown:siso_common_cell_lock_unlock
     Siso Common Save Logs
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
     [Teardown]    Run Keyword And Ignore Error    COAM Logout

Case Setup:siso_common_RU_reset
    LOG     //Case Setup:siso_common_RU_reset
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    Recovery At Case Setup if Fault Occurs
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair

Case Teardown:siso_common_RU_reset
    Siso Common Save Logs
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
     [Teardown]    Run Keyword And Ignore Error    COAM Logout

Case Setup:siso_common_RU_Lock_Unlock
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    Recovery At Case Setup if Fault Occurs
    FOR     ${RU}     IN     @{rmod_serial_mapping}
        run keyword and ignore error     COAM Unlock RU    dist_name=${rmod_serial_mapping['${RU}']['configDN']}
    END
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair

Case Teardown:siso_common_RU_Lock_Unlock
    Siso Common Save Logs
    FOR     ${RU}     IN     @{rmod_serial_mapping}
        run keyword and ignore error     COAM Unlock RU    dist_name=${rmod_serial_mapping['${RU}']['configDN']}
    END
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
     [Teardown]    Run Keyword And Ignore Error    COAM Logout

Case Setup:siso_common_bbmod_reset
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    Recovery At Case Setup if Fault Occurs
    ${bbmod_mapping}     Siso Common Get BBMOD Mapping RMOD    source=${siso_scf_xml}
    ${bbmod_cell_mapping}    Siso Common Get BBMOD Mapping Cell     source=${siso_scf_xml}
    ${bbmods_info}     Get BBMODs info
    set test variable     ${bbmod_mapping}
    set test variable     ${bbmods_info}
    set test variable     ${bbmod_cell_mapping}
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair

Case Teardown:siso_common_bbmod_reset
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    Run Keyword And Ignore Error    COAM Logout

Case Setup:siso_common_bbmod_Lock_Unlock
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    Recovery At Case Setup if Fault Occurs
    ${bbmod_mapping}     Siso Common Get BBMOD Mapping RMOD    source=${siso_scf_xml}
    ${bbmod_cell_mapping}    Siso Common Get BBMOD Mapping Cell     source=${siso_scf_xml}
    ${bbmods_info}     Get BBMODs info
    set test variable     ${bbmod_mapping}
    set test variable     ${bbmods_info}
    set test variable     ${bbmod_cell_mapping}
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair


Case Teardown:siso_common_bbmod_Lock_Unlock
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    Siso Common Save Logs
    FOR     ${bbmod}     IN     @{bbmods_info}
        run keyword and ignore error    COAM Unlock BBMOD      dist_name=${bbmod['internal']}
    END
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    Run Keyword And Ignore Error    COAM Logout


Case Setup:siso_common_rat_reset
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    Recovery At Case Setup if Fault Occurs
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

Case Teardown:siso_common_rat_reset
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    Run Keyword And Ignore Error    COAM Logout

Case Setup:siso_common_rat_Block_Unblock
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    Recovery At Case Setup if Fault Occurs
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


Case Teardown:siso_common_rat_Block_Unblock
     Siso Common Save Logs
    FOR     ${rat}     IN     @{rat_list}
        run keyword and ignore error    COAM Unlock Rat      rat_type=${rat}
     END
     Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    Run Keyword And Ignore Error    COAM Logout


Case Setup:siso_common_DU_Lock_Unlock
    Wait Until Keyword Succeeds    2m   30s   COAM Login
     Recovery At Case Setup if Fault Occurs
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

Case Teardown:siso_common_DU_Lock_Unlock
      ${nrdu_objlist}   XML.Get Elements   ${siso_scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRDU"]
      FOR    ${nrdu}    IN    @{nrdu_objlist}
         ${nrdu_dn}   XML.Get Element Attribute   ${nrdu}   distName
         COAM Unlock NRDU     distname=${nrdu_dn}
      END
      Wait Until Keyword Succeeds   20m   10s   Rat Cell should Enabled and Mplane Check     rat=nr
     [Teardown]    Run Keyword And Ignore Error    COAM Logout

Case Setup:siso_common_Commission
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     Recovery At Case Setup if Fault Occurs
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair

Case Teardown:siso_common_Commission
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    Run Keyword And Ignore Error    COAM Logout

Case Setup:siso_common_Power_Reset
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     Recovery At Case Setup if Fault Occurs
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair

Case Teardown:siso_common_Power_Reset
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    Run Keyword And Ignore Error    COAM Logout

