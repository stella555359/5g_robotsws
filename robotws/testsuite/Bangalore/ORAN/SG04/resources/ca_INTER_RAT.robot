*** Settings ***
Documentation   ---SW Download & Update to NR and LTE BTS---
...			     :copyright: Nokia


Library           String
Library           Process
Library           Collections
Library           OperatingSystem
Library           XML  use_lxml=True


*** Keywords ***
Get BTS ID From ADMIN
    [Documentation]
    ...  This KW is used to get BTS ID from ADMIN.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com

    [Arguments]  ${alias}=default

    ${bts_obj} =  coam.Get parameters for all  LNBTS  connection=${alias}
#    ${bts_id} =  Convert To String  ${bts_obj[0].btsId}
#    [Return]  ${bts_id}
    log    ${bts_obj}
    @{lnbts}=    String.Split string    ${bts_obj[0].id}    -
    ${bts_id} =  Convert To String  ${LNBTS[-1]}
    [Return]  ${bts_id}

Get WCDMA Iub Interface Name
    [Documentation]
    ...  This KW returns the name of Iub network interface.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full description:**
    ...  This KW returns the name of Iub network interface reported in ifconfig command. It is used mainly
    ...  for collecting of WCDMA tcpdump. It uses runtime and configuration SCF to find the interface.
    ...  SCF should be saved under path: ${LOG_PATH}/misc_logs/SCF_full_YYYY-MM-DD_HH-MM-SS.xml
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${sctp_port_start}  ${sctp_port_stop}=  SCTP Port Start And Stop
    ...     ${iub_if_name} =  Get WCDMA Iub interface name
    ...     Start Wireshark Log Collection For IWK Test
    ...     ...  options=-i ${interface} -s 0 -W 1 -n portrange ${sctpport_start}-${sctpport_stop}
    ...     ...  alias=wcdma_tcpdump  replace_enb=False  replace_gnb=False

    [Arguments]  ${alias}=default

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_full_${timestamp}  export_type=configurationAndRuntimeObjects  alias=${alias}
    ${bts_obj}=         Get parameters for all  BTS  connection=${alias}
    ${var_exists}=      Run Keyword And Return Status  Variable should Exist  ${bts_obj[0].wcdmaCplaneIPv4}
    ${cplane_ip}=       Set Variable If  ${var_exists}  ${bts_obj[0].wcdmaCplaneIPv4}  ${bts_obj[0].wcdmaCplane}
    ${ipv4_dist_name} =  Get DistName Attribute From SCF  ${parsed_scf}  IPADDRESSV4  IPADDRESSV4
    ...  /p[@name='localIpAddr'][.='${cplane_ip}']/..
    ${ipif_dist_name}  ${_}=  Split String From Right  ${ipv4_dist_name}  separator=/  max_split=1
    ${vlan_dist_name} =  Get Parameter Value From SCF  ${parsed_scf}  IPIF  ${ipif_dist_name}
    ...  /p[@name='interfaceDN']  dist_name_substring=True
    ${vlan_id} =  Get Parameter Value From SCF  ${parsed_scf}  VLANIF  ${vlan_dist_name}
    ...  /p[@name='vlanId']  dist_name_substring=True
    ${interface_prefix} =  _chose wcdma interface based on hw  alias=${alias}
    [Return]  ${interface_prefix}.${vlan_id}


_chose wcdma interface based on hw

    [Arguments]  ${alias}=default

    ${hw_info} =  Get Detected HW Info  connection=${alias}
    ${smod_objects} =  Set Variable  ${hw_info['systemModules']}
    ${smods_count} =  Get Length  ${smod_objects}
    ${product_name} =  Run Keyword If  ${smods_count} > 1
    ...  Evaluate  [x['productName'] for x in @{smod_objects} if x['activeRole'] == 'Primary'][0]
    ...  ELSE IF   ${smods_count} == 1  Set Variable  ${smod_objects[0]['productName']}
    ...  ELSE  Log  Incorrect number of SMODS. Check SMOD_R in runtime SCF.  level=ERROR  console=True
    ${interface} =  Set Variable If  'FSMF' in '${product_name}'  eth3
    ...                              'ASIA' in '${product_name}'  br1
    ...                              'ASIL' in '${product_name}'  br0
    [Return]  ${interface}


SCTP Port Start And Stop
    [Documentation]
    ...  This KW returns the numbers of SCTP start and stop ports in WCDMA.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full description:**
    ...  This KW returns the numbers of SCTP start and stop ports in WCDMA. It is used mainly
    ...  for collecting of WCDMA tcpdump. It uses configuration SCF to find the SCTP ports.
    ...  SCF should be saved under path: ${LOG_PATH}/misc_logs/SCF_YYYY-MM-DD_HH-MM-SS.xml
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${sctp_port_start}  ${sctp_port_stop}=  SCTP Port Start And Stop
    ...     ${iub_if_name} =  Get WCDMA Iub interface name
    ...     Start Wireshark Log Collection For IWK Test
    ...     ...  options=-i ${interface} -s 0 -W 1 -n portrange ${sctpport_start}-${sctpport_stop}
    ...     ...  alias=wcdma_tcpdump  replace_enb=False  replace_gnb=False

    [Arguments]  ${alias}=default

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_${timestamp}  alias=${alias}
    ${sctpport_start} =  Get Parameter Value From SCF  ${parsed_scf}  WNBTS  WNBTS
    ...  /list[@name='cPlaneList']/item/p[@name='sctpPortMin']
    ${sctpport_stop}=   Evaluate  ${sctpport_start} + 2
    [Return]  ${sctpport_start}  ${sctpport_stop}


Put File Via SSH To Tshark VM
    [Documentation]  This KW is used to login into VM where 3G tshark is located and put tcpdump file on it.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------+------------+---------------------------------------------+
    ...  | Parameter  | Mandatory? | Description                                 |
    ...  +============+============+=============================================+
    ...  | tshark_ip  | Yes        | IP of VM with tshark                        |
    ...  +------------+------------+---------------------------------------------+
    ...  | user       | Yes        | Username used for connecting with tshark VM |
    ...  +------------+------------+---------------------------------------------+
    ...  | password   | Yes        | Password used for connecting with tshark VM |
    ...  +------------+------------+---------------------------------------------+
    ...  | put_src    | Yes        | File source path                            |
    ...  +------------+------------+---------------------------------------------+
    ...  | put_dest   | Yes        | Destination file path on tshark VM          |
    ...  +------------+------------+---------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Put File Via SSH To Tshark VM  111.111.111.111  abc  xyz
    ...     ...  /home/ute/btsauto/logs/BTSFiles/capture.cap  /home/ute/IubLogs/SBTS_123_capture.cap

    [Arguments]  ${tshark_ip}  ${user}  ${password}  ${put_src}  ${put_dest}

    SSHLibrary.Open Connection  host=${tshark_ip}  alias=tshark_vm
    SSHLibrary.Login  username=${user}  password=${password}
    SSHLibrary.Put File  source=${put_src}  destination=${put_dest}
    SSHLibrary.File Should Exist  ${put_dest}


Save OMS WCELs Configuration
    [Documentation]
    ...  This KW saves original configuration of OMS WCEL objects.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | This KW creates dictionary that contains: keys-WCDMA cell ids and
    ...  | values-dictionary with OMS WCEL data for each cell. Each OMS WCEL data dictionary contains:
    ...  | keys-OMS parameter names and values-OMS parameter values.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                          |
    ...  +================+======+======================================================================+
    ...  | cell_list      | Yes  | List of cells that need to have their OMS WCEL configuration saved.  |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | oms_names      | Yes  | Names of OMS WCEL Parameters that should be saved.                   |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${wcels_orig_conf} =  Save OMS WCELs Configuration  cell_list=['31712', '31715', '31716']
    ...     oms_names=['AdminPICState']

    [Arguments]  ${cell_list}  ${oms_names}

    Log  Saving OMS WCEL configuration. This may take a while...  console=True
    ${wcels_orig_conf} =  Create Dictionary
    FOR  ${cell_id}  IN  @{cell_list}
        ${wcels_orig_conf} =  create OMS configuration list for one cell  ${cell_id}  ${oms_names}  ${wcels_orig_conf}
    END
    Log  Original configuration for cells ${cell_list} saved.  console=True

    [Return]  ${wcels_orig_conf}


_create OMS configuration list for one cell
    [Documentation]
    ...  This KW appends cell id (key) and WCEL parameters needing change (values) to dictionary.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  |
    ...  | This KW creates OMS WCEL data dictionary which contains: cell id as key and dictionary of OMS WCEL
    ...  | values that need change. That dictionary contains keys-OMS parameter names and values-OMS parameter
    ...  | values.
    ...  | This KW requires 'WBTS_ID' to be set as global. This parameter is equal to ID of WBTS object on OMS
    ...  | that contains WCEL objects which parameters needs to be saved.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+----------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                          |
    ...  +=====================+======+======================================================================+
    ...  | cell_id             | Yes  | Cell ID of cell that needs to have its WCEL configuration saved.     |
    ...  +---------------------+------+----------------------------------------------------------------------+
    ...  | oms_names           | Yes  | Names of OMS WCEL parameters that should be saved.                   |
    ...  +---------------------+------+----------------------------------------------------------------------+
    ...  | oms_wcel_orig_conf  | Yes  | Dictionary with currently saved OMS WCEL data (or empty).            |
    ...  +---------------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${oms_wcel_orig_conf} =  create OMS configuration list for one cell  cell_id='31711'
    ...     oms_names=['AdminPICState']
    ...     ${oms_wcel_orig_conf} = {u'31712': {u'AdminPICState': '1'}, u'31715': {u'AdminPICState': '1'}}

    [Arguments]  ${cell_id}  ${oms_names}  ${oms_wcel_orig_conf}

    ${current_values_dict} =  Create Dictionary
    FOR  ${oms_name}  IN  @{oms_names}
        ${current_value} =  Get WCEL Parameter  ${WBTS_ID}  ${cell_id}  ${oms_name}
        Set To Dictionary  ${current_values_dict}  ${oms_name}=${current_value}
    END
    Sleep  5s
    ${oms_wcel_orig_conf} =  Set To Dictionary  ${oms_wcel_orig_conf}  ${cell_id}  ${current_values_dict}
    [Return]  ${oms_wcel_orig_conf}


Compare And Change OMS WCEL Parameters
    [Documentation]
    ...  This KW checks if OMS WCEL parameters given in 'oms_data' dictionary needs change and performs it.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+---------------------------------------------------------------------------+
    ...  | Parameter    | Man. | Description                                                               |
    ...  +==============+======+===========================================================================+
    ...  | cell_id      | Yes  | Cell ID of cell which needs change in OMS WCEL element.                   |
    ...  +--------------+------+---------------------------------------------------------------------------+
    ...  | oms_data     | Yes  | Dictionary with name and value of OMS WCEL parameter that needs change.   |
    ...  +--------------+------+---------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Compare And Change OMS WCEL Parameters  cell_id=31714  oms_data={'AdminPICState': '0'}

    [Arguments]  ${cell_id}  ${oms_data}

    ${oms_names} =  Get Dictionary Keys  ${oms_data}
    ${is_equal} =  Check If Current WCEL Params Have Desired Values  ${cell_id}  ${oms_data}  ${oms_names}
    Run Keyword If  ${is_equal}
    ...  Log  All parameters of cell=${cell_id} already had correct values. No changes were made.  console=True
    ...  ELSE  Change OMS WCEL Parameters  ${cell_id}  ${oms_data}


Compare And Change OMS WBTS Parameters
    [Documentation]
    ...  This KW is used to change parameters of WBTS objects in OMS Element Manager.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...
    ...  | This KW checks if OMS WBTS parameters given in 'oms_data' dictionary needs change and performs it through
    ...  | the nwi3 interface. Needed because attempting to change a parameter to the same value results in an error.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+---------------------------------------------------------------------------+
    ...  | Parameter    | Man. | Description                                                               |
    ...  +==============+======+===========================================================================+
    ...  | wbts_id      | Yes  | ID of WBTS object which needs change.                                     |
    ...  +--------------+------+---------------------------------------------------------------------------+
    ...  | oms_data     | Yes  | Dictionary with name and value of OMS WBTS parameter that needs change.   |
    ...  +--------------+------+---------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Compare And Change OMS WBTS Parameters  ${WBTS_ID}  {'AdminPICState': '0'}

    [Arguments]  ${wbts_id}  ${oms_data}

    ${oms_names} =  Get Dictionary Keys  ${oms_data}
    ${current_values_dict} =  Create Dictionary
    FOR  ${oms_param_name}  IN  @{oms_names}
        ${current_value} =  Get WBTS Parameter  ${wbts_id}  ${oms_param_name}
        Set To Dictionary  ${current_values_dict}  ${oms_param_name}=${current_value}
    END
    Sleep  5s
    Log  \nCurrent OMS values for WBTS ${wbts_id}: ${current_values_dict}  console=True
    ${is_equal} =  Run Keyword And Return Status  Should Be Equal  ${current_values_dict}  ${oms_data}
    Run Keyword If  ${is_equal}
    ...  Log  All parameters of WBTS ${wbts_id} already had correct values. No changes were made.  console=True
    ...  ELSE  Run keywords  Set WBTS Parameters  ${WBTS_ID}  &{oms_data}
    ...  AND  Log  WBTS ${wbts_id} should now have following parameter values: ${oms_data}  console=True


Check If Current WCEL Params Have Desired Values
    [Documentation]
    ...  This KW checks if OMS WCEL parameters given in 'oms_data' dictionary needs change.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  |
    ...  | This KW checks if OMS WCEL parameters given in 'oms_data' dictionary through
    ...  | NWI3 interface have desired values.
    ...  | This KW requires 'WBTS_ID' to be set as global. This parameter is equal to ID of WBTS object on OMS
    ...  | that contains WCEL objects which parameters needs to be checked.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+-------------------------------------------------------------------------------+
    ...  | Parameter    | Man. | Description                                                                   |
    ...  +==============+======+===============================================================================+
    ...  | cell_id      | Yes  | Cell ID of cell which needs change in OMS WCEL element.                       |
    ...  +--------------+------+-------------------------------------------------------------------------------+
    ...  | oms_data     | Yes  | Dictionary with name and value of changed OMS WCEL parameter.                 |
    ...  +--------------+------+-------------------------------------------------------------------------------+
    ...  | oms_names    | Yes  | List of OMS WCEL parameter names that need to be checked for specific cell.   |
    ...  +--------------+------+-------------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${is_equal} =  Check If Current WCEL Params Have Desired Values  cell_id=31714
    ...     oms_data={'AdminPICState': '0'}  oms_names=['AdminPICState']

    [Arguments]  ${cell_id}  ${oms_data}  ${oms_names}

    ${current_values_dict} =  Create Dictionary
    FOR  ${oms_name}  IN  @{oms_names}
        ${current_value} =  Get WCEL Parameter  ${WBTS_ID}  ${cell_id}  ${oms_name}
        Set To Dictionary  ${current_values_dict}  ${oms_name}=${current_value}
    END
    Sleep  5s
    Log  \nCurrent OMS values for cell=${cell_id}: ${current_values_dict}  console=True
    ${is_equal} =  Run Keyword And Return Status  Should Be Equal  ${current_values_dict}  ${oms_data}

    [Return]  ${is_equal}


Change OMS WCEL Parameters
    [Documentation]
    ...  This KW changes OMS WCEL parameters specified in 'oms_names'.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | This KW changes OMS WCEL parameters specified in 'oms_names'.
    ...  | Changes and verification of values is made through NWI3 interface.
    ...  | This KW requires 'WBTS_ID' to be set as global. This parameter is equal to ID of WBTS object on OMS
    ...  | that contains WCEL objects which parameters needs to be changed.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+-------------------------------------------------------------------------------+
    ...  | Parameter    | Man. | Description                                                                   |
    ...  +==============+======+===============================================================================+
    ...  | cell_id      | Yes  | Cell ID of cell which needs change in OMS WCEL element.                       |
    ...  +--------------+------+-------------------------------------------------------------------------------+
    ...  | oms_data     | Yes  | Dictionary with name and value of changed OMS WCEL parameter.                 |
    ...  +--------------+------+-------------------------------------------------------------------------------+
    ...  | oms_names    | Yes  | List of OMS WCEL parameter names that need change for specific cell.          |
    ...  +--------------+------+-------------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Change OMS WCEL Parameters  cell_id=31714  oms_data={'AdminPICState': '0'}  oms_names=['AdminPICState']

    [Arguments]  ${cell_id}  ${oms_data}

    Log  Changing OMS parameters for cell ${cell_id}. This may take a while...  console=True
    Set WCEL Parameters  ${WBTS_ID}  ${cell_id}  &{oms_data}
    Sleep  5s
    Log  Cell ${cell_id} should now have following parameter values: ${oms_data}  console=True


Restore OMS Original Configuration
    [Documentation]
    ...  This KW restores OMS configuration from dictionary of cells and OMS WCEL data.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | This KW restores OMS configuration from dictionary of cells and OMS WCEL data
    ...  | OMS WCEL data is dictionary of OMS WCEL parameter names and their respective values.
    ...  | This KW sets test restrictions on TC if configuration was not restored.
    ...  | This KW uses global variable 'WCELS_ORIG_CONF', please have it set in your TC.
    ...  | This variable can be obtained by using 'Save OMS WCELs Configuration', but it still needs
    ...  | to be set as global.
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Restore OMS Original Configuration

    Log  \nRestore OMS original configuration  console=True
    Should Not Be Empty  ${WCELS_ORIG_CONF}
    ...  msg=No data to restore configuration from. Restoring OMS original configuration failed. Please Restore OMS parameters manually.
    ${cell_ids} =  Get Dictionary Keys  ${WCELS_ORIG_CONF}
    FOR  ${cell_id}  IN  @{cell_ids}
        ${oms_data} =  Get From Dictionary  ${WCELS_ORIG_CONF}  ${cell_id}
        ${is_changed} =  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  3 x  2 min  Compare And Change OMS WCEL Parameters  ${cell_id}  ${oms_data}
        ${message}=  Catenate  Restoring OMS original configuration forcell ${cell_id} failed.Please Restore OMS parameters manually.
        ...  Take into consideration that next test case verdict may not be correct because of this.\n
        Run Keyword If  ${is_changed}  Log  Configuration restored for cell=${cell_id}\n  console=True
        ...  ELSE  Log  ${message}  console=True  level=WARN
    END


Send File To Remote VM And Count NBAP Failure Packets
    [Documentation]
    ...  This KW sends tcpdump file from BTS to remote VM and counts packets indicating NBAP failure
    ...  and verifies that there are no such packets.
    ...
    ...  | **Author:**  monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW sends tcpdump file from BTS to remote VM and counts packets indicating NBAP failure
    ...  | and verifies that there are no such packets. Filter used in this TC is created with
    ...  | 'Create Filter For Packets With Nbap Failure' KW and filters packets indicating NBAP failure.
    ...  | In teardown, the connection to tshark will be torn down if global variable ${TSHARK_RUNNING} is True.
    ...  | This KW sets global Variable 'WAIT_TIME' to 0. KW 'Send File To Remote VM And Verify It
    ...  | Is Not Corrupted' sets 'WAIT_TIME' to 5.
    ...
    ...  +-------------------+------+-------------------------------------------------------------------------------+
    ...  | Parameter         | Man. | Description                                                                   |
    ...  +===================+======+===============================================================================+
    ...  | capture_file_path | Yes  | Tcpdump FILE path on VM running test. Source path.                            |
    ...  +-------------------+------+-------------------------------------------------------------------------------+
    ...  | temp_file_path    | Yes  | Temporary FILE path on VM with 3G tshark. This is path for tcpdump file sent  |
    ...  |                   |      | from VM running test to VM with 3G tshark.                                    |
    ...  +-------------------+------+-------------------------------------------------------------------------------+

    [Arguments]  ${capture_file_path}  ${temp_file_path}  ${result_dest_dir}=${Test_Files}
    ...          ${source_filename}=capture.cap
    log    ${source_filename}
    log    ${result_dest_dir}
    Set Test Variable  ${WAIT_TIME}  0
    Wait Until Keyword Succeeds  2x  1min
    ...  Send File To Remote VM And Verify It Is Not Corrupted  ${capture_file_path}
    ...                                                         ${temp_file_path}
    ...                                                         ${result_dest_dir}

    ${nbap_failure_filter} =  Create Filter For Packets With Nbap Failure
    ${packet_count} =         Get Packets Count  packet_filter=${nbap_failure_filter}
    ...                                          pcap_file_path=${temp_file_path}
    ...                                          alias=${TESTLINE_NAME}_tshark

    Log  \nFAILURE PACKET COUNT:${packet_count}\n  console=True

    [Return]    ${packet_count}
    [Teardown]  Run Keyword If  ${TSHARK_RUNNING}  Run Keywords  Teardown Tshark  alias=${TESTLINE_NAME}_tshark
    ...                                            AND           Set Test Variable  ${TSHARK_RUNNING}  ${FALSE}


Connect With Tshark On Remote VM
    [Documentation]
    ...  This KW connects with tshark located on remote VM.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW sets up connection with tshark on remote VM. It also sets a global variable '${TSHARK_RUNNING}'
    ...  | which is useful for test teardowns. If '${TSHARK_RUNNING}' is equal to 'True' this KW will end
    ...  | without trying to setup tshark.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | Parameter    | Man. | Description                                                            |
    ...  +==============+======+========================================================================+
    ...  | vm_ip        | Yes  | IP of VM with tshark                                                   |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | user         | Yes  | Username used for connecting with tshark VM                            |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | password     | Yes  | Password used for connecting with tshark VM                            |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | source_path  | Yes  | FILE source path on tshark VM                                          |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...  | tshark_dir   | No   | Directory containing tshark on tshark VM. Default is set to '/usr/bin' |
    ...  +--------------+------+------------------------------------------------------------------------+
    ...
    ...  | **Example:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Connect With Tshark On Remote VM  vm_ip='111.111.111.111'  user='abc'  password='xyz'
    ...     source_path='/home/ute/IubLogs/SBTS_123_capture.cap'  tshark_dir='/usr/bin'

    [Arguments]  ${vm_ip}  ${user}  ${password}  ${source_path}  ${tshark_dir}=/usr/bin

    ${var} =  Run Keyword And Return Status  Variable Should Exist  ${TSHARK_RUNNING}
    Run Keyword If  ${var}  Return From Keyword If  ${TSHARK_RUNNING}

    ${source_file}  ${source_dir} =  Split String From Right  ${source_path}  separator=/  max_split=1
    ${tshark_running} =              Run Keyword And Return Status  Setup Tshark  interface=eth0  log_dir=${source_dir}
    ...                              log_name=${source_file}  tshark_dir=${tshark_dir}  ssh_ip=${vm_ip}
    ...                              ssh_username=${user}  password=${password}  alias=${TESTLINE_NAME}_tshark
    Set Test Variable   ${TSHARK_RUNNING}  ${tshark_running}
    Run Keyword Unless  ${TSHARK_RUNNING}  Fail  'Setup Tshark' keyword failed


Create Filter For Packets With Nbap Failure
    [Documentation]
    ...  This KW creates display filter for 3G tshark.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates display filter for 3G tshark. Packets received
    ...  | as the result of using this filter are the ones indicating that a failure
    ...  | in NBAP has occured.

    ${nbap_failure_filter} =  Catenate  SEPARATOR=||
    ...  nbap.AuditFailure_element
    ...  nbap.BlockResourceFailure_element
    ...  nbap.CellReconfigurationFailure_element
    ...  nbap.CellSetupFailure_element
    ...  nbap.CommonMeasurementFailureIndication_element
    ...  nbap.CommonMeasurementInitiationFailure_element
    ...  nbap.CommonTransportChannelReconfigurationFailure_element
    ...  nbap.CommonTransportChannelSetupFailure_element
    ...  nbap.DedicatedMeasurementFailureIndication_element
    ...  nbap.DedicatedMeasurementInitiationFailure_element
    ...  nbap.InformationExchangeFailureIndication_element
    ...  nbap.InformationExchangeInitiationFailure_element
    ...  nbap.PhysicalSharedChannelReconfigurationFailure_element
    ...  nbap.RadioLinkAdditionFailureFDD_element
    ...  nbap.RadioLinkFailureIndication_element
    ...  nbap.RadioLinkReconfigurationFailure_element
    ...  nbap.RadioLinkSetupFailureFDD_element
    ...  nbap.SystemInformationUpdateFailure_element
    ...  rrc.activeSetUpdateFailure_element
    ...  rrc.handoverFromUTRANFailure_element
    ...  rrc.measurementControlFailure_element
    ...  rrc.physicalChannelFailure_element
    ...  rrc.physicalChannelReconfigurationFailure_element
    ...  rrc.radioBearerReconfigurationFailure_element
    ...  rrc.radioBearerReconfigurationFailure_element
    ...  rrc.radioBearerSetupFailure_element
    ...  rrc.securityModeFailure_element
    ...  rrc.transportChannelReconfigurationFailure_element
    ...  rrc.transportFormatCombinationControlFailure_element
    ...  rrc.utranMobilityInformationFailure_element
    ...  rrc.cellChangeOrderFromUTRANFailure
    ...  rrc.failureCause
    ...  rrc.rrc_FailureInfo
    [Return]  ${nbap_failure_filter}


Send File To Remote VM And Verify It Is Not Corrupted
    [Documentation]
    ...  This KW sends tcpdump file to remote VM and verifies if there is no problem with opening it.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW downloads and sends tcpdump file to remote VM and verifies if there is no
    ...  | problem with opening it. It does not convert the file in any way on remote VM
    ...  | only opens and tries to read it.
    ...  | Global Variable 'TCPDUMP_DOWNLOADED' is set to 'True' by this KW after downloading file
    ...  | from BTS. This KW also sets global variable 'WAIT_TIME' to 5.
    ...  | Remove file from remote VM after using this KW. This KW uses 'File Should Exist' KW
    ...  | from 'OperatingSystem' library.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+--------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                  |
    ...  +=====================+======+==============================================================+
    ...  | capture_file_path   | Yes  | Tcpdump FILE path on VM running test. Source path.           |
    ...  +---------------------+------+--------------------------------------------------------------+
    ...  | temp_file_path      | Yes  | Temporary FILE path on VM with 3G tshark. This is path       |
    ...  |                     |      | for tcpdump file sent from VM running test to VM             |
    ...  |                     |      | with 3G tshark.                                              |
    ...  +---------------------+------+--------------------------------------------------------------+
    ...  | result_dest_dir     | No   | Destination DIRECTORY for parsed files on VM running test.   |
    ...  |                     |      | Result path.                                                 |
    ...  +---------------------+------+--------------------------------------------------------------+
    ...
    ...  | **Example:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Send File To Remote VM And Verify It Is Not Corrupted  capture_file_path=${BTSFiles}/capture.cap
    ...     ...  temp_file_path=/home/ute/IubLogs/${TESTLINE_NAME}_capture.cap

    [Arguments]  ${capture_file_path}  ${temp_file_path}  ${result_dest_dir}=${Test_Files}
	log    ${result_dest_dir}
    Log  Sending file to remote VM and verifying it is not corrupted...  console=True

    ${file_name} =   Fetch From Right  ${capture_file_path}  marker=/
    ca_INTER_RAT.Get File From BTS  path_to_bts_file=/tmp/  filename=${file_name}  destination=${BTSFiles}/
    Set Test Variable  ${TCPDUMP_DOWNLOADED}   ${TRUE}
    OperatingSystem.File Should Exist  ${capture_file_path}    msg=File ${capture_file_path} does not exist.

    Sleep  ${WAIT_TIME}min  reason=Waiting for file transfer completion...
    Set Test Variable  ${WAIT_TIME}  5

    Put File Via SSH To Tshark VM     ${TSHARK_3G_CONNECTION_PARAMS['ip']}
    ...                               ${TSHARK_3G_CONNECTION_PARAMS['user']}
    ...                               ${TSHARK_3G_CONNECTION_PARAMS['password']}
    ...                               ${capture_file_path}
    ...                               ${temp_file_path}
    Connect With Tshark On Remote VM  ${TSHARK_3G_CONNECTION_PARAMS['ip']}
    ...                               ${TSHARK_3G_CONNECTION_PARAMS['user']}
    ...                               ${TSHARK_3G_CONNECTION_PARAMS['password']}
    ...                               ${temp_file_path}
    Read Pcap  packet_filter=nbap  output_type=pdml  pcap_file_path=${temp_file_path}  alias=${TESTLINE_NAME}_tshark


Convert Dist Name To ID
    [Documentation]
    ...  This KW converts dist name to ID.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW converts dist name passed in 'dist_name' variable to ID. The ID needs to be after
    ...  | last '/' of dist name. Part of dist name after last '/' which is not needed (is not ID)
    ...  | will be removed.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------+------+----------------------------------------------+
    ...  | Parameter             | Man. | Description                                  |
    ...  +=======================+======+==============================================+
    ...  | dist_name             | Yes  | Dist name from which ID will be retrieved.   |
    ...  +-----------------------+------+----------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${id} =  Convert Dist Name To ID  MRBTS-11111/WNBTS-1/WNCEL-12301

    [Arguments]  ${dist_name}

    ${string_dist_name} =  Convert To String  ${dist_name}
    ${path}  ${id} =  Split String From Right  ${string_dist_name}  separator=-  max_split=1

    [Return]  ${id}


Get LTE E-UTRAN Cell ID based on Global Cell ID
    [Documentation]
    ...  This KW returns the E-UTRAN Cell ID of an LTE cell based on given Global Cell ID using ADMIN.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------+------------+--------------------------------+
    ...  | Parameter       | Mandatory? | Description                    |
    ...  +=================+============+================================+
    ...  | global_cell_id  | Yes        | Global Cell ID of an LTE cell  |
    ...  +-----------------+------------+--------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...
    ...     ${e-utran_cell_id}=  Get LTE Global Cell ID based on E-UTRAN Cell ID  22947
    ...     ute_ue.Validate UE Info  LTE_UE  CELL_ID  ${e-utran_cell_id}

    [Arguments]  ${global_cell_id}  ${connection}=default

    ${lte_cells} =  Get Cells Info  lte  connection=${connection}
    ${eutran_cell_id} =  Evaluate  [x['eutranCellId'] for x in ${lte_cells} if ${global_cell_id} == x['globalCellId']]
    ${eutran_cell_id} =  Set Variable If  ${eutran_cell_id}  ${eutran_cell_id[0]}  ${None}

    [Return]  ${eutran_cell_id}


Get NR Cell ID based on Global Cell ID
    [Documentation]
    ...  This KW returns the Cell ID of an NR cell based on given Global Cell ID using ADMIN.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------+------------+-----------------------------------------------+
    ...  | Parameter       | Mandatory? | Description                                   |
    ...  +=================+============+===============================================+
    ...  | global_cell_id  | Yes        | Global Cell ID of an NR cell.                 |
    ...  +-----------------+------------+-----------------------------------------------+
    ...  | connection      | No         | Name of admin connection. Default value: gNB  |
    ...  +-----------------+------------+-----------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...
    ...     ${e-utran_cell_id}=  Get NR Cell ID based on Global Cell ID  22947
    ...     ute_ue.Validate UE Info  NR_UE  CELL_ID  ${e-utran_cell_id}

    [Arguments]  ${global_cell_id}  ${connection}=gNB
    ${nr_cells} =  Get Parameters For All  NRCEL  connection=${connection}
    ${nr_cell_id} =  Evaluate  [x['nrCellIdentity'] for x in ${nr_cells} if ${global_cell_id} == x['configurationId']]
    ${nr_cell_id} =  Set Variable If  ${nr_cell_id}  ${nr_cell_id[0]}  ${None}

    [Return]  ${nr_cell_id}


_get relation errors list from recommissioning result
    [Documentation]
    ...  This KW returns relation errors dictionary form recommissioning result.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------------+------+-----------------------------------------------------+
    ...  | Parameter               | Man. | Description                                         |
    ...  +=========================+======+=====================================================+
    ...  | recommissioning_result  | Yes  | Result returned by 'Perform Delta Recommissioning'  |
    ...  |                         |      | KW. It contains dictionary with relation errors.    |
    ...  +-------------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...     ${recommissioning_result} =  Perform Delta Recommissioning  delta_file=delta
    ...     ...                          skip_parameter_relation_errors=True
    ...     ...                          should_activate=False
    ...     ...                          timeout=600
    ...     ${relationErrors} =  get relation errors list from recommissioning result  ${recommissioning_result}

    [Arguments]  ${recommissioning_result}
    Run Keyword And Return  Set Variable  ${recommissioning_result['validationResult']['pdlValidationResult']['logs']['relationErrors']}


_validation check for incorrect delta
    [Documentation]
    ...  This KW performs validation of delta which should return relation error
    ...  passed in 'regexp_match' variable.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | relation_errors  | Yes  | Dictionary containing relation errors returned      |
    ...  |                  |      | after performing delta recommissioning.             |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | regexp_match     | Yes  | Regexp string that should match one of relation     |
    ...  |                  |      | errors in 'relation_errors' dictionary.             |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | delta_dict       | Yes  | Dictionary containing parameter names (as keys)     |
    ...  |                  |      | and their values (as values).                       |
    ...  +------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${recommissioning_result} =  Perform Delta Recommissioning  delta_file=delta
    ...     ...                          skip_parameter_relation_errors=True
    ...     ...                          should_activate=False
    ...     ${relation_errors} =  get relation errors list from recommissioning result  ${recommissioning_result}
    ...     ${error} =            Set Variable  LCELL-\\d+.actDynamicSharedSpectrum (value: true)
    ...     ${regexp_match} =     escape special characters in string  ${error}
    ...     ${sector_id} =        _validation check for incorrect delta  ${relation_errors}  ${regexp_match}

    [Arguments]  ${relation_errors}  ${regexp_match}  ${delta_dict}

    Log  validation check for incorrect delta  console=True

    Should Not Be Empty  ${relation_errors}  msg=There were no relation errors.
    ${regexp_found} =  search for regexp match in relation errors dictionary
    ...                    ${relation_errors}  ${regexp_match}

    Should Be True  ${regexp_found}
    ...  msg=Validation for incorrect delta with parameters: ${delta_dict} did not pass. There was no regular expressions match found.
    Log  Validation check for incorrect delta with parameters: ${delta_dict} was successful.  console=True


_search for regexp match in relation errors dictionary
    [Documentation]
    ...  This KW searches for regexp match in relation errors dictionary.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW prepares delta for recommissioning and performs validation check
    ...  | for relation error passed in 'error' variable. If this KW is called multiple times
    ...  | alarm: faultId=4340 'Previously downloaded plan was overwritten' will appear.
    ...  | This KW returns 'True' if regexp match was found.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------------+------+-----------------------------------------------------+
    ...  | Parameter                | Man. | Description                                         |
    ...  +==========================+======+=====================================================+
    ...  | relation_errors          | Yes  | Dctionary containing relation errors.               |
    ...  +--------------------------+------+-----------------------------------------------------+
    ...  | regexp_match             | Yes  | Regular expression string that will be matched      |
    ...  |                          |      | with regular expressions.                           |
    ...  +--------------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${recommissioning_result} =  Perform Delta Recommissioning  delta_file=delta
    ...     ...                          skip_parameter_relation_errors=True
    ...     ...                          should_activate=False
    ...     ...                          timeout=600
    ...     ${relation_errors} =  Get Relation Errors List From Recommissioning Result  ${recommissioning_result}
    ...     ${error} =            Set Variable  LCELL-\\d+.actDynamicSharedSpectrum (value: true)
    ...     ${regexp_match} =     Escape Special Characters in String  ${error}
    ...     ${result} =           search for regexp match in relation errors dictionary  ${relation_errors}  ${regexp_match}

    [Arguments]  ${relation_errors}  ${regexp_match}

    ${result} =  Set Variable  False
    FOR  ${error_dict}  IN  @{relation_errors}
       ${feedback} =  Set Variable  ${error_dict['feedback']}
       ${regexp_found} =      Run Keyword And Return Status  Should Match Regexp
       ...                    ${feedback}
       ...                    ${regexp_match}
       Run Keyword If  ${regexp_found}
       ...        Log  \nFound regexp match. \nRelation error:${feedback}  console=True
       ...  ELSE  Log  \nAdditional relation error appeared: \n${feedback}.
       ${result} =  Set Variable If  ${regexp_found}  True  ${result}
    END

    [Return]  ${result}


AT serial write
    [Documentation]
    ...  This KW is used to send a message using AT protocol.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW is used to simply send a message using AT protocol to a device connected to the UE PC, without
    ...  | checking the response.
    ...  | For this KW to work, an SSH connection to the UE PC must be open.
    ...
    ...  **Input parameters:**
    ...
    ...  +-----------------+------------+----------------------------------------------------------+
    ...  | Parameter       | Mandatory? | Description                                              |
    ...  +-----------------+------------+----------------------------------------------------------+
    ...  | command         | Yes        | AT command to be written to the device, case insensitive |
    ...  +-----------------+------------+----------------------------------------------------------+
    ...  | uepc_ssh_alias  | No         | Alias of open connection to the UE PC. Default: 'uepc'   |
    ...  +-----------------+------------+----------------------------------------------------------+

    [Arguments]  ${command}  ${uepc_ssh_alias}=uepc

    ${previous_connection}=  SSHLibrary.Switch connection  ${uepc_ssh_alias}
    ${response}=  SSHLibrary.Execute command  python ${AT_SCRIPT_PATH} COM${UE_SERIAL_PORT} ${command}
    Log  ${command} response: ${response}  console=true
    SSHLibrary.Switch connection  ${previous_connection}

    [Return]  ${response}


AT serial write and verify response
    [Documentation]
    ...  This KW is used to send a message using AT protocol and verify that the response is the same as expected.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW is used to  send a message using AT protocol to a device connected to the UE PC, and verify that
    ...  | the response received is the same as expected.
    ...  | For this KW to work, an SSH connection to the UE PC must be open.
    ...
    ...  **Input parameters:**
    ...
    ...  +-------------------+------------+----------------------------------------------------------+
    ...  | Parameter         | Mandatory? | Description                                              |
    ...  +-------------------+------------+----------------------------------------------------------+
    ...  | command           | Yes        | AT command to be written to the device, case insensitive |
    ...  +-------------------+------------+----------------------------------------------------------+
    ...  | expected_response | Yes        | Expected response from the AT command                    |
    ...  +-------------------+------------+----------------------------------------------------------+
    ...  | uepc_ssh_alias    | No         | Alias of open connection to the UE PC. Default: 'uepc'   |
    ...  +-------------------+------------+----------------------------------------------------------+

    [Arguments]  ${command}  ${expected_response}  ${uepc_ssh_alias}=uepc

    ${previous_connection}=  SSHLibrary.Switch connection  ${uepc_ssh_alias}
    ${response}=  AT serial write  ${command}
    Should match  ${response}  ${expected_response}\r
    ...  Response '${response}' was different than expected response '${expected_response}'.${\n}
    SSHLibrary.Switch connection  ${previous_connection}


Change Administrative State Of Timeslots For TRXes
    [Documentation]
    ...  This KW locks or unlocks timeslots of TRXes in GSM sector.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW locks or unlocks timeslots passed as a list or integer in 'channels' variable
    ...  | for all TRXes passed in 'trxes' variable. The change is made for one sector using
    ...  | 'ZERS' command. This KW requires active BSC connection.
    ...  | If 'range' variable is set to 'True' then timeslots passed in 'channels' variable
    ...  | are treated as beginning and end of range, so it should only contain 2 elements.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------+------+---------------------------------------------------------+
    ...  | Parameter         | Man. | Description                                             |
    ...  +===================+======+=========================================================+
    ...  | sector_id         | Yes  | ID of GSM BTS (sector).                                 |
    ...  +-------------------+------+---------------------------------------------------------+
    ...  | trxes             | Yes  | List or integer containing IDs of TRXes which should    |
    ...  |                   |      | have their timeslots locked or unlocked.                |
    ...  +-------------------+------+---------------------------------------------------------+
    ...  | channels          | Yes  | List or integer containing IDs of timeslots which       |
    ...  |                   |      | should be locked or unlocked by this KW.                |
    ...  +-------------------+------+---------------------------------------------------------+
    ...  | operation         | Yes  | Name of operation. Possible values: lock, unlock.       |
    ...  +-------------------+------+---------------------------------------------------------+
    ...  | channels_as_range | No   | Specifies if channels are passed as range               |
    ...  |                   |      | or individual channels. If this is set to 'True'        |
    ...  |                   |      | 'channels' variable should contain exactly 2 elements.  |
    ...  +-------------------+------+---------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ca_INTER_RAT.Open session to BSC
    ...     ${trxes} =  Create List  1  2  3
    ...     ${channels} =  Create List  1  2
    ...     Change Administrative State Of Timeslots For TRXes  111  ${trxes}  ${channels}  lock  True

    [Arguments]  ${sector_id}  ${trxes}  ${channels}  ${operation}  ${channels_as_range}=False

    Log  Change Administrative State Of Timeslots For TRXes - ${operation}  console=True
    Should Be True  ${channels} and ${trxes} and ${sector_id}  msg=One of required IDs is missing or list is empty.
    Return From Keyword If  not (${channels} and ${trxes} and ${sector_id})

    ${channels}=  Run Keyword If  type(${channels}) is list  Set Variable  ${channels}
    ...           ELSE  Create List  ${channels}
    ${trxes}=     Run Keyword If  type(${trxes}) is list  Set Variable  ${trxes}
    ...           ELSE  Create List  ${trxes}

    ${length} =   Get Length  ${channels}
    ${channel_range} =  Run Keyword If  ${channels_as_range} and ${length} == 2
    ...                                                 Set Variable  ${channels[0]}&&${channels[1]}
    ...                 ELSE IF         ${length} <= 0  Fail  No timeslots were passed in 'channels' variable.
    ...                 ELSE IF         ${length} == 1  Set Variable  ${channels[0]}
    ...                 ELSE IF         ${length} >= 2  Catenate  SEPARATOR=&  @{channels}

    ${administrative_state} =  Set Variable If
    ...                        '${operation.lower()}' == 'unlock'  U
    ...                        '${operation.lower()}' == 'lock'    L

    FOR  ${trx_id}  IN  @{trxes}
        Log  ${operation}ing timeslots ${channel_range} for TRx ${trx_id}  console=True
        hran_bsc.Write  ZERS:BTS=${sector_id},TRX=${trx_id},CH=${channel_range}:${administrative_state};
        hran_bsc.Read Until  ZERS:BTS=${sector_id},TRX=${trx_id},CH=${channel_range}:${administrative_state};  10s
        hran_bsc.Read Until  COMMAND EXECUTED  10s
        Check If Specified Timeslots Changed Their Administrative State  ${sector_id}
        ...                                                              ${trx_id}
        ...                                                              ${channels}
        ...                                                              ${operation.lower()}
        ...                                                              channels_as_range=True
    END


Check If Specified Timeslots Changed Their Administrative State
    [Documentation]
    ...  This KW checks if specified timeslots were locked or unlocked.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW checks if specified timeslots were locked or unlocked. This KW requires
    ...  | active BSC connection. It is checked if all operational states of passed channels
    ...  | are equal to 'BL-USR' for operation 'lock or 'WO' for operation 'unlock'.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------+------+---------------------------------------------------------+
    ...  | Parameter         | Man. | Description                                             |
    ...  +===================+======+=========================================================+
    ...  | sector_id         | Yes  | ID of GSM BTS (sector).                                 |
    ...  +-------------------+------+---------------------------------------------------------+
    ...  | trx_id            | Yes  | ID of TRX.                                              |
    ...  +-------------------+------+---------------------------------------------------------+
    ...  | channels          | Yes  | List containing IDs of timeslots which should           |
    ...  |                   |      | be unlocked.                                            |
    ...  +-------------------+------+---------------------------------------------------------+
    ...  | operation         | Yes  | Name of operation. Possible values: lock, unlock.       |
    ...  +-------------------+------+---------------------------------------------------------+
    ...  | channels_as_range | No   | Specifies if channels are passed as range               |
    ...  |                   |      | or individual channels. If this is set to 'True'        |
    ...  |                   |      | 'channels' variable should contain exactly 2 elements.  |
    ...  +-------------------+------+---------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ca_INTER_RAT.Open session to BSC
    ...     ${channels} =  Create List  1  2  7
    ...     Check If Specified Timeslots Changed Their Administrative State  111  1  ${channels}

   [Arguments]  ${sector_id}  ${trx_id}  ${channels}  ${operation}  ${channels_as_range}=False

   Log  Check if specified timeslots were ${operation}ed  console=True
   Should Be True  ${channels} and ${trx_id} and ${sector_id}  msg=One of required IDs is missing or list is empty.
   Return From Keyword If  not (${channels} and ${trx_id} and ${sector_id})

   ${states_dict} =  Get Administrative State Of Timeslots  ${sector_id}  ${trx_id}  ${channels}
   ...                                                      channels_as_range=${channels_as_range}
   ${states_list} =  Get Dictionary Values  ${states_dict}
   Run Keyword If  '${operation.lower()}' == 'unlock'  Remove Values From List  ${states_list}  UNLOCKED
   ...  ELSE IF    '${operation.lower()}' == 'lock'    Remove Values From List  ${states_list}  LOCKED
   Should Be Empty  ${states_list}  msg=Not All timeslots for BTS=${sector_id} in TRX=${trx_id} were ${operation}ed.
   Log  Channels had correct operational state.  console=True


Lock All Transport Channels For All Dedicated TRXes
    [Documentation]
    ...  This KW locks all transport channels for all dedicated TRXes.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW locks all transport channels for all dedicated TRXes.
    ...  | It locks timeslots 2-7 for BCCH TRX and timeslots 0-7 for other dedicated TRXes.
    ...  | This KW requires active BSC connection to work properly.
    ...  | In this keyword 'TIMESLOTS_FOR_UNLOCKING_DICT' global variable is created
    ...  | to hold sector ID, TRX IDs and timeslot IDs of timeslots that should be locked
    ...  | by this KW.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+---------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                             |
    ...  +==================+======+=========================================================+
    ...  | sector_id        | Yes  | ID of GSM BTS (sector).                                 |
    ...  +------------------+------+---------------------------------------------------------+
    ...  | connection       | No   | Alias for admin connection to check GSM sector          |
    ...  |                  |      | state after unlocking. Default value: default.          |
    ...  +------------------+------+---------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ca_INTER_RAT.Open session to BSC
    ...     Lock All Transport Channels For All Dedicated TRXes  111

    [Arguments]  ${sector_id}  ${connection}=default

    Log  Lock All Transport Channels For All Dedicated TRXes  console=True
    Should Be True  ${sector_id}  msg=Required ID is missing.
    Return From Keyword If  not ${sector_id}
    ${sector_locked} =  Set Variable  False
    ${all_dedicated_trxes} =  Get TRXes Of Specified Type For GSM Cell  ${sector_id}  Dedicated
    save dedicated trxes that should be locked helper  ${sector_id}  ${all_dedicated_trxes}

    ${bcch_timeslots} =  Create List  2  7
    ${dedicated_trxes}  ${bcch_trx}=  Separate Dedicated TRXes From BCCH TRX
    ...                               ${sector_id}
    ...                               ${all_dedicated_trxes}
    ${timeslot_operational_state} =   Get Administrative State Of Timeslots
    ...                               ${sector_id}
    ...                               ${bcch_trx}
    ...                               ${bcch_timeslots}
    ...                               channels_as_range=True

    hran_bsc.Lock Sector  ${sector_id}
    ${sector_locked} =  Set Variable  True
    Change Administrative State Of Timeslots For TRXes  ${sector_id}
    ...                                                 ${bcch_trx}
    ...                                                 ${bcch_timeslots}
    ...                                                 lock
    ...                                                 True

    Run Keyword Unless          ${dedicated_trxes}  Log  There are no other dedicated TRXes, except the BCCH TRX.  console=True
    Run Keyword Unless          ${dedicated_trxes}  unlock gsm sector after changing timeslots states  ${sector_locked}  ${sector_id}
    ...                                             ${connection}
    Return From Keyword If  not ${dedicated_trxes}

    ${dedicated_timeslots} =  Create List  0  7
    ${timeslot_operational_state} =  Get Administrative State Of Timeslots
    ...                              ${sector_id}
    ...                              ${bcch_trx}
    ...                              ${dedicated_timeslots}
    ...                              channels_as_range=True
    Change Administrative State Of Timeslots For TRXes  ${sector_id}
    ...                                                 ${dedicated_trxes}
    ...                                                 ${dedicated_timeslots}
    ...                                                 lock
    ...                                                 True

    [Teardown]  unlock gsm sector after changing timeslots states  ${sector_locked}  ${sector_id}  ${connection}


_save dedicated trxes that should be locked helper
    [Arguments]  ${sector_id}  ${all_dedicated_trxes}

    Should Be True  ${sector_id} and ${all_dedicated_trxes}  msg=Required ID is missing or list is empty.
    Return From Keyword If  not ${sector_id} or not ${all_dedicated_trxes}

    ${timeslots_for_unlocking_defined} =  Run Keyword And Return Status
    ...  Variable Should Exist  ${TIMESLOTS_FOR_UNLOCKING_DICT}

    Run Keyword If  ${timeslots_for_unlocking_defined}
    ...             Set To Dictionary  ${TIMESLOTS_FOR_UNLOCKING_DICT}  ${sector_id}  ${all_dedicated_trxes}
    ${timeslots_dict} =  Run Keyword If  not ${timeslots_for_unlocking_defined}
    ...                                Create Dictionary  ${sector_id}  ${all_dedicated_trxes}
    Run Keyword If  ${timeslots_for_unlocking_defined}
    ...        Set Test Variable  ${TIMESLOTS_FOR_UNLOCKING_DICT}
    ...  ELSE  Set Test Variable  ${TIMESLOTS_FOR_UNLOCKING_DICT}  ${timeslots_dict}


Unlock All Transport Channels For All Dedicated TRXes
    [Documentation]
    ...  This KW unlocks all transport channels for all dedicated TRXes.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW unlocks all transport channels for all dedicated TRXes.
    ...  | It should unlock timeslots 2-7 for BCCH TRX and timeslots 0-7 for other dedicated TRXes,
    ...  | however if currently locked TRXes are different from those an error message will be printed
    ...  | and only the ones that have operational state 'BL-USR' will be unlocked.
    ...  | This KW requires active BSC connection to work properly.
    ...  | Detailed description: this KW separates BCCH TRX from dedicated TRXes. First it chceks if timeslots
    ...  | that currently have 'BL-USR' operational state are timeslots with IDs 2-7 for BCCH TRX,
    ...  | the timeslots are unlocked even if the locked timeslots are not the same, but an error message
    ...  | is printed. If there are no other dedicated TRXes, then this KW ends. If other dedicated TRXes
    ...  | exist then each of them has their timeslots checked to see if all of them (0-7)
    ...  | have 'BL_USR' operational state. If not all timeslots were locked, then unlocking also proceeds
    ...  | and an error message is printed. The TRXes that had correct timeslots locked will have them unlocked
    ...  | at the end of this KW.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------+------+---------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                             |
    ...  +=======================+======+=========================================================+
    ...  | sector_id             | Yes  | ID of GSM BTS (sector).                                 |
    ...  +-----------------------+------+---------------------------------------------------------+
    ...  | use_existing_trx_list | No   | Use list of dedicated TRXes for sector_id saved         |
    ...  |                       |      | in global dictionary 'TIMESLOTS_FOR_UNLOCKING_DICT'.    |
    ...  |                       |      | If this dictionary does not exist this KW will search   |
    ...  |                       |      | for dedicated timeslots on its own.                     |
    ...  +-----------------------+------+---------------------------------------------------------+
    ...  | connection            | No   | Alias for admin connection to check GSM sector          |
    ...  |                       |      | state after unlocking. Default value: default.          |
    ...  +-----------------------+------+---------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ca_INTER_RAT.Open session to BSC
    ...     Unlock All Transport Channels For All Dedicated TRXes  111

    [Arguments]  ${sector_id}  ${use_existing_trx_list}=False  ${connection}=default

    Log  Unlock All Transport Channels For All Dedicated TRXes  console=True

    ${sector_locked} =  Set Variable  False
    Should Be True  ${sector_id}  msg=Required ID is missing.
    Return From Keyword If  not ${sector_id}
    hran_bsc.Lock Sector  ${sector_id}
    ${timeslots_defined} =  Run Keyword And Return Status
    ...  Variable Should Exist  ${TIMESLOTS_FOR_UNLOCKING_DICT}

    ${all_dedicated_trxes} =  Run Keyword If  ${timeslots_defined} and ${use_existing_trx_list}
    ...                       Get From Dictionary  ${TIMESLOTS_FOR_UNLOCKING_DICT}  ${sector_id}
    ...  ELSE                 Get TRXes Of Specified Type For GSM Cell
    ...                       ${sector_id}
    ...                       Dedicated
    ${dedicated_trxes}  ${bcch_trx}=  Separate Dedicated TRXes From BCCH TRX
    ...                               ${sector_id}
    ...                               ${all_dedicated_trxes}

    ${timeslots} =         Evaluate  range(2, 8)
    ${locked_timeslots} =  Get Timeslots With Specified Administrative State
    ...                    ${sector_id}
    ...                    ${bcch_trx}
    ...                    LOCKED
    ${value}  ${msg}=      Run Keyword And Ignore Error
    ...                    Lists Should Be Equal
    ...                    ${timeslots}
    ...                    ${locked_timeslots}
    ...                    msg=Locked timeslots for BCCH TRX are different than expected.
    ...                    values=True
    Run Keyword If  '${value}' == 'FAIL'  Log  ${msg}  level=ERROR

    hran_bsc.Lock Sector  ${sector_id}
    ${sector_locked} =  Set Variable  True

    Run Keyword If  ${bcch_trx}
    ...  Change Administrative State Of Timeslots For TRXes  ${sector_id}
    ...                                                      ${bcch_trx}
    ...                                                      ${locked_timeslots}
    ...                                                      unlock
    ...                                                      True
    ...  ELSE  Log  Something went wrong. There is no BCCH TRX.  level=ERROR

    Run Keyword Unless          ${dedicated_trxes}  Log  There are no other dedicated TRXes, except the BCCH TRX.  console=True
    Run Keyword Unless          ${dedicated_trxes}  unlock gsm sector after changing timeslots states  ${sector_locked}  ${sector_id}
    ...                                             ${connection}
    Return From Keyword If  not ${dedicated_trxes}

    ${timeslots} =  Evaluate  range(0, 8)
    FOR  ${trx_id}  IN  @{dedicated_trxes}
        ${locked_timeslots} =  Get Timeslots With Specified Administrative State
        ...                    ${sector_id}
        ...                    ${trx_id}
        ...                    LOCKED
        ${value}  ${msg}=  Run Keyword And Ignore Error
        ...                Lists Should Be Equal
        ...                ${timeslots}
        ...                ${locked_timeslots}
        ...                msg=Locked timeslots for dedicated TRX are different than expected.
        ...                values=True
        Continue For Loop If  '${value}' == 'PASS'

        Log  TRX${trx_id}: ${msg}  console=True  level=ERROR
        Run Keyword Unless  ${locked_timeslots}
        ...  Change Administrative State Of Timeslots For TRXes  ${sector_id}
        ...                                                      ${trx_id}
        ...                                                      ${timeslots}
        ...                                                      unlock
        ...                                                      True
        Remove Values From List     ${dedicated_trxes}
        ...                         ${trx_id}
    END
    Run Keyword If  ${dedicated_trxes}  Change Administrative State Of Timeslots For TRXes
    ...                                 ${sector_id}
    ...                                 ${dedicated_trxes}
    ...                                 ${timeslots}
    ...                                 unlock
    ...                                 True

    [Teardown]  Run Keywords  Check If There Are Any Locked Timeslots For Sector  ${sector_id}  True  AND
    ...                       unlock gsm sector after changing timeslots states  ${sector_locked}  ${sector_id}  ${connection}


_unlock gsm sector after changing timeslots states
    [Arguments]  ${sector_locked}  ${sector_id}  ${connection}
    Run Keyword If  ${sector_locked}  hran_bsc.Unlock Sector  ${sector_id}
    ${gsm_cell_runtime_distname} =  Get Runtime Dist Name For GSM Sector  ${gsm_sector_id}  ${connection}

    ${gsm_online_states}=  Run Keyword If  ${CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked",
    ...                                           blockingState=regex"[Uu]nblocked"
    ...  ELSE               Catenate  SEPARATOR=  availabilityStatus=Online,
    ...                                           operationalState=Enabled,
    ...                                           administrativeState=Unlocked,
    ...                                           blockingState=Unblocked
    Wait Until Keyword Succeeds  4min  10s  _check gsm cell state helper  ${gsm_cell_runtime_distname}
    ...  ${gsm_online_states}  ${connection}
    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'PASS'
    ...  Log  Sector-${gsm_sector_id} is back On Air with timeslots mentioned above toggled!  console=True


Check If There Are Any Locked Timeslots For Sector
    [Documentation]
    ...  This KW checks if there are any locked timeslots in specified sector.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW checks if there are any locked timeslots in specified sector.
    ...  | It returns 'False' if there are no locked timeslots left in specified sector
    ...  | and 'True' if there are. It also returns dictionary with sector ID and TRX ID
    ...  | in following format: ${sector_id}_${trx_id} as keys
    ...  | and list of locked timeslots as values. This keyword may print a warning
    ...  | if there are any locked timeslots in specified sector if 'print_wrn' is set
    ...  | to 'True'.
    ...  | This KW requires active BSC connection.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+---------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                             |
    ...  +==================+======+=========================================================+
    ...  | sector_id        | Yes  | ID of GSM BTS (sector).                                 |
    ...  +------------------+------+---------------------------------------------------------+
    ...  | print_wrn        | No   | Boolean value specifying if warning message should      |
    ...  |                  |      | be printed in case there are any locked timeslots       |
    ...  |                  |      | in 'sector_id'.                                         |
    ...  +------------------+------+---------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ca_INTER_RAT.Open session to BSC
    ...     Check If There Are Any Locked Timeslots For Sector  111  True

    [Arguments]  ${sector_id}  ${print_wrn}=False

    Should Be True  ${sector_id}  msg=Required ID is missing.
    Return From Keyword If  not ${sector_id}

    ${trx_ids} =  hran_bsc.Get TRXs List By BTS ID  bts_id=${sector_id}  alias=${False}
    ${any_locked_timeslots_exist} =  Set Variable  ${FALSE}
    ${locked_timeslots_dict} =  Create Dictionary
    FOR  ${trx_id}  IN  @{trx_ids}
        ${locked_timeslots} =  Get Timeslots With Specified Administrative State
        ...                    ${sector_id}
        ...                    ${trx_id}
        ...                    LOCKED
        ${locked_timeslots_exist} =  Run Keyword And Return Status  Should Not Be Empty  ${locked_timeslots}
        ${any_locked_timeslots_exist} =  Set Variable If  ${locked_timeslots_exist}
        ...                              ${TRUE}
        ...                              ${any_locked_timeslots_exist}
        Set To Dictionary  ${locked_timeslots_dict}  ${sector_id}_${trx_id}=${locked_timeslots}
    END
    Run Keyword If  ${any_locked_timeslots_exist} and ${print_wrn}
    ...  Log  There are still some locked timeslots: ${locked_timeslots_dict}.  level=WARN
    [Return]  ${any_locked_timeslots_exist}  ${locked_timeslots_dict}


Separate Dedicated TRXes From BCCH TRX
    [Documentation]
    ...  This KW finds which TRX from passed list is BCCH TRX and returns its ID
    ...  and list of passed TRXes with removed BCCH TRX.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW searches for BCCH TRX in list passed in 'trxes' variable.
    ...  | It searches which TRX will have MBCCH in result of 'ZERO' command.
    ...  | It returns BCCH TRX ID and list of TRXes with BCCH TRX removed.
    ...  | If no BCCH TRX is found this KW will return 'None' as first value
    ...  | and 'trxes' list as second.
    ...  | This KW requires active BSC connection.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+---------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                             |
    ...  +==================+======+=========================================================+
    ...  | sector_id        | Yes  | ID of GSM BTS (sector).                                 |
    ...  +------------------+------+---------------------------------------------------------+
    ...  | dedicated_trxes  | Yes  | List containing IDs of all dedicated TRXes.             |
    ...  |                  |      | It should contain BCCH TRX.                             |
    ...  +------------------+------+---------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ca_INTER_RAT.Open session to BSC
    ...     ${trxes} =  Create List  1  2  3
    ...     Separate Dedicated TRXes From BCCH TRX  111  ${trxes}

    [Arguments]  ${sector_id}   ${trxes}

    Should Be True  ${trxes} and ${sector_id}  msg=Required ID is missing or list is empty.
    Return From Keyword If  not (${trxes} and ${sector_id})

    ${dedicated_trxes} =  Create List  @{trxes}
    FOR  ${trx_id}  IN  @{dedicated_trxes}
        ${transc_params} =  hran_bsc.Get Transceiver Parameters  ${sector_id}  ${trx_id}
        ${is_bcch_trx} =  Run Keyword And Return Status  Should Contain  ${transc_params}  MBCCH
        Continue For Loop If  not ${is_bcch_trx}
        ${bcch_trx} =  Set Variable  ${trx_id}
        Remove Values From List  ${dedicated_trxes}  ${bcch_trx}
        Return From Keyword  ${dedicated_trxes}  ${bcch_trx}
    END

    [Return]  None  ${trxes}


Turn Off GENA
    [Documentation]
    ...  This KW turns off GENA parameter for given GSM sector.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW turns off GPRS Enabled (GENA) parameter for given GSM sector.
    ...  | If GPRS is already disabled for specified sector this KW will not
    ...  | try to disable it again. This KW requires active BSC connection.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+---------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                             |
    ...  +==================+======+=========================================================+
    ...  | sector_id        | Yes  | ID of GSM BTS (sector).                                 |
    ...  +------------------+------+---------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ca_INTER_RAT.Open session to BSC
    ...     Turn Off GENA  111

    [Arguments]  ${sector_id}

    Should Be True  ${sector_id}  msg=Required ID is missing.
    Return From Keyword If  not ${sector_id}

    Log  Turn OFF GENA  console=True
    ${gprs_enabled} =  Check If GPRS Is Enabled In GSM Sector  ${sector_id}
    Run Keyword And Return If  not ${gprs_enabled}  Log  GPRS was already disabled.  console=True
    hran_bsc.Write  ZEQV:BTS=${sector_id}:GENA=N;
    hran_bsc.Read Until  COMMAND EXECUTED  10s
    ${gprs_enabled} =  Check If GPRS Is Enabled In GSM Sector  ${sector_id}
    Should Not Be True  ${gprs_enabled}  msg=GPRS was not disabled.
    Log  GPRS was turned OFF  console=True


Turn On GENA
    [Documentation]
    ...  This KW turns on GENA parameter for given GSM sector with specified RAC value.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW turns on GPRS Enabled (GENA) parameter for given GSM sector
    ...  | with specified Routing Area Code (RAC) value. It is also possibile
    ...  | to specify Network Service Entity Identifier (NSEI) with which it
    ...  | should be enabled. If GPRS is already enabled for specified sector
    ...  | this KW will not try to enable it again. This KW requires active BSC connection.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+---------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                             |
    ...  +==================+======+=========================================================+
    ...  | sector_id        | Yes  | ID of GSM BTS (sector).                                 |
    ...  +------------------+------+---------------------------------------------------------+
    ...  | rac              | Yes  | ID of Routing Area Code (RAC).                          |
    ...  +------------------+------+---------------------------------------------------------+
    ...  | nsei             | No   | ID of Network Service Entity Identifier (NSEI).         |
    ...  +------------------+------+---------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ca_INTER_RAT.Open session to BSC
    ...     Turn On GENA  111  1  208

    [Arguments]  ${sector_id}  ${rac}  ${nsei}=None

    Should Be True  ${rac} and ${sector_id}  msg=One of required IDs is missing.
    Return From Keyword If  not (${rac} and ${sector_id})

    Log  Turn ON GENA  console=True
    ${gprs_enabled} =  Check If GPRS Is Enabled In GSM Sector  ${sector_id}
    Run Keyword And Return If  ${gprs_enabled}  Log  GPRS was already enabled.  console=True
    ${bsc_command} =  Set Variable If  ${nsei}   ZEQV:BTS=${sector_id}:GENA=Y,RAC=${rac}:NSEI=${nsei};
    ...                                          ZEQV:BTS=${sector_id}:GENA=Y,RAC=${rac};
    hran_bsc.Write  ${bsc_command}
    hran_bsc.Read Until  COMMAND EXECUTED  10s
    ${gprs_enabled} =  Check If GPRS Is Enabled In GSM Sector  ${sector_id}
    Should Be True  ${gprs_enabled}  msg=GPRS was not enabled.
    Log  GPRS was turned ON  console=True

Check If GPRS Is Enabled In GSM Sector
    [Documentation]
    ...  This KW returns 'True' if GPRS is Enabled in given GSM sector and 'False' otherwise.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...  | **Full description:**
    ...  | This KW returns 'True' if GPRS is Enabled in given GSM sector and 'False' otherwise.
    ...  | It requires active BSC connection.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+---------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                             |
    ...  +==================+======+=========================================================+
    ...  | sector_id        | Yes  | ID of GSM BTS (sector).                                 |
    ...  +------------------+------+---------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ca_INTER_RAT.Open session to BSC
    ...     ${is_gena_enabled} =  Check If GPRS Is Enabled In GSM Sector  111

    [Arguments]  ${sector_id}

    Should Be True  ${sector_id}  msg=Required ID is missing.
    Return From Keyword If  not ${sector_id}
    ${gena_on} =  Get BTS Parameters  ${sector_id}  GPRS  GENA
    Run Keyword And Return  Evaluate  '${gena_on}' == 'Y'


Get Administrative State Of Timeslots
    [Documentation]
    ...  This KW gets administrative state of specified timeslot.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW gets administrative state of specified timeslots.
    ...  | It may accept integer or list of timeslots in 'channels' variable.
    ...  | It returns dictionary with timeslot ID and administrative state.
    ...  | This KW requires active BSC connection to work properly.
    ...  **Input Parameters:**
    ...
    ...  +-------------------+------+---------------------------------------------------------+
    ...  | Parameter         | Man. | Description                                             |
    ...  +===================+======+=========================================================+
    ...  | sector_id         | Yes  | ID of GSM BTS (sector).                                 |
    ...  +-------------------+------+---------------------------------------------------------+
    ...  | trx_id            | Yes  | ID of TRX.                                              |
    ...  +-------------------+------+---------------------------------------------------------+
    ...  | channel           | Yes  | List or integer containing timeslot ID(s).              |
    ...  +-------------------+------+---------------------------------------------------------+
    ...  | channels_as_range | No   | Specifies if channels are passed as range               |
    ...  |                   |      | or individual channels. If this is set to 'True'        |
    ...  |                   |      | 'channels' variable should contain exactly 2 elements.  |
    ...  +-------------------+------+---------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ca_INTER_RAT.Open session to BSC
    ...     ${channels} =  Create list  1  2  7
    ...     ${states_dict} =  Get Administrative State Of Timeslots  111  1  ${channels}

    [Arguments]  ${sector_id}  ${trx_id}  ${channels}  ${channels_as_range}=False

    Should Be True  ${trx_id} and ${channels} and ${sector_id}  msg=One of required IDs is missing or list is empty.
    Return From Keyword If  not (${trx_id} and ${channels} and ${sector_id})
    ${channels}=  Run Keyword If  type(${channels}) is list  Set Variable  ${channels}
    ...           ELSE                                       Create List  ${channels}
    ${length} =   Get Length  ${channels}
    ${channel_range} =  Run Keyword If  ${channels_as_range} and ${length} == 2
    ...                                                 Evaluate  range(${channels[0]}, ${channels[1]}+1)
    ...                 ELSE IF         ${length} <= 0  Fail  No timeslots were passed in 'channels' variable.
    ...                 ELSE IF         ${length} >= 1  Set Variable  ${channels}

    ${timeslots_dict} =  hran_bsc.Get Transceiver Data  ${sector_id}  ${trx_id}
    ${administrative_states} =  Get From Dictionary  ${timeslots_dict}  ADM.STATE
    ${states_dict} =  Create Dictionary
    FOR  ${channel}  IN  @{channels}
        ${channel} =  Convert To String  ${channel}
        Set To Dictionary  ${states_dict}  ${channel}=${administrative_states[${channel}]}
    END

    [Return]  ${states_dict}


Get Timeslots With Specified Administrative State
    [Documentation]
    ...  This KW gets timeslots with specified administrative state.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW gets administrative state of specified timeslots of a TRX.
    ...  | It returns list with timeslot IDs of timeslots that have administrative
    ...  | state equal to the one specified in 'state_abbreviation' variable.
    ...  | This KW requires active BSC connection to work properly.
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+---------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                             |
    ...  +========================+======+=========================================================+
    ...  | sector_id              | Yes  | ID of GSM BTS (sector).                                 |
    ...  +------------------------+------+---------------------------------------------------------+
    ...  | trx_id                 | Yes  | ID of TRX.                                              |
    ...  +------------------------+------+---------------------------------------------------------+
    ...  | state_abbreviation     | Yes  | Abbreviation of administrative state name, e.g. LOCKED, |
    ...  |                        |      | UNLOCKED                                                |
    ...  +------------------------+------+---------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ca_INTER_RAT.Open session to BSC
    ...     ${timeslots} =  Get Timeslots With Specified Administrative State  111  1  LOCKED

    [Arguments]  ${sector_id}  ${trx_id}  ${state_abbreviation}

    Should Be True  ${trx_id} and ${sector_id}  msg=One of required IDs is missing.
    Return From Keyword If  not (${trx_id} and ${sector_id})

    ${timeslots} =  Create List
    ${timeslots_dict} =  hran_bsc.Get Transceiver Data  ${sector_id}  ${trx_id}
    ${operational_states} =  Get From Dictionary  ${timeslots_dict}  ADM.STATE
    FOR  ${index}  ${state}  IN ENUMERATE  @{operational_states}
        Run Keyword If  '${state}' == '${state_abbreviation}'
        ...  Append To List  ${timeslots}  ${index}
    END

    [Return]  ${timeslots}


Check If GSM Call Is Performed On Shared TRx
    [Documentation]
    ...  This KW checks if GSM call is performed on shared TRX.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW checks if GSM call is performed on shared TRX. Verification
    ...  | is done by checking if 'FR' channel state appears expected number of times
    ...  | for any of the shared TRXes. For this KW to work feature RP002014 or RP001783
    ...  |  need to be active. This KW requires active BSC connection.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------------------+------+--------------------------------------------+
    ...  | Parameter                  | Man. | Description                                |
    ...  +============================+======+============================================+
    ...  | sector_id                  | Yes  | ID of GSM BTS (sector).                    |
    ...  +----------------------------+------+--------------------------------------------+
    ...  | expected_connections_count | No   | Defines how many times 'FR' should appear  |
    ...  |                            |      | for all shared TRXes. Default: 1.          |
    ...  +----------------------------+------+--------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ca_INTER_RAT.Open session to BSC
    ...     Check If GSM Call Is Performed On Shared TRx  111

    [Arguments]  ${sector_id}  ${expected_connections_count}=1

    Should Be True  ${sector_id}  msg=Required ID is missing.
    Return From Keyword If  not ${sector_id}

    ${shared_trxes} =  Get TRXes Of Specified Type For GSM Cell  ${sector_id}  Shared
    Return From Keyword If  not ${shared_trxes}

    ${all_channels_status} =  Create List
    FOR  ${trx_id}  IN  @{shared_trxes}
        ${timeslots_dict} =  hran_bsc.Get Transceiver Data  ${sector_id}  ${trx_id}
        ${all_channels_status} =  Combine Lists  ${all_channels_status}  ${timeslots_dict['CH.STATUS']}
    END

    Should Contain X Times  ${all_channels_status}  FR  ${expected_connections_count}
    ...  msg='FR' should appear ${expected_connections_count} time(s) for shared TRXes. The count is different.


Get TRX Frequency From BSC
    [Documentation]
    ...  This KW returns frequency of given TRX using BSC.
    ...
    ...  | **Author:** magdalena.kozdras@nokia.com
    ...  | **Maintainer:** tomasz.sobania@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------+------------+--------------------------------+
    ...  | Parameter       | Mandatory? | Description                    |
    ...  +-----------------+------------+--------------------------------+
    ...  | bcf_id          | Yes        | ID of BCF                      |
    ...  +-----------------+------------+--------------------------------+
    ...  | trx_id          | Yes        | ID of TRX                      |
    ...  +-----------------+------------+--------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${freq} =  Get TRX Frequency From BSC  1012  2

    [Arguments]  ${bcf_id}  ${trx_id}
    ${freq_regex} =  Set Variable  TRX-0{1,}${trx_id}\\s{1,}\\w\\s\\S{2,6}\\s{1,}\\d{1,4}
    hran_bsc.Write  ZEEI:BCF=${bcf_id};
    ${bsc_output} =  hran_bsc.Read Until  COMMAND EXECUTED  10s
    ${freq} =  Should Match Regexp  ${bsc_output}  ${freq_regex}
    ${freq} =  Fetch From Right  ${freq}  marker=${SPACE}
    [Return]  ${freq}


Verify If DSS Is Enabled - DSSE Parameter in BSC
    [Documentation]
    ...  This KW verifies if DSS feature is activated in BSC.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW verifies if DSS feature is activated in BSC. Sectors for which verification is performed
    ...  | are given in 'gsm_sector_ids'. This KW checks if parameter 'DSSE' has value '2 (DSS GSM+WCDMA)' for each
    ...  | GSM sector. If DSS is disabled in at least one sector this KW returns 'FALSE'. Please take note
    ...  | that an open BSC connection is required for this KW to work properly.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+----------------------+
    ...  | Parameter           | Man. | Description          |
    ...  +=====================+======+======================+
    ...  | gsm_sector_ids      | Yes  | IDs of GSM sectors.  |
    ...  +---------------------+------+----------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Connect To BSC  ${BSC['ip']}  ${BSC['user']}  ${BSC['password']}
    ...     ${_}  ${parsed_scf} =  Save And Parse SCF  scf_name=SCF_runtime  export_type=configurationAndRuntimeObjects
    ...     ${bcf_id} =  Get Parameter Value From SCF  ${parsed_scf}  GNBCF  GNBCF  /p[@name='bcfId']
    ...     ${gsm_sector_ids} =  Get Sectors IDs  ${bcf_id}  ${FALSE}
    ...     ${is_dss_enabled} =  Verify If DSS Is Enabled - DSSE Parameter in BSC  ${gsm_sector_ids}

    [Arguments]  ${gsm_sector_ids}  ${rats}=WG

    Log  Verify If DSS Is Enabled - DSSE Parameter in BSC  console=True
    ${is_dss_enabled} =  Set Variable  ${TRUE}
    ${dsse_print} =  Set Variable If
    ...        '${rats}' == 'WG'  2 (DSS GSM+WCDMA)
    ...        '${rats}' == 'LG'  1 (DSS GSM+LTE)

    FOR  ${gsm_sector_id}  IN  @{gsm_sector_ids}
        Should Not Be Equal As Strings  '${gsm_sector_id}'  ''  msg=Keyword failed due to lack of GSM cell ID.
        ${gsm_cell_dss_state} =  hran_bsc.Get BTS Parameters  ${gsm_sector_id}  MIS  DSSE
        Log  For BTS=${gsm_sector_id}: DSSE=${gsm_cell_dss_state}  console=True
        ${is_dss_enabled} =      Set Variable If  '${gsm_cell_dss_state}' == '${dsse_print}'
        ...                                        ${is_dss_enabled}
        ...                                        ${FALSE}
    END

    Run Keyword If  ${is_dss_enabled}  Log  DSS is enabled in BSC.  console=True

    [Return]  ${is_dss_enabled}


Verify If DSS Is Enabled In Given WCDMA Cells Using LCELW SCF Objects
    [Documentation]
    ...  This keyword is used to verify in SCF if DSS (RP002014) is enabled in WCDMA cells given by their IDs.
    ...  It uses configuration SCF for verification. SCF should be saved under path:
    ...  ${LOG_PATH}/misc_logs/SCF_YYYY-MM-DD_HH-MM-SS.xml
    ...
    ...  **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input parameters:**
    ...
    ...  +----------------+------------+------------------------------------------------+
    ...  | Parameter      | Mandatory? | Description                                    |
    ...  +----------------+------------+------------------------------------------------+
    ...  | wcdma_cell_ids | Yes        | List of WCDMA cell IDs for which               |
    ...  |                |            | the enabling of DSS feature will be verified   |
    ...  +----------------+------------+------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${lcelw_status} =  Verify If DSS Is Enabled In Given WCDMA Cells Using LCELW SCF Objects  ${wcdma_cell_ids}

    [Arguments]  ${wcdma_cell_ids}  ${alias}=default

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_${timestamp}  alias=${alias}

    ${wcels_with_dss_disabled}=  Create List
    FOR  ${wcdma_cell_id}  IN  @{wcdma_cell_ids}
        ${lcelw_dist_name} =  Get Parameter Value From SCF  ${parsed_scf}  WNCEL  WNCEL-${wcdma_cell_id}
        ...  /p[@name='lCelwDN']  dist_name_substring=True
        ${dss_enabled_in_wcel} =  Run Keyword And Return Status  Check If Element Exists In SCF  ${parsed_scf}
        ...  LCELW  LCELW
        ...  /p[@name='actDynamicSharedSpectrum'][.='true']/../p[@name='dynamicSharedSpectrumGsmCellDN'][.!='']
        Run Keyword Unless  ${dss_enabled_in_wcel}  Append To List  ${wcels_with_dss_disabled}  ${lcelw_dist_name}
    END
    Run Keyword If  ${wcels_with_dss_disabled}  Run Keywords
    ...  Log  DSS is not enabled in all requested WCDMA cells.\nDNs of alarming SCF objects: ${wcels_with_dss_disabled}  console=True
    ...  AND  Return From Keyword  False
    Log  DSS is enabled in cells ${wcdma_cell_ids}.  console=True

    [Return]  True


Verify If DSS Is Enabled In Given LTE Cells Using LCELL SCF Objects
    [Documentation]
    ...  This keyword is used to verify in SCF if DSS (RP001783) is enabled in LTE cells given by their IDs.
    ...
    ...  **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input parameters:**
    ...
    ...  +--------------+------------+----------------------------------------------+
    ...  | Parameter    | Mandatory? | Description                                  |
    ...  +--------------+------------+----------------------------------------------+
    ...  | lte_cell_ids | Yes        | List of LTE cell IDs for which               |
    ...  |              |            | the enabling of DSS feature will be verified |
    ...  +--------------+------------+----------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${lte_cell_ids}=  Get IDs Of LTE Cells Where LG DSS Is Enabled
    ...     ${lcell_status}=  Verify If DSS Is Enabled In Given LTE Cells Using LCELL SCF Objects  ${lte_cell_ids}
    [Arguments]  ${lte_cell_ids}  ${connection}=default

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_${timestamp}  alias=${connection}
    ${lcels_with_dss_disabled}=  Create List
    FOR  ${lte_cell_id}  IN  @{lte_cell_ids}
        ${lcell_id} =  Get Parameter Value From SCF  ${parsed_scf}  LNCEL  LNCEL-${lte_cell_id}
        ...  /p[@name='lcrId']  dist_name_substring=True
        ${dss_enabled_in_lcel} =  Run Keyword And Return Status  Check If Element Exists In SCF  ${parsed_scf}
        ...  LCELL  LCELL
        ...  /p[@name='actDynamicSharedSpectrum'][.='true']/../p[@name='dynamicSharedSpectrumGsmCellDN'][.!='']
        Run Keyword Unless  ${dss_enabled_in_lcel}  Append To List  ${lcels_with_dss_disabled}  ${lcell_id}
    END
    Run Keyword If  ${lcels_with_dss_disabled}  Run Keywords
    ...  Log  DSS is not enabled in some of LTE cells.\nDNs of alarming SCF objects: ${lcels_with_dss_disabled}  console=True
    ...  AND  Return From Keyword  False
    Log  DSS is enabled in cells ${lte_cell_ids}.  console=True
    [Return]  True


Get IDs Of WCDMA Cells Where WG DSS Is Enabled
    [Documentation]
    ...  This KW creates list of WCDMA cell IDs where WG DSS is enabled.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full description:**
    ...  This KW creates list of WCDMA cell IDs where WCDMA+GSM DSS feature
    ...  (RP002014) is enabled. It uses LCELW objects to find the IDs.
    ...  It requires keywords from ca_IWK resources to work.
    ...  It uses configuration SCF for finding cell IDs. SCF should be saved under path:
    ...  ${LOG_PATH}/misc_logs/SCF_YYYY-MM-DD_HH-MM-SS.xml
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     @{wcells_with_dss} =  Get IDs Of WCDMA Cells Where WG DSS Is Enabled
    [Arguments]  ${alias}=default

    Log  \nGet IDs Of WCDMA Cells Where WG DSS Is Enabled  console=True

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${dss_cell_ids} =    Create List
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_${timestamp}  alias=${alias}
    ${dist_names} =  Get DistName Attribute From SCF  ${parsed_scf}  LCELW  LCELW
    ...  /p[@name='actDynamicSharedSpectrum'][.='true']/../p[@name='dynamicSharedSpectrumGsmCellDN'][.!='']/..
    ...  return_list=True
    FOR  ${dist_name}  IN  @{dist_names}
        ${wncel_dist_name} =  Get DistName Attribute From SCF  ${parsed_scf}  WNCEL  WNCEL
        ...  /p[@name='lCelwDN'][.='${dist_name}']/..
        ${cell_id} =     Fetch From Right  ${wncel_dist_name}  marker=-
        Append To List  ${dss_cell_ids}  ${cell_id}
    END
    Log  IDs of WCDMA cells where DSS is enabled: ${dss_cell_ids}  console=True
    [Return]  ${dss_cell_ids}


Get IDs of GSM Sectors Mapped To WCDMA Cells For WG DSS
    [Documentation]
    ...  This keyword is used to get IDs of GSM sectors mapped to WCDMA cells given
    ...  by list of IDs in WG DSS (RP002014).
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Full description:**
    ...  This keyword is used to get IDs of GSM sectors mapped to WCDMA cells given
    ...  by list of IDs in WG DSS (RP002014).
    ...  It uses configuration SCF for verification. SCF should be saved under path:
    ...  ${LOG_PATH}/misc_logs/SCF_YYYY-MM-DD_HH-MM-SS.xml
    ...
    ...  **Input parameters:**
    ...
    ...  +----------------+------------+---------------------------------------------+
    ...  | Parameter      | Mandatory? | Description                                 |
    ...  +----------------+------------+---------------------------------------------+
    ...  | wcdma_cell_ids | Yes        | ID of WCDMA cell or list of WCDMA  cell IDs |
    ...  |                |            | for which IDs of corresponding GSM sectors. |
    ...  |                |            | will be returned.                           |
    ...  +----------------+------------+---------------------------------------------+
    ...  | connection     | No         | Alias for admin connection from which cell  |
    ...  |                |            | data is needed. Default value: default.     |
    ...  +----------------+------------+---------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${wcdma_cell_ids}=  Get WCDMA Cells IDs
    ...     ${gsm_sector_ids}=  Get IDs of GSM Sectors Mapped To WCDMA Cells For WG DSS  ${wcdma_cell_ids}

    [Arguments]  ${wcdma_cell_ids}  ${connection}=default

    ${wcdma_cell_ids}=  Run Keyword If  type(${wcdma_cell_ids}) is list  Set Variable  ${wcdma_cell_ids}
    ...  ELSE  Create List  ${wcdma_cell_ids}
    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf} =  Save And Parse SCF  SCF_${timestamp}  alias=${connection}
    ${gsm_sector_ids} =  Create List
    FOR  ${wcdma_cid}  IN  @{wcdma_cell_ids}
        ${lcelw_dist_name} =  Get Parameter Value From SCF  ${parsed_scf}  WNCEL  WNCEL-${wcdma_cid}
        ...  /p[@name='lCelwDN']  dist_name_substring=True
        ${lcelc_dist_name} =  Get Parameter Value From SCF  ${parsed_scf}  LCELW  ${lcelw_dist_name}
        ...  /p[@name='dynamicSharedSpectrumGsmCellDN']  dist_name_substring=True
        ${lcelc_id} =  Fetch From Right  ${lcelc_dist_name}  marker=-
        ${gncel_dist_name} =  Get DistName Attribute From SCF  ${parsed_scf}  GNCEL  GNCEL
        ...  /p[@name='lcelcId'][.='${lcelc_id}']/..
        ${all_cells} =  Get Cell List  connection=${connection}
        ${gsm_cell_objects} =  Get From Dictionary  ${all_cells['cells']}  gsm
        ${gsm_sector_id} =  Evaluate  [x['gsmSectorID'] for x in @{gsm_cell_objects} if x['id']['configuration'] == '${gncel_dist_name}']
        Should Not Be Equal As Strings  '${gsm_sector_id[0]}'  ''  msg=No GSM cell mapped to WCDMA cell: ${wcdma_cid}.
        Append To List  ${gsm_sector_ids}  ${gsm_sector_id[0]}
    END

    [Return]  ${gsm_sector_ids}


Basic Verification Of WG DSS Enabling: Initial Configuration Verification (LCELW And BSC)
    [Documentation]
    ...  This KW performs basic verification if WG DSS is enabled - configured correctly by tester.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full description:**
    ...  This KW performs basic verification if WCDMA+GSM DSS (RP002014) is enabled.
    ...  In this KW it is only verified if basic configuration prepared by tester
    ...  is correct. It does not verify if values for DSS mapping in SCF are correct
    ...  it only checks if parameter 'dynamicSharedSpectrumGsmCellDN' is not empty.
    ...  This KW uses 'Verify If DSS Is Enabled In Given WCDMA Cells Using LCELW
    ...  SCF Objects' KW to verify through SCF if configuration is correct
    ...  and 'Verify If DSS Is Enabled - DSSE Parameter in BSC' KW to verify
    ...  on BSC if DSSE parameter was set correctly. For more information,
    ...  please see documentation for those KWs. This KW fails if LCELW
    ...  configuration is incorrect. It will also fail if BSC configuration
    ...  is incorrect if 'bsc_fails_test' variable is set to 'True'.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------------+--------------------------------------------------------+
    ...  | Parameter      | Mandatory? | Description                                            |
    ...  +----------------+------------+--------------------------------------------------------+
    ...  | wcdma_cell_ids | Yes        | IDs of WCDMA cells in which the enabling               |
    ...  |                |            | of DSS will be checked                                 |
    ...  +----------------+------------+--------------------------------------------------------+
    ...  | gsm_sector_ids | Yes        | IDs of GSM sectors in which the enabling               |
    ...  |                |            | of DSS will be checked                                 |
    ...  +----------------+------------+--------------------------------------------------------+
    ...  | bsc_fails_test | No         | This variable indicates whether this KW should fail if |
    ...  |                |            | WG DSS is not enabled on BSC. If this variable         |
    ...  |                |            | is set to 'False' only warning is printed.             |
    ...  +----------------+------------+--------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${sector_ids} =  Create List  111  112  113
    ...     Basic Verification Of WG DSS Enabling: Initial Configuration Verification (LCELW And BSC)
    ...     ...  ${sector_ids}  False  Any

    [Arguments]  ${wcdma_cell_ids}  ${gsm_sector_ids}  ${bsc_fails_test}=True  ${connection}=default

    ${dss_enabled_lcelw}=  Verify If DSS Is Enabled In Given WCDMA Cells Using LCELW SCF Objects  ${wcdma_cell_ids}  alias=${connection}

    Run Keyword Unless  ${dss_enabled_lcelw}
    ...  Log  DSS is not enabled in SCF.  level=ERROR

    ${dss_enabled_bsc} =     Verify If DSS Is Enabled - DSSE Parameter in BSC  ${gsm_sector_ids}
    Run Keyword If  ${bsc_fails_test} and not ${dss_enabled_bsc}
    ...  Log  DSS is not enabled in BSC.  level=ERROR
    ...  ELSE IF    not ${bsc_fails_test} and not ${dss_enabled_bsc}
    ...  Log  DSS is not enabled in BSC. This test runs with DSSE in BSC parameter different than '2 (DSS GSM+WCDMA)'.  level=WARN

    ${message} =  Catenate  WG DSS is disabled. There is a problem with configuration of one or more of the following
    ...                                 ('False' indicates a problem): SCF(${dss_enabled_lcelw}), BSC(${dss_enabled_bsc}).
    Run Keyword If  ${bsc_fails_test}
    ...         Should Be True  ${dss_enabled_lcelw} and ${dss_enabled_bsc}  msg=${message}
    ...  ELSE   Should Be True  ${dss_enabled_lcelw}
    ...         msg=WG DSS is disabled. There is a problem with configuration in SCF.


Basic Verification Of WG DSS Enabling In Given Cells
    [Documentation]
    ...  This KW is wrapper for KWs performing basic verification if WG DSS (RP002014) is enabled.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com, igor.binkowski@nokia.com
    ...
    ...  **Full description:**
    ...  This KW is wrapper for KWs performing basic verification if WG DSS is enabled.
    ...  It connects and disconnects from BSC and sets 'BSC_CONNECTED' global variable
    ...  accordingly. If this KW fails it may require BSC connection to be closed.
    ...  Please close BSC connection in your code if 'BSC_CONNECTED' is equal to 'True'.
    ...
    ...  **Input parameters:**
    ...
    ...  +----------------+------------+---------------------------------------------------------+
    ...  | Parameter      | Mandatory? | Description                                             |
    ...  +----------------+------------+---------------------------------------------------------+
    ...  | wcdma_cell_ids | Yes        | IDs of WCDMA cells for which verification will be done. |
    ...  |                |            | Corresponding GSM sectors will be checked as well.      |
    ...  |                |            | Can be either a list, or a single value.                |
    ...  +----------------+------------+---------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Basic Verification Of WG DSS Enabling In Given Cells  27413

    [Arguments]  ${wcdma_cell_ids}  ${connection}=default

    Log  Performing verification of WG DSS enabling in WCDMA cells ${wcdma_cell_ids} and corresponding GSM sectors.  console=True

    Set Test Variable        ${BSC_CONNECTED}  ${TRUE}
    ca_INTER_RAT.Open session to BSC

    ${wcdma_cell_ids}=  Run Keyword If  type(${wcdma_cell_ids}) is list  Set Variable  ${wcdma_cell_ids}
    ...  ELSE  Create List  ${wcdma_cell_ids}

    ${gsm_sector_ids}=  Get IDs of GSM Sectors Mapped To WCDMA Cells For WG DSS  ${wcdma_cell_ids}  connection=${connection}
    Basic Verification Of WG DSS Enabling: Initial Configuration Verification (LCELW And BSC)  ${wcdma_cell_ids}  ${gsm_sector_ids}
    ...    connection=${connection}
    Basic Verification Of DSS Enabling: Alarms Verification  connection=${connection}

    Log  DSS for WCDMA+GSM is active.  console=True

    Log  \nVerification of WG DSS enabling in cells ${wcdma_cell_ids} and corresponding GSM sectors successful!  console=True

    [Teardown]  Run Keywords  ca_INTER_RAT.Close All BSC Sessions  AND  Set Test Variable  ${BSC_CONNECTED}  ${FALSE}


Get Shared ARFCN Usage List From DSS GSM USAGE IND Message
    [Documentation]
    ...  This KW is used to get a list of shared frequencies used by GSM from DSS GSM USAGE IND message.
    ...
    ...  **Author:** igor.binkowski@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW is used to get a list of shared frequencies used by GSM from DSS GSM USAGE IND message. Obtained list
    ...  | contains bitmaps in form of numbers in hex system. An external VM with Tshark suited for 2G applications
    ...  | installed is required to use this KW.
    ...  | Before using this KW, make sure to collect pcap logs which should contain the DSS GSM USAGE IND message
    ...  | using keywords Turn On Pcap Logging and Turn Off Pcap Logging from ca_qt resource. Use the alias used for
    ...  | Turn Off Pcap Logging for this keyword in pcap_log_alias argument to point it to the right log file.
    ...
    ...  **Input parameters:**
    ...  +----------------------+------------+---------------------------------------------------------------------+
    ...  | Parameter            | Mandatory? | Description                                                         |
    ...  +----------------------+------------+---------------------------------------------------------------------+
    ...  | wireshark_log_dir    | No         | Path to folder containing pcap file for analysis.                   |
    ...  |                      |            | Default is ${TestFiles}                                             |
    ...  +----------------------+------------+---------------------------------------------------------------------+
    ...  | tshark_vm_ip         | No         | IP of VM where the pcap file will be sent and analysed.             |
    ...  |                      |            | Default is 10.42.239.50                                            |
    ...  +----------------------+------------+---------------------------------------------------------------------+
    ...  | pcap_log_alias       | No         | Alias of pcap log collected using Turn On/Off Pcap Logging from     |
    ...  |                      |            | ca_qt resource. Default is 'all'                                    |
    ...  +----------------------+------------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${shared_arfcn_usage_list}=  Get Shared ARFCN Usage List From DSS GSM USAGE IND Message  pcap_step_1

    [Arguments]  ${wireshark_log_dir}=${TestFiles}  ${tshark_vm_ip}=10.42.239.50  ${pcap_log_alias}=all
    ...  ${timeout}=10min

    Run  7z e ${wireshark_log_dir}/${TEST_NAME}_${pcap_log_alias}.zip -o${wireshark_log_dir}/${pcap_log_alias}
    Run  rm ${wireshark_log_dir}/${TEST_NAME}_${pcap_log_alias}.zip

    Put File Via SSH To Tshark VM  ${tshark_vm_ip}  ute  ute  ${wireshark_log_dir}/${pcap_log_alias}/${TEST_NAME}_${pcap_log_alias}
    ...  /home/ute/pcap_logs/${TESTLINE_NAME}/${TEST_NAME}_${pcap_log_alias}.cap

    ${shared_arfcn_usage_string} =  Use Tshark On Remote VM  ${tshark_vm_ip}  ute  ute
    ...  /home/ute/pcap_logs/${TESTLINE_NAME}/${TEST_NAME}_${pcap_log_alias}.cap
    ...  display_filter=rsl.ie_id == 0xd0  field=rsl.shared_arfcn_usage.arfcn_pos  timeout=${timeout}
    ${shared_arfcn_usage_string} =  Get Line  ${shared_arfcn_usage_string}  -1
    ${shared_arfcn_usage_list} =    Split String  ${shared_arfcn_usage_string}  separator=,

    [Return]  ${shared_arfcn_usage_list}


Use Tshark On Remote VM
    [Documentation]
    ...  Keyword used to run tshark on remote VM.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Keyword used to run tshark on remote VM. It is useful for tests that need to use tshark
    ...  on a different VM, e.g. 2G or 3G tshark installed on a different Linux system than
    ...  the one supported in automation. It can use a full tshark command ('command' argument)
    ...  or a display filter ('display_filter') with field ('field') which correspond
    ...  to -R and -e arguments in tshark command.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | Parameter         | Man. | Description                                                               |
    ...  +===================+======+===========================================================================+
    ...  | host_ip           | Yes  | IP for remote VM where tshark is located.                                 |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | user              | Yes  | Username for remote VM where tshark is located.                           |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | password          | Yes  | Password for remote VM where tshark is located.                           |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | tshark_file_path  | Yes  | Path to file located on remote VM which will be parsed.                   |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | display_filter    | No   | Display filter that will be used in tshark command,                       |
    ...  |                   |      | e.g. "rsl.ie_id == 0xd0". Default value: ${EMPTY}.                        |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | field             | No   | Field name that will be used in tshark command,                           |
    ...  |                   |      | e.g. "rsl.shared_arfcn_usage.arfcn_pos". Default value: ${EMPTY}.         |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | tshark_path       | No   | Path to tshark. Default value: /usr/bin/tshark.                           |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | command           | No   | Command that will be used by tshark. Cannot start with 'tshark'.          |
    ...  |                   |      | Default value: ${EMPTY}.                                                  |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...  | timeout           | No   | Timeout for this keyword. Default value: 10min.                           |
    ...  +-------------------+------+---------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${shared_arfcn_usage_string} =  Use Tshark On Remote VM  ${tshark_vm_ip}  ute  ute
    ...     ...  /home/ute/pcap_logs/${TESTLINE_NAME}/${TEST_NAME}_${pcap_log_alias}.cap
    ...     ...  display_filter="rsl.ie_id == 0xd0"  field="rsl.shared_arfcn_usage.arfcn_pos"

    [Arguments]  ${host_ip}  ${user}  ${password}  ${tshark_file_path}  ${display_filter}=${EMPTY}
    ...  ${field}=${EMPTY}  ${tshark_path}=/usr/bin/tshark  ${command}=${EMPTY}  ${timeout}=10min
    [Timeout]  ${timeout}
    SSHLibrary.Open Connection  ${host_ip}
    SSHLibrary.Login  ${user}  ${password}
    ${tshark_command} =  Set Variable If  '${command}' != '${EMPTY}'  ${command}
    ...             '${command}' == '${EMPTY}' and '${display_filter}' != '${EMPTY}' and '${field}' != '${EMPTY}'
    ...  -r "${tshark_file_path}" -R "${display_filter}" -T fields -e "${field}"
    ${stdout}  ${stderr}  ${rc} =  SSHLibrary.Execute Command  ${tshark_path} ${tshark_command}
    ...  return_stderr=True  return_rc=True
    Should Be Equal As Integers  ${rc}  0    msg=RC is not equal to 0.
    Should Be Empty  ${stderr}  msg=${stderr}
    [Return]  ${stdout}
    [Teardown]  SSHLibrary.Close Connection



Basic Verification Of LG DSS Enabling In Given Cells
    [Documentation]
    ...  This KW is used to check if LG DSS (RP001783) is enabled on both BTS and BSC side.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...   **Full description:**
    ...
    ...  This KW is used to check if LG DSS is enabled on both BTS and BSC side. To do so it uses keywords
    ...  Verify If DSS Is Enabled In Given LTE Cells Using LCELL SCF Objects,
    ...  Verify If DSS Is Enabled - DSSE Parameter in BSC.
    ...  It connects and disconnects from BSC and sets 'BSC_CONNECTED' global variable
    ...  accordingly. If this KW fails it may require BSC connection to be closed.
    ...  Please close BSC connection in your code if 'BSC_CONNECTED' is equal to 'True'.
    ...
    ...  **Input parameters:**
    ...
    ...  +--------------+------------+-------------------------------------------------------+
    ...  | Parameter    | Mandatory? | Description                                           |
    ...  +--------------+------------+-------------------------------------------------------+
    ...  | lte_cell_ids | Yes        | IDs of LTE cells for which verification will be done. |
    ...  |              |            | Corresponding GSM sectors will be checked as well.    |
    ...  |              |            | Can be either a list, or a single value.              |
    ...  +--------------+------------+-------------------------------------------------------+
    ...  | connection   | No         | Alias for admin connection from which                 |
    ...  |              |            | cell data is needed. Default value: default.          |
    ...  +--------------+------------+-------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Basic Verification Of LG DSS Enabling In Given Cells  22851

    [Arguments]  ${lte_cell_ids}  ${connection}=default

    Log  Performing verification of LG DSS enabling in LTE cells ${lte_cell_ids} and corresponding GSM sectors.  console=True

    Set Test Variable        ${BSC_CONNECTED}  ${TRUE}
    ca_INTER_RAT.Open session to BSC

    ${lte_cell_ids}=  Run Keyword If  type(${lte_cell_ids}) is list  Set Variable  ${lte_cell_ids}
    ...  ELSE  Create List  ${lte_cell_ids}

    ${gsm_sector_ids}=  Create List
    FOR  ${lte_cell_id}  IN  @{lte_cell_ids}
        ${gsm_sector_id}=  Get ID of GSM Cell Mapped To LTE Cell For LG DSS  ${lte_cell_id}  ${connection}
        Append To List  ${gsm_sector_ids}  ${gsm_sector_id}
    END

    ${lcell_status}=  Verify If DSS Is Enabled In Given LTE Cells Using LCELL SCF Objects  ${lte_cell_ids}  ${connection}
    ${dsse_status}=  Verify If DSS Is Enabled - DSSE Parameter in BSC  ${gsm_sector_ids}  LG
    ${message} =  Catenate  DSS is disabled. 'False' indicates a problem with this object type:
    ...  \nLCELL SCF objects - ${lcell_status}\nDSSE Parameter in BSC - ${dsse_status}
    Should Be True  ${lcell_status} and ${dsse_status}  msg=${message}

    Basic Verification Of DSS Enabling: Alarms Verification  connection=${connection}

    Log  \nVerification of LG DSS enabling in cells ${lte_cell_ids} and corresponding GSM sectors successful!  console=True

     [Teardown]  Run Keywords  ca_INTER_RAT.Close All BSC Sessions  AND  Set Test Variable  ${BSC_CONNECTED}  ${FALSE}


Get ID of GSM Cell Mapped To LTE Cell For LG DSS
    [Documentation]
    ...  This KW gets ID of GSM cell that is mapped to LTE cell for RP001783 feature.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW gets ID of GSM cell that is mapped to LTE cell for LTE+GSM DSS feature
    ...  | (RP001783). LTE cell ID is passed in 'lcell_id' parameter.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | lncel_id         | Yes  | ID of LTE cell for which ID of mapped GSM cell      |
    ...  |                  |      | will be returned.                                   |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | connection       | No   | Alias for admin connection from which               |
    ...  |                  |      | cell data is needed. Default value: default.        |
    ...  +------------------+------+-----------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${sector_id} =  Get ID of GSM Cell Mapped To LTE Cell For LG DSS  11111

    [Arguments]  ${lncel_id}  ${connection}=default

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf} =  Save And Parse SCF  SCF_${timestamp}  alias=${connection}
    ${lcr_id} =  Get Parameter Value From SCF  ${parsed_scf}  LNCEL  LNCEL-${lncel_id}
    ...  /p[@name='lcrId']  dist_name_substring=True
    ${lcelc_distname} =  Get Parameter Value From SCF  ${parsed_scf}  LCELL  LCELL-${lcr_id}
    ...  /p[@name='dynamicSharedSpectrumGsmCellDN']  dist_name_substring=True
    ${status}  ${lcelc_id}=   Run Keyword And Ignore Error  Convert Dist Name To ID  ${lcelc_distname}
    Run Keyword And Return If  '${status}' == 'FAIL'  Fail  No GSM sector was mapped to LTE cell or there was problem with mapped cell name
    ${gncel_dist_name} =  Get DistName Attribute From SCF  ${parsed_scf}  GNCEL  GNCEL
    ...  /p[@name='lcelcId'][.='${lcelc_id}']/..

    ${all_cells} =  Get Cell List  connection=${connection}
    ${gsm_cell_objects} =  Get From Dictionary  ${all_cells['cells']}  gsm
    ${gsm_sector_id} =  Evaluate  [x['gsmSectorID'] for x in @{gsm_cell_objects} if x['id']['configuration'] == '${gncel_dist_name}']
    Should Not Be Equal As Strings  '${gsm_sector_id[0]}'  ''  msg=No GSM cell mapped to LTE cell: ${lncel_id}.

    [Return]  ${gsm_sector_id[0]}


Get TRXes Of Specified Type For GSM Cell
    [Documentation]
    ...  This KW returns a list of TRXes of specified type for a GSM cell.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description**
    ...  | This KW returns a list of TRXes of specified type for a GSM cell.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+--------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                            |
    ...  +=====================+======+========================================================+
    ...  | sector_id           | Yes  | IDs of GSM sector where DSS is enabled.                |
    ...  +---------------------+------+--------------------------------------------------------+
    ...  | trx_type            | Yes  | Searched TRX type. Possible values: SHARED, DEDICATED. |
    ...  +---------------------+------+--------------------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${shared_trxes} =  Get TRXes Of Specified Type For GSM Cell  111  SHARED

    [Arguments]  ${sector_id}  ${trx_type}

    Should Be True  ${sector_id}  msg=Required ID is missing.
    Return From Keyword If  not ${sector_id}

    ${trxes} =  hran_bsc.Get TRXs List By BTS ID  bts_id=${sector_id}  alias=${False}
    Should Not Be Empty  ${trxes}
    Log  List of checked TRXes for sector ${sector_id}: ${trxes}  console=True
    ${trx_type} =  Evaluate  '${trx_type}'.upper()
    ${desired_trx_list} =  Create List
    FOR  ${trx_id}  IN  @{trxes}
        hran_bsc.Get Transceiver Data  ${sector_id}  ${trx_id}
        hran_bsc.Write  ZERO:BTS=${sector_id},TRX=${trx_id};
        ${bsc_output} =  hran_bsc.Read Until  COMMAND EXECUTED  10s
        ${dss_trx_type_line} =  Should Match Regexp  ${bsc_output}  DSS TRX TYPE.+\\n
        ${dss_trx_type} =  Remove String Using Regexp  ${dss_trx_type_line}  DSS TRX TYPE  \\s{2,}  \\s\\(  \\)  \\d
        Run Keyword If  '${trx_type}' == '${dss_trx_type}'  Append To List  ${desired_trx_list}  ${trx_id}
        Log  TRX${trx_id}=${dss_trx_type}  console=True
    END
    ${verdict}  ${msg}=  Run Keyword And Ignore Error
    ...                  Should Not Be Empty  ${desired_trx_list}  msg=There were no ${trx_type} TRXes found.
    Run Keyword If  '${verdict}' == 'FAIL'  Log  ${msg}  level=WARN
    [Return]  ${desired_trx_list}


Get Cells With The Same Picpool
    [Documentation]
    ...  This KW finds and returns list with IDs of cells that need to be in the same picpool
    ...  as the one passed in 'cell_id' variable.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full description:**
    ...  This KW finds and returns list of cells that need to be in the same
    ...  picpool as the one given as argument 'cell_id'. The same picpool cells are in one LCG
    ...  and have the same default carrier.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------------+------+---------------------------------------------------------+
    ...  | Parameter            | Man. | Description                                             |
    ...  +======================+======+=========================================================+
    ...  | cell_id              | Yes  | ID of cell for which list of cells which should         |
    ...  |                      |      | be in the same picpool will be returned.                |
    ...  +----------------------+------+---------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${same_picpool_cells} =  Get Cells With The Same Picpool  11111

    [Arguments]  ${cell_id}

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf} =  Save And Parse SCF  SCF_${timestamp}
    ${uarfcn} =  Get Parameter Value From SCF  ${parsed_scf}  WNCEL  WNCEL-${cell_id}
    ...  /p[@name='defaultCarrier']  dist_name_substring=True
    ${wlcg_list} =  Get Parameter Value From SCF  ${parsed_scf}  WNCELG  WNCELG
    ...  /list[@name='wncelIdList']/p[.='${cell_id}']/..
    ${wlcg_list} =  Remove String  ${wlcg_list}  ${SPACE}
    ${wlcg_list} =  Split To Lines  ${wlcg_list}
    ${cell_dist_names_with_same_carrier} =  Get DistName Attribute From SCF  ${parsed_scf}  WNCEL  WNCEL
    ...  /p[@name='defaultCarrier'][.='${uarfcn}']/..  return_list=True

    @{same_picpool_cells} =  Create List
    FOR  ${cell_dist_name}  IN  @{cell_dist_names_with_same_carrier}
        ${cell_id} =  Convert Dist Name To ID  ${cell_dist_name}
        ${is_in_lcg} =  Run Keyword And Return Status  List Should Contain Value  ${wlcg_list}  ${cell_id}
        Run Keyword If  ${is_in_lcg}  Append To List  ${same_picpool_cells}  ${cell_id}
    END

    Log  \nList of cells in the same picpool: ${same_picpool_cells}  console=True

    [Return]  ${same_picpool_cells}


Create Cells And LCG IDs Dictionary
    [Documentation]
    ...  This KW creates dictionary of cells and LCGs.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates dictionary with LCGs as keys and cell list as value.
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...
    ...     ${cell_lcg_dict} =  Create Cells And LCG IDs Dictionary

    Log  Creating cells and LCG IDs dictionary  console=True

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_full_${timestamp}
    ${wlcg_dist_names} =  Get DistName Attribute From SCF  ${parsed_scf}  WNCELG  WNCELG
    ...  return_list=True
    &{cell_lcg_dict} =  Create Dictionary
    FOR  ${wlcg_dist_name}  IN  @{wlcg_dist_names}
        ${lcg_id} =  Convert Dist Name To ID  ${wlcg_dist_name}
        ${cells_string} =  Get Parameter Value From SCF  ${parsed_scf}  WNCELG  ${wlcg_dist_name}
        ...  /list[@name='wncelIdList']  dist_name_substring=True
        ${cells_string} =  Remove String Using Regexp  ${cells_string}  ^\\n  ${SPACE}
        ${cells_string} =  Remove String Using Regexp  ${cells_string}  \\n$
        ${cell_list} =  Split String  ${cells_string}  separator=\n
        Set To Dictionary  ${cell_lcg_dict}  ${lcg_id}  ${cell_list}
    END
    Log  Cell and LCG dictionary= ${cell_lcg_dict}\n  console=True

    [Return]  ${cell_lcg_dict}


Get LCG ID For Cell
    [Documentation]
    ...  This KW returns LCG ID of currently verified cell.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW returns LCG ID of currently verified cell. Cell ID is passed in 'cell_id' variable.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------+------+-------------------------------------------------------------------+
    ...  | Parameter       | Man. | Description                                                       |
    ...  +=================+======+===================================================================+
    ...  | cell_id         | Yes  | ID of currently verified cell.                                    |
    ...  +-----------------+------+-------------------------------------------------------------------+
    ...  | cell_lcg_dict   | Yes  | Dictionary containing LCG IDs as keys and cell lists as values.   |
    ...  +-----------------+------+-------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...
    ...     ${cell_list1} =  Create List  12301  12302
    ...     ${cell_list2} =  Create List  12303  12304  12305
    ...     ${cell_dictionary} =  Create Dictionary  1=${cell_list1}  2=${cell_list2}
    ...     ${lcg_id} =  Get LCG ID For Cell  12301  ${cell_dictionary}

    [Arguments]  ${cell_id}  ${cell_lcg_dict}

    ${cell_id} =  Convert To Integer  ${cell_id}
    FOR  ${lcg_id}  IN  @{cell_lcg_dict}
        ${cell_list} =  Get From Dictionary  ${cell_lcg_dict}  ${lcg_id}
        ${status} =  Run Keyword And Return Status  List Should Contain Value  ${cell_list}  ${cell_id}
        Exit For Loop If  ${status}
    END
    Log  LCG ID=${lcg_id} for cell=${cell_id}\n  console=True

    [Return]  ${lcg_id}


Toggle GPRS In GSM TRX
        [Documentation]
    ...  This keyword will turn GRPS on or off in given TRX of a given GSM sector.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  | **Full description:**
    ...  | This keyword will turn GRPS on in given TRX of given GSM sector using MML command:
    ...  |   - ZERM:BTS=<BTS_ID>,TRX=<TRX_ID>:GTRX=Y;
    ...  | or turn it off using command:
    ...  |   - ZERM:BTS=<BTS_ID>,TRX=<TRX_ID>:GTRX=N;
    ...  |
    ...  | Before executing the command, it will lock the TRX.
    ...  | After executing the command, it will collect the output and check if it contains text 'COMMAND EXECUTED'.
    ...  | If not, it will fail and log the message returned by BSC.
    ...  | In teardown, it will unlock the TRX.
    ...  | This keyword requires an active connection to BSC and library hran_bsc imported in test case.
    ...
    ...  **Input parameters:**
    ...  +----------------+------------+---------------------------------------------------------------+
    ...  | Parameter name | Mandatory? | Description                                                   |
    ...  +================+============+===============================================================+
    ...  | on_or_off      | Yes        | String saying whether GPRS in TRX should be turned on or off. |
    ...  |                |            | Must take value 'on' or 'off' (case irrelevant).              |
    ...  +----------------+------------+---------------------------------------------------------------+
    ...  | bts_id         | Yes        | ID of GSM sector to which the TRX belongs.                    |
    ...  +----------------+------------+---------------------------------------------------------------+
    ...  | trx_id         | Yes        | ID of TRX where GPRS will be toggled.                         |
    ...  +----------------+------------+---------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...
    ...     Toggle GPRS In GSM TRX  ON  276  4

    [Arguments]  ${on_or_off}  ${bts_id}  ${trx_id}

    Should Be True  '${on_or_off.lower()}' in ['on', 'off']  msg=Parameter on_or_off must take value 'on' or 'off' (case irrelevant).
    ${state}=  Set Variable If  '${on_or_off.lower()}' == 'on'  Y  N

    Lock TRX  ${bts_id}  ${trx_id}
    hran_bsc.Write  ZERM:BTS=${bts_id},TRX=${trx_id}:GTRX=${state};
    ${result}=  hran_bsc.Read Until  COMMAND EXECUTED  10s
    Should Contain  ${result}  COMMAND EXECUTED  msg=Turning ${on_or_off.lower()} GPRS in TRX ${trx_id} of GSM sector ${bts_id} failed:\n${result}
    Log  GPRS in TRX ${trx_id} of BTS ${bts_id} turned ${on_or_off.lower()} successfully.  console=True

    [Teardown]  Unlock TRX  ${bts_id}  ${trx_id}


Basic Verification Of DSS Enabling: Alarms Verification
    [Documentation]
    ...  This keyword checks if alarm 'Peer RAT Communication Failure
    ...  when DSS feature is enabled' with fault ID 2422 and alarm
    ...  with fault ID 2421 did not appear and fails if any of them did.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Basic Verification Of DSS Enabling: Alarms Verification

    [Arguments]  ${connection}=default

    Assert Alarm Inactive  faultId=2422  connection=${connection}
    Assert Alarm Inactive  faultId=2421  connection=${connection}


Prepare GSM Sector For Shared Spectrum Usage
    [Documentation]
    ...  This KW will lock timeslots and turn off GTRX in all TRXes of given GSM BTS, except for one shared TRX.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  **Full description:**
    ...  This keyword is used to prepare a GSM sector for usage of shared spectrum in DSS without the need for voice
    ...  calls or data transfers. It will lock all timeslots and turn off GTRX in all TRXes of a given GSM sector,
    ...  excluding the shared TRX with the highest logical id. In case of activated RP002596 (EFSS=1)
    ...  if TRX with the highest logical id is the MBCCH TRX this KW will instead use the TRX with the next highest
    ...  logical id. It will also save the ID if this TRX inside a global variable called LAST_SHARED_TRX_ID.
    ...  After preparing a sector with this KW, tester can turn GTRX on in this shared TRX to cause allocation of
    ...  shared spectrum for GSM just as it would happen during a voice call.
    ...  To restore the state of the sector, use keyword Prepare GSM Sector For Shared Spectrum Usage - Teardown.
    ...
    ...  Notes:
    ...    - Telnet session to BSC must be open
    ...    - GENA must be enabled for given sector
    ...    - RF hopping should be configured at least in the last shared TRX
    ...
    ...  **Input parameters:**
    ...
    ...  +----------------+------------+-----------------------------------------------+
    ...  | Parameter name | Mandatory? | Description                                   |
    ...  +================+============+===============================================+
    ...  | gsm_sector_id  | Yes        | ID of GSM BTS which will be reconfigured.     |
    ...  +----------------+------------+-----------------------------------------------+
    ...  | connection     | No         | Alias for admin connection from which         |
    ...  |                |            | cell data is needed. Default value: default.  |
    ...  +----------------+------------+-----------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...
    ...     Prepare GSM Sector For Shared Spectrum Usage  420
    ...
    [Arguments]  ${gsm_sector_id}  ${connection}=default

    ${timeslot_range_0_7}=  Create List  0  7
    ${trx_ids}=  hran_bsc.Get TRXs List By BTS ID  ${gsm_sector_id}  alias=False

    ${shared_trxes} =  Get TRXes Of Specified Type For GSM Cell  ${gsm_sector_id}  SHARED
    Evaluate  $shared_trxes.sort()
    ${last_shared_trx_id}=  Set Variable  ${shared_trxes[-1]}
    ${trx_parameters}=  Wait Until Keyword Succeeds  2m  10s  hran_bsc.Get Transceiver Data  ${gsm_sector_id}  ${last_shared_trx_id}
    ${bcch_trx}=  Evaluate  'MBCCH' in ${trx_parameters['TYPE']}
    ${last_shared_trx_id}=  Set Variable If  ${bcch_trx}  ${shared_trxes[-2]}  ${last_shared_trx_id}
    Set Test Variable  ${LAST_SHARED_TRX_ID}  ${last_shared_trx_id}

    hran_bsc.Lock Sector  ${gsm_sector_id}
    FOR  ${trx_id}  IN  @{trx_ids}
        Toggle GPRS In GSM TRX  OFF  ${gsm_sector_id}  ${trx_id}
        Continue For Loop If  ${trx_id} == ${last_shared_trx_id}
        ${trx_parameters}=  Wait Until Keyword Succeeds  2m  10s  hran_bsc.Get Transceiver Data  ${gsm_sector_id}  ${trx_id}
        ${bcch_trx}=  Evaluate  'MBCCH' in ${trx_parameters['TYPE']}
        Run Keyword If  ${bcch_trx}  Run Keywords
        ...  handle bcch trx  ${gsm_sector_id}  ${trx_id}  ${trx_parameters['TYPE']}  AND  Continue For Loop
        Wait Until Keyword Succeeds  5m  1m
        ...  Change Administrative State Of Timeslots For TRXes  ${gsm_sector_id}  ${trx_id}  ${timeslot_range_0_7}  lock  True
    END
    hran_bsc.Unlock Sector  ${gsm_sector_id}
    ${gsm_cell_runtime_distname} =  Get Runtime Dist Name For GSM Sector  ${gsm_sector_id}  ${connection}

    ${gsm_online_states}=  Run Keyword If  ${CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked",
    ...                                           blockingState=regex"[Uu]nblocked"
    ...  ELSE               Catenate  SEPARATOR=  availabilityStatus=Online,
    ...                                           operationalState=Enabled,
    ...                                           administrativeState=Unlocked,
    ...                                           blockingState=Unblocked
    Wait Until Keyword Succeeds  4min  10s  _check gsm cell state helper  ${gsm_cell_runtime_distname}
    ...  ${gsm_online_states}  ${connection}
    Log  Sector-${gsm_sector_id} is back On Air with timeslots mentioned above locked!  console=True


Get Runtime Dist Name For GSM Sector
    [Documentation]
    ...  KW used for getting runtime dist name for specified GSM sector ID.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                          |
    ...  +================+======+======================================================================+
    ...  | gsm_sector_id  | Yes  | ID of GSM sector for which runtime dist name is needed.              |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | connection     | No   | Alias of admin connection from which cell info is needed.            |
    ...  |                |      | Default value: default.                                              |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get Runtime Dist Name For GSM Sector  463

    [Arguments]  ${gsm_sector_id}  ${connection}=default

    ${gsm_cells_objects} =  Get Cells Info  gsm  connection=${connection}
    ${gsm_cell_runtime_distname} =  Evaluate  [x['id']['internal'] for x in @{gsm_cells_objects} if ${gsm_sector_id} == x['gsmSectorID']][0]
    [Return]  ${gsm_cell_runtime_distname}


Get Runtime Dist Name For WCDMA Cell
    [Documentation]
    ...  KW used for getting runtime dist name for specified WCDMA cell ID.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                          |
    ...  +================+======+======================================================================+
    ...  | wcdma_cell_id  | Yes  | ID of WCDMA cell for which runtime dist name is needed.              |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | connection     | No   | Alias of admin connection from which cell info is needed.            |
    ...  |                |      | Default value: default.                                              |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get Runtime Dist Name For WCDMA Cell  29421

    [Arguments]  ${wcdma_cell_id}  ${connection}=default

    ${wcdma_cells_objects} =  Get Cells Info  wcdma  connection=${connection}
    ${wcdma_cell_runtime_distname} =  Evaluate  [x['id']['internal'] for x in @{wcdma_cells_objects} if ${wcdma_cell_id} == x['cellId']][0]
    [Return]  ${wcdma_cell_runtime_distname}


Get Runtime Dist Name For LTE Cell
    [Documentation]
    ...  KW used for getting runtime dist name for specified LTE cell ID.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                          |
    ...  +================+======+======================================================================+
    ...  | lte_cell_id    | Yes  | ID of LTE cell for which runtime dist name is needed.                |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | connection     | No   | Alias of admin connection from which cell info is needed.            |
    ...  |                |      | Default value: default.                                              |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get Runtime Dist Name For LTE Cell  29421

    [Arguments]  ${lte_cell_id}  ${connection}=default
    ${lte_cells_objects} =  Get Cells Info  lte  connection=${connection}
    ${lte_cell_runtime_distname} =  Evaluate  [x['id']['internal'] for x in @{lte_cells_objects} if ${lte_cell_id} == x['globalCellId']][0]
    [Return]  ${lte_cell_runtime_distname}


_check gsm cell state helper
    [Arguments]  ${gsm_cell_runtime_distname}  ${gsm_online_states}  ${connection}=default

    Assert  GNCEL  ${gsm_cell_runtime_distname}  ${gsm_online_states}  connection=${connection}
    Run Keyword If  ${CNI-61110_STATUS}
    ...  Run Keyword And Expect Error  *  Assert  GNCEL  ${gsm_cell_runtime_distname}  availabilityStatus!=empty
    ...  connection=${connection}


_check cell state helper
    [Arguments]  ${class}  ${cell_runtime_distname}  ${states}  ${availability_cni_check}=False
    ...  ${timeout}=10  ${connection}=default

    Assert  ${class}  ${cell_runtime_distname}  ${states}  timeout=${timeout}  connection=${connection}
    Run Keyword If  ${CNI-61110_STATUS} and ${availability_cni_check}
    ...  Run Keyword And Expect Error  *  Assert  ${class}  ${cell_runtime_distname}  availabilityStatus!=empty
    ...  timeout=${timeout}  connection=${connection}


_handle bcch trx
    [Documentation]
    ...  Helper KW for Prepare GSM Sector For Shared Spectrum Usage
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com

    [Arguments]  ${gsm_sector_id}  ${trx_id}  ${trx_timeslot_type_list}

    ${mbcch_timeslot_position}=  Get Index From List  ${trx_timeslot_type_list}  MBCCH
    ${sdcch_timeslot_position}=  Get Index From List  ${trx_timeslot_type_list}  SDCCH
    ${timeslot_list}=  Evaluate  list(range(0, 8))
    Remove Values From List  ${timeslot_list}  ${mbcch_timeslot_position}  ${sdcch_timeslot_position}

    Wait Until Keyword Succeeds  5m  1m
    ...  Change Administrative State Of Timeslots For TRXes  ${gsm_sector_id}  ${trx_id}  ${timeslot_list}  lock  False


Prepare GSM Sector For Shared Spectrum Usage - Teardown
    [Documentation]
    ...  This KW is used to restore GSM sector configuration after using KW Prepare GSM Sector For Shared Spectrum Usage.
    ...
    ...  | **Author:** igor.binkowski@nokia.com
    ...  | **Maintainer:** adam.chamera@nokia.com
    ...
    ...  | **Full description:**
    ...  | This keyword is used to restore GSM sector configuration after using keyword
    ...  | Prepare GSM Sector For Shared Spectrum Usage. It will unlock all timeslots and turn on GTRX in all TRXes
    ...  | of the given GSM sector.
    ...  |
    ...  | Note:
    ...  |   - Telnet session to BSC must be open
    ...
    ...  **Input parameters:**
    ...
    ...  +----------------+------------+-----------------------------------------------+
    ...  | Parameter name | Mandatory? | Description                                   |
    ...  +================+============+===============================================+
    ...  | gsm_sector_id  | Yes        | ID of GSM BTS which will be reconfigured      |
    ...  +----------------+------------+-----------------------------------------------+
    ...  | connection     | No         | Alias for admin connection from which         |
    ...  |                |            | cell data is needed. Default value: default.  |
    ...  +----------------+------------+-----------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...
    ...     Prepare GSM Sector For Shared Spectrum Usage - Teardown  420

    [Arguments]  ${gsm_sector_id}  ${connection}=default

    ${trx_ids}=  hran_bsc.Get TRXs List By BTS ID  ${gsm_sector_id}  alias=False
    ${timeslot_range_0_7}=  Create List  0  7
    hran_bsc.Lock Sector  ${gsm_sector_id}
    FOR  ${trx_id}  IN  @{trx_ids}
        Wait Until Keyword Succeeds  5m  1m
        ...  Change Administrative State Of Timeslots For TRXes  ${GSM_SECTOR_ID}  ${trx_id}  ${timeslot_range_0_7}  unlock  True
        Toggle GPRS In GSM TRX  ON  ${GSM_SECTOR_ID}  ${trx_id}
    END
    hran_bsc.Unlock Sector  ${gsm_sector_id}
    ${gsm_cell_runtime_distname} =  Get Runtime Dist Name For GSM Sector  ${gsm_sector_id}  ${connection}

    ${gsm_online_states}=  Run Keyword If  ${CNI-61110_STATUS}
    ...                    Catenate  SEPARATOR=
    ...                                           operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked",
    ...                                           blockingState=regex"[Uu]nblocked"
    ...  ELSE               Catenate  SEPARATOR=  availabilityStatus=Online,
    ...                                           operationalState=Enabled,
    ...                                           administrativeState=Unlocked,
    ...                                           blockingState=Unblocked
    Wait Until Keyword Succeeds  4min  10s  _check gsm cell state helper  ${gsm_cell_runtime_distname}
    ...  ${gsm_online_states}  ${connection}
    Log  Sector-${gsm_sector_id} is back On Air with timeslots mentioned above unlocked!  console=True


Collect BSC Logs
    [Documentation]
    ...  This KW collects logs from BSC and saves them to ${BTSFiles}/BSC_logs.txt.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | This KW collects logs from BSC and saves them to ${BTSFiles}/BSC_logs.txt.
    ...  | Commands for which logs are collected: "ZEEI:BCF=${bcf_id};",
    ...  | "ZEQO:BTS=${sector_id}:ALL;", "ZERO:BTS=${sector_id};".
    ...  | This KW opens and closes BSC session. BCF ID for this KW is found in IM
    ...  | if this fails this KW will try to get BCF ID form SCF defined in global
    ...  | variable ${COMMISSIONING_PATH}.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                          |
    ...  +================+======+======================================================================+
    ...  | bsc_logs_file  | No   | Absolute path to file in which BSC logs will be saved.               |
    ...  |                |      | Default value: ${BTSFiles}/misc_logs/BSC_logs.txt                    |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Collect BSC Logs

    [Arguments]  ${bsc_logs_file}=${BTSFiles}/misc_logs/BSC_logs.txt  ${alias}=default
    Log  Collecting BSC logs  console=True
    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_${timestamp}  alias=${alias}
    ${bcf_id} =  Get Parameter Value From SCF  ${parsed_scf}  GNBCF  GNBCF  /p[@name='bcfId']
    Create File  ${bsc_logs_file}  BCF ID=${bcf_id}\r\n
    ca_INTER_RAT.Open session to BSC
    ${bcf_status} =  Wait Until BSC Command Succeeds  ZEEI:BCF=${bcf_id};
    Append To File  ${bsc_logs_file}  Command sent:ZEEI:BCF=${bcf_id};\r\n${bcf_status}\r\n\r\n
    ${sector_ids} =  Get Sectors Ids    bcf_id=${bcf_id}    alias=${False}
    FOR  ${sector_id}  IN  @{sector_ids}
        ${bts_parameters} =  Wait Until BSC Command Succeeds  ZEQO:BTS=${sector_id}:ALL;
        Append To File  ${bsc_logs_file}
        ...  SECTOR ID=${sector_id}\r\nCommand sent:ZEQO:BTS=${sector_id}:ALL;\r\n${bts_parameters}\r\n\r\n
        ${trxes} =  hran_bsc.Get TRXs List By BTS ID  bts_id=${sector_id}  alias=${False}
        ${all_trx_view} =  Wait Until BSC Command Succeeds  ZERO:BTS=${sector_id};
        Append To File  ${bsc_logs_file}
        ...  SECTOR ID=${sector_id}\r\nCommand sent:ZERO:BTS=${sector_id};\r\n${all_trx_view}\r\n\r\n
    END
    [Teardown]  ca_INTER_RAT.Close All BSC Sessions


Wait Until BSC Command Succeeds
    [Documentation]
    ...  This KW runs BSC command and retries it if output does not contain command
    ...  or phrase 'COMMAND EXECUTED'.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | This KW runs BSC command and retries it if output does not contain command
    ...  | or phrase 'COMMAND EXECUTED'. This KW uses 'Wait Until Keyword Succeeds',
    ...  | so parameters 'retry' and 'retry_interval' are responsible for the same
    ...  | actions as in this KW. It requires open BSC connection.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                          |
    ...  +================+======+======================================================================+
    ...  | command        | Yes  | Command that should be sent to BSC. E.g. ZEEI:BCF=1111;              |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | retry          | No   | Max amount of times or timeout for retrying BSC command. The same    |
    ...  |                |      | as in KW 'Wait Until Keyword Succeeds'                               |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | retry_interval | No   | Interval between last and next attempt to run BSC command. The same  |
    ...  |                |      | as in KW 'Wait Until Keyword Succeeds'                               |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${output} =  Wait Until BSC Command Succeeds  ZEQO:BTS=123:ALL;  2min  30s

    [Arguments]  ${command}  ${retry}=2x  ${retry_interval}=10s
    ${output} =  Wait Until Keyword Succeeds  ${retry}  ${retry_interval}
    ...          Send BSC Command With Simple Output Checking  ${command}
    [Return]  ${output}


Send BSC Command With Simple Output Checking
    [Documentation]
    ...  This KW sends given command to BSC and checks if this command and phrase
    ...  'COMMAND EXECUTED' appeared in output.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | This KW sends given command to BSC and checks if this command and phrase
    ...  | 'COMMAND EXECUTED' appeared in output. It requires open BSC connection.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                          |
    ...  +================+======+======================================================================+
    ...  | command        | Yes  | Command that should be sent to BSC. E.g. ZEEI:BCF=1111;              |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${output} =  Send BSC Command With Simple Output Checking  ZEQO:BTS=123:ALL;

    [Arguments]  ${command}
    hran_bsc.Write  ${command}
    ${output} =  hran_bsc.Read Until  COMMAND EXECUTED
    Should End With  ${output}  COMMAND EXECUTED
    [Return]  ${output}


Get BCF ID From SCF
    [Documentation]
    ...  This KW gets ID of BCF from SCF.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | This KW gets ID of BCF from SCF. If no value is given for 'scf_path'
    ...  | path set in global variable 'COMMISSIONING_PATH' is used.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                          |
    ...  +================+======+======================================================================+
    ...  | scf_path       | No   | Absolute path to SCF file. Default value:${COMMISSIONING_PATH}.      |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${bcf_id} =  Get BCF ID From SCF

    [Arguments]  ${scf_path}=${COMMISSIONING_PATH}
    ${scf}=  Parse XML  ${scf_path}
    ${bcf_id} =  Get Element Text  ${scf}  .//managedObject[contains(@distName, 'GNBCF')]/p[@name="bcfId"]
    [Return]  ${bcf_id}


Prepare UE For Data Transfer
    [Arguments]  ${ue_alias}  ${cell_id}  ${ip_check}=True  ${retry}=3x  ${retry_interval}=2min  ${connection}=default
    ...  ${lte_cell}=True
    Wait Until Keyword Succeeds  ${retry}  ${retry_interval}
    ...  prepare ue for data transfer helper  ${ue_alias}  ${cell_id}  ${ip_check}  ${connection}  ${lte_cell}


_prepare ue for data transfer helper
    [Arguments]  ${ue_alias}  ${cell_id}  ${ip_check}  ${connection}=default  ${lte_cell}=True
    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Run Keywords
    ...         Log  ${ue_alias} was not in given cell or was not granted an IP address. Trying again...  console=True  AND  Detach UE  ${ue_alias}

    Attach UE   ${ue_alias}  timeout=30

    ${lte_cell_id} =  Run Keyword If  ${lte_cell}  Get LTE E-UTRAN Cell ID based on Global Cell ID  ${cell_id}  ${connection}
    ...  ELSE  Get NR Cell ID based on Global Cell ID  ${cell_id}  ${connection}
    ${cell_id} =  Set Variable If  ${lte_cell_id}  ${lte_cell_id}  ${cell_id}

    ${cell_id_string}=  Convert To String  ${cell_id}
    ${cell_id}=  Set Variable If  type(${cell_id}) is not bytes  ${cell_id_string}  ${cell_id}

    Wait Until Keyword Succeeds  5x  10s  Validate UE Info  ${ue_alias}  CELL_ID  ${cell_id}
    ${ue_ip}=  Run Keyword If  ${ip_check}  Wait Until Keyword Succeeds  5x  10s  Get UE Info  ${ue_alias}  IP
    ...  ELSE  Set Variable  ${None}
    Run Keyword If  ${ip_check}  Should Match Regexp  ${ue_ip}  \\d+\\.\\d+\\.\\d+\\.\\d+


Get WCDMA Cells IDs
    [Documentation]
    ...  This KW gets IDs of WCDMA cells from admin.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                          |
    ...  +================+======+======================================================================+
    ...  | alias          | No   | Alias of admin connection from which cell IDs should be collected.   |
    ...  |                |      | Default value: default.                                              |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${wcdma_cell_ids} =  Get WCDMA Cells IDs  eNB_slave

    [Arguments]  ${alias}=default
    Log  Collecting WCDMA cell IDs from ADMIN API.
    ${all_cells} =  Get Cell List  connection=${alias}
    ${all_cells} =  Get From Dictionary  ${all_cells}  cells
    ${wcdma_cell_objects} =  Get From Dictionary  ${all_cells}  wcdma
    ${wcdma_cell_ids} =  Evaluate  [x['cellId'] for x in @{wcdma_cell_objects}]
    [Return]  ${wcdma_cell_ids}


Get LTE Cells IDs
    [Documentation]
    ...  This KW gets IDs of LTE cells from admin.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                          |
    ...  +================+======+======================================================================+
    ...  | alias          | No   | Alias of admin connection from which cell IDs should be collected.   |
    ...  |                |      | Default value: default.                                              |
    ...  +----------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${lte_cell_ids} =  Get LTE Cells IDs  eNB_slave

    [Arguments]  ${alias}=default
    Log  Collecting LTE cell IDs from ADMIN API.
    ${all_cells} =  Get Cell List  connection=${alias}
    ${all_cells} =  Get From Dictionary  ${all_cells}  cells
    ${lte_cell_objects} =  Get From Dictionary  ${all_cells}  lte
    ${lte_cell_ids} =  Evaluate  [x['cellId'] for x in @{lte_cell_objects}]
    [Return]  ${lte_cell_ids}


Verify If WL DSS/SSS Is Enabled - Cell Distance
    [Documentation]
    ...  This KW verifies if WL DSS/SSS is enabled for specified cells, by checking distance
    ...  between centre frequencies of paired WCDMA and LTE cells.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW verifies if WCDMA+LTE DSS/SSS feature (RP002167, RP002546) is enabled
    ...  | for specified WCDMA-LTE cell pairs, by checking if distance between centre
    ...  | frequencies of those paired cells is in correct range <2.5 MHz; 2.6 MHz> (dlChBw=10 MHz),
    ...  | <4.9 MHz; 5.1 MHz> (dlChBw=15 MHz) or <7.4 MHz; 7.6 MHz> (dlChBw=20 MHz). It returns True
    ...  | if the distance for all cell pairs is in this range or False if it is not
    ...  | for any of the cell pairs.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-----------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                     |
    ...  +================+======+=================================================================+
    ...  | cell_mapping   | Yes  | Dictionary containing pairs of WCMDA cell IDs (keys) and LTE    |
    ...  |                |      | cell IDs (values) for which distance of their centre            |
    ...  |                |      | frequencies will be verified.                                   |
    ...  +----------------+------+-----------------------------------------------------------------+
    ...  | connection     | No   | Alias for admin connection to get parameters from cells.        |
    ...  |                |      | Default value: default.                                         |
    ...  +----------------+------+-----------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${cell_mapping} =   Create Dictionary  11123  22234
    ...     ${dss_enabled} =    Verify If WL DSS/SSS Is Enabled - Cell Distance  ${cell_mapping}

    [Arguments]  ${cell_mapping}  ${connection}=default

    ${lte_cells} =  Get Cells Info  lte  connection=${connection}
    ${wcdma_cells} =  Get Cells Info  wcdma  connection=${connection}
    ${dss_enabled_for_all} =  Set Variable  ${TRUE}
    FOR  ${wcdma_cell_id}  IN  @{cell_mapping}
        ${lte_cell_id} =    Get From Dictionary  ${cell_mapping}   ${wcdma_cell_id}
        ${lte_bw} =  Evaluate  [x['downlinkChannelBandwidth'] for x in @{lte_cells} if x['globalCellId'] == ${lte_cell_id}][0]
        ${min_distance} =  Set Variable If  '${lte_bw}' == '10 MHz'  ${2500000}
        ...                                 '${lte_bw}' == '15 MHz'  ${4900000}
        ...                                 '${lte_bw}' == '20 MHz'  ${7400000}
        ${max_distance} =  Set Variable If  '${lte_bw}' == '10 MHz'  ${2600000}
        ...                                 '${lte_bw}' == '15 MHz'  ${5100000}
        ...                                 '${lte_bw}' == '20 MHz'  ${7600000}

        Log  Checking distance betwen LTE cell=${lte_cell_id} and WCDMA cell=${wcdma_cell_id}...  console=True

        ${lte_center_freq} =  Evaluate  [x['downlinkFrequency'] for x in @{lte_cells} if x['globalCellId'] == ${lte_cell_id}][0]
        ${lte_center_freq} =  Evaluate  ${lte_center_freq} * 1000000.0
        ${wcdma_center_freq} =  Evaluate  [x['downlinkFrequency'] for x in @{wcdma_cells} if x['cellId'] == ${wcdma_cell_id}][0]
        ${lcell_wcell_distance} =  Evaluate  abs(${lte_center_freq} - ${wcdma_center_freq})
        ${dss_enabled} =  Evaluate  ${min_distance} <= ${lcell_wcell_distance} <= ${max_distance}
        ${log} =  Catenate  Distance between LTE and WCDMA centre frequency is not in range <${min_distance} Hz; ${max_distance} Hz>.
        ...                             \nDistance: (${lcell_wcell_distance} Hz)
        Run Keyword If  ${dss_enabled}
        ...        Log  Distance between LTE and WCDMA centre frequency is in range <${min_distance} Hz; ${max_distance} Hz>.  console=True
        ...  ELSE  Log  ${log}  console=True
        ${dss_enabled_for_all} =  Set Variable If  ${dss_enabled}  ${dss_enabled_for_all}  ${FALSE}
    END

    [Return]  ${dss_enabled_for_all}


Get LCELX ID From Cell ID
    [Documentation]
    ...  This KW returns ID of LCELL, LCELW or LCELC object for specified cell.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------+------+----------------------------------------------------------+
    ...  | Parameter     | Man. | Description                                              |
    ...  +===============+======+==========================================================+
    ...  | cell_id       | Yes  | Cell ID.                                                 |
    ...  +---------------+------+----------------------------------------------------------+
    ...  | rat           | Yes  | RAT of specified cell. Possible values: LTE, WCDMA, GSM. |
    ...  +---------------+------+----------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${lcr_id} =  Get LCELX ID From Cell ID  11122  LTE

    [Arguments]  ${cell_id}  ${rat}

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_full_${timestamp}

    ${lcr_id} =   Run Keyword If  '${rat}'.upper() == 'LTE'    Get Parameter Value From SCF  ${parsed_scf}  LNCEL  LNCEL-${cell_id}
    ...                                                        /p[@name='lcrId']  dist_name_substring=True
    ...           ELSE IF         '${rat}'.upper() == 'WCDMA'  _get lcelw id from cell id helper  ${parsed_scf}  ${cell_id}
    ...           ELSE IF         '${rat}'.upper() == 'GSM'    _get lcelc id from cell id helper  ${parsed_scf}  ${cell_id}
    ...                                                        ${connection}
    [Return]  ${lcr_id}


Check If UARFCN On RNC And Default Carrier In IM Are The Same For A Cell
    [Documentation]
    ...  This KW checks if UARFCN in WCEL object on OMS has the same value as default carrier
    ...  parameter in WNCEL object.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW checks if UARFCN in WCEL object on OMS has the same value as default
    ...  | carrier parameter in WNCEL object. It requires NWI3 connection parameters to
    ...  | be set before running this KW.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                                   |
    ...  +================+======+===============================================================================+
    ...  | wcdma_cell_id  | Yes  | Cell ID of cell which should have it's UARFCN verified.                       |
    ...  +----------------+------+-------------------------------------------------------------------------------+
    ...  | connection     | Yes  | Alias for admin connection for saving SCF. Default value: default.            |
    ...  +----------------+------+-------------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${dss_equal} =  Check If UARFCN On RNC And Default Carrier In IM Are The Same For A Cell  12345

    [Arguments]  ${wcdma_cell_id}  ${connection}=default
    Log  \nChecking if UARFCN On RNC And defaultCarrier in SCF are the same for cell ${wcdma_cell_id}...  console=True

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_full_${timestamp}  alias=${connection}

    ${uarfcn} =  Get Parameter Value From SCF  ${parsed_scf}  WNCEL  WNCEL-${wcdma_cell_id}
    ...  /p[@name='defaultCarrier']  dist_name_substring=True
    ${param_name_value} =  Create Dictionary  UARFCN=${uarfcn}
    ${param_name} =  Create List  UARFCN
    ${dss_equal} =  Check If Current WCEL Params Have Desired Values  ${wcdma_cell_id}  ${param_name_value}  ${param_name}
    Run Keyword If  ${dss_equal}
    ...        Log  UARFCN parameter in WCEL and defaultCarrier value in WNCEL are equal: defaultCarrier:${uarfcn} UARFCN.
    ...             console=True
    ...  ELSE  Log
    ...  There is a mismatch between UARFCN parameter in WCEL and defaultCarrier value in WNCEL: defaultCarrier:${uarfcn} UARFCN
    ...  console=True
    [Return]  ${dss_equal}


Get Cell ID From LCELX ID
    [Documentation]
    ...  This KW returns ID of cell for specified LCELL, LCELW or LCELC ID.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------+------+----------------------------------------------------------+
    ...  | Parameter     | Man. | Description                                              |
    ...  +===============+======+==========================================================+
    ...  | lcr_id        | Yes  | LCELL, LCELW or LCELC ID.                                |
    ...  +---------------+------+----------------------------------------------------------+
    ...  | rat           | Yes  | RAT of specified cell. Possible values: LTE, WCDMA, GSM. |
    ...  +---------------+------+----------------------------------------------------------+
    ...  | connection    | Yes  | Alias for admin connection. Default value: default.      |
    ...  +---------------+------+----------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${cell_id} =  Get Cell ID From LCELX ID  12  LTE

    [Arguments]  ${lcr_id}  ${rat}  ${connection}=default

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_full_${timestamp}  alias=${connection}
    ${cell} =  Run Keyword If  '${rat}'.upper() == 'LTE'    Get DistName Attribute From SCF  ${parsed_scf}  LNCEL  LNCEL
    ...                                                     /p[@name='lcrId'][.='${lcr_id}']/..
    ...        ELSE IF         '${rat}'.upper() == 'WCDMA'  _get wcdma cell id from lcelw id helper  ${parsed_scf}  ${lcr_id}
    ...        ELSE IF         '${rat}'.upper() == 'GSM'    _get gsm cell id from lcelc id helper  ${parsed_scf}  ${lcr_id}  ${connection}
    Return From Keyword If  '${rat}'.upper() == 'GSM'  ${cell}
    Run Keyword And Return  Fetch From Right  ${cell}  marker=-
    [Return]  ${cell_id}


_get wcdma cell id from lcelw id helper
    [Arguments]  ${parsed_scf}  ${lcr_id}
    ${lcelw_dist_name_list} =  Get DistName Attribute From SCF  ${parsed_scf}  LCELW  LCELW  return_list=True
    ${dist_name_part}  ${_} =  Split String From Right  ${lcelw_dist_name_list[0]}  separator=-  max_split=1
    ${lcelw_dist_name} =  Get DistName Attribute From SCF  ${parsed_scf}  WNCEL  WNCEL
    ...  /p[@name='lCelwDN'][.='${dist_name_part}-${lcr_id}']/..
    [Return]  ${lcelw_dist_name}


_get gsm cell id from lcelc id helper
    [Arguments]  ${parsed_scf}  ${lcelc_id}  ${connection}=default
    ${gncel_dist_name} =  Get DistName Attribute From SCF  ${parsed_scf}  GNCEL  GNCEL
    ...  /p[@name='lcelcId'][.='${lcelc_id}']/..
    ${scf_gsm_cell_id} =  Fetch From Right  ${gncel_dist_name}  marker=-
    ${all_cells} =  Get Cell List  connection=${connection}
    ${gsm_cell_objects} =  Get From Dictionary  ${all_cells['cells']}  gsm
    ${gsm_sector_id} =  Evaluate  [x['gsmSectorID'] for x in @{gsm_cell_objects} if x['id']['configuration'] == '${scf_gsm_cell_id}']
    [Return]  ${gsm_sector_id}


Basic Verification Of WL DSS/SSS Enabling
    [Documentation]
    ...  This KW is wrapper for KWs performing basic verification if WL DSS/SSS (RP002167, RP002546) is enabled.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW is wrapper for KWs performing basic verification if WL DSS/SSS (RP002167, RP002546) is enabled.
    ...  | By default, verification will be done in all WCDMA and LTE cells. If parameter 'cell_ids'
    ...  | is passed verification will be performed for cells from this parameter regardless
    ...  | of 'cell_selection' value. Variable 'rat' needs to be set correctly only if 'cell_ids'
    ...  | is used. If 'check_chbw' is set to False channel bandwidth verification will not be performed.
    ...  | If it is set to True then either not-empty dictinary needs to be passed in 'lcell_data_dict'
    ...  | variable or 'NEW_EARFCN' global dictionary needs to exist. 'lcell_data_dict' should contain
    ...  | dictionary with 'LCELL-ID' as key and dictionary with 'chBw' and value of 'dlChBw' as values.
    ...
    ...  **Input parameters:**
    ...
    ...  +--------------------+------------+------------------------------------------------------+
    ...  | Parameter          | Mandatory? | Description                                          |
    ...  +--------------------+------------+------------------------------------------------------+
    ...  | cell_ids           | No         | Cell ID or list of cell IDs of WCDMA or LTE RAT.     |
    ...  |                    |            | Default value: None.                                 |
    ...  +--------------------+------------+------------------------------------------------------+
    ...  | rat                | No         | RAT of cells given in 'cell_id' variable. Possible   |
    ...  |                    |            | values: 'WCDMA', 'LTE'. Default value: WCDMA.        |
    ...  +--------------------+------------+------------------------------------------------------+
    ...  | cell_selection     | No         | When equal to 'All', verification will be done in    |
    ...  |                    |            | all WCDMA cells and their corresponding LTE cells.   |
    ...  |                    |            | When equal to 'Any', it will be checked if DSS/SSS   |
    ...  |                    |            | is enabled in any WCDMA cell and its corresponding   |
    ...  |                    |            | LTE cell.                                            |
    ...  +--------------------+------------+------------------------------------------------------+
    ...  | dss_or_sss         | No         | Variable defining if KW is used for DSS or SSS.      |
    ...  |                    |            | Possible values: DSS, SSS. Default value: DSS.       |
    ...  +--------------------+------------+------------------------------------------------------+
    ...  | check_chbw         | No         | Boolean variable enabling verification of channel    |
    ...  |                    |            | bandwidth. Default value is ${FALSE}.                |
    ...  +--------------------+------------+------------------------------------------------------+
    ...  | lcell_data_dict    | No         | Dictionary containing 'LCELL-ID' as key              |
    ...  |                    |            | and dictionary with 'chBw' and its value as values.  |
    ...  |                    |            | Default value is ${EMPTY}. If not-empty dictionary   |
    ...  |                    |            | is not assigned to this variable when 'check_chbw'   |
    ...  |                    |            | is True this KW will try to assign to it             |
    ...  |                    |            | 'NEW_EARFCN' global variable. If it doesn't exist    |
    ...  |                    |            | it will then fail.                                   |
    ...  +--------------------+------------+------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Basic Verification Of WL DSS/SSS Enabling

    [Arguments]  ${cell_ids}=${None}  ${rat}=WCDMA  ${cell_selection}=All  ${dss_or_sss}=DSS
    ...  ${check_chbw}=${FALSE}  ${lcell_data_dict}=${EMPTY}

    ${lcell_data_dict} =  Set Variable If  ${check_chbw} and not "${lcell_data_dict}"  ${NEW_EARFCN}  ${lcell_data_dict}
    ${wcdma_dss_cell_ids}  ${lte_dss_cell_ids}  ${wcdma_lcg_ids}  ${dss_mapping_cell_dict}=
    ...  get lists of wcdma cells, lte cells and wcdma lcgs for wl dss/sss verification
    ...  ${cell_ids}  ${rat}  ${cell_selection}  ${dss_or_sss}

    Basic Verification Of WL DSS/SSS Enabling: Initial Configuration Verification  ${wcdma_dss_cell_ids}
    ...                                                                            ${lte_dss_cell_ids}
    ...                                                                            ${wcdma_lcg_ids}
    ...                                                                            ${lcell_data_dict}
    ...                                                                            ${dss_or_sss}

    Check If UARFCN On RNC And Default Carrier In IM Are The Same For All Given Cells  ${wcdma_dss_cell_ids}
    Basic Verification Of WL DSS/SSS Enabling: Alarms Verification  ${dss_mapping_cell_dict}

    ${all_cell_distances_passed} =  Verify If WL DSS/SSS Is Enabled - Cell Distance
    ...                            ${dss_mapping_cell_dict}
    Run Keyword Unless  ${all_cell_distances_passed}
    ...  Fail  msg=${dss_or_sss} is disabled. Cell distance for one or more cell pairs is not in the correct range.

    Log  ${dss_or_sss} for WCDMA+LTE is active.  console=True

    Run Keyword If  ${cell_ids}
    ...        Log  Verification of WL ${dss_or_sss} enabling in ${rat} cells ${cell_ids} successful!  console=True
    ...  ELSE  Log  Verification of WL ${dss_or_sss} enabling in ${cell_selection} WCDMA cells and corresponding LTE cells successful!  console=True


_get lists of wcdma cells, lte cells and wcdma lcgs for wl dss/sss verification
    [Arguments]  ${cell_ids}=${None}  ${rat}=WCDMA  ${cell_selection}=All  ${dss_or_sss}=DSS

    ${cell_ids} =  Run Keyword If  not ${cell_ids} or (${cell_ids} and type(${cell_ids}) is list)
    ...                        Set Variable  ${cell_ids}
    ...  ELSE IF  ${cell_ids}  Create List   ${cell_ids}

    Run Keyword If  ${cell_ids}
    ...        Log  Performing verification of WL ${dss_or_sss} enabling in: ${cell_ids} ${rat} cell(s).  console=True
    ...  ELSE IF  '${cell_selection}' == 'All' and not ${cell_ids}
    ...        Log  Performing verification of WL ${dss_or_sss} enabling in all WCDMA and LTE cell pairs.  console=True
    ...  ELSE  Log  Performing verification of WL ${dss_or_sss} enabling in any WCDMA and LTE cell pair.  console=True

    ${dss_mapping_cell_dict} =  Run Keyword  Get IDs Of LTE And WCDMA Cells Where WL ${dss_or_sss} Is Enabled
    ${wcdma_dss_cell_ids} =     Get Dictionary Keys    ${dss_mapping_cell_dict}
    ${lte_dss_cell_ids} =       Get Dictionary Values  ${dss_mapping_cell_dict}
    _check if specified cells are in dss cells' list  ${wcdma_dss_cell_ids}  ${lte_dss_cell_ids}
    ...                                               ${cell_ids}  ${rat}  ${cell_selection}  ${dss_or_sss}
    ${paired_wcdma_cell_ids} =  Run Keyword If  '${rat}' == 'LTE' and ${cell_ids}
    ...                                          Evaluate  [x for x, y in ${dss_mapping_cell_dict}.items() if y in ${cell_ids}]
    ...                         ELSE IF         '${rat}' == 'WCDMA' and ${cell_ids}  Set Variable  ${cell_ids}
    ...                         ELSE                                                 Set Variable  ${wcdma_dss_cell_ids}
    ${paired_lte_cell_ids} =    Run Keyword If  '${rat}' == 'WCDMA' and ${cell_ids}
    ...                                          Evaluate  [y for x, y in ${dss_mapping_cell_dict}.items() if x in ${cell_ids}]
    ...                         ELSE IF         '${rat}' == 'LTE' and ${cell_ids}    Set Variable  ${cell_ids}
    ...                         ELSE                                                 Set Variable  ${lte_dss_cell_ids}
    ${wcdma_lcg_ids} =  Run Keyword If  '${cell_selection}' == 'All' and not ${cell_ids}
    ...                 Get All WCDMA LCG IDs
    ...                 ELSE IF  '${cell_selection}' == 'Any' and not ${cell_ids}
    ...                 Run Keyword  Get IDs Of WCDMA LCGs Where Cells With WL ${dss_or_sss} Exist
    ...                 ELSE  get wcdma lcg ids for cell list  ${paired_wcdma_cell_ids}
    Keep In Dictionary  ${dss_mapping_cell_dict}  @{paired_wcdma_cell_ids}
    [Return]  ${paired_wcdma_cell_ids}  ${paired_lte_cell_ids}  ${wcdma_lcg_ids}  ${dss_mapping_cell_dict}


_get wcdma lcg ids for cell list
    [Arguments]  ${cell_ids}
    ${lcg_ids} =  Create List
    ${cell_lcg_dict} =  Create Cells And LCG IDs Dictionary
    FOR  ${cell_id}  IN  @{cell_ids}
        ${lcg_id} =  Get LCG ID For Cell  ${cell_id}  ${cell_lcg_dict}
        Append To List  ${lcg_ids}  ${lcg_id}
    END
    Remove Duplicates  ${lcg_ids}
    [Return]  ${lcg_ids}


_check if specified cells are in dss cells' list
    [Arguments]  ${wcdma_dss_cell_ids}  ${lte_dss_cell_ids}  ${cell_ids}  ${rat}  ${cell_selection}  ${dss_or_sss}
    ${wcdma_cell_ids} =  Run Keyword If  ${cell_ids} and '${rat}'.upper() == 'WCDMA'  Set Variable  ${cell_ids}
    ...                  ELSE                                                         Get WCDMA Cells IDs
    ${lte_cell_ids}=     Run Keyword If  ${cell_ids} and '${rat}'.upper() == 'LTE'    Set Variable  ${cell_ids}
    ...                  ELSE                                                         Get LTE Cells IDs

    ${all_cells_are_in_list} =  Run Keyword If  ${cell_ids} and '${rat}'.upper() == 'LTE'
    ...  Evaluate  all(item in ${lte_dss_cell_ids} for item in ${lte_cell_ids})
    ...  ELSE IF  ${cell_ids} and '${rat}'.upper() == 'WCDMA'
    ...  Evaluate  all(item in ${wcdma_dss_cell_ids} for item in ${wcdma_cell_ids})
    ...  ELSE IF  '${cell_selection}' == 'All' and not ${cell_ids}
    ...  Evaluate  all(item in ${lte_dss_cell_ids} for item in ${lte_cell_ids}) and all(item in ${wcdma_dss_cell_ids} for item in ${wcdma_cell_ids})
    ...  ELSE  Set Variable  ${TRUE}
    Run Keyword Unless  ${all_cells_are_in_list}  Fail  List of cells with enabled ${dss_or_sss} WL is different than list of all cells.


Basic Verification Of WL DSS/SSS Enabling: Initial Configuration Verification
    [Documentation]
    ...  This KW performs basic verification if WL DSS/SSS is enabled - configured correctly by tester.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW performs basic verification if WCDMA+LTE DSS/SSS (RP002167, RP002546) is enabled.
    ...  | In this KW it is only verified if basic configuration prepared by tester
    ...  | is correct. It does not verify if values for DSS/SSS mapping in SCF are correct
    ...  | it only checks if parameter 'sharedSpectrumWcdmaCellDN' in LCELL is not empty.
    ...  | This KW checks for passed WCDMA cells, WCDMA LCGs and LTE cells if:
    ...  | - LCELL objects for passed LTE cells have actWcdmaLteSharedSpectrum=true
    ...  |   and not empty sharedSpectrumWcdmaCellDN
    ...  | - LCELW objects for passed WCDMA cells have
    ...  |   actWcdmaLteSharedSpectrum="Dynamic Shared Spectrum" for DSS or
    ...  |   actWcdmaLteSharedSpectrum="Static Shared Spectrum"
    ...  |   and wcdmaFilteredBandwidthDL!=empty for SSS
    ...  | - WNCELG objects for passed WCDMA LCG IDs have not empty dssLoadFactorDCH,
    ...  |   dssLoadFactorHSDPA, dssLoadThresholdHigh and dssLoadThresholdMedium for DSS
    ...  | - LNCEL_FDD objects for passed LTE cells have actAutoPucchAlloc=true
    ...  |   and ulChBw, dlChBw with correct values depending on LTE cells' channel
    ...  |   bandwidth defined by user in 'lcell_data_dict' variable
    ...  | - LNCEL objects for passed LTE cells have dlsDciCch="DCI format 1A"
    ...  | - LNBTS object has actEnhAcAndGbrServices=true
    ...  | This KW fails if any of the above conditions are not met in checked cells or LCGs.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------------+--------------------------------------------------------+
    ...  | Parameter        | Mandatory? | Description                                            |
    ...  +------------------+------------+--------------------------------------------------------+
    ...  | wcdma_cell_ids   | Yes        | IDs of WCDMA cells in which the enabling               |
    ...  |                  |            | of DSS/SSS will be checked.                            |
    ...  +------------------+------------+--------------------------------------------------------+
    ...  | lte_cell_ids     | Yes        | IDs of LTE cells in which the enabling                 |
    ...  |                  |            | of DSS/SSS will be checked.                            |
    ...  +------------------+------------+--------------------------------------------------------+
    ...  | wcdma_lcg_ids    | Yes        | IDs of WCDMA LCGs in which the enabling                |
    ...  |                  |            | of DSS/SSS will be checked.                            |
    ...  +------------------+------------+--------------------------------------------------------+
    ...  | lcell_data_dict  | Yes        | Dictionary containing 'LCELL-ID' as key                |
    ...  |                  |            | and dictionary with 'chBw' and its value as values.    |
    ...  |                  |            | Default value is global variable 'NEW_EARFCN'.         |
    ...  +------------------+------------+--------------------------------------------------------+
    ...  | dss_or_sss       | No         | Variable defining if KW is used for DSS or SSS.        |
    ...  |                  |            | Possible values: DSS, SSS. Default value: DSS.         |
    ...  +------------------+------------+--------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${wcdma_cell_ids} =  Create List  11122  11222  11322
    ...     ${lte_cell_ids} =    Create List  55122  15522  16722
    ...     ${wcdma_lcg_ids} =   Get IDs Of WCDMA LCGs Where Cells With WL DSS Exist
    ...     Basic Verification Of WL DSS/SSS Enabling: Initial Configuration Verification
    ...     ...  ${wcdma_cell_ids}  ${lte_cell_ids}  ${wcdma_lcg_ids}

    [Arguments]  ${wcdma_cell_ids}  ${lte_cell_ids}  ${wcdma_lcg_ids}  ${lcell_data_dict}=${NEW_EARFCN}
    ...  ${dss_or_sss}=DSS

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_full_${timestamp}
    ${lcell_id_list} =  Get LCELX ID List From Cell ID List  ${lte_cell_ids}  LTE
    ${lcell_xpath_list} =  Evaluate  ['LCELL-' + x for x in @{lcell_id_list}]

    ${dss_enabled_lcell} =  Check If Every Element From List Exists In SCF  ${parsed_scf}  LCELL  ${lcell_xpath_list}
    ...  /p[@name='actWcdmaLteSharedSpectrum'][.='true']/../p[@name='sharedSpectrumWcdmaCellDN'][.!='']/..
    ...  dist_name_substring=True
    Run Keyword If  ${dss_enabled_lcell}
    ...  Log  All LCELL-[${lcell_id_list}] objects have actWcdmaLteSharedSpectrum=true and not empty sharedSpectrumWcdmaCellDN.  console=True
    ...  ELSE  Log
    ...  ${dss_or_sss} is disabled. Some of LCELL objects do not have actWcdmaLteSharedSpectrum=true or have empty sharedSpectrumWcdmaCellDN.
    ...  level=ERROR

    ${lcelw_params_verification} =  Set Variable If
    ...  '${dss_or_sss}'.upper() == 'DSS'  /p[@name='actWcdmaLteSharedSpectrum'][.='Dynamic Shared Spectrum']
    ...  '${dss_or_sss}'.upper() == 'SSS'
    ...  /p[@name='actWcdmaLteSharedSpectrum'][.='Static Shared Spectrum']/../p[@name='wcdmaFilteredBandwidthDL'][.!='']

    ${lcelw_id_list} =  Get LCELX ID List From Cell ID List  ${wcdma_cell_ids}  WCDMA
    ${lcelw_xpath_list} =  Evaluate  ['LCELW-' + x for x in @{lcelw_id_list}]
    ${dss_enabled_lcelw} =  Check If Every Element From List Exists In SCF  ${parsed_scf}  LCELW  ${lcelw_xpath_list}
    ...  ${lcelw_params_verification}  dist_name_substring=True

    Run Keyword If  ${dss_enabled_lcelw}
    ...  Log  All LCELW-[${lcelw_id_list}] objects have ${lcelw_params_verification}.  console=True
    ...  ELSE  Log  ${dss_or_sss} is disabled. Some of LCELW objects do not have ${lcelw_params_verification}.  level=ERROR

    ${wcdma_lcg_xpath_list} =  Evaluate  ['WNCELG-' + x for x in @{wcdma_lcg_ids}]
    ${wncelg_params_verification} =  Catenate
    ...  /p[@name='dssLoadFactorDCH'][.!='']/../p[@name='dssLoadFactorHSDPA'][.!='']/../p[@name='dssLoadThresholdHigh'][.!='']
    ...  /../p[@name='dssLoadThresholdMedium'][.!='']

    ${dss_enabled_wncelg} =  Run Keyword If  '${dss_or_sss}'.upper() == 'DSS'
    ...  Check If Every Element From List Exists In SCF  ${parsed_scf}  WNCELG  ${wcdma_lcg_xpath_list}
    ...  ${wncelg_params_verification}  dist_name_substring=True
    ...  ELSE  Set Variable  ${TRUE}
    ${log1} =  Catenate	 All WNCELG-[${wcdma_lcg_ids}] objects have not empty: dssLoadFactorDCH, dssLoadFactorHSDPA,
    ...        dssLoadThresholdHigh, dssLoadThresholdMedium.
    ${log2} =  Catenate	 ${dss_or_sss} is disabled. Some of WNCELG objects have empty one or more of the parameters: dssLoadFactorDCH,
    ...        dssLoadFactorHSDPA, dssLoadThresholdHigh, dssLoadThresholdMedium.
    Run Keyword If  ${dss_enabled_wncelg} and '${dss_or_sss}'.upper() == 'DSS'
    ...  Log  ${log1}  console=True
    ...  ELSE IF  not ${dss_enabled_wncelg} and '${dss_or_sss}'.upper() == 'DSS'
    ...  Log  ${log2}  level=ERROR

    ${lte_ids_str} =    Catenate  SEPARATOR=,  @{lte_cell_ids}
    ${dss_enabled_lncel_fdd} =  Verify If DSS/SSS Is Enabled - LNCEL_FDD Objects  ${lte_cell_ids}  ${lcell_data_dict}
    Run Keyword If  ${dss_enabled_lncel_fdd}
    ...  Log  All LNCEL-[${lte_ids_str}]/LNCEL_FDD-* objects have correct ulChBw, dlChBw and actAutoPucchAlloc=true.  console=True
    ...  ELSE  Log  ${dss_or_sss} is disabled. Some of LNCEL_FDD objects do not have correct ulChBw, dlChBw and/or actAutoPucchAlloc=true.
    ...  level=ERROR

    ${lte_cell_xpath_list} =  Evaluate  ['LNCEL-' + x for x in @{lte_cell_ids}]
    ${dss_enabled_lncel} =  Check If Every Element From List Exists In SCF  ${parsed_scf}  LNCEL  ${lte_cell_xpath_list}
    ...  /p[@name='dlsDciCch'][.='DCI format 1A']  dist_name_substring=True

    Run Keyword If  ${dss_enabled_lncel}
    ...  Log  All LNCEL-[${lte_ids_str}] objects have dlsDciCch="DCI format 1A".  console=True
    ...  ELSE  Log  ${dss_or_sss} is disabled. Some of LNCEL objects do not have dlsDciCch="DCI format 1A".  level=ERROR

    ${bts_id} =  Get BTS ID From ADMIN
    ${dss_enabled_lnbts} =  Check If Every Element From List Exists In SCF  ${parsed_scf}  LNBTS  LNBTS-${bts_id}
    ...  /p[@name='actEnhAcAndGbrServices'][.='true']  dist_name_substring=True

    Run Keyword If  ${dss_enabled_lnbts}
    ...  Log  LNBTS-${bts_id} object has actEnhAcAndGbrServices=true.  console=True
    ...  ELSE  Log  ${dss_or_sss} is disabled. Some of LNBTS objects do not have actEnhAcAndGbrServices=true.  level=ERROR

    ${str} =  Catenate  '${dss_or_sss}' + ' is not correctly enabled. Problem occured for:' + 'LCELL, ' * (not ${dss_enabled_lcell}) +
    ...                 'LCELW, ' * (not ${dss_enabled_lcelw}) + 'WNCELG, ' * (not ${dss_enabled_wncelg}) + 'LNCEL_FDD, ' *
    ...                 (not ${dss_enabled_lncel_fdd}) + 'LNCEL, ' * (not ${dss_enabled_lncel}) + 'LNBTS' * (not ${dss_enabled_lnbts}) + '.'
    ${msg} =  Evaluate  ${str}
    ${cond} =  Catenate  ${dss_enabled_lcell} and ${dss_enabled_lcelw} and ${dss_enabled_wncelg} and ${dss_enabled_lncel_fdd} and
    ...                              ${dss_enabled_lncel} and ${dss_enabled_lnbts}
    Should Be True  ${cond}  msg=${msg}


Basic Verification Of WL DSS/SSS Enabling: Alarms Verification
    [Documentation]
    ...  This keyword checks if alarms with any of the fault IDs:
    ...  171, 172, 173, 4387, 4567, 4565 appeared and fails
    ...  if any of them did.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Basic Verification Of WL DSS/SSS Enabling: Alarms Verification

    [Arguments]  ${dss_mapping}
    ${critical_alarms} =  Create List
    FOR  ${fault_id}  IN  171  172  173  4567  4565
        Assert Alarm Inactive  faultId=${fault_id}
    END

    FOR  ${wcell_id}  ${lcell_id}  IN  ${dss_mapping}.keys()  ${dss_mapping}.values()
        Assert Alarm Inactive  faultId=4387,notifier=regex"W(N)?CEL(_R)?-${wcell_id}"
        Assert Alarm Inactive  faultId=4387,notifier=regex"L(N)?CEL(_R)?-${lcell_id}"
    END


Get IDs Of LTE And WCDMA Cells Where WL ${dss_or_sss} Is Enabled
    [Documentation]
    ...  This KW gets IDs of LTE and WCDMAA cells where WL DSS/SSS is enabled.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW gets IDs of LTE and WCDMAA cells where WL DSS/SSS is enabled.
    ...  | It gets mapping from LCELL IM object and checks if LCELW
    ...  | objects in sharedSpectrumWcdmaCellDN parameter of LCELL objects
    ...  | have actWcdmaLteSharedSpectrum="Dynamic Shared Spectrum".
    ...  | If there is no LCELL objects with actWcdmaLteSharedSpectrum=true
    ...  | and not empty sharedSpectrumWcdmaCellDN or if any of LCELW
    ...  | objects in sharedSpectrumWcdmaCellDN do not have
    ...  | actWcdmaLteSharedSpectrum="Dynamic Shared Spectrum" this KW
    ...  | will return an empty dictionary. If mapping is defined correctly
    ...  | it returns dictionary with mapped WCDMA (keys) and LTE (values)
    ...  | cell IDs.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+---------------------------------------------------+
    ...  | Parameter    | Man. | Description                                       |
    ...  +==============+======+===================================================+
    ...  | dss_or_sss   | Yes  | Variable defining if KW is used for DSS or SSS.   |
    ...  |              |      | Possible values: DSS, SSS.                        |
    ...  +--------------+------+---------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${dss_mapping_cell_dict} =  Get IDs Of LTE And WCDMA Cells Where WL DSS Is Enabled

    ${empty_dict} =               Create Dictionary
    ${dss_mapping_cell_dict} =    Create Dictionary
    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_full_${timestamp}
    ${lcell_dist_name_list} =  Get DistName Attribute From SCF  ${parsed_scf}  LCELL  LCELL
    ...  /p[@name='actWcdmaLteSharedSpectrum'][.='true']/../p[@name='sharedSpectrumWcdmaCellDN'][.!='']/..
    ...  return_list=True
    Run Keyword Unless  ${lcell_dist_name_list}
    ...  Run Keywords  Log  There is no object LCELL with actWcdmaLteSharedSpectrum=true and not empty sharedSpectrumWcdmaCellDN.  console=True
    ...  AND           Return From Keyword  ${empty_dict}

    ${lcelw_params_verification} =  Set Variable If
    ...  '${dss_or_sss}'.upper() == 'DSS'  /p[@name='actWcdmaLteSharedSpectrum'][.='Dynamic Shared Spectrum']
    ...  '${dss_or_sss}'.upper() == 'SSS'
    ...  /p[@name='actWcdmaLteSharedSpectrum'][.='Static Shared Spectrum']/../p[@name='wcdmaFilteredBandwidthDL'][.!='']

    FOR  ${lcell_dist_name}  IN  @{lcell_dist_name_list}
        ${lcelw_dist_name} =  Get Parameter Value From SCF  ${parsed_scf}  LCELL  ${lcell_dist_name}  /p[@name='sharedSpectrumWcdmaCellDN']
        ...  dist_name_substring=True
        ${lcell_dist_name_list} =  Get DistName Attribute From SCF  ${parsed_scf}  LCELW  ${lcelw_dist_name}
        ...  ${lcelw_params_verification}/..  dist_name_substring=True
        ${status} =  Run Keyword And Return Status  Check If Element Exists In SCF  ${parsed_scf}  LCELW  ${lcelw_dist_name}
        ...  ${lcelw_params_verification}/..  dist_name_substring=True

        Run Keyword Unless  ${status}
        ...  Run Keywords  Log  There is no object LCELW with ${lcelw_params_verification} paired with ${lcell_dist_name}.  console=True
        ...  AND           Return From Keyword  ${empty_dict}
        ${lte_lcr_id} =    Fetch From Right  ${lcell_dist_name}  marker=-
        ${wcdma_lcr_id} =  Fetch From Right  ${lcelw_dist_name}  marker=-
        ${lte_dss_cell_id} =    Get Cell ID From LCELX ID  ${lte_lcr_id}    LTE
        ${wcdma_dss_cell_id} =  Get Cell ID From LCELX ID  ${wcdma_lcr_id}  WCDMA
        Set To Dictionary  ${dss_mapping_cell_dict}  ${wcdma_dss_cell_id}=${lte_dss_cell_id}
    END

    [Return]  ${dss_mapping_cell_dict}


Get LCELX ID List From Cell ID List
    [Documentation]
    ...  This KW returns IDs of LCELL, LCELW or LCELC objects
    ...  for cell IDs given in a list.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------+------+----------------------------------------------------------+
    ...  | Parameter     | Man. | Description                                              |
    ...  +===============+======+==========================================================+
    ...  | cell_id_list  | Yes  | List with cell IDs.                                      |
    ...  +---------------+------+----------------------------------------------------------+
    ...  | rat           | Yes  | RAT of specified cell. Possible values: LTE, WCDMA, GSM. |
    ...  +---------------+------+----------------------------------------------------------+
    ...  | connection    | Yes  | Alias for admin connection. Default value: default.      |
    ...  +---------------+------+----------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${cell_id_list} =  Create List  11122  11123  11124
    ...     ${lcr_dist_names_list} =  Get LCELX ID From Cell ID  ${cell_id_list}  LTE

    [Arguments]  ${cell_id_list}  ${rat}  ${connection}=default

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_full_${timestamp}
    ${lcr_ids_list} =  Create List
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${lcr_id} =   Run Keyword If  '${rat}'.upper() == 'LTE'    Get Parameter Value From SCF  ${parsed_scf}  LNCEL  LNCEL-${cell_id}
        ...                                                        /p[@name='lcrId']  dist_name_substring=True
        ...           ELSE IF         '${rat}'.upper() == 'WCDMA'  _get lcelw id from cell id helper  ${parsed_scf}  ${cell_id}
        ...           ELSE IF         '${rat}'.upper() == 'GSM'    _get lcelc id from cell id helper  ${parsed_scf}  ${cell_id}
        ...                                                        ${connection}
        Append To List  ${lcr_ids_list}  ${lcr_id}
    END
    [Return]  ${lcr_ids_list}


_get lcelw id from cell id helper
    [Arguments]  ${parsed_scf}  ${cell_id}
    ${lcelw_dist_name} =  Get Parameter Value From SCF  ${parsed_scf}  WNCEL  WNCEL-${cell_id}
    ...  /p[@name='lCelwDN']  dist_name_substring=True
    ${lcelw_id} =  Fetch From Right  ${lcelw_dist_name}  marker=-
    [Return]  ${lcelw_id}


_get lcelc id from cell id helper
    [Arguments]  ${parsed_scf}  ${cell_id}  ${connection}=default
    ${all_cells} =  Get Cell List  connection=${connection}
    ${gsm_cell_objects} =  Get From Dictionary  ${all_cells['cells']}  gsm
    ${gsm_sector_id} =  Evaluate  [x['id']['configuration'] for x in @{gsm_cell_objects} if x['gsmSectorID'] == '${cell_id}']
    ${gncel_dist_name} =  Get Parameter Value From SCF  ${parsed_scf}  GNCEL  GNCEL-${gsm_sector_id}
    ...  /p[@name='lcelcId']  dist_name_substring=True
    [Return]  ${gsm_sector_id}


Get IDs Of WCDMA LCGs Where Cells With WL ${dss_or_sss} Exist
    [Documentation]
    ...  This KW creates list of WCDMA LCG IDs where cells with
    ...  WL DSS/SSS enabled exist.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list of WCDMA LCG IDs to which WCDMA cells with
    ...  | WCDMA+LTE DSS/SSS feature (RP002167, RP002546) enabled belong.
    ...  | It uses LCELL and LCELW objects to find the IDs
    ...  | of WCDMA cells and find to which LCG they belong.
    ...  | Duplicated LCG IDs are removed.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+---------------------------------------------------+
    ...  | Parameter    | Man. | Description                                       |
    ...  +==============+======+===================================================+
    ...  | dss_or_sss   | Yes  | Variable defining if KW is used for DSS or SSS.   |
    ...  |              |      | Possible values: DSS, SSS.                        |
    ...  +--------------+------+---------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     @{lcgs_with_dss} =  Get IDs Of WCDMA LCGs Where Cells With WL DSS Exist

    ${dss_lcg_ids} =    Create List
    ${cell_lcg_dict} =  Create Cells And LCG IDs Dictionary
    ${cell_ids_dict} =  Run Keyword  Get IDs Of LTE And WCDMA Cells Where WL ${dss_or_sss} Is Enabled
    ${cell_ids} =       Get Dictionary Keys  ${cell_ids_dict}

    FOR  ${cell_id}  IN  @{cell_ids}
        ${lcg_id} =  Get LCG ID For Cell  ${cell_id}  ${cell_lcg_dict}
        Append To List  ${dss_lcg_ids}  ${lcg_id}
    END
    ${dss_lcg_ids} =  Remove Duplicates  ${dss_lcg_ids}

    [Return]  ${dss_lcg_ids}


Get All WCDMA LCG IDs
    [Documentation]
    ...  This KW creates list of all WCDMA LCG IDs.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${lcg_list} =  Get All WCDMA LCG IDs

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_full_${timestamp}
    ${wlcg_dist_names} =  Get DistName Attribute From SCF  ${parsed_scf}  WNCELG  WNCELG
    ...  return_list=True
    ${lcg_list} =  Create List
    FOR  ${wlcg_object}  IN  @{wlcg_dist_names}
        ${lcg_id} =  Convert Dist Name To ID  ${wlcg_dist_names}
        Append To List  ${lcg_list}  ${lcg_id}
    END
    [Return]  ${lcg_list}


Check If UARFCN On RNC And Default Carrier In IM Are The Same For All Given Cells
    [Documentation]
    ...  This KW checks if UARFCN in WCEL object on OMS has the same value
    ...  as default carrier parameter in WNCEL object for all given cells.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW checks if UARFCN in WCEL object on OMS has the same value
    ...  | as default carrier parameter in WNCEL object for all given cells.
    ...  | It is a wrapper KW for 'Check If UARFCN On RNC And Default Carrier
    ...  | In IM Are The Same For A Cell'. In case UARFCN and defaultCarrier
    ...  | in any of the WCDMA cells are not equal and 'fail_kw' is set
    ...  | to 'True' this KW fails. If 'fail_KW' is set to 'False' KW will return
    ...  | 'True' when UARFCN value and defaultCarrier value for all cells are
    ...  | equal and 'False' otherwise.
    ...  | This keyword sets Nwi3 connections parameters and creates global
    ...  | variable 'WBTS_ID'.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                                   |
    ...  +================+======+===============================================================================+
    ...  | wcdma_cell_ids | Yes  | List with cell IDs of cells which should have it's UARFCN verified.           |
    ...  +----------------+------+-------------------------------------------------------------------------------+
    ...  | fail_kw        | No   | Boolean value determining if this KW should fail if ARFCN and defaultCarrier  |
    ...  |                |      | of any of the cells are not equal. Default value=True.                        |
    ...  +----------------+------+-------------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${cell_list} =  Create List  12345  11122  11123
    ...     Check If UARFCN On RNC And Default Carrier In IM Are The Same For All Given Cells  ${cell_list}

   [Arguments]  ${wcdma_cell_ids}  ${fail_kw}=True

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf} =  Save And Parse SCF  scf_name=SCF_runtime_${timestamp}  export_type=configurationAndRuntimeObjects
    ${wbts_id} =  Get Parameter Value From SCF  ${parsed_scf}  WNBTS  WNBTS  /p[@name='wbtsId']
    Set Test Variable  ${WBTS_ID}  ${wbts_id}
    Setup NWI3  ${RNC['ID']}  ${RNC['OMS_IP']}
    ${all_wcarriers_equal} =  Set Variable  ${TRUE}
    FOR  ${wcell_id}  IN  @{wcdma_cell_ids}
        ${wcarriers_equal} =  Wait Until Keyword Succeeds  3x  2min
        ...  Check If UARFCN On RNC And Default Carrier In IM Are The Same For A Cell  ${wcell_id}
        ${all_wcarriers_equal} =  Set Variable If  ${wcarriers_equal}  ${all_wcarriers_equal}  ${FALSE}
    END
    Run Keyword If  ${fail_kw}  Should Be True  ${all_wcarriers_equal}
    ...                                         msg=UARFCN on RNC and default carrier in SCF are equal.
    ...  ELSE                   Return From Keyword  ${all_wcarriers_equal}


Verify If DSS/SSS Is Enabled - LNCEL_FDD Objects
    [Documentation]
    ...  This KW verifies if WL DSS/SSS is enabled for specified LTE cells, by checking
    ...  LNCEL_FDD objects.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW verifies if WCDMA+LTE DSS/SSS feature (RP002167, RP002546) is enabled
    ...  | for LTE cells, by checking LNCEL_FDD objects in SCF. Parameters
    ...  | 'ulChBw' and 'dlChBw' should have the same values as 'chBw' declared in 'lcell_data_dict'.
    ...  | Parameter 'actAutoPucchAlloc' should have value equal to 'true'.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------+------+-----------------------------------------------------------------+
    ...  | Parameter       | Man. | Description                                                     |
    ...  +=================+======+=================================================================+
    ...  | lte_cell_ids    | Yes  | List with LTE cell IDs.                                         |
    ...  +-----------------+------+-----------------------------------------------------------------+
    ...  | lcell_data_dict | No   | Dictionary containing LCELL-ID (keys) and dictionary with       |
    ...  |                 |      | 'chBw' and value of 'dlChBw' (values). Default value is global  |
    ...  |                 |      | variable 'NEW_EARFCN'.                                          |
    ...  +-----------------+------+-----------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${lte_cell_ids} =   Create Dictionary  11123  22234
    ...     ${dss_disabled_all_lncel_fdd} =  Verify If DSS/SSS Is Enabled - LNCEL_FDD Objects  ${lte_cell_ids}

    [Arguments]  ${lte_cell_ids}  ${lcell_data_dict}=${NEW_EARFCN}

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_${timestamp}
    ${dss_enabled_all_lncel_fdd} =  Set Variable  ${TRUE}
    FOR  ${lte_cell_id}  IN  @{lte_cell_ids}
        ${lcell_id} =    Get LCELX ID From Cell ID  ${lte_cell_id}  LTE
        ${lcell_data} =  Run Keyword If  "${lcell_data_dict}"  Get From Dictionary  ${lcell_data_dict}  LCELL-${lcell_id}
        ${log1} =  Run Keyword If  "${lcell_data_dict}"  Catenate
        ...  DSS/SSS is enabled. LNCEL-${lte_cell_id}/LNCEL_FDD-* object has ulChBw=${lcell_data['chBw']},
        ...  dlChBw=${lcell_data['chBw']} and actAutoPucchAlloc=true.
        ${log2} =  Catenate  DSS/SSS is enabled. LNCEL-${lte_cell_id}/LNCEL_FDD-* object has ulChBw=10 MHz|15 MHz|20 MHz,
        ...  dlChBw=10 MHz|15 MHz|20 MHz and actAutoPucchAlloc=true.
        ${log3} =  Catenate  DSS/SSS is not enabled correctly. LNCEL-${lte_cell_id}/LNCEL_FDD-* object
        ...  does not have correct ulChBw, dlChBw (value should be one of following:10 MHz, 15 MHz, 20 MHz)
        ...  and/or actAutoPucchAlloc is not equal to true.
        ${dss_enabled_lncel_fdd} =  Run Keyword If  "${lcell_data_dict}"
        ...  Run Keyword And Return Status  Check If Element Exists In SCF  ${parsed_scf}  LNCEL_FDD  LNCEL-${lte_cell_id}/
        ...  /p[@name='ulChBw'][.='${lcell_data['chBw']}']/../p[@name='dlChBw'][.='${lcell_data['chBw']}']/../p[@name='actAutoPucchAlloc'][.='true']
        ...  ELSE  _check ChBw for wl dss helper  ${parsed_scf}  ${lte_cell_id}  (10 MHz|15 MHz|20 MHz)  (10 MHz|15 MHz|20 MHz)  true
        ${dss_enabled_all_lncel_fdd} =  Set Variable If  ${dss_enabled_lncel_fdd}  ${dss_enabled_all_lncel_fdd}  ${FALSE}
        Run Keyword If  ${dss_enabled_lncel_fdd} and "${lcell_data_dict}"  Log  ${log1}  console=True
        ...  ELSE IF  ${dss_enabled_lncel_fdd} and not "${lcell_data_dict}"  Log  ${log2}  console=True
        ...  ELSE  Log  ${log3}  console=True
    END

    [Return]  ${dss_enabled_all_lncel_fdd}

_check ChBw for wl dss helper
    [Arguments]  ${parsed_scf}  ${lte_cell_id}  ${ch_bw_dl}  ${ch_bw_ul}  ${act_auto_pucch_alloc}
    ${ch_bw_dl_exists} =  Run Keyword And Return Status  Check Element In SCF  ${parsed_scf}  LNCEL_FDD  LNCEL-${lte_cell_id}/
    ...  /p[@name='ulChBw']  <p name="ulChBw">${ch_bw_dl}</p>  is_regexp=True
    ${ch_bw_ul_exists} =  Run Keyword And Return Status  Check Element In SCF  ${parsed_scf}  LNCEL_FDD  LNCEL-${lte_cell_id}/
    ...  /p[@name='dlChBw']  <p name="dlChBw">${ch_bw_ul}</p>  is_regexp=True
    ${act_auto_pucch_alloc_exists} =  Run Keyword And Return Status  Check Element In SCF  ${parsed_scf}  LNCEL_FDD  LNCEL-${lte_cell_id}/
    ...  /p[@name='actAutoPucchAlloc']  <p name="actAutoPucchAlloc">${act_auto_pucch_alloc}</p>  is_regexp=True
    ${status} =  Evaluate  ${ch_bw_dl_exists} and ${ch_bw_ul_exists} and ${act_auto_pucch_alloc_exists}
    [Return]  ${status}


Get ID Of WCDMA Cell Paired With LTE Cell
    [Documentation]
    ...  This KW returns ID of WCDMA cell that is paired with specified LTE cell.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW returns ID of WCDMA cell that is paired with specified LTE cell.
    ...  | If LTE cell passed to this KW does not have WCDMA cell mapped in
    ...  | parameter 'sharedSpectrumWcdmaCellDN' of object 'LCELL'
    ...  | this KW will fail.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | Parameter                      | Man. | Description                                              |
    ...  +================================+======+==========================================================+
    ...  | lte_cell_id                    | Yes  | ID of LTE cell.                                          |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${wcdma_cell_id} =  Get ID Of WCDMA Cell Paired With LTE Cell  11122

    [Arguments]  ${lte_cell_id}

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_${timestamp}

    ${lcelx_id} =       Get LCELX ID From Cell ID  ${lte_cell_id}  LTE
    ${lcelw_dist_name} =  Get Parameter Value From SCF  ${parsed_scf}  LCELL  LCELL-${lcelx_id}
    ...                   /p[@name='sharedSpectrumWcdmaCellDN']  dist_name_substring=True
    ${lcelw_id} =       Fetch From Right  ${lcelw_dist_name}  marker=-
    ${wcdma_cell_id} =  Get Cell ID From LCELX ID  ${lcelw_id}  WCDMA

    [Return]  ${wcdma_cell_id}


Run Hanging Users Script
    [Documentation]
    ...  This KW runs Hanging.py script and will fail if RC is not equal 0 or stdout does not
    ...  match '^No hanging users detected.*'.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW runs Hanging.py script and will fail if RC is not equal 0 or stdout does not
    ...  match '^No hanging users detected.*'. Script Hanging.py is used to detect if any
    ...  hanging users/resources are left on BTS. This KW requires global variable
    ...  'HANGING_SCRIPT_PATH'. As a result of this KW a few files are created:
    ...  'hanging_resource_check_<timestamp1>.log.raw', 'hanging_resource_check_<timestamp1>.log',
    ...  'hanging_stderr_<timestamp2>.txt', 'hanging_stdout_<timestamp2>.txt'.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+---------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                               |
    ...  +=====================+======+===========================================================================+
    ...  | log_directory       | No   | Absolute path to directory where logs from script will be saved.          |
    ...  +---------------------+------+---------------------------------------------------------------------------+
    ...  | hanging_script_path | No   | Absolute path to Hanging.py script. Default value:                        |
    ...  |                     |      | ${CURDIR}/../testsuite/SBTS/test_resources/IWK/resources/Hanging.py       |
    ...  +---------------------+------+---------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Run Hanging Users Script

    [Arguments]  ${log_directory}=${BTSFiles}
    ...  ${hanging_script_path}=${CURDIR}/Hanging.py

    Log  Hanging users script will be run from: ${HANGING_SCRIPT_PATH}  console=True
    ${timestamp} =  Get Time
    ${script_result} =  Run Process  python  ${HANGING_SCRIPT_PATH}  cwd=${log_directory}
    ...  stdout=${log_directory}/hanging_stdout_${timestamp}.txt  stderr=${log_directory}/hanging_stderr_${timestamp}.txt
    ...  timeout=1min  alias=hanging_script
    Should Be True  ${script_result.rc} == 0  msg=A problem with hanging.py script occured.
    Should Match Regexp  ${script_result.stdout}  ^No hanging users detected.*  msg=A problem related to hanging users occured.
    Log to console  Hanging users script executed.
    [Teardown]  Terminate Process  handle=hanging_script


Count Total PRB Available
        [Documentation]
    ...  This KW returns a value of expected total PRB available.
    ...
    ...  | **Author:** katarzyna.wasiel@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW returns a value of expected total PRB available.
    ...  | It will be usefull for counting a number of expected total PRB available
    ...  | only for RP002546 and RP002167 features.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | Parameter                      | Man. | Description                                              |
    ...  +================================+======+==========================================================+
    ...  | lte_cell_id                    | Yes  | ID of LTE cell.                                          |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | wcdma_cell_id                  | Yes  | ID of WCDMA cell.                                        |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | cell_load                      | Yes  | Load of WCDMA cell. Possible choice: LOW, MEDIUM, HIGH.  |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | connection                     | No   | Alias for admin connection to get parameters from cells. |
    ...  |                                |      | Default value: default.                                  |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${expected_total_prb_avail} =  Count Total PRB Available  11122  22201  LOW

    [Arguments]  ${lte_cell_id}  ${wcdma_cell_id}  ${cell_load}  ${connection}=default

    Log  Count number of expected total PRB available for ${cell_load} load WCDMA cell  console=True

    ${timestamp} =  OperatingSystem.Run  date +%F_%H-%M-%S
    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_${timestamp}  export_type=configurationAndRuntimeObjects

    ${mrbts_id} =  Get BTS ID From ADMIN
    ${lcelx_id} =  Get LCELX ID From Cell ID  ${lte_cell_id}  LTE

    ${lte_cells} =  Get Cells Info  lte  connection=${connection}
    ${lte_bw} =  Evaluate  [x['downlinkChannelBandwidth'] for x in @{lte_cells} if x['globalCellId'] == ${lte_cell_id}][0]

    ${wcdma_cells} =  Get Cells Info  wcdma  connection=${connection}
    ${wcdma_center_freq} =  Evaluate  [x['downlinkFrequency'] for x in @{wcdma_cells} if x['cellId'] == ${wcdma_cell_id}][0]
    ${wcdma_center_freq} =  Evaluate  ${wcdma_center_freq}/1000000.0
    ${wcdma_center_freq} =  Convert To Number  ${wcdma_center_freq}  2

    ${lte_center_freq} =  Evaluate  [x['downlinkFrequency'] for x in @{lte_cells} if x['globalCellId'] == ${lte_cell_id}][0]
    ${lte_centre_freq} =  Convert To Number  ${lte_center_freq}  2

    ${user_defined_gap_exists} =  Run Keyword And Return Status
    ...  Check If Element Exists In SCF  ${parsed_scf}  LCELL  LCELL-${lcelx_id}  /p[@name='wlSsMinGapDl']
    ...  dist_name_substring=True
    ${gap} =  Run Keyword If  ${user_defined_gap_exists}
    ...  Get Parameter Value From SCF  ${parsed_scf}  LCELL  LCELL-${lcelx_id}  /p[@name='wlSsMinGapDl']
    ...  dist_name_substring=True
    ...  ELSE  Get Parameter Value From SCF  ${parsed_scf}  LCELL  LCELL-${lcelx_id}  /p[@name='wlSsMinGapDlSys']
    ...  dist_name_substring=True

    ${prb_num} =  Set Variable If  '${lte_bw}' == '20 MHz'  100
    ...                            '${lte_bw}' == '15 MHz'  75
    ...                            '${lte_bw}' == '10 MHz'  50

    ${diff} =  Evaluate  ${lte_center_freq} - ${wcdma_center_freq}
    ${cell_shift}=  Set Variable If  ${diff} > 0
    ...                              left  right

    ${load} =  Set Variable If  '${cell_load}' == 'LOW'  1.2
    ...                         '${cell_load}' == 'MEDIUM'  0.6
    ...                         '${cell_load}' == 'HIGH'  0

    ${lte_limit_point} =  Run Keyword If  '${cell_shift}' == 'left'  Evaluate  ${wcdma_center_freq} + 1.92 - ${load} + ${gap}*0.001
    ...                          ELSE                                Evaluate  ${wcdma_center_freq} - 1.92 + ${load} - ${gap}*0.001

    ${lte_bw_without_guardband} =  Evaluate  ${prb_num}*0.18+0.015
    ${space_for_lte} =  Evaluate  math.fabs(${lte_center_freq}-${lte_limit_point})+${lte_bw_without_guardband}/2  modules=math
    ${total_prb_avail} =  Evaluate  math.floor((${space_for_lte}-0.015)/0.18)  modules=math

    Log  For ${cell_load} load WCDMA cell number of expected total PRB available is equal to ${total_prb_avail}.  console=True

    [Return]  ${total_prb_avail}


Save Swconfigs And Check If Flag Exists
    [Documentation]
    ...  This KW saves swconfig and checks if given flag with specified value exists.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW saves swconfig(s) for SMODs and checks if given flag with specified value exists.
    ...  | The file is saved in TestFiles directory under name passed in  new_swconfig_name
    ...  | with 'MSM_' or 'ESM_' prefix. It also checks if flag exists and depending on value of
    ...  | 'flag_should_exist' fails if it does not exist (for flag_should_exist=True)
    ...  | or fails if it exists (for flag_should_exist=False).
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | Parameter                      | Man. | Description                                              |
    ...  +================================+======+==========================================================+
    ...  | new_swconfig_name              | Yes  | Name for new swconfig. It will have 'MSM_' or 'ESM_'     |
    ...  |                                |      | appended as prefix depending on whether                  |
    ...  |                                |      | it was collected from master SMOD or extension SMOD.     |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | flag                           | Yes  | Flag with value that should be found inside swconfig     |
    ...  |                                |      | files on MSM and ESM (if ESM exists).                    |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | flag_should_exist              | No   | Boolean value defining if flag should be found inside    |
    ...  |                                |      | swconfig or not. Default value=False.                    |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Save Swconfigs And Check If Flag Exists  new_swconfig.txt  12345=0

    [Arguments]  ${new_swconfig_name}  ${flag}  ${flag_should_exist}=False
    Collect Swconfigs
    ${file_names} =         OperatingSystem.List Files In Directory  ${BTS_Files}
    ${swconfig_list} =      Evaluate  [x for x in @{file_names} if 'swconfig' in x]
    ${flag_verification} =  Set Variable  ${TRUE}
    FOR  ${swconfig_name}  IN  @{swconfig_list}
        ${msm_or_esm} =  Set Variable If  "ESM" in "${swconfig_name}"  ESM  MSM
        Move File  ${BTS_Files}/${swconfig_name}  ${Test_Files}/${msm_or_esm}_${new_swconfig_name}
        ${file_path} =  OperatingSystem.Get File  ${Test_Files}/${msm_or_esm}_${new_swconfig_name}
        ${flag_verification} =  Evaluate  (("${flag}" in """${file_path}""") == ${flag_should_exist}) and ${flag_verification}
    END
    Should Be True  ${flag_verification}  msg=Error during flag existence verification in swconfig(s).


Get file from BTS
    [Documentation]
    ...  Download file from BTS using FTP.
    ...
    ...  | **Author:** sebastian.burniak@nokia.com
    ...
    ...  | **Full description:**
    ...    Download file from BTS using FTP. This KW is copied fro hran_general resources.
    ...    Returns path to file where file is saved
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | Parameter                      | Man. | Description                                              |
    ...  +================================+======+==========================================================+
    ...  | path_to_bts_file               | Yes  | Path to directory on BTS where file is located.          |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | filename                       | Yes  | Name of file.                                    :       |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | ip_address                     | No   | IP address to SM, default 192.168.255.1                  |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...  | destination                    | No   | Place where file should be saved, default /tmp.          |
    ...  +--------------------------------+------+----------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    Get file from BTS  /rom/config/lifedata/  blackbox

    [Arguments]  ${path_to_bts_file}  ${filename}  ${ip_address}=192.168.255.1  ${destination}=/tmp/
    Ftp connect    ${ip_address}    toor4nsn   oZPS0POrRieRtu
    Cwd   ${path_to_bts_file}
    ${path}=  FtpLibrary.Download file   ${filename}    ${destination}
    ${file_path}=  Set variable  ${destination}${filename}
    [Teardown]  Ftp Close
    [Return]    ${file_path}


Open session to BSC
    [Documentation]
    ...  Connect and login to BSC
    ...
    ...  | **Author:** patryk.furman@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Full description:**
    ...  KW for connecting to BSC. It sets keepalive function on with value of 5 minutes and sets 10 seconds timeout
    ...  for Telnet feedbacks. In default it uses IP and credentials from config file. This keyword was copied
    ...  from hran_general.robot resources.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------+------+----------------------------+---------------------------------------------+
    ...  | Parameter name  | Man. | Default                    | Description                                 |
    ...  +=================+======+============================+=============================================+
    ...  | bsc_ip          | no   | ${BSC['ip']}               | BSC IP address                              |
    ...  +-----------------+------+----------------------------+---------------------------------------------+
    ...  | bsc_username    | no   | ${BSC['user']}             | BSC username used for logging in            |
    ...  +-----------------+------+----------------------------+---------------------------------------------+
    ...  | bsc_password    | no   | ${BSC['password']}         | BSC password used for logging in            |
    ...  +-----------------+------+----------------------------+---------------------------------------------+
    ...  | connection_type | no   | telnet                     | connection type used, possible values       |
    ...  |                 |      |                            | telnet/ssh                                  |
    ...  +-----------------+------+----------------------------+---------------------------------------------+

    [Arguments]  ${bsc_ip}=${BSC['ip']}  ${bsc_username}=${BSC['user']}  ${bsc_password}=${BSC['password']}  ${connection_type}=telnet
    Run Keyword If  '${connection_type}'=='telnet'  Run Keywords  hran_bsc.Bsc Connection  ${bsc_ip}
    ...  AND  hran_bsc.Bsc Login  ${bsc_username}  ${bsc_password}
    ...  ELSE  hran_bsc.Bsc Ssh Connection  host=${bsc_ip}  username=${bsc_username}  password=${bsc_password}
    hran_bsc.Set Keepalive
    hran_bsc.Set Timeout  10 seconds
    Log  Session to ${bsc_ip} started  console=${TRUE}


Close all BSC sessions
    [Documentation]
    ...  Close all connections to BSC and clear connection cache. This keyword
    ...  was copied from hran_general.robot resources.
    ...
    ...  | **Author:** patryk.furman@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com

    hran_bsc.Close All Connections
    Log  All sessions to BSC closed  console=${TRUE}


Turn On Pcap Logging
    [Documentation]
    ...  Turns IP traffic capturing on.
    ...
    ...  | **Author:** jaroslaw.lukanowicz@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  Turns IP traffic capturing on. For now measurement point is hardcoded
    ...  to NE_Terminated, uplane capturing=True and empty password.
    ...  This keyword was copied from ca_qt.robot resources.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+---------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                             |
    ...  +================+======+=========================================================+
    ...  | connection     | No   | Alias for admin connection. Default value: default.     |
    ...  +----------------+------+---------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Turn On Pcap Logging

    [Arguments]  ${connection}=default
    Start Ip Capture File  NE_Terminated  true  connection=${connection}  password=
    Log  [PCAP logging] Pcap logging started  console=${TRUE}


Turn Off Pcap Logging
    [Documentation]
    ...  Turns IP traffic capturing off, generates, downloads and compresses pcap file.
    ...
    ...  | **Author:** jaroslaw.lukanowicz@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  Turns IP traffic capturing off, generates, downloads and compresses pcap file.
    ...  This keyword was copied from ca_qt.robot resources.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+---------------------------------------------------------------------+
    ...  | Parameter      | Man. | Description                                                         |
    ...  +================+======+=====================================================================+
    ...  | ue_identifier  | No   | Parameter used for naming logs zip file and printing message.       |
    ...  |                |      | Default value: all.                                                 |
    ...  +----------------+------+---------------------------------------------------------------------+
    ...  | file_path      | No   | Absolute path where file will be saved.                             |
    ...  |                |      | Default value: ${TestFiles}/${TEST_NAME}_${ue_identifier}.zip.      |
    ...  +----------------+------+---------------------------------------------------------------------+
    ...  | connection     | No   | Alias for admin connection. Default value: default.                 |
    ...  +----------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Turn Off Pcap Logging  all

    [Arguments]  ${ue_identifier}=all  ${file_path}=${TestFiles}/${TEST_NAME}_${ue_identifier}.zip
    ...  ${connection}=default
	log    ${file_path}
    ${pcap_file} =  Set Variable  ${TestFiles}/${TEST_NAME}_${ue_identifier}.zip
    Stop Ip Capture File  30  connection=${connection}
    Generate Ip Capture File  connection=${connection}
    Download Ip Capture File  ${pcap_file}  connection=${connection}
    Log  [PCAP logging] Pcap logging terminated for UE ${ue_identifier}  console=${TRUE}

