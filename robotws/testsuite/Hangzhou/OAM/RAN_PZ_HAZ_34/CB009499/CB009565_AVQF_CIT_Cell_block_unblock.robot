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
${times}    50

*** Test Cases ***
CB009565_AVQF_CIT_cell_Block_unBlock_via_Button
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_cell_lock_unlock
   AlarmWatchdog.add_allow_alarms    fault_id=49
    FOR   ${index}    IN RANGE    ${times}
       log to console     //this is index：${index} time do ALL Cells Block unBlock...
       ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['cell_block_unblock']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       All Cells block unblock cells
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]   Case Teardown:siso_common_cell_lock_unlock


*** Keywords ***
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
