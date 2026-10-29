import sys
import pexpect


class pcf:
    def __init__(self):
        pass

    def pcf_connect(self, ip, username, password):
        self.ip = ip
        self.username = username
        self.password = password
        self.process = pexpect.spawn("ssh {}@{}".format(self.username, self.ip))
        self.process.logfile_read = sys.stdout
        self.process.expect("[Pp]assword")
        self.process.sendline("{}".format(self.password))
        self.process.sendline("/home/xk/sim-5g-pcf")
        self.process.expect("CLI>")

    def pcf_start(self):
        cmdList = (
            "configure create pcf-profile 1",
            "configure pcf-profile 1 generate-ref true",
            "configure pcf-profile 1 create-res 201",
            "configure pcf-profile 1 release-res 204",
            "configure pcf-profile 1 update-res 200",
            "configure pcf-profile 1 match-imsi 460020000000000 460029999999999",
            "configure create node pcf 1",
            "configure node pcf 1 server-service 10.57.167.167:8080",
            "configure node pcf 1 client-addr 10.57.167.167",
            "configure node pcf 1 add-profile 1",
            "proc node pcf 1 start-service",
            "proc node pcf 1 start-client",
        )
        for cmd in cmdList:
            self.process.sendline(cmd)
            self.process.expect("CLI>")
            output = self.process.before
            print(output)

    def pcf_add_one_QoS(self):
        cmdList = (
            "configure create custom-data 33",
            'configure custom-data 33 json add-object "/smPolicyDecision"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/qosId" '
            "qosIdForDefault1",
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault1/5qi" 8',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault1/arp"',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault1/arp/priorityLevel" '
            "3",
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/maxbrUl" "6 Gbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/maxbrDl" "10 Gbps"',
            'configure custom-data 33 json add-bool "/smPolicyDecision/qosDecs/qosIdForDefault1/qnc" "false"',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs/tcIdForDefault1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1/tcId" '
            "tcIdForDefault1",
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1/flowStatus" '
            "ENABLED",
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/pccRuleId" '
            "dynamicPolicyRule1",
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDescription" "permit out 17 from 10.57.240.19 to any"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDescription" "permit in 17 from any to 10.57.240.19"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDirection" BIDIRECTIONAL',
            'configure custom-data 33 json add-number "/smPolicyDecision/pccRules/dynamicPolicyRule1/precedence" 3',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/refQosData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/refQosData/-" '
            "qosIdForDefault1",
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/refTcData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/refTcData/-" '
            "tcIdForDefault1",
            'configure custom-data 33 json add-array "/smPolicyDecision/lastReqRuleData"',
            'configure custom-data 33 json add-object "/smPolicyDecision/lastReqRuleData/0"',
            'configure custom-data 33 json add-array "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds"',
            'configure custom-data 33 json add-string "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds/-" '
            "dynamicPolicyRule1",
            'configure custom-data 33 json add-array "/smPolicyDecision/policyCtrlReqTriggers"',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" SAREA_CH',
            "configure pcf-profile 1 policy-notification-data 33",
            "proc node pcf 1 policy-update-notify all",
        )

        for cmd in cmdList:
            self.process.sendline(cmd)
            self.process.expect("CLI>")
            output = self.process.before
            print(output)

    def pcf_add_two_QoS(self):
        cmdList = (
            "configure create custom-data 33",
            'configure custom-data 33 json add-object "/smPolicyDecision"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1'
            '/qosId" qosIdForDefault1',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault1/5qi" 8',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault1/arp"',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault1/arp/priorityLevel" '
            "3",
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/maxbrUl" "6 Gbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/maxbrDl" "10 Gbps"',
            'configure custom-data 33 json add-bool "/smPolicyDecision/qosDecs/qosIdForDefault1/qnc" "false"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault2"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault2'
            '/qosId" qosIdForDefault2',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault2/5qi" 9',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault2/arp"',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault2/arp/priorityLevel" '
            "4",
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault2/maxbrUl" "5 Gbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault2/maxbrDl" "6 Gbps"',
            'configure custom-data 33 json add-bool "/smPolicyDecision/qosDecs/qosIdForDefault2/qnc" "false"',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs/tcIdForDefault1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1'
            '/tcId" tcIdForDefault1',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1'
            '/flowStatus" ENABLED',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs/tcIdForDefault2"',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault2'
            '/tcId" tcIdForDefault2',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault2'
            '/flowStatus" ENABLED',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1'
            '/pccRuleId" dynamicPolicyRule1',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDescription" "permit out 17 from 10.57.240.20 to any"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDescription" "permit in 17 from any to 10.57.240.20"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDirection" BIDIRECTIONAL',
            'configure custom-data 33 json add-number "/smPolicyDecision/pccRules/dynamicPolicyRule1/precedence" 3',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/refQosData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/refQosData'
            '/-" qosIdForDefault1',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/refTcData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/refTcData'
            '/-" tcIdForDefault1',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule2"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule2'
            '/pccRuleId" dynamicPolicyRule2',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule2/flowInfos"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule2/flowInfos/0"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule2/flowInfos/0'
            '/flowDescription" "permit out 17 from 10.57.240.21 to any"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule2/flowInfos/0'
            '/flowDescription" "permit in 17 from any to 10.57.240.21"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule2/flowInfos/0'
            '/flowDirection" BIDIRECTIONAL',
            'configure custom-data 33 json add-number "/smPolicyDecision/pccRules/dynamicPolicyRule2/precedence" 3',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule2/refQosData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule2/refQosData'
            '/-" qosIdForDefault2',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule2/refTcData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule2/refTcData'
            '/-" tcIdForDefault2',
            'configure custom-data 33 json add-array "/smPolicyDecision/lastReqRuleData"',
            'configure custom-data 33 json add-object "/smPolicyDecision/lastReqRuleData/0"',
            'configure custom-data 33 json add-array "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds"',
            'configure custom-data 33 json add-string "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds'
            '/-" dynamicPolicyRule1',
            'configure custom-data 33 json add-string "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds'
            '/-" dynamicPolicyRule2',
            'configure custom-data 33 json add-array "/smPolicyDecision/policyCtrlReqTriggers"',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" SAREA_CH',
            "configure pcf-profile 1 policy-notification-data 33",
            "proc node pcf 1 policy-update-notify all",
        )

        for cmd in cmdList:
            self.process.sendline(cmd)
            self.process.expect("CLI>")
            output = self.process.before
            print(output)

    def pcf_add_two_QoS_5QI2_1(self):
        cmdList = (
            "configure create custom-data 33",
            'configure custom-data 33 json add-object "/smPolicyDecision"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1'
            '/qosId" qosIdForDefault1',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault1/5qi" 2',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault1/arp"',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault1/arp/priorityLevel" '
            "3",
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/maxbrUl" "6 Gbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/maxbrDl" "10 Gbps"',
            'configure custom-data 33 json add-bool "/smPolicyDecision/qosDecs/qosIdForDefault1/qnc" "false"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault2"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault2'
            '/qosId" qosIdForDefault2',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault2/5qi" 1',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault2/arp"',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault2/arp/priorityLevel" '
            "4",
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault2/maxbrUl" "5 Gbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault2/maxbrDl" "6 Gbps"',
            'configure custom-data 33 json add-bool "/smPolicyDecision/qosDecs/qosIdForDefault2/qnc" "false"',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs/tcIdForDefault1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1'
            '/tcId" tcIdForDefault1',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1'
            '/flowStatus" ENABLED',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs/tcIdForDefault2"',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault2'
            '/tcId" tcIdForDefault2',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault2'
            '/flowStatus" ENABLED',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1'
            '/pccRuleId" dynamicPolicyRule1',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDescription" "permit out 17 from 10.57.240.20 to any"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDescription" "permit in 17 from any to 10.57.240.20"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDirection" BIDIRECTIONAL',
            'configure custom-data 33 json add-number "/smPolicyDecision/pccRules/dynamicPolicyRule1/precedence" 3',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/refQosData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/refQosData'
            '/-" qosIdForDefault1',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/refTcData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/refTcData'
            '/-" tcIdForDefault1',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule2"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule2'
            '/pccRuleId" dynamicPolicyRule2',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule2/flowInfos"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule2/flowInfos/0"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule2/flowInfos/0'
            '/flowDescription" "permit out 17 from 10.57.240.21 to any"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule2/flowInfos/0'
            '/flowDescription" "permit in 17 from any to 10.57.240.21"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule2/flowInfos/0'
            '/flowDirection" BIDIRECTIONAL',
            'configure custom-data 33 json add-number "/smPolicyDecision/pccRules/dynamicPolicyRule2/precedence" 3',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule2/refQosData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule2/refQosData'
            '/-" qosIdForDefault2',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule2/refTcData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule2/refTcData'
            '/-" tcIdForDefault2',
            'configure custom-data 33 json add-array "/smPolicyDecision/lastReqRuleData"',
            'configure custom-data 33 json add-object "/smPolicyDecision/lastReqRuleData/0"',
            'configure custom-data 33 json add-array "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds"',
            'configure custom-data 33 json add-string "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds'
            '/-" dynamicPolicyRule1',
            'configure custom-data 33 json add-string "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds'
            '/-" dynamicPolicyRule2',
            'configure custom-data 33 json add-array "/smPolicyDecision/policyCtrlReqTriggers"',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" SAREA_CH',
            "configure pcf-profile 1 policy-notification-data 33",
            "proc node pcf 1 policy-update-notify all",
        )

        for cmd in cmdList:
            self.process.sendline(cmd)
            self.process.expect("CLI>")
            output = self.process.before
            print(output)

    def pcf_Del_one_QoS(self):
        cmdList = (
            "configure create custom-data 33",
            "configure custom-data 33 json add-object /smPolicyDecision",
            "configure custom-data 33 json add-object /smPolicyDecision/pccRules",
            'configure custom-data 33 json add-null "/smPolicyDecision/qosDecs/qosIdForDefault1"',
            "configure custom-data 33 json add-null /smPolicyDecision/pccRules/dynamicPolicyRule1",
            "configure pcf-profile 1 policy-notification-data 33",
            "proc node pcf 1 policy-update-notify all",
        )

        for cmd in cmdList:
            self.process.sendline(cmd)
            self.process.expect("CLI>")
            output = self.process.before
            print(output)

    def pcf_Del_two_QoS(self):
        cmdList = (
            "configure create custom-data 33",
            "configure custom-data 33 json add-object /smPolicyDecision",
            "configure custom-data 33 json add-object /smPolicyDecision/pccRules",
            "configure custom-data 33 json add-null /smPolicyDecision/pccRules/dynamicPolicyRule1",
            "configure custom-data 33 json add-null /smPolicyDecision/pccRules/dynamicPolicyRule2",
            "configure pcf-profile 1 policy-notification-data 33",
            "proc node pcf 1 policy-update-notify all",
        )

        for cmd in cmdList:
            self.process.sendline(cmd)
            self.process.expect("CLI>")
            output = self.process.before
            print(output)

    def pcf_add_QoS_for_delete(self):
        cmdList = (
            "configure create custom-data 33",
            'configure custom-data 33 json add-object "/smPolicyDecision"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1'
            '/qosId" qosIdForDefault1',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault1/5qi" 8',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault1/arp"',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault1/arp'
            '/priorityLevel" 3',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/maxbrUl" "6 Gbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/maxbrDl" "10 Gbps"',
            'configure custom-data 33 json add-bool "/smPolicyDecision/qosDecs/qosIdForDefault1/qnc" "false"',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs/tcIdForDefault1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1'
            '/tcId" tcIdForDefault1',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1'
            '/flowStatus" ENABLED',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1'
            '/pccRuleId" dynamicPolicyRule2',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDescription" "permit out 17 from 10.57.240.20 to any"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDescription" "permit in 17 from any to 10.57.240.20"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDirection" BIDIRECTIONAL',
            'configure custom-data 33 json add-number "/smPolicyDecision/pccRules/dynamicPolicyRule1/precedence" 3',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/refQosData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/refQosData'
            '/-" qosIdForDefault1',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/refTcData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/refTcData'
            '/-" tcIdForDefault1',
            'configure custom-data 33 json add-array "/smPolicyDecision/lastReqRuleData"',
            'configure custom-data 33 json add-object "/smPolicyDecision/lastReqRuleData/0"',
            'configure custom-data 33 json add-array "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds"',
            'configure custom-data 33 json add-string "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds'
            '/-" dynamicPolicyRule1',
            'configure custom-data 33 json add-array "/smPolicyDecision/policyCtrlReqTriggers"',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" SAREA_CH',
            "configure pcf-profile 1 policy-notification-data 33",
            "proc node pcf 1 policy-update-notify all",
        )

        for cmd in cmdList:
            self.process.sendline(cmd)
            self.process.expect("CLI>")
            output = self.process.before
            print(output)

    def pcf_delete_added_QoS(self):
        cmdList = (
            "configure create custom-data 33",
            'configure custom-data 33 json add-object "/smPolicyDecision"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1'
            '/qosId" qosIdForDefault1',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault1/5qi" 8',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault1/arp"',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault1/arp'
            '/priorityLevel" 3',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/maxbrUl" "6 Gbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/maxbrDl" "10 Gbps"',
            'configure custom-data 33 json add-bool "/smPolicyDecision/qosDecs/qosIdForDefault1/qnc" "false"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault3"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault3'
            '/qosId" qosIdForDefault3',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault3/5qi" 7',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault3/arp"',
            'configure custom-data 33 json add-number "/smPolicyDecision/qosDecs/qosIdForDefault3/arp'
            '/priorityLevel" 7',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault3/maxbrUl" "4 Gbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault3/maxbrDl" "4 Gbps"',
            'configure custom-data 33 json add-bool "/smPolicyDecision/qosDecs/qosIdForDefault3/qnc" "false"',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs/tcIdForDefault1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1'
            '/tcId" tcIdForDefault1',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1'
            '/flowStatus" ENABLED',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs/tcIdForDefault3"',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault3'
            '/tcId" tcIdForDefault3',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault3'
            '/flowStatus" ENABLED',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1'
            '/pccRuleId" dynamicPolicyRule1',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDescription" "permit out 17 from 10.57.240.20 to any"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDescription" "permit in 17 from any to 10.57.240.20"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/flowInfos/0'
            '/flowDirection" BIDIRECTIONAL',
            'configure custom-data 33 json add-number "/smPolicyDecision/pccRules/dynamicPolicyRule1/precedence" 3',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/refQosData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/refQosData'
            '/-" qosIdForDefault1',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule1/refTcData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule1/refTcData'
            '/-" tcIdForDefault1',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule3"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule3'
            '/pccRuleId" dynamicPolicyRule3',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule3/flowInfos"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/dynamicPolicyRule3/flowInfos/0"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule3/flowInfos/0'
            '/flowDescription" "permit out 17 from 10.57.240.23 to any"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule3/flowInfos/0'
            '/flowDescription" "permit in 17 from any to 10.57.240.23"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule3/flowInfos/0'
            '/flowDirection" BIDIRECTIONAL',
            'configure custom-data 33 json add-number "/smPolicyDecision/pccRules/dynamicPolicyRule3/precedence" 3',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule3/refQosData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule3/refQosData'
            '/-" qosIdForDefault3',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/dynamicPolicyRule3/refTcData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/dynamicPolicyRule3/refTcData'
            '/-" tcIdForDefault3',
            'configure custom-data 33 json add-array "/smPolicyDecision/lastReqRuleData"',
            'configure custom-data 33 json add-object "/smPolicyDecision/lastReqRuleData/0"',
            'configure custom-data 33 json add-array "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds"',
            'configure custom-data 33 json add-string "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds'
            '/-" dynamicPolicyRule1',
            'configure custom-data 33 json add-string "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds'
            '/-" dynamicPolicyRule3',
            "configure custom-data 33 json add-null / smPolicyDecision / pccRules / dynamicPolicyRule2",
            'configure custom-data 33 json add-array "/smPolicyDecision/policyCtrlReqTriggers"',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" SAREA_CH',
            "configure pcf-profile 1 policy-notification-data 33",
            "proc node pcf 1 policy-update-notify all",
        )

        for cmd in cmdList:
            self.process.sendline(cmd)
            self.process.expect("CLI>")
            output = self.process.before
            print(output)

    def pcf_disconnect(self):
        self.process.kill(0)

    def pcf_add_and_delete_QoS(self):
        self.pcf_add_QoS_for_delete
        self.pcf_delete_added_QoS
