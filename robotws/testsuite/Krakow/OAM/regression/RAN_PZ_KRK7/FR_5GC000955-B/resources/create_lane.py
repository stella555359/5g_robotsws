from robot.libraries.BuiltIn import BuiltIn


def create_lane(lane_type, sfp_create_keyword, qsfp_create_keyword, sfp2_create_keyword):
    create_lane_keywords = {"SFP": sfp_create_keyword,
                            "QSFP": qsfp_create_keyword,
                            "SFP2": sfp2_create_keyword}
    return BuiltIn().run_keyword(create_lane_keywords[lane_type])
