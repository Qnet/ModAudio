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
    Public cartid, oktocheckout As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()
         
        'Checks your Shop Access/Checkout settings.
        pd.VerifyShopAccess()

        If Not (Page.IsPostBack) Then
        End If

        'Get Task
        task = pd.getrequest("task")
        updatedisc = pd.getrequest("updatedisc")
        updategift = pd.getrequest("updategift")

        'Check for cart session id, if none then create one.
        cartid = pd.getcookie("cartid")
        orderid = pd.getcookie("orderid")
        If cartid = "" Then
            cartid = pd.getrandseq()
            pd.saveCookie("cartid", cartid, 0)
        End If

        'Determine what form elements to display (Payment Gateway related)
        pd.getgatewayoptions()

        'Check if shopping cart is valid (if checked out already, reset)
        If pd.hasCheckedOut(cartid) = "Yes" Then
            pd.removeCookie("orderid")
            pd.removeCookie("cartid")
            pd.pdRedirect("showcart.aspx?task=view")
        End If

        'Transfer Affiliate cookie.
        affillink = pd.getrequest("affillink")
        If affillink <> "" Then
            pd.saveCookie("affillink", affillink, 365)
        End If

        'Add to Cart
        If task = "addnew" Then
            'Delete Record first if changed.
            If pd.checkInt(pd.getrequest("edititemid")) = True Then
                pd.deletecartitem(pd.getrequest("edititemid"))
            End If
            pd.additemtocart(cartid)
        End If

        'Update Cart Items (qty)
        If task = "update" Then
            pd.updatecartitems(cartid)
        End If

        'Delete Cart Item
        If task = "delete" Then
            pd.deletecartitem(pd.getrequest("recid"))
        End If

        'Apply Gift Certificate
        If updategift = "Y" Then
            pd.applygiftcode(cartid, pd.getrequest("giftcode"))
        End If

        'Discounts.
        If updatedisc = "Y" Then
            pd.applydiscounts(cartid, pd.getrequest("disccode"))
        End If

        'Update Mini Cart (must appear before getOrderVariables)
        pd.updateminicart = "Yes"
        
        'Get Cart Contents
        pd.getOrderVariables("", orderid, cartid)

        'Bind Order Details to this page
        orderdetail.DataSource = pd.bindorderdetail(cartid, "")
        orderdetail.DataBind()
        
        'Reload page (Refresh minicart, etc.)
        If (task = "update" Or task = "delete" Or task = "addnew") And pd.formerror = "" Then
            pd.pdRedirect("showcart.aspx?task=view") '&randsq=" & pd.getrandseq())
        End If

        'Check that order minimum is met.
        If pd.dOrdersub < pd.orderminimum Then
            pd.formerror = pd.geterrtext("err64") & " [" & pd.showcurr(pd.orderminimum) & "]"
            oktocheckout = "N"
        Else
            oktocheckout = "Y"
        End If

        'Check for Inventory Error (read public variable)
        If pd.inventoryerror = "Yes" Then
            pd.formerror = pd.geterrtext("err3")
            oktocheckout = "N"
        End If

        

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg9)%>
<%= pd.startSection("heads3")%>
<div>
    <div class="messages">
        <%=pd.getFormError()%></div>
    <form method="POST" action="showcart.aspx" id="updateitems" name="updateitems">
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
                <div class="cartcolumn_2"><%# Container.DataItem("inverror") %><input class="formfield5" name="qty<%# Container.DataItem("count") %>" type="text" value="<%# Container.DataItem("buyqty") %>" size="5"></div>
                <div class="cartcolumn_3"><%# Container.DataItem("priceeach") %></div>
                <div class="cartcolumn_4"><%# Container.DataItem("pricetotal") %></div>
                <div style="clear: both;"></div>
            </div>

            <div style="width: 100%;">
                <div class="cartcolumn_1"><%# Container.DataItem("itemimage") %></div>
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

            <div class="cartbuttons_container">
                <%# Container.DataItem("editbutton") %>
                <%# Container.DataItem("updatebutton") %>
                <%# Container.DataItem("removebutton") %>
                <div style="clear: both;"></div>
            </div>

         <hr class="rowline2" /> 
         
          <!-- END OF ITEM REPEATER -->
          </itemtemplate>
          </asp:repeater>
    <input type="hidden" name="itemcount" value="<%=pd.iItemcount%>" />
    <input type="hidden" name="task" value="update" />
    </form>
    <% If pd.iItemcount = 0 Then%>
    <div class="cartdata">
        <%=pd.geterrtext("err52")%></div>
    <%End If%>
    <% If pd.discen = "1" And pd.iItemcount > 0 Then%>
    <div style="height: 25px;">
    </div>
    <form method="POST" action="showcart.aspx" id="discform" name="discform">
    <input type="hidden" name="updatedisc" value="Y" />
    <input type="hidden" name="tempsubtotal" value="<%=subtotala%>" />
    <div class="formheadings2">
        <%=pd.getsystext("sys7")%></div>
    <div style="width: 100%; display: inline;">
        <span class="formheadings">
            <%=pd.getsystext("sys8")%></span> <span>
                <input class="formfield3" type="text" id="disccode" name="disccode" value="<%=pd.sDisccode%>" /></span>
        <span>
            <%=pd.getButton("butts11", "", "","discform") %></span>
    </div>
    <div>
        <%=pd.fixERR(pd.discountmessage)%></div>
    </form>
    <div style="height: 25px;">
    </div>
    <hr class="rowline" />
    <% End If%>
    <% If pd.giften = "1" And pd.iItemcount > 0 Then%>
    <div style="height: 25px;">
    </div>
    <form method="POST" action="showcart.aspx" id="giftform" name="giftform">
    <input type="hidden" name="updategift" value="Y" />
    <input type="hidden" name="tempsubtotal" value="<%=subtotala%>" />
    <div class="formheadings2">
        <%=pd.getsystext("sys9")%></div>
    <div style="width: 100%; display: inline;">
        <span class="formheadings">
            <%=pd.getsystext("sys10")%></span> <span>
                <input class="formfield3" type="text" id="giftcode" name="giftcode" value="<%=pd.sGiftcode%>"></span>
        <span>
            <%=pd.getButton("butts22", "", "","giftform") %></span>
    </div>
    <div>
        <%=pd.fixERR(pd.giftmessage)%></div>
    </form>
    <div style="height: 25px;">
    </div>
    <hr class="rowline" />
    <% End If%>
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
    <% If pd.iItemcount > 0 And oktocheckout = "Y" Then%>
    <div class="formbuttons_container">
        <%=pd.getButton("butts10","", pd.shopurl & "continue.aspx","") %>
        <%=pd.getButton("butts13", "", "checkout.aspx","")%>
    </div>
    <!-- PayPal Express Checkout Option -->
    <% If pd.showppexpress = "Yes" And oktocheckout = "Y" Then%>
    <div class="formbuttons_container">
        <a href="paypal_express1.aspx">
            <img border="0" src="img/ppexpresslogo.gif" /></a>
    </div>
    <%End If%>
    <% If pd.showgcoption = "Yes" And oktocheckout = "Y" Then%>
    <!-- Google Checkout Option -->
    <div class="formbuttons_container">
        <%=pd.getgooglecheckoutbutton(cartid)%>
    </div>
    <%End If%>
    <%Else%>
    <div class="formbuttons_container">
        <%=pd.getButton("butts10","", pd.shopurl & "continue.aspx","") %>
    </div>
    <%End If%>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>
