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
    Public task, updatestatelist As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        'Verify if can Checkout.
        If pd.hasCartItems() = "No" Then pd.pdRedirect("showcart.aspx")
        If pd.hasBillingAddress() = "No" Then
            pd.pdRedirect("checkout1.aspx")
        End If
         
        'Verifies if there is an order, and if the Shipping address is present.      
        If pd.hasShippingAddress() = "Yes" And pd.getrequest("task") <> "edit" Then
            pd.pdRedirect("checkout3.aspx")
        End If

        If pd.getrequest("task") = "edit" Then task = "edit"

        'Get and check/sanitize ids, makes sure they are formatted correctly
        orderid = pd.getcookie("orderid")
        cartid = pd.getcookie("cartid")

        'Handle Interactive State/Country lists
        If pd.autostlist = 1 Then
            country.AutoPostBack = True
            If Request.Form("__EVENTTARGET") = country.UniqueID Then
                updatestatelist = "Yes"
            End If
        End If

        'Call function to get customer address for 'Auto-Fill'
        pd.getOrderVariables("", orderid, cartid)

        'If Shipping Not Required for this order
        If pd.checkifshipping() = "No" Or pd.getrequest("shipsame") <> "" Then

            'Prepare Database - Argument (database tablename)
            pd.OpenDataWriter("orders WHERE id=" & orderid & " AND cartid='" & cartid & "'")
            pd.AddData("shipname", pd.sBillName, "T")
            pd.AddData("shipcompany", pd.sBillCompany, "T")
            pd.AddData("shipstreet1", pd.sBillstreet1, "T")
            pd.AddData("shipstreet2", pd.sBillstreet2, "T")
            pd.AddData("shipstate", pd.sBillstate, "T")
            pd.AddData("shipcity", pd.sBillcity, "T")
            pd.AddData("shipcountry", pd.sBillcountry, "T")
            pd.AddData("shipzip", pd.sBillZip, "T")

            pd.AddData("orderno", pd.getorderno(), "N")
            pd.AddData("salestax", pd.gettaxrate(pd.sBillstate, pd.sBillcountry), "N2")
            pd.AddData("taxship", pd.sTaxship, "T") 'must proceed gettaxrate.
             
            If pd.getrequest("shipsame") = "com" Then
                pd.AddData("shipresdel", 0, "N")
            Else
                pd.AddData("shipresdel", 1, "N")
            End If

            pd.SaveData()
            pd.pdRedirect("checkout3.aspx")

        End If
         

        If Not (Page.IsPostBack) Then

            'Make Residential the default
            shipresdel.Checked = True
             
            'If already completed, editing, open Database and get values
            pd.OpenDataReader("SELECT * FROM orders WHERE id=" & orderid & " AND cartid='" & cartid & "'")
            If pd.ReadDataItem.Read Then

                name.Text = pd.ReadData("shipname")
                If pd.compen > 0 Then
                    company.Text = pd.ReadData("shipcompany")
                End If
                street1.Text = pd.ReadData("shipstreet1")
                street2.Text = pd.ReadData("shipstreet2")
                city.Text = pd.ReadData("shipcity")
                zip.Text = pd.ReadData("shipzip")
                tempstate = pd.ReadData("shipstate")
                tempcountry = pd.ReadData("shipcountry")
                If pd.ReadDataN("shipresdel") = 0 Then shipresdel.Checked = False

            End If
            pd.CloseData()
                          
            'Get Default State/Country if needed
            If pd.checkNull(tempstate) = "" Then tempstate = pd.sBillstate
            If pd.checkNull(tempcountry) = "" Then tempcountry = pd.sBillcountry
            
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
            pd.OpenDataWriter("orders WHERE id=" & orderid & " AND cartid='" & cartid & "'")

            'Function Arguments (column name, form id.text, Name of Field, Field Type, Min Characters, Max Characters)
            pd.AddFormData("shipname", name.Text, pd.getsystext("sys26"), "T", 5, 50)
            If pd.compen = 1 Then
                pd.AddFormData("shipcompany", company.Text, pd.getsystext("sys147"), "T", 0, 50)
            End If
            If pd.compen = 2 Then
                pd.AddFormData("shipcompany", company.Text, pd.getsystext("sys147"), "T", 5, 50)
            End If
            pd.AddFormData("shipstreet1", street1.Text, pd.getsystext("sys28"), "T", 3, 50)
            pd.AddFormData("shipstreet2", street2.Text, pd.getsystext("sys28"), "T", 0, 50)
            pd.AddFormData("shipstate", state.SelectedItem.Value, pd.getsystext("sys30"), "T", 0, 50)
            pd.AddFormData("shipcity", city.Text, pd.getsystext("sys29"), "T", 2, 50)
            pd.AddFormData("shipcountry", country.SelectedItem.Text, pd.getsystext("sys32"), "T", 0, 50)
            pd.AddFormData("shipzip", zip.Text, pd.getsystext("sys31"), "T", 0, 50)
            If country.SelectedItem.Text = "United States" Or country.SelectedItem.Text = "Canada" Then
                pd.checkForm(zip.Text, pd.getsystext("sys31"), "T", 5, 50)
            End If
             
            pd.AddData("orderno", pd.getorderno(), "N")
             
            'reset shipping, so that customer needs to re-select shipping             
            pd.AddData("ratemethod", 0, "N")
             
            pd.AddData("salestax", pd.gettaxrate(state.SelectedItem.Value, country.SelectedItem.Value), "N2")
            pd.AddData("taxship", pd.sTaxship, "T") 'must follow gettaxrate.
            If shipresdel.Checked = True Then
                pd.AddData("shipresdel", 1, "N")
            Else
                pd.AddData("shipresdel", 0, "N")
            End If
               
            'Verify Address with USPS
            If pd.formerror = "" Then
                If pd.verifyuspsaddress(street1.Text, street2.Text, city.Text, state.SelectedItem.Value, zip.Text, country.SelectedItem.Value) = False Then
                    pd.formerror = pd.geterrtext("err77") & " [" & pd.uspserror & "]"
                End If
            End If
            
            'If no errors, Add record to database
            If pd.formerror = "" Then
                
                pd.SaveData()
                If pd.getrequest("task") = "edit" Then
                    pd.pdRedirect("checkout3.aspx?task=edit")
                Else
                    pd.pdRedirect("checkout3.aspx")
                End If

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
<script language="JavaScript">

<!-- Function for auto-complete shipping address!
function fillAddressFields(form) {
    form.elements['name'].value = '<%=pd.fixjavavar(pd.sBillName)%>';
    <% if pd.compen>0 then %>
    form.elements['company'].value = '<%=pd.fixjavavar(pd.sBillCompany)%>';
    <% end if %>
    form.elements['street1'].value = '<%=pd.fixjavavar(pd.sBillStreet1)%>';
    form.elements['street2'].value = '<%=pd.fixjavavar(pd.sBillStreet2)%>';
    form.elements['city'].value = '<%=pd.fixjavavar(pd.sBillCity)%>';
    form.elements['state'].value = '<%=pd.fixjavavar(pd.sBillState)%>';
    form.elements['zip'].value = '<%=pd.fixjavavar(pd.sBillZip)%>';
    form.elements['country'].value = '<%=pd.fixjavavar(pd.sBillCountry)%>';
}
//-->
</script>
<%= pd.startSection("heads6")%>
<div class="form_container">
    <form method="POST" action="checkout2.aspx" id="pageform" name="pageform" runat="server">
    <input type="hidden" name="task" value="<%=task%>" />
    <div class="messages">
        <%=pd.getFormError()%></div>
    <% If task <> "edit" And updatestatelist <> "Yes" Then%>
    <div class="checkboxes_container">
        <asp:checkbox onclick="if (this.checked) fillAddressFields(this.form)" id="tempbillshipsame"
            value="yes" runat="server" class="checkboxes" />
        <%=pd.getsystext("sys35")%></div>
    <% End If%>
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
    <div class="checkboxes_container">
        <asp:checkbox id="shipresdel" runat="server" class="checkboxes" />
        <%=pd.getsystext("sys37")%></div>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14","","","pageform")%></div>
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>
