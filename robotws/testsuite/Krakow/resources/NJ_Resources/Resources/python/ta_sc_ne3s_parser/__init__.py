from NE3SParserInterface import NE3SParserInterface


class ta_sc_ne3s_parser(NE3SParserInterface):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        super(ta_sc_ne3s_parser, self).__init__()
