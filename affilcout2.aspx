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
         
        'Handle Interactive State/Country lists
        If pd.autostlist = 1 Then
            country.AutoPostBack = True
            If Request.Form("__EVENTTARGET") = country.UniqueID Then
                updatestatelist = "Yes"
            End If
        End If
         
    
        If Not (Page.IsPostBack) Then
    
            'Get Default State/Country if needed
            tempstate = pd.defaultstate
            tempcountry = pd.defaultcountry
            
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
            pd.OpenDataWriter("affiliates")
    
            'Function Arguments (column name, form id.text, Name of Field, Field Type, Min Characters, Max Characters)
            pd.AddFormData("affilurl", affilurl.Text, pd.getsystext("sys86"), "T", 5, 50)
            pd.AddFormData("email", email.Text, pd.getsystext("sys87"), "E", 5, 50)
            pd.AddFormData("password", password.Text, pd.getsystext("sys24"), "X", 5, 50)
            pd.AddFormData("name", name.Text, pd.getsystext("sys88"), "T", 5, 50)
            pd.AddFormData("company", company.Text, pd.getsystext("sys89"), "T", 5, 50)
            pd.AddFormData("phone", phone.Text, pd.getsystext("sys90"), "T", 7, 50)
            pd.AddFormData("street1", street1.Text, pd.getsystext("sys91"), "T", 3, 50)
            pd.AddFormData("street2", street2.Text, pd.getsystext("sys91"), "T", 0, 50)
            pd.AddFormData("state", state.SelectedItem.Value, pd.getsystext("sys93"), "T", 0, 50)
            pd.AddFormData("city", city.Text, pd.getsystext("sys92"), "T", 2, 50)
            pd.AddFormData("country", country.SelectedItem.Text, pd.getsystext("sys94"), "T", 0, 50)
            pd.AddFormData("zip", zip.Text, pd.getsystext("sys95"), "T", 0, 50)
    
            'Check Data
            If password.Text <> password2.Text Then
                pd.formerror = pd.formerror & pd.geterrtext("err28")
            End If
            If country.SelectedItem.Text = "United States" Or country.SelectedItem.Text = "Canada" Then
                pd.checkForm(zip.Text, pd.getsystext("sys95"), "T", 5, 50)
            End If
            pd.formerror = pd.formerror & pd.checkchr(email.Text, pd.getsystext("sys23"))
            pd.formerror = pd.formerror & pd.checkchr(password.Text, pd.getsystext("sys24"))
             
            'Enforce Strong Passwords (if enabled)
            If pd.isPasswordStrong(password.Text) = False Then
                pd.formerror = pd.formerror & pd.geterrtext("err72")
            End If
    
            'Check for existing Email Address
            pd.OpenDataReader("SELECT id FROM affiliates WHERE email='" & pd.FormatSqlText(email.Text) & "'")
            If pd.ReadDataItem.Read Then
                pd.formerror = pd.formerror & pd.geterrtext("err27")
            End If
            pd.CloseData()
    
            'Get default Affiliate commission
            pd.OpenSetupDataReader("setupxml", "setup")

            affilcomm = pd.ReadDataN("affilcomm")

            pd.CloseData()
    
    
            'If no errors, Add record to database
            If pd.formerror = "" Then
                'Create Affiliate Link
                affillink = pd.createaffillink(affilurl.Text)
                pd.AddData("affillink", affillink, "T")
                pd.AddData("commission", affilcomm, "N")
                recid = pd.SaveData()
                pd.savecookie("afuid", recid, 0)
                pd.savecookie("aflink", affillink, 0)
                'Create Flag to send Email Confirmation to New Affiliate
                pd.savecookie("afconf", "Y", 0)
                pd.LogAffilEvent(306, recid, affillink)
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
            
            'Force Password fields to show masked passwords.
            If Not password.Text = "" And Not password2.Text = "" Then
                ViewState(password.Text) = password.Text
                password.Attributes.Add("value", ViewState(password.Text).ToString())
                ViewState(password2.Text) = password2.Text
                password2.Attributes.Add("value", ViewState(password2.Text).ToString())
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
    <form method="POST" action="affilcout2.aspx" id="pageform" name="pageform" runat="server">
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
    <div class="formheadings">
        <%=pd.getsystext("sys24")%></div>
    <div>
        <asp:textbox class="formfield3" textmode="password" id="password" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys25")%></div>
    <div>
        <asp:textbox class="formfield3" textmode="password" id="password2" runat="server" />
    </div>
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