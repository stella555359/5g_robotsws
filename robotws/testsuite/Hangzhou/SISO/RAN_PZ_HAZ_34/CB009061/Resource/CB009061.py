from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

_gnb_id = str(tl.gnbs[0].global_bts_id)
_bts_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_bts_id
_LNBTSname = _MRBTSname+'/LNBTS-'+_bts_id
MR_NR_CELL_3 = _NRBTSname + '/NRCELL-3'
MR_NR_CELL_31 = _NRBTSname + '/NRCELL-31'
MR_NR_CELL_32 = _NRBTSname + '/NRCELL-32'

parameters_for_4598 = [
    dict(
        dist_name=MR_NR_CELL_3,
        parameter='beamSet',
        value=[{'tiltOffset': '-13'}]),
    dict(
        dist_name=MR_NR_CELL_31,
        parameter='beamSet',
        value=[{'tiltOffset': '-13'}]),
    dict(
        dist_name=MR_NR_CELL_32,
        parameter='beamSet',
        value=[{'tiltOffset': '-13'}]),
]

parameters_for_4598_clear = [
    dict(
        dist_name=MR_NR_CELL_3,
        parameter='beamSet',
        value=[{'tiltOffset': '0'}]),
    dict(
        dist_name=MR_NR_CELL_31,
        parameter='beamSet',
        value=[{'tiltOffset': '0'}]),
    dict(
        dist_name=MR_NR_CELL_32,
        parameter='beamSet',
        value=[{'tiltOffset': '0'}]),
]

parameters_for_1900_1 = [
    dict(
        value='630606',
        dist_name=MR_NR_CELL_3,
        parameter='nrarfcn'),
]

parameters_for_1900_2 = [
    dict(
        value='642680',
        dist_name=MR_NR_CELL_32,
        parameter='nrarfcn'),
]

parameters_clear_1900 = [
    dict(
        value='633400',
        dist_name=MR_NR_CELL_3,
        parameter='nrarfcn'),
]
parameters_clear_1900_2 = [
    dict(
        value='642000',
        dist_name=MR_NR_CELL_32,
        parameter='nrarfcn'),
]
ATTENUATION_VALUE_update1 = {
    'atten_value_of_port0': 35,
    'atten_value_of_port1': 35,
    'atten_value_of_port2': 35,
    'atten_value_of_port3': 35
}
ATTENUATION_VALUE_update3CC = {
    'atten_value_of_port0': 20,
    'atten_value_of_port1': 30,
    'atten_value_of_port2': 30,
    'atten_value_of_port3': 30
}
