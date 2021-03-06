$TestRecordingFile = Join-Path $PSScriptRoot 'Remove-AzsGalleryItem.Recording.json'
$currentPath = $PSScriptRoot
while(-not $mockingPath) {
    $mockingPath = Get-ChildItem -Path $currentPath -Recurse -Include 'HttpPipelineMocking.ps1' -File
    $currentPath = Split-Path -Path $currentPath -Parent
}
. ($mockingPath | Select-Object -First 1).FullName

Describe 'Remove-AzsGalleryItem' {
    it "TestCreateAndDeleteGalleryItemPiped" {
        $global:TestName = 'TestCreateAndDeleteGalleryItem'

        $name = "TestUbuntu.Test.1.0.0"
        $uri = "https://testsa.blob.redmond.ext-n35r1010.masd.stbtest.microsoft.com/testsc/TestUbuntu.Test.1.0.0.azpkg"
        Remove-AzsGalleryItem -Name $name 

        $GalleryItem = new-AzsGalleryItem -GalleryItemUri $uri 
        $GalleryItem | Should Not Be $null

        $GalleryItem | Remove-AzsGalleryItem 
    }
}
