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
    Public affillink, startdate, enddate, mainpage As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        If Not (Page.IsPostBack) Then
        End If

        affillink = pd.getrequest("affillink")
        afuid = pd.getrequest("afuid")
        startdate = pd.getrequest("startdate")
        enddate = pd.getrequest("enddate")
        If Not IsNumeric(afuid) Or affillink = "" Then pd.pdRedirect("default.aspx")

        'Open Database, check for authenticity
        pd.OpenDataReader("SELECT * FROM affiliates WHERE affillink='" & pd.FormatSqlText(affillink) & "' AND id=" & afuid)
        If pd.ReadDataItem.Read Then
            passtest = "Y"
        Else
        End If
        pd.CloseData()

        If passtest = "Y" Then
            reportrepeater.DataSource = pd.bindaffiliatereport(startdate, enddate, affillink)
            reportrepeater.DataBind()
        End If

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<html>
<head>
    <title>
        <%=pd.pagetitle%></title>
    <link rel="stylesheet" type="text/css" href="shop-css.aspx" />
    <script type="text/javascript" src="shop-javascript.js"></script>
</head>
<body class="popupbody">
    <div class="ordertxt">
        <div class="formbuttons_container">
            <%=pd.getButton("butts32", "", "javascript: window.print()","")%>
            <%=pd.getButton("butts33", "", "javascript: window.close()","")%></div>
    </div>
    <div class="ordertxt">
        &nbsp;</div>
    <div class="orderheader2">
        Affiliate Sales Report</div>
    <div class="ordertxt">
        <%=pd.formerror%></div>
    <div class="ordertxt">
        &nbsp;</div>
    <asp:Repeater ID="reportrepeater" runat="server">
        <HeaderTemplate>
            <div class="orderheader" style="width: 100%;">
                <div class="reportcolumn_1">
                    Affiliate Name</div>
                <div class="reportcolumn_2">
                    Order Date</div>
                <div class="reportcolumn_3">
                    Order No.</div>
                <div class="reportcolumn_4">
                    Sale Amount</div>
                <div class="reportcolumn_5">
                    Percent</div>
                <div class="reportcolumn_6">
                    Commission</div>
                <div style="clear: both;">
                </div>
            </div>
        </HeaderTemplate>
        <ItemTemplate>
            <div class="ordertxt" style="width: 100%;">
                <div class="reportcolumn_1">
                    <%# Container.DataItem("affiliatename") %>
                    &nbsp;</div>
                <div class="reportcolumn_2">
                    <%# Container.DataItem("shortorderdate") %></div>
                <div class="reportcolumn_3">
                    <%# Container.DataItem("orderno") %></div>
                <div class="reportcolumn_4">
                    <%# Container.DataItem("saleamount") %></div>
                <div class="reportcolumn_5">
                    <%# Container.DataItem("commission") %></div>
                <div class="reportcolumn_6">
                    <%# Container.DataItem("commissionamount") %></div>
                <div style="clear: both;">
                </div>
            </div>
        </ItemTemplate>
        <FooterTemplate>
            <div class="orderheader" style="width: 100%;">
                <div class="reportcolumn_1">
                    &nbsp;
                </div>
                <div class="reportcolumn_2">
                    &nbsp;
                </div>
                <div class="reportcolumn_3">
                    &nbsp;
                </div>
                <div class="reportcolumn_4">
                    &nbsp; ________</div>
                <div class="reportcolumn_5">
                    &nbsp;
                </div>
                <div class="reportcolumn_6">
                    &nbsp; ________</div>
                <div style="clear: both;">
                </div>
            </div>
            <div class="orderheader" style="width: 100%;">
                <div class="reportcolumn_1">
                    &nbsp;
                </div>
                <div class="reportcolumn_2">
                    &nbsp;
                </div>
                <div class="reportcolumn_3">
                    &nbsp;
                </div>
                <div class="reportcolumn_4">
                    &nbsp;
                    <%=pd.sfoot3%></div>
                <div class="reportcolumn_5">
                    &nbsp;
                </div>
                <div class="reportcolumn_6">
                    &nbsp;
                    <%=pd.sfoot5%>
                </div>
                <div style="clear: both;">
                </div>
            </div>
        </FooterTemplate>
    </asp:Repeater>
    <div class="ordertxt">
        <br />
        <%=pd.paginglinks%>
        <br />
        <br />
    </div>
</body>
</html>
