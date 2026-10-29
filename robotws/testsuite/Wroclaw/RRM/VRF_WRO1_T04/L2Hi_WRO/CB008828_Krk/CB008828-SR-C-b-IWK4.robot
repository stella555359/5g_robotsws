*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2
    ...    CLOUD_5G_I_MP_AP_LO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot
Library     taf.sbts.oam.coam.admin    WITH NAME   coam
Library     testsuite.Wroclaw.RRM.VRF_WRO1_T04.resources.Tokens

Documentation
...    author: Magdalena Hebda
...    contact: magdalena.hebda@nokia.com
...    Description: Suite description in QC

Suite Setup     Setup environment

*** Variables ***
${moid}=  PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${scfc}=  ${CURDIR}/config/scfc_AEQE_1CELL_8DL8UL.xml
${iphy}=  ${CURDIR}/config/iphy_AEQE_1CELL_8DL8UL.xml
${lua_cfg_file}=  ${CURDIR}/config/config_TDD_FR1_one_cell_two_subcells.cfg
@{SWCONFIG_FLAGS_LIST}    0x58046a=1000
${ARTIFACTORY_ROTTA}  https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local
${download_path}  ${ARTIFACTORY_ROTTA}/pawojcik/BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip

*** Test Cases ***
CB008828-SR-C-b-IWK4_Interaction_between_resource_group_scheduler_and_enhanced_MU-MIMO
    [Setup]    Prepare test environment

    ${ues_rnti}    Create Dictionary
    Set Suite Variable  ${ues_rnti}
    Register multi UEs and establish pdu sessions
    Activate beamforming on specific position for two subcells
    Start SA traffic for multi UEs

    Start TTI trace collection

    Sleep    15s
    Stop collecting logs
#    Run Keyword And Continue On Failure    Stop SA traffic for UEs
    Log to console    \n------Verify tti trace
    Verify SA traffic for ues
    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                               expected_tti=C-b-IWK4
    ...                                               cell_id=50
    ...                                               ues=${ues_rnti}

    [Teardown]  Run keywords
    ...    Deregister UE  UE_ID=1
    ...    AND    Deregister UE  UE_ID=2
    ...    AND    Deregister UE  UE_ID=3
    ...    AND    Deregister UE  UE_ID=4
    ...    AND    Deregister UE  UE_ID=5
    ...    AND    Deregister UE  UE_ID=6
    ...    AND    Deregister UE  UE_ID=7
    ...    AND    Deregister UE  UE_ID=8
    ...    AND    Deregister UE  UE_ID=9
    ...    AND    Deregister UE  UE_ID=10
    ...    AND    Deactivate srs beam profile1 for UE1
    ...    AND    Deactivate srs beam profile2 for UE2
    ...    AND    Deactivate srs beam profile3 for UE3
    ...    AND    Deactivate srs beam profile4 for UE4
    ...    AND    Deactivate srs beam profile5 for UE5
    ...    AND    Deactivate srs beam profile6 for UE6
    ...    AND    Deactivate srs beam profile7 for UE7
    ...    AND    Deactivate srs beam profile8 for UE8
    ...    AND    Deactivate srs beam profile9 for UE9
    ...    AND    Deactivate srs beam profile10 for UE10
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Setup environment
    ${CONFIGURE_ENV}    get variable value    ${configure}    "True"
    Run keyword if  ${CONFIGURE_ENV}=="True"
    ...     Get and Update BSR File  download_path=${download_path}
    Prepare suite environment  egate_config=${lua_cfg_file}  scfc=${scfc}  ap_xml=${iphy}
    Create aliases
    Create ues deployment  ues=1,2,3,4,5,6,7,8,9,10

Prepare test environment
    Setup emss in test
    Configure   ${CURDIR}/config/CB008828-SR-C-b-IWK4.yaml

Get and Update BSR File
    [Arguments]  ${download_path}    ${bsr_file_path}=${CURDIR}/config/BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
    ${token}=   get_ca_ute_artifactory_token
    Run  sudo wget -d --header='Authorization:Bearer ${token}' ${download_path} -O ${bsr_file_path}
    coam.setup admin
    ${ret}     coam.Update Software      ${bsr_file_path}
    coam.teardown admin

Register multi UEs and establish pdu sessions
    Register UE-1 and establish 1 pdu sessions on 1 slice on 1 cell
    Register UE-2 and establish 2 pdu sessions on 1 slice on 1 cell
    Register UE-3 and establish 3 pdu sessions on 2 slice on 1 cell
    Register UE-4 and establish 4 pdu sessions on 3 slice on 1 cell
    Register UE-5 and establish 5 pdu sessions on 4 slice on 1 cell
    Register UE-6 and establish 6 pdu sessions on 5 slice on 1 cell
    Register UE-7 and establish 7 pdu sessions on 6 slice on 1 cell
    Register UE-8 and establish 8 pdu sessions on 6 slice on 1 cell
    Register UE-9 and establish 9 pdu sessions on 1 slice on 1 cell
    Register UE-10 and establish 10 pdu sessions on 2 slice on 1 cell

Start SA traffic for multi UEs
    Log to console    \n------Start traffic
    Start 80Mbps DL traffic for UE-1 for 1pdu
    Start 80Mbps DL traffic for UE-2 for 2pdu
    Start 80Mbps DL traffic for UE-3 for 3pdu
    Start 80Mbps DL traffic for UE-10 for 10pdu
    Start 80Mbps DL traffic for UE-9 for 9pdu
    Start 80Mbps DL traffic for UE-4 for 4pdu
    Start 80Mbps DL traffic for UE-5 for 5pdu
    Start 80Mbps DL traffic for UE-6 for 6pdu
    Start 80Mbps DL traffic for UE-7 for 7pdu
    Start 80Mbps DL traffic for UE-8 for 8pdu
Verify SA traffic for ues
    sleep    3s
    Run keyword and continue on failure
    ...    Verify SA traffic  ue=1  dir=dl  expected_traffic=80Mbps  data_rate_type=Average   scells=0   tolerance=10
    Run keyword and continue on failure
    ...    Verify SA traffic  ue=2  dir=dl  expected_traffic=80Mbps  data_rate_type=Average   scells=0   tolerance=10
    Run keyword and continue on failure
    ...    Verify SA traffic  ue=3  dir=dl  expected_traffic=80Mbps  data_rate_type=Average   scells=0   tolerance=10
    Run keyword and continue on failure
    ...    Verify SA traffic  ue=4  dir=dl  expected_traffic=80Mbps  data_rate_type=Average   scells=0   tolerance=10
    Run keyword and continue on failure
    ...    Verify SA traffic  ue=5  dir=dl  expected_traffic=80Mbps  data_rate_type=Average   scells=0   tolerance=10
    Run keyword and continue on failure
    ...    Verify SA traffic  ue=6  dir=dl  expected_traffic=80Mbps  data_rate_type=Average   scells=0   tolerance=10
    Run keyword and continue on failure
    ...    Verify SA traffic  ue=7  dir=dl  expected_traffic=80Mbps  data_rate_type=Average   scells=0   tolerance=10
    Run keyword and continue on failure
    ...    Verify SA traffic  ue=8  dir=dl  expected_traffic=80Mbps  data_rate_type=Average   scells=0   tolerance=10
    Run keyword and continue on failure
    ...    Verify SA traffic  ue=9  dir=dl  expected_traffic=80Mbps  data_rate_type=Average   scells=0   tolerance=10
    Run keyword and continue on failure
    ...    Verify SA traffic  ue=10  dir=dl  expected_traffic=80Mbps  data_rate_type=Average   scells=0   tolerance=10

Deregister multi ues
    Release PDU session  UE_ID=10   PDU_ID=10
    Deregister UE  UE_ID=10
    Release PDU session  UE_ID=9   PDU_ID=9
    Deregister UE  UE_ID=9
    Release PDU session  UE_ID=8   PDU_ID=8
    Deregister UE  UE_ID=8
    Release PDU session  UE_ID=7   PDU_ID=7
    Deregister UE  UE_ID=7
    Release PDU session  UE_ID=6   PDU_ID=6
    Deregister UE  UE_ID=6
    Release PDU session  UE_ID=5   PDU_ID=5
    Deregister UE  UE_ID=5
    Release PDU session  UE_ID=4   PDU_ID=4
    Deregister UE  UE_ID=4
    Release PDU session  UE_ID=3   PDU_ID=3
    Deregister UE  UE_ID=3
    Release PDU session  UE_ID=2   PDU_ID=2
    Deregister UE  UE_ID=2
    Release PDU session  UE_ID=1   PDU_ID=1
    Deregister UE  UE_ID=1

Stop SA traffic for UEs
    Stop SA traffic  ue=1  pdu=1  dir=dl
    Stop SA traffic  ue=2  pdu=2  dir=dl
    Stop SA traffic  ue=3  pdu=3  dir=dl
    Stop SA traffic  ue=4  pdu=4  dir=dl
    Stop SA traffic  ue=5  pdu=5  dir=dl
    Stop SA traffic  ue=6  pdu=6  dir=dl
    Stop SA traffic  ue=7  pdu=7  dir=dl
    Stop SA traffic  ue=8  pdu=8  dir=dl
    Stop SA traffic  ue=9  pdu=9  dir=dl
    Stop SA traffic  ue=10  pdu=10  dir=dl

Stop collecting logs
    Stop and convert TTI trace collection    conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlFdSchedData|dlPagingOrSibSchedData

Activate beamforming on specific position for two subcells
    Log to console    \n------Activate beamforming
    Execute egate command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 step=5 trigger_puxch_update=0
    Execute egate command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=0 init_sub_quad_pos=1 step=5 trigger_puxch_update=0
    Execute egate command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=0 init_sub_quad_pos=2 step=5 trigger_puxch_update=0
    Execute egate command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=0 init_sub_quad_pos=3 step=5 trigger_puxch_update=0
    Execute egate command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=5 mode=fixed init_quad_pos=1 init_sub_quad_pos=0 step=5 trigger_puxch_update=0
    Execute egate command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=6 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 step=5 trigger_puxch_update=0
    Execute egate command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=7 mode=fixed init_quad_pos=1 init_sub_quad_pos=2 step=5 trigger_puxch_update=0
    Execute egate command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=8 mode=fixed init_quad_pos=1 init_sub_quad_pos=3 step=5 trigger_puxch_update=0
    Execute egate command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=7 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 step=5 trigger_puxch_update=0
    Execute egate command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=8 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 step=5 trigger_puxch_update=0
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=1 testmode=dl_mimo_srs_beam_pos action=activate profile_id=1
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=2 testmode=dl_mimo_srs_beam_pos action=activate profile_id=2
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=3 testmode=dl_mimo_srs_beam_pos action=activate profile_id=3
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=4 testmode=dl_mimo_srs_beam_pos action=activate profile_id=4
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=5 testmode=dl_mimo_srs_beam_pos action=activate profile_id=5
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=6 testmode=dl_mimo_srs_beam_pos action=activate profile_id=6
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=7 testmode=dl_mimo_srs_beam_pos action=activate profile_id=7
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=8 testmode=dl_mimo_srs_beam_pos action=activate profile_id=8
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=9 testmode=dl_mimo_srs_beam_pos action=activate profile_id=9
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=10 testmode=dl_mimo_srs_beam_pos action=activate profile_id=10

Deactivate srs beam profile${profile} for UE${UE}
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=${UE} testmode=ul_mimo_srs_beam_pos action=deactivate profile_id=${profile}
