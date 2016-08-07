VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CScreenCliper"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
'//////////////////////////////////////////////////////////////////////////////
'@@summary ֧��ȫ������
'@@require ��
'@@reference ���벿����Դ���磬�ҽ�������Ϲ������Լ�ɾ������
'@@license MIT
'@@author sunruiyeyipeng@163.com
'@@create 2016��4��28��14:10:43
'@@modify
'//////////////////////////////////////////////////////////////////////////////


'//////////////////////////////////////////////////////////////////////////////
'//
'//      ˽������
'//
'//////////////////////////////////////////////////////////////////////////////

'------------------------------------------------------------------------------
'       ˽����������
'------------------------------------------------------------------------------
Private Type GUID
  Data1 As Long
  Data2 As Integer
  Data3 As Integer
  Data4(0 To 7) As Byte
End Type
Private Type GdiplusStartupInput
  GdiplusVersion As Long
  DebugEventCallback As Long
  SuppressBackgroundThread As Long
  SuppressExternalCodecs As Long
End Type
Private Type EncoderParameter
  GUID As GUID
  NumberOfValues As Long
  Type As Long
  Value As Long
End Type
Private Type EncoderParameters
  Count As Long
  Parameter As EncoderParameter
End Type

Private Type PicBmp
  Size As Long
  Type As Long
  hbmp As Long
  hPal As Long
  Reserved As Long
End Type
'------------------------------------------------------------------------------
'       ˽��API
'------------------------------------------------------------------------------
Private Declare Function GdiplusStartup Lib "GDIPlus" (token As Long, inputbuf As GdiplusStartupInput, ByVal outputbuf As Long) As Long
Private Declare Function GdiplusShutdown Lib "GDIPlus" (ByVal token As Long) As Long
Private Declare Function GdipCreateBitmapFromHBITMAP Lib "GDIPlus" (ByVal hbm As Long, ByVal hPal As Long, Bitmap As Long) As Long
Private Declare Function GdipDisposeImage Lib "GDIPlus" (ByVal Image As Long) As Long
Private Declare Function GdipSaveImageToFile Lib "GDIPlus" (ByVal Image As Long, ByVal filename As Long, clsidEncoder As GUID, encoderParams As Any) As Long
Private Declare Function CLSIDFromString Lib "ole32" (ByVal str As Long, id As GUID) As Long
Private Declare Function GdipCreateBitmapFromFile Lib "GDIPlus" (ByVal filename As Long, Bitmap As Long) As Long

Private Declare Function GetDC Lib "user32" (ByVal hwnd As Long) As Long
Private Declare Function ReleaseDC Lib "user32" (ByVal hwnd As Long, ByVal hdc As Long) As Long
Private Declare Function BitBlt Lib "gdi32" (ByVal hDestDC As Long, ByVal x As Long, ByVal y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, ByVal dwRop As Long) As Long

Private Declare Function CreateCompatibleDC Lib "gdi32" (ByVal hdc As Long) As Long
Private Declare Function CreateCompatibleBitmap Lib "gdi32" (ByVal hdc As Long, _
ByVal nWidth As Long, ByVal nHeight As Long) As Long
Private Declare Function SelectObject Lib "gdi32" _
(ByVal hdc As Long, ByVal hObject As Long) As Long
Private Declare Function OleCreatePictureIndirect Lib "olepro32.dll" _
(PicDesc As PicBmp, RefIID As GUID, ByVal fPictureOwnsHandle As Long, _
IPic As IPicture) As Long
Private Declare Function DeleteObject Lib "gdi32" (ByVal hObject As Long) As Long
'//////////////////////////////////////////////////////////////////////////////
'//
'//      ��
'//
'//////////////////////////////////////////////////////////////////////////////


'------------------------------------------------------------------------------
'       ��ʼ��
'------------------------------------------------------------------------------
Private Sub Class_Initialize()

End Sub

'------------------------------------------------------------------------------
'       ����
'------------------------------------------------------------------------------
Private Sub Class_Terminate()

End Sub

'//////////////////////////////////////////////////////////////////////////////
'//
'//      ˽�з���
'//
'//////////////////////////////////////////////////////////////////////////////
Private Function PictureBoxSaveJPG(ByVal pict As StdPicture, ByVal filename As String, Optional ByVal quality As Byte = 80) As Boolean
  Dim tSI As GdiplusStartupInput
  Dim lRes As Long
  Dim lGDIP As Long
  Dim lBitmap As Long
    
  '��ʼ�� GDI+
  tSI.GdiplusVersion = 1
  lRes = GdiplusStartup(lGDIP, tSI, 0)
   
  If lRes = 0 Then
    '�Ӿ������ GDI+ ͼ��
    lRes = GdipCreateBitmapFromHBITMAP(pict.Handle, 0, lBitmap)
       
    If lRes = 0 Then
      Dim tJpgEncoder As GUID
      Dim tParams As EncoderParameters
       
      '��ʼ����������GUID��ʶ
      CLSIDFromString StrPtr("{557CF401-1A04-11D3-9A73-0000F81EF32E}"), tJpgEncoder
       
      '���ý���������
      tParams.Count = 1
      With tParams.Parameter ' Quality
        '�õ�Quality������GUID��ʶ
        CLSIDFromString StrPtr("{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}"), .GUID
        .NumberOfValues = 1
        .Type = 4
        .Value = VarPtr(quality)
      End With
       
      '����ͼ��
      lRes = GdipSaveImageToFile(lBitmap, StrPtr(filename), tJpgEncoder, tParams)
       
      '����GDI+ͼ��
      GdipDisposeImage lBitmap
    End If
     
    '���� GDI+
    GdiplusShutdown lGDIP
  End If
    
  If lRes Then
    PictureBoxSaveJPG = False
  Else
    PictureBoxSaveJPG = True
  End If
End Function

'//////////////////////////////////////////////////////////////////////////////
'//
'//      ���з���
'//
'//////////////////////////////////////////////////////////////////////////////
Public Sub ClipScreenToFile(ByVal FilePath As String)
  Dim pPicture As New StdPicture
  Set pPicture = ClipToImage
  PictureBoxSaveJPG pPicture, FilePath
End Sub

Private Function ClipToImage() As StdPicture
  Dim screenDc As Long, width As Long, height As Long
  Dim lPicDc As Long, lPicBmp As Long
  Dim G As GUID, p As PicBmp
  width = Screen.width / Screen.TwipsPerPixelX
  height = Screen.height / Screen.TwipsPerPixelY
  
  screenDc = GetDC(0)
  lPicDc = CreateCompatibleDC(screenDc)
  lPicBmp = CreateCompatibleBitmap(screenDc, width, height)
  SelectObject lPicDc, lPicBmp
  BitBlt lPicDc, 0, 0, width, height, screenDc, 0, 0, vbSrcCopy
  With G
    .Data1 = &H20400
    .Data4(0) = &HC0&
    .Data4(7) = &H46&
  End With
  With p
    .Size = Len(p)
    .Type = vbPicTypeBitmap
    .hbmp = lPicBmp
    .hPal = &H0&
  End With
  OleCreatePictureIndirect p, G, True, ClipToImage
  ReleaseDC 0, screenDc
  DeleteObject lPicBmp
End Function