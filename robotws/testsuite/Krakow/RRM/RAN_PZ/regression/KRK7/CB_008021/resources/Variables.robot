*** Settings ***
Documentation
...    Test Variables for regression testing for feature CB008021-FR2
...    authors: Lubomir Krzeminski
...    maintainer: Lubomir Krzeminski
...    group: RAN_PZ_KRK_SG_7
...    contact: lubomir.krzeminski@nokia.com

Library     toolsFR2.py    WITH NAME    tools

*** Variables ***
${NETACT_NAME}    ${tl.nms.netact.https_main_info.addr}
${HOSTNAME}    ${tl.nms.netact.ssh_connections_info.addr}
${USERNAME}    ${tl.nms.netact.ssh_connections_info.username}
${PASSWORD}    ${tl.nms.netact.ssh_connections_info.password}
${mrbts_id}    77012
${netact_measurement_hours}    ${4}
${mplane_ip}    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${cell_dist_name}    MRBTS-77012/NRBTS-77012/NRCELL-
${adjustPrach_name}     adjustPrachThresholdOffset
@{not_tested_cells}     2    3    4
${miNrRip_dist}    MRBTS-77012/NRBTS-77012/NRPMRNL-1
${actNrUlRip_dist}    MRBTS-77012/NRBTS-77012
${dist_name}    MRBTS-77012/NRBTS-77012/NRCELL-
${work_directory}    /home/ute/work_dir/
${bts_connection}
${FLAGS}    ether[0x20:2]==0xe24b or ether[0x20:2]==0xe24d
&{mirroring_script_params}    number_of_files=${5}    file_size_mbytes=${500}    filter=${FLAGS}    filtering=on
