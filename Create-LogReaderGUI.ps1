<#
.SYNOPSIS
    Log Viewer GUI for selecting and opening log files based on file type and modification time.

.DESCRIPTION
    This PowerShell script creates a Windows Forms-based graphical user interface (GUI) that allows users to:
    - Select a source folder containing log files.
    - Choose file types to include (.txt, .log, .ps1).
    - Specify a timespan (last X hours) to filter recently modified files.
    - View a list of matching log files, sorted by last write time.
    - Open a selected log file with its associated application.

.PARAMETER SourceFolder
    The folder path containing the log files to be searched. Can be set manually or selected via a folder browser dialog.

.PARAMETER FileTypes
    File extensions to include in the search. Options are .txt, .log, and .ps1, selectable via checkboxes.

.PARAMETER Timespan
    The time window (in hours) for filtering files based on their last modification time. Options are 1, 2, 4, 8, or 24 hours, selectable via radio buttons.

.FUNCTIONALITY
    - Loads Windows Forms and Drawing assemblies for GUI components.
    - Defines a custom class (ListLogItem) for displaying file information in the list box.
    - Provides controls for folder selection, file type filtering, and timespan selection.
    - Lists matching files in a list box, showing last write time and file name.
    - Allows opening the selected log file with the default associated application.

.NOTES
    Author: Jos Fissering
    Date: 22-05-2025
    Tested on: Windows PowerShell 5.1+, Powershell 7+
    Tested on: Windows 10/11, Windows Server 2016/2019/2022

.EXAMPLE
    Run the script to launch the Log Viewer GUI:
        .\Create-LogReaderGUI.ps1

#>

# Load the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create a custom object with Name and FullName
class ListLogItem {
    [string]$Name
    [string]$FullName
    [datetime]$LastWriteTime

    ListLogItem([string]$name, [string]$fullname, [datetime]$lastWriteTime) {
        $this.LastWriteTime = $lastWriteTime
        $this.Name = $name
        $this.FullName = $fullname
    }

    # Override ToString to show the LastWriteTime and Name in the ListBox
    [string] ToString() {
        return "$($this.LastWriteTime) `t $($this.Name)"
    }
}

# Create a new form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Log Viewer"
$form.Size = New-Object System.Drawing.Size(1010, 450)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MinimizeBox = $true

#region Source Folder
# Create a new label for the source folder	
$label_source_folder = New-Object System.Windows.Forms.Label
$label_source_folder.Text = "Source folder:"
$label_source_folder.Location = New-Object System.Drawing.Point(10, 10)
$label_source_folder.Size = New-Object System.Drawing.Size(100, 20)

# Create a new input field for the log file path
$input_source_folder = New-Object System.Windows.Forms.TextBox
$input_source_folder.Location = New-Object System.Drawing.Point(110, 10)
$input_source_folder.Size = New-Object System.Drawing.Size(750, 20)
$input_source_folder.Text = "C:\Logs\"

# Create a button to browse for the log file path
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Browse"
$browseButton.Location = New-Object System.Drawing.Point(875, 10)
$browseButton.Size = New-Object System.Drawing.Size(100, 20)
$browseButton.BackColor = [System.Drawing.Color]::FromName("cornflowerblue")

# Add an event handler for the button click
$browseButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select the folder containing the log files"
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $input_source_folder.Text = $folderBrowser.SelectedPath
    }
})
#endregion Source Folder

#region Filetypes
# Create a new label for the filetype selection
$label_filetypes = New-Object System.Windows.Forms.Label
$label_filetypes.Text = "Select the filetypes:"
$label_filetypes.Location = New-Object System.Drawing.Point(10, 40)
$label_filetypes.Size = New-Object System.Drawing.Size(250, 20)

# Create checkboxes for the filetype selection
$checkBox_txt = New-Object System.Windows.Forms.CheckBox
$checkBox_txt.Text = ".txt"
$checkBox_txt.Location = New-Object System.Drawing.Point(20, 60)
$checkBox_txt.Size = New-Object System.Drawing.Size(250, 20)
$checkBox_txt.Checked = $true

$checkBox_log = New-Object System.Windows.Forms.CheckBox
$checkBox_log.Text = ".log"
$checkBox_log.Location = New-Object System.Drawing.Point(20, 80)
$checkBox_log.Size = New-Object System.Drawing.Size(250, 20)
$checkBox_log.Checked = $true

$checkBox_ps1 = New-Object System.Windows.Forms.CheckBox
$checkBox_ps1.Text = ".ps1"
$checkBox_ps1.Location = New-Object System.Drawing.Point(20, 100)
$checkBox_ps1.Size = New-Object System.Drawing.Size(250, 20)
$checkBox_ps1.Checked = $false
#endregion Filetypes

#region Timespan
# Create a new label for the timespan selection
$label_timespan = New-Object System.Windows.Forms.Label
$label_timespan.Text = "Which timespan? (last X hours):"
$label_timespan.Location = New-Object System.Drawing.Point(10, 140)
$label_timespan.Size = New-Object System.Drawing.Size(250, 20)

# Create radio buttons for the timespan selection
$index = 0
$object_size_x = 250
$object_size_y = 20

@(
    "1 hour",
    "2 hours",
    "4 hours",
    "8 hours",
    "24 hours"
).ForEach({
    $y = 160 + ($object_size_y * $index)
    $index++

    $radioButton = New-Object System.Windows.Forms.RadioButton
    $radioButton.Text = $_
    $radioButton.Location = New-Object System.Drawing.Point(20, $y)
    $radioButton.Size = New-Object System.Drawing.Size($object_size_x, $object_size_y)
    $radioButton.Name = "radioButton$($index)"
    $form.Controls.Add($radioButton)
})

# Set the default radio button
$form.Controls["radioButton1"].Checked = $true
#endregion Timespan

# Multiple selection listbox for the log files
$ListBox_Log = New-Object System.Windows.Forms.ListBox
$ListBox_Log.Location = New-Object System.Drawing.Point(280, 40)
$ListBox_Log.Size = New-Object System.Drawing.Size(700, 330)
$ListBox_Log.SelectionMode = [System.Windows.Forms.SelectionMode]::one
$ListBox_Log.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Regular)

# Create a button to get logs
$button_get_log = New-Object System.Windows.Forms.Button
$button_get_log.Text = "Get Logs"
$button_get_log.Location = New-Object System.Drawing.Point(10, 370)
$button_get_log.Size = New-Object System.Drawing.Size(250, 30)
$button_get_log.BackColor = [System.Drawing.Color]::FromName("cornflowerblue")

# Add an event handler for the button click
$button_get_log.Add_Click({
    # Get the selected file types
    $fileTypes = @()
    if ($checkBox_txt.Checked) { $fileTypes += "*.txt" }
    if ($checkBox_log.Checked) { $fileTypes += "*.log" }
    if ($checkBox_ps1.Checked) { $fileTypes += "*.ps1" }

    # Get the selected timespan
    $timespan = 1
    if ($form.Controls["radioButton2"].Checked) { $timespan = 2 }
    elseif ($form.Controls["radioButton3"].Checked) { $timespan = 4 }
    elseif ($form.Controls["radioButton4"].Checked) { $timespan = 8 }
    elseif ($form.Controls["radioButton5"].Checked) { $timespan = 24 }

    # Get the log files based on the selected criteria
    $logFiles = Get-ChildItem -Path $input_source_folder.Text -Include $fileTypes -Recurse | Where-Object {
        $_.LastWriteTime -ge (Get-Date).AddHours(-$timespan)
    }

    # Clear the listbox and add the log files
    $ListBox_Log.Items.Clear()
    foreach ($logFile in $logFiles | Sort-Object LastWriteTime -Descending) { 
        $ListBox_Log.Items.Add([Activator]::CreateInstance([ListLogItem], @($($logFile.Name), $($logFile.FullName), $($logFile.LastWriteTime))))
    }
})

# Create a new button to open the selected log file
$button_open_log = New-Object System.Windows.Forms.Button
$button_open_log.Text = "Open Log"
$button_open_log.Location = New-Object System.Drawing.Point(280, 370)
$button_open_log.Size = New-Object System.Drawing.Size(700, 30)
$button_open_log.BackColor = [System.Drawing.Color]::FromName("cornflowerblue")

# Add an event handler for the button click
$button_open_log.Add_Click({
    if ($ListBox_Log.SelectedItem) {
        $logFilePath = $ListBox_Log.SelectedItem.FullName
        Start-Process -FilePath $logFilePath
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select a log file to open.", "No Selection", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})

# Add all controls to the form
$form.Controls.Add($label_filetypes)
$form.Controls.Add($label_timespan)
$form.Controls.Add($label_source_folder)

$form.Controls.Add($input_source_folder)

$form.Controls.Add($checkBox_txt)
$form.Controls.Add($checkBox_log)
$form.Controls.Add($checkBox_ps1)

$form.Controls.Add($ListBox_Log)

$form.Controls.Add($button_get_log)
$form.Controls.Add($button_open_log)
$form.Controls.Add($browseButton)

$form.ShowDialog() | Out-Null

