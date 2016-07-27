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
        pd.browserNoCache()
        pd.LoadPDshop()

        task = pd.getrequest("task")
        refer = pd.getrequest("refer")

        'Sign Out User if task is desired.
        If task = "signout" Then
            pd.LogShopEvent(201, pd.getcookie("customerid"), "")
            pd.signUserOut()
        End If

        'If already signed in, redirect
        If pd.isSignedIn() = "Yes" Then pd.pdRedirect("orderstatus.aspx")
        

        If Not (Page.IsPostBack) Then
         
            'Process Alert Messages
            showalert = pd.getrequest("showalert")
            If showalert = "emailsent" Then
                pd.alertmessage = pd.geterrtext("err8")
            End If
            
            'Enforce Secure Connection, PCI Compliance
            If pd.urlen = "Yes" And InStr(LCase(pd.shopsslurl), "https") <> 0 Then
                pd.jssecureredirect(pd.shopsslurl & "signin.aspx")
                'pageform.Action = pd.shopsslurl & "signin.aspx" '(only works with ASP.NET 2.0 SP2 and higher)
            End If
            
            'Demo Mode
            If pd.shopdemomode = "Yes" Then
                captcha.Text = "123456"
            End If
            
        End If

        If Page.IsPostBack Then

            semail = email.Text
            spassword = password.Text

            'Check email for invalid characters
            pd.formerror = pd.checkchr(semail, pd.getsystext("sys23"))
             
            'Verify Captcha Code
            If pd.passShopCaptcha(captcha.Text) = False Then
                pd.formerror = pd.formerror & pd.geterrtext("err71")
                captcha.Text = ""
            End If

            'Search for customer by email
            If pd.formerror = "" Then
                pd.OpenDataReader("SELECT * FROM customer WHERE email='" & pd.FormatSqlText(semail) & "'")
                If pd.ReadDataItem.Read Then
                    
                    customerid = pd.ReadDataN("id")
                    clockout = pd.ReadDataN("lockout")
                     
                    'If customer is locked out
                    If clockout = 1 Then
                        pd.formerror = pd.geterrtext("err69")
                        pd.LogShopEvent(203, customerid, "")
                    End If
                     
                Else
                    pd.formerror = pd.geterrtext("err50")
                    pd.LogShopEvent(202, 0, semail)
                End If
                pd.CloseData()
                
                'Verify Password
                If pd.formerror = "" Then
                    If pd.passwordverified("customer", customerid, password.Text) = False Then
                        pd.formerror = pd.geterrtext("err51")
                        pd.LogShopEvent(202, customerid, "")
                    End If
                End If
                 
            End If

            'Sign In
            If pd.formerror = "" Then

                'Sign User In & Redirect to Next Page
                If refer = "" Then refer = "orderstatus.aspx"
                pd.LogShopEvent(200, customerid, "")
                pd.signUserIn(customerid, refer)
                 
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
<%=pd.getTopHtml(pd.pg9)%>
<%= pd.startSection("heads4")%>
<div class="form_container">
    <form method="POST" id="pageform" name="pageform" runat="server">
    <input type="hidden" name="refer" value="<%=pd.dohtmlencode(refer)%>" />
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="formheadings">
        <%=pd.getsystext("sys23")%></div>
    <div>
        <asp:textbox class="formfield" id="email" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys24")%></div>
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
        <%= pd.getButton("butts14", "", "", "pageform")%></div>
    </form>
    <%  If pd.passemail = "ON" Then%>
    <div class="messages">
        <%=pd.getButton("butts24","","emailpassword.aspx","") %></div>
    <%  End If%>
</div>
<%= pd.endSection()%>
<!-- Allow User Registration if options allow -->
<%  If pd.checkoutflow <> 4 Then%>
<%= pd.startSection("heads31")%>
<div>
    <div class="cartbuttons_container">
        <%=pd.getButton("butts12", "", pd.shopsslurl & "register.aspx?refer=" & refer,"")%></div>
</div>
<%= pd.endSection()%>
<%  End If%>
<%=pd.getBottomHtml(pd.pg9)%>
