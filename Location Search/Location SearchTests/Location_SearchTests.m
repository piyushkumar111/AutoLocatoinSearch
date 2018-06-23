//
//  Location_SearchTests.m
//  Location SearchTests
//
//  Created by Piyush Kachariya on 6/2/18.
//  Copyright © 2018 kachariyainfotech. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Constant.h"
#import "VC_Mapview.h"
#import "VC_Search_Page.h"

@interface Location_SearchTests : XCTestCase
{
    VC_Mapview *map_view;
    VC_Search_Page *search_page;
}
@end

@implementation Location_SearchTests

- (void)setUp {
    [super setUp];
    
    map_view = loadViewController(TMStoryboard_Main,@"VC_Mapview");

    search_page = loadViewController(TMStoryboard_Main,@"VC_Search_Page");

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEmptyArrayOnStart {
    XCTAssertFalse(map_view.array_search_result,@"Array is Empty");
}

- (void)testTableviewIsNil {
    XCTAssertFalse(search_page.tblvw_search_result,@"Table is Empty");
}

- (void)testSearchLocationIsNil {
    XCTAssertFalse(search_page.searchbar_top.text = nil,@"Search has no text");
}

- (void)testSearchLocationIsNotNil {
    XCTAssertTrue(search_page.searchbar_top.text = @"test",@"Search has text");
}



@end
