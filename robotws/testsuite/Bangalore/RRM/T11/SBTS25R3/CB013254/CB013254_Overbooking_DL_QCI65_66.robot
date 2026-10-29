*** Settings ***
Force Tags    CLOUD_R4BANO_CUS     CRT    RAN_4G    RAN_4G_FDD    SBTS00

Documentation
...
...             author:           Sujeet.sharma@nokia.com
...             author:           sanjeev.pandey@nokia.com
...             maintainer:       sanjeev.pandey@nokia.com
...         This feature introduces overbooking support in DL for QCI 65 and 66 GBR traffic.
...         This is an enhancement of LTE3099 feature where overbooking of QCI 65 and QCI 66 was not supported.
...         Main goal of this feature is to allow Public Safety mission-critical and non-mission-critical group calls.
...         This is done by doing more relaxed admission control forecast calculation in downlink direction.
...         Such behavior can end with deprioritization/ preemption of other bearers with low priority.
...         Overbooking can be configured individually for the QCI 65 and QCI66. The overbooking factor is considered
...         at bearer setup, GBR bearer modification (in this case LTE1321 needs to be enabled) and also handover.
...         The overbooking factor does not change the congestion control mechanism of LTE496, e.g. GBR bearers
...         might be dropped shortly after admission if according congestion control schemes are configured.
...         The feature is activated/deactivated on cell level.
...         No new counters are introduced by this feature.
...         The feature is dedicated for FDD and TDD.
...
...         UEs mapping used across tests:
...         1-3 - preprovisioned QCI65 bearer, preemption capable
...         4-6 - preprovisioned QCI66 bearer, preemption capable
...         7-50 - only default QCI9 bearer, other bearers preemption vulnerable
...         51-53 - preprovisioned QCI65 bearer, preemption not capable
...         54-56 - preprovisioned QCI66 bearer, preemption not capable
...         57-100 - only default QCI9 bearer, other bearers preemption not vulnerable
...         sujeet.sharma@nokia.com

Resource    resources/CB013254_TC_resource.robot
Library     OperatingSystem
Library     ta_uexgate
Library     taf.ul.ue.sim.env_setup
#Library      taf.sw.reporting_portal
Library      taf.sw.syslog
Library     taf.sbts.oam.coam.admin
Resource     ../../../../resources/robot/configuration_id.robot
Library     BuiltIn
Library     String
Library     SSHLibrary
Library     Collections
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot


*** Variables ***

${scf_xml}=             scfc_BANO_FDD_TDD.xml
${cus_config}=          cus_BANO.yaml
${scfc1}        Configuration_scf_MRBTS-40807.xml
${cus_ini_1}    ${CURDIR}${/}config${/}/CB013254_cus.ini
${lua}         ${CURDIR}${/}config${/}/CB013254_epc.lua
${ue_db}       ${CURDIR}${/}config${/}/CB013254.db
${ADDRESS}     192.168.255.1
${PORT}        3600
${USE_SSL}     True

*** Test Cases ***
CB013254_Overbooking_for_QCI_65_66_GBR_bearer_in_DL_when_it_is_setup_during_initial_context_setup_or_E-RAB_setup_procedure


    [Setup]  Prepare test environment for CB013254-A_1
    run keyword and continue on failure    Link SCOUT SCF to Configuration ID for Reporting
    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog    log_dir=/tmp    log_name=feat_act.log    alias=feat_act  ip=192.168.255.126       ports=51000
    Log To Console  \n     QCI 65/66 pre-emption check & ERAB modification
    Start wireshark
    Attach UEs to reach requested limits in the CELL-1 for A_1
    Verify QCI3 reached to limit
    Attach UE-1..3 with QCI65 bearer to CELL-1    i1=1    i2=3
    Verify UE-1..3 was attached and QCI65 bearer established
    Attach UE-7 and add Bearer
    Attach regular UE-7..30 to CELL-1 & ADD QCI65 bearer   i1=8    i2=40
    Verify Pre-emption in low Priority QCI
    Modify QCI 65 in UE-7 to CELL-1
    sleep    2s
    Verify E-RAB Modification request
    Run UEx command    ue_detach    all
    Stop wireshark
    Log To Console  \n     Testing when Overbooking DL factor set 5 and then changed to 100 and 0
    Change LNBTS-1 attribute qciTab65.gbrOverbookingFactorDl to 5
    Attach UEs to reach requested limits in the CELL-1 for A_5
    Attach regular UE-57 to CELL-1
    Attach regular UE-58 to CELL-1
    Attach 2 UEs [111..125] with QCI65 bearer to CELL-1 and verify one QCI65 bearer not established
    Change LNBTS-1 attribute qciTab65.gbrOverbookingFactorDl to 100
    Add to UE-57 QCI65 bearer with 128kbps bitrate and expect bearer was established
    Verify UE-57 QCI65 bearer was established
    Change LNBTS-1 attribute qciTab65.gbrOverbookingFactorDl to 0
    sleep    5s
    Add UEs QCI65 bearer and expect bearer was not established
    Verify UEs QCI65 bearer was not established
    Run UEx command    ue_detach    all
     Log To Console  \n     Congestion handle Triggered
    Change LNBTS-1 attribute qciTab65.gbrOverbookingFactorDl to 100
    Run UEx command   ue_ul_power_control  id=101  pathloss=104
    Attach UE-101 with QCI65 bearer to CELL-1
    Verify UE-101 was attached and QCI65 bearer established
    Start dl traffic for UE-101 on QCI65
    Attach 3 UEs with QCI65 bearer CELL-1
    Verify that 3 UEs were attached and QCI65 bearers were established
    Trigger UE-101 radio conditions worsening and expect UE-101 QCI65 bearer release
    Run UEx command    ue_detach    all
     Log To Console  \n  Emergency establishment cause
    Change LNBTS-1 attribute qciTab65.gbrOverbookingFactorDl to 5
    Start wireshark_1
    Attach UEs to reach requested limits in the CELL-2 for A_10
    Verify QCI3 reached to limit_1
    Attach regular UE-7..18 to CELL-2 & ADD QCI65 bearer     i1=7    i2=22
    Sleep    1s
    Verify QCI65 reached to limit
    sleep  2s
    Attach 3 UEs with QCI65 bearer with establishment cause set to emergency to CELL-2
    Verify that 3 emergency UEs were attached and QCI65 bearers were established
    Run UEx command    ue_detach    all
    Stop wireshark_1
    Log To Console   \n Congestion handling triggered by shortage of EIRP budget
    Change LNBTS-1 attribute qciTab65.gbrOverbookingFactorDl to 100
    Start wireshark_2
    Attach UEs to reach requested limits in the CELL-1 for A_8
    Verify Cell throughput After QCI3 addition
    Verify qci3 addition
    Attach QCI65 [101-109] UEs and start DL traffic
    Verify qci65 addition
    Change LNCEL-1.eirpReduction to 6dB and expect low prio bearers release
    run keyword and ignore error     Run UEx Command     ue_detach   id=101..109
    Verify QCI3 Throughput after QCI65 release
    Verify qci3 release
    Compare Thrughput after eirp activation
    Run UEx Command     ue_detach   all
    Stop wireshark_2

    [Teardown]     Run Keywords    syslog crash verification
    ...    AND    taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act.log    unzip=True    alias=feat_act
    ...    AND    taf.sw.syslog.teardown_all_aliases_for_syslog


CB013254_Overbooking_for_QCI_65_66_GBR_bearer_in_DL_when_it_is_setup_during_initial_context_setup_or_E-RAB_setup_procedure_but_preemption_enable
     [Setup]    Configure Env for CB013254_2
     run keyword and continue on failure    Link SCOUT SCF to Configuration ID for Reporting
     taf.sw.syslog.teardown_all_aliases_for_syslog
     taf.sw.syslog.Start Syslog    log_dir=/tmp    log_name=feat_act_1.log    alias=feat_act_1  ip=192.168.255.126       ports=51000
     Start wireshark_qci3
     Run Keyword And Ignore Error     Attach UEs and add GBR QCI3 to reach requested limits in the CELL-16   i1=1     i2=70
     sleep    2s
     verify PRB has reached to requested limit
     Stop wireshark_qci3
     taf.sbts.oam.coam.admin.Setup Admin
     taf.sbts.oam.coam.admin.perform_parameter_recommissioning    dist_name=MRBTS-40807/LNBTS-40807/LNCEL-16    parameter=actPttOverbooking
      ...    value=true   operation=update    skip_parameter_relation_errors=True     should_activate=True
     taf.sbts.oam.coam.admin.Teardown admin

     Start wireshark_after_feature_activation
     Attach regular UE-71..75 to CELL-16 non-gbr and traffic
     Run Keyword And Ignore Error     Attach UEs with QCI65 bearer to CELL-16 and expect all QCI65 bearer established     i1=76     i2=145
     Sleep    2s
     verify QCI3 Pre-emption after feature activation
     Stop wireshark_after_feature_activation
     Start wireshark_after_feature_deactivation
     taf.sbts.oam.coam.admin.Setup Admin
     taf.sbts.oam.coam.admin.perform_parameter_recommissioning    dist_name=MRBTS-40807/LNBTS-40807/LNCEL-16    parameter=actPttOverbooking
       ...    value=false   operation=update    skip_parameter_relation_errors=True     should_activate=True
     taf.sbts.oam.coam.admin.Teardown admin
     Change LNBTS-40807 attribute qciTab65.gbrOverbookingFactorDl to 0
      Sleep    5s
     Run Keyword And Ignore Error     Attach UEs with QCI65 bearer to CELL-16 and expect all QCI65 bearer established     i1=150     i2=200
     verify no resource for gbr bearer
     Stop wireshark_after_feature_deactivation
     taf.sbts.oam.coam.admin.Setup Admin
     taf.sbts.oam.coam.admin.perform_parameter_recommissioning    dist_name=MRBTS-40807/LNBTS-40807/LNCEL-16    parameter=actPttOverbooking
       ...    value=true   operation=update    skip_parameter_relation_errors=True     should_activate=True
     taf.sbts.oam.coam.admin.Teardown admin
     Change LNBTS-40807 attribute qciTab65.gbrOverbookingFactorDl to 15
     Start wireshark_after_feature_activation_again
     Run Keyword And Ignore Error     Attach UEs with QCI65 bearer to CELL-16 and expect all QCI65 bearer established     i1=201     i2=250
     verify QCI65 Admission_Overbooking
     Stop wireshark_after_feature_activation_again
     Run UEx Command  ue_detach  all
      [Teardown]     Run Keywords    syslog crash verification_1
    ...    AND    taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act_1.log    unzip=True    alias=feat_act_1
    ...    AND    taf.sw.syslog.teardown_all_aliases_for_syslog
