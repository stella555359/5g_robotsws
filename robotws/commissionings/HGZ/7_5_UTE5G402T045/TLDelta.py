from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
MR_BTS_NAME = "MRBTS-" + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)

MODIFY_SCF_80040_ENABLE = [
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME,
        p_name='actProactResendRlcPdu')
]

# PARAMS_TO_MODIFY_GOLDEN
PARAMS_TO_MODIFY_GOLDEN = MODIFY_SCF_80040_ENABLE
