from taf.config.scf.interface import scf
scf = scf()


def add_parama_to_scf(mrbts, object, dict_name, base_scf_path):
    scf.load_scf(file_path=base_scf_path)
    if scf.is_list_in_object(dist_name="MRBTS-{}/MNL-1/CERTH-1/{}-1".format(mrbts, object),
                             list_name="eeSubjectAltNames"):
        scf.save_scf(file_path=base_scf_path)
    else:
        scf.add_list_to_scf(dist_name="MRBTS-{}/MNL-1/CERTH-1/{}-1".format(mrbts, object),
                            list_name="eeSubjectAltNames")
        scf.add_item_to_list(dist_name="MRBTS-{}/MNL-1/CERTH-1/{}-1".format(mrbts, object),
                             list_name="eeSubjectAltNames", elements=dict_name)
        scf.save_scf(file_path=base_scf_path)


def remove_structure_from_scf(mrbts, object, base_scf_path):
    scf.load_scf(file_path=base_scf_path)
    if scf.is_list_in_object(dist_name="MRBTS-{}/MNL-1/CERTH-1/{}-1".format(mrbts, object),
                             list_name="eeSubjectAltNames"):
        scf.remove_list_from_scf(dist_name="MRBTS-{}/MNL-1/CERTH-1/{}-1".format(mrbts, object),
                                 list_name="eeSubjectAltNames")
        scf.save_scf(file_path=base_scf_path)
    else:
        scf.save_scf(file_path=base_scf_path)
