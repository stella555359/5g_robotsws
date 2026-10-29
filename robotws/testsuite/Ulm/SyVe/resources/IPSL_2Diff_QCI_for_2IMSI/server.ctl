IpslVersion 2.0;

SimulatorControlFile;



TestBlock
  Resources = 0..127;
  On Message(CER)
    Start CEA_Server;
  On Message(DWR)
    Start DWA_Server;
  On Message(DPR)
    Start DPA_Server;
  On Message(CCR)
    Start CCA_Server;

EndTestBlock;