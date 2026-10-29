from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
tl_name = BuiltIn().get_variable_value("${testline_name}")

if tl_name == '7_5_UTE5G402T978':
    PA_INFO = {
        '3': 'default',
        '2': tl.attenuator[0],
        '4': tl.attenuator[0],
        '5': tl.attenuator[1],
        '6': tl.attenuator[1]
    }
elif tl_name == '7_5_UTE5G402T779':
    PA_INFO = {
        '1': 'default'
    }
elif tl_name == '7_5_UTE5G402T777':
    PA_INFO = {
        '1': 'default'
    }
elif tl_name == '7_5_UTE5G402T967':
    PA_INFO = {
        '1': tl.attenuator[0],
        '2': tl.attenuator[0],
        '3': tl.attenuator[0],
        '4': tl.attenuator[0],
        '5': tl.attenuator[1],
        '6': tl.attenuator[1]
    }
