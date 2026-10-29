from ute_admin import ute_admin


def scf_comm(addr, sm_scfc_path, should_activate=True, skip_param=True, port=443, alias='default_admin', timeout=600):
    """
    Starts a new OAM session using ute_admin then load and activate scf file.
    """
    admin = ute_admin()
    admin.setup_admin(bts_host=addr, bts_port=port, use_ssl=True, alias=alias, timeout=timeout)
    admin.perform_commissioning(
                bts_id=1,
                scf_file=sm_scfc_path,
                skip_parameter_relation_errors=skip_param,
                should_activate=should_activate,
                timeout=timeout,
                alias=alias)


def delta_comm(addr, delta_json_path, should_activate=True, skip_param=True, port=443, timeout=600):
    """
    Starts a new OAM session using ute_admin then performs delta commissioning using a delta JSON file.
    The file path is passed directly to the Admin API.
    """
    admin = ute_admin()
    admin.setup_admin(bts_host=addr, bts_port=port, use_ssl=True, timeout=timeout)

    admin.perform_delta_recommissioning(
        delta_file=delta_json_path,
        skip_parameter_relation_errors=skip_param,
        should_activate=should_activate,
        timeout=timeout
    )
