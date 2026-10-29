*** Settings ***
Documentation
...  common KW



*** Variables ***


*** Keywords ***
OAM Precondition Cell Should Be Onair
    [Documentation]    Do some common thing for every precondition of cases
    ...    any case should include it in test case setup
    ...    it will do following actions
    ...    1) check cell should be onair
    ...    2) initial global test varible
    ...    *AUTHOR* xianbiao.cheng@nokia-sbell.com
    ...    2019-11-15 first version for framework
    log to console  \n*** OAM Precondition Cell Should Be Onair ... ***

    ${nf_type}  Get VCU NF Type
    Run Keyword If   "${nf_type}"=="VNF"     CU Verify All VMs Are Online

#    All DUs Container Status Should Be Normal
#    CU Verify All Cells Status Are Onair
#    vDU Verify All Cells Status Should Be Onair For All DUs
    vDU Verify All Cells Status Should Be Onair
   #    Should Have Power On All RUs
#    ${ACTIVE_ALARM_LST_PRE_CU}=  run keyword and continue on failure  CU Get Active Alarms
   #  ${HISTORICAL_ALARM_LST_PRE_CU}=  run keyword and continue on failure   CU Get Historical Alarms
#    ${HISTORICAL_ALARM_LST_PRE_CU}   run keyword and ignore error   CU Get Historical Alarms
#    ${BACKUP_SCF_PATH_ON_CU}=    run keyword and continue on failure   CU Backup SCF
    set test Variable  ${CU_SW_VER_PRE}                 tbd
    set test Variable  ${DU_1_SW_VER_PRE}               tbd
    set test Variable  ${FHGW_1_SW_VER_PRE}             tbd
#    set test Variable  ${BACKUP_SCF_PATH_ON_CU}
    set test variable  ${BTS_ID}                        tbd
    set test variable  ${BTS_NAME}                      tbd
#    set test variable  ${ACTIVE_ALARM_LST_PRE_CU}
#    set test variable  ${HISTORICAL_ALARM_LST_PRE_CU}
    set test variable  ${ACTIVE_ALARM_LST_PRE_DU}       tbd
    set test variable  ${ACTIVE_ALARM_LST_PRE_FHGW}     tbd

    set test variable  ${CU_INSTANCE_ID}                tbd
    set test variable  ${PM_CHECK_LST_PATH}             tbd
    set test variable  ${VDU_NUM}                       tbd
    set test variable  ${CU_VM_NUM}                     tbd
#    @{CELLS_ID_LIST} =    CU Get Cells ID list
#    ${CELL_NUM}=  get length  ${CELLS_ID_LIST}
#    set test variable  ${CELLS_ID_LIST}
#    set test variable  ${CELL_NUM}


OAM Postcondition Cell Should Be Onair
    [Documentation]    Do some common thing for every postcondition of cases
    ...    any case should include it in test case setup
    ...    it will do following actions
    ...    1) check cell should be onair
    ...    2) close resources
    ...    *AUTHOR* xianbiao.cheng@nokia-sbell.com
    ...   history change
    ...    -30.05.2020,xianbiao.cheng@nokia-sbell.com,new KW add
    ...    -29.07.2020,peng.ling@nokia-sbell.com,modify KW according to review finding
    ...    modified by:        <28-Jul-2020>, <pelin>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | OAM Postcondition Cell Should Be Onair | |
    log to console  \n*** OAM Postcondition Cell Should Be Onair ... ***

    ${nf_type}  Get VCU NF Type
    Run Keyword If  "${nf_type}"=="VNF"      CU Verify All VMs Are Online

    All DUs Container Status Should Be Normal
    CU Verify All Cells Status Are Onair
    vDU Verify All Cells Status Should Be Onair
    No New Active Alarm Should Be Generated    active_alarm_list_before_cu=${ACTIVE_ALARM_LST_PRE_CU}
    ...  active_alarm_list_before_du=${ACTIVE_ALARM_LST_PRE_DU}  active_alarm_list_before_fhgw=${ACTIVE_ALARM_LST_PRE_FHGW}
