EXOAntiPhishPolicy 00000000-0000-0000-0000-000000000000
{
    AdminDisplayName                              = "";
    AuthenticationFailAction                      = "MoveToJmf";
    Credential                                    = $Credscredential;
    Enabled                                       = $True;
    EnableFirstContactSafetyTips                  = $False;
    EnableMailboxIntelligence                     = $True;
    EnableMailboxIntelligenceProtection           = $False;
    EnableOrganizationDomainsProtection           = $False;
    EnableSimilarDomainsSafetyTips                = $False;
    EnableSimilarUsersSafetyTips                  = $False;
    EnableSpoofIntelligence                       = $True;
    EnableTargetedDomainsProtection               = $False;
    EnableTargetedUserProtection                  = $False;
    EnableUnauthenticatedSender                   = $True;
    EnableUnusualCharactersSafetyTips             = $False;
    EnableViaTag                                  = $True;
    Ensure                                        = "Present";
    ExcludedDomains                               = @();
    ExcludedSenders                               = @();
    Identity                                      = "Office365 AntiPhish Default";
    ImpersonationProtectionState                  = "Automatic";
    MailboxIntelligenceProtectionAction           = "NoAction";
    MailboxIntelligenceProtectionActionRecipients = @();
    MakeDefault                                   = $True;
    PhishThresholdLevel                           = 1;
    TargetedDomainActionRecipients                = @();
    TargetedDomainsToProtect                      = @();
    TargetedUserActionRecipients                  = @();
    TargetedUserProtectionAction                  = "NoAction";
    TargetedUsersToProtect                        = @();
}