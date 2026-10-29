*** Settings ***
Documentation
...   author: liting.cao@nokia-sbell.com
...   contact: liting.cao@nokia-sbell.com
...   cu_oam_pm.robot



#*** Variables ***



*** Keywords ***
############################## CU PM Start ##############################
====== CU PM Start ======
     log to console  \n*** only used for readable ***
Gen CU Measurement Report File Name
    [Arguments]  ${interval}  ${file_suffix}  ${gnb_index}=0
    [Documentation]  Generate CU measurement report file name using the interval start time and stop time.
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | interval | Yes | the interval that measurements generating report file, using to calculate the file stop time.|
    ...    | file_suffix | Yes | the report file suffix, like '-:2.xml.gz' from 'A20210407.1330+0800-20210407.1345+0800_-:2.xml.gz' |

    ...    *RETURN VALUE*
    ...    the measurement file name, like A20210407.1330+0800-20210407.1345+0800_-:2.xml.gz
    ...
    ${file_start_time}=  Get CU Measurement Interval Start Time  ${interval}  ${gnb_index}
    SET Test VARIABLE    ${file_start_time}
    ${file_stop_time}=   Get Measurement Report Stop Time  ${file_start_time}  ${interval}
    ${file_name}=   Measurement File Name Gen  ${file_start_time}  ${file_stop_time}  ${file_suffix}
    [Return]  ${file_name}

Get CU Measurement Interval Start Time
    [Arguments]  ${interval}   ${gnb_index}=0
    [Documentation]  Get the CU measurement interval start time.
    ...    For example: if the current time is 2021-04-07 13:33:45 and the interval is 15min, the interval start time
    ...    will be 2021-04-07T13:30:00.000+08:00
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | interval | Yes | the measurement interval. |

    ...    *RETURN VALUE*
    ...    the tidied time based on the current time, like 2021-04-07T13:30:00.000+08:00
    ...
    ${alias}=   Get Unique ID
    CU SSH To OAM   gnb_index=${gnb_index}   alias=${alias}
    ${out}=  issh.Execute   command=date +%Y-%m-%dT%H:   alias=${alias}
    ${year_hour}   strip prompt  ${out}
    ${out}=  issh.Execute   command=date +%M   alias=${alias}
    ${min}   strip prompt  ${out}
    ${min}  Evaluate  int('${min}')
    ${pm_interval}=   Evaluate   int('${interval}')
    ${tidy_min}=  Evaluate  ${min}-${min}%${pm_interval}
    ${out}=  issh.Execute   command=date +%:z   alias=${alias}
    ${tz}   strip prompt  ${out}
    ${start_time}=  Evaluate   '{}{:0>2d}:00.000{}'.format('${year_hour}', ${tidy_min}, '${tz}')
    [Return]  ${start_time}
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}

Gen All The Given CU Measurements File Names
    [Arguments]   ${mea_id_list}  ${org_meas_info}  ${interval}  ${gnb_index}=0
    [Documentation]  Generate all of the given CU measurements file names used to check whether the report files generated or not.
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | mea_id_list | Yes | measurement id list |
    ...    | org_meas_info | Yes | the original measuremts info got from start measurement. |
    ...    | interval | Yes | the measurement interval. |

    ...    *RETURN VALUE*
    ...    dict like {'55112': 'A20210407.1330+0800-20210407.1345+0800_-:2.xml.gz',
    ...               '55114': 'A20210407.1330+0800-20210407.1345+0800_-:6.xml.gz'}
    ...
    ${mea_file_name_dict}=  create dictionary
    FOR  ${mea}  IN  @{mea_id_list}
      ${report_file_suffix}=  set variable  ${org_meas_info['${mea}']['latest_file_name'].split('_')[-1]}
      ${file_name}=   Gen CU Measurement Report File Name   ${interval}   ${report_file_suffix}   ${gnb_index}
      set to dictionary  ${mea_file_name_dict}  ${mea}  ${file_name}
    END
    [Return]   ${mea_file_name_dict}

Get All Given CU Measurements Latest File Name
    [Arguments]  ${measurement_id_list}  ${gnb_index}=0
    [Documentation]  get the given measurents report file amount
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | measurement_id_list | Yes | measurements id list, like ['55300', '55302']|

    ...    *RETURN VALUE*
    ...    measurements file admount dict, like {'55300':30, '55303':32}
    ...
    ${measurement_file_name_dict}=   create dictionary
    ${reslut_mapping_content}=  Get CU PM Result Mapping File Content  ${PM_RESULT_DIR_IN_PMCORE}/resultMapping.json  ${gnb_index}
    FOR  ${m_id}  IN  @{measurement_id_list}
      ${file_list}=  set variable  ${reslut_mapping_content['${m_id}']['filenames']}
      set to dictionary  ${measurement_file_name_dict}  ${m_id}  ${file_list[0]}
    END
    [Return]  ${measurement_file_name_dict}


CU Get PM Counter Latest Values
    [Arguments]    ${counter_id}     ${measurement_id}    ${dimension_dist_name}  ${expected_value}  ${how_many}=1  ${gnb_index}=0
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:   <19-Oct-2020>, <f2huang>, <Initial creation>
    ...    modified by:   <23-Mar-2021>, <huilxu>, <PM v2 Trunk>
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id | Yes | PM counter ID |
    ...    | measurement_id | Yes | Measurement ID |
    ...    | dimension_dist_name | No | Aggregation dimension distName of the measurement you want to retrive. |
    ...    | how_many | No | How many counter values will be get , 1 in default |
    ...    | gnb_index | No |  gnb index to indicate which gnb will be used, 0 in default  |
    ...
    ...    *RETURN VALUE*
    ...    Latest counter value
    ...    Example
    ...    | ${value}= | CU Get PM Counter Latest Value |  M55323C13001  |   55323   |   MRBTS-5226/NRBTS-5226  |  900  |  4  |
    CU Login    ${gnb_index}    restapi_version=cuoam_21b
    ${res}=  cu.get_counter    ${measurement_id}     ${dimension_dist_name}    ${counter_id}
    ${counter_values}=  set variable    ${res["values"]}
    ${num}=  get length   ${counter_values}
    ${expected_counter_values}=   set variable   ${counter_values[${num}-${how_many}:${num}]}
    ${flag}=   set variable   False
    FOR   ${counter_item}   IN   @{counter_values[${num}-${how_many}:${num}]}
       ${flag}=   set variable if  ${counter_item['value']}==${expected_value}   True
       exit for loop if    ${counter_item['value']}==${expected_value}
    END
    should be equal    ${flag}  True   Check counter value failed!
    [Teardown]   CU Logout

Counter Generate Remaining Time
    [Arguments]    ${internal_value}
    [Documentation]    Get the remaining counter generate time.
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:   <22-Oct-2020>, <rifeng>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | internal_value | Yes | the interval that counter generate |
    ...    *RETURN VALUE*
    ...    Latest counter value
    ...    Example
    ...    | ${value}= | Counter Generate Remaining Time |  15  |

    @{utc} =    Get Time    hour min sec    UTC
    ${utc_minute} =    convert to integer  @{utc}[1]
    set test variable  ${utc_minute}
    ${utc_minute_1} =    Evaluate    ${utc_minute}%${internal_value}
    ${utc_remain}=     Evaluate    ${internal_value} - ${utc_minute_1}
    Set test Variable    ${utc_remain}
    [return]    ${utc_remain}

Get CU Counter
    [Arguments]    ${counter_id}     ${measurement_id}    ${dimension_dist_name}    ${gnb_index}=0
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:   <22-Oct-2020>, <rifeng>, <Initial creation>
    ...    modified by:   <23-Mar-2021>, <huilxu>, <trunk PM V2>
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id | Yes | PM counter ID |
    ...    | measurement_id | Yes | Measurement ID |
    ...    | dimension_dist_name | No | Aggregation dimension distName of the measurement you want to retrive. |
    ...    | how_many | No | How many counter values will be get , 1 in default |
    ...    | gnb_index | No |  gnb index to indicate which gnb will be used, 0 in default  |
    ...
    ...    *RETURN VALUE*
    ...    Latest counter value
    ...    Example
    ...    | ${value}= | Get CU Counter |  M55323C13001  |   55323   |   MRBTS-5226/NRBTS-5226  |
    CU Login    ${gnb_index}   restapi_version=cuoam_21b
    ${res}=  cu.get_counter   ${measurement_id}    ${dimension_dist_name}    ${counter_id}
    ${latest_counter}=  set variable    ${res["values"][-1]['value']}
    [return]    ${latest_counter}
    [Teardown]   CU Logout

CU Sync To PM Timer Clock
    [Arguments]   ${PM_collecting_interval}=5   ${estimated_traffic_generating_duration}=4  ${gnb_index}=${0}
    [Documentation]  CU Sync To PM Timer Clock
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | estimated_traffic_generating_duration | No | estimated_traffic_generating_duration, unit is minute, default value is 7 |
    ...    | PM_collecting_interval                | No  | PM_collecting_interval, unit is minute, default value is 15 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | CU Sync To PM Timer Clock | PM_collecting_interval=5  | estimated_traffic_generating_duration=2 |
    ...    | # generate traffic to triggle counter increasement |
    ...
    Log To Console  Begin: CU Sync To PM Timer Clock
    ${alias}    Get Unique ID
    CU SSH To OAM   ${gnb_index}   alias=${alias}

    #wait clock to the moment which is 15*n minutes(n=0,1,2,3)
    ${ret}     issh.Execute    command=date +"%Y-%m-%d %H:%M:%S"   alias=${alias}

    ${vm_time}=    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}
    Log To Console   Current OAM system time:${vm_time[0]}

    ${matches}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:(\\d{2}):\\d{2}  1
    ${vm_minutes}  Set Variable   ${matches[0]}

    ${estimated_traffic_generating_duration}  Evaluate   int('${estimated_traffic_generating_duration}')
    ${PM_collecting_interval}  Evaluate  int('${PM_collecting_interval}')
    ${vm_minutes}  Evaluate  int('${vm_minutes}')

    Run Keyword If
      ...   ${PM_collecting_interval}!=5 and ${PM_collecting_interval}!=15 and ${PM_collecting_interval}!=30 and ${PM_collecting_interval}!=60
      ...    Fail   PM_collecting_interval should be 5, 15, 30 or 60 minutes.
    _Wait Some Time For Next Round PM Collecting    collecting_interval=${PM_collecting_interval}
     ...   estimated_traffic_generating_duration=${estimated_traffic_generating_duration}   vm_minutes=${vm_minutes}

    ${ret}     issh.Execute   command=date +"%Y-%m-%d %H:%M:%S"   alias=${alias}

    ${vm_time}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}
    Log To Console   Current OAM system time:${vm_time[0]}
    Log To Console  End: CU Sync To PM Timer Clock
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}

Get File From CU OAM To Local TestPC
    [Arguments]  ${file_absolute_path}   ${gnb_index}=${0}
    [Documentation]  get file from CU oam VM to local UTE. The file will be stored under UTE
    ...  ${OUTPUT_DIR}/${TEST_NAME}/${START_TIME}/pm_related directory.
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | file_absolute_path | Yes | the file path in OAM VM,
    ...                                 like /var/opt/nokia/performancemanagement/storage/results/resultMapping.json |

    ...    *RETURN VALUE*
    ...    the file path under UTE,
    ...    like /home/ute/robotws5g/testsuite/AIC/TESTCASE__Test_PM/2021_01_14_04_17_04/pm_related/resultMapping.json
    ...
    ${username}=  Set Variable  ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ${path}   ${file_name}  OperatingSystem.Split Path   ${file_absolute_path}
    ${local_file}   Get A File    CU_pm_related   ${file_name}
    ${alias}   Get Unique Id
    CU SSH To OAM     gnb_index=${gnb_index}  alias=${alias}
    issh.Execute  command=cp ${file_absolute_path} /home/${username}/${file_name}  alias=${alias}
    issh.Execute  command=chmod 777 /home/${username}/${file_name}  alias=${alias}
    issh.Execute  command=chown ${username}:${username} /home/${username}/${file_name}  alias=${alias}
    issh.download_file  remote_path=/home/${username}/${file_name}  local_path=${local_file}  alias=${alias}
    [Return]  ${local_file}
    [Teardown]  Run Keywords  issh.Execute  command=rm -rf /home/${username}/${file_name}  alias=${alias}
    ...   AND    Disconnect Interactive Connection  alias=${alias}

Get CU PM Result Mapping File Content
    [Arguments]  ${file_absolute_path}  ${gnb_index}=0
    [Documentation]  get the file resultMapping.json content
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | file_absolute_path | Yes | the resultMapping.json file path in OAM VM,
    ...                                 like /var/opt/nokia/performancemanagement/storage/results/resultMapping.json |

    ...    *RETURN VALUE*
    ...    the json file dictionary
    ...
    ${local_file}=  Get File From CU OAM To Local TestPC  ${file_absolute_path}  ${gnb_index}
    ${content}    get file    ${local_file}
    ${pm_result_mapping_dict}  Json.Loads     ${content}
    [Return]  ${pm_result_mapping_dict}

Get Latest CU PM File Generated Time
    [Arguments]  ${pm_file}   ${gnb_index}=${0}
    [Documentation]  get the generated time of latest pm report file
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pm_file | Yes | the report file name, like A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz|

    ...    *RETURN VALUE*
    ...    the linux time stamp of the report file generated, like 20210114.0315
    ...
    ${alias}  get unique id
    CU SSH To OAM     gnb_index=${gnb_index}  alias=${alias}
    ${cmd}=  set variable  ls -l ${PM_RESULT_DIR_IN_PMCORE} --time-style="+%Y%m%d.%H%M"|grep ${pm_file}
    ${out}   issh.Execute     command=${cmd}  alias=${alias}
    [Return]    ${out.strip().split()[5]}
    [Teardown]   Disconnect Interactive Connection    alias=${alias}

Get All Latest CU Counter Values Of One Measurement
    [Arguments]  ${pm_file_name}  ${gnb_index}=${0}
    [Documentation]  get all counters value under one measurement(in one report file)
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pm_file_name | Yes | the report file name, like A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz|

    ...    *RETURN VALUE*
    ...    counter value dict, like:
    ...    {'NRCELL-1': {'M55300C00000': '0',
    ...                  'M55300C00001': '0',
    ...                  'M55300C00002': '0'},
    ...     'NRCELL-2': {'M55300C00000': '0',
    ...                  'M55300C00001': '0',
    ...                  'M55300C00002': '0'}
    ...     }
    ...
    ${local_gz_pm_file}=  Get File From CU OAM To Local TestPC  ${PM_RESULT_DIR_IN_PMCORE}/${pm_file_name}  ${gnb_index}
    OperatingSystem.Run  gunzip ${local_gz_pm_file}
    ${pm_xml_report_file}  ${ext}  split extension   ${local_gz_pm_file}
    ${counter_values_of_one_mea}=  parse_pm_result_xml_file  ${pm_xml_report_file}
    [Return]  ${counter_values_of_one_mea}

Get The Given CU Measurement Info
    [Arguments]  ${measurement_id_list}  ${gnb_index}=0
    [Documentation]  get the given measurements info including counters value in the measurements, files amount,
    ...    the generated time of the latest report file, the lastest report file name.
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | measurement_id_list | Yes | measurements id list, like ['55300', '55302']|

    ...    *RETURN VALUE*
    ...    measurements info dict including counters value, file amount, latest file generated time and latest file name, like:
    ...    {'55300': {'NRCELL-1': {'M55300C00000': '0',
    ...                            'M55300C00001': '0',
    ...                            'M55300C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55300C00000': '0',
    ...                             'M55300C00001': '0',
    ...                             'M55300C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz'
    ...                },
    ...     '55302': {'NRCELL-1': {'M55302C00000': '0',
    ...                            'M55302C00001': '0',
    ...                            'M55302C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55302C00000': '0',
    ...                             'M55302C00001': '0',
    ...                             'M55302C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:11.xml.gz'
    ...                }
    ...    }
    ...
    ${reslut_mapping_content}=  Get CU PM Result Mapping File Content  ${PM_RESULT_DIR_IN_PMCORE}/resultMapping.json  ${gnb_index}
    ${all_measurements_info}=  create dictionary
    return from keyword if  "${reslut_mapping_content}"=="{}"  ${all_measurements_info}
    FOR  ${m_id}  IN  @{measurement_id_list}
      ${file_list}=  set variable  ${reslut_mapping_content['${m_id}']['filenames']}
      ${file_amount}=  get length  ${file_list}
      ${latest_file_name}=  set variable  ${file_list[0]}
      ${latest_file_generated_time}   Get Latest CU PM File Generated Time   ${latest_file_name}  ${gnb_index}
      ${counters_value}=  Get All Latest CU Counter Values Of One Measurement   ${latest_file_name}  ${gnb_index}
      &{one_measurement_info}=   create dictionary  file_amount=${file_amount}  latest_file_name=${latest_file_name}
    ...  latest_file_generated_time=${latest_file_generated_time}  &{counters_value}
      set to dictionary   ${all_measurements_info}   ${m_id}  ${one_measurement_info}
    END
    log dictionary  ${all_measurements_info}
    [Return]  ${all_measurements_info}


CU Measurement Report File Should Be Generated Successfully
    [Arguments]  ${measurement_id_list}  ${expect_mea_file_name_dict}   ${gnb_index}=0
    [Documentation]  judging the new report file should be generated, the current file amount should be more than
    ...    original file amount.
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | measurement_id_list | Yes | measurements id list, like ['55300', '55302']|
    ...    | org_meas_info | Yes | the original measurements info, obtained by 'Get The Given Measurement Info' |

    ...    *RETURN VALUE*
    ...    None
    ...
#    ${current_file_amount_dict}=  Get CU Measurement File Amount  ${measurement_id_list}  ${gnb_index}
     ${current_mea_file_name_dict}=   Get All Given CU Measurements Latest File Name   ${measurement_id_list}  ${gnb_index}
    FOR  ${m_id}  IN  @{measurement_id_list}
      run keyword and continue on failure   should be equal as strings
    ...   ${current_mea_file_name_dict['${m_id}']}   ${expect_mea_file_name_dict['${m_id}']}
    END

Wait For New CU Measurements Reports Generated
    [Arguments]  ${measurement_id_list}  ${expect_mea_file_name_dict}  ${interval}   ${gnb_index}=0
    [Documentation]  waiting the interval+1 minutes until the new report generated.
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | measurement_id_list | Yes | measurements id list, like ['55300', '55302']|
    ...    | org_meas_info | Yes | the original measurements info, obtained by 'Get The Given Measurement Info' |
    ...    | interval | the measurement interval |

    ...    *RETURN VALUE*
    ...    None
    ${wait_time}=  evaluate  int('${interval}')+1
    wait until keyword succeeds   ${wait_time}min   30sec  CU Measurement Report File Should Be Generated Successfully  ${measurement_id_list}
    ...  ${expect_mea_file_name_dict}   ${gnb_index}

Start CU Measurement Different Mo
    [Arguments]  ${counter_dn_map_list}  ${interval}  ${estimated_excution_time}  #${gnb_index}=0
    [Documentation]  start measurements which are in different MOs
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | counter_dn_map_list | Yes | counter and its dn map list, like [{'M55301C01':'NRCELL-1'},
    ...                                                                    {'M55031C01':'NRCELL-2'},
    ...                                                                    {'M55301C02':'NRCELL-1'},
    ...                                                                    {'M55301C02':'NRCELL-2'},
    ...                                                                    {'M55555C00':'NRCELL-1'},
    ...                                                                    {'M66666C00':'NRDU-1'}] |
    ...    | estimated_excution_time | Yes | the estimated excution time |
    ...    | interval | Yes | the measurement interval |

    ...    *RETURN VALUE*
    ...    the counter value, like {'M55300C00000_NRCELL-1': '0', 'M55300C00000_NRCELL-2': '0'}
    ...    the measurement info, like
    ...    {'55300': {'NRCELL-1': {'M55300C00000': '0',
    ...                            'M55300C00001': '0',
    ...                            'M55300C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55300C00000': '0',
    ...                             'M55300C00001': '0',
    ...                             'M55300C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz'
    ...                },
    ...     '55302': {'NRCELL-1': {'M55302C00000': '0',
    ...                            'M55302C00001': '0',
    ...                            'M55302C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55302C00000': '0',
    ...                             'M55302C00001': '0',
    ...                             'M55302C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:11.xml.gz'
    ...                }
    ...    }
    CU Sync To PM Timer Clock   ${interval}  ${estimated_excution_time}
    ${counter_value}  ${mea_info}   Get The Given CU Counters Value Under Different MO  ${counter_dn_map_list}
    [Return]  ${counter_value}  ${mea_info}

Stop CU Measurement Different Mo
    [Arguments]  ${counter_dn_map_list}  ${org_meas_info}   ${interval}  ${gnb_index}=0
    [Documentation]  stop measurements which are in different MOs and get the current counters value
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | counter_dn_map_list | Yes | counter and its dn map list, like [{'M55301C01':'NRCELL-1'},
     ...                                                                    {'M55031C01':'NRCELL-2'},
     ...                                                                    {'M55301C02':'NRCELL-1'},
     ...                                                                    {'M55301C02':'NRCELL-2'},
     ...                                                                    {'M55555C00':'NRCELL-1'},
     ...                                                                    {'M66666C00':'NRDU-1'}] |
    ...    | org_meas_info | Yes | the original measurements info, obtained by 'Get The Given Measurement Info' |
    ...    | interval | Yes | the measurement interval |

    ...    *RETURN VALUE*
    ...    the counter value, like {'M55300C00000_NRCELL-1': '0', 'M55300C00000_NRCELL-2': '0'}
    ...    the measurement info, like
    ...    {'55300': {'NRCELL-1': {'M55300C00000': '0',
    ...                            'M55300C00001': '0',
    ...                            'M55300C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55300C00000': '0',
    ...                             'M55300C00001': '0',
    ...                             'M55300C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz'
    ...                },
    ...     '55302': {'NRCELL-1': {'M55302C00000': '0',
    ...                            'M55302C00001': '0',
    ...                            'M55302C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55302C00000': '0',
    ...                             'M55302C00001': '0',
    ...                             'M55302C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:11.xml.gz'
    ...                }
    ...    }
    ...    *Example*
    ...    | ${counter_dn_map_list} | create list |
    ...    | ${counter_1} | create dictionary | M55300C00000 | NRCELL-1 |
    ...    | append to list | ${counter_dn_map_list} | ${counter_1} |
    ...    | ${counter_2} | create dictionary | M55300C00000 | NRCELL-2 |
    ...    | append to list | ${counter_dn_map_list} | ${counter_2} |
    ...    | ${started_counter_value} | ${started_mea_info} | Start Measurement Different Mo | ${counter_dn_map_list} |
    ...    ...                                                                                interval=${15} | estimated_excution_time=${2}|
    ...    | Log Dictionary |  ${started_counter_value} |
    ...    | Log Dictionary | ${started_mea_info} |
    ...    | Do Your Operation |
    ...    | ${cur_counter_value} | ${cur_mea_info} | Stop Measurement Different Mo | ${counter_dn_map_list} |${started_mea_info} |
    ...    ...                                                                        interval=${15} |
    ...    | Log Dictionary | ${cur_counter_value} |
    ...    | log dictionary | ${cur_mea_info} |
    ...
    ${mea_id_list}   _Get Mea Id List  ${counter_dn_map_list}
	${expect_mea_file_name_dict}=  Gen All The Given CU Measurements File Names  ${mea_id_list}  ${org_meas_info}  ${interval}  ${gnb_index}
    Wait For New CU Measurements Reports Generated  ${mea_id_list}  ${expect_mea_file_name_dict}   ${interval}   ${gnb_index}

#    Wait For New CU Measurements Reports Generated  ${mea_id_list}  ${org_meas_info}   ${interval}   ${gnb_index}
    ${counter_value}   ${mea_info}   Get The Given CU Counters Value Under Different MO  ${counter_dn_map_list}
    [Return]  ${counter_value}   ${mea_info}

Start CU Measurement Same Mo
    [Arguments]  ${counter_id_list}  ${dn}  ${interval}  ${estimated_excution_time}  ${gnb_index}=0
    [Documentation]  start measurements which are in the same MOs
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id_list | Yes | the counter id list, like: ['M55300C00000', 'M55300C00002'] |
    ...    | dn | Yes | the dn name which the counter located in, like NRCELL-1|
    ...    | estimated_excution_time | Yes | the estimated excution time |
    ...    | interval | Yes | the measurement interval |

    ...    *RETURN VALUE*
    ...    the counter value, like {'M55300C00000': '0', 'M55302C00000': '0'}
    ...    the measurement info, like
    ...    {'55300': {'NRCELL-1': {'M55300C00000': '0',
    ...                            'M55300C00001': '0',
    ...                            'M55300C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55300C00000': '0',
    ...                             'M55300C00001': '0',
    ...                             'M55300C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz'
    ...                },
    ...     '55302': {'NRCELL-1': {'M55302C00000': '0',
    ...                            'M55302C00001': '0',
    ...                            'M55302C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55302C00000': '0',
    ...                             'M55302C00001': '0',
    ...                             'M55302C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:11.xml.gz'
    ...                }
    ...    }
    CU Sync To PM Timer Clock   ${interval}  ${estimated_excution_time}
    ${counters_value}  ${mea_info}   Get The Given CU Counters Value Under The Same MO  ${counter_id_list}  ${dn}  ${gnb_index}
    [Return]  ${counters_value}  ${mea_info}

Stop CU Measurement Same Mo
    [Arguments]  ${counter_id_list}   ${dn}  ${org_meas_info}   ${interval}  ${gnb_index}=0
    [Documentation]  stop measurements which are in the same MOs, waiting for the new report generated
    ...    and return the counters value
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id_list | Yes | the counter id list, like: ['M55300C00000', 'M55300C00002'] |
    ...    | dn | Yes | the dn name which the counter located in, like NRCELL-1|
    ...    | org_meas_info | Yes | the original measurements info, obtained by 'Get The Given Measurement Info' |
    ...    | interval | Yes | the measurement interval |

    ...    *RETURN VALUE*
    ...    the counter value, like {'M55300C00000': '0', 'M55302C00000': '0'}
    ...    the measurement info, like
    ...    {'55300': {'NRCELL-1': {'M55300C00000': '0',
    ...                            'M55300C00001': '0',
    ...                            'M55300C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55300C00000': '0',
    ...                             'M55300C00001': '0',
    ...                             'M55300C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz'
    ...                },
    ...     '55302': {'NRCELL-1': {'M55302C00000': '0',
    ...                            'M55302C00001': '0',
    ...                            'M55302C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55302C00000': '0',
    ...                             'M55302C00001': '0',
    ...                             'M55302C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:11.xml.gz'
    ...                }
    ...    }
    ...    *Example*
    ...    | ${counter_id_list}= |  create list | M55300C00000 | M55300C00002 | M55302C00000 |
    ...    | ${dn}= |  set variable  | NRCELL-1 |
    ...    | ${started_counter_value} | ${started_mea_info} | Start Measurement Same Mo | ${counter_id_list} | ${dn} |
    ...    ...                                                                            interval=${15} | estimated_excution_time=${2} |
    ...    | Log Dictionary |  ${started_counter_value} |
    ...    | Log Dictionary | ${started_mea_info} |
    ...    | Do Your Operation |
    ...    | ${cur_counter_value} | ${cur_mea_info} | Stop Measurement Same Mo | ${counter_id_list} | ${dn} | ${started_mea_info} |
    ...    ...                                                                  interval=${15} |
    ...    | Log Dictionary | ${cur_counter_value} |
    ...    | log dictionary | ${cur_mea_info} |
    ...
    ${mea_id_list}   ${counter_id_mea_id_map}  _Get Mea Id List And Counter Mea Map Dict From Counter Id List  ${counter_id_list}
    ${expect_mea_file_name_dict}   Gen All The Given CU Measurements File Names  ${mea_id_list}  ${org_meas_info}  ${interval}  ${gnb_index}
    Wait For New CU Measurements Reports Generated  ${mea_id_list}  ${expect_mea_file_name_dict}   ${interval}   ${gnb_index}

#    Wait For New CU Measurements Reports Generated  ${mea_id_list}  ${org_meas_info}   ${interval}   ${gnb_index}
    ${counter_value}   ${mea_info}   Get The Given CU Counters Value Under The Same MO  ${counter_id_list}  ${dn}  ${gnb_index}
    [Return]  ${counter_value}   ${mea_info}

Get The Given CU Counters Value Under The Same MO
    [Arguments]  ${counter_id_list}   ${mea_dn}  ${gnb_index}=0
    [Documentation]  get the given counters value under the same MO,
    ...  counter_id_list can be in different measurements or the same measurements,
    ...  like ['M55301C00000', 'M55301C00101', 'M55303C00001'], but all of the counters must be in the same MO, like NRCELL-1
    ...  for mea_dn, no need to be given the absolute dist name, just can be given like NRCELL-1
    ...
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id_list | Yes | the counter id list, like: ['M55300C00000', 'M55300C00002'] |
    ...    | mea_dn | Yes | the dn name which the counter located in, like NRCELL-1|
    ...
    ...    *RETURN VALUE*
    ...    the counter value, like {'M55300C00000': '0', 'M55302C00000': '0'}
    ...    the measurement info, like
    ...    {'55300': {'NRCELL-1': {'M55300C00000': '0',
    ...                            'M55300C00001': '0',
    ...                            'M55300C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55300C00000': '0',
    ...                             'M55300C00001': '0',
    ...                             'M55300C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz'
    ...                },
    ...     '55302': {'NRCELL-1': {'M55302C00000': '0',
    ...                            'M55302C00001': '0',
    ...                            'M55302C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55302C00000': '0',
    ...                             'M55302C00001': '0',
    ...                             'M55302C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:11.xml.gz'
    ...                }
    ...    }
    ...
    ${counter_value_dict}=   create dictionary
    ${mea_id_list}  ${counter_id_mea_id_map}  _Get Mea Id List And Counter Mea Map Dict From Counter Id List  ${counter_id_list}
    ${mea_info}=   Get The Given CU Measurement Info    ${mea_id_list}   ${gnb_index}
    FOR  ${counter_id}   IN   @{counter_id_list}
      ${m_id}=  set variable  ${counter_id_mea_id_map['${counter_id}']}
      Run Keyword If  ${mea_info}  set to dictionary  ${counter_value_dict}  ${counter_id}  ${mea_info['${m_id}']['${mea_dn}']['${counter_id}']}
    ...  ELSE  set to dictionary  ${counter_value_dict}  ${counter_id}  0
    END
    [Return]  ${counter_value_dict}  ${mea_info}


Get The Given CU Counters Value Under Different MO
     [Arguments]  ${counter_id_dn_map_list}  ${gnb_index}=0
     [Documentation]  get the given counters value under the different MO.
     ...    *AUTHOR* calla.wang@nokia-sbell.com
     ...
     ...    | Input Parameters | Man. | Description |
     ...    | counter_dn_map_list | Yes | counter and its dn map list, like [{'M55301C01':'NRCELL-1'},
     ...                                                                    {'M55031C01':'NRCELL-2'},
     ...                                                                    {'M55301C02':'NRCELL-1'},
     ...                                                                    {'M55301C02':'NRCELL-2'},
     ...                                                                    {'M55555C00':'NRCELL-1'},
     ...                                                                    {'M66666C00':'NRDU-1'}] |
     ...
     ...    *RETURN VALUE*
     ...    the counter value, like {'M55300C00000_NRCELL-1': '0', 'M55300C00000_NRCELL-2': '0'}
     ...    the measurement info, like
     ...    {'55300': {'NRCELL-1': {'M55300C00000': '0',
     ...                            'M55300C00001': '0',
     ...                            'M55300C00002': '0'
     ...                            },
     ...                'NRCELL-2': {'M55300C00000': '0',
     ...                             'M55300C00001': '0',
     ...                             'M55300C00002': '0'
     ...                             },
     ...                'file_amount': 72,
     ...                'latest_file_generated_time': '20210114.0315',
     ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz'
     ...                },
     ...     '55302': {'NRCELL-1': {'M55302C00000': '0',
     ...                            'M55302C00001': '0',
     ...                            'M55302C00002': '0'
     ...                            },
     ...                'NRCELL-2': {'M55302C00000': '0',
     ...                             'M55302C00001': '0',
     ...                             'M55302C00002': '0'
     ...                             },
     ...                'file_amount': 72,
     ...                'latest_file_generated_time': '20210114.0315',
     ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:11.xml.gz'
     ...                }
     ...    }
     ...
     ${counter_value_dict}=  create dictionary
     ${mea_id_list}=   _Get Mea Id List  ${counter_id_dn_map_list}
     ${mea_info}=   Get The Given CU Measurement Info    ${mea_id_list}   ${gnb_index}
     FOR  ${item}  IN  @{counter_id_dn_map_list}
       ${counter_id}   ${dn}   get dictionary items  ${item}
       @{words}=    split string  ${counter_id}   C
       ${mea_id}=   Fetch From Right  ${words[0]}  M
       Run Keyword If  ${mea_info}  set to dictionary
     ...  ${counter_value_dict}  ${counter_id}_${dn}  ${mea_info['${mea_id}']['${dn}']['${counter_id}']}
     ...  ELSE  set to dictionary  ${counter_value_dict}  ${counter_id}_${dn}  0
     END
     [Return]  ${counter_value_dict}  ${mea_info}

############################## CU PM End ##############################
====== CU PM End ======
     log to console  \n*** only used for readable ***

############################## CU CNF PM Start ##############################
====== CU CNF PM Start ======
     log to console  \n*** only used for readable ***

CU CNF Sync To PM Timer Clock
    [Arguments]   ${PM_collecting_interval}=5   ${estimated_traffic_generating_duration}=7   ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   disconnect interactive connection  alias=${alias}
    [Documentation]  vCU Sync To PM Timer Clock.
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  PM_collecting_interval                | No  | PM_collecting_interval, unit is minute, default value is 15 |
    ...    |  estimated_traffic_generating_duration | No | estimated_traffic_generating_duration, unit is minute, default value is 7 |
    ...    |  gnb_index  |  No   | gnb index defined in init.py and indicate which cu will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | CU CNF Sync To PM Timer Clock | PM_collecting_interval=5  | estimated_traffic_generating_duration=2 |
    ...    | # generate traffic to triggle counter increasement |
    ...
    Log To Console  Begin: CU CNF Sync To PM Timer Clock
    ${alias}=  Connect To CU K8S Master With Admin  gnb_index=${gnb_index}
    ${ret}=  CU Kubectl Exec   pod_abbr=oamcm   container=oamcm   command=date +"%Y-%m-%d %H:%M:%S"   alias=${alias}
    ...                        check_result=${True}  gnb_index=${gnb_index}
    ${container_time}=    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}
    Log To Console   Current oamcm system time:${container_time[0]}

    ${matches}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:(\\d{2}):\\d{2}  1
    ${minutes}  Set Variable   ${matches[0]}

    ${estimated_traffic_generating_duration}  Evaluate   int('${estimated_traffic_generating_duration}')
    ${PM_collecting_interval}  Evaluate  int('${PM_collecting_interval}')
    ${minutes}  Evaluate  int('${minutes}')

    Run Keyword If
      ...   ${PM_collecting_interval}!=5 and ${PM_collecting_interval}!=15 and ${PM_collecting_interval}!=30 and ${PM_collecting_interval}!=60
      ...    Fail   PM_collecting_interval should be 5, 15, 30 or 60 minutes.
    _Wait Some Time For Next Round PM Collecting    collecting_interval=${PM_collecting_interval}
     ...   estimated_traffic_generating_duration=${estimated_traffic_generating_duration}   vm_minutes=${minutes}

    ${ret}=  CU Kubectl Exec   pod_abbr=oamcm    container=oamcm  command=date +"%Y-%m-%d %H:%M:%S"   alias=${alias}  check_result=${True}

    ${time}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}
    Log To Console   Current oamcm system time:${time[0]}
    Log To Console  End: CU CNF Sync To PM Timer Clock

CU CNF Get PM Related Files From pmcore Container To Local TestPC
    [Arguments]    ${file_absolute_path}   ${gnb_index}=0
    [Documentation]  Get file from pm container to local UTE. The file will be stored under UTE
    ...  ${OUTPUT_DIR}/${TEST_NAME}/${START_TIME}/pm_related directory.
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | file_absolute_path | Yes | the file path in pmcore container,
    ...                                 like /var/opt/nokia/performancemanagement/storage/results/resultMapping.json |
    ...    |  gnb_index  |  No   | gnb index defined in init.py and indicate which cu will be used, 0 in default |

    ...    *RETURN VALUE*
    ...    The file path under UTE,
    ...    like /home/ute/robotws5g/testsuite/AIC/TESTCASE__Test_PM/2021_01_14_04_17_04/pm_related/resultMapping.json
    ...
    ${username}=  Set Variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ${password}=  Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    ${alias}=    Connect To CU Node     pod_abbr=pm   gnb_index=${gnb_index}
    ${container_id}   Get CU Container ID   pod_abbr=pm   ctn_abbr=pmcore  alias=${alias}  gnb_index=${gnb_index}
    ${path}   ${file_name}  OperatingSystem.Split Path   ${file_absolute_path}
    ${out}   issh.Execute   command=docker cp ${container_id}:${file_absolute_path} ./${file_name}    alias=${alias}
    ${local_file}   Get A File    pm_related   ${file_name}
    issh.execute   command=ls -al  alias=${alias}
    ${pod_located_node}=   Get CU Pod Located Node  pod_abbr=pm  alias=${EMPTY}   gnb_index=${gnb_index}
    ${ns}=  Get CU Namespace From Testline  ${gnb_index}
    ${master_conn_alias}=   Connect To CU K8S Master With Admin   gnb_index=${gnb_index}
    issh.set prompt   assword:   alias=${master_conn_alias}
    ${out}=  issh.execute   command=scp ${username}@${pod_located_node}:./${file_name} /${username}/${ns}/${file_name}
    ...                     check_result=${False}   alias=${master_conn_alias}
    issh.set Prompt    \\#    alias=${master_conn_alias}
    run keyword if   "assword:" in """${out}"""   issh.Execute
    ...   command=${password}
    ...   check_result=${False}  alias=${master_conn_alias}
    issh.Download File   remote_path=/${username}/${ns}/${file_name}    local_path=${local_file}   alias=${master_conn_alias}
    [Return]  ${local_file}
    [Teardown]   Run keywords  Disconnect Interactive Connection  alias=${alias}   AND
     ...             Disconnect Interactive Connection  alias=${master_conn_alias}

CU CNF Get PM Result Mapping File Content
    [Arguments]   ${file_absolute_path}   ${gnb_index}=0
    [Documentation]  Get the file resultMapping.json content.
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | file_absolute_path | Yes | the resultMapping.json file path in pmcore container,
    ...                                 like /var/opt/nokia/performancemanagement/storage/results/resultMapping.json |
    ...    |  gnb_index  |  No   | gnb index defined in init.py and indicate which cu will be used, 0 in default |

    ...    *RETURN VALUE*
    ...    The json file dictionary.
    ...
    ${local_file}=  CU CNF Get PM Related Files From pmcore Container To Local TestPC   ${file_absolute_path}   ${gnb_index}
    ${content}    get file    ${local_file}
    ${pm_result_mapping_dict}  Json.Loads     ${content}
    [Return]  ${pm_result_mapping_dict}

CU CNF Get Latest PM File Generated Time
    [Arguments]  ${pm_file}   ${gnb_index}=0
    [Documentation]  Get the generated time of latest pm report file.
    ...    *AUTHOR*  fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pm_file | Yes | the report file name, like A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz |
    ...    |  gnb_index  |  No   | gnb index defined in init.py and indicate which cu will be used, 0 in default |

    ...    *RETURN VALUE*
    ...    The linux time stamp of the report file generated, like 20210114.0315
    ...
    ${alias}=  Connect To CU K8S Master With Admin   gnb_index=${gnb_index}
    ${cmd}=  set variable  ls -l ${PM_RESULT_DIR_IN_PMCORE} --time-style="+%Y%m%d.%H%M"|grep ${pm_file}
    ${out}   CU Kubectl Exec  pod_abbr=pm  container=pmcore  command=${cmd}  alias=${alias}  gnb_index=${gnb_index}
    [Return]    ${out.split()[-2]}
    [Teardown]   Disconnect Interactive Connection    alias=${alias}

CU CNF Get All Latest Counter Values Of One Measurement
    [Arguments]  ${pm_file_name}   ${gnb_index}=0
    [Documentation]  Get all counters value under one measurement(in one report file)
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  pm_file_name | Yes | the report file name, like A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz|
    ...    |  gnb_index  |  No   | gnb index defined in init.py and indicate which cu will be used, 0 in default |

    ...    *RETURN VALUE*
    ...    counter value dict, like:
    ...    {'NRCELL-1': {'M55300C00000': '0',
    ...                  'M55300C00001': '0',
    ...                  'M55300C00002': '0'},
    ...     'NRCELL-2': {'M55300C00000': '0',
    ...                  'M55300C00001': '0',
    ...                  'M55300C00002': '0'}
    ...     }
    ...
    ${local_gz_pm_file}=  CU CNF Get PM Related Files From pmcore Container To Local TestPC  ${PM_RESULT_DIR_IN_PMCORE}/${pm_file_name}
    ...  ${gnb_index}
    OperatingSystem.Run  gunzip ${local_gz_pm_file}
    ${pm_xml_report_file}  ${ext}  split extension   ${local_gz_pm_file}
    ${counter_values_of_one_mea}=  parse_pm_result_xml_file  ${pm_xml_report_file}
    [Return]  ${counter_values_of_one_mea}

CU CNF Get The Given Measurement Info
    [Arguments]  ${measurement_id_list}  ${gnb_index}=0
    [Documentation]  Get the given measurements info including counters value in the measurements, files amount,
    ...    the generated time of the latest report file, the lastest report file name.
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    |  measurement_id_list | Yes | measurements id list, like ['55300', '55302']|
    ...    |  gnb_index  |  No   | gnb index defined in init.py and indicate which cu will be used, 0 in default |

    ...    *RETURN VALUE*
    ...    measurements info dict including counters value, file amount, latest file generated time and latest file name, like:
    ...    {'55300': {'NRCELL-1': {'M55300C00000': '0',
    ...                            'M55300C00001': '0',
    ...                            'M55300C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55300C00000': '0',
    ...                             'M55300C00001': '0',
    ...                             'M55300C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz'
    ...                },
    ...     '55302': {'NRCELL-1': {'M55302C00000': '0',
    ...                            'M55302C00001': '0',
    ...                            'M55302C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55302C00000': '0',
    ...                             'M55302C00001': '0',
    ...                             'M55302C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:11.xml.gz'
    ...                }
    ...    }
    ...    *Example*
    ...    | ${mea_id_list}= | create list | 55300 | 55302 | 55303 |
    ...    | ${mea_info}= | Get The Given Measurement Info | ${mea_id_list} |
    ...    **OR**
    ...    | ${counter_id_list}= | create list | M55300C00000 | M55300C00002 | M55302C00000 |
    ...    | ${mea_id_list} | ${counter_id_mea_id_map} | _Get Mea Id List And Counter Mea Map Dict From Counter Id List | ${counter_id_list}
    ...    | ${mea_info}= | Get The Given Measurement Info | ${mea_id_list} |
    ...
    ${reslut_mapping_content}=  CU CNF Get PM Result Mapping File Content  ${PM_RESULT_DIR_IN_PMCORE}/resultMapping.json
    ...                         gnb_index=${gnb_index}
    ${all_measurements_info}=  create dictionary
    return from keyword if  "${reslut_mapping_content}"=="{}"  ${all_measurements_info}
    FOR  ${m_id}  IN  @{measurement_id_list}
      ${file_list}=  set variable  ${reslut_mapping_content['${m_id}']['filenames']}
      ${file_amount}=  get length  ${file_list}
      ${latest_file_name}=  set variable  ${file_list[0]}
      ${latest_file_generated_time}   CU CNF Get Latest PM File Generated Time   ${latest_file_name}  ${gnb_index}
      ${counters_value}=  CU CNF Get All Latest Counter Values Of One Measurement   ${latest_file_name}  gnb_index=${gnb_index}
      &{one_measurement_info}=   create dictionary  file_amount=${file_amount}  latest_file_name=${latest_file_name}
    ...  latest_file_generated_time=${latest_file_generated_time}  &{counters_value}
      set to dictionary   ${all_measurements_info}   ${m_id}  ${one_measurement_info}
    END
    log dictionary  ${all_measurements_info}
    [Return]  ${all_measurements_info}

CU CNF Get Measurement File Amount
    [Arguments]  ${measurement_id_list}  ${gnb_index}=0
    [Documentation]  Get the given measurents report file amount.
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | measurement_id_list | Yes | measurements id list, like ['55300', '55302']|

    ...    *RETURN VALUE*
    ...    measurements file admount dict, like {'55300':30, '55303':32}
    ...
    ${measurement_file_ammount_dict}=   create dictionary
    ${reslut_mapping_content}=  Get PM Result Mapping File Content  ${PM_RESULT_DIR_IN_PMCORE}/resultMapping.json  ${gnb_index}
    FOR  ${m_id}  IN  @{measurement_id_list}
      ${file_list}=  set variable  ${reslut_mapping_content['${m_id}']['filenames']}
      ${file_amount}=  get length  ${file_list}
      set to dictionary  ${measurement_file_ammount_dict}  ${m_id}  ${file_amount}
    END
    [Return]  ${measurement_file_ammount_dict}

CU CNF Get All Measurement Latest File Name
    [Arguments]  ${measurement_id_list}  ${gnb_index}=0
    [Documentation]  Get the given measurents report file amount.
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | measurement_id_list | Yes | measurements id list, like ['55300', '55302']|

    ...    *RETURN VALUE*
    ...    measurements file admount dict, like {'55300':30, '55303':32}
    ...
    ${measurement_file_name_dict}=   create dictionary
    ${reslut_mapping_content}=  CU CNF Get PM Result Mapping File Content  ${PM_RESULT_DIR_IN_PMCORE}/resultMapping.json  ${gnb_index}
    FOR  ${m_id}  IN  @{measurement_id_list}
      ${file_list}=  set variable  ${reslut_mapping_content['${m_id}']['filenames']}
      set to dictionary  ${measurement_file_name_dict}  ${m_id}  ${file_list[0]}
    END
    [Return]  ${measurement_file_name_dict}

CU CNF Start Measurement Different Mo
    [Arguments]  ${counter_dn_map_list}  ${interval}  ${estimated_excution_time}  ${gnb_index}=0
    [Documentation]  Start measurements which are in different MOs.
    ...    the robot log is put in the \\verification\Public_Shared\PCI\Logs\log_start_stop_different_mo.html
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | counter_dn_map_list | Yes | counter and its dn map list, like [{'M55301C01':'NRCELL-1'},
    ...                                                                    {'M55031C01':'NRCELL-2'},
    ...                                                                    {'M55301C02':'NRCELL-1'},
    ...                                                                    {'M55301C02':'NRCELL-2'},
    ...                                                                    {'M55555C00':'NRCELL-1'},
    ...                                                                    {'M66666C00':'NRDU-1'}] |
    ...    | estimated_excution_time | Yes | the estimated excution time |
    ...    | interval | Yes | the measurement interval |

    ...    *RETURN VALUE*
    ...    the counter value, like {'M55300C00000_NRCELL-1': '0', 'M55300C00000_NRCELL-2': '0'}
    ...    the measurement info, like
    ...    {'55300': {'NRCELL-1': {'M55300C00000': '0',
    ...                            'M55300C00001': '0',
    ...                            'M55300C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55300C00000': '0',
    ...                             'M55300C00001': '0',
    ...                             'M55300C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz'
    ...                },
    ...     '55302': {'NRCELL-1': {'M55302C00000': '0',
    ...                            'M55302C00001': '0',
    ...                            'M55302C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55302C00000': '0',
    ...                             'M55302C00001': '0',
    ...                             'M55302C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:11.xml.gz'
    ...                }
    ...    }
    ...    *Example*
    ...    | ${counter_dn_map_list} | create list |
    ...    | ${counter_1} | create dictionary | M55300C00000 | NRCELL-1 |
    ...    | append to list | ${counter_dn_map_list} | ${counter_1} |
    ...    | ${counter_2} | create dictionary | M55300C00000 | NRCELL-2 |
    ...    | append to list | ${counter_dn_map_list} | ${counter_2} |
    ...    | ${started_counter_value} | ${started_mea_info} | Start Measurement Different Mo | ${counter_dn_map_list} |
    ...    ...                                                                                interval=${15} | estimated_excution_time=${2}|
    ...
    CU CNF Sync To PM Timer Clock  PM_collecting_interval=${interval}  estimated_traffic_generating_duration=${estimated_excution_time}
    ${counter_value}  ${mea_info}  CU CNF Get The Given Counters Value Under Different MO  ${counter_dn_map_list}  ${gnb_index}
    [Return]  ${counter_value}  ${mea_info}

CU CNF Stop Measurement Different Mo
    [Arguments]  ${counter_dn_map_list}  ${org_meas_info}   ${interval}  ${gnb_index}=0
    [Documentation]  Stop measurements which are in different MOs and get the current counters value
    ...    the robot log is put in the \\verification\Public_Shared\PCI\Logs\log_start_stop_different_mo.html
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | counter_dn_map_list | Yes | counter and its dn map list, like [{'M55301C01':'NRCELL-1'},
     ...                                                                    {'M55031C01':'NRCELL-2'},
     ...                                                                    {'M55301C02':'NRCELL-1'},
     ...                                                                    {'M55301C02':'NRCELL-2'},
     ...                                                                    {'M55555C00':'NRCELL-1'},
     ...                                                                    {'M66666C00':'NRDU-1'}] |
    ...    | org_meas_info | Yes | the original measurements info, obtained by 'Get The Given Measurement Info' |
    ...    | interval | Yes | the measurement interval |

    ...    *RETURN VALUE*
    ...    the counter value, like {'M55300C00000_NRCELL-1': '0', 'M55300C00000_NRCELL-2': '0'}
    ...    the measurement info, like
    ...    {'55300': {'NRCELL-1': {'M55300C00000': '0',
    ...                            'M55300C00001': '0',
    ...                            'M55300C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55300C00000': '0',
    ...                             'M55300C00001': '0',
    ...                             'M55300C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz'
    ...                },
    ...     '55302': {'NRCELL-1': {'M55302C00000': '0',
    ...                            'M55302C00001': '0',
    ...                            'M55302C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55302C00000': '0',
    ...                             'M55302C00001': '0',
    ...                             'M55302C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:11.xml.gz'
    ...                }
    ...    }
    ...    *Example*
    ...    | ${counter_dn_map_list} | create list |
    ...    | ${counter_1} | create dictionary | M55300C00000 | NRCELL-1 |
    ...    | append to list | ${counter_dn_map_list} | ${counter_1} |
    ...    | ${counter_2} | create dictionary | M55300C00000 | NRCELL-2 |
    ...    | append to list | ${counter_dn_map_list} | ${counter_2} |
    ...    | ${started_counter_value} | ${started_mea_info} | Start Measurement Different Mo | ${counter_dn_map_list} |
    ...    ...                                                                                interval=${15} | estimated_excution_time=${2}|
    ...    | Log Dictionary |  ${started_counter_value} |
    ...    | Log Dictionary | ${started_mea_info} |
    ...    | Do Your Operation |
    ...    | ${cur_counter_value} | ${cur_mea_info} | Stop Measurement Different Mo | ${counter_dn_map_list} |${started_mea_info} |
    ...    ...                                                                        interval=${15} |
    ...    | Log Dictionary | ${cur_counter_value} |
    ...    | log dictionary | ${cur_mea_info} |
    ...
    ${mea_id_list}   _Get Mea Id List  ${counter_dn_map_list}
	${expect_mea_file_name_dict}=  CU CNF Gen All The Given Measurements File Names  ${mea_id_list}  ${org_meas_info}  ${interval}  ${gnb_index}
    CU CNF Wait For New Measurements Reports Generated  ${mea_id_list}  ${expect_mea_file_name_dict}   ${interval}   ${gnb_index}
    ${counter_value}   ${mea_info}   CU CNF Get The Given Counters Value Under Different MO  ${counter_dn_map_list}
    [Return]  ${counter_value}   ${mea_info}

CU CNF Start Measurement Same Mo
    [Arguments]  ${counter_id_list}  ${dn}  ${interval}  ${estimated_excution_time}  ${gnb_index}=0
    [Documentation]  Start measurements which are in the same MOs.
    ...    the robot log is put in \\verification\Public_Shared\PCI\Logs\log_start_stop_same_mo.html
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id_list | Yes | the counter id list, like: ['M55300C00000', 'M55300C00002'] |
    ...    | dn | Yes | the dn name which the counter located in, like NRCELL-1|
    ...    | estimated_excution_time | Yes | the estimated excution time |
    ...    | interval | Yes | the measurement interval |

    ...    *RETURN VALUE*
    ...    the counter value, like {'M55300C00000': '0', 'M55302C00000': '0'}
    ...    the measurement info, like
    ...    {'55300': {'NRCELL-1': {'M55300C00000': '0',
    ...                            'M55300C00001': '0',
    ...                            'M55300C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55300C00000': '0',
    ...                             'M55300C00001': '0',
    ...                             'M55300C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz'
    ...                },
    ...     '55302': {'NRCELL-1': {'M55302C00000': '0',
    ...                            'M55302C00001': '0',
    ...                            'M55302C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55302C00000': '0',
    ...                             'M55302C00001': '0',
    ...                             'M55302C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:11.xml.gz'
    ...                }
    ...    }
    ...    *Example*
    ...    | ${counter_id_list}= |  create list | M55300C00000 | M55300C00002 | M55302C00000 |
    ...    | ${dn}= |  set variable  | NRCELL-1 |
    ...    | ${started_counter_value} | ${started_mea_info} | Start Measurement Same Mo | ${counter_id_list} | ${dn} |
    ...    ...                                                                            interval=${15} | estimated_excution_time=${2} |
    ...    | Log Dictionary |  ${started_counter_value} |
    ...    | Log Dictionary | ${started_mea_info} |
    ...
    CU CNF Sync To PM Timer Clock  PM_collecting_interval=${interval}
    ...                            estimated_traffic_generating_duration=${estimated_excution_time}
    ...                            gnb_index=${gnb_index}
    ${counters_value}  ${mea_info}   CU CNF Get The Given Counters Value Under The Same MO   ${counter_id_list}   ${dn}
    [Return]  ${counters_value}  ${mea_info}

CU CNF Stop Measurement Same Mo
    [Arguments]  ${counter_id_list}   ${dn}  ${org_meas_info}   ${interval}  ${gnb_index}=0
    [Documentation]  Stop measurements which are in the same MOs, waiting for the new report generated
    ...    the robot log is put in \\verification\Public_Shared\PCI\Logs\log_start_stop_same_mo.html
    ...    and return the counters value
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id_list | Yes | the counter id list, like: ['M55300C00000', 'M55300C00002'] |
    ...    | dn | Yes | the dn name which the counter located in, like NRCELL-1|
    ...    | org_meas_info | Yes | the original measurements info, obtained by 'Get The Given Measurement Info' |
    ...    | interval | Yes | the measurement interval |

    ...    *RETURN VALUE*
    ...    the counter value, like {'M55300C00000': '0', 'M55302C00000': '0'}
    ...    the measurement info, like
    ...    {'55300': {'NRCELL-1': {'M55300C00000': '0',
    ...                            'M55300C00001': '0',
    ...                            'M55300C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55300C00000': '0',
    ...                             'M55300C00001': '0',
    ...                             'M55300C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz'
    ...                },
    ...     '55302': {'NRCELL-1': {'M55302C00000': '0',
    ...                            'M55302C00001': '0',
    ...                            'M55302C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55302C00000': '0',
    ...                             'M55302C00001': '0',
    ...                             'M55302C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:11.xml.gz'
    ...                }
    ...    }
    ...    *Example*
    ...    | ${counter_id_list}= |  create list | M55300C00000 | M55300C00002 | M55302C00000 |
    ...    | ${dn}= |  set variable  | NRCELL-1 |
    ...    | ${started_counter_value} | ${started_mea_info} |  CU CNF Start Measurement Same Mo | ${counter_id_list} | ${dn} |
    ...    ...                                                                            interval=${15} | estimated_excution_time=${2} |
    ...    | Log Dictionary |  ${started_counter_value} |
    ...    | Log Dictionary | ${started_mea_info} |
    ...    | Do Your Operation |
    ...    | ${cur_counter_value} | ${cur_mea_info} | CU CNF Stop Measurement Same Mo | ${counter_id_list} | ${dn} | ${started_mea_info} |
    ...    ...                                                                  interval=${15} |
    ...    | Log Dictionary | ${cur_counter_value} |
    ...    | log dictionary | ${cur_mea_info} |
    ...
    ${mea_id_list}   ${counter_id_mea_id_map}  _Get Mea Id List And Counter Mea Map Dict From Counter Id List  ${counter_id_list}
    ${expect_mea_file_name_dict}=  CU CNF Gen All The Given Measurements File Names  ${mea_id_list}  ${org_meas_info}  ${interval}  ${gnb_index}
    CU CNF Wait For New Measurements Reports Generated  ${mea_id_list}  ${expect_mea_file_name_dict}   ${interval}   ${gnb_index}
    ${counter_value}   ${mea_info}=   CU CNF Get The Given Counters Value Under The Same MO  ${counter_id_list}  ${dn}
    [Return]  ${counter_value}   ${mea_info}

CU CNF Wait For New Measurements Reports Generated
    [Arguments]  ${measurement_id_list}  ${expect_mea_file_name_dict}  ${interval}   ${gnb_index}=0
    [Documentation]  Waiting the interval+1 minutes until the new report generated.
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | measurement_id_list | Yes | measurements id list, like ['55300', '55302']|
    ...    | org_meas_info | Yes | the original measurements info, obtained by 'Get The Given Measurement Info' |
    ...    | interval | the measurement interval |

    ...    *RETURN VALUE*
    ...    None

    ${wait_time}=  evaluate  int('${interval}')+1
    wait until keyword succeeds   ${wait_time}min   30sec  CU CNF Measurement Report File Should Be Generated Successfully
    ...   ${measurement_id_list}   ${expect_mea_file_name_dict}   ${gnb_index}

CU CNF Measurement Report File Should Be Generated Successfully
    [Arguments]  ${measurement_id_list}  ${expect_mea_file_name_dict}   ${gnb_index}=0
    [Documentation]  Judging the new report file should be generated, the current file amount should be more than
    ...    original file amount.
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | measurement_id_list | Yes | measurements id list, like ['55300', '55302']|
    ...    | org_meas_info | Yes | the original measurements info, obtained by 'Get The Given Measurement Info' |

    ...    *RETURN VALUE*
    ...    None
    ...
    ${current_file_name_dict}=  CU CNF Get All Measurement Latest File Name  ${measurement_id_list}  ${gnb_index}
    FOR  ${m_id}  IN  @{measurement_id_list}
      run keyword and continue on failure   Should Be Equal As Strings
    ...  ${current_file_name_dict['${m_id}']}  ${expect_mea_file_name_dict['${m_id}']}
    END

CU CNF Gen All The Given Measurements File Names
    [Arguments]   ${mea_id_list}  ${org_meas_info}  ${interval}   ${gnb_index}=0
    [Documentation]  Generate all of the given measurements file names used to check whether the report files generated or not.
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | mea_id_list | Yes | measurement id list |
    ...    | org_meas_info | Yes | the original measuremts info got from start measurement. |
    ...    | interval | Yes | the measurement interval. |

    ...    *RETURN VALUE*
    ...    dict like {'55112': 'A20210407.1330+0800-20210407.1345+0800_-:2.xml.gz',
    ...               '55114': 'A20210407.1330+0800-20210407.1345+0800_-:6.xml.gz'}
    ...
    ${mea_file_name_dict}=  create dictionary
    FOR  ${mea}  IN  @{mea_id_list}
      ${report_file_suffix}=  set variable  ${org_meas_info['${mea}']['latest_file_name'].split('_')[-1]}
      ${file_name}=   CU CNF Gen Measurement Report File Name   ${interval}   ${report_file_suffix}   ${gnb_index}
      set to dictionary  ${mea_file_name_dict}  ${mea}  ${file_name}
    END
    [Return]   ${mea_file_name_dict}


CU CNF Gen Measurement Report File Name
    [Arguments]  ${interval}  ${file_suffix}  ${gnb_index}=0
    [Documentation]  Generate measurement report file name using the interval start time and stop time.
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | interval | Yes | the interval that measurements generating report file, using to calculate the file stop time.|
    ...    | file_suffix | Yes | the report file suffix, like '-:2.xml.gz' from 'A20210407.1330+0800-20210407.1345+0800_-:2.xml.gz' |

    ...    *RETURN VALUE*
    ...    the measurement file name, like A20210407.1330+0800-20210407.1345+0800_-:2.xml.gz
    ...
    ${file_start_time}=  CU CNF Generate Measurement Report Start Time    ${interval}  gnb_index=${gnb_index}
    ${file_stop_time}=   Get Measurement Report Stop Time  ${file_start_time}  ${interval}
    ${file_name}=   Measurement File Name Gen  ${file_start_time}  ${file_stop_time}  ${file_suffix}
    [Return]  ${file_name}

CU CNF Generate Measurement Report Start Time
    [Arguments]   ${mea_interval}   ${gnb_index}=0
     Log To Console     CU CNF Generate Measurement Report Start Time
    ${ns}=  Get CU Namespace From Testline  gnb_index=${gnb_index}
    ${container_full_name}   Get CU Full Container Name By Container Abbreviation   ctr_abbr=pmcore
    ${alias}=  Connect To CU K8S Master With Admin  gnb_index=${gnb_index}
    ${pod_full_name}=   Get CU Full Pod Name By Pod Abbreviation   pod_abbr=pm  alias=${alias}  gnb_index=${gnb_index}

    ${cmd_base}=  set variable    kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} --
    ${year_hour_min_cmd}=   catenate   ${cmd_base}    bash -c "date +%Y-%m-%dT%H:%M"
    ${tz_cmd}=    catenate   ${cmd_base}    bash -c "date +%:z"
    # execute the command, and get the related time factors.
    ${year_hour_min}=    issh.execute    command=${year_hour_min_cmd}   check_result=${False}  alias=${alias}
    ${tz}=   issh.execute   command=${tz_cmd}   check_result=${False}  alias=${alias}
    ${year_hour_min}=    Get Regexp Matches      ${year_hour_min}   \\d+-\\d+-\\d+T\\d+:\\d+
    @{time_splited}=  Split String   ${year_hour_min[0]}   :
    ${year_hour}=   Strip String   ${time_splited[0]}
    ${min}=   Strip String   ${time_splited[-1]}
    ${tz}=     Get Regexp Matches    ${tz}   \\+\\d+:\\d+
    ${min_num}=    convert to integer    ${min}
    ${interval}=   convert to integer   ${mea_interval}
    ${tidy_min}=   evaluate  ${min_num}-${min_num}%${interval}

    ${tidy_time}=   run keyword if  ${tidy_min}>=10    set variable     ${year_hour}:${tidy_min}:00.000${tz[0]}
    ...   ELSE   set variable     ${year_hour}:0${tidy_min}:00.000${tz[0]}
    log to console     Measurement Report Start Time: ${tidy_time}
    [Return]  ${tidy_time}
    [Teardown]  Disconnect Interactive Connection     ${alias}

CU CNF Get The Given Counters Value Under The Same MO
    [Arguments]  ${counter_id_list}   ${mea_dn}  ${gnb_index}=0
    [Documentation]  Get the given counters value under the same MO,
    ...  counter_id_list can be in different measurements or the same measurements,
    ...  like ['M55301C00000', 'M55301C00101', 'M55303C00001'], but all of the counters must be in the same MO, like NRCELL-1
    ...  for mea_dn, no need to be given the absolute dist name, just can be given like NRCELL-1
    ...
    ...    *AUTHOR* fen.huang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id_list | Yes | the counter id list, like: ['M55300C00000', 'M55300C00002'] |
    ...    | mea_dn | Yes | the dn name which the counter located in, like NRCELL-1|
    ...
    ...    *RETURN VALUE*
    ...    the counter value, like {'M55300C00000': '0', 'M55302C00000': '0'}
    ...    the measurement info, like
    ...    {'55300': {'NRCELL-1': {'M55300C00000': '0',
    ...                            'M55300C00001': '0',
    ...                            'M55300C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55300C00000': '0',
    ...                             'M55300C00001': '0',
    ...                             'M55300C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz'
    ...                },
    ...     '55302': {'NRCELL-1': {'M55302C00000': '0',
    ...                            'M55302C00001': '0',
    ...                            'M55302C00002': '0'
    ...                            },
    ...                'NRCELL-2': {'M55302C00000': '0',
    ...                             'M55302C00001': '0',
    ...                             'M55302C00002': '0'
    ...                             },
    ...                'file_amount': 72,
    ...                'latest_file_generated_time': '20210114.0315',
    ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:11.xml.gz'
    ...                }
    ...    }
    ...
    ${counter_value_dict}=   create dictionary
    ${mea_id_list}  ${counter_id_mea_id_map}  _Get Mea Id List And Counter Mea Map Dict From Counter Id List  ${counter_id_list}
    ${mea_info}=   CU CNF Get The Given Measurement Info    ${mea_id_list}   ${gnb_index}
    FOR  ${counter_id}   IN   @{counter_id_list}
      ${m_id}=  set variable  ${counter_id_mea_id_map['${counter_id}']}
      Run Keyword If  ${mea_info}  set to dictionary  ${counter_value_dict}  ${counter_id}  ${mea_info['${m_id}']['${mea_dn}']['${counter_id}']}
    ...  ELSE  set to dictionary  ${counter_value_dict}  ${counter_id}  0
    END
    [Return]  ${counter_value_dict}  ${mea_info}

CU CNF Get The Given Counters Value Under Different MO
     [Arguments]  ${counter_id_dn_map_list}  ${gnb_index}=0
     [Documentation]  Get the given counters value under the different MO.
     ...    *AUTHOR* fen.huang@nokia-sbell.com
     ...
     ...    | Input Parameters | Man. | Description |
     ...    | counter_dn_map_list | Yes | counter and its dn map list, like [{'M55301C01':'NRCELL-1'},
     ...                                                                    {'M55031C01':'NRCELL-2'},
     ...                                                                    {'M55301C02':'NRCELL-1'},
     ...                                                                    {'M55301C02':'NRCELL-2'},
     ...                                                                    {'M55555C00':'NRCELL-1'},
     ...                                                                    {'M66666C00':'NRDU-1'}] |
     ...
     ...    *RETURN VALUE*
     ...    the counter value, like {'M55300C00000_NRCELL-1': '0', 'M55300C00000_NRCELL-2': '0'}
     ...    the measurement info, like
     ...    {'55300': {'NRCELL-1': {'M55300C00000': '0',
     ...                            'M55300C00001': '0',
     ...                            'M55300C00002': '0'
     ...                            },
     ...                'NRCELL-2': {'M55300C00000': '0',
     ...                             'M55300C00001': '0',
     ...                             'M55300C00002': '0'
     ...                             },
     ...                'file_amount': 72,
     ...                'latest_file_generated_time': '20210114.0315',
     ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz'
     ...                },
     ...     '55302': {'NRCELL-1': {'M55302C00000': '0',
     ...                            'M55302C00001': '0',
     ...                            'M55302C00002': '0'
     ...                            },
     ...                'NRCELL-2': {'M55302C00000': '0',
     ...                             'M55302C00001': '0',
     ...                             'M55302C00002': '0'
     ...                             },
     ...                'file_amount': 72,
     ...                'latest_file_generated_time': '20210114.0315',
     ...                'latest_file_name': 'A20210114.0300+0000-20210114.0315+0000_-:11.xml.gz'
     ...                }
     ...    }
     ...
     ${counter_value_dict}=  create dictionary
     ${mea_id_list}=   _Get Mea Id List  ${counter_id_dn_map_list}
     ${mea_info}=   CU CNF Get The Given Measurement Info    ${mea_id_list}   ${gnb_index}
     FOR  ${item}  IN  @{counter_id_dn_map_list}
       ${counter_id}   ${dn}   get dictionary items  ${item}
       @{words}=    split string  ${counter_id}   C
       ${mea_id}=   Fetch From Right  ${words[0]}  M
       Run Keyword If  ${mea_info}  set to dictionary
     ...  ${counter_value_dict}  ${counter_id}_${dn}  ${mea_info['${mea_id}']['${dn}']['${counter_id}']}
     ...  ELSE  set to dictionary  ${counter_value_dict}  ${counter_id}_${dn}  0
     END
     [Return]  ${counter_value_dict}  ${mea_info}

############################## CU CNF PM End ##############################
====== CU CNF PM End ======
     log to console  \n*** only used for readable **
