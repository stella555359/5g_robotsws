*** Settings ***
Documentation
...   contact: Szymon Startek

Library     DateTime
Library     SSHLibrary
Library     ute_ue
Library     taf.sbts.oam.coam.admin  WITH NAME  admin
Resource    ../../resources/ca_IWK.robot


*** Variables ***
${NR_CELL_ID}                              # NR main cell of the TC. It will handle the DL tput.
${POWER_GROUP_ID}                          # ID of the power group used in the TC.
${NR_UE_CAPABILITY}                        # NR UE1 capability.


*** Keywords ***
TC__CB008940_F5_POST_Interaction_CB008392_Cell_TX_Path_Switch_Off_List
    Set Tags    CA-INTER_RAT    AUTHOR-santiago.galindo@nokia.com    OWNER-vladislav.gusak@nokia.com
    ...         MAINTAINER-santiago.galindo@nokia.com    PHASE-CRT   SW-SBTS23R3    FEATURE-CB008940-F    GROUP_IN_CHARGE-WRO_2_Vrf

    Preconditions
    Step1: DL Data Transfer for TXs Switch Off List


Preconditions
    Log  \n==== Preconditions ====  console=True

    Set Global Variables
    Save Swconfigs And Check If Flag Exists For Specified BTS  new_swconfig.txt
    ...  ${GNB_OAM_IP}  0x420068=7  flag_should_exist=True
    Check If Feature CB008392 Is Active
    Require UE  NR_UE  ${NR_UE_CAPABILITY}
    Check Measurements In Syslog
    Log  = Preconditions passed =  console=True


Set Global Variables
    Set Test Variable  ${NEW_CB008940_CONFIG}  False

    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}

    ${scf_path_gnb}  ${parsed_scf_gnb}=  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${SCF_PATH_GNB}  ${scf_path_gnb}
    Set Test Variable  ${PARSED_SCF_GNB}  ${parsed_scf_gnb}

    ${lbps_rtxs_on_time} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID}
    ...  /p[@name='lbpsRTXSOnTime']  dist_name_substring=True
    ${lbps_rtxs_on_time_for_waiting} =  Evaluate  ${lbps_rtxs_on_time} + 30
    Set Test Variable  ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}  ${lbps_rtxs_on_time_for_waiting}

    ${lbps_rtxs_off_time} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID}
    ...  /p[@name='lbpsRTXSOffTime']  dist_name_substring=True
    ${lbps_rtxs_off_time_for_waiting} =  Evaluate  ${lbps_rtxs_off_time} + 30
    Set Test Variable  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}  ${lbps_rtxs_off_time_for_waiting}

    ${lbps_rtx_max_load} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID}
    ...  /p[@name='lbpsRTXMaxLoad']  dist_name_substring=True
    Set Test Variable  ${LBPS_RTX_MAX_LOAD}  ${lbps_rtx_max_load}

    ${lbps_rtx_min_load} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRPGRP  NRPGRP-${POWER_GROUP_ID}
    ...  /p[@name='lbpsRTXMinLoad']  dist_name_substring=True
    Set Test Variable  ${LBPS_RTX_MIN_LOAD}  ${lbps_rtx_min_load}


Check Measurements In Syslog
    Log  \n==== Check Measurements In Syslog ====  console=True

    ${start_time} =  Get Time From BTS
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  1min  10s
    ...  Analyze Power Group Load From Syslog For CB008392  ${POWER_GROUP_ID}  ${start_time}  NoTpt  release=${RELEASE_LOCAL}
    Log  Wait ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s to check if energy saving state changed.  console=True
    Sleep  ${LBPS_RTXS_OFF_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.

    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID}  reducedEnergySaving  connection=gNB


Step1: DL Data Transfer for TXs Switch Off List
    Log  \n==== Step1: DL Data Transfer for TXs Switch Off List ====  console=True

    Log  Start min NR DL data transfer in cell ${NR_CELL_ID} on UE.  console=True
    Prepare UE For Data Transfer  NR_UE  ${NR_CELL_ID}  connection=gNB  lte_cell=False
    Start Data Transfer  NR_DL  NR_UE  dl  throughput=25 Mbits/sec  packet_size=1400  duration=300s  buffer=32M  apn=${APN}

    ${start_time} =  Get Time From BTS
    Check Data Transfer Is Alive  NR_DL
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  2min  10s
    ...  Analyze Power Group Load From Syslog For CB008392  ${POWER_GROUP_ID}  ${start_time}  Lower  release=${RELEASE_LOCAL}
    Log  Wait ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s to check if energy saving state changed.  console=True
    Sleep  ${LBPS_RTXS_ON_TIME_FOR_WAITNIG}s  reason=Waiting to check if energy saving state changed.

    Run Keyword And Continue On Failure
    ...  Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_CELL_ID}  reducedEnergySaving  connection=gNB
    Run Keyword And Continue On Failure
    ...  Analyze Power Group Load From Syslog For CB008392  ${POWER_GROUP_ID}  ${start_time}  condition=Lower  release=${RELEASE_LOCAL}
    [Teardown]  Stop Data Transfer  NR_DL


Debug Syslog Prints
    ${syslog} =  Run Keyword And Continue On Failure  Wait For Message In Syslog File
    ...  regexp=EnergySavingAlgorithm.*  timeout=10s  alias=gNB
    Create File  ${LOG_PATH}/misc_logs/syslogDebug1.txt  ${syslog}
    ${syslog} =  Run Keyword And Continue On Failure  Wait For Message In Syslog File
    ...  regexp=EnergySavingService.*  timeout=10s  alias=gNB
    Create File  ${LOG_PATH}/misc_logs/syslogDebug2.txt  ${syslog}


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Log  \n=== TC Teardown ===  console=True
    Set Attenuation For All Cells  100%
    Detach UE  NR_UE
    _verify bts states for iwk test helper  alias=gNB
    Run Keyword And Ignore Error  Debug Syslog Prints
    IWK Test Teardown  delta_exists=False  local_enb_connection=False  single_bts=True

