*** Settings ***
Documentation    ...
#Suite Setup       Common Suite Setup
#Test Setup        Common Test Setup
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CB009169    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_zhachen    CN1_SG6    SBTS00    SBTS23R2
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/Config/
#${FULL_SCFC}                 CB009169_ET_BE303_SCF.xml
#${IPHY_XML}                  ${CURDIR}/Resources/wts/iphy_CB009169_ET_BC102_BC503.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/Resources/wts/
#${WTS_AP_XML}                airphone.xml
#${WTS_CFG}                   CB009169_ET_BE303.cfg
#${EGATE_FILE}                /opt/iphy/latest/egate_console.log
#
#
#*** Test Cases ***
#CB009169_ET_BE303_T_F_100Mhz_20Mhz_MultiUE_Cell_Lock_With_Graceful_Cell_Shutdown_On_Scell_Blind_Scell_Addition
#    Two CA UE Attach And Scell Check
#    Three Non CA UE Attach
#    Start DLUL Traffic For All UEs
#    Wait Until Keyword Succeeds    2min    30s    Check Tput For All UEs
#    Set PHR Testmode    profile_id=1    phr_mode=Fixed    phr_start=0    phr_max=23
#    Set PHR Testmode    profile_id=2    phr_mode=Fixed    phr_start=30    phr_max=23
#    Set UE Position
#    Enable Graceful Shutdown For Cell 3
#    Trigger UE2 Scell Release
#    Trigger A3 Event And Check Handover Status For UE4
#	sleep    180s    reason=wait for graceful shutdown
#    Attach UE6 and Start Traffic
#    Check All UE Status
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#
#
#Two CA UE Attach And Scell Check
#    SA Single UE Attach     ue_id=1
#	Trigger A1 Scell Addition    ue_id=1    srsrp_nr=120    phycell_id=60
#    Check SA Scell PhysicalID With UE ID    ue_id=1    scell_physicalid=50    scell_index=1
#	Check SA Scell PhysicalID With UE ID    ue_id=1    scell_physicalid=52    scell_index=2
#    SA Single UE Attach     ue_id=2
#	Trigger A1 Scell Addition    ue_id=2    srsrp_nr=120    phycell_id=60
#    Check SA Scell PhysicalID With UE ID    ue_id=2    scell_physicalid=50    scell_index=1
#    Check SA Scell PhysicalID With UE ID    ue_id=2    scell_physicalid=52    scell_index=2
#
#Three Non CA UE Attach
#    SA Single UE Attach     ue_id=3
#    SA Single UE Attach     ue_id=4
#    SA Single UE Attach     ue_id=5
#
#Set UE Position
#	Set UE To Center   UE_ID=1    SCELL_ID=2
#	Set UE To Center   UE_ID=3    SCELL_ID=1
#	Set UE To Center   UE_ID=5    SCELL_ID=1
#	Set UE To Edge    UE_ID=2    SCELL_ID=1
#	Set UE To Edge    UE_ID=2    SCELL_ID=2
#	Set UE To Edge    UE_ID=4    SCELL_ID=1
#
#Set UE To Center
#    [Arguments]    ${UE_ID}=1    ${SCELL_ID}=1
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${UE_ID} testmode=phr_override action=activate profile_id=1 scell=${SCELL_ID}
#
#Set UE To Edge
#    [Arguments]    ${UE_ID}=1    ${SCELL_ID}=1
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${UE_ID} testmode=phr_override action=activate profile_id=2 scell=${SCELL_ID}
#
#Start DLUL Traffic For All UEs
#    SA Start DL Traffic Internal    ue_id=1    mbps=250    pdu_id=1
#    SA Start UL Traffic Internal    ue_id=1    mbps=100     pdu_id=1
#    SA Start DL Traffic Internal    ue_id=2    mbps=250     pdu_id=1
#    SA Start UL Traffic Internal    ue_id=2    mbps=100     pdu_id=1
#    SA Start DL Traffic Internal    ue_id=3    mbps=180    pdu_id=1
#    SA Start UL Traffic Internal    ue_id=3    mbps=100     pdu_id=1
#    SA Start DL Traffic Internal    ue_id=4    mbps=100     pdu_id=1
#    SA Start UL Traffic Internal    ue_id=4    mbps=100     pdu_id=1
#    SA Start DL Traffic Internal    ue_id=5    mbps=100    pdu_id=1
#    SA Start UL Traffic Internal    ue_id=5    mbps=100    pdu_id=1
#
#
#Check Tput For All UEs
#    sleep    10s
#    CUDU L2 Capture And Decode TTitrace    log_id=1    duration=2
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=BIP/1
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=pcell    scell_index=0    target_tp=130
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=scell    scell_index=1    target_tp=14
#	Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=scell    scell_index=2    target_tp=30
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=ul    cell_type=pcell    scell_index=0    target_tp=17
#	Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=ul    cell_type=scell    scell_index=2    target_tp=23
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=dl    cell_type=pcell    scell_index=0    target_tp=130
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=dl    cell_type=scell    scell_index=1    target_tp=14
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=dl    cell_type=scell    scell_index=2    target_tp=30
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=ul    cell_type=pcell    scell_index=0    target_tp=17
#	Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=ul    cell_type=scell    scell_index=2    target_tp=23
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=3    dir=dl    cell_type=pcell    scell_index=0    target_tp=130
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=3    dir=ul    cell_type=pcell    scell_index=0    target_tp=35
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=4    dir=dl    cell_type=pcell    scell_index=0    target_tp=35
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=4    dir=ul    cell_type=pcell    scell_index=0    target_tp=45
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=5    dir=dl    cell_type=pcell    scell_index=0    target_tp=35
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=5    dir=ul    cell_type=pcell    scell_index=0    target_tp=45
#
#
#Enable Graceful Shutdown For Cell 3
#    Log To Console    Enable graceful shutdown for cell 3...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-3    administrativeState    Shutting Down
#
#
#Attach UE6 and Start Traffic
#    SA Single UE Attach     ue_id=6
#	Trigger A1 Scell Addition    ue_id=6    srsrp_nr=120    phycell_id=60
#    Check SA Scell PhysicalID With UE ID    ue_id=6    scell_physicalid=50    scell_index=1
#	SA Start DL Traffic Internal    ue_id=6    mbps=300    pdu_id=1
#    SA Start UL Traffic Internal    ue_id=6    mbps=150    pdu_id=1
#
#Check All UE Status
#	Check UE2 UE3 UE4 UE6 Tput
#    Check UE5 Released
#
#
#Check UE2 UE3 UE4 UE6 Tput
#    sleep    10s
#    CUDU L2 Capture And Decode TTitrace    log_id=2    duration=2
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=BIP/2
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=dl    cell_type=pcell    scell_index=0    target_tp=130
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=dl    cell_type=scell    scell_index=1    target_tp=14
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=ul    cell_type=pcell    scell_index=0    target_tp=17
#	Check CA UE Pcell Scell Cell TPut On Target    ue_id=3    dir=dl    cell_type=pcell    scell_index=0    target_tp=130
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=3    dir=ul    cell_type=pcell    scell_index=0    target_tp=35
#	Check CA UE Pcell Scell Cell TPut On Target    ue_id=4    dir=dl    cell_type=pcell    scell_index=0    target_tp=80
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=4    dir=ul    cell_type=pcell    scell_index=0    target_tp=65
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=6    dir=dl    cell_type=pcell    scell_index=0    target_tp=130
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=6    dir=dl    cell_type=scell    scell_index=1    target_tp=14
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=6    dir=ul    cell_type=pcell    scell_index=0    target_tp=17
#
#Check UE5 Released
#    Wait Until Keyword Succeeds    300s    30s    Check Egate Log With Message    ${EGATE_FILE}
#    ...    UE5: detached
#
#
#Trigger UE2 Scell Release
#    Log To Console    Trigger A2 event...
#    ${pattern}    Set Variable    sCellToReleaseList
#    ${cmd}    Catenate    ue_measurement_send_nr id\=2 meas_id\=3 rs_type\=ssb event\=A2 scell\=2 scell_rsrp\=25
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#
#
#Trigger A3 Event And Check Handover Status For UE4
#    Log To Console    Trigger A3 event...
#    ${pattern}    Set Variable    UE4: Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.2 performed
#    ${cmd}    Catenate    ue_measurement_send_nr id\=4 meas_id\=1 event\=A3 srsrp_nr\=20
#    ...    phycell_id\=51 nrsrp_nr\=100
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
