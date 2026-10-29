from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
MR_BTS_NAME = "MRBTS-" + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)

# PARAMS_TO_MODIFY_GOLDEN and PARAMS_TO_ADD_GOLDEN are related with peak.
PARAMS_TO_MODIFY_GOLDEN = [
    dict(value="true", dist_name=MR_NR_BTS_NAME + "/NRCELL-1", p_name="actPrachMultiplexing"),
    dict(value="true", dist_name=MR_NR_BTS_NAME + "/NRCELL-2", p_name="actPrachMultiplexing"),
    dict(value="pos2", dist_name=MR_NR_BTS_NAME + "/NRCELL-1", p_name="dmrsTypeAPosition"),
    dict(value="pos3", dist_name=MR_NR_BTS_NAME + "/NRCELL-2", p_name="dmrsTypeAPosition"),
    dict(value="true", dist_name=MR_NR_BTS_NAME + "/NRCELL-1", p_name="actPdschRmCsirsForTracking"),
    dict(value="true", dist_name=MR_NR_BTS_NAME + "/NRCELL-2", p_name="actPdschRmCsirsForTracking"),
    # dict(value="370", dist_name=MR_NR_BTS_NAME + "/NRCELL-1", p_name="pMax"),
]

PARAMS_TO_ADD_GOLDEN = [
    dict(
        dist_name=MR_NR_BTS_NAME + "/NRCELL-1",
        list_name="dynPdcchTdMgt",
        elements={
            "actDynPdcchTd": "true",
            "pdcchBlockingThreshold": "30",
            "pdcchFreeThreshold": "50"}),
    dict(
        dist_name=MR_NR_BTS_NAME + "/NRCELL-2",
        list_name="dynPdcchTdMgt",
        elements={
            "actDynPdcchTd": "true",
            "pdcchBlockingThreshold": "30",
            "pdcchFreeThreshold": "50"}),
    dict(
        dist_name=MR_NR_BTS_NAME + "/NRCELL-3",
        list_name="dynPdcchTdMgt",
        elements={
            "actDynPdcchTd": "true",
            "pdcchBlockingThreshold": "30",
            "pdcchFreeThreshold": "50"}),
    dict(
        dist_name=MR_NR_BTS_NAME + "/NRCELL-4",
        list_name="dynPdcchTdMgt",
        elements={
            "actDynPdcchTd": "true",
            "pdcchBlockingThreshold": "30",
            "pdcchFreeThreshold": "50"}),
    dict(
        dist_name=MR_NR_BTS_NAME + "/NRCELL-5",
        list_name="dynPdcchTdMgt",
        elements={
            "actDynPdcchTd": "true",
            "pdcchBlockingThreshold": "30",
            "pdcchFreeThreshold": "50"}),
    dict(
        dist_name=MR_NR_BTS_NAME + "/NRCELL-6",
        list_name="dynPdcchTdMgt",
        elements={
            "actDynPdcchTd": "true",
            "pdcchBlockingThreshold": "30",
            "pdcchFreeThreshold": "50"}),
    dict(
        dist_name=MR_NR_BTS_NAME + "/NRCELL-7",
        list_name="dynPdcchTdMgt",
        elements={
            "actDynPdcchTd": "true",
            "pdcchBlockingThreshold": "30",
            "pdcchFreeThreshold": "50"}),
]
