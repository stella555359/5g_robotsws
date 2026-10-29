*** Settings ***
Documentation
...        maintainer:   Karol Rybak, Pawel Grabania
...        contact:      karol.rybak@nokia.com, pawel.grabania@nokia.com
...        author:       Karol Rybak, Pawel Grabania
...        description:  Test Cases for CB008285

Resource    ./resources/CB008285_KW.robot

Suite Setup     Prepare suite environment    egate_config=${lua_cfg_file}    scfc=${scfc}  ap_xml=${iphy}  x2=False

Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${lua_cfg_file}=  ${CURDIR}/config/egate_C2.cfg
${scfc}=  ${CURDIR}/config/scfc_C2_beam_true.xml
${iphy}=  ${CURDIR}/config/iphy_C2.xml
${egate_file_AMF}=  ${CURDIR}/config/egate_AMF.cfg
${scfc_AMF}=  ${CURDIR}/config/scfc_AMF.xml
${ap_xml_AMF}=  ${CURDIR}/config/iphy_AMF.xml
${egate_file_FR1}=  ${CURDIR}/config/egate_FR1.cfg
${scfc_FR1}=  ${CURDIR}/config/scfc_FR1.xml
${ap_xml_FR1}=  ${CURDIR}/config/iphy_FR1.xml
${egate_file_B4}=  ${CURDIR}/config/egate_B4.cfg
${scfc_B4}=  ${CURDIR}/config/scfc_B4.xml
${ap_xml_B4}=  ${CURDIR}/config/iphy_B4.xml

@{All_cells}       1    2    3    4    5    6    7    8    9    10
*** Test Cases ***

CB008285-W_DL_peak_throughput_per_UE_for_C2_PRACH_config

    Attach UE SA  ue_id_first=1  ue_id_last=2  pdu=1  nwslice=1  nwslice_reg=1
    Run traffic SA   ue_id=1  dir=dl  loop=5  mbps=175  pdu=1  protocol=tcp
    Sleep  300s
    Verify SA traffic  ue=1  dir=dl  expected_traffic=533Mbps  tolerance=6  data_rate_type=maximum
    Stop SA traffic  ue=1
    Detach UE SA  ue_id_first=1  ue_id_last=2

    Configure env  egate_setup=${CURDIR}/config/egate_C2.cfg
    ...    scfc=${CURDIR}/config/scfc_C2_beam_false.xml  ap_xml=${CURDIR}/config/iphy_C2.xml
    sleep  300s

    Attach UE SA  ue_id_first=1  ue_id_last=2  pdu=1  nwslice=1  nwslice_reg=1
    Run traffic SA   ue_id=1  dir=dl  loop=5  mbps=146  pdu=1  protocol=tcp
    Sleep  300s
    Verify SA traffic  ue=1  dir=dl  expected_traffic=584Mbps  tolerance=6  data_rate_type=maximum
    Stop SA traffic  ue=1
    Detach UE SA  ue_id_first=1  ue_id_last=2

    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report

CB008285-W_UL_peak_throughput_per_UE_for_C2_PRACH_config

    Attach UE SA  ue_id_first=1  ue_id_last=2  pdu=1  nwslice=1  nwslice_reg=1
    Run traffic SA   ue_id=1  dir=ul  loop=2  mbps=143  pdu=1  protocol=tcp
    Sleep  300s
    Verify SA traffic  ue=1  dir=ul  expected_traffic=144Mbps  tolerance=5  data_rate_type=maximum
    Stop SA traffic  ue=1
    Detach UE SA  ue_id_first=1  ue_id_last=2

    Configure env  egate_setup=${CURDIR}/config/egate_C2.cfg
     ...    scfc=${CURDIR}/config/scfc_C2_beam_false.xml  ap_xml=${CURDIR}/config/iphy_C2.xml
    sleep  300s

    Attach UE SA  ue_id_first=1  ue_id_last=2  pdu=1  nwslice=1  nwslice_reg=1
    Run traffic SA   ue_id=1  dir=ul  loop=2  mbps=143  pdu=1  protocol=tcp
    Sleep  300s
    Verify SA traffic  ue=1  dir=ul  expected_traffic=144Mbps  tolerance=5  data_rate_type=maximum
    Stop SA traffic  ue=1
    Detach UE SA  ue_id_first=1  ue_id_last=2

    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report

CB008285-A_FR2_Standalone_deployment_with_two_CELLGROUPs_and_FR1_cell
    Prepare test environment FR1  ${egate_file_FR1}  ${scfc_FR1}  ${ap_xml_FR1}
    gnbcell.Verify All Cells Are Onair

    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report

CB008285_B_008_5GC000740_NG_C_link_locking_unlocking_with_One_AMF_SA_calls
    Prepare test environment 2AMF  ${egate_file_AMF}  ${scfc_AMF}  ${ap_xml_AMF}

    Check All AMF ngLinkStatus    status=Unlocked
    gnbcell.Verify All Cells Are Onair
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55119C00001    2            NG_CU_SETUP_REQUEST_SENT
    ...    M55119C00002    2            NG_CU_SETUP_RESPONSE_RCV
    ...    M55119C00501    0            NG_SHUTDOWN_LOCKED
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counters}

    Attach UE SA    ue_id_first=1  ue_id_last=2  pdu=1  nwslice=1  nwslice_reg=1,2
    Add PDU session    ue_id=1  pdu=2  nwslice=2
    Run traffic SA    ue_id=1  dir=dl  loop=3  mbps=175  pdu=1  protocol=tcp
    Run traffic SA    ue_id=1  dir=dl  loop=3  mbps=175  pdu=2  protocol=tcp
    Run traffic SA   ue_id=1  dir=ul  loop=2  mbps=70  pdu=1  protocol=tcp
    Run traffic SA    ue_id=1  dir=ul  loop=2  mbps=70  pdu=2  protocol=tcp

    Sleep  120s
    Run Keyword And Continue On Failure
    ...    Verify SA traffic  ue=1  dir=dl  expected_traffic=250Mbps  tolerance=20  data_rate_type=average  pdu=1
    Run Keyword And Continue On Failure
    ...    Verify SA traffic  ue=1  dir=ul  expected_traffic=70Mbps  tolerance=20  data_rate_type=average  pdu=1
    Run Keyword And Continue On Failure
    ...    Verify SA traffic  ue=1  dir=dl  expected_traffic=250Mbps  tolerance=20  data_rate_type=average  pdu=2
    Run Keyword And Continue On Failure
    ...    Verify SA traffic  ue=1  dir=ul  expected_traffic=70Mbps  tolerance=20  data_rate_type=average  pdu=2

    Wait For Next Full Pm Interval
    Lock default AMF
    sleep    60s
    Check Only Default AMF ngLinkStatus    status=Locked
    gnbcell.Verify All Cells Are Onair

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55119C00001    0            NG_CU_SETUP_REQUEST_SENT
    ...    M55119C00002    0            NG_CU_SETUP_RESPONSE_RCV
    ...    M55119C00501    1            NG_SHUTDOWN_LOCKED
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counters}

    Run Keyword And Continue On Failure
    ...    Verify SA traffic  ue=1  dir=dl  expected_traffic=250Mbps  tolerance=20  data_rate_type=average  pdu=1
    Run Keyword And Continue On Failure
    ...    Verify SA traffic  ue=1  dir=ul  expected_traffic=70Mbps  tolerance=20  data_rate_type=average  pdu=1
    Run Keyword And Continue On Failure
    ...    Verify SA traffic  ue=1  dir=dl  expected_traffic=250Mbps  tolerance=20  data_rate_type=average  pdu=2
    Run Keyword And Continue On Failure
    ...    Verify SA traffic  ue=1  dir=ul  expected_traffic=70Mbps  tolerance=20  data_rate_type=average  pdu=2

    Wait For Next Full Pm Interval
    Unlock default AMF
    Sleep    60s
    Check All AMF ngLinkStatus    status=Unlocked

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55119C00001    1            NG_CU_SETUP_REQUEST_SENT
    ...    M55119C00002    1            NG_CU_SETUP_RESPONSE_RCV
    ...    M55119C00501    0            NG_SHUTDOWN_LOCKED
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counters}

    Run Keyword And Continue On Failure
    ...    Verify SA traffic  ue=1  dir=dl  expected_traffic=250Mbps  tolerance=20  data_rate_type=average  pdu=1
    Run Keyword And Continue On Failure
    ...    Verify SA traffic  ue=1  dir=ul  expected_traffic=70Mbps  tolerance=20  data_rate_type=average  pdu=1
    Run Keyword And Continue On Failure
    ...    Verify SA traffic  ue=1  dir=dl  expected_traffic=250Mbps  tolerance=20  data_rate_type=average  pdu=2
    Run Keyword And Continue On Failure
    ...    Verify SA traffic  ue=1  dir=ul  expected_traffic=70Mbps  tolerance=20  data_rate_type=average  pdu=2

    Detach UE SA    ue_id_first=1  ue_id_last=2
    gnbcell.Verify All Cells are OnAir

    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report

CB008285-W_DL_peak_throughput_per_UE_for_B4_PRACH_config
    Configure env  egate_setup=${egate_file_B4}  scfc=${scfc_B4}  ap_xml=${ap_xml_B4}
    gnbcell.Verify All Cells Are Onair

    Attach UE SA  ue_id_first=1  ue_id_last=2  pdu=1  nwslice=1  nwslice_reg=1
    Run traffic SA   ue_id=1  dir=dl  loop=6  mbps=85  pdu=1  protocol=tcp
    Sleep  300s
    Verify SA traffic  ue=1  dir=dl  expected_traffic=425Mbps  tolerance=5  data_rate_type=maximum
    Stop SA traffic  ue=1
    Detach UE SA  ue_id_first=1  ue_id_last=2
    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report
