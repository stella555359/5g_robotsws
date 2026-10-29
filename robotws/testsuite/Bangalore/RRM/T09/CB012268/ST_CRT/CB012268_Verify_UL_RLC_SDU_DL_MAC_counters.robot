*** Settings ***
Documentation
...      author:           chaithanya    chaithanya.h_s@nokia.com
...      maintainer:       chaithanya    chaithanya.h_s@nokia.com

...      INTRODUCTION:  The aim of the Cb012464 feature is NR Radio Quality Measurement PM Counters
...      Provides PMQAP counters for 5G DL/UL radio quality measurements.
...      Improves reporting of UL RIP per PRB counters;
...      Delivers SS-RSRP/RSRQ/SINR distribution counters per SSB Beam.
...      Introduces counters to report UL SINR and RIP per spatial stream
...      RI, BLER , CQI, MCS value multiple PMQAP profile counter validation

Library   String
Library   Collections
Library   DateTime
Library   OperatingSystem
Library   Process
Library   Screenshot
Library   XML
Library   Telnet
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library   taf.sw.dcap.rd    WITH NAME    rd
Library   taf.collectors.core   WITH NAME   core
Library   taf.collectors.btslog  WITH NAME   btslog
Library   taf/rfrl/uuf4all/resources/python/uuf_rfrl_update.py
Library   testsuite.Bangalore.ORAN.resources.python.ta_ultracaller  WITH NAME  uc
Library   ../../../../ORAN/resources/python/SysValidation.py  WITH NAME  Validation
Library   taf.selenium.sbts    WITH NAME  Selenium_Sbts
Library   taf.hw.rf_attenuator.attenuator    WITH NAME   attenuator
Library    OperatingSystem    WITH NAME    os
Library   ta5g_pm_counters
Resource  ../../../../resources/robot/PM_Counters.robot
Resource  ../../resources/robot/Common_keywords_ST.robot
Library     taf.collectors.pmcounters    WITH NAME    collect_pm
Library     taf.analyzer.pmcounter       WITH NAME    check_pm
Library    ute_fsmaccess

Resource    ../../../../resources/robot/Admin.robot

Test Setup        Run Keywords          Set_export_yml     10.43.13.80
...      AND      Test_Setup_keywords

Test Teardown     Test_Teardown_Keywords

*** Variables ***
${LOOP_COUNT}             4
${folder}                          /home/ute/robotws
@{UE_alias}                        UE1
@{capabilities}                    Legacy_1
@{DL_udpcalltype}=                    TCP
@{UL_udpcalltype}=                    TCP
${protocol}=                       TCP
@{direction_dl}=                   dl
@{direction_ul}=                   ul
${timeout}=                        1800
${Attenuator_ip_addr}              10.43.13.250
${Attenuator_com_port}             3001
@{attenuation_ports}               1    2
#${attenuation_port}                1
${Attenuator_vendor}               TOPYOUNG
${Attenuator_model}                TAS16T16-51-120-1N-DEJS
@{PVA_Port_1_2}    		           1    2
${Counter_DL_MAC_SDU}               MRBTS-30311/NRBTS-30311/NRCELL-301
${Counter_DL_MAC_UL_RLC}            MRBTS-30311/NRBTS-30311/NRCELL-301
${PMQAP_Counter_DL_MAC_UL_RLC}      NRPMQAP-9
${ABSTRACT_LIB_CONFIG}=            /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012268/UE/ta_ue_config.yaml
${BTS_ID}                          MRBTS-30311
${BTSLOG} =                        btslog
&{BTS_Details}                     bts_host=192.168.255.129
...                                bts_port=443
...                                username=Nemuadmin
...                                password=nemuuser
...                                use_ssl=True
...                                update_interval=5000
...                                admin_api_log_dir=${EXECDIR}
...                                name=default
...                                bundle_path=${ABSTRACT_LIB_CONFIG}
...                                release=SBTS00
...                                timeout=30
${DELTA_F_disable} =               /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012268/config/F_disable.json
${DELTA_F_enable} =                /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012268/config/F_Split_enable.json
${commision_file}                  /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012268/config/Default_scf.xml
${DELTA_C_enable} =                /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012268/config/SBTS26R2/C_Split_enable.json
${connection}                      default
#${ue_yaml_target}=		/home/ute/robotws/testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/data_transfer/ta_ue_config.yaml
#${ABSTRACT_LIB_CONFIG}




*** Test Cases ***
[1][1.0] CB012268_A2_Verify_UL_RLC_SDU_UE_Tput_Volume_PMQAP_Counter_Basic_Verification_Single_UE
    [Tags]    QC_276038   QCD_MN_RAN    QCP_RAN_VRF
    log to console      ${OUTPUT_DIR}
    admin.Connect to   bts_host=${BTS_Details.bts_host}    username=${BTS_Details.username}
...                    password=${BTS_Details.password}    admin_api_log_dir=${BTS_Details.admin_api_log_dir}
...                    release=${BTS_Details.release}
    Perform commissioning     ${commision_file}
    sleep   200 s
    Perform delta commissioning     ${DELTA_F_disable}
    Sleep    20s
    start Btslogs from Local machine    ${BTSLOG}
    Sleep    20 s  							 #BTS may need some time to update scf file.
    Require ue for ue functions      				 ##Attach Ue to gnb
    detach ue via ultracaller
    initial ue attach via ultracaller
    UDP_DL_UL_data_transfer
    Validate the Counter before actMacUserThpt
    Perform delta commissioning     ${DELTA_F_enable}
    detach ue via ultracaller
    initial ue attach via ultracaller
    UDP_DL_UL_data_transfer
    detach ue via ultracaller
    initial ue attach via ultracaller
    UDP_DL_UL_data_transfer
    detach ue via ultracaller
    initial ue attach via ultracaller
    UDP_DL_UL_data_transfer
    detach ue via ultracaller
    initial ue attach via ultracaller
    UDP_DL_UL_data_transfer
    detach ue via ultracaller
    initial ue attach via ultracaller
    UDP_DL_UL_data_transfer
    Validate the Counter after actMacUserThpt with UL counters
    Validate the Counter after PMQAP actMacUserThpt with UL counters


	Perform delta commissioning     ${DELTA_C_enable}
	Sleep    20s
    start Btslogs from Local machine    ${BTSLOG}
    Sleep    20 s  							 #BTS may need some time to update scf file.
    Require ue for ue functions
    detach ue via ultracaller
    initial ue attach via ultracaller
    UDP_DL_UL_data_transfer
    UE_Attach_Detach_Loop
    initial ue attach via ultracaller
    UDP_DL_UL_data_transfer
    Validate the Counter after PDCP_SDU_CELL_THP_UL_MAX_with_UL_DL_counters

#    uc.stop_data_transfer    ${UE_alias}

*** Keywords ***
UE_Attach_Detach_Loop
    FOR    ${i}    IN RANGE    ${LOOP_COUNT}
        initial ue attach via ultracaller
        Sleep    10 s
        UDP_DL_UL_data_transfer
        Sleep    20 s
        detach ue via ultracaller
        Sleep    10 s
    END


UDP_DL_UL_data_transfer
    uc.start_datatransfer    ${UE_alias}    ${DL_udpcalltype}    direction=${direction_dl}
    Sleep    30 s
    uc.start_datatransfer    ${UE_alias}    ${UL_udpcalltype}    direction=${direction_ul}

Validate the Counter before actMacUserThpt
#* [>200000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55373C00005    0    DL_MAC_SDU_VOL_UE_TPUT_PMQAP
    ...     M55373C00006    0    DL_MAC_SDU_TIME_UE_TPUT_PMQAP
    ...     M55349C03002    0    DL_RLC_PDU_VOL_UE_TPUT
    ...     M55349C04002    0    DL_RLC_PDU_TIME_UE_TPUT
    ...     M55353C00002    0    DL_RLC_PDU_VOL_UE_TPUT_PMQAP
    ...     M55353C00003    0    DL_RLC_PDU_TIME_UE_TPUT_PMQAP
    ...     M55309C00002    0    DL_MAC_SDU_VOL_UE_TPUT
    ...     M55309C00003    0    DL_MAC_SDU_TIME_UE_TPUT

    ...     local_moid=${Counter_DL_MAC_SDU}
    ...     file_path=${pm_counter_file}

Validate the Counter after actMacUserThpt with UL counters
#* [>400000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55349C03002    1466037-2166037168    DL_RLC_PDU_VOL_UE_TPUT
    ...     M55349C04002    1436908-3690877168   DL_RLC_PDU_TIME_UE_TPUT
    ...     M55309C00002    1466037-2166037168   DL_MAC_SDU_VOL_UE_TPUT
    ...     M55309C00003    1436908-3690877168    DL_MAC_SDU_TIME_UE_TPUT

    ...     M55349C03001    1466037-2166037168    UL_RLC_VOL_UE_TPUT_TOT
    ...     M55349C00085    1466037-2166037168    UL_RLC_SDU_VOL_UE_TPUT_TOT
    ...     local_moid=${Counter_DL_MAC_UL_RLC}
    ...     file_path=${pm_counter_file}

Validate the Counter after PMQAP actMacUserThpt with UL counters
#* [>400000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55373C00005    682398-6823988712    DL_MAC_SDU_VOL_UE_TPUT_PMQAP
    ...     M55373C00006    1711-1711675678    DL_MAC_SDU_TIME_UE_TPUT_PMQAP
    ...     M55353C00002    682398-6823988712   DL_RLC_PDU_VOL_UE_TPUT_PMQAP
    ...     M55353C00003    1711-1711675678    DL_RLC_PDU_TIME_UE_TPUT_PMQAP
    ...     M55353C00001    870805-8708051056    UL_RLC_VOL_UE_TPUT_PMQAP
    ...     M55353C00034    870805-8708051056    UL_RLC_SDU_VOL_UE_TPUT_PMQA
    ...     local_moid=${PMQAP_Counter_DL_MAC_UL_RLC}
    ...     file_path=${pm_counter_file}


Validate the Counter after PDCP_SDU_CELL_THP_UL_MAX_with_UL_DL_counters
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55349C00086    >0    RLC_SDU_CELL_THP_DL_MAX
    ...     M55349C00087    >0    RLC_SDU_CELL_THP_UL_MAX
    ...     local_moid=${Counter_DL_MAC_UL_RLC}
    ...     file_path=${pm_counter_file}


Set_export_yml
   [Arguments]    ${VM_IP}
   OperatingSystem.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
   log    ${VM_IP}
