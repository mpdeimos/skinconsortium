;###########################################################################################
;###########################################################################################
;#
;#										      ClassicPro Installer         
;#									   Copyright (c) 2009 by Pawe� Porwisz                                   
;#
;###########################################################################################
;###########################################################################################

; Loading AutoGenerated Config File
	!include "cPro_Installer_Config.nsh"

; Definitions
	!define CPRO_SOURCEPATH "ClassicPro"
	!define CPRO_NAME "ClassicPro"
	!define CPRO_CRS "�"
	!define CPRO_REVISION "0"
	!define CPRO_BUILD "0"
	!define CPRO_PAYPAL_LINK "https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=donate%40skinconsortium%2ecom&item_name=SkinConsortium%20Donation&item_number=%3e%20for%20skin%3a%20ClassicPro&no_shipping=1&no_note=1&cn=Optional%20Message&tax=0�cy_code=EUR&lc=GB&bn=PP%2dDonationsBF&charset=UTF%2d8"	
	!define CPRO_TECHNICAL_SUPPORT_LINK "http://forums.skinconsortium.com/index.php?page=Board&boardID=46"
	!define /Date CPRO_DATE "%Y-%m-%d"
	!define CPRO_BT "http://cpro.skinconsortium.com"
	!define CPRO_WEB_PAGE "http://cpro.skinconsortium.com"
	!define CPRO_HELP_LINK "http://forums.skinconsortium.com/"
	!define CPRO_AUTHOR "Skin Consortium"
	!define CPRO_COMPANY "Skin Consortium"
	!define /Date CPRO_COPYRIGHT "Copyright (c) 2005-%Y"	
	!define CPRO_UNINSTALLER "Uninstall ClassicPro"	
	!define CPRO_WINAMP_VERSION "5.55"
	!define CPRO_OUTFILE_PATH "C:\Program Files\Winamp\Plugins\ClassicPro\_installer"	; change to compile properly
	!define CPRO_WINAMP_SKINS "C:\Program Files\Winamp\Skins"				; change to compile properly
	!define CPRO_WINAMP_SYSTEM "C:\Program Files\Winamp\System"				; change to compile properly
	
;###########################################################################################
;#											CONFIGURATION
;###########################################################################################

	!if ${CPRO_BUILD_TYPE} == "BETA"
; Beta stage	
		Name "${CPRO_NAME}${CPRO_CRS} v${CPRO_VERSION} ${CPRO_BUILD_NAME}"
		OutFile "${CPRO_OUTFILE_PATH}\${CPRO_NAME}_${CPRO_VERSION}_${CPRO_BUILD_FILENAME_ADDITION}.exe"

	!else if ${CPRO_BUILD_TYPE} == "NIGHTLY"
; Alpha stage	
		Name "${CPRO_NAME}${CPRO_CRS} v${CPRO_VERSION} ${CPRO_BUILD_NAME}"
		OutFile "${CPRO_OUTFILE_PATH}\${CPRO_NAME}_${CPRO_VERSION}_${CPRO_BUILD_FILENAME_ADDITION}_(${CPRO_DATE}).exe"
	!else
; Release
		Name "${CPRO_NAME}${CPRO_CRS} v${CPRO_VERSION}"
		OutFile "${CPRO_OUTFILE_PATH}\${CPRO_NAME}_${CPRO_VERSION}.exe"		
	!endif

	SetCompressor /SOLID lzma
	Caption "$(CPro_Caption)"
	BrandingText "${CPRO_BT}"

	InstType $(CPro_Full)
	InstType $(CPro_Minimal)
	
	ReserveFile "Plugins\Linker.dll"
	ReserveFile "Plugins\LockedList.dll"
	
; Plugins Dir   
	!addplugindir "Plugins"  
   
;###########################################################################################
;#									  DESTINATION FOLDER
;###########################################################################################

	InstallDir "$PROGRAMFILES\Winamp"
	InstallDirRegKey "HKLM" "Software\Microsoft\Windows\CurrentVersion\Uninstall\Winamp" "UninstallString"
	RequestExecutionLevel "admin"
	XPStyle "on"

;###########################################################################################
;#									 	HEADER FILES
;###########################################################################################

	!include "MUI2.nsh"
	!include "Sections.nsh"
	!include "nsDialogs.nsh"
	!include "WinVer.nsh"
	
;###########################################################################################
;#									 INTERFACE SETTINGS 
;###########################################################################################

	DirText "$(CPro_DirText)"
	!define MUI_CUSTOMFUNCTION_GUIINIT My_GUIInit
	!define MUI_LANGDLL_WINDOWTITLE $LANG_TITLE
	!define MUI_LANGDLL_INFO $(CPro_Language_Text)
	!define MUI_FINISHPAGE_TITLE_3LINES
	!define MUI_WELCOMEPAGE_TITLE_3LINES
	!define MUI_WELCOMEPAGE_TITLE $(CPro_Welcome_Title)
	!define MUI_WELCOMEPAGE_TEXT $(CPro_Welcome_Text)

	!if ${CPRO_BUILD_TYPE} != "FINAL"
		!define MUI_HEADERIMAGE_LEFT
	!else
		!define MUI_HEADERIMAGE_RIGHT
	!endif 

	!define MUI_HEADERIMAGE

	!if ${CPRO_BUILD_TYPE} == "BETA"
		!define MUI_HEADERIMAGE_BITMAP "Images\header-beta.bmp"
	!else if ${CPRO_BUILD_TYPE} == "NIGHTLY"
		!define MUI_HEADERIMAGE_BITMAP "Images\header-nightly.bmp"
	!else
		!define MUI_HEADERIMAGE_BITMAP "Images\header.bmp"
	!endif 
	
	!define MUI_ABORTWARNING
	!define MUI_COMPONENTSPAGE_SMALLDESC
	!define MUI_ICON "Images\icon.ico"
	!define MUI_COMPONENTSPAGE_CHECKBITMAP "${NSISDIR}\Contrib\Graphics\Checks\modern.bmp"
	!define MUI_WELCOMEFINISHPAGE_BITMAP "Images\win.bmp"
	!define MUI_UNICON "Images\icon.ico"
	!define MUI_UNCOMPONENTSPAGE_CHECKBITMAP "${NSISDIR}\Contrib\Graphics\Checks\modern.bmp"
	!define MUI_UNWELCOMEFINISHPAGE_BITMAP "Images\win.bmp"
	
; Installer pages	
	!insertmacro MUI_PAGE_WELCOME
	!insertmacro MUI_PAGE_LICENSE "..\License.txt" ;_installer\License\CPro_en_us_License.rtf"
	!insertmacro MUI_PAGE_COMPONENTS
	!insertmacro MUI_PAGE_DIRECTORY
	Page Custom LockedListShow		
	Page custom CreateCleanupPage CheckCleanupPage ""	
	!insertmacro MUI_PAGE_INSTFILES
	Page custom CreateFinishPage CheckFinishPage ""

; Uninstaller pages
	!define MUI_CUSTOMFUNCTION_UNGUIINIT un.My_GUIInit	
	!define MUI_WELCOMEPAGE_TITLE_3LINES
	!define MUI_WELCOMEPAGE_TITLE $(CPro_Un_Welcome_Title)
	!define MUI_WELCOMEPAGE_TEXT $(CPro_Un_Welcome_Text)
	!insertmacro MUI_UNPAGE_WELCOME
	UninstPage Custom un.LockedListShow	
	!insertmacro MUI_UNPAGE_CONFIRM	
	!insertmacro MUI_UNPAGE_INSTFILES
	!insertmacro MUI_UNPAGE_FINISH
	!define MUI_UNHEADERIMAGE
	!define MUI_UNHEADERIMAGE_BITMAP "Images\header.bmp"
	!define MUI_UNABORTWARNING
	!define MUI_UNCOMPONENTSPAGE_SMALLDESC	
	
;###########################################################################################
;#									INSTALLER  LANGUAGE
;###########################################################################################

	!define MUI_LANGDLL_ALLLANGUAGES
	!insertmacro MUI_RESERVEFILE_LANGDLL
	
; Language: English (1033), [ANSI], ${LANG_ENGLISH}
	!insertmacro MUI_LANGUAGE "English" 		
	!include "Languages\cPro_en_us.nsh"

; Language: German (1031), [1252], ${LANG_GERMAN}
	!insertmacro MUI_LANGUAGE "German"			
	!include "Languages\cPro_de_de.nsh"
	
; Language: French (1036), [1252], ${LANG_FRENCH}	
	!insertmacro MUI_LANGUAGE "French"			
	!include "Languages\cPro_fr_fr.nsh"		
	
; Language: Polish (1045), [1250], ${LANG_POLISH}	
	!insertmacro MUI_LANGUAGE "Polish"			
	!include "Languages\cPro_pl_pl.nsh"

; Language: Brazilian Portuguese (1046), [1252], ${LANG_PORTUGUESE_BRAZILIAN}
	!insertmacro MUI_LANGUAGE "PortugueseBR"
	!include "Languages\cPro_pt_br.nsh"

; Language: Romanian (1048), [1250], ${LANG_ROMANIAN}
	!insertmacro MUI_LANGUAGE "Romanian"		
	!include "Languages\cPro_ro_ro.nsh"
	
; Language: Russian (1049), [1251], ${LANG_RUSSIAN}
	!insertmacro MUI_LANGUAGE "Russian"			
	!include "Languages\cPro_ru_ru.nsh"	
	
; Language: Turkish (1055), [1254], ${LANG_TURKISH}	
	!insertmacro MUI_LANGUAGE "Turkish"			
	!include "Languages\cPro_tr_tr.nsh"

; Language: Danish (1030), [1252], ${LANG_DANISH}	
	!insertmacro MUI_LANGUAGE "Danish"			
	!include "Languages\cPro_da_dk.nsh"

; Language: Spanish International (3082), [1252], ${LANG_SPANISH_INTERNATIONAL}
	; !insertmacro MUI_LANGUAGE "SpanishInternational"			
	; !include "Languages\cPro_es_us.nsh"

; Language: Italian (1040), [1252], ${LANG_ITALIAN}	
	; !insertmacro MUI_LANGUAGE "Italian"			
	; !include "Languages\cPro_it_it.nsh"

; Language: Dutch (1043), [1252], ${LANG_DUTCH}	
	; !insertmacro MUI_LANGUAGE "Dutch"			
	; !include "Languages\cPro_nl_nl.nsh"
	
; Language: Chinese (Simplified) (2052), [936], ${LANG_SIMPCHINESE}
	; !insertmacro MUI_LANGUAGE "SimpChinese"		
	; !include "Languages\cPro_zh_cn.nsh"
	
; Language: Chinese (Traditional) (1028), [950], ${LANG_TRADCHINESE}
	; !insertmacro MUI_LANGUAGE "TradChinese"		
	; !include "Languages\cPro_zh_tw.nsh"
	
; Language: Swedish (1053), [1252], ${LANG_SWEDISH}	
	; !insertmacro MUI_LANGUAGE "Swedish"			
	; !include "Languages\cPro_sv_se.nsh"

; Language: Japanese (1041), [932], ${LANG_JAPANESE}	
	; !insertmacro MUI_LANGUAGE "Japanese"			
	; !include "Languages\cPro_ja_jp.nsh"

; Language: Korean (1042), [949], ${LANG_KOREAN}	
	; !insertmacro MUI_LANGUAGE "Korean"			
	; !include "Languages\cPro_ko_kr.nsh"
	
;###########################################################################################
;#										VERSION INFORMATION
;###########################################################################################

	!if ${CPRO_BUILD_TYPE} == "BETA"
; Beta stage	
		VIProductVersion "${CPRO_VERSION}.${CPRO_REVISION}.${CPRO_BUILD}"
		VIAddVersionKey "ProductName" "${CPRO_NAME} ${CPRO_BUILD_NAME}"
		VIAddVersionKey "ProductVersion" "${CPRO_VERSION}"	
		VIAddVersionKey "Comments" "${CPRO_NAME} v${CPRO_VERSION} ${CPRO_BUILD_NAME}, ${CPRO_WEB_PAGE}"
		VIAddVersionKey "CompanyName" "${CPRO_COMPANY}"
		VIAddVersionKey "LegalCopyright" "${CPRO_COPYRIGHT}, ${CPRO_AUTHOR}"
		VIAddVersionKey "FileDescription" "${CPRO_NAME} v${CPRO_VERSION} ${CPRO_BUILD_NAME} (${CPRO_BUILD_TYPE})"
		VIAddVersionKey "FileVersion" "${CPRO_VERSION}"

	!else if ${CPRO_BUILD_TYPE} == "NIGHTLY"
; Alpha stage	
		VIProductVersion "${CPRO_VERSION}.${CPRO_REVISION}.${CPRO_BUILD}"
		VIAddVersionKey "ProductName" "${CPRO_NAME} ${CPRO_BUILD_NAME}"
		VIAddVersionKey "ProductVersion" "${CPRO_VERSION}"	
		VIAddVersionKey "Comments" "${CPRO_NAME} v${CPRO_VERSION} ${CPRO_BUILD_NAME}, ${CPRO_WEB_PAGE}"
		VIAddVersionKey "CompanyName" "${CPRO_COMPANY}"
		VIAddVersionKey "LegalCopyright" "${CPRO_COPYRIGHT}, ${CPRO_AUTHOR}"
		VIAddVersionKey "FileDescription" "${CPRO_NAME} v${CPRO_VERSION} ${CPRO_BUILD_NAME} (${CPRO_BUILD_TYPE})"
		VIAddVersionKey "FileVersion" "${CPRO_VERSION}"
	!else
; Release
		VIProductVersion "${CPRO_VERSION}.${CPRO_REVISION}.${CPRO_BUILD}"
		VIAddVersionKey "ProductName" "${CPRO_NAME}"
		VIAddVersionKey "ProductVersion" "${CPRO_VERSION}"		
		VIAddVersionKey "Comments" "${CPRO_NAME} v${CPRO_VERSION}, ${CPRO_WEB_PAGE}"
		VIAddVersionKey "CompanyName" "${CPRO_COMPANY}"
		VIAddVersionKey "LegalCopyright" "${CPRO_COPYRIGHT}, ${CPRO_AUTHOR}"
		VIAddVersionKey "FileDescription" "${CPRO_NAME} v${CPRO_VERSION}"
		VIAddVersionKey "FileVersion" "${CPRO_VERSION}"		
	!endif

	Var /Global WINAMP_INI_DIR
	
!macro SharedPath un
  
	Function ${un}GetWinampIniPath

		StrCpy $WINAMP_INI_DIR $INSTDIR
		
		IfFileExists "$INSTDIR\paths.ini" 0 Paths.ini_Not_Found
		
			ReadINIStr $0 "$INSTDIR\paths.ini" "Winamp" "inidir"
			StrCmp $0 "" Paths.ini_Empty

			StrCpy $2 $0 1
			IntOp $1 0 - 0
			StrCmp $2 "{"+1 No_Replace
			LoopBack:
				IntOp $1 $1 + 1
				StrCpy $2 $0 1 $1
				StrCmp $2 "}" CSID_Found LoopBack
				IntCmp $1 3 CSID_Found LoopBack No_Replace
					CSID_Found:
						StrCpy $3 $0 $1 1
						IntOp $1 $1 + 1
						StrCpy $2 $0 "" $1
						System::Call 'shell32::SHGetSpecialFolderPathA(i $HWNDPARENT, t .r1, i $3, b 'false') i r0'
						StrCpy $0 "$1$2"
			No_Replace:
			StrCpy $WINAMP_INI_DIR $0
			DetailPrint "$(CPro_Account): $WINAMP_INI_DIR"
			Goto done
			
			Paths.ini_Empty:
				DetailPrint "$(CPro_No_Account): $WINAMP_INI_DIR"
				Goto done
		Paths.ini_Not_Found:
			DetailPrint "$(CPro_No_Account): $WINAMP_INI_DIR"
			Goto done
		done:
	
	FunctionEnd

!macroend

; Insert function as an installer and uninstaller function
	!insertmacro SharedPath ""
	!insertmacro SharedPath "un."
	
	
Function .onInit

; Language
	Var /GLOBAL LANG_TITLE
		StrCpy $LANG_TITLE  $(CPro_Language_Title)
	!insertmacro MUI_LANGDLL_DISPLAY
	InitPluginsDir
	
	Var /Global Dialog
	
; Finish Page Variables
	Var /Global Label1
	Var /Global Label1_Font
	Var /Global Label2
	Var /Global Label3
	Var /Global Label4	
	Var /Global CheckBox1
	Var /Global CheckBox2	
	Var /Global Checkbox_State	
	Var /GLOBAL Button	
	Var /GLOBAL Img_Left		
	Var /GLOBAL Img_Handle_Left

	File /oname=$PLUGINSDIR\PayPal.bmp "Images\donate.bmp"
	File /oname=$PLUGINSDIR\Img_Left.bmp "Images\win.bmp"
	
; Cleanup Page Variables	
	Var /GLOBAL Cleanup_Check_StudioXnf
	Var /GLOBAL Cleanup_Check_WinampIni
	Var /GLOBAL Cleanup_Check_StudioXnf_B
	Var /GLOBAL Cleanup_Check_WinampIni_B
	
FunctionEnd

Function My_GUIInit

	FindWindow $0 "#32770" "" $HWNDPARENT
	GetDlgItem $0 $HWNDPARENT 1028
	EnableWindow $0 1
	Linker::link /NOUNLOAD $0 "${CPRO_BT}"

FunctionEnd

Function .onGUIEnd

	Linker::Unload

FunctionEnd

Function .onVerifyInstDir

	IfFileExists $INSTDIR\Winamp.exe Good
		Abort
	Good:

FunctionEnd

Function CreateFinishPage

    LockWindow on
    GetDlgItem $0 $HWNDPARENT 1028
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1256
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1045
    ShowWindow $0 ${SW_NORMAL}
    LockWindow off

    nsDialogs::Create /NOUNLOAD 1044
	Pop $Dialog
	
	${If} $Dialog == error
		Abort
	${EndIf}
	
    SetCtlColors $Dialog "" "0xFFFFFF"

	${NSD_CreateBitmap} 0u 0u 109u 193u ""
	Pop $Img_Left
	${NSD_SetImage} $Img_Left $PLUGINSDIR\Img_Left.bmp $Img_Handle_Left
	
	${NSD_CreateLabel} 115u 20u 63% 30u "$(CPro_FinishPage_1)"
	Pop $Label1
	${NSD_AddStyle} $Label1 ${WS_VISIBLE}|${WS_CHILD}|${WS_CLIPSIBLINGS}
	CreateFont $Label1_Font "TAHOMA" "13" "700"
	SendMessage $Label1 ${WM_SETFONT} $Label1_Font 0	
    SetCtlColors $Label1 "0x000000" "TRANSPARENT"
	
	${NSD_CreateLabel} 115u 60u 63% 30u "$(CPro_FinishPage_2)"
	Pop $Label2
	${NSD_AddStyle} $Label2 ${WS_VISIBLE}|${WS_CHILD}|${WS_CLIPSIBLINGS}
    SetCtlColors $Label2 "0x000000" "TRANSPARENT"	
	
	${NSD_CreateButton} 115u 100u 58 35 ""
	Pop $Button
	${NSD_AddStyle} $Button "${BS_BITMAP}" 
	System::Call 'user32::LoadImage(i 0, t "$PLUGINSDIR\PayPal.bmp", i ${IMAGE_BITMAP}, i 0, i 0, i ${LR_CREATEDIBSECTION}|${LR_LOADFROMFILE}) i.s' 
	Pop $1 
	SendMessage $Button ${BM_SETIMAGE} ${IMAGE_BITMAP} $1
	${NSD_OnClick} $Button Button_Click		

	${NSD_CreateLabel} 160u 100u 50% 30u "$(CPro_FinishPage_3)"
	Pop $Label3
	${NSD_AddStyle} $Label3 ${WS_VISIBLE}|${WS_CHILD}|${WS_CLIPSIBLINGS}
    SetCtlColors $Label3 "0x000000" "TRANSPARENT"

	${NSD_CreateLabel} 115u 148u 63% 10u "$(CPro_FinishPage_4)"
	Pop $Label4
	${NSD_AddStyle} $Label4 ${WS_VISIBLE}|${WS_CHILD}|${WS_CLIPSIBLINGS}
    SetCtlColors $Label4 "0x000000" "TRANSPARENT"	

	${NSD_CreateCheckBox} 115u 160u 65% 10u "$(CPro_FinishPage_6)"
	Pop $CheckBox1
	;${If} $Cleanup_Check_WinampIni_B == ${BST_CHECKED}
	;	EnableWindow $CheckBox1 0
	;${Else}
		${NSD_Check} $CheckBox1
	;${EndIf}
	SetCtlColors $CheckBox1 "0x000000" "0xFFFFFF"
	
	${NSD_CreateCheckBox} 115u 170u 65% 16u "$(CPro_FinishPage_5)"
	Pop $CheckBox2	
	${NSD_Check} $CheckBox2		
    SetCtlColors $CheckBox2 "0x000000" "0xFFFFFF"	

	GetDlgItem $R0 $HWNDPARENT 1
	SendMessage $R0 ${WM_SETTEXT} 0 "STR:$(CPro_FinishPage_7)"
	
	nsDialogs::Show
	${NSD_FreeImage} $Img_Handle_Left

FunctionEnd

Function Button_Click

	Pop $0
	ExecShell "open" "${CPro_PayPal_Link}"

FunctionEnd

Function CheckFinishPage

	${NSD_GetState} $CheckBox2 $Checkbox_State
	${If} $Checkbox_State = ${BST_CHECKED}
		ExecShell "open" "${CPRO_WEB_PAGE}"
	${EndIf}
	
	;${If} $Cleanup_Check_WinampIni_B != ${BST_CHECKED}
		${NSD_GetState} $CheckBox1 $Checkbox_State
		${If} $Checkbox_State = ${BST_CHECKED}

			DetailPrint "$(CPro_Ini)"
				WriteINIStr "$WINAMP_INI_DIR\winamp.ini" "Winamp" "skin" "cPro__Bento.wal"
				FlushINI "$WINAMP_INI_DIR\winamp.ini"
			ExecShell "open" "$INSTDIR\winamp.exe"
		${EndIf}
	;${EndIf}
	
FunctionEnd

Function CreateCleanupPage

	!insertmacro MUI_HEADER_TEXT "$(CPro_CleanupPage_Title)" "$(CPro_CleanupPage_Subtitle)"
	
	nsDialogs::Create /NOUNLOAD 1018
	Pop $Dialog
	
	${If} $Dialog == error
		Abort
	${EndIf}

	${NSD_CreateLabel} 0 0 100% 18u "$(CPro_CleanupPage_Caption0)"
	${NSD_CreateLabel} 0 18u 100% 18u "$(CPro_CleanupPage_Caption1)"
	${NSD_CreateLabel} 0 38u 100% 9u "$(CPro_CleanupPage_Caption2)"
	${NSD_CreateLabel} 0 49u 100% 18u "$(CPro_CleanupPage_Caption3)"
	${NSD_CreateLabel} 0 67u 100% 9u "$(CPro_CleanupPage_Caption4)"

	${NSD_CreateCheckBox} 0 80u 100% 12u "$(CPro_CleanupPage_StudioXnf)"
	Pop $Cleanup_Check_StudioXnf
	${NSD_CreateLabel} 22 92u 100% 10u "$(CPro_CleanupPage_StudioXnf_Desc)"
	Pop $R1
	CreateFont $R9 "Arial" "7" "400"	
	SendMessage $R1 ${WM_SETFONT} $R9 0
	EnableWindow $R1 0

	${NSD_CreateCheckBox} 0 100u 100% 12u "$(CPro_CleanupPage_WinampIni)"
	Pop $Cleanup_Check_WinampIni
	${NSD_CreateLabel} 22 112u 100% 10u "$(CPro_CleanupPage_WinampIni_Desc)"
	Pop $R1
 	SendMessage $R1 ${WM_SETFONT} $R9 0
	EnableWindow $R1 0

	${NSD_CreateLabel} 0 123u 100% 9u "$(CPro_CleanupPage_Footer)"
	${NSD_CreateLink} 22 132u 100% 9u "$(CPro_CleanupPage_TSLink)"
	Pop $R0
	${NSD_OnClick} $R0 CleanupTSLink_onClick

	nsDialogs::Show

FunctionEnd

Function CleanupTSLink_onClick

	Pop $0
	ExecShell "open" "${CPro_Technical_Support_Link}"

FunctionEnd

Function CheckCleanupPage

	${NSD_GetState} "$Cleanup_Check_StudioXnf" "$Cleanup_Check_StudioXnf_B"
	${NSD_GetState} "$Cleanup_Check_WinampIni" "$Cleanup_Check_WinampIni_B"

FunctionEnd
	
Function LockedListShow

	${If} ${AtLeastWinNt4}
		!insertmacro MUI_HEADER_TEXT "$(CPro_CloseWinamp_Welcome_Title)" "$(CPro_CloseWinamp_Welcome_Text)"
			LockedList::AddModule /NOUNLOAD "$INSTDIR\winamp.exe"
			LockedList::Dialog /heading "$(CPro_CloseWinamp_Heading)" /searching "$(CPro_CloseWinamp_Searching)" /endsearch "$(CPro_CloseWinamp_EndSearch)" /endmonitor "$(CPro_CloseWinamp_EndMonitor)" /noprograms "$(CPro_CloseWinamp_NoPrograms)" /colheadings "$(CPro_CloseWinamp_ColHeadings1)" "$(CPro_CloseWinamp_ColHeadings2)" /autoclosesilent "$(CPro_CloseWinamp_Autoclosesilent)" ignore "$(^NextBtn)"
	${EndIf}

FunctionEnd

Function un.LockedListShow

	${If} ${AtLeastWinNt4}
		!insertmacro MUI_HEADER_TEXT "$(CPro_CloseWinamp_Welcome_Title)" "$(CPro_CloseWinamp_Welcome_Text)"
			LockedList::AddModule /NOUNLOAD "$INSTDIR\winamp.exe"
			LockedList::Dialog /heading "$(CPro_CloseWinamp_Heading)" /searching "$(CPro_CloseWinamp_Searching)" /endsearch "$(CPro_CloseWinamp_EndSearch)" /endmonitor "$(CPro_CloseWinamp_EndMonitor)" /noprograms "$(CPro_CloseWinamp_NoPrograms)" /colheadings "$(CPro_CloseWinamp_ColHeadings1)" "$(CPro_CloseWinamp_ColHeadings2)" /autoclosesilent "$(CPro_CloseWinamp_Autoclosesilent)" ignore "$(^NextBtn)"
	${EndIf}

FunctionEnd

	ShowInstDetails "show"

;###########################################################################################
;#									INSTALLER  SECTIONS 
;###########################################################################################

Section "-Pre"

	DetailPrint "$(CPro_Winamp_Path)"
		Call GetWinampIniPath

SectionEnd

Section "$(CPro_CProFiles)" "CPro_Sec_CProFiles"

	SectionIn 1 2 RO
; Main directory	
	SetOutPath $INSTDIR\Plugins\ClassicPro
		File "..\*.txt"
; Installer -- TODO add to new category 'Development Kit', so user can unselect
	SetOutPath $INSTDIR\Plugins\ClassicPro\_installer
		File "*.nsi"
		File "*.nsh"
	SetOutPath $INSTDIR\Plugins\ClassicPro\_installer\Images
		File "images\*.bmp"
		File "images\*.ico"
	SetOutPath $INSTDIR\Plugins\ClassicPro\_installer\Languages
		File "Languages\*.nsh"
	SetOutPath $INSTDIR\Plugins\ClassicPro\_installer\Plugins
		File "Plugins\*.txt"
		File "Plugins\*.dll"
	SetOutPath $INSTDIR\Plugins\ClassicPro\_installer\Files
		File "Files\*.*"
; CPro engine		
	SetOutPath $INSTDIR\Plugins\ClassicPro\engine
		File "..\engine\*.xml"
; CPro engine	 - Image		
	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\image
		File "..\engine\image\*.png"
; CPro engine	 - cPro::One
	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\one\scripts
		File "..\engine\one\scripts\*.m"
		File "..\engine\one\scripts\*.maki"
	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\one\scripts\attribs
		File "..\engine\one\scripts\attribs\*.m"
	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\one\xml
		File "..\engine\one\xml\*.xml"
; CPro engine	 - Scripts
	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\scripts
		File "..\engine\scripts\*.m"
		File "..\engine\scripts\*.maki"
	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\scripts\attribs
		File "..\engine\scripts\attribs\*.m"
	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\scripts\lib
		File "..\engine\scripts\lib\*.mi"
; CPro engine	 - xml
	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xml
		File "..\engine\xml\*.xml"
; CPro engine	 - xui
	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui
		File "..\engine\xui\*.xml"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\AlbumArt
		File "..\engine\xui\AlbumArt\*.xml"
		File "..\engine\xui\AlbumArt\*.m"
		File "..\engine\xui\AlbumArt\*.maki"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\CentroSUI
		File "..\engine\xui\CentroSUI\*.xml"
	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\CentroSUI\scripts
		File "..\engine\xui\CentroSUI\scripts\*.m"
		File "..\engine\xui\CentroSUI\scripts\*.maki"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\CproTabs
		File "..\engine\xui\CproTabs\*.xml"
		File "..\engine\xui\CproTabs\*.m"
		File "..\engine\xui\CproTabs\*.maki"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\editbox
		File "..\engine\xui\editbox\*.xml"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\FadeText
		File "..\engine\xui\FadeText\*.xml"
		File "..\engine\xui\FadeText\*.m"
		File "..\engine\xui\FadeText\*.maki"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\historyeditbox
		File "..\engine\xui\historyeditbox\*.xml"
		File "..\engine\xui\historyeditbox\*.m"
		File "..\engine\xui\historyeditbox\*.maki"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\ModernSongticker
		File "..\engine\xui\ModernSongticker\*.xml"
		File "..\engine\xui\ModernSongticker\*.txt"
		File "..\engine\xui\ModernSongticker\*.m"
		File "..\engine\xui\ModernSongticker\*.maki"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\Ratings
		File "..\engine\xui\Ratings\*.xml"
		File "..\engine\xui\Ratings\*.m"
		File "..\engine\xui\Ratings\*.maki"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\PlaylistPro
		File "..\engine\xui\PlaylistPro\alt\*.xml"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\PlaylistPro\alt
		File "..\engine\xui\PlaylistPro\alt\*.xml"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\SC-Channels
		File "..\engine\xui\SC-Channels\*.xml"
		File "..\engine\xui\SC-Channels\*.m"
		File "..\engine\xui\SC-Channels\*.maki"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\SC-ProgressGrid
		File "..\engine\xui\SC-ProgressGrid\*.xml"
		File "..\engine\xui\SC-ProgressGrid\*.m"
		File "..\engine\xui\SC-ProgressGrid\*.maki"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\ScrollBar
		File "..\engine\xui\ScrollBar\*.xml"
		File "..\engine\xui\ScrollBar\*.m"
		File "..\engine\xui\ScrollBar\*.maki"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\updateSystem
		File "..\engine\xui\updateSystem\*.xml"
		File "..\engine\xui\updateSystem\*.m"
		File "..\engine\xui\updateSystem\*.maki"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\WasabiButton
		File "..\engine\xui\WasabiButton\*.xml"
		File "..\engine\xui\WasabiButton\*.m"
		File "..\engine\xui\WasabiButton\*.maki"

; Additional XUI Objects for widget devs

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\Layouts
		File "..\engine\xui\Layouts\*.xml"
		File "..\engine\xui\Layouts\*.m"
		File "..\engine\xui\Layouts\*.maki"

	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\KeepRatioLayer
		File "..\engine\xui\KeepRatioLayer\*.xml"
		File "..\engine\xui\KeepRatioLayer\*.m"
		File "..\engine\xui\KeepRatioLayer\*.maki"

; cPro::Flex
;	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\flex\scripts
;		File /nonfatal "..\engine\flex\scripts\*.m"
;		File /nonfatal "..\engine\flex\scripts\*.maki"

;	SetOutPath $INSTDIR\Plugins\ClassicPro\engine\flex\xml
;		File /nonfatal "..\engine\flex\xml\*.xml"
		
;	SetOutPath "$INSTDIR\Skins\cProFlex - iFlex"
;		File /nonfatal /r "${CPRO_WINAMP_SKINS}\cProFlex - iFlex\"
;	SetOutPath "$INSTDIR\Skins\cProFlex - Xenolith"
;		File /nonfatal /r "${CPRO_WINAMP_SKINS}\cProFlex - Xenolith\"

	SetOutPath "$INSTDIR\Skins"
		File "${CPRO_WINAMP_SKINS}\cPro__Bento.wal"
		
	RMDir /r "$INSTDIR\Skins\cPro - Big Bento\" 
	RMDir /r "$INSTDIR\Skins\cPro - Bento\" 
	RMDir /r "$INSTDIR\Skins\cPro_Bento\" 

; System files

	SetOutPath $INSTDIR\System
		AllowSkipFiles off
		Delete "${CPRO_WINAMP_SYSTEM}\ClassicProFlex.w5s"
		Delete "${CPRO_WINAMP_SYSTEM}\ClassicPro.w5s"
		Delete "${CPRO_WINAMP_SYSTEM}\ClassicPro.wbm"
		
; Sometimes this file is still open, so allow skip needs to be off
		File /nonfatal "${CPRO_WINAMP_SYSTEM}\ClassicPro.w5s"
		File /nonfatal "${CPRO_WINAMP_SYSTEM}\ClassicPro.wbm"
 
SectionEnd

SectionGroup "$(CPro_CProCustom)" CPro_Sec_CProCustom

	Section "$(CPro_cPlaylistPro)" CPro_Sec_cPlaylistPro
		
		SectionIn 1 2
		SetOutPath $INSTDIR\Plugins\ClassicPro\engine\xui\PlaylistPro
			File "..\engine\xui\PlaylistPro\*.xml"
			File "..\engine\xui\PlaylistPro\*.m"
			File "..\engine\xui\PlaylistPro\*.maki"
		
	SectionEnd
	
SectionGroupEnd

SectionGroup "$(CPro_WidgetsSection)" CPro_Sec_WidgetsSection

	Section "$(CPro_wBrowserPro)" CPro_Sec_wBrowserPro

		SectionIn 1
		
		SetOutPath "$INSTDIR\Plugins\ClassicPro\engine\widgets\Load"
			File "..\engine\widgets\Load\browserpro.xml"
 
		SetOutPath "$INSTDIR\Plugins\ClassicPro\engine\widgets\Data\BrowserPro"
			File "..\engine\widgets\Data\BrowserPro\*.m"
			File "..\engine\widgets\Data\BrowserPro\*.png"
			File "..\engine\widgets\Data\BrowserPro\*.maki"
			File "..\engine\widgets\Data\BrowserPro\*.xml"
			File "..\engine\widgets\Data\BrowserPro\*.mi"

		SetOutPath "$INSTDIR\Plugins\ClassicPro\engine\widgets\Data\BrowserPro\icons"
			File "..\engine\widgets\Data\BrowserPro\icons\*.png"

		SetOutPath "$INSTDIR\Plugins\ClassicPro\engine\widgets\Data\BrowserPro\source"
			File "..\engine\widgets\Data\BrowserPro\source\*.xml"			

		SetOutPath "$INSTDIR\Plugins\ClassicPro\engine\widgets"
			File "..\engine\widgets\cpro-widget-BrowserPro.nsi"

	SectionEnd

	Section "$(CPro_wAlbumArt)" CPro_Sec_wAlbumArt
	
		SectionIn 1
		SetOutPath "$INSTDIR\Plugins\ClassicPro\engine\widgets\Load"
			File "..\engine\widgets\Load\nowplaying.xml"

		SetOutPath "$INSTDIR\Plugins\ClassicPro\engine\widgets\Data\NowPlaying"
			File "..\engine\widgets\Data\NowPlaying\*.xml"
			File "..\engine\widgets\Data\NowPlaying\*.m"
			File "..\engine\widgets\Data\NowPlaying\*.maki"
			File "..\engine\widgets\Data\NowPlaying\*.png"
	
	SectionEnd

SectionGroupEnd

Section "-Leave"

; Registry entries
	WriteRegStr "HKLM" "Software\Microsoft\Windows\CurrentVersion\Uninstall\${CPRO_NAME}" "UninstallString" '"$INSTDIR\${CPRO_UNINSTALLER}.exe"'
	WriteRegStr "HKLM" "Software\Microsoft\Windows\CurrentVersion\Uninstall\${CPRO_NAME}" "InstallLocation" "$INSTDIR"
	WriteRegStr "HKLM" "Software\Microsoft\Windows\CurrentVersion\Uninstall\${CPRO_NAME}" "DisplayName" "${CPRO_NAME}${CPRO_CRS} v${CPRO_VERSION}"
	WriteRegStr "HKLM" "Software\Microsoft\Windows\CurrentVersion\Uninstall\${CPRO_NAME}" "DisplayIcon" "$INSTDIR\Plugins\ClassicPro\_installer\Images\icon.ico"
	WriteRegStr "HKLM" "Software\Microsoft\Windows\CurrentVersion\Uninstall\${CPRO_NAME}" "DisplayVersion" "${CPRO_VERSION}"
	WriteRegStr "HKLM" "Software\Microsoft\Windows\CurrentVersion\Uninstall\${CPRO_NAME}" "URLInfoAbout" "${CPRO_WEB_PAGE}"
	WriteRegStr "HKLM" "Software\Microsoft\Windows\CurrentVersion\Uninstall\${CPRO_NAME}" "HelpLink" "${CPRO_HELP_LINK}" 
	WriteRegStr "HKLM" "Software\Microsoft\Windows\CurrentVersion\Uninstall\${CPRO_NAME}" "Publisher" "${CPRO_COMPANY}"
	WriteRegDWORD "HKLM" "Software\Microsoft\Windows\CurrentVersion\Uninstall\${CPRO_NAME}" "NoModify" "1"
	WriteRegDWORD "HKLM" "Software\Microsoft\Windows\CurrentVersion\Uninstall\${CPRO_NAME}" "NoRepair" "1"

; Menu Start entries	
	SetShellVarContext all
		CreateDirectory "$SMPROGRAMS\Winamp\${CPRO_NAME}"
		CreateShortCut "$SMPROGRAMS\Winamp\${CPRO_NAME}\$(CPro_MenuStart1).lnk" "$INSTDIR\${CPRO_UNINSTALLER}.exe"
		CreateShortCut "$SMPROGRAMS\Winamp\${CPRO_NAME}\$(CPro_MenuStart2).lnk" "$INSTDIR\Plugins\ClassicPro\Whats new.txt"
		File /oname=$SMPROGRAMS\Winamp\${CPRO_NAME}\$(CPro_MenuStart3).url "Plugins\link.url"
		
	SetShellVarContext current

; Create uninstaller
	WriteUninstaller "$INSTDIR\${CPRO_UNINSTALLER}.exe"

	SetAutoClose false

	${If} $Cleanup_Check_WinampIni_B == ${BST_CHECKED}
		SetOutPath "$WINAMP_INI_DIR"
		File "Files\winamp.ini"
	${EndIf}

	${If} $Cleanup_Check_StudioXnf_B == ${BST_CHECKED}
		Delete $WINAMP_INI_DIR\studio.xnf
	${EndIf}
		
SectionEnd

;###########################################################################################
;#								INSTALLER DESCRIPTIONS SECTION 
;###########################################################################################

	!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
		!insertmacro MUI_DESCRIPTION_TEXT ${CPro_Sec_CProFiles} $(CPro_Desc_CProFiles)
		!insertmacro MUI_DESCRIPTION_TEXT ${CPro_Sec_wBrowserPro} $(CPro_Desc_wBrowserPro)
		!insertmacro MUI_DESCRIPTION_TEXT ${CPro_Sec_wAlbumArt} $(CPro_Desc_wAlbumArt)
		!insertmacro MUI_DESCRIPTION_TEXT ${CPro_Sec_WidgetsSection} $(CPro_Desc_WidgetsSection)
		!insertmacro MUI_DESCRIPTION_TEXT ${CPro_Sec_CProCustom} $(CPro_Desc_CProCustom)
		!insertmacro MUI_DESCRIPTION_TEXT ${CPro_Sec_cPlaylistPro} $(CPro_Desc_cPlaylistPro)
	!insertmacro MUI_FUNCTION_DESCRIPTION_END

;###########################################################################################
;#										UNINSTALLER
;###########################################################################################

	ShowUninstDetails "show"

Function un.onInit

; Language
	StrCpy $LANG_TITLE $(CPro_Un_Language_Title)
	!insertmacro MUI_UNGETLANGUAGE
	InitPluginsDir
		
FunctionEnd

Function un.My_GUIInit

	FindWindow $0 "#32770" "" $HWNDPARENT
	GetDlgItem $0 $HWNDPARENT 1028
	EnableWindow $0 1
	Linker::link /NOUNLOAD $0 "${CPRO_BT}"

FunctionEnd

Function un.onGUIEnd

	Linker::Unload

FunctionEnd

Section "-Un.Pre"

	DetailPrint "$(CPro_Winamp_Path)"
		Call un.GetWinampIniPath	
		
SectionEnd

Section "-Un.Uninstall"

	SetAutoClose "false"
	DetailPrint "$(CPro_Ini)"
		WriteINIStr "$WINAMP_INI_DIR\winamp.ini" "Winamp" "skin" "Bento"
		FlushINI "$WINAMP_INI_DIR\winamp.ini"	
	RMDir /r "$INSTDIR\Plugins\ClassicPro"
	Delete "$INSTDIR\Skins\cPro__Bento.wal"
	
	SetShellVarContext all
		RMDir /r "$SMPROGRAMS\Winamp\${CPRO_NAME}"
	SetShellVarContext current
	
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${CPRO_NAME}"	
	Delete /REBOOTOK "$INSTDIR\${CPRO_UNINSTALLER}.exe"
	
SectionEnd

;###########################################################################################
;#								       CPRO - THE END
;###########################################################################################