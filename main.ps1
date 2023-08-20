# Load the necessary assemblies for displaying input boxes
Add-Type -AssemblyName Microsoft.VisualBasic, System.Windows.Forms

# Get input values and remove spaces
$sourceComputer = ([Microsoft.VisualBasic.Interaction]::InputBox("Enter the source Computer name", "Source Computer Name")) -replace ' ', ''
$destinationComputer = ([Microsoft.VisualBasic.Interaction]::InputBox("Enter the destination Computer name", "Destination Computer Name")) -replace ' ', ''

# Display the inputs
Write-Host "Source Computer: $sourceComputer"
Write-Host "Destination Computer: $destinationComputer"
Write-Host "Copying user profiles from $sourceComputer to $destinationComputer"
Start-Sleep -Seconds 1

# Define the UNC path to the remote computer's user folder location
$remoteUserFolderPath = "\\$sourceComputer\C$\Users"

# Get the user folders from the remote computer
try {
    $userFolderNames = (Get-ChildItem -Path $remoteUserFolderPath -Directory).Name
} catch {
    Write-Host "Error accessing remote computer: $sourceComputer"
    exit
}

# Display the users found
Write-Host "`Users found on ${sourceComputer}: $($userFolderNames -join ', ')"

# Define common folder paths to be created
$commonFolders = @("Desktop", "Documents", "Music", "Videos", "Favorites")

foreach ($UserName in $userFolderNames) {
    $userDestinationPath = "\\$destinationComputer\C$\Source\CP\$UserName"

    # Create directories if they don't exist
    New-Item -Path $userDestinationPath -Type Directory -Force
    $commonFolders | ForEach-Object {
        New-Item -Path "$userDestinationPath\$_" -Type Directory -Force
    }

    # Copy user directories to the destination computer
    $commonFolders | ForEach-Object {
        $srcPath = "\\$sourceComputer\C$\Users\$UserName\$_"
        $destPath = "$userDestinationPath\$_"
        Copy-Item -Path $srcPath -Destination $destPath -Recurse -Force
    }

    $textInfo = [System.Globalization.CultureInfo]::CurrentCulture.TextInfo
    Write-Host "Successfully copied $($textInfo.ToTitleCase($UserName.ToLower())) to $destinationComputer" -ForegroundColor Green
}
