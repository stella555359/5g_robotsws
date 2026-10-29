# Script for Decoding Dcap Logs containing ttitrace pcap files across Various folders
Pre-requisites to run the script:  
Make sure you have python >= 3.13  

Intial Setup:  
### In the script directory  
```python setup.py```  
### To activate the environment created, This environment needs to be activated when you run the script  
```./.tti_env/scripts/activate```  

### If you want to install the requirements system wide, you can use this command in the SCRIPT directory  
```pip install -r requirements.txt```  

### To use the script to decode Dcap Logs containing .pcap files, you can use this command in the SCRIPT directory  
```python main.py path/to/your/zip/folder```  

### The folder structure from Dcap Logs it expects:  
```zip_folder/  
└── 2085003052/  
    ├── 0800/  
    │   ├── trace1.pcap  
    │   ├── trace2.pcap  
    │   └── trace3.pcap  
    └── 0900/  
        ├── trace1.pcap  
        ├── trace2.pcap  
        └── trace3.pcap  
```

### After the script process finishing  
After  
```unzip_folder/  
└── 2085003052/  
    ├── 0800/  
    │   ├── ssgEvaluationData.csv  
    │   ├── ulDci_decode.csv  
    │   └── dl_dci_decode.csv...etc...  
    └── 0900/  
        ├── ssgEvaluationData.csv  
        ├── ulDci_decode.csv  
        └── ulDci_decode.csv ...etc..  
``` 


