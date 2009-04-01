//
//  AIIRCServicesPasswordPlugin.m
//  Adium
//
//  Created by Zachary West on 2009-03-28.
//

#import "AIIRCServicesPasswordPlugin.h"
#import "ESIRCAccount.h"
#import <AIUtilities/AIStringAdditions.h>
#import <Adium/AIPasswordPromptController.h>
#import <Adium/AIAccountControllerProtocol.h>
#import <Adium/AIContentControllerProtocol.h>
#import <Adium/AIContentObject.h>
#import <Adium/AIContentMessage.h>
#import <Adium/AIChat.h>
#import <Adium/AIListObject.h>
#import <Adium/AIAccount.h>

@implementation AIIRCServicesPasswordPlugin
- (void)installPlugin
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(willReceiveContent:)
												 name:Content_WillReceiveContent
											   object:nil];
}

- (void)uninstallPlugin
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark Content handling
- (void)willReceiveContent:(NSNotification *)notification
{	
	AIContentObject		*contentObject = [[notification userInfo] objectForKey:@"Object"];
	
	if (![contentObject isKindOfClass:[AIContentMessage class]]) {
		return;
	}
	
	// Some servers, such as DALnet, send the messages from things like "NickServ@…", so let's check the prefix.
	// We don't send a *response* to this user, so it's okay to not care if it's an imposter.
	if ([contentObject.source.UID.lowercaseString hasPrefix:@"nickserv"]) {
		NSString *message = contentObject.message.string;
		AIAccount *account = contentObject.chat.account;
		
		// Needs updating for various implementations.
		if ([message rangeOfString:@"This nickname is registered"].location != NSNotFound ||
			[message rangeOfString:@"Invalid password"].location != NSNotFound) {
			AILogWithSignature(@"%@ received challenge :%@", account.displayName, message);
			
			[adium.accountController passwordForType:AINickServPassword
										  forAccount:account
										promptOption:(([message rangeOfString:@"Invalid password"].location != NSNotFound) ? AIPromptAlways : AIPromptAsNeeded)
												name:account.displayName
									 notifyingTarget:self
											selector:@selector(nickservPasswordReturned:returnCode:context:)
											 context:[NSDictionary dictionaryWithObjectsAndKeys:account, @"Account", account.displayName, @"Name", nil]];

			contentObject.displayContent = NO;
		} else if ([message rangeOfString:@"before it is changed"].location != NSNotFound) {
			contentObject.displayContent = NO;
		} else if ([message rangeOfString:@"now identified for"].location != NSNotFound) {
			if ([account boolValueForProperty:@"Identifying"]) {
				[account setValue:nil forProperty:@"Identifying" notify:NotifyNever];
				contentObject.displayContent = NO;
			}
		}
	} else if ([contentObject.source.UID isCaseInsensitivelyEqualToString:@"freenode-connect"] &&
			   [contentObject.chat.account.host rangeOfString:@"freenode.net"].location != NSNotFound) {
		// As a side benefit of having this huge construct here, SHUT UP FREENODE PLEASE.
		contentObject.displayContent = NO; // NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO
	}
}

#pragma mark NickServ passwords
- (void)nickservPasswordReturned:(NSString *)inPassword returnCode:(AIPasswordPromptReturn)returnCode context:(NSDictionary *)inDict
{
	ESIRCAccount *account = [inDict objectForKey:@"Account"];
	NSString	 *displayName = [inDict objectForKey:@"Name"];
	
	AILogWithSignature(@"%@ password returned with any: %d", displayName, inPassword.length > 0);
	
	if (inPassword && inPassword.length) {
		[account setValue:[NSNumber numberWithBool:YES] forProperty:@"Identifying" notify:NotifyNever];
		[(ESIRCAccount *)account identifyForNickServName:displayName password:inPassword];
	}
}

#pragma mark ChanServ passwords

@end
