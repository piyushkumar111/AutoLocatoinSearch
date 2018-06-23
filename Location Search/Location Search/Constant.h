//
//  Constant.h
//  Location Search
//
//  Created by Piyush Kachariya on 6/2/18.
//  Copyright © 2018 kachariyainfotech. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#define getStroyboard(StoryboardWithName) [UIStoryboard storyboardWithName:StoryboardWithName bundle:NULL]
#define loadViewController(StroyBoardName, VCIdentifer) [getStroyboard(StroyBoardName)instantiateViewControllerWithIdentifier:VCIdentifer]

#define TMStoryboard_Main @"Main"

#define kGOOGLE_API_KEY @"AIzaSyAmm1m3lURDNSYyqhOMzrq5U1GA1my2BNQ"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define DISPLAY_ALL @"DISPLAY_ALL"
#define DISPLAY_CENTER @"DISPLAY_CENTER"

#endif /* Constant_h */

