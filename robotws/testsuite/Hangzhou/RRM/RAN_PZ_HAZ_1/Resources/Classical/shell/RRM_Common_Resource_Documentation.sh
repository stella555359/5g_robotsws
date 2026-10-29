if [ -d "documentation" ]; then
  rm -rf documentation
fi
mkdir documentation
python -m robot.libdoc ../RRM_BTS.robot ./documentation/RRM_BTS.html
python -m robot.libdoc ../RRM_Capture_Analysis_Log.robot ./documentation/RRM_Capture_Analysis_Log.html
python -m robot.libdoc ../RRM_Common_Setup_Teardown.robot ./documentation/RRM_Common_Setup_Teardown.html
python -m robot.libdoc ../RRM_Counter_KPI.robot ./documentation/RRM_Counter_KPI.html
python -m robot.libdoc ../RRM_File_Operation.robot ./documentation/RRM_File_Operation.html
python -m robot.libdoc ../RRM_UE.robot ./documentation/RRM_UE.html
python -m robot.libdoc ../device_connection/PA.robot ./documentation/PA.html
python -m robot.libdoc ../device_connection/PB.robot ./documentation/PB.html
python -m robot.libdoc ../python/gnb_tool.py ./documentation/gnb_tool.html
python -m robot.libdoc ../python/DCAP/dcap_control.py ./documentation/dcap_control.html
