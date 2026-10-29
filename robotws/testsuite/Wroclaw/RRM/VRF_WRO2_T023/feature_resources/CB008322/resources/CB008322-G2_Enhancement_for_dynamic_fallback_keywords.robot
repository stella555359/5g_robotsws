*** Settings ***
Documentation
...  contact: Oleksandr Kulieshov

Library    Collections
Library    String
Library    DateTime
Library    XML  use_lxml=True
Library    taf.analyzer.pmcounter
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Library    taf.hw.mcs  WITH NAME   MCS
Library    taf.transport.ssh
Library    taf.ue
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.bip_log_collector.BipLogCollector  WITH NAME  BIP
Library    ../../../../VRF_WRO2_T01/resources/legacy/ps_csv_parser.py  WITH NAME  parser
Library    ../../../resources/swconfig_operations/SwconfigOperations.py
Library    ../../../resources/TTI_reader.py
Resource   ../../../resources/ca_IWK.robot
Resource   ../../../../VRF_WRO2_T01/resources/legacy/topyoung_mcs.robot


*** Keywords ***
Start Specific Data Transfer
    [Documentation]
    ...  Prepares UE and starts data transfer.
    ...
    ...  **Full description:**
    ...
    ...  Attaches UE, validates cell and IP, and starts data transfer depending on ${tput_value}.
    ...  Requires ${NR_CALL_CELL_ID} with expected to attach cell ID.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...  | **Maintainer:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Input Parameters:**
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | tput_value            | Yes  | Value of expected tput expressed in Mbits/sec                       |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...     Start Specific Data Transfer  1500

    [Arguments]  ${tput_value}

    Log  === Start ${tput_value} Mbits/sec Data Transfer ===  console=True
    ${dt_name}  Set Variable If  '${tput_value}'=='1500'  NR_DL_high  NR_DL_low
    Attach UE  NR_UE
    ${current_ue_cell}  Get Ue Info  NR_UE  cell_id
    ${ue_ip}  Wait Until Keyword Succeeds  5x  10s  Get UE Info  NR_UE  ip
    Should Match Regexp  ${ue_ip}  \\d+\\.\\d+\\.\\d+\\.\\d+
    Should Match  ${current_ue_cell}  ${NR_CALL_CELL_ID}  msg=UE attached to antother cell than expected!
    Start Data Transfer  ${dt_name}  NR_UE  dl  throughput=${tput_value} Mbits/sec
    ...  protocol=udp  packet=1400
    Sleep  10s  reason=Waiting to call stabilize
    Check Data Transfer Is Alive   ${dt_name}
    Log  === ${tput_value} Mbits/sec Data Transfer Started ===  console=True


${action} Attenuation At ${amount} Phase Shifter Outputs
    [Documentation]
    ...  It is used to upload settings to phase shifter.
    ...
    ...  **Full description:**
    ...
    ...  According to arguments ${action} and ${amount} prepares and uploads attenuation.
    ...  The attenuation preparation is based on the configuration provided under path ${PS_CONFIG_PATH}.
    ...  Allows to change attanuation at two or all phase shifter output ports.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...  | **Maintainer:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Input Parameters:**
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | action                | Yes  | Possible values 'Set' any other will be treated as 'Reduce'         |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | amount                | Yes  | Possible values 'All' any other will be treated as 'Two'            |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...     Set Attenuation At All Phase Shifter Outputs

    ${suppress}  Set Variable If  '${action}'=='Set'  True  False
    ${all_outputs}  Set Variable If  '${amount}'=='All'  True  False
    ${att_list}  parser.Get Att Output Channel  ${PS_CONFIG_PATH}
    ${increased_att_list}  Prepare Increased Attenuation List  ${att_list}
    Run Keyword If  ${all_outputs} and ${suppress}  Create All Output Channels Lists  ${increased_att_list}
    ...  ELSE IF  ${all_outputs} and not ${suppress}  Create All Output Channels Lists  ${att_list}
    ...  ELSE  Create Two Output Channels Lists  ${att_list}  ${suppress}
    CB008322-G2_Enhancement_for_dynamic_fallback_keywords.Setup Phaseshifter  ${all_outputs}


Setup phaseshifter
    [Documentation]
    ...  Uploads settings at phase shifter.
    ...
    ...  **Full description:**
    ...
    ...  Establishes a connection to phase shifter based on data provided in __init__.py.
    ...  Uploads prepared attenuation setup.
    ...  Any other connection to phase shifter (even manual connection) must be terminated before using KW Setup MCS.
    ...  Requires ${ATT_B12} which is provided by KW Get Att Output Channel.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...  | **Maintainer:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Input Parameters:**
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | all_outputs           | Yes  | Determines number of updated output ports, value True or False      |
    ...  |                       |      | In case of False it is 2 output ports                               |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...     Setup phaseshifter  True

    [Arguments]   ${all_outputs}

    Log  === Start Setting At Phase Shifter ===  console=True
    Setup MCS
    ${length}  Get Length  ${ATT_B12}
    Run Keyword If  ${all_outputs}  Update All Attenuations  ${length}
    ...  ELSE  Update Two Attenuations   ${length}
    Log  === Phase Shifter Is Set! ===  console=True
    [Teardown]  Teardown MCS


Collect BIP Logs For Specific Amount Of Time
    [Documentation]
    ...  Collects BIP logs.
    ...
    ...  **Full description:**
    ...
    ...  Collector of BIP log which utilizes gnbMirroring scripts. Implements common log collector API.
    ...  Logs are collected only for the first iteration of the loop.
    ...  Log are collected under path ${LOG_PATH}/misc_logs.
    ...  Requires variables ${LOG_PATH} (path where logs will be collected) and ${ITERATION} (number of current loop iteration).
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...  | **Maintainer:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Input Parameters:**
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | time_in_seconds       | Yes  | Time of log collecting expressed in seconds                         |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | name                  | Yes  | Name of collected log                                               |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...     Collect BIP Logs For Specific Amount Of Time  3  before_attenuation

    [Arguments]    ${time_in_seconds}  ${name}

    Return From Keyword If  ${ITERATION} != 1
    BIP.Start Log Collecting
    Sleep  ${time_in_seconds}s  reason=For BIP collection
    BIP.Stop Log Collecting
    ${pcap_path}  BIP.Download Log  ${LOG_PATH}/misc_logs/${name}
    Log To Console  ${pcap_path}


Create Two Output Channels Lists
    [Documentation]
    ...  Creates attenuation list for two output channels.
    ...
    ...  **Full description:**
    ...
    ...  Creates attenuation set depending on ${att} and ${suppress}.
    ...  Attenuation is prepared for phase shifter output ports 13 and 14.
    ...  If ${suppress}==True attenuation is set to 90dBm.
    ...  ${att} list is created based on previously prepared phase shifter configuration.
    ...  Attenuation list is prepared as a set of global variables ${ATT_B${i}}.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...  | **Maintainer:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Input Parameters:**
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | att                   | Yes  | list of prepared attenuation values                                 |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | suppress              | Yes  | if suppress==True attenuation is set to 90dBm, value True or False  |
    ...  |                       |      | if suppress==False attenuation is set to 20dBm as in ${att}         |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  ${attenuation_list}    Create List    90.0    90.0    90.0    20.0    20.0    20.0
    ...  Create Two Output Channels Lists  ${attenuation_list}  True

    [Arguments]   ${att}  ${suppress}

    FOR   ${i}   IN RANGE  12  14
        Run Keyword If  ${suppress}  Set Test Variable  ${ATT_B${i}}  ${att}[0]
        ...             ELSE         Set Test Variable  ${ATT_B${i}}  ${att}[${i}]
    END


Create All Output Channels Lists
    [Documentation]
    ...  Creates attenuation list for all output channels.
    ...
    ...  **Full description:**
    ...
    ...  Creates attenuation set depending on ${att}.
    ...  Attenuation is prepared for all 16 phase shifter output ports.
    ...  ${att} list is created based on previously prepared phase shifter configuration.
    ...  Attenuation list is prepared as a set of global variables ${ATT_B${i}}.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...  | **Maintainer:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Input Parameters:**
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | att                   | Yes  | list of prepared attenuation values                                 |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  ${attenuation_list}    Create List    90.0    90.0    90.0    20.0    20.0    20.0
    ...  Create All Output Channels Lists  ${attenuation_list}

    [Arguments]   ${att}

    FOR   ${i}   IN RANGE   16
        Set Test Variable   ${ATT_B${i}}   ${att}[${i}]
    END


Prepare Increased Attenuation List
    [Documentation]
    ...  Prepares incerased attenuation list based on previously prepared phase shifter configuration.
    ...
    ...  **Full description:**
    ...
    ...  Replaces each current attenuation with value 20 dBm by value passed by user in ${DEDICATED_ATT}.
    ...  Returns modified list of attenuation.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...  | **Maintainer:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Input Parameters:**
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | prim_att_list         | Yes  | primary list of attenuation                                         |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  ${attenuation_list}    Create List    90.0    90.0    90.0    20.0    20.0    20.0
    ...  Prepare Increased Attenuation List  ${attenuation_list}

   [Arguments]    ${prim_att_list}

    ${modified_list}  Create List
    ${float_dedicated_att}  Evaluate  float(${DEDICATED_ATT})
    FOR  ${output_port}  IN  @{prim_att_list}
        ${output_att}  Secondary Loop  ${output_port}  20.0  ${float_dedicated_att}
        Append To List  ${modified_list}  ${output_att}
    END
    [Return]    ${modified_list}


Secondary Loop
    [Documentation]
    ...  Helper loop due to limitations of RobotFramework 3.1.2 using loops inside loops.
    ...
    ...  **Full description:**
    ...
    ...  Replaces attenuation values for single output.
    ...  Returns silngle output modified attenuation list.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...  | **Maintainer:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Input Parameters:**
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | output_port           | Yes  | number of output port                                               |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | primary_att           | Yes  | value to be replaced                                                |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | increased_att         | Yes  | Attenuation value which will replace 'primary_att'                  |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...     Secondary Loop  B12  20  40

    [Arguments]    ${output_port}    ${primary_att}    ${increased_att}

    ${attenuation_list}  Create List
    FOR  ${attenuation}  IN  @{output_port}
            Run Keyword If  '${attenuation}' == '${primary_att}'  Append To List  ${attenuation_list}  ${increased_att}
            ...    ELSE  Append To List  ${attenuation_list}  ${attenuation}
    END
    [Return]    ${attenuation_list}


Update Two Attenuations
    [Documentation]
    ...  Uploads attenuation for two phase shifter outputs.
    ...
    ...  **Full description:**
    ...
    ...  Updates attenuation at phase shifter output ports B13 and B14.
    ...  Requires existing phase shifter connection with alias MCS_0.
    ...  Requires ${ATT_B12} and ${ATT_B13} which are provided by KW Get Att Output Channel.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...  | **Maintainer:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Input Parameters:**
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | length                | Yes  | number of input ports defined for single output port                |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...     Update Two Attenuations  128

    [Arguments]  ${length}

    FOR  ${i}  IN RANGE  0  ${length}
        MCS.set attenuation  ${ATT_B12}[${i}]  ${i+1}  ${13}   MCS_0
        MCS.set attenuation  ${ATT_B13}[${i}]  ${i+1}  ${14}   MCS_0
    END


Update All Attenuations
    [Documentation]
    ...  Uploads attenuation for all phase shifter outputs.
    ...
    ...  **Full description:**
    ...
    ...  Updates attenuation at phase shifter all output ports.
    ...  Requires existing phase shifter connection with alias MCS_0.
    ...  Requires variables from ${ATT_B0} to ${ATT_B15} which are provided by KW Get Att Output Channel.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...  | **Maintainer:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Input Parameters:**
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | length                | Yes  | number of input ports defined for sinle output port                 |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...     Update All Attenuations  64

    [Arguments]  ${length}

    FOR  ${i}  IN RANGE  0  ${length}
        MCS.set attenuation   ${ATT_B0}[${i}]    ${i+1}    ${1}    MCS_0
        MCS.set attenuation   ${ATT_B1}[${i}]    ${i+1}    ${2}    MCS_0
        MCS.set attenuation   ${ATT_B2}[${i}]    ${i+1}    ${3}    MCS_0
        MCS.set attenuation   ${ATT_B3}[${i}]    ${i+1}    ${4}    MCS_0
        MCS.set attenuation   ${ATT_B4}[${i}]    ${i+1}    ${5}    MCS_0
        MCS.set attenuation   ${ATT_B5}[${i}]    ${i+1}    ${6}    MCS_0
        MCS.set attenuation   ${ATT_B6}[${i}]    ${i+1}    ${7}    MCS_0
        MCS.set attenuation   ${ATT_B7}[${i}]    ${i+1}    ${8}    MCS_0
        MCS.set attenuation   ${ATT_B8}[${i}]    ${i+1}    ${9}    MCS_0
        MCS.set attenuation   ${ATT_B9}[${i}]    ${i+1}    ${10}   MCS_0
        MCS.set attenuation   ${ATT_B10}[${i}]   ${i+1}    ${11}   MCS_0
        MCS.set attenuation   ${ATT_B11}[${i}]   ${i+1}    ${12}   MCS_0
        MCS.set attenuation   ${ATT_B12}[${i}]   ${i+1}    ${13}   MCS_0
        MCS.set attenuation   ${ATT_B13}[${i}]   ${i+1}    ${14}   MCS_0
        MCS.set attenuation   ${ATT_B14}[${i}]   ${i+1}    ${15}   MCS_0
        MCS.set attenuation   ${ATT_B15}[${i}]   ${i+1}    ${16}   MCS_0
    END


Set Up Tti Dec
    [Documentation]
    ...  KW used to setup tti decoder.
    ...
    ...  **Full description:**
    ...
    ...  KW used to install *_tti-dec.deb package, which is available for every build.
    ...  Requires to provide ${DOWNLOAD_TTI_DEC}.
    ...  ${DOWNLOAD_TTI_DEC} determines if tti-dec.deb will be downloaded and installed. Value True or False.
    ...
    ...  | **Author:** tomasz.stawowczyk@nokia.com
    ...  | **Maintainer:** tomasz.stawowczyk@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...     Set Up Tti Dec

    Return From Keyword If  not ${DOWNLOAD_TTI_DEC}
    Log  \nSetting up TTI decoder  console=True
    ${sw_version}    Get SW Version  alias=gNB
    ${tti_dec_dir}   Set Variable
    ...  https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/${sw_version}/${sw_version}_tti-dec.deb
    ${download_dir}  Set Variable  /home/ute/Downloads
    ${rc_wget}  OperatingSystem.Run And Return Rc  wget ${tti_dec_dir} -O ${download_dir}/tti_dec.deb
    Should Be Equal As Integers  ${rc_wget}  0  msg=wget command ended with an error
    ${rc_dpkg}  OperatingSystem.Run And Return Rc  sudo dpkg -i ${download_dir}/tti_dec.deb
    Should Be Equal As Integers  ${rc_dpkg}  0  msg=dpkg command ended with an error
    Log  \nNew version of TTI decoder was successfully installed  console=True
