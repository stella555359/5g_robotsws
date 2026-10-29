*** Settings ***
Documentation    This file contains variable which can be used by tester during test suite preparation.

*** Variables ***
#This variable set max time to reach OnAir state for tested configuration. This variable is use only during test setup.
${SETUP_CHECK_ONAIR_STATE_TIMEOUT}=  200

#This variable set max time to check alarm 4001 in software check and update procedure.
# This alarm can be visible when new hardawre is detected and updated during setup.
${SETUP_CHECK_4001_ALARM_AFTER_SWUPDATE_TIMEOUT}=  120

#This is default start up time for tested configuration. User can checnge this variable on suite or testcase level.
${CONFIGURATION_STARTUP_TIMEOUT}=  360

#This is default start up time for tested configuration. User can checnge this variable on suite or testcase level.
${CONFIGURATION_POWER_STARTUP_TIMEOUT}=  360

#This is default timeout in tested configuration for sw update procedure.
#User can checnge this variable on suite or testcase level.
${CONFIGURATION_SWUPDATE_TIMEOUT}=  1200

#This is default timeout during reset configuration in tested configuration.
#User can checnge this variable on suite or testcase level.
${RESET_CONFIGURATION_STARTUP_TIMEOUT}=  720

#This is default timeout during reset configuration in tested configuration.
#User can checnge this variable on suite or testcase level.
${HARDWARE_DETECTION_TIME}=  500

#Default place where topology-configs for current reservation is keep.
${GLOBAL_TOPOLOGY_CONFIGS_REPOSITORY}=  /home/ute/testline_init_results/execution/configs/topology_configs

#variable defines custom additional alarm list, detail decription is inside FM_Faults.robot file.
${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=  ${EMPTY}

# This variable provides information of primary BTS IP in live mode, in case BTS LMP port
# with primary node is available via remote VM, IP address as string should be provided for remote VM
${CUSTOM_LIVE_MODE_PRIMARY_NODE_IP}=  ${EMPTY}

# This variable provides information of primary BTS IP in mplane mode.
${CUSTOM_MPLANE_MODE_PRIMARY_NODE_IP}=  ${EMPTY}

${CUSTOM_TEMP_DIR}=  /tmp

&{BRANCH_UPGRADE_BUILD}=
...  SBTS23R1=SBTS22R4_ENB_0000_001217_000000
...  SBTS23R2=SBTS23R1_ENB_0000_001766_000000
...  SBTS23R3=SBTS23R2_ENB_0000_001112_000000
...  SBTS23R4=SBTS23R3_ENB_0000_000496_000012
...  SBTS24R1=SBTS23R4_ENB_0000_000861_000030
...  SBTS24R2=SBTS24R1_ENB_0000_001152_000000
...  SBTS24R3=SBTS24R2_ENB_0000_000346_000000
...  SBTS25R1=SBTS24R3_ENB_0000_000017_000000
...  SBTS25R2=SBTS25R1_ENB_0000_000756_000000
...  SBTS25R3=SBTS25R2_ENB_0000_000025_000000

@{global_common_fault_list}=
...    faultId=61652, severity=Minor
...    faultId=61524, severity=Minor
...    faultId=61649, severity=Minor
...    faultId=4592, severity=Warning
...    faultId=4655, severity=Minor
...    faultId=4654, severity=Minor
...    faultId=4681, severity=Minor
...    faultId=4681, severity=Major
...    faultId=4681, severity=Warning
...    faultId=7300, severity=Major
...    faultId=6327, severity=Major
...    faultId=7319, severity=Major
...    faultId=4590, severity=Warning

&{GLOBAL_ALLOWED_FAULTS}=   common=@{global_common_fault_list}

@{global_setup_fault_list}=
...    faultId=61652, severity=Minor
...    faultId=61524, severity=Minor
...    faultId=61649, severity=Minor
...    faultId=4592, severity=Warning
...    faultId=4655, severity=Minor
...    faultId=4654, severity=Minor
...    faultId=4681, severity=Minor
...    faultId=4681, severity=Major
...    faultId=4681, severity=Warning
...    faultId=7300, severity=Major
...    faultId=6327, severity=Major
...    faultId=7319, severity=Major
...    faultId=4590, severity=Warning
...    faultId=4001
...    faultId=2002
...    faultId=10
...    faultId=4309
...    faultId=23
...    faultId=1811, severity=Warning

&{GLOBAL_SETUP_ALLOWED_FAULTS}=   common=@{global_setup_fault_list}

${SKIP_TRUCK_ROLL}    ${False}       # to disable Truck And Roll feature set this flag to True

@{FID4589_RELEASE_STRING_LIST}=
...    MAA
...    AR0
...    5GRU5.0
...    RRH-ORAN

@{FID4589_RELEASE_LESS_THAN_5_1_STRING_LIST}=
...    FJ0

@{FID1815_ALLOWED_SEVERITY_LIST}=
...  Minor
...  Major

@{FID1815_ALLOWED_HW_LIST}=
...  ABIA AirScale Capacity
...  ABIN AirScale Capacity
...  ABIO AirScale Capacity
...  ABIL AirScale Capacity
...  ABIP AirScale Capacity
...  ABIQ AirScale Capacity
...  ASOE AirScale Core
...  ASOH AirScale Core
...  ASIA
...  ASIB
...  ASIK
...  ASIL
...  AAFB
...  AAFIA
...  AAIB
...  AAIC
...  AEHE
...  AENB
...  AEQC
...  AEQE
...  AEQH
...  AEQI
...  AEQJ
...  AEQK
...  AEQM
...  AEQP
...  AEQQ
...  AEQV
...  AEQW
...  AEQY
...  AEQZ
...  AHAA
...  AHAB
...  AHBB
...  AHBC
...  AHBCA
...  AHBCB
...  AHBCC
...  AHBCD
...  AHBOA
...  AHCA
...  AHCA-B
...  AHCC
...  AHCE
...  AHCF
...  AHCG
...  AHCI
...  AHDA
...  AHDB
...  AHDC
...  AHEA
...  AHEB
...  AHEC
...  AHED
...  AHEE
...  AHEGA
...  AHEGB
...  AHEGC
...  AHEGG
...  AHEGHA
...  AHEGF
...  AHEGI
...  AHEGJ
...  AHEH
...  AHFB
...  AHFIA
...  AHFIB
...  AHFIC
...  AHFIE
...  AHFIG
...  AHFIHA
...  AHFII
...  AHGA
...  AHGC
...  AHGD
...  AHGE
...  AHGF
...  AHHA
...  AHHB
...  AHIB
...  AHLB
...  AHLBA
...  AHLBBA
...  AHLJA
...  AHLOA
...  AHLOB
...  AHMA
...  AHNA
...  AHOA
...  AHPB
...  AHPC
...  AHPCA
...  AHPCB
...  AHPCDB
...  AHPD
...  AHPDA
...  AHPDB
...  AHPDC
...  AHPE
...  AHPF
...  AHPG
...  AHPH
...  AHPJ
...  AHPL
...  AHPMDA
...  AHPMDB
...  AHPMDD
...  AHPMDG
...  AHPMDH
...  AHPMDI
...  AHPMDJ
...  AHRA
...  AHSA
...  AHSB
...  ANEGA
...  ARCA
...  ARDA
...  ARDB
...  AREA
...  ARGA
...  ARHA
...  ARMA
...  ARPA
...  ARPB
...  AWHHD
...  AWHHF
...  AWHHG
...  AWHHI
...  AWHKA
...  AWHKB
...  AWHQE
...  AWHQF
...  AWHQM
...  AWHQV
...  AWHTA
...  AWMFIA
...  AZFGA
...  AZHA
...  AZHE
...  AZHL
...  AZHM
...  AZHN
...  AZNA
...  AZNB
...  AZNC
...  AZND
...  AZNE
...  AZQC
...  AZQD
...  AZQE
...  AZQF
...  AZQI
...  AZQJ
...  AZQO
...  AZQR
...  AZQW
...  AZRA
...  AZRB
...  AZRC
...  AZTA

${FID1815_TIMEOUT}=  10

@{EXPECTED_LINK_BREAK_LIST}

#=============Fault Signature=================
${FID1981_FAULT_SIGNATURE_SCHEME}=  {
...                   "fixed_value": {
...                    	"category": "SW_FAILURE",
...                    	"scope": "RFM",
...                    	"minor": "-",
...                    	"info": "-",
...                    	"rfmCpri": "-",
...                    	"rfmFpga": "-",
...                    	"rfmGpp": "-"
...                   },
...                   "dynamic_value": [
...                   	"component",
...                     "date",
...                   	"loadName"
...                   ],
...                   "alternative_value": {
...                   },
...                   "not_empty_value": [
...                     "extraInfo"
...                   ]
...                  }
@{FID_1981_ALARM_INFO}=  7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
...                      7115 BASE STATION INFORMATION
...                      7116 BASE STATION SERVICE PROBLEM
...                      7652 BASE STATION NOTIFICATION
...                      7653 CELL FAULTY
...                      7654 CELL OPERATION DEGRADED
${FID_1981_WARNING_TIMEOUT}=  900
${FID_1981_CRITICAL_TIMEOUT}=  360

${FID1911_FAULT_SIGNATURE_SCHEME}=  {
...                   "fixed_value": {
...                    	"category": "SW_FAILURE",
...                     "info": "-",
...                     "minor": "-",
...                     "rfmCpri": "-",
...                     "rfmFpga": "-",
...                     "rfmGpp": "-",
...                     "scope": "RFM"
...                   },
...                   "dynamic_value": [
...                   	"component",
...                   	"loadName",
...                   	"date",
...                     "resetCounter"
...                   ],
...                   "alternative_value": {
...                   },
...                   "not_empty_value": [
...                     "extraInfo"
...                   ]
...                 }
@{FID_1911_ALARM_INFO}=  7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
...                      7115 BASE STATION INFORMATION
...                      7116 BASE STATION SERVICE PROBLEM
...                      7652 BASE STATION NOTIFICATION
...                      7653 CELL FAULTY
...                      7654 CELL OPERATION DEGRADED
...                      7655 CELL NOTIFICATION

${FID_1911_TIMEOUT}=  1200

${FID4590_FAULT_SIGNATURE_SCHEME}=   {
...                   "fixed_value": {
...                     "extraInfo": "-",
...                     "minor": "RFM_GPP",
...                     "rfmCpri": "-",
...                     "rfmFpga": "-",
...                     "scope": "RFM"
...                   },
...                   "dynamic_value": [
...                   	"component",
...                   	"loadName",
...                   	"date",
...                     "resetCounter"
...                   ],
...                   "alternative_value": {
...                   	"category": "SW_FAILURE|UNKNOWN"
...                   },
...                   "not_empty_value": [
...                     "info",
...                     "rfmGpp"
...                   ]
...                 }
@{FID_4590_ALARM_INFO}=  7115 BASE STATION INFORMATION
...                      7652 BASE STATION NOTIFICATION

${FID1907_FAULT_SIGNATURE_SCHEME}=  {
...                   "fixed_value": {
...                    	"category": "SW_FAILURE",
...                     "info": "-",
...                     "minor": "-",
...                     "rfmCpri": "-",
...                     "rfmFpga": "-",
...                     "rfmGpp": "-",
...                     "scope": "RFM"
...                   },
...                   "dynamic_value": [
...                   	"component",
...                   	"loadName",
...                   	"date",
...                     "resetCounter"
...                   ],
...                   "alternative_value": {
...                   },
...                   "not_empty_value": [
...                     "extraInfo"
...                   ]
...                 }
${FID_1907_TIMEOUT}=  1200
@{FID_1907_ALARM_INFO}=  7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
...                      7115 BASE STATION INFORMATION
...                      7116 BASE STATION SERVICE PROBLEM
...                      7652 BASE STATION NOTIFICATION
...                      7653 CELL FAULTY
...                      7654 CELL OPERATION DEGRADED
...                      7655 CELL NOTIFICATION

@{FID_1901_ALARM_INFO}=  7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
...                      7111 BASE STATION SOFTWARE MANAGEMENT PROBLEM
...                      7115 BASE STATION INFORMATION
...                      7652 BASE STATION NOTIFICATION
...                      7653 CELL FAULTY
...                      7654 CELL OPERATION DEGRADED
${FID1901_FAULT_SIGNATURE_SCHEME}=  {
...                   "fixed_value": {
...                    	"category": "SW_FAILURE",
...                     "info": "-",
...                     "minor": "-",
...                     "rfmCpri": "-",
...                     "rfmFpga": "-",
...                     "rfmGpp": "-",
...                     "scope": "RFM"
...                   },
...                   "dynamic_value": [
...                   	"component",
...                   	"loadName",
...                   	"date",
...                     "resetCounter"
...                   ],
...                   "alternative_value": {
...                   },
...                   "not_empty_value": [
...                     "extraInfo"
...                   ]
...                 }
${CRITICAL_FAULT_SIGNATURE_SCHEME}=  {
...                   "fixed_value": {
...                     "category": "-",
...                     "scope": "-",
...                     "minor": "-",
...                     "info": "-",
...                     "extraInfo": "-",
...                     "rfmCpri": "-",
...                     "rfmFpga": "-",
...                     "rfmGpp": "-",
...                     "resetCounter": "-",
...                     "component": "-",
...                     "date": "-",
...                     "loadName": "-"
...                   },
...                   "dynamic_value": [
...                   ],
...                   "alternative_value": {
...                   },
...                   "not_empty_value": [
...                   ]
...                 }
${FID_1901_TIMEOUT}=  540

${FID4589_FAULT_SIGNATURE_SCHEME}=   {
...                   "fixed_value": {
...                    	"category": "POWER_OFF",
...                    	"scope": "RFM",
...                    	"minor": "-",
...                    	"extraInfo": "-",
...                    	"info": "-",
...                    	"rfmCpri": "-",
...                    	"rfmFpga": "-",
...                    	"rfmGpp": "-"
...                   },
...                   "dynamic_value": [
...                   	"component",
...                   	"loadName",
...                   	"date",
...                   	"resetCounter"
...                   ],
...                   "alternative_value": {
...                   },
...                 "not_empty_value": [
...                  ]
...                 }

@{FID_4589_ALARM_INFO}=  7115 BASE STATION INFORMATION
...                      7652 BASE STATION NOTIFICATION

${FID_4589_APPEAR_TIMEOUT}=  5
${FID_4589_DISAPPEAR_TIMEOUT}=  40

@{RMODS_Supporting_Deep_Sleep}=
...  AHBB  AHBC  AHCA  AHCC  AHCE  AHCF  AHEB  AHEH  AHEJ  AHFB  AHGB  AHGD  AHGE  AHHA  AHHB  AHIB  AHNA  AHPB  AHGF  AHSB  # FRMr5.1_1_4T4R
...  AHBCA  AHBCB  AHBCC  AHBCD  AHBOA  AHEGB  AHEGC  AHEGF  AHEGJ  AHLBA  AHLBBA  AHLOA  AHPCA  AHPCB  AHPDA  AHPMDH  # FRMr5.1a_4T4R
...  AHCG  AHCH  AHDA  AHDB  AHED  AHMA  AHPC  AHPE  AHPG  AHPJ  # FRMr5.1_1_2T4R
...  AHEGA  AHEGI  AHPCDB  # FRMr5.1_2T4R
...  AHEGG  AHEGH  AHEGK  AHLOB  AHPMDG  AWMFIA  # FRMr6.2_4T4R
...  AHEGHA  AHEGSA  AHPMDK  AHPDB  AHPDC  AHPDD   # FRMr6.2a_4T4R
...  AHPMDA  AHPMDB  AHPMDD  AHPMDI  AHPMDJ  # FRMr5.1_4T4R
...  AHSA  # FRMr5.1_1_2T0R
...  AKFA  AKHD  AKHM  AKNA  AKNB  AKQA  AKQI  AKQJ  AKQW  AKQZ  # cMAAr6.2_8T8R_eCPRI
...  AQHA  AQHB  AQHC  AQQA  AQQC  AQQJ  AQQQ  AQQV  AQQY    # cMAAr6.2_32T32R
...  AQNA  AQQE  AQQK  AQQL  AQQN  AQQS  AQQT  # cMAAr6.2_64T64R
...  AQQF  # cMAAr6.2a_32T32R
...  AQQQA  # cMAAr6.2b_64T64R
...  ARCA  ARDA  ARDB  AREA  ARGA  ARHA  ARMA  ARPA  ARPB  # FRMr5.1_1_6T6R
...  ARDC  AREC  ARGB  # FRMr6.2_6T6R
...  AVHA  AVQE  AVQG  AVQL  AVQQA  AVQQB  AVQQC    # cMAAr7.1_64T64R
...  AVHQA  AVHQB  AVNB  AVQA  AVQC  AVQD  AVQF  AVQJ  AVQQ  AVQY  # cMAAr7.1_32T32R
...  AZHL  AZHM  AZHN  AZQI  AZQJ  AZQO  AZQP  AZQS  AZQU  AZQW  AZTA  # cMAAr6.1_8T8R
...  AEQB  AEQE  AEQE_I  AEQI  AEQK  AEQK_I  AEQM  AEQP  AEQP_I  AEQU  # cMAAr6.1_64T64R_eCPRI
...  AENB  AEQC  AEQQ  AEQQ_I  AEQV  AEQW  AEQY  AEQZ  # cMAAr6.1_32T32R_eCPRI
...  AHPL
