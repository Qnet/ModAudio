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
    Public method, amtmethod, nexttask, giftid As String
    
    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)
    
        If IsNothing(pd) = False Then pd.PDShopError()
    
    End Sub
    
    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)
    
        pd = New PDshopFunctions()
        pd.LoadPDshop()
         
        'Checks your Shop Access/Checkout settings.
        pd.VerifyShopAccess()
    
        'Check for cartid.
        cartid = pd.getcookie("cartid")
        If cartid = "" Then
            cartid = pd.getrandseq()
            pd.saveCookie("cartid", cartid, 0)
        End If
    
        giftid = pd.getrequest("giftid")
        task = pd.getrequest("task")
        If task = "" Then
            nexttask = "add"
        Else
            nexttask = task
        End If
        amtmethod = pd.getrequest("amtmethod")
        method = pd.getrequest("method")
         
        'Handle Interactive State/Country lists
        If pd.autostlist = 1 Then
            country.AutoPostBack = True
            If Request.Form("__EVENTTARGET") = country.UniqueID Then
                updatestatelist = "Yes"
            End If
        End If
    
        If Not (Page.IsPostBack) Then
    
            'Get Lists
            fixamount.DataSource = pd.getgiftcertamounts()
            fixamount.DataBind()
    
            'Pre-select amount.
            If InStr(pd.giftopt, "VA") Then
                amtmethod = "1"
                varamount.Text = pd.showNumC(0)
            ElseIf InStr(pd.giftopt, "FI") Then
                amtmethod = "2"
            End If
    
            If task = "edit" And IsNumeric(giftid) Then
                'Open Database, get values
                pd.OpenDataReader("SELECT * FROM giftcert WHERE id=" & giftid & " AND code='" & pd.FormatSqlText(cartid) & "'")
                If pd.ReadDataItem.Read Then
    
                    sentto.Text = pd.ReadData("sentto")
                    sentfrom.Text = pd.ReadData("sentfrom")
                    message.Text = pd.ReadData("message")
                    name.Text = pd.ReadData("recipname")
                    street1.Text = pd.ReadData("recipstreet1")
                    street2.Text = pd.ReadData("recipstreet2")
                    city.Text = pd.ReadData("recipcity")
                    zip.Text = pd.ReadData("recipzip")
                    recipemail.Text = pd.ReadData("recipemail")
                    method = pd.ReadData("method")
    
                    If InStr(pd.giftopt, "FI") Then
                        fixamount.SelectedIndex = fixamount.Items.IndexOf(fixamount.Items.FindByValue(pd.ReadDataC("amount")))
                        amtmethod = "2"
                    End If
    
                    If InStr(pd.giftopt, "VA") Then
                        varamount.Text = pd.ReadDataC("amount")
                        amtmethod = "1"
                    End If
    
                    'Get & Select States & Countries
                    tempstate = pd.ReadData("recipstate")
                    tempcountry = pd.ReadData("recipcountry")
    
                Else
                    'If no record found (possible security breach).
                    pd.removeCookie("cartid")
                    pd.signUserOut()
                    pd.pdRedirect("showcart.aspx")
    
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
    
            'Prepare Database - Argument (database tablename)
            If task = "add" Then
                'If Adding New Gift Cert.
                pd.OpenDataWriter("giftcert")
                pd.AddData("code", cartid, "T") 'Use cartid for tracking until order is finalized
                pd.AddData("status", 0, "N")
                pd.AddData("orderid", 0, "N")
                pd.AddData("buydate", DateTime.Now.ToShortDateString, "T")
            Else
                If IsNumeric(giftid) Then
                    pd.OpenDataWriter("giftcert WHERE id=" & giftid & " AND code='" & cartid & "'")
                Else
                    'If no record found (possible security breach).
                    pd.removeCookie("cartid")
                    pd.signUserOut()
                    pd.pdRedirect("showcart.aspx")
                End If
            End If
    
            'Function Arguments (column name, form id.text, Name of Field, Field Type, Min Characters, Max Characters)
            pd.AddFormData("sentto", sentto.Text, pd.getsystext("sys68"), "T", 3, 50)
            pd.AddFormData("sentfrom", sentfrom.Text, pd.getsystext("sys69"), "T", 5, 50)
    
            'Determine the Amount
            If amtmethod = "1" Then
                pd.AddFormData("amount", varamount.Text, pd.getsystext("sys70"), "C", 0, 0)
            Else
                pd.AddFormData("amount", fixamount.SelectedItem.Value, pd.getsystext("sys70"), "C", 0, 0)
            End If
            pd.AddFormData("message", message.Text, pd.getsystext("sys71"), "T", 3, 255)
            
    
            If method = "1" Or pd.gifteonly = 1 Then
                pd.AddData("method", "1", "T")
                pd.AddFormData("recipemail", recipemail.Text, pd.getsystext("sys73"), "T", 5, 50)
                pd.AddFormData("recipname", name.Text, pd.getsystext("sys26"), "T", 0, 50)
                pd.AddFormData("recipstreet1", street1.Text, pd.getsystext("sys28"), "T", 0, 50)
                pd.AddFormData("recipstreet2", street2.Text, pd.getsystext("sys28"), "T", 0, 50)
                pd.AddFormData("recipstate", state.SelectedItem.Value, pd.getsystext("sys30"), "T", 0, 50)
                pd.AddFormData("recipcity", city.Text, pd.getsystext("sys29"), "T", 0, 50)
                pd.AddFormData("recipcountry", country.SelectedItem.Text, pd.getsystext("sys32"), "T", 0, 50)
                pd.AddFormData("recipzip", zip.Text, pd.getsystext("sys31"), "T", 0, 50)
                If country.SelectedItem.Text = "United States" Or country.SelectedItem.Text = "Canada" Then
                    pd.checkForm(zip.Text, pd.getsystext("sys31"), "T", 0, 50)
                End If
                pd.formerror = pd.formerror & pd.checkchr(recipemail.Text, pd.getsystext("sys73"))
    
            Else
                pd.AddData("method", "2", "T")
                pd.AddFormData("recipemail", recipemail.Text, pd.getsystext("sys73"), "T", 0, 50)
                pd.AddFormData("recipname", name.Text, pd.getsystext("sys26"), "T", 5, 50)
                pd.AddFormData("recipstreet1", street1.Text, pd.getsystext("sys28"), "T", 3, 50)
                pd.AddFormData("recipstreet2", street2.Text, pd.getsystext("sys28"), "T", 0, 50)
                pd.AddFormData("recipstate", state.SelectedItem.Value, pd.getsystext("sys30"), "T", 0, 50)
                pd.AddFormData("recipcity", city.Text, pd.getsystext("sys29"), "T", 2, 50)
                pd.AddFormData("recipcountry", country.SelectedItem.Text, pd.getsystext("sys32"), "T", 0, 50)
                pd.AddFormData("recipzip", zip.Text, pd.getsystext("sys31"), "T", 0, 50)
                If country.SelectedItem.Text = "United States" Or country.SelectedItem.Text = "Canada" Then
                    pd.checkForm(zip.Text, pd.getsystext("sys31"), "T", 5, 50)
                End If
                pd.formerror = pd.formerror & pd.checkchr(recipemail.Text, pd.getsystext("sys73"))
            End If
    
    
            'If no errors, Add record to database
            If pd.formerror = "" Then
                recid = pd.SaveData()
                'Update/Add to shopping cart after updating/adding the Gift Cert. Record.
                If task = "add" Then
                    pd.OpenDataWriter("orderdetail")
                    pd.AddData("cartid", cartid, "T")
                    pd.AddData("itemno", 0, "N")
                    If amtmethod = "1" Then
                        pd.AddData("price", varamount.Text, "C")
                    Else
                        pd.AddData("price", fixamount.SelectedItem.Value, "C")
                    End If
                    pd.AddData("qty", 1, "N")
                    pd.AddData("weight", 0, "N")
                    pd.AddData("subof", 0, "N")
                    pd.AddData("digital", "GC", "T")
                    pd.AddData("taxable", "No", "T")
                    pd.AddData("giftid", recid, "N")
                Else
                    pd.OpenDataWriter("orderdetail WHERE giftid=" & giftid & " AND cartid='" & cartid & "'")
                    If amtmethod = "1" Then
                        pd.AddData("price", varamount.Text, "C")
                    Else
                        pd.AddData("price", fixamount.SelectedItem.Value, "C")
                    End If
                End If
                'Save/Update Shopping Cart
                pd.SaveData()
    
                pd.pdRedirect("showcart.aspx")
    
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
<%=pd.getTopHtml(pd.pg10)%>
<%= pd.startSection("heads14")%>
<div>
    <form method="POST" action="giftcert.aspx" id="pageform" name="pageform" runat="server">
    <input type="hidden" name="task" value="<%=nexttask%>" />
    <input type="hidden" name="giftid" value="<%=giftid%>" />
    <div class="messages">
        <%=pd.getFormError()%></div>

    <div class="formheadings">
        <%=pd.getsystext("sys69")%></div>
    <div>
        <asp:textbox class="formfield" id="sentfrom" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys68")%></div>
    <div>
        <asp:textbox class="formfield" id="sentto" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys73")%></div>
    <div>
        <asp:textbox class="formfield" id="recipemail" runat="server" />
    </div>

    <div class="formheadings">
        <%=pd.getsystext("sys70")%></div>
    <% If InStr(pd.giftopt, "VA") Then%>
    <div class="radiobuttons_container">
        <%If pd.giftopt = "VA" Then%><input type="hidden" name="amtmethod" value="1" /><%Else%><input
            class="radiobuttons" type="radio" name="amtmethod" value="1" <%if amtmethod="1" then response.write(" checked")%> />
        <%End If%>
        <asp:textbox class="formfield3" id="varamount" runat="server" />
    </div>
    <% End If%>
    <% If InStr(pd.giftopt, "FI") Then%>
    <div class="radiobuttons_container">
        <%If pd.giftopt = "FI" Then%><input type="hidden" name="amtmethod" value="2" /><%Else%><input
            class="radiobuttons" type="radio" name="amtmethod" value="2" <%if amtmethod="2" then response.write(" checked")%> />
        <%End If%>
        <asp:dropdownlist id="fixamount" runat="server" datavaluefield="value" datatextfield="name" />
    </div>
    <%End If%>
    <div class="formheadings">
        <%=pd.getsystext("sys71")%></div>
    <div>
        <asp:textbox class="formtextarea1" id="message" wrap="true" textmode="MultiLine"
            runat="server" />
    </div>
    <% If pd.gifteonly = 0 Then%>
    <div class="radiobuttons_container">
        <input class="radiobuttons" type="radio" name="method" value="1" <%if method="1" or method="" then response.write(" checked")%> />
        <%=pd.getsystext("sys72")%>
    </div>
    <% End If%>

    <% If pd.gifteonly = 0 Then%>
    <div class="radiobuttons_container">
        <input class="radiobuttons" type="radio" name="method" value="2" <%if method="2" then response.write(" checked")%> />
        <%=pd.getsystext("sys74")%>
    </div>
    <div class="formheadings2">
        <%=pd.getsystext("sys75")%></div>
    <div class="formheadings">
        <%=pd.getsystext("sys26")%></div>
    <div>
        <asp:textbox class="formfield" id="name" runat="server" />
    </div>
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
    <% End If%>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14","","","pageform")%></div>
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg10)%>