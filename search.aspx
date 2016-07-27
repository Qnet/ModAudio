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
    Public catname, catdesc, catpgconfig As String
    Public catitemcount, subcatitemcount, catpagetype, catpagemax As Integer

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)


        pd = New PDshopFunctions()
        pd.LoadPDshop()
         
        'Checks your Shop Access/Checkout settings.
        pd.VerifyShopAccess()

        'Not Used
        If Not (Page.IsPostBack) Then
        End If

        catpagemax = 10
        catmaxcols = 1
        catpgconfig = "AC, MD, SP, SD, SI, ST"
        catpagetype = 1
        
        'Determine List View or Grid View
        pd.pageviewby = pd.getcookie("viewby")
        If pd.pageviewby = "" Then
            If catpagetype = 2 Then
                pd.pageviewby = "grid"
            End If
        ElseIf pd.pageviewby = "grid" Then
            catmaxcols = 2
            catpagetype = 2
        ElseIf pd.pageviewby = "list" Then
            catpagetype = 1
            catmaxcols = 1
        End If
        
        'Override Column width defaults
        'pd.colwidth1 = 20
        'pd.colwidth2 = 50
        'pd.colwidth3 = 10
        'pd.colwidth4 = 15
        pd.currentpgconfig = catpgconfig
        
        columnrepeater.DataSource = pd.bindcategoryitems("S", catpagemax)
        catitemcount = columnrepeater.DataSource.Count
        columnrepeater.RepeatColumns = catmaxcols
        columnrepeater.RepeatDirection = catsortdir
            
        columnrepeater.RepeatLayout = RepeatLayout.Table
        columnrepeater.GridLines = GridLines.None
        columnrepeater.DataBind()


    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg8)%>
<%= pd.startSection("heads1")%>
<div>

    <% If catitemcount > 0 Then%>
    <div class="messages">
        <%=pd.getFormError()%></div>
    <asp:datalist id="columnrepeater" runat="server" style="width: 99%; table-layout: fixed;"
        itemstyle-verticalalign="Top">

    <itemtemplate>

        <% If catpagetype = 1 Or catpagetype = 0 Then%>

           <div class="catitemlist_div">
               <div class="catitemlist_column1" style="width: <%=pd.colwidth1 %>%;"><div class="listimage"><%# Container.DataItem("itemimage") %></div></div>
                <div class="catitemlist_column2" style="width: <%=pd.colwidth2 %>%;">
                    <div class="listname"><%# Container.DataItem("itemname") %></div>
                    <div class="listdesc"><%# Container.DataItem("shortdesc") %></div>
                   <div class="cartbuttons_container">
                        <%# Container.DataItem("buybutton") %>
                        <%# Container.DataItem("morebutton") %>
                    </div>
               </div>
               <div class="catitemlist_column3" style="width: <%=pd.colwidth3 %>%;">
                    <div class="listitemno"><%# Container.DataItem("itemno") %></div>
               </div>
                <div class="catitemlist_column4" style="width: <%=pd.colwidth4 %>%;">                    
                    <div class="listprice"><%# Container.DataItem("itemprice") %></div>
                    <div class="messages"><%# Container.DataItem("stockmessage") %></div>
               </div>
                <div style="clear: both;"></div>
          </div>

        <% Else%>
        <div class="catitem_div">
           <div class="listimage"><%# Container.DataItem("itemgridimage")%></div>
           <div class="listname"><%# Container.DataItem("itemname") %></div>           
           <div class="listdesc"><%# Container.DataItem("shortdesc") %></div>
           <div class="cartbuttons_container">
                <%# Container.DataItem("buybutton") %>
                <%# Container.DataItem("morebutton") %>
            </div>
          <div class="listitemno"><%# Container.DataItem("itemno") %></div>
          <div class="listprice"><%# Container.DataItem("itemprice") %></div>
          <div class="messages"><%# Container.DataItem("stockmessage") %></div>          
          </div>
      <% End If%>

    </itemtemplate>
    </asp:datalist>
    <div>
        <%=pd.paginglinks%></div>
    <% End If%>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg8)%>
