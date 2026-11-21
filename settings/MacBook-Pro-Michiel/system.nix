# Captured from this Mac by `nix run .#capture-settings`; edits here are
# overwritten by the next capture. Put settings both Macs share in
# ../shared.nix and paths that should never be captured in ../ignore.txt.
{
  applications = {
    finder = {
      menuBar = {
        view = {
          showPathBar = true;
          showSidebar = true;
          showStatusBar = true;
        };
      };
      settings = {
        advanced = {
          showAllFilenameExtensions = true;
        };
        general = {
          showTheseItemsOnTheDesktop = {
            cdsDvdsAndiPods = true;
            externalDisks = true;
            hardDisks = true;
          };
        };
      };
    };
    systemSettings = {
      accessibility = {
        audio = {
          backgroundSoundsOptions = {
            timer = false;
          };
        };
        keyboard = {
          accessibilityKeyboardOptions = {
            fadeAfter = 15.0;
          };
          slowKeys = false;
          stickyKeys = false;
          stickyKeysOptions = {
            pressTheShiftKeyFiveTimesToToggleStickyKeys = false;
          };
        };
        pointerControl = {
          trackpadOptions = {
            useTrackpadForScrolling = true;
          };
        };
        readAndSpeak = {
          typingFeedback = {
            characters = true;
            modifierKeys = false;
            selectionChanges = false;
            words = true;
          };
        };
        subtitlesAndCaptioning = {
          showAutomaticallyWhenLanguagesDoNotMatch = false;
        };
        zoom = {
          useKeyboardShortcutsToZoom = false;
        };
      };
      appleIntelligenceAndSiri = {
        siri = {
          enable = true;
        };
      };
      battery = {
        energyMode = {
          onBattery = "Automatic";
          onPowerAdapter = "High Power";
        };
        options = {
          preventAutomaticSleepingOnPowerAdapterWhenTheDisplayIsOff = true;
          slightlyDimTheDisplayOnBattery = true;
          wakeForNetworkAccess = "Only on Power Adapter";
        };
      };
      desktopAndDock = {
        desktopAndStageManager = {
          showWindowsFromAnApplication = "One at a Time";
        };
        dock = {
          automaticallyHideAndShowTheDock = {
            enabled = true;
          };
          size = 30;
        };
        hotCorners = {
          bottomRight = {
            action = "Quick Note";
          };
        };
        missionControl = {
          groupWindowsByApplication = true;
          shortcuts = {
            applicationWindows = "-";
            missionControl = "-";
            showDesktop = "-";
          };
        };
        windows = {
          dragWindowsToLeftOrRightEdgeOfScreenToTile = false;
          dragWindowsToMenuBarToFillScreen = false;
        };
      };
      general = {
        dateAndTime = {
          setTimeZoneAutomaticallyUsingYourCurrentLocation = true;
          source = "time.euro.apple.com";
          timeZone = "Europe/Amsterdam";
        };
        languageAndRegion = {
          applications = {
            "app.solomd" = [
              "en"
            ];
          };
          preferredLanguages = [
            "en-GB"
            "nl-NL"
          ];
          region = "en_NL";
        };
        sharing = {
          contentCaching = false;
          fileSharing = false;
          fileSharingOptions = {
            sharedFolders = {
              "/Users/michielbruins/Downloads" = "Downloads";
            };
          };
          mediaSharing = {
            shareMediaWithGuests = false;
          };
          printerSharing = false;
          remoteApplicationScripting = false;
          remoteApplicationScriptingOptions = {
            allowAccessFor = "Only these users";
          };
          remoteManagement = false;
          screenSharing = false;
          screenSharingOptions = {
            allowAccessFor = "Only these users";
          };
        };
        softwareUpdate = {
          automaticallyDownloadNewUpdatesWhenAvailable = true;
          automaticallyInstallApplicationUpdatesFromTheAppStore = true;
          automaticallyInstallMacOSUpdates = true;
          automaticallyInstallSystemDataFilesAndSecurityUpdates = true;
        };
      };
      keyboard = {
        delayUntilRepeat = 15;
        keyRepeatRate = 2;
        keyboardNavigation = true;
        keyboardShortcuts = {
          accessibility = {
            decreaseContrast = false;
            increaseContrast = false;
            invertColors = false;
          };
          inputSources = {
            selectNextSourceInInputMenu = "⌃⌥Space";
            selectThePreviousInputSource = "⌃Space";
          };
          missionControl = {
            moveLeftASpace = true;
            moveRightASpace = true;
          };
          services = {
            "com.apple.ChineseTextConverterService - Convert Text from Simplified to Traditional Chinese - convertTextToTraditionalChinese" =
              false;
            "com.apple.ChineseTextConverterService - Convert Text from Traditional to Simplified Chinese - convertTextToSimplifiedChinese" =
              false;
            "com.apple.Dictionary - Look Up in Dictionary - doLookupService" = true;
            "com.apple.FolderActionsSetup - Folder Actions Setup - openFilesFromPasteboard" = false;
            "com.apple.QuickTime.service.encodeSelectedAudioFiles - Encode Selected Audio Files - runWorkflowAsService" =
              false;
            "com.apple.Safari - Search With %WebSearchProvider@ - searchWithWebSearchProvider" = false;
            "com.apple.Stickies - Make Sticky - makeStickyFromTextService" = true;
            "com.apple.Terminal - New Terminal Tab at Folder - newTerminalAtFolder" = false;
            "com.apple.Terminal - New Terminal at Folder - newTerminalAtFolder" = false;
            "com.apple.Terminal - Open man Page in Terminal - openManPage" = false;
            "com.apple.Terminal - Search man Page Index in Terminal - searchManPages" = false;
            "com.apple.services.encodeSelectedVideoFiles - Encode Selected Video Files - runWorkflowAsService" =
              false;
            "com.apple.services.setDesktopPicture - Set Desktop Picture - runWorkflowAsService" = false;
            "dev.warp.Warp-Stable - New Warp Tab Here - openTab" = false;
            "dev.warp.Warp-Stable - New Warp Window Here - openWindow" = false;
            "mega.mac - MEGA - handleItems" = false;
          };
          spotlight = {
            showFinderSearchWindow = false;
            showSpotlightSearch = false;
          };
        };
        textInput = {
          addPeriodWithDoubleSpace = true;
          automaticallySwitchToADocumentsInputSource = true;
          capitalizeWordsAutomatically = true;
          inputSources = [
            "com.apple.keylayout.ABC"
          ];
        };
        useF1F2EtcKeysAsStandardFunctionKeys = false;
      };
      lockScreen = {
        turnDisplayOffOnBatteryWhenInactive = "For 10 minutes";
        turnDisplayOffOnPowerAdapterWhenInactive = "For 20 minutes";
      };
      menuBar = {
        batteryOptions = {
          showPercentage = true;
        };
        clock = {
          showAmPm = true;
          showTheDayOfTheWeek = true;
        };
        display = "Always Show";
        sound = "Always Show";
      };
      network = {
        firewall = {
          firewall = false;
          options = {
            automaticallyAllowBuiltInSoftwareToReceiveIncomingConnections = true;
            automaticallyAllowDownloadedSignedSoftwareToReceiveIncomingConnections = true;
            blockAllIncomingConnections = false;
            enableStealthMode = false;
          };
        };
      };
      privacyAndSecurity = {
        analyticsAndImprovements = {
          shareMacAnalytics = false;
          shareWithAppDevelopers = false;
        };
        appleAdvertising = {
          personalizedAds = true;
        };
      };
      sound = {
        soundEffects = {
          alertVolume = 0.0;
        };
      };
      spotlight = {
        resultsFromClipboard = true;
        searchResults = {
          appStore = true;
          apps = true;
          books = true;
          calculator = true;
          calendar = true;
          contacts = true;
          dictionary = true;
          files = true;
          folders = true;
          games = true;
          iPhoneApps = true;
          mail = true;
          menuItems = true;
          messages = true;
          music = true;
          notes = true;
          phone = true;
          photos = true;
          podcasts = true;
          reminders = true;
          safari = true;
          shortcuts = true;
          systemSettings = true;
          tips = true;
          voiceMemos = true;
        };
      };
      trackpad = {
        pointAndClick = {
          click = "Medium";
          trackingSpeed = 0.875;
        };
        scrollAndZoom = {
          rotate = true;
          zoomInOrOut = true;
        };
      };
      wallpaper = {
        startScreenSaver = "After 2 minutes";
      };
    };
  };
}
