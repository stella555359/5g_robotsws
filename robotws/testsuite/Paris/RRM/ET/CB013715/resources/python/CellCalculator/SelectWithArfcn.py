class UnexpectedFlow(Exception):
    pass


def select_with_arfcn(arfcn, first_range_case, second_range_case, third_range_case):
    max_allowed_arfcn = 3279165
    if arfcn <= 599999:
        return first_range_case
    elif arfcn <= 2016666:
        return second_range_case
    elif arfcn <= max_allowed_arfcn:
        return third_range_case
    else:
        raise UnexpectedFlow(f"Arfcn beyond {max_allowed_arfcn} is unsupported")


def calculate_arfcn_raster(arfcn):
    return select_with_arfcn(arfcn, 5, 15, 60)


# Example usage
try:
    result = calculate_arfcn_raster(700000)
    print(result)
except ValueError as e:
    print(e)


# Example usage
try:
    result = select_with_arfcn(700000, "Case 1", "Case 2", "Case 3")
    print(result)
except UnexpectedFlow as e:
    print(e)
