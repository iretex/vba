VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "MailSender"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Dim tmpaddresList As String
Dim tmpText As String
Dim tmpSubject As String
Dim compName As String, formName As String, perName As String, formNum As String
Dim statVal As String
Dim workStatSht As Worksheet
Dim techSend As Boolean
Dim f As UserFormMessage

Public Function sendMsg() As Boolean
    tmpSubject = "�������� �� ������ ��������� �������"
    'tmp stub for approved and started i don't know to whom i should send emails.
    If tmpaddresList = "" Then
        sendMsg = True
        techSend = True
        Exit Function
    ElseIf tmpaddresList = "Error" Then
        Debug.Assert False
        'company name was not found
        Exit Function
    End If
    
    Call ShowSendMessage
    If f.msgWasSent Then
        sendMsg = True
        techSend = False
    End If
End Function

Public Sub collectVarMsg(targAddr As String, oldVal As String, inStatusVal As String)
    Dim tmpRng As Range
    
    Set workStatSht = ActiveWorkbook.Sheets("Workstatus")
    Set tmpRng = workStatSht.Range(targAddr)
    Call initVars(tmpRng, inStatusVal)
    'nobody could set default status
    If statVal = "�� ���������" Then
        Exit Sub
    End If
    tmpText = tmpText + collectMsg(oldVal)
    tmpaddresList = getAprAddr()

End Sub

Public Sub addPermanentMsg(usrName As String)
    tmpText = tmpText & "��������� ����������� �������������: " & usrName & vbCrLf
End Sub

Public Function completeSendMsg() As String
    Dim resString As String
    'Debug.Assert False
    If Not techSend Then
        If Not SendStatusMail(f.TextBoxTo.Caption, f.TextBoxText.Value, f.TextBoxSubject.Caption) Then
            completeSendMsg = "Outlook �� ����������"
            Unload f
            Exit Function
        End If
        Unload f
    End If
    Set workStatSht = Nothing
    completeSendMsg = "ok"
End Function

Private Function collectMsg(oldVal As String) As String
    collectMsg = "������ ��� ��������: " & compName & " �����: " & formNum & " (" & formName & ") �������: " & perName
    collectMsg = collectMsg & " ��� ������� �� ������� " & oldVal & " �� " & statVal & vbLf
End Function

Private Function getAprAddr() As String
    Dim shtToWork As Worksheet
    Dim shtName As String
    Dim foundCell As Range
    Dim foundCellAddr As String
    
    shtName = getAprSht
    If shtName = "" Then Exit Function
     
    Set shtToWork = Sheets(shtName)
    shtToWork.Select
    Columns("A:A").Select
    Set foundCell = Selection.find(what:=compName, after:=ActiveCell, LookIn:=xlFormulas _
        , LookAt:=xlWhole, SearchOrder:=xlByRows, SearchDirection:=xlNext, _
        MatchCase:=False, SearchFormat:=False)
    If Not foundCell Is Nothing Then
        foundCellAddr = foundCell.Address
        Do While Not foundCell Is Nothing
            getAprAddr = getAprAddr & Cells(foundCell.Row, foundCell.Column + 3).Value & ";"
            foundCell.Activate
            Set foundCell = Selection.FindNext(ActiveCell)
            If foundCellAddr = foundCell.Address Then Exit Do
        Loop
    Else
        getAprAddr = "Error"
    End If

    'cleaning
    Set foundCell = Nothing
    'getAprAddr = "Chernokalskayaea@dtek.com" '"galkinva@dtek.com"
    'Debug.Assert False
End Function

Private Function getAprSht() As String
    If statVal = "������ �������" Then
        getAprSht = "msfo_table"
    ElseIf statVal = "������ �������� ������" Or statVal = "�������" Then
        getAprSht = "user_table"
    End If
End Function

Private Sub initVars(changedRng As Range, inStatusVal As String)
    
    compName = workStatSht.Cells(10, changedRng.Column).Value
    formName = workStatSht.Cells(changedRng.Row, 12).Value
    formNum = workStatSht.Cells(changedRng.Row, 11).Value
    perName = workStatSht.Range("N3").Value
    statVal = inStatusVal
    
End Sub

Function SendStatusMail(addresList, text, subject) As Boolean
    '
    Dim objOutlook As Object
    Dim objOutlookMsg As Object
    Dim objOutlookRecip As Object
    Dim objOutlookAttach As Object
    '
    Set objOutlook = CreateObject("Outlook.Application")
    Set objOutlookMsg = objOutlook.CreateItem(olMailItem)
    Debug.Assert Not objOutlookMsg Is Nothing
    '
    With objOutlookMsg
        '
        .To = addresList
        .subject = subject
        .Body = text
        On Error Resume Next
        .Send
        If Err.Number <> 0 Then
            Set objOutlookMsg = Nothing
            Set objOutlook = Nothing
            On Error GoTo 0
            Exit Function
        End If
        On Error GoTo 0
    End With
    '
    Set objOutlookMsg = Nothing
    Set objOutlook = Nothing
    Set objOutlookRecip = Nothing
    Set objOutlookAttach = Nothing
    SendStatusMail = True
    '
End Function
Sub ShowSendMessage()
    '
    Set f = New UserFormMessage
    '
    f.TextBoxSubject.Caption = tmpSubject
    f.TextBoxText = tmpText
    f.TextBoxTo.Caption = tmpaddresList
    '
    f.Show
    '
End Sub
