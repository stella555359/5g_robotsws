from taf.config.scf.interface import scf
scf = scf()


def add_parama_to_scf(mrbts, dict_name, base_scf_path):
    scf.load_scf(file_path=base_scf_path)
    if scf.is_list_in_object(dist_name="MRBTS-{}/MNL-1/CERTH-1/CMPECDSA-1".format(mrbts),
                             list_name="eeSubjectAltNames"):
        scf.add_item_to_list(dist_name="MRBTS-{}/MNL-1/CERTH-1/CMPECDSA-1".format(mrbts),
                             list_name="eeSubjectAltNames", elements=dict_name)
        scf.save_scf("new_scf.xml")
        return "new_scf.xml"
    else:
        scf.add_list_to_scf(dist_name="MRBTS-{}/MNL-1/CERTH-1/CMPECDSA-1".format(mrbts),
                            list_name="eeSubjectAltNames")
        scf.add_item_to_list(dist_name="MRBTS-{}/MNL-1/CERTH-1/CMPECDSA-1".format(mrbts),
                             list_name="eeSubjectAltNames", elements=dict_name)
        scf.save_scf("new_scf.xml")
        return "new_scf.xml"
