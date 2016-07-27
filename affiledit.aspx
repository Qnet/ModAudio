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
         
        'Handle Interactive State/Country lists
        If pd.autostlist = 1 Then
            country.AutoPostBack = True
            If Request.Form("__EVENTTARGET") = country.UniqueID Then
                updatestatelist = "Yes"
            End If
        End If
             
        If Not (Page.IsPostBack) Then
            
            'Process Alert Messages
            showalert = pd.getrequest("showalert")
            If showalert = "pwchanged" Then
                pd.alertmessage = pd.geterrtext("err7")
            End If
    
            'Open Database, get values
            pd.OpenDataReader("SELECT * FROM affiliates WHERE affillink='" & pd.FormatSqlText(affillink) & "' AND id=" & afuid)
            If pd.ReadDataItem.Read Then
                affilurl.Text = pd.ReadData("affilurl")
                company.Text = pd.ReadData("company")
                name.Text = pd.ReadData("name")
                email.Text = pd.ReadData("email")
                phone.Text = pd.ReadData("phone")
                street1.Text = pd.ReadData("street1")
                street2.Text = pd.ReadData("street2")
                city.Text = pd.ReadData("city")
                zip.Text = pd.ReadData("zip")
                tempstate = pd.ReadData("state")
                tempcountry = pd.ReadData("country")
    
            Else
                'If no record found (possible security breach).
                pd.removeCookie("afuid")
                pd.removeCookie("aflink")
                pd.pdRedirect("affilsignin.aspx")
            End If
            pd.CloseData()
             
             
            'Get Default State/Country if needed
            If pd.checkNull(tempstate) = "" Then tempstate = pd.defaultstate
            If pd.checkNull(tempcountry) = "" Then tempcountry = pd.defaultcountry
            
            'Get States & Countries Lists
            country.DataSource = pd.getcountrylist()
            country.DataBind()
            state.DataSource = pd.getstatelist(tempcountry)
            state.DataBind()
            
            If state.Items.Count = 1 Then
                state.Enabled = False
            Else
                state.Enabled = True
            End If
                
            'Set Selected State/Country          
            state.SelectedIndex = state.Items.IndexOf(state.Items.FindByValue(tempstate))
            country.SelectedIndex = country.Items.IndexOf(country.Items.FindByText(tempcountry))
    
        End If
    
        If Page.IsPostBack And updatestatelist <> "Yes" Then
    
            'Prepare Database - Argument (database tablename)
            pd.OpenDataWriter("affiliates WHERE affillink='" & pd.FormatSqlText(affillink) & "' AND id=" & afuid)
    
            'Function Arguments (column name, form id.text, Name of Field, Field Type, Min Characters, Max Characters)
            pd.AddFormData("affilurl", affilurl.Text, pd.getsystext("sys86"), "T", 5, 50)
            pd.AddFormData("email", email.Text, pd.getsystext("sys87"), "E", 5, 50)
            pd.AddFormData("name", name.Text, pd.getsystext("sys88"), "T", 5, 50)
            pd.AddFormData("company", company.Text, pd.getsystext("sys89"), "T", 5, 50)
            pd.AddFormData("phone", phone.Text, pd.getsystext("sys90"), "T", 7, 50)
            pd.AddFormData("street1", street1.Text, pd.getsystext("sys91"), "T", 3, 50)
            pd.AddFormData("street2", street2.Text, pd.getsystext("sys91"), "T", 0, 50)
            pd.AddFormData("state", state.SelectedItem.Value, pd.getsystext("sys93"), "T", 0, 50)
            pd.AddFormData("city", city.Text, pd.getsystext("sys92"), "T", 2, 50)
            pd.AddFormData("country", country.SelectedItem.Text, pd.getsystext("sys94"), "T", 0, 50)
            pd.AddFormData("zip", zip.Text, pd.getsystext("sys95"), "T", 0, 50)

            If country.SelectedItem.Text = "United States" Or country.SelectedItem.Text = "Canada" Then
                pd.checkForm(zip.Text, pd.getsystext("sys95"), "T", 5, 50)
            End If
            pd.formerror = pd.formerror & pd.checkchr(email.Text, pd.getsystext("sys23"))
    
            'If no errors, Add record to database
            If pd.formerror = "" Then
                recid = pd.SaveData()
                pd.LogAffilEvent(307, afuid, "")
                pd.pdRedirect("affilstatus.aspx")
            End If
    
        End If
         
        'Update State List for country selected
        If updatestatelist = "Yes" Then
            state.DataSource = pd.getstatelist(country.SelectedItem.Text)
            state.DataBind()
             
            If state.Items.Count = 1 Then
                state.Enabled = False
            Else
                state.Enabled = True
            End If
                   
        End If
    
    End Sub
    
    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)
    
        If IsNothing(pd) = False Then pd.UnLoadPDshop()
    
    End Sub

</script>
<%=pd.getTopHtml(pd.pg7)%>
<%= pd.startSection("heads20")%>
<div>
    <form method="POST" id="pageform" name="pageform" runat="server">
    <input type="hidden" name="task" value="post" />
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="formheadings">
        <%=pd.getsystext("sys86")%></div>
    <div>
        <asp:textbox class="formfield" id="affilurl" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys87")%></div>
    <div>
        <asp:textbox class="formfield" id="email" runat="server" />
    </div>
    <div class="messages" align="left">
        <%= pd.getButton("butts23", "", "affilchgpsswrd.aspx", "")%></div>
    <br />
    <div class="formheadings">
        <%=pd.getsystext("sys88")%></div>
    <div>
        <asp:textbox class="formfield" id="name" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys89")%></div>
    <div>
        <asp:textbox class="formfield" id="company" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys91")%></div>
    <div>
        <asp:textbox class="formfield" id="street1" runat="server" />
    </div>
    <div>
        <asp:textbox class="formfield" id="street2" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys92")%></div>
    <div>
        <asp:textbox class="formfield" id="city" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys94")%></div>
    <div>
        <asp:dropdownlist id="country" runat="server" datavaluefield="name" datatextfield="name" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys93")%></div>
    <div>
        <asp:dropdownlist id="state" runat="server" datavaluefield="abbr" datatextfield="name" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys95")%></div>
    <div>
        <asp:textbox class="formfield" id="zip" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys90")%></div>
    <div>
        <asp:textbox class="formfield" id="phone" runat="server" />
    </div>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14","","","pageform")%></div>
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg7)%>