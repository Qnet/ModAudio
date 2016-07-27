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
    Public contemailen, messagesent, refer As String
    
    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)
    
        If IsNothing(pd) = False Then pd.PDShopError()
    
    End Sub
    
    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)
    
        pd = New PDshopFunctions()
        pd.LoadPDshop()
    
        'Get email related setup info
        pd.OpenSetupDataReader("otherxml", "email")

        contemailen = pd.ReadData("contemailen")
        contemailenb = pd.ReadData("contemailenb")
        emailto = pd.ReadData("contemailto")
        emailcc = pd.ReadData("contemailcc")

        pd.CloseData()
        
        'If Contact us is not enabled, redirect
        If contemailen <> "ON" Then
            pd.pdRedirect("../")
        End If
    
        If Not (Page.IsPostBack) Then
          
            'Process Alert Messages
            showalert = pd.getrequest("showalert")
            If showalert = "emailsent" Then
                pd.alertmessage = pd.geterrtext("err48")
            End If
            
            'Demo Mode
            If pd.shopdemomode = "Yes" Then
                captcha.Text = "123456"
            End If
    
        End If
    
        If Page.IsPostBack Then
    
            'Check form for errors
            pd.checkForm(email.Text, pd.getsystext("sys76"), "T", 3, 50)
            pd.formerror = pd.formerror & pd.checkchr(email.Text, pd.getsystext("sys76"))
            pd.checkForm(comments.Text, pd.getsystext("sys79"), "T", 0, 2000)
             
            'Verify Captcha Code
            If pd.passShopCaptcha(captcha.Text) = False Then
                pd.formerror = pd.formerror & pd.geterrtext("err71")
                captcha.Text = ""
            End If
    
            'Send Email
            If pd.formerror = "" Then
    
                emailtoname = "Admin"
                If contemailenb = "ON" Then
                    emailfrom = email.Text
                    emailfromname = name.Text
                Else
                    emailfrom = pd.emailadmin
                    emailfromname = pd.storename
                End If
                emailsubject = pd.storename & " - Contact Us Form"
                emailbody = pd.storename & ":" & vbCrLf
                emailbody = emailbody & pd.getsystext("sys76") & " - " & email.Text & vbCrLf
                emailbody = emailbody & pd.getsystext("sys77") & " - " & name.Text & vbCrLf
                emailbody = emailbody & pd.getsystext("sys78") & " - " & phone.Text & vbCrLf
                emailbody = emailbody & pd.getsystext("sys79") & " - " & comments.Text
    
                'Arguments(semailto,semailfrom,semailsubject,semailbody,semailformat,semailattachment)
                pd.Sendemail(emailto, emailcc, emailfrom, emailfromname, emailsubject, emailbody, "Text", "")
                pd.formerror = pd.geterrtext("err48")
                messagesent = "Yes"
                pd.pdRedirect("contactus.aspx?showalert=emailsent")
    
            End If
    
    
        End If
    
    
    End Sub
    
    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)
    
        If IsNothing(pd) = False Then pd.UnLoadPDshop()
    
    End Sub

</script>
<%=pd.getTopHtml(pd.pg3)%>
<%= pd.startSection("hdcontact")%>
<div class="form_container">
    <form method="POST" action="contactus.aspx" id="pageform" name="pageform" runat="server">
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="formheadings">
        <%=pd.getsystext("sys76")%></div>
    <div>
        <asp:textbox class="formfield" id="email" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys77")%></div>
    <div>
        <asp:textbox class="formfield" id="name" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys78")%></div>
    <div>
        <asp:textbox class="formfield" id="phone" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys79")%></div>
    <div>
        <asp:textbox class="formtextarea1" id="comments" wrap="true" textmode="MultiLine"
            runat="server" />
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
        <%= pd.getButton("butts14", "", "", "pageform")%></div>
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg3)%>