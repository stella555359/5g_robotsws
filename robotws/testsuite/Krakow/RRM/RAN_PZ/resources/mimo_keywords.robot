*** Keywords ***

Enable Rank2 MIMO For Uplink
   Configure NRCELL Type   physical_cell_id=${physical_cell_id}
   ...              value=2DL2UL
   Configure MIMO   physical_cell_id=${physical_cell_id}
   ...              stream=uplink
   ...              mode=Closed loop Spatial Multiplexing (2x2)

Enable Rank2 MIMO For Downlink
   Configure NRCELL Type   physical_cell_id=${physical_cell_id}
   ...              value=2DL2UL
   Configure MIMO   physical_cell_id=${physical_cell_id}
   ...              stream=downlink
   ...              mode=2x2 Closed Loop Spatial Multiplexing


Enable Rank2 MIMO For Uplink And Downlink
   Enable Rank2 MIMO For Uplink
   Enable Rank2 MIMO For Downlink