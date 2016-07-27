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
    Public refer, affillink, afuid As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()

        'Check if already signed in
        afuid = pd.getcookie("afuid")
        affillink = pd.getcookie("aflink")
        If afuid = "" Then
            pd.pdRedirect("affilsignin.aspx")
        End If

        'Get email setup data
        pd.OpenSetupDataReader("otherxml", "email")

        affilconfe = pd.ReadData("affilconfe")
        emailfrom3 = pd.ReadData("emailfrom3")
        emailfromname3 = pd.ReadData("emailfromname3")
        emailsubject3 = pd.ReadData("emailsubject3")
        emailbody3 = pd.ReadData("emailbody3")
        notifyadmin = pd.ReadData("notifyadmin")
        orderemailto = pd.ReadData("orderemailto")
        orderemailcc = pd.ReadData("orderemailcc")

        pd.CloseData()


        'Open Database, get values
        pd.OpenDataReader("SELECT * FROM affiliates WHERE affillink='" & pd.FormatSqlText(affillink) & "' AND id=" & afuid)
        If pd.ReadDataItem.Read Then
            affilurl = pd.ReadData("affilurl")
            company = pd.ReadData("company")
            Name = pd.ReadData("name")
            email = pd.ReadData("email")
            phone = pd.ReadData("phone")
            street1 = pd.ReadData("street1")
            street2 = pd.ReadData("street2")
            city = pd.ReadData("city")
            zip = pd.ReadData("zip")
            password = pd.ReadDataX("password") 'Get Encrypted Data
            state = pd.ReadData("state")
            country = pd.ReadData("country")

        Else
            'If no record found (possible security breach).
            pd.removeCookie("afuid")
            pd.removeCookie("aflink")
            pd.pdRedirect("affilsignin.aspx")
        End If
        pd.CloseData()


        'Send Affiliate emails when needed
        If pd.getcookie("afconf") = "Y" Then

            'Send Order Confirmation Email
            If affilconfe = "ON" Then

                emailto = email
                emailtoname = name
                emailfrom = emailfrom3
                emailfromname = emailfromname3
                emailsubject = emailsubject3
                emailbody = emailbody3
                emailbody = Replace(emailbody, "##AFFILNAME##", Name)
                emailbody = Replace(emailbody, "##AFFILID##", affillink)
                emailbody = Replace(emailbody, "##AFFILPASS##", password)
                emailbody = Replace(emailbody, "##AFFILLINK##", pd.shopurl & "?affillink=" & affillink)

                'Arguments(semailto,semailfrom,semailsubject,semailbody,semailformat,semailattachment)
                pd.Sendemail(emailto, emailcc, emailfrom, emailfromname, emailsubject, emailbody, "Text", "")

            End If

            'Send Admin Notification Email
            If notifyadmin = "ON" Then

                emailto = orderemailto
                emailcc = orderemailcc
                emailfrom = pd.emailadmin
                emailfromname = pd.storename
                emailsubject = pd.storename & " - Affiliate Notification"
                emailbody = "New Affiliate has registered!" & vbCrLf & "Affiliate Name: " & Name & vbCrLf & "Company: " & company & vbCrLf & "Website: " & affilurl & vbCrLf & "Affiliate ID: " & affillink

                'Arguments(semailto,semailfrom,semailsubject,semailbody,semailformat,semailattachment)
                pd.Sendemail(emailto, emailcc, emailfrom, emailfromname, emailsubject, emailbody, "Text", "")

            End If
            'Flag that Email has been sent
            pd.removeCookie("afconf")
        End If


        If Page.IsPostBack Then

        End If

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg7)%>
<%= pd.startSection("heads10")%>
<div>
    <div class="messages">
        <%=pd.getsystext("sys84")%></div>
    <div class="itemname">
        <%=affillink%></div>
    <div class="messages">
        <%=pd.getsystext("sys96")%></div>
    <div class="itemname">
        <%=pd.shopurl%>default.aspx?affillink=<%=affillink%></div>
    <div class="formbuttons_container">
        <%=pd.getButton("butts16","","affiledit.aspx?&refer=affilstatus.aspx","") %>
        <%=pd.getButton("butts3","","affilsignin.aspx?task=signout","") %></div>
</div>
<%= pd.endSection()%>
<%= pd.startSection("heads21")%>
<div>
    <form method="POST" action="affilreport.aspx" target="_blank" name="affilform" id="affilform">
    <input type="hidden" name="affillink" value="<%=affillink%>" />
    <input type="hidden" name="afuid" value="<%=afuid%>" />
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="formheadings">
        <%=pd.getsystext("sys97")%></div>
    <div>
        <input class="formfield3" type="text" name="startdate" value="<%=pd.showdate(DateTime.Now.AddDays(-31).ToShortDateString)%>" /></div>
    <div class="formheadings">
        <%=pd.getsystext("sys98")%></div>
    <div>
        <input class="formfield3" type="text" name="enddate" value="<%=pd.showdate(DateTime.Now.ToShortDateString)%>" /></div>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14","","","affilform")%></div>
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg7)%>
