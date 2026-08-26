# Windhawk Configuration

Windhawk is a customization engine for the Windows taskbar, start menu, and explorer.

## Active Mods:

1. `taskbar-autohide-instant-show` (v2.2)
2. `taskbar-auto-hide-when-maximized` (v1.2.6)
3. `taskbar-tray-system-icon-tweaks` (v1.3)
4. `taskbar-height-and-icon-size` (v1.3.7)
5. `windows-11-taskbar-styler` (v1.8)
6. `windows-11-start-menu-styler` (v1.7)
7. `windows-11-notification-center-styler` (v1.6)
8. `explorer-details-better-file-sizes` (v1.5.1)

### Windows 11 Taskbar Styler

```yaml
theme: FrostyGlass
styleConstants:
  - BorderBrush=<LinearGradientBrush StartPoint="0,0" EndPoint="0,1"><GradientStop Color="#15808080" Offset="0.0" /><GradientStop Color="#15404040" Offset="0.25" /><GradientStop Color="#15808080" Offset="1" /></LinearGradientBrush>
controlStyles:
  - target: Grid#SystemTrayFrameGrid
    styles:
      - Padding=8,0,16,0
  - target: ' Taskbar.TaskbarFrame#TaskbarFrame > Grid#RootGrid'
    styles:
      - Padding=8,0,8,0
  - target: SystemTray.OmniButton#NotificationCenterButton
    styles:
      - Padding=0,0,-8,0
      - Margin=0,4,0,4
  - target: SystemTray.ChevronIconView
    styles:
      - Margin=0,4,0,4
      - Padding=0
      - CornerRadius=8
      - MinWidth=32
themeResourceVariables:
  - ''
clickThroughTaskbar: 0
xamlDiagnosticsHandling: alert
```

### Windows 11 Start Menu Styler

Sunvalley (legacy)

### Windows 11 Notification Center Styler

```yaml
theme: ''
styleConstants:
  - CommonBgBrush=<WindhawkBlur BlurAmount="25" TintColor="#25323232"/>
  - CommonBorderBrush=<SolidColorBrush Color="#10FFFFFF"/>
  - CommonBorderThickness=1,1,1,1
  - CommonCornerRadius=8
  - thumbnailImageSize=300
controlStyles:
  - target: Grid#NotificationCenterGrid
    styles:
      - Background:=$CommonBgBrush
      - BorderBrush:=$CommonBorderBrush
      - BorderThickness=$CommonBorderThickness
      - CornerRadius=$CommonCornerRadius
  - target: Grid#CalendarCenterGrid
    styles:
      - Background:=$CommonBgBrush
      - BorderBrush:=$CommonBorderBrush
      - BorderThickness=$CommonBorderThickness
      - CornerRadius=$CommonCornerRadius
  - target: ScrollViewer#CalendarControlScrollViewer
    styles:
      - Background=Transparent
  - target: Border#CalendarHeaderMinimizedOverlay
    styles:
      - Background=Transparent
  - target: ActionCenter.FocusSessionControl#FocusSessionControl > Grid#FocusGrid
    styles:
      - Background=Transparent
  - target: MenuFlyoutPresenter > Border
    styles:
      - Background:=<WindhawkBlur BlurAmount="25" TintColor="#00000000"/>
      - BorderBrush:=$CommonBorderBrush
      - BorderThickness=$CommonBorderThickness
      - CornerRadius=$CommonCornerRadius
      - Padding=2,4,2,4
  - target: MenuFlyoutItem
    styles:
      - FocusVisualPrimaryThickness=0,0,0,0
      - FocusVisualSecondaryThickness=0,0,0,0
      - UseSystemFocusVisuals=False
      - BorderThickness=0,0,0,0
  - target: Border#JumpListRestyledAcrylic
    styles:
      - Background:=$CommonBgBrush
      - BorderBrush:=$CommonBorderBrush
      - BorderThickness=$CommonBorderThickness
      - CornerRadius=$CommonCornerRadius
      - Margin=-2,-2,-2,-2
  - target: Grid#ControlCenterRegion
    styles:
      - Background:=$CommonBgBrush
      - BorderBrush:=$CommonBorderBrush
      - BorderThickness=$CommonBorderThickness
      - CornerRadius=$CommonCornerRadius
  - target: Windows.UI.Xaml.Controls.Grid#L1Grid > Border
    styles:
      - Background:=<SolidColorBrush Color="Transparent"/>
  - target: Windows.UI.Xaml.Controls.Grid#MediaTransportControlsRegion
    styles:
      - Background:=$CommonBgBrush
      - BorderBrush:=$CommonBorderBrush
      - BorderThickness=$CommonBorderThickness
      - CornerRadius=$CommonCornerRadius
  - target: Grid#MediaTransportControlsRoot
    styles:
      - Background:=<SolidColorBrush Color="Transparent"/>
  - target: ContentPresenter#PageContent
    styles:
      - Background:=<SolidColorBrush Color="Transparent"/>
  - target: ContentPresenter#PageContent > Grid > Border
    styles:
      - Background:=<SolidColorBrush Color="Transparent"/>
  - target: QuickActions.ControlCenter.AccessibleWindow#PageWindow > ContentPresenter > Grid#FullScreenPageRoot
    styles:
      - Background:=<SolidColorBrush Color="Transparent"/>
  - target: QuickActions.ControlCenter.AccessibleWindow#PageWindow > ContentPresenter > Grid#FullScreenPageRoot > ContentPresenter#PageHeader
    styles:
      - Background:=<SolidColorBrush Color="Transparent"/>
  - target: ContentControl#PageHeaderContentControl
    styles:
      - Width=64
  - target: ScrollViewer#ListContent
    styles:
      - Background:=<SolidColorBrush Color="Transparent"/>
  - target: ActionCenter.FlexibleToastView#FlexibleNormalToastView
    styles:
      - Background:=<SolidColorBrush Color="Transparent"/>
  - target: Border#ToastBackgroundBorder2
    styles:
      - Background:=$CommonBgBrush
      - BorderBrush:=$CommonBorderBrush
      - BorderThickness=$CommonBorderThickness
      - CornerRadius=$CommonCornerRadius
  - target: Border#ToastBackgroundBorder
    styles:
      - Background:=$CommonBgBrush
      - BorderBrush:=$CommonBorderBrush
      - BorderThickness=$CommonBorderThickness
      - CornerRadius=$CommonCornerRadius
  - target: JumpViewUI.SystemItemListViewItem
    styles:
      - FocusVisualPrimaryThickness=0,0,0,0
      - FocusVisualSecondaryThickness=0,0,0,0
      - UseSystemFocusVisuals=False
      - BorderThickness=0,0,0,0
  - target: JumpViewUI.JumpListListViewItem
    styles:
      - FocusVisualPrimaryThickness=0,0,0,0
      - FocusVisualSecondaryThickness=0,0,0,0
      - UseSystemFocusVisuals=False
      - BorderThickness=0,0,0,0
  - target: JumpViewUI.SystemItemListViewItem > Grid#LayoutRoot > Border#BackgroundBorder
    styles:
      - BorderThickness=0,0,0,0
      - BorderBrush:=<SolidColorBrush Color="Transparent"/>
  - target: JumpViewUI.JumpListListViewItem > Grid#LayoutRoot > Border#BackgroundBorder
    styles:
      - BorderThickness=0,0,0,0
      - BorderBrush:=<SolidColorBrush Color="Transparent"/>
  - target: ActionCenter.FlexibleItemView
    styles:
      - CornerRadius=$CommonCornerRadius
  - target: ControlCenter.MediaTransportControls#MediaTransportControls > Windows.UI.Xaml.Controls.Grid#MediaTransportControlsRegion
    styles:
      - Height=Auto
  - target: Windows.UI.Xaml.Controls.Grid#ThumbnailImage
    styles:
      - Width=$thumbnailImageSize
      - Height=$thumbnailImageSize
      - HorizontalAlignment=Center
      - VerticalAlignment=Top
      - Grid.Column=1
      - Margin=0,2,0,45
  - target: Windows.UI.Xaml.Controls.Grid#ThumbnailImage > Windows.UI.Xaml.Controls.Border
    styles:
      - CornerRadius=6
  - target: Windows.UI.Xaml.Controls.StackPanel#PrimaryAndSecondaryTextContainer
    styles:
      - VerticalAlignment=Bottom
      - Grid.Column=0
  - target: Windows.UI.Xaml.Controls.StackPanel#PrimaryAndSecondaryTextContainer > Windows.UI.Xaml.Controls.TextBlock#TitleText
    styles:
      - TextAlignment=Center
  - target: Windows.UI.Xaml.Controls.StackPanel#PrimaryAndSecondaryTextContainer > Windows.UI.Xaml.Controls.TextBlock#SubtitleText
    styles:
      - TextAlignment=Center
  - target: GridViewItem[1] > * > Rectangle#HorizontalDecreaseRect
    styles:
      - Width=>horizontalDecreaseRectWidth1
      - MinWidth={{horizontalDecreaseRectWidth1 + 8}}
  - target: GridViewItem[2] > * > Rectangle#HorizontalDecreaseRect
    styles:
      - Width=>horizontalDecreaseRectWidth2
      - MinWidth={{horizontalDecreaseRectWidth2 + 8}}
  - target: GridViewItem[3] > * > Rectangle#HorizontalDecreaseRect
    styles:
      - Width=>horizontalDecreaseRectWidth3
      - MinWidth={{horizontalDecreaseRectWidth3 + 8}}
  - target: Windows.UI.Xaml.Controls.Primitives.Thumb#HorizontalThumb
    styles:
      - Margin=-8,0,0,0
themeResourceVariables:
  - ''
```

### Windows 11 tray system icon tweaks

```yaml
hideVolumeIcon: 0
hideNetworkIcon: 0
hideBatteryIcon: 0
grayscaleBatteryIcon: 0
hideMicrophoneIcon: 0
hideGeolocationIcon: 0
hideStudioEffectsIcon: 0
hideRecallIcon: 0
hideLanguageBar: 0
hideLanguageSupplementaryIcons: 0
hideBellIcon: never
showDesktopButtonWidth: 12
```

### Taskbar height and icon size

```yaml
TaskbarHeight: 52
IconSize: 26
TaskbarButtonWidth: 45
IconSizeSmall: 30
TaskbarButtonWidthSmall: 45
```

### Taskbar auto-hide when maximized

```yaml
mode: intersected
foregroundWindowOnly: 0
excludedPrograms:
  - ''
primaryMonitorOnly: 0
oldTaskbarOnWin11: 0
```

### Taskbar auto-hide instant show

```yaml
animationType: slideFade
showSpeedup: 400
hideSpeedup: 400
showDuration: 100
hideDuration: 100
frameRate: 120
unhideDelay: 1
hideDelay: 1
oldTaskbarOnWin11: 0
edgeDetection: 0
```

### Explorer details better file sizes

```yaml
calculateFolderSizes: everything
sortSizesMixFolders: 1
disableKbOnlySizes: 1
useIecTerms: 0
```
