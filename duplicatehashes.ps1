<#
Author: Smith, Justin
Date: 2023

Modified: NA
Changes:

Find duplicate files/hashes starting with a particular directory
visually display status
#>
# Define the root directory to start the search
$rootDirectory = "\\nas540\"

# Create a hashtable to store file hashes and their paths
$hashTable = @{}

# Function to calculate the hash of a file
function Get-FileHash($filePath) {
    $hashAlgorithm = [System.Security.Cryptography.SHA256]::Create()
    $fileStream = [System.IO.File]::OpenRead($filePath)
    $hashBytes = $hashAlgorithm.ComputeHash($fileStream)
    $fileStream.Close()
    return [BitConverter]::ToString($hashBytes) -replace '-'
}

# Recursive function to search for duplicate hashes
function Find-DuplicateHashes($directory) {
    $files = Get-ChildItem -File -Path $directory
    foreach ($file in $files) {
        Write-Host "Processing $($file.FullName)..."
        $hash = Get-FileHash $file.FullName
        if ($hashTable.ContainsKey($hash)) {
            Write-Host "Duplicate Hash Found:"
            Write-Host "File 1: $($hashTable[$hash])"
            Write-Host "File 2: $($file.FullName)"
        } else {
            $hashTable[$hash] = $file.FullName
        }
    }

    $subdirectories = Get-ChildItem -Directory -Path $directory
    foreach ($subdirectory in $subdirectories) {
        Find-DuplicateHashes $subdirectory.FullName
    }
}

# Start the search for duplicate hashes
Write-Host "Searching for duplicate hashes in $($rootDirectory) and its subfolders..."
Find-DuplicateHashes $rootDirectory
Write-Host "Search completed."
