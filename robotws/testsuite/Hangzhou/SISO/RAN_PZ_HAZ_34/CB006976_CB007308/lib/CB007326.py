def modify_parameter_scf_dist_name(scf_parameter, new_value):
    for i in scf_parameter:
        i["dist_name"] = new_value
    return scf_parameter
