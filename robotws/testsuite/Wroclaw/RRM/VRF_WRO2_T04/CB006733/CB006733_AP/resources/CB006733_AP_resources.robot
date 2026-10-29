*** Settings ***
Documentation
...        Maintainers:
...           Lukasz Klimowicz, lukasz.klimowicz@nokia.com
...        Authors:
...           Dawid Chuchnowski, dawid.chuchnowski@nokia.com
...           Marcin Gorczyca, marcin.gorczyca@nokia.com
...           Krzysztof Korczak, krzysztof.korczak@nokia.com
...           Maciej Majewski, maciej.majewski@nokia.com
...           Patryk Wójcik, patryk.wojcik@nokia.com
...        Description:  Common keywords for CB006733

Library     ute_fsmaccess
Library     CB006733_AP_resources.py
Library      Process
Resource    ./collectors.robot

*** Keywords ***
Stop and convert TTI trace collection
    [Arguments]  ${directory_name}=TtiTraces    ${conversion_filter}=None
    ${parent_directory}  Set variable  ${directory_name}
    Set Test Variable  ${parent_directory}
    Stop TTI trace    target_dir=${OUTPUTDIR}/${TESTNAME}/${parent_directory}   delay=2
    Convert TTI trace pcap
    ...  input=${OUTPUTDIR}/${TESTNAME}/${parent_directory}/l2stream3/tcpdump/tcpdump.pcap
    ...  output=${OUTPUTDIR}/${TESTNAME}/${parent_directory}/output
    ...  conversion_filter=${conversion_filter}
    Log to console    Merging mltiple files for dl tti trace
    Run Process    mv    ${OUTPUTDIR}/${TESTNAME}/${parent_directory}/output_dl.0000.csv
    ...    ${OUTPUTDIR}/${TESTNAME}/${parent_directory}/output_dl.csv    shell=yes
    Run Process    tail    -n    +2    ${OUTPUTDIR}/${TESTNAME}/${parent_directory}/output_dl.000[1-3].csv
    ...    >>    ${OUTPUTDIR}/${TESTNAME}/${parent_directory}/output_dl.csv    shell=yes

Set CQI reported by UE
    [Arguments]  ${CQI}  ${UE_ID}  ${PROFILE_ID}=1
    Execute egate command
    ...    cmd=csi_override_testmode_nr profile_id=${PROFILE_ID} cqi=${CQI} cqi_mode=fixed
    Execute egate command
    ...  cmd=ue_testmode_set_nr id=${UE_ID} testmode=csi_override action=activate profile_id=${PROFILE_ID}

Set SINR reported by UE
    [Arguments]  ${UE_ID}=4  ${CELL_ID}=4  ${NOISE_PUSCH}=-1043  ${PATHLOSS}=28
    Execute egate command  cmd=ul_sinr_testmode_nr profile_id=1 pathloss=${PATHLOSS}
    Execute egate command
    ...  cmd=ue_testmode_set_nr id=${UE_ID} testmode=ul_sinr action=activate profile_id=1

    Execute egate command
    ...  cmd=ul_cell_noise_testmode_nr profile_id=1 noise_pusch=${NOISE_PUSCH}
    Execute egate command  cmd=cell_testmode_set_nr gnb=2 cell_id=${CELL_ID} testmode=ul_cell_noise action=activate profile_id=1

Set SINR reported by UE to get good radio condition
    [Arguments]  ${UE_ID}=4  ${CELL_ID}=4  ${NOISE_PUSCH}=-1043  ${PATHLOSS}=28
    Set SINR reported by UE  UE_ID=${UE_ID}  CELL_ID=${CELL_ID}  NOISE_PUSCH=${NOISE_PUSCH}  PATHLOSS=${PATHLOSS}

Set SINR reported by UE to get bad radio condition
    [Arguments]  ${UE_ID}=4  ${CELL_ID}=4  ${NOISE_PUSCH}=-700  ${PATHLOSS}=120
    Set SINR reported by UE  UE_ID=${UE_ID}  CELL_ID=${CELL_ID}  NOISE_PUSCH=${NOISE_PUSCH}  PATHLOSS=${PATHLOSS}

Send A4 measurement report for UE
    [Arguments]  ${PHYCELL_ID}=51  ${NRSRQ_NR}=95  ${NRSRP_NR}=90  ${UE_ID}=4  ${MEAS_ID}=1
    Execute egate command
    ...  cmd=ue_measurement_send_nr event=A4 phycell_id=${PHYCELL_ID} nrsrq_nr=${NRSRQ_NR} nrsrp_nr=${NRSRP_NR} id=${UE_ID} meas_id=${MEAS_ID}
    Sleep  1s  reason=wait for traffic stabilization

Send all A4 measurement reports for UE
    [Arguments]    ${UE_ID}    ${PHYCELL_ID}=51    ${NRSRQ_NR}=95    ${NRSRP_NR}=90
    ${file_path}=    Generate script for all a4 meas ids    ue_id=${UE_ID}    phycell_id=${PHYCELL_ID}
    ...              nrsrp_nr=${NRSRQ_NR}    nrsrp_nr=${NRSRP_NR}
    Execute egate command
    ...  cmd=script file=${file_path}

Start VoNR call
    [Arguments]    ${UE_ID}    ${PDU_ID}    ${QOS_FLOW_ID}=2
    Execute egate command
    ...    cmd=trf_data_start ue=${UE_ID} pdu=${PDU_ID} qfi=${QOS_FLOW_ID} dir=dl rtp_codec=amr_12_2
    Execute egate command
    ...    cmd=trf_data_start ue=${UE_ID} pdu=${PDU_ID} qfi=${QOS_FLOW_ID} dir=ul rtp_codec=amr_12_2
