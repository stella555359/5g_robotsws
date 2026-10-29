*** Settings ***
Documentation    CUS keyword
Library    String
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    Process
Library    ../python/tak_iphy/
Library    ../python/tak_bts/
Library    ../python/ta_kiss_qualcomm/
Library    ../python/tak_common/
Library    ../python/tak_files/
Library    taf.ul.ue.sim.env_setup
Library    taf.transport.ssh    WITH NAME    SSH
Library    taf.sbts.oam.coam.admin
Library    ute_syslog
Library    ute_fsmaccess
Library    ta_uexgate
Library    ta_messaging
Library    ../python/tak_xml/
Library    ta_kiss_enb_ttitrace
Library    ta_a2a
Library    ../python/tak_cus/
Library    ../python/check_btslog.py
Library    ../python/set_qc_id.py
Library    ../python/handle_vendor.py
Library    ../python/get_qualcomm_tput_bler.py
Library    taf.sw.scout    WITH NAME    scout
Variables    ../python/tak_config/

*** Keywords ***
Common Suite Setup
    [Documentation]    This keyword is common suite setup, including: get testline info, get enb info and prepare tools.
    ...    Examples:
    ...    | Common Suite Setup |
    Set Tags     QCP_RAN_VRF
    Set Tags     QCD_MN_RAN
    Get Testline Info
    Get ENB Info
    Prepare Tools

Common Suite Teardown
    [Documentation]    This keyword is common suite teardown.
    ...    Examples:
    ...    | Common Suite Teardown |

    Log    suite teardown

Common Test Setup
    [Documentation]    This keyword is common test setup, including: clean up env, set case qc id and iphy setup.
    ...    Examples:
    ...    | Common Test Setup |

    Clean Up Env
    Run Keyword And Continue On Failure    Set Case Qc Id    ${TEST_NAME}    ${ENB_SW_VERSION}
    Iphy Setup
    #Iphy Set Rrc Log

Common Test Teardown
    [Documentation]    This keyword is common test teardown, including: collect snapshot, egate console log, syslog, enb and iphy parameter file.
    ...    Examples:
    ...    | Common Test Teardown |
    [Arguments]    ${fail_msg}=ERR/TDDPS
    Setup Admin
    Collect Snapshot    target_file_name={TEST LOG DIRECTORY()}/snapshot.zip timeout=1000
    Teardown Admin
    #Iphy Get Egate Console Log    log_save_path=${TEST LOG DIRECTORY()}
    Run Keyword And Ignore Error     ute_syslog.Collect Syslog Results    alias=enb    unzip=${False}
    ...                                                        destination=${TEST_LOG_DIRECTORY()}${/}syslog${/}enb_syslog.tar.gz
    Collect Enb And Iphy Parameter File
    Cus Dump Cells Log     ${TEST LOG DIRECTORY()}
    run keyword and ignore error    Ask scout to analyze scf
    Iphy Teardown
    _syslog_should not contain    ${fail_msg}

Ask scout to analyze scf
    # ask scout to analyze scf
    ${hostname}=    Run    cat /etc/hostname | sed 's/-/_/g'
    ${host_name}    Evaluate    re.sub("_1$", "", re.sub("_2$", "", "${host_name}"))    re
    scout.setup_scout    scout_testline_name=${hostname}
    scout.request_scf

_syslog_should not contain
    [Arguments]    ${msg}=ERR/TDDPS
    ${files}     List Files In Directory      ${TEST_LOG_DIRECTORY()}${/}syslog${/}        enb_syslog*
    FOR    ${file}      IN     @{files}
        file should not contain     ${TEST_LOG_DIRECTORY()}${/}syslog${/}${file}   ${msg}
    END

Start ENB And Check Onair And Collect Log
    [Documentation]    This keyword is to start enb, check onair and start syslog.
    ...    | Input Parameters | Man. | Description |
    ...    | ${scfc_path} | Yes | scfc file full path |
    ...    | ${yaml_config} | Yes | yaml config file full path |
    ...    | ${vendor} | No | vendor parameter either by list or comma separated, not file path |
    ...    | ${enb_swconfig} | No | R&D parameters provided either by list or comma separated or full path to the file
    ...                            which will be uploaded without any changes |
    ...    | ${cus_swconfig} | No | not support now |
    ...    Examples:
    ...    | Start ENB And Check Onair And Collect Log | /tmp/scfc.xml | /tmp/cus_1.yaml | LNBTS.anrUtraTRSC=5000ms | /tmp/swconfig_eNB.txt |

    [Arguments]    ${scfc_path}    ${yaml_config}    ${vendor}=${None}    ${enb_swconfig}=${None}    ${cus_swconfig}=${None}
    ute_syslog.Start Syslog    log_dir=${TEST_LOG_DIRECTORY()}/syslog    log_name=enb_syslog    ip=192.168.255.126    file_limit=200000000
    Load CUS config Files And Wait BTS Onair    ${scfc_path}    ${yaml_config}    ${vendor}    ${enb_swconfig}    ${cus_swconfig}

Get Testline Info
    [Documentation]    This keyword is to get testline info.
    ...    Examples:
    ...    | Get Testline Info |

    ${rc}    ${testline_ip}=    OperatingSystem.Run and Return RC and Output    sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
    Set Suite Variable    ${testline_ip}
    ${rc}    ${testline_hostname}=    OperatingSystem.Run and Return RC and Output    hostname
    Set Suite Variable    ${testline_hostname}

Get ENB Info
    [Documentation]    This keyword is to get enb info.
    ...    Examples:
    ...    | Get ENB Info |

    ute_fsmaccess.Setup Enb Fsm Access
    ${ENB_SW_VERSION}=    ute_fsmaccess.Get Enb SW Version
    Set Suite Variable    ${ENB_SW_VERSION}
    ${ENB_HW_VERSION}=    ute_fsmaccess.Get Enb HW Version
    Set Suite Variable    ${ENB_HW_VERSION}
    ute_fsmaccess.Teardown Enb Fsm Access

Load CUS Config Files And Wait BTS Onair
    [Documentation]    This keyword is to load cus config file, add enb configuration (including: swconfig and vendor) and wait bts onair.
    ...    | Input Parameters | Man. | Description |
    ...    | ${scfc_path} | Yes | scfc file full path |
    ...    | ${yaml_config} | Yes | yaml config file full path |
    ...    | ${vendor} | No | vendor parameter either by list or comma separated, not file path |
    ...    | ${enb_swconfig} | No | R&D parameters provided either by list or comma separated or full path to the file
    ...                            which will be uploaded without any changes |
    ...    | ${cus_swconfig} | No | not support now |
    ...    Examples:
    ...    | Load CUS Config Files And Wait BTS Onair | /tmp/scfc.xml | /tmp/cus_1.yaml | LNBTS.anrUtraTRSC=5000ms | /tmp/swconfig_eNB.txt |

    [Arguments]    ${scfc_path}    ${yaml_config}    ${vendor}=${None}    ${enb_swconfig}=${None}    ${cus_swconfig}=${None}
    Add simulator    sim_type=cus    config=${yaml_config}    warning_lookup=True
    Add eNB configuration     scfc=${scfc_path}    rad_params=${enb_swconfig}    vendor_params=${vendor}
    Configure environment
    Log To Console    Bts is onair.

Collect Enb And Iphy Parameter File
    [Documentation]    This keyword is to collect enb and iphy parameter file.
    ...    Examples:
    ...    | Collect Enb And Iphy Parameter File |

    Setup Admin     bts_host=192.168.255.129      bts_port=443      use_ssl=True      timeout=60      alias=collect
    Collect Scf      target_file_name=${TEST LOG DIRECTORY()}${/}configuration${/}scfc.xml     alias=collect
    Teardown Admin       alias=collect
    Setup Enb Fsm Access        timeout=300        alias=enb1
    Get Enb Swconfig File    	 destination=${TEST LOG DIRECTORY()}${/}configuration${/}    alias=enb1
    Get Enb Targetbd File       destination=${TEST LOG DIRECTORY()}${/}configuration${/}    alias=enb1
    ${VENDOR_path}        Get Vendorfile Absolute Path
    Get Enb File     source=${VENDOR_path}     destination=${TEST LOG DIRECTORY()}${/}configuration${/}     alias=enb1
    Teardown Enb Fsm Access  alias=enb1
    Setup Wts Fsm Access        alias=iphy1
    Get Wts Config File    destination=${TEST LOG DIRECTORY()}${/}configuration${/}    alias=iphy1
    Get Wts File    source=/ffs/run/TargetBD*.xml    destination=${TEST LOG DIRECTORY()}${/}configuration${/}    alias=iphy1
    Teardown Wts Fsm Access       alias=iphy1

Prepare Enb Onair
    [Documentation]    This keyword is to prepare enb onair, including: check gps status, start enb, check onair and collect syslog.
    ...    | Input Parameters | Man. | Description |
    ...    | ${scfc_path} | Yes | scfc file full path |
    ...    | ${yaml_config} | Yes | yaml config file full path |
    ...    | ${vendor} | No | vendor parameter either by list or comma separated, not file path |
    ...    | ${enb_swconfig} | No | R&D parameters provided either by list or comma separated or full path to the file
    ...                            which will be uploaded without any changes |
    ...    | ${cus_swconfig} | No | not support now |
    ...    Examples:
    ...    | Prepare Enb Onair | /tmp/scfc.xml | /tmp/cus_1.yaml | LNBTS.anrUtraTRSC=5000ms | /tmp/swconfig_eNB.txt |

    [Arguments]    ${scfc_path}    ${yaml_config}    ${vendor}=${None}    ${enb_swconfig}=${None}    ${cus_swconfig}=${None}
    Check GPS Status Enable
    Start ENB And Check Onair And Collect Log    ${scfc_path}    ${yaml_config}    ${vendor}    ${enb_swconfig}    ${cus_swconfig}
    Run Keyword And Continue On Failure    check_err_wrn_in_btslog    ${TEST_LOG_DIRECTORY()}${/}syslog${/}    enb_syslog
    ute_syslog.Collect Syslog Results    alias=enb    unzip=${False}    destination=${TEST_LOG_DIRECTORY()}${/}syslog${/}enb_syslog.tar.gz

Check GPS Status Enable
    [Documentation]    This keyword is to check gps status enable.
    ...    Examples:
    ...    | Check GPS Status Enable |

    Wait Until Keyword Succeeds    15min    2min    Get GPS Status On Coam

Get GPS Status On Coam
    [Documentation]    This keyword is to get gps status.
    ...    Examples:
    ...    | Get GPS Status On Coam |

    Setup Admin    name=gps
    ${gps_status}    Get Gnsses Statuses    timeout=120    connection=gps
    should be equal    ${gps_status['GNSSE_R-1']['administrativeState']}    Unlocked
    ${enabled}    Convert To Lowercase    ${gps_status['GNSSE_R-1']['operationalState']}
    should be equal    ${enabled}    enabled
    Log To Console    gps status is '${gps_status['GNSSE_R-1']['operationalState']}'
    [Teardown]  run keyword and ignore error  Teardown Admin   connection=gps

Create Aliases
    [Documentation]    This keyword is to create ue aliases, enb alias and mme alias.
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_num} | No | scfc file full path |
    ...    Examples:
    ...    | Create Aliases | 2 |

    [Arguments]    ${ue_num}=1
     FOR    ${num}    IN RANGE    1    ${ue_num}+11
         Create UE Alias    UE_${num}    ue_id=${num}    id_type=cus
     END
     Create Enb Alias    ENB_1    enb_id=1    id_type=wts
     Create MME alias    MME_1    mme_id=1  id_type=wts

Add ENB Swconfig
    [Documentation]    This keyword is to add enb swconfig.
    ...    | Input Parameters | Man. | Description |
    ...    | ${swconfig_parameter} | Yes | swconfig parameter |
    ...    | ${enb_swconfig_file} | No | enb swconfig file full path, default is from bts |
    ...    Examples:
    ...    | Add ENB Swconfig | 0x300001:1 | /tmp/enb_swconfig.txt |

    [Arguments]    @{swconfig_parameter}    ${enb_swconfig_file}=${None}
    ${src_swconfig_file}=    Run Keyword If    '${enb_swconfig_file}'=='${None}'    Backup Swconfig    ${CURDIR}    enb_swconfig.txt
    ...                      ELSE               Set Variable    ${enb_swconfig_file}
    ${enb_swconfig_modified_file}=    Replace String    ${src_swconfig_file}    .txt    _modify.txt
    Setup Txt    src_file=${src_swconfig_file}    save_path=${enb_swconfig_modified_file}
    FOR    ${parameter}    IN    @{swconfig_parameter}
        ${key}    ${value}    Split String    ${parameter}    :
        run keyword and ignore error    Delete Txt Node    ${key}
        Add Txt Node    ${parameter}
    END
    Teardown Txt
    [Return]    ${enb_swconfig_modified_file}

Modify ENB Swconfig
    [Documentation]    This keyword is to modify enb swconfig.
    ...    | Input Parameters | Man. | Description |
    ...    | ${swconfig_parameter} | Yes | swconfig parameter |
    ...    | ${enb_swconfig_file} | No | enb swconfig file full path, default is from bts |
    ...    Examples:
    ...    | Modify ENB Swconfig | 0x300001:1 | /tmp/enb_swconfig.txt |

    [Arguments]    @{swconfig_parameter}    ${enb_swconfig_file}=${None}
    ${src_swconfig_file}=    Run Keyword If    '${enb_swconfig_file}'=='${None}'    Backup Swconfig    ${CURDIR}    enb_swconfig.txt
    ...                      ELSE               Set Variable    ${enb_swconfig_file}
    ${enb_swconfig_modified_file}=    Replace String    ${src_swconfig_file}    .txt    _modify.txt
    Setup Txt    src_file=${src_swconfig_file}    save_path=${enb_swconfig_modified_file}
    FOR    ${parameter}    IN    @{swconfig_parameter}
        Modify Txt Node        ${parameter}
    END
    Teardown Txt
    [Return]    ${enb_swconfig_modified_file}

ENB Upload Swconfig
    [Documentation]    This keyword is to upload enb swconfig file.
    ...    | Input Parameters | Man. | Description |
    ...    | ${enb_swconfig_file} | Yes | enb swconfig file full path to upload |
    ...    Examples:
    ...    | ENB Upload Swconfig | /tmp/enb_swconfig.txt |

    [Arguments]    ${enb_swconfig_file}
    Setup Enb Fsm Access    alias=enb1
    Put Enb File    ${enb_swconfig_file}    /ffs/run/swconfig.txt    alias=enb1
    Execute Command On Enb    rm -rf /ffs/run/swconfig.txt.p7    alias=enb1
    Execute Command On Enb    crasign /ffs/run/swconfig.txt    alias=enb1
    Teardown Enb Fsm Access    alias=enb1

Backup Swconfig
    [Documentation]    This keyword is to back up swconfig file
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the folder directory to store the swconfig file |
    ...    | ${backup_name} | No | the saved swconfig file name. it like swconfig_back.xml, default: swconfig.txt |
    ...    Examples:
    ...    | Backup Swconfig | /tmp |

    [Arguments]    ${backup_path}    ${backup_name}=swconfig.txt
    ${remote_path}=    Set Variable    /ffs/run/swconfig.txt
    ${local_path}=    Set Variable    ${backup_path}/${backup_name}
    ${cp_cmd}=    Set Variable    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.129:${remote_path} ${local_path}
    OperatingSystem.Run    ${cp_cmd}
    Set Suite Variable    ${ENB_SWCONFIG}    ${local_path}
    [Return]    ${local_path}

Load CUS Config Files And Wait Two BTS Onair
    [Documentation]    This keyword is to load cus config file, add enb configuration (including: swconfig and vendor) and wait two bts onair.
    ...    | Input Parameters | Man. | Description |
    ...    | ${scfc1_path} | Yes | scfc file full path for enb1 |
    ...    | ${scfc2_path} | Yes | scfc file full path for enb2 |
    ...    | ${yaml_config} | Yes | yaml config file full path |
    ...    | ${vendor1} | No | vendor parameter either by list or comma separated, not file path for enb1 |
    ...    | ${vendor2} | No | vendor parameter either by list or comma separated, not file path for enb2 |
    ...    | ${enb1_swconfig} | No | R&D parameters provided either by list or comma separated or full path to the file
    ...                            which will be uploaded without any changes for enb1 |
    ...    | ${enb2_swconfig} | No | R&D parameters provided either by list or comma separated or full path to the file
    ...                            which will be uploaded without any changes for enb2 |
    ...    | ${cus_swconfig} | No | not support now |
    ...    Examples:
    ...    | Load CUS Config Files And Wait Two BTS Onair | /tmp/scfc1.xml | /tmp/scfc2.xml | /tmp/cus_1.yaml |

    [Arguments]    ${scfc1_path}    ${scfc2_path}    ${yaml_config}    ${vendor1}=${None}    ${vendor2}=${None}
    ...            ${enb1_swconfig}=${None}    ${enb2_swconfig}=${None}    ${cus_swconfig}=${None}
    Add simulator    sim_type=cus    config=${yaml_config}    warning_lookup=True
    Add eNB configuration     scfc=${scfc1_path}    rad_params=${enb1_swconfig}    vendor_params=${vendor1}    host_id=1
    Add eNB configuration     scfc=${scfc2_path}    rad_params=${enb2_swconfig}    vendor_params=${vendor2}    host_id=2
    Configure environment
    Log To Console    Bts is onair.

Start Two ENB And Check Onair And Collect Log
    [Documentation]    This keyword is to start two enb, check onair and start syslog.
    ...    | Input Parameters | Man. | Description |
    ...    | ${scfc1_path} | Yes | scfc file full path for enb1 |
    ...    | ${scfc2_path} | Yes | scfc file full path for enb2 |
    ...    | ${yaml_config} | Yes | yaml config file full path |
    ...    | ${vendor1} | No | vendor parameter either by list or comma separated, not file path for enb1 |
    ...    | ${vendor2} | No | vendor parameter either by list or comma separated, not file path for enb2 |
    ...    | ${enb1_swconfig} | No | R&D parameters provided either by list or comma separated or full path to the file
    ...                            which will be uploaded without any changes for enb1 |
    ...    | ${enb2_swconfig} | No | R&D parameters provided either by list or comma separated or full path to the file
    ...                            which will be uploaded without any changes for enb2 |
    ...    | ${cus_swconfig} | No | not support now |
    ...    Examples:
    ...    | Start Two ENB And Check Onair And Collect Log | /tmp/scfc1.xml | /tmp/scfc2.xml | /tmp/cus_1.yaml |

    [Arguments]    ${scfc1_path}    ${scfc2_path}    ${yaml_config}    ${vendor1}=${None}    ${vendor2}=${None}
    ...            ${enb1_swconfig}=${None}    ${enb2_swconfig}=${None}    ${cus_swconfig}=${None}
    ute_syslog.Start Syslog    log_dir=${TEST_LOG_DIRECTORY()}/syslog    log_name=enb_syslog    ip=192.168.255.126    file_limit=200000000
    Load CUS Config Files And Wait Two BTS Onair    ${scfc1_path}    ${scfc2_path}    ${yaml_config}    ${vendor1}    ${vendor2}
    ...            ${enb1_swconfig}    ${enb2_swconfig}    ${cus_swconfig}

Prepare Two Enb Onair
    [Documentation]    This keyword is to prepare two enb onair, including: check gps status, start enb, check onair and collect syslog.
    ...    | Input Parameters | Man. | Description |
    ...    | ${scfc1_path} | Yes | scfc file full path for enb1 |
    ...    | ${scfc2_path} | Yes | scfc file full path for enb2 |
    ...    | ${yaml_config} | Yes | yaml config file full path |
    ...    | ${vendor1} | No | vendor parameter either by list or comma separated, not file path for enb1 |
    ...    | ${vendor2} | No | vendor parameter either by list or comma separated, not file path for enb2 |
    ...    | ${enb1_swconfig} | No | R&D parameters provided either by list or comma separated or full path to the file
    ...                            which will be uploaded without any changes for enb1 |
    ...    | ${enb2_swconfig} | No | R&D parameters provided either by list or comma separated or full path to the file
    ...                            which will be uploaded without any changes for enb2 |
    ...    | ${cus_swconfig} | No | not support now |
    ...    Examples:
    ...    | Prepare Two Enb Onair | /tmp/scfc1.xml | /tmp/scfc2.xml | /tmp/cus_1.yaml |

    [Arguments]    ${scfc1_path}    ${scfc2_path}    ${yaml_config}    ${vendor1}=${None}    ${vendor2}=${None}
    ...            ${enb1_swconfig}=${None}    ${enb2_swconfig}=${None}    ${cus_swconfig}=${None}
    Check GPS Status Enable
    Start Two ENB And Check Onair And Collect Log   ${scfc1_path}    ${scfc2_path}    ${yaml_config}    ${vendor1}    ${vendor2}
    ...            ${enb1_swconfig}    ${enb2_swconfig}    ${cus_swconfig}
    Run Keyword And Continue On Failure    check_err_wrn_in_btslog    ${TEST_LOG_DIRECTORY()}${/}syslog${/}    enb_syslog
    ute_syslog.Collect Syslog Results    alias=enb    unzip=${False}    destination=${TEST_LOG_DIRECTORY()}${/}syslog${/}enb_syslog.tar.gz
