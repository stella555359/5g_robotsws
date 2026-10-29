*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../Resources/Classical/RRM_File_Operation.robot
Resource          ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource          ../../Resources/Classical/RRM_MultiBTS_Log_Resource.robot
# Resource          ../../Resources/Classical/python/plib2/pet_main_sg06.robot
# Resource           ../../Resources/Classical/python/plib2/pet_main.robot
Library           ../../Resources/Classical/python/plib2/pet_robot.py
Library           ../../Resources/Classical/python/plib2/pkw_ap.py
Library           ../Resources/python/traffic_model_schedule.py
Library           traffic_model_schedule.TrafficModel    WITH NAME    traffic_model
Library           traffic_model_schedule.BenchmarkKpi    WITH NAME    BK
Resource          feature_resource.robot
Resource          iperf_resource.robot
Resource          pa_pb_resource.robot
Resource          ute_case_common_resource.robot
Resource          upgrade_resource.robot
Resource          airphone_resource.robot
Resource          log_resource.robot
Library           python/csv_analysis.py    WITH NAME    csv_analysis
Library           python/rbg_order.py    WITH NAME    rbg_order
Library           python/netcore_operation.py
Library           netcore_operation.CoreNetApi    WITH NAME    core_net
Library           taf.alias.store    WITH NAME    alias_store
Library           ta_uexgate
Library           ta_messaging

*** Variables ***
${Current_Trunk_Release}    SBTS26R3
${Last_Trunk_Release}    SBTS26R2
${Current_Trunk_Branchout_Sw}    ENB_9999_260227_000002
&{fault_61524}             faultId=${61524}    #SSH enabled
&{fault_61649}             faultId=${61649}    #LMP access via port xx
&{fault_61652}             faultId=${61652}    #R&D Service Port enabled
&{fault_4654}              faultId=${4654}    #Ethernet port security is disabled
&{fault_4655}              faultId=${4655}    #Service account root access is enabled
&{fault_4459}              faultId=${4459}    #User Account has Default Password
&{fault_4657}              faultId=${4657}    #Unsupported SFP
&{fault_4389}              faultId=${4389}    #OTDOA PRS transmission disabled
&{fault_23}                faultId=${23}      #SW incompatible
&{fault_4681}              faultId=${4681}    #Sanity Check Error
&{fault_4701}              faultId=${4701}
# &{fault_6450}              faultId=${6450}    #Diagnostic Files collected
@{uuf_allowed_previous}    &{fault_61652}    &{fault_61524}    &{fault_61649}    &{fault_23}
...                        &{fault_4654}    &{fault_4655}    &{fault_4459}    &{fault_4657}    &{fault_4389}
@{uuf_allowed_current}     &{fault_61652}    &{fault_61524}    &{fault_61649}
...                        &{fault_4654}    &{fault_4655}    &{fault_4459}    &{fault_4657}    &{fault_4389}
${SCF_DIR_PATH}         ${CURDIR}/../../../../../../commissionings/RRM/SRAN_5G
${SWCONFIG_DIR_PATH}    ${CURDIR}/../../../../../../commissionings/RRM/SRAN_5G
@{ALLOWED_FAULT}                   &{fault_61652}    &{fault_61524}    &{fault_61649}    &{fault_4654}    &{fault_4592}
...                                &{fault_4655}     &{fault_4681}     &{fault_4701}
${VM_IP_EXP_STRING}    (10\\.(25[0-5]\\.|2[0-4]\\d\\.|1\\d+\\.|[0-9]\\d?\\.){2}(25[0-5]|2[0-4]\\d|1\\d{2}|[1-9]?\\d))
###############for common check point#########
&{Upgrade_Case_Info}    Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
...                     Case_Tag=Upgrade
&{Feature_File_INFO}
...    Upgrade=&{Upgrade_Case_Info}
&{Topology_RFS}    CLOUD_5G_CLASSICAL_ANDRIOD_ASIBL_ABIO_ABIN_AHLOA_AHFIB-ASIKR_ABIL2_AZHL=${True}
...    CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBR_ABIO_ABIL2_AEHC_AHFIB_AHLOA_AHFIG=${True}
####### PA set############
&{HBTE_VALUE}                  max=${93}    min=${0}
&{TopYoung_VALUE}              max=${127}    min=${0}
&{RadioRack_VALUE}             max=${110}    min=${0}
&{PA_Vendor_Value}             HBTE=&{HBTE_VALUE}
...                            TOPYOUNG=&{TopYoung_VALUE}
...                            RADIORACK=&{RadioRack_VALUE}
###############for common check point#########
${ENDC_CHECKPOINT}          X2AP_SGNB_RECONFIGURATION_COMPLETE
###############for dcap#########
&{DCAP_Server}     host=10.69.67.143
...                username=utfuser
...                password=utfadmin!
...                port=443
&{Emil_Server}     host=10.56.111.172
...                username=PzHZ2
...                password=Nokia123!
&{Emil_Config}     4g_log_postfix=.emil
...                5g_log_postfix=.5gm
...                4g_profile_path=4G
...                5g_profile_path=5G
${DEBUG_MODE}      ${False}

