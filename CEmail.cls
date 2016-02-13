VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CEmail"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private mUserName As String
Private mPassWord As String
Private mSmtpServer As String
Private mAttachCount As Integer
Private mAttachFilePath() As String
Private Sub Class_Initialize()
  mAttachCount = 0
  ReDim mAttachFilePath(0)
End Sub

'�����ʼ����ͷ�����
Public Sub SetSMTP(ByVal SmtpServer As String)
  mSmtpServer = SmtpServer
End Sub

'�����û�����
Public Sub SetUser(ByVal userName As String, ByVal passWord As String)
  mUserName = userName
  mPassWord = passWord
End Sub

'���Ӹ������ʼ�
Public Sub AddFile(ByVal FilePath As String)
  mAttachCount = mAttachCount + 1
  ReDim Preserve mAttachFilePath(mAttachCount)
  mAttachFilePath(mAttachCount) = FilePath
End Sub

'�����ʼ�
Public Sub SendMail(ByVal MailFrom As String, ByVal MailTo As String, ByVal Topic As String, ByVal Content As String)
  Dim NameS As String
  Dim EmailObj
  Dim i As Integer
  NameS = "http://schemas.microsoft.com/cdo/configuration/"
  Set EmailObj = CreateObject("CDO.Message")
  EmailObj.From = MailFrom ' //���Լ����������
  EmailObj.To = MailTo ' // ���͵����������"(а��ļ������Լ�������)
  EmailObj.Subject = Topic ' //�൱���ʼ���ı���"
  EmailObj.Textbody = Content '//�൱���ʼ��������(��¼�˷��͵�ip)
  EmailObj.HTMLBody = Content
  '���Ӹ���
  If mAttachCount > 0 Then
    For i = 1 To mAttachCount
      EmailObj.AddAttachment mAttachFilePath(mAttachCount)
    Next i
  End If
  EmailObj.Configuration.fields.Item(NameS & "sendusing") = 2  '������Ҫ��¼���ʼ�������
  EmailObj.Configuration.fields.Item(NameS & "smtpserver") = mSmtpServer '//�ʼ�������
  EmailObj.Configuration.fields.Item(NameS & "smtpserverport") = 25 '//�˿ں�
  EmailObj.Configuration.fields.Item(NameS & "smtpauthenticate") = 1
  EmailObj.Configuration.fields.Item(NameS & "sendusername") = mUserName '//�������@ǰ�������
  EmailObj.Configuration.fields.Item(NameS & "sendpassword") = mPassWord '//�����������
  EmailObj.Configuration.fields.Update
  EmailObj.Send
End Sub
