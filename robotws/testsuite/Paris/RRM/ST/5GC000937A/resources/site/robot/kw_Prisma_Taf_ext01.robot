*** Settings ***
Documentation
...     Keywords Purpose:
...         Keywords for Prisma via taf.ue.prisma official Prisma Libs extension 01
...         extension contains some fork then modified kws
...
...     Version: 1.0.0
...     	Date: 27/11/2020
...
...     AUTHOR (mmW&SC Pz NPS 4 SG):
...         I_MNP_5G_NPS_IVU_SISO_MOBILITY@nokia.com


*** Keywords ***
Start airmosaic and connect to tstm Ext01
    prismaTaf.start mosaic              node_name=${airmosaic}
    sleep                               1min
    log                                 ${sid_file_name}
    log                                 ${airmosaic_config_files_path_name}
    prismaTaf.prepare test              ${sid_file_name}
    ...                                 ${airmosaic_config_files_path_name}
    ...                                 timeout=${180}
    ...                                 node_name=${airmosaic}

Start airmosaic and connect to tstm WA To Reconnect Ext01
    prismaTaf.start mosaic              node_name=${airmosaic}
    sleep                               1min
    Stop And Restart tstm uu process
    Sleep           60s
    prismaTaf.prepare test              ${sid_file_name}
    ...                                 ${airmosaic_config_files_path_name}
    ...                                 timeout=${180}
    ...                                 node_name=${airmosaic}
    Sleep           60s

Start LSU uu Ext01
    ${response}=        				prismaTaf.create 5g cell
	...									node_name=${lsu_x2uu_node}
	...									timeout=${400}
    sleep               				60s
    ${isLSU_uuStartCompleted}=          Evaluate    "lsustart completed correctly" in """${response}"""
    Should be true                      ${isLSU_uuStartCompleted}

Connect to tstm Ext01
    prismaTaf.prepare test              ${sid_file_name}
    ...                                 ${airmosaic_config_files_path_name}
    ...                                 timeout=${180}
    ...                                 node_name=${airmosaic}
