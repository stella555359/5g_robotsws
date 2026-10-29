# from robot.libraries.BuiltIn import BuiltIn
# attenuator = BuiltIn().get_variable_value('${tl.attenuator[0]}')

# attenuator OFF:
ATT_OFF_ports = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
ATT_OFF_values = [110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]

# CELL_ID_1
NSA_ports = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
NSA_values = [110, 110, 110, 110, 0, 0, 0, 0, 110, 110, 110, 110, 0, 0, 0, 0]

ATT_OFF = [
    {
        "ports": ATT_OFF_ports,
        "values": ATT_OFF_values,
    }
]

NSA = [
    {
        "ports": NSA_ports,
        "values": NSA_values,
    }
]
