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
    Public orderid, orderheader, orderfooter As String
    Public listdownloadscount As Int32

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        If Not (Page.IsPostBack) Then
        End If

        orderid = pd.getrequest("orderid")
        cartid = pd.getrequest("cartid")
        orderkey = pd.getrequest("key")
         
        'Verify if orderkey is correct (security check)
        If pd.isOrderKeyValid(orderid, orderkey) = "No" Then pd.showError(0, "View Order", "Invalid URL", "", "")

        'Get additional page setup info.
        pd.OpenSetupDataReader("otherxml", "misc")

        orderheader = pd.ReadData("orderheader")
        orderfooter = pd.ReadData("orderfooter")

        pd.CloseData()

        'Get Order Total, determine if payment is due.
        'After calling the functions below, some Public Variables will then be available...
        pd.getOrderVariables("", orderid, "")

        orderdetail.DataSource = pd.bindorderdetail(cartid, orderid)
        orderdetail.DataBind()
        
        'Mask Expiration Date
        If pd.hidecc = 1 Then
            If pd.sExpmonth <> "" Then
                pd.sExpmonth = "**"
                pd.sExpyear = "**"
            End If
        End If

        'Get Downloads
        listdownloads.DataSource = pd.bindcustomerdownloads(0, orderid)
        listdownloadscount = listdownloads.DataSource.Count
        listdownloads.DataBind()
         
        'Log Event
        pd.LogShopEvent(208, orderid, "")

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
    <title>
        <%=pd.iOrderno%>
        /
        <%=pd.sName%></title>
    <link rel="stylesheet" type="text/css" href="shop-css.aspx" />
    <script type="text/javascript" src="shop-javascript.js"></script>
    <% If pd.popuptype = "I" Then%>
    <script type="text/javascript">
        parent.document.getElementById('popupControls').innerHTML = '<img width="19" height="19" src="<% =pd.pdimgurl %>close.gif" onclick="hidePopWin(false);" id="popCloseBox" />'
    </script>
    <% End If%>
</head>
<body class="popupbody">
    <div style="width: 98%;">
        <div>
            <%=orderheader%></div>
        <div style="width: 100%;">
            <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                    <td width="49%" valign="top">
                        <div style="width: 49%; float: left; overflow: hidden;">
                            <div class="orderheader">
                                <%=pd.getsystext("sys65")%></div>
                            <div class="ordertxt">
                                <%=pd.iOrderno%></div>
                        </div>
                        <div style="width: 49%; float: left; overflow: hidden;">
                            <div class="orderheader">
                                <%=pd.getsystext("sys66")%></div>
                            <div class="ordertxt">
                                <%=pd.showdate(pd.sOrderdate)%></div>
                        </div>
                        <div class="tr">
                        </div>
                        <div style="width: 98%;">
                            <div class="orderheader">
                                <%=pd.getsystext("sys67")%></div>
                            <div class="ordertxt">
                                <%= pd.dohtmlencode(pd.sStatus)%></div>
                            <div class="orderheader">
                                <%=pd.getsystext("sys23")%></div>
                            <div class="ordertxt">
                                <%= pd.dohtmlencode(pd.sBillEmail)%></div>
                            <div class="orderheader">
                                <%=pd.getsystext("sys27")%></div>
                            <div class="ordertxt">
                                <%= pd.dohtmlencode(pd.sBillPhone)%></div>
                            <div class="orderheader">
                                <%=pd.getsystext("sys40")%></div>
                            <div class="ordertxt">
                                <%=pd.doHtmlEncode(pd.sCarriername)%>
                                <br />
                                <%= pd.dohtmlencode(pd.sTracking)%></div>
                        </div>
                    </td>
                    <td width="2%">
                    </td>
                    <td width="49%" valign="top">
                        <div style="width: 49%; float: left; overflow: hidden;">
                            <div class="orderheader">
                                <%=pd.getsystext("sys33")%></div>
                            <div class="ordertxt">
                                <%= pd.dohtmlencode(pd.sBillName)%>
                                <br />
                                <% If pd.sBillCompany <> "" Then%>
                                <%= pd.dohtmlencode(pd.sBillCompany)%><br />
                                <% End If%>
                                <%= pd.dohtmlencode(pd.sBillstreet1)%>
                                <br />
                                <%= pd.dohtmlencode(pd.sBillstreet2)%>
                                <br />
                                <%= pd.dohtmlencode(pd.sBillcity)%>
                                <br />
                                <%= pd.dohtmlencode(pd.sBillstate)%>
                                <br />
                                <%= pd.dohtmlencode(pd.sBillZip)%>
                                <br />
                                <%= pd.dohtmlencode(pd.sBillcountry)%></div>
                        </div>
                        <div style="width: 49%; float: left; overflow: hidden;">
                            <div class="orderheader">
                                <%=pd.getsystext("sys34")%></div>
                            <div class="ordertxt">
                                <%= pd.dohtmlencode(pd.sShipName)%>
                                <br />
                                <% If pd.sShipCompany <> "" Then%>
                                <%= pd.dohtmlencode(pd.sShipCompany)%><br />
                                <% End If%>
                                <%= pd.dohtmlencode(pd.sShipstreet1)%>
                                <br />
                                <%= pd.dohtmlencode(pd.sShipstreet2)%>
                                <br />
                                <%= pd.dohtmlencode(pd.sShipcity)%>
                                <br />
                                <%= pd.dohtmlencode(pd.sShipstate)%>
                                <br />
                                <%= pd.dohtmlencode(pd.sShipzip)%>
                                <br />
                                <%= pd.dohtmlencode(pd.sShipcountry)%></div>
                        </div>
                        <div class="tr">
                        </div>
                    </td>
                </tr>
            </table>
        </div>
        <div class="orderheader" style="width: 100%;">
            <div style="width: 30%; float: left;">
                <%=pd.getsystext("sys47")%></div>
            <div style="width: 41%; float: left;">
                <%=pd.getsystext("sys48")%></div>
            <div style="width: 29%; float: left;">
                <%=pd.getsystext("sys50")%></div>
            <div style="clear: both;">
            </div>
        </div>
        <div class="ordertxt" style="width: 100%;">
            <div style="width: 30%; float: left;">
                <%= pd.dohtmlencode(pd.sCctype)%><%If pd.sCctype = "PayPal" Then%>
                (<%= pd.dohtmlencode(pd.sCctrxid)%>)<%End If%></div>
            <div style="width: 41%; float: left;">
                <%= pd.dohtmlencode(pd.sCcardnohide)%></div>
            <div style="width: 29%; float: left;">
                <%= pd.dohtmlencode(pd.sExpmonth)%>/
                <%= pd.dohtmlencode(pd.sExpyear)%></div>
            <div style="clear: both;">
            </div>
        </div>
        <div class="orderheader" style="width: 100%;">
            <div class="ordercolumn_1">
                <%=pd.getsystext("sys2")%></div>
            <div class="ordercolumn_2">
                <%=pd.getsystext("sys1")%></div>
            <div class="ordercolumn_3">
                <%=pd.getsystext("sys3")%></div>
            <div class="ordercolumn_4">
                <%= pd.getsystext("sys4")%></div>
            <div class="ordercolumn_5">
                <%= pd.getsystext("sys5")%></div>
            <div style="clear: both;">
            </div>
        </div>
        <asp:Repeater ID="orderdetail" runat="server">
            <ItemTemplate>
                <div class="ordertxt" style="width: 100%;">
                    <div class="ordercolumn_1">
                        <%# Container.DataItem("itemno") %></div>
                    <div class="ordercolumn_2">
                        <%# Container.DataItem("itemname") %><%# Container.DataItem("notesoptions") %></div>
                    <div class="ordercolumn_3">
                        <%# Container.DataItem("lineqty") %></div>
                    <div class="ordercolumn_4">
                        <%# Container.DataItem("linepriceeach") %></div>
                    <div class="ordercolumn_5">
                        <%# Container.DataItem("linepricetotal") %></div>
                    <div style="clear: both;">
                    </div>
                </div>
                <asp:Repeater ID="childRepeater" runat="server" DataSource='<%# Container.DataItem.Row.GetChildRows("itemoptions") %>'>
                    <ItemTemplate>
                        <div class="ordertxt" style="width: 100%;">
                            <div class="ordercolumn_1">
                                <%# Container.DataItem("itemno") %></div>
                            <div class="ordercolumn_2">
                                <%# Container.DataItem("optionname") %>
                                <br />
                                <%# Container.DataItem("optiontext") %></div>
                            <div class="ordercolumn_3">
                                <%# Container.DataItem("lineqty") %></div>
                            <div class="ordercolumn_4">
                                <%# Container.DataItem("linepriceeach") %></div>
                            <div class="ordercolumn_5">
                                <%# Container.DataItem("linepricetotal") %></div>
                            <div style="clear: both;">
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </ItemTemplate>
        </asp:Repeater>
        <hr class="rowline" />
        <div class="ordertxt" style="width: 100%;">
            <div class="ordertotalcolumn_1">
                <%=pd.getsystext("sys11")%></div>
            <div class="ordertotalcolumn_2">
                <%=pd.showCurr(pd.dordersub)%></div>
            <div style="clear: both;">
            </div>
        </div>
        <% If pd.dDiscounts > 0 Then%>
        <div class="ordertxt" style="width: 100%;">
            <div class="ordertotalcolumn_1">
                <%=pd.getsystext("sys7")%></div>
            <div class="ordertotalcolumn_2">
                -<%=pd.showCurr(pd.dDiscounts)%></div>
            <div style="clear: both;">
            </div>
        </div>
        <% End If%>
        <% If pd.sCarriername <> "" Then%>
        <div class="ordertxt" style="width: 100%;">
            <div class="ordertotalcolumn_1">
                <%If pd.sRatemethod = "2" Then Response.Write("*")%><%=pd.getsystext("sys39")%></div>
            <div class="ordertotalcolumn_2">
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
        <div class="ordertxt" style="width: 100%;">
            <div class="ordertotalcolumn_1">
                <%=pd.getsystext("sys60")%></div>
            <div class="ordertotalcolumn_2">
                <%=pd.showCurr(pd.dOrdertaxtotal)%></div>
            <div style="clear: both;">
            </div>
        </div>
        <% End If%>
        <% If pd.dGiftamt > 0 Then%>
        <div class="ordertxt" style="width: 100%;">
            <div class="ordertotalcolumn_1">
                <%=pd.getsystext("sys9")%></div>
            <div class="ordertotalcolumn_2">
                -<%=pd.showCurr(pd.dGiftamt)%></div>
            <div style="clear: both;">
            </div>
        </div>
        <% End If%>
        <% If pd.dDiscounts > 0 Or pd.dCarrierrate > 0 Or pd.dOrdertaxtotal > 0 Or pd.dGiftamt > 0 Then%>
        <div class="ordertxt" style="width: 100%;">
            <div class="ordertotalcolumn_1">
                <%=pd.getsystext("sys61")%></div>
            <div class="ordertotalcolumn_2">
                <%=pd.showCurr(pd.dOrdergrandtotal)%></div>
            <div style="clear: both;">
            </div>
        </div>
        <% End If%>
        <% If pd.currrate <> 1 And (pd.dDiscounts > 0 Or pd.dCarrierrate > 0 Or pd.dOrdertaxtotal > 0 Or pd.dGiftamt > 0) Then%>
        <div class="ordertxt" style="width: 100%;">
            <div class="cartdata" style="width: 100%;">
                &nbsp;</div>
            <div class="ordertotalcolumn_1">
                <%=pd.getsystext("sys61")%></div>
            <div class="ordertotalcolumn_2">
                <%= pd.showPrimarycurr(pd.dOrdergrandtotal)%></div>
            <div style="clear: both;">
            </div>
        </div>
        <% End If%>
        <% If listdownloadscount > 0 Then%>
        <div class="orderheader">
            <%=pd.getsystext("sys120")%></div>
        <asp:Repeater ID="listdownloads" runat="server">
            <ItemTemplate>
                <div class="ordertxt">
                    <%# Container.DataItem("itemname") %></div>
                <div class="ordertxt">
                    <%# Container.DataItem("downloadbutton") %><%# Container.DataItem("message") %></div>
            </ItemTemplate>
        </asp:Repeater>
        <%End If%>
        <% If pd.sNotes2 <> "" Then%>
        <div class="orderheader">
            <%=pd.getsystext("sys111")%></div>
        <div class="ordertxt">
            <%= pd.dohtmlencode(pd.sNotes2)%></div>
        <% End If%>
        <div>
            <%=orderfooter%></div>
        <div class="formbuttons_container">
            <% If pd.popuptype = "I" Then%>
            <%=pd.getButton("butts32", "", "javascript: parent.popupFrame.printnormal();","")%><%=pd.getButton("butts33", "", "javascript: parent.hidePopWin(false)","")%>
            <% Else%>
            <%= pd.getButton("butts32", "", "javascript: window.print()", "")%><%= pd.getButton("butts33", "", "javascript: window.close()", "")%>
            <% End If%></div>
    </div>
</body>
</html>
