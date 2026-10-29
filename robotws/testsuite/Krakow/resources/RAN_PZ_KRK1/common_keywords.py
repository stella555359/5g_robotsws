from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu


def set_proper_dist_names(dist_names, bts_id=0, du_id=0):

    for i, dist_name in enumerate(dist_names):
        dist_name = GnbBbu().adjust_dist_name(dist_name=dist_name, bts_id=bts_id, du_id=du_id)
        dist_names[i] = dist_name
