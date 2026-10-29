*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   Common.robot

*** Variables ***

*** Keyword ***
Initialize Power Meter Releated Parameters
    ${delta_file}   Catenate   SEPARATOR=
    ...   [{
    ...       "distName":"${MRBTS}/MNL-1/MNLENT-1/FEATCADM-1",
    ...       "operation":"update",
    ...       "parameters":[{
    ...           "parameterName":"actPowerMeter",
    ...           "value":true,
    ...           "operation":"update"
    ...       }]
    ...   },{
    ...       "distName":"${MRBTS}/MNL-1/MNLENT-1/PMMNL-1",
    ...       "operation":"update",
    ...       "parameters":[{
    ...           "parameterName":"mtBtsEnergyMonitoring",
    ...           "value":"15min",
    ...           "operation":"update"
    ...       }]
    ...   },{
    ...       "distName":"${MRBTS}/MNL-1/MNLENT-1/PMMNL-1",
    ...       "operation":"update",
    ...       "parameters":[{
    ...           "parameterName":"mtSBTSRfmEnergyMonitoring",
    ...           "value":"15min",
    ...           "operation":"update"
    ...       }]
    ...   },{
    ...       "distName":"${MRBTS}/MNL-1/MNLENT-1/PMMNL-1",
    ...       "operation":"update",
    ...       "parameters":[{
    ...           "parameterName":"mtSBTSSmEnergyMonitoring",
    ...           "value":"15min",
    ...           "operation":"update"
    ...       }]
    ...   }]
    COAM Perform Delta Recommission   delta_file=${delta_file}
    Sleep   30s

Get Power Meter Releated Counters
    # ${counters_dic['BTS']['BTS']['${MRBTS}']['SBTS_Energy_Consumption']['M40002C0']}
    # ${counters_dic['BTS']['BTS']['${MRBTS}']['SBTS_Energy_Consumption']['M40002C1']}
    # ${counters_dic['BTS']['BTS']['${MRBTS}']['SBTS_Energy_Consumption']['M40002C2']}
    # ${counters_dic['BTS']['BTS']['${MRBTS}']['RMOD-1']['SBTS_RFM_Energy_Monitoring']['M40003C0']}
    # ${counters_dic['BTS']['BTS']['${MRBTS}']['RMOD-1']['SBTS_RFM_Energy_Monitoring']['M40003C1']}
    # ${counters_dic['BTS']['BTS']['${MRBTS}']['RMOD-1']['SBTS_RFM_Energy_Monitoring']['M40003C2']}
    # ${counters_dic['BTS']['BTS']['${MRBTS}']['RMOD-1']['SBTS_RFM_Energy_Monitoring']['M40003C3']}
    # ${counters_dic['BTS']['BTS']['${MRBTS}']['RMOD-1']['SBTS_RFM_Energy_Monitoring']['M40003C4']}
    # ${counters_dic['BTS']['BTS']['${MRBTS}']['RMOD-1']['SBTS_RFM_Energy_Monitoring']['M40003C5']}
    # ${counters_dic['BTS']['SMOD']['SMOD-1']['CABINET-1']['SBTS_SM_Energy_Monitoring']['M40004C0']}
    # ${counters_dic['BTS']['SMOD']['SMOD-1']['CABINET-1']['SBTS_SM_Energy_Monitoring']['M40004C1']}
    # ${counters_dic['BTS']['SMOD']['SMOD-1']['CABINET-1']['SBTS_SM_Energy_Monitoring']['M40004C2']}
    # ${counters_dic['BTS']['SMOD']['SMOD-1']['CABINET-1']['SBTS_SM_Energy_Monitoring']['M40004C3']}
    # ${counters_dic['BTS']['SMOD']['SMOD-1']['CABINET-1']['SBTS_SM_Energy_Monitoring']['M40004C4']}
    # ${counters_dic['BTS']['SMOD']['SMOD-1']['CABINET-1']['SBTS_SM_Energy_Monitoring']['M40004C5']}
    [Arguments]   ${counter_id_list}=${counter_id_list}
    ${all_counters}   Create Dictionary
    ${counters_dic}   COAM Get PM Counters   counter_id_list=${counter_id_list}
    Set To Dictionary   ${all_counters}   SBTS   ${counters_dic['BTS']['BTS']['${MRBTS}']['SBTS_Energy_Consumption']}
    FOR   ${rmod}   IN   @{RMOD_ID_LIST}
        Set To Dictionary   ${all_counters}   ${rmod}   ${counters_dic['BTS']['BTS']['${MRBTS}']['${rmod}']['SBTS_RFM_Energy_Monitoring']}
    END
    FOR   ${smod}   IN   @{SMOD_ID_LIST}
        Set To Dictionary   ${all_counters}   ${smod}   ${counters_dic['BTS']['SMOD']['${smod}']['CABINET-1']['SBTS_SM_Energy_Monitoring']}
    END
    [Return]   ${all_counters}

Get ALL Timestamp
    [Arguments]   ${all_counters}
    &{all_timestamp}   Create Dictionary
    FOR   ${key}   IN   @{all_counters.keys()}
        ${counters}   _Format_DN_Timestamp   dn_counters=${all_counters['${key}']}
        Set To Dictionary   ${all_timestamp}   ${key}   ${counters}
    END
    [Return]   ${all_timestamp}

_Format_DN_Timestamp
    [Arguments]   ${dn_counters}
    &{counters}   Create Dictionary
    FOR   ${key}   IN   @{dn_counters.keys()}
        ${timestamp_list}   _Format_Counter_Timestamp   counters=${dn_counters['${key}']}
        Set To Dictionary   ${counters}   ${key}   ${timestamp_list}
    END
    [Return]   ${counters}

_Format_Counter_Timestamp
    [Arguments]   ${counters}
    ${timestamp_list}   Create List
    FOR   ${key}   IN   @{counters.keys()}
        Append To List   ${timestamp_list}   ${${key}}
    END
    Sort List   ${timestamp_list}
    [Return]   ${timestamp_list}

Get Power Meter Releated Measurements
    ${measurements_list}   COAM Get Measurements
    &{all_measurements}   Create Dictionary
    FOR   ${values}   IN   @{measurements_list}
        ${key}   Convert To List   ${values.keys()}
        ${key}   Set Variable   ${key[0]}
        ${status}   Run Keyword And Return Status   Should Contain   ${key}   ENERGY_EFFICIENCY
        Continue For Loop If   not ${status}
        Set To Dictionary   ${all_measurements}   &{values}
    END
    [Return]   ${all_measurements}

Check Power Meter Releated Counters
    [Arguments]   ${ALL_COUNTERS}=${ALL_COUNTERS}   ${ALL_TIMESTAMP}=${ALL_TIMESTAMP}
    FOR   ${rmod}   IN   @{RMOD_ID_LIST}
        ${latest_time_0}   Set Variable   ${ALL_TIMESTAMP['${rmod}']['M40003C0'][-1]}
        ${latest_time_1}   Set Variable   ${ALL_TIMESTAMP['${rmod}']['M40003C1'][-1]}
        ${latest_time_2}   Set Variable   ${ALL_TIMESTAMP['${rmod}']['M40003C2'][-1]}
        ${latest_time_3}   Set Variable   ${ALL_TIMESTAMP['${rmod}']['M40003C3'][-1]}
        ${latest_time_4}   Set Variable   ${ALL_TIMESTAMP['${rmod}']['M40003C4'][-1]}
        ${latest_time_5}   Set Variable   ${ALL_TIMESTAMP['${rmod}']['M40003C5'][-1]}
        # Log To Console   ${ALL_COUNTERS['${rmod}']['M40003C0']['${latest_time_0}']}
        # Log To Console   ${ALL_COUNTERS['${rmod}']['M40003C1']['${latest_time_1}']}
        # Log To Console   ${ALL_COUNTERS['${rmod}']['M40003C2']['${latest_time_2}']}
        # Log To Console   ${ALL_COUNTERS['${rmod}']['M40003C3']['${latest_time_3}']}
        # Log To Console   ${ALL_COUNTERS['${rmod}']['M40003C4']['${latest_time_4}']}
        # Log To Console   ${ALL_COUNTERS['${rmod}']['M40003C5']['${latest_time_5}']}
        Should Not Be Equal As Numbers   ${ALL_COUNTERS['${rmod}']['M40003C0']['${latest_time_0}']}   0
        Should Not Be Equal As Numbers   ${ALL_COUNTERS['${rmod}']['M40003C1']['${latest_time_1}']}   0
        Should Not Be Equal As Numbers   ${ALL_COUNTERS['${rmod}']['M40003C2']['${latest_time_2}']}   0
        Should Not Be Equal As Numbers   ${ALL_COUNTERS['${rmod}']['M40003C3']['${latest_time_3}']}   0
        Should Not Be Equal As Numbers   ${ALL_COUNTERS['${rmod}']['M40003C4']['${latest_time_4}']}   0
        Should Not Be Equal As Numbers   ${ALL_COUNTERS['${rmod}']['M40003C5']['${latest_time_5}']}   0
    END
    FOR   ${smod}   IN   @{SMOD_ID_LIST}
        ${latest_time_0}   Set Variable   ${ALL_TIMESTAMP['${smod}']['M40004C0'][-1]}
        ${latest_time_1}   Set Variable   ${ALL_TIMESTAMP['${smod}']['M40004C1'][-1]}
        ${latest_time_2}   Set Variable   ${ALL_TIMESTAMP['${smod}']['M40004C2'][-1]}
        ${latest_time_3}   Set Variable   ${ALL_TIMESTAMP['${smod}']['M40004C3'][-1]}
        ${latest_time_4}   Set Variable   ${ALL_TIMESTAMP['${smod}']['M40004C4'][-1]}
        ${latest_time_5}   Set Variable   ${ALL_TIMESTAMP['${smod}']['M40004C5'][-1]}
        # Log To Console   ${ALL_COUNTERS['${smod}']['M40004C0']['${latest_time_0}']}
        # Log To Console   ${ALL_COUNTERS['${smod}']['M40004C1']['${latest_time_1}']}
        # Log To Console   ${ALL_COUNTERS['${smod}']['M40004C2']['${latest_time_2}']}
        # Log To Console   ${ALL_COUNTERS['${smod}']['M40004C3']['${latest_time_3}']}
        # Log To Console   ${ALL_COUNTERS['${smod}']['M40004C4']['${latest_time_4}']}
        # Log To Console   ${ALL_COUNTERS['${smod}']['M40004C5']['${latest_time_5}']}
        Should Not Be Equal As Numbers   ${ALL_COUNTERS['${smod}']['M40004C0']['${latest_time_0}']}   0
        Should Not Be Equal As Numbers   ${ALL_COUNTERS['${smod}']['M40004C1']['${latest_time_1}']}   0
        Should Not Be Equal As Numbers   ${ALL_COUNTERS['${smod}']['M40004C2']['${latest_time_2}']}   0
        Should Not Be Equal As Numbers   ${ALL_COUNTERS['${smod}']['M40004C3']['${latest_time_3}']}   0
        Should Not Be Equal As Numbers   ${ALL_COUNTERS['${smod}']['M40004C4']['${latest_time_4}']}   0
        Should Not Be Equal As Numbers   ${ALL_COUNTERS['${smod}']['M40004C5']['${latest_time_5}']}   0
    END
    ${latest_time_0}   Set Variable   ${ALL_TIMESTAMP['SBTS']['M40002C0'][-1]}
    ${latest_time_1}   Set Variable   ${ALL_TIMESTAMP['SBTS']['M40002C1'][-1]}
    ${latest_time_2}   Set Variable   ${ALL_TIMESTAMP['SBTS']['M40002C2'][-1]}
    # Log To Console   ${ALL_COUNTERS['SBTS']['M40002C0']['${latest_time_0}']}
    # Log To Console   ${ALL_COUNTERS['SBTS']['M40002C1']['${latest_time_1}']}
    # Log To Console   ${ALL_COUNTERS['SBTS']['M40002C2']['${latest_time_2}']}
    Should Not Be Equal As Numbers   ${ALL_COUNTERS['SBTS']['M40002C0']['${latest_time_0}']}   0
    Should Not Be Equal As Numbers   ${ALL_COUNTERS['SBTS']['M40002C1']['${latest_time_1}']}   0
    Should Not Be Equal As Numbers   ${ALL_COUNTERS['SBTS']['M40002C2']['${latest_time_2}']}   0

Check Time Interval
    [Arguments]   ${time_interval}=${900}   ${ALL_COUNTERS}=${ALL_COUNTERS}   ${ALL_TIMESTAMP}=${ALL_TIMESTAMP}
    FOR   ${rmod}   IN   @{RMOD_ID_LIST}
        Should Be True   int(${ALL_TIMESTAMP['${rmod}']['M40003C0'][-1]})-int(${ALL_TIMESTAMP['${rmod}']['M40003C0'][-2]})==int(${time_interval})
        Should Be True   int(${ALL_TIMESTAMP['${rmod}']['M40003C1'][-1]})-int(${ALL_TIMESTAMP['${rmod}']['M40003C1'][-2]})==int(${time_interval})
        Should Be True   int(${ALL_TIMESTAMP['${rmod}']['M40003C2'][-1]})-int(${ALL_TIMESTAMP['${rmod}']['M40003C2'][-2]})==int(${time_interval})
        Should Be True   int(${ALL_TIMESTAMP['${rmod}']['M40003C3'][-1]})-int(${ALL_TIMESTAMP['${rmod}']['M40003C3'][-2]})==int(${time_interval})
        Should Be True   int(${ALL_TIMESTAMP['${rmod}']['M40003C4'][-1]})-int(${ALL_TIMESTAMP['${rmod}']['M40003C4'][-2]})==int(${time_interval})
        Should Be True   int(${ALL_TIMESTAMP['${rmod}']['M40003C5'][-1]})-int(${ALL_TIMESTAMP['${rmod}']['M40003C5'][-2]})==int(${time_interval})
    END
    FOR   ${smod}   IN   @{SMOD_ID_LIST}
        Should Be True   int(${ALL_TIMESTAMP['${smod}']['M40004C0'][-1]})-int(${ALL_TIMESTAMP['${smod}']['M40004C0'][-2]})==int(${time_interval})
        Should Be True   int(${ALL_TIMESTAMP['${smod}']['M40004C1'][-1]})-int(${ALL_TIMESTAMP['${smod}']['M40004C1'][-2]})==int(${time_interval})
        Should Be True   int(${ALL_TIMESTAMP['${smod}']['M40004C2'][-1]})-int(${ALL_TIMESTAMP['${smod}']['M40004C2'][-2]})==int(${time_interval})
        Should Be True   int(${ALL_TIMESTAMP['${smod}']['M40004C3'][-1]})-int(${ALL_TIMESTAMP['${smod}']['M40004C3'][-2]})==int(${time_interval})
        Should Be True   int(${ALL_TIMESTAMP['${smod}']['M40004C4'][-1]})-int(${ALL_TIMESTAMP['${smod}']['M40004C4'][-2]})==int(${time_interval})
        Should Be True   int(${ALL_TIMESTAMP['${smod}']['M40004C5'][-1]})-int(${ALL_TIMESTAMP['${smod}']['M40004C5'][-2]})==int(${time_interval})
    END
    Should Be True   int(${ALL_TIMESTAMP['SBTS']['M40002C0'][-1]})-int(${ALL_TIMESTAMP['SBTS']['M40002C0'][-2]})==int(${time_interval})
    Should Be True   int(${ALL_TIMESTAMP['SBTS']['M40002C1'][-1]})-int(${ALL_TIMESTAMP['SBTS']['M40002C1'][-2]})==int(${time_interval})
    Should Be True   int(${ALL_TIMESTAMP['SBTS']['M40002C2'][-1]})-int(${ALL_TIMESTAMP['SBTS']['M40002C2'][-2]})==int(${time_interval})

Get Latest Timestamp
    ${all_counters}   Get Power Meter Releated Counters
    ${all_timestamp}   Get ALL Timestamp   all_counters=${all_counters}
    ${last_timestamp}   Set Variable   ${ALL_TIMESTAMP['SBTS']['M40002C0'][-1]}
    [Return]   ${last_timestamp}
