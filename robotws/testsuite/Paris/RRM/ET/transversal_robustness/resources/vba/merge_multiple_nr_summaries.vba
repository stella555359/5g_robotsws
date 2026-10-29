Sub MergeMultipleNRSummaries()
    '
    ' Macro to merge multiple NR summary Excel files into a single consolidated file
    '
    ' Expected structure of input files:
    '   kpi_name | object_name | date1 | date2 | date3 | ...
    '
    ' Instructions:
    ' 1. Open Excel
    ' 2. Alt+F11 to open VBA editor
    ' 3. Insert > Module
    ' 4. Paste this code
    ' 5. Execute with F5
    '

    Dim fileDialog As fileDialog
    Dim selectedFiles As Variant
    Dim fileCount As Long
    Dim i As Long, j As Long, k As Long, sheetIdx As Long
    Dim wb As Workbook
    Dim ws As Worksheet
    Dim outputWb As Workbook
    Dim outputWs As Worksheet
    Dim consolidatedData As Object
    Dim consolidatedData2 As Object
    Dim allDates As Object
    Dim allDates2 As Object
    Dim key As Variant
    Dim kpiName As String, objectName As String
    Dim lastRow As Long, lastCol As Long
    Dim dateCol As Variant
    Dim value As Variant
    Dim dateValues As Object
    Dim sortedDates() As String
    Dim sortedKeys() As String
    Dim dateCount As Long
    Dim rowIdx As Long, colIdx As Long
    Dim tempDate As String, tempKey As String
    Dim outputPath As String

    ' Initialize dictionaries for both sheets
    Set consolidatedData = CreateObject("Scripting.Dictionary")
    Set allDates = CreateObject("Scripting.Dictionary")
    Set consolidatedData2 = CreateObject("Scripting.Dictionary")
    Set allDates2 = CreateObject("Scripting.Dictionary")

    ' Dictionary for RefToDescription (Counter_or_KPI -> Comment)
    Dim refToDesc As Object
    Set refToDesc = CreateObject("Scripting.Dictionary")

    ' Ask user to select files
    Set fileDialog = Application.fileDialog(msoFileDialogFilePicker)
    With fileDialog
        .Title = "Sélectionner les fichiers NR Summary à fusionner"
        .AllowMultiSelect = True

        If .Show = -1 Then
            Set selectedFiles = .SelectedItems
            fileCount = .SelectedItems.Count
        Else
            MsgBox "Aucun fichier sélectionné. Opération annulée.", vbExclamation
            Exit Sub
        End If
    End With

    If fileCount = 0 Then
        MsgBox "Aucun fichier sélectionné.", vbExclamation
        Exit Sub
    End If

    Application.ScreenUpdating = False
    Application.StatusBar = "Reading and merging files..."

    ' Read each file (process the first 2 sheets)
    For i = 1 To fileCount
        Application.StatusBar = "Reading file " & i & "/" & fileCount & "..."

        On Error Resume Next
        Set wb = Workbooks.Open(selectedFiles(i), ReadOnly:=True)
        On Error GoTo 0

        If wb Is Nothing Then
            MsgBox "Error opening file: " & selectedFiles(i), vbExclamation
            GoTo NextFile
        End If

        ' Process the first 2 sheets
        For sheetIdx = 1 To 2
            If sheetIdx > wb.Sheets.Count Then Exit For

            Set ws = wb.Sheets(sheetIdx)

            ' Check structure (ignore empty lines at the beginning)
            Dim headerRow As Long
            headerRow = 1
            Do While ws.Cells(headerRow, 1).value = "" And headerRow < 10
                headerRow = headerRow + 1
            Loop

            Dim header1 As String, header2 As String
            header1 = Trim(LCase(CStr(ws.Cells(headerRow, 1).value)))
            header2 = Trim(LCase(CStr(ws.Cells(headerRow, 2).value)))

            ' Vérifier si c'est un onglet RefToDescription
            If header1 = "counter_or_kpi" And InStr(LCase(header2), "comment") > 0 Then
                ' Traiter le RefToDescription
                lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).row

                For j = headerRow + 1 To lastRow
                    Dim kpiId As String, kpiComment As String
                    kpiId = Trim(CStr(ws.Cells(j, 1).value))
                    kpiComment = Trim(CStr(ws.Cells(j, 2).value))

                    If kpiId <> "" And Not refToDesc.Exists(kpiId) Then
                        refToDesc.Add kpiId, kpiComment
                    End If
                Next j
                GoTo NextSheet
            End If

            If header1 <> "kpi_name" Or header2 <> "object_name" Then
                ' Afficher un message seulement si ce n'est pas un onglet vide
                If ws.Cells(headerRow, 1).value <> "" Then
                    MsgBox "Structure incorrecte dans l'onglet " & sheetIdx & " ('" & ws.Name & "') du fichier: " & wb.Name & vbCrLf & _
                           "Trouvé: '" & ws.Cells(headerRow, 1).value & "' et '" & ws.Cells(headerRow, 2).value & "'" & vbCrLf & _
                           "Attendu: 'kpi_name' et 'object_name' comme premiers en-têtes.", vbInformation
                End If
                GoTo NextSheet
            End If

            ' Trouver la dernière ligne et colonne (à partir de headerRow)
            lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).row
            lastCol = ws.Cells(headerRow, ws.Columns.Count).End(xlToLeft).Column

            If lastCol < 3 Then
                MsgBox "L'onglet " & sheetIdx & " ('" & ws.Name & "') du fichier " & wb.Name & " n'a pas de colonnes de dates.", vbInformation
                GoTo NextSheet
            End If

            ' Sélectionner le dictionnaire approprié
            Dim currentData As Object
            Dim currentDates As Object
            If sheetIdx = 1 Then
                Set currentData = consolidatedData
                Set currentDates = allDates
            Else
                Set currentData = consolidatedData2
                Set currentDates = allDates2
            End If

            ' Lire les colonnes de dates (à partir de la colonne 3)
            For j = 3 To lastCol
                dateCol = ws.Cells(headerRow, j).value
                If dateCol <> "" Then
                    If Not currentDates.Exists(CStr(dateCol)) Then
                        currentDates.Add CStr(dateCol), True
                    End If
                End If
            Next j

            ' Lire les données (à partir de headerRow + 1)
            For j = headerRow + 1 To lastRow
                kpiName = Trim(CStr(ws.Cells(j, 1).value))
                objectName = Trim(CStr(ws.Cells(j, 2).value))

                If kpiName <> "" And objectName <> "" Then
                    key = kpiName & "|" & objectName

                    ' Initialiser le dictionnaire pour cette clé si nécessaire
                    If Not currentData.Exists(key) Then
                        Set dateValues = CreateObject("Scripting.Dictionary")
                        currentData.Add key, dateValues
                    Else
                        Set dateValues = currentData(key)
                    End If

                    ' Ajouter les valeurs pour chaque date
                    For k = 3 To lastCol
                        dateCol = CStr(ws.Cells(headerRow, k).value)
                        If dateCol <> "" Then
                            value = ws.Cells(j, k).value

                            If Not IsEmpty(value) And value <> "" And value <> "None" Then
                                If Not dateValues.Exists(dateCol) Then
                                    dateValues.Add dateCol, value
                                End If
                            ElseIf Not dateValues.Exists(dateCol) Then
                                dateValues.Add dateCol, "None"
                            End If
                        End If
                    Next k
                End If
            Next j

NextSheet:
        Next sheetIdx

        wb.Close False

NextFile:
    Next i

    ' Check that we have data
    If consolidatedData.Count = 0 And consolidatedData2.Count = 0 And refToDesc.Count = 0 Then
        MsgBox "No data found in selected files.", vbExclamation
        Application.StatusBar = False
        Application.ScreenUpdating = True
        Exit Sub
    End If

    Application.StatusBar = "Creating consolidated file..."

    ' Create output workbook
    Set outputWb = Workbooks.Add

    ' Delete default sheets except one
    Application.DisplayAlerts = False
    Do While outputWb.Sheets.Count > 1
        outputWb.Sheets(outputWb.Sheets.Count).Delete
    Loop
    Application.DisplayAlerts = True

    ' Delete first sheet if we don't have data for sheet1
    ' and create a temporary sheet if needed
    If consolidatedData.Count = 0 Then
        ' No data for first sheet, we'll delete it later
        ' but we need it temporarily
    End If

    ' ===== Process first sheet =====
    If consolidatedData.Count > 0 Then
        Set outputWs = outputWb.Sheets(1)
        outputWs.Name = "Sheet1"  ' Default name for compatibility

        Call WriteConsolidatedSheet(outputWs, consolidatedData, allDates)
    End If

    ' ===== Process RefToDescription in second position =====
    If refToDesc.Count > 0 Then
        If consolidatedData.Count > 0 Then
            ' Add after Sheet1
            Set outputWs = outputWb.Sheets.Add(After:=outputWb.Sheets(1))
        Else
            ' Use existing first sheet
            Set outputWs = outputWb.Sheets(1)
        End If
        outputWs.Name = "RefToDescription"

        Call WriteRefToDescription(outputWs, refToDesc)
    End If

    ' ===== Process second data sheet (in 3rd position) =====
    If consolidatedData2.Count > 0 Then
        Set outputWs = outputWb.Sheets.Add(After:=outputWb.Sheets(outputWb.Sheets.Count))
        outputWs.Name = "Consolidated_Sheet2"

        Call WriteConsolidatedSheet(outputWs, consolidatedData2, allDates2)
    End If

    ' Delete first sheet if empty
    If consolidatedData.Count = 0 Then
        Application.DisplayAlerts = False
        ' First sheet is now RefToDescription or Consolidated_Sheet2
        ' Don't delete anything as everything is used
        Application.DisplayAlerts = True
    End If

    ' Ask where to save the file
    outputPath = Application.GetSaveAsFilename( _
        FileFilter:="Fichiers Excel (*.xlsx), *.xlsx", _
        Title:="Enregistrer le fichier consolidé")

    If outputPath <> "Faux" Then
        outputWb.SaveAs outputPath
        Dim totalRows As Long
        totalRows = 0
        If consolidatedData.Count > 0 Then totalRows = totalRows + consolidatedData.Count
        If consolidatedData2.Count > 0 Then totalRows = totalRows + consolidatedData2.Count

        ' Intermediate message
        Application.StatusBar = "Merge completed. Creating charts..."

        ' ===== NEW: Automatically create pivots and charts =====
        If consolidatedData.Count > 0 Then
            Call CreerPivotsEtGraphiques(outputWb)
            Call CreerGraphiqueLabTool(outputWb)
        End If
        ' ===== END NEW =====

        MsgBox "Merge and charts completed successfully!" & vbCrLf & vbCrLf & _
               "  Merged files: " & fileCount & vbCrLf & _
               "  Processed sheets: " & outputWb.Sheets.Count & vbCrLf & _
               "  Total rows: " & totalRows & vbCrLf & vbCrLf & _
               "  Output file: " & vbCrLf & "    " & outputPath, _
               vbInformation, "NR Summary Consolidation"
    Else
        MsgBox "Save cancelled. Consolidated workbook remains open.", vbInformation
    End If

    Application.StatusBar = False
    Application.ScreenUpdating = True

    Set consolidatedData = Nothing
    Set consolidatedData2 = Nothing
    Set allDates = Nothing
    Set allDates2 = Nothing
    Set dateValues = Nothing
    Set refToDesc = Nothing

End Sub

' ===== Sous-routine pour écrire RefToDescription =====
Sub WriteRefToDescription(outputWs As Worksheet, refToDesc As Object)
    Dim i As Long
    Dim key As Variant
    Dim sortedKeys() As String
    Dim keyCount As Long
    Dim tempKey As String

    ' Trier les clés (Counter_or_KPI)
    keyCount = refToDesc.Count
    ReDim sortedKeys(1 To keyCount)
    i = 1
    For Each key In refToDesc.Keys
        sortedKeys(i) = key
        i = i + 1
    Next key

    ' Tri à bulles
    For i = 1 To keyCount - 1
        Dim j As Long
        For j = i + 1 To keyCount
            If sortedKeys(i) > sortedKeys(j) Then
                tempKey = sortedKeys(i)
                sortedKeys(i) = sortedKeys(j)
                sortedKeys(j) = tempKey
            End If
        Next j
    Next i

    ' Écrire les en-têtes
    outputWs.Cells(1, 1).value = "Counter_or_KPI"
    outputWs.Cells(1, 2).value = "Comment from MIND/JUMP"

    ' Mettre les en-têtes en gras
    outputWs.Rows(1).Font.Bold = True

    ' Écrire les données
    For i = 1 To keyCount
        key = sortedKeys(i)
        outputWs.Cells(i + 1, 1).value = key
        outputWs.Cells(i + 1, 2).value = refToDesc(key)
    Next i

    ' Ajuster la largeur des colonnes
    outputWs.Columns("A").ColumnWidth = 20
    outputWs.Columns("B").ColumnWidth = 60

End Sub

' ===== Sous-routine pour écrire un onglet consolidé =====
Sub WriteConsolidatedSheet(outputWs As Worksheet, consolidatedData As Object, allDates As Object)
    Dim i As Long, j As Long
    Dim key As Variant
    Dim dateCol As Variant
    Dim value As Variant
    Dim dateValues As Object
    Dim sortedDates() As String
    Dim sortedKeys() As String
    Dim dateCount As Long
    Dim keyCount As Long
    Dim rowIdx As Long
    Dim tempDate As String, tempKey As String
    Dim parts() As String

    ' Trier les dates
    dateCount = allDates.Count
    ReDim sortedDates(1 To dateCount)
    i = 1
    For Each dateCol In allDates.Keys
        sortedDates(i) = CStr(dateCol)
        i = i + 1
    Next dateCol

    ' Tri à bulles des dates
    For i = 1 To dateCount - 1
        For j = i + 1 To dateCount
            If sortedDates(i) > sortedDates(j) Then
                tempDate = sortedDates(i)
                sortedDates(i) = sortedDates(j)
                sortedDates(j) = tempDate
            End If
        Next j
    Next i

    ' Trier les clés (kpi_name|object_name)
    keyCount = consolidatedData.Count
    ReDim sortedKeys(1 To keyCount)
    i = 1
    For Each key In consolidatedData.Keys
        sortedKeys(i) = key
        i = i + 1
    Next key

    ' Tri à bulles des clés
    For i = 1 To keyCount - 1
        For j = i + 1 To keyCount
            If sortedKeys(i) > sortedKeys(j) Then
                tempKey = sortedKeys(i)
                sortedKeys(i) = sortedKeys(j)
                sortedKeys(j) = tempKey
            End If
        Next j
    Next i

    ' Write headers
    outputWs.Cells(1, 1).value = "kpi_name"
    outputWs.Cells(1, 2).value = "object_name"
    For i = 1 To dateCount
        outputWs.Cells(1, i + 2).value = sortedDates(i)
    Next i

    ' Make headers bold
    outputWs.Rows(1).Font.Bold = True

    ' Write data
    rowIdx = 2
    For i = 1 To keyCount
        key = sortedKeys(i)
        parts = Split(key, "|")

        outputWs.Cells(rowIdx, 1).value = parts(0) ' kpi_name
        outputWs.Cells(rowIdx, 2).value = parts(1) ' object_name

        Set dateValues = consolidatedData(key)

        For j = 1 To dateCount
            dateCol = sortedDates(j)
            If dateValues.Exists(dateCol) Then
                value = dateValues(dateCol)
            Else
                value = "None"
            End If
            outputWs.Cells(rowIdx, j + 2).value = value
        Next j

        rowIdx = rowIdx + 1
    Next i

    ' Adjust column widths
    outputWs.Columns("A:B").ColumnWidth = 15
    For i = 3 To 2 + dateCount
        outputWs.Columns(i).ColumnWidth = 20
    Next i

End Sub

' ================================================================
' SECTION: CREATING PIVOTS AND CHARTS
' ================================================================

Sub CreerPivotsEtGraphiques(wb As Workbook)
    '
    ' Procedure to create pivots and charts on the merged workbook
    ' Called automatically after merge
    '

    Dim ws As Worksheet
    Dim wsNormalized As Worksheet
    Dim wsPivot As Worksheet
    Dim pc As PivotCache
    Dim pt As PivotTable
    Dim dataRange As Range
    Dim lastRow As Long
    Dim lastCol As Long
    Dim i As Long, j As Long
    Dim newRow As Long
    Dim cellValue As Variant

    ' Vérifier que la feuille de données existe
    On Error Resume Next
    Set ws = wb.Sheets(1)
    On Error GoTo 0

    If ws Is Nothing Then Exit Sub

    ' Vérifier la structure
    If ws.Cells(1, 1).value <> "kpi_name" Or ws.Cells(1, 2).value <> "object_name" Then
        Exit Sub
    End If

    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.StatusBar = "Transforming data for pivot..."

    ' Determine source data range
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).row
    lastCol = ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column

    If lastRow < 2 Then
        Application.ScreenUpdating = True
        Application.StatusBar = False
        Exit Sub
    End If

    ' Supprimer les feuilles existantes si elles existent
    On Error Resume Next
    Application.DisplayAlerts = False
    wb.Sheets("Données_Normalisées").Delete
    wb.Sheets("Pivot").Delete
    wb.Sheets("Chart_Accessibility").Delete
    wb.Sheets("Chart_Retainability").Delete
    wb.Sheets("Chart_Integrity").Delete
    wb.Sheets("Chart_Usage_Utilization").Delete
    wb.Sheets("Chart_Usage_Capacity").Delete
    wb.Sheets("Chart_Mobility").Delete
    wb.Sheets("Chart_Others").Delete
    wb.Sheets("Chart_PS_BWP").Delete
    Application.DisplayAlerts = True
    On Error GoTo 0

    ' Créer une nouvelle feuille pour les données normalisées
    Set wsNormalized = wb.Sheets.Add(After:=ws)
    wsNormalized.Name = "Données_Normalisées"

    ' Créer les en-têtes pour le format liste
    wsNormalized.Cells(1, 1).value = "kpi_name"
    wsNormalized.Cells(1, 2).value = "object_name"
    wsNormalized.Cells(1, 3).value = "date"
    wsNormalized.Cells(1, 4).value = "valeur"
    wsNormalized.Range("A1:D1").Font.Bold = True

    ' Transformer les données: de pivot plat vers liste
    newRow = 2

    For i = 2 To lastRow
        For j = 3 To lastCol
            cellValue = ws.Cells(i, j).value

            wsNormalized.Cells(newRow, 1).value = ws.Cells(i, 1).value  ' kpi_name
            wsNormalized.Cells(newRow, 2).value = ws.Cells(i, 2).value  ' object_name
            wsNormalized.Cells(newRow, 3).value = ws.Cells(1, j).value  ' date

            If cellValue = "None" Or IsEmpty(cellValue) Or cellValue = "" Then
                wsNormalized.Cells(newRow, 4).value = ""
            Else
                wsNormalized.Cells(newRow, 4).value = cellValue
            End If
            newRow = newRow + 1
        Next j
    Next i

    Application.StatusBar = "Création du tableau croisé dynamique..."

    ' Définir la plage de données normalisées
    Set dataRange = wsNormalized.Range(wsNormalized.Cells(1, 1), wsNormalized.Cells(newRow - 1, 4))

    ' Créer une nouvelle feuille pour le pivot
    Set wsPivot = wb.Sheets.Add(After:=wsNormalized)
    wsPivot.Name = "Pivot"

    ' Créer le PivotCache
    Set pc = wb.PivotCaches.Create(SourceType:=xlDatabase, SourceData:=dataRange)

    ' Créer le PivotTable
    Set pt = pc.CreatePivotTable(TableDestination:=wsPivot.Range("A3"), TableName:="PivotTableNR")

    ' Configurer le PivotTable
    With pt
        With .PivotFields("kpi_name")
            .Orientation = xlRowField
            .Position = 1
        End With

        With .PivotFields("object_name")
            .Orientation = xlRowField
            .Position = 2
        End With

        With .PivotFields("date")
            .Orientation = xlColumnField
            .Position = 1
        End With

        .ColumnRange.Orientation = 90

        With .PivotFields("valeur")
            .Orientation = xlDataField
            .Function = xlSum
            .NumberFormat = "0.00"
            .Name = "Value"
        End With

        .ColumnGrand = False
        .RowGrand = False
        .TableStyle2 = "PivotStyleMedium9"
        .NullString = ""
        .DisplayErrorString = True
        .ErrorString = ""
    End With

    wsPivot.Columns("A:B").AutoFit
    For i = 3 To 50
        wsPivot.Columns(i).ColumnWidth = 12
    Next i

    wsPivot.Range("A1").value = "Tableau Croisé Dynamique - NR KPI"
    wsPivot.Range("A1").Font.Bold = True
    wsPivot.Range("A1").Font.Size = 14

    ' Create charts by category
    Application.StatusBar = "Creating charts..."

    Call CreateChartForKpiGroup(wb, pt, wsPivot, "Accessibility", _
          Array("M55113C00001", "M55113C00002", "M55113C00003", "M55113C00004", _
              "M55124C03001", "M55124C03002", "M55124C03003", "M55124C03004", _
              "NR_5004b", "NR_5011a", "NR_5013a", "NR_5020d", "NR_5022e", "NR_5151d", _
              "NR_5152a", "NR_5167c", "NR_5326a", "NR_5345a", "NR_5400b", "NR_5885a"))

    Call CreateChartForKpiGroup(wb, pt, wsPivot, "Retainability", _
          Array("M55125C01001", "M55125C08503", "M55125C09003", "M55125C09005", _
              "M55138C00004", "M55139C00012", "NR_5032e", "NR_5635a", "NR_5636a"))

    Call CreateChartForKpiGroup(wb, pt, wsPivot, "Integrity", _
          Array("NR_417a", "NR_5054b", "NR_5055c", "NR_5056d", "NR_5057e", "NR_5060b", "NR_5061b", _
              "NR_5064a", "NR_5065a", "NR_5066a", "NR_5099a", "NR_5482a", "NR_5860a", _
              "NR_5886a", "NR_5887a", "NR_5888a", "NR_5906a", "NR_5907a", "NR_5908a", _
              "NR_5909a", "NR_5910a", "NR_5911a", "NR_5912a", "NR_5913a", "NR_5914a", _
              "NR_5915a", "NR_5916a", "NR_6095a", "NR_6096a", "NR_6098a", "NR_6097a", _
              "NR_6093a", "NR_6094a", "NR_6099a"))

    Call CreateChartForKpiGroup(wb, pt, wsPivot, "Usage_Utilization", _
        Array("NR_5067a", "NR_5068a", "NR_5069a", "NR_5076b", "NR_5088d", "NR_5089e", _
              "NR_5100c", "NR_5101b", "NR_5105a", "NR_5108e", "NR_5109g", "NR_5114b", _
              "NR_5115a", "NR_5130a", "NR_5132a", "NR_5149a", "NR_5244e", "NR_5245d", _
              "NR_5258a", "NR_5259a", "NR_5432b", "NR_5433b", "NR_5436a", "NR_5437a", _
              "NR_5504a", "NR_5513b", "NR_5594a", "NR_5873b", "NR_5889a"))

    Call CreateChartForKpiGroup(wb, pt, wsPivot, "Usage_Capacity", _
        Array("NR_5077b", "NR_5078b", "NR_5120a", "NR_5121a", "NR_5124c", "NR_5125a", _
              "NR_5128c", "NR_5129a", "NR_5333a", "NR_5333b", "NR_5415a", "NR_5593a", _
              "NR_5634a", "NR_5634b"))

    Call CreateChartForKpiGroup(wb, pt, wsPivot, "Mobility", _
        Array("M55125C09013", "M55125C09014", "M55125C09015", "M55139C00015", _
              "M55139C00016", "M55147C00001", "NR_5049b", "NR_5164a", "NR_5177b", _
              "NR_5181b", "NR_5183b", "NR_5187b", "NR_5198a", "NR_5206a", "NR_5229b", _
              "NR_5422a", "NR_5429a", "NR_5517a", "NR_5543a", "NR_5672a", "NR_5676a", _
              "NR_5682a", "NR_5687a", "NR_5694a", "NR_5699a", "NR_5712a", "NR_5717a", _
              "NR_5724a", "NR_5732a"))

    Call CreateChartForKpiGroup(wb, pt, wsPivot, "Others", _
        Array("NR_226", "NR_227b", "NR_5597b", "NR_5598b"))

    Call CreateChartForKpiGroup(wb, pt, wsPivot, "PS_BWP", _
        Array("M55351C00001", "M55351C00002", "M55351C01003", "M55351C01004", _
              "M55351C01007", "M55351C01008", "M55351C01011", "M55351C01012", _
              "M55351C01015", "M55351C01016"))

    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    Application.StatusBar = False

    ' Activate first chart sheet
    On Error Resume Next
    wb.Sheets("Chart_Accessibility").Activate
    On Error GoTo 0

    ' Release objects
    Set pt = Nothing
    Set pc = Nothing
    Set dataRange = Nothing
    Set wsPivot = Nothing
    Set wsNormalized = Nothing
    Set ws = Nothing

End Sub

Sub CreateChartForKpiGroup(wb As Workbook, pt As PivotTable, wsPivot As Worksheet, _
                           groupName As String, kpiList As Variant)
    Dim wsChart As Worksheet
    Dim cht As ChartObject
    Dim ptNew As PivotTable
    Dim pf As PivotField
    Dim pi As PivotItem
    Dim kpi As Variant
    Dim kpiExists As Boolean
    Dim kpiFoundCount As Integer

    Application.StatusBar = "Création du graphique " & groupName & "..."

    Set wsChart = wb.Sheets.Add(After:=wb.Sheets(wb.Sheets.Count))
    wsChart.Name = "Chart_" & groupName

    Set ptNew = pt.PivotCache.CreatePivotTable( _
        TableDestination:=wsChart.Range("A50"), _
        TableName:="Pivot_" & groupName)

    With ptNew
        With .PivotFields("kpi_name")
            .Orientation = xlRowField
            .Position = 1
        End With

        With .PivotFields("object_name")
            .Orientation = xlRowField
            .Position = 2
        End With

        With .PivotFields("date")
            .Orientation = xlColumnField
            .Position = 1
        End With

        With .PivotFields("valeur")
            .Orientation = xlDataField
            .Function = xlSum
            .NumberFormat = "0.00"
            .Name = "Value"
        End With

        .ColumnGrand = False
        .RowGrand = False
        .NullString = ""
    End With

    Set pf = ptNew.PivotFields("kpi_name")

    kpiFoundCount = 0
    For Each kpi In kpiList
        For Each pi In pf.PivotItems
            If pi.Name = CStr(kpi) Then
                kpiFoundCount = kpiFoundCount + 1
                Exit For
            End If
        Next pi
    Next kpi

    If kpiFoundCount = 0 Then
        Application.StatusBar = "Aucun KPI trouvé pour " & groupName & " - graphique ignoré"
        Application.DisplayAlerts = False
        wsChart.Delete
        Application.DisplayAlerts = True
        Exit Sub
    End If

    For Each pi In pf.PivotItems
        pi.Visible = True
    Next pi

    For Each pi In pf.PivotItems
        kpiExists = False
        For Each kpi In kpiList
            If pi.Name = CStr(kpi) Then
                kpiExists = True
                Exit For
            End If
        Next kpi

        If Not kpiExists Then
            On Error Resume Next
            pi.Visible = False
            On Error GoTo 0
        End If
    Next pi

    Set cht = wsChart.ChartObjects.Add(Left:=10, Top:=30, Width:=800, Height:=450)
    cht.Chart.SetSourceData Source:=ptNew.TableRange2

    With cht.Chart
        .ChartType = xlLineMarkers
        .HasTitle = True
        .ChartTitle.Text = "Evolution KPI - " & Replace(groupName, "_", " - ")
        .ChartTitle.Font.Size = 14
        .ChartTitle.Font.Bold = True

        With .Axes(xlCategory)
            .HasTitle = True
            .AxisTitle.Text = "Dates"
            .AxisTitle.Font.Size = 11
            .TickLabels.Orientation = 45
            .TickLabels.Font.Size = 9
        End With

        With .Axes(xlValue)
            .HasTitle = True
            .AxisTitle.Text = "Valeurs KPI"
            .AxisTitle.Font.Size = 11
            .HasMajorGridlines = True
        End With

        .HasLegend = True
        .Legend.Position = xlLegendPositionRight
        .Legend.Font.Size = 9
        .ChartStyle = 201
        .PlotArea.Format.Fill.Visible = msoTrue
        .PlotArea.Format.Fill.ForeColor.RGB = RGB(255, 255, 255)
    End With

    wsChart.Range("A1").value = "Graphique - " & Replace(groupName, "_", " - ")
    wsChart.Range("A1").Font.Bold = True
    wsChart.Range("A1").Font.Size = 14
    wsChart.Rows("50:100").Hidden = True

    Call AddKpiDescriptionTable(wb, wsChart, kpiList, groupName)

    Set cht = Nothing
    Set ptNew = Nothing
    Set wsChart = Nothing
    Set pf = Nothing

End Sub

Sub AddKpiDescriptionTable(wb As Workbook, wsChart As Worksheet, kpiList As Variant, groupName As String)
    Dim wsRef As Worksheet
    Dim kpi As Variant
    Dim i As Long
    Dim lastRow As Long
    Dim kpiName As String
    Dim kpiDescription As String
    Dim found As Boolean
    Dim startCol As String
    Dim currentRow As Long
    Dim nextCol As String
    Dim tableRange As Range

    On Error Resume Next
    Set wsRef = wb.Sheets("RefToDescription")
    On Error GoTo 0

    If wsRef Is Nothing Then Exit Sub

    startCol = "O"
    currentRow = 3

    wsChart.Range(startCol & currentRow).value = "KPI"
    wsChart.Range(startCol & currentRow).Font.Bold = True
    wsChart.Range(startCol & currentRow).Interior.Color = RGB(68, 114, 196)
    wsChart.Range(startCol & currentRow).Font.Color = RGB(255, 255, 255)

    nextCol = Chr(Asc(startCol) + 1)
    wsChart.Range(nextCol & currentRow).value = "Description"
    wsChart.Range(nextCol & currentRow).Font.Bold = True
    wsChart.Range(nextCol & currentRow).Interior.Color = RGB(68, 114, 196)
    wsChart.Range(nextCol & currentRow).Font.Color = RGB(255, 255, 255)

    lastRow = wsRef.Cells(wsRef.Rows.Count, 1).End(xlUp).row

    currentRow = currentRow + 1
    For Each kpi In kpiList
        kpiName = CStr(kpi)
        kpiDescription = "No description found"
        found = False

        For i = 2 To lastRow
            If wsRef.Cells(i, 1).value = kpiName Then
                kpiDescription = wsRef.Cells(i, 2).value
                found = True
                Exit For
            End If
        Next i

        wsChart.Range(startCol & currentRow).value = kpiName
        wsChart.Range(nextCol & currentRow).value = kpiDescription

        If currentRow Mod 2 = 0 Then
            wsChart.Range(startCol & currentRow & ":" & nextCol & currentRow).Interior.Color = RGB(242, 242, 242)
        End If

        currentRow = currentRow + 1
    Next kpi

    wsChart.Columns(startCol).ColumnWidth = 15
    wsChart.Columns(nextCol).ColumnWidth = 60

    Set tableRange = wsChart.Range(startCol & "3:" & nextCol & (currentRow - 1))
    tableRange.Borders.LineStyle = xlContinuous
    tableRange.Borders.Weight = xlThin
    wsChart.Columns(nextCol).WrapText = True

    Set wsRef = Nothing
    Set tableRange = Nothing

End Sub

' ================================================================
' SECTION: CREATING LAB_TOOL CHART
' ================================================================

Sub CreerGraphiqueLabTool(wb As Workbook)
    '
    ' Creates a "lab_tool" sheet with a pivot chart
    ' Allows dynamic selection of KPIs and objects via filters
    '

    Dim wsNormalized As Worksheet
    Dim wsLabTool As Worksheet
    Dim pc As PivotCache
    Dim pt As PivotTable
    Dim cht As Chart
    Dim dataRange As Range
    Dim lastRow As Long

    ' Check that normalized data sheet exists
    On Error Resume Next
    Set wsNormalized = wb.Sheets("Données_Normalisées")
    On Error GoTo 0

    If wsNormalized Is Nothing Then
        MsgBox "Normalized data sheet not found. Cannot create lab_tool chart.", vbExclamation
        Exit Sub
    End If

    Application.ScreenUpdating = False
    Application.StatusBar = "Creating lab_tool pivot chart..."

    ' Delete lab_tool sheet if it already exists
    On Error Resume Next
    Application.DisplayAlerts = False
    wb.Sheets("lab_tool").Delete
    Application.DisplayAlerts = True
    On Error GoTo 0

    ' Create new lab_tool sheet
    Set wsLabTool = wb.Sheets.Add(After:=wb.Sheets(wb.Sheets.Count))
    wsLabTool.Name = "lab_tool"

    ' Determine normalized data range
    lastRow = wsNormalized.Cells(wsNormalized.Rows.Count, 1).End(xlUp).Row
    Set dataRange = wsNormalized.Range(wsNormalized.Cells(1, 1), wsNormalized.Cells(lastRow, 4))

    ' Create PivotCache
    Set pc = wb.PivotCaches.Create(SourceType:=xlDatabase, SourceData:=dataRange)

    ' Create PivotTable
    Set pt = pc.CreatePivotTable(TableDestination:=wsLabTool.Range("A3"), TableName:="PivotTable_LabTool")

    ' Configure PivotTable
    With pt
        ' Add kpi_name to rows (will become series/legend)
        With .PivotFields("kpi_name")
            .Orientation = xlRowField
            .Position = 1
        End With

        ' Add object_name to rows (will become series/legend)
        With .PivotFields("object_name")
            .Orientation = xlRowField
            .Position = 2
        End With

        ' Add date to columns (will become X-axis)
        With .PivotFields("date")
            .Orientation = xlColumnField
            .Position = 1
        End With

        ' Add valeur as values (Y-axis)
        With .PivotFields("valeur")
            .Orientation = xlDataField
            .Function = xlSum
            .NumberFormat = "0.00"
            .Name = "Value"
        End With

        .ColumnGrand = False
        .RowGrand = False
        .NullString = ""
    End With

    ' Create PivotChart
    Set cht = wb.Charts.Add
    cht.SetSourceData Source:=pt.TableRange2
    cht.ChartType = xlLine

    ' IMPORTANT: Plot rows as X-axis and columns as series
    cht.PlotBy = xlColumns

    ' Configure chart appearance
    With cht
        .HasTitle = True
        .ChartTitle.Text = "KPI Evolution - Dynamic Selection"
        .ChartTitle.Font.Size = 14
        .ChartTitle.Font.Bold = True

        With .Axes(xlCategory)
            .HasTitle = True
            .AxisTitle.Text = "Date"
            .TickLabels.Orientation = 45
            .TickLabels.Font.Size = 9
        End With

        With .Axes(xlValue)
            .HasTitle = True
            .AxisTitle.Text = "Value"
            .HasMajorGridlines = True
        End With

        .HasLegend = True
        .Legend.Position = xlLegendPositionRight
        .Legend.Font.Size = 9
    End With

    ' Move chart to lab_tool sheet as embedded chart
    cht.Location Where:=xlLocationAsObject, Name:=wsLabTool.Name

    ' Resize chart
    With wsLabTool.ChartObjects(1)
        .Left = wsLabTool.Range("A1").Left
        .Top = wsLabTool.Range("A1").Top
        .Width = 1000
        .Height = 600
    End With

    ' Add instructions
    wsLabTool.Range("A40").Value = "Interactive Pivot Chart"
    wsLabTool.Range("A41").Value = "Use filters in the chart or pivot table to select specific KPIs and objects"
    wsLabTool.Range("A42").Value = "Each series represents a KPI + Object combination"
    wsLabTool.Range("A40:A42").Font.Italic = True
    wsLabTool.Range("A40:A42").Font.Size = 9
    wsLabTool.Range("A40:A42").Font.Color = RGB(128, 128, 128)

    Application.ScreenUpdating = True
    Application.StatusBar = False

    ' Release objects
    Set cht = Nothing
    Set pt = Nothing
    Set pc = Nothing
    Set dataRange = Nothing
    Set wsLabTool = Nothing
    Set wsNormalized = Nothing

End Sub
