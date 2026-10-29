Sub CreerPivotTableNR()
    '
    ' Macro pour créer un tableau croisé dynamique à partir du fichier NR_Fusionne.xlsx
    ' avec graphiques automatiques par catégorie de KPIs
    ' Prérequis: Exécuter d'abord le script Python fusionner_nr_files.py
    ' Auteur: gerard.bonhaure@nokia.com
    ' Date: 02-janv-2026
    '
    ' IMPORTANT: Cette macro transforme d'abord les données du format "pivot plat"
    ' vers le format "liste" requis par Excel PivotTable, puis crée plusieurs graphiques
    '
    ' Instructions:
    ' 1. Exécuter fusionner_nr_files.py pour générer NR_Fusionne.xlsx
    ' 2. Ouvrir NR_Fusionne.xlsx dans Excel
    ' 3. Alt+F11 pour ouvrir l'éditeur VBA
    ' 4. Insertion > Module
    ' 5. Coller ce code
    ' 6. Exécuter avec F5 ou depuis Excel: Développeur > Macros > CreerPivotTableNR
    '

    Dim wb As Workbook
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

    ' Vérifier qu'on est bien dans le bon fichier
    Set wb = ActiveWorkbook
    If wb Is Nothing Then
        MsgBox "Aucun classeur ouvert. Veuillez ouvrir NR_Fusionne.xlsx", vbExclamation
        Exit Sub
    End If

    ' Vérifier que la feuille de données existe
    On Error Resume Next
    Set ws = wb.Sheets(1)
    On Error GoTo 0

    If ws Is Nothing Then
        MsgBox "Impossible de trouver la feuille de données.", vbExclamation
        Exit Sub
    End If

    ' Vérifier la structure (colonnes kpi_name et object_name)
    If ws.Cells(1, 1).Value <> "kpi_name" Or ws.Cells(1, 2).Value <> "object_name" Then
        MsgBox "Format de fichier incorrect. Attendu: kpi_name et object_name en colonnes A et B", vbExclamation
        Exit Sub
    End If

    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.StatusBar = "Transformation des données..."

    ' Déterminer la plage de données source
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    lastCol = ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column

    If lastRow < 2 Then
        MsgBox "Aucune donnée trouvée dans le fichier.", vbExclamation
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
    wsNormalized.Cells(1, 1).Value = "kpi_name"
    wsNormalized.Cells(1, 2).Value = "object_name"
    wsNormalized.Cells(1, 3).Value = "date"
    wsNormalized.Cells(1, 4).Value = "valeur"
    wsNormalized.Range("A1:D1").Font.Bold = True

    ' Transformer les données: de pivot plat vers liste
    newRow = 2
    Application.StatusBar = "Transformation des données en cours..."

    For i = 2 To lastRow  ' Pour chaque ligne de données
        For j = 3 To lastCol  ' Pour chaque colonne de date
            Dim cellValue As Variant
            cellValue = ws.Cells(i, j).Value

            ' Copier kpi_name et object_name
            wsNormalized.Cells(newRow, 1).Value = ws.Cells(i, 1).Value  ' kpi_name
            wsNormalized.Cells(newRow, 2).Value = ws.Cells(i, 2).Value  ' object_name
            wsNormalized.Cells(newRow, 3).Value = ws.Cells(1, j).Value  ' date

            ' Si la valeur est "None" (texte), la remplacer par "" pour que le pivot l'ignore
            If cellValue = "None" Or IsEmpty(cellValue) Or cellValue = "" Then
                wsNormalized.Cells(newRow, 4).Value = ""
            Else
                wsNormalized.Cells(newRow, 4).Value = cellValue
            End If
            newRow = newRow + 1
        Next j

        ' Afficher la progression
        If i Mod 10 = 0 Then
            Application.StatusBar = "Transformation: " & i & "/" & lastRow & " lignes..."
        End If
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
        ' Ajouter kpi_name et object_name en champs de lignes
        With .PivotFields("kpi_name")
            .Orientation = xlRowField
            .Position = 1
        End With

        With .PivotFields("object_name")
            .Orientation = xlRowField
            .Position = 2
        End With

        ' Ajouter date en champs de colonnes
        With .PivotFields("date")
            .Orientation = xlColumnField
            .Position = 1
        End With

        ' Incliner les en-têtes de colonnes (dates) à 90 degrés (vertical)
        .ColumnRange.Orientation = 90

        ' Ajouter valeur comme champ de données
        With .PivotFields("valeur")
            .Orientation = xlDataField
            .Function = xlSum
            .NumberFormat = "0.00"
            .Name = "Value"
        End With

        ' Configuration finale
        .ColumnGrand = False
        .RowGrand = False
        .TableStyle2 = "PivotStyleMedium9"

        ' Ne pas afficher 0 pour les valeurs manquantes
        .NullString = ""
        .DisplayErrorString = True
        .ErrorString = ""
    End With

    ' Ajuster les colonnes
    wsPivot.Columns("A:B").AutoFit
    For i = 3 To 50
        wsPivot.Columns(i).ColumnWidth = 12
    Next i

    ' Ajouter un titre
    wsPivot.Range("A1").Value = "Tableau Croisé Dynamique - NR KPI"
    wsPivot.Range("A1").Font.Bold = True
    wsPivot.Range("A1").Font.Size = 14

    ' ======== NOUVEAU: Créer les graphiques par catégorie ========
    Application.StatusBar = "Création des graphiques..."

    ' Créer les graphiques pour chaque catégorie
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

    ' ======== FIN NOUVEAU ========

    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    Application.StatusBar = False

    ' Message final
    MsgBox "Tableau croisé dynamique et graphiques créés !" & vbCrLf & vbCrLf & _
           "  - " & (lastRow - 1) & " lignes sources (KPI x Object)" & vbCrLf & _
           "  - " & (lastCol - 2) & " colonnes de dates" & vbCrLf & _
           "  - " & (newRow - 2) & " lignes transformées" & vbCrLf & _
           "  - 8 graphiques créés" & vbCrLf & vbCrLf & _
           "Résultats disponibles:" & vbCrLf & _
           "  • Onglet 'Pivot' - Tableau croisé dynamique" & vbCrLf & _
           "  • Onglets 'Chart_*' - Graphiques par catégorie" & vbCrLf & _
           "  • Onglet 'Données_Normalisées' - Données source", vbInformation, "PivotTable & Charts NR"

    ' Activer la première feuille de graphique
    On Error Resume Next
    wb.Sheets("Chart_Accessibility").Activate
    On Error GoTo 0

    ' Libérer les objets
    Set pt = Nothing
    Set pc = Nothing
    Set dataRange = Nothing
    Set wsPivot = Nothing
    Set wsNormalized = Nothing
    Set ws = Nothing
    Set wb = Nothing

End Sub

Sub CreateChartForKpiGroup(wb As Workbook, pt As PivotTable, wsPivot As Worksheet, _
                           groupName As String, kpiList As Variant)
    '
    ' Procédure pour créer un graphique filtré pour un groupe de KPIs
    ' Crée un PivotTable dédié pour chaque graphique
    '
    ' Paramètres:
    '   wb - Workbook actif
    '   pt - PivotTable source (utilisé pour obtenir le cache)
    '   wsPivot - Feuille contenant le pivot source
    '   groupName - Nom du groupe (ex: "Accessibility")
    '   kpiList - Tableau des KPIs à inclure
    '

    Dim wsChart As Worksheet
    Dim cht As ChartObject
    Dim ptNew As PivotTable
    Dim pf As PivotField
    Dim pi As PivotItem
    Dim kpi As Variant
    Dim kpiExists As Boolean

    Application.StatusBar = "Création du graphique " & groupName & "..."

    ' Créer une nouvelle feuille pour le graphique
    Set wsChart = wb.Sheets.Add(After:=wb.Sheets(wb.Sheets.Count))
    wsChart.Name = "Chart_" & groupName

    ' Créer un nouveau PivotTable dédié pour ce graphique
    ' en utilisant le même PivotCache que le pivot principal
    Set ptNew = pt.PivotCache.CreatePivotTable( _
        TableDestination:=wsChart.Range("A50"), _
        TableName:="Pivot_" & groupName)

    ' Configurer le nouveau PivotTable (même structure que l'original)
    With ptNew
        ' Ajouter kpi_name en champs de lignes
        With .PivotFields("kpi_name")
            .Orientation = xlRowField
            .Position = 1
        End With

        With .PivotFields("object_name")
            .Orientation = xlRowField
            .Position = 2
        End With

        ' Ajouter date en champs de colonnes
        With .PivotFields("date")
            .Orientation = xlColumnField
            .Position = 1
        End With

        ' Ajouter valeur comme champ de données
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

    ' Appliquer le filtre sur kpi_name pour ce PivotTable
    Set pf = ptNew.PivotFields("kpi_name")

    ' Vérifier d'abord si au moins un KPI de la liste existe dans les données
    Dim kpiFoundCount As Integer
    kpiFoundCount = 0

    For Each kpi In kpiList
        For Each pi In pf.PivotItems
            If pi.Name = CStr(kpi) Then
                kpiFoundCount = kpiFoundCount + 1
                Exit For
            End If
        Next pi
    Next kpi

    ' Si aucun KPI de la liste n'existe dans les données, annuler la création du graphique
    If kpiFoundCount = 0 Then
        Application.StatusBar = "Aucun KPI trouvé pour " & groupName & " - graphique ignoré"
        ' Nettoyer et sortir proprement
        Application.DisplayAlerts = False
        wsChart.Delete
        Application.DisplayAlerts = True
        Set cht = Nothing
        Set ptNew = Nothing
        Set wsChart = Nothing
        Set pf = Nothing
        Exit Sub
    End If

    ' S'assurer que tous sont visibles d'abord
    For Each pi In pf.PivotItems
        pi.Visible = True
    Next pi

    ' Désactiver les KPIs qui ne sont PAS dans la liste
    For Each pi In pf.PivotItems
        kpiExists = False
        For Each kpi In kpiList
            If pi.Name = CStr(kpi) Then
                kpiExists = True
                Exit For
            End If
        Next kpi

        If Not kpiExists Then
            On Error Resume Next  ' Ignorer les erreurs au cas où c'est le dernier élément
            pi.Visible = False
            On Error GoTo 0
        End If
    Next pi

    ' Créer le graphique sur la nouvelle feuille
    Set cht = wsChart.ChartObjects.Add(Left:=10, Top:=30, Width:=800, Height:=450)

    ' Lier le graphique au PivotTable dédié
    cht.Chart.SetSourceData Source:=ptNew.TableRange2

    ' Configurer le graphique
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

    ' Ajouter un titre sur la feuille
    wsChart.Range("A1").Value = "Graphique - " & Replace(groupName, "_", " - ")
    wsChart.Range("A1").Font.Bold = True
    wsChart.Range("A1").Font.Size = 14

    ' Masquer le PivotTable (il est en A50, en dessous du graphique)
    wsChart.Rows("50:100").Hidden = True

    ' ======== NOUVEAU: Ajouter tableau KPI + Description à droite du graphique ========
    Call AddKpiDescriptionTable(wb, wsChart, kpiList, groupName)
    ' ======== FIN NOUVEAU ========

    ' Libérer les objets
    Set cht = Nothing
    Set ptNew = Nothing
    Set wsChart = Nothing
    Set pf = Nothing

End Sub

Sub AddKpiDescriptionTable(wb As Workbook, wsChart As Worksheet, kpiList As Variant, groupName As String)
    '
    ' Procédure pour ajouter un tableau KPI + Description à côté du graphique
    '
    ' Paramètres:
    '   wb - Workbook actif
    '   wsChart - Feuille contenant le graphique
    '   kpiList - Tableau des KPIs de cette catégorie
    '   groupName - Nom du groupe
    '

    Dim wsRef As Worksheet
    Dim kpi As Variant
    Dim i As Long
    Dim j As Long
    Dim lastRow As Long
    Dim kpiName As String
    Dim kpiDescription As String
    Dim found As Boolean
    Dim startCol As String
    Dim currentRow As Long

    ' Vérifier si l'onglet RefToDescription existe
    On Error Resume Next
    Set wsRef = wb.Sheets("RefToDescription")
    On Error GoTo 0

    If wsRef Is Nothing Then
        ' Si l'onglet n'existe pas, créer le tableau sans descriptions
        Exit Sub
    End If

    ' Position du tableau : colonne M (à droite du graphique qui est généralement en A-K)
    startCol = "M"
    currentRow = 3

    ' En-têtes du tableau
    wsChart.Range(startCol & currentRow).Value = "KPI"
    wsChart.Range(startCol & currentRow).Font.Bold = True
    wsChart.Range(startCol & currentRow).Interior.Color = RGB(68, 114, 196)
    wsChart.Range(startCol & currentRow).Font.Color = RGB(255, 255, 255)

    Dim nextCol As String
    nextCol = Chr(Asc(startCol) + 1)  ' Colonne suivante (N)
    wsChart.Range(nextCol & currentRow).Value = "Description"
    wsChart.Range(nextCol & currentRow).Font.Bold = True
    wsChart.Range(nextCol & currentRow).Interior.Color = RGB(68, 114, 196)
    wsChart.Range(nextCol & currentRow).Font.Color = RGB(255, 255, 255)

    ' Trouver la dernière ligne de RefToDescription
    lastRow = wsRef.Cells(wsRef.Rows.Count, 1).End(xlUp).Row

    ' Pour chaque KPI de la liste
    currentRow = currentRow + 1
    For Each kpi In kpiList
        kpiName = CStr(kpi)
        kpiDescription = "No description found"
        found = False

        ' Chercher le KPI dans RefToDescription
        For i = 2 To lastRow
            If wsRef.Cells(i, 1).Value = kpiName Then
                kpiDescription = wsRef.Cells(i, 2).Value
                found = True
                Exit For
            End If
        Next i

        ' Écrire dans le tableau
        wsChart.Range(startCol & currentRow).Value = kpiName
        wsChart.Range(nextCol & currentRow).Value = kpiDescription

        ' Formater alternativement les lignes
        If currentRow Mod 2 = 0 Then
            wsChart.Range(startCol & currentRow & ":" & nextCol & currentRow).Interior.Color = RGB(242, 242, 242)
        End If

        currentRow = currentRow + 1
    Next kpi

    ' Ajuster les largeurs de colonnes
    wsChart.Columns(startCol).ColumnWidth = 15
    wsChart.Columns(nextCol).ColumnWidth = 60

    ' Ajouter des bordures au tableau
    Dim tableRange As Range
    Set tableRange = wsChart.Range(startCol & "3:" & nextCol & (currentRow - 1))
    tableRange.Borders.LineStyle = xlContinuous
    tableRange.Borders.Weight = xlThin

    ' Activer le retour à la ligne pour la colonne description
    wsChart.Columns(nextCol).WrapText = True

    ' Libérer les objets
    Set wsRef = Nothing
    Set tableRange = Nothing

End Sub

Sub CreateChartForOtherKpis(wb As Workbook, pt As PivotTable, wsPivot As Worksheet, _
                            groupName As String, excludeKpiList As Variant)
    '
    ' Procédure pour créer un graphique avec tous les KPIs SAUF ceux de la liste
    ' Utilisé pour le groupe "Misc" qui contient tous les autres KPIs
    '
    ' Paramètres:
    '   wb - Workbook actif
    '   pt - PivotTable source
    '   wsPivot - Feuille contenant le pivot source
    '   groupName - Nom du groupe (ex: "Misc")
    '   excludeKpiList - Tableau des KPIs à EXCLURE
    '

    Dim wsChart As Worksheet
    Dim cht As ChartObject
    Dim ptNew As PivotTable
    Dim pf As PivotField
    Dim pi As PivotItem
    Dim kpi As Variant
    Dim kpiInExcludeList As Boolean

    Application.StatusBar = "Création du graphique " & groupName & "..."

    ' Créer une nouvelle feuille pour le graphique
    Set wsChart = wb.Sheets.Add(After:=wb.Sheets(wb.Sheets.Count))
    wsChart.Name = "Chart_" & groupName

    ' Créer un nouveau PivotTable dédié
    Set ptNew = pt.PivotCache.CreatePivotTable( _
        TableDestination:=wsChart.Range("A50"), _
        TableName:="Pivot_" & groupName)

    ' Configurer le PivotTable
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

    ' Appliquer le filtre inversé : masquer les KPIs de la liste d'exclusion
    Set pf = ptNew.PivotFields("kpi_name")

    ' Compter combien de KPIs ne seront PAS masqués (pour vérifier qu'il en reste au moins 1)
    Dim countVisible As Integer
    countVisible = 0

    For Each pi In pf.PivotItems
        kpiInExcludeList = False
        For Each kpi In excludeKpiList
            If pi.Name = CStr(kpi) Then
                kpiInExcludeList = True
                Exit For
            End If
        Next kpi

        ' Compter les KPIs qui ne seront pas masqués
        If Not kpiInExcludeList Then
            countVisible = countVisible + 1
        End If
    Next pi

    ' Si aucun KPI ne restera visible, arrêter la création de ce graphique
    If countVisible = 0 Then
        MsgBox "Aucun KPI 'Misc' trouvé. Tous les KPIs sont déjà dans les autres catégories.", vbInformation
        ' Nettoyer et sortir
        Application.DisplayAlerts = False
        wsChart.Delete
        Application.DisplayAlerts = True
        Set cht = Nothing
        Set ptNew = Nothing
        Set wsChart = Nothing
        Set pf = Nothing
        Exit Sub
    End If

    ' Masquer les KPIs qui SONT dans la liste d'exclusion
    For Each pi In pf.PivotItems
        kpiInExcludeList = False
        For Each kpi In excludeKpiList
            If pi.Name = CStr(kpi) Then
                kpiInExcludeList = True
                Exit For
            End If
        Next kpi

        ' Si le KPI est dans la liste d'exclusion, le masquer
        If kpiInExcludeList Then
            On Error Resume Next  ' Ignorer les erreurs si c'est le dernier élément
            pi.Visible = False
            On Error GoTo 0
        End If
    Next pi

    ' Créer le graphique
    Set cht = wsChart.ChartObjects.Add(Left:=10, Top:=30, Width:=800, Height:=450)
    cht.Chart.SetSourceData Source:=ptNew.TableRange2

    ' Configurer le graphique
    With cht.Chart
        .ChartType = xlLineMarkers

        .HasTitle = True
        .ChartTitle.Text = "Evolution KPI - " & groupName & " (Autres KPIs)"
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

        .ChartStyle = 201

        .PlotArea.Format.Fill.Visible = msoTrue
        .PlotArea.Format.Fill.ForeColor.RGB = RGB(255, 255, 255)
    End With

    ' Configurer la légende séparément
    With cht.Chart.Legend
        .Font.Size = 9
    End With

    ' Ajouter un titre sur la feuille
    wsChart.Range("A1").Value = "Graphique - " & groupName & " (Autres KPIs)"
    wsChart.Range("A1").Font.Bold = True
    wsChart.Range("A1").Font.Size = 14

    ' Masquer le PivotTable
    wsChart.Rows("50:100").Hidden = True

    ' Libérer les objets
    Set cht = Nothing
    Set ptNew = Nothing
    Set wsChart = Nothing
    Set pf = Nothing

End Sub
