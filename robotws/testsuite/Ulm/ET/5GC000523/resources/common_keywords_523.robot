*** Settings ***
Documentation    Common keywords for 5G523 testing.
Library    OperatingSystem
Library    taf.config.scf                                     WITH NAME   scf
Library    libraries/tools_523.py                             WITH NAME   tools_523
Library    taf.config.wts                                     WITH NAME   wts
Library    ../../../resources/Common/python/MCSharkDissectors.py

Resource   ../../../resources/Common/connect.robot
Resource   ../../../resources/Common/ttitrace.robot
Resource   ../../../resources/Common/testline.robot
Resource   ../../../resources/Common/gnb.robot
Resource   ../../../resources/Common/util.robot
Resource   ../../../resources/Common/commissioning.robot
Resource   ../../../resources/Common/pmcounters.robot
Resource   ../../../resources/Common/tcpdump.robot
Resource   ../../../resources/Common/btslog.robot
Resource   ../../../resources/Common/ute_workarounds.robot
Resource   ../../../resources/Common/wts_ue.robot
Resource   ../../../resources/Common/snapshot.robot
Resource   ../../../resources/Common/reporting.robot
Resource   ../../../resources/Common/git_handling.robot



*** Keywords ***

Setup Suite
    Set Console Output
    Make necessary Changes to gNB SCF
    Get config info for Common OAM
    Determine freqency band


Get config info for Common OAM
    ${sw_build}  ${branch}=  Retreive gNB sw version
    Set suite variable  ${sw_build}
    Set suite variable  ${branch}
    Set environment variable  SW_BUILD  ${sw_build}
    Log to console  SW VERSION UNDER TEST: ${sw_build}
    ${Phy_cell_ids}=  Get gNB Physical Cell ID
    Set suite variable  ${Phy_cell_ids}
    ${num_cells}=  Get length  ${Phy_cell_ids}
    Set Suite variable  ${num_cells}
    IF   ${num_cells}==1   Set variables for single cell   ELSE IF   ${num_cells}==2   Set variables for two cells


Determine freqency band
    OperatingSystem.Create Directory  ${OUTPUT_DIR}/${SUITE_NAME}
    ${distName_params}=  Get distNames from gNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ${scf_file}=  Get SCF from gNB  target_dir=${OUTPUT_DIR}/${SUITE_NAME}
    scf.load_scf  ${scf_file}
    ${nr_frequency_band}=  scf.get_value_from_scf  dist_name=${distName_params[0]}  p_name=freqBandIndicatorNR
    ${nr_freq_config}=  tools_523.determine_tl_freq_configuration  nrband=${nr_frequency_band}
    Set Suite Variable  ${nr_freq_config}


Set variables for single cell
    ${Phy_cell_id_cell_1}=  Get From Dictionary	${Phy_cell_ids}	 NRCELL-1
    ${pci}=  Set variable  ${Phy_cell_id_cell_1}
    Set Suite variable  ${Phy_cell_id_cell_1}
    Set Suite variable  ${pci}


Set variables for two cells
    Set variables for single cell
    ${Phy_cell_id_cell_2}=  Get From Dictionary	${Phy_cell_ids}	 NRCELL-2
    Set Suite variable  ${Phy_cell_id_cell_2}
    ${pci}=  Set variable  ${Phy_cell_id_cell_1},${Phy_cell_id_cell_2}
    Set Suite variable  ${pci}


Convert pcap to text
    [Arguments]  ${source}   ${target}

    ${gnb_version}=   Get gNB SW version    gnb_id=${0}
    Update MCshark Dissector      ${gnb_version}

    ssh.send_command
    ...  nice tshark -V -r ${source} -T text > ${target}
    ...  connection=testPC
    ssh.await execution end  connection=testPC  timeout=30min


Get PM Counter Interval
    OperatingSystem.Create Directory  ${OUTPUT_DIR}/${SUITE_NAME}
    ${scf_file}=  Get SCF from gNB  target_dir=${OUTPUT_DIR}/${SUITE_NAME}
    scf.load_scf  ${scf_file}
    ${interval_pm}=  scf.get_value_from_scf  dist_name=MNL-1/MNLENT-1/PMCADM-1  p_name=reportingIntervalPm
    RETURN  ${interval_pm}


Evaluate Throughput for all ues
    [Arguments]  ${expected_throughput_per_ue}  ${data_direction}  ${num_of_ues}=1  ${permitted_variance_percentage}=10
    ...  ${desired_unit}=M
    ${resultTestDir}=  Get testcase log directory
    FOR  ${P_mue}  IN RANGE  0   ${num_of_ues}
         run keyword and continue on failure
    ...  Evaluate ue throughput  expected_throughput=${expected_throughput_per_ue}  data_direction=${data_direction}
    ...  mue_id=${P_mue}  permitted_variance_percentage=${permitted_variance_percentage}  resultTestDir=${resultTestDir}
    ...  desired_unit=${desired_unit}
    END


Attach Airphone UEs in NSA Mode
    FOR  ${ue_id}  IN RANGE  11   ${num_of_ues_per_cell}+${11}
        Attach UE to LTE  ue_id=${ue_id}
    END
    Log to Console  Serving Cell Index range for UE${ue_id}
    Update dual connectivity parameters  id=1  serving_cell_index_range_scg=5:31
    Sleep  30s
    FOR  ${ue_id}  IN RANGE  11   ${num_of_ues_per_cell}+${11}
        Log to Console  Start dual connectivity for UE${ue_id}
        Trigger LTE-NR dual connectivity for bearers  ue_id=${ue_id}  bearer_id=2
        Sleep  1s
    END


Detach Airphone UE
    log    Detach Airphone UE
    Detach UE from LTE    ue_id=1


Detect UE and Initialize Test Suite
    [Arguments]  ${la_disabled}=False
    Setup Suite
    ${_ue_type}=  Get UE type
    Set Suite Variable  ${_ue_type}
    ${total_number_of_ues}=  Set Variable  ${4}
    ${num_of_ues_per_cell}=  Set Variable  ${total_number_of_ues}
    Set suite variable  ${num_of_ues_per_cell}
    Set suite variable  ${total_number_of_ues}
    IF  '${_ue_type}'=='airphone'  Suite Setup for Airphone UE  flag_la_disabled=${la_disabled}
    ...  ELSE  Log to console  Unsupported UE
    ${precondition_satisfied}=  Set Variable  False
    Set Suite Variable   ${precondition_satisfied}


Attach UEs
    IF  '${_ue_type}'=='airphone'  Attach Airphone UEs in NSA Mode
    ...  ELSE  Log to console  Unsupported UE


#""" Airphone Traffic Keywords """
Start DL Traffic for Airphone UE
    [Arguments]  ${ue_id}  ${throughput}=${1}  ${throughput_unit}=mbps
    wts_ue.Start data traffic in egate    ue_id=${ue_id}  id=${2}  direction=dl
    ...  trf_id=2  ${throughput_unit}=${throughput}
#    wts_ue.Start data traffic in egate    ue_id=${ue_id}  id=${2}  direction=dl
#    ...  trf_id=3  ${throughput_unit}=${throughput}
#    wts_ue.Start data traffic in egate    ue_id=${ue_id}  id=${2}  direction=dl
#    ...  trf_id=4  ${throughput_unit}=${throughput}
#    wts_ue.Start data traffic in egate    ue_id=${ue_id}  id=${2}  direction=dl
#    ...  trf_id=5  ${throughput_unit}=${throughput}
#    wts_ue.Start data traffic in egate    ue_id=${ue_id}  id=${2}  direction=dl
#    ...  trf_id=6  ${throughput_unit}=${throughput}
#    wts_ue.Start data traffic in egate    ue_id=${ue_id}  id=${2}  direction=dl
#    ...  trf_id=7  ${throughput_unit}=${throughput}
#    wts_ue.Start data traffic in egate    ue_id=${ue_id}  id=${2}  direction=dl
#    ...  trf_id=8  ${throughput_unit}=${throughput}


Start UL Traffic for Airphone UE
    [Arguments]  ${ue_id}  ${throughput}=${1}  ${throughput_unit}=mbps
    wts_ue.Start data traffic in egate    ue_id=${ue_id}  id=${2}  direction=ul
    ...  trf_id=2  ${throughput_unit}=${throughput}


Start UL Traffic for all Airphone UEs
    [Arguments]  ${throughput_per_ue}=${120}  ${unit}=mbps
    FOR  ${ue_id}  IN RANGE  11   ${total_number_of_ues}+${11}
        Start UL Traffic for Airphone UE  ue_id=${ue_id}  throughput=${throughput_per_ue}  throughput_unit=${unit}
        Sleep  1s
    END


Start DL Traffic for all airphone UEs
    [Arguments]  ${throughput_per_ue}=${1}  ${unit}=mbps
    FOR  ${ue_id}  IN RANGE  11   ${total_number_of_ues}+${11}
        Start DL Traffic for Airphone UE  ue_id=${ue_id}  throughput=${throughput_per_ue}  throughput_unit=${unit}
    END


Stop UL Traffic for Airphone UE
    [Arguments]  ${ue_id}=1
    wts_ue.Stop data traffic in egate    ue_id=${ue_id}  id=${2}  direction=ul  trf_id=2


Stop DL Traffic for Airphone UE
    [Arguments]  ${ue_id}=1
    wts_ue.Stop data traffic in egate    ue_id=${ue_id}  id=${2}  direction=dl  trf_id=2


Stop UL Traffic for all Airphone UEs
    FOR  ${ue_id}  IN RANGE  11   ${total_number_of_ues}+${11}
        Stop UL Traffic for Airphone UE  ue_id=${ue_id}
    END


Stop DL Traffic for all Airphone UEs
    FOR  ${ue_id}  IN RANGE  11   ${total_number_of_ues}+${11}
        Stop DL Traffic for Airphone UE  ue_id=${ue_id}
    END


Get iperf stats for all ues
    [Arguments]  ${num_of_ues}=${total_number_of_ues}
    FOR  ${P_mue}  IN RANGE  0   ${num_of_ues}
         run keyword and continue on failure
    ...  Get iperf traffic stats  mue_id=${P_mue}
    END


# Traffic Keywords Common Usage for Airphone
Start Traffic in Downlink for all UEs
    [Arguments]  ${throughput_per_ue}=${175}  ${unit}=mbps
    IF  '${_ue_type}'=='airphone'  Start DL Traffic for all airphone UEs
    ...  throughput_per_ue=${throughput_per_ue}  unit=${unit}


Stop Traffic in Downlink for all UEs
    IF  '${_ue_type}'=='airphone'  Stop DL Traffic for all airphone UEs
    Run Keyword and Ignore Error  Get iperf stats for all ues


Start Traffic in Uplink for all UEs
    [Arguments]  ${throughput_per_ue}=${100}  ${unit}=mbps
    IF  '${_ue_type}'=='airphone'  Start UL Traffic for all airphone UEs
    ...  throughput_per_ue=${throughput_per_ue}  unit=${unit}


Stop Traffic in Uplink for all UEs
    IF  '${_ue_type}'=='airphone'  Stop UL Traffic for all airphone UEs
    Run Keyword and Ignore Error  Get iperf stats for all ues


Start UL and DL Traffic for all UEs
    [Arguments]  ${throughput_per_ue_dl}=175  ${unit_dl}=mbps  ${throughput_per_ue_ul}=175  ${unit_ul}=mbps
    Start Traffic in Downlink for all UEs  throughput_per_ue=${throughput_per_ue_dl}  unit=${unit_dl}
    Start Traffic in Uplink for all UEs  throughput_per_ue=${throughput_per_ue_ul}  unit=${unit_ul}


Stop UL and DL Traffic for all UEs
    Stop Traffic in Downlink for all UEs
    Stop Traffic in Uplink for all UEs


Disable Link Adaptation
    @{la_rd_params}=  Create list  0x580011=0  0x580012=0  0x580013=0  0x580014=0
    Update SW Config file on System Module  param_list=${la_rd_params}
    ${distName_ctr}=  Get distNames from gNB SCF  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    ${parameter1}=  create dictionary  value=0  dist_name=${distName_ctr[0]}  p_name=dllaIniMcs
    ${param_list}=     Create List     ${parameter1}
    Update SCF Parameters and commission gNB  param_list=${param_list}


Update SCF Parameters and commission gNB
    [Arguments]  ${param_list}  ${delta_scf_filename}=SCF_updated_delta.xml
    ${scf_path}=  Get SCF from gNB
    ${configuration_directory}=  Get Test Suite Config Directory
    ${path_delta_scf}=  Generate Delta Commissioning File   scf_path=${scf_path}  parameters_list=${param_list}
    ...  target_local_path=${configuration_directory}/${delta_scf_filename}
    Execute delta commissioning  delta_scf_template=${path_delta_scf}   resultDir=${OUTPUT_DIR}


Restore original egate config
    ${configuration_directory}=  Get Test Suite Config Directory
    copy file   ${configuration_directory}/basic_setup.cfg.orig  /opt/iphy/latest/basic_setup.cfg


Update UE Capability String in Basic Cfg file
    wts.Load Wts Cfg        /opt/iphy/latest/basic_setup.cfg
    wts.Modify              ue_param id=11
    ...  ue_nr_capabilities=4100000004658000000004001100000060530000000301000080009B08400000083A80000000000203C00000000000008A80000000000000A8
    wts.Save Wts Cfg        /opt/iphy/latest/basic_setup.cfg


Make necessary Changes to gNB SCF
    ${scf_path}=  Get SCF from gNB
    scf.load_scf    ${scf_path}
    Change reporting Interval
    Enable Short PUCCH
    Force Traffic over NR
    Disable Proactive UL Scheduling
    ${configuration_directory}=  Get Test Suite Config Directory
    scf.save_scf    ${configuration_directory}/SCF_updated.xml
    ${oam_alias}=  connect.Setup OAM http session
    admin.perform_commissioning    scf_file=${configuration_directory}/SCF_updated.xml  connection=${oam_alias}
    ...  skip_parameter_relation_errors=True  timeout=600
    connect.Teardown OAM http session


Enable Short PUCCH
    ${distName_NRCELL}=       Get distNames from gNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    FOR  ${distname}  IN  @{distName_NRCELL}
        scf.modify scf element    value=shortPucch  dist_name=${distname}  p_name=pucchModeSelect
        scf.modify scf element    value=false       dist_name=${distname}  p_name=actIncreasedFdmUsersPerSlot
    END


Change reporting interval
    [Arguments]    ${interval_duration}=5min
    ${distName_ctr}=  Get distNames from gNB SCF  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_ctr[0]}  p_name=miNrCellAvailability
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_ctr[0]}  p_name=miNrCellUtilization
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_ctr[0]}  p_name=miNrTimingAdvance
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_ctr[0]}  p_name=miNrUlSignalQuality
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_ctr[0]}  p_name=miNrUlHarq
    ${distName_ctr_1}=  Get distNames from gNB SCF  regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_ctr_1[0]}  p_name=reportingIntervalPm


Force Traffic over NR
    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=NRBTS-\\d+
    ${dlDataSplitMode}=    scf.Get all values from scf    p_name=dlDataSplitMode
    ${no_modes}    Get length    ${dlDataSplitMode}
    FOR    ${id}    IN RANGE    1    ${no_modes}+1
        scf.modify_scf_element  value=dlOverF1U  dist_name=${bts_distNames[0]}/NRDRB-${id}  p_name=dlDataSplitMode  list_name=nsaDrbParam
        scf.modify_scf_element  value=ulOverNr   dist_name=${bts_distNames[0]}/NRDRB-${id}  p_name=ulDataPath       list_name=nsaDrbParam
    END


Disable Proactive UL Scheduling
    ${distName_NRCELL}=  gnb.Get distNames from gNB DU    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    Sort List  ${distName_NRCELL}
    ${element_exists}=    scf.is element in object    dist_name=${distName_NRCELL[0]}    p_name=actProactUlScheduling
    IF   ${element_exists}   scf.modify scf element   dist_name=${distName_NRCELL[0]}   p_name=actProactUlScheduling   value=false


Suite Setup for Airphone UE
    [Documentation]    Collect all needed configuration to bring TL back to status
    ...    AirphoneConfig.xml, basic.cfg, ap_swconfig, gnb_swconfig, SCF
    ...    Upload needed config file to TL
    [Arguments]  ${flag_la_disabled}=False
    testline.Set Console Output
    Log Variables
    git_handling.Save Current Workspace Info
    ute_workarounds.UTE Cloud Workaround
    testline.Create Test Suite Log Folders
    Backup Airphone WTS Config    basic_setup.cfg.orig
    ${nrarfcn_Str}=    Get nrarfcn Info
    @{nrarfcn_List}=   split string 	 ${nrarfcn_Str} 	:
    ${nrarfcn}=        convert to integer    ${nrarfcn_List}[0]
    IF    ${nrarfcn} < 2000000    Update UE Capability String in Basic Cfg file
    Configure multiple UEs in WTS Basic Configuration File  number_of_ues=${total_number_of_ues}  start_ue_id=${11}
    Backup Airphone WTS Config
    testline.Check TL Infos
    IF  '${flag_la_disabled}'=='True'   Disable Link Adaptation
    ${suite_folder}=    testline.Get test suite directory
    log     ${suite_folder}
    run keyword and ignore error    btslog.Create CPlane Runtime File to gNB    gnb_id=${0}    level=trace
    run keyword and ignore error    btslog.Create CPlane Runtime File to AP      ue_id=${0}    level=trace
    Bring Airphone TL to on Air status
    Wait until Node to be onair state


Backup Airphone WTS Config
    [Arguments]    ${basic_setup_file_name}=basic_setup.cfg
    ${configuration_directory}=  Get Test Suite Config Directory
    Copy File   /opt/iphy/latest/basic_setup.cfg  ${configuration_directory}/${basic_setup_file_name}


Retreive gNB sw version
    ${current_gnb_sw}=  Get gNB SW version
    Append to file  ${OUTPUT_DIR}/sw_version.txt  ${current_gnb_sw}
    ${build}=  Fetch From Left  string=${current_gnb_sw}  marker=_
    # The value of branch here is to distinguish the changes in the TTI Trace dissection between branch 22R3 and others
    ${branch}=  Set Variable If  '${build}'=='SBTS22R3'  branch  master
    RETURN  ${current_gnb_sw}  ${branch}
