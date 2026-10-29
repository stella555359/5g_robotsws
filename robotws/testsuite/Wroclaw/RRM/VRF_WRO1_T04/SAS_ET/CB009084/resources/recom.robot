*** Settings ***
Documentation
...   author: Kamil Bucki, Adrianna Pienkowska
...   contact: kamil.bucki@nokia.com, adrianna.pienkowska@nokia.com
...   description: Krakow Verification Engineering team common keywords for CB008132 feature

Library    ute_wtssim
Library    ute_fsmaccess
Library    ute_tshark
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_egate
Library    ta5g_syslog

Library    recom.py                                             WITH NAME    recom__

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

Just Do Recomissioning
    [Arguments]     ${delta_file}
    ...             ${output_dir}
    Log     Just Do Recomissioning
    recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                       delta=${delta_file}

Configure Dynamically Delta And Do Recomissioning
    [Arguments]     ${delta_setup}
    ...             ${delta_file}
    ...             ${output_dir}
    recom__.set_dynamically_quotas_sd_cell_celldeptype_mapping            delta_file=${delta_file}
    ...                                                                   delta_setup=${delta_setup}
    recom__.Perform Delta Recomissioning      output_dir=${output_dir}
    ...                                       delta=${DELTA_READY_TO_COM}