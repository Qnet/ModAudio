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
    Public refer As String
    
    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)
    
        If IsNothing(pd) = False Then pd.PDShopError()
    
    End Sub
    
    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)
    
        pd = New PDshopFunctions()
        pd.LoadPDshop()
    
        'Check if already signed in
        affiliateuserid = pd.getcookie("afuid")
        If afuid <> "" Then
            pd.pdRedirect("affilstatus.aspx")
        End If
    

        'Process Alert Messages
        showalert = pd.getrequest("showalert")
        If showalert = "emailsent" Then
            pd.alertmessage = pd.geterrtext("err8")
        End If
        
        'Demo Mode
        If pd.shopdemomode = "Yes" Then
            captcha.Text = "123456"
        End If
                        
    
        'Sign Out User if task is desired.
        If pd.getrequest("task") = "signout" Then
            pd.removeCookie("afuid")
            pd.removeCookie("aflink")
            pd.formerror = "You have been signed out!"
            pd.LogAffilEvent(301, affiliateuserid, "")
        End If
    
        'Sign In
        If Page.IsPostBack Then
            saffillink = affillink.Text
            spassword = password.Text
            task = "signin"
        End If

        If task = "signin" Then
    
            'Check Affiliate Login for invalid characters
            pd.formerror = pd.checkchr(saffillink, pd.getsystext("sys84"))
             
            'Verify Captcha Code
            If pd.passShopCaptcha(captcha.Text) = False Then
                pd.formerror = pd.formerror & pd.geterrtext("err71")
                captcha.Text = ""
            End If
    
            If pd.formerror = "" Then
    
                'Search for affiliate by affillink
                pd.OpenDataReader("SELECT * FROM affiliates WHERE affillink='" & pd.FormatSqlText(saffillink) & "'")
                If pd.ReadDataItem.Read Then
                    affiliateuserid = pd.ReadDataN("id")
                Else
                    pd.formerror = pd.geterrtext("err51")
                    pd.LogAffilEvent(302, 0, saffillink)
                End If
                pd.CloseData()
                
                'Verify Password
                If pd.formerror = "" Then
                    If pd.passwordverified("affiliates", affiliateuserid, password.Text) = False Then
                        pd.formerror = pd.geterrtext("err51")
                        pd.LogAffilEvent(302, affiliateuserid, saffillink)
                    End If
                End If
    
                'If no errors, sign in!
                If pd.formerror = "" Then
                    pd.savecookie("afuid", affiliateuserid, 0)
                    pd.savecookie("aflink", saffillink, 0)
                    pd.LogAffilEvent(300, affiliateuserid, saffillink)
                    pd.pdRedirect("affilstatus.aspx")
                End If
                                  
            Else
                
                'Force Password fields to show masked passwords.
                If Not password.Text = "" Then
                    ViewState(password.Text) = password.Text
                    password.Attributes.Add("value", ViewState(password.Text).ToString())
                End If
    
            End If
    
        End If
    
    End Sub
    
    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)
    
        If IsNothing(pd) = False Then pd.UnLoadPDshop()
    
    End Sub

</script>
<%=pd.getTopHtml(pd.pg7)%>
<%= pd.startSection("heads18")%>
<div>
    <form method="POST" action="affilsignin.aspx" id="pageform" name="pageform" runat="server">
    <input type="hidden" name="refer" value="<%=pd.dohtmlencode(refer)%>">
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="formheadings">
        <%=pd.getsystext("sys84")%></div>
    <div>
        <asp:textbox class="formfield" id="affillink" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys85")%></div>
    <div>
        <asp:textbox class="formfield" textmode="password" id="password" runat="server" />
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
    <% If pd.passemail = "ON" Then%>
    <div class="messages">
        <%=pd.getButton("butts24","","affilemailpass.aspx","") %></div>
    <% End If%>
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg7)%>