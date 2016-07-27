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

        'Verify User.
        If pd.isSignedIn() = "No" Then pd.pdRedirect("signin.aspx")

        customerid = pd.getcookie("customerid")
        refer = pd.getrequest("refer")
         
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
            pd.OpenDataReader("SELECT * FROM customer WHERE id=" & customerid)
            If pd.ReadDataItem.Read Then

                name.Text = pd.ReadData("name")
                If pd.compen > 0 Then
                    company.Text = pd.ReadData("company")
                End If
                email.Text = pd.ReadData("email")
                phone.Text = pd.ReadData("phone")
                street1.Text = pd.ReadData("street1")
                street2.Text = pd.ReadData("street2")
                city.Text = pd.ReadData("city")
                zip.Text = pd.ReadData("zip")
                'password.text=pd.ReadDataX("password") 'Get Encrypted Data
                 
                If pd.ReadDataN("optin") = 1 Then optin.Checked = True

                tempstate = pd.ReadData("state")
                tempcountry = pd.ReadData("country")

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
            pd.OpenDataWriter("customer WHERE id=" & customerid)

            'Function Arguments (column name, form id.text, Name of Field, Field Type, Min Characters, Max Characters)
            pd.AddFormData("email", email.Text, pd.getsystext("sys23"), "E", 5, 50)
            pd.AddFormData("name", name.Text, pd.getsystext("sys26"), "T", 5, 50)
            If pd.compen = 1 Then
                pd.AddFormData("company", company.Text, pd.getsystext("sys147"), "T", 0, 50)
            End If
            If pd.compen = 2 Then
                pd.AddFormData("company", company.Text, pd.getsystext("sys147"), "T", 5, 50)
            End If
            pd.AddFormData("phone", phone.Text, pd.getsystext("sys27"), "T", 7, 50)
            pd.AddFormData("street1", street1.Text, pd.getsystext("sys28"), "T", 3, 50)
            pd.AddFormData("street2", street2.Text, pd.getsystext("sys28"), "T", 0, 50)
            pd.AddFormData("state", state.SelectedItem.Value, pd.getsystext("sys30"), "T", 0, 50)
            pd.AddFormData("city", city.Text, pd.getsystext("sys29"), "T", 2, 50)
            pd.AddFormData("country", country.SelectedItem.Text, pd.getsystext("sys32"), "T", 0, 50)
            pd.AddFormData("zip", zip.Text, pd.getsystext("sys31"), "T", 0, 50)
            If country.SelectedItem.Text = "United States" Or country.SelectedItem.Text = "Canada" Then
                pd.checkForm(zip.Text, pd.getsystext("sys31"), "T", 5, 50)
            End If
            pd.formerror = pd.formerror & pd.checkchr(email.Text, pd.getsystext("sys23"))
             
            If pd.optinen = "ON" Then
                If optin.Checked = True Then
                    pd.AddData("optin", 1, "N")
                Else
                    pd.AddData("optin", 0, "N")
                End If
            End If
             
            'Check for existing Email Address
            pd.OpenDataReader("SELECT id FROM customer WHERE id<>" & customerid & " AND email='" & pd.FormatSqlText(email.Text) & "'")
            If pd.ReadDataItem.Read Then
                pd.formerror = pd.formerror & pd.geterrtext("err27")
            End If
            pd.CloseData()

            'If no errors, Add record to database
            If pd.formerror = "" Then
                pd.SaveData()
                If refer = "" Then refer = "orderstatus.aspx"
                pd.pdRedirect(refer)
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
<%=pd.getTopHtml(pd.pg9)%>
<%= pd.startSection("heads5")%>
<div class="form_container">
    <form method="POST" action="chgprofile.aspx" id="pageform" name="pageform" runat="server">
    <input type="hidden" name="task" value="post" />
    <input type="hidden" name="refer" value="<%=pd.dohtmlencode(refer)%>" />
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="formheadings">
        <%=pd.getsystext("sys23")%></div>
    <div>
        <asp:textbox class="formfield" id="email" runat="server" />
    </div>
    <div class="messages" align="left">
        <%=pd.getButton("butts23","","chgpsswrd.aspx","") %></div>
    <br />
    <div class="formheadings">
        <%=pd.getsystext("sys26")%></div>
    <div>
        <asp:textbox class="formfield" id="name" runat="server" />
    </div>
    <% If pd.compen > 0 Then%>
    <div class="formheadings">
        <%= pd.getsystext("sys147")%></div>
    <div>
        <asp:textbox class="formfield" id="company" runat="server" />
    </div>
    <% End If%>
    <div class="formheadings">
        <%=pd.getsystext("sys28")%></div>
    <div>
        <asp:textbox class="formfield" id="street1" runat="server" />
    </div>
    <div>
        <asp:textbox class="formfield" id="street2" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys29")%></div>
    <div>
        <asp:textbox class="formfield" id="city" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys32")%></div>
    <div>
        <asp:dropdownlist id="country" runat="server" datavaluefield="name" datatextfield="name" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys30")%></div>
    <div>
        <asp:dropdownlist id="state" runat="server" datavaluefield="abbr" datatextfield="name" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys31")%></div>
    <div>
        <asp:textbox class="formfield" id="zip" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys27")%></div>
    <div>
        <asp:textbox class="formfield" id="phone" runat="server" />
    </div>
    <% If pd.optinen = "ON" Then%>
    <div class="checkboxes_container">
        <asp:checkbox id="optin" runat="server" />
        <%=pd.geterrtext("err70")%>
    </div>
    <% End If%>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14","","","pageform")%></div>
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>
