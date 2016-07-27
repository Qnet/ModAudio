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
    Public itemid, catname, catdesc, catpgconfig As String
    Public catitemcount, subcatitemcount As Int32

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub
    
  
    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()
         
        'Checks your Shop Access/Checkout settings.
        pd.VerifyShopAccess()

        itemid = pd.getrequest("itemid")
        If Not IsNumeric(itemid) Then pd.pdRedirect("default.aspx")

        'Not Used
        If Not (Page.IsPostBack) Then
        End If


        'Get Item Contents
        itemdetail.DataSource = pd.binditemdetail()
        itemdetail.DataBind()

        pd.OpenDataReader("SELECT * FROM items WHERE id=" & pd.FormatSqlText(itemid))
        If pd.ReadDataItem.Read Then
            catname = pd.ReadData("name")
            catshortdesc = pd.ReadData("shortdesc")
            itemreviewen = pd.ReadData("reviews")
            
            'Make sure Item Review is enabled
            If pd.reviewen = "A" Or (pd.reviewen = "I" And itemreviewen = "ON") Then
            Else
                pd.pdRedirect(pd.shopurl & "item.aspx?itemid=" & itemid)
            End If
             
        Else
            pd.pdRedirect("default.aspx")
        End If
        pd.CloseData()


        'Determine default page settings.
        If catpgconfig = "" Then
            catpgconfig = "MD, SP, SD, SI, ST"
        End If

        'Set Search engine meta tags.
        If catmetatitle <> "" Then
            pd.pagetitle = catmetatitle
        End If
        If catmetakeyw <> "" Then
            pd.keywords = catmetakeyw
        End If
        If catmetadesc <> "" Then
            pd.sitedesc = catmetadesc
        End If

        'Get Reviews
        listrepeater.DataSource = pd.binditemreviews(itemid, -1, 10)
        listrepeater.DataBind()
        catitemcount = listrepeater.DataSource.Count

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg12)%>
<%= pd.startSection("hditem")%>
<div>
    <div class="messages">
        <%=pd.getFormError()%></div>
    <asp:repeater id="itemdetail" runat="server">
        <itemtemplate>
        <div style="width: 100%;">
            <div style="float: left;">
                <% If pd.hideitemheading = "" Then%>
                <%# Container.DataItem("smallimagewrap")%>
                <div class="messages"><%# Container.DataItem("nameheading") %></div>
                <div class="itemname"><%# Container.DataItem("name") %></div>
                <div class="messages"><%# Container.DataItem("itemnoheading") %></div>
                <div class="itemname"><%# Container.DataItem("itemno") %></div>
                <div class="messages"><%# Container.DataItem("custom1heading") %></div>
                <div class="itemname"><%# Container.DataItem("custom1text") %></div>
                <div class="messages"><%# Container.DataItem("custom2heading") %></div>
                <div class="itemname"><%# Container.DataItem("custom2text") %></div>
                <div class="messages"><%# Container.DataItem("custom3heading") %></div>
                <div class="itemname"><%# Container.DataItem("custom3text") %></div>    
                 
                <div class="messages"><%# Container.DataItem("avgreviewheading") %></div>
                <div><%# Container.DataItem("avgreviewicon") %></div>

                <% End If%>            
                <div class="listdesc"><br /><%# Container.DataItem("shortdesc")%><br /></div>                  
            </div> 
            <div style="clear: both;"></div>
            <%# Container.DataItem("imagegallery")%>
        </div>
        <% If catitemcount = 0 Then%>                  
        <div class="messages"><br /><%= pd.geterrtext("err68")%></div>                                 
        <% End If%> 
     
        <div class="cartbuttons_container"><%# Container.DataItem("reviewbutton") %><%# Container.DataItem("viewitembutton")%>
        <% '=pd.getButton("butts38", "", pd.shopurl & "item.aspx?itemid=" & itemid, "")%>
        </div>

    </itemtemplate>
    </asp:repeater>
</div>
<% =pd.endSection() %>
<%  If catitemcount > 0 Then%>
<%= pd.startSection("hdreviews")%>
<div>
    <div class="messages">
        <%=pd.getFormError()%></div>
    <asp:repeater id="listrepeater" runat="server">
            <headertemplate>


            <div class="formheadings" style="width: 100%;">
                <div class="reviewscolumn_1"><a href="itemreview.aspx?itemid=<%=itemid%>&sortby=rating"><%=pd.getsystext("sys128")%></a></div>
                <div class="reviewscolumn_2"><a href="itemreview.aspx?itemid=<%=itemid%>&page=1&sortby=title"><%=pd.getsystext("sys129")%></a></div>
                <div class="reviewscolumn_3"><a href="itemreview.aspx?itemid=<%=itemid%>&page=1&sortby=date"><%=pd.getsystext("sys130")%></a></div>
                <div style="clear: both;"></div>
            </div> 
       
          </headertemplate>
          <itemtemplate>


            <div class="cartdata" style="width: 100%;">
                <div class="reviewscolumn_1"><%# Container.DataItem("starimage") %></div>
                <div class="reviewscolumn_2"><%# Container.DataItem("revtitle") %></div>
                <div class="reviewscolumn_3"><%# Container.DataItem("reviewdateformatted") %></div>
                <div style="clear: both;"></div>
            </div> 


            <div class="listdesc" style="width: 100%;">
                <div class="reviewscolumn_1">&nbsp;</div>
                <div class="reviewscolumn_2"><%# Container.DataItem("revcomments") %><br /> - <%# Container.DataItem("custname") %></div>
                <div class="reviewscolumn_3">&nbsp;</div>
                <div style="clear: both;"></div>
            </div>
            
                   
         </itemtemplate>
        <footertemplate>
    
        </footertemplate>
        </asp:repeater>
    <div class="paginglinks">
        <%=pd.paginglinks%></div>
</div>
<% =pd.endSection %>
<%  End If%>
<%=pd.getBottomHtml(pd.pg12)%>
