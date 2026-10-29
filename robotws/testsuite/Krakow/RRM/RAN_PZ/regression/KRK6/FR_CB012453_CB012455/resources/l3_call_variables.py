L3_CALL = False
L3_CALL_RESOURCE = "taf/rfrl/ue/robot/REAL_UE.robot"
L3_CALL_KEYWORDS = \
    {"Prepare Ue for L3 Call": {"capabilities": "COMMERCIAL_UE", "alias": "UE"},
     "Verify L3 Call Data Transfer DL&UL":
         {"duration": "60s", "tput_dl": "4200 Mbits/sec", "tput_ul": "400 Mbits/sec", "deviation": "20%",
          "parallel_streams_dl": "2", "parallel_streams_ul": "2", "size_packet_dl": "1310B", "size_packet_ul": "1310B",
          "buffer_server_dl": "4M",
          "alias": "UE"},
     "Stop Using Ue": ["UE"]}
COLLECT_LOGS_DURING_DATA_TRANSFER = False
