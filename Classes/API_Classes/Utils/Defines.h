
#import "Defines.h"
#import "EnumHeader.h"
#import "Connection.h"
#import "Categories.h"
#import "NRValidation.h"
#import "WebServiceHeader.h"
#import "CoreDataHeaders.h"
#import "SharedClass.h"
#import "ApplicationConstantsHeader.h"
#import "FontHeader.h"
#import "Utils.h"
#import "UIImageView+WebCache.h"
#import "InlineHeader.h"
#import "Location.h"


//Core data


#define GetCustomViewForNib(nibname,index) [[[NSBundle mainBundle] loadNibNamed:nibname owner:self options:nil] objectAtIndex:index]

//User Default
#define UserDefaluts                   [NSUserDefaults standardUserDefaults]

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__) //DLog(...)//dhirendra cahnge
#endif



////////....................Application .......................//////////

#define AppSharedClass [SharedClass sharedInstance]

#define AppThemeColor   Rgb2UIColor(0, 145, 250)
#define AppRedThemeColor Rgb2UIColor(229, 65, 84)
#define AppGreenThemeColor Rgb2UIColor(80, 192, 185)
#define AppOrangeThemeColor Rgb2UIColor(248, 170, 185)
#define AppBlueThemeColor Rgb2UIColor(34, 184, 226)


//.........................................Core Data..................................

#define CurrentUserId [UserModel userId]
#define UserTableEntity   ((UserTable *)[CoreDataHandler getUserEntity])

//EntityName


//.........................................Generic Methods..................................

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define RESIGN_KEYBOARD [[[UIApplication sharedApplication] keyWindow] endEditing:YES];

#define DefaultNavigationHeight 64
#define DefaultTabBarHeight 49
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define CORNER_RADIUS 5.0


static inline double radians (double degrees) {return degrees * M_PI/180;}


inline static NSString * stringValue (id data)
{
    if([data isKindOfClass:[NSString class]])
        return (NSString *)data;
    else if ([data isKindOfClass:[NSNumber class]])
        return ((NSNumber *)data).stringValue;
    else
        return nil;
}

inline static NSNumber * numberValue (id data)
{
    if([data isKindOfClass:[NSNumber class]])
        return (NSNumber *)data;
    else if ([data isKindOfClass:[NSString class]])
        return [NSNumber numberWithFloat:((NSString *)data).floatValue];
    else
        return nil;
}

inline static void SetCornerRadius (UIView *view)
{
    view.layer.cornerRadius = CORNER_RADIUS;
}






