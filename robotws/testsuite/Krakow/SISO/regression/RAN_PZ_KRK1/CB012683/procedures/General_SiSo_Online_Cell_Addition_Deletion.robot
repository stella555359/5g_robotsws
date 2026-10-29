*** Settings ***
Documentation
...   Test CB012683 - General_SiSo_Online_Cell_Addition_Deletion
...   author: Julia Luszcz
...   author/contact: julia.luszcz@nokia.com

*** Keywords ***
General_SiSo_Online_Cell_Addition_Deletion
    Download gNB Configuration File         local_dir=${LOG_PATH}    filename=${default_scf_filename}
    Perform Delta Commissioning On gNB      ${main_deltas}[delta_remove_cell]

    Download gNB Configuration File         local_dir=${LOG_PATH}    filename=${deleted_cell_scf_filename}
    Calculate Delta SCF    ${LOG_PATH}/${default_scf_filename}
    ...                    ${LOG_PATH}/${deleted_cell_scf_filename}
    ...                    ${LOG_PATH}/${add_cell_delta_filename}
    gnbscf.Perform BTS Delta JSON Commissioning    ${LOG_PATH}/${add_cell_delta_filename}
    Wait Until Keyword Succeeds    60s   10s    gnbcell.verify_all_cells_are_onair