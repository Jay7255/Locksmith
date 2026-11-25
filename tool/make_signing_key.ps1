# Makes the Locksmith signing key and copies it to the clipboard, ready to
# paste into GitHub as the SIGNING_KEYSTORE secret. Run once, on your PC:
#   powershell -ExecutionPolicy Bypass -File tool\make_signing_key.ps1
#
# This key signs the test builds from GitHub, so a new build installs over
# the old app (and keeps your progress) instead of needing an uninstall.
# Keep the .keystore file safe: if it's lost, phones need one uninstall.

$keytool = 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'
if (-not (Test-Path $keytool)) { $keytool = 'keytool' }
$file = Join-Path $HOME 'locksmith-test.keystore'

if (Test-Path $file) {
  Write-Host "Key already exists: $file (using it)." -ForegroundColor Yellow
} else {
  & $keytool -genkeypair -keystore $file -storepass android -keypass android `
    -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 `
    -dname 'CN=Locksmith, O=Jonathan, C=ZM'
  if (-not (Test-Path $file)) { Write-Host 'keytool failed. Is Android Studio installed?' -ForegroundColor Red; return }
}

[Convert]::ToBase64String([IO.File]::ReadAllBytes($file)) | Set-Clipboard
Write-Host "`nDone. The key is copied to your clipboard." -ForegroundColor Green
Write-Host 'Now on GitHub: Locksmith repo > Settings > Secrets and variables > Actions >'
Write-Host 'New repository secret. Name: SIGNING_KEYSTORE   Secret: paste (Ctrl+V)   > Add secret.'
Write-Host "Back up this file somewhere safe: $file"
