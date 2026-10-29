from robot.libraries.BuiltIn import BuiltIn
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib
import NIDD_Modify_data_template as data_template

# Params defined in CB006137_keywords.Decode CA group mapping and set global variable
PCELL_ID = BuiltIn().get_variable_value('${PCELL_ID}')

RESTAPI_DEACT_actUlDftSOfdm = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.RESTAPI_MODIFY_actUlDftSOfdm, list_cell_id=[PCELL_ID], value='false')
RESTAPI_RRE_TIMERS = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.RESTAPI_MODIFY_RRE_TIMERS, list_cell_id=[PCELL_ID])

RESTAPI_RRE_PARAMS = [
    dict(dist_name=param_modify_lib.DN_NRBTS, parameter='tRLFindForDU', value='3000ms'),
    dict(dist_name=param_modify_lib.DN_NRBTS, parameter='tRLFindForDUSA', value='3000ms'),
    dict(dist_name=param_modify_lib.DN_NRBTS, parameter='tWaitingRlRecover', value='10000ms'),
    dict(dist_name=param_modify_lib.DN_NRBTS, parameter='tWaitingRlRecoverSA', value='10000ms'),
    dict(dist_name=param_modify_lib.DN_NRBTS, parameter='srb2RlcAmProf',
         value=[dict(dlMaxRetxThreshold='t32', dlPollByte='infinity', dlPollPDU='infinity',
                     dlTPollRetr='ms100', dlTProhib='ms0', dlTReassembly='ms35',
                     ulMaxRetxThreshold='t1', ulPollByte='infinity', ulPollPDU='infinity',
                     ulTPollRetr='ms45', ulTProhib='ms0', ulTReassembly='ms35')]),
    dict(dist_name=param_modify_lib.DN_NRBTS, parameter='srb3RlcAmProf',
         value=[dict(dlMaxRetxThreshold='t32', dlPollByte='infinity', dlPollPDU='infinity',
                     dlTPollRetr='ms100', dlTProhib='ms0', dlTReassembly='ms35',
                     ulMaxRetxThreshold='t1', ulPollByte='infinity', ulPollPDU='infinity',
                     ulTPollRetr='ms45', ulTProhib='ms0', ulTReassembly='ms35')]),
    dict(dist_name=param_modify_lib.DN_NRBTS + "/NRDRB_RLC_AM-1", parameter='dlMaxRetxThreshold',
         value='t32'),
    dict(dist_name=param_modify_lib.DN_NRBTS + "/NRDRB_RLC_AM-1", parameter='ulMaxRetxThreshold',
         value='t1'),
    dict(dist_name=param_modify_lib.DN_NRBTS + "/NRDRB_RLC_AM-2", parameter='dlMaxRetxThreshold',
         value='t32'),
    dict(dist_name=param_modify_lib.DN_NRBTS + "/NRDRB_RLC_AM-2", parameter='ulMaxRetxThreshold',
         value='t1'),
] + RESTAPI_DEACT_actUlDftSOfdm + RESTAPI_RRE_TIMERS
