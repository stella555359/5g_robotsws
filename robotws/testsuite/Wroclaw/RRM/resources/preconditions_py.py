# author  : Jan Rownicki
# contact : jan.rownicki@nokia.com
# usage   : from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id, nrbts_str
#           and use like standard variables, you can even rename them (if you somehow need to):
#           from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id as different_name

import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
mrbts_id = fixture.get_robot_variable("${tl.gnbs[0].instance_id}")
mrbts_id = int(mrbts_id) if mrbts_id is not None else 0

nrbts_id = fixture.get_robot_variable("${tl.gnbs[0].global_bts_id}")
nrbts_id = int(nrbts_id) if nrbts_id is not None else 0

radio_type = str(fixture.get_robot_variable("${tl.gnbs[0].dus[0].rus[0].radio_type}"))
sw_release_name = None
smod_name = None

mrbts_str = "MRBTS-" + str(mrbts_id)
nrbts_str = "/NRBTS-" + str(nrbts_id)
bts_prefix = mrbts_str + nrbts_str


def update_python_globals():
    global sw_release_name
    sw_release_name = str(fixture.get_robot_variable("${sw release name}"))


def get_smod_name():
    global smod_name
    if smod_name is None:
        with fixture.webUI.WebUIOperations() as coam:
            smod_info = coam.get_managed_objects(class_name='SMOD_R',
                                                 timeout=30)
            smod_name = smod_info[0]['parameters']['productName'][:4]
    return smod_name


def set_smod_slave(is_slave):
    global smod_name
    if is_slave:
        if smod_name != 'ASIK':
            return False
        else:
            return is_slave
    return is_slave
