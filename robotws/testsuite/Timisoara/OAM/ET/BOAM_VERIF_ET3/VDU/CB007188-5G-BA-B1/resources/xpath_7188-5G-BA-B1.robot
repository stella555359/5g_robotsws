*** Variables ***
${Configuration_button}         xpath=//p-button[@title="Parameter Editor"]

${Properties_tab}           //*[@id="open-detail-panel-button"]/span[1]

${Status_button}            //*[@id="webem-root"]/div/div/webem-single-column-layout-with-actions-bar/
...  webem-page-layout/div/webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[2]/i

${Cell}                     //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...  ui-webem-panel-split/as-split/div[2]/div/div/vdu-cells-status/div/status-shared-operations-view/
...  div[2]/status-shared-tile-grid/div/span/ui-webem-vdu-cell-tile/ui-webem-tile-tooltip/div/div/div

${ConfigPlans_list}         //*[@id="configuration-plans-dropdown"]/div/div[2]/span

${connection_lost_message}      //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...  webem-server-connection-notification/div/span
