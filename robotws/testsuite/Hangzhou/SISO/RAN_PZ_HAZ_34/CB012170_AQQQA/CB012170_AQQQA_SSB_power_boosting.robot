*** Settings ***
Documentation
...    Author: Yang Di
...    Contact: di.yang@nokia-sbell.com
...    Squad group: SG_05
...    Feature CB012170

Test Timeout      90 minutes    #testing will terminate if the case run time exceed 90 minutes
Suite Setup       Run Keywords  CB012170 Common Suite Setup  AND    Commission configuration on WebUI
Suite Teardown    CB012170 Common Suite Teardown
Test Setup        CB012170 Common Test Setup
Test Teardown     CB012170 Common Test Teardown

Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012170_AQQQA/common_resource/common_resource.robot

*** Test Cases ***
CB012170_SR_001_A#B1_Online_feature_activation
    [Tags]    001
    Get EIRP PM counters
    ${EIRP_counters_list_1}   get CB012170 counters value
    Attach UE and send DL traffic and check energySavingState
    Online change actSSBBoostInmMIMOMuting
    Verify traffic And Stop UE
    ${EIRP_counters_list_2}   get CB012170 counters value
    Compare counters    ${EIRP_counters_list_1}    ${EIRP_counters_list_2}

#CB012170_SR_002_A#B2_Online_feature_ deactivation
#    [Tags]    002
#    Online change actSSBBoostInmMIMOMuting
#    Get EIRP PM counters
#    ${EIRP_counters_list_1}   get CB012170 counters value
#    Attach UE and send DL traffic and check energySavingState
#    Online change actSSBBoostInmMIMOMuting  value=false
#    Verify traffic And Stop UE
#    ${EIRP_counters_list_2}   get CB012170 counters value
#    Compare counters    ${EIRP_counters_list_2}    ${EIRP_counters_list_1}

*** Keywords ***
Commission configuration on WebUI
    [Arguments]    ${connection}=GNB_OAM    ${ru_index}=${1}     ${should_activate}=${True}
    ...            ${skip_parameter_relation_errors}=True
    ${cell_list}    Get All Cell Id    ru_index=${ru_index}
    Initialise delta store
    Log To Console    \n--------Commission configuration on WebUI-------
    ${nrbts_path}       Set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ${nrcell_path}       Set variable    ${nrbts_path}/NRCELL-
    ${nrpgrp_path}       Set variable    ${nrbts_path}/NRPGRP-
    ${nrpmrnl_path}       Set variable    ${nrbts_path}/NRPMRNL-1
#    ${random_cell_id}  Evaluate   random.sample(${cell_list},1)   random
    set suite variable    ${random_cell_id}    1
#    set suite variable    ${random_cell_id}    ${random_cell_id[0]}
    Add Parameters To Delta  ${nrbts_path}    actCoordinated4g5gPowerSaving=disabled  actLbpsCtrlLogicEnh=false
    ...                      actNrLBmMimoRTXPowerSaving=false  actNrLBPowerSaving=false  actSSBBoostInmMIMOMuting=false
    Add param to delta  ${nrcell_path}1    actEirpControl       value=true
    Add param to delta  ${nrpmrnl_path}    miNrEirp       value=5min
    FOR  ${index}  IN     @{cell_list}
       run keyword if  ${index}!=${random_cell_id}    Add param to delta  ${nrcell_path}${index}    cellBarred
       ...       value=barred
    END
    FOR  ${index}  IN RANGE    1  3
       Delete Managed Object From Delta  ${nrpgrp_path}${index}
    END
    ${delta}                Collect delta store
    TAF_ADMIN.Perform Delta Recommissioning       connection=${connection}       delta_file=${delta}
    ...                                        should_activate=${should_activate}
    ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    Initialise delta store
    Add param to delta  ${nrbts_path}    actNrLBmMimoRTXPowerSaving       value=true
    ${lbps_dict_1}    Create Dictionary
    ...            lbpsDayOfWeek=Mon    lbpsDuration=1440    lbpsStartTimeHour=0    lbpsStartTimeMinute=0
    ...            lbpsSuspended=notSuspended
    ${lbps_dict_2}    Create Dictionary
    ...            lbpsDayOfWeek=Tue    lbpsDuration=1440    lbpsStartTimeHour=0    lbpsStartTimeMinute=0
    ...            lbpsSuspended=notSuspended
    ${lbps_dict_3}    Create Dictionary
    ...            lbpsDayOfWeek=Wed    lbpsDuration=1440    lbpsStartTimeHour=0    lbpsStartTimeMinute=0
    ...            lbpsSuspended=notSuspended
    ${lbps_dict_4}    Create Dictionary
    ...            lbpsDayOfWeek=Thu    lbpsDuration=1440    lbpsStartTimeHour=0    lbpsStartTimeMinute=0
    ...            lbpsSuspended=notSuspended
    ${lbps_dict_5}    Create Dictionary
    ...            lbpsDayOfWeek=Fri    lbpsDuration=1440    lbpsStartTimeHour=0    lbpsStartTimeMinute=0
    ...            lbpsSuspended=notSuspended
    ${lbps_dict_6}    Create Dictionary
    ...            lbpsDayOfWeek=Sat    lbpsDuration=1440    lbpsStartTimeHour=0    lbpsStartTimeMinute=0
    ...            lbpsSuspended=notSuspended
    ${lbps_dict_7}    Create Dictionary
    ...            lbpsDayOfWeek=Sun    lbpsDuration=1440    lbpsStartTimeHour=0    lbpsStartTimeMinute=0
    ...            lbpsSuspended=notSuspended
    ${pgrp_dict}    Create Dictionary
    ...            lbpsCSONCtlEnabled=false    lbpsLastCellMinLoad=20    lbpsLastCellRTXMinLoad=30
    ...            lbpsLastCellSOEnabled=true    lbpsMaxLoad=30    lbpsPdcchLoadOffset=20    lbpsRTXCellCapOffset=40
    ...            lbpsRTXMaxLoad=30    lbpsRTXSOffTime=120    lbpsSOMethod=TX switch off    lbpsMinLoad=20
    ...            lbpsRTXMinLoad=20    lbpsRTXSOnTime=120
    FOR  ${index}  IN     @{cell_list}
       add managed object and parameter to delta  ${nrpgrp_path}${index}    &{pgrp_dict}
       &{lbpsCellList}   Create dictionary   lbpsCellSOOrder=1   lbpsUseExtConfig=false   nrCellId=${index}
       Add List Parameters To Delta  ${nrpgrp_path}${index}        lbpsCellList           &{lbpsCellList}
       add list of dictionaries to delta  ${nrpgrp_path}${index}    lbpsPeriodList
    ...    ${lbps_dict_1}    ${lbps_dict_2}    ${lbps_dict_3}    ${lbps_dict_4}    ${lbps_dict_5}    ${lbps_dict_6}
    ...    ${lbps_dict_7}
    END
    ${delta}                Collect delta store
    TAF_ADMIN.Perform Delta Recommissioning       connection=${connection}       delta_file=${delta}
    ...                                        should_activate=${should_activate}
    ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online

Attach UE and send DL traffic and check energySavingState
    Log To Console    \n-------------Attach UE--------------
    Nokia UE Attach    ue_index=${ue_id}
    Nokia UE Send DL Traffic    ue_index=${ue_id}    send_traffic=25M    send_duration=2400
    ${cell_list}    Get All Cell Id
    FOR     ${cell}    IN     @{cell_list}
        Wait Until Keyword Succeeds    5min    30s    Check cell EnergySaving state via COAM
        ...    expect_energySavingState=reducedEnergySaving    cellID=${cell}
    END

Get EIRP PM counters
    Log To Console    \n-------------Get EIRP PM counters--------------
    ${EIRP_counters_list}   create list
    FOR    ${num}    IN RANGE    0    4
        append to list    ${EIRP_counters_list}    M55324C0040${num}
    END
#    FOR    ${num}    IN RANGE    1    61
#        ${counter_id}    set variable if     ${num} < 10    M55324C0010${num}    M55324C001${num}
#        append to list    ${EIRP_counters_list}    ${counter_id}
#    END
#    FOR    ${num}    IN RANGE    1    61
#        ${counter_id}    set variable if     ${num} < 10    M55324C0020${num}    M55324C002${num}
#        append to list    ${EIRP_counters_list}    ${counter_id}
#    END
#    FOR    ${num}    IN RANGE    1    61
#        ${counter_id}    set variable if     ${num} < 10    M55324C0050${num}    M55324C005${num}
#        append to list    ${EIRP_counters_list}    ${counter_id}
#    END
#    FOR    ${num}    IN RANGE    1    61
#        ${counter_id}    set variable if     ${num} < 10    M55324C0060${num}    M55324C006${num}
#        append to list    ${EIRP_counters_list}    ${counter_id}
#    END
#    FOR    ${num}    IN RANGE    1    61
#        ${counter_id}    set variable if     ${num} < 10    M55324C0070${num}    M55324C007${num}
#        append to list    ${EIRP_counters_list}    ${counter_id}
#    END
    ${eirp_cell_counter_list}    create list   M55324C00800  M55324C00801  M55324C00802  M55324C00464
    ${counters_length}    Get Length    ${eirp_cell_counter_list}
    FOR  ${counter_index}  IN RANGE    ${counters_length}
        append to list    ${EIRP_counters_list}    ${eirp_cell_counter_list}[${counter_index}]
    END
    log to console    EIRP PM counters are ${EIRP_counters_list}
    Set test variable    ${EIRP_counters_list}

Online change actSSBBoostInmMIMOMuting
    [Arguments]    ${value}=true
    Connect to gnb coam via ssl
    Log To Console    \n-------------Online change actSSBBoostInmMIMOMuting to ${value}--------------
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=actSSBBoostInmMIMOMuting    value=${value}
    CI_commssion.Verify all cells should be Online

Compare counters
    [Arguments]    ${counters_1}    ${counters_2}
    ${counters_1_length}    Get Length    ${counters_1}
    ${counters_2_length}    Get Length    ${counters_2}
    Log To Console    \n-------------Compare counters--------------
    Should Be True    ${counters_1_length} == ${counters_2_length}
    FOR    ${counter_index}    IN RANGE    ${counters_1_length}
        Should Be True    ${counters_2}[${counter_index}] > ${counters_1}[${counter_index}]
    END

