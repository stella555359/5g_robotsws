*** Settings ***
Documentation   This is a keyword file for CB008731, part commissioning, delete
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

Delete element
    scf.load_scf    ${resultBaseDir}/SCFC_start.xml
    FOR   ${cell_id}   IN   1   2   3   4
       scf.remove_mo_with_descendant_mos        dist_name=${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1
    END
    scf.save_scf   ${resultBaseDir}/SCFC_start_after_remove.xml