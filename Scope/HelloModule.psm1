Function Get-HelloName {
    if ($name) {
        $greeting = "Hello, $name!"
    } else {
        $greeting = "Hello, World!"
    }
    
    $greeting
}
 
Function Set-HelloName {
    param(
        [Parameter(Mandatory)]
        [string]$HelloName
    )
    
    $name = $HelloName
}