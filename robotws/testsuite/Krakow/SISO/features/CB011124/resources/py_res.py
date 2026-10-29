from taf.rfrl.bts.devices.generic_bts import GenericBts

gen_bts = GenericBts()


def prepare_distname_for_sfp_rmod(bts_id=0):
    return gen_bts.adjust_dist_name(dist_name=f'MRBTS-{gen_bts.get_bts_instance_id()}/MNL-1/MNLENT-1/PMMNL-1',
                                    bts_id=bts_id)
