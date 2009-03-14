/* 
 * Adium is the legal property of its developers, whose names are listed in the copyright file included
 * with this source distribution.
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 * Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import "AILaconicaAccountViewController.h"
#import "AILaconicaAccount.h"

@implementation AILaconicaAccountViewController

/*!
 * @brief Configure the account view
 */
- (void)configureForAccount:(AIAccount *)inAccount
{
	[super configureForAccount:inAccount];
	
	textField_server.stringValue = account.host ?: @"";
	[textField_server setEnabled:YES];
	
	textField_APIpath.stringValue = ((AILaconicaAccount *)account).apiPath ?: @"";
	[textField_APIpath setEnabled:YES];
}

/*!
 * @brief The Update Interval combo box was changed.
 */
- (void)saveConfiguration
{
	[super saveConfiguration];

	[account setPreference:textField_server.stringValue
					forKey:LACONICA_PREFERENCE_HOST
					 group:LACONICA_PREF_GROUP];

	[account setPreference:textField_APIpath.stringValue
					forKey:LACONICA_PREFERENCE_APIPATH
					 group:LACONICA_PREF_GROUP];
	
}

@end
