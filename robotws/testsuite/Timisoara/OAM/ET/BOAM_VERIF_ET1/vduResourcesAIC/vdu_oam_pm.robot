*** Settings ***
Documentation
...   author: liting.cao@nokia-sbell.com
...   contact: liting.cao@nokia-sbell.com
...   vdu_oam_pm.robot



#*** Variables ***



*** Keywords ***
############################## vDU PM Start ##############################
====== vDU PM Start ======
     log to console  \n*** only used for readable ***

vDU Get PM Counter Latest Values
    [Arguments]   ${counter_id}   ${dimension_dist_name}  ${vdu_index}=0
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    firstly, using restapi to get the counter whole info, then get the latest value
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:   <27-Oct-2020>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id | Yes | PM counter ID |
    ...    | dimension_dist_name | Yes | the dimension dist name that the counter belongs to, like MRBTS-5323/NRBTS-5323/NRCELL-1 |
    ...    | vdu_index | No |  vdu index to indicate which vdu will be used, 0 in default  |
    ...
    ...    *RETURN VALUE*
    ...    Latest counter value
    vDU Rest Login    vdu_index=${vdu_index}
    ${res}=  vdu.get_counter_values    ${counter_id}   ${dimension_dist_name}
    ${latest_counter}=  set variable    ${res[-1]['value']}
    [return]    ${latest_counter}
    [Teardown]   vDU Rest Logout   vdu_index=${vdu_index}


VDU Sync To PM Timer Clock
    [Arguments]   ${PM_collecting_interval}=5   ${estimated_traffic_generating_duration}=4
    [Teardown]  Run Keyword And Ignore Error   disconnect interactive connection  alias=${alias}
    [Documentation]  VDU Sync To PM Timer Clock
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | estimated_traffic_generating_duration | No | estimated_traffic_generating_duration, unit is minute, default value is 7 |
    ...    | PM_collecting_interval                | No  | PM_collecting_interval, unit is minute, default value is 15 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | VDU Sync To PM Timer Clock | PM_collecting_interval=5  | estimated_traffic_generating_duration=2 |
    ...    | # generate traffic to triggle counter increasement |
    ...
    Log To Console  Begin: VDU Sync To PM Timer Clock
    ${alias}    Get Unique ID
    #Connect To vDU Node Interactively   pod_abbr=oamcp   alias=${alias}
    Connect To vDU Node Interactively   pod_abbr=oam   alias=${alias}

    #wait clock to the moment which is 15*n minutes(n=0,1,2,3)
#    ${ret}     Kubectl Exec Interactively    pod_abbr=oam    container=oam   command=date +"%Y-%m-%d %H:%M:%S"   alias=${alias}
    ${ret}     Kubectl Exec Interactively    container=oamagent   command=date +"%Y-%m-%d %H:%M:%S"   alias=${alias}

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

    #${ret}     Kubectl Exec Interactively    pod_abbr=oam    container=oam   command=date +"%Y-%m-%d %H:%M:%S"   alias=${alias}
    ${ret}     Kubectl Exec Interactively     container=oamagent   command=date +"%Y-%m-%d %H:%M:%S"   alias=${alias}

    ${vm_time}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}
    Log To Console   Current OAM system time:${vm_time[0]}
    Log To Console  End: VDU Sync To PM Timer Clock


_Wait Some Time For Next Round PM Collecting
    [Arguments]   ${collecting_interval}  ${estimated_traffic_generating_duration}   ${vm_minutes}
    Should Be True  ${estimated_traffic_generating_duration}<=${collecting_interval}

    ${vm_minutes_mod}    Evaluate    int(math.fmod(${vm_minutes},int(${collecting_interval})))    modules=math

    Log To Console  vm_minutes_mod result:${vm_minutes_mod}
    Run Keyword If   ${vm_minutes_mod}==0  Log To Console   it's the time of N*${collecting_interval} minutes, so need not wait
    Return From Keyword If  ${vm_minutes_mod}==0

    ${wait_time}    Evaluate    int(${collecting_interval})-${vm_minutes_mod}

    ${msg}   Run Keyword If  ${wait_time}>${estimated_traffic_generating_duration}   Set Variable
    ...    There is no next collecting point during estimated_traffic_generating_duration
    ${msg}   Run Keyword If  ${wait_time}>${estimated_traffic_generating_duration}   Set Variable
    ...    ${msg}(${estimated_traffic_generating_duration} minutes), so need not wait to synced to next round collecting point.

    Run Keyword If   ${wait_time}>${estimated_traffic_generating_duration}
    ...  Log To Console   ${msg}
    Return From Keyword If   ${wait_time}>${estimated_traffic_generating_duration}

    ${msg}  Set Variable   There is next collecting point during estimated_traffic_generating_duration
    ${msg}  Set Variable  ${msg}(${estimated_traffic_generating_duration} minutes), so need wait to sync to next round collecting point.
    Log To Console  ${msg}

    ${wait_time_sec}   Evaluate   ${wait_time}*60+31
    Log To Console   wait time: ${wait_time} minutes
    Sleep   ${wait_time_sec}

Get PM Related Files From pmcore Container To Local TestPC For NCIR Or NCS
    [Arguments]  ${file_absolute_path}  ${vdu_index}=0  #${gnb_index}=0
    [Documentation]  get file from pmcore container to local UTE. The file will be stored under UTE
    ...  ${OUTPUT_DIR}/${TEST_NAME}/${START_TIME}/pm_related directory.
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | file_absolute_path | Yes | the file path in pmcore container,
    ...                                 like /var/opt/nokia/performancemanagement/storage/results/resultMapping.json |

    ...    *RETURN VALUE*
    ...    the file path under UTE,
    ...    like /home/ute/robotws5g/testsuite/AIC/TESTCASE__Test_PM/2021_01_14_04_17_04/pm_related/resultMapping.json
    ...
    ${alias}   Get Unique Id
    Connect To VDU Node Interactively   pod_abbr=pm  vdu_index=${vdu_index}  alias=${alias}
    ${ns}   Get VDU Namespace From TestLine
    ${container_id}   Get Container ID From Docker Ps Command By POD Abbreviation Interactively  ns=${ns}  pod_abbr=pm  container=pmcore
    ...    alias=${alias}
    ${path}   ${file_name}  OperatingSystem.Split Path   ${file_absolute_path}
    ${out}   issh.Execute   command=docker cp ${container_id}:${file_absolute_path} ./${file_name}    alias=${alias}
    ${local_file}   Get A File    pm_related   ${file_name}
    issh.Download File   remote_path=./${file_name}   local_path=${local_file}   alias=${alias}
    issh.Execute  rm -rf ./${file_name}  alias=${alias}
    [Return]  ${local_file}
    [Teardown]  Run Keywords  issh.Execute  rm -rf ./${file_name}  alias=${alias}  AND
    ...  Disconnect Interactive Connection  alias=${alias}

Get PM Related Files From pmcore Container To Local TestPC For OCP
    [Arguments]  ${file_absolute_path}    ${ctr_abbr}=pmcore  ${pod_abbr}=pm
    ...          ${folder_name}=pm_related    ${vdu_index}=0  ${gnb_index}=0
    [Documentation]  get file from pmcore container to local UTE for OCP. The file will be stored under UTE
    ...  ${OUTPUT_DIR}/${TEST_NAME}/${START_TIME}/pm_related directory.
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | file_absolute_path | Yes | the file path in pmcore container,
    ...    like /var/opt/nokia/performancemanagement/storage/results/resultMapping.json |

    ...    *RETURN VALUE*
    ...    the file path under UTE,
    ...    like /home/ute/robotws5g/testsuite/AIC/TESTCASE__Test_PM/2021_01_14_04_17_04/pm_related/resultMapping.json
    ...
    ${local_file}    Download File From VDU To Local TestPC    file_absolute_path=${file_absolute_path}
    ...                                       ctr_abbr=${ctr_abbr}
    ...                                       pod_abbr=${pod_abbr}
    ...                                       folder_name=${folder_name}
    ...                                       vdu_index=${vdu_index}
    ...                                       gnb_index=${gnb_index}
    [Return]  ${local_file}

Download File From VDU To Local TestPC
    [Arguments]  ${file_absolute_path}    ${ctr_abbr}=pmcore  ${pod_abbr}=pm
    ...          ${folder_name}=pm_related    ${vdu_index}=0  ${gnb_index}=0
    [Documentation]  get file from pmcore container to local UTE for OCP. The file will be stored under UTE
    ...  ${OUTPUT_DIR}/${TEST_NAME}/${START_TIME}/pm_related directory.
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | file_absolute_path | Yes | the file path in pmcore container,
    ...    like /var/opt/nokia/performancemanagement/storage/results/resultMapping.json |

    ...    *RETURN VALUE*
    ...    the file path under UTE,
    ...    like /home/ute/robotws5g/testsuite/AIC/TESTCASE__Test_PM/2021_01_14_04_17_04/pm_related/resultMapping.json
    ...
    ${alias}   Get Unique Id
    Connect To VDU Node Interactively   pod_abbr=pm  vdu_index=${vdu_index}  alias=${alias}
    ${ns}   Get VDU Namespace From TestLine
    ${container_name}   get full container name by container abbreviation   ctr_abbr=${ctr_abbr}
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively    pod_abbr=${pod_abbr}   alias=${alias}
    ...  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${path}   ${file_name}  OperatingSystem.Split Path   ${file_absolute_path}
    ${cmd}    Catenate    kubectl exec ${full_pod_name} -c ${container_name} -n ${ns} -- /bin/gzip -c ${file_absolute_path}
    ...                   |gunzip > ./${file_name}
    ${out}   issh.Execute   command=${cmd}
    ...                     alias=${alias}
    ${local_file}   Get A File    ${folder_name}   ${file_name}
    issh.Download File   remote_path=./${file_name}   local_path=${local_file}   alias=${alias}
    issh.Execute  rm -rf ./${file_name}  alias=${alias}
    [Return]  ${local_file}
    [Teardown]  Run Keywords  issh.Execute  rm -rf ./${file_name}  alias=${alias}  AND
    ...  Disconnect Interactive Connection  alias=${alias}

Get PM Related Files From pmcore Container To Local TestPC
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Arguments]  ${file_absolute_path}  ${vdu_index}=0  ${gnb_index}=0
    [Documentation]  get file from pmcore container to local UTE. The file will be stored under UTE
    ...  ${OUTPUT_DIR}/${TEST_NAME}/${START_TIME}/pm_related directory.
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | file_absolute_path | Yes | the file path in pmcore container,
    ...                                 like /var/opt/nokia/performancemanagement/storage/results/resultMapping.json |

    ...    *RETURN VALUE*
    ...    the file path under UTE,
    ...    like /home/ute/robotws5g/testsuite/AIC/TESTCASE__Test_PM/2021_01_14_04_17_04/pm_related/resultMapping.json
    ${platform}   Get Platform Name
    ${local_file}   runkeyword if   "${platform}"=="NCIR" or "${platform}"=="NCS"
    ...   Get PM Related Files From pmcore Container To Local TestPC For NCIR Or NCS    file_absolute_path=${file_absolute_path}
    ...                                                                                 vdu_index=${vdu_index}
    ...                                                                                 gnb_index=${gnb_index}
    ...   ELSE    Get PM Related Files From pmcore Container To Local TestPC For OCP    file_absolute_path=${file_absolute_path}
    ...                                                                                 vdu_index=${vdu_index}
    ...                                                                                 gnb_index=${gnb_index}
    [Return]    ${local_file}

Get PM Result Mapping File Content
    [Arguments]  ${file_absolute_path}  ${vdu_index}=0  ${gnb_index}=0
    [Documentation]  get the file resultMapping.json content
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | file_absolute_path | Yes | the resultMapping.json file path in pmcore container,
    ...                                 like /var/opt/nokia/performancemanagement/storage/results/resultMapping.json |

    ...    *RETURN VALUE*
    ...    the json file dictionary
    ...
    ${local_file}=  Get PM Related Files From pmcore Container To Local TestPC  ${file_absolute_path}  ${vdu_index}  ${gnb_index}
    ${content}    get file    ${local_file}
    ${pm_result_mapping_dict}  Json.Loads     ${content}
    [Return]  ${pm_result_mapping_dict}

Get Latest PM File Generated Time
    [Arguments]  ${pm_file}   ${vdu_index}=0  #${gnb_index}=0
    [Documentation]  get the generated time of latest pm report file
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pm_file | Yes | the report file name, like A20210114.0300+0000-20210114.0315+0000_-:9.xml.gz|

    ...    *RETURN VALUE*
    ...    the linux time stamp of the report file generated, like 20210114.0315
    ...
    ${alias}  get unique id
    connect to k8s master with tenant interactively   vdu_index=${vdu_index}  alias=${alias}
    ${cmd}=  set variable  ls -l ${PM_RESULT_DIR_IN_PMCORE} --time-style="+%Y%m%d.%H%M"|grep ${pm_file}
    ${out}   Kubectl Exec Interactively  pod_abbr=pm  container=pmcore  command=${cmd}  alias=${alias}  vdu_index=${vdu_index}
    [Return]    ${out.split()[-2]}
    [Teardown]   Disconnect Interactive Connection    alias=${alias}

Get All Latest Counter Values Of One Measurement
    [Arguments]  ${pm_file_name}   ${vdu_index}=0  ${gnb_index}=0
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
    ${local_gz_pm_file}=  Get PM Related Files From pmcore Container To Local TestPC  ${PM_RESULT_DIR_IN_PMCORE}/${pm_file_name}
    ...  ${vdu_index}  ${gnb_index}
    OperatingSystem.Run  gunzip ${local_gz_pm_file}
    ${pm_xml_report_file}  ${ext}  split extension   ${local_gz_pm_file}
    ${counter_values_of_one_mea}=  parse_pm_result_xml_file  ${pm_xml_report_file}
    [Return]  ${counter_values_of_one_mea}

Get The Given Measurement Info
    [Arguments]  ${measurement_id_list}  ${vdu_index}=0
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
    ...    *Example*
    ...    | ${mea_id_list}= | create list | 55300 | 55302 | 55303 |
    ...    | ${mea_info}= | Get The Given Measurement Info | ${mea_id_list} |
    ...    **OR**
    ...    | ${counter_id_list}= | create list | M55300C00000 | M55300C00002 | M55302C00000 |
    ...    | ${mea_id_list} | ${counter_id_mea_id_map} | _Get Mea Id List And Counter Mea Map Dict From Counter Id List | ${counter_id_list}
    ...    | ${mea_info}= | Get The Given Measurement Info | ${mea_id_list} |
    ...
    ${reslut_mapping_content}=  Get PM Result Mapping File Content  ${PM_RESULT_DIR_IN_PMCORE}/resultMapping.json  ${vdu_index}
    ${all_measurements_info}=  create dictionary
    return from keyword if  "${reslut_mapping_content}"=="{}"  ${all_measurements_info}
    FOR  ${m_id}  IN  @{measurement_id_list}
      ${file_list}=  set variable  ${reslut_mapping_content['${m_id}']['filenames']}
      ${file_amount}=  get length  ${file_list}
      ${latest_file_name}=  set variable  ${file_list[0]}
      ${latest_file_generated_time}   Get Latest PM File Generated Time   ${latest_file_name}  ${vdu_index}
      ${counters_value}=  Get All Latest Counter Values Of One Measurement   ${latest_file_name}  ${vdu_index}
      &{one_measurement_info}=   create dictionary  file_amount=${file_amount}  latest_file_name=${latest_file_name}
    ...  latest_file_generated_time=${latest_file_generated_time}  &{counters_value}
      set to dictionary   ${all_measurements_info}   ${m_id}  ${one_measurement_info}
    END
    log dictionary  ${all_measurements_info}
    [Return]  ${all_measurements_info}


Get All Measurement Latest File Name
    [Arguments]  ${measurement_id_list}  ${vdu_index}=0
    [Documentation]  get the given measurents report file amount
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | measurement_id_list | Yes | measurements id list, like ['55300', '55302']|

    ...    *RETURN VALUE*
    ...    measurements file admount dict, like {'55300':30, '55303':32}
    ...
    ${measurement_file_name_dict}=   create dictionary
    ${reslut_mapping_content}=  Get PM Result Mapping File Content  ${PM_RESULT_DIR_IN_PMCORE}/resultMapping.json  ${vdu_index}
    FOR  ${m_id}  IN  @{measurement_id_list}
      ${file_list}=  set variable  ${reslut_mapping_content['${m_id}']['filenames']}
      set to dictionary  ${measurement_file_name_dict}  ${m_id}  ${file_list[0]}
    END
    [Return]  ${measurement_file_name_dict}


Measurement Report File Should Be Generated Successfully
    [Arguments]  ${measurement_id_list}  ${expect_mea_file_name_dict}   ${vdu_index}=0
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
    ${current_file_name_dict}=  Get All Measurement Latest File Name  ${measurement_id_list}  ${vdu_index}
    FOR  ${m_id}  IN  @{measurement_id_list}
      run keyword and continue on failure   Should Be Equal As Strings
    ...  ${current_file_name_dict['${m_id}']}  ${expect_mea_file_name_dict['${m_id}']}
    END

Wait For New Measurements Reports Generated
    [Arguments]  ${measurement_id_list}  ${expect_mea_file_name_dict}  ${interval}   ${vdu_index}=0
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
    wait until keyword succeeds   ${wait_time}min   30sec  Measurement Report File Should Be Generated Successfully  ${measurement_id_list}
    ...  ${expect_mea_file_name_dict}   ${vdu_index}

Start Measurement Different Mo
    [Arguments]  ${counter_dn_map_list}  ${interval}  ${estimated_excution_time}  #${vdu_index}=0
    [Documentation]  start measurements which are in different MOs.
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
    VDU Sync To PM Timer Clock  PM_collecting_interval=${interval}  estimated_traffic_generating_duration=${estimated_excution_time}
    ${counter_value}  ${mea_info}   Get The Given Counters Value Under Different MO  ${counter_dn_map_list}
    [Return]  ${counter_value}  ${mea_info}

Stop Measurement Different Mo
    [Arguments]  ${counter_dn_map_list}  ${org_meas_info}   ${interval}  ${vdu_index}=0
    [Documentation]  stop measurements which are in different MOs and get the current counters value
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
	${expect_mea_file_name_dict}=  Gen All The Given vDU Measurements File Names  ${mea_id_list}  ${org_meas_info}  ${interval}  ${vdu_index}
    Wait For New Measurements Reports Generated  ${mea_id_list}  ${expect_mea_file_name_dict}   ${interval}   ${vdu_index}
#    Wait For New Measurements Reports Generated  ${mea_id_list}  ${org_meas_info}   ${interval}   ${vdu_index}
    ${counter_value}   ${mea_info}   Get The Given Counters Value Under Different MO  ${counter_dn_map_list}
    [Return]  ${counter_value}   ${mea_info}

Start Measurement Same Mo
    [Arguments]  ${counter_id_list}  ${dn}  ${interval}  ${estimated_excution_time}  #${vdu_index}=0
    [Documentation]  start measurements which are in the same MOs.
    ...    the robot log is put in \\verification\Public_Shared\PCI\Logs\log_start_stop_same_mo.html
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
    ...    *Example*
    ...    | ${counter_id_list}= |  create list | M55300C00000 | M55300C00002 | M55302C00000 |
    ...    | ${dn}= |  set variable  | NRCELL-1 |
    ...    | ${started_counter_value} | ${started_mea_info} | Start Measurement Same Mo | ${counter_id_list} | ${dn} |
    ...    ...                                                                            interval=${15} | estimated_excution_time=${2} |
    ...    | Log Dictionary |  ${started_counter_value} |
    ...    | Log Dictionary | ${started_mea_info} |
    ...
    VDU Sync To PM Timer Clock  PM_collecting_interval=${interval}  estimated_traffic_generating_duration=${estimated_excution_time}
    ${counters_value}  ${mea_info}   Get The Given Counters Value Under The Same MO  ${counter_id_list}  ${dn}
    [Return]  ${counters_value}  ${mea_info}

Stop Measurement Same Mo
    [Arguments]  ${counter_id_list}   ${dn}  ${org_meas_info}   ${interval}  ${vdu_index}=0
    [Documentation]  stop measurements which are in the same MOs, waiting for the new report generated
    ...    the robot log is put in \\verification\Public_Shared\PCI\Logs\log_start_stop_same_mo.html
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
    ${expect_mea_file_name_dict}=  Gen All The Given vDU Measurements File Names  ${mea_id_list}  ${org_meas_info}  ${interval}  ${vdu_index}
    Wait For New Measurements Reports Generated  ${mea_id_list}  ${expect_mea_file_name_dict}   ${interval}   ${vdu_index}
    ${counter_value}   ${mea_info}   Get The Given Counters Value Under The Same MO  ${counter_id_list}  ${dn}
    [Return]  ${counter_value}   ${mea_info}

Stop Measurement Same Mo at the specified time
    [Arguments]  ${counter_id_list}   ${dn}  ${org_meas_info}   ${interval}   ${file_start_time}   ${vdu_index}=0
    [Documentation]  stop measurements which are in the same MOs, waiting for the new report generated
    ...    the robot log is put in \\verification\Public_Shared\PCI\Logs\log_start_stop_same_mo.html
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
    ${expect_mea_file_name_dict}=  Gen All The Given vDU Measurements File Names at the specified time  ${mea_id_list}
    ...  ${org_meas_info}   ${interval}  ${file_start_time}   ${vdu_index}
    Wait For New Measurements Reports Generated  ${mea_id_list}  ${expect_mea_file_name_dict}   ${interval}   ${vdu_index}
    ${counter_value}   ${mea_info}   Get The Given Counters Value Under The Same MO  ${counter_id_list}  ${dn}
    [Return]  ${counter_value}   ${mea_info}

Gen All The Given vDU Measurements File Names
    [Arguments]   ${mea_id_list}  ${org_meas_info}  ${interval}   ${vdu_index}=0   #${file_start_time}
    [Documentation]  Generate all of the given vdu measurements file names used to check whether the report files generated or not.
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
      ${file_name}=   Gen vDU Measurement Report File Name   ${interval}   ${report_file_suffix}   ${vdu_index}
      set to dictionary  ${mea_file_name_dict}  ${mea}  ${file_name}
    END
    [Return]   ${mea_file_name_dict}

Gen All The Given vDU Measurements File Names at the specified time
    [Arguments]   ${mea_id_list}  ${org_meas_info}  ${interval}   ${file_start_time}   ${vdu_index}=0
    [Documentation]  Generate all of the given vdu measurements file names used to check whether the report files generated or not.
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
      ${file_name}=   Gen vDU Measurement Report File Name at the specified time   ${interval}   ${report_file_suffix}
    ...    ${file_start_time}   ${vdu_index}
      set to dictionary  ${mea_file_name_dict}  ${mea}  ${file_name}
    END
    [Return]   ${mea_file_name_dict}


Gen vDU Measurement Report File Name
    [Arguments]  ${interval}  ${file_suffix}  ${vdu_index}=0
    [Documentation]  Generate vDU measurement report file name using the interval start time and stop time.
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | interval | Yes | the interval that measurements generating report file, using to calculate the file stop time.|
    ...    | file_suffix | Yes | the report file suffix, like '-:2.xml.gz' from 'A20210407.1330+0800-20210407.1345+0800_-:2.xml.gz' |

    ...    *RETURN VALUE*
    ...    the measurement file name, like A20210407.1330+0800-20210407.1345+0800_-:2.xml.gz
    ...
    ${file_start_time}=  Get vDU Measurement Start Time  ${interval}  vdu_index=${vdu_index}
    ${file_stop_time}=   Get Measurement Report Stop Time  ${file_start_time}  ${interval}
    ${file_name}=   Measurement File Name Gen  ${file_start_time}  ${file_stop_time}  ${file_suffix}
    [Return]  ${file_name}

Gen vDU Measurement Report File Name at the specified time
    [Arguments]  ${interval}  ${file_suffix}  ${file_start_time}   #${vdu_index}=0
    [Documentation]  Generate vDU measurement report file name using the interval start time and stop time.
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | interval | Yes | the interval that measurements generating report file, using to calculate the file stop time.|
    ...    | file_suffix | Yes | the report file suffix, like '-:2.xml.gz' from 'A20210407.1330+0800-20210407.1345+0800_-:2.xml.gz' |

    ...    *RETURN VALUE*
    ...    the measurement file name, like A20210407.1330+0800-20210407.1345+0800_-:2.xml.gz
    ...
#    ${file_start_time}=  Get vDU Measurement Start Time  ${interval}  vdu_index=${vdu_index}
    ${file_stop_time}=   Get Measurement Report Stop Time  ${file_start_time}  ${interval}
    ${file_name}=   Measurement File Name Gen  ${file_start_time}  ${file_stop_time}  ${file_suffix}
    [Return]  ${file_name}

Get vDU Measurement Start Time
    [Arguments]  ${mea_interval}  ${pod_abbr}=pm  ${container}=pmcore   ${vdu_index}=0
    [Documentation]  Get the vdu measurement interval start time.
    ...    For example: if the current time is 2021-04-07 13:33:45 and the interval is 15min, the interval start time
    ...    will be 2021-04-07T13:30:00.000+08:00
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | interval | Yes | the measurement interval. |
    ...    | pod_abbr | No. | default is pm pod. |
    ...    | container | No. | default is pmcore. |

    ...    *RETURN VALUE*
    ...    the tidied time based on the current time, like 2021-04-07T13:30:00.000+08:00
    ...
    ${alias}    Get Unique ID
    Connect To K8s Master With Tenant  vdu_index=${vdu_index}  alias=${alias}
    ${container}     Get Full Container Name By Container Abbreviation  ctr_abbr=${container}   vdu_index=${vdu_index}
    ${ns}  Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    ${pod_full_name}  Get Full Pod Name By Pod Abbreviation   pod_abbr=${pod_abbr}   connection=${alias}  vdu_index=${vdu_index}
    ${start_time}=  generate_vdu_measurement_report_start_time  ${pod_full_name}  ${container}  ${ns}  ${alias}  ${mea_interval}
    [Teardown]  Disconnect From K8s Master  connection=${alias}
    [Return]  ${start_time}


_Get Mea Id List And Counter Mea Map Dict From Counter Id List
    [Arguments]  ${counter_id_list}
    ${mea_id_list}=  create list
    ${counter_id_mea_id_map}=  create dictionary
    FOR  ${counter_id}   IN   @{counter_id_list}
      @{words}=    split string  ${counter_id}   C
      ${mea_id}=   Fetch From Right  ${words[0]}  M
      append to list  ${mea_id_list}  ${mea_id}
      set to dictionary  ${counter_id_mea_id_map}  ${counter_id}  ${mea_id}
    END
    ${mea_id_list}  evaluate  sorted(set(${mea_id_list}))
    [Return]  ${mea_id_list}   ${counter_id_mea_id_map}

Get The Given Counters Value Under The Same MO
    [Arguments]  ${counter_id_list}   ${mea_dn}  ${vdu_index}=0
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
    ${mea_info}=   Get The Given Measurement Info    ${mea_id_list}   ${vdu_index}
    FOR  ${counter_id}   IN   @{counter_id_list}
      ${m_id}=  set variable  ${counter_id_mea_id_map['${counter_id}']}
      Run Keyword If  ${mea_info}  set to dictionary  ${counter_value_dict}  ${counter_id}  ${mea_info['${m_id}']['${mea_dn}']['${counter_id}']}
    ...  ELSE  set to dictionary  ${counter_value_dict}  ${counter_id}  0
    END
    [Return]  ${counter_value_dict}  ${mea_info}

_Get Mea Id List
    [Arguments]  ${counter_id_dn_map_list}
    ${mea_id_list}=  create list
    FOR  ${item}  IN  @{counter_id_dn_map_list}
      ${counter_id}   ${dn}   get dictionary items  ${item}
      @{words}=    split string  ${counter_id}   C
      ${mea_id}=   Fetch From Right  ${words[0]}  M
      append to list  ${mea_id_list}  ${mea_id}
    END
    ${mea_id_list}  evaluate  sorted(set(${mea_id_list}))
    [Return]  ${mea_id_list}

Get The Given Counters Value Under Different MO
     [Arguments]  ${counter_id_dn_map_list}  ${vdu_index}=0
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
     ${mea_info}=   Get The Given Measurement Info    ${mea_id_list}   ${vdu_index}
     FOR  ${item}  IN  @{counter_id_dn_map_list}
       ${counter_id}   ${dn}   get dictionary items  ${item}
       @{words}=    split string  ${counter_id}   C
       ${mea_id}=   Fetch From Right  ${words[0]}  M
       Run Keyword If  ${mea_info}  set to dictionary
     ...  ${counter_value_dict}  ${counter_id}_${dn}  ${mea_info['${mea_id}']['${dn}']['${counter_id}']}
     ...  ELSE  set to dictionary  ${counter_value_dict}  ${counter_id}_${dn}  0
     END
     [Return]  ${counter_value_dict}  ${mea_info}


Check counter value bigger than 0
    [Arguments]    ${counter_id}    ${cur_counter_value}
    [Documentation]    Get latest PM counter value is bigger than 0
    ...    author: liting.cao@nokia-sbell.com
    ...    modified by:   <13-Mar-2021>, <litcao>, <Initial creation>
    ...    | counter_id | Yes | PM counter ID |
    ...    | cur_counter_value | Yes | origin counter value dic |
    Log To Console     check    ${counter_id}    update
    ${result} =   set variable   False
    ${result} =  set variable if
    ...    ${cur_counter_value['${counter_id}']}>0    True
    should be equal    ${result}  True   Check counter value failed!


############################## vDU PM End ##############################
====== vDU PM End ======
     log to console  \n*** only used for readable **
