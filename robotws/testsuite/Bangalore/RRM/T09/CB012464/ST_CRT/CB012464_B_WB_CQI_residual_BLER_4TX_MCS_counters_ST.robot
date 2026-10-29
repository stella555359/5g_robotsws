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
library   OperatingSystem    WITH NAME    os
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
${Counter_MOC_PATH_64}             MRBTS-30311/NRBTS-30311/NRCELL-22
#${ABSTRACT_LIB_CONFIG}=            /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012464/ST_CRT/UE/ta_ue_config.yaml
${ABSTRACT_LIB_CONFIG}=            /home/ute/UE/Downloads/ta_ue_config.yaml
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
${DELTA_PATH_4TX} =                /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012464/ST_CRT/config/Delta_4tx_256qam.json
${DELTA_PATH_2TX} =                /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012464/ST_CRT/config/Delta_2tx_64qam.json
${DELTA_PATH_feature_off}=         /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012464/ST_CRT/config/Delta_feature_disable.json
${commision_file} =                /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012464/ST_CRT/config/Default_scf.xml
${connection} =                      default
*** Test Cases ***

[1][1.0] CB012464_B_WB_CQI_residual_BLER_4TX_MCS_counters_ST.robot

    [Tags]    QC_223539    QCD_MN_RAN    QCP_RAN_VRF
    admin.Connect to    bts_host=${BTS_Details.bts_host}   username=${BTS_Details.username}
    ...    password=${BTS_Details.password}  admin_api_log_dir=${BTS_Details.admin_api_log_dir}   release=${BTS_Details.release}
	Perform commissioning     ${commision_file}
    sleep   300 s
    Perform delta commissioning     ${DELTA_PATH_4TX}
	Sleep    200s
    start Btslogs from Local machine    ${BTSLOG}
    Sleep    120 s  							 #BTS may need some time to update scf file.
    Require ue for ue functions      				 ##Attach Ue to gnb
    initial ue attach via ultracaller
    FTP_dl_data_transfer_with_attenuation
    Validate the Counter 4Tx after UE attach
    Validate the Counter BLER Residual after UE attach
    Validate the MCS_PMQAP_256Qam Counter after UE attach
    uc.stop_data_transfer    ${UE_alias}

    FTP_dl_data_transfer_with_attenuation
    Validate the CQI_PMQAP_256Qam Counter after UE attach
    uc.stop_data_transfer    ${UE_alias}

    Perform delta commissioning    ${DELTA_PATH_2TX}
    Sleep    200s
    FTP_dl_data_transfer_with_attenuation
    Validate the Counter 2Tx DLMIMO after UE attach
    Validate the MCS_PMQAP_64Qam Counter after UE attach
    uc.stop_data_transfer    ${UE_alias}
	Validate the CQI_MCS_PMQAP_64Qam Counter With Data Disable

	FTP_dl_data_transfer_with_attenuation
	Validate the Counter 2Tx DLMIMO after UE attach
    Validate the MCS_PMQAP_64Qam Counter after UE attach
    uc.stop_data_transfer    ${UE_alias}

    Perform delta commissioning     ${DELTA_PATH_feature_off}
    Sleep    200s
    Validate the CQI_MCS_PMQAP_64Qam Counter With Feature Disable

    Stops Btslogs from Local machine    ${BTSLOG}
	detach ue via ultracaller


*** Keywords ***
FTP_dl_data_transfer_with_attenuation
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
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=60db
    Sleep    10 s
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=0db
    Sleep    10 s
#	attenuator.disconnect    ip_addr=${Attenuator_ip_addr}

Validate the Counter 4Tx after UE attach
#* [>200000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55386C00034    100000-800000      PDSCH_4TX_RI_01_PMQAP
    ...     M55386C00035    500-10000        PDSCH_4TX_RI_02_PMQAP
    ...     local_moid=${Counter_MOC_PATH_256}
    ...     file_path=${pm_counter_file}

Validate the Counter 2Tx DLMIMO after UE attach
#* [>400000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55386C00032    1000-1000000    PDSCH_2TX_RI_01_PMQAP
    ...     M55386C00033     0-50000     PDSCH_2TX_RI_02_PMQAP
    ...     local_moid=${Counter_MOC_PATH_64}
    ...     file_path=${pm_counter_file}

Validate the Counter BLER Residual after UE attach
#* [>1000 & 2000000 value given based on PDU pegging]*
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55386C00031    100000-500000     PDSCH_ANY_SUCC_DRB_PMQAP
    ...     M55386C00030    0-1000       PDSCH_LAST_FAIL_DRB_PMQAP
    ...     local_moid=${Counter_MOC_PATH_256}
    ...     file_path=${pm_counter_file}
    ${PDSCH_ANY_SUCC_DRB_PMQAP_value}=     Get Latest Pm Counter Value
	...      counter_id=M55386C00031
	...      local_moid=${Counter_MOC_PATH_256}
	...     filepath=${pm_counter_file}
	${PDSCH_LAST_FAIL_DRB_PMQAP_value}=    Get Latest Pm Counter Value    counter_id=M55386C00030    local_moid=${Counter_MOC_PATH_256}
	...     filepath=${pm_counter_file}
	${result}    Evaluate    ${PDSCH_LAST_FAIL_DRB_PMQAP_value}/(${PDSCH_LAST_FAIL_DRB_PMQAP_value}+${PDSCH_ANY_SUCC_DRB_PMQAP_value})

Validate the CQI_PMQAP_256Qam Counter after UE attach
#* [>1000 & 10000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55386C00025    0-10000      WB_CQI_256TBL_CQI_BIN03_PMQAP
    ...     M55386C00026    0-10000      WB_CQI_256TBL_CQI_BIN04_PMQAP
    ...     local_moid=${Counter_MOC_PATH_256}
    ...     file_path=${pm_counter_file}

Validate the MCS_PMQAP_256Qam Counter after UE attach
#* [>1000 & 10000 value given based on PDU pegging]*
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
	...     M55386C00027    1000-50000      WB_CQI_256TBL_CQI_BIN05_PMQAP
	...     M55386C00058    100-100000      PDSCH_CP_INRE_BIN0_256TBL_PMQ
	...     M55386C00059    100-100000       PDSCH_CP_INRE_BIN1_256TBL_PMQ
	...     M55386C00060    1000-100000      PDSCH_CP_INRE_BIN2_256TBL_PMQ
	...     M55386C00061    1000-500000      PDSCH_CP_INRE_BIN3_256TBL_PMQ
	...     M55386C00062    1000-100000      PDSCH_CP_INRE_BIN4_256TBL_PMQ
    ...     local_moid=${Counter_MOC_PATH_256}
	...     file_path=${pm_counter_file}

Validate the MCS_PMQAP_64Qam Counter after UE attach
#* [>1000 & 5000 value given based on PDU pegging]*
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
	...     M55386C00022    0-10000        WB_CQI_64TBL_CQI_BIN05_PMQAP
	...     M55386C00053    0-10000        PDSCH_CP_INRE_BIN0_64TBL_PMQ
	...     M55386C00054    0-10000        PDSCH_CP_INRE_BIN1_64TBL_PMQ
	...     M55386C00055    0-10000        PDSCH_CP_INRE_BIN2_64TBL_PMQ
	...     M55386C00056    0-500000        PDSCH_CP_INRE_BIN3_64TBL_PMQ
	...     M55386C00057    0-10000        PDSCH_CP_INRE_BIN4_64TBL_PMQ
    ...     local_moid=${Counter_MOC_PATH_64}
	...     file_path=${pm_counter_file}

Validate the CQI_MCS_PMQAP_64Qam Counter With Data Disable
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55386C00032    0-50      PDSCH_2TX_RI_01_PMQAP
    ...     M55386C00033    0-50      PDSCH_2TX_RI_02_PMQAP
    ...     M55386C00022    0-50      WB_CQI_64TBL_CQI_BIN05_PMQAP
    ...     M55386C00053    0-50      PDSCH_CP_INRE_BIN0_64TBL_PMQ
    ...     M55386C00054    0-50      PDSCH_CP_INRE_BIN1_64TBL_PMQ
    ...     M55386C00055    0-50      PDSCH_CP_INRE_BIN2_64TBL_PMQ
    ...     M55386C00056    0-50      PDSCH_CP_INRE_BIN3_64TBL_PMQ
    ...     M55386C00057    0-50      PDSCH_CP_INRE_BIN4_64TBL_PMQ
    ...     local_moid=${Counter_MOC_PATH_64}
    ...     file_path=${pm_counter_file}

Validate the CQI_MCS_PMQAP_64Qam Counter With Feature Disable
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55386C00032    0      PDSCH_2TX_RI_01_PMQAP
    ...     M55386C00033    0      PDSCH_2TX_RI_02_PMQAP
	...     M55386C00022    0      WB_CQI_64TBL_CQI_BIN05_PMQAP
	...     M55386C00053    0      PDSCH_CP_INRE_BIN0_64TBL_PMQ
	...     M55386C00054    0      PDSCH_CP_INRE_BIN1_64TBL_PMQ
	...     M55386C00055    0      PDSCH_CP_INRE_BIN2_64TBL_PMQ
	...     M55386C00056    0      PDSCH_CP_INRE_BIN3_64TBL_PMQ
	...     M55386C00057    0      PDSCH_CP_INRE_BIN4_64TBL_PMQ
	...     local_moid=${Counter_MOC_PATH_64}
    ...     file_path=${pm_counter_file}

