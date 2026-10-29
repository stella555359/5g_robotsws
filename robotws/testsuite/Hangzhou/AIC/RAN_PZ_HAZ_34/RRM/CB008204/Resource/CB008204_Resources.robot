*** Settings ***
Documentation     author:yajie.li
...               Group: HGZ_SG1
...               contact: yajie.li@nokia-sbell.com

Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot

#Resource          ../../../../AIC/RAN_PZ_HAZ_34/Resources/aic_common_resources.robot
Resource       ../../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource       ../../CB007199_ABG/Resource/CB007199_ABG_Resources.robot
Resource       taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library        taf.transport.ssh    WITH NAME    csn
Library        Process


*** Variables ***
${CFGFILE_PATH}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/

${UE_TYPE}                   ${tl.ues[1].capabilities[-1]}
${IMSI1}                     ${tl.ues[1].imsi}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${ENB_WEBUI_IP}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENBWEBUI_URL}             https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${PA1_INFO}                  ${tl.attenuators[0]}
${PA2_INFO}                  ${tl.attenuators[1]}

##################define these variable for convenient############################

########################END of alias Define#######################################

*** Keywords ***

####Case Level  Keywords#####
TC.CB008204_E_2_L2PS_PMQAP_Counters_to_measure_DL_UL_PRB_utilisation
    [Documentation]  CU cpounter:
    ...  M55352C02001(UL_PDCP_SDU_CU_PMQAP)      ----SA

    ...  DU counter:
    ...  M55353C02001(DL_RLC_SDU_USDAT_DU_PMQAP)  ---SA
    ...  M55363C00004(UL_PRB_UTIL_SLOT_MAX_PMQAP) ---SA   0<counter<=100
    ...  M55353C02003(DL_RLC_SDU_TX_AIR_PMQAP)    ----SA

    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
      ...    modified_cfgfile_CU=${LOG_PATH}/8204_SA_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU_GoldenSCF}
      ...    modified_cfgfile_DU=${LOG_PATH}/8204_SA_DU_SCF.xml    ResourceFolder=${CURDIR}
      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU_8204_E2     mo_to_add_CU=MOs_TO_ADD_CU_8204_E2
      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU_8204_E2     list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU_8204_E2
      ...    list_to_add_CU=LIST_TO_ADD_CU_8204_E2
      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU_8204_E2     mo_to_add_DU=MOs_TO_ADD_DU_8204_E2
      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU_8204_E2     list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY_DU_8204_E2
      ...    list_to_add_DU=LIST_TO_ADD_DU_8204_E2
    KW.Cloud Commission And Check On Air     CU_SCF=${LOG_PATH}/8204_SA_CU_SCF.xml    DU_SCF=${LOG_PATH}/8204_SA_DU_SCF.xml

    KW.Adjust PA To Default Value For CB008204
    MultiUE.L3Call      UECFG=${UECFG_SA}
    Run Keyword And Continue On Failure     wait until keyword succeeds   16min   2min    KW.Check vCU PM Counter Range Result
    ...     measurement_id=55352     dist_name=${8204_SA_dist_name}  counter_id=M55352C02001  expected_value1=50000  expected_value2=250000

    Run Keyword And Continue On Failure     wait until keyword succeeds   16min   2min    KW.Check vDU PM Counter Range Result
    ...   counter_id=M55353C02001    dist_name=${8204_SA_dist_name}   vdu_index=0    expected_value1=50000     expected_value2=250000
    Run Keyword And Continue On Failure     wait until keyword succeeds   16min   2min    KW.Check vDU PM Counter Range Result
    ...   counter_id=M55363C00004    dist_name=${8204_SA_dist_name}   vdu_index=0    expected_value1=0     expected_value2=100
    Run Keyword And Continue On Failure     wait until keyword succeeds   16min   2min    KW.Check vDU PM Counter Range Result
    ...   counter_id=M55353C02003    dist_name=${8204_SA_dist_name}   vdu_index=0    expected_value1=50000     expected_value2=250000


TC.CB008204_C_1_CP_PM_counters_for_monitoring_time_on_each_leg_for_all_ENDC_UEs_with_UL_ data_splitting_Bearer_added_with_UL_on_LTE+NR
    [Documentation]  CU cpounter:
    ...  M55146C00003(ENDC_UL_DATA_TIME_LTENR)   ---NSA
    ...  DU counter:
    ...  M55307C01001(TA_RACH_RESP_BIN_01)  ---SA/NSA

    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
      ...    modified_cfgfile_CU=${LOG_PATH}/8204_NSA_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU_GoldenSCF}
      ...    modified_cfgfile_DU=${LOG_PATH}/8204_NSA_DU_SCF.xml    ResourceFolder=${CURDIR}
      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU_8204_C1     mo_to_add_CU=MOs_TO_ADD_CU_8204_C1
      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU_8204_C1     list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU_8204_C1
      ...    list_to_add_CU=LIST_TO_ADD_CU_8204_C1
      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU_8204_C1     mo_to_add_DU=MOs_TO_ADD_8204_DU_C1
      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU_8204_C1     list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY_DU_8204_C1
      ...    list_to_add_DU=LIST_TO_ADD_8204_DU_C1
    KW.Cloud Commission And Check On Air     CU_SCF=${LOG_PATH}/8204_NSA_CU_SCF.xml    DU_SCF=${LOG_PATH}/8204_NSA_DU_SCF.xml
    KW.Adjust PA To Default Value For CB008204
    Run Keyword And Continue On Failure    Start to collect the X2 log on eNB    x2_log_name=8204_ENB.pcap
    Run Keyword And Continue On Failure    MultiUE.L3Call      UECFG=${UECFG_NSA}
    Run Keyword And Continue On Failure    Stop and download X2 Logs on eNB    x2_log_name=8204_ENB.pcap
    Run Keyword And Continue On Failure     wait until keyword succeeds   16min   2min    KW.Check vCU PM Counter Range Result
    ...     measurement_id=55146     dist_name=${8204_NSA_dist_name}    counter_id=M55146C00003    expected_value1=100000
    ...     expected_value2=500000
    Run Keyword And Continue On Failure     wait until keyword succeeds   16min   2min    KW.Check vDU PM Counter Range Result
    ...   counter_id=M55307C01001    dist_name=${8204_NSA_dist_name}   vdu_index=0    expected_value1=0     expected_value2=5




####Case Level Keywords#####
Setup Suite for CB008204
    log to console     Suite start
    Create Logs Folder For Test Case
    Import Variables        ${CFGFILE_PATH}TLConfiguration.py
    set suite variable     ${UECFG_SA}         ${TLCommonConfig_SAUE['MultiUECFG']}
    set suite variable     ${UECFG_NSA}        ${TLCommonConfig_NSAUE['MultiUECFG']}
    set suite variable     ${eNBRU_PA_Ports}       ${CASE_INPUT_CB008204['CB008204']['eNBRU_PA_Ports']}
    set suite variable     ${5GRU1_PA_Ports}       ${CASE_INPUT_CB008204['CB008204']['5GRU1_PA_Ports']}
    set suite variable     ${5GRU2_PA_Ports}       ${CASE_INPUT_CB008204['CB008204']['5GRU2_PA_Ports']}
    set suite variable     ${8204_SA_dist_name}       ${CASE_INPUT_CB008204['CB008204']['8204_SA_dist_name']}
    set suite variable     ${8204_NSA_dist_name}      ${CASE_INPUT_CB008204['CB008204']['8204_NSA_dist_name']}
    set suite variable     ${MRBTS_ID}        ${CASE_INPUT_CB008204['CB008204']['MRBTS_ID']}
    set suite variable     ${NRBTS_ID}        ${CASE_INPUT_CB008204['CB008204']['NRBTS_ID']}
    Conn.ResetCache

Teardown Suite for CB008204
    log to console     Suite teardown

Setup case for CB008204
    log to console     Case Start

Teardown case for CB008204
    Run Keyword And Ignore Error    run    command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Conn.ResetCache
    log to console     Case teardown


KW.Adjust PA To Default Value For CB008204
    [Arguments]
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${eNBRU_PA_Ports}
    ...    value=${CASE_INPUT_CB008204['CB008204']['PA_Value_1']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for eNB default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008204['CB008204']['PA_Value_1']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU1 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008204['CB008204']['PA_Value_2']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU2 default value.

KW.Check vDU PM Counter Range Result
    [Arguments]    ${counter_id}    ${dist_name}    ${expected_value1}    ${expected_value2}    ${vdu_index}=0    ${how_many}=1
    vDU Rest Login    vdu_index=${vdu_index}
    ${res}=  vdu.get_counter_values    counter_id=${counter_id}   dimension_dn=${dist_name}
    ${num}=  get length   ${res}
    ${expected_counter_values}=   set variable   ${res[${num}-${how_many}:${num}]}
    ${flag}=   set variable   False
    FOR   ${counter_item}   IN   @{res[${num}-${how_many}:${num}]}
          ${flag}=   set variable if  ${expected_value1}<${counter_item['value']}<=${expected_value2}   True
          exit for loop if    ${expected_value1}<${counter_item['value']}<=${expected_value2}
          should be equal    ${flag}  True   Check counter value failed!
    END
    [Teardown]   vDU Rest Logout   vdu_index=${vdu_index}


KW.Check vCU PM Counter Range Result
    [Arguments]   ${measurement_id}     ${dist_name}    ${counter_id}    ${expected_value1}    ${expected_value2}    ${gnb_index}=0    ${how_many}=1
    [Documentation]  For example: M55157C00003, measurement_id is 55157
    ...     CU Login is use cu_version=cuoam_19b, counter check will fail
    CU Login      gnb_index=${gnb_index}    cu_version=cuoam_21b
    ${res}=  cu.get_counter    measurement_id=${measurement_id}     dimension_dist_name=${dist_name}    counter_id=${counter_id}
    ${counter_values}=  set variable    ${res["values"]}
    ${num}=  get length   ${counter_values}
    ${expected_counter_values}=   set variable   ${counter_values[${num}-${how_many}:${num}]}
    ${flag}=   set variable   False
    FOR   ${counter_item}   IN   @{counter_values[${num}-${how_many}:${num}]}
          ${flag}=   set variable if  ${expected_value1}<${counter_item['value']}<=${expected_value2}   True
          exit for loop if    ${expected_value1}<${counter_item['value']}<=${expected_value2}
          should be equal    ${flag}  True   Check counter value failed!
    END
    [Teardown]   CU Logout