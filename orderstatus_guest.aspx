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

        'Check if using Order Link to Access
        orderid = pd.getrequest("orderid")
        orderkey = pd.getrequest("key")
        'If IsNumeric(orderid) And Len(orderkey) > 10 Then
        If pd.isOrderKeyValid(orderid, orderkey) = "No" Then
            pd.pdRedirect("signin.aspx")
        End If
        'End If

        'After calling the functions below, some Public Variables will then be available...
        pd.getOrderVariables("", orderid, "")

        'Get Customer Downloads
        listdownloads.DataSource = pd.bindcustomerdownloads(0, orderid)
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
    <div>
        <hr class="rowline">
    </div>
    <div>
        <div class="formheadings">
            <span class="formheadings">
                <%=pd.getsystext("sys65")%></span><br />
            <span class="cartdata">
                <%=pd.iOrderno%></span><br />
            <br />
            <span class="formheadings">
                <%=pd.getsystext("sys67")%></span><br />
            <span class="cartdata">
                <%=pd.sStatus%></span><br />
            <br />
            <% If pd.sCarriername <> "" Then%>
            <span class="formheadings">
                <%=pd.getsystext("sys40")%></span><br />
            <span class="cartdata">
                <%=pd.sCarriername%>
                <br />
                <%=pd.sTracking%></span><br />
            <br />
            <% End If%>
            <% If pd.sNotes2 <> "" Then%>
            <span class="formheadings">
                <%=pd.getsystext("sys111")%></span><br />
            <span class="cartdata">
                <%=pd.snotes2%></span><br />
            <br />
            <% End If%>
        </div>
        <div>
            <%= pd.getButton("butts26", "", "javascript: showwindow('popup_orderview.aspx?orderid=" & pd.iOrderid & "&key=" & pd.getOrderKey(pd.iOrderid) & "', " & pd.ordwinw & "," & pd.ordwinh & ", null)", "")%>
        </div>
    </div>
    <% If listdownloadscount > 0 Then%>
    <br />
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
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>
