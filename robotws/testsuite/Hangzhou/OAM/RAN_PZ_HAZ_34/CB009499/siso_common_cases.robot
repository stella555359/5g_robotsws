*** Settings ***
Documentation
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    to define SG07 COMMON SISO Cased

Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/oam_common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/resource.py

Suite Setup   Siso Common Suite Setup
Suite Teardown   Siso Common Suite Teardown

*** Variables ***
${times}    5

*** Test Cases ***
siso_common_check_PDL_Rule
   [Timeout]  1h
   [Setup]    Wait Until Keyword Succeeds    2m   30s   COAM Login
   COAM Check Validation Error
   [Teardown]   run keywords    Siso Common Save Logs   AND    COAM Logout


siso_common_cell_reset
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_cell_reset
   FOR   ${index}    IN RANGE    ${times}
       log to console     //this is index：${index} time do ALL Cells Reset...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['cell_reset']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
        ${lte_cell_operation}   Set Variable If
        ...   "${tl.gnbs[0].global_bts_id}" in ${LTE_CELL_NOT_OPERATION_TL}   ${False}
        ...   ${True}
       All Cells Reset   lte_cell_operation=${lte_cell_operation}
    END
    [Teardown]   Case Teardown:siso_common_cell_reset


#siso_common_cell_lock_unlock_via_CM
#   [Timeout]  8h
#   [Setup]    Case Setup:siso_common_cell_lock_unlock
#   FOR   ${index}    IN RANGE    ${5}
#       log to console     //this is index：${index} time do ALL Cells lock unlock...
#       ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['cell_lock_unlock']}    ${False}
#        set test variable    ${rulog_exist}
#        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
#       All Cells lock unlock cells
#    END
#    [Teardown]   Case Teardown:siso_common_cell_lock_unlock

siso_common_cell_Block_unBlock_via_Button
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_cell_lock_unlock
    FOR   ${index}    IN RANGE    ${times}
       log to console     //this is index：${index} time do ALL Cells Block unBlock...
       ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['cell_block_unblock']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       All Cells block unblock cells
    END
    [Teardown]   Case Teardown:siso_common_cell_lock_unlock


siso_common_RU_reset
   [Timeout]  16h
   [Setup]    Case Setup:siso_common_RU_reset
   FOR   ${index}    IN RANGE    ${times}
       continue for loop if    '${tl.gnbs[0].global_bts_id}' in @{RU_ignore_TL}
       log to console     //this is index：${index} time do ALL RUs reset...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['ru_reset']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       ALL RUs reset
    END
    [Teardown]   Case Teardown:siso_common_RU_reset


siso_common_RU_Lock_Unlock
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_RU_Lock_Unlock
   FOR   ${index}    IN RANGE    ${times}
       continue for loop if    '${tl.gnbs[0].global_bts_id}' in @{RU_ignore_TL}
       log to console     //this is index：${index} time do ALL RUs Lock Unlock...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['ru_lock_unlock']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       ALL RUs Lock Unlock
    END
    [Teardown]   Case Teardown:siso_common_RU_Lock_Unlock


siso_common_bbmod_reset_without_graceful_cell_shutdown
   [Timeout]  16h
   [Setup]    Case Setup:siso_common_bbmod_reset
   FOR   ${index}    IN RANGE    ${times}
       continue for loop if    '${tl.gnbs[0].global_bts_id}' in @{BB_ignore_TL}
       log to console     //this is index：${index} time do All BBMODs Reset...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['bbmod_reset']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       All BBMODs Reset
    END
    [Teardown]   Case Teardown:siso_common_bbmod_reset


siso_common_bbmod_reset_with_graceful_cell_shutdown
   [Timeout]  16h
   [Setup]    Case Setup:siso_common_bbmod_reset
   FOR   ${index}    IN RANGE    ${times}
       continue for loop if    '${tl.gnbs[0].global_bts_id}' in @{BB_ignore_TL}
       log to console     //this is index：${index} time do All BBMODs Reset...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['bbmod_reset']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       All BBMODs Reset    graceful_cell_shutdown=${True}
    END
    [Teardown]   Case Teardown:siso_common_bbmod_reset


siso_common_bbmod_power_reset
   [Timeout]  16h
   [Setup]    Case Setup:siso_common_bbmod_reset
   FOR   ${index}    IN RANGE    ${times}
       continue for loop if    '${tl.gnbs[0].global_bts_id}' in @{BB_ignore_TL}
       log to console     //this is index：${index} time do All BBMODs Reset...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['bbmod_reset']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       All BBMODs Reset    reset_type=PowerReset    graceful_cell_shutdown=${True}
    END
    [Teardown]   Case Teardown:siso_common_bbmod_reset


siso_common_bbmod_Lock_Unlock
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_bbmod_Lock_Unlock
   FOR   ${index}    IN RANGE    ${times}
       continue for loop if    '${tl.gnbs[0].global_bts_id}' in @{BB_ignore_TL}
       log to console     //this is index：${index} time do All BBMODs Lock UnLock...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['bbmod_lock_unlock']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       All BBMODs Lock UnLock
    END
    [Teardown]   Case Teardown:siso_common_bbmod_Lock_Unlock


siso_common_rat_reset_actRATResetEnhancement_False
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_rat_reset_actRATResetEnhancement_False
   FOR   ${index}    IN RANGE    ${times}
       log to console     //this is index：${index} time do All RAT Reset with actRATResetEnhancement=False...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['rat_reset']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       run keyword if   '${release}'<'SBTS25R3'    All RAT Reset
    END
    [Teardown]   Case Teardown:siso_common_rat_reset_actRATResetEnhancement_False


siso_common_rat_reset_actRATResetEnhancement_True
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_rat_reset_actRATResetEnhancement_True
   FOR   ${index}    IN RANGE    ${times}
       log to console     //this is index：${index} time do All Soft RAT Reset with actRATResetEnhancement=True...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['rat_reset']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       run keyword if   '${release}'>='SBTS24R3'    All Soft RAT Reset with actRATResetEnhancement True
    END

#    FOR   ${index}    IN RANGE    ${times}
#       log to console     //this is index：${index} time do All Hard RAT Reset with actRATResetEnhancement=True...
#       All Hard RAT Reset with actRATResetEnhancement True
#    END
    [Teardown]   Case Teardown:siso_common_rat_reset_actRATResetEnhancement_True


siso_common_rat_Block_Unblock
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_rat_Block_unBlock
   FOR   ${index}    IN RANGE    ${times}
       log to console     //this is index：${index} time do ALL RAT BLOCK UNBLOCK...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['rat_block_unblock']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       All RAT Block Unblock
    END
    [Teardown]   Case Teardown:siso_common_rat_Block_unBlock


siso_common_DU_Lock_Unlock
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_DU_Lock_Unlock
   FOR   ${index}    IN RANGE    ${times}
       log to console     //this is index：${index} time do NRDU LOCK UNLOCK...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['du_lock_unlock']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       All NRDU Lock Unlock
    END
    [Teardown]   Case Teardown:siso_common_DU_Lock_Unlock


siso_common_Commission
   [Timeout]  8h
   [Setup]   Case Setup:siso_common_Commission
   FOR   ${index}    IN RANGE    ${times}
       log to console     //this is index：${index} time do common Commission...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['commission']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       All Site Commissioning
    END
    [Teardown]    Case Teardown:siso_common_Commission


siso_common_Power_Reset
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_Power_Reset
   FOR   ${index}    IN RANGE    ${times}
       log to console     //this is index：${index} time do power reset...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['power_reset']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       All Site Power Reset
    END
    [Teardown]    Case Teardown:siso_common_Power_Reset


*** Keywords ***
Case Setup:siso_common_cell_reset
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     Recovery At Case Setup if Fault Occurs
     ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List
     set test variable    ${nr_cell_list}
     set test variable    ${lte_cell_list}
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair


Case Teardown:siso_common_cell_reset
    LOG     //Case Teardown:siso_common_cell_reset
    Siso Common Save Logs
    [Teardown]    COAM Logout


Case Setup:siso_common_cell_lock_unlock
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     Recovery At Case Setup if Fault Occurs
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
     [Teardown]    COAM Logout



Case Setup:siso_common_RU_reset
    LOG     //Case Setup:siso_common_RU_reset
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    Recovery At Case Setup if Fault Occurs
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair

Case Teardown:siso_common_RU_reset
    Siso Common Save Logs
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
     [Teardown]    COAM Logout


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
     [Teardown]    COAM Logout


Case Setup:siso_common_bbmod_reset
   ${egen_exist}    run keyword if   '${tl.gnbs[0].global_bts_id}' in @{egen_TL}    Set Variable    ${True}    ${False}
   ${ipcapture_exist}    set variable if   '${tl.gnbs[0].global_bts_id}' in @{ipcapture_TL}    ${True}    ${False}
   set test variable    ${egen_exist}
   set test variable    ${ipcapture_exist}
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    Recovery At Case Setup if Fault Occurs
    COAM Backup Full SCF   file_name=siso_scf_bbmod_reset.xml
    ${bbmodreset_siso_scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/siso_scf_bbmod_reset.xml
    ${rmod_cell_mapping}    ${cell_num}    UUF Get RMOD SN Cell Mapping From Full SCF    source=${bbmodreset_siso_scf_xml}
    ${rmod_serial_mapping}    UUF Get RMOD SerialNumber Mapping    source=${bbmodreset_siso_scf_xml}
    ${bbmod_mapping}     Siso Common Get BBMOD Mapping RMOD    source=${bbmodreset_siso_scf_xml}
    ${bbmod_cell_mapping}    Siso Common Get BBMOD Mapping Cell     source=${bbmodreset_siso_scf_xml}
    ${bbmods_info}     Get BBMODs info
    set suite variable    ${bbmodreset_siso_scf_xml}
    set test variable     ${bbmod_mapping}
    set test variable     ${bbmods_info}
    set test variable     ${bbmod_cell_mapping}
    set suite variable    ${rmod_cell_mapping}
    set suite variable    ${rmod_serial_mapping}
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair


Case Teardown:siso_common_bbmod_reset
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    COAM Logout


Case Setup:siso_common_bbmod_Lock_Unlock
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    Recovery At Case Setup if Fault Occurs
    COAM Backup Full SCF   file_name=siso_scf_bbmod_lock.xml
    ${bbmodlock_siso_scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/siso_scf_bbmod_lock.xml
    ${rmod_cell_mapping}    ${cell_num}    UUF Get RMOD SN Cell Mapping From Full SCF    source=${bbmodlock_siso_scf_xml}
    ${rmod_serial_mapping}    UUF Get RMOD SerialNumber Mapping    source=${bbmodlock_siso_scf_xml}
    set suite variable    ${bbmodlock_siso_scf_xml}
    set suite variable    ${rmod_cell_mapping}
    set suite variable    ${rmod_serial_mapping}
    ${bbmod_mapping}     Siso Common Get BBMOD Mapping RMOD    source=${bbmodlock_siso_scf_xml}
    ${bbmod_cell_mapping}    Siso Common Get BBMOD Mapping Cell     source=${bbmodlock_siso_scf_xml}
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
     [Teardown]    COAM Logout

Case Setup:siso_common_rat_reset_actRATResetEnhancement_False
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
    ${release}   COAM Get SW Release   connection=COAM
    set test variable    ${release}
    run keyword if   'SBTS24R2'<'${release}'<'SBTS25R3'
    ...    Active or Disable Rat Hard Reset by Param    option=false
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair


Case Teardown:siso_common_rat_reset_actRATResetEnhancement_False
    run keyword if   'SBTS24R2'<'${release}'<'SBTS25R3'
    ...    Active or Disable Rat Hard Reset by Param    option=true
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    COAM Logout

Case Setup:siso_common_rat_reset_actRATResetEnhancement_True
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
    ${release}   COAM Get SW Release   connection=COAM
    set test variable    ${release}
    run keyword if   'SBTS24R2'<'${release}'<'SBTS25R3'
    ...    Active or Disable Rat Hard Reset by Param    option=true
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair


Case Teardown:siso_common_rat_reset_actRATResetEnhancement_True
    run keyword if   'SBTS24R2'<'${release}'<'SBTS25R3'
    ...    Active or Disable Rat Hard Reset by Param    option=true
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    COAM Logout


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
     [Teardown]    COAM Logout


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
      Siso Common Save Logs
      ${nrdu_objlist}   XML.Get Elements   ${siso_scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRDU"]
      FOR    ${nrdu}    IN    @{nrdu_objlist}
         ${nrdu_dn}   XML.Get Element Attribute   ${nrdu}   distName
         COAM Unlock NRDU     distname=${nrdu_dn}
      END
      Wait Until Keyword Succeeds   20m   10s   Rat Cell should Enabled and Mplane Check     rat=nr
     [Teardown]    COAM Logout


Case Setup:siso_common_Commission
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     Recovery At Case Setup if Fault Occurs
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair

Case Teardown:siso_common_Commission
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    COAM Logout


Case Setup:siso_common_Power_Reset
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     Recovery At Case Setup if Fault Occurs
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair

Case Teardown:siso_common_Power_Reset
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    COAM Logout
