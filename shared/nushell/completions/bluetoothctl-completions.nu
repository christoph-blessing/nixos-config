def "nu-complete bluetoothctl connect" [] {
    ^bluetoothctl devices Paired | parse "{prefix} {value} {description}" | reject "prefix"
}

def "nu-complete bluetoothctl disconnect" [] {
    ^bluetoothctl devices Connected | parse "{prefix} {value} {description}" | reject "prefix"
}

def "nu-complete bluetoothctl devices" [] {
    [
        "Paired",
        "Bonded",
        "Trusted",
        "Connected"
    ]
}

export extern "bluetoothctl connect" [
    device: string@"nu-complete bluetoothctl connect"
]

export extern "bluetoothctl disconnect" [
    device: string@"nu-complete bluetoothctl disconnect"
]

export extern "bluetoothctl devices" [
    property?: string@"nu-complete bluetoothctl devices"
]
