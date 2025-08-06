function Get-FactorialIterative {
    param (
        [int]$number
    )

    if ($number -le 0) { return 0 }
    $result = 1
    while ($number -gt 0) {
        $result *= $number
        $number--
    } 

    return $result
}

# Example: The factorial of 6 (6!)
Get-FactorialIterative -number 6



function Get-FactorialRecursive {
    param (
        [int]$number
    )

    if ($number -le 1) {
        return 1
    } else {
        return $number * (Get-FactorialRecursive -number ($number - 1))
    }
}

# Voorbeeld: The factorial of 6 (6!)
Get-FactorialRecursive -number 6


function Get-FibonacciRecursive {
    param(
        [int]$number
    )

    if ($number -le 0) { return 0 }
    elseif ($number -eq 1) { return 1 }
    else {
        return (Get-FibonacciRecursive -number ($number - 1)) + (Get-FibonacciRecursive -number ($number - 2))
    }
}

# Example: het 10e Fibonacci-getal
Get-FibonacciRecursive -number 10


function Get-FibonacciIterative {
    param(
        [int]$number
    )

    if ($number -le 0) { return 0 }
    elseif ($number -eq 1) { return 1 }

    $a = 0
    $b = 1

    for ($i = 2; $i -le $number; $i++) {
        $temp = $a + $b
        $a = $b
        $b = $temp
    }

    return $b
}

# Example: het 10e Fibonacci-getal
Get-FibonacciIterative -number 10
