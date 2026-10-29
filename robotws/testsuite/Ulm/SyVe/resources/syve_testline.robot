*** Settings ***
Documentation     Keywords related to CCRT handling

Resource   ../../resources/Common/testline.robot
Resource   ../../resources/Common/commissioning.robot
Resource   ../../resources/Common/gnb.robot
Resource   ../../resources/Common/snapshot.robot
Resource   ../../resources/Common/btslog.robot
Resource   ../resources/iperf_processes.robot
Resource   ../../resources/Common/connect.robot
Resource   taf/rfrl/common_resources/common_step/interface.robot
Resource   taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource   attenuator.robot
Resource   enb.robot

Library    taf.sw.scout    WITH NAME    scout
Library    taf.ue


*** Variables ***
@{ENABLED_LOGS}    snapshot    syslog
${USE_SCOUT_INTERNAL_ID}    True


*** Keywords ***
Get GNB Initial Config Path
    [Documentation]        :Author: Masiar Makkinejad  :Editor:Amr Aboushehata
    ...                    used to retrieve the full storage path of the SCF config file, that is to be applied for the
    ...                    current testline and the current SW branch during the Robot Testsuite Teardown phase of
    ...                    test runs on Common CRT testlines of Pz Ulm Tribe (SyVe). This reset of the commissioning at
    ...                    the end of each Testsuite execution shall assure, that the next Testsuite execution running
    ...                    on the same testline, can assume a known and defined initial configuration as stored at
    ...                    the path returned by this keyword.
    ...                    The keyword takes the logical ID of the GNB of the current testline as input parameter. The
    ...                    current SW branch information is fetched from the target.
    ...    :param gnb_id:  logical ID of the GNB on the current testline, for which the full storage path shall be
    ...                    returned. Allowed range is [0 .. (maxNumGnbInTlConfig-1)]. Default value is 0.
    ...    :param du_id:   (optional) logical ID of the DU on the gNB. Only needed in case of cloudBTS testlines
    ...    :param config_path:   (optional) default is /mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs
    [Arguments]    ${gnb_id}=0    ${du_id}=0    ${branch_version}=None  ${scf_file_name}=scf.xml
    ...    ${config_path}=/mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs
    ...    ${repository_config_path}=/home/ute/CRT/topology-configs/PzUlm_CRT_TL_configs

    ${tl_name}    testline.Get Testline Name

    IF    '${branch_version}'=='None'
           ${sw_branch}    testline.Get GNB SW Branch    gnb_id=${gnb_id}    du_id=${du_id}
    ELSE
           ${sw_branch}    Set Variable   ${branch_version}
    END

    ${sw_branch_adapted}    Set Variable If    'SBTS00_ENB_9999' in '${sw_branch}'    5G_0.800    ${sw_branch}

    ${repository_scf_path}    Set Variable    ${repository_config_path}/${sw_branch_adapted}/${tl_name}/GNB-${gnb_id}/${scf_file_name}
    ${file_exists}    Run Keyword And Return Status    File Should Exist    ${repository_scf_path}
    IF    ${file_exists}
        RETURN    ${repository_scf_path}
    END

    ${inital_scf_path}    Set Variable    ${config_path}/${sw_branch_adapted}/${tl_name}/GNB-${gnb_id}/${scf_file_name}
    ${file_exists}    Run Keyword And Return Status    File Should Exist    ${inital_scf_path}
    IF    ${file_exists}
        RETURN    ${inital_scf_path}
    END

    Fail    The initial SCF for GNB-${gnb_id} of Common CRT testline '${tl_name}' doesn't exist at paths
    ...     \n - '${repository_scf_path}'\n and
    ...     \n - '${inital_scf_path}'\n
    ...     Please create it first!


Get ENB Initial Config Path
    [Documentation]        :Author: Amr Aboushehata
    ...                    used to retrieve the full storage path of the SCF config file, that is to be applied for the
    ...                    current testline and the current SW branch during the Robot Testsuite Teardown phase of
    ...                    test runs on Common CRT testlines of Pz Ulm Tribe (SyVe). This reset of the commissioning at
    ...                    the end of each Testsuite execution shall assure, that the next Testsuite execution running
    ...                    on the same testline, can assume a known and defined initial configuration as stored at
    ...                    the path returned by this keyword.
    ...                    The keyword takes the logical ID of the ENB of the current testline as input parameter. The
    ...                    current SW branch information is fetched from the target.
    ...    :param enb_id:  logical ID of the ENB on the current testline, for which the full storage path shall be
    ...                    returned. Allowed range is [0 .. (maxNumEnbInTlConfig-1)]. Default value is 0.
    ...    :param config_path:   (optional) default is /mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs
    [Arguments]    ${enb_id}=0    ${branch_version}=None
    ...    ${config_path}=/mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs
    ${tl_name}=    testline.Get Testline Name

    IF    '${branch_version}'=='None'
           ${sw_branch}=    syve_testline.Get eNB SW Branch    enb_id=${enb_id}
    ELSE
           ${sw_branch}=    Set Variable    ${branch_version}
    END

    ${sw_branch_adapted}=    Set Variable If    'SBTS00_ENB_9999' in '${sw_branch}'    5G_0.800    ${sw_branch}

    ${inital_scf_path}=    Set Variable    ${config_path}/${sw_branch_adapted}/${tl_name}/ENB-${enb_id}/scf.xml
    File Should Exist    ${inital_scf_path}
    ...  The initial SCF for ENB-${enb_id} of Common CRT testline '${tl_name}' doesn't exist at path \n'${inital_scf_path}'\nPlease create it first!
    RETURN    ${inital_scf_path}


Testline Teardown For CCRT
    [Documentation]    :Author: Antje Jooss   Modified by: Anuk/Monika
    ...    This function is defined for general testline teardown of all CCRT tests.
    ...    In case no argument is given, the gnb list from __init__.py is taken and all gnbs will be commissioned with
    ...    initial SCF, e.g.
    ...    USAGE:
    ...    Resource    ../../../SyVe/resources/syve_testline.robot
    ...    Testline Teardown for CCRT
    ...    or e.g.: Testline Teardown for CCRT    gnb_id=${0}
    [Arguments]    ${gnb_id}=${None}  ${node_list}=${None}    ${ignore_eNB}=${False}

    Collect Snapshot For All Nodes  ${node_list}
    ${status_truckRoll}=  Run Keyword and Return Status    Check Truck Roll For Nodes
    IF   ${status_truckRoll}
        connect.Disconnect All Available SSH Connections
        interface.Common Step Trigger
        attenuator.Set Attenuator To Max Value
        iperf_processes.Kill All Iperf Processes On Appserver And UE PC
        Load Initial GNB SCF For CCRT        ${gnb_id}
    END
    ${status_TruckRoll_post}=  Run Keyword And Return Status    Check Truck Roll For Nodes
    IF     ${status_TruckRoll_post}!=True     Collect Snapshot For All Nodes
    [Teardown]    Collect Syslogs For All Nodes    ignore_eNB=${ignore_eNB}


Testline Setup For CCRT
    [Documentation]    :Author: Monika Kolleshi
    ...    This function is defined for general testline setup for all CCRT tests.
    ...    No arg are needed to be passed when calling this keyword
    ...    because it will take the global variable: ENABLED_LOGS in account
    ...    Add this KW in the section of Prepare TL for Testing in each CCRT test.
    [Arguments]    ${ignore_eNB}=${False}
    syve_testline.Start Enabled Logs    ignore_eNB=${ignore_eNB}


Load Initial GNB SCF For CCRT
    [Documentation]    :Author: Antje Jooss
    ...    This function is defined to load the inital scf to all GNBs.
    ...    Function can be called with and without gnb argument. If argument is given only this gnb is commissioned.
    ...    In case no argument is given, the gnb list from __init__.py is taken and all gnbs will be commissioned with
    ...    initial SCF, e.g.
    ...    Load Initial GNB SCF For CCRT
    ...    Load Initial GNB SCF For CCRT    gnb_id=${0}
    [Arguments]    ${gnb_id}=${None}
    ${gnb_count}=   Set Variable If   ${tl.gnbs != None}   ${tl.gnbs.__len__()}   ${0}
    FOR    ${gnb}    IN RANGE    ${gnb_count}
        IF  ${gnb_id}!=${None} and ${gnb_id}!=${gnb}   CONTINUE
        ${initial_scf_path_gnb}=       Get GNB Initial Config Path    ${gnb}
        commissioning.Execute Full Commissioning    ${initial_scf_path_gnb}    ${gnb}    use_oam_http_connection=${True}
    END
    FOR    ${gnb}    IN RANGE    ${gnb_count}
        IF  ${gnb_id}!=${None} and ${gnb_id}!=${gnb}   CONTINUE
        gnb.Wait For Minimum Required State For Cell Setup  node_id=${gnb}   timeout=25min
        gnb.Wait Until Node To Be Onair State   node_id=${gnb}   timeout=15 min
    END


Load Initial ENB SCF For CCRT
    [Documentation]    :Author: Antje Jooss
    ...    This function is defined to load the inital scf to all ENBs.
    ...    Function can be called with and without gnb argument. If argument is given only this gnb is commissioned.
    ...    In case no argument is given, the enb list from __init__.py is taken and all enbs will be commissioned with
    ...    initial SCF, e.g.
    ...    Load Initial ENB SCF For CCRT
    ...    Load Initial ENB SCF For CCRT    ${enb_id}=${0}
    [Arguments]    ${enb_id}=${None}
    ${enb_count}=   Set Variable If   ${tl.enbs != None}   ${tl.enbs.__len__()}   ${0}
    FOR    ${enb}    IN RANGE    ${enb_count}
        IF  ${enb_id}!=${None} and ${enb_id}!=${enb}   CONTINUE
        ${initial_scf_path_enb}=       Get ENB initial Config Path    ${enb}
        commissioning.Execute ENB Full Commissioning    ${initial_scf_path_enb}    ${enb}    use_oam_http_connection=${True}
    END
    FOR    ${enb}    IN RANGE    ${enb_count}
        IF  ${enb_id}!=${None} and ${enb_id}!=${enb}   CONTINUE
        gnb.Wait For Minimum Required State For Cell Setup  node_type=enb    node_id=${enb}   timeout=25min
        gnb.Wait Until Node To Be Onair State   node_type=enb    node_id=${enb}   timeout=15 min
    END


Get ENB SW Branch
    [Documentation]    :Author: Amr Aboushehata
    ...    Fetch the prefix eNB SW branch
    ...    :param enb_id: (default=0) Id/Number of eNB
    ...    :return: active Software branch on eNB (e.g 5G_0.800)
    ...
    [Arguments]    ${enb_id}=0
    ${enb_sw_version}=    testline.Get ENB SW version    ${enb_id}
    ${enb_sw_version_prefix}=    Fetch from left     ${enb_sw_version}     _
    ${eNB_branch}=   Set Variable If    '_999' in '${enb_sw_version}'    SBTS00    ${enb_sw_version_prefix}
    RETURN    ${eNB_branch}


Get ENB-NB 3G SW Version
    [Documentation]    :Author: Frank Rettinger
    ...    Get NB 3G SW version, if 3G module (eg. FSMF in Cabinet-2) is connected to eNB
    ...    Utilizes only coam M-plane based API to check it.
    ...
    ...    :param enb_id: (default=0) Id/Number of eNB
    ...    :return: active Software version on NB 3G module conntected to eNB

    [Arguments]    ${enb_id}=0
    ${enb}                      Get Variable Value          ${tl.enbs[${enb_id}]}
    ${is_RealEnb_Object}        testline_py.is_realenb      ${enb}
    IF      not ${is_RealEnb_Object}    RETURN   ${EMPTY}
    admin.Connect To            bts_host=${tl.enbs[${enb_id}].oam_ip.v4}    name=enb
    ${bts_hw_info}              admin.Get Bts Info    connection=enb
    ${wcdma_rat_version}        Get Variable Value    ${bts_hw_info['swInfo']['wcdmaRatVersion']}
    Log                 [INFO] 3G WCDMA SW Version: ${wcdma_rat_version}    console=${P_console}
    admin.Teardown    connection=enb
    RETURN     ${wcdma_rat_version}


Save Current Loads
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Save eNB and gNB load to file for reporting after test end
    ...
    ...    :param enb_id: (default=0) Id/Number of eNB
    ...    :param gnb_ids: (default=EMPTY) List of Id/Number of gNBs
    ...
    [Arguments]    ${enb_id}=${0}    ${gnb_ids}=${EMPTY}
    ${resultSuiteBaseDir}=    testline.Get Test Suite Result Base Directory
    ${enbSwVersion}=    testline.Get ENB SW Version    enb_id=${enb_id}
    ${gnb_versions}=    Set Variable    ${EMPTY}
    IF    ${tl.gnbs == None}
            @{target_gnb_ids}=    Create List
    ELSE IF    '${gnb_ids}'=='${EMPTY}'
            @{target_gnb_ids}=    Create List    ${0}
    ELSE
            @{target_gnb_ids}=    Set Variable    ${gnb_ids}
    END
    FOR    ${gnb_id}    IN    @{target_gnb_ids}
        ${gnb_version}=    testline.Get GNB SW Version    gnb_id=${gnb_id}
        IF    '${gnb_versions}'!='${EMPTY}'
                ${gnb_versions}=    Catenate    SEPARATOR=;    ${gnb_versions}    ${gnb_version}
        ELSE
                ${gnb_versions}=    Set Variable    ${gnb_version}
        END
    END
    Create file    ${resultSuiteBaseDir}/reportingInfo.txt   gNB: ${gnb_versions}\neNB: ${enbSwVersion}


Check Truck Roll For Nodes
    [Documentation]    :Author: Monika/Anuk
    ...    This function is defined for general testline teardown of all CCRT tests.
    ...    This KW detects Truck Roll alarms in Suite Teardown for all the nodes in the TL.
    ...    The check is applied before and after loading the base scf in the node.
    ${gnb_count}=    Get Length  ${tl.gnbs}
    ${enb_count}=    Get Length  ${tl.enbs}

    FOR    ${gnb}    IN RANGE    ${gnb_count}
        ${status_truck_roll_gnb}=    Check Truck Roll Fault IDs    node_id=${gnb}    node_type=gnb
        IF    ${status_truck_roll_gnb}    FAIL   msg=Truck Roll Alarm detected. TL is put to Stop&Fix!
    END

    FOR    ${enb}    IN RANGE    ${enb_count}
        ${status_truck_roll_enb}=    Check Truck Roll Fault IDs    node_id=${enb}    node_type=enb
        IF    ${status_truck_roll_enb}    FAIL   msg=Truck Roll Alarm detected. TL is put to Stop&Fix!
    END


Check Truck Roll Fault IDs
    [Documentation]    Author: Anuk/ Monika
    ...    Keyword to identify if Truck Roll Fault IDs are present in the node.
    ...    If any of the alarms is found in the node (enb/gnb), a file will be created under logs folder:
    ...    syve_ta_logs/00_STOP_and_FIX_flags/x_xx_UTE5GTLxxx.txt
    ...    and the TL will be set to 'Stop and Fix' mode.
    ...    This check is included in SW installation and Test Suite Teardown 2 times.
    [Arguments]    ${node_id}=0    ${node_type}=gnb

    FOR   ${fault_name}                  ${fault_id}   IN
    ...   No connection to unit          ${10}
    ...   Communication failure          ${1806}
    ...   FSP subunit lost               ${4341}
    ...   No connection between primary and BTS extension system module  ${4352}
    ...   Virtual node not responding    ${4383}
        ${result}=    Run Keyword And Return Status    gnb_alarm.Verify Alarm is Active on gNB
        ...    fault_name=${fault_name}  gnb_id=${node_id}    fault_id=${fault_id}

        IF    ${result}
              Save Stop And Fix logs   node_id=${node_id}    node_type=${node_type}
              Log to Console     Truck Roll Alarm (${fault_name}) has been detected. Please check logs!
              RETURN   ${True}
        END
    END

    RETURN     ${False}


Save Stop And Fix Logs
    [Documentation]   Author: Anuk/ Monika
    ...               This KW dumps Test instance related data to a .txt file in case of Truck Roll Alarm detection.
    [Arguments]       ${node_id}=0    ${node_type}=gnb
    ${node}=        Set Variable    ${node_type}_${node_id}
    ${name_node}=   Get Environment Variable       name=NODE_NAME
    ${build}=          Get Environment Variable    name=BUILD_URL
    ${robot_inc_tags}=  Get Environment Variable    name=ROBOT_INCLUDE_TAGS
    IF   '${robot_inc_tags}'=='sw_update'
        ${target_sw}=   Get Environment Variable    name=TARGET_SW_VERSION_GNB
    ELSE
        ${target_sw}=   testline.Get GNB SW version
    END
    ${timestamp}=       Get Current Date            result_format=datetime
    ${log_path}=                Set variable   /mnt/etlogs/syve_ta_logs/00_STOP_and_FIX_flags/${name_node}.txt
    ${was_put_variable}=        Set variable   was put into Stop and Fix State with following attributes:
    ${log_build}=               Set Variable   JENKINS_BUILD: ${build}
    ${log_time}=                Set Variable   TIMESTAMP: ${timestamp}
    ${log_target_sw_node}=       Set Variable   AFFECTED SW: ${target_sw}
    ${log_affected_node}=            Set Variable   AFFECTED NODE: ${node}
    ${first_line}=       Catenate    ${name_node}   ${was_put_variable}
    ${Final_output}=     Catenate    SEPARATOR=${\n}  ${first_line}    ${log_build}    ${log_target_sw_node}   ${log_affected_node}   ${log_time}
    Create File     ${log_path}    ${Final_output}


Start Enabled Logs
   [Documentation]    :Author: Monika Kolleshi
    ...    This function is defined to start collecting Syslogs for all nodes.
    ...    :param ENABLED_LOGS (default=syslog) List of logs to be collected
    ...
    ...    In case of SRAN we can not start the syslog two times...
    ...    Argument ``ignore_eNB`` if it is SBTS (single RAN) we need to ignore the eNB.
    ...    SRAN share the same SMOD we can only start the syslog one time.
    ...
    ...     | ignore_eNB   | ${True} or ${False} (boolean) |
    ...
    ...    Start enabled logs

    [Arguments]    ${ignore_eNB}=${False}

    ${enb_count}    Set Number Of ENB    ignore_eNB=${ignore_eNB}

    ${gnb_count}=   Set Variable If   ${tl.gnbs != None}   ${tl.gnbs.__len__()}   ${0}

    Log To Console    Starting enabled logs: ${ENABLED_LOGS} for ${enb_count} eNBs and ${gnb_count} gNBs
    FOR    ${enb_node}    IN RANGE    ${enb_count}
         IF    ('syslog' in ${ENABLED_LOGS})
         ...   Start Syslog Collection For CCRTS    node_id=${enb_node}    node_type=enb
    END
    FOR    ${gnb_node}    IN RANGE    ${gnb_count}
         IF    ('syslog' in ${ENABLED_LOGS})
         ...   Start Syslog Collection For CCRTS    node_id=${gnb_node}    node_type=gnb
    END


Stop Enabled Logs    #ToDo: Is this KW in use? or "Collect Syslogs For All Nodes" ??
   [Documentation]    :Author: Monika Kolleshi
    ...    This function is defined to stop collecting Snapshots &/Syslogs for all nodes.
    ...    :param ENABLED_LOGS (default=snapshot, syslog) List of logs to be collected
    ...
    ...    In case of SRAN we can not start the syslog two times...
    ...    Argument ``ignore_eNB`` if it is SBTS (single RAN) we need to ignore the eNB.
    ...    SRAN share the same SMOD we can only start the syslog one time.
    ...
    ...     | ignore_eNB   | ${True} or ${False} (boolean) |
    ...
    ...    Stop enabled logs

    [Arguments]    ${ignore_eNB}=${False}

    ${enb_count}    Set Number Of ENB    ignore_eNB=${ignore_eNB}

    ${gnb_count}=   Set Variable If   ${tl.gnbs != None}   ${tl.gnbs.__len__()}   ${0}

    Collect Snapshot For All Nodes

    FOR    ${enb_node}    IN RANGE    ${enb_count}
        IF    ('syslog' in ${ENABLED_LOGS})
        ...    Stop Syslog Collection For CCRTS    node_id=${enb_node}    node_type=enb
    END

    FOR    ${gnb_node}    IN RANGE    ${gnb_count}
        IF    ('syslog' in ${ENABLED_LOGS})
        ...   Stop Syslog Collection For CCRTS    node_id=${gnb_node}    node_type=gnb
    END
    Log To Console    Stopping enabled logs: ${ENABLED_LOGS}


Collect Snapshot For All Nodes
   [Documentation]    :Author: Monika Kolleshi, Uli
    ...    This function is defined to stop collecting Snapshots for all nodes.
    ...    | ENABLED_LOGS (Global Variable)| List of logs to be collected (default=snapshot, syslog) |
    ...    | node_list                     | list of NEs to to snapshot, e.g.  gnb_0 gnb_1           |
    ...    | ..                       | If called without arguments Snapshot from all NEs are taken. |
    ...

    [Arguments]  ${node_list}=${none}
    IF  'snapshot' not in ${ENABLED_LOGS}   RETURN
    IF  '${node_list}' != '${none}'
      Log  [INFO]:${\n}Collect Snapshots for NEs: ${node_list}    console=${P_console}
      ${single_nodes}  Split String  ${node_list}
      Log List  ${single_nodes}
      FOR  ${node}  IN  @{single_nodes}
        ${node_type}  ${node_id}  Split String  ${node}  _
        ${node_type}  Convert To Lower Case  ${node_type}
        Collect Snapshot For Nodes In CCRTs    node_type=${node_type}  node_id=${node_id}
      END
    ELSE
      Log    [INFO]:${\n}Collect Snapshot for All Nodes    console=${P_console}
      Collect Snapshot For Nodes In CCRTs    node_type=gnb
      Collect Snapshot For Nodes In CCRTs    node_type=enb
    END


Collect Syslogs For All Nodes
    [Documentation]    :Author: Monika Kolleshi
    ...    This function is defined to stop collecting Syslogs for all nodes.
    ...    :param ENABLED_LOGS (default=snapshot, syslog) List of logs to be collected
    ...    Function can be called without an argument.
    [Arguments]    ${ignore_eNB}=${False}

    ${enb_count}    Set Number Of eNB    ignore_eNB=${ignore_eNB}

    ${gnb_count}  Get Length  ${tl.gnbs}

    FOR    ${enb_node}    IN RANGE    ${enb_count}
        IF    ('syslog' in ${ENABLED_LOGS}) and ${enb_count}!=${0}
        ...    Stop Syslog Collection For CCRTS    node_id=${enb_node}    node_type=enb
    END
    FOR    ${gnb_node}    IN RANGE    ${gnb_count}
        IF    ('syslog' in ${ENABLED_LOGS}) and ${gnb_count}!=${0}
        ...   Stop Syslog Collection For CCRTS    node_id=${gnb_node}    node_type=gnb
    END
    Log To Console    Stopping enabled logs: ${ENABLED_LOGS}


Set Number Of ENB
    [Arguments]    ${ignore_eNB}=${False}
    IF   ${ignore_eNB} or ${tl.enbs == None}
        ${enb_count}    Set Variable    ${0}
    ELSE
        ${enb_count}   Set Variable    ${tl.enbs.__len__()}
    END

    RETURN    ${enb_count}


Collect Snapshot For Nodes In CCRTs
    [Documentation]
    ...    | node_id    | Id/Number of Node (eNB|gNB) |
    ...    | node_type  | Node type; possible values: gNB or eNB |
    ...    :Author: Monika Kolleshi
    ...    This function is defined to collect Snapshots for all nodes
    ...    and to save them to 'test suite result base directory'.
    ...    :param node_id: (default=NONE) List of Id of nodes (enb/gnb)
    ...    :param node_type: (default=gnb) Type of node (enb/gnb)
    ...
    ...    Function can be called with an argument.
    ...    Collect Snapshot for nodes in CCRTs
    ...    Collect Snapshot for nodes in CCRTs    enb_id=${0}  node_type=enb
    ...    Collect Snapshot for nodes in CCRTs    gnb_id=${1}

    [Arguments]  ${node_id}=${None}  ${node_type}=gnb
    ${node_count}  Get Length  ${tl.${node_type}s}
    IF    ${node_count}!=0
        ${target_dir}=  testline.Get Test Suite Result Base Directory
        Log To Console  CCRTs Snapshot are starting for ${node_type}s
        FOR    ${node}    IN RANGE    ${node_count}
            IF  ${node_id}!=${None} and ${node_id}!=${node}   CONTINUE
            ${snapshot}=  snapshot.Get Snapshot For Node  node_id=${node}  node_type=${node_type}  target_dir=${target_dir}
        END
        Log To Console  CCRTs Snapshot for ${node_type}s are finished.
        Log    [INFO] PATH to Snapshot:${\n}${snapshot}    console=${P_console}
    END


Start Syslog Collection For CCRTS
    [Documentation]    :Author: Monika Kolleshi
    ...    Start collecting SysLogs.
    ...    :param node_id: (default=0) Id of node: gNB|eNB
    ...    :param node_type: (default=gnb) either enb or gnb
    ...    Function should be called with an argument.
    ...    Start syslog collection for CCRTS    node_id=${0}  node_type=enb
    ...    Start syslog collection for CCRTS    node_id=${0}

    [Arguments]  ${node_id}=${0}  ${node_type}=gnb
    ${node}=  Set Variable    ${node_type}_${node_id}
    Log To Console    SysLog collection for ${node} is starting
    ${testpc_alias}=    connect.Connect To Test PC Proxy For Node  node_id=${node_id}  node_type=${node_type}
    ssh.execute    command=pkill fsyslog    connection=${testpc_alias}
    btslog.Start Btslog    node_id=${node_id}  node_type=${node_type}
    ssh.Disconnect    connection=${testpc_alias}


Stop Syslog Collection For CCRTS
    [Documentation]    :Author: Monika Kolleshi
    ...    Stop collecting SysLogs and save them to 'test suite result base directory'
    ...    :param node_id: (default=0) Id of node: gNB|eNB
    ...    :param node_type: (default=gnb) either enb or gnb
    ...
    ...    Start Syslog Collection For CCRTS    node_id=${0}  node_type=enb
    ...    Start Syslog Collection For CCRTS    node_id=${0}

    [Arguments]  ${node_id}=${0}  ${node_type}=gnb
    ${node}=  Set Variable    ${node_type}_${node_id}
    Log To Console     SysLogs collection for ${node} is finished
    ${target_dir}=  testline.Get Test Suite Result Base Directory
    btslog.Stop Btslog  node_id=${node_id}  node_type=${node_type}  target_dir=${target_dir}


Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.Setup Scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.Request SCF   use_scout_internal_id=${USE_SCOUT_INTERNAL_ID}
    scout.Teardown Scout API
    RETURN   ${external_scf_id}


Link SCOUT SCF To Configuration ID For Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF To Configuration ID For Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb or sran or sbts |

    [Arguments]    ${node_id}=${0}    ${node_type}=gnb

    ${node_type}    string.Convert To Lowercase     ${node_type}

    IF  "${node_type}"=="gnb"
            ${node_type_Name}        Set Variable  gNB
    ELSE IF     "${node_type}"=="enb"
            ${node_type_Name}        Set Variable  eNB
    ELSE IF     "${node_type}"=="sran"
            ${node_type_Name}        Set Variable  SRAN
    ELSE IF     "${node_type}"=="sbts"
            ${node_type_Name}        Set Variable  sbts
    ELSE
        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb|SRAN|sbts
    END

    ${tl_name}=    testline.Get Testline Name
    Log To Console    ${\n}Test executed under: ${tl_name}
    ${str}=    Remove String    ${tl_name}    UTE5G
    ${node_id}=    Convert To Integer    ${node_id}
    # ${str1}=    Catenate    SEPARATOR=    ${str}    _    ${node_type_Name}${node_id+1}
    ${str1}=    Set Variable If    "${node_type_Name}"=="SRAN"    ${tl_name}    ${str}_${node_type_Name}${node_id+1}
    Log To Console    ${\n}SCOUT Test Line Name: ${str1}

    ${scout_testline_name}=    Set Variable    ${str1}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}


CCRT Test Cases Teardown
    [Documentation]
    ...    Postconditions Keywords used for CCRT. Please add here your [Teardown] KW.
    ...    | node_id    | Id/Number of Node (eNB|gNB|SRAN) |
    ...    | node_type  | Node type; possible values: SRAN, gNB or eNB | at Present... |
    ...    Example:
    ...     |  Run Keyword And Ignore Error    Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb

    [Arguments]    ${node_id}=${0}    ${node_type}=gnb

    Log    [INFO]:${\n}CCRT Test Cases Teardown    console=${P_console}
    Run Keyword And Ignore Error    Link SCOUT SCF To Configuration ID For Reporting    node_id=${node_id}    node_type=${node_type}


Correlate Cell ID To Physical Cell ID
    [Documentation]
    ...    | node_id    | Id/Number of Node (eNB|gNB) |
    ...    | node_type  | Node type; possible values: gNB or eNB | at Present only gNB but in future... |
    ...    | Cell_ID    | Id/Number of the  cell |
    ...    | Return:    | The Physical Cell ID for the related Cell.    |

    [Arguments]   ${node_id}=${0}    ${node_type}=gnb    ${Cell_ID}=${1}

    ${node_type}    string.Convert To Lowercase     ${node_type}

    IF   "${node_type}"=="gnb"
            ${cell_type}    Set Variable   NRCELL  # NRCELL is not a TYPO. (gNB use NRCEL)
    ELSE IF   "${node_type}"=="enb"
            Fail    Wrong node_type '${node_type}'! allowed: at present only gNB  # ToDo: Set Variable   LNCEL
    ELSE
            Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    END

    ${Cells_to_Phy_Cells}    gnb.Get GNB Physical Cell ID    gnb_id=${node_id}    # ToDo: the same for eNB...

    ${cell_dist_name}    Set Variable    ${cell_type}-${Cell_ID}
    ${Phy_Cell_id}    Set Variable    ${Cells_to_Phy_Cells}[${cell_dist_name}]

    Log    [INFO]:${\n}Physical Cell ID for ${cell_dist_name} is ${Phy_Cell_id}    console=${P_console}

    RETURN     ${Phy_Cell_id}


Correlate Cell ID To Radio Module ID
    [Documentation]
    ...    | node_id    | Id/Number of Node (eNB|gNB) |
    ...    | node_type  | Node type; possible values: gNB or eNB |
    ...    | Cell_ID    | Id/Number of the  cell |
    ...    | Return:    | The Radio Module ID for the related Cell.    |

    [Arguments]   ${node_id}=${0}    ${node_type}=gnb    ${Cell_ID}=${1}

    ${node_type}    string.Convert To Lowercase     ${node_type}

    ${node_cell_to_rm_map}    gnb.Get Cell Radio Module Mapping    node_id=${node_id}    node_type=${node_type}

    IF   "${node_type}"=="gnb"
            ${cell_type}    Set Variable   NRCELL
    ELSE IF   "${node_type}"=="enb"
            ${cell_type}    Set Variable   LNCEL
    ELSE
            Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    END

    ${node_cell_Keys}    Collections.Get Dictionary Keys    ${node_cell_to_rm_map}    sort_keys=True
    ${bts_type}    String.Fetch From Left    ${node_cell_Keys}[0]    ${cell_type}
    ${cell_dist_name}    Set Variable    ${bts_type}${cell_type}-${Cell_ID}

    ${rmod_dist_name}    Set Variable    ${node_cell_to_rm_map}[${cell_dist_name}][0]
    ${rmod_id}=    Get Regexp Matches    ${rmod_dist_name}    \\d+$
    Log    [INFO]:${\n}Radio Module ID for ${cell_dist_name} is ${rmod_id}[0]    console=${P_console}

    RETURN     ${rmod_id}


Power Cycle Registered UE
    [Arguments]   ${ue_alias}
    [Documentation]
    ...     get serial number from registered UE
    ...     fetch PDU_Port with this info
    ...     reset pdu
    ...
    ...     | alias | UE alias from register_UE |

    ${serial}  taf.ue.Get Ue Info  ${ue_alias}  serial
    FOR  ${mobile}   IN  @{tl.ues}
      IF  "${mobile.serial_number}" == "${serial}"
        Log To Console  Powercycle PDU for UE ${serial}
        TRY
          testline.PDU Power Reset   ${mobile.pdu_port.pdu}   ${mobile.pdu_port.port_no}
        EXCEPT
          Log  PDU Power Reset wasn't possible!   level=WARN   console=${P_console}
        ELSE
          Log To Console  Powercycle UE PDU finished
        END
        BREAK
      END
    END
