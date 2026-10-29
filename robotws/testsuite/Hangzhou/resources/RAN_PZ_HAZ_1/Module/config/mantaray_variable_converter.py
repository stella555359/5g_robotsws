class RobotObjectDict(dict):
    """A dictionary that allows attribute-based access (dictionary.key instead
    of dictionary['key']), it will ignore case incentive type when you use it.
    """

    def __getattr__(self, attr):
        value = self[str(attr).upper()]
        return RobotObjectDict(value) if isinstance(value, dict) else value

    def __setattr__(self, name, value):
        self[str(name).upper()] = value

    def __delattr__(self, name):
        del self[name]


def convert_variables(all_variables, target):
    target_list = ["TGT1", "TGT2", "TGT3", "SIM_ENB1", "SIM_ENB2"]
    target = str(target)
    if target:
        target = target.upper() if target.upper() in target_list else target_list[0]
    istarget = True if target in target_list else False
    temp_vars = {}
    for var_name in all_variables:
        if var_name.startswith("_") or var_name == "get_variables":
            continue
        else:
            temp_value = all_variables[var_name]
            temp_value = (
                RobotObjectDict(temp_value)
                if isinstance(temp_value, dict)
                else temp_value
            )
            temp_vars[var_name] = temp_value

    dest_vars = {}

    for var_name, var_value in temp_vars.items():
        temp_key = var_name
        if istarget:
            temp_key = "%s_%s" % (target, var_name)
        dest_vars[temp_key] = var_value

    return dest_vars
