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
Library   taf.sbts.oam.coam.admin    WITH NAME    admin
Library   taf.sw.dcap.rd    WITH NAME    rd
Library   taf.collectors.core   WITH NAME   core
Library   taf.collectors.btslog  WITH NAME   btslog
Library   taf/rfrl/uuf4all/resources/python/uuf_rfrl_update.py
Library   testsuite.Bangalore.ORAN.resources.python.ta_ultracaller  WITH NAME  uc
Library   ../../../../ORAN/resources/python/SysValidation.py  WITH NAME  Validation
Library   taf.selenium.sbts    WITH NAME  Selenium_Sbts
Library   taf.hw.rf_attenuator.attenuator    WITH NAME   attenuator
Library   OperatingSystem    WITH NAME    os
Library   ta5g_pm_counters
Resource  ../../../5GET_BLR/resources/robot/PM_Counters.robot
Resource  ../../resources/robot/Common_keywords_ST.robot
Library     taf.collectors.pmcounters    WITH NAME    collect_pm
Library     taf.analyzer.pmcounter       WITH NAME    check_pm
Library    ute_fsmaccess

Test Setup        Test_Setup_keywords
Test Teardown     Test_Teardown_Keywords

*** Variables ***

${folder}                          /home/ute/robotws
@{UE_alias}                        UE_1
@{capabilities}                    Legacy_1
@{udpcalltype}=                    FTP
${protocol}=                       FTP
@{direction_dl}=                   dl
@{thrughtput}=                     100mbps
@{deviation}=                      100mbps
${timeout}=                        1800
${Attenuator_ip_addr}              10.43.13.250
${Attenuator_com_port}             3001
@{attenuation_ports}               1    2
#${attenuation_port}                1
${Attenuator_vendor}               TOPYOUNG
${Attenuator_model}                TAS16T16-51-120-1N-DEJS
@{PVA_Port_1_2}    		           1    2
${Counter_MOC_PATH_256}            MRBTS-30311/NRBTS-30311/NRCELL-21
${Counter_MOC_PATH_64}             MRBTS-30311/NRBTS-30311/NRCELL-21
${ABSTRACT_LIB_CONFIG}=            /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012268/UE/ta_ue_config_B.yaml
#${ABSTRACT_LIB_CONFIG}=            /home/ute/UE/Downloads/ta_ue_config.yaml
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
${DELTA_CB012268_ON} =                /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012268/config/SBTS26R2/B_Split_enable.json
${DELTA_CB012268_cell} =                /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012268/config/SBTS26R2/celllock.json
${commision_file} =                /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012268/config/SBTS26R2/Default_scf_1.xml
${connection} =                      default
*** Test Cases ***
[1][1.0] CB012268_B1_UE_with_a_DL_pathloss_Verify_Cell_Throughput_Radio_Link_Quality_Near_Middle&Edge_UE_Counters
    [Tags]    QC_223539    QCD_MN_RAN    QCP_RAN_VRF
    admin.Connect to    bts_host=${BTS_Details.bts_host}   username=${BTS_Details.username}
    ...    password=${BTS_Details.password}  admin_api_log_dir=${BTS_Details.admin_api_log_dir}   release=${BTS_Details.release}
	Perform commissioning     ${commision_file}
    sleep   300 s
    Perform delta commissioning     ${DELTA_CB012268_ON}
	Sleep    200s
	Perform delta commissioning     ${DELTA_CB012268_cell}
	Sleep    120s
    start Btslogs from Local machine    ${BTSLOG}
    Sleep    120 s  							 #BTS may need some time to update scf file.
    Require ue for ue functions      				 ##Attach Ue to gnb
    initial ue attach via ultracaller
    FTP_dl_data_transfer_with_attenuation_near
    Sleep    60s
    Validate cell near counter

    FTP_dl_data_transfer_with_attenuation_middle
    Sleep    60 s
    Validate cell middle counter

    FTP_dl_data_transfer_with_attenuation_edge
    Sleep    60 s
    Validate cell edge counter
    uc.stop_data_transfer    ${UE_alias}

    Stops Btslogs from Local machine    ${BTSLOG}
	detach ue via ultracaller


*** Keywords ***
FTP_dl_data_transfer_with_attenuation_middle
    uc.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
    Sleep    10 s
#	uc.uc_thrughtput    ${UE_alias}    direction=${direction_dl}    thrughtput=${thrughtput}    deviation=${deviation}
    Setup_attenuator_objects    ${PVA_Port_1_2}
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=0db
    Sleep    10 s
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=10db
    Sleep    10 s
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=20db
    Sleep    10 s
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=30db
    Sleep    10 s
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=0db
    Sleep    10 s
#	attenuator.disconnect    ip_addr=${Attenuator_ip_addr}
FTP_dl_data_transfer_with_attenuation_near
    uc.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
    Sleep    10 s
    Setup_attenuator_objects    ${PVA_Port_1_2}
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=0db
    Sleep    100 s


FTP_dl_data_transfer_with_attenuation_edge
    uc.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
    Sleep    10 s
#	uc.uc_thrughtput    ${UE_alias}    direction=${direction_dl}    thrughtput=${thrughtput}    deviation=${deviation}
    Setup_attenuator_objects    ${PVA_Port_1_2}
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=0db
    Sleep    10 s
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=10db
    Sleep    10 s
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=20db
    Sleep    10 s
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=30db
    Sleep    10 s
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=40db
    Sleep    10 s
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=50db
    Sleep    10 s
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=0db
    Sleep    10 s

Validate cell near counter
#* [>200000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55394C00002     >0      PDSCH_INI_VOL_CELL_NEAR_UE
    ...     M55394C00005    >0       PUSCH_INI_VOL_CELL_NEAR_UE
    ...     M55394C00008    >0     PRB_USED_PDSCH_CELL_NEAR_UE
    ...     M55394C00011    >0      PRB_USED_PUSCH_CELL_NEAR_UE
    ...     M55400C00002    >0       ACC_UE_CELL_NEAR
    ...     local_moid=${Counter_MOC_PATH_256}
    ...     file_path=${pm_counter_file}

Validate cell middle counter
#* [>200000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55394C00003     >0      PDSCH_INI_VOL_CELL_MIDDLE_UE
    ...     M55394C00006    >0       PUSCH_INI_VOL_CELL_MIDDLE_UE
    ...     M55394C00009    >0     PRB_USED_PDSCH_CELL_MIDDLE_UE
    ...     M55394C00012    >0      PRB_USED_PUSCH_CELL_MIDDLE_UE
    ...     M55400C00003    >0       ACC_UE_CELL_MIDDLE
    ...     local_moid=${Counter_MOC_PATH_256}
    ...     file_path=${pm_counter_file}

Validate cell edge counter
#* [>200000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55394C00001     >0      PDSCH_INI_VOL_CELL_EDGE_UE
    ...     M55394C00004    >0       PUSCH_INI_VOL_CELL_EDGE_UE
    ...     M55394C00007    >0     PRB_USED_PDSCH_CELL_EDGE_UE
    ...     M55394C00010    >0      PRB_USED_PUSCH_CELL_EDGE_UE
    ...     M55400C00001    >0       ACC_UE_CELL_EDGE
    ...     local_moid=${Counter_MOC_PATH_256}
    ...     file_path=${pm_counter_file}


