def get_linkspeed_value_from_cablink(all_cablinks_parameters, cablink_distname):
    linkspeed_value = None
    for cablink in all_cablinks_parameters:
        if cablink["dist_name"] == cablink_distname:
            linkspeed_value = cablink["params"]["linkSpeed"]

    return linkspeed_value
