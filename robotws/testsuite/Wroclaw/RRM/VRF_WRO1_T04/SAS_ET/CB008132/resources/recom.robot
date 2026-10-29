*** Settings ***
Documentation
...   author: Kamil Bucki, Adrianna Pienkowska, Konrad Kucharzyk
...   contact: kamil.bucki@nokia.com, adrianna.pienkowska@nokia.com, konrad.kucharzyk@nokia.com
...   description: Krakow Verification Engineering team common keywords for CB008132 feature

Library    ute_wtssim
Library    ute_fsmaccess
Library    ute_tshark
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_egate
Library    ta5g_syslog
Library    recommissioning.py                                             WITH NAME    recom__


Variables    variables.py

*** Keywords ***

Configure Delta And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${sd}
    ...             ${fdm}
    ...             ${output_dir}
    recom__.Set Quotas Sd And Fdm On Delta            delta_file=${DELTA_WITH_QUOTAS_AND_FDM_ENABLED}
    ...                                               quotas=${quotas}
    ...                                               sd=${sd}
    ...                                               fdm=${fdm}
    recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                       delta=${DELTA_READY_TO_COM}

Configure Single NSA Slice Delta And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${nr_of_quotas}
    ...             ${output_dir}
    Log    ${nr_of_quotas}
    recom__.Set Quotas Fdm One Slice Delta    delta_file=${DELTA_1NSA_SLICE}
    ...                                       quotas=${quotas}
    recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                       delta=${DELTA_READY_TO_COM}

Configure FDM Delta And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${sd}
    ...             ${fdm}
    ...             ${output_dir}
    recom__.Set Quotas Sd And Fdm On Delta            delta_file=${DELTA_WITH_QUOTAS_AND_FDM_DISABLED}
    ...                                               quotas=${quotas}
    ...                                               sd=${sd}
    ...                                               fdm=${fdm}
    recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                       delta=${DELTA_READY_TO_COM}

Configure 2 Slices Default Delta And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${sd}
    ...             ${output_dir}
    recom__.Set Quotas Sd And Fdm On Delta            delta_file=${DELTA_DEFAULT_2SLICES}
    ...                                               quotas=${quotas}
    ...                                               sd=${sd}
    ...                                               fdm=${ENABLE_FDM_SCHEDULING}
    recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                       delta=${DELTA_READY_TO_COM}

Configure 3 Slices Delta And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${sd}
    ...             ${output_dir}
    recom__.Set Quotas Sd With 3slices On Delta            delta_file=${DELTA_SETUP_3SLICES_FOR_ONLINE_CHANGE}
    ...                                                    quotas=${quotas}
    ...                                                    sd=${sd}
    BuiltIn.Sleep   30
    recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                       delta=${DELTA_READY_TO_COM}
    BuiltIn.Sleep   60

Configure VONR Delta And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${sd}
    ...             ${output_dir}
    recom__.Set Quotas Sd With 4slices On Delta            delta_file=${DELTA_VONR}
    ...                                                    quotas=${quotas}
    ...                                                    sd=${sd}
    recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                       delta=${DELTA_READY_TO_COM}

Configure NSA VONR Delta And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${sd}
    ...             ${output_dir}
    recom__.Set Quotas Sd With 3slices On Delta            delta_file=${DELTA_VONR}
    ...                                                    quotas=${quotas}
    ...                                                    sd=${sd}
    recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                       delta=${DELTA_READY_TO_COM}

Configure CA 1PLMN Delta And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${sd}
    ...             ${output_dir}
    recom__.Set Quotas Sd With 3slices On Delta            delta_file=${DELTA_CA_1PLMN_3SLICES}
    ...                                                    quotas=${quotas}
    ...                                                    sd=${sd}
    recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                       delta=${DELTA_READY_TO_COM}

Configure CA 3PLMN Delta And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${sd}
    ...             ${output_dir}
    recom__.Set Quotas Sd With 3slices On Delta            delta_file=${DELTA_CA_3PLMN_3SLICES}
    ...                                                    quotas=${quotas}
    ...                                                    sd=${sd}
    recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                       delta=${DELTA_READY_TO_COM}

Configure NSA CA 1PLMN Delta And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${resource_dns}
    ...             ${output_dir}
    recom__.set_quotas_with_resource_dns_on_delta          delta_file=${DELTA_CA_1PLMN_2SLICES}
    ...                                                    quotas=${quotas}
    ...                                                    resource_dns=${resource_dns}
    recom__.Perform Delta Recomissioning                   output_dir=${output_dir}
    ...                                                    delta=${DELTA_READY_TO_COM}

Configure NSA CA 3PLMN Delta And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${sd}
    ...             ${output_dir}
    ...             ${resourceGroup_dn_list}
    recom__.Set Nsa Quotas Sd With 3slices On Delta        delta_file=${DELTA_CA_3PLMN_3SLICES}
    ...                                                    quotas=${quotas}
    ...                                                    sd=${sd}
    ...                                                    resourceGroup_dn_list=${resourceGroup_dn_list}
    recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                       delta=${DELTA_READY_TO_COM}

Configure 3PLMN For TTI And Sherpa Delta And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${sd}
    ...             ${output_dir}
    recom__.Set Quotas Sd With 3slices On Delta            delta_file=${DELTA_3PLMN}
    ...                                                    quotas=${quotas}
    ...                                                    sd=${sd}
    BuiltIn.Sleep   20
    recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                       delta=${DELTA_READY_TO_COM}
    BuiltIn.Sleep   20

Configure 20 Slices And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${output_dir}
    recom__.set_quotas_fdm_one_slice_delta                 delta_file=${DELTA_MAX_SLICE}
    ...                                                    quotas=${quotas}
    recom__.Perform Delta Recomissioning                   output_dir=${output_dir}
    ...                                                    delta=${DELTA_READY_TO_COM}

Configure 6 NSA Slice And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${output_dir}
    recom__.set_quotas_6_nsa_slices                        delta_file=${DELTA_6NSA_SLICE}
    ...                                                    quotas=${quotas}
    recom__.Perform Delta Recomissioning                   output_dir=${output_dir}
    ...                                                    delta=${DELTA_READY_TO_COM}

Configure 3 NSA One SA Slice And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${output_dir}
    recom__.set_quotas_nsa_sa_slice_delta                  delta_file=${DELTA_3NSA_SLICE}
    ...                                                    quotas=${quotas}
    recom__.Perform Delta Recomissioning                   output_dir=${output_dir}
    ...                                                    delta=${DELTA_READY_TO_COM}

Configure Only 3 NSA Slices And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${output_dir}
    recom__.set_quotas_nsa_sa_slice_delta                  delta_file=${DELTA_DL_PRB_3NSA_SLICES}
    ...                                                    quotas=${quotas}
    recom__.Perform Delta Recomissioning                   output_dir=${output_dir}
    ...                                                    delta=${DELTA_READY_TO_COM}

Configure 1 NSA 2 SA Slices And Do Recomissioning
    [Arguments]     ${quotas}
    ...             ${output_dir}
    recom__.set_quotas_nsa_sa_slice_delta                  delta_file=${DELTA_DL_PRB_1NSA_2SA_SLICES}
    ...                                                    quotas=${quotas}
    recom__.Perform Delta Recomissioning                   output_dir=${output_dir}
    ...                                                    delta=${DELTA_READY_TO_COM}
