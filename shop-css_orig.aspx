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
    Public thecsscode As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)
        
     
        Response.ContentType = ("text/css")
        Response.Cache.SetExpires(DateTime.Now.AddSeconds(3600))
        Response.Cache.SetCacheability(HttpCacheability.Private)

        pd = New PDshopFunctions()
         
        '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        '
        'DO NOT EDIT THE CSS IN THIS FILE - MODIFY YOUR TEMPLATE.CSS FILE INSTEAD
        'THIS CSS IS FOR USE WHEN UPGRADING... WHEN CSS IS MISSING.  
        '
        '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        '/* Main Page Sections */
        pd.cssdata.Add(".body_container {margin-top: 0px; margin-left: auto; margin-right: auto;}")
        pd.cssdata.Add(".columndata_container {margin-top: 0px; margin-left: auto; margin-right: auto;}")
        pd.cssdata.Add(".columnspacer {}")

        '/* Shop Content Sections */
        pd.cssdata.Add(".slogan {text-align: left;}")
        pd.cssdata.Add(".topbar {text-align: left; padding-bottom: 3px;}")
        pd.cssdata.Add(".middlebar {background-color: ##SBANCOLOR##; border-color: ##BORDBANNER5##; border-style: solid; border-width: 1px;}")
        pd.cssdata.Add(".topsec {text-align: left; border-color: ##BORDSECTOP##; border-style: solid; border-width: 1px;}")
        pd.cssdata.Add(".topbanner {background-color: ##BGBANNER1##; border-color: ##BORDBANNER1##; border-style: solid; border-width: 1px;}")
        pd.cssdata.Add(".bannertxt {color: ##MMTXCOLOR##; font-family: ##PDFONT##; font-size: 10px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".searchbanner {background-color: ##SBANCOLOR##; border-color: ##BORDBANNER5##; border-style: solid; border-width: 1px;}")
        pd.cssdata.Add(".searchbanner img {position: relative; top: 5px; left: 4px;}")
        pd.cssdata.Add(".searchbanner form {margin-top: 0px;}")
        pd.cssdata.Add(".area1 {text-align: left; background-color: ##BGBANNER2##; border-color: ##BORDBANNER2##; border-style: solid; border-width: 1px;}")
        pd.cssdata.Add(".area2 {text-align: left; background-color: ##BGBANNER3##; border-color: ##BORDBANNER3##; border-style: solid; border-width: 1px;}")
        pd.cssdata.Add(".botsec {border-color: ##BORDSECBOT##; border-style: solid; border-width: 1px;}")
        pd.cssdata.Add(".botlinksec {background-color: ##BGBANNER5##;}")
        pd.cssdata.Add(".botbanner {text-align: center; background-color: ##BGBANNER4##; border-color: ##BORDBANNER4##; border-style: solid; border-width: 1px;}")
        pd.cssdata.Add(".botbannermenu {text-align: center; padding: 10px; color: ##BGBANNER5##; font-family: ##PDFONT##; font-size: 12px;}")
        pd.cssdata.Add(".botbannermenu A {color: ##PDCOLOR5##;}")
        pd.cssdata.Add(".leftcol {text-align: left; background-color: ##LEFTBGCOLOR##; overflow: hidden;}")
        pd.cssdata.Add(".middlecol {text-align: left; background-color: ##MIDBGCOLOR##; overflow: hidden;}")
        pd.cssdata.Add(".rightcol {text-align: left; background-color: ##RIGHTBGCOLOR##; overflow: hidden;}")
        pd.cssdata.Add(".sectionspacer {width: auto; height: ##SPACERCOLH##px;}")
        pd.cssdata.Add(".google {float: left; padding-right: 5px;}")
        pd.cssdata.Add(".twitter_page {float: left; padding-left: 5px; padding-top: 3px; }")
        pd.cssdata.Add(".facebook_page {float: left; padding-left: 5px; padding-top: 3px;}")
        pd.cssdata.Add(".twitter_share {float: left; padding-right: 5px; padding-top: 5px; }")
        pd.cssdata.Add(".facebook_like {float: left; padding-top: 5px;}")
        pd.cssdata.Add(".minicart {padding-top: 5px; vertical-align: text-bottom; float: right; text-align: right; color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 11px; font-weight: normal; text-decoration: none;}")
        pd.cssdata.Add(".minicart A {color: ##PDCOLOR5##; font-size: 12px; font-weight: bold; text-decoration: underline;}")
        pd.cssdata.Add(".currency_div {float: right; padding-left: 15px; padding-top:1px; font-family: ##PDFONT##; font-size: 11px; font-weight: normal;}")
        pd.cssdata.Add(".currency_div select {font-family: ##PDFONT##; font-size: 11px; font-weight: normal;}")

        '/* Section Headings */
        pd.cssdata.Add(".headingtextS {text-align: left; padding: 1px; font-family: ##PDFONT##; font-size: 10px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".headingtext {text-align: left; padding: 2px; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".headingtextL {text-align: left; padding: 5px; font-family: ##PDFONT##; font-size: 14px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".tabheading {text-align: left; font-family: ##PDFONT##; font-size: 10px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".tabheadingL {text-align: left; padding-left: 6px; letter-spacing: 2px;  font-family: ##PDFONT##; font-size: 13px; font-weight: bold; text-decoration: none;}")

        pd.cssdata.Add(".customheading {text-align: left; color: #999999; background-color: ; font-family: ##PDFONT##; font-size: 16px; font-weight: bold; padding: 5px; border-color:#CCCCCC; border-style: none; border-width: 1px; text-decoration: none;}")
        pd.cssdata.Add(".headingmessages {text-align: left; padding-left: 10px; padding-top: 10px; color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 11px; font-weight: normal;}")

        '/* Shop Section Containers */
        pd.cssdata.Add(".section_container {text-align: left; width: auto; overflow: hidden;}")
        pd.cssdata.Add(".section_topdata {width: auto; overflow: hidden; }")
        pd.cssdata.Add(".section_messages {float: left; padding-left: 10px; padding-top: 10px; color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 11px; font-weight: normal;}")
        pd.cssdata.Add(".section_options {float: right; color: ##PDCOLOR3##; padding-top: 5px; padding-right: 10px; font-family: ##PDFONT##; font-size: 11px; font-weight: normal;}")
        pd.cssdata.Add(".section_options select {color: ##PDCOLOR3##; border: 1px solid #EEEEEE; font-family: ##PDFONT##; font-size: 10px; font-weight: normal;}")
        pd.cssdata.Add(".section_data {text-align: left; width: auto; margin: 10px; overflow: hidden;}")

        '/* Buttons & Links */
        pd.cssdata.Add(".buttonsstandard {font-size:10px; font-weight: bold; font-family: ##PDFONT##; margin-left: 2px; margin-top: 2px; margin-bottom: 2px; margin-right: 2px;}")
        pd.cssdata.Add(".textlinks {padding-left: 2px; font-family: ##PDFONT##; font-size: 12px; font-weight: bold;}")
        pd.cssdata.Add(".textlinks A {font-family: ##PDFONT##; font-size: 12px; font-weight: bold;}")
        pd.cssdata.Add(".textlinks A:hover {text-decoration: underline;}")
        pd.cssdata.Add(".butttxt {font-family: ##PDFONT##; font-size: 11px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".custombutton {color: #FFFFFF; background-color: #999999; font-size:11px; font-weight: bold; font-family: ##PDFONT##; margin-left: 2px; margin-top: 2px; margin-bottom: 2px; margin-right: 2px;}")
        pd.cssdata.Add(".classicbutton {white-space: nowrap; display: inline-block; height: 20px; padding: 2px; margin: 1px;}")
        pd.cssdata.Add(".classicbuttontext {border-color: #EEEEEE; border-style: solid; border-width: 1px; padding-right: 8px; padding-left: 8px; padding-top: 2px; padding-bottom: 5px; font-size:11px; font-weight: bold; font-family: ##PDFONT##; text-decoration: none;}")
        pd.cssdata.Add(".classicbuttontext A:Hover {text-decoration: underline;}")
        pd.cssdata.Add(".cartbuttons_container {padding-top: 2px; padding-bottom: 2px;}")
        pd.cssdata.Add(".cartbuttons_container img {vertical-align: top;}")
        pd.cssdata.Add(".formbuttons_container {text-align: center; margin:15px;}")

        '/* Menu Tabs (Small) */
        pd.cssdata.Add(".menutab {margin-right: 1px; margin-left: 1px; float: left; height: 15px; background-color: ##MMBGCOLOR##;}")
        pd.cssdata.Add(".menutabtext A {position: relative; top: 2px; color: ##MMTXCOLOR##; font-family: ##PDFONT##; font-size: 10px; font-weight: bold; text-decoration: none}")

        '/* Menu Tabs (Large) */
        pd.cssdata.Add(".menutabL {margin-right: 1px; margin-left: 1px; float: left; height: 20px; background-color: ##MMBGCOLOR##;}")
        pd.cssdata.Add(".menutabtextL A {position: relative; top: 2px; color: ##MMTXCOLOR##; font-family: ##PDFONT##; font-size: 14px; font-weight: bold; text-decoration: none}")

        '/* Menu Tabs (Text Links) */
        pd.cssdata.Add(".menutextlink A {padding: 2px; color: ##MMTXCOLOR##; font-family: ##PDFONT##; font-size: 10px; font-weight: bold; text-decoration: underline;}")
        pd.cssdata.Add(".menutextlinkL A {padding: 4px; color: ##MMTXCOLOR##; font-family: ##PDFONT##; font-size: 14px; font-weight: bold; text-decoration: underline;}")

        '/* Item Related */
        pd.cssdata.Add(".itemname {color: ##PDCOLOR3##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".itemname A {color: ##PDCOLOR3##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".itemdesc {color: ##PDCOLOR4##; font-family: ##PDFONT##; font-size: 11px;}")
        pd.cssdata.Add(".itemdesc A {color: ##PDCOLOR4##; font-family: ##PDFONT##; font-size: 11px;}")
        pd.cssdata.Add(".price {color: ##PDCOLOR3##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold;}")
        pd.cssdata.Add(".listname {color: ##PDCOLOR3##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".listname A {color: ##PDCOLOR3##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".listname A:hover {color: ##PDCOLOR3##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: underline;}")
        pd.cssdata.Add(".listimage {padding-top:5px; padding-right:5px; padding-bottom:5px;}")
        pd.cssdata.Add(".listdesc {padding-top:5px; padding-right:5px; padding-bottom:5px; color: ##PDCOLOR4##; font-family: ##PDFONT##; font-size: 11px;}")
        pd.cssdata.Add(".listprice {color: ##PDCOLOR3##; font-family: ##PDFONT##; font-size: 11px; font-weight: bold;}")
        pd.cssdata.Add(".listitemno {color: ##PDCOLOR3##; font-family: ##PDFONT##; font-size: 11px; font-weight: bold;}")

        '/* Item Detail Page */
        pd.cssdata.Add(".itemdescription {color: ##PDCOLOR4##; font-family: ##PDFONT##; font-size: 12px; font-weight: normal;}")
        pd.cssdata.Add(".itemqtyinput {background-color: #FFFFFF; color: #000000; font-family: ##PDFONT##; font-size: 12px; font-weight: normal;}")
        pd.cssdata.Add(".itemstockmessage {margin-top: 5px; margin-bottom: 5px; color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 12px; font-weight: normal;}")
        pd.cssdata.Add(".itemoptions_container {padding: 2px; }")
        pd.cssdata.Add(".itemoptionsgroup {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 14px; font-weight: normal; text-decoration: none;}")
        pd.cssdata.Add(".itemoptions {padding: 1px; color: ##PDCOLOR3##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".optionselect {background-color: #FFFFFF; color: ##PDCOLOR3##; border: 1px solid #000000; font-family: ##PDFONT##; font-size: 12px; font-weight: bold;}")
        pd.cssdata.Add(".optiontextinput {font-family: ##PDFONT##; font-size: 12px; font-weight: normal; background-color: #FFFFFF;}")
        pd.cssdata.Add(".optiontextarea {padding-right: 10px; vertical-align:baseline; font-family: ##PDFONT##; font-size: 12px; font-weight: normal; background-color: #FFFFFF;}")
        pd.cssdata.Add(".optioncheckbox {margin-right: 5px; vertical-align:baseline;}")
        pd.cssdata.Add(".optionradiobutton {margin-right: 5px; vertical-align:baseline;}")
        pd.cssdata.Add(".optionmonetaryinput {background-color: #FFFFFF; color: #000000; font-family: ##PDFONT##; font-size: 12px; font-weight: normal; width: 50px;}")

        '/* Item Reviews Page */
        pd.cssdata.Add(".reviewscolumn_1 {width: 20%; float: left; overflow: hidden;}")
        pd.cssdata.Add(".reviewscolumn_2 {width: 60%; float: left; overflow: hidden;}")
        pd.cssdata.Add(".reviewscolumn_3 {width: 19%; float: left; overflow: hidden; text-align: right;}")

        '/* Category Related */
        pd.cssdata.Add(".catname {color: ##PDCOLOR1##; font-family: ##PDFONT##; font-size: 14px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".catname A {color: ##PDCOLOR1##; font-family: ##PDFONT##; font-size: 14px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".catname A:hover {text-decoration: underline;}")
        pd.cssdata.Add(".catdesc {padding-bottom: 10px; color: ##PDCOLOR2##; font-family: ##PDFONT##; font-size: 11px; text-decoration: none;}")
        pd.cssdata.Add(".catdelim {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 8px; text-decoration: none;}")
        pd.cssdata.Add(".subcats {color: ##PDCOLOR1##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".subcats A {padding: 5px; color: ##PDCOLOR1##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".subcats A:hover {text-decoration: underline;}")
        pd.cssdata.Add(".subcatlist_div {width: auto; overflow: hidden; padding: 5px;}")
        pd.cssdata.Add(".catlist_div {margin-bottom: 10px;}")
        pd.cssdata.Add(".catitem_div {padding: 10px; overflow: hidden;}")
        pd.cssdata.Add(".catitemlist_div {width: 100%; overflow: hidden; padding: 5px;}")
        pd.cssdata.Add(".catitemlist_column1 {float: left; margin-right: 5px; overflow: hidden;}")
        pd.cssdata.Add(".catitemlist_column2 {float: left; margin-right: 5px; overflow: hidden;}")
        pd.cssdata.Add(".catitemlist_column3 {word-wrap: break-word; text-align: left; float: left; margin-right: 5px; overflow: hidden;}")
        pd.cssdata.Add(".catitemlist_column4 {text-align: right; float: left; overflow: hidden;}")

        '/* Top Level Category listing */
        pd.cssdata.Add(".toplevelcat {padding-bottom: 2px; color: ##PDCOLOR1##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".toplevelcat A {color: ##PDCOLOR1##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".toplevelcat A:hover {text-decoration: underline;}")
        pd.cssdata.Add(".toplevelcatdot {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 11px; font-weight: normal; text-decoration: none;}")
        pd.cssdata.Add(".toplevelcatdes {color: ##PDCOLOR2##; font-family: ##PDFONT##; font-size: 11px; text-decoration: none;}")
        pd.cssdata.Add(".toplevelsub {padding-left: 12px; padding-bottom: 7px; color: ##PDCOLOR1##; font-family: ##PDFONT##; font-size: 12px; font-weight: normal; text-decoration: none;}")
        pd.cssdata.Add(".toplevelsub A {line-height: 16px; color: ##PDCOLOR1##; font-family: ##PDFONT##; font-size: 11px; font-weight: normal; text-decoration: none;}")
        pd.cssdata.Add(".toplevelsub A:hover {text-decoration: underline;}")
        pd.cssdata.Add(".toplevelsubdot {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 8px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".toplevelsubdes {color: ##PDCOLOR2##; font-family: ##PDFONT##; font-size: 10px; text-decoration: none;}")

        '/* System Text & Error Messages */
        pd.cssdata.Add(".messages {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 10px; font-weight: normal;}")
        pd.cssdata.Add(".messages A {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 10px; font-weight: normal;}")
        pd.cssdata.Add(".messages2 {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 14px; font-weight: bold;}")
        pd.cssdata.Add(".messages3 {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 16px; font-weight: bold; text-align: center;}")
        pd.cssdata.Add(".errors {color: red; font-family: ##PDFONT##; font-size: 10px; font-weight: bold;}")
        pd.cssdata.Add(".paginglinks {padding: 10px; padding-top: 25px; text-align: center; color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 12px; font-weight: normal;}")
        pd.cssdata.Add(".paginglinks A {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 12px; font-weight: normal;}")

        '/* Forms */
        pd.cssdata.Add(".form_container {width: auto; background-color: ##FORMBGCOLOR##; padding: 15px; padding-left: 25px; padding-right: 25px;}")
        pd.cssdata.Add(".formheadings {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".formheadings A {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: underline;}")
        pd.cssdata.Add(".formheadings2 {padding-top: 10px; padding-bottom: 5px; color: ##PDCOLOR5##; font-style:italic; font-family: ##PDFONT##; font-size: 16px; font-weight: normal; text-decoration: none;}")
        pd.cssdata.Add(".formordertotal {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".rowline {color: ##PDCOLOR5##; height: 1px;}")
        pd.cssdata.Add(".rowline2 {color: #EEEEEE; height: 1px;}")
        pd.cssdata.Add(".formfield {font-family: ##PDFONT##; font-size: 12px; font-weight: normal; background-color: #FFFFFF; width: 200px;}")
        pd.cssdata.Add(".formfield2 {font-family: ##PDFONT##; font-size: 12px; font-weight: normal; background-color: #FFFFFF; width: 50px;}")
        pd.cssdata.Add(".formfield3 {font-family: ##PDFONT##; font-size: 12px; font-weight: normal; background-color: #FFFFFF; width: 100px;}")
        pd.cssdata.Add(".formfield4 {font-family: ##PDFONT##; font-size: 12px; font-weight: normal; background-color: #FFFFFF; width: 275px;}")
        pd.cssdata.Add(".formfield5 {font-family: ##PDFONT##; font-size: 12px; font-weight: normal; background-color: #FFFFFF; width: 35px;}")
        pd.cssdata.Add(".formtextarea1 {font-family: ##PDFONT##; font-size: 12px; font-weight: normal; background-color: #FFFFFF; width: 400px; height: 100px;}")
        pd.cssdata.Add(".formtextarea2 {font-family: ##PDFONT##; font-size: 12px; font-weight: normal; background-color: #FFFFFF; width: 300px; height: 100px;}")
        pd.cssdata.Add(".gatewaylogo {padding-left: 30px; padding-bottom: 10px;}")
        pd.cssdata.Add(".searchselect {background-color: ##BUTTBGCOLOR##; color: ##BUTTTXCOLOR##; border: 1px solid #EEEEEE; font-family: ##PDFONT##; font-size: 12px; font-weight: normal;}")
        pd.cssdata.Add(".searchinput {font-family: ##PDFONT##; color: #000000; font-size: 12px; font-weight: normal; background-color: #FFFFFF; width: 125px;}")
        pd.cssdata.Add(".radiobuttons_container {padding: 1px; color: ##PDCOLOR3##; font-family: ##PDFONT##; font-size: 11px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".radiobuttons {padding-right: 10px; vertical-align:baseline;}")
        pd.cssdata.Add(".checkboxes_container {padding: 1px; color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 12px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".checkboxes {padding-right: 5px; vertical-align:baseline;}")

        '/* Shopping Cart related */
        pd.cssdata.Add(".cartdata {color: ##PDCOLOR3##; font-family: ##PDFONT##; font-size: 11px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".cartdata A {color: ##PDCOLOR3##; font-family: ##PDFONT##; font-size: 11px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".cartdata2 {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 10px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".cartdata2 A {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 10px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".cartcolumn_1 {width: 50%; float: left; overflow: hidden;}")
        pd.cssdata.Add(".cartcolumn_2 {width: 15%; float: left; overflow: hidden;}")
        pd.cssdata.Add(".cartcolumn_3 {width: 15%; float: left; overflow: hidden; text-align: right;}")
        pd.cssdata.Add(".cartcolumn_4 {width: 19%; float: left; overflow: hidden; text-align: right;}")
        pd.cssdata.Add(".carttotalcolumn_1 {width: 80%; float: left; overflow: hidden; text-align: right;}")
        pd.cssdata.Add(".carttotalcolumn_2 {width: 19%; float: left; overflow: hidden; text-align: right;}")

        '/* Floating Row */
        pd.cssdata.Add(".td {float: left;}")

        '/* End/Clear Table Row */
        pd.cssdata.Add(".tr {clear: both;  visibility:hidden ; height: 0px; font-size: 0; line-height: 0px;}")

        '/* Order Receipt Page */
        pd.cssdata.Add(".orderheader {margin-top: 5px; background-color: ##HDBGCOLOR##; color: ##HDTXCOLOR##; font-family: ##PDFONT##; font-size: 11px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".orderheader2 {color: ##HDTXCOLOR##; font-family: ##PDFONT##; font-size: 14px; font-weight: bold; text-decoration: none;}")
        pd.cssdata.Add(".ordertxt {color: ##PDCOLOR5##; font-family: ##PDFONT##; font-size: 11px;}")
        pd.cssdata.Add(".ordercolumn_1 {width: 15%; float: left; overflow: hidden;}")
        pd.cssdata.Add(".ordercolumn_2 {width: 40%; float: left; overflow: hidden;}")
        pd.cssdata.Add(".ordercolumn_3 {width: 15%; float: left; overflow: hidden; text-align: center;}")
        pd.cssdata.Add(".ordercolumn_4 {width: 15%; float: left; overflow: hidden; text-align: right;}")
        pd.cssdata.Add(".ordercolumn_5 {width: 14%; float: left; overflow: hidden; text-align: right;}")
        pd.cssdata.Add(".ordertotalcolumn_1 {width: 85%; float: left; overflow: hidden; text-align: right;}")
        pd.cssdata.Add(".ordertotalcolumn_2 {width: 14%; float: left; overflow: hidden; text-align: right;}")

        '/* AFFILIATE REPORT */
        pd.cssdata.Add(".reportcolumn_1 {width: 30%; float: left; overflow: hidden;}")
        pd.cssdata.Add(".reportcolumn_2 {width: 14%; float: left; overflow: hidden;}")
        pd.cssdata.Add(".reportcolumn_3 {width: 14%; float: left; overflow: hidden; text-align: center;}")
        pd.cssdata.Add(".reportcolumn_4 {width: 14%; float: left; overflow: hidden; text-align: right;}")
        pd.cssdata.Add(".reportcolumn_5 {width: 14%; float: left; overflow: hidden; text-align: right;}")
        pd.cssdata.Add(".reportcolumn_6 {width: 13%; float: left; overflow: hidden; text-align: right;}")
                
        '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        '
        'DO NOT EDIT THE CSS IN THIS FILE - MODIFY YOUR TEMPLATE.CSS FILE INSTEAD
        'THIS CSS IS FOR USE WHEN UPGRADING... WHEN CSS IS MISSING.  
        '
        '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
        
        'MODIFY existing CSS classes if attribute is not specified (for Backward compatibility)
        pd.cssdata2.Add(".leftcol {text-align: left;}")
        pd.cssdata2.Add(".middlecol {text-align: left;}")
        pd.cssdata2.Add(".rightcol {text-align: left;}")
        
        'Write CSS Styles to browser
        pd.LoadTemplateCss = 1
        pd.LoadPDshop()
        Response.Write(pd.TemplateCss)
         
    End Sub


    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub
   

</script>
