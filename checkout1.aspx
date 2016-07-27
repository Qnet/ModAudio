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
    Public task, tempstate, tempcountry, updatestatelist As String
    
    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)
    
        If IsNothing(pd) = False Then pd.PDShopError()
    
    End Sub
    
    
    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)
    
        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()
    
        'Check if has a shopping cart, or is already signed in.
        If pd.hasStartedPayPal() = "Yes" Then pd.pdRedirect("paypal_express2.aspx")
        If pd.hasCartItems() = "No" Then pd.pdRedirect("showcart.aspx")
         
        'Make sure Address is complete
        If pd.hasBillingAddress() = "Yes" Then
            If pd.getrequest("task") = "edit" Then
                task = "edit"
            Else
                pd.pdRedirect("checkout2.aspx")
            End If
        End If
        
        'Get and check/sanitize ids
        customerid = pd.getcookie("customerid")
        orderid = pd.getcookie("orderid")
        cartid = pd.getcookie("cartid")
        
        'Handle Interactive State/Country lists
        If pd.autostlist = 1 Then
            country.AutoPostBack = True
            If Request.Form("__EVENTTARGET") = country.UniqueID Then
                updatestatelist = "Yes"
            End If
        End If
                      
        If Not (Page.IsPostBack) Then
           
            'Set defaults for shipping
            shipsame.Checked = True
            shipsameres.Checked = True
            
            'Bypass Billing Address if returning customer is already signed in 
            If pd.isSignedIn() = "Yes" And task <> "edit" Then
            
                'Get customer data
                pd.getCustomerVariables(customerid)
                
                'If customer account does not have address
                If pd.sName = "" Then
                    pd.pdRedirect("chgprofile.aspx?refer=checkout1.aspx")
                End If
                 
                'Prepare Database - Argument (database tablename)
                pd.OpenDataWriter("orders")
                pd.AddData("billname", pd.sName, "T")
                pd.AddData("billcompany", pd.sCompany, "T")
                pd.AddData("billstreet1", pd.sStreet1, "T")
                pd.AddData("billstreet2", pd.sStreet2, "T")
                pd.AddData("billstate", pd.sState, "T")
                pd.AddData("billcity", pd.sCity, "T")
                pd.AddData("billcountry", pd.sCountry, "T")
                pd.AddData("billzip", pd.sZip, "T")
                pd.AddData("billemail", pd.sEmail, "T")
                pd.AddData("billphone", pd.sPhone, "T")
                pd.AddData("cartid", cartid, "T")
                pd.AddData("orderdate", pd.showdate(DateTime.Now.ToShortDateString), "D")
                pd.AddData("ordertime", DateTime.Now.ToLongTimeString, "T")
                pd.AddData("status", "Incomplete", "T")
                pd.AddData("ipaddr", Request.ServerVariables("REMOTE_ADDR"), "T")
                pd.AddData("customerid", customerid, "N")
                pd.AddData("orderno", 0, "N")
                pd.AddData("salestax", 0, "N2")
                pd.AddData("shipresdel", 1, "N")
                pd.AddData("ratemethod", 0, "N") 'Signifies that shipping step not completed.
                pd.AddData("affillink", pd.getcookie("affillink"), "T")


                'Apply Discounts & Gift Cert. to order
                If pd.getcookie("disc") <> "" Then
                    discarr = Split(pd.getcookie("disc"), "|")
                    pd.AddData("discpct", Convert.ToDecimal(discarr(2)), "N")
                    pd.AddData("discamt", Convert.ToDecimal(discarr(1)), "N")
                    pd.AddData("disccode", discarr(0), "T")
                Else
                    pd.AddData("discpct", 0, "N")
                    pd.AddData("discamt", 0, "N")
                    pd.AddData("disccode", "", "T")
                End If
                If pd.getcookie("gift") <> "" Then
                    giftarr = Split(pd.getcookie("gift"), "|")
                    pd.AddData("giftcode", giftarr(0), "T")
                    pd.AddData("giftamt", Convert.ToDecimal(giftarr(1)), "N")
                Else
                    pd.AddData("giftcode", "", "T")
                    pd.AddData("giftamt", 0, "N")
                End If

                recid = pd.SaveData()
                pd.savecookie("orderid", recid, 0)
                pd.pdRedirect("checkout2.aspx")
                           
            End If
             
            'If already completed, open database and get values
            If task = "edit" Then
                pd.OpenDataReader("SELECT * FROM orders WHERE id=" & orderid & " AND cartid='" & cartid & "'")
                If pd.ReadDataItem.Read Then

                    name.Text = pd.ReadData("billname")
                    If pd.compen > 0 Then
                        company.Text = pd.ReadData("billcompany")
                    End If
                    street1.Text = pd.ReadData("billstreet1")
                    street2.Text = pd.ReadData("billstreet2")
                    city.Text = pd.ReadData("billcity")
                    zip.Text = pd.ReadData("billzip")
                    email.Text = pd.ReadData("billemail")
                    phone.Text = pd.ReadData("billphone")
                    tempstate = pd.ReadData("billstate")
                    tempcountry = pd.ReadData("billcountry")
                    
                End If
                pd.CloseData()
            End If
  
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

            'Prepare Database
            If task = "edit" Then
                pd.OpenDataWriter("orders WHERE id=" & orderid & " AND cartid='" & cartid & "'")
            Else
                pd.OpenDataWriter("orders")
                
                pd.AddData("orderdate", pd.showdate(DateTime.Now.ToShortDateString), "D")
                pd.AddData("ordertime", DateTime.Now.ToLongTimeString, "T")
                pd.AddData("status", "Incomplete", "T")
                pd.AddData("ipaddr", Request.ServerVariables("REMOTE_ADDR"), "T")
                pd.AddData("customerid", 0, "N")
                pd.AddData("orderno", 0, "N")
                pd.AddData("affillink", pd.getcookie("affillink"), "T")
                pd.AddData("cartid", cartid, "T")
                pd.AddData("salestax", 0, "N")
                pd.AddData("shipresdel", 1, "N")
                pd.AddData("ratemethod", 0, "N") 'Signifies that shipping step not completed.

                'Apply Discounts & Gift Cert. to order
                If pd.getcookie("disc") <> "" Then
                    discarr = Split(pd.getcookie("disc"), "|")
                    pd.AddData("discpct", Convert.ToDecimal(discarr(2)), "N")
                    pd.AddData("discamt", Convert.ToDecimal(discarr(1)), "N")
                    pd.AddData("disccode", discarr(0), "T")
                Else
                    pd.AddData("discpct", 0, "N")
                    pd.AddData("discamt", 0, "N")
                    pd.AddData("disccode", "", "T")
                End If
                If pd.getcookie("gift") <> "" Then
                    giftarr = Split(pd.getcookie("gift"), "|")
                    pd.AddData("giftcode", giftarr(0), "T")
                    pd.AddData("giftamt", Convert.ToDecimal(giftarr(1)), "N")
                Else
                    pd.AddData("giftcode", "", "T")
                    pd.AddData("giftamt", 0, "N")
                End If
                
            End If

            'Function Arguments (column name, form id.text, Name of Field, Field Type, Min Characters, Max Characters)
            pd.AddFormData("billname", name.Text, pd.getsystext("sys26"), "T", 5, 50)
            If pd.compen = 1 Then
                pd.AddFormData("billcompany", company.Text, pd.getsystext("sys147"), "T", 0, 50)
            End If
            If pd.compen = 2 Then
                pd.AddFormData("billcompany", company.Text, pd.getsystext("sys147"), "T", 5, 50)
            End If
            pd.AddFormData("billstreet1", street1.Text, pd.getsystext("sys28"), "T", 3, 50)
            pd.AddFormData("billstreet2", street2.Text, pd.getsystext("sys28"), "T", 0, 50)
            pd.AddFormData("billstate", state.SelectedItem.Value, pd.getsystext("sys30"), "T", 0, 50)
            pd.AddFormData("billcity", city.Text, pd.getsystext("sys29"), "T", 2, 50)
            pd.AddFormData("billcountry", country.SelectedItem.Text, pd.getsystext("sys32"), "T", 0, 50)
            pd.AddFormData("billzip", zip.Text, pd.getsystext("sys31"), "T", 0, 50)
            If country.SelectedItem.Text = "United States" Or country.SelectedItem.Text = "Canada" Then
                pd.checkForm(zip.Text, pd.getsystext("sys31"), "T", 5, 50)
            End If
            pd.AddFormData("billemail", email.Text, pd.getsystext("sys23"), "E", 5, 50)
            pd.AddFormData("billphone", phone.Text, pd.getsystext("sys27"), "T", 5, 50)

            'If no errors, Add record to database
            If pd.formerror = "" Then

                recid = pd.SaveData()
                If task = "edit" Then
                    pd.pdRedirect("orderreview.aspx")
                Else
                    pd.savecookie("orderid", recid, 0)
                    
                    If shipsame.Checked = True Then
                        If shipsameres.Checked = True Then
                            pd.pdRedirect("checkout2.aspx?shipsame=res")
                        Else
                            pd.pdRedirect("checkout2.aspx?shipsame=com")
                        End If
                    Else
                        pd.pdRedirect("checkout2.aspx")
                    End If
                    
                End If

            End If

    
        End If
        
        'Prevent Page from loading if "Only Pre-registered customers" is enabled
        If pd.checkoutflow = 4 And pd.isSignedIn() = "No" Then pd.pdRedirect("signin.aspx?refer=checkout1.aspx")
         
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
    
 
    'Update State List for selected country (ASP.NET 1.1 DOES NOT SUPPORT THIS - Using __EVENTTARGET Request instead for backward compatibility)
    'Private Sub country_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles country.SelectedIndexChanged
        
    'state.DataSource = pd.getstatelist(country.SelectedItem.Text) 
    'state.DataBind()    

    'End Sub 
       
    
    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)
    
        If IsNothing(pd) = False Then pd.UnLoadPDshop()
    
    End Sub
    

</script>
<%=pd.getTopHtml(pd.pg9)%>
<%= pd.startSection("heads5")%>
<div class="form_container">
    <form method="POST" action="checkout1.aspx" id="pageform" name="pageform" runat="server">
    <input type="hidden" name="task" value="<%=task%>">
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="formheadings">
        <%=pd.getsystext("sys23")%></div>
    <div>
        <asp:textbox class="formfield" id="email" runat="server" />
    </div>
    <div class="formheadings2">
        <%=pd.getsystext("sys33")%></div>
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
    <% If task <> "edit" And pd.checkifshipping() = "Yes" Then%>
    <div class="formheadings2">
        <%= pd.getsystext("sys34")%></div>
    <div class="checkboxes_container">
        <asp:checkbox id="shipsame" runat="server" class="checkboxes" />
        <%=pd.getsystext("sys35")%></div>
    <div class="checkboxes_container">
        <asp:checkbox id="shipsameres" runat="server" class="checkboxes" />
        <%=pd.getsystext("sys37")%></div>
    <% End If%>
    <div class="formbuttons_container">
        <%= pd.getButton("butts14", "", "", "pageform")%></div>
    </form>
</div>
<%=pd.EndSection()%>
<%=pd.getBottomHtml(pd.pg9)%>