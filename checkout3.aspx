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
    Public task As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        'Verify if can Checkout.
        If pd.hasCartItems() = "No" Then pd.pdRedirect("showcart.aspx")
        If pd.hasShippingAddress() = "No" Then pd.pdRedirect("checkout2.aspx")

        cartid = pd.getcookie("cartid")
        orderid = pd.getcookie("orderid")

        'Determine if Shipping selection can be skipped (already selected)
        If pd.hasShipping() = "Yes" And Not (Page.IsPostBack) Then
            If pd.getrequest("task") = "edit" Then
                task = "edit"
            Else
                pd.pdRedirect("checkout4.aspx")
            End If
        End If

        'If Shipping Not Required for this order...
        If pd.checkifshipping() = "No" Then
            skipshipping = "Yes"
        Else
            skipshipping = "No"
        End If

        'Get Shipping Services
        If skipshipping = "No" And Not (Page.IsPostBack) Then

            shippingservices.DataSource = pd.getshippingservices("Checkout")
            shippingservicescount = shippingservices.DataSource.Count
            shippingservices.DataBind()

            'If no Shipping Services were availalbe or setup
            If shippingservicescount = 0 Then
                skipshipping = "Yes"
            End If

        End If

        'If shipping is being skipped
        If skipshipping = "Yes" Then

            'Prepare Database - Argument (database tablename & a Where clause)
            pd.OpenDataWriter("orders WHERE id=" & orderid & " AND cartid='" & cartid & "'")
            'Prepare to Save
            pd.AddData("carriername", "", "T")
            pd.AddData("carrierrate", 0, "N")
            pd.AddData("ratemethod", 3, "N")
            recid = pd.SaveData()

            'Update Taxes, TaxCloud        
            pd.dotaxcloudlookup(orderid)
            
            'Goto Next Page
            pd.pdRedirect("checkout4.aspx")

        End If


        If Page.IsPostBack Then

            shipid = pd.getrequest("shipid")

            'Prepare Database - Argument (database tablename & a Where clause)
            pd.OpenDataWriter("orders WHERE id=" & orderid & " AND cartid='" & cartid & "'")

            'Prepare to Save
            pd.AddData("carriername", pd.getrequest("carriername" & shipid), "T")
            pd.AddFormData("carrierrate", pd.getrequest("carrierrate" & shipid), pd.getsystext("sys40"), "N2", 1, 50)
            pd.AddData("ratemethod", pd.getrequest("ratemethod" & shipid), "N")

            'If no errors, Update order in database
            If pd.formerror = "" Then
                recid = pd.SaveData()
                
                'Update Mini Cart (must appear before getOrderVariables)
                pd.updateminicart = "Yes"
                
                'Update Taxes, TaxCloud        
                pd.dotaxcloudlookup(orderid)
                
                'Get Cart Contents (required to update mini-cart totals)
                pd.getOrderVariables("", orderid, cartid)

                'If user is making a change to the carrier, take them to the referring page.
                If pd.getrequest("task") = "edit" Then
                    pd.pdRedirect("orderreview.aspx")
                Else
                    pd.pdRedirect("checkout4.aspx")
                End If
                 
            End If

        End If


    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg9)%>
<%= pd.startSection("heads22")%>
<div class="form_container">
    <form method="POST" action="checkout3.aspx" id="pageform" name="pageform" runat="server">
    <input type="hidden" name="task" value="<%=task%>" />
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div>
        <div class="formheadings" style="float: left;">
            <%=pd.getsystext("sys40")%></div>
        <div class="formheadings" style="float: right;">
            <%=pd.getsystext("sys41")%></div>
        <div style="clear: both;">
            <!-- -->
        </div>
    </div>
    <hr class="rowline" />
    <asp:repeater id="shippingservices" runat="server">
        <itemtemplate>
             
            <div style="width: 100%;">
            <div class="radiobuttons_container" style="float: left;">
            <span class="radiobuttons"><input type="radio" value="<%# Container.DataItem("id") %>" <%# Container.DataItem("checked") %> name="shipid" /></span><%# Container.DataItem("name") %></div>
              
            <div class="cartdata" style="float: right;"><%# Container.DataItem("showrate") %></div>
            <div style="clear: both;"><!-- --></div>

            </div>
            <input type="hidden" name="carriername<%# Container.DataItem("id") %>" value="<%# Container.DataItem("name") %>" />
            <input type="hidden" name="ratemethod<%# Container.DataItem("id") %>" value="<%# Container.DataItem("ratemethod") %>" />
            <input type="hidden" name="carrierrate<%# Container.DataItem("id") %>" value="<%# Container.DataItem("rate") %>" />
              
        </itemtemplate>
    </asp:repeater>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14","","","pageform")%></div>
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>
