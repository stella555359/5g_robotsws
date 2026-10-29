from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.cu_commission import (
    XmlParser, ManagedObjectInfo, cm)

cm_inst = cm()


def add_NRCTRLTS_obj(
        parameters,
        cu_ip,
        log_dir,
        cu_username='Nemuadmin',
        cu_password='nemuuser'):
    cm_inst.cu_inst.connect_to(
        host=cu_ip,
        port='443',
        username=cu_username,
        password=cu_password,
        secure=True)
    cm_inst.nidds = cm_inst.cu_inst.get_nidd()
    cm_inst._delete_delta_plan()
    cm_inst._create_delta_plan()
    scf_file = cm_inst._get_current_cu_scf_files(log_dir)
    cm_inst._get_dn_mo_uuid_map(scf_file)
    cm_inst._cu_add_create_mo_to_delta(parameters)
