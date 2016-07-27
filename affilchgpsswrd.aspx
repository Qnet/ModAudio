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
    Public passwordchanged, refer As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        'Check if already signed in
        afuid = pd.getcookie("afuid")
        affillink = pd.getcookie("aflink")
        If Not IsNumeric(afuid) Then pd.pdRedirect("affilsignin.aspx")

        If Not (Page.IsPostBack) Then
        End If

        If Page.IsPostBack Then
            
            'Verify Old Password
            If pd.passwordverified("affiliates", afuid, oldpassword.Text) = False Then
                pd.formerror = pd.geterrtext("err9")
            End If

            'Check new Password and Save it.
            If pd.formerror = "" Then
                
                'Prepare Database - Argument (database tablename)
                pd.OpenDataWriter("affiliates WHERE id=" & afuid)

                'Function Arguments (column name, form id.text, Name of Field, Field Type, Min Characters, Max Characters)
                pd.AddFormData("password", password.Text, pd.getsystext("sys24"), "X", 5, 50)
                pd.formerror = pd.formerror & pd.checkchr(password.Text, pd.getsystext("sys24"))
             
                'Enforce Strong Passwords (if enabled)
                If pd.isPasswordStrong(password.Text) = False Then
                    pd.formerror = pd.formerror & pd.geterrtext("err72")
                End If

                'Compare new passwords
                If password.Text <> password2.Text Then
                    pd.formerror = pd.formerror & pd.geterrtext("err28")
                End If

                'If no errors, Add record to database
                If pd.formerror = "" Then
                    pd.SaveData()
                    pd.formerror = pd.geterrtext("err7")
                    pd.LogAffilEvent(207, afuid, "")
                    pd.pdRedirect("affiledit.aspx?showalert=pwchanged")
                End If
                
            End If

        End If


    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%= pd.getTopHtml(pd.pg7)%>
<%= pd.startSection("heads4")%>
<div>
    <form method="POST" action="affilchgpsswrd.aspx" id="pageform" name="pageform" runat="server">
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="formheadings">
        <%=pd.getsystext("sys62")%></div>
    <div>
        <asp:textbox class="formfield3" textmode="password" id="oldpassword" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys63")%></div>
    <div>
        <asp:textbox class="formfield3" textmode="password" id="password" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys64")%></div>
    <div>
        <asp:textbox class="formfield3" textmode="password" id="password2" runat="server" />
    </div>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14","","","pageform")%></div>
    </form>
</div>
<%= pd.endSection()%>
<%= pd.getBottomHtml(pd.pg7)%>
