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
TC.CB008009_A_1_DL_Throughput_Distribution_counters_Non_Profile
    [Documentation]  CU cpounter:
    ...  M55350C20002(DL_PDCP_UE_TPUT_BIN1)
    ...  M55350C20021(DL_PDCP_UE_TPUT_BIN20)

    ...  M55352C03001(DL_PDCP_UE_TPUT_BIN1_PMQAP)
    ...  M55352C03020(DL_PDCP_UE_TPUT_BIN20_PMQAP)

    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
      ...    modified_cfgfile_CU=${LOG_PATH}/8009_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU_GoldenSCF}
      ...    modified_cfgfile_DU=${LOG_PATH}/8009_DU_SCF.xml    ResourceFolder=${CURDIR}
      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU_8009     mo_to_add_CU=MOs_TO_ADD_CU_8009
      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU_8009     list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU_8009
      ...    list_to_add_CU=LIST_TO_ADD_CU_8009
      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU_8009     mo_to_add_DU=MOs_TO_ADD_DU_8009
      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU_8009     list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY_DU_8009
      ...    list_to_add_DU=LIST_TO_ADD_DU_8009
    KW.Cloud Commission And Check On Air     CU_SCF=${LOG_PATH}/8009_CU_SCF.xml    DU_SCF=${LOG_PATH}/8009_DU_SCF.xml

    KW.Adjust PA To Default Value For CB008009

    Run Keyword And Continue On Failure    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${1}    power_reset=True
    Run Keyword And Continue On Failure    power_ue.UE Attach    ue_type=${UE_TYPE}  ue_index=${1}    power_reset=True
    sleep     5s
    Run Keyword And Continue On Failure    power_ue.Start traffic     ue_index=${1}     ue_type=${UE_TYPE}    direction=dl
    ...    throughput=100MKbits/sec    duration=60    apn_address=${APN}    ue_mode=SA
    sleep    90s
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${UE_TYPE}    ue_index=${1}     direction=dl
    ...     apn_address=${APN}    ue_mode=SA
    Run Keyword And Ignore Error    power_ue.UE Detach      ue_type=${UE_TYPE}    ue_index=${1}    power_reset=True

    Run Keyword And Continue On Failure     wait until keyword succeeds   16min   2min    KW.Check vCU PM Counter Range Result
    ...     measurement_id=55350     dist_name=${8009_Non_Profile_DL_dist_name}  counter_id=M55350C20017  expected_value1=50  expected_value2=70

    Run Keyword And Continue On Failure     wait until keyword succeeds   16min   2min    KW.Check vCU PM Counter Range Result
    ...     measurement_id=55352     dist_name=${8009_NRPMQAP_DL_dist_name}  counter_id=M55352C03016  expected_value1=50  expected_value2=70



TC.CB008009_B_2_UL_Throughput_Distribution_counters_PMQAP_Profile
    [Documentation]  DU cpounter:
    ...  M55349C06000(UL_RLC_UE_TPUT_BIN1)
    ...  M55349C06019(UL_RLC_UE_TPUT_BIN20)

    ...  M55353C01002(UL_RLC_UE_TPUT_BIN1_PMQAP)
    ...  M55353C01021(UL_RLC_UE_TPUT_BIN20_PMQAP)

    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
      ...    modified_cfgfile_CU=${LOG_PATH}/8009_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU_GoldenSCF}
      ...    modified_cfgfile_DU=${LOG_PATH}/8009_DU_SCF.xml    ResourceFolder=${CURDIR}
      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU_8009     mo_to_add_CU=MOs_TO_ADD_CU_8009
      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU_8009     list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU_8009
      ...    list_to_add_CU=LIST_TO_ADD_CU_8009
      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU_8009     mo_to_add_DU=MOs_TO_ADD_DU_8009
      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU_8009     list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY_DU_8009
      ...    list_to_add_DU=LIST_TO_ADD_DU_8009
    KW.Cloud Commission And Check On Air     CU_SCF=${LOG_PATH}/8009_CU_SCF.xml    DU_SCF=${LOG_PATH}/8009_DU_SCF.xml

    KW.Adjust PA To Default Value For CB008009

    Run Keyword And Continue On Failure    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${1}    power_reset=True
    Run Keyword And Continue On Failure    power_ue.UE Attach    ue_type=${UE_TYPE}  ue_index=${1}    power_reset=True
    sleep     5s
    Run Keyword And Continue On Failure    power_ue.Start traffic     ue_index=${1}     ue_type=${UE_TYPE}    direction=ul
    ...    throughput=50MKbits/sec    duration=60    apn_address=${APN}    ue_mode=SA
    sleep    90s
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${UE_TYPE}    ue_index=${1}    direction=ul
    ...     apn_address=${APN}    ue_mode=SA
    Run Keyword And Ignore Error    power_ue.UE Detach      ue_type=${UE_TYPE}    ue_index=${1}    power_reset=True

    Run Keyword And Continue On Failure     wait until keyword succeeds   16min   2min    KW.Check vDU PM Counter Range Result
    ...   counter_id=M55349C06015    dist_name=${8009_Non_Profile_UL_dist_name}   vdu_index=0    expected_value1=50     expected_value2=70

    Run Keyword And Continue On Failure     wait until keyword succeeds   16min   2min    KW.Check vDU PM Counter Range Result
    ...   counter_id=M55353C01017    dist_name=${8009_NRPMQAP_UL_dist_name}   vdu_index=0    expected_value1=50     expected_value2=70


####Case Level Keywords#####
Setup Suite for CB008009
    log to console     Suite start
    Create Logs Folder For Test Case
    Import Variables        ${CFGFILE_PATH}TLConfiguration.py
    set suite variable     ${UECFG_SA}         ${TLCommonConfig_SAUE['MultiUECFG']}
    set suite variable     ${UECFG_NSA}        ${TLCommonConfig_NSAUE['MultiUECFG']}
    set suite variable     ${eNBRU_PA_Ports}       ${CASE_INPUT_CB008009['CB008009']['eNBRU_PA_Ports']}
    set suite variable     ${5GRU1_PA_Ports}       ${CASE_INPUT_CB008009['CB008009']['5GRU1_PA_Ports']}
    set suite variable     ${5GRU2_PA_Ports}       ${CASE_INPUT_CB008009['CB008009']['5GRU2_PA_Ports']}
    set suite variable     ${8009_Non_Profile_DL_dist_name}       ${CASE_INPUT_CB008009['CB008009']['8009_Non_Profile_DL_dist_name']}
    set suite variable     ${8009_NRPMQAP_DL_dist_name}       ${CASE_INPUT_CB008009['CB008009']['8009_NRPMQAP_DL_dist_name']}
    set suite variable     ${8009_Non_Profile_UL_dist_name}       ${CASE_INPUT_CB008009['CB008009']['8009_Non_Profile_UL_dist_name']}
    set suite variable     ${8009_NRPMQAP_UL_dist_name}       ${CASE_INPUT_CB008009['CB008009']['8009_NRPMQAP_UL_dist_name']}
    set suite variable     ${MRBTS_ID}        ${CASE_INPUT_CB008009['CB008009']['MRBTS_ID']}
    set suite variable     ${NRBTS_ID}        ${CASE_INPUT_CB008009['CB008009']['NRBTS_ID']}
    set suite variable     ${APN}        ${CASE_INPUT_CB008009['CB008009']['APN']}
    Conn.ResetCache

Teardown Suite for CB008009
    log to console     Suite teardown

Setup case for CB008009
    log to console     Case Start

Teardown case for CB008009
    Run Keyword And Ignore Error    run    command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Conn.ResetCache
    log to console     Case teardown


KW.Adjust PA To Default Value For CB008009
    [Arguments]
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${eNBRU_PA_Ports}
    ...    value=${CASE_INPUT_CB008009['CB008009']['PA_Value_1']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for eNB default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008009['CB008009']['PA_Value_1']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU1 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008009['CB008009']['PA_Value_2']}   attenuator=${PA2_INFO}
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