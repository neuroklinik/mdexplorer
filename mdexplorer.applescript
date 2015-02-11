-- mdexplorer.applescript
-- mdexplorer

--  Created by Christopher Fox on 1/9/06.
--  Copyright 2006 __MyCompanyName__. All rights reserved.

on will finish launching theObject
	(* Setting up the mdAttributes data source *)
	set mdAttributesDS to data source of table view "mdAttributes" of scroll view "mdAttributes" of split view "tableSplitView" of window "mdexplorer" of theObject
	tell mdAttributesDS
		make new data column at the end of the data columns with properties {name:"key"}
		make new data column at the end of the data columns with properties {name:"description"}
		set theKeys to do shell script "mdimport -A | awk -F\\' 'BEGIN { OFS=\"\\t\"}{ print $2, $6 }'"
		set oldTIDs to AppleScript's text item delimiters
		set AppleScript's text item delimiters to tab
		repeat with eachKey from 1 to (count of paragraphs of theKeys)
			set newRow to make new data row at the end of the data rows
			set contents of data cell "key" of newRow to text item 1 of paragraph eachKey of theKeys
			set contents of data cell "description" of newRow to text item 2 of paragraph eachKey of theKeys
		end repeat
		set AppleScript's text item delimiters to oldTIDs
	end tell
end will finish launching

on selection changed theObject
	(* The user has selected a search key. Get the one selected. Set the contents of the searchKey textfield to the name of the key. *)
	set theWindow to the window of theObject
	set selectedRow to selected data row of theObject
	tell theWindow
		set contents of text field "searchKey" to contents of data cell "key" of selectedRow
	end tell
end selection changed

on clicked theObject
	(* The user has clicked the Search button. *)
	
	-- Collect some data.
	set theWindow to window of theObject
	tell theWindow
		set theSearchKey to contents of text field "searchKey"
		set theSearchBool to title of current menu item of popup button "searchBool"
		set theSearchValue to contents of text field "searchValue"
		-- display dialog theSearchKey & return & theSearchBool & return & theSearchValue
	end tell
	
	-- Run the search.
	if theSearchValue = "" then
		set foundFiles to do shell script "mdfind \"" & theSearchKey & " " & theSearchBool & " ''\""
	else
		set foundFiles to do shell script "mdfind \"" & theSearchKey & " " & theSearchBool & " " & "'" & theSearchValue & "'\""
	end if
	
	-- Populate the search results window.
	set theSearchResultsDS to data source of table view "foundItems" of scroll view "foundItems" of split view "tableSplitView" of window of theObject
	delete data rows of theSearchResultsDS
	tell theSearchResultsDS
		make new data column at the end of the data columns with properties {name:"filename"}
		make new data column at the end of the data columns with properties {name:"keyValue"}
		repeat with eachFile from 1 to (count of paragraphs of foundFiles)
			set filesKey to do shell script "mdls -name " & theSearchKey & " " & quoted form of (paragraph eachFile of foundFiles) & "  | awk '{ print $3 }' | tr -d \\\""
			set newRow to make new data row at the end of the data rows
			set contents of data cell "filename" of newRow to paragraph eachFile of foundFiles
			set contents of data cell "keyValue" of newRow to filesKey
		end repeat
	end tell
	
end clicked
