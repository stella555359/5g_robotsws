*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_[BO][BO]_AP_[KLLL]_SANSA_L1B_CPRI_CMWV_FDD
...               release-SBTS23R3    owner-jiangping.cao    team-SG14    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    @{CA_basic_config}
...    @{CB008140_config_GNB1}
@{PARAMS_IN_SCF_GNB2}
...    @{CB008140_config_GNB2}
...    @{CA_basic_config}
${maxvalue_iGnbCaXnSetupReqTmr}    300

@{CB008140_config_GNB1}
...    NRDU-1:actInterGnbCa=DLOnly
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=36
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=1
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:nrDcAllowed=true
...    NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=36
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=0
...    NRBTS/NRADJNRCELL-1:gNbId=36
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=153370
...    NRBTS/NRADJNRCELL-1:physCellId=52
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.124
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:ipAddress=10.0.1.124
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:remoteNeType=GNB

@{CB008140_config_GNB2}
...    NRDU-1:actInterGnbCa=disabled
...    NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=0
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=153370
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3

@{CA_basic_config}
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa

...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=4
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRBTS:iGnbCaXnSetupReqTmr=${maxvalue_iGnbCaXnSetupReqTmr}
...    NRBTS:iGnbCaXnSetupRespTmr=1
...    NRBTS:weightForIgnbCaSelection=1

...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRBTS:actIncXn=true
...    NRCELL:actK1Opt=intraAndInter-gNB

${7328_fault_name}    Inter-gNB CA Xn version mismatch
${7328_fault_id}    7328
${7115_alarm_id}    7115

${FAULTS_EXCLUDED_CHECKING}    62002    7328
*** Test Cases ***
CB008140-ET-AA009_Verify_Xn_ISCA_setup_failure_due_to_incompatible_protocol_version_or_timeout
    [Documentation]
    ...    [purpose]: The purpose of this case is to Verify Xn ISCA setup failure due to incompatible protocol version
    ...    [Configuration]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140
    ...    [Test Case Steps]:
    ...         a.Tester send some WTS command to do Xn inter-gNB CA setup failed due to incompatible protocol version
    ...    [Expected Results]:
    ...         a:Inter-gNB CA Xn setup procedure fails. No retry.Alarm( 7115 (BASE STATION INFORMATION) with
    ...           fault id : 7328 (Inter-gNB CA Xn version mismatch)) is reported on prime gNB.
    [Tags]    QC_193376    jiancao
    Execute Egate Command    ignb_ca_setup_param id=4 action=fail fail_cause=incompatible_xn_protocol_version
    sleep    ${maxvalue_iGnbCaXnSetupReqTmr}s    #wait for XNAP setup
    Check WireShark Log    ${CURDIR}${/}A2A_AA_009${/}a2a.ini
    Check fault 7328 and alarm 7115

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    ${command_gnb3} =    catenate    SEPARATOR=
    ...           set_gnb id=3
    ...           \ type=external plmn=311:489 s1u=10.0.1.102 x2=10.0.1.3:36422 ng=10.0.1.3 xn=10.0.1.3
    ...           \ gnb_id=0x02:22 daemon=10.0.2.1:22222 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${command_gnb3}
    ${command_gnb2} =    catenate    SEPARATOR=
    ...           set_gnb id=2
    ...           \ type=external plmn=311:489 s1u=10.0.1.102 x2=10.0.1.2:36422 ng=10.0.1.2 xn=10.0.1.2
    ...           \ gnb_id=0x01:22 daemon=10.0.2.1:22222 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${command_gnb2}
    ${command_gnb4} =    catenate    SEPARATOR=
    ...           set_gnb id=4
    ...           \ type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...           \ xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1 xp=10.0.1.124:32742 xpu=10.0.1.124:32742 xp_management=on
    Update Cfg    ${command_gnb4}
    ${command_gnb4_cell1} =    catenate    SEPARATOR=
    ...           set_cell id=1
    ...           \ gnb=4 pci=127:1 tac=0 nrci=0x01 tdd_cell=off proxy=10.0.2.91:9999 nr_arfcn=135000:127200
    ...           \ gscn=1590 mandatory_for_activation=off
    Update Cfg    ${command_gnb4_cell1}
    Update Cfg    gnb_param id=4 xn_listening_socket=1 send_xn_setup=false

Check fault 7328 and alarm 7115
    ${fault7328_alarm7115}    Create List    fault_id=${7328_fault_id}    alarm_id=${7115_alarm_id}    severity=Minor
    ...    fault_name=${7328_fault_name}
    Fm Fault Should Be Raised    ${fault7328_alarm7115}    40
