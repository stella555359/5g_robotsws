*** Settings ***
Documentation
...    Author:        daniel.bartkowiak@nokia.com
...    Maintainer:    Author

Library                 taf.ue
Library                 taf.rnc.oms.nwi3  WITH NAME  nwi3
Library                 String
Library                 DateTime
Library                 XML    use_lxml=true
Library                 taf.collectors.core    WITH NAME    core
Library                 taf.sbts.oam.coam.admin  WITH NAME  admin
Library                 Collections
Library                 SSHLibrary
Library                 OperatingSystem
Library                 ../../resources/siso_logger.py

*** Variables ***
${CELLS_YAML_PATH}               # path to reference yaml file with cells parameters
${LOGS_DIR}					     # path to store logs from L3 call
${SELECTED_CELLS}     None       # runtime distnames of cells which are going to be tested,
                                 # example: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1424/LNCEL_R-11
                                 # when using L3 call outside of RFRL TC, create variable "SELECTED_CELLS" as a List, default value is 'None'
							     # default value 'None' means that each cell commissioned on declared in init.py BTSes will be tested

*** Keywords ***
SiSo L3 Call
    [Documentation]  Possible usages: "Siso L3 Call" can be utilized as separate TC by using it straight forward in TS and defining
    ...  'CELLS_YAML_PATH', 'LOGS_DIR', 'SELECTED_CELLS' variables or as simple KW inside of any TC with provided previously
    ...  mentioned variables. To Use this KW user need to prepare yaml file and init.py with required parameters.
    ...  'remote' variable is utilized only by rfrl TC, not used in other case.
    ...  NOTE. "Siso L3 Call" uses variable 'SELECTED_CELLS' as a list of runtime_distnames
    ...  ex. /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-56006
    ...  but for making it easier use helper KW "SiSo Convert Id to Runtime Distname" before "SiSo L3 Call" depending on tested RAT
    ...  in order to allow user to input: nrCellIdentity, eutranCellId, cellI or gsmSectorID
    ...  NOTE. "USER_OAM_IP" can be set by user in special cases ony when reconfiguration is done on BTS which
    ...  makes variables "oam_ip/instance_id" outdated in init.py.
    ...  "USER_OAM_IP" is set as dictionary of keys "bts_id"="mplaneip" of actual btses
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cells_input            | No    | List of runtime distnames of cells to be tested. Default is   |
    ...  |                        |       | `${SELECTED_CELLS}`.                                          |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | remote                 | No    | Boolean flag to indicate remote execution. Default is `False`.|
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Maintainer - daniel.bartkowiak@nokia.com
    [Arguments]  ${cells_input}=${SELECTED_CELLS}  ${remote}=False
    ${remote}=   Set Variable  ${remote}
    ${index_status}=  Run Keyword And Return Status  Variable Should Exist  ${L3_CALL_INDEX}
    ${L3_CALL_INDEX}=  Run Keyword If  ${index_status}  Evaluate  ${L3_CALL_INDEX}+1
    ...    ELSE  Set Variable  1
    Set Test Variable  ${L3_CALL_INDEX}
    Import Variables  ${CELLS_YAML_PATH}
    SiSo Set Global Variables For Call
    SiSo Setup Connection To Btses
    SiSo Get Parameters From BTSes
    SiSo Set Connection to OMS And BSC
    SiSo Reject All Cells For Call
    SiSo Create Tput Description Dictionary
    ${cells_for_call_dict}=  SiSo Create Cells Dict For Call  ${cells_input}
    Run Keyword If  "${L3_CALL_INDEX}"=="1"  SiSo Prepare Ues  ${cells_for_call_dict}
    FOR  ${called_cell}  IN  @{cells_for_call_dict.keys()}
      Logging With Timestamp
      ...  message=Call started on cell ${called_cell}
      ...  style=STEP
      ...  frame=${TRUE}
      ${cell_params_dict}  ${technology}  ${bts}=  SiSo Set Specific Variables For Call  ${cells_for_call_dict}  ${called_cell}
      Run Keyword And Continue On Failure  SiSo Find Anchor LTE  ${cell_params_dict}  ${technology}
      Run Keyword If  '${ANCHOR_STAT}'=='FAIL'  Continue For Loop
      Run Keyword If  ${CA_STATUS}  Run Keyword And Continue On Failure  SiSo Accept Cells For Carrier Aggregation  ${cell_params_dict}  ${bts}
      ...  ELSE  Run Keyword And Continue On Failure  SiSo Accept Cell For Call  ${cell_params_dict}  ${technology}  ${bts}
      Run Keyword If  '${ACCEPT_STAT}'=='FAIL'  Continue For Loop
      ${attach_status}=  Run Keyword And Continue On Failure  SiSo Attach  ${cell_params_dict}  ${technology}  ${bts}  ${called_cell}
      Run Keyword If  ${attach_status} and "${DATA}"=="True"  SiSo Data transfer  ${called_cell}
      Run Keyword If  ${attach_status} and "${VOICE}"=="True" and ${CS_STATUS}  SiSo Voice Call  ${called_cell}
      Run Keyword And Ignore Error  taf.ue.Detach Ue  ue_alias=ue_${SN}  validation=False
      Run Keyword If  ${CA_STATUS}  Run Keyword And Continue On Failure  SiSo Reject Cells For Carrier Aggregation  ${cell_params_dict}  ${bts}
      ...  ELSE  Run Keyword And Continue On Failure  SiSo Reject Cell For Call  ${cell_params_dict}  ${technology}  ${bts}
      Run Keyword And Ignore Error  Siso Refresh BSC Connection
    END
    [Teardown]  Run Keywords  SiSo Accept All Cells For Call
    ...  AND  Run Keyword And Ignore Error  sshLibrary.Close Connection
    ...  AND  SiSo Teardown connection to Btses

SiSo Create Tput Description Dictionary
    [Documentation]  This KW is creating dictionaries to store throughput results.
    ${dl_throughputs}=   Create Dictionary   cell   throughput
    Set test variable    ${DL_THROUGHPUTS}    ${dl_throughputs}
    ${ul_throughputs}=   Create Dictionary   cell   throughput
    Set test variable    ${UL_THROUGHPUTS}    ${ul_throughputs}

SiSo L3 Call Procedure
    [Arguments]  ${test_logs_path}
    [Documentation]  This KW is performing L3 call procedure.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | test_logs_path         | Yes   | Path to store logs for the L3 call procedure.                 |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Set Test Variable  ${LOGS_DIR}  ${test_logs_path}
    Run Keyword If  "${REPETITION_COUNT}"=="1"  SiSo Convert Id to Runtime Distname
    SiSo L3 Call

SiSo Create Cells Dict For Call
    [Arguments]  ${tc_cells}
    [Documentation]  This KW is creating dictionary of cells to be tested during L3 call.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | tc_cells               | Yes   | Input data to be converted into a dictionary of cells.        |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  +--------------------+-------------------------------------------------------------------+
    ...  | Return Value       | Description                                                       |
    ...  +====================+===================================================================+
    ...  | tc_cells_dict      | Dictionary of cells to be tested during the L3 call.              |
    ...  +--------------------+-------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${string_type}=  Evaluate  type(${tc_cells}).__name__
    ${cells_dn_list}=  Run Keyword If  '${string_type}'=='dict'  SiSo Convert To List  ${tc_cells}
    ...  ELSE IF  '${string_type}'=='list'       Set Variable  ${tc_cells}
    ...  ELSE IF  '${string_type}'=='NoneType'   SiSo Get All Cells
    ${tc_cells_dict}=  SiSo Create Cells Dict  ${cells_dn_list}
    [Return]  ${tc_cells_dict}

SiSo Get All Cells
    [Documentation]  This KW is getting all cells from all btses defined in init.py
    ...  +--------------------+-------------------------------------------------------------------+
    ...  | Return Value       | Description                                                       |
    ...  +====================+===================================================================+
    ...  | cells_dn_list      | List of runtime distnames of all cells from all BTSes.            |
    ...  +--------------------+-------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    FOR  ${bts}  IN  @{NODES.keys()}
      ${nrcels}=  admin.Get Ids For All  NRCEL  connection=conn_${bts}
      ${lncels}=  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}  connection=conn_${bts}
      ${wncels}=  admin.Get Ids For All  WNCEL  connection=conn_${bts}
      ${gncels}=  admin.Get Ids For All  GNCEL  connection=conn_${bts}
      ${cells_dn_list}=  Combine Lists  ${nrcels}  ${lncels}  ${wncels}  ${gncels}
    END
    [Return]  ${cells_dn_list}

SiSo Create Cells Dict
    [Arguments]  ${cells_dn_list}
    [Documentation]  This KW is creating dictionary of cells to be tested.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cells_dn_list          | Yes   | List of runtime distnames of cells to be tested.              |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  +--------------------+-------------------------------------------------------------------+
    ...  | Return Value       | Description                                                       |
    ...  +====================+===================================================================+
    ...  | cells_dict         | Dictionary of cells to be tested, with cell IDs as keys.          |
    ...  +--------------------+-------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${cells_dict}=  Create Dictionary
    FOR  ${cell_dn}  IN  @{cells_dn_list}
       ${cell}  ${technology}  ${bts}=  SiSo Search Btses For Called Cell  ${cell_dn}
       Run Keyword If  '${technology}'=='lte'  Continue For Loop If  '${cell['technology']}'=='NB-IoT-FDD'
       ${temp_dict}=  Create Dictionary  cell=${cell}  technology=${technology}  bts_id=${bts}
       ${string_id}=  Run Keyword If  '${technology}'=='nr'  SiSo Prepare NR Cell Id  ${cell}  ${bts}
       ...  ELSE IF  '${technology}'=='lte'    Convert To String  ${cell['eutranCellId']}
       ...  ELSE IF  '${technology}'=='wcdma'  Convert To String  ${cell['cellId']}
       ...  ELSE IF  '${technology}'=='gsm'    Convert To String  ${cell['gsmSectorID']}
       Run Keyword If  '${CELLS_POOL['${string_id}']['ignore']}'=='TRUE'  Run Keywords
       ...  Logging With Timestamp
       ...  message=${cell_dn} is not going to be tested, 'ignore' is set to TRUE in yaml file
       ...  AND  Continue For Loop
       Run Keyword If  '${technology}'=='nr'  Set To Dictionary  ${cell}  nrCellIdentity=${string_id}
       Set To Dictionary  ${cells_dict}  ${string_id}=${temp_dict}
    END
    Should Not Be Empty  ${cells_dict}  msg=No cells are set for testing. Probably 'ignore' is set to TRUE in yaml file. Please check and retest.
    [Return]  ${cells_dict}

SiSo Prepare NR Cell Id
    [Arguments]  ${cell}  ${bts}
    [Documentation]  This KW is preparing nrCellIdentity as string from cell info.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell                   | Yes   | Dictionary containing information about the cell.             |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | bts                    | Yes   | Identifier of the BTS where the cell is located.              |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  +--------------------+-------------------------------------------------------------------+
    ...  | Return Value       | Description                                                       |
    ...  +====================+===================================================================+
    ...  | nrCellIdentity     | The prepared nrCellIdentity as a string.                         |
    ...  +--------------------+-------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${cell_inf}=  admin.Assert  NRCEL  ${cell['id']['internal']}  operationalState=regex"(?i)Enabled"  connection=conn_${bts}
    ${nrCellIdentity}=  Convert To String  ${cell_inf['nrCellIdentity']}
    [Return]  ${nrCellIdentity}

SiSo Convert To List
    [Arguments]  ${tc_cells}
    [Documentation]  This KW is converting input to list of runtime distnames.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | tc_cells               | Yes   | Input data to be converted into a list of runtime distnames.  |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${cells_dn_list}=  Create List
    FOR  ${tech}  IN  @{tc_cells.keys()}
      ${cells_dn_list}=  Combine Lists  ${cells_dn_list}  ${tc_cells['${tech}']}
    END
    Remove Values From List  ${cells_dn_list}  ${EMPTY}
    [Return]  ${cells_dn_list}

SiSo Set Specific Variables For Call
    [Arguments]  ${cells_for_call_dict}  ${called_cell}
    [Documentation]  This KW is setting variables specific for each call.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cells_for_call_dict    | Yes   | Dictionary containing cell information for the call.          |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | called_cell            | Yes   | Identifier of the cell being processed.                       |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Set Test Variable  ${SN}  ${CELLS_POOL['${called_cell}']['ue_serial']}
    Set Test Variable  ${TPUT_DURATION}  ${CELLS_POOL['${called_cell}']['tput_duration']}
    Set Test Variable  ${DL_TPUT_MAX}  ${CELLS_POOL['${called_cell}']['dl_tput_max']}
    Set Test Variable  ${DL_TPUT_MIN}  ${CELLS_POOL['${called_cell}']['dl_tput_min']}
    Set Test Variable  ${UL_TPUT_MAX}  ${CELLS_POOL['${called_cell}']['ul_tput_max']}
    Set Test Variable  ${UL_TPUT_MIN}  ${CELLS_POOL['${called_cell}']['ul_tput_min']}
    ${cs_status}=  Set Variable If  "${cells_for_call_dict['${called_cell}']['technology']}" in "gsmwcdma"  ${TRUE}  ${FALSE}
    Run Keyword If  ${cs_status}  Run Keywords
    ...  Set Test Variable  ${VOICE_DURATION}  ${CELLS_POOL['${called_cell}']['voice_duration']}
    ...  AND  Set Test Variable  ${AUTO_RESP_NUM}  ${CELLS_POOL['${called_cell}']['call_num']}
    Set Test Variable  ${CS_STATUS}  ${cs_status}
    ${ca_status}=    SiSo Check If Carrier Aggregation
    ...  ${cells_for_call_dict['${called_cell}']['cell']}
    ...  ${cells_for_call_dict['${called_cell}']['bts_id']}
    Set Test Variable  ${CA_STATUS}  ${ca_status}
    [Return]  ${cells_for_call_dict['${called_cell}']['cell']}
    ...  ${cells_for_call_dict['${called_cell}']['technology']}
    ...  ${cells_for_call_dict['${called_cell}']['bts_id']}

SiSo Perform DL Data Transfer
    [Arguments]  ${called_cell}
    [Documentation]  This KW is performing DL data transfer on UE.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | called_cell            | Yes   | Identifier of the cell on which DL data transfer is performed.|
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Run Keyword And Continue On Failure  taf.ue.Start Data Transfer  ${L3_CALL_INDEX}_DT_${called_cell}_dl  ue_${SN}  dl  packet=1300
    ...  duration=${TPUT_DURATION}  protocol=udp  throughput=${DL_TPUT_MAX}
    Run Keyword And Continue On Failure  taf.ue.Await Data Transfer Finish  ${L3_CALL_INDEX}_DT_${called_cell}_dl
    ${dl_status}  ${tput_msg}=  Run Keyword And Ignore Error  taf.ue.Verify Average Throughput
    ...  ${L3_CALL_INDEX}_DT_${called_cell}_dl  ${DL_TPUT_MIN}  ${DL_TPUT_MAX}
    Run Keyword If  "${dl_status}"=="PASS"
    ...  Logging With Timestamp
    ...  message=DL tput is in desired range: ${DL_TPUT_MIN} <-> ${DL_TPUT_MAX}
    ...  ELSE  Run Keywords
    ...  Logging With Timestamp
    ...  message=DL tput error: ${\n}${tput_msg}
    ...  AND  Run Keyword And Continue On Failure  Fail  ${tput_msg}
    ${avg_throughput}=    taf.ue.Get Average Throughput    ${L3_CALL_INDEX}_DT_${called_cell}_dl
    Run Keyword And Ignore Error    Set To Dictionary    ${DL_THROUGHPUTS}      ${called_cell}=${avg_throughput}

SiSo Perform UL Data Transfer
    [Arguments]  ${called_cell}
    [Documentation]  This KW is performing UL data transfer on UE.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | called_cell            | Yes   | Identifier of the cell on which UL data transfer is performed.|
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Run Keyword And Continue On Failure  taf.ue.Start Data Transfer  ${L3_CALL_INDEX}_DT_${called_cell}_ul  ue_${SN}  ul  packet=1300
    ...  duration=${TPUT_DURATION}  protocol=udp  throughput=${UL_TPUT_MAX}
    Run Keyword And Continue On Failure  taf.ue.Await Data Transfer Finish  ${L3_CALL_INDEX}_DT_${called_cell}_ul
    ${ul_status}  ${tput_msg}=  Run Keyword And Ignore Error  taf.ue.Verify Average Throughput
    ...  ${L3_CALL_INDEX}_DT_${called_cell}_ul  ${UL_TPUT_MIN}  ${UL_TPUT_MAX}
    Run Keyword If  "${ul_status}"=="PASS"
    ...  Logging With Timestamp
    ...  message=UL tput is in desired range: ${UL_TPUT_MIN} <-> ${UL_TPUT_MAX}
    ...  ELSE  Run Keywords
    ...  Logging With Timestamp
    ...  message=UL tput error: ${\n}${tput_msg}
    ...  AND  Run Keyword And Continue On Failure  Fail  ${tput_msg}
    ${avg_throughput}=    taf.ue.Get Average Throughput    ${L3_CALL_INDEX}_DT_${called_cell}_ul
    Run Keyword And Ignore Error    Set To Dictionary    ${UL_THROUGHPUTS}      ${called_cell}=${avg_throughput}

SiSo Voice Call
    [Arguments]  ${called_cell}
    [Documentation]  This KW is performing voice call on UE.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | called_cell            | Yes   | Identifier of the cell on which the voice call is performed.  |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${voice_status1}  ${voice_msg1}=  Run Keyword And Ignore Error  taf.ue.Start Voice Call  ${L3_CALL_INDEX}_vc_${called_cell}  ue_${SN}
    ...  ${AUTO_RESP_NUM}  ${VOICE_DURATION}
    ${voice_status2}  ${voice_msg2}=  Run Keyword And Ignore Error  taf.ue.Await Voice Call Finish  ${L3_CALL_INDEX}_vc_${called_cell}
    Run Keyword If  "${voice_status1}"=="PASS" and "${voice_status2}"=="PASS"
    ...  Logging With Timestamp
    ...  message=Voice call performed successfuly!
    ...  ELSE  Run Keywords
    ...  Logging With Timestamp
    ...  message=Voice call error: ${\n}${voice_msg1}${\n}${voice_msg2}
    ...  AND  Run Keyword And Continue On Failure  Fail  ${\n}${voice_msg1}${\n}${voice_msg2}

SiSo Data transfer
    [Arguments]  ${called_cell}
    [Documentation]  This KW is performing DL and UL data transfer on UE.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | called_cell            | Yes   | Identifier of the cell on which data transfer is performed.   |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    SiSo Perform DL Data Transfer  ${called_cell}
    SiSo Perform UL Data Transfer  ${called_cell}

SiSo Attach
    [Timeout]  10 minutes
    [Arguments]  ${cell_params_dict}  ${technology}  ${bts}  ${called_cell}
    [Documentation]  In case attach failed KW tries to make one additional recovery airplane mode on/off
    ...  and ue reboot. Each atemmpt is followed by 'Check Attach Conditions'.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the cell being processed. |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | technology             | Yes   | Technology type of the cell (e.g., nr, lte, wcdma, gsm).      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | bts                    | Yes   | Identifier of the BTS where the cell is located.              |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | called_cell            | Yes   | Identifier of the called cell                                 |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${tcpdump_name}=  SiSo Attach To Cell  ${cell_params_dict}  ${technology}  ${bts}  ${called_cell}
    ${is_attach}=  SiSo Check Attach Conditions  ${cell_params_dict}  ${technology}  ${tcpdump_name}
    ${tcpdump_name}=  Run Keyword If  ${is_attach}  Return From Keyword  ${is_attach}
    ...  ELSE  SiSo Attach To Cell  ${cell_params_dict}  ${technology}  ${bts}  ${called_cell}
    ${is_attach}=  SiSo Check Attach Conditions  ${cell_params_dict}  ${technology}  ${tcpdump_name}
    Run Keyword If  ${is_attach}  Return From Keyword  ${is_attach}
    ...  ELSE  Run Keyword And Ignore Error  taf.ue.Reboot Ue  ue_${SN}
    Sleep  10s  Timeout for ue Stabilization after reboot
    ${tcpdump_name}=  SiSo Attach To Cell  ${cell_params_dict}  ${technology}  ${bts}  ${called_cell}
    ${is_attach}=  SiSo Check Attach Conditions  ${cell_params_dict}  ${technology}  ${tcpdump_name}
    Run Keyword If  ${is_attach}  Return From Keyword  ${is_attach}
    ${ue_cell_inf}=  taf.ue.Get Ue Info  ue_${SN}
    SiSo Print On Fail  ${ue_cell_inf}  ${technology}
    Run Keyword And Continue On Failure  Fail  Attach failed. Ue ${SN} has wrong cell_id/ip. Try manually.
    Run Keyword If  not ${is_attach}  Return From Keyword  ${is_attach}

SiSo Attach To Cell
    [Timeout]  4 minutes
    [Arguments]  ${cell_params_dict}  ${technology}  ${bts}  ${called_cell}
    [Documentation]  This KW is performing attach to desired cell with tcpdump running on M-Plane.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the cell being processed. |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | technology             | Yes   | Technology type of the cell (e.g., nr, lte, wcdma, gsm).      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | bts                    | Yes   | Identifier of the BTS where the cell is located.              |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | called_cell            | Yes   | Identifier of the called cell                                 |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  +------------------------+---------------------------------------------------------------+
    ...  | Return Value           | Description                                                   |
    ...  +========================+===============================================================+
    ...  | tcpdump_name           | Name of the tcpdump file created during the attach process.   |
    ...  +------------------------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Run Keyword And Ignore Error  taf.ue.Detach Ue  ue_alias=ue_${SN}
    ${tcpdump_interface_status}=  Run Keyword And Return Status
    ...  Should Not be Empty  ${CELLS_POOL['${called_cell}']['tcpdump_if']}
    ${start_tcpdumps}=  Set Variable If  "${technology}"=="nr" or ${tcpdump_interface_status}  ${TRUE}  ${FALSE}
    ${configurations}  ${tcpdump_name}=  IF  ${start_tcpdumps}
    ...  SiSo Preconditions For Tcpdumps  ${technology}  ${bts}  ${called_cell}
    IF  not ${start_tcpdumps}
    ...  Logging With Timestamp
    ...  message=Missing "tcpdump_if" in yaml file. TCPDUMPS are not being collected for ${technology} cell.
    IF  ${start_tcpdumps}  Run Keywords
    ...  core.Create Collectors  configurations=${configurations}
    ...  AND  core.Setup Collectors  names=${tcpdump_name}
    ...  AND  core.Start Collectors    names=${tcpdump_name}
    Run Keyword And Ignore Error  taf.ue.Attach Ue  ue_alias=ue_${SN}  validation=False
    SiSo Modify Network Mode  ${cell_params_dict}  ${technology}
    IF  ${start_tcpdumps}  Run Keywords
    ...  Sleep  5s  Extend log collection
    ...  AND  core.Stop Collectors  names=${tcpdump_name}
    ...  AND  core.Collect Collectors  names=${tcpdump_name}  target_dir=${LOGS_DIR}
    ...  AND  Run  gzip ${LOGS_DIR}/${tcpdump_name}/${tcpdump_name}.pcap
    Sleep  30s  Stabilize ue attach
    [Return]  ${tcpdump_name}
    [Teardown]  Run Keyword And Ignore Error  core.Teardown Collectors  names=${tcpdump_name}

SiSo Preconditions For Tcpdumps
    [Arguments]  ${technology}  ${bts}  ${called_cell}
    [Documentation]  This KW is preparing parameters for tcpdump on M-Plane.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | technology             | Yes   | Allowed values: lte/nr/gsm/wcdma                              |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | bts                    | Yes   | ID of tested BTS                                              |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | called_cell            | Yes   | Identifier of the called cell                                 |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  +------------------------+---------------------------------------------------------------+
    ...  | Return Value           | Description                                                   |
    ...  +========================+===============================================================+
    ...  | configurations         | Configuration for tcpdumps                                    |
    ...  +------------------------+---------------------------------------------------------------+
    ...  | name                   | Log file name                                                 |
    ...  +------------------------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${timestamp}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${name}=  Set Variable  tcpdumps_${technology}_cell_${called_cell}_${timestamp}
    ${m_plane}=  Create Dictionary
    ...  host=${NODES['${bts}']['IP']}  user=toor4nsn  password=oZPS0POrRieRtu
    ${tcpdump_parameters}=  Create Dictionary
    ...     name=${name}  type=tcpdump  executor=${m_plane}
    ...     options=-i ${CELLS_POOL['${called_cell}']['tcpdump_if']}
    ${configurations}=  Create List  ${tcpdump_parameters}
    [Return]  ${configurations}  ${name}

SiSo Change Network Mode For 5G
    [Arguments]  ${cell_params_dict}
    [Documentation]  This KW is changing network mode on UE to desired technology.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the cell being processed. |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Run Keyword If  '${CELLS_POOL['${cell_params_dict['nrCellIdentity']}']['type']}'=='SA'
    ...  Run Keyword And Continue On Failure  taf.ue.Change Network Mode  ue_${SN}  NR only  network_mode_switch_method=secretcode
    ...  ELSE IF  '${CELLS_POOL['${cell_params_dict['nrCellIdentity']}']['type']}'=='NSA'
    ...  Run Keyword And Continue On Failure  taf.ue.Change Network Mode  ue_${SN}  NR/LTE  network_mode_switch_method=secretcode

SiSo Change Network Mode For LWG
    [Arguments]  ${technology}
    [Documentation]  This KW is changing network mode on UE to desired technology.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | technology             | Yes   | Technology type of the cell (e.g., nr, lte, wcdma, gsm).      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${expected_network}=  Convert To Upper Case  ${technology}
    Run Keyword And Continue On Failure  taf.ue.Change Network Mode  ue_${SN}  ${expected_network} only  network_mode_switch_method=secretcode

SiSo Modify Network Mode
    [Documentation]  Kw is unstable on UEs with android version <= 7
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the cell being processed. |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | technology             | Yes   | Technology type of the cell (e.g., nr, lte, wcdma, gsm).      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    [Arguments]  ${cell_params_dict}  ${technology}
    ${ue_cell_inf}=  taf.ue.Get Ue Info  ue_${SN}
    ${ANDROID_ON_BOARD}=  Run Keyword And Return Status  Variable Should Exist  ${ue_cell_inf['android_ver']}
    Set Test Variable  ${ANDROID_ON_BOARD}
    ${android_ver}=  Run Keyword If  ${ANDROID_ON_BOARD}  Split String  ${ue_cell_inf['android_ver']}  .
    ...  ELSE  Create List  ${0}
    Return From Keyword If  ${android_ver[0]} <= 7
    Run Keyword If  '${technology}'=='nr'
    ...  Run Keyword And Ignore Error  SiSo Change Network Mode For 5G  ${cell_params_dict}
    ...  ELSE  Run Keyword And Ignore Error  SiSo Change Network Mode For LWG  ${technology}

SiSo Check Attach Conditions
    [Timeout]  3 minutes
    [Arguments]  ${cell_params_dict}  ${technology}  ${tcpdump_name}
    [Documentation]  KW is verifying if attached cell is as expected.
    ...  Also IP addr is checked. Those two conditions decide of returned status.
    ...  KW returns one of following:  ${TRUE} or ${FALSE}
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the cell being processed. |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | technology             | Yes   | Technology type of the cell (e.g., nr, lte, wcdma, gsm).      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | tcpdump_name           | Yes   | Name of the tcpdump file to analyze.                          |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${ue_cell_inf}=  taf.ue.Get Ue Info  ue_${SN}
    ${cell_status}=  Run Keyword If  '${technology}'=='gsm'
    ...  Set Variable If  '${CELLS_POOL['${cell_params_dict['gsmSectorID']}']['cell_id']}'=='${ue_cell_inf['cell_id']}'  ${TRUE}  ${FALSE}
    ...  ELSE IF  '${technology}'=='wcdma'
    ...  Set Variable If  '${cell_params_dict['cellId']}'=='${ue_cell_inf['cell_id']}'  ${TRUE}  ${FALSE}
    ...  ELSE IF  '${technology}'=='lte'
    ...  Set Variable If  '${cell_params_dict['eutranCellId']}'=='${ue_cell_inf['cell_id']}'  ${TRUE}  ${FALSE}
    ...  ELSE IF  '${technology}'=='nr'
    ...  SiSo 5G Attach Check  ${cell_params_dict}  ${tcpdump_name}
    Run Keyword If  not ${cell_status}  Return From Keyword  ${cell_status}
	Run Keyword If  not ${ANDROID_ON_BOARD}  Return From Keyword  ${TRUE}
    ${is_ip}=  Set Variable If  "${ue_cell_inf['ip']}"=="${None}"  ${FALSE}  ${TRUE}
    Return From Keyword  ${is_ip}

SiSo 5G Attach Check
    [Arguments]  ${cell_params_dict}  ${tcpdump_name}
    [Documentation]  This KW is checking if UE attached to expected 5G cell.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the cell being processed. |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | tcpdump_name           | Yes   | Name of the tcpdump file to analyze.                          |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${5G_att_stat}  ${attach_result}=  Run Keyword If  '${CELLS_POOL['${cell_params_dict['nrCellIdentity']}']['type']}'=='NSA'
    ...  SiSo Analyze Pcap When NSA  ${cell_params_dict}  ${tcpdump_name}
    ...  ELSE
    ...  SiSo Analyze Pcap When SA  ${cell_params_dict}  ${tcpdump_name}
    Run Keyword If  not ${5G_att_stat}  Set Test Variable  ${ATTACH_RESULT}  ${attach_result}
    [Return]  ${5G_att_stat}

SiSo Analyze Pcap When NSA
    [Arguments]  ${cell_params_dict}  ${tcpdump_name}
    [Documentation]  This KW is analyzing pcap file to find out if UE attached to expected 5G cell.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the cell being processed. |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | tcpdump_name           | Yes   | Name of the tcpdump file to analyze.                          |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${pcap_result}=  SiSo Get Value From PCAP  ${LOGS_DIR}/${tcpdump_name}/${tcpdump_name}.pcap.gz  ${SgNBAdditionRequest}  ${physCellId}
    ${5G_att_stat}=  Set Variable If  '${pcap_result}'=='${cell_params_dict['physicalCellId']}'  ${TRUE}  ${FALSE}
    [Return]  ${5G_att_stat}  ${pcap_result}

SiSo Analyze Pcap When SA
    [Arguments]  ${cell_params_dict}  ${tcpdump_name}
    [Documentation]  This KW is analyzing pcap file to find out if UE attached to expected 5G cell.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the cell being processed. |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | tcpdump_name           | Yes   | Name of the tcpdump file to analyze.                          |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${pcap_result}=  SiSo Get Value From PCAP  ${LOGS_DIR}/${tcpdump_name}/${tcpdump_name}.pcap.gz  ${NRrequest}  ${NRCellIdentity}
    ${pcap_status}=  Run Keyword And Return Status  Should Not Be Empty  ${pcap_result}
    ${pcap_result}=  Run Keyword If  ${pcap_status}  Convert To Integer  ${pcap_result}
    ...  ELSE  Set Variable  ${pcap_result}
    ${5G_att_stat}=  Set Variable If  '${pcap_result}'=='${cell_params_dict['nrCellIdentity']}'  ${TRUE}  ${FALSE}
    [Return]  ${5G_att_stat}  ${pcap_result}

SiSo Print On Fail
    [Arguments]  ${ue_cell_inf}  ${technology}
    [Documentation]  This KW is printing on attach fail the cell_id and IP address where UE is attached.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | ue_cell_inf            | Yes   | Dictionary containing UE cell information.                    |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | technology             | Yes   | Technology type of the cell (e.g., nr, lte, wcdma, gsm).      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Run Keyword If  '${technology}'=='nr'
    ...  Logging With Timestamp
    ...  message=Based on pcap logs UE attached to -> ${ATTACH_RESULT} IP->${ue_cell_inf['ip']}
    ...  ELSE
    ...  Logging With Timestamp
    ...  message=UE attached to:
    ...  message_2=CELL_ID -> ${ue_cell_inf['cell_id']} BTS -> ${ue_cell_inf['enb_id']} IP->${ue_cell_inf['ip']}

SiSo Prepare Ues
    [Timeout]  3 minutes
    [Arguments]  ${cells_for_call_dict}
    [Documentation]  This KW is preparing UEs for call procedure. It is checking if all of declared UEs are connected.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cells_for_call_dict    | Yes   | Dictionary containing cell information for the call procedure.|
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${ue_list}=  Create List
    ${ue_statuses}=  Create List
    FOR  ${cell}  IN  @{cells_for_call_dict.keys()}
      Append To List  ${ue_list}   ${CELLS_POOL['${cell}']['ue_serial']}
    END
    ${unique_ues}=  Remove Duplicates  ${ue_list}
    Should Not Be Empty  ${unique_ues}  Please set ue serial numbers to yaml file
    FOR  ${ue_serial}  IN  @{unique_ues}
      ${status}=  Run Keyword And Return Status  taf.ue.Require Ue   ue_alias=ue_${ue_serial}  capabilities=${ue_serial}
      Append To List  ${ue_statuses}  ${status}
      Logging With Timestamp
      ...  message=Ue connected: ${ue_serial} -> ${status}
    END
    Run Keyword If  False in ${ue_statuses}  Fail  Not all of delared Ues connected.

SiSo Get Gnbs Parameters
    [Documentation]  This KW is getting gnbs parameters from init.py file.
    ${status}=  Run Keyword And Return Status  Should Not Be Empty  ${tl.gnbs}
    Return From Keyword If  '${status}'=='False'  &{EMPTY}
    ${gnbs_dict}=  Create Dictionary
    FOR  ${gnb}  IN  @{tl.gnbs}
       ${status}=  Run Keyword And Return Status  Variable Should Not Exist  ${gnb.cu.backhaul_site_oam_ip.v4}
       Continue For Loop If  ${status}
       ${bts_id}=  Convert to String  ${gnb.global_bts_id}
       Set To Dictionary  ${gnbs_dict}  ${bts_id}=&{EMPTY}
       Set To Dictionary  ${gnbs_dict['${gnb.global_bts_id}']}  IP=${gnb.cu.backhaul_site_oam_ip.v4}
    END
    [Return]  ${gnbs_dict}

SiSo Get Enbs Parameters
    [Documentation]  This KW is getting enbs parameters from init.py file.
    ${status}=  Run Keyword And Return Status  Should Not Be Empty  ${tl.enbs}
    Return From Keyword If  '${status}'=='False'  ${EMPTY}
    ${enbs_dict}=  Create Dictionary
    FOR  ${enb}  IN  @{tl.enbs}
       ${status}=  Run Keyword And Return Status  Variable Should Not Exist  ${enb.oam_ip.v4}
       Continue For Loop If  ${status}
       ${bts_id}=  Convert to String  ${enb.instance_id}
       Set To Dictionary  ${enbs_dict}  ${bts_id}=&{EMPTY}
       Set To Dictionary  ${enbs_dict['${enb.instance_id}']}  IP=${enb.oam_ip.v4}
    END
    [Return]  ${enbs_dict}

SiSo Setup Connection To Btses
    [Documentation]  This KW is setting connections to btses under test.
    FOR  ${bts}  IN  @{NODES.keys()}
      ${status}  ${connection}  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  2x  10s
      ...  admin.Setup Admin  admin_api_log_dir=${LOGS_DIR}  bts_host=${NODES['${bts}']['IP']}  bts_port=443  use_ssl=True  name=conn_${bts}
      Run Keyword If  '${status}'=='FAIL'
      ...  Fail  Admin connection to BTS-${bts} did not start after 2 attempts!
    END

SiSo Teardown connection to Btses
    [Documentation]  This KW is closing connections to btses under test.
    FOR  ${bts}  IN  @{NODES.keys()}
      Run Keyword And Ignore Error  admin.Teardown Admin  connection=conn_${bts}
    END

SiSo Get Parameters From BTSes
    [Documentation]  This KW is getting bts info and current scf file from each bts under test.
    FOR  ${bts}  IN  @{NODES.keys()}
      ${scf_file}=  admin.Get Current Scf File  ${LOGS_DIR}  scf_${bts}.xml  timeout=60  connection=conn_${bts}
      ${inf}=  admin.Get Bts Info  connection=conn_${bts}
      Set To Dictionary  ${NODES['${bts}']}  BTS_INFO=&{inf}  SCF=${scf_file}
      Run Keyword If  '${NODES['${bts}']['BTS_INFO']['ratState']['wcdma']}'!='NO_CELLS'  SiSo Get Wbts Id  conn_${bts}
    END

SiSo Reject All Cells For Call
    [Documentation]  This KW is rejecting all cells on bts under test before starting call procedure.
    Logging With Timestamp
    ...  message=Trying to reject all cells for call
    FOR  ${bts}  IN  @{NODES.keys()}
      SiSo Perform Rejection For All  ${bts}
    END

SiSo Perform Rejection For All
    [Arguments]  ${bts}
    [Documentation]  This KW is rejecting all cells on bts under test.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | bts                    | Yes   | Identifier of the BTS where all cells will be rejected.       |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Logging With Timestamp
    ...  message=Rejecting cells on BTS-${bts}
    SiSo Reject 5G By Barring     ${bts}
    SiSo Reject LTE By Barring    ${bts}
    SiSo Reject WCDMA By QRX  ${bts}
    SiSo Reject GSM By RXP    ${bts}
    [Teardown]  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Fail  Not all cells rejected

SiSo Reject Cell For Call
    [Arguments]  ${cell_params_dict}  ${technology}  ${bts}
    [Documentation]  This KW is rejecting single cell on bts under test.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the cell to be rejected.  |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | technology             | Yes   | Technology type of the cell (e.g., nr, lte, wcdma, gsm).      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | bts                    | Yes   | Identifier of the BTS where the cell is being rejected.       |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Run Keyword If  '${technology}'=='nr'   Run Keywords  admin.Perform Parameter Recommissioning
    ...  ${cell_params_dict['id']['configuration']}  cellBarred  update  barred  connection=conn_${bts}
    ...  AND  SiSo Reject Anchor LTE If Needed  ${cell_params_dict}
    Run Keyword If  '${technology}'=='lte'  Perform Recommissioning For LTE  ${bts}  ${cell_params_dict}  barred  allowed
    Run Keyword If  '${technology}'=='wcdma'  SiSo Recommissioning QRX Parameter in OMS
    ...  ${bts}  ${REJECT_VALUES['${technology}']}  ${cell_params_dict}
    Run Keyword If  '${technology}'=='gsm'    SiSo Recommissioning RXP Parameter in BSC
    ...  ${bts}  ${REJECT_VALUES['${technology}']}  ${cell_params_dict}
    ${wcdma_log_value}=  Run Keyword If  '${technology}'=='wcdma'  Evaluate  ${REJECT_VALUES['${technology}']}*2+1
    Run Keyword If  '${technology}'=='wcdma'  Logging With Timestamp
    ...  message=Called cell was rejected. 'qrxlevmin' set to ${wcdma_log_value}dBm
    Run Keyword If  '${technology}'=='gsm'  Logging With Timestamp
    ...  message=Called cell was rejected. 'qrxlevmin' set to ${REJECT_VALUES['${technology}']}dBm
    Run Keyword If  '${technology}'=='nr' or '${technology}'=='lte'  Logging With Timestamp  message=Called cell was barred.
    [Teardown]  Run Keyword If  '${KEYWORD STATUS}'=='FAIL'  Logging With Timestamp
    ...  message=Recommissioning failed, please check failure reason in robot logs.

SiSo Accept Cell For Call
    [Arguments]  ${cell_params_dict}  ${technology}  ${bts}
    [Documentation]  This KW is accepting single cell on bts under test.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the cell to be accepted.  |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | technology             | Yes   | Technology type of the cell (e.g., nr, lte, wcdma, gsm).      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | bts                    | Yes   | Identifier of the BTS where the cell is being accepted.       |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Sleep  30s  Timeout for CPlane stabilizing
    Run Keyword If  '${technology}'=='nr'   Wait Until Keyword Succeeds  2x  180s  Run Keywords  admin.Perform Parameter Recommissioning
    ...  ${cell_params_dict['id']['configuration']}  cellBarred  update  notBarred  connection=conn_${bts}
    ...  AND  SiSo Accept Anchor LTE If Needed  ${cell_params_dict}
    Run Keyword If  '${technology}'=='lte'  Wait Until Keyword Succeeds  2x  180s  Perform Recommissioning For LTE
    ...  ${bts}  ${cell_params_dict}  notBarred  forbidden
    Run Keyword If  '${technology}'=='wcdma'  SiSo Recommissioning QRX Parameter in OMS
    ...  ${bts}  ${ACCEPT_VALUES['${technology}']}  ${cell_params_dict}
    Run Keyword If  '${technology}'=='gsm'    SiSo Recommissioning RXP Parameter in BSC
    ...  ${bts}  ${ACCEPT_VALUES['${technology}']}  ${cell_params_dict}
    ${wcdma_log_value}=  Run Keyword If  '${technology}'=='wcdma'  Evaluate  ${ACCEPT_VALUES['${technology}']}*2+1
    Run Keyword If  '${technology}'=='wcdma'  Logging With Timestamp
    ...  message=Called cell was accepted. 'qrxlevmin' set to ${wcdma_log_value}dBm
    Run Keyword If  '${technology}'=='gsm'  Logging With Timestamp
    ...  message=Called cell was accepted. 'qrxlevmin' set to ${ACCEPT_VALUES['${technology}']}dBm
    Run Keyword If  '${technology}'=='nr' or '${technology}'=='lte'  Logging With Timestamp
    ...  message=Called cell was unbarred.
    [Teardown]  Run Keywords  Set Test Variable  ${ACCEPT_STAT}  ${KEYWORD STATUS}
    ...  AND  Run Keyword If  '${KEYWORD STATUS}'=='FAIL'
    ...  Run Keyword And Continue On Failure  SiSo Reject Cell For Call  ${cell_params_dict}  ${technology}  ${bts}
    ...  AND  Run Keyword If  '${KEYWORD STATUS}'=='FAIL'  Logging With Timestamp
    ...  message=Recommissioning failed, please check failure reason in robot logs.

Perform Recommissioning For LTE
    [Arguments]  ${bts}  ${cell_params_dict}  ${bar_value}  ${lnrel_value}
    [Documentation]  This KW is performing parameter recommissioning for LTE cell.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | bts                    | Yes   | Identifier of the BTS where the LTE cell is located.          |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the LTE cell.             |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | bar_value              | Yes   | Value to set for the `cellBarred` parameter.                  |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | lnrel_value            | Yes   | Value to set for the `lteNrDualConnectAllowed` parameter.      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    admin.Create Delta
    admin.Append Parameter Update To Delta  ${cell_params_dict['id']['configuration']}/SIB-0  cellBarred  ${bar_value}
    ${lnrel_dists}=  Evaluate Xpath  ${NODES['${bts}']['SCF']}
    ...  .//managedObject[contains(@class, "LNRELGNBCELL")][contains(@distName, "${cell_params_dict['id']['configuration']}/")]/@distName
    FOR  ${obj}  IN  @{lnrel_dists}
      admin.Append Parameter Update To Delta  ${obj}  lteNrDualConnectAllowed  ${lnrel_value}
    END
    ${delta}=  admin.Get Delta
    admin.Perform Delta Recommissioning  ${delta}  connection=conn_${bts}
    admin.Remove Delta

SiSo Accept All Cells For Call
    [Documentation]  This KW is accepting all cells on all btses under test.
    Logging With Timestamp
    ...  message=Trying to accept all cells for call
    Sleep  60s  Timeout for CPlane stabilizing
    FOR  ${bts}  IN  @{NODES.keys()}
      SiSo Perform Acceptance For All  ${bts}
    END

SiSo Perform Acceptance For All
    [Arguments]  ${bts}
    [Documentation]  This KW is accepting all cells on bts under test.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | bts                    | Yes   | Identifier of the BTS where all cells will be accepted.       |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Logging With Timestamp
    ...  message=Accepting cells on BTS-${bts}
    SiSo Accept 5G By Barring     ${bts}
    SiSo Accept LTE By Barring    ${bts}
    SiSo Accept WCDMA By QRX  ${bts}
    SiSo Accept GSM By RXP    ${bts}
    [Teardown]  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Fail  Not all cells accepted

SiSo Search Btses For Called Cell
    [Arguments]  ${ue_cell}
    [Documentation]  This KW is searching for ue_cell on all btses. If found, it returns its parameters, technology type and bts id.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | ue_cell                | Yes   | Identifier of the cell to be searched on all BTSes.           |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    FOR  ${bts}  IN  @{NODES.keys()}
      ${cell}  ${technology}=  SiSo Get Cell Parameters  ${ue_cell}  ${bts}
      ${status}=  Run Keyword And Return Status  Should Not Be Empty  ${cell}
      Exit For Loop If  ${status}
    END
    Run Keyword If  not ${status}  Fail  Cell ${ue_cell} not found on declared BTSes !
    [Return]  ${cell}  ${technology}  ${bts}

SiSo Find Ue Cell
    [Arguments]  ${ue_cell}  ${technology}  ${bts}
    [Documentation]  This KW is searching for ue_cell on bts under specified technology. If found, it returns its parameters.
    ...  Arguments:
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | ue_cell                | Yes   | Identifier of the cell to be searched on the BTS.             |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | technology             | Yes   | Technology type of the cell (e.g., nr, lte, wcdma, gsm).      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | bts                    | Yes   | Identifier of the BTS where the cell is being searched.       |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    FOR  ${cell}  IN  @{NODES['${bts}']['BTS_INFO']['cells']['${technology}']}
      ${status}=  Run Keyword And Return Status  Should Be Equal As Strings  ${cell['id']['internal']}  ${ue_cell}
      Return From Keyword If  ${status}  ${cell}
    END
    Return From Keyword  ${EMPTY}

SiSo Get Cell Parameters
    [Arguments]  ${ue_cell}  ${bts}
    [Documentation]  This KW is searching for ue_cell on bts. If found, it returns its parameters and technology type.
    ...  Arguments:
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | ue_cell                | Yes   | Identifier of the cell to be searched on the BTS.             |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | bts                    | Yes   | Identifier of the BTS where the cell is being searched.       |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    FOR  ${technology}  IN  @{NODES['${bts}']['BTS_INFO']['cells'].keys()}
      ${cell}=  SiSo Find Ue Cell  ${ue_cell}  ${technology}  ${bts}
      ${status}=  Run Keyword And Return Status  Should Not Be Empty  ${cell}
      Return From Keyword If  ${status}  ${cell}  ${technology}
    END
    Return From Keyword  ${EMPTY}  ${EMPTY}

SiSo Reject 5G By Barring
    [Arguments]  ${bts}
    SiSo Recommissioning CellBarred Parameter in ADMIN  ${bts}  technology=nr  value=barred

SiSo Reject LTE By Barring
    [Arguments]  ${bts}
    SiSo Recommissioning CellBarred Parameter in ADMIN  ${bts}  technology=lte  value=barred

SiSo Reject WCDMA By QRX
    [Arguments]  ${bts}
	SiSo Recommissioning QRX Parameter in OMS  ${bts}  value=-13

SiSo Reject GSM By RXP
    [Arguments]  ${bts}
	SiSo Recommissioning RXP Parameter in BSC  ${bts}  value=-47

SiSo Accept 5G By Barring
    [Arguments]  ${bts}
    SiSo Recommissioning CellBarred Parameter in ADMIN  ${bts}  technology=nr  value=notBarred

SiSo Accept LTE By Barring
    [Arguments]  ${bts}
    SiSo Recommissioning CellBarred Parameter in ADMIN  ${bts}  technology=lte  value=notBarred

SiSo Accept WCDMA By QRX
    [Arguments]  ${bts}
    SiSo Recommissioning QRX Parameter in OMS  ${bts}  value=-46

SiSo Accept GSM By RXP
    [Arguments]  ${bts}
    SiSo Recommissioning RXP Parameter in BSC  ${bts}  value=-90

SiSo Find Anchor LTE
    [Arguments]  ${cell_params_dict}  ${technology}
    [Documentation]  If called 5G cell is NSA type, this KW is looking for its anchor LTE cell
    ...  Arguments:
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the cell being processed. |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | technology             | Yes   | Technology type of the cell (e.g., nr, lte, wcdma, gsm).      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Return From Keyword If  '${technology}'!='nr'
    Return From Keyword If  '${CELLS_POOL['${cell_params_dict['nrCellIdentity']}']['type']}'!='NSA'
    ${anchor_config_dn}  ${anchor_bts}=  SiSo Get Anchor LNCEL for NRCEL  ${cell_params_dict}
    Set Test Variable  ${ANCHOR_CONFIG_DN}  ${anchor_config_dn}
    Set Test Variable  ${ANCHOR_BTS}  ${anchor_bts}
    [Teardown]  Run Keywords  Set Test Variable  ${ANCHOR_STAT}  ${KEYWORD STATUS}
    ...  AND  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Logging With Timestamp
    ...  message=LTE Anchor not found on tested BTSes

SiSo Reject Anchor LTE If Needed
    [Arguments]  ${cell_params_dict}
    [Documentation]  If called 5G cell is NSA type, this KW is rejecting its anchor LTE cell
    ...  Arguments:
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the cell being processed. |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Return From Keyword If  '${CELLS_POOL['${cell_params_dict['nrCellIdentity']}']['type']}'!='NSA'
    admin.Perform Parameter Recommissioning
    ...  ${ANCHOR_CONFIG_DN}/SIB-0  cellBarred  update  barred  connection=conn_${ANCHOR_BTS}

SiSo Accept Anchor LTE If Needed
    [Arguments]  ${cell_params_dict}
    [Documentation]  Accepting Anchor LTE cell if tested 5G cell is NSA type
    ...  Arguments:
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the cell being processed. |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Return From Keyword If  '${CELLS_POOL['${cell_params_dict['nrCellIdentity']}']['type']}'!='NSA'
    admin.Perform Parameter Recommissioning
    ...  ${ANCHOR_CONFIG_DN}/SIB-0  cellBarred  update  notBarred  connection=conn_${ANCHOR_BTS}

SiSo Recommissioning CellBarred Parameter in ADMIN
    [Arguments]  ${bts}  ${technology}  ${value}
    [Documentation]  Recommissioning 'cellBarred' parameter for all cells of given technology on given bts
    ...  Arguments:
    ...  +------------------+-------+-------------------------------------------------------------------------+
    ...  | Argument         | Man.  | Description                                                             |
    ...  +==================+=======+=========================================================================+
    ...  | bts              | Yes   | BTS ID where the parameter will be recommissioned.                      |
    ...  +------------------+-------+-------------------------------------------------------------------------+
    ...  | technology       | Yes   | Technology type (e.g., nr, lte, wcdma, gsm).                            |
    ...  +------------------+-------+-------------------------------------------------------------------------+
    ...  | value            | Yes   | Value to set for the 'cellBarred' parameter (e.g., barred, notBarred).  |
    ...  +------------------+-------+-------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${cells_amount}=  Get Length  ${NODES['${bts}']['BTS_INFO']['cells']['${technology}']}
    Run Keyword If  not ${cells_amount}  Return From Keyword
    admin.Create Delta
    FOR  ${cell}  IN  @{NODES['${bts}']['BTS_INFO']['cells']['${technology}']}
      ${cannot_unbarr}=  IF  '${technology}'=='nr'  SiSo Check If Cell Can Be Unbarred  ${cell['id']['configuration']}  ${bts}
      ...  ELSE  Set Variable  ${FALSE}
      Continue For Loop If  ${cannot_unbarr}
      Run Keyword If  '${technology}'=='nr'  admin.Append Parameter Update To Delta   ${cell['id']['configuration']}  cellBarred  ${value}
      ...  ELSE  admin.Append Parameter Update To Delta   ${cell['id']['configuration']}/SIB-0  cellBarred  ${value}
    END
    ${delta}=  admin.Get Delta
    ${nr_lte_status}=  Run Keyword And Return Status  admin.Perform Delta Recommissioning
    ...  ${delta}  connection=conn_${bts}
    admin.Remove Delta
    Run Keyword If  ${nr_lte_status}  Logging With Timestamp
    ...  message=All cells ${value} for '${technology}' technology
    Run Keyword If  not ${nr_lte_status}  Fail  Recommissioning "cellBarred" parameter failed

SiSo Check If Cell Can Be Unbarred
    [Arguments]  ${dn}  ${bts}
    [Documentation]  Check if nrCellType contains 0UL value, which means that cell cannot be unbarred
    ...  If it is so, return TRUE, otherwise FALSE
    ...
    ...    +------------------------+-------+-------------------------------------------------------+
    ...    | Argument               | Man.  | Description                                           |
    ...    +========================+=======+=======================================================+
    ...    | dn                     | Yes   | Cell configuration distname                           |
    ...    +------------------------+-------+-------------------------------------------------------+
    ...    | bts                    | Yes   | bts id                                                |
    ...    +------------------------+-------+-------------------------------------------------------+
    ...
    ...    +--------------------+-------------------------------------------------------------------+
    ...    | Return Value       | Description                                                       |
    ...    +====================+===================================================================+
    ...    | status             | TRUE/FALSE means wheather cell canbe unbarred                     |
    ...    +--------------------+-------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${nr_params_list}=  Create List  nrCellType
    ${nr_params_resp}  admin.Get Parameter By Distname
    ...  dist_name=${dn}
    ...  parameter_list=${nr_params_list}
    ...  connection=conn_${bts}
    ${status}=  Evaluate
    ...  re.search(r'(?i).*0UL', '${nr_params_resp[0]['parameters']['nrCellType']}') is not None  modules=re
    [Return]  ${status}

SiSo Recommissioning QRX Parameter in OMS
    [Arguments]  ${bts}  ${value}  ${wcdma_cell}=${EMPTY}
    [Documentation]  KW for recommmission QRX parameter on OMS
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | bts                    | Yes   | Identifier of the BTS where the WCDMA cell is located.        |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | value                  | Yes   | Value to set for the QRX parameter.                           |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | wcdma_cell             | No    | Specific WCDMA cell to be recommissioned. Default is empty.   |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${cells_amount}=  Get Length  ${NODES['${bts}']['BTS_INFO']['cells']['wcdma']}
    Run Keyword If  not ${cells_amount}  Return From Keyword
    ${is_one_cell}=  Run Keyword And Return Status  Should Not Be Empty  ${wcdma_cell}
    Run Keyword If  ${is_one_cell}  Run Keywords  SiSo Set Wcel Parameter  ${value}  ${wcdma_cell}
    ...  AND  Return From Keyword
    FOR  ${cell}  IN  @{NODES['${bts}']['BTS_INFO']['cells']['wcdma']}
      ${wcdma_status}=  Run Keyword And Return Status  SiSo Set Wcel Parameter  ${value}  ${cell}
      Exit For Loop If  "${wcdma_status}"=="False"
    END
    ${value}=  Evaluate  ${value}*2+1
    Run Keyword If  ${wcdma_status}  Logging With Timestamp
    ...  message=qrxlevmin -> ${value} dBm for all 'wcdma' cells
    Run Keyword If  not ${wcdma_status}  Fail

SiSo Recommissioning RXP Parameter in BSC
    [Documentation]  KW for recommmission QRX parameter on BSC.
    ...  To check current RXP parameters on BSC use command:
    ...  ZEQO:BTS=<GSM sector ID>:RAD;
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | bts                    | Yes   | Identifier of the BTS where the GSM cell is located.          |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | value                  | Yes   | Value to set for the RXP parameter.                           |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | gsm_cell               | No    | Specific GSM cell to be recommissioned. Default is empty.     |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    [Arguments]  ${bts}  ${value}  ${gsm_cell}=${EMPTY}
    ${cells_amount}=  Get Length  ${NODES['${bts}']['BTS_INFO']['cells']['gsm']}
    Run Keyword If  not ${cells_amount}  Return From Keyword
    ${is_one_cell}=  Run Keyword And Return Status  Should Not Be Empty  ${gsm_cell}
    Run Keyword If  ${is_one_cell}  Run Keywords
    ...  Wait Until Keyword Succeeds  2x  60s  SiSo Set Gsm Parameter  ${value}  ${gsm_cell}
    ...  AND  Return From Keyword
    FOR  ${cell}  IN  @{NODES['${bts}']['BTS_INFO']['cells']['gsm']}
      ${gsm_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  3x  30s  SiSo Set Gsm Parameter  ${value}  ${cell}
      Exit For Loop If  "${gsm_status}"=="False"
    END
    Run Keyword If  ${gsm_status}  Logging With Timestamp
    ...  message=qrxlevmin -> ${value} dBm for all 'gsm' cells
    Run Keyword If  not ${gsm_status}  Fail

SiSo Get Wbts Id
    [Arguments]  ${connection}=default
    [Documentation]  Getting WBTS ID for further use in setting WCEL parameters
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | connection             | No    | Connection name to retrieve the WBTS ID. Default is 'default'.|
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${wnbts_obj}=  admin.Get Id For Current  WNBTS  connection=${connection}
    ${wbts}=  admin.Get Parameters  ${wnbts_obj}  wbtsId  connection=${connection}
    Set Test Variable  ${WBTS_ID}  ${wbts['wbtsId']}

SiSo Set Wcel Parameter
    [Arguments]  ${value}  ${wcdma_cell}
    [Documentation]  KW for setting QRX parameter on OMS
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | value                  | Yes   | The value to set for the parameter.                           |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | wcdma_cell             | Yes   | The WCEL (WCDMA cell) for which the parameter is set.         |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${act_qrx}=  nwi3.Get Wcel Parameter  ${WBTS_ID}  ${wcdma_cell['cellId']}  QrxlevMin
    ${wcel_status}=  Run Keyword If  '${act_qrx}'!='${value}'  Run Keyword And Return Status
    ...  nwi3.Set Wcel Parameters  ${WBTS_ID}  ${wcdma_cell['cellId']}  QrxlevMin=${value}
    ${value}=  Evaluate  ${value}*2-1
    Run Keyword If  '${wcel_status}'=='False'  Run Keywords  Logging With Timestamp
    ...  message=Setting 'qrxlevmin' on ${wcdma_cell['cellId']} failed. Test proceeds.
    ...  AND  Fail  Setting 'qrxlevmin' on ${wcdma_cell['cellId']} failed.

SiSo Set Gsm Parameter
    [Arguments]  ${value}  ${gsm_cell}
    [Documentation]  KW for setting RXP parameter on BSC
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | value                  | Yes   | The value to set for the RXP parameter.                       |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | gsm_cell               | Yes   | The GSM cell for which the parameter is set.                  |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    sshLibrary.Write  ZEQG:BTS=${gsm_cell['gsmSectorID']}:RXP=${value};\r\n
    ${rxp_status}=  Run Keyword And Return Status  sshLibrary.Read Until  BSC DATABASE UPDATED
    sshLibrary.Write  ZEQG:BTS=${gsm_cell['gsmSectorID']}:GRXP=${value};\r\n
    ${grxp_status}=  Run Keyword And Return Status  sshLibrary.Read Until  BSC DATABASE UPDATED
    Run keyword If  not (${rxp_status} and ${grxp_status})  Run Keywords
    ...  Logging With Timestamp
    ...  message=Setting 'qrxlevmin' -> ${value}dBm on sector ${gsm_cell['gsmSectorID']} failed.
    ...  AND  Fail  Setting 'qrxlevmin' -> ${value}dBm on sector ${gsm_cell['gsmSectorID']} failed.

Siso Refresh BSC Connection
    [Documentation]  Refreshing BSC connection in case of timeout or disconnection
    ${bsc_exist}=  Run Keyword And Return Status  Variable Should Exist  ${tl.bscs[0].name}
    Run Keyword If  ${bsc_exist}  sshLibrary.Write  ZEEI::BCXU:;\r\n

SiSo Set Connection to OMS And BSC
    [Documentation]  Setting connections to OMS and BSC if WCDMA or GSM cells are present in the tested BTSes
    FOR  ${bts}  IN  @{NODES.keys()}
      Run Keyword If  '${NODES['${bts}']['BTS_INFO']['ratState']['wcdma']}'!='NO_CELLS'
      ...  nwi3.Setup Nwi3  ${tl.rncs[0].rnc_id}  ${tl.rncs[0].oms_ip.v4}
      Run Keyword If  '${NODES['${bts}']['BTS_INFO']['ratState']['gsm']}'!='NO_CELLS'  Run Keywords
      ...  sshLibrary.Set Default Configuration  timeout=10
      ...  AND
      ...  sshLibrary.Open Connection  ${tl.bscs[0].logging_telnet_connection_details.addr}
      ...  AND
      ...  sshLibrary.Login  ${tl.bscs[0].logging_telnet_connection_details.username}  ${tl.bscs[0].logging_telnet_connection_details.password}
    END

SiSo Get Anchor LNCEL for NRCEL
    [Arguments]    ${cell_params_dict}
    [Documentation]  This KW is searching for anchor LTE cell for given 5G cell parameters.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the NR cell being processed.|
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  +------------------------+---------------------------------------------------------------+
    ...  | Return Value           | Description                                                   |
    ...  +========================+===============================================================+
    ...  | anchor_config_dn       | Configuration distname of the anchor LTE cell.                |
    ...  +------------------------+---------------------------------------------------------------+
    ...  | anchor_bts             | BTS ID of the anchor LTE cell.                                |
    ...  +------------------------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    FOR  ${anchor_bts}  IN  @{NODES.keys()}
      ${scf_xml}  Parse xml  ${NODES['${anchor_bts}']['SCF']}
      ${anchor_cell_dist}=    Evaluate Xpath         ${scf_xml}
      ...     string(.//managedObject[(@class='NOKLTE:LNRELGNBCELL') and p[@name="nrCellId"]='${cell_params_dict['nrCellIdentity']}']/@distName)
      ${anchor_found}=  Run Keyword And Return Status  Should Not Be Empty  ${anchor_cell_dist}
      Exit For Loop If  ${anchor_found}
    END
    Run Keyword If  not ${anchor_found}  Fail  Anchor LTE cell not found for ${cell_params_dict['id']['internal']}! Check Configuration.
    ${anchor_config_dn}  ${anchor_lnrel}=  Split String From Right  ${anchor_cell_dist}  /  1
    [Return]    ${anchor_config_dn}   ${anchor_bts}

SiSo Set Global Variables For Call
    [Documentation]  Setting global variables for Basic L3 Call test cases
    ${gnbs}=  SiSo Get Gnbs Parameters
    ${enbs}=  SiSo Get Enbs Parameters
    ${user_oam_ip_exists}=  Run Keyword And Return Status  Variable Should Exist  ${USER_OAM_IP}
    ${NODES}=  Run Keyword If  ${user_oam_ip_exists}  SiSo User Specific Nodes
    ...  ELSE  Create Dictionary  &{gnbs}  &{enbs}
    Set Test Variable  ${NODES}
    ${REJECT_VALUES}=  Create Dictionary  wcdma=-13  gsm=-47
    ${ACCEPT_VALUES}=  Create Dictionary  wcdma=-46  gsm=-90
    Set Test Variable  ${REJECT_VALUES}
    Set Test Variable  ${ACCEPT_VALUES}
    Set Test Variable  ${SgNBAdditionRequest}  x2ap.SgNBAdditionRequest_element
    Set Test Variable  ${physCellId}  nr-rrc.physCellId
    Set Test Variable  ${NRCellIdentity}  ngap.NRCellIdentity
    Set Test Variable  ${NRrequest}  ngap
    ${data_stat}=  Run Keyword And Return Status  Variable Should Exist  ${DATA}
    Run Keyword If  not ${data_stat}  Set Test Variable  ${DATA}  True
    ${voice_stat}=  Run Keyword And Return Status  Variable Should Exist  ${VOICE}
    Run Keyword If  not ${voice_stat}  Set Test Variable  ${VOICE}  True

SiSo User Specific Nodes
    [Documentation]  This KW is creating NODES dictionary based on USER_OAM_IP dictionary provided by user.
    ...  +------------------------+---------------------------------------------------------------+
    ...  | Return Value           | Description                                                   |
    ...  +========================+===============================================================+
    ...  | NODES                  | Dictionary customized for user-specific configurations.       |
    ...  +------------------------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${oam_ip_dict}=  Create Dictionary
    FOR  ${key}  IN  @{USER_OAM_IP.keys()}
      Set To Dictionary  ${oam_ip_dict}  ${key}=&{EMPTY}
      Set To Dictionary  ${oam_ip_dict['${key}']}  IP=${USER_OAM_IP['${key}']}
    END
    [Return]  ${oam_ip_dict}

SiSo Get Value From PCAP
    [Arguments]  ${pcap_file}  ${filter_syntax}  ${field_to_print}
    [Documentation]  Reading packets based on Wireshark display filter syntax.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | pcap_file              | Yes   | Path to the PCAP file to be analyzed.                         |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | filter                 | Yes   | Wireshark display filter syntax to extract specific packets.  |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | field                  | Yes   | Field to extract from the filtered packets.                   |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  +------------------------+---------------------------------------------------------------+
    ...  | Return Value           | Description                                                   |
    ...  +========================+===============================================================+
    ...  | extracted_value        | Extracted value(s) from the PCAP file based on the filter.     |
    ...  +------------------------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${output}  Run  tshark -r "${pcap_file}" -Y "${filter_syntax}" -T fields -e ${field_to_print} | head -1
    [Return]  ${output}

SiSo Precondition Basic L3 Call TC
    Verify Multi BTS State
    Verify Alarms On All Nodes

SiSo Postcondition Basic L3 Call TC
    Verify Multi BTS State
    Verify Alarms On All Nodes

SiSo Convert Id to Runtime Distname
    [Documentation]  KW converts: nrCellIdentity, eutranCellId, cellI or gsmSectorID when set in 'SELECTED_CELLS' to runtime_distnames.
    ...  Use it once before executing KW 'SiSo L3 Call'. If you want to filter RAT where cells are searched just set 'rat' arg, when 'rat'
    ...  is not set 'any' is taken as default value and all rats are searched.
    ...  Argument 'connection' is available to distingush between 'new setup' and 'hran'.
    ...  If not set then 'default' value is used - hran mode is selected where KW takes 'default' alias
    ...  If 'any' used - new setup mode is selected where KW takes bts_id as alias on all available nodes
    ...  Arguments:
    ...  +========================+======+=============================================================+
    ...  | Argument               | Man. | Description                                                 |
    ...  +========================+======+=============================================================+
    ...  | rat                    | No   | possible values: nr, lte, wcdma, gsm, any (lower case only) |
    ...  +------------------------+------+-------------------------------------------------------------+
    ...  | connection             | No   | possible values: default, any (lower case only)             |
    ...  +------------------------+------+-------------------------------------------------------------+
    [Arguments]  ${rat}=any  ${connection}=default
    ${rat_selected_dists_list}=  Create List
    ${empty_list}=  Run Keyword And Return Status  Should Be Empty  ${SELECTED_CELLS}
    Run Keyword If  ${empty_list}  Fail  'SELECTED_CELLS' is empty!!
    Import Variables  ${CELLS_YAML_PATH}
    FOR    ${id}   IN    @{SELECTED_CELLS}
      ${dist}=  _SiSo Match Cell To RAT On Every Node  ${rat}  ${id}  ${connection}
      ${cell_missing}=  Run Keyword And Return Status  Should Be Empty  ${dist}
      Run Keyword If  ${cell_missing}  Fail  SELECTED ${rat} RAT cell => ${id} not found.
      Append To List  ${rat_selected_dists_list}  ${dist}
    END
    Set Test Variable  @{SELECTED_CELLS}  @{rat_selected_dists_list}
    Logging With Timestamp  message=Tested cells:
    FOR  ${cell}  IN  @{SELECTED_CELLS}
      Logging With Timestamp  message=${cell}
    END

_SiSo Match Cell To RAT On Every Node
    [Arguments]  ${rat}  ${id}  ${connection}=default
    [Documentation]  KW is searching for given cell id on all nodes available in NODES dictionary.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | rat                    | Yes   | RAT type to match (e.g., nr, lte, wcdma, gsm).                |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | id                     | Yes   | Identifier of the cell to be matched.                         |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | connection             | No    | Connection type (default: 'default').                         |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${status}  ${yaml_msg}=  Run Keyword And Ignore Error  Get From Dictionary  ${CELLS_POOL}  ${id}
    Run Keyword If  "${status}"=="FAIL"  Fail  Cell -> ${id} not found in YAML file
    ${cell_rat}=  Convert To Lower Case  ${yaml_msg['technology']}
    Run Keyword If  "${rat}"!="any" and "${rat}"!="${cell_rat}"  Fail  Cell -> ${id} doesn't belong to ${rat}
    ${tested_nodes}=  Run Keyword If  "${connection}"=="default"  Create List  ${connection}  ELSE  Set Variable  ${cfg.NODES}
    FOR  ${node}  IN  @{tested_nodes}
      ${match}=  _SiSo Match Cell To RAT  ${node}  ${id}  ${cell_rat}
      ${cell_found}=  Run Keyword And Return Status  Should Not Be Empty  ${match}
      Return From Keyword If  ${cell_found}  ${match}
    END
    Return From Keyword  ${EMPTY}

_SiSo Match Cell To RAT
    [Arguments]  ${node}  ${id}  ${cell_rat}
    [Documentation]  KW is searching for given cell id on given node.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | node                   | Yes   | Node identifier where the cell is being searched.             |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | id                     | Yes   | Identifier of the cell to be matched.                         |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | cell_rat               | Yes   | RAT type of the cell (e.g., nr, lte, wcdma, gsm).             |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${all_rat_objects}=  Run Keyword If  '${cell_rat}'=='nr'  _SiSo Get NR Objects  connection=${node}
    ...  ELSE  _SiSo Get LWG Objects  ${cell_rat}  connection=${node}
    FOR  ${obj}  IN  @{all_rat_objects}
      Run Keyword If  '${cell_rat}'=='nr'  Return From Keyword If  '${obj['nrCellIdentity']}'=='${id}'  ${obj['id']}
      Run Keyword If  '${cell_rat}'=='lte'  Return From Keyword If  '${obj['eutranCellId']}'=='${id}'  ${obj['id']['internal']}
      Run Keyword If  '${cell_rat}'=='wcdma'  Return From Keyword If  '${obj['cellId']}'=='${id}'  ${obj['id']['internal']}
      Run Keyword If  '${cell_rat}'=='gsm'  Return From Keyword If  '${obj['gsmSectorID']}'=='${id}'  ${obj['id']['internal']}
    END
    Return From Keyword  ${EMPTY}

_SiSo Get LWG Objects
    [Arguments]  ${cell_rat}  ${connection}=default
    [Documentation]  KW is getting all objects for given RAT on given connection.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_rat               | Yes   | RAT type to retrieve objects for (e.g., lte, wcdma, gsm).     |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | connection             | No    | Connection type (default: 'default').                         |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  +------------------------+---------------------------------------------------------------+
    ...  | Return Value           | Description                                                   |
    ...  +========================+===============================================================+
    ...  | all_rat_objects        | List of objects for the specified RAT type.                   |
    ...  +------------------------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${get_cell_list_output}=  Get Cell List  connection=${connection}
    ${all_RATs_cells_list}=  Get From Dictionary  ${get_cell_list_output}  cells
    ${all_rat_objects}=  Get From Dictionary  ${all_RATs_cells_list}  ${cell_rat}
    [Return]  ${all_rat_objects}

_SiSo Get NR Objects
    [Arguments]  ${connection}=default
    [Documentation]  KW is getting all NR objects on given connection.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | connection             | No    | Connection type (default: 'default').                         |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${status}  ${msg}=  Run Keyword And Ignore Error  Assert Every  NRCEL  operationalState=regex"(?i)Enabled"  connection=${connection}
    Run Keyword If  "${status}"=="PASS"  Return From Keyword  ${msg}
    ...  ELSE  Return From Keyword  @{EMPTY}

SiSo Prepare Supporting Cells For Carrier Aggregation
    [Arguments]  ${pcell_dict}  ${pcell_bts}
    [Documentation]  KW prepares complete dictionary with Carrier Aggregation supporting cells parameters.
    ...  Sets dictionary as global wariable for future use.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | pcell_dict             | Yes   | Dictionary containing parameters of the primary cell.         |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | pcell_bts              | Yes   | Identifier of the BTS where the primary cell is located.      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${carel_dns}=  Evaluate Xpath
    ...  ${NODES['${pcell_bts}']['SCF']}
    ...  .//managedObject[contains(@class, ":CAREL") and contains(@distName, "${pcell_dict['id']['configuration']}")]/@distName
    ${scell_dict}=  Create Dictionary
    FOR  ${carel_dn}  IN  @{carel_dns}
      ${scel_lcrid}=  Evaluate Xpath
      ...  ${NODES['${pcell_bts}']['SCF']}
      ...  string(.//managedObject[contains(@distName, "${carel_dn}")]/p[@name="lcrId"])
      ${scel_btsid}=  Evaluate Xpath
      ...  ${NODES['${pcell_bts}']['SCF']}
      ...  string(.//managedObject[contains(@distName, "${carel_dn}")]/p[@name="lnBtsId"])
      ${scel_conf_dn}=  Evaluate Xpath
      ...  ${NODES['${scel_btsid}']['SCF']}
      ...  string(.//managedObject[contains(@class, ":LNCEL") and p[@name="lcrId"]="${scel_lcrid}"]/@distName)
      Run Keyword If  "${scel_conf_dn}"=="${EMPTY}"  Fail  Supporting cell from ${carel_dn} doesn't exist on  ${scel_btsid}
      ${scel_qrx}=  Evaluate Xpath
      ...  ${NODES['${scel_btsid}']['SCF']}
      ...  string(.//managedObject[contains(@distName, "${scel_conf_dn}/SIB-0")]/p[@name="qrxlevmin"])
      ${carel_key}=  Fetch From Right  ${carel_dn}  /
      Set To Dictionary  ${scell_dict}  ${carel_key}=&{EMPTY}
      Set To Dictionary  ${scell_dict['${carel_key}']}
      ...  config_dn=${scel_conf_dn}
      ...  initial_qrx=${scel_qrx}
      ...  suppress_qrx=-44
      ...  scell_bts_id=${scel_btsid}
      admin.Create Delta  delta_id=delta_${scel_btsid}
    END
    Set Test Variable  ${SCELL_DICT}  ${scell_dict}

SiSo Perform Recommissioning For LTE Carrier Aggregation Cells
    [Arguments]  ${pcell_dict}  ${pcell_bts}  ${bar_value}  ${scell_qrx_key}
    [Documentation]  KW prepares complex dictionary with deltas for recommissioning on echa CA BTS.
    ...  After deltas are created recommissioning for all CA cells is made so that all cooperating cells can take part in call.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | pcell_dict             | Yes   | Dictionary containing parameters of the primary cell.         |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | pcell_bts              | Yes   | Identifier of the BTS where the primary cell is located.      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | bar_value              | Yes   | Value to set for the `cellBarred` parameter.                  |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | scell_qrx_key          | Yes   | Key to access the QRX parameter for the secondary cell.       |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Sleep  30s  Timeout for CPlane stabilizing
    ${deltas_dict}=  Create Dictionary
    FOR  ${carel_key}  IN  @{SCELL_DICT}
      admin.Append Parameter Update To Delta
      ...  dist_name=${SCELL_DICT['${carel_key}']['config_dn']}/SIB-0
      ...  parameter=cellBarred
      ...  value=${bar_value}
      ...  delta_id=delta_${SCELL_DICT['${carel_key}']['scell_bts_id']}
      admin.Append Parameter Update To Delta
      ...  dist_name=${SCELL_DICT['${carel_key}']['config_dn']}/SIB-0
      ...  parameter=qrxlevmin
      ...  value=${SCELL_DICT['${carel_key}']['${scell_qrx_key}']}
      ...  delta_id=delta_${SCELL_DICT['${carel_key}']['scell_bts_id']}
      ${delta_tmp}=  admin.Get Delta  delta_id=delta_${SCELL_DICT['${carel_key}']['scell_bts_id']}
      Set To Dictionary  ${deltas_dict}  ${SCELL_DICT['${carel_key}']['scell_bts_id']}=${delta_tmp}
    END
    admin.Append Parameter Update To Delta
    ...  dist_name=${pcell_dict['id']['configuration']}/SIB-0
    ...  parameter=cellBarred
    ...  value=${bar_value}
    ...  delta_id=delta_${pcell_bts}
    ${delta_tmp}=  admin.Get Delta  delta_id=delta_${pcell_bts}
    Set To Dictionary  ${deltas_dict}  ${pcell_bts}=${delta_tmp}
    admin.Remove All Delta Id
    FOR  ${bts_id}  IN  @{deltas_dict}
      admin.Perform Delta Recommissioning  ${deltas_dict['${bts_id}']}  connection=conn_${bts_id}
    END
    Logging With Timestamp
    ...  message=Feature Carrier Aggregation detected. All carrier aggregation cells are ${bar_value} for call

SiSo Accept Cells For Carrier Aggregation
    [Arguments]  ${pcell_dict}  ${pcell_bts}
    [Documentation]  KW accepts all CA cells for call
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | pcell_dict             | Yes   | Dictionary containing parameters of the primary cell.         |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | pcell_bts              | Yes   | Identifier of the BTS where the primary cell is located.      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    SiSo Prepare Supporting Cells For Carrier Aggregation  ${pcell_dict}  ${pcell_bts}
    ${recomm_status}  ${msg}=  Run Keyword And Ignore Error  SiSo Perform Recommissioning For LTE Carrier Aggregation Cells
    ...  pcell_dict=${pcell_dict}
    ...  pcell_bts=${pcell_bts}
    ...  bar_value=notBarred
    ...  scell_qrx_key=suppress_qrx
    Run Keyword If  "${recomm_status}"=="FAIL"  Fail  Recommissioning for Carrier Aggregation failed. ${\n} ${msg}
    [Teardown]  Run Keywords  Set Test Variable  ${ACCEPT_STAT}  ${KEYWORD STATUS}
    ...  AND  Run Keyword If  '${KEYWORD STATUS}'=='FAIL'  Logging With Timestamp
    ...  message=Recommissioning for Carrier Aggregation failed. ${\n} ${msg}
    ...  AND  Run Keyword If  '${KEYWORD STATUS}'=='FAIL'
    ...  Run Keyword And Continue On Failure  SiSo Reject Cells For Carrier Aggregation
    ...  pcell_dict=${pcell_dict}
    ...  pcell_bts=${pcell_bts}

SiSo Reject Cells For Carrier Aggregation
    [Arguments]  ${pcell_dict}  ${pcell_bts}
    [Documentation]  KW rejects all CA cells for call
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | pcell_dict             | Yes   | Dictionary containing parameters of the primary cell.         |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | pcell_bts              | Yes   | Identifier of the BTS where the primary cell is located.      |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    FOR  ${carel_key}  IN  @{SCELL_DICT}
      admin.Create Delta  delta_id=delta_${scell_dict['${carel_key}']['scell_bts_id']}
    END
    ${recomm_status}  ${msg}=  Run Keyword And Ignore Error  SiSo Perform Recommissioning For LTE Carrier Aggregation Cells
    ...  pcell_dict=${pcell_dict}
    ...  pcell_bts=${pcell_bts}
    ...  bar_value=barred
    ...  scell_qrx_key=initial_qrx
    Run Keyword If  "${recomm_status}"=="FAIL"  Fail  Recommissioning for Carrier Aggregation failed. ${\n} ${msg}

SiSo Check If Carrier Aggregation
    [Arguments]  ${cell_params_dict}  ${bts}
    [Documentation]  KW checks if given LTE cell has Carrier Aggregation feature enabled.
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                   |
    ...  +========================+=======+===============================================================+
    ...  | cell_params_dict       | Yes   | Dictionary containing parameters of the cell being checked.   |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  | bts                    | Yes   | Identifier of the BTS where the cell is located.              |
    ...  +------------------------+-------+---------------------------------------------------------------+
    ...  +------------------------+---------------------------------------------------------------+
    ...  | Return Value           | Description                                                   |
    ...  +========================+===============================================================+
    ...  | ca_status              | TRUE/FALSE indicating whether the cell supports CA.            |
    ...  +------------------------+---------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${carel_status}=  Evaluate Xpath  ${NODES['${bts}']['SCF']}
    ...  boolean(.//managedObject[contains(@class, ":CAREL") and contains(@distName, "${cell_params_dict['id']['configuration']}")])
    ${param_value}=  Evaluate Xpath  ${NODES['${bts}']['SCF']}
    ...  string(.//managedObject[contains(@class, ":LNBTS") and contains(@distName, "MRBTS-${bts}/LNBTS-${bts}")]/p[@name="actInterEnbDLCAggr"])
    ${ca_param}=  Set Variable If  "${param_value}"=="${EMPTY}"  false  ${param_value}
    ${ca_status}=  Set Variable If  ${carel_status} and "${ca_param}".lower()=="true"  ${TRUE}  ${FALSE}
    [Return]  ${ca_status}
