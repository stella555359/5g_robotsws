from taf.sw.qualcomm.license.interface import license
from robot.libraries.BuiltIn import BuiltIn

_builtin = BuiltIn()
tl = _builtin.get_variable_value("${tl}")


def get_5g_qxdm_and_qcat_license(username: str, password: str, ue_id: str) -> None:
    """
    Logs into QPM LK (requires a previously open instance of the application on UE PC)
    and reserves QXDM and QCAT 5g licenses.

    :param username: your qualcomm account login
    :param password: your qualcomm account password
    :param ue_id: index of ue object in init to get the UE PC data from
    """
    launcher = {'host': tl.ues[int(ue_id)].ssh_connection_details.addr,
                'path': "/cygdrive/c/QPM_LK1.5.1",
                'user': tl.ues[int(ue_id)].ssh_connection_details.username,
                'password': tl.ues[int(ue_id)].ssh_connection_details.password}
    lk = license()
    lk.setup(launcher=launcher)
    lk.login(username=username, password=password)
    lk.get_licence_qxdm_5g()
    lk.get_licence_qcat_5g()


def release_5g_qxdm_and_qcat_license(ue_id: str) -> None:
    """
    Releases qxdm and qcat licenses on QPM LK and logs out.

    :param ue_id: index of ue object in init to get the UE PC data from
    """
    launcher = {'host': tl.ues[int(ue_id)].ssh_connection_details.addr,
                'path': "/cygdrive/c/QPM_LK1.5.1",
                'user': tl.ues[int(ue_id)].ssh_connection_details.username,
                'password': tl.ues[int(ue_id)].ssh_connection_details.password}
    lk = license()
    lk.setup(launcher=launcher)
    lk.release_licence_qxdm_5g()
    lk.release_licence_qcat_5g()
    lk.logout()
    lk.teardown()
