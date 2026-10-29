from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations


def verify_link_speed_value(value):
    GenericDuOperations('GNB').verify_configuration_parameters_values(param_dict={'MRBTS-75180/EQM-1/HWTOP-1/CABLINK-1':
                                                                      {'linkSpeed': value}})


def set_swconfig_flag_and_reset_bts():
    GenericDuOperations('GNB').set_swconfig_flag(flag='0x600010', value='519528842')
