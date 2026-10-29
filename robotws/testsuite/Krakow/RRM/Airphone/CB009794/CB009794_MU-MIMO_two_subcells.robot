*** Settings ***

Documentation
...    author: Patryk Wojcik
...    contact: patryk.wojcik@nokia.com
...    Description: Suite description in QC

Library       ../resources/former_l2_sw1/python/traffic_handling.py
Resource      resources/CB009794_resources.robot

Force Tags    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_MP_AP_LO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup     Setup environment
Suite Teardown  Clean suite environment

*** Variables ***
${moid}=  PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${scfc}=  ${CURDIR}/config/SCFC_AEQE_1CELL_8DL8UL.xml
${iphy}=  ${CURDIR}/config/IPHY_AEQE_1CELL_8DL8UL.xml
${lua_cfg_file}=  ${CURDIR}/config/basic_setup_TDD_FR1_one_cell_two_subcells.cfg
@{SWCONFIG_FLAGS_LIST}    0x58046a=1000
${ARTIFACTORY_ROTTA}      https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local
${download_path}          ${ARTIFACTORY_ROTTA}/pawojcik/BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
${token}                  cmVmdGtuOjAxOjAwMDAwMDAwMDA6dVpkdTMwRjNMMW40VmNRRzd4NjltdlVOQjZh
${counters}=              M55369C00000-M55369C00007,M55369C00100-M55369C00107,M55369C00200-M55369C00207

*** Test Cases ***
CB009794-NR_RTWP_measurement_with_MU-MIMO_2subcells_TDD_eCPRI_FR1_SA
    [Setup]  Prepare BIP column for PUSCH
    Wait for next full pm interval
    Set pdu param for internal traffic  UE_ID=1
    Register UE  UE_ID=1  CELL_ID=1
    Establish PDU session  UE_ID=1
    Set pdu param for internal traffic  UE_ID=2
    Register UE  UE_ID=2  CELL_ID=1
    Establish PDU session  UE_ID=2
    Activate beamforming on specific position for two subcells
    Start SA traffic  ue=1  dir=ul  traffic_rate=200Mbps
    Start SA traffic  ue=2  dir=ul  traffic_rate=200Mbps
    Sleep    10s    reason=wait for tput stabilization
    Verify SA traffic  ue=1  dir=ul  expected_traffic=200Mbps  data_rate_type=average
    Verify SA traffic  ue=2  dir=ul  expected_traffic=200Mbps  data_rate_type=average
    Wait for next full pm interval
    Collect BIP logs  alias=two_subcells  duration=5s
    ${pm_counters}=  Wait for next pm interval and get counters
    Convert BIP logs  alias=two_subcells  num_of_ues=2
    Verify that two subcells were used  csv_path=${OUTPUT_DIR}/BIP_LOGS/two_subcells/BIP_PUSCH.csv

    Run keyword and continue on failure  verify counter  counter=M55369C00000  gnb_counters=${pm_counters}  expected_value=-53  margin=3
    Run keyword and continue on failure  verify counter  counter=M55369C00001  gnb_counters=${pm_counters}  expected_value=-53  margin=3
    Run keyword and continue on failure  verify counter  counter=M55369C00002  gnb_counters=${pm_counters}  expected_value=-53  margin=3
    Run keyword and continue on failure  verify counter  counter=M55369C00003  gnb_counters=${pm_counters}  expected_value=-53  margin=3
    Run keyword and continue on failure  verify counter  counter=M55369C00004  gnb_counters=${pm_counters}  expected_value=-53  margin=3
    Run keyword and continue on failure  verify counter  counter=M55369C00005  gnb_counters=${pm_counters}  expected_value=-53  margin=3
    Run keyword and continue on failure  verify counter  counter=M55369C00006  gnb_counters=${pm_counters}  expected_value=-53  margin=3
    Run keyword and continue on failure  verify counter  counter=M55369C00007  gnb_counters=${pm_counters}  expected_value=-53  margin=3

    Run keyword and continue on failure  verify counter  counter=M55369C00100  gnb_counters=${pm_counters}  expected_value=-53  margin=3
    Run keyword and continue on failure  verify counter  counter=M55369C00101  gnb_counters=${pm_counters}  expected_value=-53  margin=3
    Run keyword and continue on failure  verify counter  counter=M55369C00102  gnb_counters=${pm_counters}  expected_value=-53  margin=3
    Run keyword and continue on failure  verify counter  counter=M55369C00103  gnb_counters=${pm_counters}  expected_value=-53  margin=3
    Run keyword and continue on failure  verify counter  counter=M55369C00104  gnb_counters=${pm_counters}  expected_value=-53  margin=3
    Run keyword and continue on failure  verify counter  counter=M55369C00105  gnb_counters=${pm_counters}  expected_value=-53  margin=3
    Run keyword and continue on failure  verify counter  counter=M55369C00106  gnb_counters=${pm_counters}  expected_value=-53  margin=3
    Run keyword and continue on failure  verify counter  counter=M55369C00107  gnb_counters=${pm_counters}  expected_value=-53  margin=3

    Run keyword and continue on failure  verify counter  counter=M55369C00200  gnb_counters=${pm_counters}  expected_value=-53  margin=4
    Run keyword and continue on failure  verify counter  counter=M55369C00201  gnb_counters=${pm_counters}  expected_value=-53  margin=4
    Run keyword and continue on failure  verify counter  counter=M55369C00202  gnb_counters=${pm_counters}  expected_value=-55  margin=5
    Run keyword and continue on failure  verify counter  counter=M55369C00203  gnb_counters=${pm_counters}  expected_value=-55  margin=5
    Run keyword and continue on failure  verify counter  counter=M55369C00204  gnb_counters=${pm_counters}  expected_value=-53  margin=4
    Run keyword and continue on failure  verify counter  counter=M55369C00205  gnb_counters=${pm_counters}  expected_value=-53  margin=4
    Run keyword and continue on failure  verify counter  counter=M55369C00206  gnb_counters=${pm_counters}  expected_value=-55  margin=5
    Run keyword and continue on failure  verify counter  counter=M55369C00207  gnb_counters=${pm_counters}  expected_value=-55  margin=5
    Get counters value and report to rp  counters=${counters}  filepath=${pm_counters}  localmoid=NRCELL-1

    [Teardown]  Run keywords
    ...    Deregister UE  UE_ID=1
    ...    AND  Deregister UE  UE_ID=2
    ...    AND  Deactivate srs beam profile1 for UE1
    ...    AND  Deactivate srs beam profile2 for UE2
    ...    AND    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Keywords ***
Setup environment
    ${CONFIGURE_ENV}    get variable value    ${configure}    "True"
    Run keyword if  ${CONFIGURE_ENV}=="True"
    ...     Get and Update BSR File  download_path=${download_path}  token=${token}
    Prepare suite environment  egate_config=${lua_cfg_file}  scfc=${scfc}  ap_xml=${iphy}  rad_params=@{SWCONFIG_FLAGS_LIST}  x2=False
