from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl


# common variables
mrbts_id = str(tl.gnbs[0].dus[0].instance_id)
nrbts_id = mrbts_id
bts_prefix = "MRBTS-" + mrbts_id + "/NRBTS-" + nrbts_id
