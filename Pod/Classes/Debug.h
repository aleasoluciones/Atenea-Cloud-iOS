//
//  Debug.h
//  seafile
//
//  Created by Wang Wei on 10/8/12.
//  Copyright (c) 2012 Seafile Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP_NAME @"Cloud Drive"


#define API_URL  @"/api2"
#define API_URL_V21  @"/api/v2.1"

#if DEBUG
#define Debug(fmt, args...) NSLog(@"#%d %s %@:" fmt, __LINE__, __FUNCTION__, [NSThread currentThread], ##args)
#else
#define Debug(fmt, args...) do{}while(0)
#endif

#define Info(fmt, args...) NSLog(@"#%d %s %@:" fmt, __LINE__, __FUNCTION__, [NSThread currentThread], ##args)

#define Warning(fmt, args...) NSLog(@"#%d %s:[WARNING]" fmt, __LINE__, __FUNCTION__, ##args)

#define STR_CANCEL NSLocalizedString(@"Cancel", @"Seafile")
static inline BOOL IsIpad()
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

static inline NSString *actionSheetCancelTitle()
{
    return IsIpad() ? nil : STR_CANCEL;
}

#define ios7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define ios8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
#define ios9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9)
#define ios10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)

#define HEADER_HEIGHT    24
#define BAR_COLOR      [UIColor colorWithRed:0.0/255.0 green:173.0/255.0 blue:239.0/255.0 alpha:1.0]
#define HEADER_COLOR    [UIColor colorWithRed:0.0/255.0 green:173.0/255.0 blue:239.0/255.0 alpha:1.0]
#define COLOR_BLUE    [UIColor colorWithRed:0.0/255.0 green:173.0/255.0 blue:239.0/255.0 alpha:1.0]

#define SEAF_COLOR_DARK  [UIColor colorWithRed:0.0/255.0 green:173.0/255.0 blue:239.0/255.0 alpha:1.0]
#define SEAF_COLOR_LIGHT [UIColor colorWithRed:0.0/255.0 green:173.0/255.0 blue:239.0/255.0 alpha:1.0]


static inline NSBundle *SeafileBundle() {
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Seafile" ofType:@"bundle"]];
}
