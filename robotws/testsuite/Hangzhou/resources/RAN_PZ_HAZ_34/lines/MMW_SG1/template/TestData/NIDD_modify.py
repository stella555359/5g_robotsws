from robot.libraries.BuiltIn import BuiltIn
import logging
tl = BuiltIn().get_variable_value('${tl}')
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME = NR_NAME + '/NRCELL-1'
LTE_NAME = 'LNBTS-' + str(tl.enbs[0].instance_id)
LTE_CELL_NAME = LTE_NAME + '/LNCELL-1'
DIST_RLRESUMEBACKOFFTMR = NR_CELL_NAME

#       PART1--this part are parameters to be modified via rest api.
#       <dist_name>: refers to the dist_name as the scf. Its value can be NR_NAME, 'NRCELL-1'
#       <parameter>: refers to the p_name as the scf file. if need to modify p_name involving in list_name,
#                     put list_name in <parameter>, then all other p_name which exist in this list_name and the
#                     value of related p_name should be put into <value>

MODIFY_NIDD_VIA_API_TEMPLATE = [
    dict(
        value='false',
        dist_name=NR_CELL_NAME,
        parameter='actDynUlDataSplitMode'),
]

#       PART2--this part are parameters to be modified via WebUI or WebEM.
#       <dist_name>: refers to the dist_name as the scf. Its value can be NR_NAME, 'NRCELL-1'
#       <abbr>: refers to the p_name as the scf file. if need to modify p_name involving in list_name,
#                     put list_name in <parameter>, then all other p_name which exist in this list_name and the
#                     value of related p_name should be put into <value>

MODIFY_NIDD_VIA_WEBUI_TEMPLATE = [
    dict(
        new_value='false',
        dist_name=NR_CELL_NAME,
        abbr='actDynUlDataSplitMode',
        filter_param='Activate dynamic UL data split mode'),
]

MODIFY_SCF_TEMPLATE = [
    dict(
        value='20000',
        dist_name=DIST_RLRESUMEBACKOFFTMR,
        p_name='rlResumeBackOffTmr'),
]
