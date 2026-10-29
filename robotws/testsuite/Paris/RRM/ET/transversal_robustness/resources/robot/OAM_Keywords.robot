*** Settings ***
Documentation   :copyright: Nokia
...             :author/s: fabrice.delecroix@nokia.com, denis.taupin@nokia.com, gerard.bonhaure@nokia.com
...             :contact/s: denis.taupin@nokia.com, gerard.bonhaure@nokia.com
...             :description: Generic resource widely used by transversal robustness test suites

# Libraries
Library           taf.config.scf               WITH NAME    scf
Library           taf.sbts.oam.coam.admin      WITH NAME    sbts_coam
Library           ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME     coam_parameter

# Resources
Resource          ../../../../../resources/SWENG/robot/Oam.robot
Resource          ../../../../../resources/SWENG/robot/Sherpa.robot


*** Keywords ***

set_oam_parameter
    [Arguments]             ${oam_object_name}    ${oam_parameter_name}    ${oam_parameter_value}
    &{modify_param1}        Create Dictionary
    ...    parameter=${oam_parameter_name}
    ...    dist_name=${oam_object_name}
    ...    value=${oam_parameter_value}
    @{modify_param}         Create List    ${modify_param1}
    Dated Log               set_oam_parameter: ${modify_param}
    Oam.OAM Set Params      ${modify_param}

delete_cell
    [Arguments]            ${delta_delete_file}    ${gnb_alias}
    Dated Log              Delete Cell
    coam_parameter.perform_scf_delta_commission    delta_file=${delta_delete_file}    connection=${gnb_alias}

create_cell
    [Arguments]            ${delta_create_file}    ${gnb_alias}
    Dated Log              Create Cell
    coam_parameter.perform_scf_delta_commission    delta_file=${delta_create_file}    connection=${gnb_alias}
    Sleep                  20s

activate_sherpa_traces
    Dated Log              activate_sherpa_traces
    run keyword if         '${sherpa_mode}'=='activate_sherpa'    Sherpa.Activate Sherpa
    Run                    sudo pkill tcpdump

activate_sherpa_tcpdump
    Dated Log              activate sherpa and keep tcpdump alive
    run keyword if         '${sherpa_mode}'=='activate_sherpa'    Sherpa.Activate Sherpa

save_sherpa_pcap
    Dated Log              save tcpdump pcap
    Run                    sudo tar -zcvf ${LOG_PATH}/sherpa_pcap_$(date +%Y%m%d_%H%M%S).tgz /tmp/tcpdump_tcpdump.pcap

stop_tcpdump
    [Arguments]            ${keep_pcap}
    Dated Log              stop tcpdump process
    Run                    sudo pkill tcpdump
    run keyword if         '${keep_pcap}' == 'True'    save_sherpa_pcap
    Run                    sudo rm -rf /tmp/tcpdump_tcpdump.pcap

check_cell_states
    Dated Log              check_cell_states started
    @{cellsNr}             OAM Get Cells Nr    oam=${GNB_DU.oam}
    FOR    ${cellNr}    IN    @{cellsNr}
        should be equal    ${cellNr['status']['operationalState']}      enabled
        should be equal    ${cellNr['status']['barringStatus']}         unbarred
        # availabilityStatus will not be present if cell is online (as defined in CNI-61110)
        Dictionary Should Not Contain Key    ${cellNr['status']}        availabilityStatus
        ...                msg=Cell availabilityStatus is not online (${cellNr['status']})
    END
    Dated Log              check_cell_states ended

prepare_delta_files
    [Arguments]             ${original_scf_file}    ${delta_create_file}    ${delta_delete_file}
    ${tmp_scf_file}         Replace String    ${original_scf_file}    original    tmp
    ${new_scf_file}         Replace String    ${original_scf_file}    original    new
    scf.load_scf	        ${original_scf_file}
    scf.remove_mo_with_descendant_mos    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    scf.remove_mo_with_descendant_mos    dist_name=MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    scf.remove_mo_with_descendant_mos    dist_name=MRBTS-1/NRBTS-1/NRCELLGRP-0
    @{scf_modifications}    Create List    modify:MRBTS-1/NRBTS-1/NRDU-1:refNrCellGroup=1,TO_BE_REMOVED
    scf.perform_scf_modification    ${scf_modifications}
    scf.save_scf            ${tmp_scf_file}
    Run                     grep -v TO_BE_REMOVED ${tmp_scf_file} > ${new_scf_file}
    scf.calculate_delta_scf    ${new_scf_file}    ${original_scf_file}    ${delta_delete_file}
    scf.calculate_delta_scf    ${original_scf_file}    ${new_scf_file}    ${delta_create_file}

Json Recommissioning
    [Arguments]     ${delta_file}
    ${gnb_alias}    Set Variable                                   my_gnb_alias
                    sbts_coam.connect_to                           name=${gnb_alias}
                    coam_parameter.perform_scf_delta_commission    delta_file=${delta_file}
    ...                                                            connection=${gnb_alias}
    ...                                                            timeout=600
                    sbts_coam.teardown                             connection=${gnb_alias}
                    Dated Log New Line                             ---> OAM wait available
    ...                                                             OAM wait available
