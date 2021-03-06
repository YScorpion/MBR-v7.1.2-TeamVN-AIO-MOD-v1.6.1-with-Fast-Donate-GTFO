; #FUNCTION# ====================================================================================================================
; Name ..........: IsWeakBase()
; Description ...: Checks to see if the base can be classified a weak base
; Syntax ........:
; Parameters ....: None
; Return values .: An array of values of detected defense levels and information
; Author ........: LunaEclipse(April 2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func createWeakBaseStats()
	; Get the directory file contents as keys for the stats file
	Local $aKeys = _FileListToArrayRec(@ScriptDir & "\imgxml\WeakBase", "*.xml", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_SORT, $FLTAR_NOPATH)
	; Create our return array
	Local $return[UBound($aKeys) - 1][2]

	; If the stats file doesn't exist, create it
	If Not FileExists($g_sProfileWeakBasePath) Then _FileCreate($g_sProfileWeakBasePath)

	; Loop through the keys
	For $i = 1 To UBound($aKeys) - 1
		; Set the return array values
		$return[$i - 1][0] = $aKeys[$i] ; Filename
		$return[$i - 1][1] = 0 ; Number

		; Write the entry to the stats file
		IniWrite($g_sProfileWeakBasePath, "WeakBase", $aKeys[$i], "0")
	Next

	Return $return
EndFunc   ;==>createWeakBaseStats

Func readWeakBaseStats()
	; Get the directory file contents as keys for the stats file
	Local $aKeys = _FileListToArrayRec(@ScriptDir & "\imgxml\WeakBase", "*.xml", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_SORT, $FLTAR_NOPATH)
	; Create our return array
	Local $return[UBound($aKeys) - 1][2]

	; Check to see if the stats file exists
	If FileExists($g_sProfileWeakBasePath) Then
		; Loop through the keys
		For $i = 1 To UBound($aKeys) - 1
			; Set the return array values
			$return[$i - 1][0] = $aKeys[$i] ; Filename
			$return[$i - 1][1] = IniRead($g_sProfileWeakBasePath, "WeakBase", $aKeys[$i], "0") ; Current value
		Next
	Else
		; File doesn't exist so create it and return the values from creation
		$return = createWeakBaseStats()
	EndIf

	Return $return
EndFunc   ;==>readWeakBaseStats

Func updateWeakBaseStats($aResult)
	If IsArray($aResult) Then
		; Loop through the found tiles
		For $i = 1 To UBound($aResult) - 1
			; Loop through the current stats
			For $j = 0 To UBound($g_aiWeakBaseStats) - 1
				; Check to see if the current stat is for the found tile
				If $g_aiWeakBaseStats[$j][0] = $aResult[$i][0] Then
					; Update the counter
					$g_aiWeakBaseStats[$j][1] = Number($g_aiWeakBaseStats[$j][1]) + 1
				EndIf
			Next
		Next
	EndIf
EndFunc   ;==>updateWeakBaseStats

Func displayWeakBaseLog($aResult, $showLog = False)
	; Display the various statistical displays
	If $showLog And IsArray($aResult) Then
		SetLog("================ Weak Base Detection Start ================", $COLOR_INFO)
		SetLog("Highest Eagle Artillery: " & $aResult[1][0] & " - Level: " & $aResult[1][2], $COLOR_INFO)
		SetLog("Highest Inferno Tower: " & $aResult[2][0] & " - Level: " & $aResult[2][2], $COLOR_INFO)
		SetLog("Highest X-Bow: " & $aResult[3][0] & " - Level: " & $aResult[3][2], $COLOR_INFO)
		SetLog("Highest Wizard Tower: " & $aResult[4][0] & " - Level: " & $aResult[4][2], $COLOR_INFO)
		SetLog("Highest Mortar: " & $aResult[5][0] & " - Level: " & $aResult[5][2], $COLOR_INFO)
		SetLog("Highest Air Defense: " & $aResult[6][0] & " - Level: " & $aResult[6][2], $COLOR_INFO)
		SetLog("Time taken: " & $aResult[0][2] & " " & $aResult[0][3], $COLOR_INFO)
		SetLog("================ Weak Base Detection Stop =================", $COLOR_INFO)
	EndIf
EndFunc   ;==>displayWeakBaseLog

Func getTHDefenseMax($levelTownHall, $defenseType)
	Local $maxTH = 11

	; Setup Arrays with the max level per town hall level
	Local $eagleLevels[$maxTH] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2]
	Local $infernoLevels[$maxTH] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 4]
	Local $mortarLevels[$maxTH] = [0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
	Local $wizardLevels[$maxTH] = [0, 0, 0, 0, 2, 3, 4, 6, 7, 8, 9]
	Local $xbowLevels[$maxTH] = [0, 0, 0, 0, 0, 0, 0, 0, 3, 4, 4]
	Local $adefenseLevels[$maxTH] = [0, 0, 0, 2, 3, 4, 5, 6, 7, 8, 8]

	; If something went wrong with TH search and returned 0, set to max TH level
	If $levelTownHall = 0 Then $levelTownHall = $maxTH
	; Setup the default return value if no match is found
	Local $result = 100

	If $levelTownHall <= $maxTH Then
		Switch $defenseType
			Case $eWeakEagle
				$result = $eagleLevels[$levelTownHall - 1]
			Case $eWeakInferno
				$result = $infernoLevels[$levelTownHall - 1]
			Case $eWeakXBow
				$result = $xbowLevels[$levelTownHall - 1]
			Case $eWeakWizard
				$result = $wizardLevels[$levelTownHall - 1]
			Case $eWeakMortar
				$result = $mortarLevels[$levelTownHall - 1]
			Case $eWeakAirDefense
				$result = $adefenseLevels[$levelTownHall - 1]
			Case Else
				; Should never reach here unless there is a problem with the code
		EndSwitch
	EndIf

	Return $result
EndFunc   ;==>getTHDefenseMax

Func getMaxUISetting($settingArray, $defenseType)
	; Setup the default return value
	Local $result = 0, $maxDB = 0, $maxLB = 0

	If IsArray($settingArray) Then
		; Check if dead base search is active and dead base weak base detection is active, use setting if active, 0 if not active
		$maxDB = (IsWeakBaseActive($DB)) ? $settingArray[$DB] : 0
		; Check if live base search is active and live base weak base detection is active, use setting if active, 0 if not active
		$maxLB = (IsWeakBaseActive($LB)) ? $settingArray[$LB] : 0

		; Get the value that is highest
		$result = _Max(Number($maxDB), Number($maxLB))
	EndIf

	If $g_iDebugSetlog = 1 Then SetLog("Max " & $g_aWeakDefenseNames[$defenseType] & " Level: " & $result, $COLOR_INFO)
	Return $result
EndFunc   ;==>getMaxUISetting

Func getMinUISetting($settingArray, $defenseType)
	; Setup the default return value
	Local $result = 0, $minDB = 0, $minLB = 0

	If IsArray($settingArray) Then
		; Check if dead base search is active and dead base weak base detection is active, use setting if active, 0 if not active
		$minDB = (IsWeakBaseActive($DB)) ? $settingArray[$DB] : 0
		; Check if live base search is active and live base weak base detection is active, use setting if active, 0 if not active
		$minLB = (IsWeakBaseActive($LB)) ? $settingArray[$LB] : 0

		; Get the value that is highest
		$result = _Min(Number($minDB), Number($minLB))
	EndIf

	If $g_iDebugSetlog = 1 Then SetLog("Min " & $g_aWeakDefenseNames[$defenseType] & " Level: " & $result, $COLOR_INFO)
	Return $result
EndFunc   ;==>getMinUISetting

Func getIsWeak($aResults, $searchType)
	Return $aResults[$eWeakEagle][2] <= Number($g_aiFilterMaxEagleLevel[$searchType]) _
			And $aResults[$eWeakInferno][2] <= Number($g_aiFilterMaxInfernoLevel[$searchType]) _
			And $aResults[$eWeakXBow][2] <= Number($g_aiFilterMaxXBowLevel[$searchType]) _
			And $aResults[$eWeakWizard][2] <= Number($g_aiFilterMaxWizTowerLevel[$searchType]) _
			And $aResults[$eWeakMortar][2] <= Number($g_aiFilterMaxMortarLevel[$searchType])
EndFunc   ;==>getIsWeak

Func IsWeakBaseActive($type)
	Return ($g_abFilterMaxEagleEnable[$type] Or $g_abFilterMaxInfernoEnable[$type] Or $g_abFilterMaxXBowEnable[$type] Or $g_abFilterMaxWizTowerEnable[$type] Or _
			$g_abFilterMaxMortarEnable[$type] Or $g_abFilterMaxAirDefenseEnable[$type]) And IsSearchModeActive($type, False, True)
EndFunc   ;==>IsWeakBaseActive

Func defenseSearch(ByRef $aResult, $directory, $townHallLevel, $settingArray, $defenseType, ByRef $performSearch, $guiEnabledArray, $forceCaptureRegion = True)
	; Setup default return coords of 0,0
	Local $defaultCoords[1][2] = [[0, 0]]

	; Setup Empty Results in case to avoid errors, levels are set to max level of each type
	Local $aDefenseResult[7] = ["Skipped", "Skipped", $g_aWeakDefenseMaxLevels[$defenseType], 0, 0, $defaultCoords, ""]
	; Results when search is not necessary because of levels
	Local $aNotNecessary[7] = ["None", "None", 0, 0, 0, $defaultCoords, ""]

	; Setup search limitations
	Local $minSearchLevel = getMinUISetting($settingArray, $defenseType) + 1
	Local $maxSearchLevel = getTHDefenseMax($townHallLevel, $defenseType)
	Local $guiCheckDefense = IsArray($guiEnabledArray) And ((IsSearchModeActive($DB, False, True) And $guiEnabledArray[$DB]) Or (IsSearchModeActive($LB, False, True) And $guiEnabledArray[$LB]))

	; Only do the search if its required
	If $performSearch Then
		; Start the timer for individual defense searches
		Local $defenseTimer = __TimerInit()

		If $guiCheckDefense And $maxSearchLevel >= $minSearchLevel Then
			; Check the defense.
			Local $sDefenseName = StringSplit($directory, "\", $STR_NOCOUNT)
			If $g_iDebugSetlog Then SetLog("checkDefense :" & $sDefenseName[UBound($sDefenseName) - 1] & " > " & $minSearchLevel & " < " & $maxSearchLevel & " For TH:" & $townHallLevel, $COLOR_ORANGE)
			$aDefenseResult = returnHighestLevelSingleMatch($directory, $aResult[0][0], $g_sProfileWeakBasePath, $minSearchLevel, $maxSearchLevel, $forceCaptureRegion)
			; Store the redlines retrieved for use in the later searches, if you don't currently have redlines saved.
			If $aResult[0][0] = "" Then $aResult[0][0] = $aDefenseResult[6]
			; Check to see if further searches are required, $performSearch is passed ByRef, so this will update the value in the calling function
			If Number($aDefenseResult[2]) > getMaxUISetting($settingArray, $defenseType) Then $performSearch = False
			If $g_iDebugSetlog = 1 Then SetLog("checkDefense: " & $g_aWeakDefenseNames[$defenseType] & " - " & Round(__TimerDiff($defenseTimer) / 1000, 2) & " seconds")
		Else
			$aDefenseResult = $aNotNecessary
			If $g_iDebugSetlog = 1 Then SetLog("checkDefense: " & $g_aWeakDefenseNames[$defenseType] & " not necessary!")
		EndIf
	EndIf

	Return $aDefenseResult
EndFunc   ;==>defenseSearch

Func weakBaseCheck($townHallLevel = 11, $redlines = "", $forceCaptureRegion = True)
	; Setup default return coords of 0,0
	Local $defaultCoords[1][2] = [[0, 0]]
	; Setup Empty Results in case to avoid errors, levels are set to max level of each type
	Local $aResult[7][6] = [[$redlines, 0, 0, "Seconds", "", ""], _
			["Skipped", "Skipped", 2, 0, 0, $defaultCoords], _
			["Skipped", "Skipped", 4, 0, 0, $defaultCoords], _
			["Skipped", "Skipped", 4, 0, 0, $defaultCoords], _
			["Skipped", "Skipped", 9, 0, 0, $defaultCoords], _
			["Skipped", "Skipped", 9, 0, 0, $defaultCoords], _
			["Skipped", "Skipped", 8, 0, 0, $defaultCoords]]

	Local $aEagleResults, $aInfernoResults, $aMortarResults, $aWizardTowerResults, $aXBowResults, $aAirDefenseResults
	Local $performSearch = True
	; Start the timer for overall weak base search
	Local $hWeakTimer = __TimerInit()

	; Check Eagle Artillery first as there is less images to process, mortars may not be needed.
	$aEagleResults = defenseSearch($aResult, @ScriptDir & "\imgxml\WeakBase\Eagle", $townHallLevel, $g_aiFilterMaxEagleLevel, $eWeakEagle, $performSearch, $g_abFilterMaxEagleEnable, $forceCaptureRegion)
	$aInfernoResults = defenseSearch($aResult, @ScriptDir & "\imgxml\WeakBase\Infernos", $townHallLevel, $g_aiFilterMaxInfernoLevel, $eWeakInferno, $performSearch, $g_abFilterMaxInfernoEnable, $forceCaptureRegion)
	$aXBowResults = defenseSearch($aResult, @ScriptDir & "\imgxml\WeakBase\Xbow", $townHallLevel, $g_aiFilterMaxXBowLevel, $eWeakXBow, $performSearch, $g_abFilterMaxXBowEnable, $forceCaptureRegion)
	If $g_iDetectedImageType = 1 Then
		$aWizardTowerResults = defenseSearch($aResult, @ScriptDir & "\imgxml\WeakBase\WTower_Snow", $townHallLevel, $g_aiFilterMaxWizTowerLevel, $eWeakWizard, $performSearch, $g_abFilterMaxWizTowerEnable, $forceCaptureRegion)
	Else
		$aWizardTowerResults = defenseSearch($aResult, @ScriptDir & "\imgxml\WeakBase\WTower", $townHallLevel, $g_aiFilterMaxWizTowerLevel, $eWeakWizard, $performSearch, $g_abFilterMaxWizTowerEnable, $forceCaptureRegion)
	EndIf
	$aMortarResults = defenseSearch($aResult, @ScriptDir & "\imgxml\WeakBase\Mortars", $townHallLevel, $g_aiFilterMaxMortarLevel, $eWeakMortar, $performSearch, $g_abFilterMaxMortarEnable, $forceCaptureRegion)
	$aAirDefenseResults = defenseSearch($aResult, @ScriptDir & "\imgxml\WeakBase\ADefense", $townHallLevel, $g_aiFilterMaxAirDefenseLevel, $eWeakAirDefense, $performSearch, $g_abFilterMaxAirDefenseEnable, $forceCaptureRegion)


	; Fill the array that will be returned with the various results, only store the results if its a valid array
	For $i = 1 To UBound($aResult) - 1
		For $j = 0 To UBound($aResult, 2) - 1
			Switch $i
				Case $eWeakEagle
					If IsArray($aEagleResults) Then $aResult[$i][$j] = $aEagleResults[$j]
				Case $eWeakInferno
					If IsArray($aInfernoResults) Then $aResult[$i][$j] = $aInfernoResults[$j]
				Case $eWeakXBow
					If IsArray($aXBowResults) Then $aResult[$i][$j] = $aXBowResults[$j]
				Case $eWeakWizard
					If IsArray($aWizardTowerResults) Then $aResult[$i][$j] = $aWizardTowerResults[$j]
				Case $eWeakMortar
					If IsArray($aMortarResults) Then $aResult[$i][$j] = $aMortarResults[$j]
				Case $eWeakAirDefense
					If IsArray($aAirDefenseResults) Then $aResult[$i][$j] = $aAirDefenseResults[$j]
				Case Else
					; This should never happen unless there is a problem with the code.
			EndSwitch
		Next
	Next

	; Extra return results
	$aResult[0][2] = Round(__TimerDiff($hWeakTimer) / 1000, 2) ; Time taken
	$aResult[0][3] = "Seconds" ; Measurement unit

	Return $aResult
EndFunc   ;==>weakBaseCheck

Func IsWeakBase($townHallLevel = 11, $redlines = "", $forceCaptureRegion = True)
	Local $aResult = weakBaseCheck($townHallLevel, $redlines, $forceCaptureRegion)

	; Forces the display of the various statistical displays, if set to true
	; displayWeakBaseLog($aResult, true)
	; Displays the various statistical displays, if debug logging is enabled
	displayWeakBaseLog($aResult, $g_iDebugSetlog = 1)

	; Take Debug Pictures
	If Number($aResult[0][2]) > 10 Then
		; Search took longer than 10 seconds so take a debug picture no matter what the debug option is
		captureDebugImage($aResult, "WeakBase_Detection_TooSlow")
	ElseIf $g_iDebugImageSave = 1 And Number($aResult[1][4]) = 0 Then
		; Eagle Artillery not detected, so lets log the picture for manual inspection
		captureDebugImage($aResult, "WeakBase_Detection_Eagle_NotDetected")
	ElseIf $g_iDebugImageSave = 1 And Number($aResult[2][4]) = 0 Then
		; Inferno Towers not detected, so lets log the picture for manual inspection
		captureDebugImage($aResult, "WeakBase_Detection_Inferno_NotDetected")
	ElseIf $g_iDebugImageSave = 1 And Number($aResult[3][4]) = 0 Then
		; X-bows not detected, so lets log the picture for manual inspection
		captureDebugImage($aResult, "WeakBase_Detection_Xbow_NotDetected")
	ElseIf $g_iDebugImageSave = 1 And Number($aResult[4][4]) = 0 Then
		; Wizard Towers not detected, so lets log the picture for manual inspection
		captureDebugImage($aResult, "WeakBase_Detection_WTower_NotDetected")
	ElseIf $g_iDebugImageSave = 1 And Number($aResult[5][4]) = 0 Then
		; Mortars not detected, so lets log the picture for manual inspection
		captureDebugImage($aResult, "WeakBase_Detection_Mortar_NotDetected")
	ElseIf $g_iDebugImageSave = 1 And Number($aResult[6][4]) = 0 Then
		; Air Defenses not detected, so lets log the picture for manual inspection
		captureDebugImage($aResult, "WeakBase_Detection_ADefense_NotDetected")
	ElseIf $g_iDebugImageSave = 1 Then
		; Debug option is set, so take a debug picture
		captureDebugImage($aResult, "WeakBase_Detection")
	EndIf

	Return $aResult
EndFunc   ;==>IsWeakBase
