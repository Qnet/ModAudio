<%@ Page Language="VB" Explicit="False" %>

<%@ Import Namespace="PDshop9" %>
<script runat="server">

    '************************************************************
    '*         TERMS & CONDITIONS / COPYRIGHT NOTICE            *
    '************************************************************
    '*   By Downloading or using this software, you agree to    *
    '*   the terms and conditions as stated in the Software     *
    '*   License Agreement.  An updated copy of this agreement  *
    '*   can be seen at http://www.pagedowntech.com/terms.      *
    '*                                                          *
    '*   NOTICE: We do not recommend changing the code below    *
    '*   as it may interfere with future updates/upgrades.      *
    '*                                                          *
    '*        PageDown Technology, LLC., Copyright 2011.        *
    '*             pagedowntech.com / pdshop.com                *
    '*                                                          *
    '*  (this copyright notice must not be altered or removed)  *
    '************************************************************

    Public pd As PDshopFunctions
    Public messagesent As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()

        'If This feature is not enabled
        If pd.passemail <> "ON" Then pd.pdRedirect("affilsignin.aspx")
         
        'Get email info  
        pd.OpenSetupDataReader("otherxml", "email")

        emailfrom = pd.ReadData("emailfrom2")
        emailfromname = pd.ReadData("emailfromname2")
        emailsubject = pd.ReadData("emailsubject2")
        emailbody = pd.ReadData("emailbody2")

        pd.CloseData()

        If Not (Page.IsPostBack) Then

        End If

        If Page.IsPostBack Then

            'Verify Captcha Code
            If pd.passShopCaptcha(captcha.Text) = False Then
                pd.formerror = pd.formerror & pd.geterrtext("err71")
                captcha.Text = ""
            End If
            
            pd.formerror = pd.formerror & pd.checkchr(email.Text, pd.getsystext("sys23"))

            'If no errors, open database and send email
            If pd.formerror = "" Then

                pd.OpenDataReader("SELECT * FROM affiliates WHERE email='" & pd.FormatSqlText(email.Text) & "'")
                If pd.ReadDataItem.Read Then
                 
                    affilrecid = pd.ReadDataN("id")
                    emailto = pd.ReadData("email")
                    name = pd.ReadData("name")
                    affillink = pd.ReadData("affillink")
                    
                    'Determine if new password needs to be generated
                    temphash = pd.ReadData("password_hash")
                    If temphash = "" Then
                        password = pd.ReadDataX("password") 'Get Encrypted Data
                    Else
                        'Generate New Password
                        password = Left(pd.getlongrandseq(), 8)
                        savenewpass = "Yes"
                    End If

                Else
                    pd.formerror = pd.geterrtext("err50")

                End If
                pd.CloseData()
                
                'If new password was requested... save it
                If savenewpass = "Yes" Then
                    pd.OpenDataWriter("affiliates WHERE id=" & affilrecid)
                    pd.AddData("password", password, "X")
                    pd.SaveData()
                End If

            End If

            If pd.formerror = "" Then
            
                emailbody = Replace(emailbody, "##CUSTNAME##", name)
                emailbody = Replace(emailbody, "##DATE##", pd.showdate(DateTime.Now.Date))
                emailbody = Replace(emailbody, "##PASSWORD##", password)
                emailbody = Replace(emailbody, "##AFFILLINK##", affillink)

                'Arguments(semailto,semailfrom,semailsubject,semailbody,semailformat,semailattachment)
                pd.Sendemail(emailto, "", emailfrom, emailfromname, emailsubject, emailbody, "Text", "")
                pd.formerror = pd.geterrtext("err8")
                pd.LogAffilEvent(305, affilrecid, email.Text)
                pd.pdRedirect("affilsignin.aspx?showalert=emailsent")

            End If


        End If


    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg7)%>
<%= pd.startSection("heads17")%>
<div>
    <form method="POST" action="affilemailpass.aspx" id="pageform" name="pageform" runat="server">
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="formheadings">
        <%=pd.getsystext("sys23")%></div>
    <div>
        <asp:textbox class="formfield" id="email" runat="server" />
    </div>
    <% If pd.shopcaptcha = "ON" Then%>
    <br />
    <div>
        <div class="formheadings" style="float: left;">
            <%=pd.getsystext("sys134")%>
            &nbsp;<br />
            <asp:textbox class="formfield3" id="captcha" runat="server" />
        </div>
        <div style="float: left;">
            <img src="captcha.aspx?rnum=<%=pd.getrandseq() %>" border="0" /></div>
        <div style="clear: both;">
            <!-- -->
        </div>
        <% If pd.shopdemomode = "Yes" Then%>
        <div class="formheadings">
            DEMO USERS: Because this is a Demo, the 'Captcha' Verification Code has been entered
            for you. Also note that this and other security features can be turned off.</div>
        <% End If%>
    </div>
    <br />
    <% End If%>
        <div class="formbuttons_container">
        <%=pd.getButton("butts14","","","pageform")%></div>
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg7)%>
