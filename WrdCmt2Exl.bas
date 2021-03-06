Attribute VB_Name = "Module3"
Sub exportComments()
' Exports comments from a MS Word document to Excel and associates them with the heading paragraphs they are included in. 
' Need to set a VBA reference to "Microsoft Excel 14.0 Object Library"

Dim xlApp As Excel.Application
Dim xlWB As Excel.Workbook
Dim i As Integer, HeadingRow As Integer
Dim objPara As Paragraph
Dim objComment As Comment
Dim strSection As String
Dim strTemp
Dim myRange As Range

Set xlApp = CreateObject("Excel.Application")
xlApp.Visible = True
Set xlWB = xlApp.Workbooks.Add 'create a new workbook
With xlWB.Worksheets(1)
' Create Heading
    HeadingRow = 1
    .Cells(HeadingRow, 1).Formula = "Comment"
    .Cells(HeadingRow, 2).Formula = "Page"
    .Cells(HeadingRow, 3).Formula = "Paragraph"
    .Cells(HeadingRow, 4).Formula = "Comment"
    '.Cells(HeadingRow, 5).Formula = "Reviewer"
    .Cells(HeadingRow, 6).Formula = "Date"
    
    strSection = "preamble" 'all sections before "1." will be labeled as "preamble"
    strTemp = "preamble"
    If ActiveDocument.Comments.Count = 0 Then
        MsgBox ("No comments")
        Exit Sub
    End If
    
    For i = 1 To ActiveDocument.Comments.Count
        Set myRange = ActiveDocument.Comments(i).Scope
        strSection = ParentLevel(myRange.Paragraphs(1)) ' find the section heading for this comment
        'MsgBox strSection
        .Cells(i + HeadingRow, 1).Formula = ActiveDocument.Comments(i).Index
        .Cells(i + HeadingRow, 2).Formula = ActiveDocument.Comments(i).Reference.Information(wdActiveEndAdjustedPageNumber)
        .Cells(i + HeadingRow, 3).Value = strSection
        .Cells(i + HeadingRow, 4).Formula = ActiveDocument.Comments(i).Range
        '.Cells(i + HeadingRow, 5).Formula = ActiveDocument.Comments(i).Initial
        .Cells(i + HeadingRow, 6).Formula = Format(ActiveDocument.Comments(i).Date, "dd/MM/yyyy")
        .Cells(i + HeadingRow, 7).Formula = ActiveDocument.Comments(i).Range.ListFormat.ListString
    Next i
End With
Set xlWB = Nothing
Set xlApp = Nothing
End Sub


Function ParentLevel(Para As Word.Paragraph) As String
' Finds the first outlined numbered paragraph above the given paragraph object
    Dim ParaAbove As Word.Paragraph
    Set ParaAbove = Para
    sStyle = Para.Range.ParagraphStyle
    sStyle = Left(sStyle, 4)
    If sStyle = "Head" Then
        GoTo Skip
    End If
    Do While ParaAbove.OutlineLevel = Para.OutlineLevel
        Set ParaAbove = ParaAbove.Previous
    Loop
Skip:
    strTitle = ParaAbove.Range.Text
    strTitle = Left(strTitle, Len(strTitle) - 1)
    ParentLevel = ParaAbove.Range.ListFormat.ListString & " " & strTitle
End Function
