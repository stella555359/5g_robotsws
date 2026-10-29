# !/home/ute/test_repo/bin/python
# The above line can be added if you already have an ute install with mplane embedded, avoiding you to install python
# You can then chmod +x the script and run it without specifying python

from taf.ul.oran_mplane.interface import OranMplane
import sys

temp_min = sys.argv[1]
temp_max = sys.argv[2]
temp_avg = sys.argv[3]

NETCONF_SERVER_IP = "192.168.200.1"
NETCONF_SERVER_PORT = 830
ROUTER = {"session1": {"host": NETCONF_SERVER_IP, "port": NETCONF_SERVER_PORT, "username": "oru01",
                       "password": "oamterm"}}

# username can be "oru01" for first ORU, "oru02" for second ORU, etc...

# configure the backdoor with wanted values: min, max and average
xml_req = f"""<test-performance-measurement-objects xmlns="urn:nokia-airphone:performance-management:1.0">
    <epe-measurement-objects>
        <measurement-object>TEMPERATURE</measurement-object>
        <epe-measurement-result>
            <object-unit-id xmlns:o-ran-hw="urn:o-ran:hardware:1.0">o-ran-hw:O-RAN-RADIO</object-unit-id>
            <min>{temp_min}</min>
            <max>{temp_max}</max>
            <average>{temp_avg}</average>
        </epe-measurement-result>
    </epe-measurement-objects>
</test-performance-measurement-objects>"""

xml_resp = "<ok/>"

# You can also provide the full expectation in the expected_response if you use the deepdiff validation mode
EXAMPLE_MSG = {"request":  xml_req, "expected_response":  xml_resp}
print(f"Will connect on {NETCONF_SERVER_IP} : {NETCONF_SERVER_PORT}")

# See https://wrgitlab.ext.net.nokia.com/TAF/taf.ul.oran_mplane/-/blob/main/taf/ul/oran_mplane/interface.py

oran_object = OranMplane(router=ROUTER)
oran_object.connect(session="session1")
print("Netconf session established !")
print(f"Will send edit-config {EXAMPLE_MSG}")
oran_object.edit_config(session="session1", msg=EXAMPLE_MSG, validation_mode="skip_validation")

# get new performance-management values from module o-ran-performance-management
perf_managmt_req = '''<performance-measurement-objects xmlns="urn:o-ran:performance-management:1.0"
xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
  <epe-measurement-objects>
    <measurement-object>TEMPERATURE</measurement-object>
  </epe-measurement-objects>
</performance-measurement-objects>'''

# put the expected values in the response according to your config:

perf_managmt_resp = '''<performance-measurement-objects xmlns="urn:o-ran:performance-management:1.0">
    <epe-measurement-objects>
      <measurement-object>TEMPERATURE</measurement-object>
      <epe-measurement-result>
        <object-unit-id xmlns:o-ran-hw="urn:o-ran:hardware:1.0">o-ran-hw:O-RAN-RADIO</object-unit-id>
        <min>20.0</min>
        <max>30.0</max>
        <average>25.0</average>
      </epe-measurement-result>
      <epe-measurement-result>
       <object-unit-id xmlns:ianahw="urn:ietf:params:xml:ns:yang:iana-hardware">ianahw:port</object-unit-id>
        <min>41.5</min>
        <max>49.9</max>
        <average>44.2</average>
      </epe-measurement-result>
    </epe-measurement-objects>
  </performance-measurement-objects>'''

MSG = {"request": perf_managmt_req, "expected_response": perf_managmt_resp}
oran_object.get(session="session1", msg_format="xml", msg=MSG, validation_mode="skip_validation")
oran_object.close_all_sessions()
