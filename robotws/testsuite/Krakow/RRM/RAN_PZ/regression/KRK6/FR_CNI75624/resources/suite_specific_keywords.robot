*** Settings ***
Documentation
...  author:  Andrzej Pencak, Olga Urbanska
...  contact: andrzej.pencak@nokia.com, olga.urbanska@nokia.com

Library   DateTime    WITH NAME    dt
Library   OperatingSystem     WITH NAME    os
Library   String      WITH NAME   str
Library   taf.ue    WITH NAME    ue
Library   taf.rfrl.ue.logs.qxdm_logs.QxdmLogsCollector      WITH NAME  QxdmLogsCollector
Library   taf.rfrl.ue.logs.qxdm_logs.LicenseKeeperKeywords      WITH NAME  LicenseKeeperKeywords
Library   taf.rfrl.bts.commissioning
Library   taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library   taf.rfrl.utilities.test_config.DefaultFileLocation           WITH NAME    dfl
Library   taf/rfrl/procedures/resources/python/sleeping_cell_detector.py    WITH NAME    scd
Library   testsuite.Krakow.RRM.RAN_PZ.resources.pm_counter_du.PmCounterDu
Library   testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CNI75624/resources/suite_specific_keywords.py
Library   testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CNI75624/resources/smart_attenuator.py    WITH NAME    attenuator
Library   testsuite/Krakow/RRM/RAN_PZ/resources/pcap_verification/flow_verifier.py    WITH NAME    flow_verifier

Resource  taf/rfrl/bts/robot/gnb.robot
Resource  taf/rfrl/common_resources/common_step/interface.robot
Resource  testsuite/Krakow/RRM/RAN_PZ/resources/collect_logs.robot
Resource  testsuite/Krakow/RRM/RAN_PZ/resources/resources.robot
Resource  taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Keywords ***

Suite Setup
    Set cells IDs
    ${HOSTNAME}=    taf.rfrl.utilities.tl_config.Get Testline Name
    ${RELEASE}=     dfl.Get Commissioning Branch
    Set Suite Variable    @{GNB_1_CELL_1_RF_PORTS}    ${5}    ${6}
    Set Suite Variable    @{GNB_1_CELL_2_RF_PORTS}    ${11}    ${12}
    Set Suite Variable    @{GNB_2_CELL_1_RF_PORTS}    ${7}   ${8}
    Set Suite Variable    ${5GC001085_C02_scfc_gnb0}    commissionings/Krakow/${HOSTNAME}/${RELEASE}/5GC001085_C02_2CC_GNB0_SCF_gps.xml
    Set Suite Variable    ${CNI75624_06_scfc_gnb0}      commissionings/Krakow/${HOSTNAME}/${RELEASE}/CNI75624_06_2CC_GNB0_SCF_gps.xml
    Set Suite Variable    ${CNI75624_06_scfc_gnb1}      commissionings/Krakow/${HOSTNAME}/${RELEASE}/CNI75624_06_2CC_GNB1_SCF_gps.xml
    Set Suite Variable    ${CNI75624_01_scfc_gnb0}      commissionings/Krakow/${HOSTNAME}/${RELEASE}/CNI75624_01_02_2CC_GNB0_SCF_gps.xml
    Set Suite Variable    ${CNI75624_03_scfc_gnb0}      commissionings/Krakow/${HOSTNAME}/${RELEASE}/CNI75624_03_2CC_GNB0_SCF_gps.xml
    Set Suite Variable    ${CNI75624_03_scfc_gnb1}      commissionings/Krakow/${HOSTNAME}/${RELEASE}/CNI75624_03_2CC_GNB1_SCF_gps.xml
    Set Suite Variable    ${5GC001085_B07_scfc_gnb0}      commissionings/Krakow/${HOSTNAME}/${RELEASE}/5GC001085_B07_2CC_GNB0_SCF_gps.xml
    Set Suite Variable    ${attenuation_for_serving}        10dB
    Set Suite Variable    ${attenuation_for_neighbors}     30dB
    Set Suite Variable    ${attenuation_interval}          2s

Test Setup
    [arguments]    ${scfc_gnb0}=${None}    ${scfc_gnb1}=${None}
    [documentation]    This keyword prepares environment befor each test case.
    ...                :param scfc_gnb0:    path to dedicated scfc file for gNB1l
    ...                :param scfc_gnb1:    path to dedicated scfc file for gNB2
    Log Action To Console    Start test
    Perform Commissioning    scfc_gnb0=${scfc_gnb0}    scfc_gnb1=${scfc_gnb1}
    Run Keyword And Ignore Error    scd.Enable Sleeping Cell Detection Feature
    scd.Start Sleeping Cell Detection Watchdog For All Bts       log_dir=${LOG_PATH}/SleepingCell
    Download gNB Configuration File
    ...    local_dir=${OUTPUT DIR}
    ...    filename=scfc_gnb0_before_test.xml
    ...    gnb_id=0
    ...    du_id=0
    Run keyword if     '${scfc_gnb1}'!='${None}'    Download gNB Configuration File
    ...    local_dir=${OUTPUT DIR}
    ...    filename=scfc_gnb1_before_test.xml
    ...    gnb_id=1
    ...    du_id=0
    Upload QxdmLogCatch Script
    ue.Require Ue    UE_1  capabilities=REAL_ANDROID_UE
    Connect to license keeper client    lkc_path=C:/auto/QPM_LK3.1.2
    Get qxdm and qcat licence
    Kill all Qxdm processes
    Clear Log Directory
    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}    alias=RADIO_RACK_01

Test Teardown
    [arguments]    ${clear_gnb1}=${False}
    [documentation]    This keyword clears environment after each test case.
    ...                :param clear_gnb1:    the flag causes the cleaning of gNB2
    Log Action To Console    End test
    Download gNB Configuration File
    ...    local_dir=${OUTPUT DIR}
    ...    filename=scfc_gnb0_after_test.xml
    ...    gnb_id=0
    ...    du_id=0
    Run keyword if     ${clear_gnb1}  Download gNB Configuration File
    ...    local_dir=${OUTPUT DIR}
    ...    filename=scfc_gnb1_after_test.xml
    ...    gnb_id=1
    ...    du_id=0
    Run Keyword And Ignore Error    ue.Detach Ue    UE_1
    Release qxdm and qcat licence
    scd.Verify Sleeping Cell Detection
    ${ports}=     Combine Lists   ${GNB_1_CELL_1_RF_PORTS}   ${GNB_1_CELL_2_RF_PORTS}   ${GNB_2_CELL_1_RF_PORTS}
    ${values}=    Create List     110dB    110dB    110dB    110dB    110dB    110dB
    attenuator.set_ports_attenuation    RADIO_RACK_01    ${ports}    ${values}
    Common Postconditions

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]  :param msg:     message logged
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   dt.Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

Detach UE
    Log Action To Console    Detach UE
    ue.Detach Ue    UE_1

Trigger Measurement Report by the UE and perform handover from gNB1 cell1 to already known gNB2 cell1
    Log Action To Console    Trigger Measurement Report by the UE and perform handover from gNB1 cell1 to gNB2 cell1
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M
    ${pcap_name}=  Set variable    HO_${date}.pcap
    Start Tcpdump On CU    filename=${pcap_name}    interface=any    protocol=sctp
    attenuator.execute_fading_scenario    RADIO_RACK_01    source_ports=${GNB_1_CELL_1_RF_PORTS}    target_ports=${GNB_2_CELL_1_RF_PORTS}
    ...                     fading_step=2dB    fading_interval=${attenuation_interval}
    ...                     fading_min=${attenuation_for_serving}    fading_max=${attenuation_for_neighbors}
    Sleep    10s
    Stop Tcpdump On CU And Download Logs    filename=${pcap_name}
    Wait till collecting qxdm hdf log is finished
    Convert Hdf Log To Txt    timeout=240
    Sleep    5s
    Download Qxdm Logs
    Check Ue Measurements And Handover    ${gnb2_cell1_id}
    Sleep    60s
    Check If any Object Contains Specified Parameters     object_type=NRREL    gNbId=${tl.gnbs[1].instance_id}    lcrId=1
    Check If any Object Contains Specified Parameters     object_type=NRADJNRCELL    gNbId=${tl.gnbs[1].instance_id}    lcrId=1

Change ssbFrequency in newly created NRADJNRCELL
    Log Action To Console    Change ssbFrequency in NRADJNRCELL
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRADJNRCELL-12288
    ...    param_name=ssbFrequency    param_value=636636
    ...    skip_parameter_relation_errors=false    timeout=120

Change physCellId in recently updated NRADJNRCELL
    Log Action To Console    Change physCellId in NRADJNRCELL
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRADJNRCELL-12288
    ...    param_name=physCellId    param_value=111
    ...    skip_parameter_relation_errors=false    timeout=120

Check ssbFrequency was updated in NRADJNRCELL after ANR
    Log Action To Console    Check ssbFrequency updated in NRADJNRCELL
    Check If any Object Contains Specified Parameters     object_type=NRADJNRCELL
    ...    ssbFrequency=${gnb2_cell1_ssb_frequency}

Check physCellId was updated in NRADJNRCELL after ANR
    Log Action To Console    Check physCellId updated in NRADJNRCELL
    Check If any Object Contains Specified Parameters     object_type=NRADJNRCELL    physCellId=${gnb2_cell1_id}

Perform three more ssbFrequency and physCellId changes followed by ANR
    Repeat Keyword    3 times
    ...    Check ssbFrequency or physcellId is updated in NRADJNRCELL after successful ANR execution

Check ssbFrequency or physcellId is updated in NRADJNRCELL after successful ANR execution
    Change ssbFrequency in newly created NRADJNRCELL
    Attach 5G UE to gNB1 cell1 and collect logs
    Trigger Measurement Report by the UE and perform handover from gNB1 cell1 to already known gNB2 cell1
    Detach UE
    Check ssbFrequency was updated in NRADJNRCELL after ANR

    Change physCellId in recently updated NRADJNRCELL
    Attach 5G UE to gNB1 cell1 and collect logs
    Trigger Measurement Report by the UE and perform handover from gNB1 cell1 to already known gNB2 cell1
    Detach UE
    Check physCellId was updated in NRADJNRCELL after ANR

Check if any resource was leaked during test
    Log Action To Console    Check if any leaking resources after test
    Start Hanging Resource File    ip=192.168.255.1    port=15007    username=toor4nsn    password=oZPS0POrRieRtu

Set cells IDs
    ${number_of_cells}=    gnbcell.Get Number Of Cells    bts_id=0    du_id=0
    ${gnb1_cell1_parameters}=  gnbcell.Get Cell Parameters    bts_id=0    cell_id=${1}    du_id=0
    ${gnb2_cell1_parameters}=  gnbcell.Get Cell Parameters    bts_id=1    cell_id=${1}    du_id=0
    Run Keyword IF   ${number_of_cells} == 2     Set ID of second cell
    Set Suite Variable    ${gnb1_cell1_id}      ${gnb1_cell1_parameters['physCellId']}
    Set Suite Variable    ${gnb1_cell1_nrid}    ${gnb1_cell1_parameters['nrCellIdentity']}
    Run Keyword and Ignore Error    Set Suite Variable    ${gnb1_cell2_id}      ${gnb1_cell2_parameters['physCellId']}
    Set Suite Variable    ${gnb2_cell1_id}      ${gnb2_cell1_parameters['physCellId']}
    Set Suite Variable    ${gnb2_cell1_ssb_frequency}    ${gnb2_cell1_parameters['arfcnSsbPbch']}
    Run Keyword and Ignore Error     Set Suite Variable    ${gnb2_cell2_id}      ${gnb2_cell2_parameters['physCellId']}

Set ID of second cell
    [documentation]    This keyword sets ID of second cell in BTS for test.
    ${gnb1_cell2_parameters}=  gnbcell.Get Cell Parameters    bts_id=0    cell_id=${2}    du_id=0
    ${gnb2_cell2_parameters}=  gnbcell.Get Cell Parameters    bts_id=1    cell_id=${2}    du_id=0


Perform Commissioning
    [arguments]    ${scfc_gnb0}=${None}    ${scfc_gnb1}=${None}
    [documentation]    This keyword performs commissioning of both gNBs.
    ...                :param scfc_gnb0:    path to dedicated scfc file for gNB1
    ...                :param scfc_gnb1:    path to dedicated scfc file for gNB2
    Perform Commissioning For Gnbs    ${scfc_gnb0}      ${scfc_gnb1}
    Wait Until Keyword Succeeds           600      20      gnbcell.Verify Cell Is Onair   bts_id=0
    Run keyword if    '${scfc_gnb1}'!='${None}'     Wait Until Keyword Succeeds      600      20    gnbcell.Verify Cell Is Onair    bts_id=1


Perform Commissioning For Specified gNB
    [arguments]    ${gnb_id}    ${gnb_scfc}
    [documentation]    This keyword performs commissioning of specified gNB and checks state of gNB after
    ...                commissiong procedure.
    ...                :param gnb_id:    id of gNB that will be commissioned
    ...                :param gnb_scfc:    path to dedicated scfc file for gNB
    Perform Full Commissioning On Classical Gnb    bts_id=${gnb_id}   scf_path=${gnb_scfc}
    Verify if all cells are onair    300 sec    15 sec

Setup Attenuator
    ${config_dir}=    Get Testline Configuration Directory Path
    attenuator.Load Attenuation Config    ${config_dir}/attenuator.yaml
    attenuator.Require attenuator setup of    GNB_1_CELL_1_RF_PORTS
    attenuator.Require attenuator setup of    GNB_1_CELL_2_RF_PORTS
    attenuator.Require attenuator setup of    GNB_2_CELL_1_RF_PORTS

Perform Decommissioning
    [arguments]    ${clear_gnb0}=${False}    ${clear_gnb1}=${False}
    [documentation]    This keyword performs decommissioning of specified gNB.
    ...                :param clear_gnb0:    the flag causes the cleaning of gNB1
    ...                :param clear_gnb1:    the flag causes the cleaning of gNB2
    Run Keyword If    "${clear_gnb0}" != "${False}"    Perform Full Commissioning On Classical Gnb
    ...    bts_id=0    scf_path=${OUTPUT DIR}/scfc_gnb0_default.xml
    Run Keyword If    "${clear_gnb1}" != "${False}"    Perform Full Commissioning On Classical Gnb
    ...    bts_id=1    scf_path=${OUTPUT DIR}/scfc_gnb1_default.xml
    Verify if all cells are onair    300 sec    15 sec

Attach 5G UE to gNB1 cell1 and collect logs
    Log Action To Console    Attach 5G UE to gNB1 cell1
    ${ports}=     Combine Lists   ${GNB_1_CELL_1_RF_PORTS}    ${GNB_1_CELL_2_RF_PORTS}   ${GNB_2_CELL_1_RF_PORTS}
    ${values}=    Create List     ${attenuation_for_serving}   ${attenuation_for_serving}     110dB    110dB     110dB    110dB
    attenuator.set_ports_attenuation    RADIO_RACK_01    ${ports}    ${values}
    Sleep    5s
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M
    ${pcap_name}=  Set variable    UE_attach_${date}.pcap
    Start Tcpdump On CU    filename=${pcap_name}    interface=any    protocol=sctp
    Collect Qxdm Hdf Log    duration=120
    Sleep    20s
    ue.Attach Ue    UE_1
    Sleep    3s
    Stop Tcpdump On CU And Download Logs    filename=${pcap_name}
    Verify Attach Cell Id    pcap_filename=${pcap_name}    expected_nr_cell_id=${gnb1_cell1_nrid}

Trigger Measurement Report by the UE and perform handover from gNB1 cell1 to gNB1 cell2
    Log Action To Console    Trigger Measurement Report by the UE and perform handover from gNB1 cell1 to gNB1 cell2
    Check If There Are No Objects In Scf    object_type=NRREL
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M
    ${pcap_name}=  Set variable    HO_${date}.pcap
    Start Tcpdump On CU    filename=${pcap_name}    interface=any    protocol=sctp
    attenuator.execute_fading_scenario    RADIO_RACK_01    source_ports=${GNB_1_CELL_1_RF_PORTS}    target_ports=${GNB_1_CELL_2_RF_PORTS}
    ...                     fading_step=2dB    fading_interval=${attenuation_interval}
    ...                     fading_min=${attenuation_for_serving}    fading_max=${attenuation_for_neighbors}
    Sleep    10s
    Stop Tcpdump On CU And Download Logs    filename=${pcap_name}
    Wait till collecting qxdm hdf log is finished
    Convert Hdf Log To Txt    timeout=240
    Sleep    5s
    Download Qxdm Logs
    Check Ue Measurements And Handover    cell_id=${gnb1_cell2_id}
    Sleep    60s
    Check If any Object Contains Specified Parameters     object_type=NRREL    gNbId=${tl.gnbs[0].instance_id}    lcrId=2

Set parameter on gNB1
    Log Action To Console    Set maxNumNrAnrMoiAllowed to 1 on gNB1
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
    ...    param_name=maxNumNrAnrMoiAllowed    param_value=1
    ...    skip_parameter_relation_errors=true    timeout=300

Set consecRecheckForNrNbRemoval to 2 parameter on gNB1
    Log Action To Console    Set consecRecheckForNrNbRemoval to 2 parameter on gNB1
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRANRPR-1
    ...    param_name=consecRecheckForNrNbRemoval    param_value=2
    ...    skip_parameter_relation_errors=false    timeout=120

Set idleTimeForNrNbRemoval to 2 parameter on gNB1
    Log Action To Console    Set idleTimeForNrNbRemoval to 2 parameter on gNB1
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRANRPR-1
    ...    param_name=idleTimeForNrNbRemoval    param_value=2
    ...    skip_parameter_relation_errors=false    timeout=120

Set reportAmountSA to r1 parameter on gNB1 cell1
    Log Action To Console    Set reportAmountSA to r1 parameter on gNB1 cell1
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1
    ...    param_name=reportAmountSA    param_value=r1
    ...    skip_parameter_relation_errors=false    timeout=120

Set reportAmountSA to r4 parameter on gNB1 cell1
    Log Action To Console    Set reportAmountSA to r4 parameter on gNB1 cell1
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1
    ...    param_name=reportAmountSA    param_value=r4
    ...    skip_parameter_relation_errors=false    timeout=120

Trigger Measurement Report by the UE and perform handover from gNB1 cell1 to gNB2 cell1
    Log Action To Console    Trigger Measurement Report by the UE and perform handover from gNB1 cell1 to gNB2 cell1
#    Check If There Are No Objects In Scf    object_type=NRREL
#    Check If There Are No Objects In Scf    object_type=NRADJNRCELL
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M
    ${pcap_name}=  Set variable    HO_${date}.pcap
    Start Tcpdump On CU    filename=${pcap_name}    interface=any    protocol=sctp
    attenuator.execute_fading_scenario    RADIO_RACK_01    source_ports=${GNB_1_CELL_1_RF_PORTS}    target_ports=${GNB_2_CELL_1_RF_PORTS}
    ...                     fading_step=2dB    fading_interval=${attenuation_interval}
    ...                     fading_min=${attenuation_for_serving}    fading_max=${attenuation_for_neighbors}
    Sleep    10s
    Stop Tcpdump On CU And Download Logs    filename=${pcap_name}
    Wait till collecting qxdm hdf log is finished
    Convert Hdf Log To Txt    timeout=240
    Sleep    5s
    Download Qxdm Logs
    Check Ue Measurements And Handover    ${gnb2_cell1_id}
    Sleep    60s
    Check If any Object Contains Specified Parameters     object_type=NRREL    gNbId=${tl.gnbs[1].instance_id}    lcrId=1
    Check If any Object Contains Specified Parameters     object_type=NRADJNRCELL    gNbId=${tl.gnbs[1].instance_id}    lcrId=1

Perform handover from gNB2 cell1 to gNB1 cell1
    Log Action To Console    Perform handover from gNB2 cell1 to gNB1 cell1
    attenuator.execute_fading_scenario    RADIO_RACK_01    source_ports=${GNB_2_CELL_1_RF_PORTS}    target_ports=${GNB_1_CELL_1_RF_PORTS}
    ...                    fading_step=2dB    fading_interval=${attenuation_interval}
    ...                    fading_min=${attenuation_for_serving}    fading_max=${attenuation_for_neighbors}
    Sleep    10s
    Check Ue Handover    ${gnb1_cell1_id}
    ${ports}=     Combine Lists   ${GNB_2_CELL_1_RF_PORTS}
    ${values}=    Create List     110dB    110dB
    attenuator.set_ports_attenuation    RADIO_RACK_01    ${ports}    ${values}

Add PM Counter to checklist and trigger Measurement Report by the UE with gNB2 cell2
    Log Action To Console    Trigger Measurement Report by the UE with gNB2 cell2
    ${number_of_nrrels_before_measurements}=  Get Number Of Objects In Scf    object_type=NRREL
    ${expected_counter_value_range}=    Create List    ${1}    ${12}
    Add counter to checklist Du     ${failed_handovers_per_NRREL}     NRCELL    1    ${expected_counter_value_range}
    attenuator.execute_fading_scenario    RADIO_RACK_01    source_ports=${GNB_1_CELL_1_RF_PORTS}    target_ports=${GNB_2_CELL_2_RF_PORTS}
    ...                   fading_step=2dB    fading_interval=${attenuation_interval}
    ...                   fading_min=${attenuation_for_serving}    fading_max=${attenuation_for_neighbors}
    Sleep    10s
    Check Ue Measurements
    ${number_of_nrrels_after_measurements}=  Get Number Of Objects In Scf    object_type=NRREL
    Should Be Equal     ${number_of_nrrels_before_measurements}    ${number_of_nrrels_after_measurements}

Check failed_handovers_per_NRREL counter value
    Log Action To Console    Check failed_handovers_per_NRREL counter value
    Verify DU counter checklist

Assert Existence Of Nrrels and Nradjnrcell In Scf for gNB2 cell1
    Log Action To Console    Assert Existence Of Nrrels and Nradjnrcell In Scf for gNB2 cell1
    Check If any Object Contains Specified Parameters     object_type=NRREL    gNbId=${tl.gnbs[1].instance_id}    lcrId=1
    Check If any Object Contains Specified Parameters     object_type=NRADJNRCELL    gNbId=${tl.gnbs[1].instance_id}    lcrId=1

Perform handover from gNB1 cell1 to gNB2 cell1
    Log Action To Console    Perform handover from gNB1 cell1 to gNB2 cell1
    attenuator.execute_fading_scenario    RADIO_RACK_01    source_ports=${GNB_1_CELL_1_RF_PORTS}    target_ports=${GNB_2_CELL_1_RF_PORTS}
    ...                     fading_step=2dB    fading_interval=${attenuation_interval}
    ...                     fading_min=${attenuation_for_serving}    fading_max=${attenuation_for_neighbors}
    Sleep    10s
    Wait till collecting qxdm hdf log is finished
    Convert Hdf Log To Txt    timeout=240
    Sleep    5s
    Download Qxdm Logs
    Check Ue Handover    ${gnb2_cell1_id}

Trigger Handover from gNB1 cell1 to gNB1 cell2
    Log Action To Console    Perform handover from gNB1 cell1 to gNB1 cell2
    attenuator.execute_fading_scenario    RADIO_RACK_01    source_ports=${GNB_1_CELL_1_RF_PORTS}    target_ports=${GNB_1_CELL_2_RF_PORTS}
    ...                      fading_step=2dB    fading_interval=${attenuation_interval}
    ...                      fading_min=${attenuation_for_serving}    fading_max=${attenuation_for_neighbors}
    Sleep    10s
    Wait till collecting qxdm hdf log is finished
    Convert Hdf Log To Txt    timeout=240
    Sleep    5s
    Download Qxdm Logs
    Check Ue Measurements And Handover    ${gnb1_cell2_id}

Trigger Handover from gNB1 cell2 to gNB1 cell1
    Log Action To Console    Perform handover from gNB1 cell2 to gNB1 cell1
    Clear Log Directory
    Collect Qxdm Hdf Log    duration=50
    attenuator.execute_fading_scenario    RADIO_RACK_01    source_ports=${GNB_1_CELL_2_RF_PORTS}    target_ports=${GNB_1_CELL_1_RF_PORTS}
    ...                     fading_step=2dB    fading_interval=${attenuation_interval}
    ...                     fading_min=${attenuation_for_serving}    fading_max=${attenuation_for_neighbors}
    Sleep    10s
    Wait till collecting qxdm hdf log is finished
    Convert Hdf Log To Txt    timeout=240
    Sleep    5s
    Download Qxdm Logs
    Check Ue Measurements And Handover    ${gnb1_cell1_id}

Check if relations appered under both cells
    Log Action To Console    Wait for Relations to appear in WebEM
    Sleep    30s
    Check If any Object Contains Specified Parameters     object_type=NRREL    gNbId=${tl.gnbs[0].instance_id}    lcrId=2
    Sleep    40s
    Check If any Object Contains Specified Parameters     object_type=NRREL    gNbId=${tl.gnbs[0].instance_id}    lcrId=1

Change parameter maxNumOfRrc to 0 on gNB1 cell2
    Log Action To Console    Change parameter maxNumOfRrc to 0 on gNB1 cell2
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-2
    ...    param_name=maxNumOfRrcSA    param_value=0
    ...    skip_parameter_relation_errors=true    timeout=300

Perform few consecutive unsuccessful Handovers from gNB1 cell1 to gNB1 cell2 and check that NRREL was removed
    Repeat Keyword    4 times    Perform unsuccessful handover from gNB1 cell1 to gNB1 cell2
    Sleep  30s
    Check Only One Relation Existence
    Check if relation under cell2 wasn't removed

Perform unsuccessful handover from gNB1 cell1 to gNB1 cell2
    Log Action To Console    Perform unsuccessful handover from gNB1 cell1 to gNB1 cell2
    attenuator.execute_fading_scenario    RADIO_RACK_01    source_ports=${GNB_1_CELL_1_RF_PORTS}    target_ports=${GNB_1_CELL_2_RF_PORTS}
    ...                    fading_step=2dB    fading_interval=1s
    ...                    fading_min=${attenuation_for_serving}    fading_max=${attenuation_for_neighbors}
    attenuator.execute_fading_scenario    RADIO_RACK_01    source_ports=${GNB_1_CELL_2_RF_PORTS}    target_ports=${GNB_1_CELL_1_RF_PORTS}
    ...                     fading_step=2dB    fading_interval=1s
    ...                     fading_min=${attenuation_for_serving}    fading_max=${attenuation_for_neighbors}
    Run Keyword and Ignore Error    Check Ue Measurements
    Reattach UE to gNB1 cell1

Change parameter on gNB1 cell2 maxNumOfRrc back to 250
    Log Action To Console    Change maxNumOfRrc on gNB1 Cell2 back to 250
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=0    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-2
    ...    param_name=maxNumOfRrcSA    param_value=250
    ...    skip_parameter_relation_errors=true    timeout=300

Try to trigger successful Handover from gNB1 cell1 to gNB1 cell2
    Log Action To Console    Trigger successful handover from gNB1 cell1 to gNB1 cell2 after NRREL delition
    attenuator.execute_fading_scenario    RADIO_RACK_01    source_ports=${GNB_1_CELL_1_RF_PORTS}    target_ports=${GNB_1_CELL_2_RF_PORTS}
    ...                     fading_step=2dB    fading_interval=${attenuation_interval}
    ...                     fading_min=${attenuation_for_serving}    fading_max=${attenuation_for_neighbors}
    Wait till collecting qxdm hdf log is finished
    Convert Hdf Log To Txt    timeout=240
    Sleep    5s
    Download Qxdm Logs
    Check Ue Measurements And Handover    ${gnb1_cell2_id}

Perform 5 consecutive Handover failures to force NRRELs' automatic removal
    Perform configuration parameter recommissioning on gNB
    ...    gnb_id=1    du_id=0
    ...    dist_name=MRBTS-${tl.gnbs[1].instance_id}/NRBTS-${tl.gnbs[1].instance_id}/NRCELL-1
    ...    param_name=maxNumOfRrcSA    param_value=0
    ...    skip_parameter_relation_errors=true    timeout=300
    Repeat Keyword    5 times    Trigger Measurement Report by the UE and perform unsuccessful handover from gNB1 cell1 to gNB2 cell1
    Sleep    60s
    Check If any Object Contains Specified Parameters     object_type=NRREL    gNbId=${tl.gnbs[1].instance_id}    lcrId=1

Trigger Measurement Report by the UE and perform unsuccessful handover from gNB1 cell1 to gNB2 cell1
    Log Action To Console    Trigger Measurement Report by the UE and perform unsuccessful handover from gNB1 cell1 to gNB2 cell1
    ${values_10db}=     Create List    10dB     10dB
    ${values_20db}=    Create List     20dB     20dB
    ${values_30db}=    Create List     30dB     30dB
    attenuator.set_ports_attenuation    RADIO_RACK_01    ${GNB_2_CELL_1_RF_PORTS}    ${values_30db}
    Sleep    1s
    attenuator.set_ports_attenuation    RADIO_RACK_01    ${GNB_1_CELL_1_RF_PORTS}    ${values_20db}
    Sleep    1s
    attenuator.set_ports_attenuation    RADIO_RACK_01    ${GNB_1_CELL_1_RF_PORTS}    ${values_30db}
    Sleep    1s
    attenuator.set_ports_attenuation    RADIO_RACK_01    ${GNB_2_CELL_1_RF_PORTS}    ${values_10db}
    Sleep    3s
    Run Keyword And Ignore Error    Check Ue Measurements And Handover    ${gnb2_cell1_id}
    Reattach UE to gNB1 cell1


Fail And Log Error
    [Arguments]    ${msg}
    [Documentation]   :param msg: message logged
    Log     message=${msg}   level=ERROR
    Fail    msg=${msg}

Check Ue Measurements And Handover
    [arguments]    ${cell_id}
    [documentation]    This keyword checks if measurement messages have been sent and if handover procedure
    ...                has been successful.
    ...                :param cell_id:    target cell ID during handover procedure
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M_%S
    Verify CGI Request with Drx Release and ANR Drx Profile Configuration Occured in RRC Messages    file_path=${OUTPUT_DIR}/qxdm.txt
    Verify CGI Info and Handover Succeeded in RRC Messages    file_path=${OUTPUT_DIR}/qxdm.txt    target_cell_pci=${cell_id}

Check Ue Handover
    [arguments]    ${cell_id}
    [documentation]    This keyword checks if handover procedure has been successful.
    ...                :param cell_id:    target cell ID during handover procedure
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M_%S
    Verify Handover Succeeded in RRC Messages    file_path=${OUTPUT_DIR}/qxdm.txt    target_cell_pci=${cell_id}

Check Ue Measurements
    [documentation]    This keyword checks if measurement messages have been sent.
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M_%S
    Wait till collecting qxdm hdf log is finished
    Convert Hdf Log To Txt    timeout=240
    Sleep    5s
    Download Qxdm Logs
    Verify CGI Request with Drx Release and ANR Drx Profile Configuration Occured in RRC Messages    file_path=${OUTPUT_DIR}/qxdm.txt

Get Testline Configuration Directory Path
    ${CONFIG_FOLDER}=    Get Testline Name
    [return]    testline_configuration/${CONFIG_FOLDER}

Verify Attach Cell Id
    [arguments]    ${pcap_filename}    ${expected_nr_cell_id}
    [documentation]    This keyword checks ID of attached cell.
    ...                :param pcap_filename:    filename of pcap with caught messages
    ...                :param expected_nr_cell_id:    expected cell's nrcellid
    ${hex_expected_nr_cell_id}=    Get Nr Cell Id In Hex    ${expected_nr_cell_id}
    ${message_found}=    flow_verifier.Check If Message Is In Flow
    ...    awaited_message=UplinkNASTransport(contains(*nRCellIdentity=${hex_expected_nr_cell_id}))
    ...    pcap_file=${OUTPUT_DIR}/${pcap_filename}
    Run Keyword If    ${message_found} == ${False}    Fail    msg=Ue did not attach to expected cell.

Check Two Relations Existence
    ${number_of_nrrels_2}=     Get Number Of Objects In Scf    object_type=NRREL
    Should Be Equal As Integers    ${number_of_nrrels_2}     2

Check Only One Relation Existence
    ${number_of_nrrels_1}=     Get Number Of Objects In Scf    object_type=NRREL
    Should Be Equal As Integers    ${number_of_nrrels_1}     1

Check if relation under cell2 wasn't removed
    Check If any Object Contains Specified Parameters     object_type=NRREL    gNbId=${tl.gnbs[0].instance_id}    lcrId=1

Reattach UE to gNB1 cell1
    ue.Detach Ue    UE_1
    Sleep  3s
    Kill all Qxdm processes
    Clear Log Directory
    Attach 5G UE to gNB1 cell1 and collect logs

Wait enough time to force NRRELs' automatic removal
    Sleep    180s
    Check If any Object Contains Specified Parameters     object_type=NRREL    gNbId=${tl.gnbs[1].instance_id}    lcrId=1

Try to Trigger HO to gNB2 cell1
    Add counter to checklist Du     ${XN_SETUP_REQUEST_SENT}     NRBTS    ${tl.gnbs[0].instance_id}    1
    Add counter to checklist Du     ${XN_SETUP_RESPONSE_RECEIVED}     NRBTS     ${tl.gnbs[0].instance_id}    1
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M
    ${pcap_name}=  Set variable    Xn_setup_${date}.pcap
    Start Tcpdump On CU    filename=${pcap_name}    interface=any    protocol=sctp
    Log Action To Console    Try to perform handover from gNB1 cell1 to gNB2 cell1 to create Xn link
    Repeat Keyword    1 times    Try to Trigger HO to gNB2 cell1 to create Xn link
    Stop Tcpdump On CU And Download Logs    filename=${pcap_name}
    Check Ue Measurements
    Reattach UE to gNB1 cell1

Try to Trigger HO to gNB2 cell1 to create Xn link
    attenuator.execute_fading_scenario    RADIO_RACK_01    source_ports=${GNB_1_CELL_1_RF_PORTS}    target_ports=${GNB_2_CELL_1_RF_PORTS}
    ...                    fading_step=2dB    fading_interval=${attenuation_interval}
    ...                    fading_min=${attenuation_for_serving}    fading_max=${attenuation_for_neighbors}
    Log Action To Console    End of Xn link creation try

Check counters: XN_SETUP_REQUEST_SENT and XN_SETUP_RESPONSE_RECEIVED
    Log Action To Console    Check XN_SETUP_REQUEST_SENT and XN_SETUP_RESPONSE_RECEIVED counters value
    Verify DU counter checklist

Verify Xn link existance in WebEM
    Log Action To Console    Verify Xn link existance in WebEM
    Assert Existence Of Xnlink In Scf

Verify NRREL existance in WebEM
    Log Action To Console    Verify NRREL existance in WebEM
    Sleep    60s
    Check If any Object Contains Specified Parameters     object_type=NRREL    gNbId=${tl.gnbs[1].instance_id}    lcrId=1
