from datetime import datetime, timedelta


def slice_snap_timestamp(time_list, sw_version):
    timestamp = time_list[0]
    snap_prefix = "Snapshot_MRBTS-325_5G_cmWave_AEQE_Sydney_325"
    date_str = timestamp[1:5] + timestamp[6:8] + timestamp[9:11]
    time_object = (datetime.strptime(timestamp[12:17], '%H:%M') + timedelta(hours=8)).time()
    time_str = str(time_object)[0:2] + str(time_object)[3:5]
    return "{}_{}_{}-{}".format(snap_prefix, sw_version, date_str, time_str)
