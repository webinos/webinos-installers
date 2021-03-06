RequestExecutionLevel admin

!define DEBUGBUILD 0
; For help check http://nsis.sourceforge.net/Docs/Chapter4.html#4.2.1

SetCompressor lzma

!define SRCROOT "..\.."
!define RedistPath "bin"

; The GUI elements
!include "MUI.nsh"

; Set path for windows to set the webinos in path
!include "setpath.nsi"
; To manipulate registry
!include "RegistryMacros.nsi"  
; Various functions and macros used in the installer
!include "HelperFunctions.nsi"  
; File association management
!include "FileAssociation.nsh"

!define PRODUCT_ICON "webinos.ico"
!define INSTALLER_BANNER "installBanner.bmp"

!define PRODUCT_NAME "webinos"
!define VERSION "1.0.0-webinos beta"

; XP Compatibility
!ifndef SF_SELECTED
 !define SF_SELECTED 1
!endif

;--------------------------------
;Configuration

  ;General

  OutFile "${PRODUCT_NAME}-install-${VERSION}.exe"

  ShowInstDetails show
  ShowUninstDetails show

  ;Folder selection page
  InstallDir "$PROGRAMFILES\${PRODUCT_NAME}"
  
  ;Remember install folder
  InstallDirRegKey HKCU "Software\${PRODUCT_NAME}" ""

;--------------------------------
;Modern UI Configuration

  Name "${PRODUCT_NAME} ${VERSION}"

  !define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of ${PRODUCT_NAME}, an EU funded project aiming to deliver a platform for web applications across mobile, PC, home media (TV) and in-car devices.\r\n\r\nNote that the Windows version of ${PRODUCT_NAME} only runs on XP, or higher.\r\n\r\n\r\n"

  !define MUI_COMPONENTSPAGE_TEXT_TOP "Select the components to install/upgrade.  Stop any ${PRODUCT_NAME} processes if they are running.  All DLLs are installed locally."

  !define MUI_COMPONENTSPAGE_SMALLDESC
  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_TEXT "Start webinos now"
  !define MUI_FINISHPAGE_LINK "Visit Webinos.org"
  !define MUI_FINISHPAGE_LINK_LOCATION "http://webinos.org"
  !define MUI_FINISHPAGE_RUN_FUNCTION "FinishRun"
  !define MUI_FINISHPAGE_NOCLOSE
  !define MUI_ABORTWARNING
  !define MUI_ICON "${PRODUCT_ICON}"
  !define MUI_UNICON "${PRODUCT_ICON}"
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "${INSTALLER_BANNER}"
  !define MUI_UNFINISHPAGE_NOAUTOCLOSE
  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES  
  !insertmacro MUI_UNPAGE_FINISH


;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"
  
;--------------------------------
;Language Strings

  LangString DESC_SecWebinosUserSpace ${LANG_ENGLISH} "Install ${PRODUCT_NAME} core components."
	
;--------------------------------
;Reserve Files
  
  ;Things that need to be extracted on first (keep these lines before any File command!)
  ;Only useful for BZIP2 compression
  
  ReserveFile "${INSTALLER_BANNER}"
  ReserveFile "${NSISDIR}\Plugins\InstallOptions.dll"

;--------------------------------
;Installer Sections

!define SHCNE_ASSOCCHANGED 0x08000000
!define SHCNF_IDLIST 0
 
Function RefreshShellIcons
  ; By jerome tremblay - april 2003
  System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v \
  (${SHCNE_ASSOCCHANGED}, ${SHCNF_IDLIST}, 0, 0)'
FunctionEnd

Function FinishRun
  ExecShell "" "$INSTDIR\bin\wrt\webinosNodeServiceUI.exe"
	Sleep 10000
	ExecShell "" "$INSTDIR\bin\wrt\webinosBrowser.exe"
FunctionEnd

Function .onInit
  ClearErrors

# Verify that user has admin privs
  UserInfo::GetName
  IfErrors ok
  Pop $R0
  UserInfo::GetAccountType
  Pop $R1
  StrCmp $R1 "Admin" ok
    Messagebox MB_OK "Administrator privileges required to install ${PRODUCT_NAME} [$R0/$R1]"
    Abort
  ok:

 # Extract Extra windows Resources
 # !insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "MyCustomPage.ini" "MyCustomPageName"
 # Check is node app is running
  !insertmacro CheckAppRunning
  
# Delete previous start menu
  RMDir /r $SMPROGRAMS\${PRODUCT_NAME}

FunctionEnd

;--------------------
;Pre-install section

Section -pre

SectionEnd

Section "${PRODUCT_NAME} Core Components" SecWebinosUserSpace
SectionIn RO

  SetOverwrite on
  
  DetailPrint "Installing Core components"
  
  SetOutPath "$INSTDIR\webinos-pzh"
  File /r /x zombie /x jasmine-node /x *.ipch /x .gitignore /x android /x test /x pom.xml /x wscript /x *.gyp /x obj /x *.sln /x *.vcxproj* /x *.sdf /x *.suo /x *.cpp /x *.h /x *.c /x *.cc /x *.exp /x *.ilk /x *.pdb /x *.lib /x .git /x platform /x examples "${SRCROOT}\webinos-pzh\*.*"
    
  SetOutPath "$INSTDIR\webinos-pzp"
  File /r /x zombie /x jasmine-node /x *.ipch /x .gitignore /x android /x test /x pom.xml /x wscript /x *.gyp /x obj /x *.sln /x *.vcxproj* /x *.sdf /x *.suo /x *.cpp /x *.h /x *.c /x *.cc /x *.exp /x *.ilk /x *.pdb /x *.lib /x .git /x platform /x examples "${SRCROOT}\webinos-pzp\*.*"

  SetOutPath "$INSTDIR\webinos-pzp\web_root\test"
  File /r "${SRCROOT}\webinos-pzp\web_root\test\*.*"

  ;
  ; PZH apis.
  ;
  ; Need to manually install API test pages due to exclusion of test folders above.
  SetOutPath "$INSTDIR\webinos-pzh\node_modules\webinos-utilities\node_modules\webinos-api-test\test"
  File /r "${SRCROOT}\webinos-pzh\node_modules\webinos-utilities\node_modules\webinos-api-test\test\*.*"
  
  ; 
  ; PZP apis
  ;
  ; Need to manually install API test pages due to exclusion of test folders above.
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-utilities\node_modules\webinos-api-test\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-utilities\node_modules\webinos-api-test\test\*.*"

  ; webinos-api-app2app
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-app2app\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-app2app\test\*.*"
  
  ; webinos-api-applauncher
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-applauncher\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-applauncher\test\*.*"
  
  ; webinos-api-contacts
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-contacts\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-contacts\test\*.*"
  
  ; webinos-api-deviceDiscovery
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-deviceDiscovery\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-deviceDiscovery\test\*.*"
  
  ; webinos-api-deviceOrientation
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-deviceOrientation\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-deviceOrientation\test\*.*"
  
  ; webinos-api-deviceStatus
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-deviceStatus\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-deviceStatus\test\*.*"
  
  ; webinos-api-events
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-events\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-events\test\*.*"
  
  ; webinos-api-file
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-file\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-file\test\*.*"
  
  ; webinos-api-geolocation
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-geolocation\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-geolocation\test\*.*"
  
  ; webinos-api-iot
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-iot\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-iot\test\*.*"

  ; webinos-api-mediaContent
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-mediaContent\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-mediaContent\test\*.*"
  
  ; webinos-api-mediaplay
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-mediaplay\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-mediaplay\test\*.*"
  
  ; webinos-api-nfc
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-nfc\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-nfc\test\*.*"
  
  ; webinos-api-payment
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-payment\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-payment\test\*.*"
	
  ; webinos-api-policy
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-policy\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-policy\test\*.*"
  
  ; webinos-api-tv
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-tv\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-tv\test\*.*"
  
  /*
  ; webinos-api-vehicle
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-vehicle\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-vehicle\test\*.*"
  
  ; webinos-api-webNotification
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-api-webNotification\test"
  File /r "${SRCROOT}\webinos-pzp\node_modules\webinos-api-webNotification\test\*.*"
  */
  
  ; These are required in the node_modules folder so that certificate_manager can find them.	
  SetOutPath "$INSTDIR\webinos-pzp"
  File "${RedistPath}\Openssl\libeay32.dll"
  File "${RedistPath}\Openssl\ssleay32.dll"

  ; They are also required in the dcrypt folder (some reason they are not loaded using PATH)	
  SetOutPath "$INSTDIR\webinos-pzp\node_modules\webinos-widget\node_modules\dcrypt\build\Release"
  File "${RedistPath}\Openssl\libeay32.dll"
  File "${RedistPath}\Openssl\ssleay32.dll"
    
  SetOutPath "$INSTDIR"
  
  File "${PRODUCT_ICON}"

  SetOutPath "$INSTDIR\bin"
  File "${RedistPath}\node.exe"
	File /r "${RedistPath}\wrt" 
	File "${RedistPath}\zip.dll"
	File "${RedistPath}\libexpat.dll"

	; Start the ui application
	WriteRegStr HKCU "SOFTWARE\Microsoft\Windows\CurrentVersion\Run\" "${PRODUCT_NAME}UI"  "$INSTDIR\bin\wrt\webinosNodeServiceUI.exe"

	; Write the runtime configuration data (location of node.exe and working directory etc)
	${StrRep} $1 $INSTDIR\bin "\" "\\"
	${StrRep} $2 $INSTDIR "\" "\\"
	FileOpen $0 $INSTDIR\bin\wrt\wrt_config.json w
	FileWrite $0 "{$\"nodePath$\": $\"$1$\",$\"workingDirectoryPath$\": $\"$2$\",$\"pzp_nodeArgs$\": $\"webinos-pzp\webinos_pzp.js --widgetServer --branding=webinos$\",$\"pzh_nodeArgs$\": $\"webinos-pzh\webinos_pzh.js$\"}"
	FileClose $0
	
	; Write default pzh configuration (not enabled by default)
	CreateDirectory $APPDATA\webinosPzh\wrt
	FileOpen $0 $APPDATA\webinosPzh\wrt\webinos_pzh.json w
	FileWrite $0 "{$\"instance$\": $\"0$\",$\"showOutput$\": $\"0$\",$\"enabled$\": $\"0$\"}"
	FileClose $0

	; Write the default pzp configuration (enabled by default)
	CreateDirectory $APPDATA\webinos\wrt
	FileOpen $0 $APPDATA\webinos\wrt\webinos_pzp.json w
	FileWrite $0 "{$\"instance$\": $\"0$\",$\"showOutput$\": $\"0$\",$\"enabled$\": $\"1$\"}"
	FileClose $0

	; Write the app store configuration.
	FileOpen $0 $APPDATA\webinos\wrt\webinos_stores.json w
	FileWrite $0 "[{$\"name$\": $\"Megastore$\",$\"description$\": $\"Fraunhofer FOKUS Megastore$\",$\"location$\": $\"http://webinos.fokus.fraunhofer.de/store/$\",$\"logo$\": $\"http://www.fokus.fraunhofer.de/en/fame/_images/_logos/megastore_logo.png$\"},{$\"name$\": $\"UbiApps$\",$\"description$\": $\"UbiApps demonstration webinos app store$\",$\"location$\": $\"http://webinos.two268.com/$\",$\"logo$\": $\"http://ubiapps.com/files/2012/05/ubiapps-120.png$\"}]"
	FileClose $0
	
	DetailPrint "OpenSSL DLLs" 

  SetOverwrite on
  SetOutPath "$INSTDIR\bin"
  File "${RedistPath}\Openssl\libeay32.dll"
  File "${RedistPath}\Openssl\ssleay32.dll"

	DetailPrint "Microsoft Visual C 10.0 Runtime DLL" 

  SetOverwrite on
  SetOutPath "$INSTDIR\bin"
  File "${RedistPath}\Microsoft.VC100.CRT\msvcp100.dll"
  File "${RedistPath}\Microsoft.VC100.CRT\msvcr100.dll"

  File "${RedistPath}\Microsoft.VC90.CRT\Microsoft.VC90.CRT.manifest"
  File "${RedistPath}\Microsoft.VC90.CRT\msvcr90.dll"
	
	DetailPrint "Bonjour binaries" 
	SetOverwrite on
	SetOutPath "$INSTDIR\bin"
	File "${RedistPath}\Bonjour\mdnsNSP.DLL"

	DetailPrint "GTK binaries" 
	SetOverwrite on
	SetOutPath "$INSTDIR\bin"
	File "${RedistPath}\GTK\freetype6.DLL"
	File "${RedistPath}\GTK\libcairo-2.DLL"
	File "${RedistPath}\GTK\libexpat-1.DLL"
	File "${RedistPath}\GTK\libfontconfig-1.DLL"
	File "${RedistPath}\GTK\zlib1.DLL"
	File "${RedistPath}\GTK\libpng14-14.DLL"
	
  DetailPrint "Preinstalling widgets"
  SetOverwrite on
  SetOutPath $APPDATA\webinos\wrt\widgetStore
  File /r "${RedistPath}\preinstall\*.*"
  
  SetShellVarContext all
  SetOverwrite on
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"

	; Register file association
	WriteRegStr HKCR ".wgt" "" "W3C.widget"
	WriteRegStr HKCR "W3C.widget" "" "W3C widget"
	WriteRegStr HKCR "W3C.widget\DefaultIcon" "" '"$INSTDIR\bin\wrt\webinosBrowser.exe",-108'
	WriteRegStr HKCR "W3C.widget\shell\open\command" "" '"$INSTDIR\bin\wrt\webinosBrowser.exe" --webinos-side-load "%1"'
			
	Call RefreshShellIcons
				
SectionEnd

;--------------------
;Post-install section

Section -post

  SetOverwrite on
  
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall ${PRODUCT_NAME}.lnk" "$INSTDIR\Uninstall.exe"
  
  Var /GLOBAL NodeExe
  IfFileExists "$INSTDIR\bin\node.exe" "" tryGlobalNode
	StrCpy $NodeExe "$INSTDIR\bin\node.exe"
	Goto addClientStartShortcut
 
  tryGlobalNode:
    StrCpy $NodeExe "node.exe"
    
addClientStartShortcut:
  ;Set the "start in" parameter of the shortcut
  SetOutPath "$INSTDIR"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\bin\wrt\webinosBrowser.exe"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME} service.lnk" "$INSTDIR\bin\wrt\webinosNodeServiceUI.exe"
    
  writeRegistryInfo:
  ; Store install folder in registry
  WriteRegStr HKLM "SOFTWARE\${PRODUCT_NAME}\" "" $INSTDIR

  ; Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  ; Show up in Add/Remove programs
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}\" "DisplayName" "${PRODUCT_NAME} ${VERSION}"
  WriteRegExpandStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}\" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}\" "DisplayIcon" "$INSTDIR\${PRODUCT_ICON}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}\" "DisplayVersion" "${VERSION}"
  
SectionEnd

;--------------------------------
;Descriptions

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SecWebinosUserSpace} $(DESC_SecWebinosUserSpace)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Function un.onInit
  ClearErrors
  UserInfo::GetName
  IfErrors ok
  Pop $R0
  UserInfo::GetAccountType
  Pop $R1
  StrCmp $R1 "Admin" ok
    Messagebox MB_OK "Administrator privileges required to uninstall ${PRODUCT_NAME} [$R0/$R1]"
    Abort
  ok:
FunctionEnd

Section "Uninstall"

  ; Required to handle shortcuts properly on Vista/7
  SetShellVarContext all

 # Check is node app is running
  !insertmacro CheckAppRunning

  DetailPrint "Removing ${PRODUCT_NAME} from path"
  Push "$INSTDIR\bin"
  Call un.RemoveFromPath

  
  DetailPrint "Removing shortcuts"
  RMDir /r $SMPROGRAMS\${PRODUCT_NAME}

  DetailPrint "Removing installation files"
  RMDir /r "$INSTDIR"
  
  DetailPrint "Removing registry entries"
  DeleteRegKey HKCR "${PRODUCT_NAME}File"
  DeleteRegKey HKLM SOFTWARE\${PRODUCT_NAME}
  DeleteRegKey HKCU "Software\${PRODUCT_NAME}"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"

  DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${PRODUCT_NAME}UI"

  ${UnRegisterExtension} ".wgt" "W3C widget"
    
SectionEnd
