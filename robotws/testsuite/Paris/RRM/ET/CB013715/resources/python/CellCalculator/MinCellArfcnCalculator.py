

class ConfigurationError(Exception):
    def __init__(self, message, details):
        super().__init__(f"{message}: {details}")


class NrArfcn:
    def __init__(self, value):
        self.value = value

    @staticmethod
    def narrow(value):
        if value > 2**32 - 1:
            raise ConfigurationError("Narrowing to u32 occurred during fault information assembly", "")
        return NrArfcn(value)


def safe_unsigned_subtract(l_val, r_val, function_name):
    if l_val < r_val:
        raise ConfigurationError(f"Subtraction underflow in function {function_name}:",
                                 "lhs={l_val} < rhs={r_val}")
    return l_val - r_val


def safe_divide(l_val, r_val, function_name):
    if r_val == 0:
        raise ConfigurationError(f"Division by zero in function {function_name}:", "lhs={l_val}")
    return l_val / r_val


def safe_subtract(l_val, r_val):
    return safe_unsigned_subtract(l_val, r_val, __name__)


def safe_divide(l_val, r_val):
    return safe_divide(l_val, r_val, __name__)


def to_int(scs_common):
    return scs_common.value


def calculate_min_cell_arfcn(arfcn, scs_common, nrb, arfcn_raster):
    try:
        scs_common_value = to_int(scs_common)
        parenthesized_expression = (nrb.value // 2) * 12 + 6 * (nrb.value % 2)
        # calculated = arfcn.value - (parenthesized_expression * scs_common_value) // arfcn_raster
        calculated = safe_subtract(arfcn.value, (parenthesized_expression * scs_common_value) // arfcn_raster)
        return NrArfcn.narrow(calculated)
    except ConfigurationError as e:
        print(f"Warning: {e}")
        return NrArfcn(2**32 - 1)


def calculate_min_cell_arfcn_prb_blank(scs_common, arfcn_raster, nbr_of_blanked_prbs_low_edge_dl, min_cell_arfcn):
    try:
        scs_common_value = to_int(scs_common)
        calculated = min_cell_arfcn.value + nbr_of_blanked_prbs_low_edge_dl * 12 * scs_common_value // arfcn_raster
        return calculated
    except ConfigurationError as e:
        print(f"Warning: {e}")
        return 2**32 - 1


def convert_absolute_frequency_point_a_to_min_cell_arfcn(absolute_frequency_point_a):
    try:
        return NrArfcn(absolute_frequency_point_a)
    except ConfigurationError as e:
        print(f"Warning: {e}")
        return NrArfcn(2**32 - 1)
