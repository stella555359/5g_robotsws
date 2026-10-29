*** Settings ***
Documentation
...     Test Suite Purpose:
...         Variable file for Hanover
...
...         last update: 29.07.2020

*** Variables ***
${intra_gnb_A3_config}=       ${custom['HO_Configuration'][0]}      # points to intra gNB A3 HO
${intra_gnb_A5_config}=       ${custom['HO_Configuration'][1]}      # points to intra gNB A5 HO
${source_attenuator_id}                ${custom['HO_Configuration'][1]['intra_gnb_A5']['source_attenuator_id']}
${target_attenuator_id}                ${custom['HO_Configuration'][1]['intra_gnb_A5']['target_attenuator_id']}
${source_channels}                     ${custom['HO_Configuration'][1]['intra_gnb_A5']['source_channels']}
${target_channels}                     ${custom['HO_Configuration'][1]['intra_gnb_A5']['target_channels']}
${attenuations_min}                    ${custom['HO_Configuration'][1]['intra_gnb_A5']['attenuations_min']}
${attenuations_max}                    ${custom['HO_Configuration'][1]['intra_gnb_A5']['attenuations_max']}
${source_attenuations_a2}              ${custom['HO_Configuration'][1]['intra_gnb_A5']['source_attenuations_a2']}
${target_attenuations_a2}              ${custom['HO_Configuration'][1]['intra_gnb_A5']['target_attenuations_a2']}
${source_attenuations_ho_trigger}     ${custom['HO_Configuration'][1]['intra_gnb_A5']['source_attenuations_ho_trigger']}
${target_attenuations_ho_trigger}     ${custom['HO_Configuration'][1]['intra_gnb_A5']['target_attenuations_ho_trigger']}
${source_attenuations_attach}          ${custom['HO_Configuration'][1]['intra_gnb_A5']['source_attenuations_attach']}
${target_attenuations_attach}          ${custom['HO_Configuration'][1]['intra_gnb_A5']['target_attenuations_attach']}
