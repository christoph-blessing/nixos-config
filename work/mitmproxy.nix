{ ... }:

{
  security.pki.certificates = [
    ''
      mitmproxy.org
      =========
      -----BEGIN CERTIFICATE-----
      MIIDNTCCAh2gAwIBAgIUWf1uT8NvuOAYEowMAIXLrMtOK5IwDQYJKoZIhvcNAQEL
      BQAwKDESMBAGA1UEAwwJbWl0bXByb3h5MRIwEAYDVQQKDAltaXRtcHJveHkwHhcN
      MjQxMTMwMTU1NDQyWhcNMzQxMTMwMTU1NDQyWjAoMRIwEAYDVQQDDAltaXRtcHJv
      eHkxEjAQBgNVBAoMCW1pdG1wcm94eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
      AQoCggEBALoB29ZGr2bh0BPsZdEIz2oEEqc8V/um5/R85bA6aVvlc4Wz3S8FOTQi
      k0CpFnc+d5XUbOLqpHki5fSAJdYVLMIbYDllh9C7edjLw58lG9Fvg+A9IntFVbl5
      YbD6JudjoeikfhfJMu40c/vqSyAT3VBNn9ZqJZIDp8IRcSv1rJhEjMli3GJc771z
      Gg6I/IU8oV86ZCVh0mOe2xKFftyCdNK8E65TPP2DV6/HCS8JIbycM922aB+URZFs
      R+Bn4nQNxqamXjb+UEsZA0607sqtgWEMdXYevokSjD/kLFL4Zahq4fKqI1ihvBQg
      KSGirpV2Rlpkec5wcuYUPNfoiRx3QNcCAwEAAaNXMFUwDwYDVR0TAQH/BAUwAwEB
      /zATBgNVHSUEDDAKBggrBgEFBQcDATAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYE
      FAdz196l4GtxeQ5QwhyohsDfx/V3MA0GCSqGSIb3DQEBCwUAA4IBAQBCAFTrDJ2N
      wHefRl4Jpnb0Hv8hcSN3u6eIve0UGpXWUefvEAUeufA4aT/VPPlae2+HUvjqPCaG
      YxGIMJP4vbbZSuPu1W5MZAlOA+7szjNKEKg1tOQPniw8bGdLkV+pNhsEqMJBnZrZ
      Y+fCt/jwu7JE5oFV/+E74ySqkVJ9T2Fj2KJlqFpUcwiP2wuc/2WKJs6Htg4j/XbW
      6YpbrzH3py2uBaewb+cOmGeSP48hlqyeJPqEvrYdHtHYBRRXKAUnul+fwsKNECV7
      QwfVidyOhK0GEHABmcif2QInbbaAOgab2MpF3uguuBdBbAeFEbdWwC2q/YDKfGnV
      QNMpiEYE8cjO
      -----END CERTIFICATE-----
    ''
  ];

  networking.firewall.allowedTCPPorts = [ 8040 ];
}
