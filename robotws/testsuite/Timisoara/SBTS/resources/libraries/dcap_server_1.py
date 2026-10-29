from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

# dcap_ip = "10.101.60.40"
dcap_ip = "10.57.195.82"
dcap_username = "utfuser"
dcap_password = "utfadmin!"
uplane_destination = dcap_ip
dcap_ipv6 = "2a00:8a00:8000:136:10:57:167:44"
uplane_ipv6 = dcap_ipv6
gnb_ipv6 = "2a00:8a00:8000:136:10:57:236:1a2"
cplane_destination = dcap_ip
file_location = "/sharedvolume/udptracer/_data/"
try:
    DCAP_host = tl.gnbs[0].dcap.connection_details.addr
except Exception:
    DCAP_host = "10.57.195.83"
try:
    DCAP_host_bak = tl.gnbs[0].dcap.connection_details.addr
except Exception:
    DCAP_host_bak = "10.57.195.83"
