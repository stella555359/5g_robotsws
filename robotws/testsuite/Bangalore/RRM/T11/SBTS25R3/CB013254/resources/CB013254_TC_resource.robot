*** Settings ***
Documentation
...
...             author:           Sujeet
...             maintainer:       Sujeet.sharma@nokia.com
...

Library     OperatingSystem
Library     ta_uexgate
Library     taf.ul.ue.sim.env_setup
Library     taf.collectors.tshark
Library           ta_messaging
Library     ta_emss
Library         ta5g_tshark
Library		taf.sbts.oam.coam.admin
Library      taf.sw.wtssim
*** Variables ***
${EGATE_PORT}=          20000
${edaemon_port}=        10000
@{SWCONFIG_FLAGS_LIST}=     0x1A1300=0   0x9D0000=5    0x1A0020=1    0x45005a=1    0x1003F=2    0x10040=2   0x10041=5   0x10042=0xC0A8FF7E
...     0x10043=51000    0x1A1300=0   0x0001003F = 1    0x00010040 = 1     0x00010041 = 5    0xF000E = 1    0xF000F = 1    0xF0010 = 1   0xF0011 = 1
${coco_yaml}=            /home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T11/SBTS25R3/CB013254/config/cus_BANO.yaml
${scfc}=             scfc_BANO_FDD_TDD.xml




*** Keywords ***



Prepare test environment for CB013254-A_1
    Add Simulator   sim_type=cus    config=${coco_yaml}
    Add Enb Configuration           scfc=${scfc}    rad_params=@{SWCONFIG_FLAGS_LIST}
    Configure_environment
    Setup Emss    enb_id=1
    taf.sw.wtssim.setup egate  egate_port=${EGATE_PORT}
    Create aliases

#    Start collecting logs
Configure Env for CB013254_2
   	Add Simulator       sim_type=cus    config=${cus_ini_1},${ue_db}
    Add Enb Configuration         scfc=${scfc1}    rad_params=@{SWCONFIG_FLAGS_LIST}
    Add Epc                         config=${lua}
    configure_environment



Cleanup test environment
#    Stop collecting logs
    Teardown egate and edaemon


Prepare test environment fast
    Setup Emss    enb_id=1
    Setup egate and edaemon
    Create aliases

Create aliases
    Create UE group aliases  alias=UE  start_ue_id=1  stop_ue_id=110  id_type=rtg
    Create MME alias    alias=MME_1    mme_id=1  id_type=wts
    Create enb alias    alias=ENB_1   enb_id=2  id_type=wts

Setup egate and edaemon
    Setup egate  egate_port=${egate_port}  host_ip=${egate_host}

Teardown egate and edaemon
#    Teardown Edaemon
    Teardown Egate

Attach regular UEs [${ue_id_start:\d+}-${ue_id_stop:\d+}] with gbr: ${gbr} and start traffic to CELL-${cell_id:\d+}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${${ue_id_stop}+1}
        Attach regular UE-${ue_id} with gbr: ${gbr} and start traffic to CELL-${cell_id}
        sleep    0.2
    END
    sleep   5

Attach regular UE-${ue_id:\d+} with gbr: ${gbr} and start traffic to CELL-${cell_id:\d+}
    Run UEx command  ue_attach  id=${ue_id}  cell=${cell_id}
    sleep  0.5
    Run UEx command  bearer_add  ue=${ue_id}  qci=3  mbr_dl=${gbr}  mbr_ul=${gbr}  gbr_dl=${gbr}  gbr_ul=${gbr}
    sleep  0.5
    Run UEx command  trf_data_start  ue=${ue_id}  Mbps=1  dir=dl  protocol=udp  bearer=6

Attach regular UE-${ue_id:\d+} and start DL traffic to CELL-${cell_id:\d+}
    Run UEx command  ue_attach  id=${ue_id}  cell=${cell_id}
    sleep  0.5
    Run UEx command  bearer_add  ue=${ue_id}  qci=3  mbr_dl=128  mbr_ul=128  gbr_dl=128  gbr_ul=128
    sleep  0.5
    Run UEx command  trf_data_start  ue=${ue_id}  Mbps=2  dir=dl  protocol=udp  qci=3


Attach regular UEs [${ue_id_start:\d+}-${ue_id_stop:\d+}] and start DL traffic to CELL-${cell_id:\d+}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${${ue_id_stop}+1}
        Attach regular UE-${ue_id} and start DL traffic to CELL-${cell_id}
        sleep    0.2
    END
    sleep   5

Start DL traffic on UE-${ue_id:\d+} with QCI-${qci}
    Run UEx command  trf_data_start  ue=${ue_id}  Mbps=2  dir=dl  protocol=udp  qci=${qci}


Detach Ues [${ue_id_start:\d+}-${ue_id_stop:\d+}]
    Run UEx command  ue_detach  id=${ue_id_start}..${ue_id_stop}

Detach UE-${ue_id:\d+}
    Run UEx command  ue_detach  id=${ue_id}

Attach UEs to reach requested limits in the CELL-1 for A_1
    run keyword and ignore error    Attach regular UEs [18-35] with gbr: 128 and start traffic to CELL-1
    sleep  5

Attach regular UE-${ue_id:\d+} to CELL-${cell_id:\d+}
    Run UEx command  ue_attach  id=${ue_id}  cell=${cell_id}
    sleep  2

Attach UE-${ue_id:\d+} with QCI${qci_id:\d+} bearer to CELL-${cell_id:\d+}
    Expect Message Flow
    ...  UE_${ue_id}:RRC_RRCConnectionRequest
    ...  UE_${ue_id}:RRC_RRCConnectionSetup
    ...  UE_${ue_id}:RRC_RRCConnectionSetupComplete
    ...  MME_1:S1AP_InitialUEMessage
    ...  MME_1:S1AP_InitialContextSetupRequest as ICS_REQUEST_${qci_id}
    ...  UE_${ue_id}:RRC_UECapabilityEnquiry
    ...  UE_${ue_id}:RRC_UECapabilityInformation
    ...  UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...  UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...  MME_1:S1AP_InitialContextSetupResponse as ICS_RESPONSE_${qci_id}
    ...  alias=UE_${ue_id}_attach_flow    overall_timeout=15

    Run UEx command  ue_attach  id=${ue_id}  cell=${cell_id}
#    sleep  5
    Flow occurred as expected    UE_${ue_id}_attach_flow

Verify UE-${ue_id:\d+} was attached and QCI${qci_id:\d+} bearer established


    Verify That Message Fulfills Query
    ...  E-RABToBeSetupItemCtxtSUReq contains (qCI eq ${qci_id} and e-RAB-ID eq 6)
    ...  message_alias=ICS_REQUEST_${qci_id}
    ...  flow_alias=UE_${ue_id}_attach_flow

    Verify That Message Fulfills Query
    ...  E-RABSetupItemCtxtSURes contains (e-RAB-ID eq 6)
    ...  message_alias=ICS_RESPONSE_${qci_id}
    ...  flow_alias=UE_${ue_id}_attach_flow



Add to UE-${ue_id:\d+} QCI${qci_id:\d+} bearer and expect preemption of regular UE-${preempt_ue_id:\d+} low prio bearer
    Expect Message Flow
    ...   MME_1:S1AP_E-RABReleaseIndication (radioNetwork eq "release-due-to-pre-emption")
    ...   alias=UE_${preempt_ue_id}_bearer_preempt    overall_timeout=15

    Expect Message Flow
    ...   MME_1:S1AP_E-RABSetupRequest as ERAB_REQUEST_${qci_id}
    ...   MME_1:S1AP_E-RABSetupResponse as ERAB_RESPONSE_${qci_id}
    ...   alias=UE_${ue_id}_bearer_add   overall_timeout=15

    run keyword and ignore error    Run UEx command  bearer_add  ue=${ue_id}  qci=${qci_id}  mbr_dl=256  mbr_ul=256  gbr_dl=256  gbr_ul=256


Verify UE-${preempt_ue_id:\d+} low prio bearer was preempted
    Expect Message Flow
    ...   MME_1:S1AP_E-RABReleaseIndication
    ...   alias=UE_${preempt_ue_id}_bearer_preempt    overall_timeout=15


Verify UE-${ue_id:\d+} QCI${qci_id:\d+} bearer was established
    Flow occurred as expected    UE_${ue_id}_bearer_add

    Verify That Message Fulfills Query
    ...  E-RABToBeSetupItemBearerSUReq contains (qCI eq ${qci_id} and e-RAB-ID eq 6)
    ...  message_alias=ERAB_REQUEST_${qci_id}
    ...  flow_alias=UE_${ue_id}_bearer_add

    Verify That Message Fulfills Query
    ...  E-RABSetupListBearerSURes contains (e-RAB-ID eq 6)
    ...  message_alias=ERAB_RESPONSE_${qci_id}
    ...  flow_alias=UE_${ue_id}_bearer_add


Modify UE-${ue_id:\d+} QCI${qci:\d+} bearer bitrate to ${bitrate:\d+}kbps and start traffic
    Run WTS command  bearer_mod  ue=${ue_id} id=${${qci}-50} mbr_ul=${bitrate} gbr_ul=${bitrate}
    sleep  2
    Run UEx command  trf_data_start  ue=${ue_id}  Mbps=1  dir=dl  protocol=udp  bearer=6
    sleep  1

Modify UE-${ue_id:\d+} QCI${qci:\d+} bearer bitrate to ${bitrate:\d+}kbps
    Run WTS command  bearer_mod  ue=${ue_id} id=${${qci}-50} mbr_ul=${bitrate} gbr_ul=${bitrate}
    sleep  1

## A_2

Attach UEs to reach requested limits in the CELL-1 for A-2
     run keyword and ignore error    Attach regular UEs [10-21] with gbr: 128 and start traffic to CELL-1
    sleep  5

Modify UE-${ue_id:\d+} QCI${qci_id:\d+} bearer GBR value from ${start_value:\d+} to ${stop_value:\d+}
    Expect Message Flow
    ...   MME_1:S1AP_E-RABModifyRequest as ERAB_REQUEST_${qci_id}
    ...   MME_1:S1AP_E-RABModifyResponse as ERAB_RESPONSE_${qci_id}
    ...   alias=UE_${ue_id}_bearer_mod   overall_timeout=15

    Run WTS command  bearer_mod  ue=${ue_id} id=${${qci_id}-50} mbr_ul=${stop_value} gbr_ul=${stop_value}
    Log  ${start_value}
    sleep  5

Modify UE-${ue_id:\d+} QCI${qci_id:\d+} bearer GBR value to ${stop_value:\d+} and expect preemption of regular UE-${preempt_ue_id:\d+} low prio bearer
    Expect Message Flow
    ...   MME_1:S1AP_E-RABModifyRequest as ERAB_REQUEST_${qci_id}
    ...   MME_1:S1AP_E-RABModifyResponse as ERAB_RESPONSE_${qci_id}
    ...   alias=UE_${ue_id}_bearer_mod   overall_timeout=15

    Expect Message Flow
    ...   MME_1:S1AP_E-RABReleaseIndication (radioNetwork eq "release-due-to-pre-emption")
    ...   alias=UE_${preempt_ue_id}_bearer_preempt    overall_timeout=15

    Run WTS command  bearer_mod  ue=${ue_id} id=16 mbr_ul=${stop_value} gbr_ul=${stop_value}

Verify UE-${ue_id:\d+} QCI${qci_id:\d+} bearer was modified successfully
    Flow occurred as expected    UE_${ue_id}_bearer_mod

    Verify That Message Fulfills Query
    ...  E-RABToBeModifiedListBearerModReq contains (qCI eq ${qci_id} and e-RAB-ID eq 6)
    ...  message_alias=ERAB_REQUEST_${qci_id}
    ...  flow_alias=UE_${ue_id}_bearer_mod

    Verify That Message Fulfills Query
    ...  E-RABModifyItemBearerModRes contains (e-RAB-ID eq 6)
    ...  message_alias=ERAB_RESPONSE_${qci_id}
    ...  flow_alias=UE_${ue_id}_bearer_mod


### A_3

Attach UEs to reach requested limits in the CELL-1 for A_3
    Attach regular UEs [10-13] with gbr: 128 and start traffic to CELL-1

Attach UE-${ue_id:\d+} with QCI${qci_id:\d+} bearer to enb-2 CELL-21
    Run UEx command  ue_attach  id=${ue_id}  cell=21  enb=2
    Log   ${qci_id}

#Trigger UE-101,102,1 S1HO with cause 'radio reason handover' from eNB-${source_enb_id:\d+} to eNB-${target_enb_id:\d+}
#... CELL-${target_cell_id:\d+} and expect preemption of regular UE-${preempt_ue_id:\d+} low prio bearer
#    Expect Message Flow
#    ...         MME_1:S1AP_E-RABReleaseIndication (radioNetwork eq "release-due-to-pre-emption")
#    ...         alias=UE_${preempt_ue_id}_bearer_preempt    overall_timeout=15
#
#    Expect message flow
#    ...         MME_1:S1AP_HandoverRequest (radioNetwork eq "handover-desirable-for-radio-reason")
#    ...         MME_1:S1AP_HandoverRequest (radioNetwork eq "handover-desirable-for-radio-reason")
#    ...         MME_1:S1AP_HandoverRequest (radioNetwork eq "handover-desirable-for-radio-reason")
#    ...         alias=s1ap_ho_1  overall_timeout=15
#
#    Expect message will not occur
#    ...         MME_1:S1AP_HandoverFailure
#    ...         alias=s1ap_ho_failure  overall_timeout=5
#
#    Run WTS command  enb_param  ho_source=s1  id=${source_enb_id}  s1_ho_cause=handover_desirable_for_radio_reasons
#    Run uex command  ue_ho  id=101..102,1  enb=${target_enb_id}  cell=${target_cell_id}

Verify UE-${ue_id} HO was successful and QCI${qci_id} bearer was admited
    Flow occurred as expected    s1ap_ho_${ue_id}
    Flow not occurred for message   s1ap_ho_failure
    Log  ${qci_id}

Prepare test environment for cb013254-A_3
    Configure eNB    ${A_3_yaml}  enb_id=1



#### A_4

Attach UEs to reach requested limits in the CELL-1 for A_4
    Attach regular UEs [10-13] with gbr: 128 and start traffic to CELL-1


Change UE-${ue_id:\d+} QCI from ${old_qci:\d+} to ${new_qci:\d+}
    Run WTS command  bearer_mod  ue=${ue_id} id=${${old_qci}-50} qci=${new_qci}
    sleep  1

Cleanup test environment for cb013254-A_4
    Detach Ues [10-13]
    Detach Ues [4-4]
    Detach Ues [101-102]
##### A_5

Attach UEs to reach requested limits in the CELL-1 for A_5
    run keyword and ignore error    Attach regular UEs [10-24] with gbr: 128 and start traffic to CELL-1

Attach UE-${ue_id} with QCI${qci_id} bearer to CELL-${cell_id} and expect QCI${qci_id} bearer not established
    Expect Message Flow
    ...  UE_${ue_id}:RRC_RRCConnectionRequest
    ...  UE_${ue_id}:RRC_RRCConnectionSetup
    ...  UE_${ue_id}:RRC_RRCConnectionSetupComplete
    ...  MME_1:S1AP_InitialUEMessage
    ...  MME_1:S1AP_InitialContextSetupRequest as ICS_REQUEST_${qci_id}
    ...  UE_${ue_id}:RRC_UECapabilityEnquiry
    ...  UE_${ue_id}:RRC_UECapabilityInformation
    ...  UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...  UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...  MME_1:S1AP_InitialContextSetupResponse as ICS_RESPONSE_${qci_id}
    ...  alias=UE_${ue_id}_attach_flow    overall_timeout=15

    Run Keyword And Ignore Error   Run UEx command  ue_attach  id=${ue_id}  cell=${cell_id}
    sleep  1

Attach ${ue_count} UEs [${ue_ids}] with QCI${qci_id} bearer to CELL-${cell_id} and verify one QCI${qci_id} bearer not established

    Expect Message Flow
    ...  MME_1:S1AP_InitialContextSetupResponse (cause contains (radioNetwork eq 'radio-resources-not-available') and e-RAB-ID eq 6)
    ...  alias=attach_flow  overall_timeout=15

    Run Keyword And Ignore Error   Run UEx command  ue_attach  id=${ue_ids}  cell=${cell_id}
    Log   ${ue_count}
    Log   ${qci_id}
    Log    ${cell_id}

Verify UE-${ue_id} was attached and QCI${qci_id} bearer not established


    Verify That Message Fulfills Query
    ...  E-RABList contains (cause contains (radioNetwork eq 'radio-resources-not-available') and e-RAB-ID eq 6)
    ...  message_alias=ICS_RESPONSE_${qci_id}
    ...  flow_alias=UE_${ue_id}_attach_flow

Change ${object} attribute ${attribute} to ${new_value:\w+}
    Edit object attributes  ${object}  ${attribute}=${new_value}  enb_id=1
    sleep    10

Add to UE-${ue_id:\d+} QCI${qci_id:\d+} bearer with ${bitrate:\d+}kbps bitrate and expect bearer was established
    Expect Message Flow
    ...   MME_1:S1AP_E-RABSetupRequest as ERAB_REQUEST_${qci_id}
    ...   MME_1:S1AP_E-RABSetupResponse as ERAB_RESPONSE_${qci_id}
    ...   alias=UE_${ue_id}_bearer_add   overall_timeout=15

    Run UEx command  bearer_add  ue=${ue_id}  qci=${qci_id}  mbr_dl=${bitrate}  mbr_ul=${bitrate}  gbr_dl=${bitrate}  gbr_ul=${bitrate}
    Run UEx command  trf_data_start  ue=${ue_id}  Mbps=1  dir=dl  protocol=udp  qci=${qci_id}
    sleep  5

Add to UE-${ue_id:\d+} QCI${qci_id:\d+} bearer and expect bearer was not established
    Expect Message Flow
    ...   MME_1:S1AP_E-RABSetupRequest as ERAB_REQUEST_${qci_id}
    ...   MME_1:S1AP_E-RABSetupResponse (cause is present) as ERAB_RESPONSE_${qci_id}
    ...   alias=UE_${ue_id}_bearer_add   overall_timeout=15

    Run Keyword And Ignore Error   Run UEx command  bearer_add  ue=${ue_id}  qci=${qci_id}  mbr_dl=256  mbr_ul=256  gbr_dl=256  gbr_ul=256

Verify UE-${ue_id:\d+} QCI${qci_id:\d+} bearer was not established
    Flow occurred as expected    UE_${ue_id}_bearer_add

    Verify That Message Fulfills Query
    ...  E-RABToBeSetupListBearerSUReq contains (qCI eq ${qci_id} and e-RAB-ID eq 6)
    ...  message_alias=ERAB_REQUEST_${qci_id}
    ...  flow_alias=UE_${ue_id}_bearer_add

    Verify That Message Fulfills Query
    ...  E-RABList contains (cause contains (radioNetwork eq 'radio-resources-not-available') and e-RAB-ID eq 6)
    ...  message_alias=ERAB_RESPONSE_${qci_id}
    ...  flow_alias=UE_${ue_id}_bearer_add

Add UEs QCI65 bearer and expect bearer was not established
        Expect Message Flow
    ...   MME_1:S1AP_E-RABSetupRequest as ERAB_REQUEST_65
    ...   MME_1:S1AP_E-RABSetupResponse (cause is present) as ERAB_RESPONSE_65
    ...   alias=UE_bearer_add   overall_timeout=15
     Run Keyword And Ignore Error   Run UEx command  bearer_add  ue=58  qci=65  mbr_dl=256  mbr_ul=256  gbr_dl=256  gbr_ul=256
     Run Keyword And Ignore Error   Run UEx command    ue_attach    id=59..64    cell=1
     Run Keyword And Ignore Error   Run UEx command  bearer_add  ue=59..64  qci=65  mbr_dl=256  mbr_ul=256  gbr_dl=256  gbr_ul=256

Verify UEs QCI65 bearer was not established
     Flow occurred as expected    UE_bearer_add

    Verify That Message Fulfills Query
    ...  E-RABToBeSetupListBearerSUReq contains (qCI eq 65 and e-RAB-ID eq 6)
    ...  message_alias=ERAB_REQUEST_65
    ...  flow_alias=UE_bearer_add

    Verify That Message Fulfills Query
    ...  E-RABList contains (cause contains (radioNetwork eq 'radio-resources-not-available') and e-RAB-ID eq 6)
    ...  message_alias=ERAB_RESPONSE_65
    ...  flow_alias=UE_bearer_add


Prepare test environment for cb013254-A_5
    Change LNBTS-1 attribute qciTab65.gbrOverbookingFactorDl to 5

Cleanup test environment for cb013254-A_5
#    Detach Ues [10-13]
#    Detach Ues [57-58]
#    Detach Ues [51-52]
    run uex command    ue_detach    all
    Change LNBTS-1 attribute qciTab65.gbrOverbookingFactorDl to 5

###### A_6

Attach UEs to reach requested limits in the CELL-1 for A_6
    Attach regular UEs [7-11] with gbr: 128 and start traffic to CELL-2

#Trigger UE-${ue_id:\d+} QCI${old_qci:\d+} bearer QCI modification to QCI${new_qci:\d+} and
#... UL GBR value from ${start_value:\d+} to ${stop_value:\d+} and expect preemption of regular UE-${preempt_ue_id:\d+} low prio bearer
#    Expect Message Flow
#    ...   MME_1:S1AP_E-RABReleaseIndication (radioNetwork eq "release-due-to-pre-emption")
#    ...   alias=UE_${preempt_ue_id}_bearer_preempt    overall_timeout=15
#
#    Expect Message Flow
#    ...   MME_1:S1AP_E-RABModifyRequest as ERAB_REQUEST_${new_qci}
#    ...   MME_1:S1AP_E-RABModifyResponse as ERAB_RESPONSE_${new_qci}
#    ...   alias=UE_${ue_id}_bearer_mod   overall_timeout=15
#
#    Run WTS command  bearer_mod  ue=${ue_id} id=${${old_qci}-50} qci=${new_qci} mbr_ul=${stop_value} gbr_ul=${stop_value}
#    Log   ${start_value}

# TODO
Prepare test environment for cb013254-A_6
#    configure enb  ${A_6_yaml}
     Change LNBTS-1 attribute qciTab66.gbrOverbookingFactorDl to 10
     Change LNBTS-1 attribute qciTab65.gbrOverbookingFactorDl to 1

Cleanup test environment for cb013254-A_6
    run keyword and ignore error
    ...     run uex command  ue_detach  id=1..14

####### A_7

Attach UEs to reach requested limits in the CELL-1 for A_7
    Attach regular UEs [7-17] with gbr: 128 and start traffic to CELL-1


Start ${dir} traffic for UE-${ue_id:\d+} on QCI${qci:\d+}
    trf_data_start  ue=${ue_id}  Mbps=1  dir=${dir}  protocol=udp  qci=${qci}
    sleep  5

Trigger UE-${ue_id:\d+} radio conditions worsening and expect UE-${ue_id:\d+} QCI${qci:\d+} bearer release
    Expect Message Flow
    ...   MME_1:S1AP_E-RABReleaseIndication
    ...   alias=UE_${ue_id}_bearer_release    overall_timeout=15

    ue_ul_power_control  id=${ue_id}  pathloss=106
    Log   ${qci}

Verify UE-${ue_id:\d+} QCI${qci:\d+} bearer was released
    Flow occurred as expected    UE_${ue_id}_bearer_release
    Log   ${qci}

Attach 3 UEs with QCI65 bearer CELL-1
    Expect Message Flow
    ...  MME_1:S1AP_InitialContextSetupResponse as ICS_RESPONSE_1
    ...  MME_1:S1AP_InitialContextSetupResponse as ICS_RESPONSE_2
    ...  MME_1:S1AP_InitialContextSetupResponse as ICS_RESPONSE_3
    ...  alias=UE_102_103_104_attach_flow    overall_timeout=15

     Run UEx command  ue_attach  id=102..104  cell=1

Verify that 3 UEs were attached and QCI${qci_id} bearers were established
    Flow occurred as expected  UE_102_103_104_attach_flow

    Verify That Message Fulfills Query
    ...  E-RABSetupListCtxtSURes contains (e-RAB-ID eq 6)
    ...  message_alias=ICS_RESPONSE_1
    ...  flow_alias=UE_102_103_104_attach_flow

    Verify That Message Fulfills Query
    ...  E-RABSetupListCtxtSURes contains (e-RAB-ID eq 6)
    ...  message_alias=ICS_RESPONSE_2
    ...  flow_alias=UE_102_103_104_attach_flow

    Verify That Message Fulfills Query
    ...  E-RABSetupListCtxtSURes contains (e-RAB-ID eq 6)
    ...  message_alias=ICS_RESPONSE_3
    ...  flow_alias=UE_102_103_104_attach_flow
    Log   ${qci_id}

Prepare test environment for cb013254-A_7
    ue_ul_power_control  id=101  pathloss=104

Cleanup test environment for cb013254-A_7
    Change LNCEL-1 attribute ulTargetBler to 49
    ue_ul_power_control  id=101  pathloss=0
    ue_detach  id=101..104

######## A_8

Attach UEs to reach requested limits in the CELL-1 for A_8
     run keyword and ignore error    Attach regular UEs [10-25] and start DL traffic to CELL-1
     run keyword and ignore error    Attach regular UEs [26-36] with gbr: 128 and start traffic to CELL-1

Change LNCEL-1.eirpReduction to 6dB and expect low prio bearers release
    Expect Message Flow
    ...   MME_1:S1AP_E-RABReleaseIndication
    ...   alias=UE_X_bearer_release    overall_timeout=120

    Change LNCEL-1 attribute eirpReduction to 6dB

Attach QCI65 [101-109] UEs and start DL traffic
     run keyword and ignore error    run uex command  ue_attach  id=101..109  cell=1  rate=1
     run keyword and ignore error    run uex command  trf_data_start  Mbps=2  dir=dl  protocol=udp  qci=65  ue=101..109  rate=1

Verify low prio bearers were released due to EIRP resource shortage
    Flow occurred as expected    UE_X_bearer_release



######### A_9
Attach UEs to reach requested limits in the CELL-1 for A_9
    Attach regular UEs [10-20] with gbr: 128 and start traffic to CELL-1

Start MBMS session with QCI${qci} service_id=${service_id} and throughput=${throughput}
    Expect Message Flow
    ...                 MME_1:M3AP_MBMSSessionStartRequest
    ...                 MME_1:M3AP_MBMSSessionStartResponse
    ...                 alias=MBMS_START_${service_id}
    ...                 overall_timeout=30
    start mbms session
    ...                 qci=${qci}
    ...                 gbr=${throughput}
    ...                 sai=1
    ...                 tmgi=${service_id}:${plmn}
    ...                 time_correction_period=5
    ...                 session_id=${service_id}
    Flow Occurred as expected    alias=MBMS_START_${service_id}
    sleep  10

Start MBMS traffic for session with
    [Arguments]  ${session_id}=1  ${bit_rate}=950k  ${buffer_length}=1400
    generate_multicast_traffic    tmgi=${session_id}:${plmn}  alias=session_${session_id}  bit_rate=${bit_rate}  buffer_length=${buffer_length}

Verify That Average Mbms Traffic For Enb Cell Session Is reached
    no operation

Attach multiple UEs with QCI66
    Expect message will not occur
    ...         MME_1:S1AP_InitialContextSetupResponse (cause is present)
    ...         alias=s1ap_ics_failure  overall_timeout=10
    Run UEx command  ue_attach  id=4..6,54..56  cell=1

Verify all UEs were accepted and bearers established
    Flow not occurred for message   s1ap_ics_failure

Stop all running MBMS sessions
    Expect Message Flow
    ...                  MME_1:M3AP_MBMSSessionStopRequest
    ...                  MME_1:M3AP_MBMSSessionStopResponse
    ...                  alias=MBMS_SESSION_STOP     overall_timeout=30
    stop_mbms_session
    ...             tmgi=1:244:09
    Flow Occurred as expected    alias=MBMS_SESSION_STOP

Prepare test environment for cb013254-A_9
    Wait until M3 link is up    enb_id=1
    run wts command  mbms_param  time_ref=UTC
    run wts command  mbms_param  sync_ref=0:0

Cleanup test environment for cb013254-A_9
    run keyword and ignore error
    ...     run uex command  ue_detach  id=4..6,54..56,10..20

########## A_10



Attach UEs to reach requested limits in the CELL-2 for A_10
    run keyword and ignore error     Attach regular UEs [22-38] with gbr: 128 and start traffic to CELL-2
    sleep  5

Attach UE-${ue_id:\d+} with QCI65 bearer and with establishment cause set to emergency to CELL-1
    Expect Message Flow
    ...  UE_${ue_id}:RRC_RRCConnectionRequest
    ...  UE_${ue_id}:RRC_RRCConnectionSetup
    ...  UE_${ue_id}:RRC_RRCConnectionSetupComplete
    ...  MME_1:S1AP_InitialUEMessage
    ...  MME_1:S1AP_InitialContextSetupRequest as ICS_REQUEST_65
    ...  UE_${ue_id}:RRC_UECapabilityEnquiry
    ...  UE_${ue_id}:RRC_UECapabilityInformation
    ...  UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...  UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...  MME_1:S1AP_InitialContextSetupResponse as ICS_RESPONSE_65
    ...  alias=UE_${ue_id}_attach_flow    overall_timeout=15

    Run UEx command  ue_attach  id=${ue_id}  cell=1  establishment_cause=emergency


Attach 3 UEs with QCI${qci_id} bearer to CELL-${cell_id} and expect one QCI${qci_id} bearer not established
    Expect Message Flow
    ...  MME_1:S1AP_InitialContextSetupRequest as ICS_REQUEST_${qci_id}
    ...  MME_1:S1AP_InitialContextSetupResponse (cause is present) as ICS_RESPONSE_${qci_id}
    ...  alias=${qci_id}bearer_not_established_flow    overall_timeout=15

    Run Keyword And Ignore Error   Run UEx command  ue_attach  id=51..53  cell=${cell_id}

    sleep  5

    ue_detach  id=51..53

    sleep  5

Attach 3 UEs with QCI${qci_id} bearer to CELL-${cell_id}


     Expect Message Flow
    ...   MME_1:S1AP_E-RABSetupRequest as ERAB_REQUEST_${qci_id}
    ...   MME_1:S1AP_E-RABSetupResponse (cause is present) as ERAB_RESPONSE_${qci_id}
    ...   alias=${qci_id}bearer_not_established_flow    overall_timeout=15

     Run Keyword And Ignore Error     Run UEx command  ue_attach  id=111..120  cell=${cell_id}    rate=1
     sleep    5s






Verify that one QCI${qci_id} bearer was not established
#    Flow occurred as expected    ${qci_id}bearer_not_established_flow
#
#    Verify That Message Fulfills Query
#    ...  E-RABToBeSetupListBearerSUReq contains (qCI eq ${qci_id} and e-RAB-ID eq 6)
#    ...  message_alias=ERAB_REQUEST_${qci_id}
#    ...  flow_alias=${qci_id}bearer_not_established_flow

    Verify That Message Fulfills Query
    ...  E-RABList contains (cause contains (radioNetwork eq 'radio-resources-not-available') and e-RAB-ID eq 6)
    ...  message_alias=ERAB_RESPONSE_${qci_id}
    ...  flow_alias=${qci_id}bearer_not_established_flow

Attach 3 UEs with QCI65 bearer with establishment cause set to emergency to CELL-2
    Expect Message Flow
    ...  MME_1:S1AP_InitialContextSetupResponse as ICS_RESPONSE_1
    ...  MME_1:S1AP_InitialContextSetupResponse as ICS_RESPONSE_2
    ...  MME_1:S1AP_InitialContextSetupResponse as ICS_RESPONSE_3
    ...  alias=UE_51_52_53_attach_flow    overall_timeout=15

     Run UEx command  ue_attach  id=51..53  cell=2  establishment_cause=emergency
     sleep  0.5

Verify that 3 emergency UEs were attached and QCI${qci_id} bearers were established
    Flow occurred as expected  UE_51_52_53_attach_flow

    Verify That Message Fulfills Query
    ...  E-RABSetupListCtxtSURes contains (e-RAB-ID eq 6)
     ...  message_alias=ICS_RESPONSE_1
    ...  flow_alias=UE_51_52_53_attach_flow

    Verify That Message Fulfills Query
    ...  E-RABSetupListCtxtSURes contains (e-RAB-ID eq 6)
     ...  message_alias=ICS_RESPONSE_2
    ...  flow_alias=UE_51_52_53_attach_flow

    Verify That Message Fulfills Query
    ...  E-RABSetupListCtxtSURes contains (e-RAB-ID eq 6)
    ...  message_alias=ICS_RESPONSE_3
    ...  flow_alias=UE_51_52_53_attach_flow
    Log   ${qci_id}

Start wireshark
    start_tshark   log_filename=CB013254.pcap    eth_interface=eth3   capture_filter=less 1000   alias=resource_check

Stop wireshark
    stop_tshark    alias=resource_check

Start wireshark_1
    start_tshark   log_filename=CB013254_1.pcap    eth_interface=eth3   capture_filter=less 1000   alias=resource_check_1

Stop wireshark_1
    stop_tshark    alias=resource_check_1

Start wireshark_2
    start_tshark   log_filename=CB013254_2.pcap    eth_interface=eth3   capture_filter=less 1000   alias=resource_check_2

Stop wireshark_2
    stop_tshark    alias=resource_check_2

Attach UE-1..3 with QCI65 bearer to CELL-1

          [Arguments]    ${i1}     ${i2}
    FOR    ${ue_id}    IN RANGE    ${i1}    ${i2}

            Run UEx Command  ue_attach    id=${ue_id}  cell=1
            Run UEx Command  trf_data_start  ue=${ue_id}  dir=dl  Mbps=1  protocol=udp  size=1400    qci=65
            sleep    1s
    END

Verify UE-1..3 was attached and QCI65 bearer established
     Verify_tshark_for_at_least_given_number_of_messages   packet_filter=s1ap.qCI == 65 && s1ap.e_RAB_ID == 6
     ...  number_of_messages=1   alias=resource_check

Attach regular UE-7..30 to CELL-1 & ADD QCI65 bearer
            [Arguments]    ${i1}     ${i2}
    FOR    ${ue_id}    IN RANGE    ${i1}    ${i2}

           run keyword and ignore error     Run UEx Command  ue_attach    id=${ue_id}  cell=1
           run keyword and ignore error    Run UEx Command    bearer_add    ue=${ue_id}  qci=65    mbr_ul=256 mbr_dl=256 gbr_ul=256 gbr_dl=256
            sleep    .5s
    END
Attach UE-7 and add Bearer
     Run UEx Command  ue_attach    id=7  cell=1
      Run UEx Command    bearer_add    ue=7  qci=65    mbr_ul=64 mbr_dl=64 gbr_ul=64 gbr_dl=64

Modify QCI 65 in UE-7 to CELL-1

       Run WTS command  bearer_mod  ue=7  id=15   qci=65 mbr_dl=256  gbr_dl=256

Attach regular UE-7..18 to CELL-2 & ADD QCI65 bearer
            [Arguments]    ${i1}     ${i2}
    FOR    ${ue_id}    IN RANGE    ${i1}    ${i2}

           run keyword and ignore error     Run UEx Command  ue_attach    id=${ue_id}  cell=2
           run keyword and ignore error    Run UEx Command    bearer_add    ue=${ue_id}  qci=65    mbr_ul=256 mbr_dl=256 gbr_ul=256 gbr_dl=256
            sleep    .5s
    END




Verify Pre-emption in low Priority QCI
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=s1ap.radioNetwork == 39 && s1ap.e_RAB_ID == 6
    ...    number_of_messages=1    alias=resource_check

Verify QCI3 reached to limit
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=s1ap.radioNetwork == 25 && s1ap.e_RAB_ID == 6
    ...   number_of_messages=1     alias=resource_check

Verify QCI3 reached to limit_1
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=s1ap.radioNetwork == 25 && s1ap.e_RAB_ID == 6
    ...   number_of_messages=1     alias=resource_check_1

Verify QCI65 reached to limit
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=s1ap.radioNetwork == 25 && s1ap.e_RAB_ID == 6
    ...   number_of_messages=1     alias=resource_check_1

Verify qci3 release
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=s1ap.radioNetwork == 25 && s1ap.e_RAB_ID == 6
    ...   number_of_messages=3     alias=resource_check_2

Verify qci3 addition
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=s1ap.qCI == 3 && s1ap.e_RAB_ID == 6
    ...   number_of_messages=3     alias=resource_check_2

Verify qci65 addition
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=s1ap.qCI == 65 && s1ap.e_RAB_ID == 6
    ...  number_of_messages=3     alias=resource_check_2

Verify E-RAB Modification request
    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=s1ap.E_RABModifyListBearerModRes
    ...    number_of_messages=1    alias=resource_check


syslog crash verification

#K2 DSP crash
    ${1}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6706      alias=feat_act
    ${2}=    taf.sw.syslog.count_syslog_messages      regexp=faultId: 6707      alias=feat_act
    ${3}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6709      alias=feat_act

#K2 ARM Application crash
    ${4}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6708      alias=feat_act
	${5}=    taf.sw.syslog.count_syslog_messages      regexp=faultId: 4019      alias=feat_act
	${6}=    taf.sw.syslog.count_syslog_messages      regexp=FR_FaultProcessor::triggerLogConnectionIfNeeded      alias=feat_act
#AXM ARM crash
	${7}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6450      alias=feat_act
	${8}=    taf.sw.syslog.count_syslog_messages      regexp=FR_FaultProcessor::triggerLogConnectionIfNeeded      alias=feat_act
	${9}=    taf.sw.syslog.count_syslog_messages      regexp=BTSOM_COLLECT_DSP_CRASH_LOGS      alias=feat_act
    ${10}=    taf.sw.syslog.count_syslog_messages      regexp=EAaErrorFatality_Fatal      alias=feat_act

	Should be True     ${1} == 0
	Should be True     ${2} == 0
	Should be True     ${3} == 0
	Should be True     ${4} == 0
	Should be True     ${5} == 0
	Should be True     ${6} == 0
	Should be True     ${7} == 0
	Should be True     ${8} == 0
	Should be True     ${9} == 0
	Should be True     ${10} == 0


Start wireshark_qci3
     start_tshark   log_filename=CB013254_qci3.pcap    eth_interface=eth3   capture_filter=less 1000   alias=resource_check_qci3

Stop wireshark_qci3
     stop_tshark    alias=resource_check_qci3

Start wireshark_after_feature_activation
     start_tshark   log_filename=CB013254_qci65.pcap    eth_interface=eth3   capture_filter=less 1000   alias=resource_check_qci65

Stop wireshark_after_feature_activation
     stop_tshark    alias=resource_check_qci65



verify QCI3 Pre-emption after feature activation
      Verify_tshark_for_at_least_given_number_of_messages    packet_filter=s1ap.radioNetwork == 39 && s1ap.e_RAB_ID == 6
      ...    number_of_messages=5     alias=resource_check_qci65

verify PRB has reached to requested limit
      Verify_tshark_for_at_least_given_number_of_messages    packet_filter=s1ap.radioNetwork == 25 && s1ap.e_RAB_ID == 6
       ...    number_of_messages=1     alias=resource_check_qci3

Attach regular UE-71..75 to CELL-16 non-gbr and traffic
     run uex command    ue_attach  id=71..75  cell=16  rate=1
     run uex command    trf_data_start    ue=71..75    Mbps=2  dir=dl  protocol=udp
Start wireshark_after_feature_activation_again
      start_tshark   log_filename=CB013254_act.pcap    eth_interface=eth3   capture_filter=less 1000   alias=resource_check_act
Stop wireshark_after_feature_activation_again
      stop_tshark    alias=resource_check_act

verify QCI65 Admission_Overbooking
      Verify_tshark_for_at_least_given_number_of_messages      packet_filter=s1ap.qCI == 66 && s1ap.e_RAB_ID == 6
      ...    number_of_messages=1     alias=resource_check_act

Attach UEs and add GBR QCI3 to reach requested limits in the CELL-16

          [Arguments]    ${i1}     ${i2}
    FOR    ${ue_id}    IN RANGE    ${i1}    ${i2}

            Run UEx Command  ue_attach    id=${ue_id}  cell=16
            Run UEx Command    bearer_add    ue=${ue_id}  qci=3 mbr_ul=128 mbr_dl=128 gbr_ul=128 gbr_dl=128
            Run UEx Command  trf_data_start  ue=${ue_id}  dir=dl  Mbps=1  protocol=udp  size=1400    qci=3
            sleep    2s
    END


Attach UEs with QCI65 bearer to CELL-16 and expect all QCI65 bearer established
       [Arguments]    ${i1}     ${i2}
    FOR    ${ue_id}    IN RANGE    ${i1}    ${i2}
        Run UEx Command  ue_attach    id=${ue_id}  cell=16
        Run UEx Command    bearer_add    ue=${ue_id}  qci=66 mbr_ul=128 mbr_dl=128 gbr_ul=128 gbr_dl=128
        Run UEx Command  trf_data_start  ue=${ue_id}  dir=dl  Mbps=1  protocol=udp  size=1400    qci=66

        sleep    2s
    END

Start wireshark_after_feature_deactivation
      start_tshark   log_filename=CB013254_Deact.pcap    eth_interface=eth3   capture_filter=less 1000   alias=resource_check_Deact
verify no resource for gbr bearer
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=s1ap.radioNetwork == 25 && s1ap.e_RAB_ID == 6
     ...    number_of_messages=1    alias=resource_check_Deact

Stop wireshark_after_feature_deactivation
     stop_tshark     alias=resource_check_Deact


syslog crash verification_1

#K2 DSP crash
    ${1}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6706      alias=feat_act_1
    ${2}=    taf.sw.syslog.count_syslog_messages      regexp=faultId: 6707      alias=feat_act_1
    ${3}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6709      alias=feat_act_1

#K2 ARM Application crash
    ${4}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6708      alias=feat_act_1
	${5}=    taf.sw.syslog.count_syslog_messages      regexp=faultId: 4019      alias=feat_act_1
	${6}=    taf.sw.syslog.count_syslog_messages      regexp=FR_FaultProcessor::triggerLogConnectionIfNeeded      alias=feat_act_1
#AXM ARM crash
	${7}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6450      alias=feat_act_1
	${8}=    taf.sw.syslog.count_syslog_messages      regexp=FR_FaultProcessor::triggerLogConnectionIfNeeded      alias=feat_act_1
	${9}=    taf.sw.syslog.count_syslog_messages      regexp=BTSOM_COLLECT_DSP_CRASH_LOGS      alias=feat_act_1
    ${10}=    taf.sw.syslog.count_syslog_messages      regexp=EAaErrorFatality_Fatal      alias=feat_act_1

	Should be True     ${1} == 0
	Should be True     ${2} == 0
	Should be True     ${3} == 0
	Should be True     ${4} == 0
	Should be True     ${5} == 0
	Should be True     ${6} == 0
	Should be True     ${7} == 0
	Should be True     ${8} == 0
	Should be True     ${9} == 0
	Should be True     ${10} == 0


Verify Cell throughput After QCI3 addition
     ${output}     Run UEx Command     cell_stats    id=1    type=dl_mac    unit=kbps    output=brief
     ${b}=  Convert To String  ${output}
     Append To File       ${OUTPUT_DIR}${/}THP1.txt      ${b}
     Log To Console      ${b}

Verify QCI3 Throughput after QCI65 release
     ${output}     Run UEx Command     cell_stats    id=1    type=dl_mac    unit=kbps    output=brief
     ${b}=  Convert To String  ${output}
     Append To File       ${OUTPUT_DIR}${/}THP2.txt      ${b}
     Log To Console      ${b}

Compare Thrughput after eirp activation
     ${Evaluate2}=    Run    awk '{print $4}' ${OUTPUT_DIR}${/}THP2.txt
     ${THP_BEFORE_EIRP2}=      Evaluate    float(${Evaluate2})
     ${Evaluate1}=    Run    awk '{print $4}' ${OUTPUT_DIR}${/}THP1.txt
     ${THP_BEFORE_EIRP1}=      Evaluate    float(${Evaluate1})
     Should be True     ${THP_BEFORE_EIRP1} > ${THP_BEFORE_EIRP2}


Convert String To Number
    ${string_number}    Set Variable    123.45
    ${number}    Evaluate    float(${string_number})
    Should Be Equal As Numbers    ${number}    123.45
