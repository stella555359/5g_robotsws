*** Settings ***
Documentation  Egate and uexgate management
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    OperatingSystem
Library    ta_uexgate
Library    taf.sw.wtssim    WITH NAME    wtssim

Resource    ./call_and_throughput.robot
Resource    ./tshark.robot

*** Keywords ***
CUS Egate Should Reach OnAir
    [Arguments]  ${cfg_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword starts egate (OnAir should be reached on all cells).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cfg_file_path          | Yes  | Path to the egate config file.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${file_name}=  Fetch From Right  string=${cfg_file_path}  marker=/
    ${lua_dir_path}=  Remove String  ${cfg_file_path}  /${file_name}
    wtssim.Add Egate Lua Dirs  ${lua_dir_path}
    wtssim.Start Egate Process  cfg_file=${cfg_file_path}  timeout=120
    ${interface}=  Run  ip address show eth3
    wtssim.Start Egate Services  timeout=${EGATE_TO_ONAIR_TIMEOUT}

Uexgate Perform Attach
    [Arguments]  ${subcell_uexgate}  ${ue_id_begin}  ${ue_id_end}
    [Documentation]
    ...  Description:
    ...  Keyword performs attach to the LTE cell and checks if
    ...  the "nas_eps.nas_msg_emm_type==0x43" messages appear in the packets.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | subcell_uexgate        | Yes  | Cell subcell number for uexgate purposes.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id_begin            | Yes  | Initial UE number.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id_end              | Yes  | End UE number.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    Create Directory  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach
    ${interface}=  Run  ip address show | grep "10.0.1.1" | awk 'NR==1{print $NF}'
    ${tshark_alias}=  Set Variable  ${interface}_attach_cell_${subcell_uexgate}
    Tshark Start Capturing On Interface  interface=${interface}  alias=${tshark_alias}  capture_filter=sctp
    Set Legacy UE Max Capabilities
    Run Uex Command  ue_attach  id=${ue_id_begin}..${ue_id_end}  cell=${subcell_uexgate}
    Sleep  15
    Tshark Stop Capturing  alias=${tshark_alias}
    Run Keyword And Continue On Failure
    ...  Tshark Verify Packet Filter  packet_filter=nas_eps.nas_msg_emm_type==0x43  alias=${tshark_alias}
    Run Keyword And Ignore Error
    ...  Run  tar cvzf ${SUITE_LOGS_DIR_PATH}/${tshark_alias}.tar.gz ${SUITE_LOGS_DIR_PATH}/${tshark_alias} --remove-files
    Run Keyword And Ignore Error
    ...  Move File  ${SUITE_LOGS_DIR_PATH}/${tshark_alias}.tar.gz  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach
    [Teardown]  Tshark Teardown  alias=${tshark_alias}

Uexgate Perform CA Attach
    [Arguments]  ${subcell_uexgate}  ${ue_id_begin}  ${ue_id_end}
    [Documentation]
    ...  Description:
    ...  Keyword performs attach in the case of carrier aggregation configuration cell
    ...  and checks if the relevant messages appears in the packets.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | subcell_uexgate        | Yes  | Cell subcell number for uexgate purposes.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id_begin            | Yes  | Initial UE number.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id_end              | Yes  | End UE number.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    Create Directory  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach
    ${interface_1}=  Run  ip address show | grep "10.0.1.1" | awk 'NR==1{print $NF}'
    ${interface_2}=  Run  ip address show | grep "10.0.2.1" | awk 'NR==1{print $NF}'
    ${tshark_alias_1}=  Set Variable  ${interface_1}_attach_cell_${subcell_uexgate}
    ${tshark_alias_2}=  Set Variable  ${interface_2}_attach_cell_${subcell_uexgate}
    Tshark Start Capturing On Interface  interface=${interface_1}  alias=${tshark_alias_1}  capture_filter=sctp
    Tshark Start Capturing On Interface  interface=${interface_2}  alias=${tshark_alias_2}  capture_filter=less 1000
    ${ue_param_1}=  Set Variable  ue_param id=${ue_id_begin}..${ue_id_end} release=15 category=12
    ${extended_bands_exist}=  Run Keyword And Return Status  Variable Should Exist  ${EXTENDED_SUPPORTED_BANDS}
    ${ue_param_2}=  Set Variable If  ${extended_bands_exist}
    ...  ca_supported_bands=${CA_SUPPORTED_BANDS} supported_bands=${SUPPORTED_BANDS} extended_supported_bands=${EXTENDED_SUPPORTED_BANDS}
    ...  ca_supported_bands=${CA_SUPPORTED_BANDS} supported_bands=${SUPPORTED_BANDS}
#    ${ue_param_3}=  Set Variable  downlink_LAA_supported=on category_ul=14 ul_64QAM_supported=on
    ${ue_param_3}=  Set Variable  category_ul=14 ul_64QAM_supported=on
    ${ue_param_4}=  Set Variable  supported_ul256qam=all category_dl=17 dl_256QAM_supported=on freq_gaps=true
    Run Uex Command  ${ue_param_1} ${ue_param_2} ${ue_param_3} ${ue_param_4}
    Run Uex Command  ue_attach  id=${ue_id_begin}..${ue_id_end}  cell=${subcell_uexgate}
    Sleep  15
    Tshark Stop Capturing  alias=${tshark_alias_1}
    Tshark Stop Capturing  alias=${tshark_alias_2}
    Run Uex Command  ue_param  reset  id=${ue_id_begin}..${ue_id_end}
    Run Keyword And Continue On Failure
    ...  Tshark Verify Packet Filter  packet_filter=nas_eps.nas_msg_emm_type==0x43  alias=${tshark_alias_1}
    Run Keyword And Ignore Error
    ...  Run  tar cvzf ${SUITE_LOGS_DIR_PATH}/${tshark_alias_1}.tar.gz ${SUITE_LOGS_DIR_PATH}/${tshark_alias_1} --remove-files
    Run Keyword And Ignore Error
    ...  Move File  ${SUITE_LOGS_DIR_PATH}/${tshark_alias_1}.tar.gz  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach
    ${status_actdlcaggr}=  Admin Get LNBTS Parameter Value  parameter_name=actDLCAggr
    ${status_actdlcaggr}=  Convert To Boolean  ${status_actdlcaggr}
    ${status_actulcaggr}=  Admin Get LNBTS Parameter Value  parameter_name=actULCAggr
    ${status_actulcaggr}=  Convert To Boolean  ${status_actulcaggr}
    ${scell_lcr_id_list}=  Admin Get LNCEL CAREL Parameter Value List
    ...  lncel_id=${subcell_uexgate}  parameter_name=lcrId
    FOR  ${scell_lcr_id}  IN  @{scell_lcr_id_list}
      ${earfcn_dl}=  Admin Get LNCEL_M Parameter Value  lncel_id=${scell_lcr_id}  parameter_name=earfcnDl
      ${earfcn_ul}=  Admin Get LNCEL_M Parameter Value  lncel_id=${scell_lcr_id}  parameter_name=earfcnUl
      Run Keyword If  ${status_actdlcaggr} and ${status_actulcaggr}  Run Keywords
      ...  Run Keyword And Continue On Failure
      ...  Tshark Verify Packet Filter  packet_filter=lte-rrc.dl_CarrierFreq_r10==${earfcn_dl}  alias=${tshark_alias_2}
      ...  AND  Run Keyword And Continue On Failure
      ...  Tshark Verify Packet Filter  packet_filter=lte-rrc.ul_CarrierFreq_r10==${earfcn_ul}  alias=${tshark_alias_2}
      ...  ELSE IF  ${status_actdlcaggr}  Run Keyword And Continue On Failure
      ...  Tshark Verify Packet Filter  packet_filter=lte-rrc.dl_CarrierFreq_r10==${earfcn_dl}  alias=${tshark_alias_2}
      ...  ELSE IF  ${status_actulcaggr}  Run Keyword And Continue On Failure
      ...  Tshark Verify Packet Filter  packet_filter=lte-rrc.ul_CarrierFreq_r10==${earfcn_ul}  alias=${tshark_alias_2}
    END
    Run Keyword And Ignore Error
    ...  Run  tar cvzf ${SUITE_LOGS_DIR_PATH}/${tshark_alias_2}.tar.gz ${SUITE_LOGS_DIR_PATH}/${tshark_alias_2} --remove-files
    Run Keyword And Ignore Error
    ...  Move File  ${SUITE_LOGS_DIR_PATH}/${tshark_alias_2}.tar.gz  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach
    [Teardown]  Run Keywords  Tshark Teardown  alias=${tshark_alias_1}
    ...  AND  Tshark Teardown  alias=${tshark_alias_2}

Uexgate Execute Full Duplex Throughput Measurement
    [Arguments]  ${ul_throughput}  ${dl_throughput}  ${bps_throughput}  ${ue_id_begin}  ${ue_id_end}
    ...  ${packet_size}  ${call_time}=${THROUGHPUT_MEASUREMENT_TIME}
    [Documentation]
    ...  Description:
    ...  Keyword executes uplink and downlink throughput measurement via uexgate command and check if desired throughput was correct.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ul_throughput          | Yes  | Uplink throughput rate value.                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dl_throughput          | Yes  | Downlink throughput rate value.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bps_throughput         | Yes  | Throughput rate unit.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id_begin            | Yes  | Initial UE number.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id_end              | Yes  | End UE number.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | packet_size            | Yes  | Packet size in Bytes per one direction                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | call_time              | Yes  | Time of transfer data.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${trf_data_1}=  Set Variable  ue=${ue_id_begin}..${ue_id_end} trf_id=1 dir=dl protocol=udp
    ${trf_data_2}=  Set Variable  size=${packet_size} ${bps_throughput}=${dl_throughput} stats=true
    Run Uex Command  trf_data_start  ${trf_data_1}  ${trf_data_2}
    ${trf_data_3}=  Set Variable  ue=${ue_id_begin}..${ue_id_end} trf_id=2 dir=ul protocol=udp
    ${trf_data_4}=  Set Variable  size=${packet_size} ${bps_throughput}=${ul_throughput} stats=true
    Run Uex Command  trf_data_start  ${trf_data_3} ${trf_data_4}
    Sleep  ${call_time}
    Run Keyword And Continue On Failure  CUS Verify Full Duplex Throughput Success Rate
    ...  ue_id_begin=${ue_id_begin}  ue_id_end=${ue_id_end}  bps_throughput=${bps_throughput}
    Run Uex Command  trf_data_stop  ue=${ue_id_begin}..${ue_id_end}  trf_id=1
    Run Uex Command  trf_data_stop  ue=${ue_id_begin}..${ue_id_end}  trf_id=2

Uexgate Execute Half Duplex Throughput Measurement
    [Arguments]  ${traffic_direction}  ${throughput}  ${bps_throughput}  ${ue_id_begin}  ${ue_id_end}
    ...  ${packet_size}  ${call_time}=${THROUGHPUT_MEASUREMENT_TIME}
    [Documentation]
    ...  Description:
    ...  Keyword executes uplink or downlink throughput measurement via uexgate command and check if desired throughput was correct.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dir                    | Yes  | Uplink or downlink throughput rate value.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | throughput             | Yes  | Uplink or downlink throughput rate value.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bps_throughput         | Yes  | Throughput rate unit.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id_begin            | Yes  | Initial UE number.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id_end              | Yes  | End UE number.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | packet_size            | Yes  | Packet size in Bytes per one direction                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | call_time              | Yes  | Time of transfer data.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${trf_data_1}=  Set Variable  ue=${ue_id_begin}..${ue_id_end} trf_id=1 dir=${traffic_direction} protocol=udp
    ${trf_data_2}=  Set Variable  size=${packet_size} ${bps_throughput}=${throughput} stats=true
    Run Uex Command  trf_data_start  ${trf_data_1}  ${trf_data_2}
    Sleep  ${call_time}
    Run Keyword And Continue On Failure  CUS Verify Half Duplex Throughput Success Rate
    ...  traffic_direction=${traffic_direction}  ue_id_begin=${ue_id_begin}
    ...  ue_id_end=${ue_id_end}  bps_throughput=${bps_throughput}
    Run Uex Command  trf_data_stop  ue=${ue_id_begin}..${ue_id_end}  trf_id=1

Uexgate Verify Throughput Success Rate
    [Arguments]  ${traffic_direction}  ${ue_id}  ${trf_id}  ${bps_throughput}
    ...  ${packet_loss}=${ACCEPTABLE_PACKET_LOSS}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword verifies if measured throughput has success rate for given traffic direction.
    ...  Additionally it prints formatted values of cell parameters and measured throughput to console.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | traffic_direction      | Yes  | Traffic direction.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id                  | Yes  | UE number.                                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | trf_id                 | Yes  | Traffic id.                                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bps_throughput         | Yes  | Throughput rate unit.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | packet_loss            | Yes  | Acceptable percentage of reduced bandwidth throughput.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  log_to_console        |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${trf_stats}=  Run Uex Command  get_trf_data_stats  ue=${ue_id}  trf_id=${trf_id}  unit=${bps_throughput}
    ${tputs_ue}=  Get From Dictionary  dictionary=${trf_stats}  key=${traffic_direction}
    ${tput_success_rate}=  Get From Dictionary  dictionary=${tputs_ue}  key=pass
    ${tput_success_rate}=  Evaluate  "%.2f" % ${tput_success_rate}
    ${tput_avg}=  Get From Dictionary  dictionary=${tputs_ue}  key=avg
    ${tput_avg}=  Evaluate  "%.2f" % ${tput_avg}
    Log  ${info_prefix}Traffic direction: ${traffic_direction}  console=${log_to_console}
    Log  ${info_prefix}Average throughput: ${tput_avg} ${bps_throughput}  console=${log_to_console}
    Log  ${info_prefix}Achieved ${tput_success_rate}% of expected throughput  console=${log_to_console}
    Run Keyword And Continue On Failure  Should Be True  ${tput_success_rate}>=100-${packet_loss}

Uexgate Perform Detach
    [Arguments]  ${subcell_uexgate}  ${ue_id_begin}  ${ue_id_end}
    [Documentation]
    ...  Description:
    ...  Keyword performs detach form the given cell and checks
    ...  if the "s1ap.nas==2" messages appear in the packets.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | subcell_uexgate        | Yes  | Cell subcell number for uexgate purposes.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id_begin            | Yes  | Initial UE number.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id_end              | Yes  | End UE number.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    Create Directory  ${SUITE_LOGS_DIR_PATH}/${TEST_NAME}/detach
    ${interface}=  Run  ip address show | grep "10.0.1.1" | awk 'NR==1{print $NF}'
    ${tshark_alias}=  Set Variable  ${interface}_detach_cell_${subcell_uexgate}
    Tshark Start Capturing On Interface  interface=${interface}  alias=${tshark_alias}  capture_filter=sctp
    Run Uex Command  ue_detach  id=${ue_id_begin}..${ue_id_end}
    Sleep  5
    Tshark Stop Capturing  alias=${tshark_alias}
    Run Keyword And Continue On Failure
    ...  Tshark Verify Packet Filter  packet_filter=s1ap.nas==2  alias=${tshark_alias}
    Run Keyword And Ignore Error
    ...  Run  tar cvzf ${SUITE_LOGS_DIR_PATH}/${tshark_alias}.tar.gz ${SUITE_LOGS_DIR_PATH}/${tshark_alias} --remove-files
    Run Keyword And Ignore Error
    ...  Move File  ${SUITE_LOGS_DIR_PATH}/${tshark_alias}.tar.gz  ${SUITE_LOGS_DIR_PATH}/${TEST_NAME}/detach
    [Teardown]  Tshark Teardown  alias=${tshark_alias}

Uexgate Get Ue Param Supported Bands
    [Arguments]  ${band_number_list}
    [Documentation]
    ...  Description:
    ...  Keyword returns ue param "supported bands" parameter based on band number list.
    ...  Supported bands are returned in "supported bands" parameter format, e.g. "1,3"
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | band_number_list       | Yes  | List of band number.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${supported_bands}=  Get Substring  '@{band_number_list}'  2  -2
    ${supported_bands}=  Remove String  ${supported_bands}  ${SPACE}
    [Return]  ${supported_bands}

Set Catm Ue Capabilities
    [Arguments]  ${configuration_id_list}
    [Documentation]
    ...  Description:
    ...  Keyword sets catm ue capabilities based on the configuration cell id list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | configuration_id_list  | Yes  | List of configuration cell id.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${ue_id_begin}=  Evaluate  ${UE_COUNT}+${UE_IoT_COUNT}+1
    ${ue_id_end}=  Evaluate  ${UE_IoT_COUNT}+${UE_COUNT}+${UE_CATM_COUNT}
    ${band_number_list}=  Get Band Number List  configuration_id_list=${configuration_id_list}
    ${supported_bands}=  Uexgate Get Ue Param Supported Bands  band_number_list=${band_number_list}
    ${ca_supported_bands}=  Set Variable  ${band_number_list[0]}::a
    ${ue_param_1}=  Set Variable  release=14 category=1 category_dl=-1 category_ul=-1 ce_parameters=modeA
    ${ue_param_2}=  Set Variable  ca_supported_bands=${ca_supported_bands} supported_bands=${supported_bands}
    Run UEx command  ue_param id=${ue_id_begin}..${ue_id_end} ${ue_param_1} ${ue_param_2}

Set Legacy UE Max Capabilities
    [Documentation]
    ...  Description:
    ...  Keyword sets max ue capabilities for legacy cells e.g. 64QAM/256QAM support.
    ...
    ...  Author:      jakub.pacahana@nokia.com
    ...  Maintainer:  jakub.pacahana@nokia.com

    ${ue_param_1}=  Set Variable  release=15 category=12 supported_bands=1:false ca_supported_bands=1:a:a-4
    ${ue_param_2}=  Set Variable  category_ul=14 ul_64QAM_supported=on supported_ul256qam=all
    ${ue_param_3}=  Set Variable  category_dl=17 dl_256QAM_supported=on freq_gaps=true
    Run UEx command  ue_param id=1 ${ue_param_1} ${ue_param_2} ${ue_param_3}

