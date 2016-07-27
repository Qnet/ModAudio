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
    Public orderid, shippingrequired As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        If Not (Page.IsPostBack) Then
        End If

        'Verify if can Checkout.
        'If pd.isSignedIn() = "No" Then pd.pdRedirect("checkout1.aspx")
        If pd.hasCartItems() = "No" Then pd.pdRedirect("showcart.aspx")
        If pd.hasOrder() = "No" Then pd.pdRedirect("checkout2.aspx")

        orderid = pd.getcookie("orderid")
        cartid = pd.getcookie("cartid")

        'Get Order Total, determine if payment is due.
        'After calling the functions below, some Public Variables will then be available...
        pd.getOrderVariables("", orderid, cartid)

        'Get Cart Contents
        orderdetail.DataSource = pd.bindorderdetail(cartid, "")
        orderdetail.DataBind()

        'Determine if Shipping is required (returns Yes or No)
        shippingrequired = pd.checkifshipping()

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%= pd.getTopHtml(pd.pg9)%>
<%= pd.startSection("heads16")%>
<div>
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div style="width: 100%;">
        <div class="formheadings2" style="float: left;">
            <%=pd.getsystext("sys33")%></div>
        <div style="float: right;">
            <% If orderid <> "" Then%><%=pd.getButton("butts15","","checkout1.aspx?task=edit","") %><% End If%></div>
        <div class="tr">
        </div>
    </div>
    <div class="cartdata">
        <%=pd.sBillEmail%><br />
        <%=pd.sBillName%><br />
        <% if pd.sBillCompany <>"" then %>
        <%= pd.sBillCompany%><br />
        <% end if %>
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
            <% If orderid <> "" Then%><%=pd.getButton("butts15","","checkout2.aspx?task=edit","")%><% End If%></div>
        <div class="tr">
        </div>
    </div>
    <div class="cartdata">
        <%=pd.sShipname%><br />
        <% If pd.sShipCompany <> "" Then%>
        <%= pd.sShipCompany%><br />
        <% end if %>
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
            <%=pd.getButton("butts15","","checkout3.aspx?task=edit","")%></div>
        <div class="tr">
        </div>
    </div>
    <div class="cartdata">
        <%=pd.sCarriername%></div>
    <% End If%>
    <div>
        <hr class="rowline" />
    </div>
    <div style="width: 100%;">
        <div class="formheadings2" style="float: left;">
            <%= pd.getsystext("sys59")%></div>
        <div style="float: right;">
            <%= pd.getButton("butts15", "", "showcart.aspx", "")%></div>
        <div class="tr">t
        </div>
    </div>
    <div class="cartdata" style="width: 100%;">
        &nbsp;</div>
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
    <input type="hidden" name="itemcount" value="<%=pd.iItemcount%>" />
    <input type="hidden" name="task" value="update" />
    </form>
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
        <div class="tr">
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
        <div class="tr">
        </div>
    </div>
    <% End If%>
    <% If pd.dOrdertaxtotal > 0 Then%>
    <div class="cartdata" style="width: 100%;">
        <div class="carttotalcolumn_1">
            <%=pd.getsystext("sys60")%></div>
        <div class="carttotalcolumn_2">
            <%=pd.showCurr(pd.dOrdertaxtotal)%></div>
        <div class="tr">
        </div>
    </div>
    <% End If%>
    <% If pd.dGiftamt > 0 Then%>
    <div class="cartdata" style="width: 100%;">
        <div class="carttotalcolumn_1">
            <%=pd.getsystext("sys9")%></div>
        <div class="carttotalcolumn_2">
            -<%=pd.showCurr(pd.dGiftamt)%></div>
        <div class="tr">
        </div>
    </div>
    <% End If%>
    <% If pd.dDiscounts > 0 Or pd.dCarrierrate > 0 Or pd.dOrdertaxtotal > 0 Or pd.dGiftamt > 0 Then%>
    <div class="cartdata" style="width: 100%;">
        <div class="carttotalcolumn_1">
            <%=pd.getsystext("sys61")%></div>
        <div class="carttotalcolumn_2">
            <%=pd.showCurr(pd.dOrdergrandtotal)%></div>
        <div class="tr">
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
        <div class="tr">
        </div>
    </div>
    <div class="cartdata" style="width: 100%;">
        &nbsp;</div>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14", "", "checkout4.aspx","")%>
    </div>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>