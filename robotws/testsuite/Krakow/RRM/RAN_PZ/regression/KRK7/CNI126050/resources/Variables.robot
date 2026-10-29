*** Settings ***
Documentation
...    Test Variables for regression testing for feature CNI126050-FR2
...    authors: Lubomir Krzeminski
...    maintainer: Lubomir Krzeminski
...    group: RAN_PZ_KRK_SG_7
...    contact: lubomir.krzeminski@nokia.com

Library     toolsFR2.py    WITH NAME    tools

*** Variables ***
${mrbts_id}    77012
${measurement_hours}    ${1}
${mplane_ip}    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${cell_dist_name}    MRBTS-77012/NRBTS-77012/NRCELL-
${adjustPrach_name}     adjustPrachThresholdOffset
@{not_tested_cells}     2    3    4
${miNrRip_dist}    MRBTS-77012/NRBTS-77012/NRPMRNL-1
${actNrUlRip_dist}    MRBTS-77012/NRBTS-77012
${dist_name}    MRBTS-77012/NRBTS-77012/NRCELL-
${work_directory}    /home/ute/work_dir/
${test_vector_path}    /home/ute/test_repository/testsuite/Krakow/RRM/RAN_PZ/regression/KRK7/CNI126050/resources/test_vector_FR2.csv
${bts_connection}
