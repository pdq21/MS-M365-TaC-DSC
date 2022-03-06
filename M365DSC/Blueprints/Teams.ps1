TeamsCallingPolicy 00000000-0000-0000-0000-000000000000
{
    AllowCallForwardingToPhone        = $True;
    AllowCallForwardingToUser         = $True;
    AllowCallGroups                   = $True;
    AllowCloudRecordingForCalls       = $False;
    AllowDelegation                   = $True;
    AllowPrivateCalling               = $True;
    AllowTranscriptionForCalling      = $False;
    AllowVoicemail                    = "UserOverride";
    AllowWebPSTNCalling               = $True;
    AutoAnswerEnabledType             = "Disabled";
    BusyOnBusyEnabledType             = "Disabled";
    Credential                        = $Credscredential;
    Ensure                            = "Present";
    Identity                          = "Global";
    LiveCaptionsEnabledTypeForCalling = "DisabledUserOverride";
    MusicOnHoldEnabledType            = "Enabled";
    PreventTollBypass                 = $False;
    SafeTransferEnabled               = "Disabled";
    SpamFilteringEnabledType          = "Enabled";
}