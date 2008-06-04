/*---------------------------------------------------
-----------------------------------------------------
Filename:	browser.m
Version:	4.1

Type:		maki
Date:		23. Jan. 2008 - 10:06 
Author:		Martin Poehlmann aka Deimos
E-Mail:		martin@skinconsortium.com
Internet:	www.skinconsortium.com
		www.martin.deimos.de.vu
-----------------------------------------------------
---------------------------------------------------*/

#include <lib/std.mi>
#include <lib/config.mi>
#include <lib/fileio.mi>
#include <lib/application.mi>

#define RELEASE
#define FILE_NAME "browser.m"
#include <lib/debug.m>

#define BROWSER_SCRIPT

#include init_browser.m

Class PopupMenu AttribMenu;


Function doLyricSearch();
Function doExplorerSearch();
Function doFoxySearch();

Function AttribMenu createMenufromAttribList (List entries);
/**
	createMenufromAttribList() explanation
	the List "entries" MUST have the following style:
	item 0 - is a configItem, which represents the root item.
	all other items are ConfigAttributes, which will be autofilled
*/

Function loadInternalLinks();

Function string prepareWebString(string url, string replace);
Function string strReplace(string str, string replace, string by);
	
Function performWebSearch (string searchstring);
Function BrowserReload();

Function playListItem(int num);
Function enqueueListItem(int num);
Function downloadListItem(int num);


Global Container quicklink_name;
Global Layout normal, quicklink_name_layout;
Global Frame dualwnd;

Global Group scr_content, g_search, g_navurl, sg;

Global Browser brw;
Global Button bback, bffwd, bhome, bbrowse, brefresh, bstop, bsearch, blinks;
Global Button scr_open, scr_close, scr_rescan, scr_play, scr_download;
Global Edit navurl, searchedit;

Global GuiList scr_list;

Global PopUpMenu scr_menu;
Global List internal_LinksTitle, internal_LinksUrl, internal_LinksSubmenus;

Global Boolean isAutomatedSearch, mouseDown, lyricMode, explorerMode, foxyMode;

//pjn123 EDIT
Global Group g_scr_show, g_scr_hide, g_scr_play, g_scr_download, g_scr_rescan;
Global Layer l_scr_show, l_scr_hide, l_scr_play, l_scr_download, l_scr_rescan;
Global String BROWSER_DEFAULT_HOME, BROWSER_NOCONNECTION;
//END


System.onScriptLoaded ()
{
	initAttribs_Browser();
	
	sg = getScriptGroup();
	normal = sg.getParentLayout();
	dualwnd = sg.getObject("browser.dualwnd");
	g_search = dualwnd.findObject("browser.search");
	g_navurl = dualwnd.findObject("browser.navurl");
	brw = dualwnd.findObject("webbrowser");
	bback = dualwnd.findObject("browser.back");
	bffwd = dualwnd.findObject("browser.fwd");
	bhome = dualwnd.findObject("browser.home");
	bbrowse = g_navurl.findObject("browser.navigate");
	brefresh = dualwnd.findObject("browser.refresh");
	bstop = dualwnd.findObject("browser.stop");
	navurl = g_navurl.findObject("browser.hedit");
	bsearch = g_search.findObject("search.choose");
	blinks = dualwnd.findObject("browser.links");

	browser_search_attrib.onDataChanged();

	searchedit = g_search.getObject("search.edit");
	//BROWSER_DEFAULT_HOME = strleft(getParam() ,System.strsearch(getParam(), "ColorThemes")) + "Plugins\classicPro\engine\homepage\index.htm";
	BROWSER_DEFAULT_HOME = "http://cpro.skinconsortium.com/browser.php";
	BROWSER_NOCONNECTION = strleft(getParam() ,System.strsearch(getParam(), "ColorThemes")) + "Plugins\classicPro\engine\homepage\error.htm";


	//pjn123 EDIT
	g_scr_show = dualwnd.findObject("browser.scraper.group.show");
	g_scr_hide = dualwnd.findObject("browser.scraper.group.hide");
	g_scr_play = dualwnd.findObject("browser.scraper.group.play");
	g_scr_download = dualwnd.findObject("browser.scraper.group.download");
	g_scr_rescan = dualwnd.findObject("browser.scraper.group.rescan");
	l_scr_show = dualwnd.findObject("browser.scraper.lay.show");
	l_scr_hide = dualwnd.findObject("browser.scraper.lay.hide");
	l_scr_play = dualwnd.findObject("browser.scraper.lay.play");
	l_scr_download = dualwnd.findObject("browser.scraper.lay.download");
	l_scr_rescan = dualwnd.findObject("browser.scraper.lay.rescan");
	//END


	scr_open = dualwnd.findObject("browser.scraper.show");
	scr_content = dualwnd.findObject("browser.scraper");
	scr_close = scr_content.findObject("browser.scraper.hide");
	scr_rescan= scr_content.findObject("browser.scraper.rescan");
	scr_play = scr_content.findObject("browser.scraper.play");
	scr_download = scr_content.findObject("browser.scraper.download");
	scr_list = scr_content.findObject("scraper.results");

	navurl.setText(getPrivateString("Winamp Bento", "Browser Home", BROWSER_DEFAULT_HOME));

	internal_LinksTitle = new list;
	internal_LinksUrl = new list;
	internal_LinksSubmenus = new list;

	loadInternalLinks();

	browser_scr_show_attrib.onDataChanged ();
}

System.onScriptUnloading ()
{
	if (browser_scr_show_attrib.getData() == "1") setPrivateInt(getSkinName(), "browser.frame.pos", dualwnd.getPosition());

	delete internal_LinksTitle;
	delete internal_LinksUrl;
	delete internal_LinksSubmenus;
}

//----------------------------------------------------------------------------------------------------------------
// Check if we should display a specific page on set visible (see suicore.maki)
//----------------------------------------------------------------------------------------------------------------

brw.onSetVisible (Boolean onoff)
{
	if (onoff)
	{
		if (getPrivateString(getSkinName(), "UrlXgive", "") != "")
		{
			navurl.setText(getPrivateString(getSkinName(), "UrlXgive", ""));
			browserReload();
			setPrivateString(getSkinName(), "UrlXgive", "");
			DebugStrinG("[browser.m] -> External Loading Completed",0);
			return;
		}
		else if (getPrivateString(getSkinName(), "Browser Open", "") != "")
		{
			navurl.setText(getPrivateString(getSkinName(), "Browser Open", ""));
			browserReload();
			setPrivateString(getSkinName(), "Browser Open", "");
			DebugString("[browser.m] -> Loading Completed",0);
			return;
		}
		browserReload();
		
		if(lyricMode){
			doLyricSearch();
		}
		else if(explorerMode){
			doExplorerSearch();
		}
		else if(foxyMode){
			doFoxySearch();
		}
	}
}


//----------------------------------------------------------------------------------------------------------------
// All direct interaction w/ browser is recieved here.
// The actions are triggered by buttonclicks and suicore.maki.
// actions send to the XUI oject will be send to brw.
//----------------------------------------------------------------------------------------------------------------

sg.onAction (String action, String param, Int x, int y, int p1, int p2, GuiObject source)
{
	brw.onAction (action, param, x, y, p1, p2, source);
}


brw.onAction (String action, String param, Int x, int y, int p1, int p2, GuiObject source)
{
	// Open an URL
	if (strlower(action) == "openurl")
	{
		param = prepareWebString(param, "+");
		navurl.setText(param);
		browserReload();
		return;
	}
	// Websearch
	if (strlower(action) == "search")
	{
		// start!
		if (strlower(param) == "go")
		{
			performWebSearch(searchedit.getText());
		}
		// set text and start!
		else
		{
			isAutomatedSearch = TRUE;
			searchedit.setText(param);
			performWebSearch(param);
			isAutomatedSearch = FALSE;
		}
	}
}

//----------------------------------------------------------------------------------------------------------------
// Browser main controls.
//----------------------------------------------------------------------------------------------------------------

bback.onLeftClick ()
{
	brw.back();
}
bffwd.onLeftClick ()
{
	brw.forward();
}

bbrowse.onLeftClick ()
{
	browserReload();
}

brefresh.onLeftClick ()
{
	browserReload();
}

bstop.onLeftClick ()
{
	brw.stop();
}

bhome.onLeftClick ()
{
	navurl.setText(getPrivateString("Winamp Bento", "Browser Home", BROWSER_DEFAULT_HOME));
	browserReload();
}

// set a custom default home
bhome.onRightButtonUp(int x, int y)
{
	popupmenu editmenu = new popupmenu;
	editmenu.addcommand("Set current Page as default Home",1, 0,0);
	editmenu.addcommand("Restore default Home",2, 0,0);

	int ret = editmenu.popatxy(clientToScreenX(bhome.getLeft()), clientToScreenY(bhome.getTop() + bhome.getHeight()));
	
	if (ret == 1) setPrivateString("Winamp Bento", "Browser Home", navurl.getText());
	if (ret == 2) setPrivateString("Winamp Bento", "Browser Home", BROWSER_DEFAULT_HOME);

	delete editmenu;
	complete;
}

// Windows Vista Compatibility hack. w/ this we get not so much winamp crashes. nevertheless the editbox code must be changed in gen_ff
browserReload()
{
	if (!navurl) return;
	if (!brw) return;
	string t = navurl.getText();
	brw.navigateUrl(t);
}

navurl.onEnter ()
{
	string t = navurl.getText();
	if (isKeyDown(VK_SHIFT)) t = "www." + t + ".com";
	else if (isKeyDown(VK_CONTROL)) t = "www." + t + ".com";
	brw.navigateUrl(t);
}

//----------------------------------------------------------------------------------------------------------------
// Enlarge searcheditbox if we have enough space
//----------------------------------------------------------------------------------------------------------------

sg.onResize (int x, int y, int w, int h)
{
	if (w > 580)
	{
		g_search.show();
		g_search.setXmlParam("x", "-267");
		g_search.setXmlParam("w", "263");
		g_navurl.setXmlParam("x", "134");
		g_navurl.setXmlParam("w", "-403");
	}
	else if (w > 400)
	{
		g_search.show();
		g_search.setXmlParam("x", "-167");
		g_search.setXmlParam("w", "163");
		g_navurl.setXmlParam("x", "134");
		g_navurl.setXmlParam("w", "-303");
	}
	else 
	{
		g_search.hide();
		g_navurl.setXmlParam("x", "134");
		g_navurl.setXmlParam("w", "-140");
	}
	
	//pjn123 EDIT
	if(h<20){
		 navurl.hide();
		 searchedit.hide();
	}
	else{
		navurl.show();
		if(!lyricMode && !explorerMode && !foxyMode) searchedit.show();
	}
	
	if(h<dualwnd.getPosition()+50){
		dualwnd.setPosition(26);
	}
	//END
}


//----------------------------------------------------------------------------------------------------------------
// Web Search
//----------------------------------------------------------------------------------------------------------------

searchedit.onEnter ()
{
	performWebSearch(getText());
}

performWebSearch (string searchstring)
{
	if (strlower(searchstring) == "")
	{
		return;
	}
	
	// check what the current websearch is
	if (browser_search_attrib.getData() == "Modern Skins") 
		searchstring = "http://www.winamp.com/skins/search/?s=m&q=" + prepareWebString(searchstring, "+");

	else if (browser_search_attrib.getData() == "Classic Skins") 
		searchstring = "http://www.winamp.com/skins/search/?s=c&q=" + prepareWebString(searchstring, "+");

	else if (browser_search_attrib.getData() == "Plugins") 
		searchstring = "http://www.winamp.com/plugins/search/?q=" + prepareWebString(searchstring, "+");

	else if (browser_search_attrib.getData() == "Videos") 
		searchstring = "http://www.winamp.com/media/video-search/?q=" + prepareWebString(searchstring, "+");

	else if (browser_search_attrib.getData() == "Music") 
		searchstring = "http://www.winamp.com/media/music-search/?q=" + prepareWebString(searchstring, "+");

	else if (browser_search_attrib.getData() == "Web Search") 
	{
		if (isAutomatedSearch)
		{
			searchstring = "http://slirsredirect.search.aol.com/redirector/sredir?sredir=1841&invocationType=en00-winamp-55--as&query=" + prepareWebString(searchstring, "+");
		}
		else
		{
			searchstring = "http://slirsredirect.search.aol.com/redirector/sredir?sredir=1840&invocationType=en00-winamp-55--ws&query=" + prepareWebString(searchstring, "+");
		}
	}

	else if (browser_search_attrib.getData() == "AOL Music Search") 
		searchstring = "http://search.music.aol.com/search/" + prepareWebString(searchstring, "+");

	else if (browser_search_attrib.getData() == "AOL Tickets") 
		searchstring = "http://tickets.aol.com/search.adp?brand=aolboxoffice&query=" + prepareWebString(searchstring, "+");

	else if (browser_search_attrib.getData() == "Pollstar") 
		searchstring = "http://www.pollstar.com/tour/searchall.pl?By=All&Content=" + prepareWebString(searchstring, "+");

	else if (browser_search_attrib.getData() == "Truveo Video Search") 
		searchstring = "http://www.truveo.com/?method=truveo.videos.getVideos&query=" + prepareWebString(searchstring, "+");

	else if (browser_search_attrib.getData() == "Bandsintown") 
		searchstring = "http://www.bandsintown.com/" + prepareWebString(searchstring, "");

	else if (browser_search_attrib.getData() == "Live Nation") 
		searchstring = "http://www.livenation.com/search/intermediateSearch/searchstring/" + prepareWebString(searchstring, "+");

	else if (browser_search_attrib.getData() == "JamBase") 
		searchstring = "http://www.jambase.com/search.asp?band=" + prepareWebString(searchstring, "+");

	else if (browser_search_attrib.getData() == "OnTour") 
		searchstring = "http://www.ontour.net/Search.aspx?v=12484&t=1&st=" + prepareWebString(searchstring, "%20");

	else if (browser_search_attrib.getData() == "Wikipedia Search") 
		searchstring = "http://en.wikipedia.org/wiki/Special:Search?search=" + prepareWebString(searchstring, "+") + "&go=Go";

	else if (browser_search_attrib.getData() == "Lyric Search") 
		searchstring = "http://www.google.com";

	else if (browser_search_attrib.getData() == "Explorer Search") 
		searchstring = "http://www.google.com";

	else if (browser_search_attrib.getData() == "Artist Search on www.FoxyTunes.com") 
		searchstring = "http://www.google.com";

	else //let's do the aol search :)
		searchstring = "http://search.aol.com/aol/search?query=" + prepareWebString(searchstring, "+");

	navurl.setText(searchstring);
	browserReload();
}

// Set the button image according to the current websearch
browser_search_attrib.onDataChanged ()
{
	lyricMode=false;
	explorerMode=false;
	foxyMode=false;
	
	if (getData() == "AOL Music Search") 
	{
		bsearch.setXmlParam("image", "browser.button.search.aol.normal");
	}
	else if (getData() == "AOL Tickets") bsearch.setXmlParam("image", "browser.button.search.aol.normal");
	else if (getData() == "Truveo Video Search") bsearch.setXmlParam("image", "browser.button.search.truveo.normal");
	else if (getData() == "Bandsintown") bsearch.setXmlParam("image", "browser.button.search.bit.normal");
	else if (getData() == "JamBase") bsearch.setXmlParam("image", "browser.button.search.jambase.normal");
	else if (getData() == "OnTour") bsearch.setXmlParam("image", "browser.button.search.ontour.normal");
	else if (getData() == "Web Search") bsearch.setXmlParam("image", "browser.button.search.google.normal");
	else if (getData() == "Live Nation") bsearch.setXmlParam("image", "browser.button.search.ln.normal");
	else if (getData() == "Pollstar") bsearch.setXmlParam("image", "browser.button.search.pollstar.normal");
	else if (getData() == "Wikipedia Search") bsearch.setXmlParam("image", "browser.button.search.wiki.normal");
	else if (getData() == "Lyric Search"){
		bsearch.setXmlParam("image", "browser.button.search.lyric.normal");
		lyricMode=true;
		doLyricSearch();
	}
	else if (getData() == "Explorer Search"){
		bsearch.setXmlParam("image", "browser.button.search.explorer.normal");
		explorerMode=true;
		doExplorerSearch();
	}
	else if (getData() == "Artist Search on www.FoxyTunes.com"){
		bsearch.setXmlParam("image", "browser.button.search.foxy.normal");
		foxyMode=true;
		doFoxySearch();
	}
	else bsearch.setXmlParam("image", "browser.button.search.winamp.normal");

	if (brw.isVisible() && !lyricMode && !explorerMode && !foxyMode)
	{
		performWebSearch(searchedit.getText());
		searchedit.show();
	}
	
	//pjn123 edit
	if (brw.isVisible() && lyricMode){
		doLyricSearch();
		searchedit.hide();
	}
	
	//pjn123 edit
	if (brw.isVisible() && explorerMode){
		doExplorerSearch();
		searchedit.hide();
	}

	//pjn123 edit
	if (brw.isVisible() && foxyMode){
		doFoxySearch();
		searchedit.hide();
	}
}

// Show the Menu to choose a web search
bsearch.onLeftClick ()
{
	AttribMenu searchlist = createMenufromAttribList (SearchAttributeList);

	int ret = searchlist.popatxy(clientToScreenX(bsearch.getLeft()), clientToScreenY(bsearch.getTop() + bsearch.getHeight()));
	if (ret >= 0) 
	{
		configAttribute temp = SearchAttributeList.enumItem(ret);
		temp.setData("1");
	}

	delete searchlist;
	complete;
}

// This is the main function to create a menu out of configattributes
// Better leave this function as it is.
createMenufromAttribList (list entries)
{
	//Boolean dummy = 0;
	int mydummy =0;
	ConfigAttribute temp;
	ConfigItem root = entries.enumItem(0);
	PopUpMenu _menu;
	list submenus, subroots;
	submenus = new list;
	submenus.removeAll();
	subroots = new list;
	subroots.removeAll();
	_menu = new PopUpMenu;
	for ( int i = 1; i < entries.getNumItems(); i++ )
	{
		temp = entries.enumItem(i);
		configItem parent = temp.getParentItem();
		if (parent == root)
		{
			_menu.addCommand (
				temp.getAttributeName(),
				i,
				temp.getData() == "1",
				0
			);		
		}
		else
		{
			popupmenu submenu;
			boolean gotit = FALSE;
			for ( int j = 0; j < submenus.getNumItems(); j++ )
			{
				if (subroots.enumItem(j) == parent)
				{
					submenu = submenus.enumItem(j);
					submenus.removeItem(j);
					gotit = TRUE;
				}
			}
			if (gotit == FALSE)
			{
				subroots.addItem(parent);
				submenu = new popupmenu;
			}
			submenu.addCommand (
				temp.getAttributeName(),
				i,
				temp.getData() == "1",
				0
			);
			submenus.addItem(submenu);
		}
	}
	for ( int i = 0; i < submenus.getNumItems(); i++ )
	{
		if (mydummy==0){
			_menu.addSubMenu(submenus.enumItem(i), "Concert Search"); //TODO ci.getName();
			mydummy++;
		}
		else if(mydummy == 1){
			_menu.addSubMenu(submenus.enumItem(i), "Winamp.com Search"); //TODO ci.getName();
			mydummy++;
		}
		else if(mydummy == 2){
			_menu.addSubMenu(submenus.enumItem(i), "Auto Search playing file"); //TODO ci.getName();
			mydummy++;
		}
	}
	delete submenus;
	delete subroots;

	return _menu;
}

// perpare a webstring out of the searchedit input
// %artist% and %album% are special inputs and will be rendered
// " " will be replaced for browser compatability
string prepareWebString (string url, string replace)
{
	string artist = getPlayItemMetaDataString("artist");
	string album = getPlayItemMetaDataString("album");

	if (artist == "") artist = getPlayitemString();
	if (album == "") album = getPlayitemString();

	url = strReplace(url, "%artist%", artist);
	url = strReplace(url, "%album%", album);
	url = strReplace(url, " ", replace);

	return url;
}

// a basic function to replace a substring inside a string
string strReplace(string str, string replace, string by)
{
	int pos;
	int len = strlen(replace);
	while (pos = strsearch(str, replace) > -1)
	{
		string str_ = "";
		String _str = "";

		if (pos > 0) str_ = strleft(str, pos);
		
		pos = strlen(str)-pos-len;
		if (pos > 0) _str = strright(str, pos);

		str = str_ + by + _str;
	}
	return str;
}


//----------------------------------------------------------------------------------------------------------------
// Quick Links
//----------------------------------------------------------------------------------------------------------------

Function storeInternalLink(string name, string url);

storeInternalLink (string name, string url)
{
	internal_LinksTitle.addItem(name);
	internal_LinksUrl.addItem(url);
	
}

// add [[beontop]TRUE] to get the menu before all other menus
loadInternalLinks ()
{
	// Internal Subemus
	internal_LinksSubmenus.addItem("[[beontop]TRUE]Help and Support"); // [[submenu]1]
	internal_LinksSubmenus.addItem("MP3 Music Blogs"); // [[submenu]2]
	internal_LinksSubmenus.addItem("Special Offers"); // [[submenu]3]

	// Internal Quick Links - main view
//	storeInternalLink ("[[beontop]TRUE]Report a Bug", "http://beta.aol.com/projects.php?project=winamp&loc=bugreport"); // Delete in final
	storeInternalLink ("Winamp", "http://www.winamp.com");
	storeInternalLink ("SHOUTcast", "http://www.shoutcast.com");
	storeInternalLink ("AOL Music", "http://music.aol.com");
	storeInternalLink ("Spinner", "http://www.spinner.com/category/mp3-of-the-day/");

	// Internal Quick links - help & support
	storeInternalLink ("[[submenu]1]Winamp Help", "http://www.winamp.com/support/help/50/");
	storeInternalLink ("[[submenu]1]Winamp Forums", "http://forums.winamp.com/");
	storeInternalLink ("[[submenu]1]Upgrade to Winamp Pro", "http://www.winamp.com/buy");

	// Internal Quick links - MP3 Music blogs
	//storeInternalLink ("[[submenu]2]Idolator", "http://www.idolator.com/tunes/mp3");
	storeInternalLink ("[[submenu]2]You Ain't No Picasso", "http://youaintnopicasso.com/");
	storeInternalLink ("[[submenu]2]Aurgasm", "http://aurgasm.us");
	storeInternalLink ("[[submenu]2]An Aquarium Drunkard", "http://www.aquariumdrunkard.com/");

	storeInternalLink ("[[submenu]2]Spinner", "http://www.spinner.com/category/mp3-of-the-day/");
	storeInternalLink ("[[submenu]2]elbo.ws", "http://elbo.ws/");
	storeInternalLink ("[[submenu]2]fluxblog", "http://www.fluxblog.org/");
	storeInternalLink ("[[submenu]2]Music For Robots", "http://music.for-robots.com/");
	storeInternalLink ("[[submenu]2]Gorilla vs Bear", "http://gorillavsbear.blogspot.com/");
	storeInternalLink ("[[submenu]2]fingertips", "http://fingertipsmusic.blogspot.com/");
	storeInternalLink ("[[submenu]2]soul sides", "http://soul-sides.com/");
	storeInternalLink ("[[submenu]2]Said the Gramphone", "http://www.saidthegramophone.com/");
	storeInternalLink ("[[submenu]2]Product Shop NYC", "http://www.productshopnyc.com/htdocs/");
	storeInternalLink ("[[submenu]2]scissorkick" , "http://scissorkick.com/");
	storeInternalLink ("[[submenu]2]brooklynvegan", "http://brooklynvegan.com/");
	storeInternalLink ("[[submenu]2]blogotheque", "http://www.blogotheque.net/");
	storeInternalLink ("[[submenu]2]stereogum", "http://www.stereogum.com/");
	storeInternalLink ("[[submenu]2]pretty much amazing", "http://prettymuchamazing.com/");
	storeInternalLink ("[[submenu]2]My Old Kentucky Blog", "http://myoldkyhome.blogspot.com/");
	//storeInternalLink ("[[submenu]2]the tofu hut", "http://tofuhut.blogspot.com/");
	storeInternalLink ("[[submenu]2]MP3 4U", "http://mp34u.muzic.com/");
	//storeInternalLink ("[[submenu]2]indie kids", "http://www.indiekids.org/");
	storeInternalLink ("[[submenu]2]3hive", "http://www.3hive.com/");
	storeInternalLink ("[[submenu]2]moistworks", "http://www.moistworks.com/"); 
	storeInternalLink ("[[submenu]2]Each Note Secure", "http://www.eachnotesecure.com/");
	storeInternalLink ("[[submenu]2]swedelife", "http://www.swedelife.com/"); 
	storeInternalLink ("[[submenu]2]Sonic X", "http://www.sonicx.com/");
	storeInternalLink ("[[submenu]2]mfiles", "http://www.mfiles.co.uk/mp3-files.htm");
	storeInternalLink ("[[submenu]2]The Hype Machine", "http://www.hypem.com");
	
	// Internal quick Links - Special Offers
	storeInternalLink ("[[submenu]3]eMusic 50 Free MP3s", "http://www.emusic.com/promo/win/index.html?fref=3D150599");
	storeInternalLink ("[[submenu]3]Get BONUS Ringtones!", "http://offers.thumbplay.com/offers/212/los?ptrx=winamp&iframe=true&thpcid=15000_ringtones&thpcampid=bookmrk");
}

// used to get the name of the quicklink and store it in a new subfolder
Function string convertQuickLinkTempName (string name, int subfolder);
string convertQuickLinkTempName (string name, int subfolder)
{
	if (strleft(name, 10) == "[[submenu]")
	{
		name = strright(name, strlen(name) - 10);
		name = getToken(name, "]", 1);
	}
	if (subfolder > 0)
	{
		name = "[[submenu]" + integerToString(subfolder) + "]" + name;
	}
	return name;	
}

// returns  the current subfolder, zero if it is in root
Function getSubFolderNum(string name);
int getSubFolderNum (string name)
{
	if (strleft(name, 10) == "[[submenu]")
	{
		name = strright(name, strlen(name) - 10);
		return stringToInteger(getToken(name, "]", 0));
	}
	else
	{
		return 0;
	}	
}

// if "blabla" is a subfolder, this function will return what subfolder num it has. -1 is returned for no success
Function getSubFolderNameToNum(string name);
int getSubFolderNameToNum (string name)
{
	int subItems = getPrivateInt("Winamp Browser QuickLinks SubMenus", "numItems", 0);

	for ( int i = 1; i <= subItems; i++ )
	{
		if (getPrivateString("Winamp Browser QuickLinks SubMenus", "itemText_" + integerToString(i), "ERROR") == name) return i;
	}
	return -1;
}

Function PopupMenu createCustomMenu (boolean wantAdd, int startVal);
Function showQLEdit(int item);
Global Boolean ql_edit_visible;
Global Int editItemNum;

Global Button edit_ok;
global edit qlname, qlurl;
global dropdownlist qlparent;

// Show the Quicklink Edit Box. also used to create a new quick link item
showQLEdit (int item)
{
	editItemNum = item;
	ql_edit_visible = 1;
	quicklink_name = newDynamicContainer("browser.quicklink.edit.dialog2");
	if (!quicklink_name) return;
	quicklink_name_layout = quicklink_name.getLayout("normal");
	if (!quicklink_name_layout) return;

	qlname = quicklink_name_layout.findObject("edit.name");
	qlurl = quicklink_name_layout.findObject("edit.url");
	qlparent = quicklink_name_layout.findObject("edit.parent");

	// predefined entry in subfolder selection
	qlparent.addItem("* root");
	qlparent.setXmlParam("select", "* root");

	int subItems = getPrivateInt("Winamp Browser QuickLinks SubMenus", "numItems", 0);

	// load all existing subfolders
	for ( int i = 1; i <= subItems; i++ )
	{
		qlparent.addItem(getPrivateString("Winamp Browser QuickLinks SubMenus", "itemText_" + integerToString(i), "ERROR"));
		if ( (item + 1000) * (-1) == i ) qlparent.setXmlParam("select", getPrivateString("Winamp Browser QuickLinks SubMenus", "itemText_" + integerToString(i), "ERROR"));
	}

	// standard text for a new folder
	qlparent.addItem("[new subfolder]");

	edit_ok = quicklink_name_layout.findObject("return.values");

	// check if we should edit a quick link...
	if (item > 0)
	{
		string name = getPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(item), "ERROR");
		int sf = getSubFolderNum(name);
		if (sf > 0)
		{
			qlparent.setXmlParam("select", getPrivateString("Winamp Browser QuickLinks SubMenus", "itemText_" + integerToString(sf), "ERROR"));
		}
		qlname.setText(convertQuickLinkTempName(name, 0));
		qlurl.setText(getPrivateString("Winamp Browser QuickLinks", "itemLink_" + integerToString(item), "ERROR"));
	}
	// ...or create a new one
	else
	{
		editItemNum += 1000;
		editItemNum *= -1;
		qlurl.setText(navurl.getText());
		qlname.setText(brw.getDocumentTitle());
		editItemNum = 0;
	}

	// show the window
	quicklink_name_layout.center();
	quicklink_name_layout.show();
	quicklink_name_layout.setfocus();
}

// Yay, OK has clicked - let's save the quick link
edit_ok.onLeftClick ()
{
	if (qlname.getText() == "")
	{
		qlname.setText("Please enter a name for your Quicklink!");
		return;
	}
	if (qlurl.getText() == "")
	{
		qlurl.setText("Please enter an URL for your Quicklink!");
		return;
	}

	// If we store a new quicklink let's insert it in the end of the list.
	if (editItemNum == 0) 
	{
		editItemNum = getPrivateInt("Winamp Browser QuickLinks", "numItems", -1) + 1;
		setPrivateInt("Winamp Browser QuickLinks", "numItems", editItemNum);
	}
	edit e = qlparent.findObject("combobox.edit");
	string sel = e.getText();

	//store as root item
	if (sel == "* root")
	{
		setPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(editItemNum), qlname.getText());
	}
	// store in a subfolder
	else
	{
		int i = getSubFolderNameToNum (sel);
		// store in a existing subfolder
		if (i > 0)
		{
			setPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(editItemNum), "[[submenu]" + integerToString(i) + "]" + qlname.getText());
		}
		// store in a new subfolder
		else
		{
			int subitems = getPrivateInt("Winamp Browser QuickLinks SubMenus", "numItems", 0);
			setPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(editItemNum), "[[submenu]" + integerToString(subitems + 1) + "]" + qlname.getText());
			
			setPrivateInt("Winamp Browser QuickLinks SubMenus", "numItems", subitems + 1);
			setPrivateString("Winamp Browser QuickLinks SubMenus", "itemText_" + integerToString(subitems + 1), sel);
		}		
	}
	// save link and close window
	setPrivateString("Winamp Browser QuickLinks", "itemLink_" + integerToString(editItemNum), qlurl.getText());
	quicklink_name_layout.hide(); 
}


Function showSMEdit(int item);
Global Boolean sm_edit_visible;
Global Int smEditItemNum;
Global Layout submenu_name_layout;
Global Container submenu_name;

Global Button sm_edit_ok;
global edit smname;

// Show Sub Menu Editbox
showSMEdit (int item)
{
	item += 20000;
	item *= -1;
	smEditItemNum = item;
	sm_edit_visible = 1;
	submenu_name = newDynamicContainer("browser.submenu.edit2");
	if (!submenu_name) return;
	submenu_name_layout = submenu_name.getLayout("normal");
	if (!submenu_name_layout) return;

	smname = submenu_name_layout.findObject("edit.name");
	sm_Edit_ok = submenu_name_layout.findObject("return.values");

	// load submenu text, if we edit
	if (smEditItemNum)
	{
		smname.setText(getPrivateString("Winamp Browser QuickLinks SubMenus", "itemText_" + integerToString(smEditItemNum), "ERROR"));
	}

	submenu_name_layout.center();
	submenu_name_layout.show();
	submenu_name_layout.setfocus();
}

sm_edit_ok.onLeftClick ()
{
	if (smname.getText() == "")
	{
		smname.setText("Please enter a Subfolder name!");
		return;
	}
	
	// is this a new submenu?
	if (smEditItemNum == 0) 
	{
		smEditItemNum = getPrivateInt("Winamp Browser QuickLinks SubMenus", "numItems", 0);
		smEditItemNum++;
		setPrivateInt("Winamp Browser QuickLinks SubMenus", "numItems", smEditItemNum);
	}
	setPrivateString("Winamp Browser QuickLinks SubMenus", "itemText_" + integerToString(smEditItemNum), smname.getText());
	submenu_name_layout.hide(); 
}


// Is one of the edit windows closed?
system.onHideLayout (Layout _layout)
{
	if (_layout == quicklink_name_layout) 
	{
		ql_edit_visible = 0;
		return;
	}
	else if (_layout == submenu_name_layout) 
	{
		sm_edit_visible = 0;
	}
}

/* Hey, someone has clicked on the quicklinks button.
   we will show a menu and return the users descision as int.
   Here is the range what is done for what return value
	]oo;-40000]	delete subfolder: abs(ret += 20000)
	]-40000;-20000]	edit submenu: abs(ret += 20000)
	]-20000;-1000]	add quicklink in subfolder: abs(ret += 1000)
	[1;10000[	browse quicklink: ret
	[10000;20000[	edit quicklink: ret -= 10000
	[20000;30000[	delete quicklink
	[40000;oo[	browse internal quicklink: ret -= 40000
*/

blinks.onLeftClick ()
{
	popupmenu quicklinks = new popupmenu;

	quicklinks = createCustomMenu (1 , 0);

	int ret = quicklinks.popatxy(clientToScreenX(blinks.getLeft()), clientToScreenY(blinks.getTop() + blinks.getHeight()));
	
	delete quicklinks;

	// see above
	if (ret <= -1000 && ret > -20000) showQLEdit(ret);
	if (ret <= -20000 && ret > -40000) showSMEdit(ret);
	if (ret <= -40000)
	{
		ret += 40000;
		ret *= -1;
		int answer = messageBox ("Do You really want to delete this Subfolder?\nAll Quick Links stored in this folderwill be\ntransfered to the root of the menu!", "Confirmation" , 4, "");
		if (answer = 4)
		{
			int Subitems = getPrivateInt("Winamp Browser QuickLinks Submenus", "numItems", -1);
			int items = getPrivateInt("Winamp Browser QuickLinks", "numItems", -1);

			setPrivateInt("Winamp Browser QuickLinks Submenus", "numItems", Subitems - 1);

			for ( int i = ret; i <= Subitems; i++ )
			{
				string set = getPrivateString("Winamp Browser QuickLinks Submenus", "itemText_" + integerToString(i+1), "ERROR");
				setPrivateString("Winamp Browser QuickLinks Submenus", "itemText_" + integerToString(i), set);
				string vv = "[[submenu]" + integerToString(i) + "]";
				for ( int ii = 1; ii <= items; ii++ )
				{
					string v = getPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(ii), "ERROR");
					if (strleft (v, strlen(vv)) == vv)
					{
						v = strright(v, strlen(v) - strlen(vv));
						if (i == ret)
						{								
							setPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(ii), v);
						}
						else
						{
							v = "[[submenu]" + integerToString(i-1) + "]" + v;
							setPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(ii), v);
							
						}
					}						
				}
			}			
		}
		return;
	}

	if (ret <= 0) return;

	int items = getPrivateInt("Winamp Browser QuickLinks", "numItems", -1);

	if (ret > items) 
	{
		if (ret > 10000 && ret < 20000) showQLEdit(ret - 10000);
		else if (ret > 20000 && ret < 30000) 
		{
			ret -= 20000;
			int answer = messageBox ("Do You really want to delete this Quick Link?", "Confirmation" , 4, "");
			if (answer == 4)
			{
				int items = getPrivateInt("Winamp Browser QuickLinks", "numItems", -1);

				setPrivateInt("Winamp Browser QuickLinks", "numItems", items - 1);

				for ( int i = ret; i <= items; i++ )
				{
					string set = getPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(i+1), "ERROR");
					setPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(i), set);
					set = getPrivateString("Winamp Browser QuickLinks", "itemLink_" + integerToString(i+1), "ERROR");
					setPrivateString("Winamp Browser QuickLinks", "itemLink_" + integerToString(i), set);
				}				
			}
		}
		else if (ret >= 40000)
		{
			navurl.setText (internal_LinksURL.enumItem(ret-40000));
			browserReload();
		}
		return;
	}			
	else if (ret > 0 && ret <= items) 
	{
		navurl.setText (getPrivateString("Winamp Browser QuickLinks", "itemLink_" + integerToString(ret), "ERROR"));
		browserReload();
	}

	complete;
}

createCustomMenu (boolean wantAdd, int startVal)
{
	popupmenu _menu = new popupmenu;

	int subItems = getPrivateInt("Winamp Browser QuickLinks SubMenus", "numItems", 0);
	int items = getPrivateInt("Winamp Browser QuickLinks", "numItems", 0);
	int int_subItems = internal_LinksSubmenus.getNumItems();
	int int_items = internal_LinksTitle.getNumItems();

	/** load top SubMenus */
	for ( int i = 0; i < int_items; i++ )
	{
		string v = internal_LinksTitle.enumItem(i);
		if (strleft(v, strlen("[[beontop]TRUE]")) == "[[beontop]TRUE]")
		{
			v = strright(v, strlen(v) - strlen("[[beontop]TRUE]"));
			if (strleft(v, 10) != "[[submenu]")
			{
				_menu.addCommand (
					v,
					40000 + i,
					0,
					0
				);
			}
		}
	}
	for ( int i = 0; i < int_subItems ; i++ )
	{
		if (strleft(internal_LinksSubmenus.enumItem(i), strlen("[[beontop]TRUE]")) == "[[beontop]TRUE]")
		{
			popupmenu _sub = new popupmenu;
			for ( int ii = 0; ii < int_items; ii++ )
			{
				string v = internal_LinksTitle.enumItem(ii);
				string vv = "[[submenu]" + integerToString(i+1) + "]";
				if (strleft (v, strlen(vv)) == vv)
				{
					v = strright(v, strlen(v) - strlen(vv));
					_sub.addCommand (v, 40000 + ii, 0, 0);
				}
			}
			if (_sub.getNumCommands() < 1) _sub.addCommand ("No Quick Links Stored", 0, 0, 1);
			string tmp = internal_LinksSubmenus.enumItem(i);
			_menu.AddSubMenu (_sub, strright(tmp, strlen(tmp) - strlen("[[beontop]TRUE]")));
		}
	
	}

	if (_menu.getNumCommands() > 0) _menu.addSeparator();

	if (wantAdd == 1)
	{
		popupmenu editsub = new popupmenu;
		
		/** Edit Quick links */
		
		popupmenu editmenu = new popupmenu;

		if (subItems > 0)
		{
			for ( int i = 1; i <= subItems; i++ )
			{
				string vv = "[[submenu]" + integerToString(i) + "]";
				popupmenu _sub = new popupmenu;
				for ( int ii = 1; ii <= items; ii++ )
				{
					string v = getPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(ii), "ERROR");
					if (strleft (v, strlen(vv)) == vv)
					{
						v = strright(v, strlen(v) - strlen(vv));
						_sub.addCommand (v, 10000 + ii, 0, 0);
					}
				}
				if (_sub.getNumCommands() < 1) _sub.addCommand ("No Quick Links Stored", 0, 0, 1);
				editmenu.AddSubMenu (_sub, getPrivateString("Winamp Browser QuickLinks SubMenus", "itemText_" + integerToString(i), "ERROR"));
			}
		}

		for ( int i = 1; i <= items; i++ )
		{
			string v = getPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(i), "ERROR");
			if (strleft(v, 10) != "[[submenu]")
			{
				editmenu.addCommand (
					v,
					10000 + i,
					0,
					0
				);
			}
		}

		if (editmenu.getNumCommands() < 1) editmenu.addCommand ("No Quick Links Stored", 0, 0, 1);

		editsub.addSubMenu (editmenu, "Edit Quick Link");

		/** Delete SubMenus */

		popupmenu editmenu2 = new popupmenu;

		if (subItems > 0)
		{
			for ( int i = 1; i <= subItems; i++ )
			{
				popupmenu _sub = new popupmenu;
				for ( int ii = 1; ii <= items; ii++ )
				{
					string v = getPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(ii), "ERROR");
					string vv = "[[submenu]" + integerToString(i) + "]";
					if (strleft (v, strlen(vv)) == vv)
					{
						v = strright(v, strlen(v) - strlen(vv));
						_sub.addCommand (v, 20000 + ii, 0, 0);
					}
				}
				if (_sub.getNumCommands() < 1) _sub.addCommand ("No Quick Links Stored", 0, 0, 1);
				editmenu2.AddSubMenu (_sub, getPrivateString("Winamp Browser QuickLinks SubMenus", "itemText_" + integerToString(i), "ERROR"));
			}
		}

		for ( int i = 1; i <= items; i++ )
		{
			string v = getPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(i), "ERROR");
			if (strleft(v, 10) != "[[submenu]")
			{
				
				editmenu2.addCommand (
					v,
					20000 + i,
					0,
					0
				);
			}
		}

		if (editmenu2.getNumCommands() < 1) editmenu2.addCommand ("No Quick Links Stored", 0, 0, 1);
		editsub.addSubMenu (editmenu2, "Delete Quick Link");
		editsub.addSeparator();

		/** Edit SubMenus */
		
		popupmenu editmenu3 = new popupmenu;

		for ( int i = 1; i <= subItems; i++ )
		{
			editmenu3.addCommand (
				getPrivateString("Winamp Browser QuickLinks SubMenus", "itemText_" + integerToString(i), "ERROR"),
				-20000 - i,
				0,
				0
			);
		}
		if (editmenu3.getNumCommands() < 1) editmenu3.addCommand ("No Subfolders Stored", 0, 0, 1);
		editsub.addSubMenu (editmenu3, "Edit Subfolder");


		/** Delete SubMenus */
		
		popupmenu editmenu4 = new popupmenu;

		for ( int i = 1; i <= subItems; i++ )
		{
			editmenu4.addCommand (
				getPrivateString("Winamp Browser QuickLinks SubMenus", "itemText_" + integerToString(i), "ERROR"),
				-40000 - i,
				0,
				0
			);
		}
		if (editmenu4.getNumCommands() < 1) editmenu4.addCommand ("No Subfolders Stored", 0, 0, 1);
		editsub.addSubMenu (editmenu4, "Delete Subfolder");

		_menu.addSubMenu (editsub, "Manage Quick Links");
		_menu.addSeparator();

	}

	if (wantAdd == 1)
	{
		_menu.addCommand ("<Add new Subfolder>", -20000, 0, 0);
		_menu.addCommand ("<Add current Page>",	-1000, 0, 0);
		_menu.addSeparator();
	}	

	/** load SubMenus */
	for ( int i = 0; i < int_subItems ; i++ )
	{
		if (strleft(internal_LinksSubmenus.enumItem(i), strlen("[[beontop]TRUE]")) != "[[beontop]TRUE]")
		{
			popupmenu _sub = new popupmenu;
			for ( int ii = 0; ii < int_items; ii++ )
			{
				string v = internal_LinksTitle.enumItem(ii);
				string vv = "[[submenu]" + integerToString(i+1) + "]";
				if (strleft (v, strlen(vv)) == vv)
				{
					v = strright(v, strlen(v) - strlen(vv));
					_sub.addCommand (v, 40000 + ii, 0, 0);
				}
			}
			if (_sub.getNumCommands() < 1) _sub.addCommand ("No Quick Links Stored", 0, 0, 1);
			_menu.AddSubMenu (_sub, internal_LinksSubmenus.enumItem(i));
		}
	
	}

	if (subItems > 0)
	{		
		for ( int i = 1; i <= subItems; i++ )
		{
			popupmenu _sub = new popupmenu;
			if (wantAdd == 1) _sub.addCommand ("<Add current Page>",	-1000 - i, 0, 0);
			_sub.addSeparator();
			for ( int ii = 1; ii <= items; ii++ )
			{
				string v = getPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(ii), "ERROR");
				string vv = "[[submenu]" + integerToString(i) + "]";
				if (strleft (v, strlen(vv)) == vv)
				{
					v = strright(v, strlen(v) - strlen(vv));
					_sub.addCommand (v, startVal + ii, 0, 0);
				}
			}
			if (_sub.getNumCommands() < 3) _sub.addCommand ("No Quick Links Stored", 0, 0, 1);
			_menu.AddSubMenu (_sub, getPrivateString("Winamp Browser QuickLinks SubMenus", "itemText_" + integerToString(i), "ERROR"));
		}
	}
 
	// load internal entries
	for ( int i = 0; i < int_items; i++ )
	{
		string v = internal_LinksTitle.enumItem(i);
		if (strleft(v, strlen("[[beontop]TRUE]")) != "[[beontop]TRUE]")
		{
			if (strleft(v, 10) != "[[submenu]")
			{
				_menu.addCommand (
					v,
					40000 + i,
					0,
					0
				);
			}
		}
	}

	for ( int i = 1; i <= items; i++ )
	{
		string v = getPrivateString("Winamp Browser QuickLinks", "itemText_" + integerToString(i), "ERROR");
		if (strleft(v, 10) != "[[submenu]")
		{
			_menu.addCommand (
				v,
				startVal + i,
				0,
				0
			);
		}
	}
	if (_menu.getNumCommands() < 6) _menu.addCommand ("No Quick Links Stored", 0, 0, 1);
	return _menu;
	
}


//----------------------------------------------------------------------------------------------------------------
// Site Scraper
//----------------------------------------------------------------------------------------------------------------

// scrape everytime the document does change and change navurl text
brw.onDocumentComplete (String url)
{
	if (navurl.gettext() != url && url != "about:blank") navurl.setText(url);
	if (scr_list)
	{
		scr_list.deleteAllItems();
		brw.scrape();
	}
	
	if(brw.getDocumentTitle()=="Cannot find server"){
		brw.navigateUrl(BROWSER_NOCONNECTION);
	}
}


// Handles for wasabi:farme: show, hide, resize
scr_open.onLeftClick ()
{
	browser_scr_show_attrib.setData("1");
}

scr_close.onLeftClick ()
{
	browser_scr_show_attrib.setData("0");
}

Global Boolean nocallback;
browser_scr_show_attrib.onDataChanged ()
{
	if (brw == NULL || nocallback) return;
	if (getData() == "1")
	{
		//pjn123 EDIT
		/*scr_close.show();
		scr_open.hide();
		scr_download.show();
		scr_play.show();
		scr_rescan.show();*/
		g_scr_hide.show();
		g_scr_show.hide();
		g_scr_play.show();
		g_scr_download.show();
		g_scr_rescan.show();
		//END

		dualwnd.setPosition(getPrivateInt(getSkinName(), "browser.frame.pos", 100));
	}
	else
	{
		//pjn123 EDIT
		/*scr_close.hide();
		scr_open.show();
		scr_download.hide();
		scr_play.hide();
		scr_rescan.hide();*/
		g_scr_hide.hide();
		g_scr_show.show();
		g_scr_play.hide();
		g_scr_download.hide();
		g_scr_rescan.hide();
		//END
		
		if (dualwnd.getPosition() > 26) setPrivateInt(getSkinName(), "browser.frame.pos", dualwnd.getPosition());
		dualwnd.setPosition(26);
	}
}

scr_content.onResize (int x, int y, int w, int h)
{
		g_scr_hide.setXmlParam("x", "-"+integerToString(g_scr_hide.getWidth()));
		g_scr_show.setXmlParam("x", "-"+integerToString(g_scr_show.getWidth()));
		g_scr_rescan.setXmlParam("x", "-"+integerToString(g_scr_hide.getWidth()+g_scr_rescan.getWidth()+5));
		g_scr_download.setXmlParam("x", "-"+integerToString(g_scr_hide.getWidth()+g_scr_rescan.getWidth()+g_scr_download.getWidth()+10));
		g_scr_play.setXmlParam("x", "-"+integerToString(g_scr_hide.getWidth()+g_scr_rescan.getWidth()+g_scr_download.getWidth()+g_scr_play.getWidth()+15));


	nocallback = TRUE;
	if (dualwnd.getPosition() <= 26)
	{
		browser_scr_show_attrib.setData("0");
		dualwnd.setPosition(26);
		scr_content.show();

		//pjn123 EDIT
		/*scr_close.hide();
		scr_open.show();
		scr_download.hide();
		scr_play.hide();
		scr_rescan.hide();*/
		g_scr_hide.hide();
		g_scr_show.show();
		g_scr_play.hide();
		g_scr_download.hide();
		g_scr_rescan.hide();
		//END
	}
	else
	{
		//pjn123 EDIT
		/*scr_close.show();
		scr_open.hide();
		scr_download.show();
		scr_play.show();
		scr_rescan.show();*/
		g_scr_hide.show();
		g_scr_show.hide();
		g_scr_play.show();
		g_scr_download.show();
		g_scr_rescan.show();
		//END

		browser_scr_show_attrib.setData("1");
	}
	nocallback = FALSE;	
	
}

// called everytime a media link is found. you must call brw.scrape to get them!
brw.onMediaLink (string url)
{
	scr_list.addItem(removePath(url));
	scr_list.setSubItem(scr_list.getLastAddedItemPos(), 1, url);
}

Global Boolean prevent = FALSE;

// List Right click menu
scr_list.onRightClick (int num)
{
	scr_menu = new PopUpMenu;

	scr_menu.addCommand("Play selection\tEnter", 1, 0, 0);
	scr_menu.addCommand("Enqueue selection"/*\tShift+Enter"*/, 2, 0, 0);
	scr_menu.addCommand("Download selection"/*\tShift+Enter"*/, 3, 0, 0);
	scr_menu.addCommand("Send to:"/*\tShift+Enter"*/, 4, 0, 1);

	scr_menu.addSeparator();
	scr_menu.addCommand("Play all"/*\tAlt+Enter"*/, 11, 0, 0);
	scr_menu.addCommand("Enqueue all"/*\tShift+Alt+Enter"*/, 12, 0, 0);
	scr_menu.addCommand("Download all"/*\tShift+Alt+Enter"*/, 13, 0, 0);

	scr_menu.addSeparator();
	scr_menu.addCommand("Select all\tCtrl+A", 101, 0, 0);
	scr_menu.addCommand("Remove selection\tCtrl+R", 201, 0, 0);

	int result = scr_menu.popAtMouse();

	if (result)
	{
		if (result == 1) playListItem(num);
		else if (result == 2) enqueueListItem(num);
		else if (result == 3) downloadListItem(num);
		else if (result == 11 )
		{
			boolean enqueue = 0;
			int v = scr_list.getNumItems();
			for ( int i = 0; i < v ; i++ )
			{
				if (enqueue == 0)
				{
					System.playFile(scr_list.getItemLabel(i,1));
					enqueue = 1;
				}
				else
				{
					System.enqueueFile(scr_list.getItemLabel(i,1));
				}		
			}
		}
		else if (result == 12 )
		{
			int v = scr_list.getNumItems();
			for ( int i = 0; i < v ; i++ )
			{
				System.enqueueFile(scr_list.getItemLabel(i,1));		
			}
		}
		else if (result == 13 )
		{
			int v = scr_list.getNumItems();
			for ( int i = 0; i < v ; i++ )
			{
				System.downloadURL(scr_list.getItemLabel(i,1), scr_list.getItemLabel(i,0), "Download " + getExtFamily(scr_list.getItemLabel(i,1)));
			}
		}
		else if (result == 101) selectAll();
		else if (result == 201) 
		{
			if (getFirstItemSelected() == getNextItemSelected(getFirstItemSelected()))
			{
				deletebypos(getFirstItemSelected());
				if (scr_menu) delete scr_menu;
				return;
			}
			
			int v = scr_list.getNumItems();
			for ( int i = v-1; i >= 0 ; i-- )
			{
				if (getItemSelected(i)) deletebypos(i);
			}			
		}
	}

	if (scr_menu) delete scr_menu;
}

// User Buttons
scr_download.onLeftClick ()
{
	if (scr_list.getFirstItemSelected() == -1)
	{
		int v = scr_list.getNumItems();
		for ( int i = 0; i < v ; i++ )
		{
			System.downloadURL(scr_list.getItemLabel(i,1), scr_list.getItemLabel(i,0), "Download " + getExtFamily(scr_list.getItemLabel(i,1)));
		}
	}
	else
	{
		downloadListItem(-1);
	}
}

scr_play.onLeftClick ()
{
	playListItem(-1);
}

scr_rescan.onLeftClick ()
{
	scr_list.deleteAllItems();
	brw.scrape();
}

scr_list.onDoubleClick (Int itemnum)
{
	 playListItem(itemnum);
}

scr_list.onKeyDown (int code)
{
	if (code == 13) 
	{
		if (isKeyDown(VK_CONTROL))
		{
			enqueueListItem(scr_list.getItemFocused());
		}
		else
		{
			playListItem(scr_list.getItemFocused());
		}		
		prevent = TRUE;
	}
	else if (code == 65 && isKeyDown(VK_CONTROL))
	{
		selectAll();
		prevent = TRUE;
	}
	else if (code == 82 && isKeyDown(VK_CONTROL))
	{
		if (getFirstItemSelected() == getNextItemSelected(getFirstItemSelected()))
		{
			deletebypos(getFirstItemSelected());
			if (scr_menu) delete scr_menu;
			return;
		}
		
		int v = scr_list.getNumItems();
		for ( int i = v-1; i >= 0 ; i-- )
		{
			if (getItemSelected(i)) deletebypos(i);
		}
	}
	complete;
}

// prevent this action to be reported to other scripts
System.onKeyDown (String key)
{
	if (prevent)
	{
		prevent = FALSE;
		complete;
	}
}

// play a list item
playListItem (int num)
{
	if (scr_list.getFirstItemSelected() == -1)
	{
		
		boolean enqueue = 0;
		int v = scr_list.getNumItems();
		for ( int i = 0; i < v ; i++ )
		{
			if (enqueue == 0)
			{
				System.playFile(scr_list.getItemLabel(i,1));
				enqueue = 1;
			}
			else
			{
				System.enqueueFile(scr_list.getItemLabel(i,1));
			}		
		}
		return;
	}
	
	int sel = scr_list.getFirstItemSelected();
	if (sel == scr_list.getNextItemSelected(sel))
	{
		System.playFile(scr_list.getItemLabel(sel,1));
		return;
	}
	
	boolean enqueue = 0;
	int v = scr_list.getNumItems();
	for ( int i = 0; i < v ; i++ )
	{
		if (scr_list.getItemSelected(i))
		{
			if (enqueue == 0)
			{
				System.playFile(scr_list.getItemLabel(i,1));
				enqueue = 1;
			}
			else
			{
				System.enqueueFile(scr_list.getItemLabel(i,1));
			}
		}		
	}
}

// enqueue a list item
enqueueListItem (int num)
{
	int sel = scr_list.getFirstItemSelected();
	if (sel == scr_list.getNextItemSelected(sel))
	{
		System.enqueueFile(scr_list.getItemLabel(sel,1));
		return;
	}
	
	int v = scr_list.getNumItems();
	for ( int i = 0; i < v ; i++ )
	{
		if (scr_list.getItemSelected(i)) System.enqueueFile(scr_list.getItemLabel(i,1));		
	}
}

// downlaod a list item
downloadListItem (int num)
{
	int sel = scr_list.getFirstItemSelected();
	if (sel == scr_list.getNextItemSelected(sel))
	{
		string vv = scr_list.getItemLabel(sel,0);
		System.downloadURL(scr_list.getItemLabel(sel,1), vv, "Download File");		
		return;
	}
	
	int v = scr_list.getNumItems();
	for ( int i = 0; i < v ; i++ )
	{
		string vv = scr_list.getItemLabel(i,0);
		if (scr_list.getItemSelected(i)) System.downloadURL(scr_list.getItemLabel(i,1), vv, "Download File");		
	}
}



//pjn123 EDIT.... very ungly.. I know... bit lazy, and it works! :O
/*

	g_scr_show = dualwnd.findObject("browser.scraper.group.show");
	g_scr_hide = dualwnd.findObject("browser.scraper.group.hide");
	g_scr_play = dualwnd.findObject("browser.scraper.group.play");
	g_scr_download = dualwnd.findObject("browser.scraper.group.download");
	g_scr_rescan = dualwnd.findObject("browser.scraper.group.rescan");


*/
scr_open.onEnterArea(){
	if(mouseDown){
		l_scr_show.setXmlParam("image", "browser.button.scraper.show.down");
		g_scr_show.setXmlParam("y", "2");
	}
	else{
		l_scr_show.setXmlParam("image", "browser.button.scraper.show.hover");
		g_scr_show.setXmlParam("y", "1");
	}
}
scr_open.onLeaveArea(){
	l_scr_show.setXmlParam("image", "browser.button.scraper.show.normal");
	g_scr_show.setXmlParam("y", "1");
}
scr_open.onLeftButtonDown(int x, int y){
	mouseDown=true;
	l_scr_show.setXmlParam("image", "browser.button.scraper.show.down");
	g_scr_show.setXmlParam("y", "2");
}
scr_open.onLeftButtonUp(int x, int y){
	mouseDown=false;
	l_scr_show.setXmlParam("image", "browser.button.scraper.show.hover");
	g_scr_show.setXmlParam("y", "1");
}


scr_close.onEnterArea(){
	if(mouseDown){
		l_scr_hide.setXmlParam("image", "browser.button.scraper.hide.down");
		g_scr_hide.setXmlParam("y", "2");
	}
	else{
		l_scr_hide.setXmlParam("image", "browser.button.scraper.hide.hover");
		g_scr_hide.setXmlParam("y", "1");
	}
}
scr_close.onLeaveArea(){
	l_scr_hide.setXmlParam("image", "browser.button.scraper.hide.normal");
	g_scr_hide.setXmlParam("y", "1");
}
scr_close.onLeftButtonDown(int x, int y){
	mouseDown=true;
	l_scr_hide.setXmlParam("image", "browser.button.scraper.hide.down");
	g_scr_hide.setXmlParam("y", "2");
}
scr_close.onLeftButtonUp(int x, int y){
	mouseDown=false;
	l_scr_hide.setXmlParam("image", "browser.button.scraper.hide.hover");
	g_scr_hide.setXmlParam("y", "1");
}


scr_rescan.onEnterArea(){
	if(mouseDown){
		l_scr_rescan.setXmlParam("image", "browser.button.scraper.rescan.down");
		g_scr_rescan.setXmlParam("y", "2");
	}
	else{
		l_scr_rescan.setXmlParam("image", "browser.button.scraper.rescan.hover");
		g_scr_rescan.setXmlParam("y", "1");
	}
}
scr_rescan.onLeaveArea(){
	l_scr_rescan.setXmlParam("image", "browser.button.scraper.rescan.normal");
	g_scr_rescan.setXmlParam("y", "1");
}
scr_rescan.onLeftButtonDown(int x, int y){
	mouseDown=true;
	l_scr_rescan.setXmlParam("image", "browser.button.scraper.rescan.down");
	g_scr_rescan.setXmlParam("y", "2");
}
scr_rescan.onLeftButtonUp(int x, int y){
	mouseDown=false;
	l_scr_rescan.setXmlParam("image", "browser.button.scraper.rescan.hover");
	g_scr_rescan.setXmlParam("y", "1");
}


scr_play.onEnterArea(){
	if(mouseDown){
		l_scr_play.setXmlParam("image", "browser.button.scraper.play.down");
		g_scr_play.setXmlParam("y", "2");
	}
	else{
		l_scr_play.setXmlParam("image", "browser.button.scraper.play.hover");
		g_scr_play.setXmlParam("y", "1");
	}
}
scr_play.onLeaveArea(){
	l_scr_play.setXmlParam("image", "browser.button.scraper.play.normal");
	g_scr_play.setXmlParam("y", "1");
}
scr_play.onLeftButtonDown(int x, int y){
	mouseDown=true;
	l_scr_play.setXmlParam("image", "browser.button.scraper.play.down");
	g_scr_play.setXmlParam("y", "2");
}
scr_play.onLeftButtonUp(int x, int y){
	mouseDown=false;
	l_scr_play.setXmlParam("image", "browser.button.scraper.play.hover");
	g_scr_play.setXmlParam("y", "1");
}


scr_download.onEnterArea(){
	if(mouseDown){
		l_scr_download.setXmlParam("image", "browser.button.scraper.download.down");
		g_scr_download.setXmlParam("y", "2");
	}
	else{
		l_scr_download.setXmlParam("image", "browser.button.scraper.download.hover");
		g_scr_download.setXmlParam("y", "1");
	}
}
scr_download.onLeaveArea(){
	l_scr_download.setXmlParam("image", "browser.button.scraper.download.normal");
	g_scr_download.setXmlParam("y", "1");
}
scr_download.onLeftButtonDown(int x, int y){
	mouseDown=true;
	l_scr_download.setXmlParam("image", "browser.button.scraper.download.down");
	g_scr_download.setXmlParam("y", "2");
}
scr_download.onLeftButtonUp(int x, int y){
	mouseDown=false;
	l_scr_download.setXmlParam("image", "browser.button.scraper.download.hover");
	g_scr_download.setXmlParam("y", "1");
}



doLyricSearch(){
	String temp = "http://www.lyricsplugin.com/winamp03/plugin/?artist="+getPlayItemMetaDataString("artist")+"&title="+getPlayItemMetaDataString("title");
	temp = strReplace(temp, " ", "%20");
	brw.navigateUrl(temp);
}
doExplorerSearch(){
    String temp = getPlayItemMetaDataString("filename");
    brw.navigateUrl(getPath(temp));
}
doFoxySearch(){
	String temp = "http://www.foxytunes.com/artist/"+getPlayItemMetaDataString("artist");
	temp = strReplace(temp, " ", "_");
	//http://www.foxytunes.com/artist/will_smith
	brw.navigateUrl(temp);
}

System.onTitleChange(String newtxt){
	if(lyricMode){
		doLyricSearch();
	}
	else if(explorerMode){
		doExplorerSearch();
	}
	else if(foxyMode){
		doFoxySearch();
	}
}
