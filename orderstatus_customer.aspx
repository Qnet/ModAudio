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
    Public listdownloadscount, listorderscount As Int32

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

        'Call customer address
        pd.getCustomerVariables(customerid)

        'Get Customer orders
        listorders.DataSource = pd.bindcustomerorders(customerid)
        listorderscount = listorders.DataSource.Count
        listorders.DataBind()

        'Get Customer Downloads
        listdownloads.DataSource = pd.bindcustomerdownloads(customerid, 0)
        listdownloadscount = listdownloads.DataSource.Count
        listdownloads.DataBind()


        If Not (Page.IsPostBack) Then

        End If

        If Page.IsPostBack Then

        End If


    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg9)%>
<%= pd.startSection("heads8")%>
<div>
    <form method="POST" id="pageform" name="pageform" runat="server">
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="listname">
        <%=pd.sName%><br />
        <%=pd.sEmail%>
    </div>
     <div style="clear: both; height: 10px;"><!-- --></div>
    <div class="cartbuttons_container">
        <%=pd.getButton("butts16","","chgprofile.aspx","") %>
        <%=pd.getButton("butts10","", pd.shopurl & "continue.aspx","") %></div>
    <div style="clear: both; height: 10px;"><!-- --></div>
    <% If listdownloadscount > 0 Then%>
    <asp:repeater id="listdownloads" runat="server">
        <headertemplate>
           
        <hr class="rowline" />
        <div style="width: 100%;">
            <div class="formheadings" style="float: left; width: 33%;"><%=pd.getsystext("sys65")%></div>
            <div class="formheadings" style="float: left; width: 33%;"><%=pd.getsystext("sys1")%></div>
            <div class="formheadings" style="float: left; width: 33%;"></div>
            <div style="clear: both;"><!-- --></div>
        </div>
        <hr class="rowline" />

        </headertemplate>
        <itemtemplate>

        <div style="width: 100%;">
            <div class="cartdata" style="float: left; width: 33%;"><%# Container.DataItem("orderno") %></div>
            <div class="cartdata" style="float: left; width: 33%;"><%# Container.DataItem("itemname") %></div>
            <div class="cartdata" style="float: left; width: 33%;"><%# Container.DataItem("message") %><%# Container.DataItem("downloadbutton") %></div>
            <div style="clear: both; height: 10px;"><!-- --></div>
        </div>
             
        </itemtemplate>
        <footertemplate>
        </footertemplate>
    </asp:repeater>
    <%End If%>
    <% If listorderscount > 0 Then%>
    <asp:repeater id="listorders" runat="server">
        <headertemplate>         
           
        <hr class="rowline" />
        <div style="width: 100%;">
            <div class="formheadings" style="float: left; width: 25%;"><%=pd.getsystext("sys65")%></div>
            <div class="formheadings" style="float: left; width: 25%;"><%= pd.getsystext("sys66")%></div>
            <div class="formheadings" style="float: left; width: 25%;"><%= pd.getsystext("sys67")%></div>
            <div class="formheadings" style="float: left; width: 25%;"></div>
            <div style="clear: both;"><!-- --></div>
        </div>
        <hr class="rowline" />
             
        </headertemplate>
        <itemtemplate>
             
        <div style="width: 100%;">
            <div class="cartdata" style="float: left; width: 25%;"><%# Container.DataItem("orderno") %></div>
            <div class="cartdata" style="float: left; width: 25%;"><%# Container.DataItem("thedate") %></div>
            <div class="cartdata" style="float: left; width: 25%;"><%# Container.DataItem("status") %></div>
            <div class="cartdata" style="float: left; width: 25%;"><%# Container.DataItem("vieworderbutton") %></div>
            <div style="clear: both; height: 5px;"><!-- --></div>
        </div>

        </itemtemplate>
        <footertemplate>
        </footertemplate>

    </asp:repeater>
    <%End If%>
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>