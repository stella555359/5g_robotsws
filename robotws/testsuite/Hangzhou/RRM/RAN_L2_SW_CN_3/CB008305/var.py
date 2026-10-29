test_content = {"ConnectionSetup": {"ConnectionType": "ndis"},
                "Protocol": "UDP",
                "ProtocolVer": 2,
                "TestType": "UL",
                "Address": "10.106.164.180",
                "Port": 5021,
                "TestTime": 120,
                "UDPBandwidth": 80000,
                "UDPBufferSize": 1024,
                "UDPPacketSize": 1400,
                "Thread": 1
                }
TestPlans = {
    "TestPlans": [{
      "TestTasks": [{
        "TaskName": "Bandwidth Test",
        "TaskEnable": True,
        "TaskType": "iperf",
        "TestTimes": 10,
        "TestInterval": 10,
        "CyclePeriod": 180,
        "TestContent": test_content
                  }]
                }]
    }
