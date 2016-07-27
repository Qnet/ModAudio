<%@ Page Language="VB" Explicit="False" %>

<%@ Import Namespace="PDshop9" %>
<script runat="server">

    Public pd As PDshopFunctions
    Public orderid, cartid, checkoutsuccess, shippingrequired As String
    Public shippingservicescount As Integer

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        'Initialize PayPal
        pd.getgatewayoptions()
        pd.pptoken = pd.getcookie("pptoken")
        pd.getPayPalExpressURL()

        orderid = pd.getcookie("orderid")
        cartid = pd.getcookie("cartid")
         
        'Handle PayPal Cancel
        task = pd.getrequest("task")
        If task = "cancel" Then
            pd.removeCookie("tkid")
            pd.removeCookie("customerid")
            pd.removeCookie("orderid")
            pd.removeCookie("pptoken")
            pd.pdRedirect("showcart.aspx")
        End If

        'Handle PayPal return
        newtoken = pd.getrequest("token")

        If Not (Page.IsPostBack) Then

            If newtoken <> "" Then

                pd.pptoken = newtoken

                If pd.getPayPalExpressCheckoutDetails() = "Success" Then

                    'Open Database, get cartid and save.
                    pd.OpenDataReader("SELECT cartid, id FROM orders WHERE cctrxid='" & pd.FormatSqlText(pd.pptoken) & "'")
                    If pd.ReadDataItem.Read Then
                        orderid = pd.ReadDataN("id")
                        cartid = pd.ReadData("cartid")
                        pd.saveCookie("cartid", cartid, 0)
                        pd.saveCookie("orderid", orderid, 0)
                        pd.saveCookie("pptoken", pd.pptoken, 0)
                    End If
                    pd.CloseData()

                    'Save Details from PayPal in PDshop
                    pd.OpenDataWriter("orders WHERE cctrxid='" & pd.FormatSqlText(pd.pptoken) & "'")
                     
                    pd.AddData("billname", pd.sName, "T")
                    pd.AddData("billstreet1", pd.sStreet1, "T")
                    pd.AddData("billstreet2", pd.sStreet2, "T")
                    pd.AddData("billstate", pd.sState, "T")
                    pd.AddData("billcity", pd.sCity, "T")
                    pd.AddData("billcountry", pd.sCountry, "T")
                    pd.AddData("billzip", pd.sZip, "T")
                    pd.AddData("billemail", pd.sEmail, "T")
                    pd.AddData("billphone", pd.sPhone, "T")
                     
                    pd.AddData("shipname", pd.sName, "T")
                    pd.AddData("shipstreet1", pd.sStreet1, "T")
                    pd.AddData("shipstreet2", pd.sStreet2, "T")
                    pd.AddData("shipstate", pd.sState, "T")
                    pd.AddData("shipcity", pd.sCity, "T")
                    pd.AddData("shipcountry", pd.sCountry, "T")
                    pd.AddData("shipzip", pd.sZip, "T")
                     
                    pd.AddData("ccnoc", pd.sEmail, "T")
                    pd.AddData("cctype", pd.sTempkey, "T")
                    pd.AddData("salestax", pd.gettaxrate(pd.sState, pd.sCountry), "N")
                    pd.AddData("taxship", pd.sTaxship, "T") 'must proceed gettaxrate.
                    pd.SaveData()

                    'Refresh Page (must be done so that order can be properly displayed)_
                    pd.pdRedirect("paypal_express2.aspx")

                End If

            End If
 
        End If

        If Page.IsPostBack Then

            shipid = pd.getrequest("shipid")

            If IsNumeric(shipid) Then
                pd.OpenDataWriter("orders WHERE id=" & pd.FormatSqlText(orderid) & " AND cctrxid='" & pd.FormatSqlText(pd.pptoken) & "'")
                pd.AddData("carriername", pd.getrequest("carriername" & shipid), "T")
                pd.AddFormData("carrierrate", pd.getrequest("carrierrate" & shipid), pd.getsystext("sys40"), "N2", 1, 50)
                pd.AddData("ratemethod", pd.getrequest("ratemethod" & shipid), "N")
                pd.SaveData()
            Else
                pd.OpenDataWriter("orders WHERE id=" & pd.FormatSqlText(orderid) & " AND cctrxid='" & pd.FormatSqlText(pd.pptoken) & "'")
                pd.AddData("carriername", "", "T")
                pd.AddData("carrierrate", 0, "N")
                pd.AddData("ratemethod", 3, "N")
                pd.SaveData()
            End If

            If pd.getrequest("task") = "checkout" Then

                pd.getOrderVariables("", orderid, cartid)

                'Finalize Order
                ppresponse = pd.doPayPalExpressCheckoutPayment()
                 
                If ppresponse = "Success" Or ppresponse = "SuccessWithWarning" Then
                 
                    pd.OpenDataWriter("orders WHERE cctrxid='" & pd.FormatSqlText(pd.pptoken) & "'")
                    pd.AddData("ccapproval", "Express", "T")
                    pd.AddData("cctrxid", pd.sCctrxid, "T")
                    pd.AddData("tracking", "", "T")
                    pd.AddData("downen", pd.downen, "N")
                    pd.AddData("cctype", "PayPal", "T")
                    pd.AddData("status", "New", "T")
                    pd.SaveData()

                    pd.linkorderdetail(cartid, "", orderid)
                    pd.updateinventory(orderid)
                    pd.finalizegc(orderid)
                    pd.updategcstatus(orderid)
                    
                    'Auth/Capture Tax Cloud
                    pd.dotaxcloudauth(orderid)

                    'Save PayPal Transaction ID (to display on next page)
                    pd.saveCookie("pptrx", pd.sCctrxid, 0)

                    pd.pdRedirect("checkout5.aspx")
                Else

                    'pd.formerror = pd.formerror & errormessage

                End If

            End If

        End If

                     
        If IsNumeric(cartid) = False Or IsNumeric(orderid) = False Then
            pd.pdRedirect("showcart.aspx")
        End If
         
        'Update Taxes, TaxCloud        
        pd.dotaxcloudlookup(orderid)
        
        'Determine if Shipping is required (returns Yes or No)
        shippingrequired = pd.checkifshipping()

        If shippingrequired = "Yes" Then
            shippingservices.DataSource = pd.getshippingservices("Checkout")
            shippingservicescount = shippingservices.DataSource.Count
            shippingservices.DataBind()
        End If

        
        'Update Mini Cart (must appear before getOrderVariables)
        pd.updateminicart = "Yes"
        
        'Get Order Total, determine if payment is due.
        'After calling the functions below, some Public Variables will then be available...
        pd.getOrderVariables("", orderid, cartid)

        'Get Cart Contents
        orderdetail.DataSource = pd.bindorderdetail(cartid, "")
        orderdetail.DataBind()
        
    End Sub


    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg9)%>
<script language="JavaScript">
  <!--
    function docheckout() {
        document.getElementById('task').value = 'checkout';
        document.getElementById('pageform').submit();
    }
  // -->
</script>
<%= pd.startSection("heads16")%>
<div class="form_container">
    <form method="POST" id="pageform" name="pageform" runat="server">
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div style="width: 100%;">
        <div class="formheadings2" style="float: left;">
            <%=pd.getsystext("sys33")%></div>
        <div style="float: right;">
            <% If orderid <> "" And pd.sCcapproval <> "Mark" Then%><%=pd.getButton("butts15","",pd.ppexpressurl,"") %><% End If%></div>
        <div style="clear: both;">
            <!-- -->
        </div>
    </div>
    <div class="cartdata">
        <%=pd.sBillEmail%><br />
        <%=pd.sBillName%><br />
        <%=pd.sBillStreet1%><br />
        <%=pd.sBillStreet2%><br />
        <%=pd.sBillCity%><br />
        <%=pd.sBillState%><br />
        <%=pd.sBillZip%><br />
        <%=pd.sBillCountry%></div>
    <% If shippingrequired = "Yes" Then%>
    <div>
        <hr class="rowline">
    </div>
    <div style="width: 100%;">
        <div class="formheadings2" style="float: left;">
            <%=pd.getsystext("sys34")%></div>
        <div style="float: right;">
            <% If orderid <> "" And pd.sCcapproval <> "Mark" Then%><%=pd.getButton("butts15","",pd.ppexpressurl,"") %><% End If%></div>
        <div style="clear: both;">
            <!-- -->
        </div>
    </div>
    <div class="cartdata">
        <%=pd.sShipname%><br />
        <%=pd.sShipstreet1%><br />
        <%=pd.sShipstreet2%><br />
        <%=pd.sShipcity%><br />
        <%=pd.sShipstate%><br />
        <%=pd.sShipzip%><br />
        <%=pd.sShipcountry%></div>
    <div>
        <hr class="rowline">
    </div>
    <div style="width: 100%;">
        <div class="formheadings2" style="float: left;">
            <%=pd.getsystext("sys39")%></div>
        <div style="float: right;">
            <%=pd.getButton("butts9","","","pageform")%></div>
        <div style="clear: both;">
            <!-- -->
        </div>
    </div>

    <% End If%>
    <% If shippingservicescount > 0 Then%>

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
    <% End If%>


    <div>
        <hr class="rowline">
    </div>
    <div style="width: 100%;">
        <div class="formheadings2" style="float: left;">
            <%= pd.getsystext("sys59")%></div>
        <div style="float: right;">
            <%'= pd.getButton("butts15", "", "showcart.aspx", "")%></div>
        <div style="clear: both;">
            <!-- -->
        </div>
    </div>


    <div class="cartdata" style="width: 100%;">
        &nbsp;</div>
    <div class="formheadings" style="width: 100%;">
        <div class="cartcolumn_1">
            <%=pd.getsystext("sys1")%>/<%=pd.getsystext("sys2")%></div>
        <div class="cartcolumn_2">
            <%=pd.getsystext("sys3")%></div>
        <div class="cartcolumn_3">
            <%=pd.getsystext("sys4")%></div>
        <div class="cartcolumn_4">
            <%=pd.getsystext("sys5")%></div>
        <div style="clear: both;">
        </div>
    </div>
    <hr class="rowline" />
    <!-- START OF ITEM REPEATER -->
    <asp:repeater id="orderdetail" runat="server">
          <itemtemplate>
          <%# Container.DataItem("hiddenitemid") %>
          <%# Container.DataItem("hiddenrecid") %>

            <div class="cartdata" style="width: 100%;">
                <div class="cartcolumn_1"><%# Container.DataItem("itemname") %><br /><%# Container.DataItem("itemno") %></div>
                <div class="cartcolumn_2"><%# Container.DataItem("buyqty") %></div>
                <div class="cartcolumn_3"><%# Container.DataItem("priceeach") %></div>
                <div class="cartcolumn_4"><%# Container.DataItem("pricetotal") %></div>
                <div style="clear: both;"></div>
            </div>

            
            <div class="formheadings" style="width: 100%;">
                <div class="cartcolumn_1"><%# Container.DataItem("optionheader") %></div>
                <div style="clear: both;"></div>
            </div>

             <!-- OPTIONS REPEATER -->
            <asp:repeater id="childRepeater" runat="server" datasource='<%# Container.DataItem.Row.GetChildRows("itemoptions") %>'>
            <itemtemplate>

            <div class="cartdata2" style="width: 100%;">
                <div class="cartcolumn_1"><%# Container.DataItem("inverror") %><%# Container.DataItem("optionname") %></div>
                <div style="clear: both;"></div>
            </div>
            <div class="cartdata2" style="width: 100%;">
                <div class="cartcolumn_1"><%# Container.DataItem("optiontext") %> <!-- --></div>
                <div style="clear: both;"></div>
            </div>

            </itemtemplate>
            </asp:Repeater>
            <!-- END OPTIONS REPEATER -->


         <hr class="rowline2" /> 
         
          <!-- END OF ITEM REPEATER -->
          </itemtemplate>
          </asp:repeater>
    <div class="cartdata" style="width: 100%;">
        <div class="carttotalcolumn_1">
            <%=pd.getsystext("sys11")%></div>
        <div class="carttotalcolumn_2">
            <%=pd.showCurr(pd.dordersub)%></div>
        <div style="clear: both;">
        </div>
    </div>
    <% If pd.dDiscounts > 0 Then%>
    <div class="cartdata" style="width: 100%;">
        <div class="carttotalcolumn_1">
            <%=pd.getsystext("sys7")%></div>
        <div class="carttotalcolumn_2">
            -<%=pd.showCurr(pd.dDiscounts)%></div>
        <div style="clear: both;">
        </div>
    </div>
    <% End If%>
    <% If pd.dCarrierrate > 0 Then%>
    <div class="cartdata" style="width: 100%;">
        <div class="carttotalcolumn_1">
            <%If pd.sRatemethod = "2" Then Response.Write("*")%><%=pd.getsystext("sys39")%></div>
        <div class="carttotalcolumn_2">
            <%
                If pd.sRatemethod = "3" Then
                    Response.Write(pd.getsystext("sys109"))
                Else
                    Response.Write(pd.showcurr(pd.dCarrierrate))
                End If
            %></div>
        <div style="clear: both;">
        </div>
    </div>
    <% End If%>
    <% If pd.dOrdertaxtotal > 0 Then%>
    <div class="cartdata" style="width: 100%;">
        <div class="carttotalcolumn_1">
            <%=pd.getsystext("sys60")%></div>
        <div class="carttotalcolumn_2">
            <%=pd.showCurr(pd.dOrdertaxtotal)%></div>
        <div style="clear: both;">
        </div>
    </div>
    <% End If%>
    <% If pd.dGiftamt > 0 Then%>
    <div class="cartdata" style="width: 100%;">
        <div class="carttotalcolumn_1">
            <%=pd.getsystext("sys9")%></div>
        <div class="carttotalcolumn_2">
            -<%=pd.showCurr(pd.dGiftamt)%></div>
        <div style="clear: both;">
        </div>
    </div>
    <% End If%>
    <% If pd.dDiscounts > 0 Or pd.dCarrierrate > 0 Or pd.dOrdertaxtotal > 0 Or pd.dGiftamt > 0 Then%>
    <div class="cartdata" style="width: 100%;">
        <div class="carttotalcolumn_1">
            <%=pd.getsystext("sys61")%></div>
        <div class="carttotalcolumn_2">
            <%=pd.showCurr(pd.dOrdergrandtotal)%></div>
        <div style="clear: both;">
        </div>
    </div>
    <% End If%>

    <% If pd.currrate <> 1 And (pd.dDiscounts > 0 Or pd.dCarrierrate > 0 Or pd.dOrdertaxtotal > 0 Or pd.dGiftamt > 0) Then%>
    <div class="cartdata" style="width: 100%;">
        &nbsp;</div>
    <div class="cartdata" style="width: 100%;">
        <div class="carttotalcolumn_1">
            <%=pd.getsystext("sys61")%></div>
        <div class="carttotalcolumn_2">
            <%= pd.showPrimarycurr(pd.dOrdergrandtotal)%> </div>
        <div class="tr">
        </div>
    </div>
    <% End If%>

    <div class="cartdata" style="width: 100%;">
        <div class="carttotalcolumn_1">
            <%=pd.getsystext("sys12")%></div>
        <div class="carttotalcolumn_2">
            <%=pd.iItemcount%></div>
        <div style="clear: both;">
        </div>
    </div>
    <div class="cartdata" style="width: 100%;">
        &nbsp;</div>
    <div class="formbuttons_container">
        <%=pd.getButton("butts34", "", "javascript: docheckout();","")%>
        <%=pd.getButton("butts35", "", "paypal_express2.aspx?task=cancel","")%>
    </div>
    <input type="hidden" name="task" id="task" value="" />
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>
