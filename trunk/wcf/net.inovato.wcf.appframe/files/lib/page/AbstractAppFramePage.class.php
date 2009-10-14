<?php
// wcf imports
require_once(WCF_DIR.'lib/page/AbstractPage.class.php');

// appframe imports
require_once(WCF_DIR.'lib/page/AppFramePage.class.php');
require_once(WCF_DIR.'lib/page/util/AppFrameBreadCrumb.class.php');

/**
 * @author		Martin Poehlmann
 * @copyright	2009 Inovato, LLC <http://www.inovato.net>
 * @license		Creative Commons Attribution-Noncommercial-No Derivative Works 3.0 Unported <http://creativecommons.org/licenses/by-nc-nd/3.0/>
 * @package		net.inovato.wcf.appframe
 */

abstract class AbstractAppFramePage extends AbstractPage implements AppFramePage
{
	public $templateName = 'appFrameGenericSite';
	
	// Site Title. May be a language var.
	public $appFrameGenericSiteTitle = '';
	
	// Shows the Site Caption
	public $appFrameGenericSiteShowCaption = true;
	
	// Site caption text. May be language vars.
	public $appFrameGenericSiteCaption = '';
	public $appFrameGenericSiteCaptionSub = '';
	
	// Icon shown beside the caption.
	public $appFrameGenericSiteCaptionIcon = '';
	
	// Self Link to the page. This will normally be constructed out of the classname. Modify in setSelfLink() method.
	public $appFrameSelfLink;
	
	// Allow Searchbots to index the page.
	public $appFrameAllowSpidersToIndexThisPage = true;
	
	// BreadCrumb navigation entries 
	public $appFrameBreadCrumbs = array();
	
	/**
	 * Creates a new AbstractAppFramePage object.
	 */
	public function __construct()
	{
		$this->setSelfLink();
		$this->appFrameBreadCrumbs[] = new AppFrameBreadCrumb(PAGE_TITLE, 'index.php?page=Index'.SID_ARG_2ND_NOT_ENCODED, 'indexS.png');
		parent::__construct();
	}
	
	/**
	 * Sets the self link
	 */	
	public function setSelfLink()
	{
		$this->appFrameSelfLink = self::buildAppFrameSelfLink($this);
	}
	
	public static function buildAppFrameSelfLink(Page $page)
	{
		$last4 = substr(get_class($page), -4, 4);
		if ($last4 == 'Page')
		{
			return 'index.php?page='.substr(get_class($page), 0, -4).SID_ARG_2ND_NOT_ENCODED;
		}
		else if ($last4 == 'Form')
		{
		 	return 'index.php?form='.substr(get_class($page), 0, -4).SID_ARG_2ND_NOT_ENCODED;
		}
		else // we assume it's an action now
		{
			return 'index.php?action='.substr(get_class($page), 0, -6).SID_ARG_2ND_NOT_ENCODED;
		}		
	}

	/**
	 * @see Page::assignVariables();
	 */
	public function assignVariables()
	{
		parent::assignVariables();

		self::assignAppFrameVariables($this);
		
		/* TODO reimplement something like this
		check if (WCF::getSession()->spiderID)
		{
			if ($lastChangeTime = @filemtime(WBB_DIR.'cache/cache.stat.php')) {
				@header('Last-Modified: '.gmdate('D, d M Y H:i:s', $lastChangeTime).' GMT');
			}
		}*/
	}
	
	public static function assignAppFrameVariables(AppFramePage $appFramePage)
	{
		WCF::getTPL()->assign(array(
			'selfLink' => $appFramePage->appFrameSelfLink,
			'allowSpidersToIndexThisPage' => $appFramePage->appFrameAllowSpidersToIndexThisPage,
			'appFrameGenericSiteTitle' => $appFramePage->appFrameGenericSiteTitle,
			'appFrameBreadCrumbs' => $appFramePage->appFrameBreadCrumbs,
			'appFrameGenericSiteShowCaption' => $appFramePage->appFrameGenericSiteShowCaption,
			'appFrameGenericSiteCaption' => $appFramePage->appFrameGenericSiteCaption,
			'appFrameGenericSiteCaptionSub' => $appFramePage->appFrameGenericSiteCaptionSub,
			'appFrameGenericSiteCaptionIcon' => $appFramePage->appFrameGenericSiteCaptionIcon,
			
		));		
	}
}
?>