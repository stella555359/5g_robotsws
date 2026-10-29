from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

dcap_ip = "10.57.195.82"
dcap_username = "utfuser"
dcap_password = "utfadmin!"
uplane_destination = dcap_ip + ":1234"
dcap_ipv6 = "2a00:8a00:8000:136:10:57:167:44"
uplane_ipv6 = dcap_ipv6 + ":1234"
gnb_ipv6 = "2a00:8a00:8000:136:10:57:236:1a2"
cplane_destination = dcap_ip + ":9999"
file_location = "/sharedvolume/udptracer/_data/"
DCAP_host = tl.test_pcs[2].connection_details.addr
try:
    DCAP_host_bak = tl.test_pcs[3].connection_details.addr
except Exception:
    # DCAP_host_bak = "10.101.60.41"
    DCAP_host_bak = "110.57.195.82"
