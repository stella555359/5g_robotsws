from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


# modify CB008502_TC1 SCF

PARAMS_TO_DELETE_8502_TC1 = []

MOs_TO_ADD_8502_TC1 = []

PARAMS_TO_MODIFY_8502_TC1 = [
    dict(value="eCpri25", dist_name="MRBTS-11051/EQM-1/HWTOP-1/CABLINK-5", p_name="linkSpeed")
]

LIST_PARAMS_TO_MODIFY_8502_TC1 = []

LIST_TO_ADD_8502_TC1 = []


# modify CB008502_TC2 SCF

PARAMS_TO_DELETE_8502_TC2 = []

MOs_TO_ADD_8502_TC2 = []

PARAMS_TO_MODIFY_8502_TC2 = [
    dict(value="eCpri10", dist_name="MRBTS-11051/EQM-1/HWTOP-1/CABLINK-5", p_name="linkSpeed")
]

LIST_PARAMS_TO_MODIFY_8502_TC2 = []

LIST_TO_ADD_8502_TC2 = []
