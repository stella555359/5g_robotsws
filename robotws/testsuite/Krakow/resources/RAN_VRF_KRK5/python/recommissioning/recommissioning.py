from taf.rfrl.bts.devices.generic_bts import GenericBts


def adjust_dist_name(dist_name, bts_id=0, du_id=0, cell_id=None):
    if 'NRCELL' in dist_name or 'LNCEL' in dist_name:
        dist_name = dist_name.format({}, {}, cell_id)
    return GenericBts().adjust_dist_name(dist_name=dist_name, bts_id=int(bts_id), du_id=int(du_id))
