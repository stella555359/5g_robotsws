Sub CreateConstraintFileFromScoutReport()
    '
    ' Macro pour convertir les données de l'onglet "Chart Data" en format constraint CSV
    ' Équivalent VBA du script Python parse_scout_report.py
    '
    ' Instructions:
    ' 1. Ouvrir le workbook Excel contenant l'onglet "Chart Data"
    ' 2. Alt+F11 pour ouvrir l'éditeur VBA
    ' 3. Insertion > Module
    ' 4. Coller ce code
    ' 5. Exécuter avec F5 ou depuis Excel: Développeur > Macros > CreateConstraintFileFromScoutReport
    '
    
    Dim wb As Workbook
    Dim ws As Worksheet
    Dim outputFile As String
    Dim fso As Object
    Dim fileNum As Integer
    Dim lastRow As Long
    Dim row As Long
    
    ' Dictionnaires pour stocker les données
    Dim dataDict As Object
    Dim familyDeviations As Object
    
    Dim distName As String, entryName As String, groupName As String, valueStr As String
    Dim oamId As String, counterCode As String, comment As String
    Dim key As String
    Dim value As Double
    Dim tempValues() As Double
    Dim i As Long, j As Long
    Dim newEntry As Object
    Dim currentEntry As Object
    Dim currentCount As Long
    Dim outputLines As Object
    Dim allKeys As Variant
    Dim keyParts() As String
    Dim minValue As Variant, maxValue As Variant
    Dim valueCount As Long
    Dim values() As Double
    Dim deviation As Double
    Dim temp As Double
    Dim outLine As String
    Dim familyNames As Variant
    Dim familyName As String
    Dim familyLines As Collection
    Dim downloadsPath As String
    Dim regex As Object
    Dim matches As Object
    Dim code As String
    Dim parts() As String
    Dim element As String
    Dim cellId As String
    Dim isLegacy As Boolean
    Dim userResponse As VbMsgBoxResult
    Dim filePicker As fileDialog
    Dim selectedFiles As Variant
    Dim fileCount As Long
    Dim fileIdx As Long
    Dim currentFile As String
    Dim baseName As String
    Dim processedCount As Long
    Dim failedCount As Long
    Dim outputSummary As String
    
    ' Demander le mode Legacy
    userResponse = MsgBox("Mode Legacy ?" & vbCrLf & vbCrLf & _
                         "OUI = Commenter les lignes NRBTS et None/None" & vbCrLf & _
                         "NON = Conserver toutes les lignes", _
                         vbYesNo + vbQuestion, "Sélection du mode")
    
    isLegacy = (userResponse = vbYes)
    
    ' Préparer dossier de sortie (Downloads)
    Set fso = CreateObject("Scripting.FileSystemObject")
    downloadsPath = CreateObject("WScript.Shell").SpecialFolders("MyDocuments")
    downloadsPath = Replace(downloadsPath, "Documents", "Downloads")

    ' Sélection multi-fichiers (comme merge_multiple_nr_summaries.vba)
    Set filePicker = Application.fileDialog(msoFileDialogFilePicker)
    With filePicker
        .Title = "Sélectionner un ou plusieurs fichiers Excel contenant l'onglet Chart Data"
        .AllowMultiSelect = True
        .Filters.Clear
        .Filters.Add "Fichiers Excel", "*.xlsx;*.xlsm;*.xls"

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

    processedCount = 0
    failedCount = 0
    outputSummary = ""

    Application.ScreenUpdating = False

    For fileIdx = 1 To fileCount
        currentFile = selectedFiles(fileIdx)
        Application.StatusBar = "Traitement fichier " & fileIdx & "/" & fileCount & "..."

        Set wb = Nothing
        Set ws = Nothing

        On Error Resume Next
        Set wb = Workbooks.Open(currentFile, ReadOnly:=True)
        On Error GoTo 0

        If wb Is Nothing Then
            failedCount = failedCount + 1
            outputSummary = outputSummary & "- ERROR ouverture: " & currentFile & vbCrLf
            GoTo NextWorkbook
        End If

        On Error Resume Next
        Set ws = wb.Sheets("Chart Data")
        On Error GoTo 0

        If ws Is Nothing Then
            failedCount = failedCount + 1
            outputSummary = outputSummary & "- ERROR onglet manquant (Chart Data): " & wb.Name & vbCrLf
            wb.Close False
            GoTo NextWorkbook
        End If

        baseName = fso.GetBaseName(currentFile)
        outputFile = downloadsPath & "\constraint_" & baseName & "_" & Format(Now, "YYYYMMDD_HHNNSS") & ".csv"
    
    ' Initialiser les dictionnaires
    Set dataDict = CreateObject("Scripting.Dictionary")
    Set familyDeviations = CreateObject("Scripting.Dictionary")
    
    ' Configurer les déviations par famille (en pourcentage)
    familyDeviations("Accessibility") = 0.5
    familyDeviations("Integrity") = 5#
    familyDeviations("Mobility") = 1#
    familyDeviations("Retainability") = 1#
    familyDeviations("Usage - Utilization") = 5#
    familyDeviations("Usage - Capacity") = 5#
    familyDeviations("Usage -  Energy Efficiency") = 10#
    familyDeviations("default") = 5#
    
    Application.ScreenUpdating = False
    Application.StatusBar = "Lecture des données de l'onglet Chart Data..."
    
    ' Trouver la dernière ligne avec des données
    lastRow = ws.Cells(ws.Rows.Count, 2).End(xlUp).row
    
    If lastRow < 2 Then
        MsgBox "Aucune donnée trouvée dans l'onglet Chart Data.", vbExclamation
        Application.ScreenUpdating = True
        Exit Sub
    End If
    
    ' Lire les données depuis l'onglet
    Set regex = CreateObject("VBScript.RegExp")
    
    For row = 2 To lastRow
        distName = Trim(CStr(ws.Cells(row, 2).value))
        entryName = Trim(CStr(ws.Cells(row, 3).value))
        groupName = Trim(CStr(ws.Cells(row, 4).value))
        valueStr = Trim(CStr(ws.Cells(row, 6).value))
        
        If distName = "" Or entryName = "" Then GoTo NextLine
        
        ' === EXTRAIRE OAM ID ===
        oamId = ""
        parts = Split(distName, "/")
        If UBound(parts) >= 1 Then
            element = parts(UBound(parts))
            If Left(element, 7) = "NRCELL-" Then
                cellId = Mid(element, 8)
                oamId = "NRCELL[@id='" & cellId & "']"
            ElseIf element = "bts" Then
                oamId = "NRBTS[@id='1']"
            End If
        End If
        If oamId = "" Then GoTo NextLine
        
        ' === EXTRAIRE COUNTER CODE ===
        counterCode = ""
        regex.Pattern = "\[([^\]]+)\]"
        regex.Global = False
        Set matches = regex.Execute(entryName)
        If matches.Count > 0 Then
            code = matches(0).SubMatches(0)
            regex.Pattern = "[a-z]+$"
            counterCode = regex.Replace(code, "")
        End If
        If counterCode = "" Then GoTo NextLine
        
        ' === EXTRAIRE COMMENT ===
        comment = ""
        regex.Pattern = "\[[^\]]+\]\s*(.*)"
        Set matches = regex.Execute(entryName)
        If matches.Count > 0 Then
            comment = Trim(matches(0).SubMatches(0))
        End If
        
        ' Créer la clé
        key = oamId & "|" & counterCode & "|" & comment
        
        ' Initialiser si nouveau
        If Not dataDict.Exists(key) Then
            Set newEntry = CreateObject("Scripting.Dictionary")
            newEntry("values") = Array()
            newEntry("group_name") = groupName
            newEntry("value_count") = 0
            Set dataDict(key) = newEntry
        End If
        
        ' Ajouter la valeur si numérique
        If valueStr <> "" And IsNumeric(valueStr) Then
            value = CDbl(valueStr)
            Set currentEntry = dataDict(key)
            
            currentCount = currentEntry("value_count")
            ReDim Preserve tempValues(currentCount) As Double
            If currentCount > 0 Then
                For j = 0 To currentCount - 1
                    tempValues(j) = currentEntry("values")(j)
                Next j
            End If
            tempValues(currentCount) = value
            currentEntry("values") = tempValues
            currentEntry("value_count") = currentCount + 1
        End If
        
NextLine:
    Next row
    
    Application.StatusBar = "Calcul des min/max et écriture du fichier constraint..."
    
    ' Préparer les données pour l'écriture
    Set outputLines = CreateObject("Scripting.Dictionary")
    allKeys = dataDict.Keys
    
    For i = 0 To UBound(allKeys)
        key = allKeys(i)
        Set currentEntry = dataDict(key)
        
        keyParts = Split(key, "|")
        oamId = keyParts(0)
        counterCode = keyParts(1)
        comment = keyParts(2)
        groupName = currentEntry("group_name")
        valueCount = currentEntry("value_count")
        
        If valueCount > 0 Then
            values = currentEntry("values")
            minValue = values(0)
            maxValue = values(0)
            For j = 1 To valueCount - 1
                If values(j) < minValue Then minValue = values(j)
                If values(j) > maxValue Then maxValue = values(j)
            Next j
            
            ' Appliquer la déviation
            If InStr(1, comment, "delay", vbTextCompare) > 0 Then
                deviation = 30#
            ElseIf familyDeviations.Exists(groupName) Then
                deviation = familyDeviations(groupName)
            Else
                deviation = familyDeviations("default")
            End If
            
            ' === APPLY DEVIATION INLINE ===
            Dim devAmount As Double, adjustedMin As Double, adjustedMax As Double
            devAmount = minValue * (-deviation / 100#)
            adjustedMin = minValue + devAmount
            If minValue >= 0 And minValue <= 100 Then
                If adjustedMin < 0 Then adjustedMin = 0
                If adjustedMin > 100 Then adjustedMin = 100
            ElseIf minValue >= 0 And adjustedMin < 0 Then
                adjustedMin = 0
            End If
            minValue = adjustedMin
            
            devAmount = maxValue * (deviation / 100#)
            adjustedMax = maxValue + devAmount
            If maxValue >= 0 And maxValue <= 100 Then
                If adjustedMax < 0 Then adjustedMax = 0
                If adjustedMax > 100 Then adjustedMax = 100
            ElseIf maxValue >= 0 And adjustedMax < 0 Then
                adjustedMax = 0
            End If
            maxValue = adjustedMax
            
            If minValue > maxValue Then
                temp = minValue
                minValue = maxValue
                maxValue = temp
            End If
            
            ' Force min à 0 pour les KPIs BLER
            If InStr(1, comment, "BLER", vbTextCompare) > 0 Then
                minValue = 0
            End If
        Else
            minValue = Empty
            maxValue = Empty
        End If
        
        ' Stocker dans le dictionnaire de sortie avec clé pour tri
        If Not outputLines.Exists(groupName) Then
            Set outputLines(groupName) = CreateObject("Scripting.Dictionary")
        End If
        
        ' === FORMAT CONSTRAINT LINE INLINE ===
        Dim minStr As String, maxStr As String
        Dim oamIdPadded As String, counterPadded As String, variantPadded As String
        Dim isIntegerKPI As Boolean
        
        ' Vérifier si le KPI concerne des "number" ou "total" (doit être entier)
        isIntegerKPI = (InStr(1, comment, "number", vbTextCompare) > 0 Or _
                InStr(1, comment, "total", vbTextCompare) > 0)
        
        ' Format min value
        If IsEmpty(minValue) Or Not IsNumeric(minValue) Then
            minStr = "None"
        Else
            Dim roundedMin As Double
            If isIntegerKPI Then
                ' Arrondir à l'entier inférieur (Floor)
                roundedMin = Int(minValue)
                minStr = CStr(roundedMin)
            Else
                roundedMin = Round(minValue, 2)
                If roundedMin = Int(roundedMin) Then
                    minStr = CStr(Int(roundedMin))
                Else
                    minStr = CStr(roundedMin)
                End If
            End If
        End If
        
        ' Format max value
        If IsEmpty(maxValue) Or Not IsNumeric(maxValue) Then
            maxStr = "None"
        Else
            Dim roundedMax As Double
            If isIntegerKPI Then
                ' Arrondir à l'entier supérieur (Ceiling)
                If maxValue = Int(maxValue) Then
                    roundedMax = maxValue
                Else
                    roundedMax = Int(maxValue) + 1
                End If
                maxStr = CStr(roundedMax)
            Else
                roundedMax = Round(maxValue, 2)
                If roundedMax = Int(roundedMax) Then
                    maxStr = CStr(Int(roundedMax))
                Else
                    maxStr = CStr(roundedMax)
                End If
            End If
        End If
        
        ' Padding
        Dim padLen As Long
        padLen = 15 - Len(oamId)
        If padLen < 0 Then padLen = 0
        oamIdPadded = oamId & String(padLen, " ")

        padLen = 12 - Len(counterCode)
        If padLen < 0 Then padLen = 0
        counterPadded = counterCode & String(padLen, " ")

        padLen = 10 - Len(minStr)
        If padLen < 0 Then padLen = 0
        minStr = String(padLen, " ") & minStr

        padLen = 10 - Len(maxStr)
        If padLen < 0 Then padLen = 0
        maxStr = String(padLen, " ") & maxStr

        variantPadded = String(8 - 3, " ") & "ALL"
        
        outLine = oamIdPadded & ";   " & counterPadded & ";" & minStr & ";" & maxStr & ";" & variantPadded & ";   " & comment
        
        ' Stocker avec une clé de tri (CTR avant KPI, puis référence croissante, puis oamId)
        Dim sortKey As String
        sortKey = BuildConstraintSortKey(counterCode, oamId)
        If Not outputLines(groupName).Exists(sortKey) Then
            outputLines(groupName).Add sortKey, outLine
        End If
    Next i
    
    ' Écrire le fichier de sortie
    fileNum = FreeFile
    Open outputFile For Output As fileNum
    
    Print #fileNum, "#oam_id        ; Counter_or_KPI;       Min;       Max; Variant;   Comment from MIND/JUMP"
    
    familyNames = outputLines.Keys
    Dim sortedFamilies() As String
    ReDim sortedFamilies(UBound(familyNames))
    For i = 0 To UBound(familyNames)
        sortedFamilies(i) = CStr(familyNames(i))
    Next i
    SortStringArray sortedFamilies

    For i = 0 To UBound(sortedFamilies)
        familyName = sortedFamilies(i)
        Print #fileNum, "# ===== " & familyName & " ====="
        
        ' Récupérer le dictionnaire des lignes pour cette famille
        Dim familyDict As Object
        Set familyDict = outputLines(familyName)
        
        ' Trier les clés (counterCode|oamId)
        Dim sortedKeys() As String
        Dim familyKeys As Variant
        Dim k As Long, m As Long
        Dim tempKey As String
        
        familyKeys = familyDict.Keys
        ReDim sortedKeys(UBound(familyKeys))
        For k = 0 To UBound(familyKeys)
            sortedKeys(k) = familyKeys(k)
        Next k
        
        SortStringArray sortedKeys
        
        ' Écrire les lignes dans l'ordre trié
        For k = 0 To UBound(sortedKeys)
            Dim lineToWrite As String
            lineToWrite = familyDict(sortedKeys(k))
            
            ' Appliquer les règles Legacy si nécessaire
            If isLegacy Then
                ' Vérifier si la ligne commence par NRBTS[@id='1']
                If InStr(1, lineToWrite, "NRBTS[@id='1']") = 1 Then
                    lineToWrite = "# " & lineToWrite
                ' Vérifier si la ligne contient None;      None (Min et Max à None)
                ElseIf InStr(lineToWrite, ";      None;      None;") > 0 Then
                    lineToWrite = "# " & lineToWrite
                End If
            End If
            
            Print #fileNum, lineToWrite
        Next k
    Next i
    
    Close fileNum

    processedCount = processedCount + 1
    outputSummary = outputSummary & "- OK: " & outputFile & vbCrLf

    wb.Close False

NextWorkbook:
    Set dataDict = Nothing
    Set familyDeviations = Nothing
    Set outputLines = Nothing
    Set ws = Nothing
    Set wb = Nothing
    Next fileIdx

    Application.ScreenUpdating = True
    Application.StatusBar = False

    MsgBox "Traitement terminé !" & vbCrLf & vbCrLf & _
           "  Fichiers sélectionnés : " & fileCount & vbCrLf & _
           "  Succès : " & processedCount & vbCrLf & _
           "  Échecs : " & failedCount & vbCrLf & vbCrLf & _
           outputSummary, _
           vbInformation, "Constraint File(s) Created"

    Set fso = Nothing
    
End Sub

Private Function BuildConstraintSortKey(ByVal referenceCode As String, ByVal oamId As String) As String
    Dim normalizedRef As String
    Dim groupOrder As String

    normalizedRef = UCase(Trim(referenceCode))
    If IsCounterReference(normalizedRef) Then
        groupOrder = "0"
    Else
        groupOrder = "1"
    End If

    BuildConstraintSortKey = groupOrder & "|" & normalizedRef & "|" & UCase(Trim(oamId))
End Function

Private Function IsCounterReference(ByVal referenceCode As String) As Boolean
    Dim cleanCode As String

    cleanCode = UCase(Trim(referenceCode))

    If Len(cleanCode) >= 2 Then
        If Left(cleanCode, 3) = "CTR" Then
            IsCounterReference = True
            Exit Function
        End If

        If Left(cleanCode, 1) = "M" And Mid(cleanCode, 2, 1) Like "#" Then
            IsCounterReference = True
            Exit Function
        End If
    End If

    IsCounterReference = False
End Function

Private Sub SortStringArray(ByRef arr() As String)
    Dim i As Long
    Dim j As Long
    Dim temp As String

    If UBound(arr) <= LBound(arr) Then Exit Sub

    For i = LBound(arr) To UBound(arr) - 1
        For j = i + 1 To UBound(arr)
            If StrComp(arr(i), arr(j), vbTextCompare) > 0 Then
                temp = arr(i)
                arr(i) = arr(j)
                arr(j) = temp
            End If
        Next j
    Next i
End Sub
