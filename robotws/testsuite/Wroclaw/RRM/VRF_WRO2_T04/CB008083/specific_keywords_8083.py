import json
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.global_variables import bts_prefix
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import (
    TSharkCommandAssembler,
)
from testsuite.Wroclaw.RRM.resources.pcap_verification.message_to_tree import (
    message_to_tree,
)


def verify_gnb_cu_name(pcap_file, gnbcuname):
    filter = "e1ap.GNB_CU_CP_ConfigurationUpdate_element"
    output = (
        TSharkCommandAssembler().with_filter(filter).with_pcap_file(pcap_file).build()
    )
    value = (
        message_to_tree(output)
        .find("GNB-CU-CP-Name")
        .filter("GNB-CU-CP-ConfigurationUpdate")
        .first()["val"]
    )
    assert (
        value == gnbcuname
    ), "gNB CU Name is wrong, \n expected value: {}, \n current value: {}".format(
        gnbcuname, value
    )


def get_amf_status():
    with AdminSession() as admin:
        amf_status = {}
        info = admin.get_managed_objects(class_name="SERVEDAMF_R")
    for i in range(len(info)):
        amf_status.update(
            {info[i]["parameters"]["amfName"]: info[i]["parameters"]["ngLinkStatus"]}
        )
    return amf_status


def change_ng_link_status(action, amf_no="1"):
    distname = "{}/SERVEDAMF-{}".format(bts_prefix, amf_no)
    with AdminSession() as admin:
        if action == "lock":
            admin.lock_ng_link(dist_name=distname, timeout=120)
        if action == "unlock":
            admin.unlock_ng_link(dist_name=distname, timeout=120)


def delete_gNbCuName():
    with AdminSession() as admin:
        admin.perform_parameter_recommissioning(
            dist_name="{}".format(bts_prefix),
            parameter="gNbCuName",
            operation="delete",
            value="",
        )


def add_amf(ip_address, amf_id=2):
    with AdminSession() as admin:
        admin.perform_object_recommissioning(
            dist_name='{}/SERVEDAMF-{}'.format(bts_prefix, amf_id),
            parameter=[{"parameterName": "amfIPAddress", "operation": "update", "value": ip_address}],
            operation='create',
        )


def delete_amf(amf_id=2):
    with AdminSession() as admin:
        admin.perform_object_recommissioning(
            dist_name='{}/SERVEDAMF-{}'.format(bts_prefix, amf_id),
            parameter=[],
            operation='delete',
        )
